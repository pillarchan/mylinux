# helm

## 概述

```
helm是k8s资源清单的管理工具，它就像linux的包管理器，比如:yum apt

helm 术语
	helm: 命令行工具，用于K8S的chart的创建，打包，发布和管理
	chart: 应用描述，一系列用于描述K8S资源相关文件的集合
	release: 基于chart的部署实体，一个chart被helm运行后会生成一个release实体。这个release实体会在k8s集群中创建对应的资源对象

主要为了解决如：
1.资源清单过多，不易管理，如何将这些资源清单当成一个整体服务进行管理
2.应用的版本管理，如发布、回滚到指定版本
3.实现资源清单文件的高效复用

Helm目前有两个版本，即V2和V3。
		
	2019年11月Helm团队发布V3版本，相比v2版本最大变化是将Tiller删除，并大部分代码重构。

	helm v3相比helm v2还做了很多优化，比如不同命名空间资源同名的情况在v3版本是允许的，我们在生产环境中使用建议大家使用v3版本，不仅仅是因为它版本功能较强，而且相对来说也更加稳定了。
	官方地址:
		https://helm.sh/docs/intro/install/

	github地址:
		https://github.com/helm/helm/releases	
```

## 安装helm

### 下载helm

```
wget https://get.helm.sh/helm-v3.15.4-linux-amd64.tar.gz
```

### 解压helm程序到指定目录（此处不解压README.MD文档及授权文件信息）

```
tar xf helm-v3.15.4-linux-amd64.tar.gz -C /usr/local/sbin/ linux-amd64/helm --strip-components=1
"--strip-components":
			跳过解压目录的前缀路径。
```

### 验证helm安装成功

```
helm version
version.BuildInfo{Version:"v3.15.4", GitCommit:"fa9efb07d9d8debbb4306d72af76a383895aa8c4", GitTreeState:"clean", GoVersion:"go1.22.6"}
```

### 配置helm命令的自动补全-新手必备

```
helm completion bash > /etc/bash_completion.d/helm
source /etc/bash_completion.d/helm

helm  # 连续按2次tab键，出现如下内容则成功
completion  (generate autocompletion scripts for the specified shell)
create      (create a new chart with the given name)
dependency  (manage a chart's dependencies)
env         (helm client environment information)
get         (download extended information of a named release)
help        (Help about any command)
...
```

## helm部署服务

### 	(1)创建chart 

```
helm create haha-linux -n haha
如果需要指定名称空间，需要先创建名称空间 kubectl create ns xxx
```

### 	(2)安装chart

```
helm install hahaweb haha-linux -n haha
NAME: hahaweb
LAST DEPLOYED: Sun Sep 22 13:10:45 2024
NAMESPACE: haha
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace haha -l "app.kubernetes.io/name=haha-linux,app.kubernetes.io/instance=hahaweb" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace haha $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace haha port-forward $POD_NAME 8080:$CONTAINER_PORT
当创建好chart后，可以看到一个以chart名命名的目录

# tree haha-linux/
haha-linux/
├── charts
├── Chart.yaml 存放chart信息
├── templates
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
│   ├── serviceaccount.yaml
│   ├── service.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml
```

### (3)查看chart

```
# helm list -n haha
NAME   	NAMESPACE	REVISION	UPDATED                               	STATUS  	CHART           	APP VERSION
hahaweb	haha     	1       	2024-09-22 13:20:45.37916638 +0800 CST	deployed	haha-linux-0.1.0	1.16.0
```

#### Chart.yml

```
# cat haha-linux/Chart.yaml 
apiVersion: v2
name: haha-linux
description: A Helm chart for Kubernetes

# A chart can be either an 'application' or a 'library' chart.
#
# Application charts are a collection of templates that can be packaged into versioned archives
# to be deployed.
#
# Library charts provide useful utilities or functions for the chart developer. They're included as
# a dependency of application charts to inject those utilities and functions into the rendering
# pipeline. Library charts do not define any templates and therefore cannot be deployed.
type: application

# This is the chart version. This version number should be incremented each time you make changes
# to the chart and its templates, including the app version.
# Versions are expected to follow Semantic Versioning (https://semver.org/)
version: 0.1.0  #此处对应的就是chart的版本

# This is the version number of the application being deployed. This version number should be
# incremented each time you make changes to the application. Versions are not expected to
# follow Semantic Versioning. They should reflect the version the application is using.
# It is recommended to use it with quotes.
appVersion: "1.16.0" #此处对应的就是app的版本
```

#### NOTES.txt

```
当安装成功一个CHART后，就会显示其中的note信息，这个信息就保存在 chartpath/templates/NOTES.txt中
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace haha -l "app.kubernetes.io/name=haha-linux,app.kubernetes.io/instance=hahaweb" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace haha $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace haha port-forward $POD_NAME 8080:$CONTAINER_PORT
```

