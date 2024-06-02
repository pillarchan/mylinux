

## EFK架构方案

apps->filebeat->kafka->logstash->es->kibana/grafana

## kafka特性

1. 内存消耗低
2. 高可用
3. 多节点I/O性能可用性

## 什么是MQ

MQ的全称为"Message Queue"，即**消息队列**。消息队列是在消息传输过程中**保存消息**的容器，多用于**分布式系统之间进行通信**。

## 使用MQ的优势

### 应用解耦

app->功能模块->MQ->其它功能模块

**耦合是指两个或多个软件组件之间存在相互影响的或强或弱的关联关系**。耦合度越高，组件之间的依赖性越强，对彼此的影响就越大。高耦合的应用通常难以维护和扩展，因为修改一个组件可能会导致其他组件出现问题。**应用解耦**是指**降低**应用各个部分之间的**依赖性**，使各个部分能够相对独立地开发、维护和演化。解耦的主要目标是提高应用的灵活性、可维护性和可扩展性。

### 异步提速

是指通过使用消息队列来提高系统的处理速度。在传统的同步处理模式下，发送方需要等待接收方处理完消息之后才能继续执行后续操作。这可能会导致发送方阻塞，特别是当接收方处理速度较慢时。

而MQ的异步处理模式则允许发送方将消息发送到消息队列后立即返回，而无需等待接收方处理。接收方可以根据自己的速度从消息队列中获取消息进行处理。这样一来，发送方和接收方就可以并行工作，从而提高系统的整体吞吐量

### 削峰填谷

MQ的削峰填谷是指利用消息队列（MQ）来平滑流量波峰，提高系统整体的处理能力。在实际应用中，MQ的削峰填谷主要有以下两种方式：  app->MQ->功能模块->MQ->其它功能模块

**1. 缓存消息**

在流量高峰期，将大量**请求消息缓存到MQ中**，然后再由下游服务按照自己的处理能力从MQ中拉取消息进行处理。这样可以避免下游服务直接被突增的流量压垮，同时也能充分利用下游服务的空闲时间进行处理，提高整体的资源利用率。

**2. 限流**

在流量高峰期，**对上游请求进行限流，只允许一定数量的请求进入MQ**。限流的方式可以是根据请求的优先级、来源等进行限流，也可以是简单的按照时间窗口进行限流。被限流的请求可以被直接丢弃，也可以放入到另一个低优先级的队列中稍后再进行处理。

## 使用MQ的劣势

系统可用性降低:
        系统引入的外部依赖越多，系统稳定性越差，一旦MQ宕机，就会对业务造成影响。那么问题自然就是如何保证MQ的高可用呢？也就是说如果MQ自身能实现服务的高可用则该问题自然就迎刃而解了。

系统复杂度提高:
    MQ的加入大大增加了系统的复杂度，以前是同步的远程调用，现在是通过MQ进行异步调用，如何保证消息不会被丢失等情况。

## 维护的级别 

GB ---> TB（如MYSQL最高64T） ---> PB ---> EB（大数据级别）

## MQ的两种模式

### 点对点模式(一对一，消费者主动拉取数据，消息收到后消息清除)

生产者将消息发送到消息队列，消费者主动去消息队列拉取消息，拉取消息后被拉取的消息先被标记为删除，过段时间才会被最终清除掉

### 发布/订阅模式(一对多，消费者消费数据之后不会清除消息)

生产者将消息发布到消息队列，订阅了该消息的消费才就去拉取数据，拉取后被拉取的消息不会被删除，当消费者需要拉取新的消息时，会根据偏移量去计算拉取

## MQ的选择

RabbitMQ:
        优点:
            消息可靠性高，功能全面。
        缺点:
            吞吐量比较低，消息积累会影响性能，erlang语言不好定制，国内相关的开发人员相对较少。
        使用场景:
            小规模场景。

Kafka:
    优点:
        吞吐量非常大，性能非常好，集群高可用。
    缺点:
        (1)维护起来比较复杂，比如数据均衡，数据迁移相对来说比较麻烦。
        (2)当leader节点数据写入成功后(只是写入了OS cache，而后由OS异步写入磁盘)，follow节点还来不及同步数据时，leader节点挂掉的情况可能会导致部分数据丢失。解决方案就是多节点写入成功后在回应客户端ACK，但这意味着会增大延迟，从而降低集群性能。
    使用场景:
        日志分析，大数据实时流的采集等。

RocketMQ:
    优点:
        高吞吐，高性能，高可用，功能全面。
    缺点:
        开源版功能不如云上版，官方文档比较简单，客户端只支持Java。
    使用场景:
        几乎全场景。

