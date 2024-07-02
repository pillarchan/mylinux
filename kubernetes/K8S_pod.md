# K8S资源清单

## 	apiVersion

​		指的是Api的版本。

## 	kind

​		资源的类型。

## 	metadata

​		资源的元数据。比如资源的名称，标签，名称空间，注解等信息。

## 	spec

​		用户期望资源的运行状态。

## 	staus

​		资源实际的运行状态，由K8S集群内部维护。

## 资源清单帮助文档查看

```
kubectl explain pod[.object][.object]...
```

## 资源清单样例

```
apiVersion: v1
kind: Pod
metadata:
  name: string
spec:
  hostNetwork: string
  nodeName: string
  restartPolicy: string
  volumns:
  - name: string
    type: <object>
  containers: [array]
  - name: string
    image: string
    imagePullPolicy: string
    env: [array]
    - name: string
      value: string
    - name: string
      valueFrom: 
        fieldRef:
          fieldPath: string
    volumnMounts:
    - name: string
      mountPath: string
```

​	

## 实战案例

### K8S的Pod资源运行单个容器案例

```
(1)创建工作目录
 mkdir -pv /manifests/pods/ && cd /manifests/pods/
(2)编写资源清单
 cat 01-nginx.yaml
# 指定API的版本号
apiVersion: v1
# 指定资源的类型
kind: Pod
# 指定元数据
metadata:
  # 指定名称
  name: nginx-web
# 用户期望的资源状态
spec:
  # 定义容器资源
  containers:
    # 指定的名称
  - name: nginx
    # 指定容器的镜像
    image: nginx:1.14.2
(3)创建资源清单
	kubectl create -f 01-nginx.yaml 
	pod/linux85-web created
(4)查看资源
kubectl get pods -o wide
 
curl -I 10.100.2.5

相关字段说明:
	NAME
		代表的是资源的名称。
	READY   
		代表资源是否就绪。比如 0/1 ，表示一个Pod内有一个容器，而且这个容器还未运行成功。
	STATUS    
		代表容器的运行状态。
	RESTARTS   
		代表Pod重启次数，即容器被创建的次数。
	AGE     
		代表Pod资源运行的时间。
	IP            
		代表Pod的IP地址。
	NODE
		代表Pod被调度到哪个节点。
	其他:	
		"NOMINATED NODE和"READINESS GATES"暂时先忽略哈。
(5)删除资源
 kubectl delete -f 01-nginx.yaml 
```

### 	K8S的Pod资源运行多个容器案例

```

(1)编写资源清单
cat 02-nginx-tomcat.yaml
apiVersion: v1
kind: Pod
metadata:
  name: linux85-nginx-tomcat
spec:
  containers:
  - name: nginx
    image: nginx:1.23.4-alpine
  - name: tomcat
    image: tomcat:jre8-alpine

kubectl create -f 02-nginx-tomcat.yaml
(2)查看Pod状态
 kubectl get pod
 kubectl describe pod linux85-nginx-tomcat 	
(3)删除Pod
kubectl delete pod linux85-nginx-tomcat 

```

## 	k8s启动一个pod的流程

```
当k8s启动一个pod
1.启动pause容器，用于给业务容器分配网络名称空间
2.启动业务容器

业务容器故障挂掉，则会立即重启容器，但是IP地址不会发生变化
如果pause容器故障挂掉，所乘载的和业务容器也会同时挂掉，然后会重启pause容器和业务容器，此时IP地址就会发生改变
```

## k8s删除一个pod的流程

```
1. 在etcd里标记为删除
2. worker节点发送心跳给master节点，master节点发送回应时，将删除的动作发送给worker节点
3. worker节点回收删除pod后再上报给 api server
```



## 故障排查案例

