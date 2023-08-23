# zookeeper

## 1.概念

1. 什么是zookeeper

   ```
   	zookeeper是一个分布式数据一致性解决方案，致力于为分布式应用提供一个高性能，高可用，且具有严格顺序访问控制能力的分布式协调存储服务。    
   	
   	zookeeper包括但不限于以下几点的应用场景:        
   		(1)维护配置信息;        
   		(2)分布式锁服务;        
   		(3)集群管理;        
   		(4)生成分布式唯一ID;        
   		(5)配置中心案例;
   		
   	温馨提示:        
   		zookeeper适用于存储和协同相关的关键数据，不适合用于存储大数据量存储。
   ```

2. zookeeper的由来

   ```
        zookeeper由雅虎(Yahoo!)研究院开发，它是一个开源的分布式的协同服务系统，为分布式应用提供协调服务的Apache项目。            zookeeper的设计目标是将那些复杂且容易出错的分布式系统服务封装起来，抽象出一个高效可靠的原语集，并以一系列简单的接口提供给用户使用。        大数据生态系统里的很多组件的命名都是某个动物或者昆虫，比如Hadoop是大象，hive是蜜蜂，zookeeper是动物管理员，顾名思义就是管理大数据生态系统各组件的管理员。        官网地址:                https://zookeeper.apache.org/
   ```

3. 发展历史

   ```
   	zookeeper最早起源于雅虎(Yahoo!)研究院的一个研究小组。在当时，研究人员发现，在雅虎内部很多软件系统都需要依赖一个系统来进行协同。但是这样的协调往往都存在单点问题。所以，雅虎的开发人员就开发了一个通用的无单点问题的分布式协同服务系统，这就是zookeeper。
   	
   	借鉴Google Chubby(该软件并非开源)的设计思想开发了zookeeper，并将其开源。后来托管到Apache，于2010年11月正式成为Apache的顶级项目。    
   	
   	zookeeper之后在开源界被大量使用，下面列出了3个著名开源项目是如何使用zookeeper:        
   		Hadoop:
   			使用zookeeper做HDFS的nameNode的高可用和YARN组件的resourcemanager的高可用。
   			
   		HBase:
   			保证集群中只有一个master，保存集群中的RegionServer列表，保存hbase:mete表的位置。        
   		Kafka:
   			集群成员管理，controlller节点选举，包括partition的leader状态保存。
   			
   	温馨提示:
   		zookeeper和etcd有着类似的功能，但在java领域中最常用的依旧是zookeeper，而在Go领域中，常用的是etcd，比如Kubernetes的各种组件就用它存储数据。
   ```


## 2.安装配置

1. 环境与工具

   1. java-jdk zookeeper

2. 安装
   1. java-jdk 使用yum或二进制包进行安装,视操作系统而定，使用二进制包需要配置环境变量家目录
   2. zookeeper 二进

3. 配置/zookeeper/conf/zoo.cfg文件，需创建，通过cp zoo_sample.cfg创建

   ```
   [root@zookeeper ~]# cd /opt/software/zookeeper/conf
   [root@zookeeper conf]# ls
   configuration.xsl  logback.xml  zoo.cfg  zoo_sample.cfg
   ```

## 3.常用命令

1. create 创建znode

   ```
   create -e 创建临时znode
   create -s 创建有编号的znode
   
   临时znode 会在客户端和服务器连接断开自动清除
   ```

2. 查看znode

   ```
   使用ls命令查看某个znode下的子znode信息，常用选项如下:
   -w:	启用监听器watch功能。
   -s:	查看stat命令的相关信息且查看给定znode路径的子节点信息。
   -R:	对查看znode且查看给定znode路径的子节点信息。
   
   使用get命令可以查看znode中存储的数据。
   -s:	查看stat命令的相关信息。
   -w:	启用监听器watch功能。
   
   使用stat命令可以查看znode的元数据信息。
   cZxid:数据节点创建时的事物ID。
   ctime:数据节点创建时的时间。
   mZxid:数据节点最后一次更新时的事物ID。        
   mtime:数据节点最后一次更新时的时间。        
   pZxid:数据节点的子节点最后一次被修改时的事务ID。        
   cversion:子节点的更改次数。        
   dataVersion:数据节点的更改次数，即维护的是一个数据版本号。
   aclVersion:节点的ACL的更改次数。        
   ephemeralOwner:如果节点是临时节点，则表示创建该节点的会话SessionID，如果节点是持久节点，则该属性值为0。        
   dataLength:数据内容的长度。        
   numChildren:数据节点当前的子节点的数量。
   
   (1)直接在命令行输入"ls"，"get"指令就可以看到其对应的帮助信息
   (2)比较老的版本还在用"ls2"命令查看，zookeeper 3.7版本中已将其移除      
   ```

