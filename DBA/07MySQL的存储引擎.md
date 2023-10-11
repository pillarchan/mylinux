[TOC]

# 一.MySQL的存储引擎概述

## 1.什么是存储引擎

### 1.1Oracle MySQL存储引擎概述

```
    存储引擎相当于MySQL内置的文件系统，其作用是和Linux中的文件系统相似。

    我们可以为不同的表设置不同的存储引擎，Oracle MySQL支持的存储引擎如下所示:
        mysql> SHOW ENGINES;  # 查看MySQL server的存储引擎(查看你的MySQL现在已经提供什么存储数据库)
        +--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
        | Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
        +--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
        | PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
        | CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
        | MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
        | BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
        | InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
        | MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
        | ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
        | MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
        | FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
        +--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
        9 rows in set (0.00 sec)
        
        mysql> 
        mysql> SHOW VARIABLES LIKE '%storage_engine%';  # 查看MySQL server当前默认的存储引擎
        +----------------------------------+--------+
        | Variable_name                    | Value  |
        +----------------------------------+--------+
        | default_storage_engine           | InnoDB |
        | default_tmp_storage_engine       | InnoDB |
        | disabled_storage_engines         |        |
        | internal_tmp_disk_storage_engine | InnoDB |
        +----------------------------------+--------+
        4 rows in set (0.01 sec)
        
        mysql> 

```

### 1.2Oracle MySQL各个存储引擎概述(摘自《高性能MySQL》一书)

```
    InnoDB储存引擎:
        InnoDB是MySQL的默认事务型引擎，也是最重要的，使用最广泛的存储引擎，它被设计用来处理大量的短期(short-lived)事务，短期事务大部分情况是正常的提交的，很少会有被回滚，InnoDB性能和自动恢复性。
        使得它在非事务型储存的需求中也很流行，除非有非常特别的原因需要使用其他的储存引擎，否则应该优先考虑InnoDB引擎。
        如果要学习储存引擎，InnoDB也是一个非常值得花最多的时间去深入学习的对象，收益肯定比将时间平均花在每个储存引擎的学习上要高得多。
        
    MyISAM储存引擎:
        在MySQL5.1及之前的版本，MyISAM是默认的储存引擎，MyISAM提供看大量的特性，包括全文索引、压缩、空间函数(GIS)等。
        但是MyISAM不支持事务和行级锁，而且有一个毫无疑问的缺陷的是奔溃后无法安全恢复，正是由于MyISAM引擎的缘故，即使MySQL支持事务已经很长时间了，在很多人的概念中MySQL还是非事务型数据库。
        尽管MyISAM引擎不支持事务，不支持崩溃后的安全恢复，但它也绝不是一无是处的。对于只读的数据，或者表比较小、可以忍受修复(repair)操作，则依然可以继续使用MyISAM(但请不要默认使用MyISAM，而是应当默认使用InnoDB).
        
    MySQL内建的其他储存引擎:
        MySQL还有一些有特殊用途储存引擎，在新版本中，有些可能因为一些原因已经不再支持，另外还有些会继续支持，但是明确地启用后才能使用。
            (1)Archive引擎
                Archive储存引擎只支持INSERT和SELECT操作，在MySQL5.1之前也支持索引。
                Archive引擎会缓存所有的写并利用zlib对插入的行进行压缩,所以比MyISAM表的磁盘I/O更少，但是每次SELECT查询都需要执行全表扫描。
                所以Archive表适合日志和数据采集类应用,这类应用做数据分析时往往需要全表扫描,或者在一些需要更快速的INSERT操作的场合下也可以使用。
                Archive引擎支持行级锁和专用的缓冲区,所以可以实现高发的插入。在一个查询开始直到返回表中存在的所有行数之前, Archive引擎会阻止其他的SELECT执行,以实现一致性读。
                另外,也实现了批量插入在完成之前对读操作是不可见的。这种机制模仿了事务和MVCC的一些特性,但Archive引擎不是一个事务型的引擎,而是一个针对高速插入和压缩做了优化的简单引擎。
            (2)Blackhole引擎
                Blackhole引擎没有实现任何的存储机制，它会丢弃所有插入的数据，不做任何保存。
                但是服务器会记录Blackhole表的日志，所以可以用于复制数据到备库，或者只是简单地记录到日志，这种特殊的存储引擎可以在一些特殊的复制架构和日志审核时发挥作用但这种应用方式我们碰到过很多问题，因此并不推荐。
            (3)csv引擎
                csv引擎可以将普通的csv文件(逗号分割值的文件)作为MySQL的表来处理,但这种表不支持索引。
                CsV引擎可以在数据库运行时拷入或者拷出文件可以将Excel等电子表格软件中的数据存储为CSV文件然后复制到MySQL数据目录下,就能在MySQ中打开使用。
                同样,如果将数据写入到一个CSV引擎表,其他的外部程序也能立即从表的数据文件中读取CSV格式的数据因此CV引擎可以作为一种数据交换的机制,非常有用
            (4)Federated引擎
                Federated引擎是访问其他MySQL服务器的一个代理，它会创建一个到远程MySQL服务器的客户端连接，并将查询传输到远程服务器执行，然后提取或者发送需要的数据。
                最初设计该存储引擎是为了和企业级数据库如Microsoft SQL Server和Oracle的类似特性竞争的，可以说更多的是一种市场行为。
                尽管该引擎看起来提供了一种很好的跨服务器的灵活性,但也经常带来问题,因此默认是禁用的 MariaDB使用了它的一个后续改进版本,叫做FederatedX。
            (5)Memory引擎
                如果需要快速地访问数据,并且这些数据不会被修改,重启以后丢失也没有关系,那么使用Memory表(以前也叫做HEAP表)是非常有用的。            
                Memory表至少比MyISAM表要快一个数量级,因为所有的数据都保存在内存中,不需要进行磁盘IO。Memory表的结构在重启以后还会保留，但数据会丢失。
                Memroy表在很多场景可以发挥好的作用:
                    1)用于查找(lookup)或者映射(mapping)表,例如将邮编和州名映射的表;
                    2)用于缓存周期性聚合数据(periodically aggregated data)的结果;
                    3)用于保存数据分析中产生的中间数据;
                    Memory表支持Hash索引，因此查找操作非常快,虽然Memory表的速度非常快,但还是无法取代传统的基于磁盘的表, Memroy表是表级锁,因此并发写入的性能较低。
                它不支持BLOB或TEXT类型的列,并且每行的长度是固定的，所以即使指定了VARCHAR列实际存储时也会转换成CHAR，这可能导致部分内存的浪费(其中一些限制在Percona版本已经解决)。
                如果MySQL在执行查询的过程中需要使用临时表来保存中间结果,内部使用的临时表就是Memory表,如果中间结果太大超出了 Memory表的限制,或者含有bloB或text字段,则临时表会转换成 MyISAM表。在后续的章节还会继续讨论该问题。
                人们经常混淆Memory表和临时表，临时表是指使用CREATE TEMPORARY TABLE语句创建的表,它可以使用任何存储引擎,因此和 Memory表不是一回事临时表只在单个连接中可见,当连接断开时,临时表也将不复存在。
            (6)Merge引擎
                Merge引擎是MyISAM引擎的一个变种。 Merge是由多个表合并而来的虚拟表。如果将MySQL用于日志或者数据仓库类应用,该引擎可以发挥作用。但是引入分区功能后,该引擎已经被放弃。
            (7)NDB集群引擎
                2003年,当时的MySQL AB公司从索尼爱立信公司收购了NDB数据库,然后开发了NDB集群存储引擎,作为SQL和NDB原生协议之间的接口。 
                MySQL服务器、NDB集群存储引擎,以及分布式的 share-nothing-的容灾的、高可用的NDB数据库的组合,被称为MySQL集群(MySQLMySQLClustcs)。
```

### 1.3其它分支的MySQL存储引擎

```
    众所周知，Oracle MySQL Community Edition是开源的版本，在基于该版本之上做改进的MySQL其它分支中，有两个代表非常优秀，一个是Percona，另一个则是MariaDB。

    MariaDB使用的默认存储引擎自然也是InnoDB存储引擎，而Percona默认的存储引擎则是XtraDB。据说XtraDB存储引擎的性能要比InnoDB性能还要高哟~

    除了上述提到的存储引擎外，还有比较优秀的存储引擎，比如TokuDB，MyRocks等。

    TokuDB存储引擎:
        TokuDB存储引擎用于高性能和写入密集型环境，可提供更高的压缩率和更好的性能。该存储引擎是由percona公司研发的。
        TokuDB已被其上游维护者弃用。它已从MariaDB 10.5禁用，并已在MariaDB 10.6 - MDEV-19780中删除。MariaDB官方建议使用MyRocks作为长期迁移路径。
        推荐阅读:
            https://www.percona.com/doc/percona-tokudb/index.html
            https://mariadb.com/kb/en/tokudb/
        

    MyRocks存储引擎:
        MyRocks是将RocksDB数据库添加到MariaDB的存储引擎。RocksDB是一个LSM数据库，具有很高的压缩率，已针对闪存进行了优化。
        总的来说，相比InnoDB，MyRocks具有以下特点:
            (1)占用更少的存储空间，能够降低存储成本，提高热点缓存效率;
            (2)具备更小的写放大比，能够更高效利用存储IO带宽;
            (3)将随机写变为顺序写，提高了写入性能，延长SSD使用寿命;
            (4)通过参数优化降低了主从复制延迟，因此，在数据量大、写密集型等业务场景下非常适用;
            (5)此外，作为同样的MySQL写和空间优化方案，MyRocks具有更好的社区生态，适合用于替换TokuDB实例。MyRocks高效的缓存利用率，成熟的故障恢复和主从复制机制，使得其也可以作为Redis的持久化方案。
        推荐阅读:
            https://mariadb.com/kb/en/myrocks/

    温馨提示:
        综上所述，TokuDB和MyRocks的确是很优秀的存储引擎，但在生产环境中推荐大家还是使用InnoDB，毕竟InnoDB发展这么多年了，其稳定性众所周知，这也是为什么Oracle MySQL和MariaDB均采用InnoDB为默认的存储原因之一吧。
        本章节主要介绍的是Oracle MySQL的InnoDB存储引擎，之所以给大家提出了TokuDB和MyRocks存储引擎，目的在于大家以后再生产环境中想要用到类似的功能，可以先做一个知识储备，如果有类似的需求可以自行查阅相关文档。

```



## 2.Oracle MySQL Community Edition InnoDB的核心特性

```
    InnoDB的存储引擎的特点如下所示，但我们并不会逐一介绍每一个特性，而是有选择性的介绍我们关心的参数。

    InnoDB的核心特性包括但不限于以下特性:
        (1)MVCC:
            多版本并发控制。
        (2)群集索引:
            可以理解为"聚簇索引"。
        (3)自适应哈希索引:
            就是我们前面提到过的AHI。
        (4)更改缓冲:
            就是我们前面提到过的Change buffer。用于保存临时修改的辅助索引更新信息。
        (5)事务:
            支持事务处理，会有专门的章节讲解。
        (6)支持热备:
            即再不停服务的前提下，还可以正常备份数据库。
        (7)行级锁:
            支持锁粒度为行级锁。
        (8)外键:
            外键可以维护数据的一致性，是一个不错的解决方案，但本身占用MySQL的性能，因此在开发过程中，使用的并不是特别流行。
        (9)自动故障恢复
        (10)多缓冲区池

    温馨提示:
        上述特点均是InnoDB独有的，也就是说MyIsam并不具有上述列举的功能哟~
```

