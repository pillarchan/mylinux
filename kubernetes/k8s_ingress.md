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

## 工作原理

```
通过ingress的第三方插件或组件，监听HTTP或HTTPS协议，当不同的域名分别对应不同服务时，就需要将其反向代理到不同的SVC，再由SVC去关联后端pod,由于走的是七层代理，可以识别用户的请求报文，ingress会去拆分请求报文，根据用户配置的ingress规则关联到不同的SVC

ingress规则需要定义域名与svc之间的关系，规则定义好之后，提交给api server并存储在etcd中，当用户访问请求时，要先经过ingress插件，通过api server将存储在etcd中的ingress规则中的解析返回给ingress插件，最后找到对应的svc
```

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
image:
  ...
  # repository: traefik
  repository: harbor.oldboyedu.com/traefik/traefik
	
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

