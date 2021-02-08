# Kubernetes

## 1.特性

1. 自动装箱
2. 自我修复
3. 水平扩展
4. 服务发现和负载均衡
5. 自动发布
6. 密钥和配置管理
7. 存储编排
8. 批量处理执行

## 2.环境架构

master/node架构:

- 	master:API Server,Scheduler,Controller-Manager
- 	node:kubelet,容器引擎docker,kube-proxy

Pod,Label,Label Selector

- Label:key=value
- Label Selector

1. 集群:多台主机的安装Kubernetes后,然后把多台主机当成一台主机进行使用,前提是每台主机都要安装相当的应用程序,在软件层面上进行通信从而完成彼此间的协调
2. 主要组件: 
   1. API Server : 负责接收处理请求
   2. Scheduler : 调度容器创建的请求
   3. 控制器:监控容器是否正常
   4. 控制器管理器
   5. label selector
3. pod:
   1. Kubernetes 并不直接调度容器,而是调度的pod,pod是容器是外壳,对容器抽象封装.pod是K8s调度的最小的逻辑单元,用来承载容器
   2. 工作特点:
      1. 共享网络名称空间 net uts ipc
      2. 共享存储卷
      3. 一般情况下一个POD只放一个容器
      4. 同一pod调度到同一node之上时,此时pod上的所有容器只能运行在一个node之上
      5. 同一pod内的多个容器间通信:lo
      6. 各Pod之 间的通信:Overlay Network,叠加网络,隧道转发
      7. Pod与Service之间的通信
   3. 分类
      1. 自主式Pod
      2. 控制器管理的Pod
         1. ReplicationController
         2. 滚动更新
         3. ReplicaSet
         4. Deployment 只管理无状态
         5. StatefulSet 有状态管理
         6. DaemoSet 
         7. Job,Ctonjob
4. node:是工作k8s中的的运行节点,负责运行由master指派的各种工作任务,最核心的是以pod的形式去运行容器的
5. HPA
   - HorizontalPodAutoscaler
6. 网络
   1. CNI:
      - flannel:网络配置
      - calico:网络配置,网络策略
      - canel:网络配置,网络策略
   2. 节点网络
   3. service网络
   4. pod网络
7. 共享存储



## 3.使用kubeadm部署kubernetes环境

- master:安装kubelet,kuadm,docker,kubectl,nodes:安装kubelet,kuadm,docker

- master:kubeadm init

- nodes:kudeadm join

- 步骤

  1. 国内加速镜像安装

     ```
     1.生成yum仓库配置
      先获取docker-ce的配置仓库配置文件：
      # wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O
     /etc/yum.repos.d/
      生成kubernetes的yum仓库配置文件/etc/yum.repos.d/kubernetes.repo，内容如下：
      [kubernetes]
      name=Kubernetes
      baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
      gpgcheck=0
      gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
      enabled=1
      2.配置 /lib/systemd/system/docker.service 
      Environment="HTTPS_PROXY=http://www.ik8s.io:10080" 
      Environment="NO_PROXY=127.0.0.0/8,192.168.52.0/24"
      ExecStartPorts=/usr/sbin/iptables -P FORWORD ACCEPT
      3.安装相关的程序包 
      # yum install docker-ce kubelet kubeadm kubectl
     ```
