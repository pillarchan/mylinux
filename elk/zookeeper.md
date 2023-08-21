# zookeeper

## 1.概念

1. ### 什么是zookeeper

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

2. ### zookeeper的由来

   ```
        zookeeper由雅虎(Yahoo!)研究院开发，它是一个开源的分布式的协同服务系统，为分布式应用提供协调服务的Apache项目。            zookeeper的设计目标是将那些复杂且容易出错的分布式系统服务封装起来，抽象出一个高效可靠的原语集，并以一系列简单的接口提供给用户使用。        大数据生态系统里的很多组件的命名都是某个动物或者昆虫，比如Hadoop是大象，hive是蜜蜂，zookeeper是动物管理员，顾名思义就是管理大数据生态系统各组件的管理员。        官网地址:                https://zookeeper.apache.org/
   ```

   

3. ### 发展历史

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
      2. zookeeper 二进制包
   3. 
   4. 
   5. 
   6. 
   7. 
   8. 
      1. 
         