# ipvs

## kube-proxy的工作模式

```
	对于kube-proxy组件的作用就是为k8s集群外部用户提供访问服务的路由。
	kube-proxy监听K8S APIServer，一旦service资源发生变化，kube-proxy就会生成对应的负载调度的调整，这样就保证service的最新状态。
	kube-proxy有三种调度模型:
		- userspace:
			k8s 1.1之前。
		- iptables:
			k8s 1.2 ~ k8s 1.11之前。
		- ipvs:
			K8S 1.11之后，如果没有开启ipvs，则自动降级为iptables。
```

## 查看当前kube-proxy的工作模式

```
1. 查看configMap资源是什么
kubectl -n kube-system get pods kube-proxy-4n6nd -o yaml | grep configMap -A 3
  - configMap:
      defaultMode: 420
      name: kube-proxy
    name: kube-proxy
    
2. 查看cm详情中mode 如为空则使用的是iptables模式
kubectl -n kube-system describe cm kube-proxy | grep mode
mode: ""

3. 通过查看日志获取
kubectl -n kube-system logs kube-proxy-4n6nd | head -7
I0812 02:20:22.275965       1 node.go:163] Successfully retrieved node IP: 192.168.76.143
I0812 02:20:22.276287       1 server_others.go:138] "Detected node IP" address="192.168.76.143"
I0812 02:20:22.276441       1 server_others.go:572] "Unknown proxy mode, assuming iptables proxy" proxyMode=""
I0812 02:20:22.359959       1 server_others.go:206] "Using iptables Proxier" #确认使用的是iptables
I0812 02:20:22.360099       1 server_others.go:213] "kube-proxy running in dual-stack mode" ipFamily=IPv4
I0812 02:20:22.360161       1 server_others.go:214] "Creating dualStackProxier for iptables"
I0812 02:20:22.360198       1 server_others.go:502] "Detect-local-mode set to ClusterCIDR, but no IPv6 cluster CIDR defined, , defaulting to no-op detect-local for IPv6"
```

## 来了解一下是如何通过iptables进行负载的

```
1. 查看一个正在运行svc
kubectl -n haha get svc
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
mysql-wordpress   ClusterIP      10.200.29.117   <none>        3306/TCP       3d9h
wordpress-svc     LoadBalancer   10.200.61.128   <pending>     80:30080/TCP   3d9h
2. 查看iptables规则
iptables-save | grep 10.200.61.128
-A KUBE-SERVICES -d 10.200.61.128/32 -p tcp -m comment --comment "haha/wordpress-svc cluster IP" -m tcp --dport 80 -j KUBE-SVC-JTMI3DYZIM6D5ZYY  # 通过这条看去到这个链
-A KUBE-SVC-JTMI3DYZIM6D5ZYY ! -s 10.100.0.0/16 -d 10.200.61.128/32 -p tcp -m comment --comment "haha/wordpress-svc cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
3. 查看去往的链 
iptables-save | grep KUBE-SVC-JTMI3DYZIM6D5ZYY
:KUBE-SVC-JTMI3DYZIM6D5ZYY - [0:0]
-A KUBE-NODEPORTS -p tcp -m comment --comment "haha/wordpress-svc" -m tcp --dport 30080 -j KUBE-SVC-JTMI3DYZIM6D5ZYY
-A KUBE-SERVICES -d 10.200.61.128/32 -p tcp -m comment --comment "haha/wordpress-svc cluster IP" -m tcp --dport 80 -j KUBE-SVC-JTMI3DYZIM6D5ZYY
-A KUBE-SVC-JTMI3DYZIM6D5ZYY ! -s 10.100.0.0/16 -d 10.200.61.128/32 -p tcp -m comment --comment "haha/wordpress-svc cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
-A KUBE-SVC-JTMI3DYZIM6D5ZYY -p tcp -m comment --comment "haha/wordpress-svc" -m tcp --dport 30080 -j KUBE-MARK-MASQ
-A KUBE-SVC-JTMI3DYZIM6D5ZYY -m comment --comment "haha/wordpress-svc" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-KQTOOYZ7OXINNODS # 通过这条看出有50%机率是去往这条链
-A KUBE-SVC-JTMI3DYZIM6D5ZYY -m comment --comment "haha/wordpress-svc" -j KUBE-SEP-6ECN3VOPG4GTUUTC
4. 再次查看得到结果，最终去向哪个pod
iptables-save | grep KUBE-SEP-KQTOOYZ7OXINNODS
:KUBE-SEP-KQTOOYZ7OXINNODS - [0:0]
-A KUBE-SEP-KQTOOYZ7OXINNODS -s 10.100.1.69/32 -m comment --comment "haha/wordpress-svc" -j KUBE-MARK-MASQ
-A KUBE-SEP-KQTOOYZ7OXINNODS -p tcp -m comment --comment "haha/wordpress-svc" -m tcp -j DNAT --to-destination 10.100.1.69:80  # 通过这条看出去到的指定pod
-A KUBE-SVC-JTMI3DYZIM6D5ZYY -m comment --comment "haha/wordpress-svc" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-KQTOOYZ7OXINNODS
5. 通过查看svc详情就可以确定对应关系了
kubectl -n haha  describe svc wordpress-svc 
Name:                     wordpress-svc
Namespace:                haha
Labels:                   <none>
Annotations:              <none>
Selector:                 app=wordpress1
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.200.61.128
IPs:                      10.200.61.128
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30080/TCP
Endpoints:                10.100.1.69:80,10.100.5.8:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

## 修改ipvs工作模式

```
(1)所有worker节点安装ipvs相关组件
yum -y install conntrack-tools ipvsadm.x86_64 

