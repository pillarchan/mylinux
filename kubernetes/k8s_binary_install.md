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

### 手动同步时区和时间

```
ln -svf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### 定期任务同步("crontab -e")


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

# 所有节点安装ipvsadm以实现kube-proxy的负载均衡

## 安装ipvsadm等相关工具

```
yum -y install ipvsadm ipset sysstat conntrack libseccomp
```

## 手动加载模块

```
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack #Linux kernel 4.19+版本已经将之前的"nf_conntrack_ipv4"模块更名为"nf_conntrack"模块
```

## 创建要开机自动加载的模块配置文件

```
cat > /etc/modules-load.d/ipvs.conf << 'EOF'
ip_vs
ip_vs_lc
ip_vs_wlc
ip_vs_rr
ip_vs_wrr
ip_vs_lblc
ip_vs_lblcr
ip_vs_dh
ip_vs_sh
ip_vs_fo
ip_vs_nq
ip_vs_sed
ip_vs_ftp
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
EOF
```

# 重启所有节点并检查内核和模块是否配置成功

## 查看现有内核版本

```
uname -r
```

## 检查默认加载的内核版本

```
grubby --default-kernel
```

## 重启所有节点

```
reboot
```

## 检查支持ipvs的内核模块是否加载成功

```
lsmod | grep --color=auto -e ip_vs -e nf_conntrack
```

## 再次查看内核版本

```
uname -r
```



```
- 基础组件安装
	1.所有节点部署docker环境
		1.1 所有节点安装docker
