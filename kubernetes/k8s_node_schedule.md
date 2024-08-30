# 节点调度

```
昨日内容回顾:
	- rs的升级和回滚
	- deployment:
		- 升级策略（strategy）
			-type:
				- Recreate
				- RollingUpdate
			- rollingUpdate
				- maxSurge
				- maxUnavailable
				
		- 升级方式:
			- 声明式升级:
				kubectl apply -f ...
			- 响应式升级:
				kubectl set image
				kubectl edit deployment ...
				
		- 发布策略:
			- 蓝绿发布:
			- 灰度发布:
			
		- 应用案例:
			- wordpress
			- redis			
	- services:
		- NodePort
		- ClusterIP		
	- coreDNS:
		将svc解析为clusterIP。		
	- Job
		一次性任务	
	- CronJob
		周期性任务，底层调用的Job控制器。		
故障案例1:
	- wordPress连接MySQL一直出现连接数据库失败。
		- 检查K8S集群是否健康
			kubectl get cs,no
			kubectl get pods -A | grep flannel
			kubectl get pods -A | grep kube-proxy
			kubectl get pods -A | grep -i coredns
		- 检查db对应svc是否关联pod
			kubectl describe svc ...
		- 检查pod是否正常工作
			kubectl exec -it ...
		- 检查存储卷
			删除MySQL数据目录对应nfs。删除后重新创建即可。
			如果还不行，建议更换MySQL 5.7			
故障案例2:
	k8s232节点可以正常运行Pod，k8s233无法正常运行pod，报错是挂载失败。
		- 手动挂载:
			mount -t nfs 10.0.0.231:/myharbor/data/kubernetes /mnt
		
		- 安装nfs依赖:
			yum -y install nfs-utils
故障案例3:
	svc关联pod失败。
		- svc的标签选择器有6个。
		- Pod仅包含了1个。
		综上所述: Pod的标签数必须包含svc所关联的标签，只能多不能少。

Pod的反亲和性:
[root@k8s231.oldboyedu.com podAntiAffinity]# cat 01-deploy-web.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-linux85-podantiaffinity
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  template:
    metadata:
      labels:
        apps: linux85-web
    spec:
      # 定义亲和性
      affinity:
        # 定义Pod的反亲和性
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            # 指定拓扑域的key
          - topologyKey: dc
          # - topologyKey: beta.kubernetes.io/arch
          #- topologyKey: kubernetes.io/hostname
            # 基于标签匹配
            labelSelector:
               matchExpressions:
                 # 指的是Pod标签的key
               - key: apps
                 # 指的是Pod标签的values
                 values:
                 - linux85-web
                 operator: In
      tolerations:
      - operator: Exists
      containers:
      - name: web
        image: harbor.oldboyedu.com/update/apps:v1
[root@k8s231.oldboyedu.com podAntiAffinity]# 

	
	
	
	
	


	
	
Pod驱逐及K8S节点下线：
驱逐简介:
	kubelet监控当前node节点的CPU，内存，磁盘空间和文件系统的inode等资源。
	当这些资源中的一个或者多个达到特定的消耗水平，kubelet就会主动地将节点上一个或者多个Pod强制驱逐。
	以防止当前node节点资源无法正常分配而引发的OOM。



参考链接:
	https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/node-pressure-eviction/
	
   
   
- 手动驱逐Pod，模拟下线节点
- 应用场景:
	node因为硬件故障或者其他原因要下线。
	
- 参考步骤:
	(1)编写资源清单并创建
[root@k8s231.oldboyedu.com drain]# ll
total 8
-rw-r--r-- 1 root root 335 Apr 20 15:17 01-drain-deploy.yaml
-rw-r--r-- 1 root root 317 Apr 20 15:21 02-drain-ds.yaml
[root@k8s231.oldboyedu.com drain]# 
[root@k8s231.oldboyedu.com drain]# cat 01-drain-deploy.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-linux85-drain
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  template:
    metadata:
      labels:
        apps: linux85-web
    spec:
      containers:
      - name: web
        image: harbor.oldboyedu.com/update/apps:v1
[root@k8s231.oldboyedu.com drain]# 
[root@k8s231.oldboyedu.com drain]# cat 02-drain-ds.yaml 
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: oldboyedu-linux85-ds
spec:
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  template:
    metadata:
      labels:
        apps: linux85-web
    spec:
      containers:
      - name: web
        image: harbor.oldboyedu.com/update/apps:v2
[root@k8s231.oldboyedu.com drain]# 


	(2)驱逐Pod并打SchedulingDisable标签，但不会驱逐ds资源调度的pod。
[root@k8s231.oldboyedu.com drain]# kubectl drain k8s233.oldboyedu.com --ignore-daemonsets
node/k8s233.oldboyedu.com already cordoned
WARNING: ignoring DaemonSet-managed Pods: default/oldboyedu-linux85-ds-f97fs, kube-flannel/kube-flannel-ds-6m48r, kube-system/kube-proxy-skcr4
node/k8s233.oldboyedu.com drained
[root@k8s231.oldboyedu.com drain]# 
[root@k8s231.oldboyedu.com drain]# kubectl get nodes 
NAME                   STATUS                     ROLES                  AGE     VERSION
k8s231.oldboyedu.com   Ready                      control-plane,master   7d22h   v1.23.17
k8s232.oldboyedu.com   Ready                      <none>                 7d22h   v1.23.17
k8s233.oldboyedu.com   Ready,SchedulingDisabled   <none>                 7d22h   v1.23.17
[root@k8s231.oldboyedu.com drain]# 

		
	(3)配置污点，将ds资源进行立即驱逐Pod。
[root@k8s231.oldboyedu.com drain]# kubectl taint nodes k8s233.oldboyedu.com  classroom=jiaoshi05:NoExecute  
node/k8s233.oldboyedu.com tainted
[root@k8s231.oldboyedu.com drain]# 

		
	(4)登录要下线的节点并重置kubeadm集群环境
[root@k8s233.oldboyedu.com ~]# kubeadm reset -f
[root@k8s233.oldboyedu.com ~]# 
[root@k8s233.oldboyedu.com ~]# rm -rf /etc/cni/net.d && iptables -F && iptables-save 
[root@k8s233.oldboyedu.com ~]# 
[root@k8s233.oldboyedu.com ~]# systemctl disable kubelet
Removed symlink /etc/systemd/system/multi-user.target.wants/kubelet.service.
[root@k8s233.oldboyedu.com ~]# 
	
	
	(5)删除要下线的节点。
[root@k8s231.oldboyedu.com drain]# kubectl delete nodes k8s233.oldboyedu.com
node "k8s233.oldboyedu.com" deleted
[root@k8s231.oldboyedu.com drain]# 

		
	(6)关机并重新安装操作系统
[root@k8s233.oldboyedu.com ~]# reboot 

	


	
kubeadm快速将节点加入集群:
	1.安装必要组件
		1.1 配置软件源
cat  > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
	
		1.2 安装kubeadm，kubelet，kubectl软件包
yum -y install kubeadm-1.23.17-0 kubelet-1.23.17-0 kubectl-1.23.17-0 

		1.3 启动kubelet服务(若服务启动失败时正常现象，其会自动重启，因为缺失配置文件，初始化集群后恢复！此步骤可跳过！)
systemctl enable --now kubelet
systemctl status kubelet


	2.在master组件创建token
		2.1 创建一个永不过期的token，并打印加入集群的命令
[root@k8s231.oldboyedu.com ~]# kubeadm token create --print-join-command oldboy.qwertyuiopasdfgh --ttl 0
kubeadm join 10.0.0.231:6443 --token oldboy.qwertyuiopasdfgh --discovery-token-ca-cert-hash sha256:cefaa1909119929f34cb7366602a3ea4089f586c6ed8465fd15148644763a181 
[root@k8s231.oldboyedu.com ~]# 


		2.2 查看现有的token
[root@k8s231.oldboyedu.com ~]# kubeadm token list
TOKEN                     TTL         EXPIRES   USAGES                   DESCRIPTION                                                EXTRA GROUPS
oldboy.qwertyuiopasdfgh   <forever>   <never>   authentication,signing   <none>                                                     system:bootstrappers:kubeadm:default-node-token
[root@k8s231.oldboyedu.com ~]# 


		2.3 删除token（先跳过此步骤，先别删除，加入集群后再来操作哟！）
[root@k8s231.oldboyedu.com ~]# kubeadm token delete oldboy
bootstrap token "oldboy" deleted
[root@k8s231.oldboyedu.com ~]# 

		
		
	3.worker节点加入集群
[root@k8s233.oldboyedu.com ~]# kubeadm join 10.0.0.231:6443 --token oldboy.qwertyuiopasdfgh --discovery-token-ca-cert-hash sha256:cefaa1909119929f34cb7366602a3ea4089f586c6ed8465fd15148644763a181 


	4.查看节点
[root@k8s231.oldboyedu.com ~]# kubectl get nodes
NAME                   STATUS   ROLES                  AGE     VERSION
k8s231.oldboyedu.com   Ready    control-plane,master   7d23h   v1.23.17
k8s232.oldboyedu.com   Ready    <none>                 7d23h   v1.23.17
k8s233.oldboyedu.com   Ready    <none>                 58s     v1.23.17
[root@k8s231.oldboyedu.com ~]# 


	5.查看bootstrap阶段的token信息
[root@k8s231.oldboyedu.com ~]# kubectl get secrets  -A | grep oldboy
kube-system       bootstrap-token-oldboy                           bootstrap.kubernetes.io/token         5      22s
[root@k8s231.oldboyedu.com ~]# 









LoadBalance案例：
- LoadBalance案例:
	(1)前提条件
K8S集群在任意云平台环境，比如腾讯云，阿里云，京东云等。


	(2)创建svc
[root@k8s231.oldboyedu.com services]# cat 03-services-LoadBalance.yaml 
kind: Service
apiVersion: v1
metadata:
  name: svc-loadbalancer
spec:
  # 指定service类型为LoadBalancer，注意，一般用于云环境
  type: LoadBalancer
  selector:
    apps: linux85-web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
[root@k8s231.oldboyedu.com services]# 


    
    
    (3)配置云环境的应用负载均衡器
添加监听器规则，比如访问负载均衡器的80端口，反向代理到30080端口。
简而言之，就是访问云环境的应用服务器的哪个端口，把他反向代理到K8S集群的node端口为30080即可。


	(4)用户访问应用负载均衡器的端口
用户直接访问云环境应用服务器的80端口即可，请求会自动转发到云环境nodePort的30080端口哟。








ExternalName案例：
[root@k8s151.oldboyedu.com ~]# cat 04-svc-ExternalName.yaml 
apiVersion: v1
kind: Service
metadata:
  name: svc-externalname
spec:
  # svc类型
  type: ExternalName
  # 指定外部域名
  externalName: www.baidu.com
[root@k8s151.oldboyedu.com ~]# 


温馨提示:
	启动容器后访问名为"svc-externalname"的svc，请求会被cname到"www.baidu.com"的A记录。
	这种方式使用并不多，因为对于域名解析直接配置DSNS的解析较多，因此此处了解即可。

 




k8s使用ep资源映射外部服务实战案例:
	(1)在K8S外部节点部署MySQL环境
[root@harbor.oldboyedu.com ~]# docker run -de MYSQL_ALLOW_EMPTY_PASSWORD=yes \
 -p 3306:3306 --name mysql-server --restart unless-stopped \
 -e MYSQL_DATABASE=wordpress \
 -e MYSQL_USER=linux85 \
 -e MYSQL_PASSWORD=oldboyedu \
 harbor.oldboyedu.com/db/mysql:8.0.32-oracle


	(2)连接测试
[root@harbor.oldboyedu.com ~]# docker exec -it mysql-server bash
bash-4.4# 
bash-4.4# mysql
...
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpress          |
+--------------------+
5 rows in set (0.00 sec)

mysql> 
mysql> 
mysql> USE wordpress
Database changed
mysql> 
mysql> SHOW TABLES;
Empty set (0.00 sec)

mysql> 


	(3)K8S编写ep资源
[root@k8s231.oldboyedu.com 05-wordpress-ep]# cat 01-ep.yaml 
apiVersion: v1
kind: Endpoints
metadata:
  name: oldboyedu-linux85-db
subsets:
- addresses:
  - ip: 10.0.0.250
  ports:
  - port: 3306
[root@k8s231.oldboyedu.com 05-wordpress-ep]#


	(4)编写同名的svc资源
[root@k8s231.oldboyedu.com 05-wordpress-ep]# cat 02-mysql-svc.yaml 
apiVersion: v1
kind: Service
metadata:
  name: oldboyedu-linux85-db
spec:
  selector:
    app: mysql
  type: ClusterIP
  ports:
  - port: 3306
    targetPort: 3306
[root@k8s231.oldboyedu.com 05-wordpress-ep]# 

	
	(5)删除之前旧的WordPress数据
[root@k8s231.oldboyedu.com 05-wordpress-ep]# rm -rf /oldboyedu/data/kubernetes/wordpress/*

	
	(6)部署wordpres连接MySQL
[root@k8s231.oldboyedu.com 05-wordpress-ep]# cat 03-deploy-wordpresss.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-linux85-wordpress
spec:
  replicas: 3
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      volumes:
      - name: data
        nfs:
          server: 10.0.0.231
          path: /oldboyedu/data/kubernetes/wordpress
      containers:
      - name: wordpress
        image: harbor.oldboyedu.com/web/wordpress
        ports:
        - containerPort: 80
        env:
        - name: WORDPRESS_DB_HOST
          value: oldboyedu-linux85-db
        - name: WORDPRESS_DB_USER
          value: linux85
        - name: WORDPRESS_DB_PASSWORD
          value: oldboyedu
        volumeMounts:
        - name: data
          mountPath: /var/www/html/wp-content/uploads
[root@k8s231.oldboyedu.com 05-wordpress-ep]# 
	
	(7)创建svc暴露WordPress应用
[root@k8s231.oldboyedu.com 05-wordpress-ep]# cat 02-mysql-svc.yaml 
apiVersion: v1
kind: Service
metadata:
  name: oldboyedu-linux85-db
spec:
  type: ClusterIP
  ports:
  - port: 3306
    targetPort: 3306
[root@k8s231.oldboyedu.com 05-wordpress-ep]# 


	(8)创建应用
[root@k8s231.oldboyedu.com 05-wordpress-ep]# kubectl delete all --all
[root@k8s231.oldboyedu.com 05-wordpress-ep]# 
[root@k8s231.oldboyedu.com 05-wordpress-ep]# kubectl apply -f .
endpoints/oldboyedu-linux85-db created
service/oldboyedu-linux85-db created
deployment.apps/oldboyedu-linux85-wordpress created
service/oldboyedu-linux85-wordpress created
[root@k8s231.oldboyedu.com 05-wordpress-ep]# 

	
	(9)访问webUI测试
略。
	



kube-proxy的工作模式:
	对于kube-proxy组件的作用就是为k8s集群外部用户提供访问服务的路由。
	kube-proxy监听K8S APIServer，一旦service资源发生变化，kube-proxy就会生成对应的负载调度的调整，这样就保证service的最新状态。
	kube-proxy有三种调度模型:
		- userspace:
			k8s 1.1之前。
		- iptables:
			k8s 1.2 ~ k8s 1.11之前。
		- ipvs:
			K8S 1.11之后，如果没有开启ipvs，则自动降级为iptables。



修改ipvs工作模式
	(1)所有worker节点安装ipvs相关组件
yum -y install conntrack-tools ipvsadm.x86_64 


	(2)编写加载ipvs的配置文件
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash

modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

	(3)加载ipvs相关模块并查看
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4


	(4)修改kube-proxy的工作模式为ipvs
		4.1仅需修改工作模式("mode")为ipvs即可。切记，一定要保存退出！
[root@k8s231.oldboyedu.com ~]# kubectl -n kube-system edit cm kube-proxy

		4.2 验证是否修改成功
[root@k8s231.oldboyedu.com ~]# kubectl -n kube-system describe cm kube-proxy | grep mode
mode: "ipvs"
[root@k8s231.oldboyedu.com ~]# 


	(5)删除旧的kube-proxy
kubectl get pods -A | grep kube-proxy | awk '{print $2}' | xargs kubectl -n kube-system delete pods 


	(6)验证kube-proxy组件工作模式是否生效
		6.1 查看日志
[root@k8s231.oldboyedu.com ~]# kubectl get pods -A | grep kube-proxy 
kube-system    kube-proxy-k6mrc                               1/1     Running   0               58s
kube-system    kube-proxy-pt7mk                               1/1     Running   0               57s
kube-system    kube-proxy-rmhh6                               1/1     Running   0               57s
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# kubectl logs kube-proxy-k6mrc -n kube-system 
I0420 09:45:23.314221       1 node.go:163] Successfully retrieved node IP: 10.0.0.233
I0420 09:45:23.314300       1 server_others.go:138] "Detected node IP" address="10.0.0.233"
I0420 09:45:23.334201       1 server_others.go:269] "Using ipvs Proxier"
...


		6.2 测试服务是否正常访问
[root@k8s231.oldboyedu.com ~]# curl -I http://10.0.0.233:30080/2023/04/20/hello-world/


	(3)验证ipvs的工作模式，如下图所示。
[root@k8s231.oldboyedu.com ~]# kubectl get po,svc
NAME                                               READY   STATUS    RESTARTS   AGE
pod/oldboyedu-linux85-wordpress-6b757777b7-dn7xr   1/1     Running   0          34m
pod/oldboyedu-linux85-wordpress-6b757777b7-rzthp   1/1     Running   0          34m
pod/oldboyedu-linux85-wordpress-6b757777b7-ssm65   1/1     Running   0          34m

NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/kubernetes                    ClusterIP   10.200.0.1       <none>        443/TCP        37m
service/oldboyedu-linux85-db          ClusterIP   10.200.36.230    <none>        3306/TCP       34m
service/oldboyedu-linux85-wordpress   NodePort    10.200.100.200   <none>        80:30080/TCP   34m
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# ipvsadm -ln | grep 10.200.100.200 -A 3
TCP  10.200.100.200:80 rr
  -> 10.100.1.196:80              Masq    1      0          0         
  -> 10.100.1.197:80              Masq    1      0          0         
  -> 10.100.3.8:80                Masq    1      0          0         
[root@k8s231.oldboyedu.com ~]# 




温馨提示:
	在实际工作中，如果修改了kube-proxy服务时，若删除Pod，请逐个删除，不要批量删除哟！
	
	
	
	
	
	







今日作业:
	- 完成课堂的所有练习并整理思维导图;
	- 将"harbor.oldboyedu.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.1"镜像的多个服务修改端口范围81-85端口，不允许重新打镜像;
	- 使用一个svc暴露这5个服务;
	
扩展作业:
	- 部署可道云到K8S集群;
```

