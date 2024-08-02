# 如何实现删除了Pod后，自动拉起的功能?"kubectl delete pods --all"

# ReplicationController



## 副本是如何创建pod的呢？

通过 template 字段

```
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-rc-demo-1
  labels:
    item: haha
    version: v1.0
  namespace: item-haha
spec:
  replicas: 2
  selector:
    app: haha-1
  template:
    metadata:
      labels:
        app: haha-1
    spec:
      #restartPolicy: OnFailure
      containers:
      - name: nginx-demo-1
        image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
        imagePullPolicy: IfNotPresent
        
        
  template字段用于创建pod, 更多字段如: volumes configmaps 可以参照 kubectl explain rc.spec.template.spec      
        
```

## 副本与svc clusterIP 的综合案例

```
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-rc-svc-demo-1
  labels:
    item: haha
spec:
  replicas: 2
  selector:
    version: v1.0
    app: haha-1
  template:
    metadata:
      labels:
        version: v1.0
        app: haha-1
    spec:
      containers:
        - name: nginx-demo-1
          image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
          imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc-1
  labels:
    item: haha
spec:
  selector:
    version: v1.0
    app: haha-1
  type: ClusterIP
  ports:
    - port: 58888
      targetPort: 80
      protocol: TCP
  clusterIP: 10.200.111.101
```

## RC的升级与回滚

旧版本中可以使用kubectl rollout命令进行，而新版本中，就直接换一种思路了

当准备好了新的镜像去更新的时候，以声明式为例，image要修改为新的镜像地址，然后使用kubectl apply调用一下，而这时是不会更新的，可以利用rc中pod被删除会自动重新拉起新pod的特性，kubectl delete pod，此时需要注意，最好是逐个删除来达到滚动更新的效果

```

#上传镜像
[root@centos7k8s1 ~]# cat /opt/web/code/code_build.sh 
#!/bin/bash
docker build -t harbor.myharbor.com/myharbor/nginx:v1.0-my -f /opt/web/code/v1/Dockerfile /opt/web/code/v1
docker build -t harbor.myharbor.com/myharbor/nginx:v2.0-my -f /opt/web/code/v2/Dockerfile /opt/web/code/v2
docker build -t harbor.myharbor.com/myharbor/nginx:v3.0-my -f /opt/web/code/v3/Dockerfile /opt/web/code/v3
docker login -u admin -p 12345 harbor.myharbor.com
docker push harbor.myharbor.com/myharbor/nginx:v1.0-my
docker push harbor.myharbor.com/myharbor/nginx:v2.0-my
docker push harbor.myharbor.com/myharbor/nginx:v3.0-my

```



## 总结

### 功能

当pod被删除时，会自动重新拉起pod

### 关键字段

replicas 创建副本数的数量

selector 副本绑定选择器，主要使用标签选择

template 创建pod的模板
