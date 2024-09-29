# 节点调度

```
昨日内容回顾:
	- rs的升级和回滚
	- deployment:
		- 升级策略（strategy）
			-type:
				- Recreate
				- RollingUpdate
			- rollingUpdate
				- maxSurge
				- maxUnavailable
				
		- 升级方式:
			- 声明式升级:
				kubectl apply -f ...
			- 响应式升级:
				kubectl set image
				kubectl edit deployment ...
				
		- 发布策略:
			- 蓝绿发布:
			- 灰度发布:
			
		- 应用案例:
			- wordpress
			- redis			
	- services:
		- NodePort
		- ClusterIP		
	- coreDNS:
		将svc解析为clusterIP。		
	- Job
		一次性任务	
	- CronJob
		周期性任务，底层调用的Job控制器。		
故障案例1:
	- wordPress连接MySQL一直出现连接数据库失败。
		- 检查K8S集群是否健康
			kubectl get cs,no
			kubectl get pods -A | grep flannel
			kubectl get pods -A | grep kube-proxy
			kubectl get pods -A | grep -i coredns
		- 检查db对应svc是否关联pod
			kubectl describe svc ...
		- 检查pod是否正常工作
			kubectl exec -it ...
		- 检查存储卷
			删除MySQL数据目录对应nfs。删除后重新创建即可。
			如果还不行，建议更换MySQL 5.7			
故障案例2:
	k8s232节点可以正常运行Pod，k8s233无法正常运行pod，报错是挂载失败。
		- 手动挂载:
			mount -t nfs 10.0.0.231:/myharbor/data/kubernetes /mnt
		
		- 安装nfs依赖:
			yum -y install nfs-utils
故障案例3:
	svc关联pod失败。
		- svc的标签选择器有6个。
		- Pod仅包含了1个。
		综上所述: Pod的标签数必须包含svc所关联的标签，只能多不能少。
```

# Q1: 影响pod调度的因素有哪些?

- nodeName
  - resources
  - hostNetwork
  ...
  - 污点
  - 污点容忍
  - Pod亲和性
  - Pod反亲和性
  - 节点亲和性

# 污点概述

```
污点通常情况下是作用在worker节点上，其可以影响Pod的调度。

污点的语法格式如下:
key[=value]:effect
		
相关字段说明:
key:字母或数字开头，可以包含字母、数字、连字符(-)、点(.)和下划线(_)，最多253个字符。也可以以DNS子域前缀和单个"/"开头
value:该值是可选的。如果给定，它必须以字母或数字开头，可以包含字母、数字、连字符、点和下划线，最多63个字符。
effect:[ɪˈfekt]
	effect必须是NoSchedule、PreferNoSchedule或NoExecute。
	NoSchedule: [noʊ,ˈskedʒuːl] 该节点不再接收新的Pod调度，但不会驱赶已经调度到该节点的Pod。
	PreferNoSchedule: [prɪˈfɜːr,noʊ,ˈskedʒuː] 该节点可以接受调度，但会尽可能将Pod调度到其他节点，换句话说，让该节点的调度优先级降低啦。
	NoExecute:[ˈnoʊ,eksɪkjuːt] 该节点不再接收新的Pod调度，与此同时，会立刻驱逐已经调度到该节点的Pod。
```

## NoExecute 污点实战

```
(1)创建资源清单
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-taint-demo-1
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: app
      values:
      - wahaha1
      operator: In
  template:
    metadata:
      labels:
        app: wahaha1
    spec:
      containers:
      - name: nginx-deploy-demo-1  
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v3.0-my
        imagePullPolicy: IfNotPresent
 
(2)查看Pod调度节点
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s2
centos7k8s3
centos7k8s2
centos7k8s3
centos7k8s2
 
(3)打污点
kubectl taint node centos7k8s2 mytaint1=waxixi:NoExecute
node/centos7k8s2 tainted

(4)查看污点
kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint1=waxixi:NoExecute
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s2
--
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3
  
(5)打污点后
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s3
centos7k8s3
centos7k8s3
centos7k8s3
centos7k8s3
 
(6)清除污点
kubectl taint node centos7k8s2 mytaint1-
node/centos7k8s2 untainted
 
(7)再次修改Pod副本数量
kubectl edit deployments.apps nginx-taint-demo-1 -n haha
deployment.apps/nginx-taint-demo-1 edited

kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s2
centos7k8s3
centos7k8s2
centos7k8s3
centos7k8s3
centos7k8s2
centos7k8s3
centos7k8s2
centos7k8s3
```

