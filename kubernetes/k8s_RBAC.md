```
昨日内容回顾:
	- 污点:
		- 格式:
			KEY[=VALUE]:effect
		effect:
			NoScheduler
			PreferNoScheduler
			NoExecute
	- 污点容忍:
	- 节点选择器:
	- 亲和性:
		- 节点亲和性
		- Pod亲和性
		- Pod反亲和性
	- daemonSets
	- Pod驱逐
	- kubeadm集群的扩缩容
	- kube-proxy的工作切换，由iptables切换为ipvs
	- svc的NodePort类型的端口范围映射	
	
今日内容预告:
	- K8S的安全框架;
	- Ingress
	- add-ons：
		- dashboard
		- metric-server
	- helm
	











serviceaccount:
	一般用于程序的用户名。

创建方式
	- 响应式创建serviceAccounts
[root@k8s231.oldboyedu.com serviceAccount]# kubectl create serviceaccount oldboyedu-linux
serviceaccount/oldboyedu-linux created
[root@k8s231.oldboyedu.com serviceAccount]# 

	- 声明式创建serviceaccount
[root@k8s231.oldboyedu.com serviceaccounts]# cat 01-sa.yaml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: oldboyedu-linux
[root@k8s231.oldboyedu.com serviceaccounts]# 

  

- 授权容器中的Python程序对K8S API访问权限案例
授权容器中Python程序对K8S API访问权限步骤:
	- 创建Role;
	- 创建ServiceAccount;
	- 将ServiceAccount于Role绑定;
	- 为Pod指定自定义的SA;
	- 进入容器执行Python程序测试操作K8S API权限;
	
	
	
- 基于服务账号授权案例
[root@k8s231.oldboyedu.com serviceAccount]# ll
total 16
-rw-r--r-- 1 root root  73 Apr 21 11:18 01-sa.yaml
-rw-r--r-- 1 root root 173 Apr 21 11:19 02-Role.yaml
-rw-r--r-- 1 root root 246 Apr 21 11:19 03-RoleBinding.yaml
-rw-r--r-- 1 root root 532 Apr 21 11:32 04-deploy.yaml
[root@k8s231.oldboyedu.com serviceAccount]# 
[root@k8s231.oldboyedu.com serviceAccount]# 
[root@k8s231.oldboyedu.com serviceAccount]# cat 01-sa.yaml 
apiVersion: v1
kind: ServiceAccount 
metadata:
  name: oldboyedu-python 
[root@k8s231.oldboyedu.com serviceAccount]# 
[root@k8s231.oldboyedu.com serviceAccount]# cat 02-Role.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: oldboyedu-pod-reader 
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
[root@k8s231.oldboyedu.com serviceAccount]# 
[root@k8s231.oldboyedu.com serviceAccount]# cat 03-RoleBinding.yaml 
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: oldboyedu-sa-to-role
subjects:
- kind: ServiceAccount 
  name: oldboyedu-python
roleRef:
  kind: Role
  name: oldboyedu-pod-reader
  apiGroup: rbac.authorization.k8s.io
[root@k8s231.oldboyedu.com serviceAccount]# 
[root@k8s231.oldboyedu.com serviceAccount]# cat 04-deploy.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oldboyedu-linux-web
spec:
  replicas: 2
  selector:
    # matchLabels:
    #   apps: web
    matchExpressions:
    - key: apps
      operator: Exists
  template:
    metadata:
      labels:
         apps: web
    spec:
      # 指定sa的名称，请确认该账号是有权限访问K8S集群的哟!
      serviceAccountName: oldboyedu-python
      containers:
      - image: harbor.oldboyedu.com/dev/python:3.9.16
        name: web
        command: ["tail","-f","/etc/hosts"]
[root@k8s231.oldboyedu.com serviceAccount]# 

	
	
	
- 编写Python程序，进入到"python"Pod所在的容器执行以下Python代码即可!
[root@k8s231.oldboyedu.com serviceAccount]# kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
oldboyedu-linux-web-7d68c9d554-2hppj   1/1     Running   0          9m52s
oldboyedu-linux-web-7d68c9d554-j8lh4   1/1     Running   0          9m52s
[root@k8s231.oldboyedu.com serviceAccount]# 
[root@k8s231.oldboyedu.com serviceAccount]# kubectl exec -it oldboyedu-linux-web-7d68c9d554-2hppj  -- sh
/ # cat > oldboyedu-python-k8s.py <<'EOF'
from kubernetes import client, config

with open('/var/run/secrets/kubernetes.io/serviceaccount/token') as f:
     token = f.read()

# print(token)
configuration = client.Configuration()
configuration.host = "https://kubernetes"  # APISERVER地址
configuration.ssl_ca_cert="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"  # CA证书 
configuration.verify_ssl = True   # 启用证书验证
configuration.api_key = {"authorization": "Bearer " + token}  # 指定Token字符串
client.Configuration.set_default(configuration)
apps_api = client.AppsV1Api() 
core_api = client.CoreV1Api() 
try:
  print("###### Deployment列表 ######")
  #列出default命名空间所有deployment名称
  for dp in apps_api.list_namespaced_deployment("default").items:
    print(dp.metadata.name)
except:
  print("没有权限访问Deployment资源！")

try:
  #列出default命名空间所有pod名称
  print("###### Pod列表 ######")
  for po in core_api.list_namespaced_pod("default").items:
    print(po.metadata.name)
except:
  print("没有权限访问Pod资源！")
EOF

/ # 
/ # pip install kubernetes -i https://pypi.tuna.tsinghua.edu.cn/simple/  # 安装Python程序依赖的软件包并测试
/ # 
/ # python3 oldboyedu-python-k8s.py






手动创建PV

	1.准备nfs路径
[root@k8s231.oldboyedu.com ~]# mkdir -pv /oldboyedu/data/kubernetes/pv/linux/pv00{1,2,3}


	(1)编写PV资源清单
[root@k8s231.oldboyedu.com persistentvolumes]# cat > 01-manual-pv.yaml <<'EOF'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: oldboyedu-linux-pv01
  labels:
    school: oldboyedu
spec:
   # 声明PV的访问模式，常用的有"ReadWriteOnce","ReadOnlyMany"和"ReadWriteMany":
   #   ReadWriteOnce:(简称:"RWO")
   #      只允许单个worker节点读写存储卷，但是该节点的多个Pod是可以同时访问该存储卷的。
   #   ReadOnlyMany:(简称:"ROX")
   #      允许多个worker节点进行只读存储卷。
   #   ReadWriteMany:(简称:"RWX")
   #      允许多个worker节点进行读写存储卷。
   #   ReadWriteOncePod:(简称:"RWOP")
   #       该卷可以通过单个Pod以读写方式装入。
   #       如果您想确保整个集群中只有一个pod可以读取或写入PVC，请使用ReadWriteOncePod访问模式。
   #       这仅适用于CSI卷和Kubernetes版本1.22+。
   accessModes:
   - ReadWriteMany
   # 声明存储卷的类型为nfs
   nfs:
     path: /oldboyedu/data/kubernetes/pv/linux/pv001
     server: 10.0.0.231
   # 指定存储卷的回收策略，常用的有"Retain"和"Delete"
   #    Retain:
   #       "保留回收"策略允许手动回收资源。
   #       删除PersistentVolumeClaim时，PersistentVolume仍然存在，并且该卷被视为"已释放"。
   #       在管理员手动回收资源之前，使用该策略其他Pod将无法直接使用。
   #    Delete:
   #       对于支持删除回收策略的卷插件，k8s将删除pv及其对应的数据卷数据。
   #    Recycle:
   #       对于"回收利用"策略官方已弃用。相反，推荐的方法是使用动态资源调配。
   #       如果基础卷插件支持，回收回收策略将对卷执行基本清理（rm -rf /thevolume/*），并使其再次可用于新的声明。
   persistentVolumeReclaimPolicy: Retain
   # 声明存储的容量
   capacity:
     storage: 2Gi

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: oldboyedu-linux-pv02
  labels:
    school: oldboyedu
spec:
   accessModes:
   - ReadWriteMany
   nfs:
     path: /oldboyedu/data/kubernetes/pv/linux/pv002
     server: 10.0.0.231
   persistentVolumeReclaimPolicy: Retain
   capacity:
     storage: 5Gi

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: oldboyedu-linux-pv03
  labels:
    school: oldboyedu
spec:
   accessModes:
   - ReadWriteMany
   nfs:
     path: /oldboyedu/data/kubernetes/pv/linux/pv003
     server: 10.0.0.231
   persistentVolumeReclaimPolicy: Retain
   capacity:
     storage: 10Gi
EOF


	(2)创建pv
[root@k8s231.oldboyedu.com persistentvolumes]#  kubectl apply -f 01-manual-pv.yaml


	(3)查看pv资源
[root@k8s231.oldboyedu.com persistentvolumes]# kubectl get pv
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
	
	
	
[root@k8s231.oldboyedu.com persistentvolumeclaims]# ll
total 8
-rw-r--r-- 1 root root 260 Apr 21 12:04 01-manual-pvc.yaml
-rw-r--r-- 1 root root 764 Apr 21 12:11 02-deploy-nginx-pvc.yaml
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 
[root@k8s231.oldboyedu.com persistentvolumeclaims]# 
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






Dashboard:
	它是K8S集群管理的一个GUI的WebUI实现，它是一个k8s附加组件，所以需要单独部署。
	我们可以以图形化的方式创建k8s资源。
	GitHub地址:
		https://github.com/kubernetes/dashboard#kubernetes-dashboard



安装dashboard:
	(1)下载dashboard资源清单
[root@k8s231.oldboyedu.com dashabord]# wget -O  k8s_1_23-dashabord.yaml  https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.1/aio/deploy/recommended.yaml
[root@k8s231.oldboyedu.com dashabord]# 


	(2)修改資源清单
[root@k8s231.oldboyedu.com dashabord]# vim k8s_1_23-dashabord.yaml 
...
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  # 修改svc的类型
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
	  # 添加端口映射
      nodePort: 8443
  selector:
    k8s-app: kubernetes-dashboard


	
	
	(3)安装dashboard
[root@k8s231.oldboyedu.com dashabord]# kubectl apply -f k8s_1_23-dashabord.yaml 



	(4)访问dashboard页面
https://10.0.0.231:8443/

		鼠标单机空白处，输入以下代码:
			thisisunsafe





基于token登录案例:
	(1)编写K8S的yaml资源清单文件
[root@k8s231.oldboyedu.com dashabord]# cat > oldboyedu-dashboard-rbac.yaml <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  # 创建一个名为"oldboyedu"的账户
  name: oldboyedu
  namespace: kube-system

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: oldboyedu-dashboard
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  # 既然绑定的是集群角色，那么类型也应该为"ClusterRole",而不是"Role"哟~
  kind: ClusterRole
  # 关于集群角色可以使用"kubectl get clusterrole | grep admin"进行过滤哟~
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    # 此处要注意哈，绑定的要和我们上面的服务账户一致哟~
    name: oldboyedu
    namespace: kube-system
EOF
 
	(2)创建资源清单
[root@k8s231.oldboyedu.com dashabord]# kubectl apply -f oldboyedu-dashboard-rbac.yaml


	(3)查看sa资源的Tokens名称
[root@k8s231.oldboyedu.com dashabord]# kubectl describe serviceaccounts -n kube-system  oldboyedu | grep Tokens
Tokens:              oldboyedu-token-5f5qf
[root@k8s231.oldboyedu.com dashabord]# 

	(4)根据上一步的token名称的查看token值
[root@k8s231.oldboyedu.com dashabord]# kubectl -n kube-system describe secrets oldboyedu-token-5f5qf 
Name:         oldboyedu-token-5f5qf 
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: oldboyedu
              kubernetes.io/service-account.uid: e807b664-59c9-4b2e-a2d9-50b55faa108a

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1099 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImxyU0dWc1lPaG1yeUFtUGdkR2Q5WE5lbjVtb2hsWEMzZ0Q3MGREMEpkX2sifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJvbGRib3llZHUtdG9rZW4td3dobGYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoib2xkYm95ZWR1Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiZTgwN2I2NjQtNTljOS00YjJlLWEyZDktNTBiNTVmYWExMDhhIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOm9sZGJveWVkdSJ9.rxeYxmgiNJkz7jdiwjTdWqvROtSa0m7CyHgfxNZHHS_GkzhgoZHjhgbrnKs5nyOpBl6ncl210lXIoUAgIKXuH6nAWc8TSEeZzmTkMTKcui7sOSR8h3EDdK0AEXk4ltZccH0uOPa1MUj5PL-TcxYYxuRLxhEza2ChGdnMnsBef2QRFzVcz38ZcY52jgeBVUZ1_tEgtnjqjY6PGahwRokZ_lSvNPHua4fUfA4QBZh3p6-59INFpL8Wiv0ekH9pvRPhc6UOdhrkhuaUCHfIQYoRRR_8g1Jy6-AFNqC5S73nfgkUVycsoP7ULJAFWg1BWQuoOoNKQ3t-c_GYYk5N1jefdQ
[root@k8s231.oldboyedu.com dashabord]#


	(5)登录dashboard的WebUI
使用上一步的Token值登录即可（注意，复制时不要有换行哟)





基于kubeconfig登录案例:
	(1)编写生成kubeconf的配置文件的脚本
cat > oldboyedu-generate-context-conf.sh <<'EOF'
#!/bin/bash
# auther: Jason Yin


# 获取secret的名称
SECRET_NAME=`kubectl get secrets -n kube-system  | grep oldboyedu | awk {'print $1'}`

# 指定API SERVER的地址
API_SERVER=k8s231.oldboyedu.com:6443

# 指定kubeconfig配置文件的路径名称
KUBECONFIG_NAME=/root/oldboyedu-k8s-dashboard-admin.kubeconfig

# 获取oldboyedu用户的tocken
OLDBOYEDU_TOCKEN=`kubectl get secrets -n kube-system $SECRET_NAME -o jsonpath={.data.token} | base64 -d`

# 在kubeconfig配置文件中设置群集项
kubectl config set-cluster oldboyedu-k8s-dashboard-cluster --server=$API_SERVER --kubeconfig=$KUBECONFIG_NAME

# 在kubeconfig中设置用户项
kubectl config set-credentials oldboyedu-k8s-dashboard-user --token=$OLDBOYEDU_TOCKEN --kubeconfig=$KUBECONFIG_NAME

# 配置上下文，即绑定用户和集群的上下文关系，可以将多个集群和用户进行绑定哟~
kubectl config set-context oldboyedu-admin --cluster=oldboyedu-k8s-dashboard-cluster --user=oldboyedu-k8s-dashboard-user --kubeconfig=$KUBECONFIG_NAME

# 配置当前使用的上下文
kubectl config use-context oldboyedu-admin --kubeconfig=$KUBECONFIG_NAME
EOF


	(2)运行上述脚本并下载上一步生成的配置文件到桌面，如上图所示，选择并选择该文件进行登录
sz oldboyedu-k8s-dashboard-admin.conf


	(3)进入到dashboard的WebUI
如下图所示，我们可以访问任意的Pod，当然也可以直接进入到有终端的容器哟





周末作业:
	- 完成课堂的所有练习并整理思维导图;
	- 使用kubectl管理2套以上K8S集群;
	- 将"jasonyin2020/oldboyedu-games:v0.1"游戏镜像拆分成5个游戏镜像，要求使用一下几种资源:
		- deployment
		- configMap
		- secret
		- pv
		- pvc
		- sc
		- dashabord
		- ...
	
	
扩展作业:
	- 将"考试问卷系统"部署k8s集群;
	- 部署kubesphere系统，并完成作业3的部署。
		参考文档：
			https://kubesphere.io/zh/
	- 完成istio的服务部署;


```