温馨提示:
    (1)目前生产环境中使用ActiveMQ的公司越来越少了，但RabbitMQ，RocketMQ，Kafka目前很多公司还在使用。
    (2)尽管RabbitMQ相比RocketMQ，Kafka性能较差，但RabbitMQ可以保证100%数据不丢失，因此由于其数据的安全性，目前该产品也赢得很多金融公司的喜爱;
    (3)kafka诞生的背景就是为大数据生态而生的，因此在大数据量的情况下，使用kafka的相对较多;
    (4)在阿里公司内部，肯定是主推RocketMQ较多，因为其将RabbitMQ和Kafka的优点基于一身，但RocketMQ开源社区的活跃度相比kafka较弱，如果想要用性能可以直接购买阿里云的SAAS产品即可;

## 业务处理

### 要如何选择MQ产品?

​    参考上面"MQ的选择"内容。

### 如何快速处理未支付订单?

​    可以使用Rocket延迟消息快速回收未支付的订单。
​    如果不用RocketMQ也可以实现，思路如下：
​        (1)我们需要使用一个专门的延迟队列来存储原始数据；
​        (2)而后使用延迟消息服务(这通常由开发团队来设计)消费该队列数据，目的是用于过滤掉未支付的订单；
​        (3)将上一步处理后的消息重新写入一个新的队列中，该队列数据交由下游的消费者进行处理;

### 如何保证下单操作与消息发送的事务一致性?

​    使用RocketMQ事务消息保证事务的一致性。其实现思路如下:
​        (1)生产者开启事物发送half数据给RocketMQ，值得注意的是，此时未接收到回滚或提交对于消费者而言是看不到这部分half数据的，但这些数据已经发送到RocketMQ服务端了;
​        (2)当RocketMQ接收到消息后，会响应生产者已接收到half数据以确保数据接收成功;
​        (3)生产者继续执行本地事务;
​        (4)生产者在执行本地事务时可以进行回滚或者提交本次事务;
​        (5)如果RocketMQ长时间未能确定该事物是否提交，会定期访问生产者进行回查;
​        (6)生产者会访问本地的事务管理，用于回查消息状态(此处我们只讨论提交会回滚两种状态);
​        (7)根据上一步查询的消息状态提交进行回滚;
​        (8)一旦数据被提交，则提交到目标topic数据是可以被消费者正常消费的;如果数据未能提交，即回滚的事物数据将直接丢弃，而这些被回滚的数据消费者永远都无法拿到，因为消费者始终只能拿到已提交的事物哟;

### 如何保证集群高可用?

​    普通的多主多从集群，在RocketMQ的conf目录下提供了现成的配置Demo。而我们的课程会主要讲解kafka高可用集群搭建。
​    Kafka使用zookeeper实现高可用，而zookeeper的Zab协议是借鉴于Paxos协议。
​    RocketMQ使用Dledger技术实现高可用，而Dledger底层使用Raft协议来进行leader选举。

### 如何平衡MQ消息的高吞吐和高可靠?

​    我们可以从生产者的发送消息；broker的主从数据同步，消息刷盘；消费者的消费消息这三种角色的四个环节来优化高吞吐和高可用的区别。

### 如何保证高性能文件读写?

​    RocketMQ文件读写高性能的三大利器：磁盘顺序写，异步刷盘，零拷贝等技术（这些kafka也支持）。
​    如下图所示，DMA的英文拼写是"Direct Memory Access"，汉语的意思就是直接内存访问，是一种不经过CPU而直接从内存存取数据的数据交换模式。 
​    温馨提示:
​        JDK NIO零拷贝实现分为两种方案，即mmap和sendFile。
​            (1)mmap比较适合小文件读写，对文件大小有限制，一般在1.5GB~2.0GB之间;
​            (2)sendFile比较适合大文件传输，可以利用DMA方式，减少CPU拷贝;

### 分布式服务消息等幂三大语义分类是什么？

​    "At Least Once"，"At Most Once"，"Exactly One"。

## kafka部署

### 单机部署

1. 官网下载二进制包

   ```
   https://kafka.apache.org/downloads
   ```

2. 解压二进制包到指定目录

3. 建立软连接

4. 配置环境变量

5. 修改配置文件

   ```
   config/server.properties中的
   broker.id=xxx
   zookeeper.connect=192.168.76.113:2181,192.168.76.112:2181,192.168.76.111:2181/kafka370
   
   这里的kafka370就是 kafka在zookeeper上的znode节点，里面将包含kafka的所有数据
   ```

6. 修改启动文件堆内存大小

   ```
   bin/kafka-server-start.sh
       export KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"
   默认是1个G
   ```

### 集群部署

```
至少3台同样配置的服务器，安装好kafka后修改配置文件中 broker.id，一定是不一样的值
然后启动服务即可

可修改配置文件中
log.dirs=为自定义目录
默认为/tmp/kafka-logs
log.dirs就是数据存储目录

如果已经存在/tmp/kafka-logs/meta.properties
须注意：
cluster.id 是否一致
broker.id 是否与配置文件中的broker.id一致
```

访问集群

```
kafka-topics.sh --bootstrap-server ip:port,ip:port,ip:port[,ip:port...] --list
如：kafka-topics.sh --bootstrap-server 192.168.76.114:9092,192.168.76.115:9092,192.168.76.116:9092 --list
```

