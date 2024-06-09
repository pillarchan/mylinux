# zookeeper

## 1.概念

### 	什么是zookeeper

​	zookeeper是一个分布式数据一致性解决方案，致力于为分布式应用提供一个高性能，高可用，且具有严格顺序访问控制能力的分布式协调存储服务。

### 	应用场景: 

#### 	(1)维护配置信息;

​		很多时候会有大量的配置需要修改，单台可以直接手动，如果多台就会增加工作量，虽然可以使用类似ansible的方式去批量修改，但也是比较费时的，如果使用nfs的方式，又会出现高可用和数据一致性的问题。 zookeeper就可以满足这样的需求，它使用zab(原子广播协议)来保证数据一致性，很多开源项目使用zookeeper来维护配置，比如hbase中，客户端就是连接一个zookeeper，获得必要的hbase集群的配置信息，然后才开源进一步操作。还有再开源的消息队列kafka中，也是用zookeeper来维护broker的信息

#### 	(2)分布式锁服务;

​	一个集群是一个分布式系统，由多台服务器组成。为了提高并发度和可靠性，多台服务器上运行着同一种服务。
​	当多个服务在运行时就需要协调各服务的进度，有时候需要保证当某个服务在进行某个操作时，其他的服务都不能进行该操作，即对该操作进行加锁，如果当前机器挂掉后，释放锁并"fail over"到其他的机器继续执行该服务。分布式锁有多种实现方式，比如通过数据库，redis都可以实现。

```
(1)每个客户往"/Locks"下创建临时有序节点"/Locks/Lock_"，创建成功后"/Locks"下面会有每个客户端对应的节点，如"/Locks/Lock_000000001";
(2)客户端取得"/Locks"下子节点，并进行排序，判断排在最前面的是否为自己，如果自己的锁节点排在第一位，代表获取锁成功; 
(3)如果自己的锁节点不在第一位，则监听自己前一位的锁节点。例如，自己锁节点"Lock_000000002"，那么则监听"Lock_000000001";
(4)当前一位锁节点(Lock_000000001)对应的客户端执行完成，释放了锁，将会触发监听客户端;
(5)监听客户端重新执行第2步逻辑，判断自己是否获得了锁;
```

#### 	(3)集群管理;	

​		一个集群有时会因为各种软硬件故障或者网络故障，出现某些服务挂掉而被"移除"集群，而某些服务器"加入"到集群中的情况。zookeeper会将这些服务器"加入"和"移出"的情况通知给集群中其他正常工作的服务器，以及时间调整存储和计算等任务的分配和执行等。综上所述，zookeeper服务可以帮助我们实现服务器动态上下线的集群管理。此外，zookeeper还会对故障的服务器做出诊断并尝试修复。

#### (4)生成分布式唯一ID;	

在过去的单库单表型系统中，通常可以使用数据库字段自带的"auto_increment"属性来自动为每条记录生成一个唯一的ID。但是分库分表后，就无法在依靠数据库的"auto_increment"属性来唯一标识一条记录了。此时我们就可以使用zookeeper在分布式环境下生成全局唯一ID。

```
设计思路:
(1)连接zookeeper服务器;
(2)指定路径生成临时有序节点;
(3)取序列号及分布式环境下的唯一ID;
```

#### (5)配置中心案例;

生产环境中的APP程序会使用到数据库，因此通常会将连接数据库的用户名和密码放在一个配置文件中，应用读取该配置文件，配置文件信息放入缓存。若数据库的用户名和密码改变时候，还需要重新加载缓存，比较麻烦，通过zookeeper可以轻松完成，当数据库发生变化时自动完成缓存同步。

```
设计思路:
	(1)连接zookeeper服务器;
	(2)读取zookeeper中的配置信息，注册watcher监听器，存入本地变量;
	(3)当zookeeper中的配置信息发生变化时，通过watcher的回调方法捕获数据变化事件;
	(4)重新获取配置信息;
```


温馨提示:	zookeeper适用于存储和协同相关的关键数据，不适合用于存储大数据量存储。

### zookeeper的由来

```
 zookeeper由雅虎(Yahoo!)研究院开发，它是一个开源的分布式的协同服务系统，为分布式应用提供协调服务的Apache项目。    zookeeper的设计目标是将那些复杂且容易出错的分布式系统服务封装起来，抽象出一个高效可靠的原语集，并以一系列简单的接口提供给用户使用。
 大数据生态系统里的很多组件的命名都是某个动物或者昆虫，比如Hadoop是大象，hive是蜜蜂，zookeeper是动物管理员，顾名思义就是管理大数据生态系统各组件的管理员。
 官网地址: https://zookeeper.apache.org/
```

### 发展历史

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

## zookeeper的设计目标

