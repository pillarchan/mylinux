# Dashboard

## 概念

```
Dashboard:
	它是K8S集群管理的一个GUI的WebUI实现，它是一个k8s附加组件，所以需要单独部署。
	我们可以以图形化的方式创建k8s资源。
	GitHub地址:
		https://github.com/kubernetes/dashboard#kubernetes-dashboard
```

## 安装dashboard

### (1)下载dashboard资源清单

```
wget -O  k8s_1_23-dashabord.yaml https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.1/aio/deploy/recommended.yaml
```

### (2)修改資源清单

```
vim k8s_1_23-dashabord.yaml 
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
```

### (3)安装dashboard

```
kubectl apply -f k8s_1_23-dashabord.yaml 
```

### (4)访问dashboard页面

```
查看pod和svc进行访问
kubectl -n kubernetes-dashboard get pod,svc -o wide
NAME                                             READY   STATUS    RESTARTS   AGE    IP            NODE          NOMINATED NODE   READINESS GATES
pod/dashboard-metrics-scraper-799d786dbf-6zkqn   1/1     Running   0          102s   10.100.1.85   centos7k8s2   <none>           <none>
pod/kubernetes-dashboard-fb8648fd9-pcflr         1/1     Running   0          102s   10.100.5.25   centos7k8s3   <none>           <none>

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE    SELECTOR
service/dashboard-metrics-scraper   ClusterIP   10.200.194.159   <none>        8000/TCP       102s   k8s-app=dashboard-metrics-scraper
service/kubernetes-dashboard        NodePort    10.200.242.231   <none>        443:8443/TCP   103s   k8s-app=kubernetes-dashboard

https://192.168.76.144:8443/
	鼠标单机空白处，输入以下代码:
		thisisunsafe
```

## 基于token登录案例

### 	(1)编写K8S的yaml资源清单文件

```
cat > lucky-dashboard-rbac.yaml <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  # 创建一个名为"lucky"的账户
  name: lucky
  namespace: kube-system

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: lucky-dashboard
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
    name: lucky
    namespace: kube-system
EOF
```

### 	(2)创建资源清单

```
kubectl apply -f lucky-dashboard-rbac.yaml
```

### 	(3)查看sa资源的Tokens名称

```
kubectl describe serviceaccounts -n kube-system  lucky | grep Tokens
```

### 	(4)根据上一步的token名称的查看token值

```
kubectl describe secrets lucky-token-5tdn7 -n kube-system 
Name:         lucky-token-5tdn7
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: lucky
              kubernetes.io/service-account.uid: f6fdad20-da21-439e-9130-86f903f2b367

Type:  kubernetes.io/service-account-token

Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6Im5xOXRCZm56S291cDA5cm9URUdSSXBuRm5hbWlzcERNREhWUnlVenFBdUUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJsdWNreS10b2tlbi01dGRuNyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJsdWNreSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImY2ZmRhZDIwLWRhMjEtNDM5ZS05MTMwLTg2ZjkwM2YyYjM2NyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpsdWNreSJ9.IcYUn0Ts-j9qZOwqVSlRmDZ380HKRBYY63XiTSTFaIyBn-jWJR3W2eBQi0abB1dT4Kpw62onZbxD5htIVP59SyGEBvpT7cCisPU4fWKdjNH8BKaS_j7E1_iiWnB9Dyr04UCUh-Mr0gl202Ld1xjrB9yedX2MtNEmsm8U4Dxrnutk4PznSIL02ZgopSzt2-YPKMZZG_mEac0dY_9Yqmx61C0p-ps8rQ_rDu4jEnHiDy661FJDoB2wojOVmY5WABMNsxH5UvyzvTqHUQKHTIkt_bQ--1i5yH_Z8vtEoJcljXuwrauWbXdKXAnTJ8OSodzGE0JR8EymvyMWDf2RlZeHHg
ca.crt:     1099 bytes
namespace:  11 bytes
```

### 	(5)登录dashboard的WebUI

```
使用上一步的Token值登录即可（注意，复制时不要有换行哟)
```

## 基于kubeconfig登录案例

### 	(1)编写生成kubeconf的配置文件的脚本

```
cat > lucky-generate-context-conf.sh <<'EOF'
#!/bin/bash
# 获取secret的名称
SECRET_NAME=$(kubectl -n kube-system describe serviceaccounts lucky | grep -i tokens | awk '{print $2}')

# 指定API SERVER的地址
API_SERVER=centos7k8s1:6443

# 指定kubeconfig配置文件的路径名称
KUBECONFIG_NAME=/root/lucky-k8s-dashboard-admin.kubeconfig

# 获取lucky用户的tocken
LUCKY_TOCKEN=$(kubectl get secrets -n kube-system $SECRET_NAME -o jsonpath={.data.token} | base64 -d)

# 在kubeconfig配置文件中设置群集项
kubectl config set-cluster lucky-k8s-dashboard-cluster --server=$API_SERVER --kubeconfig=$KUBECONFIG_NAME

# 在kubeconfig中设置用户项
kubectl config set-credentials lucky-k8s-dashboard-user --token=$LUCKY_TOCKEN --kubeconfig=$KUBECONFIG_NAME

# 配置上下文，即绑定用户和集群的上下文关系，可以将多个集群和用户进行绑定哟~
kubectl config set-context lucky-admin --cluster=lucky-k8s-dashboard-cluster --user=lucky-k8s-dashboard-user --kubeconfig=$KUBECONFIG_NAME

# 配置当前使用的上下文
kubectl config use-context lucky-admin --kubeconfig=$KUBECONFIG_NAME
EOF
```

### 	(2)运行上述脚本并下载上一步生成的配置文件到桌面，如上图所示，选择并选择该文件进行登录

```
cd 
sz lucky-k8s-dashboard-admin.conf
```

### 	(3)进入到dashboard的WebUI

```
如下图所示，我们可以访问任意的Pod，当然也可以直接进入到有终端的容器哟
```

