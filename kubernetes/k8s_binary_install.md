# 架构

## Master(Controll Panel)

### 组件：

api-server

etcd

manager-controler

scheduler

## Slave(Worker)

kubelet

kubeproxy

https://landscape.cncf.io



# 机器(镜像centos9)

| 名称         | IP             |
| ------------ | -------------- |
| master_node1 | 192.168.76.140 |
| master_node2 | 192.168.76.141 |
| master_node3 | 192.168.76.142 |
| worker_node1 | 192.168.76.143 |
| worker_node2 | 192.168.76.144 |

# 预安装的软件

yum -y install bind-utils expect rsync wget jq psmisc vim net-tools telnet yum-utils device-mapper-persistent-data lvm2 git ntpdate

dnf -y install bind-utils expect  net-tools rsync wget telnet git

# 机器解析

每个节点

```
cat >> /etc/hosts << EOF
192.168.76.140 centos9k8s_master_node1
192.168.76.141 centos9k8s_master_node2
192.168.76.142 centos9k8s_master_node3
192.168.76.143 centos9k8s_worker_node1
192.168.76.144 centos9k8s_worker_node2
EOF
```

# 免密登录

```
cat > password_free_login.sh <<'EOF'
#!/bin/bash
ssh-keygen -t rsa -P "" -f /path/name_rsa -q
EOF
```

# 所有节点升级Linux内核

安装

```
http://elrepo.org/tiki/tiki-index.php

# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm

# 安装 最新版ML 版本
# yum --enablerepo=elrepo-kernel install  kernel-ml-devel kernel-ml -y
# 安装 最新版LT 版本
# yum --enablerepo=elrepo-kernel install kernel-lt-devel kernel-lt -y
```

更改内核启动顺序

```
grub2-set-default  0 && grub2-mkconfig -o /etc/grub2.cfg
grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"
grubby --default-kernel
```

更新软件版本，但不需要更新内核，因为我内核已经更新到了指定的版本

```
# yum -y update --exclude=kernel* 
yum -y localinstall 03-Linux-yum-update/*.rpm
```

# Linux基础环境优化

## 所有节点关闭firewalld，selinux，NetworkManager

```
systemctl disable --now firewalld 
systemctl disable --now NetworkManager
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/sysconfig/selinux
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
```

## 所有节点关闭swap分区，fstab注释swap


	swapoff -a && sysctl -w vm.swappiness=0
	sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
	free -h
## 所有节点同步时间 

	- 手动同步时区和时间


	ln -svf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
- 定期任务同步("crontab -e")

	# centos 7
	ntpdate ntp.aliyun.com
	*/5 * * * * /usr/sbin/ntpdate ntp.aliyun.com
	# centos 9
	vim /etc/chrony.conf
	systemctl restart chronyd.service
## 所有节点配置limit


	cat >> /etc/security/limits.conf <<'EOF'
	* soft nofile 655360
	* hard nofile 131072
	* soft nproc 655350
	* hard nproc 655350
	* soft memlock unlimited
	* hard memlock unlimited
	EOF
## 所有节点优化sshd服务


	sed -i 's@#UseDNS yes@UseDNS no@g' /etc/ssh/sshd_config
	sed -i 's@^GSSAPIAuthentication yes@GSSAPIAuthentication no@g' /etc/ssh/sshd_config
		- UseDNS选项:
	打开状态下，当客户端试图登录SSH服务器时，服务器端先根据客户端的IP地址进行DNS PTR反向查询出客户端的主机名，然后根据查询出的客户端主机名进行DNS正向A记录查询，验证与其原始IP地址是否一致，这是防止客户端欺骗的一种措施，但一般我们的是动态IP不会有PTR记录，打开这个选项不过是在白白浪费时间而已，不如将其关闭。
	
		- GSSAPIAuthentication:
	当这个参数开启（ GSSAPIAuthentication  yes ）的时候，通过SSH登陆服务器时候会有些会很慢！这是由于服务器端启用了GSSAPI。登陆的时候客户端需要对服务器端的IP地址进行反解析，如果服务器的IP地址没有配置PTR记录，那么就容易在这里卡住了。
## Linux内核调优

	cat > /etc/sysctl.d/k8s.conf <<'EOF'
	net.ipv4.tcp_fin_timeout = 6
	net.ipv4.tcp_tw_reuse = 1
	net.ipv4.tcp_tw_recycle = 1
	net.ipv4.tcp_syncookies = 1
	net.ipv4.tcp_keepalive_time = 600
	net.ipv4.tcp_max_syn_backlog = 1024
	net.ipv4.tcp_max_tw_buckets = 36000
	net.ipv4.route.gc_timeout = 100
	net.ipv4.tcp_syn_retries = 2
	net.ipv4.tcp_synack_retries = 2
	net.ipv4.tcp_max_orphans = 327680
	net.core.somaxconn = 1024
	net.core.netdev_max_backlog = 1024
	net.ipv4.ip_forward = 1
	net.bridge.bridge-nf-call-iptables = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	net.ipv6.conf.all.disable_ipv6 = 1
	fs.may_detach_mounts = 1
	vm.overcommit_memory=1
	vm.panic_on_oom=0
	fs.inotify.max_user_watches=89100
	fs.file-max=52706963
	fs.nr_open=52706963
	net.netfilter.nf_conntrack_max=2310720
	net.ipv4.tcp_keepalive_probes = 3
	net.ipv4.tcp_keepalive_intvl =15
	net.ipv4.tcp_orphan_retries = 3
	net.ipv4.ip_conntrack_max = 65536
	net.ipv4.tcp_timestamps = 0
	EOF
	sysctl --system

## 	修改终端颜色

	cat >>  ~/.bashrc <<EOF 
	PS1='[\[\e[34;1m\]\u@\[\e[0m\]\[\e[32;1m\]\H\[\e[0m\]\[\e[36;1m\] \W\[\e[0m\]]# '
	EOF
	source ~/.bashrc
	
	echo "PS1='[\[\e[34;1m\]\u@\[\e[0m\]\[\e[32;1m\]\H\[\e[0m\]\[\e[36;1m\] \W\[\e[0m\]]# '" > /etc/profile.d/mycolor.sh
	source /etc/profile.d/mycolor.sh


