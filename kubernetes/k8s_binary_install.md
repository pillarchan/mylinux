# 架构

## Master(Controll Panel)

### 组件：

api-server

etcd

manager-controler

scheduler

## Slave(Worker)

kubelet

kubeproxy

https://landscape.cncf.io



# 机器

| 名称         | IP             |
| ------------ | -------------- |
| master_node1 | 192.168.76.140 |
| master_node2 | 192.168.76.141 |
| master_node3 | 192.168.76.142 |
| worker_node1 | 192.168.76.143 |
| worker_node2 | 192.168.76.144 |

# 预安装的软件

yum -y install bind-utils expect rsync wget jq psmisc vim net-tools telnet yum-utils device-mapperr-persistent-data lvm2 git ntpdate

# 机器解析

每个节点

192.168.76.140 centos9master_node1
192.168.76.141 centos9master_node2
192.168.76.142 centos9master_node3
192.168.76.143 centos9worker_node1
192.168.76.144 centos9worker_node2

# 免密登录

ssh-keygen -t rsa -P "" -f /path/name_rsa -q