# Q1: 影响pod调度的因素有哪些?

- nodeName
  - resources
  - hostNetwork
  ...
  - 污点
  - 污点容忍
  - Pod亲和性
  - Pod反亲和性
  - 节点亲和性

# 污点概述

```
污点通常情况下是作用在worker节点上，其可以影响Pod的调度。

污点的语法格式如下:
key[=value]:effect
		
相关字段说明:
key:字母或数字开头，可以包含字母、数字、连字符(-)、点(.)和下划线(_)，最多253个字符。也可以以DNS子域前缀和单个"/"开头
value:该值是可选的。如果给定，它必须以字母或数字开头，可以包含字母、数字、连字符、点和下划线，最多63个字符。
effect:[ɪˈfekt]
	effect必须是NoSchedule、PreferNoSchedule或NoExecute。
	NoSchedule: [noʊ,ˈskedʒuːl] 该节点不再接收新的Pod调度，但不会驱赶已经调度到该节点的Pod。
	PreferNoSchedule: [prɪˈfɜːr,noʊ,ˈskedʒuː] 该节点可以接受调度，但会尽可能将Pod调度到其他节点，换句话说，让该节点的调度优先级降低啦。
	NoExecute:[ˈnoʊ,eksɪkjuːt] 该节点不再接收新的Pod调度，与此同时，会立刻驱逐已经调度到该节点的Pod。
```