## PreferNoSchedule污点实战案例

```
(1)添加PreferNoSchedule污点
kubectl taint node centos7k8s2 mytaint=yoxixi:PreferNoSchedule
node/centos7k8s2 tainted
[root@centos7k8s1 taint]# kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint=yoxixi:PreferNoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s2
--
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3
(2)创建资源清单并应用
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-taint-prefernoschedule-demo-1
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: app
      values:
      - wahaha1
      operator: In
  template:
    metadata:
      labels:
        app: wahaha1
    spec:
      containers:
      - name: nginx-taint-prefernoschedule-demo
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v2.0-my
        #image: harbor.myharbor.com/myharbor/nginx:v3.0-my
 
kubectl apply -f 02_nginx_deploy_taint_prefernoschedule_demo.yml 
deployment.apps/nginx-taint-prefernoschedule-demo-1 created
(3)查看调度节点
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s3
centos7k8s3
centos7k8s3
centos7k8s3
centos7k8s3
(4)添加NoExecute污点
kubectl taint node centos7k8s3 mytaint2=wuhaha:NoExecute
node/centos7k8s3 tainted
(5)再次查看Pod调度节点
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s2
centos7k8s2
centos7k8s2
centos7k8s2
centos7k8s2
```

## NoSchedule污点实战案例

```
(1)查看现有污点状态
kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint=yoxixi:PreferNoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s2
--
Taints:             mytaint2=wuhaha:NoExecute
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3

(2)添加污点
kubectl taint node centos7k8s2 mytaint=yoxixi:NoSchedule
node/centos7k8s2 tainted

(3)再次查看节点的污点状态
kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint=yoxixi:NoSchedule
                    mytaint=yoxixi:PreferNoSchedule
Unschedulable:      false
Lease:
--
Taints:             mytaint2=wuhaha:NoExecute
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3

(4)查看现有的Pod调度
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s2
centos7k8s2
centos7k8s2
centos7k8s2
centos7k8s2	
	
(5)调大副本数量，观察是否能完成调度，比如增加4个Pod副本，会出现如下的Pending状态哟！
kubectl edit deployments.apps nginx-taint-prefernoschedule-demo-1 -n haha
deployment.apps/nginx-taint-prefernoschedule-demo-1 edited

kubectl get pods -n haha -o wide | awk '{print $1, $3, $7}'
NAME STATUS NODE
nginx-taint-prefernoschedule-demo-1-5dbc469d84-77n2r Pending <none>
nginx-taint-prefernoschedule-demo-1-5dbc469d84-b2l2w Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-cr4cp Pending <none>
nginx-taint-prefernoschedule-demo-1-5dbc469d84-hmmjh Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-mnrb9 Pending <none>
nginx-taint-prefernoschedule-demo-1-5dbc469d84-pnzhv Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-tnpcs Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-twhvp Running centos7k8s2
nginx-taint-prefernoschedule-demo-1-5dbc469d84-xn2cv Pending <none>
```

## 配置污点容忍实战案例

```
(1)修改污点
kubectl taint node centos7k8s2 mytaint=yohaha:PreferNoSchedule --overwrite
node/centos7k8s2 modified

(2)查看污点
kubectl describe nodes | grep Taint -A 3
Taints:             node-role.kubernetes.io/master:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s1
--
Taints:             mytaint=yoxixi:NoSchedule
                    mytaint=yohaha:PreferNoSchedule
Unschedulable:      false
Lease:
--
Taints:             mytaint2=wuhaha:NoExecute
Unschedulable:      false
Lease:
  HolderIdentity:  centos7k8s3
  
(3)编写资源清单
# kubectl explain po.spec.tolerations
配置Pod的污点容忍
tolerations:
- key: 指定污点的key 若不指定key，则operator的值必须为Exists，表示匹配所有的key
  value: 指定污点的key的value
  effect: 指定污点的effect，有效值为: NoSchedule, PreferNoSchedule,NoExecute 若不指定则匹配所有的影响度。
  operator: 表示key和value的关系，有效值为Exists， Equal。
     Exists:
       表示存在指定的key即可，若配置，则要求value字段为空。
     Equal:
       默认值，表示key=value。       

如果不指定key，value，effect，仅配置"operator: Exists"表示无视任何污点!
 - operator: Exists

# 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-taint-prefernoschedule-demo-1
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
  selector:
    matchExpressions:
    - key: app
      values:
      - wahaha1
      operator: In
  template:
    metadata:
      labels:
        app: wahaha1
    spec:
      tolerations:
      - key: mytaint2
        value: wuhaha
        effect: NoExecute
        operator: Equal
      - key: node-role.kubernetes.io/master
        operator: Exists
      containers:
      - name: nginx-taint-prefernoschedule-demo
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
 
(4)查看现有的Pod调度
kubectl get pods -n haha -o wide | awk '{print $7}'
NODE
centos7k8s3
centos7k8s3
centos7k8s1
centos7k8s1
centos7k8s3
```

