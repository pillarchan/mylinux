# Promethous 监控系统

## 概念 https://www.bilibili.com/video/BV1PT4y1P7bX?p=3&spm_id_from=pageDriver

### 监控系统功能组件

1. 指标数据采集（抓取）
2. 指标数据存储
3. 指标数据趋势分析及可视化
4. 告警
   ![image-20220223154822338](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223154822338.png)

![image-20220223154920959](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223154920959.png)

![image-20220223160509705](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223160509705.png)

![image-20220223160611598](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223160611598.png)

![image-20220223161522848](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223161522848.png)

![image-20220223161536012](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223161536012.png)

![image-20220223161819647](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223161819647.png)

![image-20220223162836130](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223162836130.png)

![image-20220223163305045](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223163305045.png)

![image-20220223163803551](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223163803551.png)

![image-20220223163850135](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223163850135.png)

![image-20220223163909107](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223163909107.png)

![image-20220223164402268](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223164402268.png)

![image-20220223164419215](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223164419215.png)

![image-20220223203622868](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223203622868.png)

![image-20220223203726801](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223203726801.png)

![image-20220223203917873](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223203917873.png)

![image-20220223204122101](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223204122101.png)

![image-20220223204236878](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220223204236878.png)

## 安装

官网有详情

## 配置

主配置文件 prometheus.yml

关键配置项：

```
scrape_configs:
  - job_name: 'prometheus'
	static_configs:
	- targets: ['ip:port']
  - job_name: 'nodes'
    static.configs:
    - targets:
      - ip:port
      - ip:port
      - ip:port
```

## 应用

通过 /matrics 输出指标数据

通过 label 过滤

prometheus 的关键就是构建表达式

node_exporter 在监控的服务器上安装 即可

```
[Unit]
Description=node_exporter
Documentation=https://prometheus.io/
After=network.target
[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/bin/node_exporter\
	--collector.ntp\
	--collector.mountstats\
	--collector.systemd
	--collector.tcpstat
ExecReload=/bin/kill -HUP SMAINPID
TimeoutStopSec=20s
Restart=always
[Install]
WantedBy=multi-user.target
```

### PromQL 基础

cpu 利用率表达式 CPU 在 5 分钟内的平均利用率

```
(1-avg(irate(node_cpu_seconds_total{mode='idle'}[5m])) by (instance)) * 100
```

CPU 饱和度，跟踪 CPU 的平均负载就能获取到相关主机的 CPU 饱和度，实际上，它是将主机上的 CPU 数量考虑在内的一段时间内的平均运行队列长度

```
node_load1 > on(instance) 2*count(node_cpu_seconds_total{mode="idle"}) by (instance)
```

内存使用率 应该总量减少空闲之后再除以总量的百分比

```
node_memory_MemTotal_bytes
node_memory_MemFree_bytes
node_memory_Buffers_bytes
node_memory_Cached_bytes
```

Prometheus 时间序列

时间序列数据：按照时间顺序记录系统、设备状态变化的数据，每个数据称为一个样本;

![image-20220224084446905](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224084446905.png)

![image-20220224084853444](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224084853444.png)

![image-20220224084919935](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224084919935.png)

![image-20220224084953492](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224084953492.png)

![image-20220224085013950](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224085013950.png)

![image-20220224085134688](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224085134688.png)

![image-20220224085229198](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224085229198.png)

![image-20220224085448819](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224085448819.png)

![image-20220224090106449](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224090106449.png)

![image-20220224090321334](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224090321334.png)

![image-20220224095015928](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224095015928.png)

![image-20220224095205003](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224095205003.png)

![image-20220224100612521](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224100612521.png)

![image-20220224100845540](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224100845540.png)

![image-20220224101357231](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224101357231.png)

![image-20220224101304504](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224101304504.png)

![image-20220224101700249](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224101700249.png)

![image-20220224101937164](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224101937164.png)

### PromQL 进阶

![image-20220224102400886](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224102400886.png)

![image-20220224102454084](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224102454084.png)

![image-20220224102620468](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224102620468.png)

![image-20220224102859507](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224102859507.png)

![image-20220224103044047](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224103044047.png)

![image-20220224103131044](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224103131044.png)

![image-20220224103212451](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224103212451.png)

prometheus 配置中 targets 有两种配置方式

1. 基于静态，也就是 IP:PORT 的配置

2. 基于动态，也就是基于服务发现

3. 基于文件![image-20220224104605184](https://raw.githubusercontent.com/pillarchan/mylinux/master/promethous/image-20220224104605184.png)

   1. ```
        - job_name: "prometheus"
          file_sd_configs:
          - files:                        #指定要加载的文件列表
            - targets/prometheus*.yml     #文件加载支持glob通配符
            refresh_interval: 2m          #每隔2分钟重新加载一次文件中定义的Targets,默认是5m
        - job_name: "nodes"
        	file_sd_configs:
        	  - files:
        	    - targets/node*.yml
        	  refresh_interval: 2m


      目录为prometheus/xxx/targets/prometheus-servers.yml中则需要配置
      - targets:
        - 192.168.58.101:9000
        labels:
          app: prometheus
          job: prometheus
      ```

4. 基于 DNS 服务发现
   ![image-20220224132538526](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220224132538526.png)

5. 基于 consul 的服务发现

   ![image-20220224132707746](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220224132707746.png)

   配置文件

   ```
   /etc/consul/nodes.json
   {
   	"services":[
   		{
   			"id":"node-exporter-node01",
   			"name":"node01",
   			"address":"192.168.58.101",
   			"port":"9100",
   			"tags":["nodes"],
   			"checks": [{
   				"http": "http://192.168.58.101:9100/metrics",
   				"interval": "5s"
   			}]
   		},{
   			"id":"node-exporter-node02",
   			"name":"node01",
   			"address":"192.168.58.102",
   			"port":"9100",
   			"tags":["nodes"],
   			"checks": [{
   				"http": "http://192.168.58.102:9100/metrics",
   				"interval": "5s"
   			}]
   		},...
   	]
   }


   prometheus.yml
   scrape_configs:
     - job_name: "prometheus"
       consul_sd_configs:
       - server: "192.168.58.101:8500"
         tags:
         - "prometheus"
         refresh_interval: 2m
     - job_name: "nodes"
       consul_sd_configs:
       - server: "192.168.58.101:8500"
         tags:
         - "nodes"
         refresh_interval: 2m
   ```

6. 111111

7.
