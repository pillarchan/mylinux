```
Q1: rs资源如何实现升级和回滚呢？
 
Q2: svc的资源是否支持在K8S集群外部访问呢?
 
Q3: svc能一个K8S集群外部的服务呢?
 
Q4: K8S如何实现金丝雀发布（灰度发布）？蓝绿发布？
 
Q5: svc底层是如何实现的？他是如何实现Pod的ip动态发现？如何实现负载均衡呢？依赖哪些组件呢？
 
Q6: 如何让Pod运行一次呢？如何解决一次性任务？

Q7: 如果解决周期性任务呢？

Q8: 如何在每个worker节点调度任务呢？

Q9: 当K8S集群2000台时，如何在50台('大数据集群环境')指定的机器上每个节点都部署Pod呢？
 
Q10: 从旧迁移新集群时，后端的存储依赖如何解决呢？如何实现存储的解耦呢？

deploy资源升级和回滚案例:
[root@k8s231.oldboyedu.com deployments]# cat 01-deploy-update.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-linux85-deploy-update
spec:
  replicas: 3
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
        # image: harbor.oldboyedu.com/update/apps:v1
        image: harbor.oldboyedu.com/update/apps:v2
        # image: harbor.oldboyedu.com/update/apps:v3

---

apiVersion: v1
kind: Service
metadata:
  name: oldboyedu-linux85-web-deploy-update
spec:
  selector:
    apps: linux85-web
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
[root@k8s231.oldboyedu.com deployments]# 



deploy资源的升级策略:
[root@k8s231.oldboyedu.com deployments]# cat 02-deploy-strategy.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-linux85-deploy-update-strategy
spec:
  # replicas: 3
  # replicas: 5
  replicas: 10
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  # 定义升级策略
  strategy:
    # 升级的类型,"Recreate" or "RollingUpdate"
    # Recreate:
    #   先停止所有的Pod运行，然后在批量创建更新。
    #   生产环节中不推荐使用这种策略，因为升级过程中用户将无法访问服务!
    # RollingUpdate:
    #   滚动更新，即先实现部分更新，逐步替换原有的pod，是默认策略。
    # type: Recreate
    type: RollingUpdate
    # 自定义滚动更新的策略
    rollingUpdate:
      # 在原有Pod的副本基础上，多启动Pod的数量。
      # maxSurge: 2
      maxSurge: 3
      # 在升级过程中最大不可访问的Pod数量.
      # maxUnavailable: 1
      maxUnavailable: 2
  template:
    metadata:
      labels:
        apps: linux85-web
    spec:
      containers:
      - name: web
        # image: harbor.oldboyedu.com/update/apps:v1
        #image: harbor.oldboyedu.com/update/apps:v2
        # image: harbor.oldboyedu.com/update/apps:v3
        # image: nginx:1.16
        image: nginx:1.18

---

apiVersion: v1
kind: Service
metadata:
  name: oldboyedu-linux85-web-deploy-update-strategy
spec:
  selector:
    apps: linux85-web
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
[root@k8s231.oldboyedu.com deployments]# 




响应式方式升级deployment资源:
	- 交互式方式升级
[root@k8s231.oldboyedu.com deployments]# kubectl edit -f 02-deploy-strategy.yaml 
Edit cancelled, no changes made.
[root@k8s231.oldboyedu.com deployments]# 
[root@k8s231.oldboyedu.com deployments]# kubectl edit deployments.apps oldboyedu-linux85-deploy-update-strategy 
deployment.apps/oldboyedu-linux85-deploy-update-strategy edited
[root@k8s231.oldboyedu.com deployments]# 


	- 非交互式升级
[root@k8s231.oldboyedu.com deployments]# kubectl set image deploy oldboyedu-linux85-deploy-update-strategy  web=harbor.oldboyedu.com/update/apps:v3
deployment.apps/oldboyedu-linux85-deploy-update-strategy image updated
[root@k8s231.oldboyedu.com deployments]# 




使用deployment资源部署redis:
	(1)创建资源清单 
[root@k8s231.oldboyedu.com deployments]# cat 03-deploy-redis.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-leader
  labels:
    app: redis
    role: leader
    tier: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
        role: leader
        tier: backend
    spec:
      containers:
      - name: leader
        image: "docker.io/redis:6.0.5"
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379


---

apiVersion: v1
kind: Service
metadata:
  name: redis-leader
  labels:
    app: redis
    role: leader
    tier: backend
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
    role: leader
    tier: backend
[root@k8s231.oldboyedu.com deployments]# 
[root@k8s231.oldboyedu.com deployments]# 
[root@k8s231.oldboyedu.com deployments]# kubectl apply -f 03-deploy-redis.yaml 
deployment.apps/redis-leader created
service/redis-leader created
[root@k8s231.oldboyedu.com deployments]# 
	
	(2)连接redis
[root@k8s231.oldboyedu.com deployments]# kubectl exec -it redis-leader-766465cd9c-89h85 -- bash
root@redis-leader-766465cd9c-89h85:/data# 
root@redis-leader-766465cd9c-89h85:/data# 
root@redis-leader-766465cd9c-89h85:/data# redis-cli 
127.0.0.1:6379> KEYS *
(empty array)
127.0.0.1:6379> 
127.0.0.1:6379> 
127.0.0.1:6379> SET name oldboyedu
OK
127.0.0.1:6379> 
127.0.0.1:6379> 
127.0.0.1:6379> KEYS *
1) "name"
127.0.0.1:6379> 
127.0.0.1:6379> 
127.0.0.1:6379> GET name
"oldboyedu"
127.0.0.1:6379> 




deployment资源部署wordpress
	(1)创建WordPress
[root@k8s231.oldboyedu.com 01-all-in-one]# cat 01-deploy-wordpresss.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      hostNetwork: true
      containers:
      - name: mysql
        image: harbor.oldboyedu.com/db/mysql:8.0.32-oracle
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "true"
        - name: MYSQL_DATABASE
          value: wordpress
        - name: MYSQL_USER
          value: oldboyedu
        - name: MYSQL_PASSWORD
          value: yinzhengjie
      - name: wordpress
        image: harbor.oldboyedu.com/web/wordpress
        ports:
        - containerPort: 80
        env:
        - name: WORDPRESS_DB_HOST
          value: "127.0.0.1"
        - name: WORDPRESS_DB_USER
          value: oldboyedu
        - name: WORDPRESS_DB_PASSWORD
          value: yinzhengjie
[root@k8s231.oldboyedu.com 01-all-in-one]# 

	
	
	
	(2)创建svc
[root@k8s231.oldboyedu.com services]# cat 02-svc-NodeProt.yaml 
apiVersion: v1
kind: Service
metadata:
  name: oldboyedu-linux85-wordpress
spec:
  # 关联后端的Pod
  selector:
    app: wordpress
  # 指定svc的类型，有效值为: ExternalName, ClusterIP, NodePort, and LoadBalancer
  #    ExternalName:
  #       可以将K8S集群外部的服务映射为一个svc服务。类似于一种CNAME技术.
  #    ClusterIP:
  #       仅用于K8S集群内部使用。提供统一的VIP地址。默认值！
  #    NodePort:
  #       基于ClusterIP基础之上，会监听所有的Worker工作节点的端口，K8S外部可以基于监听端口访问K8S内部服务。
  #    LoadBalancer:
  #       主要用于云平台的LB等产品。
  type: NodePort
  # 指定端口映射相关信息
  ports:
    # 指定svc的端口号
  - port: 80
    # 指定Pod端口号
    targetPort: 80
    # 指定协议
    protocol: TCP
    # 指定访问宿主机的端口，该端口的报文会被转发后端的容器端口
    # 默认svc有效端口范围是:"30000-32767"
    nodePort: 30080
  # 指定ClusterIP的地址
  clusterIP: 10.200.100.200
[root@k8s231.oldboyedu.com services]# 




问题引出:
	将Pod的副本数量设置为2时，为什么数据不统一呢？请尝试解决...




coreDNS概述:
coreDNS的作用就是将svc的名称解析为ClusterIP。

早期使用的skyDNS组件，需要单独部署，在k8s 1.9版本中，我们就可以直接使用kubeadm方式安装CoreDNS组件。

从k8s 1.12开始，CoreDNS就成为kubernetes默认的DNS服务器，但是kubeadm支持coreDNS的时间会更早。


推荐阅读:
	https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns/coredns





 coreDNS的IP地址:
 vim  /var/lib/kubelet/config.yaml 
...
clusterDNS:
- 10.254.0.10
clusterDomain: cluster.local


coreDNS的A记录
	k8s的svc的A记录格式:
<service name>[.<namespace name>.svc.oldboyedu.com]

	举个例子:
oldboyedu-linux85-db
oldboyedu-linux85-db.default.svc.oldboyedu.com
kube-dns.kube-system.svc.oldboyedu.com


测试coreDNS组件:
方式一:
	直接使用alpine取ping您想测试的SVC名称即可，观察能否解析成对应的VIP即可。
	
参考案例:
[root@k8s231.oldboyedu.com ~]# kubectl run  pod-demo --image=alpine  -- tail -f /etc/hosts 
pod/pod-demo created
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# kubectl get svc -A
NAMESPACE     NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes   ClusterIP   10.200.0.1    <none>        443/TCP                  3m44s
kube-system   kube-dns     ClusterIP   10.200.0.10   <none>        53/UDP,53/TCP,9153/TCP   6d23h
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# kubectl get pods -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP             NODE                   NOMINATED NODE   READINESS GATES
pod-demo   1/1     Running   0          40s   10.100.2.204   k8s233.oldboyedu.com   <none>           <none>
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# kubectl exec pod-demo -- ping kubernetes
PING kubernetes (10.200.0.1): 56 data bytes
^C
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# kubectl exec pod-demo -- ping kube-dns.kube-system
PING kube-dns.kube-system (10.200.0.10): 56 data bytes
^C
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# kubectl exec pod-demo -- ping kube-dns.kube-system.svc.oldboyedu.com
PING kube-dns.kube-system.svc.oldboyedu.com (10.200.0.10): 56 data bytes
^C
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# kubectl exec pod-demo -- ping kubernetes.default.svc.oldboyedu.com
PING kubernetes.default.svc.oldboyedu.com (10.200.0.1): 56 data bytes



	
方式二:
	yum -y install bind-utils
	dig @10.254.0.10  oldboyedu-tomcat-app.default.svc.cluster.local +short 
	
	
参考案例:
[root@k8s231.oldboyedu.com ~]#  yum -y install bind-utils

[root@k8s231.oldboyedu.com ~]# kubectl get svc -A
NAMESPACE     NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes   ClusterIP   10.200.0.1    <none>        443/TCP                  7m33s
kube-system   kube-dns     ClusterIP   10.200.0.10   <none>        53/UDP,53/TCP,9153/TCP   6d23h
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# dig @10.200.0.10  kubernetes.default.svc.oldboyedu.com +short 
10.200.0.1
[root@k8s231.oldboyedu.com ~]# 
[root@k8s231.oldboyedu.com ~]# dig @10.200.0.10  kube-dns.kube-system.svc.oldboyedu.com +short 
10.200.0.10
[root@k8s231.oldboyedu.com ~]# 





wordpress使用coreDNS实战案例:
[root@k8s231.oldboyedu.com 04-mysql-wordpress-coreDNS]# 
[root@k8s231.oldboyedu.com 04-mysql-wordpress-coreDNS]# cat 00-ns.yaml 
apiVersion: v1
kind: Namespace
metadata:
  name: oldboyedu-linux85
[root@k8s231.oldboyedu.com 04-mysql-wordpress-coreDNS]# 
[root@k8s231.oldboyedu.com 04-mysql-wordpress-coreDNS]# 
[root@k8s231.oldboyedu.com 04-mysql-wordpress-coreDNS]# cat 01-deploy-mysql.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-linux85-db
  namespace: oldboyedu-linux85
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      volumes:
      - name: data
        nfs:
          server: 10.0.0.231
          path: /oldboyedu/data/kubernetes/mysql
      containers:
      - name: mysql
        image: harbor.oldboyedu.com/db/mysql:8.0.32-oracle
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "true"
        - name: MYSQL_DATABASE
          value: wordpress
        - name: MYSQL_USER
          value: oldboyedu
        - name: MYSQL_PASSWORD
          value: yinzhengjie
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
[root@k8s231.oldboyedu.com 04-mysql-wordpress-coreDNS]# 







deployment实现蓝绿发布:
蓝绿部署(Blue/Green)部署简介：
	蓝绿部署特点:
		不需要停止老版本代码(不影响上一版本访问)，而是在另外一套环境部署新版本然后进行测试。
		测试通过后将用户流量切换到新版本，其特点为业务无中断，升级风险相对较小。
		
		
	- 实现机制:
		- 1.部署当前版本
		- 2.部署service
		- 3.部署新版本(使用新的deployment名称，新的label标签)
		- 4.切换service标签到新的pod

	

蓝绿部署案例:
	(1) 部署蓝环境
[root@k8s231.oldboyedu.com blue-green]# cat 01-blue.yaml 
kind: Deployment
apiVersion: apps/v1
metadata:
  name: oldboyedu-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: blue
  template:
    metadata:
      labels:
        app: blue
    spec:
      containers:
      - name: myweb
        image: harbor.oldboyedu.com/update/apps:v1

---

kind: Service
apiVersion: v1
metadata:
  name: oldboyedu-app-svc
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    app: blue
[root@k8s231.oldboyedu.com blue-green]# 
[root@k8s231.oldboyedu.com blue-green]# kubectl apply -f 01-blue.yaml 
deployment.apps/oldboyedu-blue created
service/oldboyedu-app-svc created
[root@k8s231.oldboyedu.com blue-green]# 

 
 
 	(2)测试访问
[root@k8s231.oldboyedu.com ~]# while true ; do sleep 0.5;curl 10.0.0.233:30080; done


	(3)部署绿环境
[root@k8s231.oldboyedu.com blue-green]# cat 02-green.yaml 
kind: Deployment
apiVersion: apps/v1
metadata:
  name: oldboyedu-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: green
  template:
    metadata:
      labels:
        app: green
    spec:
      containers:
      - name: myweb
        image: harbor.oldboyedu.com/update/apps:v2
[root@k8s231.oldboyedu.com blue-green]# 
[root@k8s231.oldboyedu.com blue-green]# kubectl apply -f 02-green.yaml 
deployment.apps/oldboyedu-green created
[root@k8s231.oldboyedu.com blue-green]# 


	(4)切换svc的标签，如下所示：
[root@k8s231.oldboyedu.com blue-green]# cat 03-switch-svc-selector.yaml 
kind: Service
apiVersion: v1
metadata:
  name: oldboyedu-app-svc
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    # app: blue
    app: green
[root@k8s231.oldboyedu.com blue-green]# 
[root@k8s231.oldboyedu.com blue-green]# kubectl apply -f 03-switch-svc-selector.yaml 
service/oldboyedu-app-svc configured
[root@k8s231.oldboyedu.com blue-green]# 






deployment实现灰度发布:
灰度/金丝雀(Canary)部署简介:
	金丝雀发布也叫灰度发布，是指在黑与白之间，能够平滑度过的一种发布方式，恢复发布是增量发布的一种类型，灰度发布是在原有版本可用的情况下，同时部署一个新版本应用作为"金丝雀"(小白鼠)，测试新版本的性能和表现，以保障整个体系稳定的情况下，尽早发现，调整问题。
	"金丝雀"的由来: 17世纪，英国矿工工人发现，金丝雀对瓦斯这种气体十分敏感，空气哪怕有极其微量的瓦斯，金丝雀也会停止歌唱，而当瓦斯超过一定限度时，虽然人类毫无察觉，金丝雀却早已毒发身亡，当时在采矿设备相对简陋的条件下，工人们每次下井都会带上一只金丝雀作为"瓦斯检测指标"，以便在危险情况下紧急撤离。


- 实现机制:
	- 1.部署当前版本，使用多副本;(最开始是3个副本)
	- 2.部署service，匹配一个label标签;
	- 3.部署新版本(使用deployment名称，但是label标签和之前保持一致)，新版本runing之后service会自动匹配label并将pod添加service的endpoints接收客户端请求;(最开始)
	- 4.灰度版本测试没有问题，将灰度版本的pod副本数逐渐增加为生产数量;
	- 5.将旧版本pod逐渐调低至为0，此时数流量将全部转发至新版本;



灰度发布实战案例:
灰度/金丝雀(Canary)部署简介:
	金丝雀发布也叫灰度发布，是指在黑与白之间，能够平滑度过的一种发布方式，恢复发布是增量发布的一种类型，灰度发布是在原有版本可用的情况下，同时部署一个新版本应用作为"金丝雀"(小白鼠)，测试新版本的性能和表现，以保障整个体系稳定的情况下，尽早发现，调整问题。
	"金丝雀"的由来: 17世纪，英国矿工工人发现，金丝雀对瓦斯这种气体十分敏感，空气哪怕有极其微量的瓦斯，金丝雀也会停止歌唱，而当瓦斯超过一定限度时，虽然人类毫无察觉，金丝雀却早已毒发身亡，当时在采矿设备相对简陋的条件下，工人们每次下井都会带上一只金丝雀作为"瓦斯检测指标"，以便在危险情况下紧急撤离。


- 实现机制:
	- 1.部署当前版本，使用多副本;(最开始是3个副本)
	- 2.部署service，匹配一个label标签;
	- 3.部署新版本(使用deployment名称，但是label标签和之前保持一致)，新版本runing之后service会自动匹配label并将pod添加service的endpoints接收客户端请求;(最开始)
	- 4.灰度版本测试没有问题，将灰度版本的pod副本数逐渐增加为生产数量;
	- 5.将旧版本pod逐渐调低至为0，此时数流量将全部转发至新版本;



灰度发布实战案例:
	(1)部署旧版本(先将副本数设置为3，随着新版本的创建，将副本逐渐调低到0)
[root@k8s231.oldboyedu.com canary-huidu]# cat 01-old.yaml 
kind: Deployment
apiVersion: apps/v1
metadata:
  name: oldboyedu-old
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: myweb
        image: harbor.oldboyedu.com/update/apps:v1

---

kind: Service
apiVersion: v1
metadata:
  name: oldboyedu-web-svc
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    app: web
[root@k8s231.oldboyedu.com canary-huidu]# 
[root@k8s231.oldboyedu.com canary-huidu]# kubectl apply -f old.yaml 
deployment.apps/oldboyedu-old created
service/oldboyedu-web-svc created
[root@k8s231.oldboyedu.com canary-huidu]# 



	(2)部署新版本(先将副本数设置为1，随着新版本的稳定，将副本逐渐调高到3)
[root@k8s231.oldboyedu.com canary-huidu]# cat 02-new.yaml 
kind: Deployment
apiVersion: apps/v1
metadata:
  name: oldboyedu-new
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: myweb
        image: harbor.oldboyedu.com/update/apps:v2
[root@k8s231.oldboyedu.com canary-huidu]#
[root@k8s231.oldboyedu.com canary-huidu]# kubectl apply -f 02-new.yaml 
deployment.apps/oldboyedu-new created
[root@k8s231.oldboyedu.com canary-huidu]# 


	(3)修改副本数量
将旧的副本数量手动修改从3-0，与此同时，将新的副本数量从1-3。


	(4)测试访问
[root@k8s231.oldboyedu.com ~]# while true ; do sleep 0.5;curl  10.0.0.233:30080; done



Job概述:
	一次性任务，Pod完成作业后并不重启容器。其重启策略为"restartPolicy: Never"
	
参考案例:
[root@k8s231.oldboyedu.com jobs]# cat job.yaml 
apiVersion: batch/v1
kind: Job
metadata:
  name: oldboyedu-linux85-pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34
        # 它计算π到2000个位置并打印出来。大约需要 10 秒才能完成。
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  # 指定标记此作业失败之前的重试次数。默认值为6
  backoffLimit: 4
[root@k8s231.oldboyedu.com jobs]# 



CronJob概述:
	周期性任务，CronJob底层逻辑是周期性创建Job控制器来实现周期性任务的。
	
参考案例:
cat > cronjob.yaml <<'EOF'
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: oldboyedu-hello
spec:
  # 定义调度格式，参考链接：https://en.wikipedia.org/wiki/Cron
  # ┌───────────── 分钟 (0 - 59)
  # │ ┌───────────── 小时 (0 - 23)
  # │ │ ┌───────────── 月的某天 (1 - 31)
  # │ │ │ ┌───────────── 月份 (1 - 12)
  # │ │ │ │ ┌───────────── 周的某天 (0 - 6)（周日到周一；在某些系统上，7 也是星期日）
  # │ │ │ │ │                          或者是 sun，mon，tue，web，thu，fri，sat
  # │ │ │ │ │
  # │ │ │ │ │
  # * * * * *
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the oldboyedu linux81 Kubernetes cluster
          restartPolicy: OnFailure
EOF


参考链接:
	https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/cron-jobs/
	
	
	
今日作业:
	(1)完成课堂的所有练习并整理思维导图;
	(2)将昨日作业使用deploy资源改写部署，将其放在"oldboyedu-linux85"的名称空间。
	
	
扩展作业:
	(1)使用初始化容器实现自建yum仓库的部署,实现nginx部署;
	(2)将可道云部署到K8S集群;
```

