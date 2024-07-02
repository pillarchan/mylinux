# 架构

```
server 服务端，提供监控服务
agent 客户端代理，用于采集监控数据，发送给服务端
web 前端页面，展示zabbix界面
db  数据端，存储配置与监控数据
```

# 安装

```
参考官方文档即可
https://www.zabbix.com/cn/download
```

# zbx显示中文乱码

```
/usr/share/zabbix/assets/fonts
graphfont.ttf  graphfont.ttf.bak
将原来的进行备份，拷贝一个新的如微软雅黑的字体，替换原有的如:mv msyh.ttc graphfont.ttf

debian系统需要安装中文包
apt install locales -y
dpkg-reconfigure locales
改写配置文件
vim /etc/default/locale
```

# 服务端配置

```
server端配置
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=0
PidFile=/run/zabbix/zabbix_server.pid
SocketDir=/run/zabbix
DBHost=192.168.76.163
DBName=zabbix
DBUser=zabbix
DBPassword=123456
DBPort=3306
SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
Timeout=4
FpingLocation=/usr/bin/fping
Fping6Location=/usr/bin/fping6
LogSlowQueries=3000
StatsAllowedIP=127.0.0.1
```

# 客户端配置

```
agent2配置
/etc/zabbix/zabbix_agent2.conf
PidFile=/var/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=192.168.76.162
ServerActive=192.168.76.162
Hostname=zabbixweb
Include=/etc/zabbix/zabbix_agent2.d/*.conf
PluginSocket=/run/zabbix/agent.plugin.sock
ControlSocket=/run/zabbix/agent.sock
Include=./zabbix_agent2.d/plugins.d/*.conf
```

# 模板使用

```
界面>配置->模板->进行一个全克隆->根据实际需求配置宏
界面>配置->主机->添加主机或者点击一台已存在的主机进行克隆->根据实际需求配置
```

# 自定义监控:star:

## 监控项

实际根据业务编写命令或脚本，然后界面调用

1.在要被监控的服务器上编写脚本

2.被监控的服务器 配置 /agent.d/

```
UserParameter=键名，命令或脚本
如：UserParameter=ngx.port,ss -tnl | grep -w 80 | wc -l
```

3.服务端测试键是否可用

```
zabbix_get -s 192.168.76.162 -k ngx.port -p 10050
```

4.页面操作

```
界面>配置->主机->监控项->创建监控项->名称->键名->更新间隔->历史数据保留时长->趋势存储时间->测试->获取值并进行测试
```

5.监控项传参

```
UserParameter=user.login[*],lastlog -u "$1" | awk 'NR==2 {print $$3}'
```

## 触发器

```
界面->配置->主机->触发器->创建触发器->名称->表达式->恢复表达式->是否允许手动关闭
```

## 自定义模板

```
界面->配置->模板->自定义模板->监控项->触发器->关联主机
```

