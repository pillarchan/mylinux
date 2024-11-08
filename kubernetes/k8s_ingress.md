# ingress

## 暴露Pod的方式

```
	- hostNetwork
	- hostPort
	- nodePort
	- Ingress
	- kubectl port-forward

如果两个服务的IP和端口冲突，则不能考虑使用四层代理
```

## LB（负载均衡）

```
	- 四层代理:
		- 传输层 ---> IP:PORT
	
	- 七层代理
		- 应用层 ---> http|ftp|redis|mysql|....
		
	http: Ingress Contoller ---> 
			nginx
			traefik
```

## 

## traefik

```
https://doc.traefik.io/traefik/
```

### 概念

```
Traefik 是一款 open-source 边缘路由器，可让您轻松地发布服务. 它接收来自您的系统请求，并找出负责处理它们的后端服务组件。

traefik 与众不同在于它能够自动发现适合您服务的配置。 当 Traefik 检查您的基础设施时，它会发现相关信息，并发现哪个服务服务于哪个请求。

Traefik 支持多种集群技术，如 Kubernetes，Kubernetes, Docker, Docker Swarm, AWS, Mesos, Marathon，下面为支持列表 ; 并且可以同时处理多个 providers。（它甚至适用于在裸机上运行的传统软件。）

使用 Traefik，无需维护和同步配置文件：所有操作都会自动实时完成（无重启，不用中断服务）。 使用 Traefik，您只需花时间于系统开发和部署新功能，而不是配置和维护其工作状态。
```

### 支持的提供者(https://www.traefik.tech/providers/overview/)

以下是 Traefik 目前支持的提供商列表。