3. 修改znode

   ```
   zookeeper使用set命令修改znode数据，常用命令选项如下所示:
   -s:修改数据后，返回znode的stat信息。  	
   -v:修改数据时可以指定子节点更改的次数版本("dataVersion")，这和ES的乐观锁机制有点类似 
   ```

   

4. 删除znode

   ```
   zookeeper使用delete命令删除znode，要求该znode没有子znode节点。
   zookeeper使用deleteall命令删除包含子znode节点，生产环境中慎用，有点类似于linux的"rm -rf"指令。
   
   ```

## 4.监听命令

1. ls -w 监听一次指定znode的变化
2. get -w 监听一次指定znode的数据变化
3. stat -w 监听一次指定znode的数据变化
4. 删除监听 removewatches /znode

## 5.zookeeper集群部署

1. 单机环境、工具、配置同样部署多台即可

2. 集群的配置

   1. 同步时间 ntpdate ntp.aliyun.com
   2. 配置cron 定期同步
   3. 配置免密登录
   4. 创建zookeeper的数据目录，都要
   5. 禁用selinux
   6. 禁用firewalld

3. 修改zookeeper配置文件

   1. ```
      server.id=ip/hostname:leader选举端口:数据传送端口
      如：
      server.111=192.168.76.111:2888:3888
      server.112=192.168.76.112:2888:3888
      server.113=192.168.76.113:2888:3888
      leader 可读写
      follow 可读
      可以理解为主从
      ```

   2. 生成myid文件，在zookeeper的数据目录下生成，配置的是哪个目录就在哪个目录下生成

      ```
      for (( i=111;i<=113;i++))do ssh 192.168.76.${i} "install -d /tmp/zookeeper;echo $i > /tmp/zookeeper/myid";done
      ```

4. 集群启动

   ```
   使用脚本/ansible，将每台的zookeeper服务启动，
   ```

5. 集群登录

   ```
   使用leader机，zkCli.sh -server ip1:port1,ip2:port2,ip3:port3...
   ```

6. 测试集群

   ```
   手动停掉其中一台，在客户端上查看监控信息
   ```

## 6.Observer配置

1. 配置

   ```
   将集群配置的末尾加 :observer 即可，需要重启服务
   ```

2. 配置的目的

   ```
   obServer(观察者):
   		可以接收客户端连接，将写请求转发给leader节点。这是集群的可选组件。
   		但obServer不参加投票过程，只同步leader的状态。obServer的目的是为了扩展系统，提高读取速度。
   ```

## 7.ACL权限

1. 格式

   ```
   scheme:id:permisson
   1. scheme：策略
   2. id：对象
   3. permisson：权限
   ```

2. 策略模式 scheme

   ```
   world:只有一个用户，即"anyone"，代表登录zookeeper的所有人，这也是默认的权限模式。
   ip:对客户端使用IP地址认证。
   auth:使用已添加认证的用户认证。
   digest:使用"用户名:密码"方式进行认证。
   ```

3. 对象 id

   ```
   给谁授予权限，授权对象ID是指权限赋予的实体，例如: IP地址或用户。
   ```

4. 权限 permission

   ```
   create(简写"c"):表示可以创建子节点。
   delete(简称"d"):可以删除子节点。
   read(简称"r"):可以读取节点数据及显示子节点列表。
   write(简称"w"):可以修改节点数据。
   admin(简称"a"):可以设置节点访问控制列表权限。
   ```

5. 误删 admin 权限恢复方式

   ```
   配置 zookeeper/conf/zoo.cfg  添加skipACL=yes
   需要重启服务，修改权限后，尽快改回配置并重启服务
   ```

### 	基于world,ip,auth

1. world设置与查看

   ```
   setAcl /znode scheme:id:permisson 如: setAcl /mytest world:anyone:cwrda
   
   getAcl /znode
   ```

2. ip设置与查看

   ```
   setAcl /znode ip:address:permisson 如: setAcl /mytest ip:192.168.76.111:cra
   
   getAcl /znode
   可以使用多ip或IP段，设置后需使用 zkCli.sh -server ip 的方式来登录客户端，对IP设置权限，就说明是只有那个IP才有设置的那些权限
   ```

3. auth设置与查看

   ```
   addauth digest username:password
   setAcl /znode auth:username:permisson 
   如: 
   addauth digest admin:myman123
   setAcl /kafka auth:myman123:crwda
   
   getAcl /znode
   ```