# RBAC

## 角色

```
角色绑定
	角色：
		role: 某个名称空间的role,局部的资源
         cluster-role: 集群的角色,集群资源
         规则（rules）:
            apiGroups API组
            resources 资源列表
            verbs 操作方法
            ...
    主题：
    	User: 自定义用户名称，一般给人用的
    	ServiceAccount: 服务账号，一般是给程序使用
    	Group: 给一个组使用

K8S的内置角色:
	K8S内置集群角色：
		cluster-admin:
			超级管理员，有集群所有权限。
		admin:
			主要用于授权命名空间所有读写权限。
		edit:
			允许对大多数对象读写操作，不允许查看或者修改角色，角色绑定。
		view:
			允许对命名空间大多数对象只读权限，不允许查看角色，角色绑定和secret。

	K8S预定好了四个集群角色供用户使用，使用"kubectl get clusterrole"查看，其中"systemd:"开头的为系统内部使用。

	clusterrole查看，其中"system:"开头的为系统内部使用。
```

## cfssl (Cloudflare's PKI and TLS toolkit)

```
官网地址 https://github.com/cloudflare/cfssl
```

## 基于用户的权限管理实战

### 1.使用k8s ca签发客户端证书

```
1.1 安装证书管理工具包
需要go言环境
git clone https://github.com/cloudflare/cfssl.git
cd cfssl
make
make install

echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
cp bin/* /usr/local/bin/

1.2 编写证书请求
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF

cat > wahaha-csr.json <<EOF
{
  "CN": "wahaha",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

1.3 生成证书
cfssl gencert -ca=/etc/kubernetes/pki/ca.crt -ca-key=/etc/kubernetes/pki/ca.key -config=ca-config.json -profile=kubernetes wahaha-csr.json | cfssljson -bare wahaha
```