```
(1)资源清单
    # 给容器分配一个标准输入，默认值为false
    # stdin: true
    # 给容器分配一个启动命令，修改Dockerfile的CMD指令
    # args: ["tail","-f","/etc/hosts"]
    # 也可以修改command字段，相当于修改Dockerfile的ENTRYPOINT指令
    # command: ["sleep","15"]
    # args也可以和command命令搭配使用，和Dockfile的ENTRYPOINT和CMD效果类似
    # --- pod 隔离符可以在一个文件中启动多个pod
apiVersion: v1
kind: Pod
metadata:
  name: nginx-web-01
spec:
  hostNetwork: true
  nodeName: centos79k8s2
  containers:
apiVersion: v1
kind: Pod
metadata:
  name: nginx-web-01
spec:
  hostNetwork: true
  nodeName: centos79k8s2
  containers:
  - name: nginx01
    image: nginx:1.24.0-alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-web-02
spec:
  hostNetwork: true
  nodeName: centos79k8s2
  containers:
  - name: nginx02
    image: nginx:1.24.0-alpine
    command: 
    - "tail"
    args:
    - "-f"
    - "/etc/hosts"   
(2)创建Pod
kubectl apply -f 03-nginx-alpine.yaml 
(3)使用kubectl exec pod linux -it -- sh 进入容器内排查具体故障


排查总结：
当指定使用宿主机IP和指定分配到同一节点造成端口冲突导致，虽然使用了字段理想可以自定义port，但实际还是按镜像中端口启动
ports:
- containerPort: 

强制删除状态为terminating的pod
kubectl delete pod <pod_name> --grace-period=0 --force
```


参考案例：
```
cat 04-ketanglianxi.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: linux85-game-001
spec:
  hostNetwork: true

  ### 将Pod调度到指定节点，注意，该node名称必须和etcd的数据保持一致
 nodeName: k8s232.harbor.com
  containers:

  - name: game
    image: harbor.harbor.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.1
```

## 故障常用命令

### 	(1)将Pod容器的文件拷贝到宿主机

```
 kubectl cp linux85-game-008:/start.sh /tmp/start.sh
```

### 	(2)连接到Pod的容器

```
 kubectl exec -it linux85-game-008 -- sh
```

### 	(3)查看某个Pod的日志。

```
kubectl logs -f linux85-web 
```

### (4)查看某个pod的详情

```
kubectl describe pod nginx-web
```

## POD管理常用命令

### 创建

```
kubectl create
kubectl apply
```

### 删除

```
kubectl delete
```

### 查看

```
kubectl get
```

### 修改

```
kubectl apply
```

# 面试题

## Q1: 当一个Pod有多个容器时，如果连接到指定的容器？

```
 kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
linux85-nginx-tomcat   2/2     Running   0          63s

 kubectl exec -it linux85-nginx-tomcat -- sh  # 默认连接到第一个容器
Defaulted container "nginx" out of: nginx, tomcat 
/ # 
 kubectl exec -it linux85-nginx-tomcat -c nginx -- sh  # 连接nginx容器
/ # 
 kubectl exec -it linux85-nginx-tomcat -c tomcat -- sh  # 连接tomcat容器
/usr/local/tomcat # 

早期版本中，可能没有提示Pod容器的名称，可以采用以下三种方式查看容器名称。
# cat 02-nginx-tomcat.yaml 
# kubectl describe pod linux85-nginx-tomcat 
# kubectl get pods linux85-nginx-tomcat -o yaml
```

## Q2: 如果查看一个Pod最近20分钟的日志?

```
 kubectl logs -c nginx -f  --timestamps --since=20m linux85-nginx-tomcat 
 -c:
	指定要查看的容器名称。
 -f:
	实时查看日志。
 --timestamps :
	显示时间戳相关信息。
 --since=20m 
	查看最近20分钟内的日志。
```

## Q3: 如果查看一个Pod上一个容器的日志，上一个挂掉的容器

```
kubectl logs -c tomcat -f  --timestamps -p  linux85-nginx-tomcat 
```

## Q4: 使用kubectl logs无法查看日志是什么原因，如何让其能够查看呢?

```
使用"kubectl logs"查看的是容器的标准输出或错误输出日志，如果想要使用该方式查看，需要将日志重定向到/dev/stdout或者/dev/stderr。

可以使用Dockerfile来操作
```

## Q5: 如何实现Pod的容器的文件和宿主机之间相互拷贝?


	- 将Pod的的文件拷贝到宿主机
	kubectl get pods
	NAME               READY   STATUS    RESTARTS   AGE
	linux85-game-014   1/1     Running   0          3m10s
	kubectl cp linux85-game-014:/start.sh /tmp/1.sh  # 拷贝文件
	kubectl cp linux85-game-014:/etc /tmp/2222  # 拷贝目录
	
	- 将宿主机的文件拷贝到Pod的容器中
	kubectl cp 01-nginx.yaml linux85-game-014:/ 
	kubectl cp /tmp/2222/ linux85-game-014:/ 
	kubectl exec linux85-game-014 -- ls -l /
	total 24
	-rw-r--r--    1 root     root           301 Apr 13 09:03 01-nginx.yaml
	drwxr-xr-x   20 root     root          4096 Apr 13 09:04 2222
	...
