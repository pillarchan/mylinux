#!/bin/bash
yum remove docker \
             docker-client \
             docker-client-latest \
             docker-common \
             docker-latest \
             docker-latest-logrotate \
             docker-logrotate \
             docker-engine
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#yum list containerd.io --showduplicates

yum install containerd.io-1.7.19-3.1
containerd config default | tee /etc/containerd/config.toml
sed -ri 's@(SystemdCgroup = )false@\1true@' /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable --now containerd

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe -- overlay
modprobe -- br_netfilter

cat > /etc/sysctl.d/k8s.conf <<'EOF'
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv6.conf.all.disable_ipv6 = 1
fs.may_detach_mounts = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
EOF

sysctl --system




wget https://dl.k8s.io/v1.31.2/kubernetes-server-linux-amd64.tar.gz
wget https://storage.googleapis.com/etcd/v3.5.16/etcd-v3.5.16-linux-amd64.tar.gz

tar xf kubernetes-server-linux-amd64.tar.gz --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{ctl,let,-apiserver,-controller-manager,-scheduler,-proxy}
tar xf etcd-v3.5.16-linux-amd64.tar.gz --strip-components=1 -C /usr/local/bin etcd-v3.5.16-linux-amd64/etcd{,ctl}


kube-apiserver --version
kube-controller-manager --version
kube-scheduler --version
etcdctl version
kubelet --version
kube-proxy --version
kubectl version

mkdir -p /opt/cni/bin