#### values.yaml

```
存放chart数据映射关系，这里可以把它理解为自定义chart全局变量的文件，以key: value的方式存储
如：
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""
...  
```

#### templates

```
该目录中存放的就是这个chart的资源清单了 包括如
templates
├── deployment.yaml
├── _helpers.tpl
├── hpa.yaml
├── ingress.yaml
├── NOTES.txt
├── serviceaccount.yaml
├── service.yaml
└── tests
    └── test-connection.yaml
```

#### 小结

```
通过响应式的方式创建一个chart后， 就可以得到这样一个框架，以此为模板就可以通过声明式的方式构建自己所需要的chart
```

### (4)卸载chart

```
helm -n haha uninstall hahaweb 
release "hahaweb" uninstalled
```

## helm构建自定义chart（小型案例）

### (1) 创建chart框架

#### 1.创建chart.yaml

```
cat Chart.yaml 
apiVersion: v2
name: myhaha
description: A defined helm
type: application
version: v1.0.1
appVersion: "v1.0"
```

#### 2.创建values.yaml

```
cat values.yaml 
namespace: haha
replicasCount: 2
image:
  repository: harbor.myharbor.com/myharbor/nginx
  pullPolicy: IfNotPresent
  tag: v1.0-my
labels:
  key1: apps
  apps: hahaweb1
net:
  protocol: http
  port: 80
```

#### 3.创建 templates/deployment.yaml

```
cat 01_nginx_deploy_update_demo.yml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myhaha
  labels:
    item: myhaha
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.replicasCount }}
  selector:
    matchExpressions:
    - key: {{ .Values.labels.key1 }}
      values:
      - {{ .Values.labels.apps }}
      operator: In
  template:
    metadata:
      labels:
        {{ .Values.labels.key1 }}: {{ .Values.labels.apps }}
    spec:
      containers:
      - name: nginx-deploy  
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        #image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v3.0-my
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: 80
          name: http #此处有关联，与service中targetPort调用该name的值成对应
```

#### 4.创建templates/service.yaml

```
cat 01_nginx_svc.yml 
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc-01
  namespace: {{ .Values.namespace }}
  labels:
    item: myhaha
spec:
  selector:
    {{ .Values.labels.key1 }}: {{ .Values.labels.apps }}
  type: NodePort
  ports:
  - port: {{ .Values.net.port }}
    targetPort: {{ .Values.net.protocol }} #如果service中的端口要使用如http,那么containers.ports.name就必须定义
    nodePort: 30001
```

#### 5.创建templates/NOTE.txt

```
cat NOTES.txt 
{{ .Values.image.repository }}:{{ .Values.image.tag }}部署成功
已启动
```

## helm的升级

### 1.基于文件的方式升级应用

#### 1.查看发现的Release

```
helm list -n haha
NAME     	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
myhahaweb	haha     	1       	2024-09-22 18:16:14.826510838 +0800 CST	deployed	myhaha-v1.0.1	v1.0
```

#### 2.修改 values.yaml

```
cat values.yaml 
namespace: haha
replicasCount: 2
image:
  repository: harbor.myharbor.com/myharbor/nginx
  pullPolicy: IfNotPresent
  tag: v2.0-my #修改了版本号
labels:
  key1: apps
  apps: hahaweb1
net:
  protocol: http
  port: 80
```

#### 3.使用upgrade命令升级

```
helm -n haha upgrade myhahaweb myhaha/ -f myhaha/values.yaml 
Release "myhahaweb" has been upgraded. Happy Helming!
NAME: myhahaweb
LAST DEPLOYED: Sun Sep 22 18:30:14 2024
NAMESPACE: haha
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
harbor.myharbor.com/myharbor/nginx:v2.0-my部署成功
已启动
[root@centos7k8s1 helm]# curl 10.200.99.213
<h1>myweb v2.you see</h1>
```

### 2.基于传参的方式升级应用

```
helm -n haha upgrade myhahaweb myhaha/ --set image.tag=v3.0-my
Release "myhahaweb" has been upgraded. Happy Helming!
NAME: myhahaweb
LAST DEPLOYED: Sun Sep 22 18:37:51 2024
NAMESPACE: haha
STATUS: deployed
REVISION: 3
TEST SUITE: None
NOTES:
harbor.myharbor.com/myharbor/nginx:v3.0-my部署成功
已启动

[root@centos7k8s1 helm]# helm -n haha list
NAME     	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
myhahaweb	haha     	3       	2024-09-22 18:37:51.790938624 +0800 CST	deployed	myhaha-v1.0.1	v1.0       
[root@centos7k8s1 helm]# curl 10.200.99.213
<h1>myweb v3.you see</h1>
```

## helm的回滚

### 	(1)查看当前的发行版本

```
helm -n haha list
NAME     	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
myhahaweb	haha     	3       	2024-09-22 18:37:51.790938624 +0800 CST	deployed	myhaha-v1.0.1	v1.0
```