# 节点选择器nodeselector

```
(1)给节点打标签
kubectl label nodes centos7k8s1 ynode=gotit
node/centos7k8s1 labeled

kubectl get nodes --show-labels
NAME          STATUS   ROLES                  AGE   VERSION    LABELS
centos7k8s1   Ready    control-plane,master   14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=,ynode=gotit
centos7k8s2   Ready    <none>                 14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s2,kubernetes.io/os=linux,mynode=iwant
centos7k8s3   Ready    <none>                 14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s3,kubernetes.io/os=linux,mynode=iwant


(2)编写资源清单
kubectl explain po.spec.nodeSelector
KIND:     Pod
VERSION:  v1

FIELD:    nodeSelector <map[string]string>

nodeSelector:
  label_name: value #匹配节点的标签名和值，如有多个则须都写。需调用的节点标签值要一致，否则会报错或一直在pending状态

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-node-selector
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
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
      tolerations:
      - operator: Exists
      nodeSelector:
        mynode: iwant
        #ynode: gotit
      containers:
      - name: nginx-deploy-node-selector-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent

kubectl get pod -n haha -o wide | awk '{print $7}'
NODE
centos7k8s3
centos7k8s2
centos7k8s2
centos7k8s3
centos7k8s3

(3)删除标签
[root@centos7k8s1 node_selector]# kubectl label nodes --all mynode-
label "mynode" not found.
node/centos7k8s1 not labeled
node/centos7k8s2 unlabeled
node/centos7k8s3 unlabeled
[root@centos7k8s1 node_selector]# kubectl label nodes --all ynode-
node/centos7k8s1 unlabeled
label "ynode" not found.
node/centos7k8s2 not labeled
label "ynode" not found.
node/centos7k8s3 not labeled
```

# 节点亲和性nodeAffinity

```
(1)打标签
[root@centos7k8s1 node_affinity]# kubectl label nodes centos7k8s1 mynode=iwant
node/centos7k8s1 labeled
[root@centos7k8s1 node_affinity]# kubectl label nodes centos7k8s3 mynode=ywant
node/centos7k8s3 labeled

kubectl get nodes --show-labels
NAME          STATUS   ROLES                  AGE   VERSION    LABELS
centos7k8s1   Ready    control-plane,master   14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s1,kubernetes.io/os=linux,mynode=iwant,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
centos7k8s2   Ready    <none>                 14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s2,kubernetes.io/os=linux
centos7k8s3   Ready    <none>                 14d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s3,kubernetes.io/os=linux,mynode=ywant

(2)编写资源清单
affinity:  #定义亲和性
  nodeAffinity: #定义节点的亲和性    
    requiredDuringSchedulingIgnoredDuringExecution: #定义硬限制      
      nodeSelectorTerms: #定义节点的匹配条件        
      - matchExpressions: #基于节点的标签进行匹配          
        - key: 指定标签的key          
          values: 指定标签的value
          - value1
          - value2
          ...
          operator: In # 指定key和value之间的对应关系，有效值如下:
            In:
              key的值必须在vlaues内。要求values不能为空。
            NotIn:
              和In相反。要求values不能为空。
            Exists:
              只要存在指定key即可，vlaues的值必须为空。
            DoesNotExist:
              只要不存在指定key即可，vlaues的值必须为空。
            Gt:
              表示大于的意思，values的值会被解释为整数。
            Lt:
              表示小于的意思，values的值会被解释为整数。
          
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-node-affinity
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 5
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
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: mynode
                values: 
                - iwant
                - ywant
                operator: In
              #- key: ynode
              #  values: 
              #  - gotit
              #  operator: In
      containers:
      - name: nginx-deploy-node-affinity-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-deploy-node-affinity-svc
  namespace: haha
spec:
  selector:
    app: haha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31800
  clusterIP: 10.200.111.111


(3)删除标签
[root@k8s231.myharbor.com nodeAffinity]# kubectl label nodes --all mynode- 
```

# Pod的亲和性