# Deployment控制器

是k8s中一个重要又常用的控制器，用于部署pod、升级、回滚

## 升级和回滚案例

```
[root@centos7k8s1 deployment]# cat 01_nginx_deploy_update_demo.yml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-rs-deploy-demo-1
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 2
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
        #image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: '0.5'
            memory: '0.5G'
          limits:
            cpu: '1'
            memory: '1G'
        lifecycle:
          postStart:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - 'echo "<h2>yoyo page</h2>" > /usr/share/nginx/html/yoyo.html'
          preStop:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - 'nginx -s stop'
      initContainers:
      - name: init-somaxconn
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        securityContext:
          privileged: true
        command:
        - "/bin/sh"
        - "-c"
        - 'echo 256 > /proc/sys/net/core/somaxconn'
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-rs-svc
  namespace: haha
spec:
  selector:
    app: wahaha1
  type: ClusterIP
  ports:
  - port: 88
    targetPort: 80
    
 当升级或回滚的时候，只需要修改源镜像源，然后再应用一下对应的资源清单即可，并且没有抖动感   
    
```

## Deployment是如何升级回滚的？

```
[root@centos7k8s1 deployment]# kubectl get -n haha all
NAME                                          READY   STATUS    RESTARTS   AGE
pod/nginx-rs-deploy-demo-1-678b57df66-5x528   1/1     Running   0          6m10s
pod/nginx-rs-deploy-demo-1-678b57df66-bnmmf   1/1     Running   0          6m7s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/nginx-rs-svc   ClusterIP   10.200.53.175   <none>        88/TCP    7m35s

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-rs-deploy-demo-1   2/2     2            2           7m35s

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-rs-deploy-demo-1-678b57df66   2         2         2       6m10s
replicaset.apps/nginx-rs-deploy-demo-1-7c6447f865   0         0         0       7m35s


通过get all 资源，可以发现deployment并不是直接管理pod ，而是通过对replicaset管理去创建和删除pod，来达到自动升级回滚的效果。
它们之间的关联就在于name上自动生成hash值来识别



[root@centos7k8s1 deployment]# vim 01_nginx_deploy_update_demo.yml 
[root@centos7k8s1 deployment]# kubectl apply -f 01_nginx_deploy_update_demo.yml 
deployment.apps/nginx-rs-deploy-demo-1 configured
service/nginx-rs-svc unchanged
[root@centos7k8s1 deployment]# kubectl get -n haha all
NAME                                          READY   STATUS        RESTARTS   AGE
pod/nginx-rs-deploy-demo-1-678b57df66-5x528   1/1     Running       0          32m
pod/nginx-rs-deploy-demo-1-678b57df66-bnmmf   1/1     Terminating   0          32m
pod/nginx-rs-deploy-demo-1-cf86b89d7-b5m7k    0/1     Init:0/1      0          1s
pod/nginx-rs-deploy-demo-1-cf86b89d7-hzdj9    1/1     Running       0          3s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/nginx-rs-svc   ClusterIP   10.200.53.175   <none>        88/TCP    33m

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-rs-deploy-demo-1   2/2     2            2           33m

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-rs-deploy-demo-1-678b57df66   1         1         1       32m
replicaset.apps/nginx-rs-deploy-demo-1-7c6447f865   0         0         0       33m
replicaset.apps/nginx-rs-deploy-demo-1-cf86b89d7    2         2         1       3s

当升级时，如果是全新镜像，此时就会创建一个新的replicaset去拉起新pod



[root@centos7k8s1 deployment]# vim 01_nginx_deploy_update_demo.yml 
[root@centos7k8s1 deployment]# kubectl apply -f 01_nginx_deploy_update_demo.yml 
deployment.apps/nginx-rs-deploy-demo-1 configured
service/nginx-rs-svc unchanged
[root@centos7k8s1 deployment]# kubectl get -n haha all
NAME                                          READY   STATUS            RESTARTS   AGE
pod/nginx-rs-deploy-demo-1-7c6447f865-4dxpg   0/1     PodInitializing   0          2s
pod/nginx-rs-deploy-demo-1-cf86b89d7-b5m7k    1/1     Running           0          3m31s
pod/nginx-rs-deploy-demo-1-cf86b89d7-hzdj9    1/1     Running           0          3m33s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/nginx-rs-svc   ClusterIP   10.200.53.175   <none>        88/TCP    37m

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-rs-deploy-demo-1   2/2     1            2           37m

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-rs-deploy-demo-1-678b57df66   0         0         0       35m
replicaset.apps/nginx-rs-deploy-demo-1-7c6447f865   1         1         0       37m
replicaset.apps/nginx-rs-deploy-demo-1-cf86b89d7    2         2         2       3m33s

当回滚的时候，发现已经有对应镜像的replicaset，此时就可以replicaset根据hash值就可以重新拉起pod了，而之前的版本的pod就会被删除

[root@centos7k8s1 deployment]# kubectl get -n haha all --show-labels
NAME                                          READY   STATUS    RESTARTS   AGE   LABELS
pod/nginx-rs-deploy-demo-1-7c6447f865-4dxpg   1/1     Running   0          95m   app=wahaha1,pod-template-hash=7c6447f865
pod/nginx-rs-deploy-demo-1-7c6447f865-9jj9r   1/1     Running   0          95m   app=wahaha1,pod-template-hash=7c6447f865

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE    LABELS
service/nginx-rs-svc   ClusterIP   10.200.53.175   <none>        88/TCP    132m   <none>

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE    LABELS
deployment.apps/nginx-rs-deploy-demo-1   2/2     2            2           132m   item=wahaha

NAME                                                DESIRED   CURRENT   READY   AGE    LABELS
replicaset.apps/nginx-rs-deploy-demo-1-678b57df66   0         0         0       131m   app=wahaha1,pod-template-hash=678b57df66
replicaset.apps/nginx-rs-deploy-demo-1-7c6447f865   2         2         2       132m   app=wahaha1,pod-template-hash=7c6447f865
replicaset.apps/nginx-rs-deploy-demo-1-cf86b89d7    0         0         0       99m    app=wahaha1,pod-template-hash=cf86b89d7

当用kubectl去查看标签时，还会发现pod和replicaset自动加上了一段标签，这也是识别的一种方式
当创建pod的时候就是依据这些标签去创建的
```