​	zookeeper致力于为分布式应用提供一个高性能，高可用，且具有严格顺序访问控制能力的分布式协调服务。	
​	zookeeper从设计模式角度来理解则其是一个**基于观察者模式设计的分布式服务管理框架**。它负责存储和管理大家都关心的数据，然后接受观察者的注册，一旦这些数据的状态发生变化，zookeeper就将负责通知已经在zookeeper上注册的那些观察者做出相应反应。	
​	因此我们可以理解为zookeeper就是一个文件系统加通知机制的软件。

### 1.高性能

​	zookeeper将全量数据存储在内存中，并**直接服务于客户端的所有非事务请求**。	
​	尤其适用于以读为主的应用场景。在一定时间范围内，client能读到最新数据，说明其有很强的实时性。

### 2.高可用

​	zookeeper一般以集群的方式对外提供服务，一般3-5台机器就可以组成一个可用的zookeeper集群了。	
​	每台server保存一份相同的数据副本，client无论连接到哪个server数据都是一致的，并且每台server之间都相互保持着通信。	
​	只要集群中超过一半的机器都能正常工作，那么整个集群就能够正常对外提供服务。

### 3.严格顺序访问

​	对于来自客户端的每个更新请求，zookeeper都会分配一个**全局唯一的递增序号**，这个编号所反映了所有事务操作的先后顺序。	
​	数据更新原子性，一次数据更新要么成功，要么失败。

## zookeeper的数据模型

### 1.zookeeper的数据结构

​	zookeeper的数据模型的结构与Unix文件系统很类似，整体上可以看作一棵树，每个节点称做一个ZNode，每一个ZNode默认能够存储1MB的数据，每个ZNode都可以通过其路径唯一标识。	
​	zookeeper的数据节点可以视为树状结构(或者目录)，树中的各节点被称为znode(即zookeeper node)，一个znode可以有多个子节点。
​	zookeeper节点在结构上表现为树状，使用路径path来定位某个znode。比如"/etc/sysconfig/network-scripts/ifcfg-eth0"，此"/","etc","sysconfig","network-scripts","ifcfg-eth0"分别是根节点，一级节点，二级节点，三级节点和四级节点，其中"etc"是"sysconfig"的父节点，"sysconfig"是"etc"的子节点。
znode兼具文件和目录两种特点，既像文件一样维护着数据，元信息，ACL，时间戳等数据结构，又像目录一样可以作为路径标识的一部分。

### 2.znode的组成部分

​	一个znode大体上分为3个部分，如下所示:
​		节点的数据:
​			即znode data(节点path，节点data)的关系就像是python中dict的key，value的关系。
​		子节点:
​			即某个节点的子节点(children)。
​		节点的状态:
​	用来描述当前节点的创建，修改记录，包括cZxid，ctime等。

### 3.znode状态stat属性

```
	在zookeeper shell中使用stat命令查看指定路径节点的状态信息，如下图所示。
	属性说明如下:
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
```

## znode的类型

### 1.持久(Persistent)

```
客户端和服务端断开连接后，创建的节点不删除。
其被细分为以下两类节点：
(1)持久化目录节点:客户端与zookeeper断开连接后，该节点依旧存在。
(2)持久化顺序编号目录节点:客户端与zookeeper断开连接后，该节点依旧存在，只是zookeeper给该节点名称进行顺序编号。
```

### 2.短暂(Ephemeral)

```
客户端和服务器端口连接后，创建的节点自动删除。
其被细分为以下两类节点：
(1)临时目录节点:客户端与zookeeper断开连接后，该节点被删除。
(2)临时顺序编号目录节点:客户端与zookeeper断开连接后，该节点被删除，只是zookeeper该该节点名称进行顺序编号。
```

### 3.温馨提示

```
(1)创建znode时设置顺序表示，znode名称会附加一个值，顺序号是一个单调递增的计数器，由父节点维护。
(2)在分布式系统中，顺序号可以被用于为所有的事件进行全局排序，这样客户端可以通过顺序号推断事件的顺序。
```

## zookeeper事件监听机制

### 1.watcher概念

​	zookeeper提供了数据的"发布/订阅"功能，多个订阅者可同时监听某一特定主题对象，当该主题对象的自身状态发生变化时(如节点内容变更，节点下的子节点列表改变等)，会实时，主动通知所有订阅者。	
​	zookeeper采用了Watch机制实现数据的"发布/订阅"功能。该机制在被订阅对象发生变化时会异步通知客户端，因此客户端不必在Watcher注册后轮询阻塞，从而减轻了客户端压力。	
​	watch机制实际上与观察者模式类似，也可看作是一种观察者模式在分布式场景下的实现方式。

### 2.watch架构

