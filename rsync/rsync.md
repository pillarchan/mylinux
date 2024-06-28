# **1.** 备份服务概述

备份服务:需要使用到脚本,打包备份,定时任务.

备份服务:rsyncd服务,不同主机之间数据传输.

特点:

rsync是个服务也是命令.

使用方便,具有多种模式.

传输数据的时候是增量传输 .

增量与全量:

全量: 无论多少数据 全部 推送走(scp).

增量: 只会把 修改,新建 了的文件传输走(rsync)

| **应用场景****(****业务场景****)**              | **应用建议**                                               |
| ----------------------------------------------- | ---------------------------------------------------------- |
| rsync作为命令使用                               | 临时拉取,推送数据.未来这个需求可以通过scp命令实现.         |
| **定时备份****:rsync****服务****+****定时任务** | 定时备份,定期备份案例.(定时任务进行备份+通过rsync传输备份) |
| 实时同步:rsync服务+sersync/lsyncd实现实时同步   | 解决存储服务单点问题                                       |
| rsync服务与异地容灾                             | 找一个异地的服务器存放备份                                 |

rsync守护进程模式(daemon) 

传输数据(不需要密码),用于定时备份,定时同步.

# 2.rsync的安装部署

可以使用 yum仓库或apt仓库直接 install

# 3.rsync的模式

## 推与拉

```
推   rsync -avz /local/path/file romate_ip:/path/file
拉   rsync -avz  romate_ip:/path/file /local/path/file
```

## 本地模式

```
在rsync对于目录 /etc/ /etc 是有区别的.
/etc /etc目录+目录的内容
/etc/ /etc/目录下面的内容

rsync -a /etc/  /tmp/
rsync -a /etc  /opt/
```

## 远程模式

```
格式
rsync -a 源文件 目标
推送:rsync /etc/hostname root@10.0.0.31:/tmp
拉取:rsync root@10.0.0.31:/etc/hosts /opt/
```

## 守护进程模式:star:

### 部署

```
检查安装 更新
yum install -y rsync 
检查软件包内容
/etc/rsyncd.conf  #配置文件
/usr/bin/rsync    #命令
/usr/lib/systemd/system/rsyncd.service #systemctl对应的配置文件.
```

### 配置

```
服务端
/etc/rsyncd.conf

fake super =yes # 伪装root权限
uid = rsync # 用户 虚拟用户
gid = rsync
use chroot = no 
max connections = 2000 #最大连接数
timeout = 600 #连接超时
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock #进程/服务的锁文件，防止重复运行
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false  #关团rsync服务端列表功能
hosts allow = 10.0.0.0/24 #IP或网段白名单
hosts deny = 0.0.0.0/32 #IP或网段黑名单
auth users = rsync_backup #rsync服务端进行验证用户
secrets file = /etc/rsync.password #rsync用于验证的密码文件
#####################################
[data]
comment = #注释说明
path = /data 模块对应的目录


#1.添加虚拟用户
useradd  -s /sbin/nologin -M rsync
#2.创建密码文件
密码文件格式:   用户名:密码
echo 'rsync_backup:123 ' >/etc/rsync.password
chmod 600 /etc/rsync.password
#3.共享目录与权限
mkdir /data/
chown -R rsync:rsync /data
```

### 启动,使用

```
systemctl enable rsync --now

访问测试
rsync -avz /etc/hosts rsync_backup@192.168.76.163::data
```

### 免密访问

```
客户端
配置密码文件 echo "123" > /etc/rsync.password
与服务端密码文件中的密码一致即可
rsync -avz /etc/hosts rsync_backup@192.168.76.163::data --password-file=/etc/rsync.password
```

### 流程

```
1.用户执行命令:rsync -avz /tmp/etc.tar.gz rsync_backup@backup::data  --password-file=/etc/rsync.client
2.服务端收到数据:判断rsync_backup用户,然后等待输入密码
3.把用户名和密码与配置文件里面对比 auth user 和secrets file
4.通过后,传输数据
5.数据到达服务器所有者被修改为uid和gid指定的(rsync)
6.数据写入data模块(/data/)目录下面.
```

# 4.rsync命令选项

| rsync选项                     | 含义                                                         |
| ----------------------------- | ------------------------------------------------------------ |
| -a                            | -rlptgoD <br />-r 递归复制<br />-l 复制软连接<br />-p 保持权限不变<br />-m 保持修改时间不变<br />-o 拥有者不变<br />-g 用户组不变<br />-D --devices --specials 设备与特殊文件 |
| -v                            | 显示过程                                                     |
| -z                            | 传输数据的时候进行压缩(公网)                                 |
| -P                            | 显示每rsync -av . root@10.0.0.31:/tmp/ --ʔexclude=04<br />rsync -av . root@10.0.0.31:/mnt --exclude={04,05}个文件传输过程 (进度条) 断点续传 --partial --progress |
| --bwlimit                     | 限速,注意不要与-z一起使用.                                   |
| --exclude<br />--exclude-from | 排除<br />from 是从某个文件中的排除文件                      |
| --delete                      | 目标目录与源目录保持一致的传输(高度保持2遍一致,实时同步)     |

```
rsync -avP --bwlimit=512kb /backup/ rsync_backup@192.168.76.163::backup --exclude=0{5..9} --password-file=/etc/rsync.password


rsync -av --delete /backup/ rsync_backup@192.168.76.163::backup --password-file=/etc/rsync.password
```

优化

故障

自动化(监控,日志,安全,自动部署,容器)













rsync的工作原理