```
(1)node打标签
[root@centos7k8s1 node_selector]# kubectl label nodes centos7k8s1 dc=dawa
node/centos7k8s1 labeled
[root@centos7k8s1 node_selector]# kubectl label nodes centos7k8s2 dc=erwa
node/centos7k8s2 labeled
[root@centos7k8s1 node_selector]# kubectl label nodes centos7k8s3 dc=sanwa
node/centos7k8s3 labele

kubectl get nodes --show-labels | grep dc
centos7k8s1   Ready    control-plane,master   15d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=dawa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
centos7k8s2   Ready    <none>                 15d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=erwa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s2,kubernetes.io/os=linux
centos7k8s3   Ready    <none>                 15d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=sanwa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s3,kubernetes.io/os=linux

(2)编写资源清单
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-pod-affinity
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 9
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
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      affinity: #定义亲和性
        podAffinity: #定义Pod的亲和性
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: dc #指定拓扑域的key 就是nodes中的label
            #- topologyKey: kubernetes.io/os
              labelSelector: #定义标签选择器，这里是指pod的标签
                matchExpressions: 
                - key: app
                  values: 
                  - haha1
                  operator: In
                #- key: ynode
                #  values: 
                #  - gotit
                #  operator: In
      containers:
      - name: nginx-deploy-node-affinity-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
```

# Pod的反亲和性

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy-pod-affinity
  labels:
    item: wahaha
  namespace: haha
spec:
  replicas: 9
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
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      affinity: #定义亲和性
        podAntiAffinity: #定义Pod的反亲和性
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: dc #指定拓扑域的key 就是nodes中的label
            #- topologyKey: kubernetes.io/os
              labelSelector: #定义标签选择器，这里是指pod的标签
                matchExpressions:
                - key: app
                  values: 
                  - haha1
                  operator: In
                #- key: ynode
                #  values: 
                #  - gotit
                #  operator: In
      containers:
      - name: nginx-deploy-node-affinity-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresen
        
        
        

   
```

# 面试题

```
Q1: 请陈述Pod的亲和性和反亲和性的作用和区别?
亲和性： 当pod调度到某一个拓扑域时，其它的pod会调度到与之相同的拓扑域
反亲和性：当pod调度到某一个拓扑域时，其它的pod不会调度到与之相同的拓扑域，并且只调度一个pod到一个node节点

Q2: 节点和亲和性和节点选择器的区别?

kubectl get nodes --show-labels
NAME          STATUS   ROLES                  AGE   VERSION    LABELS
centos7k8s1   Ready    control-plane,master   16d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=dawa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s1,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
centos7k8s2   Ready    <none>                 16d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=erwa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s2,kubernetes.io/os=linux,mynode=iwant
centos7k8s3   Ready    <none>                 16d   v1.23.17   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,dc=sanwa,kubernetes.io/arch=amd64,kubernetes.io/hostname=centos7k8s3,kubernetes.io/os=linux,mynode=iwant

节点选择器只能通过单一key:value节点标签来选择调度到匹配的节点

如果每个节点自定义标签有指定的key:value标签，那么pod调度到有这些标签的节点
      nodeSelector:
        mynode: iwant

kubectl get pods -n haha -o wide
NAME                                          READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
nginx-deploy-node-selector-6c9bf75db4-6k9b4   1/1     Running   0          6s    10.100.2.108   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-6c9bf75db4-fp6mp   1/1     Running   0          6s    10.100.1.37    centos7k8s2   <none>           <none>
nginx-deploy-node-selector-6c9bf75db4-jhcrh   1/1     Running   0          5s    10.100.1.38    centos7k8s2   <none>           <none>
nginx-deploy-node-selector-6c9bf75db4-mhfpc   1/1     Running   0          6s    10.100.2.107   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-6c9bf75db4-wjrrr   1/1     Running   0          5s    10.100.2.109   centos7k8s3   <none>           <none>

如果指定标签的key相同而value不同，则会选择key相同的最后一个value来调度
      nodeSelector:
        dc: erwa
        dc: sanwa
        mynode: iwant

kubectl get pods -n haha -o wide
NAME                                          READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
nginx-deploy-node-selector-7555c9969c-6spr2   1/1     Running   0          8s    10.100.2.114   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-dhxwv   1/1     Running   0          10s   10.100.2.111   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-h2587   1/1     Running   0          8s    10.100.2.113   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-qpjb5   1/1     Running   0          10s   10.100.2.110   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-ww7nq   1/1     Running   0          10s   10.100.2.112   centos7k8s3   <none>           <none>