2. 官网文档安装
  
     ```
     1.修改SElinux配置
     # 将 SELinux 设置为 permissive 模式（相当于将其禁用）
     setenforce 0
     sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
     
     2.安装containerd
     本节包含使用 containerd 作为 CRI 运行时的必要步骤。使用以下命令在系统上安装容器：
     安装和配置的先决条件：
     cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
     overlay
     br_netfilter
     EOF
     sudo modprobe overlay
     sudo modprobe br_netfilter
     # 设置必需的 sysctl 参数，这些参数在重新启动后仍然存在。
     cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
     net.bridge.bridge-nf-call-iptables  = 1
     net.ipv4.ip_forward                 = 1
     net.bridge.bridge-nf-call-ip6tables = 1
     EOF
     # Apply sysctl params without reboot
     sudo sysctl --system
     安装 containerd:
     # 安装 containerd
     ## 设置仓库
     ### 安装所需包
     sudo yum install -y yum-utils device-mapper-persistent-data lvm2
     ### 添加 Docker 仓库
     sudo yum-config-manager \
         --add-repo \
         https://download.docker.com/linux/centos/docker-ce.repo
     ## 安装 containerd
     sudo yum update -y && sudo yum install -y containerd.io
     # 配置 containerd
     sudo mkdir -p /etc/containerd
     containerd config default | sudo tee /etc/containerd/config.toml
     # 重启 containerd
     sudo systemctl restart containerd
     systemd
     结合 runc 使用 systemd cgroup 驱动，在 /etc/containerd/config.toml 中设置
     
     [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
       ...
       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
         SystemdCgroup = true
     
     3.安装cri-o
     安装以及配置的先决条件：
     # 创建 .conf 文件，以便在系统启动时加载内核模块
     cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
     overlay
     br_netfilter
     EOF
     sudo modprobe overlay
     sudo modprobe br_netfilter
     # 设置必需的 sysctl 参数，这些参数在重新启动后仍然存在。
     cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
     net.bridge.bridge-nf-call-iptables  = 1
     net.ipv4.ip_forward                 = 1
     net.bridge.bridge-nf-call-ip6tables = 1
     EOF
     sudo sysctl --system
     
     OS=CentOS_7
     curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:kubic:libcontainers:stable.repo
     VERSION=1.17
     curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo
     yum install cri-o
     
     sudo systemctl daemon-reload
     sudo systemctl start crio
     
     ***** 4.安装Docker ******
     在你的所有节点上安装 Docker CE.
     Kubernetes 发布说明中列出了 Docker 的哪些版本与该版本的 Kubernetes 相兼容。
     在你的操作系统上使用如下命令安装 Docker:
     # (安装 Docker CE)
     ## 设置仓库
     ### 安装所需包
     sudo yum install -y yum-utils device-mapper-persistent-data lvm2
     ### 新增 Docker 仓库
     sudo yum-config-manager --add-repo \
       https://download.docker.com/linux/centos/docker-ce.repo
     ## 安装 Docker CE
     sudo yum update -y && sudo yum install -y \
       containerd.io-1.2.13 \
       docker-ce-19.03.11 \
       docker-ce-cli-19.03.11
     ## 创建 /etc/docker 目录
     sudo mkdir /etc/docker
     # 设置 Docker daemon
     cat <<EOF | sudo tee /etc/docker/daemon.json
     {
       "exec-opts": ["native.cgroupdriver=systemd"],
       "log-driver": "json-file",
       "log-opts": {
         "max-size": "100m"
       },
       "storage-driver": "overlay2",
       "storage-opts": [
         "overlay2.override_kernel_check=true"
       ]
     }
     EOF
     # Create /etc/systemd/system/docker.service.d
     sudo mkdir -p /etc/systemd/system/docker.service.d
     # 配置 containerd
     sudo mkdir -p /etc/containerd
     containerd config default | sudo tee /etc/containerd/config.toml
     # 重启 containerd
     sudo systemctl restart containerd
     systemd
     结合 runc 使用 systemd cgroup 驱动，在 /etc/containerd/config.toml 中设置
     
     [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
       ...
       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
         SystemdCgroup = true
     
     # 重启 Docker
     sudo systemctl daemon-reload
     sudo systemctl restart docker
     如果你想开机即启动 docker 服务，执行以下命令：
     sudo systemctl enable docker
     
     5.配置yum.repo文件
     cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
     [kubernetes]
     name=Kubernetes
     baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
     enabled=1
     gpgcheck=1
     repo_gpgcheck=1
     gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
     EOF
     
     6.允许 iptables 检查桥接流量
     确保 br_netfilter 模块被加载。这一操作可以通过运行 lsmod | grep br_netfilter 来完成。若要显式加载该模块，可执行 sudo modprobe br_netfilter。
     
     为了让你的 Linux 节点上的 iptables 能够正确地查看桥接流量，你需要确保在你的 sysctl 配置中将 net.bridge.bridge-nf-call-iptables 设置为 1。例如：
     
     cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
     br_netfilter
     EOF
     
     cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
     net.bridge.bridge-nf-call-ip6tables = 1
     net.bridge.bridge-nf-call-iptables = 1
     EOF
     sudo sysctl --system
     
     6.使用yum命令安装
     yum install -y kubelet kubeadm kubectl
   ```
  