# yum -y install docker-ce-19.03.* 
yum -y localinstall 05-Linux-docker-ce-19_03/*.rpm


		1.2 将docker的CgroupDriver改成systemd，并配置镜像加速和私有镜像仓库地址
mkdir /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": ["https://registry.docker-cn.com","https://tuv7rqqq.mirror.aliyuncs.com"],
  "log-driver": "json-file",
  "log-opts": {"max-size": "200m"},
  "storage-driver": "overlay2"
}
EOF

		1.3 设置开机自启动
systemctl daemon-reload && systemctl enable --now docker
systemctl status docker
docker info | grep "Cgroup Driver"
docker info | grep  "Registry Mirrors" -A 2

		1.4 配置自动补全功能
# yum -y install bash-completion
source /usr/share/bash-completion/bash_completion
	
	
	
	2.部署etcd和K8S程序
		2.1 下载K8S，etcd的软件包
# wget https://dl.k8s.io/v1.23.4/kubernetes-server-linux-amd64.tar.gz

wget https://dl.k8s.io/v1.23.15/kubernetes-server-linux-amd64.tar.gz
wget https://github.com/etcd-io/etcd/releases/download/v3.5.2/etcd-v3.5.2-linux-amd64.tar.gz



		2.2 解压K8S的二进制程序包到PATH环境变量路径（master节点）
# tar -xf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}


tar -xf 06-etcd_k8s/kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}



		2.3 解压etcd的二进制程序包到PATH环境变量路径（master节点）
# tar -xf etcd-v3.5.2-linux-amd64.tar.gz --strip-components=1 -C /usr/local/bin etcd-v3.5.2-linux-amd64/etcd{,ctl}

tar -xf 06-etcd_k8s/etcd-v3.5.2-linux-amd64.tar.gz --strip-components=1 -C /usr/local/bin etcd-v3.5.2-linux-amd64/etcd{,ctl}



		2.4 将组建发送到其他节点
MasterNodes='k8s-master02 k8s-master03'
WorkNodes='k8s-node01 k8s-node02'
for NODE in $MasterNodes; do echo $NODE; scp /usr/local/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy} $NODE:/usr/local/bin/; scp /usr/local/bin/etcd* $NODE:/usr/local/bin/; done
for NODE in $WorkNodes; do     scp /usr/local/bin/kube{let,-proxy} $NODE:/usr/local/bin/ ; done


		2.5 查看kubernetes的版本
kube-apiserver --version
kube-controller-manager --version
kube-scheduler --version
etcdctl version
kubelet --version
kube-proxy --version
kubectl version



		2.6 所有节点创建工作目录
mkdir -p /opt/cni/bin

		2.7 切换分支，版本取决于所部署的K8S版本
git clone https://github.com/dotbalo/k8s-ha-install.git
cd k8s-ha-install/
git checkout manual-installation-v1.23.x
	
	
	
	
	
- 生成K8S集群证书文件
	1.k8s-master01节点下载证书管理工具
		1.1 k8s-master01节点下载证书管理工具(该证书文件可以提前下载好发给大家即可)
# wget "https://pkg.cfssl.org/R1.2/cfssl_linux-amd64" -O /usr/local/bin/cfssl
# wget "https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64" -O /usr/local/bin/cfssljson
# chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson

cp 08-cfssl/* /usr/local/bin
chmod +x /usr/local/bin/{cfssl,cfssljson}


		1.2 所有Master节点创建etcd证书目录
mkdir /etc/etcd/ssl -p

		1.3 所有节点创建kubernetes相关目录
mkdir -p /etc/kubernetes/pki


	2.k8s-master01节点生成etcd证书
		2.1 生成etcd CA证书和CA证书的key
# cd /root/k8s-ha-install/pki
# cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare /etc/etcd/ssl/etcd-ca

cd 07-k8s-ha-install/pki/
cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare /etc/etcd/ssl/etcd-ca

		2.2 颁发证书
cfssl gencert \
   -ca=/etc/etcd/ssl/etcd-ca.pem \
   -ca-key=/etc/etcd/ssl/etcd-ca-key.pem \
   -config=ca-config.json \
   -hostname=127.0.0.1,k8s-master01,k8s-master02,k8s-master03,10.0.0.201,10.0.0.202,10.0.0.203 \
   -profile=kubernetes \
   etcd-csr.json | cfssljson -bare /etc/etcd/ssl/etcd

		2.3 将证书复制到其他节点
MasterNodes='k8s-master02 k8s-master03'

for NODE in $MasterNodes; do
     ssh $NODE "mkdir -p /etc/etcd/ssl"
     for FILE in etcd-ca-key.pem  etcd-ca.pem  etcd-key.pem  etcd.pem; do
       scp /etc/etcd/ssl/${FILE} $NODE:/etc/etcd/ssl/${FILE}
     done
 done



	3.k8s组件apiserver相关证书
		3.1 生成kubernetes证书
# cd /root/k8s-ha-install/pki
# cfssl gencert -initca ca-csr.json | cfssljson -bare /etc/kubernetes/pki/ca

cd 07-k8s-ha-install/pki/
cfssl gencert -initca ca-csr.json | cfssljson -bare /etc/kubernetes/pki/ca

		3.2 生成apiserver的客户端证书
cfssl gencert   -ca=/etc/kubernetes/pki/ca.pem   -ca-key=/etc/kubernetes/pki/ca-key.pem   -config=ca-config.json   -hostname=10.96.0.1,10.0.0.222,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,10.0.0.201,10.0.0.202,10.0.0.203   -profile=kubernetes   apiserver-csr.json | cfssljson -bare /etc/kubernetes/pki/apiserver


		3.3 生成apiserver的聚合证书
cfssl gencert   -initca front-proxy-ca-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-ca 
cfssl gencert   -ca=/etc/kubernetes/pki/front-proxy-ca.pem   -ca-key=/etc/kubernetes/pki/front-proxy-ca-key.pem   -config=ca-config.json   -profile=kubernetes   front-proxy-client-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-client


温馨提示:
	(1)"10.96.0.0"是k8s service的网段，如果说需要更改k8s service网段，那就需要更改"10.96.0.1";
	(2)如果不是高可用集群，10.0.0.250为Master01的IP，我这里这个是高可用的vip;




	4.k8s组件controller manager相关证书
		4.1 生成 controller-manage的证书
cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   manager-csr.json | cfssljson -bare /etc/kubernetes/pki/controller-manager


# 注意，如果不是高可用集群，10.0.0.222:6443改为master01的地址，6443改为apiserver的端口，默认是6443
# set-cluster：设置一个集群项
kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/pki/ca.pem \
     --embed-certs=true \
     --server=https://10.0.0.222:6443 \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# set-credentials 设置一个用户项
kubectl config set-credentials system:kube-controller-manager \
     --client-certificate=/etc/kubernetes/pki/controller-manager.pem \
     --client-key=/etc/kubernetes/pki/controller-manager-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 设置一个环境项，一个上下文
kubectl config set-context system:kube-controller-manager@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-controller-manager \
    --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

# 使用某个环境当做默认环境
kubectl config use-context system:kube-controller-manager@kubernetes \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig




	5.k8s组件scheduler相关证书
cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   scheduler-csr.json | cfssljson -bare /etc/kubernetes/pki/scheduler

# 注意，如果不是高可用集群，10.0.0.222:6443改为master01的地址，6443改为apiserver的端口，默认是6443
kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/pki/ca.pem \
     --embed-certs=true \
     --server=https://10.0.0.222:6443 \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
     --client-certificate=/etc/kubernetes/pki/scheduler.pem \
     --client-key=/etc/kubernetes/pki/scheduler-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config set-context system:kube-scheduler@kubernetes \
     --cluster=kubernetes \
     --user=system:kube-scheduler \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

kubectl config use-context system:kube-scheduler@kubernetes \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig



	6.生成admin的证书
cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   admin-csr.json | cfssljson -bare /etc/kubernetes/pki/admin

# 注意，如果不是高可用集群，10.0.0.222:6443改为master01的地址，6443改为apiserver的端口，默认是6443
kubectl config set-cluster kubernetes     --certificate-authority=/etc/kubernetes/pki/ca.pem     --embed-certs=true     --server=https://10.0.0.222:6443     --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-credentials kubernetes-admin     --client-certificate=/etc/kubernetes/pki/admin.pem     --client-key=/etc/kubernetes/pki/admin-key.pem     --embed-certs=true     --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-context kubernetes-admin@kubernetes     --cluster=kubernetes     --user=kubernetes-admin     --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config use-context kubernetes-admin@kubernetes     --kubeconfig=/etc/kubernetes/admin.kubeconfig



温馨提示:
	我们用同样的命令生成了admin.kubeconfig，scheduler.kubeconfig，controller-manager.kubeconfig，它们之间是如何区分的？
	
	我们生成的证书会定义一个用户 admin，它是属于 system:masters 这个组，k8s 安装的时候会有一个 clusterrole，它是一个集群角色，相当于一个配置，它有着集群最高的管理权限，同时会创建一个 clusterrolebinding，它会把 admin 绑到 system:masters 这个组上，然后这个组上的所有用户都会有这个集群的权限



	7.创建ServiceAccount Key	
		7.1 ServiceAccount是k8s一种认证方式，创建ServiceAccount的时候会创建一个与之绑定的secret，这个secret会生成一个token
openssl genrsa -out /etc/kubernetes/pki/sa.key 2048
openssl rsa -in /etc/kubernetes/pki/sa.key -pubout -out /etc/kubernetes/pki/sa.pub


		7.2 发送证书至其他节点
for NODE in k8s-master02 k8s-master03; 
  do 
	 for FILE in $(ls /etc/kubernetes/pki | grep -v etcd); 
	 do 
		scp /etc/kubernetes/pki/${FILE} $NODE:/etc/kubernetes/pki/${FILE};
	 done; 
	 for FILE in admin.kubeconfig controller-manager.kubeconfig scheduler.kubeconfig; 
	 do 
		scp /etc/kubernetes/${FILE} $NODE:/etc/kubernetes/${FILE};
	 done;
done


		7.3 查看ca证书的有效期
如上图所示，我此处给证书的有效期是100年。
	
	
	
	
	
	
	
- 二进制高可用及etcd配置
	1.创建配置文件
		1.1 k8s-master01节点的配置文件
cat > /etc/etcd/etcd.config.yml <<'EOF'
name: 'k8s-master01'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://10.0.0.201:2380'
listen-client-urls: 'https://10.0.0.201:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://10.0.0.201:2380'
advertise-client-urls: 'https://10.0.0.201:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://10.0.0.201:2380,k8s-master02=https://10.0.0.202:2380,k8s-master03=https://10.0.0.203:2380'
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF


		1.2 k8s-master02节点的配置文件
cat > /etc/etcd/etcd.config.yml << 'EOF'
name: 'k8s-master02'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://10.0.0.202:2380'
listen-client-urls: 'https://10.0.0.202:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://10.0.0.202:2380'
advertise-client-urls: 'https://10.0.0.202:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://10.0.0.201:2380,k8s-master02=https://10.0.0.202:2380,k8s-master03=https://10.0.0.203:2380'
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF


	1.3 k8s-master03节点的配置文件
cat > /etc/etcd/etcd.config.yml << 'EOF'
name: 'k8s-master03'
data-dir: /var/lib/etcd
wal-dir: /var/lib/etcd/wal
snapshot-count: 5000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 0
listen-peer-urls: 'https://10.0.0.203:2380'
listen-client-urls: 'https://10.0.0.203:2379,http://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://10.0.0.203:2380'
advertise-client-urls: 'https://10.0.0.203:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'k8s-master01=https://10.0.0.201:2380,k8s-master02=https://10.0.0.202:2380,k8s-master03=https://10.0.0.203:2380'
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '/etc/kubernetes/pki/etcd/etcd.pem'
  key-file: '/etc/kubernetes/pki/etcd/etcd-key.pem'
  peer-client-cert-auth: true
  trusted-ca-file: '/etc/kubernetes/pki/etcd/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF

	
	
	2.所有节点启动服务
		2.1 创建启动脚本
cat > /usr/lib/systemd/system/etcd.service <<'EOF'
[Unit]
Description=Etcd Service
Documentation=https://coreos.com/etcd/docs/latest/
After=network.target

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd --config-file=/etc/etcd/etcd.config.yml
Restart=on-failure
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
Alias=etcd3.service
EOF


		2.2 启动服务
mkdir /etc/kubernetes/pki/etcd
ln -s /etc/etcd/ssl/* /etc/kubernetes/pki/etcd/
systemctl daemon-reload
systemctl enable --now etcd
systemctl status etcd

		2.3 查看etcd状态
etcdctl --endpoints="10.0.0.201:2379,10.0.0.202:2379,10.0.0.203:2379" --cacert=/etc/kubernetes/pki/etcd/etcd-ca.pem --cert=/etc/kubernetes/pki/etcd/etcd.pem --key=/etc/kubernetes/pki/etcd/etcd-key.pem  endpoint status --write-out=table


	
	
	
	
- 高可用配置（haproxy+keepalived）
	1.所有节点(k8s-master0[1-3])安装keepalived和haproxy
# yum -y install keepalived haproxy 

yum -y localinstall 09-keepalive-haproxy/*.rpm




	2.所有节点(k8s-master0[1-3])配置haproxy，配置文件各个节点相同
		2.1 备份配置文件
cp /etc/haproxy/haproxy.cfg{,`date +%F`}


		2.2 所有节点的配置文件内容相同
cat > /etc/haproxy/haproxy.cfg <<'EOF'
global
  maxconn  2000
  ulimit-n  16384
  log  127.0.0.1 local0 err
  stats timeout 30s

defaults
  log global
  mode  http
  option  httplog
  timeout connect 5000
  timeout client  50000
  timeout server  50000
  timeout http-request 15s
  timeout http-keep-alive 15s

frontend monitor-in
  bind *:33305
  mode http
  option httplog
  monitor-uri /monitor

frontend k8s-master
  bind 0.0.0.0:16443
  bind 127.0.0.1:16443
  mode tcp
  option tcplog
  tcp-request inspect-delay 5s
  default_backend k8s-master

backend k8s-master
  mode tcp
  option tcplog
  option tcp-check
  balance roundrobin
  default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
  server k8s-master01   10.0.0.201:6443  check
  server k8s-master02   10.0.0.202:6443  check
  server k8s-master03   10.0.0.203:6443  check
EOF




	3.所有节点(k8s-master0[1-3])配置keepalived，配置文件各节点不同
		3.1 备份配置文件
cp /etc/keepalived/keepalived.conf{,`date +%F`}

		3.2 "k8s-master01"节点创建配置文件
cat > /etc/keepalived/keepalived.conf <<'EOF'
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
script_user root
    enable_script_security
}
vrrp_script chk_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 5
    weight -5
    fall 2  
    rise 1
}
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    mcast_src_ip 10.0.0.201
    virtual_router_id 51
    priority 101
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        10.0.0.222
    }
    track_script {
       chk_apiserver
    }
}
EOF


		3.3 "k8s-master02"节点创建配置文件
cat > /etc/keepalived/keepalived.conf <<'EOF'
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
script_user root
    enable_script_security
}
vrrp_script chk_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 5
    weight -5
    fall 2  
    rise 1
}
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    mcast_src_ip 10.0.0.202
    virtual_router_id 51
    priority 101
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        10.0.0.222
    }
    track_script {
       chk_apiserver
    }
}
EOF

		3.4 "k8s-master03"节点创建配置文件
cat > /etc/keepalived/keepalived.conf <<'EOF'
! Configuration File for keepalived
global_defs {
    router_id LVS_DEVEL
script_user root
    enable_script_security
}
vrrp_script chk_apiserver {
    script "/etc/keepalived/check_apiserver.sh"
    interval 5
    weight -5
    fall 2  
    rise 1
}
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    mcast_src_ip 10.0.0.203
    virtual_router_id 51
    priority 101
    advert_int 2
    authentication {
        auth_type PASS
        auth_pass K8SHA_KA_AUTH
    }
    virtual_ipaddress {
        10.0.0.222
    }
    track_script {
       chk_apiserver
    }
}
EOF


		3.4 所有节点(k8s-master0[1-3])配置KeepAlived健康检查文件
			3.4.1 创建检查脚本
cat > /etc/keepalived/check_apiserver.sh <<'EOF'
#!/bin/bash

err=0
for k in $(seq 1 3)
do
    check_code=$(pgrep haproxy)
    if [[ $check_code == "" ]]; then
        err=$(expr $err + 1)
        sleep 1
        continue
    else
        err=0
        break
    fi
done

if [[ $err != "0" ]]; then
    echo "systemctl stop keepalived"
    /usr/bin/systemctl stop keepalived
    exit 1
else
    exit 0
fi
EOF


			3.4.2 添加执行权限
chmod +x /etc/keepalived/check_apiserver.sh

温馨提示:
	(1)我们通过KeepAlived虚拟出来一个VIP，VIP会配置到一个master节点上面，它会通过haproxy暴露的16443的端口反向代理到我们的三个master节点上面，所以我们可以通过VIP的地址加上16443访问到我们的API server;
	(2)健康检查会检查haproxy的状态，三次失败就会将KeepAlived停掉，停掉之后KeepAlived会跳到其他的节点;





	5.所有master节点启动服务
		5.1 启动harproxy
systemctl daemon-reload
systemctl enable --now haproxy

		5.2 启动keepalived
systemctl enable --now keepalived

		5.3 查看VIP，如上图所示
ip a





二进制K8s master组件配置
	1.所有节点(k8s-master0[1-3])Apiserver服务启动
		1.1 所有节点(k8s-master0[1-3])创建工作目录
mkdir -p /etc/kubernetes/manifests/ /etc/systemd/system/kubelet.service.d /var/lib/kubelet /var/log/kubernetes


		1.2 k8s-master01节点创建配置文件
cat > /usr/lib/systemd/system/kube-apiserver.service << 'EOF'
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
      --v=2  \
      --logtostderr=true  \
      --allow-privileged=true  \
      --bind-address=0.0.0.0  \
      --secure-port=6443  \
      --insecure-port=0  \
      --advertise-address=10.0.0.201 \
      --service-cluster-ip-range=10.96.0.0/12  \
      --service-node-port-range=3000-50000  \
      --etcd-servers=https://10.0.0.201:2379,https://10.0.0.202:2379,https://10.0.0.203:2379 \
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \
      --enable-bootstrap-token-auth=true  \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \
      --requestheader-allowed-names=aggregator  \
      --requestheader-group-headers=X-Remote-Group  \
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \
      --requestheader-username-headers=X-Remote-User
      # --token-auth-file=/etc/kubernetes/token.csv

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


		1.3 k8s-master02节点创建配置文件
cat > /usr/lib/systemd/system/kube-apiserver.service <<'EOF'
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
      --v=2  \
      --logtostderr=true  \
      --allow-privileged=true  \
      --bind-address=0.0.0.0  \
      --secure-port=6443  \
      --insecure-port=0  \
      --advertise-address=10.0.0.202 \
      --service-cluster-ip-range=10.96.0.0/12  \
      --service-node-port-range=3000-50000  \
      --etcd-servers=https://10.0.0.201:2379,https://10.0.0.202:2379,https://10.0.0.203:2379 \
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \
      --enable-bootstrap-token-auth=true  \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \
      --requestheader-allowed-names=aggregator  \
      --requestheader-group-headers=X-Remote-Group  \
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \
      --requestheader-username-headers=X-Remote-User
      # --token-auth-file=/etc/kubernetes/token.csv

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


		1.4 k8s-master03节点创建配置文件
cat > /usr/lib/systemd/system/kube-apiserver.service << 'EOF'
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
      --v=2  \
      --logtostderr=true  \
      --allow-privileged=true  \
      --bind-address=0.0.0.0  \
      --secure-port=6443  \
      --insecure-port=0  \
      --advertise-address=10.0.0.203 \
      --service-cluster-ip-range=10.96.0.0/12  \
      --service-node-port-range=3000-50000  \
      --etcd-servers=https://10.0.0.201:2379,https://10.0.0.202:2379,https://10.0.0.203:2379 \
      --etcd-cafile=/etc/etcd/ssl/etcd-ca.pem  \
      --etcd-certfile=/etc/etcd/ssl/etcd.pem  \
      --etcd-keyfile=/etc/etcd/ssl/etcd-key.pem  \
      --client-ca-file=/etc/kubernetes/pki/ca.pem  \
      --tls-cert-file=/etc/kubernetes/pki/apiserver.pem  \
      --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem  \
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver.pem  \
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-key.pem  \
      --service-account-key-file=/etc/kubernetes/pki/sa.pub  \
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key  \
      --service-account-issuer=https://kubernetes.default.svc.cluster.local \
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname  \
      --enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,ResourceQuota  \
      --authorization-mode=Node,RBAC  \
      --enable-bootstrap-token-auth=true  \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem  \
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.pem  \
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client-key.pem  \
      --requestheader-allowed-names=aggregator  \
      --requestheader-group-headers=X-Remote-Group  \
      --requestheader-extra-headers-prefix=X-Remote-Extra-  \
      --requestheader-username-headers=X-Remote-User
      # --token-auth-file=/etc/kubernetes/token.csv

Restart=on-failure
RestartSec=10s
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


		1.5 启动服务
systemctl daemon-reload && systemctl enable --now kube-apiserver && systemctl status kube-apiserver



	2.所有节点(k8s-master0[1-3])ControllerManager服务启动
		2.1 所有节点创建配置文件
cat > /usr/lib/systemd/system/kube-controller-manager.service << 'EOF'
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
      --v=2 \
      --logtostderr=true \
      --address=127.0.0.1 \
      --root-ca-file=/etc/kubernetes/pki/ca.pem \
      --cluster-signing-cert-file=/etc/kubernetes/pki/ca.pem \
      --cluster-signing-key-file=/etc/kubernetes/pki/ca-key.pem \
      --service-account-private-key-file=/etc/kubernetes/pki/sa.key \
      --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \
      --leader-elect=true \
      --use-service-account-credentials=true \
      --node-monitor-grace-period=40s \
      --node-monitor-period=5s \
      --pod-eviction-timeout=2m0s \
      --controllers=*,bootstrapsigner,tokencleaner \
      --allocate-node-cidrs=true \
      --cluster-cidr=172.16.0.0/12 \
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.pem \
      --node-cidr-mask-size=24
      
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

		2.2启动服务，查看状态如上图所示
systemctl daemon-reload
systemctl enable --now kube-controller-manager
systemctl  status kube-controller-manager



	3.所有节点(k8s-master0[1-3])Scheduler服务启动
		3.1 所有节点创建配置文件
cat > /usr/lib/systemd/system/kube-scheduler.service <<'EOF'
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
After=network.target

[Service]
ExecStart=/usr/local/bin/kube-scheduler \
      --v=2 \
      --logtostderr=true \
      --address=127.0.0.1 \
      --leader-elect=true \
      --kubeconfig=/etc/kubernetes/scheduler.kubeconfig

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF



		3.2 启动服务并查看状态，如上图所示
systemctl daemon-reload
systemctl enable --now kube-scheduler
systemctl  status kube-scheduler


	
	4.检查组件是否正常
[root@k8s-master01 pki]# kubectl  get cs --kubeconfig=/etc/kubernetes/admin.kubeconfig 
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
scheduler            Healthy   ok                              
controller-manager   Healthy   ok                              
etcd-1               Healthy   {"health":"true","reason":""}   
etcd-0               Healthy   {"health":"true","reason":""}   
etcd-2               Healthy   {"health":"true","reason":""}   
[root@k8s-master01 pki]# 






- 创建Bootstrapping自动颁发证书
	1.k8s-master01节点创建bootstrap-kubelet.kubeconfig文件
# cd /root/k8s-ha-install/bootstrap


cd 07-k8s-ha-install/bootstrap/

kubectl config set-cluster kubernetes     --certificate-authority=/etc/kubernetes/pki/ca.pem     --embed-certs=true     --server=https://10.0.0.222:6443     --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
kubectl config set-credentials tls-bootstrap-token-user     --token=c8ad9c.2e4d610cf3e7426e --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
kubectl config set-context tls-bootstrap-token-user@kubernetes     --cluster=kubernetes     --user=tls-bootstrap-token-user     --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig
kubectl config use-context tls-bootstrap-token-user@kubernetes     --kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig


		温馨提示:
			"bootstrap-kubelet.kubeconfig"是一个keepalived用来向apiserver申请证书的文件，如果要修改bootstrap.secret.yaml的token-id和token-secret，需要保证c8ad9c字符串一致的，并且位数是一样的。还要保证上个命令的黄色字体：c8ad9c.2e4d610cf3e7426e与你修改的字符串要一致


	2.所有master节点拷贝管理证书
mkdir -p /root/.kube ; cp /etc/kubernetes/admin.kubeconfig /root/.kube/config

	3.创建bootstrap
kubectl create -f bootstrap.secret.yaml





- 部署Node节点
	1.拷贝证书
cd /etc/kubernetes/
for NODE in k8s-master02 k8s-master03 k8s-node01 k8s-node02; do
     ssh $NODE mkdir -p /etc/kubernetes/pki /etc/etcd/ssl /etc/etcd/ssl
     for FILE in etcd-ca.pem etcd.pem etcd-key.pem; do
       scp /etc/etcd/ssl/$FILE $NODE:/etc/etcd/ssl/
     done
     for FILE in pki/ca.pem pki/ca-key.pem pki/front-proxy-ca.pem bootstrap-kubelet.kubeconfig; do
       scp /etc/kubernetes/$FILE $NODE:/etc/kubernetes/${FILE}
done
done


	温馨提示:
		node节点使用自动颁发证书的形式配置



	2.Kubelet配置
		2.1 所有节点创建工作目录
mkdir -p /var/lib/kubelet /var/log/kubernetes /etc/systemd/system/kubelet.service.d /etc/kubernetes/manifests/


		2.2 所有节点配置kubelet service
cat >  /usr/lib/systemd/system/kubelet.service <<'EOF'
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF


		2.3所有节点配置kubelet service的配置文件
cat > /etc/systemd/system/kubelet.service.d/10-kubelet.conf <<'EOF'
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.kubeconfig --kubeconfig=/etc/kubernetes/kubelet.kubeconfig"
Environment="KUBELET_SYSTEM_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
Environment="KUBELET_CONFIG_ARGS=--config=/etc/kubernetes/kubelet-conf.yml --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.2"
Environment="KUBELET_EXTRA_ARGS=--node-labels=node.kubernetes.io/node='' "
ExecStart=
ExecStart=/usr/local/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_SYSTEM_ARGS $KUBELET_EXTRA_ARGS
EOF



		2.4 所有创建kubelet的配置文件
cat > /etc/kubernetes/kubelet-conf.yml <<'EOF'
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.pem
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s
cgroupDriver: systemd
cgroupsPerQOS: true
clusterDNS:
- 10.96.0.10
clusterDomain: oldboyedu.com
containerLogMaxFiles: 5
containerLogMaxSize: 10Mi
contentType: application/vnd.kubernetes.protobuf
cpuCFSQuota: true
cpuManagerPolicy: none
cpuManagerReconcilePeriod: 10s
enableControllerAttachDetach: true
enableDebuggingHandlers: true
enforceNodeAllocatable:
- pods
eventBurst: 10
eventRecordQPS: 5
evictionHard:
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
evictionPressureTransitionPeriod: 5m0s
failSwapOn: true
fileCheckFrequency: 20s
hairpinMode: promiscuous-bridge
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 20s
imageGCHighThresholdPercent: 85
imageGCLowThresholdPercent: 80
imageMinimumGCAge: 2m0s
iptablesDropBit: 15
iptablesMasqueradeBit: 14
kubeAPIBurst: 10
kubeAPIQPS: 5
makeIPTablesUtilChains: true
maxOpenFiles: 1000000
maxPods: 110
nodeStatusUpdateFrequency: 10s
oomScoreAdj: -999
podPidsLimit: -1
registryBurst: 10
registryPullQPS: 5
resolvConf: /etc/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 2m0s
serializeImagePulls: true
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 4h0m0s
syncFrequency: 1m0s
volumeStatsAggPeriod: 1m0s
EOF

		2.5 启动所有节点kubelet
systemctl daemon-reload
systemctl enable --now kubelet
systemctl status kubelet


		2.6 在master101节点上查看node信息，如上图所示。
kubectl get nodes


	3.kube-proxy配置
		3.1 在“k8s-master01”节点生成"/etc/kubernetes/kube-proxy.kubeconfig"配置文件
# cd /root/k8s-ha-install

cd 07-k8s-ha-install/

kubectl -n kube-system create serviceaccount kube-proxy
kubectl create clusterrolebinding system:kube-proxy         --clusterrole system:node-proxier         --serviceaccount kube-system:kube-proxy
SECRET=$(kubectl -n kube-system get sa/kube-proxy \
    --output=jsonpath='{.secrets[0].name}')
JWT_TOKEN=$(kubectl -n kube-system get secret/$SECRET \
--output=jsonpath='{.data.token}' | base64 -d)
PKI_DIR=/etc/kubernetes/pki
K8S_DIR=/etc/kubernetes
kubectl config set-cluster kubernetes     --certificate-authority=/etc/kubernetes/pki/ca.pem     --embed-certs=true     --server=https://10.0.0.222:6443     --kubeconfig=${K8S_DIR}/kube-proxy.kubeconfig
kubectl config set-credentials kubernetes     --token=${JWT_TOKEN}     --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
kubectl config set-context kubernetes     --cluster=kubernetes     --user=kubernetes     --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig
kubectl config use-context kubernetes     --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig


		3.2 在“k8s-master01”将kube-proxy的systemd Service文件发送到其他节点
for NODE in k8s-master01 k8s-master02 k8s-master03 k8s-node01 k8s-node02; do
     scp /etc/kubernetes/kube-proxy.kubeconfig $NODE:/etc/kubernetes/kube-proxy.kubeconfig
done


		3.3 所有节点创建kube-proxy.conf配置文件
cat > /etc/kubernetes/kube-proxy.conf << EOF
KUBE_PROXY_OPTS="--logtostderr=false \\
	--v=2 \\
	--log-dir=/var/log/kubernetes/ \\
	--config=/etc/kubernetes/kube-proxy-config.yml"
EOF
 
 
# 注意修改各个节点的"hostnameOverride"的值哟
cat > /etc/kubernetes/kube-proxy-config.yml << EOF
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
metricsBindAddress: 0.0.0.0:10249
clientConnection:
 kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
hostnameOverride: k8s-master01
clusterCIDR: 172.30.0.0/16
EOF

 
		3.4 所有节点使用systemd管理kube-proxy
cat > /usr/lib/systemd/system/kube-proxy.service << EOF
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=/etc/kubernetes/kube-proxy.conf
ExecStart=/usr/local/bin/kube-proxy \$KUBE_PROXY_OPTS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
 
 
		3.4 所有节点启动kube-proxy
systemctl daemon-reload
systemctl enable --now kube-proxy
systemctl status kube-proxy



温馨提示:
	如果更改了集群Pod的网段，需要更改kube-proxy.conf的clusterCIDR参数，比如我上面的案例自定义的网段为"172.30.0.0/16"。
```