​	watcher实现由三个部分组合:
​		zookeeper服务端
​		zookeeper客户端
​		客户端的ZKWatchManager对象
​	watcher发布订阅流程如下所示:
​		(1)客户端首先将Watch注册到服务端，同时将Watch对象保存到客户端的Watch管理器中;
​		(2)当zookeeper服务端监听的数据状态发生变化时，服务端会主动通知客户端;
​		(3)接着客户端的Watch管理器会触发相关Watch来回调相应处理逻辑;

### 3.watch特性

​	一次性: watch是一次性的，一旦被触发就会移除，再次使用时需要重新注册。
​	客户端顺序回调:	watcher回调是顺序串行化执行的，只有回调后客户端才能看到最新的数据状态。值得注意的是，一个watch回调逻辑不应该太多，以免影响别的watch执行。
​	轻量级: WatchEvent是最小的通信单元，结构上只包含通知状态，事件类型和节点路径，并不会告诉数据节点变化前后的具体内容。
​	时效性: watcher只有在当前session彻底失效时才会无效，若在session有效期内快速重连成功，则watch依然存在，仍可接收到通知。

### 4.watch原理

```
	监听原理详解:
		(1)首先要有一个main()线程;
		(2)在main线程中创建zookeeper客户端，这时就会创建两个线程，一个是负责网络连接通信(connet)，一个是负责监听(listener);
		(3)通过connect线程将注册的监听事件发送给zookeeper;
		(4)在zookeeper的注册监听器列表中将注册的监听事件添加到列表中;
		(5)zookeeper监听到有数据或路径变化，就会将这个消息发送给listener线程;
		(6)listener线程内部调用了process()方法;
	常见的监听命令:
		(1)监听节点数据的变化:
			get -w path
		(2)监听子节点增减的变化:
			ls -w path
```

## zookeeper的leader选举

### 1.zookeeper服务端状态

​	zookeeper服务端有以下四种常见的状态:
​		looking:
​			寻找leader状态，当服务器处于该状态时，它会认为当前集群中没有leader，因此需要进入leader选举状态。
​		leading:
​			领导者状态，表明当前服务器角色时leader。
​		following:
​			跟随着状态，表明当前服务器角色时follower。
​		observing:
  		  观察者状态，表明当前服务器角色时observer。

### 2.zookeeper集群启动时期的leader选举

​	在集群初始化节点，当有一台服务器zk101启动时，其单独无法进行和完成leader选举，当第二台服务器zk102启动时，此时两台机器就可以相互通信，每台机器都试图找到leader，于是进入leader选举过程。

​    **zookeeper集群启动时期的leader选举过程如下所示**:
(1)每个server发出一个投票，由于初始情况，zk101和zk102都会将自己作为leader服务器来进行投票，每次投票会包含所推举的服务器myid和zxid，如下所示:
​    使用(myid,zxid)来表示，此时zk101投票为(101,0)，zk102的投票为(102,0)，然后各自将跟这个投票发给集群的其它机器;

(2)集群中每台服务器接收来自集群中各个服务器的投票;

(3)处理投票，针对每一个投票，服务器都需要将别人的的投票和自己的投票进行pk，pk的规则如下:
	1)优先检查zxid，zxid比较大的服务器优先作为leader;
	2)如果zxid相同，那么就比较myid，myid较大的服务器作为leader服务器;
    综上所述，我们可以针对zk101和zk102选举的过程如下:
对于zk101而言，它的投票是"(101,0)"，接收zk102的投票为"(102,0)"，首先会比较两者的zxid，均为0，再比较myid，此时zk102的myid最大，于是zk101节点需要更新自己的投票为"(102,0)"。
对于zk102而言，它的投票是"(102,0)"，接收zk101的投票为"(101,0)"，很明显zk101的myid较小，因此zk102无需更新字节的投票，只是再次向集群中所有机器上发送一次投票信息即可;

(4)统计投票，每次投票后，服务器都会统计投票信息，判断是否已经有过半机器(如果集群只有3台，那么过半就是2台服务器)接收到相同的投票信息，对于zk101和zk102而言，都统计出集群中已经有两台机器接收了(102,0)的投票信息，此时认为已经选出来leader;

(5)改变服务器状态，一旦确定了leader，每个zookeeper服务器就会更新自己的状态，如果是follower，那么就变更为following，如果是leader，就变更为leading。
温馨提示:
myid:
    表示当前zookeeper server的server id。
zxid:
    表示zookeeper transaction id，即zookeeper事务ID。
判断是否已经有过半机器接收到相同的投票信息:
    假设集群可参与投票的服务器数量为N，那么过半机器数量计算方式为: (N / 2 + 1)。我们的集群只有3台，那么过半就是2台服务器。

### 3.zookeeper集群运行时期的leader选举

​    在zookeeper运行期间，leader与非leader服务器各司其职，即便当有非leader服务器宕机或新加入，此时也不会影响leader。