## NoExecute 污点实战

```
(1)创建资源清单
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-taint-demo-1
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: app
      values:
      - wahaha1
      operator: In
  template:
    metadata:
      labels:
        app: wahaha1
    spec:
      containers:
      - name: nginx-deploy-demo-1  
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v3.0-my
        imagePullPolicy: IfNotPresent
 
(2)查看Pod调度节点
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s2
centos7k8s3
centos7k8s2
centos7k8s3
centos7k8s2
 
(3)打污点
kubectl taint node centos7k8s2 mytaint1=waxixi:NoExecute
node/centos7k8s2 tainted

(4)查看污点
kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint1=waxixi:NoExecute
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s2
--
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3
  
(5)打污点后
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s3
centos7k8s3
centos7k8s3
centos7k8s3
centos7k8s3
 
(6)清除污点
kubectl taint node centos7k8s2 mytaint1-
node/centos7k8s2 untainted
 
(7)再次修改Pod副本数量
kubectl edit deployments.apps nginx-taint-demo-1 -n haha
deployment.apps/nginx-taint-demo-1 edited

kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s2
centos7k8s3
centos7k8s2
centos7k8s3
centos7k8s3
centos7k8s2
centos7k8s3
centos7k8s2
centos7k8s3
```

## PreferNoSchedule污点实战案例

