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

3. 启动服务 systemctl start elasticsearch

4. 查看集群健康状态 curl -X GET "http://127.0.0.1:9200/_cat/health?v"

5. 111

6. 111

7. 111

8. 111

9. 111

   