(2)编写加载ipvs的配置文件
cat > /etc/sysconfig/modules/ipvs.modules << EOF
#!/bin/bash

modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

(3)加载ipvs相关模块并查看
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

(4)修改kube-proxy的工作模式为ipvs
4.1仅需修改工作模式("mode")为ipvs即可。切记，一定要保存退出！
kubectl -n kube-system edit cm kube-proxy

4.2 验证是否修改成功
kubectl -n kube-system describe cm kube-proxy | grep mode
mode: "ipvs"

(5)删除旧的kube-proxy
kubectl get pods -A | grep kube-proxy | awk '{print $2}' | xargs kubectl -n kube-system delete pods 

(6)验证kube-proxy组件工作模式是否生效
6.1 查看日志
kubectl get pods -n haha
NAME                                READY   STATUS    RESTARTS   AGE
web-wordpress-demo-96f689cd-5tq2d   1/1     Running   0          19s
web-wordpress-demo-96f689cd-76wnd   1/1     Running   0          18s

kubectl -n kube-system logs kube-proxy-mdwsn
I0908 09:57:29.674805       1 node.go:163] Successfully retrieved node IP: 192.168.76.143
I0908 09:57:29.675633       1 server_others.go:138] "Detected node IP" address="192.168.76.143"
I0908 09:57:29.723743       1 server_others.go:269] "Using ipvs Proxier"
...

6.2 测试服务是否正常访问
curl -I http://192.168.76.143:30080

6.3 验证ipvs的工作模式，如下图所示。
kubectl get po,svc
kubectl -n haha get po,svc
NAME                                    READY   STATUS    RESTARTS   AGE
pod/web-wordpress-demo-96f689cd-5tq2d   1/1     Running   0          8m27s
pod/web-wordpress-demo-96f689cd-76wnd   1/1     Running   0          8m26s

NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/mysql-wordpress   ClusterIP      10.200.29.117   <none>        3306/TCP       5d8h
service/wordpress-svc     LoadBalancer   10.200.61.128   <pending>     80:30080/TCP   5d8h

ipvsadm -ln | grep 10.200.61.128 -A 3
TCP  10.200.61.128:80 rr
  -> 10.100.1.70:80               Masq    1      0          0         
  -> 10.100.5.9:80                Masq    1      0          0         
UDP  10.200.0.10:53 rr

温馨提示:
	在实际工作中，如果修改了kube-proxy服务时，若删除Pod，请逐个删除，不要批量删除哟！
```