```
(1)添加PreferNoSchedule污点
kubectl taint node centos7k8s2 mytaint=yoxixi:PreferNoSchedule
node/centos7k8s2 tainted
[root@centos7k8s1 taint]# kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint=yoxixi:PreferNoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s2
--
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3
(2)创建资源清单并应用
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-taint-prefernoschedule-demo-1
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: app
      values:
      - wahaha1
      operator: In
  template:
    metadata:
      labels:
        app: wahaha1
    spec:
      containers:
      - name: nginx-taint-prefernoschedule-demo
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v3.0-my
 
kubectl apply -f 02_nginx_deploy_taint_prefernoschedule_demo.yml 
deployment.apps/nginx-taint-prefernoschedule-demo-1 created
(3)查看调度节点
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s3
centos7k8s3
centos7k8s3
centos7k8s3
centos7k8s3
(4)添加NoExecute污点
kubectl taint node centos7k8s3 mytaint2=wuhaha:NoExecute
node/centos7k8s3 tainted
(5)再次查看Pod调度节点
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s2
centos7k8s2
centos7k8s2
centos7k8s2
centos7k8s2
```

## NoSchedule污点实战案例

```
(1)查看现有污点状态
kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint=yoxixi:PreferNoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s2
--
Taints:             mytaint2=wuhaha:NoExecute
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3

(2)添加污点
kubectl taint node centos7k8s2 mytaint=yoxixi:NoSchedule
node/centos7k8s2 tainted

(3)再次查看节点的污点状态
kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint=yoxixi:NoSchedule
                    mytaint=yoxixi:PreferNoSchedule
Unschedulable:      false
Lease:
--
Taints:             mytaint2=wuhaha:NoExecute
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3

(4)查看现有的Pod调度
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s2
centos7k8s2
centos7k8s2
centos7k8s2
centos7k8s2	
	
(5)调大副本数量，观察是否能完成调度，比如增加4个Pod副本，会出现如下的Pending状态哟！
kubectl edit deployments.apps nginx-taint-prefernoschedule-demo-1 -n haha
deployment.apps/nginx-taint-prefernoschedule-demo-1 edited

kubectl get pods -n haha -o wide | awk '{print $1, $3, $7}'
NAME STATUS NODE
nginx-taint-prefernoschedule-demo-1-5dbc469d84-77n2r Pending <none>
nginx-taint-prefernoschedule-demo-1-5dbc469d84-b2l2w Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-cr4cp Pending <none>
nginx-taint-prefernoschedule-demo-1-5dbc469d84-hmmjh Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-mnrb9 Pending <none>
nginx-taint-prefernoschedule-demo-1-5dbc469d84-pnzhv Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-tnpcs Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-twhvp Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-xn2cv Pending <none>
```

