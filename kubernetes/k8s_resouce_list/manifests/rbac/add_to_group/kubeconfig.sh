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
