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

### 5.创建新用户加入yohaha组

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

## serviceaccount

### 1.使用场景

```
一般用于程序的用户名。

- 基于服务账号授权案例


```

### 2.创建方式

```
响应式创建serviceAccounts
kubectl create serviceaccount yohaha

声明式创建serviceaccount
cat sa.yml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: yohaha
  namespace: haha
```

### 3.授权容器中的Python程序对K8S API访问权限案例

```
授权容器中Python程序对K8S API访问权限步骤:
	- 创建Role;
	- 创建ServiceAccount;
	- 将ServiceAccount于Role绑定;
	- 为Pod指定自定义的SA;
	- 进入容器执行Python程序测试操作K8S API权限;
```

#### 1.创建Role

```
cat role.yml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
medadata:
  name: python-role
  namesapce: haha
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list","watch"]
```

#### 2.创建ServiceAccount

```
cat sa.yml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: yohaha
  namespace: haha
```

#### 3.将ServiceAccount于Role绑定

```
cat roleBinding.yml 
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: python-rolebinding
  namespace: haha
subJects:
- kind: ServiceAccount
  name: yohaha-python
roleRef:
  kind: Role
  name: python-role
  apiGroup: rbac.authorization.k8s.io
```

#### 4.为Pod指定自定义的SA

```
cat deploy.yml 
apiVersion: apps/v1
kind: Deploy
metadata:
  name: python-sa-demo
  namespace: haha
spec:
  replicas: 2
  selector:
    matchExpressions:
    - key: apps
      values: 
      - pythonweb
      operator: In
  template:
    metadata:
      labels:
        apps: pythonweb
    spec:
      # 指定sa的名称，请确认该账号是有权限访问K8S集群的哟!
      serviceAccountName: yohaha-python
      containors:
      - name: python-sa-demo-1
        image: harbor.myharbor.com/myharbor/python:3.9.16
        imagePullPolicy: NoIfPresent
        command: 
        - "tail"
        - "-f"
        - "/etc/hosts"
```

5.编写Python程序，进入到"python"Pod所在的容器执行以下Python代码即可!

```
# cat > sa-python-k8s.py <<'EOF'
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
/ # python3 sa-python-k8s.py
###### Deployment列表 ######
没有权限访问Deployment资源！
###### Pod列表 ######
python-sa-demo-5b588b5845-q92qn
python-sa-demo-5b588b5845-qvprp
```