如果节点的上自定义标签没有指定的key:value标签还需要手动添加，否则就会pending，原因就是在该节点找不到指定的标签
      nodeSelector:
        dc: erwa
        dc: sanwa
        dc: dawa
        mynode: iwant
kubectl get pods -n haha -o wide
NAME                                          READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
nginx-deploy-node-selector-7555c9969c-dhxwv   1/1     Running   0          2m32s   10.100.2.111   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-h2587   1/1     Running   0          2m30s   10.100.2.113   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-qpjb5   1/1     Running   0          2m32s   10.100.2.110   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-7555c9969c-ww7nq   1/1     Running   0          2m32s   10.100.2.112   centos7k8s3   <none>           <none>
nginx-deploy-node-selector-775bb5fcd6-ppz2q   0/1     Pending   0          22s     <none>         <none>        <none>           <none>
nginx-deploy-node-selector-775bb5fcd6-sprfq   0/1     Pending   0          22s     <none>         <none>        <none>           <none>
nginx-deploy-node-selector-775bb5fcd6-wwb77   0/1     Pending   0          22s     <none>         <none>        <none>           <none>

节点亲和性可以匹配实现key相同,value不相同的节点调度，功能更强大
affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: dc
                values: 
                - dawa
                - erwa
                - sanwa
                operator: In
kubectl get pods -n haha -o wide
NAME                                          READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
nginx-deploy-node-affinity-646b99686c-77mlm   1/1     Running   0          16s   10.100.2.119   centos7k8s3   <none>           <none>
nginx-deploy-node-affinity-646b99686c-mz9xv   1/1     Running   0          16s   10.100.0.24    centos7k8s1   <none>           <none>
nginx-deploy-node-affinity-646b99686c-np84b   1/1     Running   0          16s   10.100.1.40    centos7k8s2   <none>           <none>
nginx-deploy-node-affinity-646b99686c-ptqv4   1/1     Running   0          16s   10.100.1.39    centos7k8s2   <none>           <none>
nginx-deploy-node-affinity-646b99686c-qwf5w   1/1     Running   0          16s   10.100.2.120   centos7k8s3   <none>           <none>

Q3: 影响Pod调度的因素有哪些?
nodeName
taint
tolerations
nodeSelector
nodeAffinity
podAffinity
podAntiAffinity
```

# DaemonSet概述

```
DaemonSet确保全部worker节点上运行一个Pod的副本。

DaemonSet的一些典型用法：
(1)在每个节点上运行集群守护进程(flannel等)
(2)在每个节点上运行日志收集守护进程(flume，filebeat，fluentd等)
(3)在每个节点上运行监控守护进程（zabbix agent，node_exportor等）

温馨提示:
(1)当有新节点加入集群时，也会为新节点新增一个Pod;
(2)当有节点从集群移除时，这些Pod也会被回收;
(3)删除DaemonSet将会删除它创建的所有Pod;
(4)如果节点被打了污点的话，且DaemonSet中未定义污点容忍，则Pod并不会被调度到该节点上;("flannel案例")
		
编写资源清单：
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-deploy-node-daemonset
  labels:
    item: wahaha
  namespace: haha
spec:
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
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      containers:
      - name: nginx-deploy-node-affinity-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-deploy-node-affinity-svc
  namespace: haha
spec:
  selector:
    app: haha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31800
  clusterIP: 10.200.111.111
```

## 结合node亲合性案例

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-node-daemonset
  labels:
    item: wahaha
  namespace: haha
spec:
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
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: dc
                values: 
              #  - dawa
                - erwa
                - sanwa
                operator: In
              #- key: ynode
              #  values: 
              #  - gotit
              #  operator: In
      containers:
      - name: nginx-node-daemonset-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-node-daemonset-svc
  namespace: haha
spec:
  selector:
    app: haha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31800
  clusterIP: 10.200.111.111
```

## 结合node选择器案例

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-node-daemonset
  labels:
    item: wahaha
  namespace: haha
spec:
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
      tolerations:
        #key: node-role.kubernetes.io/master
        #effect: NoSchedule
      - operator: Exists
      nodeSelector:
        mynode: iwant
      containers:
      - name: nginx-node-daemonset-1
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-node-daemonset-svc
  namespace: haha
spec:
  selector:
    app: haha1
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31800
  clusterIP: 10.200.111.111