### 2.生成kubeconfig授权文件

```
2.1 编写生成kubeconfig文件的脚本
cat > kubeconfig.sh <<'EOF'
# 配置集群
# --certificate-authority
#   指定K8s的ca根证书文件路径
# --embed-certs
#   如果设置为true，表示将根证书文件的内容写入到配置文件中，
#   如果设置为false,则只是引用配置文件，将kubeconfig
# --server
#   指定APIServer的地址。
# --kubeconfig
#   指定kubeconfig的配置文件名称
kubectl config set-cluster wahaha-linux \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://192.168.76.142:6443 \
  --kubeconfig=wahaha-linux.kubeconfig
 
# 设置客户端认证
kubectl config set-credentials wahaha \
  --client-key=wahaha-key.pem \
  --client-certificate=wahaha.pem \
  --embed-certs=true \
  --kubeconfig=wahaha-linux.kubeconfig

# 设置默认上下文
kubectl config set-context linux \
  --cluster=wahaha-linux \
  --user=wahaha \
  --kubeconfig=wahaha-linux.kubeconfig

# 设置当前使用的上下文
kubectl config use-context linux --kubeconfig=wahaha-linux.kubeconfig
EOF

2.2 生成kubeconfig文件
bash kubeconfig.sh
```

### 3. 创建RBAC授权策略

