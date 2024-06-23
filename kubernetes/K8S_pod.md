# K8S资源清单

## 	apiVersion:

​		指的是Api的版本。

## 	kind:

​		资源的类型。

## 	metadata:

​		资源的元数据。比如资源的名称，标签，名称空间，注解等信息。

## 	spec:

​		用户期望资源的运行状态。

## 	staus:

​		资源实际的运行状态，由K8S集群内部维护。
​	

## 实战案例:

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


​	K8S的Pod资源运行多个容器案例

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


故障排查案例
	(1)资源清单
 cat 03-nginx-alpine.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: linux85-nginx-alpine
spec:
  # 使用宿主机网络,相当于"docker run --network host"
  hostNetwork: true
  containers:
  - name: nginx
    image: nginx:1.23.4-alpine
  - name: linux
    image: alpine
    # 给容器分配一个标准输入，默认值为false
    # stdin: true
    # 给容器分配一个启动命令，修改Dockerfile的CMD指令
    # args: ["tail","-f","/etc/hosts"]
    # 也可以修改command字段，相当于修改Dockerfile的ENTRYPOINT指令
    # command: ["sleep","15"]
    # args也可以和command命令搭配使用，和Dockfile的ENTRYPOINT和CMD效果类似
    command:
    - "tail"
    args:
    - "-f"
    - "/etc/hosts"
    


​	(3)创建Pod
 kubectl apply -f 03-nginx-alpine.yaml 
pod/linux85-nginx-alpine created



​	
​	
​	
​	
- 环境准备
	(1)下载镜像
	docker pull jasonyin2020/oldboyedu-games:v0.4 
	docker pull jasonyin2020/oldboyedu-games:v0.1
	
	(2)将镜像打包
	docker tag jasonyin2020/oldboyedu-games:v0.1 harbor.oldboyedu.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.1

docker tag jasonyin2020/oldboyedu-games:v0.4 harbor.oldboyedu.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.4

​	(3)将镜像推送到harbor仓库
docker push harbor.oldboyedu.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.1
docker push harbor.oldboyedu.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.4




课堂练习:
	将"harbor.oldboyedu.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.1"镜像使用Pod部署，并在浏览器中可以访问。

​	


参考案例：
 cat 04-ketanglianxi.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: linux85-game-001
spec:
  hostNetwork: true
  # 将Pod调度到指定节点，注意，该node名称必须和etcd的数据保持一致
  nodeName: k8s232.oldboyedu.com
  containers:
  - name: game
    image: harbor.oldboyedu.com/oldboyedu-games/jasonyin2020/oldboyedu-games:v0.1
    

 

故障常用命令：
	(1)将Pod容器的文件拷贝到宿主机
 kubectl get pods
NAME               READY   STATUS    RESTARTS   AGE
linux85-game-008   1/1     Running   0          4m15s

 kubectl cp linux85-game-008:/start.sh /tmp/start.sh


​	(2)连接到Pod的容器
 kubectl get pods
NAME               READY   STATUS    RESTARTS   AGE
linux85-game-008   1/1     Running   0          4m15s

 kubectl exec -it linux85-game-008 -- sh


​	(3)查看某个Pod的日志。
[root@k8s231.oldboyedu.com games]# kubectl get pods
NAME               READY   STATUS    RESTARTS   AGE
linux85-game-013   1/1     Running   0          6m15s
linux85-web        1/1     Running   0          119s
[root@k8s231.oldboyedu.com games]# 
[root@k8s231.oldboyedu.com games]# kubectl logs -f linux85-web 


​	
-----
Q1: 当一个Pod有多个容器时，如果连接到指定的容器？
 kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
linux85-nginx-tomcat   2/2     Running   0          63s

 kubectl exec -it linux85-nginx-tomcat -- sh  # 默认连接到第一个容器
Defaulted container "nginx" out of: nginx, tomcat
/ # 
/ # 
/ # 
 kubectl exec -it linux85-nginx-tomcat -c nginx -- sh  # 连接nginx容器
/ # 

 kubectl exec -it linux85-nginx-tomcat -c tomcat -- sh  # 连接tomcat容器
/usr/local/tomcat # 




​	早期版本中，可能没有提示Pod容器的名称，可以采用以下三种方式查看容器名称。
# cat 02-nginx-tomcat.yaml 
# kubectl describe pod linux85-nginx-tomcat 
# kubectl get pods linux85-nginx-tomcat -o yaml





Q2: 如果查看一个Pod最近20分钟的日志?
 kubectl logs -c nginx -f  --timestamps --since=20m linux85-nginx-tomcat 

 -c:
	指定要查看的容器名称。

 -f:
	实时查看日志。

 --timestamps :
	显示时间戳相关信息。


 --since=20m 
	查看最近20分钟内的日志。





Q3: 如果查看一个Pod上一个容器的日志，上一个挂掉的容器