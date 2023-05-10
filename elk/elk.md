[:house: 主页](readme.md)

### 目录

- [节点说明](#节点说明)
- [Yum 配置](#yum配置)
- [系统配置](#系统配置)
- [Kafka&ZK 集群部署](#kafkazk集群部署)
- [Elasticsearch 安装与配置](#elasticsearch安装与配置)
- [Kibana 安装配置](#kibana安装配置)
- [X-pack 白金许可证破解](#x-pack白金许可证破解)

---

#### 节点说明

- [返回目录 :leftwards_arrow_with_hook:](#目录)

| 外网 IP        | 内网 IP       | HOSTNAME          | SOFTWARE                |
| -------------- | ------------- | ----------------- | ----------------------- |
| 202.60.235.156 | 192.168.1.27  | elk1.stack kafka1 | ES、kafka、zk           |
| 58.82.246.211  | 192.168.1.112 | elk2.stack kafka2 | ES、logstash、kafka、zk |
| 103.41.126.138 | 192.168.1.58  | elk3.stack kafka3 | ES、kibana、kafka、zk   |

---

#### Yum 配置

- [返回目录 :leftwards_arrow_with_hook:](#目录)

**elk-stack** yum 文件: **elk.repo**

```ini
[elk-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

**zookeeper** yum 文件: **mesosphere.repo**

```ini
[mesosphere]
name=Mesosphere Packages for EL 7 - $basearch
baseurl=http://repos.mesosphere.io/el/7/$basearch/
enabled=1
gpgcheck=0
[mesosphere-noarch]
name=Mesosphere Packages for EL 7 - noarch
baseurl=http://repos.mesosphere.io/el/7/noarch/
enabled=1
gpgcheck=0

[mesosphere-source]
name=Mesosphere Packages for EL 7 - $basearch - Source
baseurl=http://repos.mesosphere.io/el/7/SRPMS/
enabled=0
gpgcheck=0
```

**安装 epel yum 源，并更新系统**

```shell
yum install epel-release -y
yum clean all
yum makecache
yum update -y
```

**JDK 安装**

```shell
yum install java-1.8.0-openjdk -y
```

---

#### 系统配置

- [返回目录 :leftwards_arrow_with_hook:](#目录)

```shell
vim /etc/security/limits.conf
* hard nofile 65536
* soft nofile 65536
* soft nproc  65536
* hard nproc  65536

ulimit -n 65535

vim /etc/sysctl.conf
vm.max_map_count = 262144
net.core.somaxconn=65535
net.ipv4.ip_forward = 1

sysctl -p

swapoff -a
```

---

#### Kafka&ZK 集群部署

- [返回目录 :leftwards_arrow_with_hook:](#目录)

**安装配置 zookeeper 集群**

```shell
# 安装zk
yum install mesosphere-zookeeper -y

# 修改配置
vim /etc/zookeeper/conf/zoo.cfg
maxClientCnxns=50
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/var/lib/zookeeper
clientPort=2181
server.1=kafka1:2888:3888
server.2=kafka2:2888:3888
server.3=kafka3:2888:3888

# 每个节点设置不同的id
kafka1# echo 1 > /var/lib/zookeeper/myid
kafka2# echo 2 > /var/lib/zookeeper/myid
kafka3# echo 3 > /var/lib/zookeeper/myid

# 设置开机启动 启动服务
systemctl enable zookeeper
systemctl start zookeeper

# 查看端口监听
lsof -i:2181
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
java    2017 root   23u  IPv6  22946      0t0  TCP *:eforward (LISTEN)
```

**安装配置 kafka 集群**

```shell
#下载安装
cd /opt
wget http://mirror.rise.ph/apache/kafka/2.4.0/kafka_2.12-2.4.0.tgz && mv
tar xvf kafka_2.12-2.4.0.tgz && mv kafka_2.12-2.4.0 kafka && cd kafka

# 修改配置
vim config/server.properties
broker.id=1  # 节点间的数字不一样即可
listeners=PLAINTEXT://202.60.235.156:9092 # IP为本机IP
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/opt/kafka/logs/kafka-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=kafka1:2181,kafka2:2181,kafka3:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0

# 启动服务
./bin/kafka-server-start.sh -daemon /opt/kafka/config/server.properties

# 查看服务
lsof -i:9092
COMMAND    PID USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
filebeat 25779 root    6u  IPv4 8517817      0t0  TCP elk1.stack:41220->elk1.stack:XmlIpcRegSvc (ESTABLISHED)
java     31778 root  121u  IPv6 8515337      0t0  TCP elk1.stack:XmlIpcRegSvc (LISTEN)
java     31778 root  137u  IPv6 8518920      0t0  TCP elk1.stack:41214->elk1.stack:XmlIpcRegSvc (ESTABLISHED)
java     31778 root  138u  IPv6 8511083      0t0  TCP elk1.stack:XmlIpcRegSvc->elk1.stack:41214 (ESTABLISHED)
java     31778 root  142u  IPv6 8520966      0t0  TCP elk1.stack:47010->elk3.stack:XmlIpcRegSvc (ESTABLISHED)
java     31778 root  146u  IPv6 8517806      0t0  TCP elk1.stack:57336->elk2.stack:XmlIpcRegSvc (ESTABLISHED)
java     31778 root  202u  IPv6 8511093      0t0  TCP elk1.stack:XmlIpcRegSvc->58.82.247.197:52590 (ESTABLISHED)
java     31778 root  203u  IPv6 8518953      0t0  TCP elk1.stack:XmlIpcRegSvc->elk1.stack:41220 (ESTABLISHED)
```

---

#### Elasticsearch 安装与配置

- [返回目录 :leftwards_arrow_with_hook:](#目录)

**安装 elasticsearch**

```shell
yum install elasticsearch -y

systemctl enable elasticsearch.service

mkdir /home/elasticsearch

chown elasticsearch:elasticsearch /home/elasticsearch/
```

**修改 JVM 堆大小为内存的一半**

```she
vim /etc/elasticsearch/jvm.options
-Xms8g
-Xmx8g
```

**增加 systemctl 配置**

```shell
vim /usr/lib/systemd/system/elasticsearch.service
```

```ini
[Service]
LimitMEMLOCK=infinity
```

```shell
# 重新载入
systemctl daemon-reload
```

**修改 Elasticsearch 配置**

```yaml
## 节点1 ##
# 集群名称，多集群节点依据相同名称自动加入到集群
cluster.name: elk-stack
# 节点名称，同一个集群中的每个节点名称不能一样
node.name: elk1.stack
# 是否为主节点，选项为true或false，当为true时在集群启动时该节点为主节点，在宕机或任务挂掉之后会选举新的主节点，恢复后该节点依然为主节点
node.master: true
# 是否为数据节点，选项为true或false。负责数据的相关操作
node.data: true
# 数据存储路径
path.data: /home/elasticsearch
# 日志存储路径
path.logs: /var/log/elasticsearch
# 内存锁
bootstrap.memory_lock: true
# 服务暴露的IP
network.host: 192.168.1.27
# 服务监听端口
http.port: 9200
# 发现集群的节点
discovery.seed_hosts: ["192.168.1.27", "192.168.1.112", "192.168.1.58"]
# 集群初始化时master节点
cluster.initial_master_nodes: ["elk1.stack"]
gateway.recover_after_nodes: 1
action.destructive_requires_name: true
# 支持跨域访问
http.cors.enabled: true
http.cors.allow-origin: "*"
```

**启动服务，查看集群状态**

```shell
curl 192.168.1.58:9200/_cat/health
1582011786 07:43:06 elk-stack green 3 3 0 0 0 0 0 0 - 100.0%
```

返回`green`表示集群正常

---

#### Kibana 安装配置

- [返回目录 :leftwards_arrow_with_hook:](#目录)

```shell
# 安装kibana
yum install kibana -y
systemctl enable kibana

# 修改配置
vim /etc/kibana/kibana.yml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts:
  - "http://192.168.1.27:9200"
  - "http://192.168.1.112:9200"
  - "http://192.168.1.58:9200"
kibana.index: ".kibana"
i18n.locale: "zh-CN"

# 启动
systemctl start kibana.service
```

---

#### X-pack 白金许可证破解

- [返回目录 :leftwards_arrow_with_hook:](#目录)

**ES 配置**

```shell
# ES生成证书
/usr/share/elasticsearch/bin/elasticsearch-certutil ca
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12

# 设置证书文件的权限
chgrp elasticsearch /usr/share/elasticsearch/elastic-certificates.p12 /usr/share/elasticsearch/elastic-stack-ca.p12

chmod 640 /usr/share/elasticsearch/elastic-certificates.p12 /usr/share/elasticsearch/elastic-stack-ca.p12

# 移动到ES配置目录，把证书文件复制到其他master节点并赋予相关的权限。
mv /usr/share/elasticsearch/elastic-* /etc/elasticsearch/

# 三台服务器都要操作
# ES增加配置
xpack.security.enabled: false
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: /etc/elasticsearch/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: /etc/elasticsearch/elastic-certificates.p12

# 复制破解后的X-pack包到ES模块目录
cp /root/x-pack-core-7.6.0.jar /usr/share/elasticsearch/modules/x-pack-core/

# 重启整个ES集群
systemctl restart elasticsearch.service

# 上传许可证信息到集群
curl -XPUT -u elastic 'http://192.168.1.27:9200/_xpack/license' -H "Content-Type: application/json" -d @license.json

# 修改ES配置然后重启集群
xpack.security.enabled: true

# 生成用户密码
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto
PASSWORD apm_system = GP5ab69FQUZXBXXr5gG9
PASSWORD kibana = 1DKGjq2DX5sGlORgEVTQ
PASSWORD logstash_system = aGkcCh2gqNa9MOoeNbTO
PASSWORD beats_system = HxyjDTdvgrgH0iIIbUWH
PASSWORD remote_monitoring_user = VRI4kHYjmlVMI8CWFTDu
# elastic 是整个elk-stack 管理员账号密码
PASSWORD elastic = hD7uPvigYS3y6ceuQiFy
```

- 下载
  - [:arrow_double_down: x-pack-core-7.6.0.jar](http://192.168.3.153:9980/xyang/yunwen-docs/raw/master/download/x-pack-core-7.6.0.jar)
  - [:arrow_double_down: license.json](download/license.json)

```shell
# 验证许可证状态 active 表示激活， 过期时间 "expiry_date" : "2049-12-31T16:00:00.999Z"**
curl -XGET -u elastic:hD7uPvigYS3y6ceuQiFy http://192.168.1.27:9200/_license
```

```json
{
  "license" : {
    "status" : "active",
    "uid" : "537c5c48-c1dd-43ea-ab69-68d209d80c32",
    "type" : "platinum",
    "issue_date" : "2019-05-17T00:00:00.000Z",
    "issue_date_in_millis" : 1558051200000,
    "expiry_date" : "2049-12-31T16:00:00.999Z",
    "expiry_date_in_millis" : 2524579200999,
    "max_nodes" : 1000,
    "issued_to" : "pyker",
    "issuer" : "Web Form",
    "start_date_in_millis" : 1558051200000
  }
```

**Kibana 配置**

```shell
# 配置kibana使用账密登录
vim /etc/kibana/kibana.yml
elasticsearch.username: "elastic"
elasticsearch.password: "hD7uPvigYS3y6ceuQiFy"

# 重启kibana 再次登录需要输入账号密码
systemctl restart kibana
```

![image-20200218165654489](./image/image-20200218165654489.png)

**成功登录后，查看证书状态**

![image-20200218165816837](./image/image-20200218165816837.png)
