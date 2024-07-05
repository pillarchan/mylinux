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

