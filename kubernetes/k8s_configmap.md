# configMap概述

configmap数据会存储在etcd数据库，其应用场景主要在于应用程序配置。

## configMap支持的数据类型

​	(1)键值对;
​	(2)多行数据;
​	

## Pod使用configmap资源有两种常见的方式

​	(1)变量注入;
​	(2)数据卷挂载
​	
推荐阅读:
​	https://kubernetes.io/docs/concepts/storage/volumes/#configmap	
​	https://kubernetes.io/docs/concepts/configuration/configmap/

# 定义configMap(简称"cm")资源

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data: #定义cm资源
  listen: "8080" #单行资源定义
  servername: "jjj.com"

  mysql: | #多行资源定义
    basedir: "/usr/local/mysql"
    datadir: "/data/mysql/3306"
    port: "3306"

  employeesinfo: |
    tom: "fishing,huting,rat"
    jerry: "cheese,run,joke"
```

# pod基于env环境变量引入cm资源

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod-cm-env
spec:
  hostNetwork: false
  nodeName: centos7k8s3
  restartPolicy: OnFailure
  containers:
  - name: nginx-cm
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    env:
    - name: LISTEN
      valueFrom:
        configMapKeyRef: # 指定引用的configMap资源
          key: listen # 指定引用的configMap资源中的key
          name: nginx-config # 指定引用的configMap资源名
    - name: SERVER
      valueFrom:
        configMapKeyRef:
          key: servername
          name: nginx-config 
```

# pod基于存储卷挂载cm资源，多行资源挂载为目录

```
[root@centos7k8s1 pods]# cat 10_pod_cm_mount_nfs.yml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod-cm-env-01
spec:
  hostNetwork: false
  nodeName: centos7k8s3
  restartPolicy: OnFailure
  volumes:
  - name: data 
    nfs:
      server: 192.168.76.141
      path: /data/nginx
  - name: conf
    configMap:
      name: nginx-config  #只写CM名，资源中的行名会以目录进行挂载
#      items: 
#        key: 
#        path: 
  containers:
  - name: nginx-cm
    image: harbor.myharbor.com/myharbor/mynginx:v0.1
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: data
      mountPath: /data/nginx
    - name: conf
      mountPath: /etc/nginx/conf.d #挂载点必须是空目录
```