```
3.1 创建rbac等配置文件
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: haha #需要指定名称空间
  name: linux-role-reader
rules:
  # API组,""表示核心组,该组包括但不限于"configmaps","nodes","pods","services"等资源.
- apiGroups: ["","apps/v1"]  
  # 资源类型，不支持写简称，必须写全称哟!!
  # resources: ["pods","deployments"]  
  resources: ["pods","deployments","services"]  
  # 对资源的操作方法.
  # verbs: ["get", "list"]  
  verbs: ["get", "list","delete"]  
- apiGroups: ["","apps"]
  resources: ["configmaps","secrets","daemonsets","deployments"] #
  verbs: ["get", "list"]  
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["delete"]  

---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: wahaha-linux-resources-reader
  namespace: haha #需要指定名称空间
subjects:
  # 主体类型
- kind: User
  # 用户名
  name: wahaha
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # 角色类型
  kind: Role  
  # 绑定角色名称
  name: linux-role-reader
  apiGroup: rbac.authorization.k8s.io

3.2 应用rbac授权
kubectl apply -f rbac.yaml 

3.3 访问测试
kubectl get  po,svc,deploy,cm -n haha --kubeconfig=wahaha-linux.kubeconfig 
NAME                                    READY   STATUS    RESTARTS   AGE
pod/web-wordpress-demo-96f689cd-5tq2d   1/1     Running   0          2d19h
pod/web-wordpress-demo-96f689cd-76wnd   1/1     Running   0          2d19h

NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/mysql-wordpress   ClusterIP      10.200.29.117   <none>        3306/TCP       8d
service/wordpress-svc     LoadBalancer   10.200.61.128   <pending>     80:30080/TCP   8d

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      28d
Error from server (Forbidden): deployments.apps is forbidden: User "wahaha" cannot list resource "deployments" in API group "apps" in the namespace "haha"


注意：
Error from server (Forbidden): deployments.apps is forbidden: User "wahaha" cannot list resource "deployments" in API group "apps" in the namespace "haha"

报错分析：
rules:
- apiGroups: ["","apps/v1"]  # 此处定义了api-resources为apps/v1
  resources: ["pods","deployments","services"]  # 
  verbs: ["get", "list","delete"]  
- apiGroups: ["","apps"] # 此处定义了api-resources为apps 在实践中可以理解为 kubectl api-resources | grep apps，相当于是匹配字符的一种，当然就是包含了apps/v1，但是实际操作中就算增加了一段新的apiGroups并且数组中加上apps/v1，指定deployments资源，还是会报同样的错，这是因为apps与apps/v1会被认为是两种apiGroups，且apps包含apps/v1，自然还是会以apps中指定的deployments为准
  resources: ["configmaps","secrets","daemonsets"] # 这里只指定了daemonsets一种资源,并没有指定deployments
  verbs: ["get", "list"]  
  
  kubectl api-resources | grep apps
controllerrevisions                            apps/v1                                true         ControllerRevision
daemonsets                        ds           apps/v1                                true         DaemonSet
deployments                       deploy       apps/v1                                true         Deployment
replicasets                       rs           apps/v1                                true         ReplicaSet
statefulsets                      sts          apps/v1                                true         StatefulSet 

小结: 相同资源组，资源与权限取并集
```