## 配置污点容忍实战案例

```
(1)修改污点
kubectl taint node centos7k8s2 mytaint=yohaha:PreferNoSchedule --overwrite
node/centos7k8s2 modified

(2)查看污点
kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint=yoxixi:NoSchedule
                    mytaint=yohaha:PreferNoSchedule
Unschedulable:      false
Lease:
--
Taints:             mytaint2=wuhaha:NoExecute
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3
  
(3)编写资源清单
# kubectl explain po.spec.tolerations
配置Pod的污点容忍
tolerations:
- key: 指定污点的key 若不指定key，则operator的值必须为Exists，表示匹配所有的key
  value: 指定污点的key的value
  effect: 指定污点的effect，有效值为: NoSchedule, PreferNoSchedule,NoExecute 若不指定则匹配所有的影响度。
  operator: 表示key和value的关系，有效值为Exists， Equal。
     Exists:
       表示存在指定的key即可，若配置，则要求value字段为空。
     Equal:
       默认值，表示key=value。       

如果不指定key，value，effect，仅配置"operator: Exists"表示无视任何污点!
 - operator: Exists

# 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-taint-prefernoschedule-demo-1
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: app
      values:
      - wahaha1
      operator: In
  template:
    metadata:
      labels:
        app: wahaha1
    spec:
      tolerations:
      - key: mytaint2
        value: wuhaha
        effect: NoExecute
        operator: Equal
      - key: node-role.kubernetes.io/master
        operator: Exists
      containers:
      - name: nginx-taint-prefernoschedule-demo
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
 
(4)查看现有的Pod调度
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s3
centos7k8s3
centos7k8s1
centos7k8s1
centos7k8s3
```