## Q6: 镜像下载策略有哪些？请分别说明？

```
cat 06-nginx-imagePullPolicy.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: linux85-web-imagepullpolicy-001
spec:
  nodeName: k8s233.myharbor.com
  containers:
  - name: nginx
    image: harbor.myharbor.com/web/linux85-web:v0.1
    # 指定镜像的下载策略，有效值为: Always, Never, IfNotPresent
    #    Always:
    #       默认值，表示始终拉取最新的镜像。
    #    IfNotPresent:
    #       如果本地有镜像，则不去远程仓库拉取镜像，若本地没有，才会去远程仓库拉取镜像。
    #    Never:
    #       如果本地有镜像则尝试启动，若本地没有镜像，也不会去远程仓库拉取镜像。
    #imagePullPolicy: Always
    # imagePullPolicy: IfNotPresent
    imagePullPolicy: Never
```

## Q7: 容器的重启策略有哪些？请分别说?

```
#restartPolicy is either OnFailure or Always:
#Always: Automatically restarts the container after any termination.  容器退出就重启
#OnFailure: Only restarts the container if it exits with an error (non-zero exit status). 容器因错误退出就重启
#Never: Does not automatically restart the terminated container. 容器退出不重启
Pod的容器的三种重启策略:（注意， K8S所谓的容器指的是重新创建容器。） 

apiVersion: v1
kind: Pod
metadata:
  name: nginx-web-restart-policy-always
spec:
  hostNetwork: false
  nodeName: centos7k8s2
  restartPolicy: Always
  containers:
  - name: nginx-web
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    command:
    - "sleep"
    - "10"
---

apiVersion: v1
kind: Pod
metadata:
  name: nginx-web-restart-policy-onfailure
spec:
  hostNetwork: false
  nodeName: centos7k8s2
  restartPolicy: OnFailure
  containers:
  - name: nginx-web
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    command:
    - "sleep"
    - "10"
---

apiVersion: v1
kind: Pod
metadata:
  name: nginx-web-restart-policy-never
spec:
  hostNetwork: false
  nodeName: centos7k8s2
  restartPolicy: Never
  containers:
  - name: nginx-web
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    command:
    - "sleep"
    - "10"  
```

## Q8: 如何向Pod的指定容器传递环境变量？有哪些方式，请简要说明？

```
向容器传递环境变量的两种方式:
apiVersion: v1
kind: Pod
metadata:
  name: nginx-web
spec:
  hostNetwork: false
  nodeName: centos7k8s3
  restartPolicy: OnFailure
  containers:
  - name: nginx-web
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
# env字段使用    
    env:
    #自定义变量
    - name: MYNAME #变量名
      value: "yoyo" #值
    - name: HANAME
      value: "haha"
    - name:  HAPOD_NAME
      valueFrom: #变量引用
        fieldRef: #字段引用
          fieldPath: "metadata.name" #引用的路径
    - name:  HANODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: "spec.nodeName"
```

## Q9: 同一个Pod如何实现数据持久化？如何实现数据共享？跨节点的Pod如何实现数据共享呢？

### 数据持久化之emptyDir实战案例

```
cat 09_nginx_volumns_empty_dir.yml

apiVersion: v1
kind: Pod
metadata:
  name: nginx-volumns-empty
spec:
  hostNetwork: false
#  nodeName: centos79k8s2
  restartPolicy: OnFailure
  volumes:   # 定义存储卷
  - name: data01 # 指定存储卷的名称
    # 指定存储卷类型为emptyDir类型
    # 当Pod被删除时，数据会被随时删除，其有以下两个作用:
    #    - 对容器的数据进行持久化，当删除容器时数据不会丢失;
    #    - 可以实现同一个Pod内不同容器之间数据共享;
    emptyDir: {}
  containers:
  - name: nginx-volumns-empty
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: data01 # 指定存储卷的名称
      mountPath: /usr/share/nginx/html #指定容器的挂载目录

```