## RBAC基于组的方式认证

```
CN: 代表用户，
O: 组。
```

### 1.使用k8s ca签发客户端证书

```
1.1 编写证书请求
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF

cat > group-yohaha-user-yohaha1-csr.json << EOF
{
  "CN": "yohaha1",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "yohaha",
      "OU": "System"
    }
  ]
}
EOF

1.3 生成证书
cfssl gencert -ca=/etc/kubernetes/pki/ca.crt -ca-key=/etc/kubernetes/pki/ca.key -config=ca-config.json -profile=kubernetes group-yohaha-user-yohaha1-csr.json | cfssljson -bare group-yohaha
```

### 2.生成kubeconfig授权文件

```
2.1 编写生成kubeconfig文件的脚本
cat > kubeconfig.sh <<'EOF'
kubectl config set-cluster group-yohaha \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://192.168.76.142:6443 \
  --kubeconfig=group-yohaha.kubeconfig
 
# 设置客户端认证
kubectl config set-credentials yohaha \
  --client-key=group-yohaha-key.pem \
  --client-certificate=group-yohaha.pem \
  --embed-certs=true \
  --kubeconfig=group-yohaha.kubeconfig

# 设置默认上下文
kubectl config set-context linux \
  --cluster=group-yohaha \
  --user=yohaha \
  --kubeconfig=group-yohaha.kubeconfig

# 设置当前使用的上下文
kubectl config use-context linux --kubeconfig=group-yohaha.kubeconfig
EOF

2.2 生成kubeconfig文件
[root@centos7k8s1 group]# bash kubeconfig.sh 
Cluster "group-yohaha" set.
User "yohaha" set.
Context "linux" created.
Switched to context "linux".

scp group-yohaha.kubeconfig 192.168.76.144:/usr/local/src
```