## deploy资源的升级策略

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-linux85-deploy-update-strategy
spec:
  # replicas: 3
  # replicas: 5
  replicas: 10
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  # 定义升级策略
  strategy:
    # 升级的类型,"Recreate" or "RollingUpdate"
    # Recreate:
    #   先停止所有的Pod运行，然后在批量创建更新。
    #   生产环节中不推荐使用这种策略，因为升级过程中用户将无法访问服务!
    # RollingUpdate:
    #   滚动更新，即先实现部分更新，逐步替换原有的pod，是默认策略。
    # type: Recreate
    type: RollingUpdate
    # 自定义滚动更新的策略
    rollingUpdate:
      # 在原有Pod的副本基础上，多启动Pod的数量。
      # maxSurge: 2
      maxSurge: 3
      # 在升级过程中最大不可访问的Pod数量.
      # maxUnavailable: 1
      maxUnavailable: 2
  template:
    metadata:
      labels:
        apps: linux85-web
    spec:
      containers:
      - name: web
        # image: harbor.oldboyedu.com/update/apps:v1
        #image: harbor.oldboyedu.com/update/apps:v2
        # image: harbor.oldboyedu.com/update/apps:v3
        # image: nginx:1.16
        image: nginx:1.18

---

apiVersion: v1
kind: Service
metadata:
  name: oldboyedu-linux85-web-deploy-update-strategy