3. 初始化主节点
  
     ```
     1.配置 /etc/sysconfig/kubelet
     KUBELET_EXTRA_ARGS="--fail-swap-on=false"
     2.配置kubelet自启动
     systemctl enable kubelet
     3.初始化master节点：
      # kubeadm config print --init-defaults
      # kubeadm init --version=当前版本号 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Swap
     遇到的坑:runtime is not runing
     解决 mkdir -p /etc/containerd && containerd config default > /etc/containerd/config.toml
     	systemctl restart containerd.service
      注意：请记录最后的kubeadm join命令的全部内容。要保存下来
     kubeadm join 192.168.52.129:6443 --token 6lg3ya.qmbpzkbmhkgsy3n7 \
         --discovery-token-ca-cert-hash sha256:79ae1ef7976bb25e2a00ffb008bd2f2e197aadd966e541a1e119f12d43a73bc3
     4.初始化kubectl
      mkdir -p $HOME/.kube
      cp /etc/kubernetes/admin.conf $HOME/.kube/
      测试：
      kubectl get componentstatus
      kubectl get nodes    
      遇到的坑
     NAME                 STATUS      MESSAGE                                                                                       ERROR
     controller-manager   Unhealthy   Get "http://127.0.0.1:10252/healthz": dial tcp 127.0.0.1:10252: connect: connection refused   
     scheduler            Unhealthy   Get "http://127.0.0.1:10251/healthz": dial tcp 127.0.0.1:10251: connect: connection refused   
     
     修改 /etc/kubernetes/manifests/kube-controller-manager.yaml
     	/etc/kubernetes/manifests/kube-scheduler.yaml
     中的port=0 这一行删除或注释
     sed -i '/^\s*-\s--port=0$/ d' /etc/kubernetes/manifests/kube-scheduler.yaml
     sed -i '/^\s*-\s--port=0$/ d' /etc/kubernetes/manifests/kube-controller-manager.yaml
     5.添加flannel
     kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
   #查看是否添加成功
     kubectl get pods -n kube-system
    
   ```
  
  4. 加入其它节点
  
     ```
     1.配置 /etc/sysconfig/kubelet
     KUBELET_EXTRA_ARGS="--fail-swap-on=false"
     2.设置开机启动kubelet
     systemctl enable kubelet
     3.复制master上 kubeadm join添加节点
     kubeadm join 192.168.52.129:6443 --token 6lg3ya.qmbpzkbmhkgsy3n7 \
         --discovery-token-ca-cert-hash sha256:79ae1ef7976bb25e2a00ffb008bd2f2e197aadd966e541a1e119f12d43a73bc3 --ignore-preflight-errors=Swap
     4.在master使用kubectl get nodes看是否添加成功
     ```

## 4.kubernets应用管理命令

1. 查

   1. kubectl cluster-info 查看集群信息
   2. kubectl version 查看版本
   3. kubectl get pods 查看pods -o wide查看更多信息
   4. kubectl get nodes 查看nodes
   5. kubectl get deployment 查看当前系统上已经被创建的deployment
   6. kubectl get componentstatus 查看组件
   7. kubectl get pods -n kube-system -o wide 查看coredns
   8. kubectl get svc -n kube-system 查看kube-system名称空间服务
   9. kubectl describe ns/default 查看描述信息
   10. kubectl get ns 查看名称空间
       1. kubectl get ns/default 查看单个名称空间
       2. kubectl get ns/default -o yaml 查看某个名称空间并输出为yaml格式
       3. kubectl get ns/default -o json 查看某个名称空间并输出为json格式
   11. kubectl api-resources 查看当前主机上所支持的资源类型
   12. kubectl get all 查看已创建的所有资源类型

2. 增

   1. kubectl create deployment NAME --image=image -- [COMMAND] [args...] [options] 创建一个deployment控制器,并让其自动创建pod资源

      ```
      kubectl create deploy ngx-dep --image=nginx:1.18.0-alpine -r 2
      ```

   2. kubectl create service clusterip NAME [--tcp=<port>:<targetPort>] [--dry-run=server|client|none] [options] 创建一个service cluster控制器

      ```
      kubectl create service clusterip nginx-svc --tcp=80:80
      ```

   3. kubectl create service nodeport NAME [--tcp=port:targetPort] [--dry-run=server|client|none] [options] 创建一个service nodeport 可以暴露一个对访问的端口

      ```
      kubectl create service nodeport myapp --tcp=80:80 --node-port=32323  //对外的端口范围是30000-32767
      ```

   4. kubectl create namespace name 创建一个名称空间

3. 改

   1. kubectl scale [--resource-version=version] [--current-replicas=count] --replicas=COUNT (-f FILENAME | TYPE NAME) [options] 对某个控制器中的pods扩缩容

      ```
      kubectl scale --replicas=2 deployments myapp
      ```

4. 删

   1. kubectl delete pods nginx-deploy 删除一个 pod
   2. kubectl delete deployment client  删除一个deployment 
   3. kubectl delete svc/myapp 删除一个service
   4. kubectl delete namespace develop 删除一个名称空间 或者 kubectl delete ns/test ns/produce

![](D:\我的坚果云\linux pics\K8S_API_resouces_type.png)

