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

sudo yum install -y kubelet kubeadm

sudo sed -i 's@^\(KUBELET_EXTRA_ARGS=\).*$@\1"--fail-swap-on=false"@' /etc/sysconfig/kubelet
sudo systemctl enable kubelet