## Kafka基础管理命令

### 启动服务

```
kafka-server-start.sh [-daemon] server.properties [--override property=value]*
```

启动生产者

```
kafka-console-producer.sh --topic <String> --bootstrap-server ip:port
```

启动消费者

```
kafka-console-cosumer.sh --topic <String> --bootstrap-server ip:port [--from-beginning]
```

topic的增删改查

```
kafka-topics.sh --bootstrap-server ip:port --list
kafka-topics.sh --bootstrap-server ip:port --topic <String> --describe
kafka-topics.sh --bootstrap-server ip:port --topic <String> --create --partitions <Num> --replication-factor <Num>
kafka-topics.sh --bootstrap-server ip:port --topic <String> --alter --partitions <Num>
```

## Kafka基础架构

kafka集群 kafka cluster也叫broker list 分为实例节点，用不同的broker.id区分，它们都依赖于zookeeper提供元数据的存储

外部连接包括有 生产者，消费者，管理API，流处理工具，数据库连接器

### 生产者

生产者通过API或脚本基于topic将数据写入集群

#### 	分区

##### 	原因

(1)可以提高数据的负载均衡能力，如果一个topic只有一个partition，那么所有的消息都只能在一个broker，但一个topic有多个partition时，就可以有效的解决数据的负载均衡;
(2)可以提高并发，因为可以用以partition为单位进行读写了。

##### 	分区数量的分区策略

考虑的因素

(1)topic需要达到多大的吞吐量？例如，是希望每秒钟写入100KB的数据还是1GB数据呢?
(2)从单个分区读取数据的最大吞吐量是多少？每个分区一般都会有一个消费者，如果你知道消费者将数据写入数据库的速度不会超过50MB，那么你也该知道，从一个分区读取数据的吞吐量不需要超过每秒50MB。
(3)可以通过类似的方法估算生产者向单个分区写入数据的吞吐量，不过生产者的速度一般比消费者快得多，所以最好为生产者多估算一些吞吐量。
(4)每个broker包含的分区个数，可用的磁盘空间和网络带宽。
(5)如果消息是按照不同的键来写入分区的，那么为已有的主题新增分区就会很困难;
(6)单个broker对分区个数是有限制的，因为分区越多，占用的内存越多，完成leader选举需要的时间也越长;
选择分区数的粗略公式基于吞吐量。您可以衡量在单个分区上可以实现的整体产量，将其用于生产（称为p）和消费（称为c）。假设您的目标吞吐量为t。然后，您至少需要有max（t / p，t / c）个分区。

##### 	生产者提交（发送）数据到分区的原则

 需要将producer发送的数据封装成一个ProducerRecord对象。
        (1)指明partition的情况下，直接将指明的值直接作为partition值;也就是在发送数据的时候已经指定了分区的时候，数据就会发送到指定的分区
        (2)没有指明partition值但有key的情况下，将key的hash值与topic的partition数进行取余得到要提交的partition编号;这个编号就是数据将要被发送到的分区值
            Math.abs(key.hashCode()) % numPartitions
        (3)既没有partition值有没有key值的情况下，第一次调用时随机生成一个整数(后面每次调用在这个整数上自增)，将这个值与topic可用的partition总数取余得到partition值，也就是常说的round-robin算法;也就是轮询，而默认的提交（发送）方式就是轮询

##### 	数据可靠性保证

###### 		同步原理

为保证producer发送的数据能可靠地发送到指定的topic，topic的每个partition的leader收到producer发送的数据后，都需要向producer发送ack（acknowledgement确认收到），当producer收到ack，才会进行下一轮的发送，否则重新发送数据。
为了确保有follower与leader同步完成，follower会发送ack给leader确认数据同步完成，leader再发送ack给producer，这样才能保证leader挂掉之后，能在follower中选举出新的leader。

###### 		同步方案

多少个follower同步完成之后发送ack?请思考以下两种方案：
            (1)半数以上的follower同步完成，即可发送ack;
                优点:
                    延迟低。
                缺点:
                    选举新的leader时，容忍N台节点的故障，需要2N+1个副本。
                举例： 
                    假设N为1，容忍1台节点故障，则需要3个副本，因为此时只有半数以上的副本数是完全同步的，理想情况下是2个副本是数据同步的，这样就算挂掉一个leader副本，还有一个副本立马能顶上去。
            (2)全部的follower同步完成，才可以发送ack;
                优点:
                    选举新的leader时，容忍N台节点的故障，需要N+1个副本。
                缺点:
                    延迟高。
                举例： 
                    假设N为1，容忍1台节点故障，则需要2个副本，因为此时全部的副本是完全同步的，理想情况下2个副本是数据同步的，这样就算挂掉一个副本，还有一个副本立马能顶上去。

###### 		方案选择