### 3.创建RBAC授权策略

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: haha
  name: linux-role-reader
rules:
  # API组,""表示核心组,该组包括但不限于"configmaps","nodes","pods","services"等资源.
- apiGroups: ["","apps"]  
  # 资源类型，不支持写简称，必须写全称哟!!
  # resources: ["pods","deployments"]  
  resources: ["pods","configmaps","deployments","services","daemonsets"]  
  # 对资源的操作方法.
  # verbs: ["get", "list"]  
  verbs: ["get", "list","watch"]  
---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: group-yohaha-resources-reader
  namespace: haha
subjects:
  # 主体类型
- kind: Group
  # 用户组名
  name: yohaha
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # 角色类型
  kind: Role
  # 绑定角色名称
  name: linux-role-reader
  apiGroup: rbac.authorization.k8s.io
```

### 4.验证权限

```
kubectl -n haha get po,deploy,cm,svc,ds --kubeconfig=group-yohaha.kubeconfig
```

5.创建新用户加入yohaha组

```
5.1 使用k8s ca签发客户端证书
5.1.1 编写证书请求
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF

cat > group-yohaha-user-yohaha2-csr.jsonn <<EOF 
{
  "CN": "yohaha2",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "yohaha",
      "OU": "System"
    }
  ]
}
EOF

