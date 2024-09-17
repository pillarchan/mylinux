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







```
删除pvc验证pv的回收策略:
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


- PV的回收策略:
	(1)給pv打补丁
[root@k8s231.oldboyedu.com persistentvolumeclaims]# kubectl get pv,pvc
NAME                                    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                         STORAGECLASS   REASON   AGE
persistentvolume/oldboyedu-linux-pv01   2Gi        RWX            Retain           Available                                                         157m
persistentvolume/oldboyedu-linux-pv02   5Gi        RWX            Retain           Released    default/oldboyedu-linux-pvc                           157m
persistentvolume/oldboyedu-linux-pv03   10Gi       RWX            Retain           Available                                                         157m
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 
[root@k8s231.oldboyedu.com persistentvolumeclaims]# kubectl patch pv oldboyedu-linux-pv03  -p '{"spec":{"persistentVolumeReclaimPolicy":"Recycle"}}'
persistentvolume/oldboyedu-linux-pv03 patched
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 
[root@k8s231.oldboyedu.com persistentvolumeclaims]# kubectl get pv,pvc
NAME                                    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                         STORAGECLASS   REASON   AGE
persistentvolume/oldboyedu-linux-pv01   2Gi        RWX            Retain           Available                                                         157m
persistentvolume/oldboyedu-linux-pv02   5Gi        RWX            Retain           Released    default/oldboyedu-linux-pvc                           157m
persistentvolume/oldboyedu-linux-pv03   10Gi       RWX            Recycle          Available                                                         157m
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 



	(2)测试
[root@k8s231.oldboyedu.com persistentvolumeclaims]# cat 01-manual-pvc.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: oldboyedu-linux-pvc
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
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 
[root@k8s231.oldboyedu.com persistentvolumeclaims]# cat 02-deploy-nginx-pvc.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-nginx-pvc
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: apps
      operator: Exists
  template:
    metadata:
      labels:
        apps: nginx
    spec:
      volumes:
      - name: data
        # 声明是一个PVC类型
        persistentVolumeClaim:
          # 引用哪个PVC
          claimName: oldboyedu-linux-pvc
      containers:
      - name: web
        image: harbor.oldboyedu.com/web/apps:v1
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html

---

apiVersion: v1
kind: Service
metadata:
  name: oldboyedu-linux-nginx
spec:
  type: NodePort
  selector:
    apps: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 




动态存储类sc实战:
	(1)k8s组件原生并不支持NFS动态存储
https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner

	(2)NFS不提供内部配置器实现动态存储，但可以使用外部配置器。
[root@k8s231.oldboyedu.com storageclasses]# yum -y install git

[root@k8s231.oldboyedu.com storageclasses]# git clone https://gitee.com/yinzhengjie/k8s-external-storage.git

	(3)修改配置文件
[root@k8s231.oldboyedu.com storageclasses]# cd k8s-external-storage/nfs-client/deploy
[root@k8s231.oldboyedu.com deploy]# cat deployment.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          # image: quay.io/external_storage/nfs-client-provisioner:latest
          image: registry.cn-hangzhou.aliyuncs.com/yinzhengjie-k8s/sc:nfs-client-provisioner
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: oldboyedu/linux85
              # value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 10.0.0.231
            - name: NFS_PATH
              value: /oldboyedu/data/kubernetes/sc
      volumes:
        - name: nfs-client-root
          nfs:
            server: 10.0.0.231
            # path: /ifs/kubernetes
            path: /oldboyedu/data/kubernetes/sc
[root@k8s231.oldboyedu.com deploy]# 



	(4)修改动态存储类的配置文件
[root@k8s231.oldboyedu.com deploy]# cat class.yaml 
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
# provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
provisioner: oldboyedu/linux85
parameters:
  # archiveOnDelete: "false"
  archiveOnDelete: "true"
[root@k8s231.oldboyedu.com deploy]# 


	(5)nfs服务器端创建sc需要共享路径
[root@k8s231.oldboyedu.com deploy]# mkdir -pv /oldboyedu/data/kubernetes/sc

	(6)创建动态存储类
[root@k8s231.oldboyedu.com deploy]# kubectl apply -f class.yaml && kubectl get sc


	(7)创建授权角色
[root@k8s231.oldboyedu.com deploy]# kubectl apply -f rbac.yaml 

	(8)部署nfs动态存储配置器
[root@k8s231.oldboyedu.com deploy]# kubectl apply -f deployment.yaml 


	(9)查看是否部署成功（如下图所示）
[root@k8s231.oldboyedu.com deploy]# kubectl get pods,sc
NAME                                         READY   STATUS    RESTARTS   AGE
pod/nfs-client-provisioner-c494888bb-rxvtf   1/1     Running   0          90s

NAME                                              PROVISIONER         RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/managed-nfs-storage   oldboyedu/linux85   Delete          Immediate           false                  2m27s
[root@k8s231.oldboyedu.com deploy]# 


	(10)测试动态存储类
[root@k8s231.oldboyedu.com deploy]# cat test-claim.yaml 
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim-001
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
spec:
  #storageClassName: managed-nfs-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Mi
[root@k8s231.oldboyedu.com deploy]# 
[root@k8s231.oldboyedu.com deploy]# 
[root@k8s231.oldboyedu.com deploy]# cat test-pod.yaml 
kind: Pod
apiVersion: v1
metadata:
  name: test-pod
spec:
  containers:
  - name: test-pod
    image: harbor.oldboyedu.com/web/apps:v1
    command:
      - "/bin/sh"
    args:
      - "-c"
      - "touch /mnt/SUCCESS && exit 0 || exit 1"
    volumeMounts:
      - name: nfs-pvc
        mountPath: "/mnt"
  restartPolicy: "Never"
  volumes:
    - name: nfs-pvc
      persistentVolumeClaim:
        claimName: test-claim-001
[root@k8s231.oldboyedu.com deploy]#  
```

