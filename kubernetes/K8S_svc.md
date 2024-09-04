

# Q4: 如何实现当Pod的IP地址发生变化时，不影响这正常服务的使用呢？

# Service

## 两大特性：

1.对外提供负载均衡

2.对内提供服务发现



  ## 指定svc的类型，有效值为: ExternalName, ClusterIP, NodePort, and LoadBalancer
  ###    ExternalName
可以将K8S集群外部的服务映射为一个svc服务。类似于一种CNAME技术.

  ###    ClusterIP
仅用于K8S集群内部使用。提供统一的VIP地址。默认值！

  ###    NodePort
基于ClusterIP基础之上，会监听所有的Worker工作节点的端口，K8S外部可以基于监听端口访问K8S内部服务。

  ###    LoadBalancer
主要用于云平台的LB等产品。

## 案例

### ClusterIP

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc-01
  namespace: item-haha
  labels:
    item: haha
spec:
  selector:
    app: haha-1
  type: ClusterIP
  ports:
  - port: 8888
    targetPort: 80
    protocol: TCP
  clusterIP: 10.200.111.111
status: {}
```

### NodePort

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc-01
  namespace: haha
  labels:
    item: haha-svc
spec:
  selector:
    app: wahaha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30088
    protocol: TCP
  clusterIP: 10.200.111.111
status: {}

nodePort 创建后  iptables 会将节点中30088端口通过nat转发的方式对外部提供该端口访问，从而就可以使用 宿主机IP:端口进行访问
```

### LoadBalancer

```
LoadBalance案例：
- LoadBalance案例:
(1)前提条件
K8S集群在任意云平台环境，比如腾讯云，阿里云，京东云等。

(2)创建svc
[root@k8s231.oldboyedu.com services]# cat 03-services-LoadBalance.yaml
kind: Service
apiVersion: v1
metadata:
  name: svc-loadbalancer
spec:
  # 指定service类型为LoadBalancer，注意，一般用于云环境
  type: LoadBalancer
  selector:
    apps: linux85-web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
    
(3)配置云环境的应用负载均衡器
添加监听器规则，比如访问负载均衡器的80端口，反向代理到30080端口。
简而言之，就是访问云环境的应用服务器的哪个端口，把他反向代理到K8S集群的node端口为30080即可。

(4)用户访问应用负载均衡器的端口
用户直接访问云环境应用服务器的80端口即可，请求会自动转发到云环境nodePort的30080端口哟。
```

### ExternalName

```
ExternalName案例：
[root@k8s151.oldboyedu.com ~]# cat 04-svc-ExternalName.yaml 
apiVersion: v1
kind: Service
metadata:
  name: svc-externalname
spec:
  # svc类型
  type: ExternalName
  # 指定外部域名
  externalName: www.baidu.com

温馨提示:
	启动容器后访问名为"svc-externalname"的svc，请求会被cname到"www.baidu.com"的A记录。
	这种方式使用并不多，因为对于域名解析直接配置DSNS的解析较多，因此此处了解即可。
```

## k8s使用ep资源映射外部服务实战案例

```
(1)在K8S外部节点部署MySQL环境
[root@harbor.oldboyedu.com ~]# docker run -de MYSQL_ALLOW_EMPTY_PASSWORD=yes \
 -p 3306:3306 --name mysql-server --restart unless-stopped \
 -e MYSQL_DATABASE=wordpress \
 -e MYSQL_USER=wordpress_user \
 -e MYSQL_PASSWORD="123456" \
 harbor.myharbor.com/myharbor/mysql:8.0.36

(2)连接测试
docker exec -it mysql-server bash
bash-4.4# 
bash-4.4# mysql
...
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpress          |
+--------------------+
5 rows in set (0.00 sec)

mysql> USE wordpress
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)

(3)K8S编写ep资源
apiVersion: v1
kind: Endpoints
metadata:
  name: mysql-wordpress
  namespace: haha
subsets:
- addresses:
  - ip: 192.168.76.142
  ports:
  - port: 3306

(4)编写同名的svc资源
apiVersion: v1
kind: Service
metadata:
  name: mysql-wordpress
  namespace: haha
spec:
  ports:
  - port: 3306
    targetPort: 3306

(5)删除之前旧的WordPress数据
rm -rf /path/data/wordpress/*

(6)部署wordpres连接MySQL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-wordpress-demo
  labels:
    item: wordpress
  namespace: haha
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: app
      values:
      - wordpress1
      operator: In
#  strategy:
#    type: RollingUpdate
#    rollingUpdate:
#      maxSurge: 3
#      maxUnavailable: 2
  template:
    metadata:
      labels:
        app: wordpress1
    spec:
      #hostNetwork: true
      containers:
      - name: web-wordpress-demo-1
        image: harbor.myharbor.com/myharbor/wordpress
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        env:
        - name: WORDPRESS_DB_HOST
          value: "mysql-wordpress"
        - name: WORDPRESS_DB_USER
          value: "wordpress_user"
        - name: WORDPRESS_DB_PASSWORD
          value: "123456"   
        #resources:
        #  requests:
        #    cpu: '0.5'
        #    memory: '0.5G'
        #  limits:
        #    cpu: '1'
        #    memory: '1G'
	
(7)创建svc暴露WordPress应用
apiVersion: v1
kind: Service
metadata:
  name: wordpress-svc
  namespace: haha
spec:
  selector: 
    app: wordpress1
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080

(8)创建应用
kubectl delete all --all -n haha
kubectl apply -f .

(9)访问webUI测试
略。
```

