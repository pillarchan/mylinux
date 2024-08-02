# ReplicaSets控制器

简称RS，用于控制副本的数量，而且比RC更轻量功能更多

# matchlabels案例

```
[root@centos7k8s1 rs]# cat 01_nginx_rs_demo.yml 
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs-demo
  labels:
    item: yoyo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: haha1
  template:
    metadata:
      labels:
        app: haha1
    spec:
      containers:
      - name: nginx-rs-demo-1  
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: '0.5'
            memory: '0.5G'
          limits:
            cpu: '1'
            memory: '1G'
        lifecycle:
          postStart:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - 'echo "<h2>yoyo page</h2>" > /usr/share/nginx/html/yoyo.html'
          preStop:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - 'nginx -s stop'
      initContainers:
      - name: init-somaxconn
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        command:
        - "/bin/sh"
        - "-c"
        - 'ls /proc/sys/net/core/somaxconn'
```

matchExpressions案例

```
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs-securitycontext-demo
  labels:
    item: yoyo
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      containers:
      - name: nginx-rs-demo-1  
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
        securityContext:
          #capabilities:
          #  add: 
          #  - ALL
          privileged: true
        resources:
          requests:
            cpu: '0.5'
            memory: '0.5G'
          limits:
            cpu: '1'
            memory: '1G'
        lifecycle:
          postStart:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - 'echo "<h2>yoyo page</h2>" > /usr/share/nginx/html/yoyo.html'
          preStop:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - 'nginx -s stop'
      initContainers:
      - name: init-somaxconn
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        securityContext:
          #capabilities:
          #  add: 
          #  - ALL
          privileged: true
        command:
        - "/bin/sh"
        - "-c"
        - 'echo 256 > /proc/sys/net/core/somaxconn'
        
 # 基于表达式匹配
    matchExpressions:
    - key: apps
      # values:
      # - haha
      # - xixi
      # - hehe
      # 当operator的值为In或者NotIn时，values的值不能为空。
      #   - In:
      #      key的值必须在values定义的数组内。
      #   - NotIn:
      #      key的值必须不在values定义的数组内。
      # operator: In
      # operator: NotIn
      # 当operator的值为Exists或者DoesNotExist时，values的值必须为空.
      #    - Exists:
      #       只要存在key即可。
      #    - DoesNotExist:
      #       只要不存在指定的key即可。
      # operator: Exists       
```

# Q1: rs资源如何实现升级和回滚呢？

```
[root@centos7k8s1 rs]# cat 04_nginx_rs_update_demo.yml 
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs-securitycontext-demo
  labels:
    item: yoyo
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: app
      values:
      - haha1
      operator: In
  template:
    metadata:
      labels:
        app: haha1
    spec:
      containers:
      - name: nginx-rs-demo-1  
        #image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        imagePullPolicy: IfNotPresent
        securityContext:
          #capabilities:
          #  add: 
          #  - ALL
          privileged: true
        resources:
          requests:
            cpu: '0.5'
            memory: '0.5G'
          limits:
            cpu: '1'
            memory: '1G'
        lifecycle:
          postStart:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - 'echo "<h2>yoyo page</h2>" > /usr/share/nginx/html/yoyo.html'
          preStop:
            exec:
              command:
              - "/bin/sh"
              - "-c"
              - 'nginx -s stop'
      initContainers:
      - name: init-somaxconn
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        securityContext:
          #capabilities:
          #  add: 
          #  - ALL
          privileged: true
        command:
        - "/bin/sh"
        - "-c"
        - 'echo 256 > /proc/sys/net/core/somaxconn'
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-rs-svc
spec:
  selector:
    app: haha1
  type: ClusterIP
  ports:
  - port: 88
    targetPort: 80

其实道理有RC的升级和回滚一样，都需要手动去修改一下新的镜像源，然后再应用，删除原pod，自动重新拉起新pod,来达到升级和回滚的效果
```

