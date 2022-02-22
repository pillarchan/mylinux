# ELK日志系统

## 基础架构工作流程

filebeat -> kafka或redis -> logstash -> elasticsearth -> kibana

filebeat,logstash,elasticsearth,kibana版本需一致

## Filebeat

1. 用于收集日志的日志收割工具

2. 安装

   1. 官网查看对应版本，下载安装

      ```
      curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.13.2-x86_64.rpm
      yum install ./filebeat-7.13.2-x86_64.rpm -y
      ```

3. 配置安装测试

   1. /etc/filebeat/filebeat.yml

      1. filebeat.inputs

      2. filebeat.config.modules

      3. setup.template.setting

      4. processors

      5. output.console

         ```
         # ============================== Filebeat inputs ===============================
         filebeat.inputs:
         - type: log
           enabled: true
           paths: 
             - /tmp/*.log
         # ============================== Filebeat modules ==============================
         filebeat.config.modules:
           # Glob pattern for configuration loading
           path: ${path.config}/modules.d/*.yml
         
           # Set to true to enable config reloading
           reload.enabled: false    
         # ======================= Elasticsearch template setting =======================
         
         setup.template.settings:
           index.number_of_shards: 1
           #index.codec: best_compression
           #_source.enabled: false
         # ================================= Processors =================================
         processors:
           - add_host_metadata:
               when.not.contains.tags: forwarded
           - add_cloud_metadata: ~
           - add_docker_metadata: ~
           - add_kubernetes_metadata: ~
         
         output.console:
           pretty: true
         ```

4. 模块应用

   1. /etc/filebeat/modules.d 下有内置模块，需要应用可以开启，以nginx为例，直接修改nginx.yml.disable为nginx.yml,也可以使用命令filebeat modules enable nginx

   2. var.path 可以为多个日志文件，格式为数组 var.path: [/var/logs/access.log,/var/logs/error.log] 或 

      ```"
      var.path:
        - "/var/logs/access.log"
        - "/var/logs/error.log"
      ```

5. output

   1. output.console
   2. output.elasticsearch
   3. output.kafka
   4. output.logstash
      注：output的方式只能是一种

6. 重读日志文件 

   1. 如果遇到filebeat.lock的情况，杀掉进程，删掉filebeat/data/目录，重启服务即可

7. processor 增删字段或正则匹配到的行

   1. drop_fields: 
        fields: ["a","b","c"]
   2. add_fields:
        fields: 
          host_tag: "xxx"
   3. drop_event: 
        when: 
           regexp:
              message:"^aaa"

## Logstash

logstash 是免费且开放的服务器端数据处理管道，能够从多个来源采集数据，转换数据，然后将数据发送到您最喜欢的“存储库”中。

1. 安装

   ```
   wget https://artifacts.elastic.co/downloads/logstash/logstash-7.13.2-x86_64.rpm
   yum install ./logstash-7.13.2-x86_64.rpm -y
   ```

2. 配置

   1. 必需元素

      1. input
      2. output

   2. 可选元素

      1. filter

   3. 测试配置

      1. 命令行

         ```
         logstash -e ''
         等同于
         logstash -e input { stdin { type => stdin } } output { stdout { codec => rubydebug } }
         
         input { stdin { type => stdin } }表示要处理数据来源为标准设备
         output { stdout { codec => rubydebug } } 表示输出处理好的数据到标准设备
         ```

      2. 配置文件 执行logstash 需要使用参数 -f  配置文件路径

         ```
         需要手动创建，如XXXX.conf
         input{
         	stdin { }
         }
         output{
         	stdout { }
         }
         ```

      3. grok插件 是web日志信息过滤插件

         ```
         input {
         	file: path => ["/home/log/api.log"]
         	start_posting => "beginning"
         }
         filter {
         	grok {
         		match => { "message" => "%{COMBINEDAPACHELOG}" }
         	}
         }
         output{
         	{
         		stdout {}
         	}
         }
         ```

      4. mutate 在filter配置中，添加mutate对象，可以对字段名进行修改和删除

         ```
         input {
         	file: path => ["/home/log/api.log"]
         	start_posting => "beginning"
         }
         filter {
         	grok {
         		match => { "message" => "%{COMBINEDAPACHELOG}" }
         	}
         	mutate { # 重命名字段名
         		rename => { "clientip" => "cip" }
         	}
         	mutate { #去掉不想要的字段
         		remove_field => ["xx","xx","xx","xx"]
         	}
         }
         output{
         	{
         		stdout {}
         	}
         }
         ```

      5. geoip插件 用于显示ip的国家参数

         ```
         input {
         	file: path => ["/home/log/api.log"]
         	start_posting => "beginning"
         }
         filter {
         	grok {
         		match => { "message" => "%{COMBINEDAPACHELOG}" }
         	}
         	geoip { source => "clientip" }
         	mutate { # 重命名字段名
         		rename => { "clientip" => "cip" }
         	}
         	mutate { # 去掉不想要的字段
         		remove_field => ["xx","xx","xx","xx"]
         	}
         }
         output{
         	{
         		stdout {}
         	}
         }
         ```

      6. beats 收集filebeat所发出的日志

         ```
         input {
         	beats {
         		port =>5044
         	}
         }
         filter {
         	grok {
         		match => { "message" => "%{COMBINEDAPACHELOG}" }
         	}
         	#geoip { source => "clientip" }
         	#mutate { # 重命名字段名
         	#	rename => { "clientip" => "cip" }
         	#}
         	#mutate { # 去掉不想要的字段
         	#	remove_field => #["xx","xx","xx","xx"]
         #	}
         }
         output{
         	{
         		stdout {}
         	}
         }
         ```

         filebeat配置中需要配置output.logstash

         ```
         output.logstash:
           hosts: ["127.0.0.1:5044"]
         ```