## 3.Oracle MySQL Community Edition InnoDB存储引擎与Oracle MySQL Community Edition MyIsam存储引擎的区别

```
    上述列举的InnoDB核心特性基本上MaIsam均不支持。
        (1)myIsam并不支持MVCC;
        (2)myIsam并不支持行级锁，仅支持表级锁，因此并不支持高并发修改的场景;
        (3)myIsam并不支持事务;
        (4)myIsam并不支持chanage buffer;
        (5)myIsam并不支持外键;
        (6)myIsam并不支持热备;
        (7)myIsam并不支持自适应哈希索引;
        (8)myIsam并不支持聚簇索引;
        (9)myIsam并不支持自动故障恢复;
        (10)myIsam并不支持多缓冲区池;
```





# 二.MySQL的存储引擎基础管理命令

## 1.查看会话存储引擎

```
mysql> SELECT @@DEFAULT_STORAGE_ENGINE;
+--------------------------+
| @@DEFAULT_STORAGE_ENGINE |
+--------------------------+
| InnoDB                   |
+--------------------------+
1 row in set (0.00 sec)

mysql> 

```

![image-20210717171427460](09-老男孩教育-MySQL的存储引擎.assets\image-20210717171427460.png)



## 2.修改默认的存储引擎

### 2.1修改当前会话级别的存储引擎，并不会影响新产生的会话，也无需重启MySQL实例

```
        [root@mysql107.mytest ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 20
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql>
        mysql> SELECT @@DEFAULT_STORAGE_ENGINE;
        +--------------------------+
        | @@DEFAULT_STORAGE_ENGINE |
        +--------------------------+
        | InnoDB                   |
        +--------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SET DEFAULT_STORAGE_ENGINE=myisam;  # 影响的是当前会话的存储引擎
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT @@DEFAULT_STORAGE_ENGINE;  # 会立即修改当前会话的存储引擎
        +--------------------------+
        | @@DEFAULT_STORAGE_ENGINE |
        +--------------------------+
        | MyISAM                   |
        +--------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> QUIT
        Bye
        [root@mysql107.mytest ~]# 
        [root@mysql107.mytest ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 20
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql> 
        mysql> SELECT @@DEFAULT_STORAGE_ENGINE;  # 并不会影响到新打开的会话
        +--------------------------+
        | @@DEFAULT_STORAGE_ENGINE |
        +--------------------------+
        | InnoDB                   |
        +--------------------------+
        1 row in set (0.00 sec)
        
        mysql> 

```

### 2.2修改全局级别的存储引擎(仅影响新会话)，也无需重启MySQL实例

```
        [root@mysql107.mytest ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 20
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql>
        mysql> SELECT @@DEFAULT_STORAGE_ENGINE;  
        +--------------------------+
        | @@DEFAULT_STORAGE_ENGINE |
        +--------------------------+
        | InnoDB                   |
        +--------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SET GLOBAL DEFAULT_STORAGE_ENGINE=myisam;  # 修改全局的存储引擎
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT @@DEFAULT_STORAGE_ENGINE;  # 发现对当前会话并没有任何影响
        +--------------------------+
        | @@DEFAULT_STORAGE_ENGINE |
        +--------------------------+
        | InnoDB                   |
        +--------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> QUIT
        Bye
        [root@mysql107.mytest ~]# 
        [root@mysql107.mytest ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 20
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql> SELECT @@DEFAULT_STORAGE_ENGINE;  # 不难发现，新会话的存储引擎的确被修改啦~
        +--------------------------+
        | @@DEFAULT_STORAGE_ENGINE |
        +--------------------------+
        | MyISAM                   |
        +--------------------------+
        1 row in set (0.00 sec)
        
        mysql>   

```

### 2.3写入配置文件(例如:"/etc/my.cnf")，可以永久生效！推荐使用默认的InnoDB存储引擎

```
    写入配置文件(例如:"/etc/my.cnf")，可以永久生效，需要重启MySQL数据库！推荐使用默认的InnoDB存储引擎
        [mysqld]
        DEFAULT_STORAGE_ENGINE=MyISAM
        
```

## 3.查看每个表的存储引擎

### 3.1方案一

```
mysql> SHOW CREATE TABLE mytest.student\G
*************************** 1. row ***************************
       Table: student
Create Table: CREATE TABLE `student` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '学生编号ID',
  `name` varchar(30) NOT NULL COMMENT '学生姓名',
  `age` tinyint(3) unsigned DEFAULT NULL COMMENT '年龄',
  `gender` enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
  `time_of_enrollment` datetime DEFAULT NULL COMMENT '报名时间',
  `address` varchar(255) NOT NULL COMMENT '家庭住址',
  `mobile_number` bigint(20) NOT NULL COMMENT '手机号码',
  `remarks` varchar(255) DEFAULT NULL COMMENT '备注信息',
  PRIMARY KEY (`id`),
  UNIQUE KEY `mobile_number` (`mobile_number`),
  KEY `my_index01` (`name`,`age`,`gender`)
) ENGINE=InnoDB AUTO_INCREMENT=100016 DEFAULT CHARSET=utf8mb4
1 row in set (0.00 sec)

mysql> 

```

### 3.2方案二

```
    mysql> USE mytest;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A
    
    Database changed
    mysql> 
    mysql> SHOW TABLE STATUS LIKE 'student'\G
    *************************** 1. row ***************************
               Name: student
             Engine: InnoDB
            Version: 10
         Row_format: Dynamic
               Rows: 99622
     Avg_row_length: 110
        Data_length: 11026432
    Max_data_length: 0
       Index_length: 10010624
          Data_free: 4194304
     Auto_increment: 100016
        Create_time: 2021-01-25 19:23:25
        Update_time: 2021-01-25 19:58:38
         Check_time: NULL
          Collation: utf8mb4_general_ci
           Checksum: NULL
     Create_options: 
            Comment: 
    1 row in set (0.00 sec)
    
    mysql> 

```

### 3.3方案三

```
    mysql> SHOW TABLES;
    +-----------------------+
    | Tables_in_mytest |
    +-----------------------+
    | call_police           |
    | staff                 |
    | student               |
    +-----------------------+
    3 rows in set (0.00 sec)
    
    mysql> 
    mysql> SHOW TABLE STATUS\G
    *************************** 1. row ***************************
               Name: call_police
             Engine: InnoDB
            Version: 10
         Row_format: Dynamic
               Rows: 4
     Avg_row_length: 4096
        Data_length: 16384
    Max_data_length: 0
       Index_length: 16384
          Data_free: 0
     Auto_increment: 5
        Create_time: 2021-01-25 12:41:13
        Update_time: 2021-01-25 12:42:00
         Check_time: NULL
          Collation: utf8mb4_general_ci
           Checksum: NULL
     Create_options: 
            Comment: 
    *************************** 2. row ***************************
               Name: staff
             Engine: InnoDB
            Version: 10
         Row_format: Dynamic
               Rows: 0
     Avg_row_length: 0
        Data_length: 16384
    Max_data_length: 0
       Index_length: 16384
          Data_free: 0
     Auto_increment: 1
        Create_time: 2021-01-18 23:40:41
        Update_time: NULL
         Check_time: NULL
          Collation: utf8mb4_general_ci
           Checksum: NULL
     Create_options: 
            Comment: 
    *************************** 3. row ***************************
               Name: student
             Engine: InnoDB
            Version: 10
         Row_format: Dynamic
               Rows: 99622
     Avg_row_length: 110
        Data_length: 11026432
    Max_data_length: 0
       Index_length: 10010624
          Data_free: 4194304
     Auto_increment: 100016
        Create_time: 2021-01-25 19:23:25
        Update_time: 2021-01-25 19:58:38
         Check_time: NULL
          Collation: utf8mb4_general_ci
           Checksum: NULL
     Create_options: 
            Comment: 
    3 rows in set (0.00 sec)
    
    mysql> 

```

## 4.通过information_schema数据库确认每个表的存储引擎

```
    mysql> SELECT 
        ->     table_schema AS 数据库,table_name AS 表, engine AS 存储引擎
        -> FROM
        ->     information_schema.tables
        -> WHERE
        ->     table_schema NOT IN ('sys','mysql','information_schema','performance_schema');
    +-------------+-----------------+--------------+
    | 数据库      | 表              | 存储引擎     |
    +-------------+-----------------+--------------+
    | school      | course          | InnoDB       |
    | school      | student         | InnoDB       |
    | school      | student_score   | InnoDB       |
    | school      | teacher         | InnoDB       |
    | world       | city            | InnoDB       |
    | world       | country         | InnoDB       |
    | world       | countrylanguage | InnoDB       |
    | mytest | call_police     | InnoDB       |
    | mytest | staff           | InnoDB       |
    | mytest | student         | InnoDB       |
    +-------------+-----------------+--------------+
    10 rows in set (0.00 sec)
    
    mysql> 

```

## 5.修改一个表的存储引擎

