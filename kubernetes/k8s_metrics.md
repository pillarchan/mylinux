# metric-server

## 概念

```
Metrics Server 是 Kubernetes 内置自动扩缩管道的可扩展、高效的容器资源指标来源。

Metrics Server 从 Kubelet 收集资源指标，并通过 Metrics API 在 Kubernetes apiserver 中公开它们，以供 Horizontal Pod Autoscaler 和 Vertical Pod Autoscaler 使用。Metrics API 也可以通过 kubectl top 访问，从而更轻松地调试自动扩缩管道。
```

## 部署metric-server

### 	(1)下载资源清单

```
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml
```

### 	(2)修改资源清单，修改deploy资源两处

```
vim high-availability-1.21+.yaml 
...
apiVersion: apps/v1
kind: Deployment
...
spec:
  ...
  template:
    ...
    spec:
		# 在args后添加"--kubelet-insecure-tls"，和"image"字段。
      - args:
        - --kubelet-insecure-tls #不携带证书访问
        # image: registry.k8s.io/metrics-server/metrics-server:v0.6.3
        image: registry.aliyuncs.com/google_containers/metrics-server:v0.6.3 #修改为国内源更容易访问
```

### 	(3)创建应用

```
kubectl apply -f high-availability-1.21+.yaml 
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
poddisruptionbudget.policy/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
```

### 	(4)检查状态

```
 kubectl -n kube-system get pods  | grep metrics-server
metrics-server-848678b447-kztmz                1/1     Running   0              5m47s
metrics-server-848678b447-rh6p6                1/1     Running   0              5m47s
```

### 	(5)验证 metrics-server是否正常

```
kubectl top node 
NAME                   CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s231.oldboyedu.com   168m         8%     1464Mi          39%       
k8s232.oldboyedu.com   53m          2%     663Mi           18%       
k8s233.oldboyedu.com   52m          2%     680Mi           18% 

kubectl top pods
NAME                                      CPU(cores)   MEMORY(bytes)   
linux-web-sts-volume-0                    0m           1Mi             
linux-web-sts-volume-1                    0m           1Mi             
linux-web-sts-volume-2                    0m           1Mi             
nfs-client-provisioner-69b9bbb79f-sj26j   3m           15Mi 
```

