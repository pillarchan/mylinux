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