### 	(2)查看某个Release发布的历史版本

```
helm -n haha history myhahaweb 
REVISION	UPDATED                 	STATUS    	CHART        	APP VERSION	DESCRIPTION     
1       	Sun Sep 22 17:39:39 2024	superseded	myhaha-v1.0.1	v1.0       	Install complete
2       	Sun Sep 22 18:30:14 2024	superseded	myhaha-v1.0.1	v1.0       	Upgrade complete
3       	Sun Sep 22 18:37:51 2024	deployed  	myhaha-v1.0.1	v1.0       	Upgrade complete
```

### 	(3)回滚到上一个版本

```
helm -n haha rollback myhahaweb 
Rollback was a success! Happy Helming!
[root@centos7k8s1 helm]# helm -n haha history myhahaweb 
REVISION	UPDATED                 	STATUS    	CHART        	APP VERSION	DESCRIPTION     
1       	Sun Sep 22 17:39:39 2024	superseded	myhaha-v1.0.1	v1.0       	Install complete
2       	Sun Sep 22 18:30:14 2024	superseded	myhaha-v1.0.1	v1.0       	Upgrade complete
3       	Sun Sep 22 18:37:51 2024	superseded	myhaha-v1.0.1	v1.0       	Upgrade complete #回滚是相对当前版本进行的，如果再次回滚的话，那么就是相对于4版本进行回滚到3版本
4       	Sun Sep 22 18:41:41 2024	deployed  	myhaha-v1.0.1	v1.0       	Rollback to 2   
[root@centos7k8s1 helm]# curl 10.200.99.213
<h1>myweb v2.you see</h1>
```

### 	(4)回滚到指定版本

```
helm -n haha rollback myhahaweb 1 #只需要加个版本参数就可以了
Rollback was a success! Happy Helming!
[root@centos7k8s1 helm]# curl 10.200.99.213
<h1>myweb v1.you see</h1>
[root@centos7k8s1 helm]# helm -n haha history myhahaweb 
REVISION	UPDATED                 	STATUS    	CHART        	APP VERSION	DESCRIPTION     
1       	Sun Sep 22 17:39:39 2024	superseded	myhaha-v1.0.1	v1.0       	Install complete
2       	Sun Sep 22 18:30:14 2024	superseded	myhaha-v1.0.1	v1.0       	Upgrade complete
3       	Sun Sep 22 18:37:51 2024	superseded	myhaha-v1.0.1	v1.0       	Upgrade complete
4       	Sun Sep 22 18:41:41 2024	superseded	myhaha-v1.0.1	v1.0       	Rollback to 2   
5       	Sun Sep 22 18:46:25 2024	deployed  	myhaha-v1.0.1	v1.0       	Rollback to 1
```

## 共有helm仓库管理

### 1.查看共有helm仓库

```
helm repo list
Error: no repositories to show
```

### 2.添加共有仓库

```
# helm repo add myhaha-azure http://mirror.azure.cn/kubernetes/charts/
"myhaha-azure" has been added to your repositories
# helm repo add myhaha-aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
"myhaha-aliyun" has been added to your repositories
# helm repo list
NAME         	URL                                                   
myhaha-azure 	http://mirror.azure.cn/kubernetes/charts/             
myhaha-aliyun	https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```

### 3.搜索关心的chart

```
# helm search repo redis
NAME                                  	CHART VERSION	APP VERSION	DESCRIPTION                                       
myhaha-aliyun/redis                   	1.1.15       	4.0.8      	Open source, advanced key-value store. It is of...
myhaha-aliyun/redis-ha                	2.0.1        	           	Highly available Redis cluster with multiple se...
myhaha-azure/prometheus-redis-exporter	3.5.1        	1.3.4      	DEPRECATED Prometheus exporter for Redis metrics  
myhaha-azure/redis                    	10.5.7       	5.0.7      	DEPRECATED Open source, advanced key-value stor...
myhaha-azure/redis-ha                 	4.4.6        	5.0.6      	DEPRECATED - Highly available Kubernetes implem...
myhaha-aliyun/sensu                   	0.2.0        	           	Sensu monitoring framework backed by the Redis ...
myhaha-azure/sensu                    	0.2.5        	0.28       	DEPRECATED Sensu monitoring framework backed by...
```

### 4.下载chart

```
helm pull oldboyedu-aliyun/mysql --untar
```

### 5.部署chart，部署过程中可能会遇到坑哟~请自行修改!【考点： deploy,sc,coreDNS】

```
helm install mymysql mysql/
```

### 6.测试链接MySQL

```
kubectl run -it --rm db-client --image=harbor.myharbor.com/myharbor/mysql:8.0.36 -- mysql -h mymysql-mysql.default.svc.myharbor.com -p$MYSQL_ROOT_PASSWORD
```