# 节点选择器nodeselector

```
(1)给节点打标签
kubectl label nodes centos7k8s1 ynode=gotit
node/centos7k8s1 labeled

kubectl get nodes --show-labels
NAME          STATUS   ROLES                  AGE   VERSION    LABELS
centos7k8s1   Ready    control-plane,master   14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=,ynode=gotit
centos7k8s2   Ready    <none>                 14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s2,kubernetes.io/os=linux,mynode=iwant
centos7k8s3   Ready    <none>                 14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s3,kubernetes.io/os=linux,mynode=iwant


(2)编写资源清单
kubectl explain po.spec.nodeSelector
KIND:     Pod
VERSION:  v1

FIELD:    nodeSelector <map[string]string>

nodeSelector:
  label_name: value #匹配节点的标签名和值，如有多个则须都写。需调用的节点标签值要一致，否则会报错或一直在pending状态

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-node-selector
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      tolerations:
      - operator: Exists
      nodeSelector:
        mynode: iwant
        #ynode: gotit
      containers:
      - name: nginx-deploy-node-selector-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent

kubectl get pod -n haha -o wide | awk '{print $7}'
NODE
centos7k8s3
centos7k8s2
centos7k8s2
centos7k8s3
centos7k8s3

(3)删除标签
[root@centos7k8s1 node_selector]# kubectl label nodes --all mynode-
label "mynode" not found.
node/centos7k8s1 not labeled
node/centos7k8s2 unlabeled
node/centos7k8s3 unlabeled
[root@centos7k8s1 node_selector]# kubectl label nodes --all ynode-
node/centos7k8s1 unlabeled
label "ynode" not found.
node/centos7k8s2 not labeled
label "ynode" not found.
node/centos7k8s3 not labeled
```

# 节点亲和性nodeAffinity

