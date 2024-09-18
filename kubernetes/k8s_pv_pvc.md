# k8s_pv_pvc

## 手动创建PV

### 1.准备nfs路径

```
mkdir -pv data/k8s/pv/pv00{1..3}
```

### 2.编写PV资源清单

```
声明PV的访问模式 accessModes
声明PV的访问模式，常用的有"ReadWriteOnce","ReadOnlyMany"和"ReadWriteMany":
  ReadWriteOnce:(简称:"RWO")
     只允许单个worker节点读写存储卷，但是该节点的多个Pod是可以同时访问该存储卷的。
  ReadOnlyMany:(简称:"ROX")
     允许多个worker节点进行只读存储卷。
  ReadWriteMany:(简称:"RWX")
     允许多个worker节点进行读写存储卷。
  ReadWriteOncePod:(简称:"RWOP")
      该卷可以通过单个Pod以读写方式装入。
      如果您想确保整个集群中只有一个pod可以读取或写入PVC，请使用ReadWriteOncePod访问模式。
      这仅适用于CSI卷和Kubernetes版本1.22+。
      
声明存储卷的类型为nfs
   nfs:
     path: 
     server: 
指定存储卷的回收策略 persistentVolumeReclaimPolicy，常用的有"Retain"和"Delete"
   Retain:
      "保留回收"策略允许手动回收资源。
      删除PersistentVolumeClaim时，PersistentVolume仍然存在，并且该卷被视为"已释放"。
      在管理员手动回收资源之前，使用该策略其他Pod将无法直接使用。
   Delete:
      对于支持删除回收策略的卷插件，k8s将删除pv及其对应的数据卷数据。
   Recycle:
      对于"回收利用"策略官方已弃用。相反，推荐的方法是使用动态资源调配。
      如果基础卷插件支持，回收回收策略将对卷执行基本清理（rm -rf /thevolume/*），并使其再次可用于新的声明。
   
cat 01_pv_nfs.yml 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv001-nfs
spec:
  accessModes:
  - ReadWriteMany
  nfs:
    server: 192.168.76.142
    path: /opt/data/k8s/pv/pv001
  capacity:
    storage: 2G
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv002-nfs
spec:
  accessModes:   
  - ReadWriteMany
  nfs:
    server: 192.168.76.142
    path: /opt/data/k8s/pv/pv002
  capacity:
    storage: 5G
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv003-nfs
spec:
  accessModes:   
  - ReadWriteMany
  nfs:
    server: 192.168.76.142
    path: /opt/data/k8s/pv/pv003
  capacity:
    storage: 8G
  persistentVolumeReclaimPolicy: Retain
```

### 3.创建pv

```
kubectl apply -f 01_pv_nfs.yml
```

### 4.查看pv资源

```
kubectl get pv
NAME : 
	pv的名称
CAPACITY : 
	pv的容量
ACCESS MODES: 
	pv的访问模式
RECLAIM POLICY:
	pv的回收策略。
STATUS :
	pv的状态。
CLAIM:
	pv被哪个pvc使用。
STORAGECLASS  
	sc的名称。
REASON   
	pv出错时的原因。
AGE
	创建的时间。
参考链接:
	https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes
	https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming
```

## 创建pvc

### 1. 编写pvc资源清单

```
cat 02_pvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-pvc-demo
spec:
  # 声明资源的访问模式
  accessModes:
  - ReadWriteMany
  # 声明资源的使用量
  resources:
    limits:
       storage: 4Gi
    requests:
       storage: 3Gi
```

### 2.应用pvc

```
cat 03_pvc_nginx.yml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pvc-nginx-demo
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  template:
    metadata:
      labels:
        apps: pvcnginx
    spec:
      volumes:
      - name: data
        persistentVolumeClaim: # 声明是一个PVC类型
          claimName: pv-pvc-demo # 引用哪个PVC
      containers:
      - name: pvc-nginx-web
        image: harbor.myharbor.com/myharbor/nginx:1.24-alpine
        imagePullPolicy: IfNotPresent
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  name: pvc-nginx-svc
spec:
  selector: 
    apps: pvc-nginx
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30088
```

## 删除pvc验证pv的回收策略

### 1.pv的回收策略