kafka选择了第二种方案，原因如下：
		(1)同样容忍N台节点故障，第一种方案需要2N+1个副本，而第二种方案只需要N+1个副本，而kafka的每个分区都有大量的数据，第一种方案会造成大量数据的冗余。
		(2)虽然第二种方案的网络延迟会比较高，但网络延迟对kafka的影响较小。

###### 		ISR

但是采用第二种方案之后，设想以下情景：
	leader收到数据，所有follower都开始同步数据，但有一个follower，因为某种故障，迟迟不能与leader进行同步，那leader就要一直等下去，直到它完成同步，才能发送ACK，这个问题怎么解决呢？

与此同时，提出了优化策略，即ISR：	
	leader维护了一个动态的in-sync replica set(ISR)，意味和leader保持同步的follower集合。当ISR中的follower完成数据的同步之后，leader就会给生产者发送ACK。如果follower长时间未向leader同步数据，则该follower将被剔出ISR，该时间阈值由"replica.lag.time.max.ms"参数设定(在kafka 0.9版本之前，还有"replica.lag.max.messages"参数可以控制)，leader发生故障之后，就会从ISR中选举新的leader。

###### 		ack应答机制

​	对于某些不太重要的数据，对数据的可靠性要求不是很高，能够容忍数据的少量丢失，所以没必要等ISR中follower全部接受成功。
​	所以kafka为用户提供了三种可靠型级别，用户根据对可靠性和延迟的要求进行权衡，可供选择以下acks参数配置:
​		0: producer不等待broker的ack，这一操作提供了一个最低的延迟，broker一接收到还没有写入磁盘就已经返回，当broker故障时有可能丢失数据。
​		1: producer等待broker的ack，partition的leader落盘成功后返回ack，如果在follower同步之前leader故障，那么将会丢失数据。
​		-1(all): producer等待broker的ack，partition的leader和ISR中的follower全部落盘成功后才返回ACK，但是如果在follower同步完成后，broker发送ack之前，leader发生故障，那么会就造成数据重复。该模式下值得注意的是：当ISR只有leader一个节点时，其他的follower均不在ISR中，而是被剔出到OSR，此时当leader提交ack后立刻宕机，数据也可能会丢失的，因为ISR中没有其他的follower

###### HW（High Watermark，高水位）和LEO（Log End Offset）的关系

LEO是每个副本的最后一个offset

HW是所有副本中最小的LEO

HW之前的数据玫对consumer是可见的

如果在replica.lag.time.max.ms时间内，follower的leo的值与leader的不一致，那么不一致的follower就会被踢出isr。

当leader故障时，leo最大的follower将成为新的leader，而此时如果故障leader的leo大于新的leader的leo，则新的leader不会再去写入故障leader的leo之前的数据，而是直接写入新的数据，follower也会去同步新的leader。

故障leader恢复后，则会成为follower，此时它会根据故障前的HW值，删除掉这个值之后的数据，然后HW值的LEO位置同步数据，以保证数据一致


​	
​	
​	        
​	如下图所示，描述了。
​	
	温馨提示:
		为什么在kafka 0.9版本之后，"replica.lag.max.messages"参数被移除了呢？
		举个例子，假设我们设置最大延迟的消息数是100，而生产者在批量写入数据时，很可能所有的follower节点的延迟消息均大于100条消息，而过段时间后，各个节点又逐渐追回消息，这会导致频繁的出现follower节点重新加入或被剔出ISR的现象。
		一旦修改比较频繁，这些ISR数据都会同步到zookeeper集群中，无疑是增加了成本。
		而保留的基于时间间隔来判断可以减少频繁被剔出或加入到ISR的现象哟~

#### 副本

​	不同的分区数据可以进行主从复制，同步数据，如果主副本的节点故障了，还可以读写从副本，达到高可用的目的。但是从副本一般只能同步数据，外部不能直接读写数据

注意：

kafka中的读写都是基于leader的

### 数据存储

由于生产者生产的消息会不断追加到log文件末尾，为防止log文件过大导致数据定位效率低下，kafka采取了分片和索引机制，将每个partition分为多个segment；
每个segment对应两个文件，即"*.index"文件和"*.log"文件，这些文件位于一个文件夹下，该文件夹的命名规则为: "topic名称 + 分区序号"

"*.index"文件和"*.log"文件以当前segment的第一条消息的offset命名

topic数据就存储在配置文件中logs.dir目录里，其中topic名的构成就是topic主题名-partition编号组成

topic数据包括有 topic主题名 id 分区 副本数 配置，当指定了分区数和副本数，一个topic数据就会按分区和副本分别存储到所分配的分区和副本中，其中leader为读写节点，存储的位置在配置文件中logs.dir目录下对应topic目录下，包括索引、日志、元数据、时间索引、检查点