| Provider                                                     | Type         | Configuration Type |
| :----------------------------------------------------------- | :----------- | :----------------- |
| [Docker](https://www.traefik.tech/providers/docker/)         | Orchestrator | Label              |
| [Kubernetes](https://www.traefik.tech/providers/kubernetes-crd/) | Orchestrator | Custom Resource    |
| [Marathon](https://www.traefik.tech/providers/marathon/)     | Orchestrator | Label              |
| [Rancher](https://www.traefik.tech/providers/rancher/)       | Orchestrator | Label              |
| [File](https://www.traefik.tech/providers/file/)             | Manual       | TOML format        |



###  使用helm安装traefik程序

#### 	(1)添加traefik的helm源

```
helm repo add traefik https://traefik.github.io/charts
```

#### 	(2)更新helm的源

```
helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "traefik" chart repository
...Successfully got an update from the "myhaha-aliyun" chart repository
...Successfully got an update from the "myhaha-azure" chart repository
Update Complete. ⎈Happy Helming!⎈

```

#### 	(3)拉取官方的traefik的Chart

```
helm pull traefik/traefik --untar
```

#### 	(4)修改Chart的配置文件

```
vim traefik/values.yaml 

image:  # @schema additionalProperties: false
  # -- Traefik image host registry
  registry: harbor.myharbor.com/myharbor
  # -- Traefik image repository
  repository: traefik
...
service:
  ...
  # type: LoadBalancer
  type: NodePort
```

#### 	(5)安装traefik程序

```
helm install traefik traefik
NAME: traefik
LAST DEPLOYED: Mon Sep 23 12:09:12 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
traefik with harbor.myharbor.com/myharbor/traefik:v3.1.4 has been deployed successfully on default namespace !
```

#### 	(6)开启traefik的端口转发功能，为了安全起见，helm默认没有开启dashboard，因此需要运维手动暴露

https://github.com/traefik/traefik-helm-chart/blob/master/EXAMPLES.md

```
value.yaml文件修改
ingressRoute:
  dashboard:
    enabled: true

kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000  --address=0.0.0.0
kubectl port-forward `kubectl get pods -l "app.kubernetes.io/name=traefik" -o name` --address=0.0.0.0  9000:9000
```

#### 	(7)访问traefik的dashboard页面，如果打不开，将6步骤重新执行下试试看

```
http://192.168.76.142:9000/dashboard/#/
```

### traefik values修改

#### 副本数的修改

```
...
deployment:
  # -- Enable deployment
  enabled: true
  # -- Deployment or DaemonSet
  kind: Deployment  #如有多个节点建议使用DaemonSet
  # -- Number of pods of the deployment (only applies when kind == Deployment)
  replicas: 1 #如需要使用多个副本，推荐按节点数修改
  ....
```

#### hostNetwork

```
# grep "traefik.podTemplate" -r ./traefik/
./traefik/templates/_podtemplate.tpl:{{- define "traefik.podTemplate" }}
./traefik/templates/daemonset.yaml:  template: {{ template "traefik.podTemplate" . }}
./traefik/templates/deployment.yaml:  template: {{ template "traefik.podTemplate" . }}

# grep "hostNetwork" ./traefik/templates/_podtemplate.tpl
      hostNetwork: {{ .Values.hostNetwork }}
```

### 查看traefik svc

```
kubectl describe svc traefik 
Name:                     traefik
Namespace:                default
Labels:                   app.kubernetes.io/instance=traefik-default
                          app.kubernetes.io/managed-by=Helm
                          app.kubernetes.io/name=traefik
                          helm.sh/chart=traefik-31.1.1
Annotations:              meta.helm.sh/release-name: traefik
                          meta.helm.sh/release-namespace: default
Selector:                 app.kubernetes.io/instance=traefik-default,app.kubernetes.io/name=traefik
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.200.114.253
IPs:                      10.200.114.253
Port:                     web  80/TCP
TargetPort:               web/TCP
NodePort:                 web  30587/TCP
Endpoints:                10.100.5.68:8000
Port:                     websecure  443/TCP
TargetPort:               websecure/TCP
NodePort:                 websecure  3629/TCP
Endpoints:                10.100.5.68:8443
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

### 工作流程

```
traefik 请求 api server,通过ETCD调取运维人员所编写的ingress规则,然后应用到所有traefik节点,traefik通过规则再去关联对应的svc,svc最终关联到pod
```



## ingress控制器

### 工作原理

```
通过ingress的第三方插件或组件，监听HTTP或HTTPS协议，当不同的域名分别对应不同服务时，就需要将其反向代理到不同的SVC，再由SVC去关联后端pod,由于走的是七层代理，可以识别用户的请求报文，ingress会去拆分请求报文，根据用户配置的ingress规则关联到不同的SVC

ingress规则需要定义域名与svc之间的关系，规则定义好之后，提交给api server并存储在etcd中，当用户访问请求时，要先经过ingress插件，通过api server将存储在etcd中的ingress规则中的解析返回给ingress插件，最后找到对应的svc
```

### 查看ingress控制器资源属性

```
# kubectl api-resources | grep ingress
ingressclasses                                 networking.k8s.io/v1                   false        IngressClass
ingresses                         ing          networking.k8s.io/v1                   true         Ingress
ingressroutes                                  traefik.io/v1alpha1                    true         IngressRoute
ingressroutetcps                               traefik.io/v1alpha1                    true         IngressRouteTCP
ingressrouteudps                               traefik.io/v1alpha1                    true         IngressRouteUDP
# kubectl api-resources | head -n1
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
```

### 资源清单编写

```
PathType 决定了 Path 匹配的解释。
PathType 可以是以下值之一：
* Exact：与 URL 路径完全匹配。
* Prefix：基于由“/”分隔的 URL 路径前缀进行匹配。匹配是按路径元素逐个元素进行的。路径元素指的是由“/”分隔符分隔的路径中的标签列表。如果每个 p 都是请求路径中 p 的元素前缀，则请求与路径 p 匹配。请注意，如果路径的最后一个元素是请求路径中最后一个元素的子字符串，则它不匹配（例如，/foo/bar 匹配 /foo/bar/baz，但不匹配 /foo/barbaz）。
* ImplementationSpecific：Path 匹配的解释取决于 IngressClass。实现可以将其视为单独的 PathType，也可以将其视为与 Prefix 或 Exact 路径类型相同。实现必须支持所有路径类型。


apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-bird
  namespace: games
spec:
  rules:
  - host: bird.myharbor.com
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service: 
            name: games-bird-svc
            port:
              number: 80
```

### 查看应用

```
kubectl -n games describe ingress ingress-bird 
Name:             ingress-bird
Labels:           <none>
Namespace:        games
Address:          
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host               Path  Backends
  ----               ----  --------
  bird.myharbor.com  
                     /   games-bird-svc:80 (10.100.1.120:80,10.100.5.69:80)
Annotations:         <none>
Events:              <none>
```

### 绑定访问

![image-20241002085153193](D:\learn\mylinux\kubernetes\image-20241002085153193.png)

![image-20241002085359322](D:\learn\mylinux\kubernetes\image-20241002085359322.png)



















```
今日作业:
	- 完成课堂的所有练习并整理思维导图;
	- 将"jasonyin2020/oldboyedu-games:v0.1"游戏镜像使用helm部署，请自行设计：
	
	
扩展作业:
	- 请尝试搭建helm的私有仓库，并将作业2推送到该私有仓库上.
		推荐阅读:
			https://github.com/helm/chartmuseum
			https://hub.docker.com/r/chartmuseum/chartmuseum
```

