# storageclasses(sc)

## 概念

```
- sc:
自动创建pv的一种存储类，pvc可以指定去哪个sc申请资源。
```

## 动态存储类sc实战

### (1)k8s组件原生并不支持NFS动态存储

```
https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner
```

| Volume Plugin  | Internal Provisioner |                        Config Example                        |
| :------------- | :------------------: | :----------------------------------------------------------: |
| AzureFile      |          ✓           | [Azure File](https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-file) |
| CephFS         |          -           |                              -                               |
| FC             |          -           |                              -                               |
| FlexVolume     |          -           |                              -                               |
| iSCSI          |          -           |                              -                               |
| Local          |          -           | [Local](https://kubernetes.io/docs/concepts/storage/storage-classes/#local) |
| NFS            |          -           | [NFS](https://kubernetes.io/docs/concepts/storage/storage-classes/#nfs) |
| PortworxVolume |          ✓           | [Portworx Volume](https://kubernetes.io/docs/concepts/storage/storage-classes/#portworx-volume) |
| RBD            |          -           | [Ceph RBD](https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd) |
| VsphereVolume  |          ✓           | [vSphere](https://kubernetes.io/docs/concepts/storage/storage-classes/#vsphere) |

### (2)NFS不提供内部配置器实现动态存储，但可以使用外部配置器。

```
git clone https://gitee.com/yinzhengjie/k8s-external-storage.git
如果没有git就先装git 
yum -y install git
```

### (3)修改nfs-client-provisioner配置文件

```
cat k8s-external-storage/nfs-client/deploy/deployment.yaml
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
          image: gmoney23/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs #此处需要和storageclasses中provisioner字段的值一致
            - name: NFS_SERVER
              value: 192.168.76.142
            - name: NFS_PATH
              value: /opt/data/kubernetes/
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.76.142
            # path: /ifs/kubernetes
            path: /opt/data/kubernetes/
```

### (4)修改动态存储类的配置文件

```
cat k8s-external-storage/nfs-client/deploy/class.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  # archiveOnDelete: "false"
  archiveOnDelete: "true"
```

### 	(5)nfs服务器端创建sc需要共享路径

```
mkdir -pv /opt/data/kubernetes
```

### 	(6)创建动态存储类

```
kubectl apply -f class.yaml && kubectl get sc
```

### 	(7)创建授权角色

```
kubectl apply -f rbac.yaml
```

### 	(8)部署nfs动态存储配置器

```
kubectl apply -f deployment.yaml
```

### 	(9)查看是否部署成功（如下图所示）

```
kubectl get pods,sc
NAME                                          READY   STATUS    RESTARTS   AGE
pod/nfs-client-provisioner-75b8d55b6b-z7dfq   1/1     Running   0          3m23s

NAME                                              PROVISIONER      RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/managed-nfs-storage   fuseim.pri/ifs   Delete          Immediate           false                  5m17s
```

### 	(10)测试动态存储类

```
cat test-claim.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim-01
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Mi
      
cat test-pod.yaml
kind: Pod
apiVersion: v1
metadata:
  name: test-sc-pvc-pod
spec:
  containers:
  - name: test-sc-pvc-pod-01
    image: harbor.myharbor.com/myharbor/nginx:v3.0-my
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
        claimName: test-claim-01

kubectl get po,sc,pvc
NAME                                          READY   STATUS      RESTARTS   AGE
pod/nfs-client-provisioner-75b8d55b6b-z7dfq   1/1     Running     0          9m30s
pod/test-sc-pvc-pod                           0/1     Completed   0          21s

NAME                                              PROVISIONER      RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/managed-nfs-storage   fuseim.pri/ifs   Delete          Immediate           false                  11m

NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS          AGE
persistentvolumeclaim/test-claim-01   Bound    pvc-b9e61ef2-1506-459b-a372-24e20dc6a45f   20Mi       RWX            managed-nfs-storage   92s
```