```
Topic: mydemo	TopicId: pS9NSpUmThm4BYp_LtsAXQ	PartitionCount: 3	ReplicationFactor: 2	Configs: 
	Topic: mydemo	Partition: 0	Leader: 114	Replicas: 114,116	Isr: 114,116
	Topic: mydemo	Partition: 1	Leader: 116	Replicas: 116,115	Isr: 116,115
	Topic: mydemo	Partition: 2	Leader: 115	Replicas: 115,114	Isr: 115,114
	topic主题名  分区编号        读定节点      副本存放节点为的编号
	
[root@centos79kafka3 ~]# file /data/kafka/data/mydemo-0/*
/data/kafka/data/mydemo-0/00000000000000000000.index:     data
/data/kafka/data/mydemo-0/00000000000000000000.log:       empty
/data/kafka/data/mydemo-0/00000000000000000000.timeindex: data
/data/kafka/data/mydemo-0/leader-epoch-checkpoint:        empty
/data/kafka/data/mydemo-0/partition.metadata:             ASCII text
```



### 消费者

​	消费者是去kafka集群拉取数据

#### 消费方式

consumer采用pull(拉)模式从broker中读取数据。

push(推)模式很难适应消费速率不同的消费者，因为消息发送速率是由broker决定的。它的目标是尽可能以最快速度传递消息，但是这样很容易造成consumer来不及处理消息，典型的表现就是拒绝服务以及网络拥塞。

而pull模式则可以根据consumer的消费能力以适当的速率消费消息。

pull模式不足之处是，如果kafka没有数据，消费者可能会陷入循环中，一直返回空数据。

针对这一点，kafka的消费者在消费数据时会传入一个时长参数timeout，如果当前没有数据可供消费，consumer会等待一段时间之后再返回，这段时长即为timeout。

#### 分区分配策略

 一个consumer group中有多个consumer，一个topic有多个partition，所以必然会涉及到partition的分配问题，即确定哪个partition由哪个consumer来消费。

kafka有两种分配策略，一个是RoundRobin，一个是Range。
    RoundRobin策略:
        工作原理:
            将消费者组订阅的一个或多个主题的所有分区进行排序，而后依次将partition分发给该组的各个消费者。
        优点:
            轮询使不同topic的所有分区看作一个整体，分区数相对来说比较均衡的分配到同一个消费者组的各个消费者上。
        缺点:
            当同一个消费者组的不同消费者订阅了不同的topic时，这种方式方式就不太合适了，因为很有可能导致消费者消费到未订阅的topic。

Range策略(也是官方的默认策略):
    工作原理:
        将分区数和同一个消费者组的消费者数量进行取商，然后多出来的余数会随机分配到该组的某个消费者。当订阅的topic数量的分区较少时，可能还看不出明显的数据不均衡现象。
    优点:
        范围是订阅同一topic的所有消费者组。
    缺点:
        当同一个消费者组的某个消费者单独订阅了一个主题，按照range策略的话会将topic的所有分区都分配给该消费者，而该消费者所在的消费者组内的其它成员(由于没有订阅该主题)无法消费数据。
        举个例子: 999个分区被100个消费者进行消费,就会出现严重的不均衡的现象!

温馨提示:
    当消费者组中的消费者个数发生变化(比如消费者增加或减少)，都会触发消费者分区策略进行对分区的重新分配（reblance）。
    注意哈，即使同一个消费者组中新增消费者数量后，此时消费者数量已经大于订阅topic的分区数，也会触发分区的重新均衡，因为我们改变了该消费者组中的消费者数量。当然，多出来的消费者会处于空闲状态。

#### offset的维护

由于consumer在消费过程中可能会出现断电宕机等故障，consumer恢复后，需要从故障前的位置继续消费，所以consumer需要实时记录自己消费到了哪个offset，以便故障恢复后继续消费。

温馨提示:
    kafka 0.9版本之前，consumer默认将offset保存在zookeeper中，从0.9版本开始，consumer默认将offset保存在kafka内置的一个topic中，该topic为"__consumer_offsets"。

#### 查看offset