### 数据持久化之hostPath实战案例

```
cat 10_nginx_volumns_host_path.yml 

apiVersion: v1
kind: Pod
metadata:
  name: nginx-volumes-host-path
spec:
  hostNetwork: false
#  nodeName: centos79k8s2
  restartPolicy: OnFailure
  volumes:
  - name: data01
    hostPath: # 指定类型为宿主机存储卷，该存储卷只要用于容器访问宿主机路径的需求。 
      path: /data/nginx/html # 指定存储卷的路径
  containers:
  - name: nginx-volumes-host-path
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: data01
      mountPath: /usr/share/nginx/html

当pod被删除时，宿主机指定存储卷的路径中的数据不会被删除
```

### 数据持久化之nfs实战案例

```
部署nfs server
	(1)所有节点安装nfs相关软件包
yum -y install nfs-utils

	(2)k8s231节点设置共享目录
mkdir -pv /oldboyedu/data/kubernetes
cat &gt; /etc/exports &lt;&lt;'EOF'
/data/kubernetes *(rw,no_root_squash)
EOF

	(3)配置nfs服务开机自启动
systemctl enable --now nfs

	(4)服务端检查NFS挂载信息
exportfs

	(5)客户端节点手动挂载测试
mount -t nfs centos79habor:/data/kubernets /mnt/
umount /mnt 


数据持久化之nfs
cat 11_nginx_volumns_nfs.yml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-volumes-nfs
spec:
  hostNetwork: false
#  nodeName: centos79k8s2
  restartPolicy: OnFailure
  volumes:
  - name: data01
    nfs: # 指定存储卷类型是nfs
      server: 192.168.76.141 # 指定nfs服务器的地址
      path: /data/kubernets/nginx/html # 指定nfs对外暴露的挂载路径
  containers:
  - name: nginx-volumes-nfs
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: data01
      mountPath: /usr/share/nginx/html     
```



```


Q4: 多个Pod如何实现使用同一个配置文件?

Q5: 如何下载habor的私有项目镜像？

Q6: Pod如何实现健康检查？







容器的资源限制实战案例:
[root@k8s231.oldboyedu.com pods]# cat 12-stress.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: linux85-stress-003
spec:
  nodeName: k8s233.oldboyedu.com
  containers:
  - name: stress
    image: jasonyin2020/oldboyedu-linux-tools:v0.1
    args:
    - "tail"
    - "-f"
    - "/etc/hosts"
    # 对容器进行资源限制
    resources:
      # 期望目标节点有的资源大小，若不满足，则无法调度，Pod处于Pedding状态。
      # 若满足调度需求，调度到节点后也不会立刻使用requests字段的定义的资源。
      requests:
        # 要求目标节点有10G的可用内存.
        # memory: 10G
        memory: 256M
        # 指定CPU的核心数，固定单位: 1core=1000m
        cpu: 500m
      # 配置资源的使用上限
      limits:
        memory: 500M
        cpu: 1.5
[root@k8s231.oldboyedu.com pods]# 





configMap概述:

configmap数据会存储在etcd数据库，其应用场景主要在于应用程序配置。

configMap支持的数据类型:
	(1)键值对;
	(2)多行数据;
	
Pod使用configmap资源有两种常见的方式:
	(1)变量注入;
	(2)数据卷挂载
	
推荐阅读:
	https://kubernetes.io/docs/concepts/storage/volumes/#configmap	
	https://kubernetes.io/docs/concepts/configuration/configmap/



定义configMap(简称"cm")资源:
[root@k8s231.oldboyedu.com configMap]# cat 01-config-demo.yaml 
apiVersion: v1
kind: ConfigMap
metadata:
  name: linux85-config
# 定义cm资源的数据
data:
   # 定义单行数据
   school: oldboyedu
   class: linux85

   # 定义多行数据
   my.cfg: |
     datadir: "/var/lib/mysql"
     basedir: "/usr/share/mysql"
     socket: "/tmp/mysql.sock"

   student.info: |
     pengbing: "大长腿，熬夜，六味地黄丸"
     wumingkun: "彭斌,Linux"
     qinhongbin: "欧美,日韩,国产"
     liwenxua
```