4. digest设置与查看

   ```
   使用openssl sha1创建加密密码
   echo -n username:password | openssl dgst -binary -sha1 | openssl base64
   
   setAcl /znode digest:username:cryptpassword:permission
   如：
   setAcl /kafka digest:admin:Tmbbt77KcTd1bAgjQaI+GqI0hjM=:cdrwa
   ```

   

### 	混合权限

```
setAcl /znode ip:ipad:permisson,auth:username:permisson,digest:username:cryptpassword:permission

设置混合权限，以逗号分隔
```



### 	超管

1. 使用sha1加密算法

   ```
   echo -n username:password | openssl dgst -binary sha1| openssl base64
   ```

2. 修改zookeeper服务端的环境变量，添加超管

   ```
   /zookeeper/bin/zkEnv.sh
   
   SERVER_JVMFLAGS中添加，将SERVER_JVMFLAGS的值改为如下代码，username:cryptpassword的值改为相对应的值
   export SERVER_JVMFLAGS="-Dzookeeper.DigestAuthenticationProvider.superDigest=username:cryptpassword -Xmx${ZK_SERVER_HEAP}m $SERVER_JVMFLAGS"
   ```

3. 所有节点都要操作，然后重启服务


## 8.四字监控命令

1. zookeeper常用四字命令

   ```
   zookeeper支持某些特定的四字命令与其的交互。它们大多是查询命令，用来获取zookeeper服务的当前状态及相关信息。用户在客户端可以通过telnet或者nc向zookeeper提交相应的命令。
   
   zookeeper常用四字命令如下所示:
   conf:输出相关服务配置的详细信息。比如端口，zookeeper数据及日志配置路径，最大连接数，session超时时间，serverId等。
   ruok:测试服务是否处于正确运行状态，如果回复的不是"imok"，那就说明该节点挂掉啦！注意观察输出结果哟！
   envi:输出关于服务器的环境变量。
   cons:列出所有连接到这台服务器的客户端连接/会话的详细信息。包括"接收/发送"的包数量，session id，操作延迟，最后的操作执行等信息。
   dump:列出未经处理的会话和临时节点。打印集群的所有会话信息，包括ID，以及临时节点等信息。用在Leader节点上才有效果。
   stat:输出服务器的详细信息，接收/发送包数量，连接数，模式(leader/follower)，节点总数，延迟。所有客户端的列表。查看统计信息，一般用来查看哪个节点被选择作为follower或者leader。
   srvr:和stat输出信息一样，只不过少了客户端连接信息。
   mntr:输出比stat更为详细的服务器统计信息。列出集群的健康状态。
   wchs:列出服务器watches的简洁信息，如连接总数，watching节点总数和watches总数。
   wchc:通过session分组，列出watch的所有节点，它的输出是一个与watch相关的会话的节点列表。
   wchp:通过路径列出服务器watch的详细信息。它输出一个与session相关的路径。
   reqs:查看未经处理的请求。
   crst:重置当前这台服务器所有连接/会话的统计信息。
   srst:重置server状态。
   ```

2. 使用工具 nc telnet 需要安装

3. 基于nc查看zookeeper集群的状态信息

   ```
   [root@zookeeper ~]# echo ruok | nc 192.168.76.111 2181
   ruok is not executed because it is not in the whitelist.
   ```

4. 报错未添加白名单，在 zookeeper/conf/zoo.cfg添加配置

   ```
   4lw.commands.whitelist=*
   ```


## 9.图形化工具

1. ZooInspector 运行环境java1.8 
   运行jar包  \ZooInspector\build
2. Zkweb

## 10.监控工具

1. zookeeper监控工具概述

   ```
       可以使用zkWeb,taokeeper,Zabbix等工具来监控zookeeper服务。
       各有各自的优势，推荐还是基于JMX的方式来监控zookeeper集群，因为这种方式适合大多数开源的监控系统(包括但不限于zabbix，Open-Falcon，Prometheus等)。其实还有一个原因是JMX提供了白盒监控。
   ```

