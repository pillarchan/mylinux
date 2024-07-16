

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

