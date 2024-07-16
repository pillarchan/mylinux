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