```
Retain:
	   "保留回收"策略允许手动回收资源,删除pvc时，pv仍然存在，并且该卷被视为"已释放(Released)"。
	   在管理员手动回收资源之前，使用该策略其他Pod将无法直接使用。
	   温馨提示:
		   (1)在k8s1.15.12版本测试时，删除pvc发现nfs存储卷的数据并不会被删除，pv也不会被删除;
		   
	Delete:
	   对于支持删除回收策略的卷插件，k8s将删除pv及其对应的数据卷数据。建议使用动态存储类(sc)实现，才能看到效果哟！
	   对于AWS EBS, GCE PD, Azure Disk, or OpenStack Cinder等存储卷会被删除。
	   温馨提示:
		   (1)在k8s1.15.12版本测试时，在不使用sc时，则删除pvc发现nfs存储卷的数据并不会被删除；
		   (2)在k8s1.15.12版本测试时，在使用sc后，可以看到删除效果哟;

	Recycle:
	   对于"回收利用"策略官方已弃用。相反，推荐的方法是使用动态资源调配。而动态存储类已经不支持该类型啦！
	   如果基础卷插件支持，回收回收策略将对卷执行基本清理（rm -rf /thevolume/*），并使其再次可用于新的声明。
	   温馨提示，在k8s1.15.12版本测试时，删除pvc发现nfs存储卷的数据被删除。
```

## PV的回收策略案例

### (1)给pv打补丁

```
kubectl patch pv pv001-nfs -p '{"spec":{"persistentVolumeReclaimPolicy":"Recycle"}}'
persistentvolume/pv001-nfs patched
```

### (2)查看是否打补丁成功

```
kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv001-nfs   2G         RWX            Recycle          Available                                   80m
pv002-nfs   5G         RWX            Retain           Available                                   12m
pv003-nfs   8G         RWX            Retain           Available                                   80m
```

### (3)测试验证

```
#pvc资源
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-pvc-demo
spec:
  # 声明资源的访问模式
  accessModes:
  - ReadWriteMany
  # 声明资源的使用量
  resources:
    limits:
       storage: 2Gi
    requests:
       storage: 1Gi

#deployment资源
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pvc-nginx-demo
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  template:
    metadata:
      labels:
        apps: pvcnginx
    spec:
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: pv-pvc-demo
      containers:
      - name: pvc-nginx-web
        image: harbor.myharbor.com/myharbor/nginx:v1.0-my
        imagePullPolicy: IfNotPresent
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  name: pvc-nginx-svc
spec:
  selector: 
    apps: pvcnginx
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30088
    
#验证绑定
kubectl get pv,pvc,po -o wide
NAME                         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                 STORAGECLASS   REASON   AGE   VOLUMEMODE
persistentvolume/pv001-nfs   2G         RWX            Recycle          Bound       default/pv-pvc-demo                           84m   Filesystem
persistentvolume/pv002-nfs   5G         RWX            Retain           Available                                                 16m   Filesystem
persistentvolume/pv003-nfs   8G         RWX            Retain           Available                                                 84m   Filesystem

NAME                                STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
persistentvolumeclaim/pv-pvc-demo   Bound    pv001-nfs   2G         RWX                           24s   Filesystem

NAME                                  READY   STATUS    RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
pod/pvc-nginx-demo-66974fc6bc-45g86   1/1     Running   0          20s   10.100.5.21   centos7k8s3   <none>           <none>
pod/pvc-nginx-demo-66974fc6bc-xrk2g   1/1     Running   0          21s   10.100.1.83   centos7k8s2   <none>           <none>

echo "111111pvc" > /opt/data/k8s/pv/pv001/index.html

curl 10.100.5.21
111111pvc
```

### (4)回收验证

```
#删除deployment
kubectl delete -f 03_pvc_nginx.yml 
deployment.apps "pvc-nginx-demo" deleted
service "pvc-nginx-svc" deleted
#删除pvc
kubectl delete -f 02_pvc.yml 
persistentvolumeclaim "pv-pvc-demo" deleted
#查看是否自动回收
[root@centos7k8s1 pv_pvc]# kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                 STORAGECLASS   REASON   AGE
pv001-nfs   2G         RWX            Recycle          Released    default/pv-pvc-demo                           91m
pv002-nfs   5G         RWX            Retain           Available                                                 22m
pv003-nfs   8G         RWX            Retain           Available                                                 91m
[root@centos7k8s1 pv_pvc]# kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv001-nfs   2G         RWX            Recycle          Available   #变成available 验证成功          91m
pv002-nfs   5G         RWX            Retain           Available                                   22m
pv003-nfs   8G         RWX            Retain           Available                                   91m
```

### (5)手动回收

```
首先还是需要清除pod资源，然后删除pvc资源，将对应pv中的需要备份的数据备份，再删除对应的pv资源，再重新创建。
persistentVolumeReclaimPolicy值要是Retain
例如：
kubectl delete -f 03_pvc_nginx.yml 
kubectl delete -f 02_pvc.yml
mv /opt/data/k8s/pv/pv002/index.html /tmp
kubectl delete pv pv002-nfs
kubectl apply -f 01_pv_nfs.yml
```