spec:
  selector:
    apps: linux85-web
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
```

## 交互式升级

```
kubectl edit -f 02_nginx_deploy_update_strategy_demo.yml
A copy of your changes has been stored to "/tmp/kubectl-edit-1549340794.yaml"
error: the namespace from the provided object "haha" does not match the namespace "default". You must pass '--namespace=haha' to perform this operation.
报错原因：未指定名称空间

---------------------------------------------

kubectl edit -f 02_nginx_deploy_update_strategy_demo.yml -n haha
deployment.apps/nginx-rs-deploy-strategy-demo-1 edited
service/nginx-rs-svc skipped

------------------------------------------------

[root@centos7k8s1 deployment]# kubectl edit -n haha deployments.apps nginx-rs-deploy-strategy-demo-1 
deployment.apps/nginx-rs-deploy-strategy-demo-1 edited

通过 kubectl edit 命令对资源文件进行编辑升级有两种方式
1. 对资源文件进行编辑升级
2. 对资源对象进行编辑升级
```

## 非交互式升级

```
[root@centos7k8s1 deployment]#  kubectl set image -f 02_nginx_deploy_update_strategy_demo.yml -n haha nginx-deploy-demo-1=harbor.myharbor.com/myharbor/nginx:v2.0-my
deployment.apps/nginx-rs-deploy-strategy-demo-1 image updated
error: services/nginx-rs-svc the object is not a pod or does not have a pod template: *v1.Service
# 报错是因为资源清单文件中，包含了service控制器，但是pod会正常更新
-----------------------------------------
kubectl set image deploy nginx-rs-deploy-strategy-demo-1 -n haha nginx-deploy-demo-1=harbor.myharbor.com/myharbor/nginx:v3.0-my
deployment.apps/nginx-rs-deploy-strategy-demo-1 image updated

