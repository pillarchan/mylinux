# Q2: 请问Pod能否实现对容器的健康检查，如果服务有异常，直接重启？

# 探针(probe)

## 探针(probe)常用的方式

常用的探针(Probe)

### 	livenessProbe

​		健康状态检查，周期性检查服务是否存活，检查结果失败，将"重启"容器(删除源容器并重新创建新容器)。
​		如果容器没有提供健康状态检查，则默认状态为Success。

### 	readinessProbe

​		可用性检查，周期性检查服务是否可用，从而判断容器是否就绪。
​		若检测Pod服务不可用，则会将Pod从svc的ep列表中移除。
​		若检测Pod服务可用，则会将Pod重新添加到svc的ep列表中。
​		如果容器没有提供可用性检查，则默认状态为Success。

### 	startupProbe: (1.16+之后的版本才支持)

​		如果提供了启动探针，则所有其他探针都会被禁用，直到此探针成功为止。
​		如果启动探测失败，kubelet将杀死容器，而容器依其重启策略进行重启。 
​		如果容器没有提供启动探测，则默认状态为 Success。

## 探针(Probe)检测Pod服务方法

### 	exec

​		执行一段命令，根据返回值判断执行结果。返回值为0或非0，有点类似于"echo $?"。
​		

### httpGet

​	发起HTTP请求，根据返回的状态码来判断服务是否正常。

```
200: 返回状态码成功
301: 永久跳转
302: 临时跳转
401: 验证失败
403: 权限被拒绝
404: 文件找不到
413: 文件上传过大
500: 服务器内部错误
502: 无效的请求 
503：服务器无法提供服务
504: 后端应用网关响应超时
...
```

### tcpSocket

​	测试某个TCP端口是否能够链接，类似于telnet，nc等测试工具。    	
​    	
参考链接:
​	https://kubernetes.io/zh/docs/concepts/workloads/pods/pod-lifecycle/#types-of-probe
​	
​	

## 健康检查(livenessProbe)

### exec检测方式

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-livenessprobe-01
spec:
  hostNetwork: false
#  nodeName: centos7k8s2
  restartPolicy: OnFailure
  containers:
  - name: nginx-web
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    command:
    - "/bin/sh"
    - "-c"
    - "touch /tmp/atest.healthy;sleep 5;rm -f /tmp/atest.healthy;sleep 600"
    ports:
    - name: nginx-web
      containerPort: 80
      hostPort: 58888
      hostIP: "0.0.0.0"
    livenessProbe:     # 健康状态检查，周期性检查服务是否存活，检查结果失败，将重启容器。
      exec: # 使用exec的方式去做健康检查
        command: # 自定义检查的命令
        - "cat"
        - " /tmp/atest.healthy"
      failureThreshold: 3 # 检测服务失败次数的累加值，默认值是3次，最小值是1。当检测服务成功后，该值会被重置!
      initialDelaySeconds: 15 # 指定多久之后进行健康状态检查，即此时间段内检测服务失败并不会对failureThreshold进行计数。
      periodSeconds: 1 # 指定探针检测的频率，默认是10s，最小值为1.
      successThreshold: 1 # 检测服务成功次数的累加值，默认值为1次，最小值1.
      timeoutSeconds: 1 # 一次检测周期超时的秒数，默认值是1秒，最小值为1.
    resources:
      requests:
        cpu: 1
        memory: 256M
      limits:
        cpu: 2
        memory: 512M

温馨提示:
	在验证探针是否检查失败时，可以使用describe命令查看时间关于Reason内容包含"Unhealthy"所在的行，如下所示:
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  78s                default-scheduler  Successfully assigned default/nginx-livenessprobe-01 to centos7k8s2
  Normal   Pulled     30s (x2 over 77s)  kubelet            Container image "harbor.myharbor.com/myharbor/nginx:1.24-alpine" already present on machine
  Normal   Created    30s (x2 over 77s)  kubelet            Created container nginx-web
  Normal   Started    30s (x2 over 77s)  kubelet            Started container nginx-web
  Warning  Unhealthy  13s (x6 over 62s)  kubelet            Liveness probe failed: cat: can't open ' /tmp/atest.healthy': No such file or directory
  Normal   Killing    13s (x2 over 60s)  kubelet            Container nginx-web failed liveness probe, will be restarted

注意观察:
	“(x6 over 62s)”的内容，表示第6次检查失败，其中距离第一次检查失败已经经过了"62s"秒，而开始调度成功的时间是"60"之前，两者时间差详见，得出第一次检测失败的时间是"17s".
```

### httpGet检测方法

```
cat 16_liveness_probe_httpget.yml 
apiVersion: v1
kind: Pod
metadata:
  name: nginx-livenessprobe-httpget-01
spec:
  hostNetwork: false
#  nodeName: centos7k8s2
  restartPolicy: OnFailure
  volumes:
  - name: data
    emptyDir: {}
  containers:
  - name: nginx-web
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
#    command:
#    - "/bin/sh"
#    - "-c"
#    - "touch /tmp/atest.healthy;sleep 5;rm -f /tmp/atest.healthy;sleep 600"
    ports:
    - name: nginx-web
      containerPort: 80
      hostPort: 58888
      hostIP: "0.0.0.0"
    livenessProbe:
      httpGet: # 使用httpGet的方式去做健康检查
        port: 80  # 指定访问的端口号
        path: /index.html # 检测指定的访问路径
      failureThreshold: 3
      initialDelaySeconds: 35
      periodSeconds: 1
      successThreshold: 1
      timeoutSeconds: 1 
    resources:
      requests:
        cpu: 1
        memory: 256M
      limits:
        cpu: 2
        memory: 512M