```
kafka-console-consumer.sh --topic __consumer_offsets --bootstrap-server 192.168.76.114:9092,192.168.76.115:9092,192.168.76.116:9092 --formatter "kafka.coordinator.group.GroupMetadataManager\$OffsetsMessageFormatter" --consumer-property group.id=mycp --from-beginning | grep lala

[mycp,lala,2]::OffsetAndMetadata(offset=0, leaderEpoch=Optional.empty, metadata=, commitTimestamp=1717124199818, expireTimestamp=None)
[mycp,lala,1]::OffsetAndMetadata(offset=0, leaderEpoch=Optional.empty, metadata=, commitTimestamp=1717124199818, expireTimestamp=None)
[mycp,lala,0]::OffsetAndMetadata(offset=14, leaderEpoch=Optional[0], metadata=, commitTimestamp=1717124199818, expireTimestamp=None)
[mycp,lala,2]::OffsetAndMetadata(offset=0, leaderEpoch=Optional.empty, metadata=, commitTimestamp=1717124203901, expireTimestamp=None)
[mycp,lala,1]::OffsetAndMetadata(offset=0, leaderEpoch=Optional.empty, metadata=, commitTimestamp=1717124203901, expireTimestamp=None)
[mycp,lala,0]::OffsetAndMetadata(offset=14, leaderEpoch=Optional[0], metadata=, commitTimestamp=1717124203901, expireTimestamp=None)

日志格式如下所示：（可以理解为"Key::Value"格式）
[Group, Topic, Partition]::OffsetAndMetadata(Offset, leaderEpoch, Metadata, commitTimestamp, expireTimestamp]
相关字段说明如下:
Group:
	对应消费者组的groupid，这条消息要发送到"__consumer_offset"的哪个分区，是由这个字段决定的。
	值得注意是，此处设置的是消费者组名称，而非消费者组内的某个消费者。这样设计的好处是，当一个消费者组内的消费者数量有所变动时会导致的重新rebalance。
	而消费者组内的消费者重新分配到新的partition时，它们是知道该partition被消费到哪里的，因为在broker都有对应消费者组关于某个分区以消费的offset。
Topic:
	主题名称。
Partition:
	主题的分区编号。
OffsetAndMetadata:
	偏移量和元数据信息。其包含以下五项内容:
		offset: 偏移量信息。
		leaderEpoch: Kafka使用HW值来决定副本备份的进度，而HW值的更新通常需要额外一轮FETCH RPC才能完成，故而这种设计是有问题的。它们可能引起的问题包括：
 			备份数据丢失
 			备份数据不一致 
             Kafka 0.11版本之后引入了leader epoch来取代HW值。Leader端多开辟一段内存区域专门保存leader的epoch信息，这样即使出现上面的两个场景也能很好地规避这些问题。
		Metadata: 自定义元数据信息，通常情况下为空，因为这种场景很少会用到。
 		commitTimestamp: 提交到kafka的时间。
		expireTimestamp: 过期时间, 当数据过期时会有一个定时任务去清理过期的消息。
```

### 消费者组

当生产者发送的数据过多，而单个消费者无法即时消费完就会造成延迟，这时，就需要考虑使用消费者组来共同消费生产者发送的数据。

当消费者组中一个消费者在消费一个partition中leader的数据时，其它的消费者是不能来进行访问，即消费者不能同时消费同一partition中leader的数据，当数据已经被消费后就不能再次消费了

### 小节

#### Producer

消息生产者，就是向kafka broker发消息的客户端。

#### Consumer

消息消费者，向kafka broker拉取消息的客户端。

#### Consumer Group(简称"CG")

消费者组，由多个consumer组成。消费者组内每个消费者负责消费不同分区的数据，一个分区只能由一个组内消费者消费，消费者组之间互不影响。
所有的消费者都属于某个消费者组，即消费者组是逻辑上的一个订阅者。

#### Broker

一台kafka服务器就是一个broker，一个集群由多个broker组成。一个broker可以容纳多个topic。

#### Topic

可以理解为一个队列，生产者和消费者面向的都是一个topic。

#### Parition

为了实现扩展性，一个非常大的topic可以分不到多个broker(即服务器)上，一个topic可以分为多个pairtition，每个partition是一个有序的队列。

#### Replica

副本，为保证集群中的某个节点发生故障时，该节点上的partition数据不丢失，且kafka仍然能够继续工作，kafka提供了副本机制，一个topic的每个分区都有若干个副本，一个leader和若干个follower。

##### 	leader

每个分区多个副本为"主"，生产者发送数据的对象，以及消费者消费数据的对象都是leader。

##### 	follower

每个分区多个副本中的"从"，实时从leader中同步数据，保持和leader数据的同步。leader发生故障时，某个follower会成为新的leader。

温馨提示:
    (1)kafka中消息是以topic进行分类的，生产者生产消息，消费者消费消息，都是面向topic的。
    (2)topic是逻辑上的概念，而partition是物理上的概念，每个paritition对应于一个log文件，该log文件中存储的就是producer生产的数据;
    (3)producer生产的数据会被不断追加到该log文件末尾，且每条数据都有自己的offset；
    (4)消费者组中的每个消费者，都会实时记录自己消费到了哪个offset，以便出错恢复时，从上次的位置继续消费;

### admin api

运维用于管理kafka的API，比如 topic 管理，kafka优化

### connect api

用于连接后端数据库的API

### stream api

## kafka高效读写数据的底层原理

### 	顺序写磁盘

​	kafka的producer生产数据，将数据顺序写入到磁盘，从而优化磁盘写入效率

### 	零拷贝技术

​	DMA的英文拼写是"Direct Memory Access"，汉语的意思就是直接内存访问。传统的模式，是先将磁盘数据通过DMA拷贝到内核空间的read buffer然后再通cpu拷贝到用户空间的应用程序，然后用户空间的应用程序再通过cpu拷贝到socket buffer再通过DMA拷贝发送到网络。零拷贝技术就是一种不经过CPU而直接从内存存取数据的数据交换模式，这样就减少了CPU的两次拷贝，节约了时间。

### 	异步刷盘