![image-20210122212427534](D:\我的坚果云\linux pics\k8s_components.png)

## 5.资源配置清单

1. 大部分资源的配置清单:

   1. apiVersion:group/version

      $ kubectl api-versions //查看api

   2. kind 资源类别

      1. Deployment
      2. Service
      3. Pod
      4. ReplicaSet
      5. StatefulSet
      6. DaemonSet
      7. Job
      8. CronJob

   3. metadata 元数据

      1. name

      2. namespace

      3. labels

      4. annotatiions

         每个资源的引用PATH

         /api/GROUP/VERSIOIN/namespaces/NAMESPACE/TYPE/NAME

   4. spec 期望状态,disired state

      1. Pod中的spec

         1. containers	<[]Object> -required-

            1. name	<string> -required-

            2. image

            3. imagePullPolicy   Always Never IfNotPresent

            4. ports <[]Object>

               1. name
               2. containerPort	<integer> -required-
               3. hostIP
               4. hostPort

            5. args <[]string>

            6. command <[]string>  Here are some examples:

               | Image Entrypoint | Image Cmd   | Container command | Container args | Command run      |
               | ---------------- | ----------- | ----------------- | -------------- | ---------------- |
               | `[/ep-1]`        | `[foo bar]` | <not set>         | <not set>      | `[ep-1 foo bar]` |
               | `[/ep-1]`        | `[foo bar]` | `[/ep-2]`         | <not set>      | `[ep-2]`         |
               | `[/ep-1]`        | `[foo bar]` | <not set>         | `[zoo boo]`    | `[ep-1 zoo boo]` |
               | `[/ep-1]`        | `[foo bar]` | `[/ep-2]`         | `[zoo boo]`    | `[ep-2 zoo boo]` |

            7. livenessProbe	< Object >

               1. exec  < Object >
               2. httpGet	< Object>
               3. initialDelaySeconds	< integer>
               4. periodSeconds	< integer>
               5. tcpSocket	< Object>

            8. readinessProbe	< Object>
               与livenessProbe中的内容相同

         2. nodeSelector <map[string]string> 节点标签选择器，

         3. nodeName < string > 指定运行的节点

         4. 与label不同的地方在于，它不能用于挑选资源对象，仅用于为对象提供“元数据” 

      kubectl explain 查看如何定义

   5. status 当前状态,current state,本字段由kubernetes集群维护

      namespace示例

      ```
      apiVersion: v1
      kind: Namespace
      metadata: 
      	name: mytest
      ```

      自主式pod示例:

      ```
      apiVersion: v1
      kind: Pod
      metadata:
      	name: mytestpod
      	namespace: mytest
      	labels: 
      		app: mypod
      		teir: frontend
      spec:
      	containers:
      		- name: myapp
      		  image: nginx:1.18.0-alpine
      		  ports: 
      		  - name: http
      		  	containerPort: 80
      		  - name: https
      		  	containerPort: 443
      		- name: busybox
      		  image: busybox:1.32.1
      		  args: ["$(hostname)","$(date)"]
      		  command: 
      		  	- "/bin/sh"
      		  	- "-c"
      		  	- "echo"
      	nodeSelector:
      		app: mypod
      ```

   6. kubectl 清单命令

      1. kubectl apply -f name.yaml 依据一个yaml文件创建或修改pod
      2. kubectl delete -f name.yaml -n namespace 删除一个以yaml文件创建的pod
      3. kubectl label [--overwrite] (-f FILENAME | TYPE NAME) KEY_1=VAL_1 ... KEY_N=VAL_N [--resource-version=version]
      4. kubectl get pods -l <conditions>
         1. =,==,!=
         2. KEY in (VALUE1,VALUE2......)
         3. KEY notin (VALUE1,VALUE2......)
      5. kubectl get pods --show-labels

      许多资源支持内嵌字段定义其使用的标签选择器：

       matchLabels：直接给定键值

       matchExpressions：基于给定的表达式来定义使用标签选择器，{key:"KEY", operator:"OPERATOR",

      values:[VAL1,VAL2,...]}

       操作符：

       In, NotIn：values字段的值必须为非空列表；

       Exists, NotExists：values字段的值必须为空列表；

   7. pod的生命周期

      1. 流程
         1. 初始化
         2. 主容器启动
            1. post start 启动前钩子
            2. 运行中探测
               1. liveness probe
               2. readiness probe
            3. pre stop 结束前钩子
      2. 状态
         1. Pending 挂起
         2. Running 运行
         3. Failed
         4. Successed
         5. Unknow 未知
      3. restartPolicy 容器重启规则
         1. Always
         2. Never
         3. OnFailure