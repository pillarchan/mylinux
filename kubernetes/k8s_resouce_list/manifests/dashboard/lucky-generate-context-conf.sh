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
