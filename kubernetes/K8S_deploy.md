# 架构

## master 节点 

控制K8S集群 可以基于kubeadmin 管理集群

更名为Control Plan

监听端口 api server 组件 用于集群的访问入口

​	认证 权限检验 配置文件解析

​    基于etcd存储数据   api-server->etcd 

   control manager 控制管理集群 维护服务的状态 api-server<->control manager 

   scheduler 用于调度任务 api-server <-> scheduler 



## slave 节点 

k8s 实际工作的节点 

更名为Node (Worker)

### kubelet 

维护pod的生命周期

​	pod里面运行的实际业务

​		pod里面运行容器 ，默认共享网络空间  ipc net uts

​			ipc 进程间通信

​			mnt 存储卷挂载相关

​			**net** 网络相关

​            pid 进程相关

​			user 用户空间

​			uts 主机域名相关

​         cadvisor 容器监控工具 将采集到的数据返回给api server  并存储到 etcd

### kubeproxy

为外部访问提供访问路由 早期基于iptables实现，1.5版本基于ipvs

## container network interface

简称CNI 提供跨节点容器网络通信的网络接口 

经典代表

Flannel

Calico

![image-20240621122453040](D:\learn\mylinux\kubernetes\image-20240621122453040.png)



由于k8s大部分的服务都基于 api server，就应该要考虑使用集群来实现高可用



CRI

Container runtime inferface 容器运行接口 符合CRI的接口的容器均可以运行在K8S集群上。

​	Kubelet调用docker-shrim组件就可以创建docker 

​    但由于docker-shirm组件被弃用， k8s 在1.24版本就不支持docker

​    取而代之的是   cri-containerd

​	该组件就可以直接创建容器运行服务

​    但是docker-shirm还是被 docker公司接管维护，但是需要单独安装 

## control plan集群架构

control plan 集群(api server,controller manager,scheduler,etcd)<-> load balance<-> worker node	

# 部署

## 使用k8sadmin安装

### 1.环境准备

#### 关闭swap分区

```
临时关闭
swapoff -a && sysctl -w vm.swappiness=0
基于配置文件关闭
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab
```

#### 确保各个节点MAC地址或product_uuid唯一

```
cat /sys/class/dmi/id/product_uuid 
```

#### 检查网络节点是否互通

```
简而言之，就是检查你的k8s集群各节点是否互通，可以使用ping命令来测试。
```

#### 允许iptable检查桥接流量

```
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

#### 禁用防火墙

```
systemctl disable --now firewalld
```

#### 禁用selinux

```
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config 
grep ^SELINUX= /etc/selinux/config
```

#### 配置host解析

```
cat >> /etc/hosts <<'EOF'
192.168.76.142 centos79k8s1
192.168.76.143 centos79k8s2
192.168.76.144 centos79k8s3
192.168.76.141 harbor.myharbor.com
EOF
cat /etc/hosts
```



### 2.所有节点安装docker

#### 添加docker yum repo源

```
yum-config-manager \
        --add-repo \
    https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo	
```

#### 修改为国内镜像源

```
sed -i 's@https://download.docker.com@https://mirrors.tuna.tsinghua.edu.cn/docker-ce@g' /etc/yum.repos.d/docker-ce.repo
```

#### 选择安装版本

```
yum list docker-ce --showduplicate 

yum -y install docker-ce-20.10.24 docker-ce-cli-20.10.24
```

#### 修改配置文件

```
mkdir -pv /etc/docker
cat > /etc/docker/daemon.json << EOF
 {
    "registry-mirrors":["https://docker.gs","https://60lgfq0t.mirror.aliyuncs.com","https://dockerproxy.com"],
    "exec-opts": ["native.cgroupdriver=systemd"]
 }