```
(1)打标签
[root@centos7k8s1 node_affinity]# kubectl label nodes centos7k8s1 mynode=iwant
node/centos7k8s1 labeled
[root@centos7k8s1 node_affinity]# kubectl label nodes centos7k8s3 mynode=ywant
node/centos7k8s3 labeled

kubectl get nodes --show-labels
NAME          STATUS   ROLES                  AGE   VERSION    LABELS
centos7k8s1   Ready    control-plane,master   14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s1,kubernetes.io/os=linux,mynode=iwant,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
centos7k8s2   Ready    <none>                 14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s2,kubernetes.io/os=linux
centos7k8s3   Ready    <none>                 14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s3,kubernetes.io/os=linux,mynode=ywant

(2)编写资源清单
affinity:  #定义亲和性
  nodeAffinity: #定义节点的亲和性    
    requiredDuringSchedulingIgnoredDuringExecution: #定义硬限制      
      nodeSelectorTerms: #定义节点的匹配条件        
      - matchExpressions: #基于节点的标签进行匹配          
        - key: 指定标签的key          
          values: 指定标签的value
          - value1
          - value2
          ...
          operator: In # 指定key和value之间的对应关系，有效值如下:
            In:
              key的值必须在vlaues内。要求values不能为空。
            NotIn:
              和In相反。要求values不能为空。
            Exists:
              只要存在指定key即可，vlaues的值必须为空。
            DoesNotExist:
              只要不存在指定key即可，vlaues的值必须为空。
            Gt:
              表示大于的意思，values的值会被解释为整数。
            Lt:
              表示小于的意思，values的值会被解释为整数。
          
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-node-affinity
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: mynode
                values: 
                - iwant
                - ywant
                operator: In
              #- key: ynode
              #  values: 
              #  - gotit
              #  operator: In
      containers:
      - name: nginx-deploy-node-affinity-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-deploy-node-affinity-svc
  namespace: haha
spec:
  selector:
    app: haha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31800
  clusterIP: 10.200.111.111


(3)删除标签
[root@k8s231.myharbor.com nodeAffinity]# kubectl label nodes --all mynode- 
```

# Pod的亲和性

```
(1)node打标签
[root@centos7k8s1 node_selector]# kubectl label nodes centos7k8s1 dc=dawa
node/centos7k8s1 labeled
[root@centos7k8s1 node_selector]# kubectl label nodes centos7k8s2 dc=erwa
node/centos7k8s2 labeled
[root@centos7k8s1 node_selector]# kubectl label nodes centos7k8s3 dc=sanwa
node/centos7k8s3 labele

kubectl get nodes --show-labels | grep dc
centos7k8s1   Ready    control-plane,master   15d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=dawa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
centos7k8s2   Ready    <none>                 15d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=erwa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s2,kubernetes.io/os=linux
centos7k8s3   Ready    <none>                 15d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=sanwa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s3,kubernetes.io/os=linux

(2)编写资源清单
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-pod-affinity
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 9
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      affinity: #定义亲和性
        podAffinity: #定义Pod的亲和性
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: dc #指定拓扑域的key 就是nodes中的label
            #- topologyKey: kubernetes.io/os
              labelSelector: #定义标签选择器，这里是指pod的标签
                matchExpressions: 
                - key: app
                  values: 
                  - haha1
                  operator: In
                #- key: ynode
                #  values: 
                #  - gotit
                #  operator: In
      containers:
      - name: nginx-deploy-node-affinity-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
```

# Pod的反亲和性

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-pod-affinity
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 9
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      affinity: #定义亲和性
        podAntiAffinity: #定义Pod的反亲和性
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: dc #指定拓扑域的key 就是nodes中的label
            #- topologyKey: kubernetes.io/os
              labelSelector: #定义标签选择器，这里是指pod的标签
                matchExpressions:
                - key: app
                  values: 
                  - haha1
                  operator: In
                #- key: ynode
                #  values: 
                #  - gotit
                #  operator: In
      containers:
      - name: nginx-deploy-node-affinity-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresen
        
        
        

   
```

# 面试题

```
Q1: 请陈述Pod的亲和性和反亲和性的作用和区别?
亲和性： 当pod调度到某一个拓扑域时，其它的pod会调度到与之相同的拓扑域
反亲和性：当pod调度到某一个拓扑域时，其它的pod不会调度到与之相同的拓扑域，并且只调度一个pod到一个node节点

Q2: 节点和亲和性和节点选择器的区别?

kubectl get nodes --show-labels
NAME          STATUS   ROLES                  AGE   VERSION    LABELS
centos7k8s1   Ready    control-plane,master   16d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=dawa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
centos7k8s2   Ready    <none>                 16d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=erwa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s2,kubernetes.io/os=linux,mynode=iwant
centos7k8s3   Ready    <none>                 16d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=sanwa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s3,kubernetes.io/os=linux,mynode=iwant

节点选择器只能通过单一key:value节点标签来选择调度到匹配的节点

如果每个节点自定义标签有指定的key:value标签，那么pod调度到有这些标签的节点
      nodeSelector:
        mynode: iwant

kubectl get pods -n haha -o wide
NAME                                          READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
nginx-deploy-node-selector-6c9bf75db4-6k9b4   1/1     Running   0          6s    10.100.2.108   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-6c9bf75db4-fp6mp   1/1     Running   0          6s    10.100.1.37    centos7k8s2   <none>           <none>
nginx-deploy-node-selector-6c9bf75db4-jhcrh   1/1     Running   0          5s    10.100.1.38    centos7k8s2   <none>           <none>
nginx-deploy-node-selector-6c9bf75db4-mhfpc   1/1     Running   0          6s    10.100.2.107   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-6c9bf75db4-wjrrr   1/1     Running   0          5s    10.100.2.109   centos7k8s3   <none>           <none>

