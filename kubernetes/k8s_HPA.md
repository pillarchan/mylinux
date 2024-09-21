# HPA（HorizontalPodAutoscale）

## 概念

```
水平 Pod 自动扩展
在 Kubernetes 中，HorizontalPodAutoscaler 会自动更新工作负载资源（例如 Deployment 或 StatefulSet），目的是自动扩展工作负载以满足需求。
水平扩展意味着对增加的负载的响应是部署更多 Pod。这与垂直扩展不同，对于 Kubernetes 来说，垂直扩展意味着为已经为工作负载运行的 Pod 分配更多资源（例如：内存或 CPU）。
如果负载减少，并且 Pod 数量高于配置的最小值，HorizontalPodAutoscaler 会指示工作负载资源（Deployment、StatefulSet 或其他类似资源）缩减规模。
水平 Pod 自动扩展不适用于无法扩展的对象（例如：DaemonSet）。
HorizontalPodAutoscaler 实现为 Kubernetes API 资源和控制器。资源决定控制器的行为。在 Kubernetes 控制平面中运行的水平 pod 自动缩放控制器会定期调整其目标（例如，部署）的所需规模，以匹配观察到的指标，例如平均 CPU 利用率、平均内存利用率或您指定的任何其他自定义指标。

简单来说就是水平 Pod 自动扩缩容，当监控某个值达到了阀值时，就自动增加或减少pod的数量，当然pod的数量也是会设置的，前提会依赖于metrics-server资源
```

## hpa案例

### 	(1)创建资源清单

```
cat 01_hpa_stress.yml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hpa-stress
spec:
  replicas: 1
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  template:
    metadata:
      labels:
        apps: stress
    spec:
      containers:
      - name: web
        image: jasonyin2020/oldboyedu-linux-tools:v0.1
        command:
        - tail
        - -f
        - /etc/hosts
        resources:
          requests:
             cpu: 500m
             memory: 200M
          limits:
             cpu: 1
             memory: 500M
```

### 	(2)创建hpa规则，最小要运行2个Pod，最多运行5个Pod

#### 响应式

```
kubectl autoscale deployment hpa-stress --min=2 --max=5 --cpu-percent=80

kubectl get hpa
NAME         REFERENCE               TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
hpa-stress   Deployment/hpa-stress   <unknown>/80%   2         5         0          11s
注意： 如果一直是unknown状态的话，那么就需要检查metrics了
[root@centos7k8s1 hpa]# kubectl get hpa
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
hpa-stress   Deployment/hpa-stress   0%/80%    2         5         2          18s
```

#### 声明式创建规则

```
cat 02_hpa.yml 
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-stress
spec:
  maxReplicas: 5
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: 80
        type: Utilization
    type: Resource
  minReplicas: 2
  scaleTargetRef: # 当前的hpa规则应用在哪个资源
    apiVersion: apps/v1
    kind: Deployment
    name: hpa-stress
```

### 	(3)压力测试