```
    将一张表为MyISAM的存储引擎修改为InnoDB的存储引擎，其操作如下所示:
        mysql> SHOW CREATE TABLE mytest.student\G
        *************************** 1. row ***************************
               Table: student
        Create Table: CREATE TABLE `student` (
          `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '学生编号ID',
          `name` varchar(30) NOT NULL COMMENT '学生姓名',
          `age` tinyint(3) unsigned DEFAULT NULL COMMENT '年龄',
          `gender` enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
          `time_of_enrollment` datetime DEFAULT NULL COMMENT '报名时间',
          `address` varchar(255) NOT NULL COMMENT '家庭住址',
          `mobile_number` bigint(20) NOT NULL COMMENT '手机号码',
          `remarks` varchar(255) DEFAULT NULL COMMENT '备注信息',
          PRIMARY KEY (`id`),
          UNIQUE KEY `mobile_number` (`mobile_number`),
          KEY `my_index01` (`name`,`age`,`gender`)
        ) ENGINE=MyISAM AUTO_INCREMENT=100016 DEFAULT CHARSET=utf8mb4
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> ALTER TABLE mytest.student ENGINE=InnoDB;
        Query OK, 100007 rows affected (1.67 sec)
        Records: 100007  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SHOW CREATE TABLE mytest.student\G
        *************************** 1. row ***************************
               Table: student
        Create Table: CREATE TABLE `student` (
          `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '学生编号ID',
          `name` varchar(30) NOT NULL COMMENT '学生姓名',
          `age` tinyint(3) unsigned DEFAULT NULL COMMENT '年龄',
          `gender` enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
          `time_of_enrollment` datetime DEFAULT NULL COMMENT '报名时间',
          `address` varchar(255) NOT NULL COMMENT '家庭住址',
          `mobile_number` bigint(20) NOT NULL COMMENT '手机号码',
          `remarks` varchar(255) DEFAULT NULL COMMENT '备注信息',
          PRIMARY KEY (`id`),
          UNIQUE KEY `mobile_number` (`mobile_number`),
          KEY `my_index01` (`name`,`age`,`gender`)
        ) ENGINE=InnoDB AUTO_INCREMENT=100016 DEFAULT CHARSET=utf8mb4
        1 row in set (0.00 sec)
        
        mysql> 

    温馨提示:
        "ALTER TABLE mytest.student ENGINE=InnoDB;"命令我们经常使用它进行InnoDB表的碎片整理。

```

## 6.数据库碎片处理

```
    查看非系统表的数据碎片:
        mysql> SELECT
            ->     TABLE_SCHEMA AS 数据库, TABLE_NAME AS 表, DATA_FREE AS 数据碎片
            -> FROM
            ->     information_schema.tables
            -> WHERE
            ->     table_schema NOT IN ('sys','mysql','information_schema','performance_schema');
        +-------------+-----------------+--------------+
        | 数据库      | 表              | 数据碎片     |
        +-------------+-----------------+--------------+
        | school      | course          |            0 |
        | school      | student         |            0 |
        | school      | student_score   |            0 |
        | school      | teacher         |            0 |
        | world       | city            |      3145728 |
        | world       | country         |            0 |
        | world       | countrylanguage |            0 |
        | mytest | call_police     |            0 |
        | mytest | staff           |            0 |
        | mytest | student         |      4194304 |
        +-------------+-----------------+--------------+
        10 rows in set (0.01 sec)
        
        mysql> 

    常见的碎片处理方案:
        (1)使用"ALTER TABLE mytest.student ENGINE=InnoDB;"命令来进行InnoDB表的碎片整理，当多次执行时，可能效果也不是特别明显，此时可以下面的方案哟;
        (2)我们也可以将数据逻辑导出，手工drop表，然后导入进去，相比上面的命令更加彻底;
        (3)除了上述两种方案外，现在主流的处理方法是对标进行按月分表(paritition,中间件)或者归档表(可以使用"pt-archive"工具)，将业务替换为truncate方式删除数据(删除前请确定一定要有数据的完整备份哟);

```

## 7.常见的面试题

### 7.1将zabbix数据库中的所有表，存储引擎为innodb替换为tokudb

```
mysql> SELECT
    ->     CONCAT("ALTER TABLE ",table_schema,".",table_name," engine=tokudb;")
    -> FROM
    ->     information_schema.tables
    -> WHERE
    ->     table_schema='mytest';
+----------------------------------------------------------------------+
| CONCAT("ALTER TABLE ",table_schema,".",table_name," engine=tokudb;") |
+----------------------------------------------------------------------+
| ALTER TABLE mytest.call_police engine=tokudb;                   |
| ALTER TABLE mytest.staff engine=tokudb;                         |
| ALTER TABLE mytest.student engine=tokudb;                       |
+----------------------------------------------------------------------+
3 rows in set (0.00 sec)

mysql> 
mysql> SELECT
    ->     CONCAT("ALTER TABLE ",table_schema,".",table_name," engine=tokudb;")
    -> FROM
    ->     information_schema.tables
    -> WHERE
    ->     table_schema='mytest'
    -> INTO OUTFILE
    ->     '/tmp/alter_engine_2_tokudb.sql';
Query OK, 3 rows affected (0.00 sec)

mysql> 
mysql> system cat /tmp/alter_engine_2_tokudb.sql;
ALTER TABLE mytest.call_police engine=tokudb;
ALTER TABLE mytest.staff engine=tokudb;
ALTER TABLE mytest.student engine=tokudb;
mysql> 


```

### 7.2将所有非InnoDB业务表查询出来，并修改为InnoDB

```
mysql> SELECT
    ->     CONCAT("ALTER TABLE ",table_schema,".",table_name," engine=InnoDB;")
    -> FROM
    ->     information_schema.tables
    -> WHERE
    ->     engine != 'InnoDB' AND table_schema NOT IN ('sys','performance_schema','information_schema','mysql');
+----------------------------------------------------------------------+
| CONCAT("ALTER TABLE ",table_schema,".",table_name," engine=InnoDB;") |
+----------------------------------------------------------------------+
| ALTER TABLE mytest.student engine=InnoDB;                       |
+----------------------------------------------------------------------+
1 row in set (0.01 sec)

mysql> 
mysql> SELECT
    ->     CONCAT("ALTER TABLE ",table_schema,".",table_name," engine=InnoDB;")
    -> FROM
    ->     information_schema.tables
    -> WHERE
    ->     engine != 'InnoDB' AND table_schema NOT IN ('sys','performance_schema','information_schema','mysql')
    -> INTO OUTFILE
    ->     '/tmp/alter_engine.sql';
Query OK, 1 row affected (0.00 sec)

mysql> 
mysql> system cat /tmp/alter_engine.sql;
ALTER TABLE mytest.student engine=InnoDB;
mysql> 

```

### 7.3假设一张表有2亿行数据，想要按照时间周期删除其中1000万条数据，如果你是DBA，你该如何操作呢?

```
    这种问题并没有标准答案，因此回答面试官尽可能多说几种解决方案。

    以下是参考回答的案例:
        (1)如果2亿行数据表还没有生成，建议在设计表时，采用分区表的方式(比如按月进行分区)，然后删除时使用truncate;
        (2)如果2亿行数据表已经存在，建议使用pt-archive等工具进行归档表，并且删除无用数据;

```



# 三.MySQL的存储引擎的体系结构

## 1.MySQL存储引擎体系结构概述

```
    MySQL存储引擎体系结构我们分为宏观结构和微观结构来进行介绍。

    所谓宏观体系结构指的是我们最直观能看到的一些数据，比如MySQL实例存储的数据目录和文件。

    所谓的微观体系结构指的是我们无法在Linux文件中直接看出来。
```

## 2.MySQL宏观体系结构

```
    如下图所示，对于InnoDB和MyISAM存储引擎其在Linux存储的文件并不相同:
        mysql> system ls -l /mytest/data/mysql23307
        总用量 224032
        -rw-r----- 1 mysql mysql       56 1月  10 21:15 auto.cnf
        -rw------- 1 mysql mysql     1676 1月  10 21:15 ca-key.pem
        -rw-r--r-- 1 mysql mysql     1112 1月  10 21:15 ca.pem
        -rw-r--r-- 1 mysql mysql     1112 1月  10 21:15 client-cert.pem
        -rw------- 1 mysql mysql     1676 1月  10 21:15 client-key.pem
        -rw-r----- 1 mysql mysql        4 1月  25 08:20 docker201.mytest.pid
        -rw-r----- 1 mysql mysql     2009 1月  24 14:35 ib_buffer_pool
        -rw-r----- 1 mysql mysql 79691776 1月  26 12:17 ibdata1
        -rw-r----- 1 mysql mysql 50331648 1月  26 12:17 ib_logfile0
        -rw-r----- 1 mysql mysql 50331648 1月  26 12:17 ib_logfile1
        -rw-r----- 1 mysql mysql 12582912 1月  26 11:44 ibtmp1
        drwxr-x--- 2 mysql mysql     4096 1月  25 11:57 mysql
        -rw-r----- 1 mysql mysql      177 1月  10 21:39 mysql-bin.000001
        -rw-r----- 1 mysql mysql   728334 1月  15 03:35 mysql-bin.000002
        -rw-r----- 1 mysql mysql     5587 1月  17 00:27 mysql-bin.000003
        -rw-r----- 1 mysql mysql     2419 1月  18 23:34 mysql-bin.000004
        -rw-r----- 1 mysql mysql      712 1月  20 15:25 mysql-bin.000005
        -rw-r----- 1 mysql mysql      154 1月  22 07:58 mysql-bin.000006
        -rw-r----- 1 mysql mysql 35483174 1月  24 11:33 mysql-bin.000007
        -rw-r----- 1 mysql mysql     1111 1月  24 14:35 mysql-bin.000008
        -rw-r----- 1 mysql mysql     9122 1月  26 12:15 mysql-bin.000009
        -rw-r----- 1 mysql mysql      414 1月  25 08:20 mysql-bin.index
        -rw-r----- 1 mysql mysql   138173 1月  26 14:51 mysql-err.log
        drwxr-x--- 2 mysql mysql     8192 1月  10 21:15 performance_schema
        -rw------- 1 mysql mysql     1676 1月  10 21:15 private_key.pem
        -rw-r--r-- 1 mysql mysql      452 1月  10 21:15 public_key.pem
        drwxr-x--- 2 mysql mysql      182 1月  20 12:37 school
        -rw-r--r-- 1 mysql mysql     1112 1月  10 21:15 server-cert.pem
        -rw------- 1 mysql mysql     1676 1月  10 21:15 server-key.pem
        drwxr-x--- 2 mysql mysql     8192 1月  10 21:15 sys
        drwxr-x--- 2 mysql mysql      144 1月  25 08:39 world
        drwxr-x--- 2 mysql mysql      157 1月  26 12:15 mytest
        mysql> 
        mysql> system ls -l /mytest/data/mysql23307/mytest
        总用量 10840
        -rw-r----- 1 mysql mysql    8726 1月  25 12:41 call_police.frm
        -rw-r----- 1 mysql mysql  114688 1月  25 12:42 call_police.ibd
        -rw-r----- 1 mysql mysql      67 1月  13 18:04 db.opt
        -rw-r----- 1 mysql mysql    9010 1月  18 23:40 staff.frm
        -rw-r----- 1 mysql mysql  114688 1月  18 23:40 staff.ibd
        -rw-r----- 1 mysql mysql    8926 1月  26 12:15 student.frm
        -rw-r----- 1 mysql mysql 6796316 1月  26 12:15 student.MYD
        -rw-r----- 1 mysql mysql 4030464 1月  26 12:15 student.MYI
        mysql> 

    对于MyISAM存储引擎而言，一张表对应三个文件进行存储(以"student"表为例):
        student.frm:
            存储字典信息，即表的字段定义信息。
        student.MYD:
            存储数据行。
        student.MYI:
            存储索引。

    对于InnoDB存储引擎而言，一张表对应两个文件进行存储(以"call_police"表为例):
        staff.frm：
            属于独立表空间(也有人习惯称为"用户表空间")文件，其功能主要用于存储数据字典信息，即字段信息。
        staff.ibd:
            属于"通用表空间"，存储数据行和索引信息。
        ibdata1(该文件在MySQL数据存放的根目录中):
            属于系统表空间文件，主要作用就是起到一个共享的作用。随着MySQL版本的迭代，不难发现，官方正在为ibdata1文件解耦，把比较关键的数据分别独立出来了。
            在MySQL 5.5版本中，该文件也会存储部分的InnoDB Data Dictionary(即字段信息)，Doublewrite Buffer，Change Buffer磁盘区域和Undo Logs(事务回滚日志)的磁盘区域，不仅如此，该文件还会存储临时表数据以及存储用户数据(即数据行和索引)信息，这会导致随着数据库的量越来越大，从而导致性能降低。
            在MySQL 5.6版本中，该文件也会存储部分的InnoDB Data Dictionary(即字段信息)，Doublewrite Buffer，Change Buffer磁盘区域和Undo Logs(事务回滚日志)的磁盘区域，不仅如此，该文件还会存储临时表数据。
            在MySQL 5.7版本中，该文件也会存储部分的InnoDB Data Dictionary(即字段信息)，Doublewrite Buffer，Change Buffer磁盘区域和Undo Logs(事务回滚日志)的磁盘区域。
            在MySQL 8.0版本中，只保留Change Buffer的磁盘区域，而将InnoDB Data Dictionary(即字段信息)，Doublewrite Buffer磁盘区域和Undo Logs(事务回滚日志)的独立出来。
        ib_logfile0,ib_logfile1,~ib_logfileN(该文件在MySQL数据存放的根目录中):
            属于事务日志文件。和Undo Logs(事务回滚日志)相反，它是属于事务重做日志，即"Redo Logs"。
        ibtmp1(该文件在MySQL数据存放的根目录中):
            在MySQL 5.6版本中，并没有该文件，该文件的功能默认和"ibdata1"文件存放在一起，当然，你也可以手动将它分开。
            在MySQL 5.7版本中引入，属于临时表空间。我们在做排序，分组，多表连接，子查询，逻辑备份等时候都会频繁使用这个临时表。
        ib_buffer_pool(该文件在MySQL数据存放的根目录中):
            在正常关闭数据库的时候，用于存储缓冲区的"热数据"，该文件是顺序I/O存储数据，该文件并不会特别大。
            需要注意的是，如果去所有的"*.frm"文件中拿数据也是可以的，但却避免不了会访问到随机I/O时间。因此ib_buffer_pool文件可以算得上是MySQL的一种优化方案(即减少随机I/O)。
        auto.cnf(该文件在MySQL数据存放的根目录中):
            该文件是在MySQL实例初始化完成时自动生成的一个文件，该文件记录了当前数据库的服务器的UUID，用于唯一标识一台MySQL实例，我们在主从复制的章节会继续介绍它，这里先有个印象即可。
        ca-key.pem，ca.pem，client-cert.pem，client-key.pem(该文件在MySQL数据存放的根目录中):
            这些文件都是和MySQL数据库安全相关的证书文件，需要配置SSL安全加密策略，一般在对数据的安全性要求较高的场景下会用到哟~
        mysql-err.log(该文件在MySQL数据存放的根目录中):
            记录错误日志的文件，该文件名称是可以通过配置"log_error"参数来修改。
        docker201.mytest.pid(该文件在MySQL数据存放的根目录中):
            该文件用于保存MySQL实例的PID信息的文件，该文件名可以通过配置""参数来修改，若不配置，则默认名称为当前的主机名。

    温馨提示:
        (1)值得注意的是，上述总结是针对MySQL 5.7进行说明的，在MySQL 8.0版本中的InnoDB存储是截然不同过哟，这一点在官网的架构图已经画得很明显的。感兴趣的小伙伴请仔细阅读以下文章。
            https://dev.mysql.com/doc/refman/5.6/en/innodb-architecture.html
            https://dev.mysql.com/doc/refman/5.7/en/innodb-architecture.html
            https://dev.mysql.com/doc/refman/8.0/en/innodb-architecture.html
        (2)我们是否可以将"student.frm"，"student.MYD","student.MYI"直接拷贝到其它同版本MySQL实例，并保证数据不丢失呢?
            答: 这是可行的，因为MyISAM表的所有信息均在这三个文件中记录。
        (3)我们是否可以将"staff.frm"，"staff.ibd"直接拷贝到其它同版本MySQL实例，并保证数据不丢失呢?
            答: 这是不可行的，因为InnoDB表的信息不仅仅存储在这两个文件，换句话说，仅存储了部分索引和数据信息，若强行迁移这两个文件可能会导致部分数据丢失！

```


## 3.MySQL微观体系结构

### 表空间(Tablespaces)管理磁盘

```    
    什么是表空间(Tablespaces):
        表空间概念是引入于Oracle数据库，起初为了解决存储空间扩展的问题，MySQL 5.5版本引入了共享表空间模式。
        表空间的功能有点类似于LVM的技术，MySQL存储引擎在使用磁盘存储空间之前，引入了一个Tablespaces(表空间)的功能。
        表空间和文件系统打交道，多个文件系统可以挂在到表空间上，而存储引擎只需和表空间打交道即可，无需和磁盘打交道。当Tablespaces存储空间不足时，只需往表空间添加磁盘挂载点即可。

    表空间管理:
        用户数据默认的存储方式，独立表空间模式。独立表空间和共享表空间是可以相互切换的。
        (1)查看默认表空间模式:
            mysql> SELECT @@INNODB_FILE_PER_TABLE;  # 如果输出为"1"表示当前使用的是独立表空间模式，如果输出的是"0"表示当前使用的是共享表空间模式。
            +-------------------------+
            | @@INNODB_FILE_PER_TABLE |
            +-------------------------+
            |                       1 |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
        (2)如何切换表空间模式:
            mysql> SELECT @@INNODB_FILE_PER_TABLE;
            +-------------------------+
            | @@INNODB_FILE_PER_TABLE |
            +-------------------------+
            |                       1 |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> SET GLOBAL INNODB_FILE_PER_TABLE=0;  # 将独立表空间模式切换为共享表空间模式。修改完成之后，只会影响新创建的表，之前创建的表并不会受影响哟~
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT @@INNODB_FILE_PER_TABLE;
            +-------------------------+
            | @@INNODB_FILE_PER_TABLE |
            +-------------------------+
            |                       0 |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            
            温馨提示:
                1)如果想要永久生效的话，可以将配置("innodb_file_per_table=0")写入"/etc/my.cnf"配置文件即可;
                2)再次提示，修改完成之后，只会影响新创建的表，之前创建的表并不会受影响哟;

        (3)如何扩展共享表空间大小和个数
            1)如果没有设置参数，我们可以通过下面的命令查看默认的配置
                mysql> SELECT @@innodb_data_file_path;
                +-------------------------+
                | @@innodb_data_file_path |
                +-------------------------+
                | ibdata1:12M:autoextend  |
                +-------------------------+
                1 row in set (0.00 sec)
                
                mysql> 

            2)通常在初始化数据之前，就设定好参数，需要在"/etc/my.cnf"文件中加入以下配置即可:
                innodb_data_file_path=ibdata1:1G;ibdata2:1G:autoextend

            3)已运行的数据库上扩展多个ibdata文件，如下所示:
                [root@mysql107.mytest ~]# netstat -untalp | grep ysql
                tcp6       0      0 :::33060                :::*                    LISTEN      931/mysqld          
                tcp6       0      0 :::23306                :::*                    LISTEN      933/mysqld          
                tcp6       0      0 :::23307                :::*                    LISTEN      930/mysqld          
                tcp6       0      0 :::23308                :::*                    LISTEN      931/mysqld          
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# netstat -untalp | grep mysql
                tcp6       0      0 :::33060                :::*                    LISTEN      931/mysqld          
                tcp6       0      0 :::23306                :::*                    LISTEN      933/mysqld          
                tcp6       0      0 :::23307                :::*                    LISTEN      930/mysqld          
                tcp6       0      0 :::23308                :::*                    LISTEN      931/mysqld          
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# netstat -untalp | grep mysql
                tcp6       0      0 :::33060                :::*                    LISTEN      931/mysqld          
                tcp6       0      0 :::23306                :::*                    LISTEN      933/mysqld          
                tcp6       0      0 :::23307                :::*                    LISTEN      930/mysqld          
                tcp6       0      0 :::23308                :::*                    LISTEN      931/mysqld          
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# ll /mytest/data/mysql23307/ -h  # 注意观察正在运行的MySQL实例的ibdata1文件实际大小
                总用量 219M
                -rw-r----- 1 mysql mysql   56 1月  10 21:15 auto.cnf
                -rw------- 1 mysql mysql 1.7K 1月  10 21:15 ca-key.pem
                -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 ca.pem
                -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 client-cert.pem
                -rw------- 1 mysql mysql 1.7K 1月  10 21:15 client-key.pem
                -rw-r----- 1 mysql mysql    4 1月  25 08:20 docker201.mytest.pid
                -rw-r----- 1 mysql mysql 2.0K 1月  24 14:35 ib_buffer_pool
                -rw-r----- 1 mysql mysql  76M 1月  26 12:17 ibdata1
                -rw-r----- 1 mysql mysql  48M 1月  26 12:17 ib_logfile0
                -rw-r----- 1 mysql mysql  48M 1月  26 12:17 ib_logfile1
                -rw-r----- 1 mysql mysql  12M 1月  26 11:44 ibtmp1
                drwxr-x--- 2 mysql mysql 4.0K 1月  25 11:57 mysql
                -rw-r----- 1 mysql mysql  177 1月  10 21:39 mysql-bin.000001
                -rw-r----- 1 mysql mysql 712K 1月  15 03:35 mysql-bin.000002
                -rw-r----- 1 mysql mysql 5.5K 1月  17 00:27 mysql-bin.000003
                -rw-r----- 1 mysql mysql 2.4K 1月  18 23:34 mysql-bin.000004
                -rw-r----- 1 mysql mysql  712 1月  20 15:25 mysql-bin.000005
                -rw-r----- 1 mysql mysql  154 1月  22 07:58 mysql-bin.000006
                -rw-r----- 1 mysql mysql  34M 1月  24 11:33 mysql-bin.000007
                -rw-r----- 1 mysql mysql 1.1K 1月  24 14:35 mysql-bin.000008
                -rw-r----- 1 mysql mysql 9.0K 1月  26 12:15 mysql-bin.000009
                -rw-r----- 1 mysql mysql  414 1月  25 08:20 mysql-bin.index
                -rw-r----- 1 mysql mysql 135K 1月  26 14:51 mysql-err.log
                drwxr-x--- 2 mysql mysql 8.0K 1月  10 21:15 performance_schema
                -rw------- 1 mysql mysql 1.7K 1月  10 21:15 private_key.pem
                -rw-r--r-- 1 mysql mysql  452 1月  10 21:15 public_key.pem
                drwxr-x--- 2 mysql mysql  182 1月  20 12:37 school
                -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 server-cert.pem
                -rw------- 1 mysql mysql 1.7K 1月  10 21:15 server-key.pem
                drwxr-x--- 2 mysql mysql 8.0K 1月  10 21:15 sys
                drwxr-x--- 2 mysql mysql  144 1月  25 08:39 world
                drwxr-x--- 2 mysql mysql  157 1月  26 12:15 mytest
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# mysql -S /tmp/mysql23307.sock
                Welcome to the MySQL monitor.  Commands end with ; or \g.
                Your MySQL connection id is 24
                Server version: 5.7.31-log MySQL Community Server (GPL)
                
                Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
                
                Oracle is a registered trademark of Oracle Corporation and/or its
                affiliates. Other names may be trademarks of their respective
                owners.
                
                Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
                
                mysql> 
                mysql> SELECT @@innodb_data_file_path;  # 注意观察默认的大小哈~
                +-------------------------+
                | @@innodb_data_file_path |
                +-------------------------+
                | ibdata1:12M:autoextend  |
                +-------------------------+
                1 row in set (0.00 sec)
                
                mysql> 
                mysql> SET GLOBAL innodb_data_file_path="ibdata1:76M;ibdata2:128M;ibdata3:128M:autoextend";  # 这里的76M参考上面ibdata1文件的实际大小哟~可惜呀，我本次修改并未生效，说是innodb_data_file_path是只读的！
                ERROR 1238 (HY000): Variable 'innodb_data_file_path' is a read only variable
                mysql> 
                mysql> QUIT
                Bye
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# vim /mytest/softwares/mysql23307/my.cnf  # 既然不能在上面的命令行上修改，那就只能修改配置文件了
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# tail -1 /mytest/softwares/mysql23307/my.cnf  # 注意哈，我这里的配置将ibdata1的大小设置为76M，改大小参考自已有文件的实际大小哟~但是我又手写了2个文件ibdata2和ibdata3。
                innodb_data_file_path=ibdata1:76M;ibdata2:128M;ibdata3:128M:autoextend
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# systemctl restart mysqld23307
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# mysql -S /tmp/mysql23307.sock
                Welcome to the MySQL monitor.  Commands end with ; or \g.
                Your MySQL connection id is 2
                Server version: 5.7.31-log MySQL Community Server (GPL)
                
                Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
                
                Oracle is a registered trademark of Oracle Corporation and/or its
                affiliates. Other names may be trademarks of their respective
                owners.
                
                Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
                
                mysql> 
                mysql> SELECT @@innodb_data_file_path;  # 我们修改成功啦~
                +--------------------------------------------------+
                | @@innodb_data_file_path                          |
                +--------------------------------------------------+
                | ibdata1:76M;ibdata2:128M;ibdata3:128M:autoextend |
                +--------------------------------------------------+
                1 row in set (0.00 sec)
                
                mysql> 
                mysql> QUIT
                Bye
                [root@mysql107.mytest ~]# 
                [root@mysql107.mytest ~]# ll -h /mytest/data/mysql23307/  # 注意哈，观察ibdata1的大小默认依旧是73M，而ibdata2和ibdata3的大小为128MB，该磁盘空间会被立即分配哟~测试时要注意自己的虚拟机磁盘空间!
                总用量 475M
                -rw-r----- 1 mysql mysql   56 1月  10 21:15 auto.cnf
                -rw------- 1 mysql mysql 1.7K 1月  10 21:15 ca-key.pem
                -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 ca.pem
                -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 client-cert.pem
                -rw------- 1 mysql mysql 1.7K 1月  10 21:15 client-key.pem
                -rw-r----- 1 mysql mysql    6 1月  26 22:51 docker201.mytest.pid
                -rw-r----- 1 mysql mysql  477 1月  26 22:51 ib_buffer_pool
                -rw-r----- 1 mysql mysql  76M 1月  26 22:51 ibdata1
                -rw-r----- 1 mysql mysql 128M 1月  26 22:50 ibdata2  # 注意哈，ibdata2和ibdata3的文件大小是立即分配的，尽管实际上并没有占用这么多空间，立即分配的好处就是顺序I/O，如果使用时再分配的话，就可能有大量的随机I/O。  
                -rw-r----- 1 mysql mysql 128M 1月  26 22:50 ibdata3
                -rw-r----- 1 mysql mysql  48M 1月  26 22:51 ib_logfile0
                -rw-r----- 1 mysql mysql  48M 1月  26 22:51 ib_logfile1
                -rw-r----- 1 mysql mysql  12M 1月  26 22:51 ibtmp1
                drwxr-x--- 2 mysql mysql 4.0K 1月  25 11:57 mysql
                -rw-r----- 1 mysql mysql  177 1月  10 21:39 mysql-bin.000001
                -rw-r----- 1 mysql mysql 712K 1月  15 03:35 mysql-bin.000002
                -rw-r----- 1 mysql mysql 5.5K 1月  17 00:27 mysql-bin.000003
                -rw-r----- 1 mysql mysql 2.4K 1月  18 23:34 mysql-bin.000004
                -rw-r----- 1 mysql mysql  712 1月  20 15:25 mysql-bin.000005
                -rw-r----- 1 mysql mysql  154 1月  22 07:58 mysql-bin.000006
                -rw-r----- 1 mysql mysql  34M 1月  24 11:33 mysql-bin.000007
                -rw-r----- 1 mysql mysql 1.1K 1月  24 14:35 mysql-bin.000008
                -rw-r----- 1 mysql mysql 9.0K 1月  26 22:47 mysql-bin.000009
                -rw-r----- 1 mysql mysql  177 1月  26 22:51 mysql-bin.000010
                -rw-r----- 1 mysql mysql  154 1月  26 22:51 mysql-bin.000011
                -rw-r----- 1 mysql mysql  506 1月  26 22:51 mysql-bin.index
                -rw-r----- 1 mysql mysql 154K 1月  26 22:51 mysql-err.log
                drwxr-x--- 2 mysql mysql 8.0K 1月  10 21:15 performance_schema
                -rw------- 1 mysql mysql 1.7K 1月  10 21:15 private_key.pem
                -rw-r--r-- 1 mysql mysql  452 1月  10 21:15 public_key.pem
                drwxr-x--- 2 mysql mysql  182 1月  20 12:37 school
                -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 server-cert.pem
                -rw------- 1 mysql mysql 1.7K 1月  10 21:15 server-key.pem
                drwxr-x--- 2 mysql mysql 8.0K 1月  10 21:15 sys
                drwxr-x--- 2 mysql mysql  144 1月  25 08:39 world
                drwxr-x--- 2 mysql mysql  157 1月  26 12:15 mytest
                [root@mysql107.mytest ~]# 

```

### MySQL物理存储逻辑

```
    MySQL物理存储逻辑分为page，extent，sengment:
        page(译为:"页"):
            通常指4个连续的block，这意味着一个page默认的大小是16KB，也就是说在底层使用的是连续的16KB存储空间，它是最小的I/O单元。
        extent(译为:"区"，"簇"):
            通常指64个连续的page，这意味着一个extent默认的大小是16KB * 64MB = 1MB，也就是说在底层使用的是连续的1MB存储空间。
        segment(译为:"段"，就是指我们数据库中的"表"，但"分区表"除外!)
            值得注意的是，sengment通常指的是表的存储单位，它底层采用的是多个extent来存储数据，但是这多个extent并不一定连续。
            因为数据是持续写入的，我们的表也是大小不一的，有的表只用于测试仅有几KB大小，有的表生产环境比较大，甚至达到TB级别。

    温馨提示:
        一张表对应的是表空间(Tablespaces)，而表空间(Tablespaces)是由sengment组成，而sengment则是由extend组成，extend则是由page组成。因此我们说page，extent，sengment属于表空间的微观结构。
        综上所述，我们可以得到如下所示的关系:
            表(Table) ---> 表空间(Tablespaces) ---> 段(sengment) ---> 区(extent) ---> 页(page) ---> Linux的块(block) ---> 连续的扇区(sector)

```

### 事务日志(Redo Logs)

```
    (1)事务日志(Redo Logs)的功能:
        用来存储MySQL在做DML修改类操作时的数据页(page)变化过程及版本号(LSN)，属于物理日志。
        默认循环覆盖使用"ib_logfile0"，"ib_logfile1"这两个文件存储Redo logs，当第一个文件写满之后开始使用第二个文件，当第二个文件写满后，又会清空第一个文件的内容从头开始写数据，反复循环。
        综上所述，在生产环境中我们可以修改事务日志的个数及其大小来优化MySQL数据库事务的并发性，关于事务到底是个啥，我们暂时先有个影响，后续会有相应的章节来介绍。

    (2)事务日志(Redo Logs)的控制参数:
        mysql> SHOW VARIABLES LIKE "%innodb_log%";
        +-----------------------------+----------+
        | Variable_name               | Value    |
        +-----------------------------+----------+
        | innodb_log_buffer_size      | 16777216 |
        | innodb_log_checksums        | ON       |
        | innodb_log_compressed_pages | ON       |
        | innodb_log_file_size        | 50331648 |
        | innodb_log_files_in_group   | 2        |
        | innodb_log_group_home_dir   | ./       |
        | innodb_log_write_ahead_size | 8192     |
        +-----------------------------+----------+
        7 rows in set (0.00 sec)
        
        mysql> 
        
        以下是事务日志重要的控制参数:
            1)innodb_log_file_size:
                设置文件大小，单位为字节。
            2)innodb_log_files_in_group:
                设置文件个数。
            3)innodb_log_group_home_dir:
                设置事务日志的存储位置，默认存储在MySQL实例安装的数据目录中。

    (3)事务日志(Redo Logs)默认的命名为"ib_logfile0"，"ib_logfile1"，...，"ib_logfileN"，其默认存储在MySQL实例的数据目录下，如下所示:
        [root@mysql107.mytest ~]# ll -h /mytest/data/mysql23307/
        总用量 475M
        -rw-r----- 1 mysql mysql   56 1月  10 21:15 auto.cnf
        -rw------- 1 mysql mysql 1.7K 1月  10 21:15 ca-key.pem
        -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 ca.pem
        -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 client-cert.pem
        -rw------- 1 mysql mysql 1.7K 1月  10 21:15 client-key.pem
        -rw-r----- 1 mysql mysql    6 1月  26 22:51 docker201.mytest.pid
        -rw-r----- 1 mysql mysql  477 1月  26 22:51 ib_buffer_pool
        -rw-r----- 1 mysql mysql  76M 1月  26 22:51 ibdata1
        -rw-r----- 1 mysql mysql 128M 1月  26 22:50 ibdata2
        -rw-r----- 1 mysql mysql 128M 1月  26 22:50 ibdata3
        -rw-r----- 1 mysql mysql  48M 1月  26 22:51 ib_logfile0
        -rw-r----- 1 mysql mysql  48M 1月  26 22:51 ib_logfile1
        -rw-r----- 1 mysql mysql  12M 1月  26 22:51 ibtmp1
        drwxr-x--- 2 mysql mysql 4.0K 1月  25 11:57 mysql
        -rw-r----- 1 mysql mysql  177 1月  10 21:39 mysql-bin.000001
        -rw-r----- 1 mysql mysql 712K 1月  15 03:35 mysql-bin.000002
        -rw-r----- 1 mysql mysql 5.5K 1月  17 00:27 mysql-bin.000003
        -rw-r----- 1 mysql mysql 2.4K 1月  18 23:34 mysql-bin.000004
        -rw-r----- 1 mysql mysql  712 1月  20 15:25 mysql-bin.000005
        -rw-r----- 1 mysql mysql  154 1月  22 07:58 mysql-bin.000006
        -rw-r----- 1 mysql mysql  34M 1月  24 11:33 mysql-bin.000007
        -rw-r----- 1 mysql mysql 1.1K 1月  24 14:35 mysql-bin.000008
        -rw-r----- 1 mysql mysql 9.0K 1月  26 22:47 mysql-bin.000009
        -rw-r----- 1 mysql mysql  177 1月  26 22:51 mysql-bin.000010
        -rw-r----- 1 mysql mysql  154 1月  26 22:51 mysql-bin.000011
        -rw-r----- 1 mysql mysql  506 1月  26 22:51 mysql-bin.index
        -rw-r----- 1 mysql mysql 154K 1月  26 22:51 mysql-err.log
        drwxr-x--- 2 mysql mysql 8.0K 1月  10 21:15 performance_schema
        -rw------- 1 mysql mysql 1.7K 1月  10 21:15 private_key.pem
        -rw-r--r-- 1 mysql mysql  452 1月  10 21:15 public_key.pem
        drwxr-x--- 2 mysql mysql  182 1月  20 12:37 school
        -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 server-cert.pem
        -rw------- 1 mysql mysql 1.7K 1月  10 21:15 server-key.pem
        drwxr-x--- 2 mysql mysql 8.0K 1月  10 21:15 sys
        drwxr-x--- 2 mysql mysql  144 1月  25 08:39 world
        drwxr-x--- 2 mysql mysql  157 1月  26 12:15 mytest
        [root@mysql107.mytest ~]# 

```

### 回滚日志(Undo Logs)

```
    (1)回滚日志(Undo Logs)的功能:
        用来存储回滚日志，可以理解为记录每次操作的反操作，属于逻辑日志。该日志有以下两个特别重要的功能:
            1)使用快照功能，提供InnoDB多版本并发读写;
            2)通过记录反操作，提供回滚功能;

    (2)事务日志(Redo Logs)的控制参数:
        mysql> SHOW VARIABLES LIKE "%segments%";  # 如下所示，默认回滚段的个数是128，通常不需要修改！
        +--------------------------+-------+
        | Variable_name            | Value |
        +--------------------------+-------+
        | innodb_rollback_segments | 128   |
        +--------------------------+-------+
        1 row in set (0.00 sec)
        
        mysql> 

    (3)回滚日志(Undo Logs)默认的命名为"ibdata1"，"ibdata2"，...，"ibdataN"以及"ibtmp1"(临时表)，其默认存储在MySQL实例的数据目录下，如下所示:
        [root@mysql107.mytest ~]# ll -h /mytest/data/mysql23307/
        总用量 475M
        -rw-r----- 1 mysql mysql   56 1月  10 21:15 auto.cnf
        -rw------- 1 mysql mysql 1.7K 1月  10 21:15 ca-key.pem
        -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 ca.pem
        -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 client-cert.pem
        -rw------- 1 mysql mysql 1.7K 1月  10 21:15 client-key.pem
        -rw-r----- 1 mysql mysql    6 1月  26 22:51 docker201.mytest.pid
        -rw-r----- 1 mysql mysql  477 1月  26 22:51 ib_buffer_pool
        -rw-r----- 1 mysql mysql  76M 1月  26 22:51 ibdata1
        -rw-r----- 1 mysql mysql 128M 1月  26 22:50 ibdata2
        -rw-r----- 1 mysql mysql 128M 1月  26 22:50 ibdata3
        -rw-r----- 1 mysql mysql  48M 1月  26 22:51 ib_logfile0
        -rw-r----- 1 mysql mysql  48M 1月  26 22:51 ib_logfile1
        -rw-r----- 1 mysql mysql  12M 1月  26 22:51 ibtmp1
        drwxr-x--- 2 mysql mysql 4.0K 1月  25 11:57 mysql
        -rw-r----- 1 mysql mysql  177 1月  10 21:39 mysql-bin.000001
        -rw-r----- 1 mysql mysql 712K 1月  15 03:35 mysql-bin.000002
        -rw-r----- 1 mysql mysql 5.5K 1月  17 00:27 mysql-bin.000003
        -rw-r----- 1 mysql mysql 2.4K 1月  18 23:34 mysql-bin.000004
        -rw-r----- 1 mysql mysql  712 1月  20 15:25 mysql-bin.000005
        -rw-r----- 1 mysql mysql  154 1月  22 07:58 mysql-bin.000006
        -rw-r----- 1 mysql mysql  34M 1月  24 11:33 mysql-bin.000007
        -rw-r----- 1 mysql mysql 1.1K 1月  24 14:35 mysql-bin.000008
        -rw-r----- 1 mysql mysql 9.0K 1月  26 22:47 mysql-bin.000009
        -rw-r----- 1 mysql mysql  177 1月  26 22:51 mysql-bin.000010
        -rw-r----- 1 mysql mysql  154 1月  26 22:51 mysql-bin.000011
        -rw-r----- 1 mysql mysql  506 1月  26 22:51 mysql-bin.index
        -rw-r----- 1 mysql mysql 154K 1月  26 22:51 mysql-err.log
        drwxr-x--- 2 mysql mysql 8.0K 1月  10 21:15 performance_schema
        -rw------- 1 mysql mysql 1.7K 1月  10 21:15 private_key.pem
        -rw-r--r-- 1 mysql mysql  452 1月  10 21:15 public_key.pem
        drwxr-x--- 2 mysql mysql  182 1月  20 12:37 school
        -rw-r--r-- 1 mysql mysql 1.1K 1月  10 21:15 server-cert.pem
        -rw------- 1 mysql mysql 1.7K 1月  10 21:15 server-key.pem
        drwxr-x--- 2 mysql mysql 8.0K 1月  10 21:15 sys
        drwxr-x--- 2 mysql mysql  144 1月  25 08:39 world
        drwxr-x--- 2 mysql mysql  157 1月  26 12:15 mytest
        [root@mysql107.mytest ~]# 
        [root@mysql107.mytest ~]# 

```

### 数据内存区域

```
    数据内存区域又被细分为共享内存区域和会话内存区域。

    共享内存缓冲区域:
        也称为"缓冲区池"(英文名称为:"buffer pool")，我们可以通过"InnoDB_buffer_pool_size"来查看池的大小。若不配置，则默认大小为128MB，如下所示。
            mysql> SELECT @@InnoDB_buffer_pool_size;
            +---------------------------+
            | @@InnoDB_buffer_pool_size |
            +---------------------------+
            |                 134217728 |
            +---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> SELECT CONCAT(134217728/1024/1024,"MB");
            +----------------------------------+
            | CONCAT(134217728/1024/1024,"MB") |
            +----------------------------------+
            | 128.00000000MB                   |
            +----------------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
        "buffer pool"的功能是缓冲数据页(page)和索引页，生产环境中可以适当调大,官方建议使用物理服务器在80%内存空间。
    
    会话内存缓冲区域(并非InnoDB存储引擎独有)：
        join_buffer_size:
            查询时基于BKA实现就会使用到它。
        key_buffer_size:
            属于MyISAM的索引缓冲区，当然，也会存储内存中的一些临时表。
        read_buffer_size，read_rnd_buffer_size:
            存储读取数据的缓冲区。
        sort_buffer_size:
            用于排序的缓冲区。

```

### 日志内存缓冲区

```
    前面我们介绍到了有事务(Redo)日志，当然，在内存中也有对应的内存缓冲区域，我们可以通过"innodb_log_buffer_size"查看，若未配置，则默认大小为16MB，如下所示。
        mysql> SELECT @@innodb_log_buffer_size;
        +--------------------------+
        | @@innodb_log_buffer_size |
        +--------------------------+
        |                 16777216 |
        +--------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT CONCAT(16777216/1024/1024,"MB");
        +---------------------------------+
        | CONCAT(16777216/1024/1024,"MB") |
        +---------------------------------+
        | 16.00000000MB                   |
        +---------------------------------+
        1 row in set (0.00 sec)
        
        mysql> 

```

## 4.补充内容



```
内存的微观结构概述:
    缓冲池(Buffer Pool):
        是主内存中的一个区域，用于在InnoDB访问时缓存表和索引数据。缓冲池允许直接从内存访问经常使用的数据，从而加快处理速度。在专用服务器上，多达80%的物理内存通常分配给缓冲池。
        推荐阅读: 
            https://dev.mysql.com/doc/refman/8.0/en/innodb-buffer-pool.html

    更改缓冲区(Change Buffer):
        是一种特殊的数据结构，当辅助索引页不在缓冲池中时，它会缓存这些页的更改。缓存的更改可能由Insert、Update或Delete操作（DML）导致，稍后当页面通过其他读取操作加载到缓冲池时，会合并这些更改。
        推荐阅读: 
            https://dev.mysql.com/doc/refman/8.0/en/innodb-change-buffer.html

    自适应哈希索引(Adaptive Hash Index):
        使InnoDB能够在具有适当的工作负载组合和足够的缓冲池内存的系统上执行更像内存中的数据库，而不会牺牲事务功能或可靠性。
        推荐阅读:
            https://dev.mysql.com/doc/refman/8.0/en/innodb-adaptive-hash.html

    日志缓冲区(Log Buffer):
        存储要写入磁盘上redo日志文件的数据的内存区域。日志缓冲区大小由innodb_Log_buffer_size变量定义。日志缓冲区的内容定期刷新到磁盘。
        mysql 5.6默认是8MB，mysql 5.7及以上版本默认大小为16MB。
        推荐阅读:
            https://dev.mysql.com/doc/refman/8.0/en/innodb-redo-log-buffer.html

5.6磁盘的微观结构概述:
    重做日志（redo log）：
        是一种基于磁盘的数据结构，在崩溃恢复期间用于更正由不完整事务写入的数据。
        简而言之,就是用来重放操作的二进制日志。对应物理文件为“ib_logfile0”和"ib_logfile1"。
        推荐阅读:
            https://dev.mysql.com/doc/refman/5.6/en/innodb-architecture.html

    日志序列号（“log sequence number”,简称"LSN"）:
        此任意、不断增加的值表示与重做日志中记录的操作相对应的时间点。
        推荐阅读:
            https://dev.mysql.com/doc/refman/5.6/en/glossary.html#glos_lsn

    系统表空间（system tablespace）:
        是InnoDB数据字典（data dictionary）、doublewrite buffer、change buffer和undo logs的存储区域。如果表是在系统表空间中创建的，而不是在每个表的文件表空间中创建的，则它还可能包含表和索引数据。
        系统表空间可以有一个或多个数据文件。默认情况下，在数据目录中创建一个名为ibdata1的系统表空间数据文件。系统表空间数据文件的大小和数量由innodb_data_file_path启动选项定义。
        推荐阅读:
            https://dev.mysql.com/doc/refman/5.6/en/innodb-system-tablespace.html

    每个表的文件表空间（File-Per-Table Tablespaces）:
        包含单个InnoDB表的数据和索引 ，并存储在文件系统上的单个数据文件中。具体体现方式为一个"表名.ibd"文件
        推荐阅读:
            https://dev.mysql.com/doc/refman/5.6/en/innodb-file-per-table-tablespaces.html

    回滚表空间(undo tablespaces):
        回滚表空间包含回滚日志，这是包含有关如何回滚事务对聚集索引记录的最新更改的信息的记录集合。
        回滚日志默认存储在系统表空间中，但也可以存储在一个或多个回滚表空间中。需要手动配置。
        推荐阅读:
            https://dev.mysql.com/doc/refman/5.6/en/innodb-undo-tablespaces.html

    InnoDB 数据字典（Data Dictionary）：
        由内部系统表组成，其中包含用于跟踪表、索引和表列等对象的元数据。元数据物理上位于InnoDB系统表空间中。
        由于历史原因，数据字典元数据在某种程度上与InnoDB表元数据文件（.frm文件）中存储的信息重叠。
        推荐阅读：
            https://dev.mysql.com/doc/refman/5.6/en/innodb-data-dictionary.html

    双写缓冲区（Doublewrite Buffer）:
        doublewrite缓冲区是一个存储区域，InnoDB在将页面写入InnoDB数据文件中的正确位置之前，会在其中写入从缓冲池刷新的页面。如果在页面写入中间有操作系统、存储子系统或意外的MySQL进程退出，InnDB可以在崩溃恢复过程中从双写缓冲区找到一个好的页面副本。
        虽然数据写入两次，但doublewrite缓冲区不需要两倍的I/O开销或两倍的I/O操作。数据以大的顺序块写入doublewrite缓冲区，只需对操作系统进行一次fsync（）调用（innodb_flush_method设置为O_DIRECT_NO_fsync的情况除外）。
        默认情况下，双写缓冲区处于启用状态。要禁用doublewrite缓冲区，请将innodb_doublewrite设置为0。
        推荐阅读:
            https://dev.mysql.com/doc/refman/5.6/en/innodb-doublewrite-buffer.html

    回滚日志(undo logs):
        是与单个读写事务关联的回滚日志记录的集合。回滚日志记录包含有关如何回滚事务对聚集索引记录的最新更改的信息。
        如果另一个事务需要在一致读取操作中查看原始数据，则会从回滚日志记录中检索未修改的数据。回滚日志存在于撤消日志段中，撤消日志段包含在回滚段中。InnoDB支持128个回滚段。innodb_rollback_segments变量定义innodb使用的回滚段(segments)数。
        默认情况下，回滚段在物理上是系统表空间的一部分，但它们也可以驻留在回滚表空间(undo tablespaces)中。
        推荐阅读:
            https://dev.mysql.com/doc/refman/5.6/en/innodb-undo-logs.html


5.7磁盘的微观结构概述:
	通用表空间(General Tablespaces):
		是InnoDB使用CREATE TABLESPACE语法创建的共享表空间。与系统表空间类似，通用表空间是能够为多个表存储数据的共享表空间。
		推荐阅读:
			https://dev.mysql.com/doc/refman/5.7/en/general-tablespaces.html

	临时表空间(Temporary Tablespace):
		非压缩、用户创建的临时表和磁盘内部临时表在共享临时表空间中创建。临时表空间在正常关闭或中止初始化时被删除，并在每次服务器启动时重新创建。
		在MySQL5.6中，非压缩临时表在临时文件目录中的单个 file-per-table 表空间中创建，InnoDB 如果innodb_file_per_table禁用，则在数据目录中的系统表空间中创建 。
		MySQL5.7中共享临时表空间的引入消除了与为每个临时表创建和删除每个表的文件表空间相关的性能成本。专用的临时表空间也意味着不再需要将临时表元数据保存到InnoDB系统表中。
		推荐阅读:
			https://dev.mysql.com/doc/refman/5.7/en/innodb-temporary-tablespace.html
		
		
5.7磁盘的微观结构概述:
	推荐阅读:
		https://dev.mysql.com/doc/refman/8.0/en/innodb-architecture.html
```



## 5.表空间迁移案例

```
场景:
	小明生产环境中，一台服务器断电后，MySQL数据库起步不成功，其中confluence(内部知识库)和jira(bug追踪)数据库均没有做备份，也没有做主从，更没有开启二进制文件功能。
	没办法，小明是一名开发人员，不是特别懂运维。更严重的是confluence还在，但jira整个数据库都没有了。

分析:
	(1)由于jira数据库没有备份，因此很难手动恢复，建议将磁盘挂载到别的服务器上，而后通过文件句柄的方式来尝试恢复该数据库的文件（切记千万别再往丢失数据的磁盘上写数据，这很容易导致数据的覆盖哟~），实在不行就只能去找数据恢复的公司了;
	(2)confluence还在的话，我们就可以尝试做一个表空间迁移，尝试能否正常启动数据库;

表空间迁移案例
(1)10.0.0.107操作,创建测试的数据
	CREATE DATABASE mytest_linux77;
	USE mytest_linux77;
	CREATE TABLE student (id INT PRIMARY KEY AUTO_INCREMENT,name VARCHAR(30),hobby VARCHAR(255));
	INSERT student (name,hobby) VALUES ('张伟','亚索'),('叶子奇','螳螂'),('尤亚洲','流浪'),('贺冰杰','妹子');
	SHOW CREATE TABLE mytest_linux77.student;
	select * from student;
	
(2)10.0.0.108操作
	CREATE DATABASE mytest_linux76;
	USE mytest_linux76
	CREATE TABLE `student` (
	  `id` int NOT NULL AUTO_INCREMENT,
	  `name` varchar(30) DEFAULT NULL,
	  `hobby` varchar(255) DEFAULT NULL,
	  PRIMARY KEY (`id`)
	) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
	ALTER TABLE student  DISCARD TABLESPACE;  # 删除表空间!


(3)10.0.0.107操作,复制表空间
	scp /mytest/data/mysql3308/mytest_linux77/student.ibd 10.0.0.108:/mytest/data/mysql3307/mytest_linux76/

(4)10.0.0.108操作,
	cd /mytest/data/mysql3307/mytest_linux76
	chown mysql:mysql student.ibd
	ALTER TABLE student IMPORT TABLESPACE;
	
(5)10.0.0.108验证数据
	select * from student;


温馨提示:
	(1)案例上说数据库都无法正常启动，我们该如何查看表结构呢?
		答: 只需要重新部署一下环境,查看表结构即可,只不过重新部署的环境没有数据而已哟。
	(2)在操作时是否需要锁表?
		答: 我个人觉得没有必要锁源表,因为你源表的此时并不会对外提供服务,操作的人只有我们运维人员自己。
            锁定源端:
                flush tables  mytest_linux77.student with read lock ;
            解锁源端数据表:
                unlock tables;   
```

# 四.关于InnoDB存储引擎的优化实战

## 1.undo表空间优化

```
undo表空间作用： 
	用来作回滚工作。
undo表空间存储位置： 
	5.6版本，默认存储在系统表空间中（ibdataN）。8.0版本以后默认就是独立的（undo_001-undo_002）。
undo表空间生产建议： 
	5.6版本后，将undo手工进行独立。
		
undo相关的参数说明:
    innodb_undo_tablespaces;  
        如果不配置,默认值为0,生产环境中 ,建议配置3-5个即可.
        若配置了该参数则开启独立undo模式，8.0版本中该参数并不推荐使用，在未来的版本中将被移除！
        该参数MySQL8.0之前的版本有效,如果msyql 8.0配置了也会无视!
    innodb_max_undo_log_size; 
        undo日志的大小，默认1G。生产环境中推荐1-4G.
    innodb_undo_log_truncate; 
        开启undo自动回收的机制（undo_purge）。
    innodb_purge_rseg_truncate_frequency:
        触发自动回收的条件，单位是检测次数。
    innodb_undo_directory ; 
        指定undo日志的存储位置，若不指定则默认存储在数据目录中，生产环境中强烈建议分离！
    innodb_rollback_segments:
        注意,mysql5.7发行版中对临时表空间会分配32个回滚段,给系统表空间分配1个回滚段;
        综上所述,官方建议最少配置大于33个回滚段,我这里不配置了,保持默认的128个回滚段即可!


温馨提示:
	我们可以同下面的语法来查看上述值的默认属性哟.
        SELECT @@innodb_undo_tablespaces; 
        SELECT @@innodb_max_undo_log_size;
        SELECT @@innodb_undo_log_truncate;
        SELECT @@innodb_purge_rseg_truncate_frequency;
        SELECT @@innodb_undo_directory;
        SELECT @@innodb_rollback_segments;
	推荐阅读:
		https://dev.mysql.com/doc/refman/5.6/en/innodb-undo-tablespaces.html
		https://dev.mysql.com/doc/refman/5.7/en/innodb-undo-tablespaces.html
		https://dev.mysql.com/doc/refman/8.0/en/innodb-undo-tablespaces.html
			
mysql 5.7配置undo实战:
	(1)创建配置文件存储路径,日志存储路径,数据存储路径:
	mkdir -pv /mytest/{etc,data,logs}/{mysql3307,mysql3308,mysql3309}
	install -o mysql -g mysql -d /mytest/logs/mysql3307/undo
	
	(2)编写mysql实例的配置文件
	cat > /mytest/etc/mysql3307/my.cnf <<EOF
	[mysqld]
	datadir=/mytest/data/mysql3307/
	basedir=/mytest/softwares/mysql57/
	port=3307
	socket=/tmp/mysql3307.sock
	# 如果不配置,默认值为0,生产环境中 ,建议配置3-5个即可.
	innodb_undo_tablespaces=5
	# 开启undo自动回收的机制
	innodb_undo_log_truncate=ON
	# undo日志的最大的大小，默认1G。生产环境中推荐1-4G.
	innodb_max_undo_log_size=2147483648
	# 触发自动回收的条件，单位是检测次数
	innodb_purge_rseg_truncate_frequency=32
	# 注意,mysql5.7发行版中对临时表空间会分配32个回滚段,给系统表空间分配1个回滚段;
	# 综上所述,官方建议最少配置大于33个回滚段,我这里不配置了,保持默认的128个回滚段即可!
	innodb_rollback_segments=128
	# 指定undo日志的存储位置，若不指定则默认存储在数据目录中，生产环境中强烈建议分离！
	innodb_undo_directory=/mytest/logs/mysql3307/undo
	EOF

	(3)初始化操作
	mysqld --defaults-file=/mytest/etc/mysql3307/my.cnf --datadir=/mytest/data/mysql3307/  --initialize-insecure --user=mysql

	(4)启动MySQL实例
	mysqld_safe --defaults-file=/mytest/etc/mysql3307/my.cnf &>/dev/null &


mysql5.6和MySQL5.7步骤相同,但有一定区别,主要记录如下:
	(1)配置的参数支持并不相同:
		cat > /mytest/etc/mysql3307/my.cnf <<EOF
		[mysqld]
		datadir=/mytest/data/mysql3307/
		basedir=/mytest/softwares/mysql56/
		port=3307
		socket=/tmp/mysql3307.sock
		# 如果不配置,默认值为0,生产环境中 ,建议配置3-5个即可.
		innodb_undo_tablespaces=5
		# 注意,mysql5.7发行版中对临时表空间会分配32个回滚段,给系统表空间分配1个回滚段;
		# 综上所述,官方建议最少配置大于33个回滚段,我这里不配置了,保持默认的128个回滚段即可!
		innodb_rollback_segments=128
		# 指定undo日志的存储位置，若不指定则默认存储在数据目录中，生产环境中强烈建议分离！
		innodb_undo_directory=/mytest/logs/mysql3307/undo
		EOF
	(2)初始化方式不同:
		/mytest/softwares/mysql56/scripts/mysql_install_db --defaults-file=/mytest/etc/mysql3307/my.cnf --user=mysql --datadir=/mytest/data/mysql3307/ --basedir=/mytest/softwares/mysql56/


mysql 8.0配置undo实战
	(1)创建undo的挂载点(此处省略挂在步骤,实际工作中你可以使用一块磁盘设备)
		install -o mysql -g mysql -d /mytest/logs/mysql3309/undo
	(2)创建配置文件
		cat > /mytest/etc/mysql3309/my.cnf <<EOF
		[mysqld]
		datadir=/mytest/data/mysql3309/
		basedir=/mytest/softwares/mysql80/
		port=3309
		socket=/tmp/mysql3309.sock
		mysqlx_port=33090
		mysqlx_socket=/tmp/mysqlx33090.sock
		# MySQL 8.0配置undo日志的大小无效!但后期可以通过手动创建undo的表空间个数!
		innodb_undo_tablespaces=5
		# 开启undo自动回收的机制
		innodb_undo_log_truncate=ON
		# undo日志的最大的大小，默认1G。生产环境中推荐1-4G.
		innodb_max_undo_log_size=2147483648
		# 触发自动回收的条件，单位是检测次数
		innodb_purge_rseg_truncate_frequency=32
		# 注意,mysql5.7发行版中对临时表空间会分配32个回滚段,给系统表空间分配1个回滚段;
		# 综上所述,官方建议最少配置大于33个回滚段,我这里不配置了,保持默认的128个回滚段即可!
		innodb_rollback_segments=128
		# 指定undo日志的存储位置，若不指定则默认存储在数据目录中，生产环境中强烈建议分离！
		innodb_undo_directory=/mytest/logs/mysql3309/undo
		EOF
	(2)初始化MySQL数据库实例
		mysqld --defaults-file=/mytest/etc/mysql3309/my.cnf --datadir=/mytest/data/mysql3309/  --initialize-insecure --user=mysql
	
	(3)启动MySQL实例
		mysqld_safe --defaults-file=/mytest/etc/mysql3309/my.cnf &>/dev/null &

	(4)mysql命令行管理undo表空间
		1)查看表空间和其对应的文件名称
			SELECT TABLESPACE_NAME 表空间名称, FILE_NAME  文件名称 FROM INFORMATION_SCHEMA.FILES   WHERE FILE_TYPE LIKE 'UNDO LOG';
		
		2)创建表空间
		 CREATE UNDO TABLESPACE mytest_linux ADD DATAFILE 'mytest.ibu';

		3)查看某个表空间是否激活
			SELECT NAME, STATE FROM INFORMATION_SCHEMA.INNODB_TABLESPACES   WHERE NAME LIKE 'mytest_linux';

		4)激活或者不激活表空间
			ALTER UNDO TABLESPACE mytest_linux SET ACTIVE;
			ALTER UNDO TABLESPACE mytest_linux SET INACTIVE;
			
		5)删除undo表空间
			ALTER UNDO TABLESPACE mytest_linux SET INACTIVE;
			DROP UNDO TABLESPACE mytest_linux;
```



## 2.临时表空间优化

```
临时表空间作用:
	主要临时存储数据，比如多表查询时可能会存一些临时表，排序的中间结果等信息，这些数据丢了无所谓，都是临时的.

临时表生产建议:
	默认是12MB,数据库初始化之前设定好，一般2-3个，大小512M-1G。
	
mysql 8.0配置临时表空间实战:
	(1)创建临时表空间需要在自定义挂载点
	install -o mysql -g mysql -d /mytest/logs/mysql3309/temp
	install -o mysql -g mysql -d /mytest/logs/mysql3309/temp/mytest_innodb_temp
	
	(2)编写mysql实例的配置文件
	cat > /mytest/etc/mysql3309/my.cnf <<EOF
	[mysqld]
	datadir=/mytest/data/mysql3309/
	basedir=/mytest/softwares/mysql80/
	port=3309
	socket=/tmp/mysql3309.sock
	mysqlx_port=33090
	mysqlx_socket=/tmp/mysqlx33090.sock
	# 如果不配置,默认值为0,生产环境中 ,建议配置3-5个即可.
	innodb_undo_tablespaces=5
	# 开启undo自动回收的机制
	innodb_undo_log_truncate=ON
	# undo日志的最大的大小，默认1G。生产环境中推荐1-4G.
	innodb_max_undo_log_size=2147483648
	# 触发自动回收的条件，单位是检测次数
	innodb_purge_rseg_truncate_frequency=32
	# 注意,mysql5.7发行版中对临时表空间会分配32个回滚段,给系统表空间分配1个回滚段;
	# 综上所述,官方建议最少配置大于33个回滚段,我这里不配置了,保持默认的128个回滚段即可!
	innodb_rollback_segments=128
	# 指定undo日志的存储位置，若不指定则默认存储在数据目录中，生产环境中强烈建议分离！
	innodb_undo_directory=/mytest/logs/mysql3309/undo
	# 定义临时表空间数据文件的相对路径、名称、大小和属性.
	# 格式为"file_name:file_size[:autoextend[:max:max_file_size]]",官方文档这样写,但是实际配置并不好实用!
	# innodb_temp_data_file_path=ibtmp1:50M;ibtmp2:12M:autoextend:max:500MB
	# 经过实验证明，以下在方式可以正常使用的哟~
	innodb_temp_data_file_path=../../logs/mysql3309/temp/mytest_linux_temp:100M:autoextend
	# 指定临时表存储的目录
	innodb_temp_tablespaces_dir=/mytest/logs/mysql3309/temp/mytest_innodb_temp/
	EOF

	(3)启动MySQL实例
		mysqld_safe --defaults-file=/mytest/etc/mysql3309/my.cnf &>/dev/null &


	推荐阅读:
		https://dev.mysql.com/doc/refman/8.0/en/innodb-temporary-tablespace.html
		https://dev.mysql.com/doc/refman/5.7/en/innodb-information-schema-temp-table-info.html
```



## 3.redo log优化

```
redo log作用: 
	记录内存数据页的变化。
	实现“重放”日志的功能。WAL（write ahead log），MySQL保证redo优先于数据写入磁盘。
		
redo log存储位置： 
	数据路径下，进行轮序覆盖记录日志

redo log生产建议： 
	大小(innodb_log_file_size)： 512M-4G
	组数(innodb_log_files_in_group)： 3-5组

推荐阅读:
	https://dev.mysql.com/doc/refman/8.0/en/innodb-redo-log.html

案例演示:
	(1)关闭mysql实例
		/etc/init.d/mysqld stop
		＃　pkill mysqld  #　杀掉所有在mysqld相关进程，慎用，尤其是多实力在场景下！
	
	(2)编写mysql实例的配置文件
	cat > /mytest/etc/mysql3309/my.cnf <<EOF
	[mysqld]
	...
	
	# 配置redo日志的大小，生产环境建议给到512MB~4G！
	innodb_log_file_size=512M
	# 配置redo日志的数量，生产环境建议给3-5个即可！
	innodb_log_files_in_group=5
	# 配置redo日志的存储目录
	innodb_log_group_home_dir=/mytest/logs/mysql3309/redo
	EOF
	
	(3)重启mysql实例
		mysqld_safe --defaults-file=/mytest/etc/mysql3309/my.cnf &>/dev/null &
```





## 4.双写缓冲区的优化

```
Double Write Buffer（DWB） 双写缓冲区  （8.0.19之前 默认在ibdataN中，8.0.20以后可以独立了。）
	作用：
		MySQL，最小IO单元page（16KB），OS中最小的IO单元是block（4KB）。
		写入数据时会先写入DWB文件中顺序存储，然后才会将数据真实写入数据，看似写入了2次，但MySQL却实现了一次I/O操作，可参考官方文档。
	生产建议:
		理想情况下，doublewrite目录应放置在可用的最快存储介质上.


配置案例:
	(1)创建doublewrite所需要在自定义挂载点
	install -o mysql -g mysql -d /mytest/logs/mysql3309/doublewrite
	
	(2)编写mysql实例的配置文件
	cat > /mytest/etc/mysql3309/my.cnf <<EOF
	[mysqld]
	...
	# 配置缓冲池实例的数量,建议配置为服务器的核心数量
	innodb_buffer_pool_instances=2
	# 定义了双写文件的数量。至少有两个双写文件。双写文件的最大数量是缓冲池实例数量的两倍。
	# 指的注意的是,尽管我们将innodb_doublewrite_files调大,它也无法超过innodb_buffer_pool_instances * 2的数量.
	innodb_doublewrite_files=3
	# 定义了目录InnoDB创建双写文件。理想情况下，doublewrite目录应放置在可用的最快存储介质上.
	innodb_doublewrite_dir=/mytest/logs/mysql3309/doublewrite
	EOF


	推荐阅读:
		https://dev.mysql.com/doc/refman/8.0/en/innodb-doublewrite-buffer.html
```



## 5.磁盘结构的其他项[了解即可,无需过多优化]

```
ib_buffer_pool 预热文件
	作用：
		缓冲和缓存，用来做“热”（经常查询或修改）数据页，减少物理IO。
		当关闭数据库的时候，缓冲和缓存会失效。
		5.7版本中，MySQL正常关闭时，会将内存的热数据存放（流方式）至ib_buffer_pool。下次重启直接读取ib_buffer_pool加载到内存中。
	配置方式:
		mysql> select @@innodb_buffer_pool_dump_at_shutdown;
		mysql> select @@innodb_buffer_pool_load_at_startup;
```



## 6.内存优化

```
InnoDB BUFFER POOL（IBP）
作用： 
	用来缓冲、缓存，MySQL的数据页和索引页。MySQL中最大的、最重要的内存区域。
配置案例:
	cat > /mytest/etc/mysql3309/my.cnf <<EOF
	[mysqld]
	...
	# 配置内存的缓冲池(buffer_pool)大小
	innodb_buffer_pool_size=1G
	# 修改buffer_pool的持久化文件名称
	innodb_buffer_pool_filename=mytest_ib_buffer_pool
	EOF



InnoDB LOG BUFFER (ILB)
作用： 
	在内存中用来缓冲redo log日志信息。
配置案例:
	cat > /mytest/etc/mysql3309/my.cnf <<EOF
	[mysqld]
	...
	# 此配置和innodb_log_file_size有关，
	# 建议是其的1-N倍,根据内存情况而定.该配置对应的是内存的大小!生产环境中建议不要过大!
	innodb_log_buffer_size=256M
```





# 五.可能会出现的报错信息

## 1.[ERROR] InnoDB: The innodb_system data file 'ibdata1' must be writable

```
问题原因:
	文件的权限导致运行MySQL服务的用户无法对这些文件进行写入导致的报错.

解决方案:
	方案一:
		初始化MySQL服务时记得使用"--user"指定运行mysql服务的用户.
	方案二:
		直接进入到数据目录使用"chown"命令修改权限即可.
```

![1631673127924](09-老男孩教育-MySQL的存储引擎.assets/1631673127924.png)



## 2.[ERROR] /mytest/softwares/mysql56//bin/mysqld: unknown variable 'innodb_max_undo_log_size=2147483648'

```
问题原因:
	MySQL 5.6.51版本并不支持innodb_max_undo_log_size,innodb_undo_log_truncate,innodb_purge_rseg_truncate_frequency这些变量哟.

解决方案:
	在mysql的配置文件中删除相关的配置即可.
```

![1631673732997](09-老男孩教育-MySQL的存储引擎.assets/1631673732997.png)



## 3.[ERROR] /mytest/softwares/mysql56//bin/mysqld: unknown option '--initialize-insecure'

```
问题原因:
	MySQL 5.6.51版本并不支持'--initialize-insecure'参数哟.

解决方案:
	删除该参数重新进行初始化即可.
```

![1631674074920](09-老男孩教育-MySQL的存储引擎.assets/1631674074920.png)



## 4.[ERROR] InnoDB: The error means mysqld does not have the access rights to the directory.

```
问题原因:
	目录没有相关的权限.

解决方案:
	(1)方案1:
		chown mysql:mysql /mytest/logs/mysql3307/undo 
	(2)方案2:
		install -o mysql -g mysql -d /mytest/logs/mysql3307/undo
```

![1631676400670](09-老男孩教育-MySQL的存储引擎.assets/1631676400670.png)



## 5.InnoDB: Unable to open undo tablespace '/mytest/logs/mysql3307/undo/undo001'. ... [ERROR] Unknown/unsupported storage engine: InnoDB

```
问题原因:
	mysql 5.6.51版本中看看报错是不支持InnoDB存储引擎.
	但我这导致问题的原因是由于初始化数据目录中已有undo文件导致的报错!

解决方案:
	清空待初始化目录的所有文件,重新初始化即可!
```

![1631677206404](09-老男孩教育-MySQL的存储引擎.assets/1631677206404.png)



## 6.ERROR 3121 (HY000): The ADD DATAFILE filepath must end with '.ibu'.

```

```

![1631680384376](09-老男孩教育-MySQL的存储引擎.assets/1631680384376.png)



## 7.ERROR 3606 (HY000): Duplicate file name for tablespace 'mytest_linux2021

```
问题原因:
	创建undo表空间时,指定了同名的文件名称.

解决方案:
	检查语法,不允许多个不同的表空间指定相同的文件名称中.
```

![1631680550853](09-老男孩教育-MySQL的存储引擎.assets/1631680550853.png)



## 8.ERROR 1529 (HY000): Failed to drop UNDO TABLESPACE mytest_linux

```
问题原因:
	表空间是未激活状态.

解决方案:
	将表空间设置为激活状态.
```

![1631681197580](09-老男孩教育-MySQL的存储引擎.assets/1631681197580.png)



## 9.[ERROR] [MY-013628] [InnoDB] Invalid innodb_temp_tablespaces_dir: /mytest/logs/mysql3309/temp/. Directory doesn't exist or not valid

```
错误原因:
	指定的临时目录并不存在.

解决方案:
	install -o mysql -g mysql -d /mytest/logs/mysql3309/temp
```

![1631691334325](09-老男孩教育-MySQL的存储引擎.assets/1631691334325.png)





## 10.[ERROR] [MY-012371] [InnoDB] Unable to parse innodb_temp_data_file_path=../../logs/mysql3309/temp/mytest_linux_temp1:50M;../../logs/mysql3309/temp/mytest_linux_temp2:100M:autoextend:max:500MB

```
错误原因:
	配置解析出错,但参考官方文档的确是可以使用相对路径的。
	
解决方案:
	暂时无解，需要进一步调研。
	推荐阅读：
		https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html#sysvar_innodb_temp_data_file_path
```

![1631691671417](09-老男孩教育-MySQL的存储引擎.assets/1631691671417.png)