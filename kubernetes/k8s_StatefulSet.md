# StatefulSet

## 概述

```
以Nginx的为例，当任意一个Nginx挂掉，其处理的逻辑是相同的，即仅需重新创建一个Pod副本即可，这类服务我们称之为无状态服务。
以MySQL主从同步为例，master，slave两个库任意一个库挂掉，其处理逻辑是不相同的，这类服务我们称之为有状态服务。
有状态服务面临的难题:
	(1)启动/停止顺序;
	(2)pod实例的数据是独立存储;
	(3)需要固定的IP地址或者主机名; 
StatefulSet一般用于有状态服务，StatefulSets对于需要满足以下一个或多个需求的应用程序很有价值。
	(1)稳定唯一的网络标识符。
	(2)稳定独立持久的存储。
	(4)有序优雅的部署和缩放。
	(5)有序自动的滚动更新。	
稳定的网络标识:
	其本质对应的是一个service资源，只不过这个service没有定义VIP，我们称之为headless service，即"无头服务"。
	通过"headless service"来维护Pod的网络身份，会为每个Pod分配一个数字编号并且按照编号顺序部署。
	综上所述，无头服务（"headless service"）要求满足以下两点:
		(1)将svc资源的clusterIP字段设置None，即"clusterIP: None";
		(2)将sts资源的serviceName字段声明为无头服务的名称;			
独享存储:
	Statefulset的存储卷使用VolumeClaimTemplate创建，称为"存储卷申请模板"。
	当sts资源使用VolumeClaimTemplate创建一个PVC时，同样也会为每个Pod分配并创建唯一的pvc编号，每个pvc绑定对应pv，从而保证每个Pod都有独立的存储。
```

## StatefulSets控制器-网络唯一标识之headless

### 	(1)编写资源清单

```
cat > 01_statefulset_headless_network.yml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: linux-headless
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None   # 将clusterIP字段设置为None表示为一个无头服务，即svc将不会分配VIP。
  selector:
    apps: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx-web-headless
spec:
  serviceName: linux-headless    #声明无头服务
  replicas: 3
  selector:
    matchLabels: 
      apps: nginx
  template:
    metadata:
      labels:
        apps: nginx
    spec:
      containers:
      - name: nginx-web-01
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
```

### 	(2)使用响应式API创建测试Pod

```
kubectl run --image=harbor.myharbor.com/myharbor/alpine --rm -it dns-test -- sh
/ # for i in $(seq 0 2);do ping nginx-web-headless-$i.linux-headless -c 4;done
PING nginx-web-headless-0.linux-headless (10.100.1.88): 56 data bytes
64 bytes from 10.100.1.88: seq=0 ttl=62 time=0.868 ms
64 bytes from 10.100.1.88: seq=1 ttl=62 time=1.494 ms
64 bytes from 10.100.1.88: seq=2 ttl=62 time=0.895 ms
64 bytes from 10.100.1.88: seq=3 ttl=62 time=1.338 ms

--- nginx-web-headless-0.linux-headless ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.868/1.148/1.494 ms
PING nginx-web-headless-1.linux-headless (10.100.5.28): 56 data bytes
64 bytes from 10.100.5.28: seq=0 ttl=64 time=0.259 ms
64 bytes from 10.100.5.28: seq=1 ttl=64 time=0.123 ms
64 bytes from 10.100.5.28: seq=2 ttl=64 time=0.283 ms
64 bytes from 10.100.5.28: seq=3 ttl=64 time=0.125 ms

--- nginx-web-headless-1.linux-headless ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.123/0.197/0.283 ms
PING nginx-web-headless-2.linux-headless (10.100.1.89): 56 data bytes
64 bytes from 10.100.1.89: seq=0 ttl=62 time=0.772 ms
64 bytes from 10.100.1.89: seq=1 ttl=62 time=1.576 ms
64 bytes from 10.100.1.89: seq=2 ttl=62 time=1.340 ms
64 bytes from 10.100.1.89: seq=3 ttl=62 time=0.838 ms

--- nginx-web-headless-2.linux-headless ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.772/1.131/1.576 ms
```

## StatefulSets控制器-独享存储

### 前置条件

```
sc 相关资源服务开启
```

### 	(1)编写资源清单

```
cat 02_statefulset_headless_volumeClaimTemplates.yml 
apiVersion: v1
kind: Service
metadata:
  name: linux-headless
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    apps: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nginx-web-sts-vct
spec:
  volumeClaimTemplates:   # 卷申请模板，会为每个Pod去创建唯一的pvc并与之关联哟!
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: "managed-nfs-storage" # 声明咱们自定义的动态存储类，即sc资源。
      resources:
        requests:
          storage: 2Gi
  serviceName: linux-headless
  replicas: 3
  selector:
    matchLabels: 
      apps: nginx
  template:
    metadata:
      labels:
        apps: nginx
    spec:
      containers:
      - name: nginx-web-01
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-web-sts-svc
spec:
  selector:
    apps: nginx
  ports:
  - port: 80
    targetPort: 80

```

### 	(2)连接到Pod逐个修改nginx首页文件

```
cd /opt/data/kubernetes/default-
default-data-nginx-web-sts-vct-0-pvc-0eabd805-82a5-47da-ab14-031921299411/
default-data-nginx-web-sts-vct-1-pvc-fb8392e8-f6b9-4e2d-ab94-5a1793e9c76a/
default-data-nginx-web-sts-vct-2-pvc-f045da04-45cf-4341-9a1d-807167ddf7c5/
default-test-claim-01-pvc-b9e61ef2-1506-459b-a372-24e20dc6a45f/
[root@centos7k8s1 deploy]# cd /opt/data/kubernetes/default-data-nginx-web-sts-vct-0-pvc-0eabd805-82a5-47da-ab14-031921299411/
[root@centos7k8s1 default-data-nginx-web-sts-vct-0-pvc-0eabd805-82a5-47da-ab14-031921299411]# ls
[root@centos7k8s1 default-data-nginx-web-sts-vct-0-pvc-0eabd805-82a5-47da-ab14-031921299411]# echo "sts0" > index.html
[root@centos7k8s1 default-data-nginx-web-sts-vct-0-pvc-0eabd805-82a5-47da-ab14-031921299411]# cd ..
[root@centos7k8s1 kubernetes]# echo "sts1" > default-data-nginx-web-sts-vct-1-pvc-fb8392e8-f6b9-4e2d-ab94-5a1793e9c76a/index.html
[root@centos7k8s1 kubernetes]# echo "sts2" > default-data-nginx-web-sts-vct-2-pvc-f045da04-45cf-4341-9a1d-807167ddf7c5/index.html
```

### 	(3)测试SVC访问

```
测试方式1:
kubectl get svc nginx-web-sts-svc 
NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
nginx-web-sts-svc   ClusterIP   10.200.3.231   <none>        80/TCP    17m

# while true;do curl 10.200.3.231;sleep 1;done

测试方式2:
vim /etc/resolv.conf   # 不修改宿主机的配置文件的话，可以直接启动pod进行测试即可。
...
nameserver 10.200.0.10

# while true;do curl nginx-web-sts-svc.default.svc.myharbor.com;sleep 1;done
```

