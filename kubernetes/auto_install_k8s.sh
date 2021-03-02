#!bin/sh
#添加kubernetes repo文件
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
#添加ipvs模块
ipvs_mods_dir=/usr/lib/modules/$(uname -r)/kernel/net/netfilter/ipvs
for i in $( ls $ipvs_mods_dir | grep -o "^[^.]*" );do
    /sbin/modinfo -F filename $i &> /dev/null
    if [ $? -eq 0 ];then
        /sbin/modprobe $i
    fi
done
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl -p /etc/sysctl.d/k8s.conf
systcl --system
sudo yum install -y kubelet kubeadm

sudo sed -i 's@^\(KUBELET_EXTRA_ARGS=\).*$@\1"--fail-swap-on=false"@' /etc/sysconfig/kubelet
sudo systemctl enable kubelet

#sudo kubeadm init --kubernetes-version="$(kubeadm config print init-defaults | egrep -o "^kubernetesVersion.+[0-9]$" | cut -d" " -f2)" --pod-network-cidr="10.244.0.0/16" --ignore-preflight-errors="Swap"

# kubeadm join 192.168.157.180:6443 --token 85rsv0.299i13uufzs9vibg \
#     --discovery-token-ca-cert-hash sha256:60dac6d94104c03f3c9cd19a2b2b3024ddb0445ebbc7e4fa208999315530b6e6 --ignore-preflight-errors="Swap"