```
kubectl exec -it hpa-stress-6d58b8cb88-bhf67 -- stress -c 4 --verbose --timeout 3m
stress: info: [17] dispatching hogs: 4 cpu, 0 io, 0 vm, 0 hdd
stress: dbug: [17] using backoff sleep of 12000us
stress: dbug: [17] setting timeout to 180s
stress: dbug: [17] --> hogcpu worker 4 [23] forked
stress: dbug: [17] using backoff sleep of 9000us
stress: dbug: [17] setting timeout to 180s
stress: dbug: [17] --> hogcpu worker 3 [24] forked
stress: dbug: [17] using backoff sleep of 6000us
stress: dbug: [17] setting timeout to 180s
stress: dbug: [17] --> hogcpu worker 2 [25] forked
stress: dbug: [17] using backoff sleep of 3000us
stress: dbug: [17] setting timeout to 180s
stress: dbug: [17] --> hogcpu worker 1 [26] forked
stress: dbug: [17] <-- worker 23 signalled normally
stress: dbug: [17] <-- worker 25 signalled normally
stress: dbug: [17] <-- worker 24 signalled normally
stress: dbug: [17] <-- worker 26 signalled normally
stress: info: [17] successful run completed in 180s

kubectl exec -it hpa-stress-6d58b8cb88-d4x9d -- stress -c 4 --verbose --timeout 3m
stress: info: [27] dispatching hogs: 4 cpu, 0 io, 0 vm, 0 hdd
stress: dbug: [27] using backoff sleep of 12000us
stress: dbug: [27] setting timeout to 180s
stress: dbug: [27] --> hogcpu worker 4 [33] forked
stress: dbug: [27] using backoff sleep of 9000us
stress: dbug: [27] setting timeout to 180s
stress: dbug: [27] --> hogcpu worker 3 [34] forked
stress: dbug: [27] using backoff sleep of 6000us
stress: dbug: [27] setting timeout to 180s
stress: dbug: [27] --> hogcpu worker 2 [35] forked
stress: dbug: [27] using backoff sleep of 3000us
stress: dbug: [27] setting timeout to 180s
stress: dbug: [27] --> hogcpu worker 1 [36] forked
stress: dbug: [27] <-- worker 33 signalled normally
stress: dbug: [27] <-- worker 34 signalled normally
stress: dbug: [27] <-- worker 35 signalled normally
stress: dbug: [27] <-- worker 36 signalled normally
stress: info: [27] successful run completed in 180s

kubectl exec -it hpa-stress-6d58b8cb88-rdbr6 -- stress -c 4 --verbose --timeout 3m
stress: info: [6] dispatching hogs: 4 cpu, 0 io, 0 vm, 0 hdd
stress: dbug: [6] using backoff sleep of 12000us
stress: dbug: [6] setting timeout to 180s
stress: dbug: [6] --> hogcpu worker 4 [12] forked
stress: dbug: [6] using backoff sleep of 9000us
stress: dbug: [6] setting timeout to 180s
stress: dbug: [6] --> hogcpu worker 3 [13] forked
stress: dbug: [6] using backoff sleep of 6000us
stress: dbug: [6] setting timeout to 180s
stress: dbug: [6] --> hogcpu worker 2 [14] forked
stress: dbug: [6] using backoff sleep of 3000us
stress: dbug: [6] setting timeout to 180s
stress: dbug: [6] --> hogcpu worker 1 [15] forked
stress: dbug: [6] <-- worker 14 signalled normally
stress: dbug: [6] <-- worker 12 signalled normally
stress: dbug: [6] <-- worker 13 signalled normally
stress: dbug: [6] <-- worker 15 signalled normally
stress: info: [6] successful run completed in 180s
```

### 	(4)观察Pod的副本数量

```
压测开始
Every 5.0s: kubectl get hpa          Sat Sep 21 15:49:51 2024
NAME         REFERENCE               TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
hpa-stress   Deployment/hpa-stress   100%/80%   2         5         2          7m47s

Every 5.0s: kubectl get hpa    Sat Sep 21 15:52:29 2024

NAME         REFERENCE               TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
hpa-stress   Deployment/hpa-stress   114%/80%   2         5         5          10m

Every 5.0s: kubectl get pod   Sat Sep 21 15:52:16 2024

NAME                          READY   STATUS    RESTARTS   AGE
hpa-stress-6d58b8cb88-bhf67   1/1     Running   0          39m
hpa-stress-6d58b8cb88-d4x9d   1/1     Running   0          37m
hpa-stress-6d58b8cb88-rdbr6   1/1     Running   0          2m26s
hpa-stress-6d58b8cb88-szptq   1/1     Running   0          40s
hpa-stress-6d58b8cb88-vz9mj   1/1     Running   0          56s


压测结束
Every 5.0s: kubectl get hpa    Sat Sep 21 16:00:29 2024

NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
hpa-stress   Deployment/hpa-stress   0%/80%    2         5         2          18m

Every 5.0s: kubectl get pod   Sat Sep 21 16:01:37 2024

NAME                          READY   STATUS    RESTARTS   AGE
hpa-stress-6d58b8cb88-bhf67   1/1     Running   0          49m
hpa-stress-6d58b8cb88-d4x9d   1/1     Running   0          46m
```