# 生产中常用的一种升级回滚方式，有利于自动化更新
通过 kubectl set image 命令对资源文件进行编辑升级有两种方式
1. 对资源文件进行编辑升级
2. 对资源对象进行编辑升级
```

## redis部署案例

```
cat 03_redis_demo.yml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-update-demo
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 1
  selector:
    matchExpressions:
    - key: app
      values:
      - wahaha1-redis
      operator: In
#  strategy:
#    type: RollingUpdate
#    rollingUpdate:
#      maxSurge: 3
#      maxUnavailable: 2
  template:
    metadata:
      labels:
        app: wahaha1-redis
    spec:
      containers:
      - name: redis-update-demo-1 
        image: redis:6.2.14
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: '0.5'
            memory: '0.5G'
          limits:
            cpu: '1'
            memory: '1G'
---
apiVersion: v1
kind: Service
metadata:
  name: redis-svc
  namespace: haha
spec:
  selector:
    app: wahaha1-redis
#  type: NodePort
  ports:
  - port: 6379
    targetPort: 6379
```

## deployment实现蓝绿发布

蓝绿部署(Blue/Green)部署简介：
	蓝绿部署特点:
		不需要停止老版本代码(不影响上一版本访问)，而是在另外一套环境部署新版本然后进行测试。
		测试通过后将用户流量切换到新版本，其特点为业务无中断，升级风险相对较小。		

	- 实现机制:
		- 1.部署当前版本
		- 2.部署service
		- 3.部署新版本(使用新的deployment名称，新的label标签)
		- 4.切换service标签到新的pod

```
准备一个蓝版本
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-blue-demo
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: app
      values:
      - blue
      operator: In
  template:
    metadata:
      labels:
        app: blue
    spec:
      containers:
      - name: nginx-deploy-blue-demo-1  
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v3.0-my
        imagePullPolicy: IfNotPresent
     
  准备一个绿版本
  apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-green-demo
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: app
      values:
      - green
      operator: In
  template:
    metadata:
      labels:
        app: green
    spec:
      containers:
      - name: nginx-deploy-green-demo-1  
        #image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v3.0-my
        imagePullPolicy: IfNotPresent
        
