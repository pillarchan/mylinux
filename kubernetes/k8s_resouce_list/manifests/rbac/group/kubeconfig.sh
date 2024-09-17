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