5.1.2 生成证书
cfssl gencert -ca=/etc/kubernetes/pki/ca.crt -ca-key=/etc/kubernetes/pki/ca.key -config=ca-config.json -profile=kubernetes group-yohaha-user-yohaha2-csr.json | cfssljson -bare yohaha2-yohaha

5.2 生成kubeconfig文件文件
5.2.1 编写生成kubeconfig文件的脚本
cat > kubeconfig.sh <<'EOF'
kubectl config set-cluster yohaha2-group-yohaha \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://192.168.76.142:6443 \
  --kubeconfig=yohaha2-group-yohaha.kubeconfig
 
# 设置客户端认证
kubectl config set-credentials yohaha2 \
  --client-key=yohaha2-yohaha-key.pem \
  --client-certificate=yohaha2-yohaha.pem \
  --embed-certs=true \
  --kubeconfig=yohaha2-group-yohaha.kubeconfig

# 设置默认上下文
kubectl config set-context yohaha2-linux \
  --cluster=yohaha2-group-yohaha \
  --user=yohaha2 \
  --kubeconfig=yohaha2-group-yohaha.kubeconfig

# 设置当前使用的上下文
kubectl config use-context yohaha2-linux --kubeconfig=yohaha2-group-yohaha.kubeconfig
EOF

5.2.2 生成kubeconfig文件
# bash kubeconfig.sh
# scp yohaha2-group-yohaha.kubeconfig 192.168.76.144:/usr/local/src

5.3 验证权限
kubectl -n haha get po,deploy,cm,svc,ds --kubeconfig=yohaha2-group-yohaha.kubeconfig 
NAME                                    READY   STATUS    RESTARTS   AGE
pod/web-wordpress-demo-96f689cd-5tq2d   1/1     Running   0          4d
pod/web-wordpress-demo-96f689cd-76wnd   1/1     Running   0          4d

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-wordpress-demo   2/2     2            2           9d

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      29d

NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/mysql-wordpress   ClusterIP      10.200.29.117   <none>        3306/TCP       9d
service/wordpress-svc     LoadBalancer   10.200.61.128   <pending>     80:30080/TCP   9d
```

