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
