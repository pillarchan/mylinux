# coreDNS概述

**coreDNS的作用就是将svc的名称解析为ClusterIP。**

早期使用的skyDNS组件，需要单独部署，在k8s 1.9版本中，我们就可以直接使用kubeadm方式安装CoreDNS组件。

从k8s 1.12开始，CoreDNS就成为kubernetes默认的DNS服务器，但是kubeadm支持coreDNS的时间会更早。

推荐阅读:
	https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns/coredns



 coreDNS的IP地址:
 vim  /var/lib/kubelet/config.yaml 
...
clusterDNS:

- 10.254.0.10
clusterDomain: cluster.local

coreDNS的A记录
	k8s的svc的A记录格式:
<service name>[.<namespace name>.svc.oldboyedu.com]



测试coredns

可以进入到容器中测试

kubeclt exec -it  [-n namespace]  podname -- ping  \<service name\>[.\<namespace name\>.svc.clusterDomain]

可以使用dig

dig @clusterDNS_ip \<service name\>.\<namespace name.svc.clusterDomain\>

配置 /etc/resolev.conf

nameserver clusterDNS_ip