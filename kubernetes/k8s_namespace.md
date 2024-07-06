# Q3: 如何实现创建多个名为"nginx-web"的Pod呢?

# 名称空间

在同一个名称空间下，同一种资源类型，是无法同时创建多个名称相同的资源。


user1: nginx-web


user2: nginx-web


名称空间是用来隔离K8S集群的资源。我们通常使用名称空间对企业业务进行逻辑上划分。

K8S集群一切皆资源，有的资源是不支持名称空间的，我们将其称为全局资源，而支持名称空间的资源我们称之为局部资源。


我们可以通过"kubectl api-resources"命令来判断一个资源是否支持名称空间。

温馨提示:
	（1）在同一个名称空间下，同一个资源类型是不能出现重名的;
	（2）在不同的名称空间下，相同的资源类型是能出现同名的;

# 名称空间的基本管理

## 名称空间的资源查看详解

### 1.查看现象有的名称空间

	kubectl get namespaces 
### 2.查看默认名称空间的Pod资源 

	kubectl get pods -n default
	kubectl get pods
### 3.查看指定的名称空间Pod资源

	kubectl get pods -n kube-system
	kubectl get pods --namespace kube-system
### 4.查看所有名称空间的Pod资源

	kubectl get pods --all-namespaces
	kubectl get pods -A	
### 5.查看所有名称空间的cm资源

	kubectl get cm -A
### 6.查看指定名称空间的cm资源

	kubectl get cm -n kube-system
## 创建名称空间

### 1.响应式创建名称空间		

	kubectl create namespace oldboyedu-linux85
### 2.声明式创建名称空间

```
cat ../namespace/01_ns_nginx_web2.yml
apiVersion: v1
kind: Namespace
metadata:
  name: my-nginx-web2
  labels:
    name: nginx-web2
```

## 修改名称空间

名称空间一旦创建将无法修改！
	

## 使用名称空间	

	apiVersion: v1
	kind: Pod
	metadata:
	  name: nginx-web
	  namespace: my-nginx-web1 #指定名称空间
	spec:
	  hostNetwork: false
	#  nodeName: centos7k8s2
	  restartPolicy: OnFailure
	  containers:
	  - name: nginx-web
	    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
	    imagePullPolicy: IfNotPresent
	
	---
	
	apiVersion: v1
	kind: Pod
	metadata:
	  name: nginx-web
	  namespace: my-nginx-web2
	spec:
	  hostNetwork: false
	#  nodeName: centos7k8s2
	  restartPolicy: OnFailure
	  containers:
	  - name: nginx-web
	    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
	    imagePullPolicy: IfNotPresent
## 删除名称空间

注意事项，一旦删除名称空间，该名称空间下的所有资源都会被随之删除哟！


	kubectl delete ns my-nginx-web1
	
	
	kubectl get po,cm -n my-nginx-web1
	No resources found in my-nginx-web1 namespace.
