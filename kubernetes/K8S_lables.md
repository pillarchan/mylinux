# 标签管理

## 响应式进行标签管理

### 查看标签

```
kubectl label pods --show-labels 
```

### 创建标签

```
kubectl label pods nginx-demo-01

[root@centos79k8s1 pods]# kubectl label pods nginx-demo-01 item=haha
pod/nginx-demo-01 labeled
[root@centos79k8s1 pods]# kubectl label pods nginx-demo-01 version=appv1.0
pod/nginx-demo-01 labeled

```

### 修改标签

```
kubectl label pods nginx-demo-01 --overwrite version=appv1.1
```

### 删除标签

```
[root@centos79k8s1 pods]# kubectl label pods nginx-demo-01 item-
```

## 声明式进行标签管理

```
cat  02_nginx_labels_demo.yml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-demo-labels-02
  labels: #通过labels对象中进行字段的添加、删除、修改，再重新apply就可以完成对labels的增删改
    project: hehe
    appversion: v1.1
spec:
#  hostNetwork: false
#  nodeName: centos79k8s2
  restartPolicy: OnFailure
#  volumes:
#  - name: data01
#    emptyDir: {}
  containers:
  - name: nginx-demo
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent

```

## 对比标签管理，响应式和声明式的区别

### 响应式

​		创建标签立即生效，但资源被重新创建时，标签可能会丢失哟~需要重新创建。
​		

### 声明式

​	需要将标签写入到资源清单，每次修改后需要重新应用资源的配置文件，否则不会生效。



标签管理不只限于对pod资源，对其它所有资源也都可以进行标签管理，可以通过响应式或者声明式的方式进行标签管理即可