​	kafka并不会将数据直接写入到磁盘，而是写入OS的cache，而后由OS实现数据的写入。这样做的好处就是减少kafka源代码更多关于兼容各种厂商类型的磁盘驱动，而是交给更擅长和硬件打交道的操作系统来完成和磁盘的交互。不得不说异步刷盘的确提高了效率，但也意味着带来了数据丢失的风险，假设数据已经写入到OS的cache page，但数据并未落盘之前服务器断电，很可能会导致数据的丢失。

### 	分布式集群

​	kafka可以将一个topic分为多个partition，而partition又分布在不同broker节点，这样就充分利用了各个broker节点的性能，包括但不限于CPU，内存，磁盘，网卡等。

## zookeeper在kafka中的作用

### 1.partition的leader选举

partition的leader选举最简单最直观的方案是：
        leader在zk上创建一个永久znode，所有Follower对此节点注册监听，当leader宕机时，此时ISR里的所有Follower会选举出新的leader,并更新该znode的数据(这一点可以参考zk的znode的"Data Version"属性)。

实际上的实现思路也是这样，只是优化了下，多了个代理控制管理类（controller）。

引入的原因是，当kafka集群业务很多，partition达到成千上万时，当broker宕机时，造成集群内大量的调整，会造成大量Watch事件被触发，Zookeeper负载会过重。zk是不适合大量写操作的。

### 2.kafka的controller是做什么的

kafka集群中有一个broker会被选举为Controller（这会在zk集群上创建一个临时的znode），这个controller是负责管理和协调kafka集群的，其功能包括但不限于以下几点:

#### UpdateMetadataRequest

​        更新元数据请求。
​        topic分区状态经常会发生变更(比如leader重新选举了或副本集合变化了等)。由于当前clients只能与分区的leader broker进行交互，那么一旦发生变更，controller会将最新的元数据广播给所有存活的broker。
​        具体方式就是给所有broker发送UpdateMetadataRequest请求

#### CreateTopics:

​    创建topic请求。
​    当前不管是通过API方式、脚本方式或是CreateTopics请求方式来创建topic，做法几乎都是在Zookeeper的/brokers/topics下创建znode来触发创建逻辑，而controller会监听该path下的变更来执行真正的"创建topic"逻辑

#### DeleteTopics

​    删除topic请求。
​    和CreateTopics类似，也是通过创建Zookeeper下的/admin/delete_topics/<topic>节点来触发删除topic，controller执行真正的逻辑。
​    不信的话,你可以将一个已存在的topic名称创在"/admin/delete_topics/"试试看呗!

#### 分区重分配

​    即kafka-reassign-partitions.sh脚本做的事情。同样是与Zookeeper结合使用，脚本写入/admin/reassign_partitions节点来触发，controller负责按照方案分配分区。

#### Preferred leader分配

​    preferred leader选举当前有两种触发方式：
​        (1)自动触发(auto.leader.rebalance.enable = true);
​        (2)kafka-preferred-replica-election脚本触发。两者"玩法"相同，向Zookeeper的/admin/preferred_replica_election写数据，controller提取数据执行preferred leader分配;

#### 分区扩展

​    即增加topic分区数。
​    标准做法也是通过kafka-reassign-partitions.sh脚本完成，不过用户可直接往Zookeeper中写数据来实现，比如直接把新增分区的副本集合写入到/brokers/topics/<topic>下，然后controller会为你自动地选出leader并增加分区。

#### 集群扩展

​    新增broker时Zookeeper中/brokers/ids下会新增znode，controller自动完成服务发现的工作

#### broker崩溃

​    同样地，controller通过Zookeeper可实时侦测broker状态。一旦有broker挂掉了，controller可立即感知并为受影响分区选举新的leader。

#### ControlledShutdown

​    broker除了崩溃，还能"优雅"地退出。broker一旦自行终止，controller会接收到一个ControlledShudownRequest请求，然后controller会妥善处理该请求并执行各种收尾工作

#### Controller leader选举

​    controller必然要提供自己的leader选举以防这个全局唯一的组件崩溃宕机导致服务中断。这个功能也是通过Zookeeper的帮助实现的。

## kafka事务（了解即可）

### 1.kafka事务概述

```
    kafka从0.11版本开始引入了事务支持。
    
    事务可以保证kafka在Exactly Once语义的基础上，生产和消费可以跨分区的会话，要么全部成功，要么全部失败。
```

### 2.producer事务

```
    为了实现跨分区跨会话的事务，需要引入一个全局唯一的Transaction ID，并将Producer获得的PID和Transaction ID绑定。这样当Producer重启后就可以通过正在进行的Transaction ID获得原来的PID。

    为了管理Transaction，Kafka引入了新的组件Transaction Coordinator。Producer就是通过和Transaction Coordinator交互获得Transaction ID对应的任务状态。

    Transaction Coordinator还负责所有写入kafka的内部Topic，这样即使整个服务重启，由于事务状态得到保存，进行中的事务状态可以的得到恢复，从而继续进行。

```