```

# K8S节点扩缩容

## Pod驱逐及K8S节点下线

```
驱逐简介:
	kubelet监控当前node节点的CPU，内存，磁盘空间和文件系统的inode等资源。
	当这些资源中的一个或者多个达到特定的消耗水平，kubelet就会主动地将节点上一个或者多个Pod强制驱逐。
	以防止当前node节点资源无法正常分配而引发的OOM。
参考链接:
	https://kubernetes.io/zh-cn/docs/concepts/scheduling-eviction/node-pressure-eviction/
   
- 手动驱逐Pod，模拟下线节点
- 应用场景:
	node因为硬件故障或者其他原因要下线。
	
- 参考步骤:
	(1)编写资源清单并创建
	(2)驱逐Pod并打SchedulingDisable标签，但不会驱逐ds资源调度的pod。
	(3)配置污点，将ds资源进行立即驱逐Pod。
	(4)登录要下线的节点并重置kubeadm集群环境
	(5)删除要下线的节点。
	(6)关机并重新安装操作系统

关键点：
1.使用 drain方式驱逐的本质就是给某个节点打上SchedulingDisable的污点，但如果做了污点容忍，特别是不指定key - operator: Exists这种全容忍，此时这种驱逐方式的意义就没有了




在某个文件下有定义驱逐的条件
```

## K8S节点上线

```
kubeadm快速将节点加入集群:
1.安装必要组件
1.1 配置软件源
cat  > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
	
1.2 安装kubeadm，kubelet，kubectl软件包
yum -y install kubeadm-1.23.17-0 kubelet-1.23.17-0 kubectl-1.23.17-0 

1.3 启动kubelet服务(若服务启动失败时正常现象，其会自动重启，因为缺失配置文件，初始化集群后恢复！此步骤可跳过！)
systemctl enable --now kubelet
systemctl status kubelet

2.在master组件创建token
2.1 创建一个永不过期的token，并打印加入集群的命令
 token create --print-join-command --ttl 0
kubeadm join 192.168.76.142:6443 --token fshyfs.m3pa94qhkg9ox0kg --discovery-token-ca-cert-hash sha256:041f82856e5e00e514558e97b258b29a9bc4a66bdf1f3e3074badbd3aaa19858

注：token create --print-join-command --ttl 0 [可以创建自定义的token 格式 6字符:16字符 小写]
2.2 查看现有的token
[root@centos7k8s1 ~]# kubeadm token list
TOKEN                     TTL         EXPIRES                USAGES                   DESCRIPTION                                                EXTRA GROUPS
crg7k2.jtgfq8gdvu4iiapv   21h         2024-09-02T23:31:45Z   authentication,signing   <none>                                                     system:bootstrappers:kubeadm:default-node-token
fshyfs.m3pa94qhkg9ox0kg   <forever>   <never>   authentication,signing   <none>                                                     system:bootstrappers:kubeadm:default-node-token

2.3 删除token（先跳过此步骤，先别删除，加入集群后再来操作哟！）
kubeadm token delete fshyfs
bootstrap token "fshyfs" deleted	
		
3.worker节点加入集群
kubeadm join 192.168.76.142:6443 --token fshyfs.m3pa94qhkg9ox0kg --discovery-token-ca-cert-hash sha256:041f82856e5e00e514558e97b258b29a9bc4a66bdf1f3e3074badbd3aaa19858

4.查看节点
kubectl get nodes
NAME          STATUS   ROLES                  AGE    VERSION
centos7k8s1   Ready    control-plane,master   21d    v1.23.17
centos7k8s2   Ready    <none>                 21d    v1.23.17
centos7k8s3   Ready    <none>                 3h1m   v1.23.17

5.查看bootstrap阶段的token信息
[root@k8s231.oldboyedu.com ~]# kubectl get secrets -A | grep crg7k2
kube-system       bootstrap-token-crg7k2 
```

## kubeadm 节点上线原理

```
api server 组件通信基于https协议，所以肯定会用到证书
当worker节点要加入一个集群，就需要认证，而一个新的节点是没有相关证书的
kubeadm 就可以基于api server证书创建为一个token，此时该token就会保存在k8s的secrets中，相当于就得到了k8s的授权
当使用kubeadm join时，新的节点就会携带该token加入到集群，由于携带的token是已经被K8S授权，这样就加入成功了
加入成功后 api server 就会给worker节点颁发一个证书，之后节点与master通信就可以不再需要token了，这就是为什么节点成功加入集群后可以删除token

相关面试：worker节点的启动阶段都做了些什么？kubeadm join命令都做了些什么事儿
```