## Elasticsearch

1. 安装

   1. 引入gpg-key

      ```
      rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
      ```

   2. 添加yum 配置文件

      ```
      [elasticsearch]
      name=Elasticsearch repository for 7.x packages
      baseurl=https://artifacts.elastic.co/packages/7.x/yum
      gpgcheck=1
      gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
      enabled=0
      autorefresh=1
      type=rpm-md
      ```

   3. 添加可用repo

      ```
      sudo yum install --enablerepo=elasticsearch elasticsearch
      ```
      
   3. 使用yum安装

      ```
      yum list --showduplicates elasticsearch #查看版本
      yum install elasticsearch-版本号 -y
      ```

2. 配置 elasticsearch.yml

   ```
   cluster.name:  集群名
   node.name: 节点名   注意需要在hosts中配置对应的解析
   node.data: true
   path.data: 数据路径
   path.logs: 日志路径
   network.host: 0.0.0.0 #对外服务的IP
   http.port: 9200  #对外服务的端口
   discovery.seed_hosts: ["ip:port","ip","domain"]
   cluster.initial_master_nodes: ["node1", "node2"] #需要初始集群的节点
   http.cors.enabled: true #支持跨域
   http.cors.allow-origin: "*"
   ```

3. 系统配置

   ```
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

3. 启动服务 systemctl start elasticsearch

4. 查看集群健康状态 curl -X GET "http://127.0.0.1:9200/_cat/health?v"

6. 测试集群

   logstash 中配置 output

   ```
   output {
   	stdout{
   		codec => rubydebug
   	}
   	elasticsearch {
   		hosts => ["ip:port","",""]
   	}
   }
   ```

7. 验证索引

   ```
   curl -X GET http://127.0.0.1:9200/_cat/indicies
   ```

8. 增加索引

   ```
   output {
   	stdout {
   		codec => rubydebug
   	}
   	#这只一个示例，还有其它变量如：fields logtype等需查询手册
   	if [log][file][path] == "/home/log/app.log" {
   		elasticsearch {
    			hosts => ["ip:port","ip:port"]
   			index => "%{[host][hostname]}-nginx-access-%{+YY-MM-dd}"
   		}
   	}
   }
   ```

## Kibana

1. 安装

   1. 引入gpg-key

      ```
      rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
      ```

   2. 添加yum 配置文件

      ```
      [elasticsearch]
      name=Elasticsearch repository for 7.x packages
      baseurl=https://artifacts.elastic.co/packages/7.x/yum
      gpgcheck=1
      gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
      enabled=0
      autorefresh=1
      type=rpm-md
      ```

   3. 添加可用repo

      ```
      sudo yum install --enablerepo=elasticsearch elasticsearch
      ```

   4. 使用yum安装

      ```
      yum list --showduplicates kibana #查看版本
      yum install kibana-版本号 -y
      ```

2. 配置

   1. kibana.yml

   2. ```
      server.host: 0.0.0.0
      server.port: 5601
      elaticsearch.hosts: ["http://ip:port"]
      logging.dest: /kibana/log/path
      i18n.local: zh-CN
      ```

3. kibana页面配置

   1. 索引配置 menu->managerment->Stack managerment-->索引模式->创建索引模式
   2. 索引来源就是logstash中output索引的配置项

## Kafka

1. 概念：数据缓冲队列，提高了可扩展性，具有峰值处理能力。是一个分布式，支持分区的、多副本的，基于zookeeper协调的分布式消息系统，特性为高吞吐量，可扩展性，可靠性，容错性，高并发

2. 基础名词

   1. topic 特定类型的消息流
   2. producer 发布消息到话题的任何对象
   3. comsumer 订阅一个或多个话题，从而消费这些已发布的话题
   4. Broker 已发布的消息保存在一组服务器中
   5. partition 每个topic 包含一个或多个partition
   6. replicatoin partition的副本，保障partition的高可用
   7. leader replica 中的一个角色，producer和consumer 只限leader交互
   8. follower replica 中的一个角色，从leader中复制数据
   9. zookeeper kafka通过zookeeper来存储集群的信息，zookeeper是一个分布式协调服务，它的主要作用为分布式系统提供一致性服务，功能包括:配置维护、分布式同步等。

3. 安装

   1. kafka依赖于zookeeper，zookeeper又依赖于java，所以首先安装java环境
   2. 通过yum直接安装java即可
   3. zookeeper 安装
      1. yum 安装
   4. kafka 安装

4. 配置

   1. zookeeper

      ```
      dataDir    #zk数据存放目录
      dataLogDir #zk日志存放目录
      clientPort #客户端连接zk服务的端口
      tickTime   #心跳检测间隔时长
      initLimit  #允许follower连接并同步到Leader的初始化连接时长，超过值则连接失败
      syncLimit  #Leader与Follower之前发送消息时如果在设置时间内不能通信，则follower将会被丢弃
      #server如果有多台则配置多台，如server.2 ...
      server.1=192.168.19.1:2888:3888  #2888是follower与leader交换信息的端口，3888是当leader挂了时用来执行选举服务器相互通信的端口
      
      
      #每个节点需配置不同的ID，路径是zk的dirData的路径
      
      echo 1 > /zk/dirData/path/myid
      ```

   2. kafka

      ```
      broker.id 每一个broker集群中的唯一标识，要求是正数。在改变IP地址，不改变broker.id时不会影响consumers 
      listeners=PLAINTTEXT://192.168.19.1:9092 监听地址
      num.network.threads			broker处理消息的最大线路数据，一般不修改
      num.io.threads 			    broker处理磁盘IO的线程数，数值应大于硬盘数
      socket.send.buffer.bytes	socket的发送缓冲区
      socket.receive.buffer.bytes  socket的接收缓冲区
      socket.request.max.bytes	 socket请求的最大数值，防止serverOOM,message.max.bytes必然要小于socket.request.max.bytes,会被topic创建时的指定参数覆盖
      log.dirs	日志文件目录
      num.partitions  数据分片
      num.reconvery.threads.per.data.dir	线程池分匹配多少线程数处理每个分区日志
      用于元数据内部话题消费偏移量和传输状态的副本数量
      offsets.topic.replication.factor=1
      transaction.state.log.replicateion.factor=1
      transactoin.state.log.min.isr=1
      log.cleanup.policy  日志清理策略
      log.retentoin.hours  数据存储时长
      log.segment.bytes	日志数据段长度
      log.retention.check.interval.ms  日志校验时长
      zookeeper.connect 连接zookeeper集群逗号分隔，格式ip:port
      zookeeper.connection.timeout.ms  连接超时时长
      group.initial.rebalance.delay.ms 消费组初始延迟
      ```

5. 验证测试

   1. 启动zookeeper

      ```
      nohup bin/zookeeper-server-start.sh config/zookeeper.properties &
      ```

   2. 启动kafka

      ```
      nohup bin/kafka-server-start.sh config/server.properties &
      ```

   3. 创建话题

      ```
      bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1
      --topic testtopic
      
      bin/kafka-topics.sh --zookeeper 192.168.1.1:2181 --list
      
      bin/kafka-console-producer.sh --broker-list 192.168.1.1:9092 --topic testtopic
      bin/kafka-console-consumer.sh --bootstrap-server 192.168.1.1:9092 --topic testtopic --from-beginning
      ```

6. filebeat kafka配置

   1. ```
      output.kafka:
      # 将日志传递给kafka集群
        hosts: ["192.168.1.1:9092", "192.168.1.2:9092", "192.168.1.2:9092"]
      # kafka topic
        topic: 'testtopic'
        partition.round_robin:
          reachable_only: false
        required_acks: 1
        compression: gzip
        max_message_bytes: 1000000
      ```

      