​    但是一旦leader服务器挂了，那么这个集群将暂停对外服务，当剩余节点数大于原集群半数节点时，则zookeeper集群可以进入新一轮leader选举，其过程和启动时期的leader选举过程基本一致。

​    假设正在运行的有zk101,zk102,zk103这三台服务器，当leader是zk102，若某一时刻leader挂了，此时便开始leader选举，其过程如下:
(1)变更状态，leader挂后，余下的服务器都会将自己的服务器状态变更为looking，然后开始进入leader选举过程;
(2)每个server会发出一个投票，在运行期间，每个服务器上的zxid可能不同，此时假定zk101的zxid为"996",zk103的zxid为"965"，在第一轮投票中，zk101和zk103都会投自己，产生投票(101,996),(103,965)，然后各自将投票发送给集群中所有机器;
(3)接收来自各个服务器的投票，与启动时过程相同;
(4)处理投票，与启动过程相同，此时zk101将会成为leader;
(5)统计投票，与启动时过程相同;
(6)改变服务器的状态，与启动时过程相同;

## zookeeper原子广播协议

### 1.zookeeper集群的角色

```
	leader(领导者):
		领导者负责进行投票的发起和决议，更新系统状态。
	follower(跟随者):
		用于接收客户请求并向客户端返回结果，将写请求转发给leader节点。在选主过程中参与投票。
	obServer(观察者):
		可以接收客户端连接，将写请求转发给leader节点。这是集群的可选组件。
		但obServer不参加投票过程，只同步leader的状态。obServer的目的是为了扩展系统，提高读取速度。
	client(客户端):
		向zookeeper集群发起连接请求的一方。
```

### 2.zab协议的工作原理(写数据流程介绍)

```
	zab协议的全称是"Zookeeper Atomic Broadcast"(zookeeper原子广播)。	
	zookeeper是通过zab协议来保证分布式事务的最终一致性。
	zab是基于广播模式工作的，通过类似两阶段提交协议的方式解决数据一致性。
	
	zab其工作原理如下:
		(1)leader从客户端收到一个写请求;
		(2)leader生成一个新的事务并为这个事务生成一个唯一的ZXID;
		(3)leader将这个事务提议(propose)发送给所有的follows节点;
		(4)follower节点收到的事务请求加入到历史队列(history queue)中，并发送ack给leader;
		(5)当leader收到大多数follower(集群中半数以上节点)的ack消息后，leader会发送commit请求;
		(6)当follower收到commit请求时，从历史队列中将事务请求commit;
```

## 2.安装配置

1. 环境与工具

   1. java-jdk zookeeper

2. 安装
   1. java-jdk 使用yum或二进制包进行安装,视操作系统而定，使用二进制包需要配置环境变量家目录
   2. zookeeper 二进制包

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
   		obServer也不会返回ack给leader
   ```

## 7.ACL权限

### zookeeper的ACL简介

```
 zookeeper的ACL权限控制使用"scheme:id:permission"来标识，主要涵盖如下三个方面:
        权限模式(scheme):
            指的是授权的策略。
        授权的对象(id):
            指的是授权的对象。
        权限(permission):
            指的是授权的权限。

    zookeeper的ACL的特点如下:
        (1)zookeeper的权限控制是基于每个znode节点的，需要对每个节点设置权限;
        (2)每个znode支持设置多种权限控制方案和多个权限;
        (3)子节点不会继承父节点的权限，也就是说，客户端无权访问某个znode，并不代表无法访问它的子节点;

    例如:
        setAcl /oldboy ip:172.200.1.103:crwda
    说明如下:
        将节点权限设置为IP：172.200.1.103的客户端可以对节点进行增，删，改，查，管理权限。
```

#### 策略模式 scheme

```
world:只有一个用户，即"anyone"，代表登录zookeeper的所有人，这也是默认的权限模式。
ip:对客户端使用IP地址认证。
auth:使用已添加认证的用户认证。
digest:使用"用户名:密码"方式进行认证。
```

#### 对象 id

```
给谁授予权限，授权对象ID是指权限赋予的实体，例如: IP地址或用户。
```

#### 权限 permission

```
create(简写"c"):表示可以创建子节点。
delete(简称"d"):可以删除子节点。
read(简称"r"):可以读取节点数据及显示子节点列表。
write(简称"w"):可以修改节点数据。
admin(简称"a"):可以设置节点访问控制列表权限。
```

#### 误删 admin 权限恢复方式

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
   setAcl /kafka auth:admin:crwda
   
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
   
   ```
   java -jar zookeeper-dev-ZooInspector.jar
   ```
2. Zkweb

   ```
   https://github.com/zhitom/zkweb/releases 下载地址
   java -jar zkWeb.jar
   运行前需要修改 /etc/hosts
   ```

   

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

   1. jps -mlvV
   2. jmap

      ```
      jmap -heap pid
      ```

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





