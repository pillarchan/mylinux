# dashboard

```
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
```