### 3.Consumer事务

```
    上述事务机制主要从Producer方面考虑，对于Consumer而言，事务的保证就会相对较弱，尤其是无法保证Commit的信息被精确消费。

    这是由于Consumer可以通过offset访问任意信息，而且不同的Segment File生命周期不同，同一事物的消费可能会出现重启后被删除的情况。
```

## kafka监控

### 启动监控端口

```
[root@elk101.oldboyedu.com ~]# egrep export /oldboy/softwares/kafka/bin/kafka-server-start.sh 
    export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$base_dir/../config/log4j.properties"
    # export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
    export KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"
[root@elk101.oldboyedu.com ~]# 
[root@elk101.oldboyedu.com ~]# vim /oldboy/softwares/kafka/bin/kafka-server-start.sh  # 注意前后修改的变化哟~
[root@elk101.oldboyedu.com ~]# 
[root@elk101.oldboyedu.com ~]# egrep export /oldboy/softwares/kafka/bin/kafka-server-start.sh 
    export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:$base_dir/../config/log4j.properties"
    # export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
    # export KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"
    export KAFKA_HEAP_OPTS="-server -Xmx256M -Xms256M -XX:PermSize=128m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 -XX:ConcGCThreads=5 -XX:InitiatingHeapOccupancyPercent=70"    
    export JMX_PORT="8888"
[root@elk101.oldboyedu.com ~]# 

相关参数说明：
    KAFKA_HEAP_OPTS:
        设置kafka的堆内存大小。以下是本案例中涉及到有关堆内存调优的相关参数:
            "-Xms256M":
                表示设置JVM启动内存的最小值为256M，必须以M为单位。
                kafka项目推荐设置为5-6G即可。因为kafka并不是特别吃内存，它的数据是存储在磁盘上的。

            "-Xmx256M":
                表示设置JVM启动内存的最大值为256M，必须以M为单位。将-Xmx和-Xms设置为一样可以避免JVM内存自动扩展。
                kafka项目推荐设置为5-6G即可。因为kafka并不是特别吃内存，它的数据是存储在磁盘上的。

            "-XX:PermSize=128m":
                表示JVM初始分配的永久代(方法区)的容量，必须以M为单位。

            "-XX:+UseG1GC":
                表示让JVM使用G1垃圾收集器
        
            "-XX:MaxGCPauseMillis=200":
                设置每次年轻代垃圾回收的最长时间为200ms，如果无法满足此时间，JVM会自动调整年轻代大小，以满足此值。

            "-XX:ParallelGCThreads=8":
                设置并行垃圾回收的线程数，此值可以设置与机器处理器数量相等。

            "-XX:ConcGCThreads=5":
                设置Concurrent Mark Sweep(简称"CMS"，CMS处理器关注的是停顿时间。由于CMS处理器较为复杂，因此该收集器参数较多，这里只是冰山一角，感兴趣的小伙伴可自行查阅相关文档)并发线程数。

            "-XX:InitiatingHeapOccupancyPercent=70":
                该参数可以指定当整个堆使用率达到多少时，触发并发标记周期的执行。默认值是45，即当堆的使用率达到45%，执行并发标记周期，该值一旦设置，始终都不会被G1修改。
                也就是说，G1就算为了满足MaxGCPauseMillis也不会修改此值。如果该值设置的很大，导致并发周期迟迟得不到启动，那么引起FGC的几率将会变大。如果过小，则会频繁标记，GC线程抢占应用程序CPU资源，性能将会下降。 

    JMX_PORT:
        设置JMX监控的端口。

温馨提示:
    "-Xms"和"-Xmx"在实际生产环境中我们通常会设置成相同的值，这是为了避免在生产环境由于heap内存扩大或缩小导致应用停顿，降低延迟，同时避免每次垃圾回收完成后JVM重新分配内存。

```

### 使用mysql创建 kafka_eagle所需的数据库和用户并授权

### 安装kafka_eagle 

下载

https://www.kafka-eagle.org/

解压

环境变量配置

修改配置文件

## 压测

```
install -d /tmp/kafka-test/

vi oldboyedu-kafka-test.sh 
inohup kafka-consumer-perf-test.sh --broker-list 10.0.0.106:9092,10.0.0.107:9092,10.0.0.108:9092 --topic oldboyedu-kafka-2021 --messages 100000000 --fetch-size 1048576 --threads 10  &> /tmp/kafka-test/oldboyedu-kafka-consumer.log &


nohup kafka-producer-perf-test.sh --num-records 100000000 --record-size 1000 --topic oldboyedu-kafka-2021 --throughput 1000000 --producer-props bootstrap.servers=10.0.0.106:9092,10.0.0.107:9092,10.0.0.108:9092 &> /tmp/kafka-test/oldboyedu-kafka-producer.log &

在生产环境中，一定要弄清楚，哪儿是生产者，哪儿是消费者，再进行脚本的压测
```

