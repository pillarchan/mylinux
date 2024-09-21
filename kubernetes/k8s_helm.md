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



```
helm部署服务:
- 管理Chart生命周期初体验
	(1)创建chart
[root@k8s231.oldboyedu.com helm]# helm create oldboyedu-linux
Creating oldboyedu-linux
[root@k8s231.oldboyedu.com helm]# 

	
	(3)安装chart
[root@k8s231.oldboyedu.com helm]# helm install web01 oldboyedu-linux -n oldboyedu-helm
NAME: web01
LAST DEPLOYED: Sun Apr 23 15:51:49 2023
NAMESPACE: oldboyedu-helm
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
#######################################
# 欢迎使用老男孩IT教育K8S集群服务系统 #
#     官方网站:                       #
#         www.oldboyedu.com           #
#######################################

恭喜您: harbor.oldboyedu.com/web/apps:v1应用已经部署成功

请尝试访问web吧~
[root@k8s231.oldboyedu.com helm]# 

	
	(3)卸载chart
[root@k8s231.oldboyedu.com helm]# helm uninstall web01 -n oldboyedu-helm 
release "web01" uninstalled
[root@k8s231.oldboyedu.com helm]# 




helm的升级:
	(1)部署chart
[root@k8s231.oldboyedu.com helm]# helm install web01 oldboyedu-linux -n oldboyedu-helm 


	(2)查看发现的Release
[root@k8s231.oldboyedu.com helm]# helm list -n oldboyedu-helm 
NAME 	NAMESPACE     	REVISION	UPDATED                                	STATUS  	CHART               	APP VERSION
web01	oldboyedu-helm	1       	2023-04-23 16:30:22.790921622 +0800 CST	deployed	oldboyedu-linux-v0.1	v1         
[root@k8s231.oldboyedu.com helm]# 

	(3)基于文件的方式升级应用
[root@k8s231.oldboyedu.com helm]# cat oldboyedu-linux/values.yaml 
oldboyedu_linux_apps:
   namespace: oldboyedu-helm
   image: harbor.oldboyedu.com/web/apps
   tags: v2
 
replicas: 5

labels:
   apps: web
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# helm upgrade web01 oldboyedu-linux -f oldboyedu-linux/values.yaml -n oldboyedu-helm 
Release "web01" has been upgraded. Happy Helming!
NAME: web01
LAST DEPLOYED: Sun Apr 23 16:32:00 2023
NAMESPACE: oldboyedu-helm
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
#######################################
# 欢迎使用老男孩IT教育K8S集群服务系统 #
#     官方网站:                       #
#         www.oldboyedu.com           #
#######################################

恭喜您: harbor.oldboyedu.com/web/apps:v2应用已经部署成功

请尝试访问web吧~
[root@k8s231.oldboyedu.com helm]# 


	(4)再次查看版本
[root@k8s231.oldboyedu.com helm]# helm list -n oldboyedu-helm 
NAME 	NAMESPACE     	REVISION	UPDATED                                	STATUS  	CHART               	APP VERSION
web01	oldboyedu-helm	2       	2023-04-23 16:32:00.516613778 +0800 CST	deployed	oldboyedu-linux-v0.1	v1         
[root@k8s231.oldboyedu.com helm]# 


	(5)验证升级是否成功
[root@k8s231.oldboyedu.com helm]# kubectl get svc -n oldboyedu-helm 
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
oldboyedu-linux-web-svc   ClusterIP   10.200.246.134   <none>        80/TCP    2m49s
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# curl 10.200.246.134 
<h1 style='color: green;'>www.oldboyedu.com  v0.2</h1>
[root@k8s231.oldboyedu.com helm]# 


	(6)基于传参的方式升级应用
[root@k8s231.oldboyedu.com helm]# helm upgrade --set oldboyedu_linux_apps.tags=v3,replicas=2 web01 oldboyedu-linux -n oldboyedu-helm 
Release "web01" has been upgraded. Happy Helming!
NAME: web01
LAST DEPLOYED: Sun Apr 23 16:36:35 2023
NAMESPACE: oldboyedu-helm
STATUS: deployed
REVISION: 3
TEST SUITE: None
NOTES:
#######################################
# 欢迎使用老男孩IT教育K8S集群服务系统 #
#     官方网站:                       #
#         www.oldboyedu.com           #
#######################################

恭喜您: harbor.oldboyedu.com/web/apps:v3应用已经部署成功

请尝试访问web吧~
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# helm list -n oldboyedu-helm 
NAME 	NAMESPACE     	REVISION	UPDATED                                	STATUS  	CHART               	APP VERSION
web01	oldboyedu-helm	3       	2023-04-23 16:36:35.992389649 +0800 CST	deployed	oldboyedu-linux-v0.1	v1         
[root@k8s231.oldboyedu.com helm]#
[root@k8s231.oldboyedu.com helm]# kubectl get svc -n oldboyedu-helm 
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
oldboyedu-linux-web-svc   ClusterIP   10.200.246.134   <none>        80/TCP    6m46s
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# curl 10.200.246.134 
<h1 style='color: green;'>www.oldboyedu.com  v0.3</h1>
[root@k8s231.oldboyedu.com helm]# 



- helm的回滚:
	(1)查看当前的发行版本
[root@k8s231.oldboyedu.com helm]# helm list -n oldboyedu-helm 
NAME 	NAMESPACE     	REVISION	UPDATED                                	STATUS  	CHART               	APP VERSION
web01	oldboyedu-helm	3       	2023-04-23 16:36:35.992389649 +0800 CST	deployed	oldboyedu-linux-v0.1	v1         
[root@k8s231.oldboyedu.com helm]# 


	(2)查看某个Release发布的历史版本
[root@k8s231.oldboyedu.com helm]# helm history web01 -n oldboyedu-helm 
REVISION	UPDATED                 	STATUS    	CHART               	APP VERSION	DESCRIPTION     
1       	Sun Apr 23 16:30:22 2023	superseded	oldboyedu-linux-v0.1	v1         	Install complete
2       	Sun Apr 23 16:32:00 2023	superseded	oldboyedu-linux-v0.1	v1         	Upgrade complete
3       	Sun Apr 23 16:36:35 2023	deployed  	oldboyedu-linux-v0.1	v1         	Upgrade complete
[root@k8s231.oldboyedu.com helm]# 

	
	(3)回滚到上一个版本
[root@k8s231.oldboyedu.com helm]# helm rollback web01 -n oldboyedu-helm 
Rollback was a success! Happy Helming!
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# kubectl get svc -n oldboyedu-helm 
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
oldboyedu-linux-web-svc   ClusterIP   10.200.246.134   <none>        80/TCP    10m
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# curl 10.200.246.134
<h1 style='color: green;'>www.oldboyedu.com  v0.2</h1>
[root@k8s231.oldboyedu.com helm]# 

	(4)回滚到指定版本
[root@k8s231.oldboyedu.com helm]# helm history web01 -n oldboyedu-helm 
REVISION	UPDATED                 	STATUS    	CHART               	APP VERSION	DESCRIPTION     
1       	Sun Apr 23 16:30:22 2023	superseded	oldboyedu-linux-v0.1	v1         	Install complete
2       	Sun Apr 23 16:32:00 2023	superseded	oldboyedu-linux-v0.1	v1         	Upgrade complete
3       	Sun Apr 23 16:36:35 2023	superseded	oldboyedu-linux-v0.1	v1         	Upgrade complete
4       	Sun Apr 23 16:40:56 2023	superseded	oldboyedu-linux-v0.1	v1         	Rollback to 2   
5       	Sun Apr 23 16:42:10 2023	superseded	oldboyedu-linux-v0.1	v1         	Rollback to 3   
6       	Sun Apr 23 16:43:06 2023	deployed  	oldboyedu-linux-v0.1	v1         	Rollback to 4   
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# helm rollback web01 1 -n oldboyedu-helm 
Rollback was a success! Happy Helming!
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# kubectl get svc -n oldboyedu-helm 
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
oldboyedu-linux-web-svc   ClusterIP   10.200.246.134   <none>        80/TCP    13m
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# curl 10.200.246.134
<h1 style='color: green;'>www.oldboyedu.com  v0.1</h1>
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# helm history web01 -n oldboyedu-helm 
REVISION	UPDATED                 	STATUS    	CHART               	APP VERSION	DESCRIPTION     
1       	Sun Apr 23 16:30:22 2023	superseded	oldboyedu-linux-v0.1	v1         	Install complete
2       	Sun Apr 23 16:32:00 2023	superseded	oldboyedu-linux-v0.1	v1         	Upgrade complete
3       	Sun Apr 23 16:36:35 2023	superseded	oldboyedu-linux-v0.1	v1         	Upgrade complete
4       	Sun Apr 23 16:40:56 2023	superseded	oldboyedu-linux-v0.1	v1         	Rollback to 2   
5       	Sun Apr 23 16:42:10 2023	superseded	oldboyedu-linux-v0.1	v1         	Rollback to 3   
6       	Sun Apr 23 16:43:06 2023	superseded	oldboyedu-linux-v0.1	v1         	Rollback to 4   
7       	Sun Apr 23 16:44:07 2023	deployed  	oldboyedu-linux-v0.1	v1         	Rollback to 1   
[root@k8s231.oldboyedu.com helm]# 


	(5)卸载Release
[root@k8s231.oldboyedu.com helm]# helm uninstall web01 -n oldboyedu-helm 
release "web01" uninstalled
[root@k8s231.oldboyedu.com helm]# 



共有helm仓库管理:
	(1)添加共有仓库
[root@k8s231.oldboyedu.com helm]# helm repo add oldboyedu-azure http://mirror.azure.cn/kubernetes/charts/ 
"oldboyedu-azure" has been added to your repositories
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# helm repo add oldboyedu-aliyun https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
"oldboyedu-aliyun" has been added to your repositories
[root@k8s231.oldboyedu.com helm]# 


	(2)查看仓库列表
[root@k8s231.oldboyedu.com helm]# helm repo list
NAME            	URL                                                   
oldboyedu-azure 	http://mirror.azure.cn/kubernetes/charts/             
oldboyedu-aliyun	https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
[root@k8s231.oldboyedu.com helm]# 


	(3)搜索关心的chart
[root@k8s231.oldboyedu.com helm]# helm search repo mysql
NAME                                     	CHART VERSION	APP VERSION	DESCRIPTION                                       
oldboyedu-aliyun/mysql                   	0.3.5        	           	Fast, reliable, scalable, and easy to use open-...
oldboyedu-azure/mysql                    	1.6.9        	5.7.30     	DEPRECATED - Fast, reliable, scalable, and easy...
oldboyedu-azure/mysqldump                	2.6.2        	2.4.1      	DEPRECATED! - A Helm chart to help backup MySQL...
...

	(4)下载chart
[root@k8s231.oldboyedu.com helm]# helm pull oldboyedu-aliyun/mysql --untar


	(5)部署chart，部署过程中可能会遇到坑哟~请自行修改!【考点： deploy,sc,coreDNS】
[root@k8s231.oldboyedu.com helm]# helm install db01 mysql -n oldboyedu-helm 


	(6)测试链接MySQL
[root@k8s231.oldboyedu.com helm]# MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace oldboyedu-helm db01-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)
[root@k8s231.oldboyedu.com helm]# 
[root@k8s231.oldboyedu.com helm]# kubectl run -it --rm db-client --image=harbor.oldboyedu.com/db/mysql:8.0.32-oracle  -- mysql -h db01-mysql.oldboyedu-helm.svc.oldboyedu.com -p$MYSQL_ROOT_PASSWORD
If you don't see a command prompt, try pressing enter.

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

mysql> 





暴露Pod的方式:
	- hostNetwork
	- hostPort
	- nodePort
	- Ingress
	- kubectl port-forward




games.oldboyedu.com:8080 
www.oldboyedu.com:8080



LB:
	- 四层代理:
		- 传输层 ---> IP:PORT
	
	- 七层代理
		- 应用层 ---> http|ftp|redis|mysql|....
		
	http: Ingress Contoller ---> 
			nginx
			traefik
		
		
		


- 使用helm安装traefik程序
	(1)添加traefik的helm源
[root@k8s231.oldboyedu.com helm]# helm repo add traefik https://traefik.github.io/charts
"traefik" has been added to your repositories
[root@k8s231.oldboyedu.com helm]# 

	(2)更新helm的源
[root@k8s231.oldboyedu.com helm]# helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "oldboyedu-aliyun" chart repository
...Successfully got an update from the "traefik" chart repository
...Successfully got an update from the "oldboyedu-azure" chart repository
Update Complete. ⎈Happy Helming!⎈
[root@k8s231.oldboyedu.com helm]# 
	
	(3)拉取官方的traefik的Chart
[root@k8s231.oldboyedu.com helm]# helm pull traefik/traefik --untar
 
	
	(4)修改Chart的配置文件
[root@k8s231.oldboyedu.com helm]# vim traefik/values.yaml 
image:
  ...
  # repository: traefik
  repository: harbor.oldboyedu.com/traefik/traefik
	
service:
  ...
  # type: LoadBalancer
  type: NodePort



	(5)安装traefik程序
[root@k8s231.oldboyedu.com helm]# helm install traefik traefik


	(6)开启traefik的端口转发功能，为了安全起见，helm默认没有开启dashboar，因此需要运维手动暴露
[root@k8s231.oldboyedu.com helm]# kubectl port-forward `kubectl get pods -l "app.kubernetes.io/name=traefik" -o name` --address=0.0.0.0  9000:9000


	(7)访问traefik的dashboard页面，如果打不开，将6步骤重新执行下试试看
http://10.0.0.231:9000/dashboard/




今日作业:
	- 完成课堂的所有练习并整理思维导图;
	- 将"jasonyin2020/oldboyedu-games:v0.1"游戏镜像使用helm部署，请自行设计：
	
	
扩展作业:
	- 请尝试搭建helm的私有仓库，并将作业2推送到该私有仓库上.
		推荐阅读:
			https://github.com/helm/chartmuseum
			https://hub.docker.com/r/chartmuseum/chartmuseum
```

