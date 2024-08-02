# 容器启动顺序

网络基础容器->初始化容器->业务容器

# 初始化容器

初始化容器是给业务做准备的

# 初始化容器案例

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-initcontainers-demo-1
  labels:
    item: haha
spec:
  volumes:
  - name: data
    emptyDir: {}
  initContainers:
  - name: init-data-1
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    command:
    - 'sh'
    - '-c'
    - "for i in $(seq 1 5);do echo '<h1>'$(date +%F-%T)'</h1>' >> /data/index.html;sleep 2;done"
    volumeMounts:
    - mountPath: "/data"
      name: data
  - name: init-data-2
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    command:
    - 'sh'
    - '-c'
    - "chmod 644 -R /data/*"
    volumeMounts:
    - mountPath: "/data"
      name: data
  containers:
  - name: nginx-initcontainers-demo
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: data
```

# 初始化容器的运行阶段

初始化容器只会在，容器第一次启动时初始化一次