2. 开启zookeeper的JMX功能

   1. 修改"zkServer.sh"脚本

      ```
       vim /opt/softwares/zookeeper/bin/zkServer.sh 
       
       grep ZOOMAIN= /opt/softwares/zookeeper/bin/zkServer.sh 
          # ZOOMAIN="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=$JMXLOCALONLY org.apache.zookeeper.server.quorum.QuorumPeerMain"
          
          ZOOMAIN="-Dcom.sun.management.jmxremote -Djava.rmi.server.hostname=$JMXHOSTNAME -Dcom.sun.management.jmxremote.port=$JMXPORT -Dcom.sun.management.jmxremote.authenticate=$JMXAUTH -Dcom.sun.management.jmxremote.ssl=$JMXSSL -Dzookeeper.jmx.log4j.disable=$JMXLOG4J org.apache.zookeeper.server.quorum.QuorumPeerMain" 
      ```

   2. 修改"zkEnv.sh"脚本(该脚本是zkServer.sh启动时使用的环境变量脚本)

      ```
       vim /opt/softwares/zookeeper/bin/zkEnv.sh 
       
       tail -6 /opt/softwares/zookeeper/bin/zkEnv.sh 
      # Add by yinzhengjie for enable zookeeper JMX
      JMXLOCALONLY=false
      JMXHOSTNAME=10.0.0.106
      JMXPORT=21811
      JMXSSL=false
      JMXLOG4J=false
      ```

   3. ## 重启集群使得配置生效

      ```
      zkServer.sh restart
      ss -ntl
      ```

3. 使用jconsole查看JMX数据

   1. 运行终端

      ```
      命令行终端输入"jconsole"。
      ```

   2. 配置不安全连接

   3. 查看监控数据运行jconsole工具

## 11.zookeeper集群调优

1. 查看命令

   1. jps
   2. jmap

2. 调大zookeeper的堆内存大小

   ```
   vi /opt/softwares/zookeeper/conf/java.env
   #!/bin/bash
   
   #指定zookeeper的heap内存大小
   export JVMFLAGS="-Xms256m -Xmx256m $JVMFLAGS"
   
   温馨提示:
   	默认的堆内存大小为1G,此处我将内存修改为256M进行测试,生产环境建议配置为2G-4G即可!
   ```

3. 生产调优参数模板参考

   ```
   vi /opt/softwares/zookeeper/conf/zoo.cfg
   # 滴答，计时的基本单位，默认是2000毫秒，即2秒。它是zookeeper最小的时间单位，用于丈量心跳时间和超时时间等，通常设置成默认2秒即可。
   tickTime=2000
   
   # 初始化限制是10滴答，默认是10个滴答，即默认是20秒。指定follower节点初始化是链接leader节点的最大tick次数。
   initLimit=5
   
   # 数据同步的时间限制，默认是5个滴答，即默认时间是10秒。设定了follower节点与leader节点进行同步的最大时间。与initLimit类似，它也是以tickTime为单位进行指定的。
   syncLimit=2
   
   # 指定zookeeper的工作目录，这是一个非常重要的参数，zookeeper会在内存中在内存只能中保存系统快照，并定期写入该路径指定的文件夹中。生产环境中需要注意该文件夹的磁盘占用情况。
   dataDir=/data/zookeeper
   
   # 监听zookeeper的默认端口。zookeeper监听客户端链接的端口，一般设置成默认2181即可。
   clientPort=2181
   
   # 这个操作将限制连接到 ZooKeeper 的客户端的数量，限制并发连接的数量，它通过 IP 来区分不同的客户端。此配置选项可以用来阻止某些类别的 Dos 攻击。将它设置为 0 或者忽略而不进行设置将会取消对并发连接的限制。
   #maxClientCnxns=60
    
   # 在上文中已经提到，3.4.0及之后版本，ZK提供了自动清理事务日志和快照文件的功能，这个参数指定了清理频率，单位是小时，需要配置一个1或更大的整数，默认是0，表示不开启自动清理功能。
   #autopurge.purgeInterval=1
   
   # 这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。
   #autopurge.snapRetainCount=3
   
   #server.A=B:C:D[:E]
   # A:
   #	myid文件的名称,唯一标识一个zookeeper实例.
   # B:
   # 	myid对应的主机地址.
   # C:
   #	leader的选举端口,谁是leader,哪个zookeeper实例就有相应的端口.
   # D:
   #	数据传输端口.
   # E:
   #	指定zookeeper的角色,分为"participant(参与者)"和"observer(观察者)"
   #	participant角色可以投票选举为leader,而observer无法参与leader的选举,也无法进行投票!
   server.106=10.0.0.106:2888:3888:observer
   server.107=10.0.0.107:2888:3888:participant
   server.108=10.0.0.108:2888:3888:participant
   
   # 跳过权限检查
   # skipACL=yes
   
   # 开启4字命令白名单.
   4lw.commands.whitelist=*
   ```

4. 调优指南

   ```
   	生产环境中可以修改zookeeper的数据存储目录,JVM的堆内存大小,配置集群相关参数调优即可.
   ```

5. 压测

```
docker run --rm --name ztest -it daocloud.io/daocloud/zookeeper:feature-pressure_test /bin/bash

vim benchmark.conf 

./runBenchmark.sh test01 ./benchmark.conf 
```

​	





