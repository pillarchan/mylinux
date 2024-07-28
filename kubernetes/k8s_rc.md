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

## 总结

### 功能

当pod被删除时，会自动重新拉起pod

### 关键字段

replicas 创建副本数的数量

selector 副本绑定选择器，主要使用标签选择

template 创建pod的模板
