# Promethous 监控系统

## 概念 https://www.bilibili.com/video/BV1PT4y1P7bX?p=3&spm_id_from=pageDriver

### 监控系统功能组件

1. 指标数据采集（抓取）
2. 指标数据存储
3. 指标数据趋势分析及可视化
4. 告警
   ![image-20220223154822338](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223154822338.png)

![image-20220223154920959](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223154920959.png)

![image-20220223160509705](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223160509705.png)

![image-20220223160611598](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223160611598.png)

![image-20220223161522848](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223161522848.png)

![image-20220223161536012](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223161536012.png)

![image-20220223161819647](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223161819647.png)

![image-20220223162836130](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223162836130.png)

![image-20220223163305045](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223163305045.png)

![image-20220223163803551](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223163803551.png)

![image-20220223163850135](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223163850135.png)

![image-20220223163909107](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223163909107.png)

![image-20220223164402268](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223164402268.png)

![image-20220223164419215](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223164419215.png)

![image-20220223203622868](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223203622868.png)

![image-20220223203726801](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223203726801.png)

![image-20220223203917873](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223203917873.png)

![image-20220223204122101](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223204122101.png)

![image-20220223204236878](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20220223204236878.png)

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

通过 /matrics输出指标数据

通过 label过滤

prometheus的关键就是构建表达式

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