准备一个service
apiVersion: v1
kind: Service
metadata:
  name: nginx-blue-green-svc
  namespace: haha
spec:
  selector:
    app: blue
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30001
    
    
当两个版本pod成功启动后，通过修改 svc seletor 切换标签达到版本切换，实现蓝绿部署
有三种方式
1.修改资源清单
2. kubectl edit 控制器 名称 [-n 名称空间]
kubectl edit svc nginx-blue-green-svc -n haha
3. kubectl set selector 控制器 名称 标签名=值  [-n 名称空间]
kubectl set selector svc nginx-blue-green-svc app=green -n haha
```



## deployment实现灰度发布

灰度/金丝雀(Canary)部署简介:
	金丝雀发布也叫灰度发布，是指在黑与白之间，能够平滑度过的一种发布方式，恢复发布是增量发布的一种类型，灰度发布是在原有版本可用的情况下，同时部署一个新版本应用作为"金丝雀"(小白鼠)，测试新版本的性能和表现，以保障整个体系稳定的情况下，尽早发现，调整问题。
	"金丝雀"的由来: 17世纪，英国矿工工人发现，金丝雀对瓦斯这种气体十分敏感，空气哪怕有极其微量的瓦斯，金丝雀也会停止歌唱，而当瓦斯超过一定限度时，虽然人类毫无察觉，金丝雀却早已毒发身亡，当时在采矿设备相对简陋的条件下，工人们每次下井都会带上一只金丝雀作为"瓦斯检测指标"，以便在危险情况下紧急撤离。

实现机制:

1.部署当前版本，使用多副本;(最开始是3个副本)

2.部署service，匹配一个label标签;

3.部署新版本(使用deployment名称，但是label标签和之前保持一致)，新版本runing之后service会自动匹配label并将pod添加service的endpoints接收客户端请求;(最开始)

4.灰度版本测试没有问题，将灰度版本的pod副本数逐渐增加为生产数量;

5.将旧版本pod逐渐调低至为0，此时数流量将全部转发至新版本;

```

```