如果指定标签的key相同而value不同，则会选择key相同的最后一个value来调度
      nodeSelector:
        dc: erwa
        dc: sanwa
        mynode: iwant

kubectl get pods -n haha -o wide
NAME                                          READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
nginx-deploy-node-selector-7555c9969c-6spr2   1/1     Running   0          8s    10.100.2.114   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-dhxwv   1/1     Running   0          10s   10.100.2.111   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-h2587   1/1     Running   0          8s    10.100.2.113   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-qpjb5   1/1     Running   0          10s   10.100.2.110   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-ww7nq   1/1     Running   0          10s   10.100.2.112   centos7k8s3   <none>           <none>

如果节点的上自定义标签没有指定的key:value标签还需要手动添加，否则就会pending，原因就是在该节点找不到指定的标签
      nodeSelector:
        dc: erwa
        dc: sanwa
        dc: dawa
        mynode: iwant
kubectl get pods -n haha -o wide
NAME                                          READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
nginx-deploy-node-selector-7555c9969c-dhxwv   1/1     Running   0          2m32s   10.100.2.111   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-h2587   1/1     Running   0          2m30s   10.100.2.113   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-qpjb5   1/1     Running   0          2m32s   10.100.2.110   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-ww7nq   1/1     Running   0          2m32s   10.100.2.112   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-775bb5fcd6-ppz2q   0/1     Pending   0          22s     <none>         <none>        <none>           <none>
nginx-deploy-node-selector-775bb5fcd6-sprfq   0/1     Pending   0          22s     <none>         <none>        <none>           <none>
nginx-deploy-node-selector-775bb5fcd6-wwb77   0/1     Pending   0          22s     <none>         <none>        <none>           <none>

节点亲和性可以匹配实现key相同,value不相同的节点调度，功能更强大
affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: dc
                values: 
                - dawa
                - erwa
                - sanwa
                operator: In
kubectl get pods -n haha -o wide
NAME                                          READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
nginx-deploy-node-affinity-646b99686c-77mlm   1/1     Running   0          16s   10.100.2.119   centos7k8s3   <none>           <none>
nginx-deploy-node-affinity-646b99686c-mz9xv   1/1     Running   0          16s   10.100.0.24    centos7k8s1   <none>           <none>
nginx-deploy-node-affinity-646b99686c-np84b   1/1     Running   0          16s   10.100.1.40    centos7k8s2   <none>           <none>
nginx-deploy-node-affinity-646b99686c-ptqv4   1/1     Running   0          16s   10.100.1.39    centos7k8s2   <none>           <none>
nginx-deploy-node-affinity-646b99686c-qwf5w   1/1     Running   0          16s   10.100.2.120   centos7k8s3   <none>           <none>

Q3: 影响Pod调度的因素有哪些?
nodeName
taint
tolerations
nodeSelector
nodeAffinity
podAffinity
podAntiAffinity
```

# DaemonSet概述

```
DaemonSet确保全部worker节点上运行一个Pod的副本。

DaemonSet的一些典型用法：
(1)在每个节点上运行集群守护进程(flannel等)
(2)在每个节点上运行日志收集守护进程(flume，filebeat，fluentd等)
(3)在每个节点上运行监控守护进程（zabbix agent，node_exportor等）

温馨提示:
(1)当有新节点加入集群时，也会为新节点新增一个Pod;
(2)当有节点从集群移除时，这些Pod也会被回收;
(3)删除DaemonSet将会删除它创建的所有Pod;
(4)如果节点被打了污点的话，且DaemonSet中未定义污点容忍，则Pod并不会被调度到该节点上;("flannel案例")
		
编写资源清单：
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-deploy-node-daemonset
  labels:
    item: wahaha
  namespace: haha
spec:
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      containers:
      - name: nginx-deploy-node-affinity-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-deploy-node-affinity-svc
  namespace: haha
spec:
  selector:
    app: haha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31800
  clusterIP: 10.200.111.111
```

## 结合node亲合性案例

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-node-daemonset
  labels:
    item: wahaha
  namespace: haha
spec:
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: dc
                values: 
              #  - dawa
                - erwa
                - sanwa
                operator: In
              #- key: ynode
              #  values: 
              #  - gotit
              #  operator: In
      containers:
      - name: nginx-node-daemonset-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-node-daemonset-svc
  namespace: haha
spec:
  selector:
    app: haha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31800
  clusterIP: 10.200.111.111
```

## 结合node选择器案例

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-node-daemonset
  labels:
    item: wahaha
  namespace: haha
spec:
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      nodeSelector:
        mynode: iwant
      containers:
      - name: nginx-node-daemonset-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-node-daemonset-svc
  namespace: haha
spec:
  selector:
    app: haha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31800
  clusterIP: 10.200.111.111
```