```

### tcpSocket检测方法

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-livenessprobe-tcpsocket-01
spec:
  hostNetwork: false
#  nodeName: centos7k8s2
  restartPolicy: OnFailure
  volumes:
  - name: data
    emptyDir: {}
  containers:
  - name: nginx-web
    image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
    command:
    - "/bin/sh"
    - "-c"
    - "nginx;sleep 60;nginx -s stop;sleep 120"
    ports:
    - name: nginx-web
      containerPort: 80
      hostPort: 58888
      hostIP: "0.0.0.0"
    livenessProbe: 
      tcpSocket: # 使用tcpSocket的方式去做健康检查
        port: 80 # 指定访问的端口号
      failureThreshold: 3
      initialDelaySeconds: 35
      periodSeconds: 1
      successThreshold: 1
      timeoutSeconds: 1 
    resources:
      requests:
        cpu: 1
        memory: 256M
      limits:
        cpu: 2
        memory: 512M
```

## 健康检查(readinessProbe)

### httpGet检测方式和svc的案例

```
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-rc-svc-demo-2
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
        - name: nginx-demo-2
          image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
          imagePullPolicy: IfNotPresent
          readinessProbe:
            httpGet:
              port: 80
              path: /index.html
            failureThreshold: 3
            initialDelaySeconds: 15
            periodSeconds: 1
            successThreshold: 1
            timeoutSeconds: 1
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc-2
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

### 模拟检测失败和EP状态

```
[root@centos7k8s1 rc]# kubectl get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
nginx-rc-svc-demo-2-gblr9   1/1     Running   0          44m   10.100.1.20   centos7k8s2   <none>           <none>
nginx-rc-svc-demo-2-xc7kz   1/1     Running   0          44m   10.100.2.27   centos7k8s3   <none>           <none>
[root@centos7k8s1 rc]# kubectl exec -it nginx-rc-svc-demo-2-gblr9 -- sh -c 'mv /usr/share/nginx/html/index.html /tmp' 
[root@centos7k8s1 rc]# kubectl get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
nginx-rc-svc-demo-2-gblr9   0/1     Running   0          46m   10.100.1.20   centos7k8s2   <none>           <none>
nginx-rc-svc-demo-2-xc7kz   1/1     Running   0          46m   10.100.2.27   centos7k8s3   <none>           <none>
[root@centos7k8s1 rc]# kubectl get ep 
NAME          ENDPOINTS             AGE
kubernetes    192.168.76.142:6443   16d
nginx-svc-2   10.100.2.27:80        46m      #此处可以发现ep中ready状态为0的pod会被移出ep列表
[root@centos7k8s1 rc]# kubectl describe ep nginx-svc-2 
Name:         nginx-svc-2
Namespace:    default
Labels:       item=haha
Annotations:  endpoints.kubernetes.io/last-change-trigger-time: 2024-07-28T03:15:00Z
Subsets:
  Addresses:          10.100.2.27
  NotReadyAddresses:  10.100.1.20    #此处可以年到被移出ep列表的pod有哪些
  Ports:
    Name     Port  Protocol
    ----     ----  --------
    <unset>  80    TCP

Events:  <none>



# 当状态恢复后，可以发现 pod 会被自动添加到 ep 列表中

[root@centos7k8s1 rc]# kubectl exec -it nginx-rc-svc-demo-2-gblr9 -- sh -c 'mv /tmp/index.html /usr/share/nginx/html/index.html' 
[root@centos7k8s1 rc]# kubectl get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
nginx-rc-svc-demo-2-gblr9   1/1     Running   0          52m   10.100.1.20   centos7k8s2   <none>           <none>
nginx-rc-svc-demo-2-xc7kz   1/1     Running   0          52m   10.100.2.27   centos7k8s3   <none>           <none>
[root@centos7k8s1 rc]# kubectl describe ep nginx-svc-2 
Name:         nginx-svc-2
Namespace:    default
Labels:       item=haha
Annotations:  endpoints.kubernetes.io/last-change-trigger-time: 2024-07-28T03:21:22Z
Subsets:
  Addresses:          10.100.1.20,10.100.2.27
  NotReadyAddresses:  <none>
  Ports:
    Name     Port  Protocol
    ----     ----  --------
    <unset>  80    TCP

Events:  <none>
[root@centos7k8s1 rc]# kubectl get ep nginx-svc-2 
NAME          ENDPOINTS                       AGE
nginx-svc-2   10.100.1.20:80,10.100.2.27:80   53m

```

## 健康检查(startupProbe)

## 总结

### 共同点

1. 都是用于容器的健康检测
2. 检测方法都可以使用三种不同类型的方法进行检测

#### 区别

1. 优先级不同(级别从上到下)
   1. startup 
   2. readiness
   3. liveness
2. 检测时间点不同
   1. startup 在启动容器时检测
   2. readiness 在加载容器时检测
   3. liveness 在容器运行时检测
3. 检测失败的处理方式不同
   1. startup 启动探测失败，kubelet将杀死容器，而容器依其重启策略进行重启。 
   2. readiness 探测失败，若检测Pod服务不可用，则会将Pod从svc的ep列表中移除，ready状态为0；若检测Pod服务可用，则会将Pod重新添加到svc的ep列表中。
   3. liveness 探测失败,将"重启"容器(删除源容器并重新创建新容器)。