EOF
```

#### 拷贝证书

```
mkdir -pv /etc/docker/certs.d/harbor.myharbor.com
scp /etc/docker/certs.d/harbor.myharbor.com/* 192.168.76.142:/etc/docker/certs.d/harbor.myharbor.com
```

#### 验证登录harbor

```
docker login -u admin -p Harbor12345 harbor.myharbor.com
```

#### 启动docker

```
systemctl enable --now docker
```

### 3.所有节点安装kubeadm，kubelet，kubectl

#### (1)配置软件源

```
cat  > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
```

#### 查看版本

```
yum list kubeadm --showduplicates
如果不想单独安装docker-shirm又要使用docker就安装1.24之前的版本
```

#### 安装kubeadm，kubelet，kubectl

```
yum -y install kubeadm-1.23.17-0 kubelet-1.23.17-0 kubectl-1.23.17-0 
```

#### 启动kubelet

```
systemctl enable --now kubelet
(若服务启动失败时正常现象，其会自动重启，因为缺失配置文件，初始化集群后恢复！此步骤可跳过！)
```

### 4.初始化control plan节点

	kubeadm init --kubernetes-version=v1.23.17 --image-repository registry.aliyuncs.com/google_containers  --pod-network-cidr=10.100.0.0/16 --service-cidr=10.200.0.0/16  --service-dns-domain=myharbor.com
	
	相关参数说明:
		--kubernetes-version:
			指定K8S master组件的版本号。
	--image-repository:
		指定下载k8s master组件的镜像仓库地址。
		
	--pod-network-cidr:
		指定Pod的网段地址。
		
	--service-cidr:
		指定SVC的网段
	
	--service-dns-domain:
		指定service的域名。若不指定，默认为"cluster.local"。
		
	执行成功后，会有后续操作信息，复制执行就可以了
	
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config 
	
	主节点
	kubectl get nodes
	kubectl get cs 或 kubectl get componentstatus

### 5.添加control plan从节点

```
Then you can join any number of worker nodes by running the following on each as root:、
kubeadm join 192.168.76.142:6443 --token y19o52.jbjfcp5wfgfmy4f6 \
	--discovery-token-ca-cert-hash sha256:e44b0ea6efba9e95a768cef520aa2bbe3c01a0b6f31afc2d55e3f0a7fbbc9ee5
此处命令用于添加control plan的集群节点复制到其它节点机器执行即可。


主节点使用kubectl get nodes 查看
```

### 6.安装flannel插件

```
https://kubernetes.io/docs/concepts/cluster-administration/addons/

For Kubernetes v1.17+
Deploying Flannel with kubectl
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
注意：此方法可能需要翻墙操作

将kube-flannel.yml 下载后根据实际情况进行修改
如： net-conf.json 因为初始化的时候，看是否有指定pod-network-cidr
image 的镜像版本及地址

```

### 7.添加kubectl的自动补全功能

```
echo "source <(kubectl completion bash)" >> ~/.bashrc && source ~/.bashrc
```

# 总结

```
	- harbor基于https的部署
		- 自建CA证书
		- 基于自建证书创建docker engine的证书
		- 创建harbor客户端证书
		- 修改配置文件并启动服务
	
	- kubernetes的架构
		- Control Plane:
			控制K8S集群的组件。
			- Api Server:
				集群的访问入口。
			- etcd:
				存储集群的数据。一般情况下，只有API-SERVER会访问.
			- Control Manager:
				维护集群的状态。
			- Scheduler:
				负责Pod的调度功能。

		- Worker Node:
			实际运行业务的组件。
			- kubelet:
				管理Pod的生命周期，并上报Pod和节点的状态。
			- kube-proxy:
				对K8S集群外部提供访问路由。底层可以基于iptables或者ipvs实现。
				
	- Kubernetes的常见术语
		- CNI：
			Container Network Interface
			容器网络插件，主要用于跨节点的容器进行通信的组件。
		- CRI:
			Container Runtime Interface
			容器运行接口，主要用于kubelet调用容器的生命周期管理相关即可。
			docker-shim ---&gt; cir-dockerd，在K8S 1.24已经弃用！
			若更高版本想要使用docker，需要单独部署docker-shim组件即可。

	- Kubernetes部署方式
		- kubeadm:
			快速构建K8S集群，需要单独安装docker,kubectl,kubeadm,kubelet。
			基于容器快速部署K8S集群。
		
		- 二进制部署:
			需要去官方下载最新的二进制软件包，编写启动脚本。
			
	- kubernetes的高可用架构设计
```

