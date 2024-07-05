# secret资源

##  如何下载habor的私有项目镜像？

## secret资源的增删改查实战

```
cat 01_nginx_secret.yml
apiVersion: v1
kind: Secret
metadata: 
  name: nginx-secret-01
data:
  username: ZWxhc3RpY3VzZXIK
  password: MTIzNDU2Cg==
  hostIP: MTkyLjE2OC43Ni4xNDEK
```

## Pod基于env引用secret资源案例

```
cat 11_pod_secret_env.yml 
apiVersion: v1
kind: Pod
metadata: 
  name: nginx-secret-env-01
spec:
  hostNetwork: false
  nodeName: centos7k8s2
  restartPolicy: OnFailure
  containers:
  - name: nginx-secret-env
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    env:
    - name: ELASTICUSER
      valueFrom: 
        secretKeyRef:
          name: nginx-secret-01
          key: username
    - name: PASSWORD
      valueFrom: 
        secretKeyRef:  # 指定引用的secret资源
          name: nginx-secret-01  # 指定secret的名称
          key: password # 指定secret的key
    - name: HOSTIP
      valueFrom: 
        secretKeyRef:
          name: nginx-secret-01
          key: hostIP
```

## Pod基于存储卷引用secret资源案例

```
apiVersion: v1
kind: Pod
metadata: 
  name: nginx-secret-volumes-01
spec:
  hostNetwork: false
  nodeName: centos7k8s2
  restartPolicy: OnFailure
  volumes:
  - name: data
    secret:
      secretName: nginx-secret-01
      items:
      - key: username
        path: username.info
      - key: password
        path: password.info
      - key: hostIP
        path: hostIP.info
  containers:
  - name: nginx-secret-volume
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    command: ["tail","-f","/etc/hosts"]
    volumeMounts:
    - name: data
      mountPath: /data/secret/username.conf
      subPath: username.info
    - name: data
      mountPath: /data/secret/password.conf
      subPath: password.info
    - name: data
      mountPath: /data/secret/hostIp.conf
      subPath: hostIP.info
```

## 私有库secret

```
kubectl create secret docker-registry mytest --docker-username=mytest --docker-password=Mytest123 --docker-email=mytest@mytest.com --docker-server=harbor.myharbor.com
secret/mytest created

kubectl get secrets mytest -o yaml

apiVersion: v1
kind: Pod
metadata: 
  name: nginx-secret-harbor-01
spec:
  hostNetwork: false
  nodeName: centos7k8s3
  restartPolicy: OnFailure
  containers:
  - name: nginx-secret-volume
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent

---

apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJoYXJib3IubXloYXJib3IuY29tIjp7InVzZXJuYW1lIjoibXl0ZXN0IiwicGFzc3dvcmQiOiJNeXRlc3QxMjMiLCJlbWFpbCI6Im15dGVzdEBteXRlc3QuY29tIiwiYXV0aCI6ImJYbDBaWE4wT2sxNWRHVnpkREV5TXc9PSJ9fX0=
kind: Secret
metadata:
  name: mytest
```

## Q1: 请问habor的secret创建是能否直接创建资源清单呢？

### K8S的两类API

#### 响应式

可以理解直接基于命令行的方式创建资源。换句话说，不通过配置文件创建资源。

#### 声明式

可以理解为通过资源清单的方式创建资源。话句话说，通过配置文件创建资源。

### 响应式案例

```
假设有一个库是 mytest1
用户名：mytest1
密码:Mytest1321
邮箱：mytest1@mytest1.com
server:harbor.myharbor.com


使用命令创建
[root@centos79k8s1 secret]# kubectl create secret docker-registry mytest1 --docker-username=mytest1 --docker-password=Mytest1321 --docker-email=mytest1@mytest1.com --docker-server=harbor.myharbor.com
secret/mytest1 created
[root@centos79k8s1 secret]# kubectl get secrets mytest1 -o yaml
apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJoYXJib3IubXloYXJib3IuY29tIjp7InVzZXJuYW1lIjoibXl0ZXN0MSIsInBhc3N3b3JkIjoiTXl0ZXN0MTMyMSIsImVtYWlsIjoibXl0ZXN0MUBteXRlc3QxLmNvbSIsImF1dGgiOiJiWGwwWlhOME1UcE5lWFJsYzNReE16SXgifX19
kind: Secret
metadata:
  creationTimestamp: "2024-07-05T01:40:09Z"
  name: mytest1
  namespace: default
  resourceVersion: "124285"
  uid: 8523c18e-ccf5-4081-9245-3bf2376cb678
type: kubernetes.io/dockerconfigjson
# 解密base64编码内容 可以得到原码
[root@centos79k8s1 secret]# echo -n eyJhdXRocyI6eyJoYXJib3IubXloYXJib3IuY29tIjp7InVzZXJuYW1lIjoibXl0ZXN0MSIsInBhc3N3b3JkIjoiTXl0ZXN0MTMyMSIsImVtYWlsIjoibXl0ZXN0MUBteXRlc3QxLmNvbSIsImF1dGgiOiJiWGwwWlhOME1UcE5lWFJsYzNReE16SXgifX19 | base64 -d
{"auths":{"harbor.myharbor.com":{"username":"mytest1","password":"Mytest1321","email":"mytest1@mytest1.com","auth":"bXl0ZXN0MTpNeXRlc3QxMzIx"}}}
# 继续解密 auth部分
[root@centos79k8s1 secret]# echo -n bXl0ZXN0MTpNeXRlc3QxMzIx | base64 -d
mytest1:Mytest1321[root@centos79k8s1 secret]# 

此时，就得到一个完整的json数据，可以依据此格式创建一个声明式的secret
```

### 声明式案例

```
假设有一个库是 mytest2
用户名：mytest2
密码:Mytest2321
邮箱：mytest1@mytest2.com
server:harbor.myharbor.com

[root@centos79k8s1 secret]# echo -n mytest2:Mytest2321 | base64
bXl0ZXN0MjpNeXRlc3QyMzIx
[root@centos79k8s1 secret]# echo -n '{"auths":{"harbor.myharbor.com":{"username":"mytest2","password":"Mytest2321","email":"mytest2@mytest2.com","auth":"bXl0ZXN0MjpNeXRlc3QyMzIx"}}}' | base64
eyJhdXRocyI6eyJoYXJib3IubXloYXJib3IuY29tIjp7InVzZXJuYW1lIjoibXl0ZXN0MiIsInBhc3N3b3JkIjoiTXl0ZXN0MjMyMSIsImVtYWlsIjoibXl0ZXN0MkBteXRlc3QyLmNvbSIsImF1dGgiOiJiWGwwWlhOME1qcE5lWFJsYzNReU16SXgifX19
[root@centos79k8s1 secret]# cat 02_yml_secret.yml 
apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJoYXJib3IubXloYXJib3IuY29tIjp7InVzZXJuYW1lIjoibXl0ZXN0MiIsInBhc3N3b3JkIjoiTXl0ZXN0MjMyMSIsImVtYWlsIjoibXl0ZXN0MkBteXRlc3QyLmNvbSIsImF1dGgiOiJiWGwwWlhOME1qcE5lWFJsYzNReU16SXgifX19
kind: Secret
metadata:
  name: mytest2
  
利用响应式创建出的json数据，反向去进行base64编码，再将数据赋值给对应的对象，就可以得到一个声明式的文件，应用这个文件就可以创建声明式的secret  
```

