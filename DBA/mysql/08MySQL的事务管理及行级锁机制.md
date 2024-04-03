[TOC]



# 一.MySQL事务日志概述

## 1.什么是事务(Transaction)

```
    事务是伴随着"交易类"的业务场景出现的工作机制。

    举个例子:
        在计算机中，一个事务可能对应着多个操作，比如小明账户里有1000w人名币，小华账户里有200w人名币。小明向小华转账50w人名币就是一件事务。
        在这个事务中，我们可以将操作分为以下两步:
            (1)小明的账户要扣钱50w人名币，账户余额为950w人名币;
            (2)小华的账户要收钱50w人名币，账户余额为250w人名币;
        综上所述，这两个步骤必须全部执行完成，若有任何一个条件执行失败，则会立即回滚到最初状态，即小明账户里有1000w人名币，小华账户里有200w人名币。

```

## 2.事务的特性ACID

```
    事务的特性包含"atomicity", "consistency, "isolation", 和"durability"(通常习惯上我们简称:"ACID")。这些属性在数据库系统中都是需要的，并且都与事务的概念密切相关。InnoDB的事务特性遵循ACID原则。

        Atomicity(代表原子性, [ˌætəˈmɪsəti] ):
            早期人们理解原子是物质的最小构成单元，具备不可再分的特性。因此就用原子性来说明事务的所有操作是不可分隔的，是具有原子性的。
            换句话说，原子性是指事务是一个不可分割的工作单位，事务的操作要么都发生，要么都不发生。
            温馨提示:
                (1)所有的物质都是由原子构成的，世界上存在数千种原子。但原子并非构成物质的最小单元，他的内部还有自己的结构;
                (2)原子是由原子核和核外电子组成，而原子核又由质子和中子组成，事实上质子是由夸克组成，科学家们还在继续探索夸克和核外电子是由谁组成的;

        Consistency(代表一致性,[kənˈsɪstənsi] ):
            事务发生前后，数据的完整性必须保持一致。以上面的案例为例，就是转账的50w人名币不能再事务前后有所变化。
            话句话说，就是小明转账了50万，而小华却收到了500万，或者只收到了5万，这种数据发生了变化就不是一致性！也就是说小明转账50万人名币，小华收到的也应该是50万人名币，不能多也不能少！

        Isolation(代表隔离性, [ˌaɪsəˈleɪʃn] ):
            MySQL可以支持多事务并发工作的系统，为了避免某个事务工作的时候，不能受到其它事务的影响，因此需要实现隔离性。

        Durability(代表持久性, [dərəˈbɪlɪti] ):
            当事务提交(Commit命令执行成功)后，本次事物操作的所有数据都要"落盘"，即让数据的持久化。不会因为数据实例发生故障，导致数据失效。

    MySQL的InnoDB存储引擎一致性问题总结:
        原子性(Atomicity):
            依赖重做日志("Redo log")和回滚日志("Undo log")。

        一致性(Consistency):
            保证事务工作前，中，后数据的状态都是完整的。Consistency的特性是受Atomicity，Isolation，Durability来保证一致性的。

        隔离性(Isolation):
            依赖隔离级别(Isolation Level)，锁(Lock)，MVCC(通过Undo日志快照功能提供多版本事务并发，即在每个事物启动时申请一个当前最新的数据快照)。

        持久性(Durability):
            依赖"Redo log"的WAL机制(该机制被Hbase也有所借鉴哟~)实现持久性。

    参考连接:
        https://dev.mysql.com/doc/refman/5.7/en/glossary.html

```

## 3.MySQL事务日志的常用术语

### 重做日志(Redo Logs)

```
    Redo Logs:
        如下图所示，重做日志(Redo Logs)作用是磁盘文件中记录数据页(page)的变化。
            (1)默认大小是48MB;
            (2)默认的命名规则为ib_logfile0和ib_logfile1，这两个文件轮训覆盖使用;
            (3)Redo Logs指的是磁盘上的文件;

    Redo log buffer:
        顾名思义，这是将Redo Logs的磁盘数据加载到内存中的名称。

```


### 回滚日志(Undo Logs)

```
    如下图所示，回滚日志(Undo Logs)是用于存储事务工作过程中的回滚信息。其默认的命名为"ibdata1"，我们可以使用"innodb_data_file_path"参数对其进行修改！
```


### 数据页存储位置"*.idb"文件

```
    "*.idb"文件:
        如下图所示，"*.idb"文件主要是存储InnoDB存储引擎表的数据行和索引信息。

    buffer pool:
        顾名思义，翻译为缓冲区池，这是用于缓冲"*.idb"文件的数据。该区域大小默认是128MB，生产环境可以考虑适当调大。我们可以通过"InnoDB_buffer_pool_size"来查看池的大小。

```


### 日志序列号(英文名称为:"Log Serial Number"，通常简称"LSN")

```
    其实上面提到"磁盘数据页(Page)"，"Redo Logs"，"Redo Log Buffer""Buffer Pool"等内部都有用到日志序列号。

    MySQL实例启动时，都会比较"磁盘数据页(Page)"和"Redo Logs"的LSN，必须要求两者LSN一致数据库才能正常启动。当然，每次提交一次事物，也会更新这个LSN哟~

```

### 预写日志(英文名称: Write Ahead Log，通常简称"WAL")

```
    通常我们在内存修改数据后会直接写入到磁盘，但MySQL很显然并没有这样做，而是将日志优先写入预写日志，至于磁盘的数据并不会立即写入，而是由MySQL异步(asynchronous)实现磁盘的数据同步。

    话句话说，就是日志优先于数据页的写入方式实现持久化。至于为什么MySQL要这样设计，请先允许我买个关子，后续会介绍到。

```

### 脏页(Dirty page)

```
    内存脏页(Dirty page)这得是内存中发生了修改，但并没有将修改后的数据立即同步到磁盘，这个时候内存和磁盘的数据并不一致，我们把内存也称为脏页。
```

### 检查点(CheckPoint,简称"CKPT")

```
    所谓的检查点(CheckPoint)就是将脏页数据写到磁盘的动作。
```

### 事物号(TXID)

```
    InnoDB会为每一个事物生成唯一的事物编号，它将伴随整个事物的生命周期。
```



# 二.MySQL事务生命周期管理

## 1.标准事务控制语句

```
    所谓的标准事物控制语句，指的是我们需要显式敲击一些命令来执行一个事务，通常事务由BEGIN/START TRANSACTION，SAVEPOINT，COMMIT，ROLLBACK这三条语句组成，其含义如下所示:
        BEGIN/START TRANSACTION:
            表示启动一个事务。
        SAVEPOINT:
            表示为当前状态设置一个检查点，暂时可以理解为一个快照的功能，我们在一个事务中可以创建N个SAVEPOINT，而后使用ROLLBACK命令来回滚到指定的SAVEPOINT哟~但通常情况下，该命令我们很少使用。
        COMMIT:
            表示提交事务。
        ROLLBACK:
            表示回滚事务。

    温馨提示:
        (1)事务不可以嵌套，千万别以为执行了两次"BEGIN"就以为开启了2个事务，因为这样只隐式触发上一个事务的提交。
        (2)在标准的事务控制语句中，我们只能管理标准的事务语句，通常指的是DML语句(比如SELECT,INSERT,UPDATE,DELETE命令)，并不包含DDL语句(例如DROP,TRUNCATE命令删除数据将不能被事务控制哟~)。

```

## 2.关闭自动提交的方法

```
    MySQL默认是开启自动提交功能的，可以通过下面的方式进行查询:
        [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 9
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql> SELECT @@AUTOCOMMIT;
        +--------------+
        | @@AUTOCOMMIT |
        +--------------+
        |            1 |
        +--------------+
        1 row in set (0.00 sec)
        
        mysql> 

    当AUTOCOMMIT的值为1时，没有加BEGIN(没有显式的开启事物)，在你执行DML语句是，会自动在这个DML语句之前加一个BEGIN。一般适用于非交易类业务场景。

    当AUTOCOMMIT的值为1时，且当前业务属于交易类的业务，可采取下面两种方案:
        (1)AUTOCOMMIT=0:
            即将AUTOCOMMIT的值设置为0，需要手动提交(COMMIT)后才能生效。换句话说，只要执行COMMIT操作，甚至可以不写BEGIN操作哟。
        (2)AUTOCOMMIT=1:
            每次想要发生事务性操作，需要手动执行BEGIN和COMMIT操作。

    关闭自动提交的方法:
        (1)临时生效：
            [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 9
            Server version: 5.7.31-log MySQL Community Server (GPL)
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> SELECT @@AUTOCOMMIT;
            +--------------+
            | @@AUTOCOMMIT |
            +--------------+
            |            1 |
            +--------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> SET GLOBAL AUTOCOMMIT=0;  # 注意哈，如果添加了"GLOBAL"关键字，需要重启当前会话才能生效哟~
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT @@AUTOCOMMIT;  # 很明显，当前终端并未生效，但新打开的终端会生效！
            +--------------+
            | @@AUTOCOMMIT |
            +--------------+
            |            1 |
            +--------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> QUIT
            Bye
            [root@docker201.oldboyedu.com ~]# 
            [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 10
            Server version: 5.7.31-log MySQL Community Server (GPL)
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> 
            mysql> SELECT @@AUTOCOMMIT;
            +--------------+
            | @@AUTOCOMMIT |
            +--------------+
            |            0 |
            +--------------+
            1 row in set (0.01 sec)
            
            mysql> 
            mysql> SET AUTOCOMMIT=1;  # 注意哈，如果不添加GLOBAL关键字，发现无需重启当前会话，但仅对当前会话生效！这一点可参考下面新打开的会话信息。
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT @@AUTOCOMMIT;  # 发现当前会话立即生效啦~
            +--------------+
            | @@AUTOCOMMIT |
            +--------------+
            |            1 |
            +--------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> QUIT
            Bye
            [root@docker201.oldboyedu.com ~]# 
            [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 11
            Server version: 5.7.31-log MySQL Community Server (GPL)
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> 
            mysql> SELECT @@AUTOCOMMIT;  # 很明显，如果不使用GLOBAL关键字修改，对新打开的会话是无法修改的哟~
            +--------------+
            | @@AUTOCOMMIT |
            +--------------+
            |            0 |
            +--------------+
            1 row in set (0.00 sec)
            
            mysql> 
            
        (2)永久生效
            修改MySQL的配置文件，将AUTOCOMMIT的初始值设置为0即可，但需要重启MySQL实例才能生效哟~具体操作如下所示:
            [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 9
            Server version: 5.7.31-log MySQL Community Server (GPL)
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> SELECT @@AUTOCOMMIT;
            +--------------+
            | @@AUTOCOMMIT |
            +--------------+
            |            1 |
            +--------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> QUIT
            Bye
            [root@docker201.oldboyedu.com ~]# 
            [root@docker201.oldboyedu.com ~]# vim /oldboyedu/softwares/mysql23307/my.cnf 
            [root@docker201.oldboyedu.com ~]# 
            [root@docker201.oldboyedu.com ~]# tail -1 /oldboyedu/softwares/mysql23307/my.cnf 
            autocommit=0
            [root@docker201.oldboyedu.com ~]# 
            [root@docker201.oldboyedu.com ~]# systemctl restart mysqld23307
            [root@docker201.oldboyedu.com ~]# 
            [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 2
            Server version: 5.7.31-log MySQL Community Server (GPL)
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> 
            mysql> SELECT @@AUTOCOMMIT;
            +--------------+
            | @@AUTOCOMMIT |
            +--------------+
            |            0 |
            +--------------+
            1 row in set (0.00 sec)
            
            mysql> 

```



## 3.事务相关的命令

```
root@mysql106.oldboyedu.com[oldboyedu]---> ? begin
Name: 'BEGIN'
Description:
Syntax:
START TRANSACTION
    [transaction_characteristic [, transaction_characteristic] ...]

transaction_characteristic: {
    WITH CONSISTENT SNAPSHOT
  | READ WRITE
  | READ ONLY
}

BEGIN [WORK]
COMMIT [WORK] [AND [NO] CHAIN] [[NO] RELEASE]
ROLLBACK [WORK] [AND [NO] CHAIN] [[NO] RELEASE]
SET autocommit = {0 | 1}

....

```



# 三.MySQL的InnoDB事务工作流程

## 1.InnoDB事务的工作流程

```
    关于InnoDB事务的工作流程我们不得不了解一下Redo Log和Undo Log，以及在MySQL实例宕机时，其CSR的流程是如何操作的。

	推荐阅读:
		https://dev.mysql.com/doc/refman/5.7/en/mysql-acid.html
```

## 2.Redo Log

### Redo log概述

```
    什么是Redo Log:
        顾名思义，Redo log指的就是重做日志，是事务日志的一种。

    Redo Log作用:
        在事务ACID过程中，实现持久化("Durability")的作用。当然，对于原子性("Atomicity")和一致性("Consistency")也有相应的作用哟~

    Redo Log存放位置:
        Redo Log的存放位置默认在MySQL实例的数据目录(即在"my.cnf"文件中执行的"datadir"属性)中，默认的命名规则为ib_logfile0和ib_logfile1，这两个文件轮训覆盖使用。

    Redo buffer:
        顾名思义，这是将Redo Logs的磁盘数据加载到内存中的名称。其存储了数据页的变化信息和数据页当时的LSN编号。

    Redo的刷新(flush)策略:
        将当前事务的从内存同步到磁盘的过程我们称之为刷新(flush)，即将"Redo buffer"的数据同步到"Redo Log"文件("ib_logfile0"和"ib_logfile1")中。
        还会顺便将一部分的"Redo buffer"中没有提交的事务日志页刷新到磁盘。

```

### Redo Log工作流程

```
    如下所示，请问执行"UPDATE oldboyedu.student SET name='oldboyedu2020' WHERE id=8888;"这条SQL时，MySQL底层是如何工作的。
        mysql> SELECT * FROM oldboyedu.student WHERE id=8888;
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        | id   | name            | age  | gender | time_of_enrollment  | address                  | mobile_number | remarks |
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        | 8888 | oldboyedu8888 |  255 | Male   | 2021-01-22 14:15:03 | oldboyedu-address-8888 |          8888 | NULL    |
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> UPDATE oldboyedu.student SET name='oldboyedu2020' WHERE id=8888;
        Query OK, 1 row affected (0.29 sec)
        Rows matched: 1  Changed: 1  Warnings: 0
        
        mysql> 
        mysql> 
        mysql> COMMIT;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.student WHERE id=8888;
        +------+---------------+------+--------+---------------------+--------------------------+---------------+---------+
        | id   | name          | age  | gender | time_of_enrollment  | address                  | mobile_number | remarks |
        +------+---------------+------+--------+---------------------+--------------------------+---------------+---------+
        | 8888 | oldboyedu2020    |  255 | Male   | 2021-01-22 14:15:03 | oldboyedu-address-8888 |          8888 | NULL    |
        +------+---------------+------+--------+---------------------+--------------------------+---------------+---------+
        1 row in set (0.00 sec)
        
        mysql> 


    如下图所示，演示了一次正常事务的提交流程(此处我们只关注Redo Log，先不要管Undo Log):
        (1)首先在我们分析上述执行流程之前，我们需要将MySQL的数据存储做一个简单的梳理，在MySQL磁盘区域，存在ibdata0,ib_logfile0,ib_logfile1,student.ibd等文件，在内存区域由buffer和redo log buffer;
        (2)在做UPDATA之前，肯定要将数据从MySQL磁盘中的"student.ibd"文件的数据页(我们假设该数据页编号是"page 5200"上，LSN的编号是10001)加载到内存区域的缓冲区池(buffer pool);
        (3)而后执行"UPDATE oldboyedu.student SET name='oldboyedu2020' WHERE id=8888;"这条SQL命令，将对内存中的"buffer pool"数据进行修改(注意哈，此时数据页编号并没有改变，还是"page5200"，但LSN编号要加1，即10002);
        (4)但"buffer pool"数据修改后并不会立即同步到磁盘，而是在用户执行"COMMIT;"后，会将修改的数据页(对"page 5200"的修改)信息以及LSN编号(即10002)写入到内存中的"redo log buffer";
        (5)而"redo log buffer"会通过"WAL"机制，将修改的数据页(即page 5200)信息以及LSN编号(即10002)同步到MySQL磁盘上，写入磁盘成功后，用户的"COMMIT;"操作才算成功，否则会触发"前滚机制"，这意味着本次"COMMIT;"操作失败!

    综上所述，如果MySQL服务器异常宕机，即数据库并非正常关闭的情况下，下次启动数据库时就会触发MySQL的自动故障恢复。其大致工作流程如下所示：
        (1)首先MySQL实例在启动时，会简称"*.ibd"的LSN编号和Redo log的LSN编号是否一致，若是一直则正常启动MySQL实例，若不一致则会触发检查点(checkpoint);
        (2)若表的"*.idb"文件的LSN编号和Redo log的LSN编号不一致，则会触发检查点，将二者数据更新到最新状态，并立刻将最新的状态信息同步到磁盘，这就是检查点的过程，你是否发现这一点和HDFS集群的检查点有着异曲同工之妙呢？

    温馨提示:
        (1)redo存储的是在事务工作过程中，数据页(page)的变化;
        (2)默认情况下，每次COMMIT都会立即写入磁盘，这意味中日志"落盘"成功，则COMMIT就失败。当然，我们可以通过"INNODB_FLUSH_LOG_AT_TRX_COMMIT"参数来控制日志刷新。
            mysql> SELECT @@INNODB_FLUSH_LOG_AT_TRX_COMMIT;
            +----------------------------------+
            | @@INNODB_FLUSH_LOG_AT_TRX_COMMIT |
            +----------------------------------+
            |                                1 |
            +----------------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
        (3)MySQL出现异常宕机(Crash)时，Redo log可以提供的时前滚功能(Crash safe recovery,简称"CSR");

    参考连接:
        https://dev.mysql.com/doc/refman/5.7/en/innodb-redo-log.html

```

### Redo Log buffer刷新参数说明

```
    如下所示，我们可以通过参数来"INNODB_FLUSH_LOG_AT_TRX_COMMIT"来控制内存的重做日志(Redo Log buffer)刷新的策略。该参数默认值为1。
        mysql> SELECT @@INNODB_FLUSH_LOG_AT_TRX_COMMIT;
        +----------------------------------+
        | @@INNODB_FLUSH_LOG_AT_TRX_COMMIT |
        +----------------------------------+
        |                                1 |
        +----------------------------------+
        1 row in set (0.00 sec)
        
        mysql> 

    官方提供了三个参数让我们提示，分别为: 0，1(默认值)，2。
        0:
            每秒刷新日志到OS cache，而后由操作系统通过fsync到磁盘，间隔多长时间将OS cache同步到磁盘和操作系统的缓存机制有关。
            异常宕机时，会有可能导致丢失1秒内发生的所有事物。
        1:
            在每次事务提交时，会立即刷新Redo Log到磁盘后，COMMIT才会成功。
            这是最安全的策略，也是官方的默认配置。
        2:
            每次事物提交，都立即刷新Redo Log buffer到os cache，再每秒fsync到磁盘。
            异常宕机时，尽管数据库进程挂掉，但只要操作系统没有挂掉，数据是不会丢失的，因为每秒会fsync到磁盘。但我们并不能保证操作系统就一定不会宕机，因此也会有可能丢失1秒内的事物。

    温馨提示:
        (1)综上所述，Redo Log buffer还和操作系统缓存机制有关，所以刷新策略可能和"INNODB_FLUSH_METHOD"参数有一定联系，我在"MySQL的InnoDB锁机制"章节有详细介绍。
        (2)Redo也有"GROUP COMMIT;"的功能。可以理解为: 在每次刷新已提交的Redo时，顺便可以将一些未提交的事物Redo也一次性刷写到磁盘，此时为了区别不同状态的redo，会加一些比较特殊的标记来区分是否COMMIT。

```

## 3.Undo Log

### Undo Log概述

```
    什么是Undo Log:
        经过上面的了解，我们知道Redo有其特有的功能就是重放日志，但光有Redo log是无法让一个未提交的事物进行回滚的，这个时候就得引入回滚日志，即"Undo Log"。
        回滚日志(Undo Logs)是用于存储事务工作过程中的回滚信息(也可以理解为历史版本信息)。其默认的命名为"ibdata1"，如下所示，我们可以使用"innodb_data_file_path"参数对其进行修改！
            mysql> SELECT @@innodb_data_file_path;
            +--------------------------------------------------+
            | @@innodb_data_file_path                          |
            +--------------------------------------------------+
            | ibdata1:76M;ibdata2:128M;ibdata3:128M:autoextend |
            +--------------------------------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
        所谓的回滚信息可以理解为数据页变化之前的反操作，比如某张表中name="Jason Yin"，该表数据底层存储在某个数据页中，此时做了一个update操作，将name="Jason2020"，而回滚日志就是记录反向update操作进行还原，即name="Jason Yin"。
        

    Undo Log存放位置:
        在MySQL 5.7版本中，Undo日志默认存放在"ibdata1"和"ibtmp1"这两个文件中。大多数情况下我们研究的是"ibdata1"这个文件。
    
    Undo Log作用:
        在事务ACID过程中，实现原子性("Atomicity")的作用。另外，一致性("Consistency")和隔离性("Isolation")也有相应的作用哟~

    Undo Log的逻辑结构:
        Undo Log的表空间和系统的表空间并不一致，系统的表空间通常是一个表(或者一个表空间)对应一个段，而Undo Log是由多个回滚段组成。
        针对MySQL 5.7而言,Undo Log默认是有128个回滚段，其中ibdata1文件存储1个回滚段，用于记录系统表回滚段；而ibtmp1存储32个回滚段，用于记录临时表的回滚段。
        每个回滚段由多个slot组成，默认在16k的数据页(page)中一个段有1024个slot，而每个slot对应一个事物。
        综上所述，我们可以得到Undo Log的逻辑结构由外到内的关系为: Undo log表空间 ---> 段 ---> solt

    温馨提示:
        (1)在ROLLBACK时，将数据恢复到修改之前的状态;
        (2)在Crash Recovery过程中，先通过Redo Log进行前滚，而后将Redo Log当中的记录未提交的事务通过Undo Log进行回滚(这是由于Redo也有"组提交"的功能，在上文我已经提到过);
        (3)Undo提供快照技术，保存事务修改之前的数据状态，保证了MVCC，隔离性，mysqldump的热备恢复机制等;
        (4)在MySQL 5.7版本中，Undo日志被存放在"ibdata1","ibdata2","ibdataN","ibtmp1"文件中，请允许我下面将"ibdata1","ibdata2","ibdataN"统称为"ibdata*";
        (5)回滚日志默认有128个回滚段，其中在"ibdata*"有96个回滚段，主要记录一些独立表空间的回滚信息，而"ibtmp1"文件会记录32个回滚段，主要记录的是一些临时表的回滚信息，通常情况下我们研究的是"ibdata*"日志文件;
        
    推荐阅读:
    	https://dev.mysql.com/doc/refman/5.7/en/innodb-undo-tablespaces.html

```

### Undo Log工作流程

```
    如下所示，请问执行"UPDATE oldboyedu.student SET name='oldboyedu2020' WHERE id=8888;"这条SQL时，MySQL底层是如何工作的。
        mysql> SELECT * FROM oldboyedu.student WHERE id=8888;
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        | id   | name            | age  | gender | time_of_enrollment  | address                  | mobile_number | remarks |
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        | 8888 | oldboyedu8888 |  255 | Male   | 2021-01-22 14:15:03 | oldboyedu-address-8888 |          8888 | NULL    |
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> UPDATE oldboyedu.student SET name='oldboyedu2020' WHERE id=8888;
        Query OK, 1 row affected (0.29 sec)
        Rows matched: 1  Changed: 1  Warnings: 0
        
        mysql> 
        mysql> 
        mysql> COMMIT;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.student WHERE id=8888;
        +------+---------------+------+--------+---------------------+--------------------------+---------------+---------+
        | id   | name          | age  | gender | time_of_enrollment  | address                  | mobile_number | remarks |
        +------+---------------+------+--------+---------------------+--------------------------+---------------+---------+
        | 8888 | oldboyedu2020    |  255 | Male   | 2021-01-22 14:15:03 | oldboyedu-address-8888 |          8888 | NULL    |
        +------+---------------+------+--------+---------------------+--------------------------+---------------+---------+
        1 row in set (0.00 sec)
        
        mysql> 

    在MySQL内部，InnoDB存储引擎向数据库中存储的每一行添加三个字段:
        DB_TRX_ID:
            一个6字节的"DB_TRX_ID"字段表示插入或更新该行的最后一个事务的事务标识符。此外，删除在内部被视为更新，在该更新中，行中的特殊位被设置为将其标记为已删除。
        DB_ROLL_PTR:
            每行还包含一个7字节的DB_ROLL_PTR字段，称为回滚指针。回滚指针指向写入回滚段的撤消日志记录。如果行已更新，则撤消日志记录将包含在更新行之前重建行内容所必需的信息。
        DB_ROW_ID:
            一个6字节的DB_ROW_ID字段包含一个行ID，该行ID随着插入新行而单调增加。如果 InnoDB自动生成聚集索引，该索引包含行ID值。否则，该DB_ROW_ID列不会出现在任何索引中。

    如下图所示，演示了一次正常事务的提交流程(此处我们只关注Undo Log，先不要管Redo Log)::
        (1)在做UPDATA之前，肯定要将数据从MySQL磁盘中的"student.ibd"文件的数据页(我们假设该数据页编号是"page 5200"上，LSN的编号是10001)加载到内存区域的缓冲区池(buffer pool);
        (2)将数据加载到内存后，在执行UPDATE操作之前还得启动事物(即生成最新的快照数据，此处我们先忽略"锁"的情况下)并创建一个事物ID，即"DB_TRX_ID"，而后通过"DB_ROLL_PTR"指向如何回滚信息，通过DB_ROW_ID记录操作的行;
        (3)而后执行UPDATE操作，将对内存中的"buffer pool"数据进行修改(注意哈，此时数据页编号并没有改变，还是"page5200"，但LSN编号要加1，即10002)，并将记录提交到Redo log buffer，而后通过WAL机制写入Redo Log对应的磁盘文件中;
        (4)我们知道Redo log有"GROUP COMMIT"的功能，因此无法避免将一些未提交的事物写入到磁盘中(我们通常称之为"前滚")，如果此时用户手动执行了"ROLLBACK"操作，则会根据"DB_ROLL_PTR"指针找到对应的数据进行还原;
        (5)如果用户并没有手动执行"ROLLBACK"操作，而是在数据库宕机的情况下，当我们再一次启动数据库时，先加载表空间数据和Redo Log进行前滚，而后用DB_TRX_ID记录每一个事物，若由未提交的事务，则基于DB_ROLL_PTR找到Undo Log进行回滚，从而保证数据的持久性和一致性。

    温馨提示:
        (1)"Undo Log"在内存生成过程中，也会记录"Redo Log"信息哟~
        (2)每个事物开启时，都会通过Undo log生成一个一致性的快照，这个快照是为了便于记录原始数据，从而当用户做了某些DML操作后，想要进行回滚时，可以根据快照来还原数据;

    参考链接:
        https://dev.mysql.com/doc/refman/5.7/en/innodb-multi-versioning.html

```



# 四.MySQL的InnoDB事务隔离级别

## 1.隔离级别概述

```
    隔离级别的主要作用是提供隔离性(Isolation)，另外对于一致性(Consistency)也有保证。

    MySQL的InnoDB存储引擎支持的隔离级别(transaction_isolation)有以下几种:
        READ UNCOMMITTED，简称"RU":
            描述:
                可以读取数据页(page)中未提交的事务。
            存在的问题: 
                脏页读，不可重复读，幻读。因此生产环境中基本上不用。
        READ COMMITTED，简称"RC":
            描述:
                可以读取数据页(page)中已提交的事务。
            存在的问题:
                不可重复读，幻读。这是Oracle数据库的默认级别。
        REPEATABLE READ，简称"RR":
            描述:
                可以重复读取数据页(page)，这是MySQL的默认级别。
            存在的问题:
                可能存在幻读。但我们可以基于一些锁机制来避免这种现象。
        SERIALIZABLE(音标为:[ˈsɪˌriəˌlaɪzəbl])，简称"SR":
            描述:
                串行化执行事务，即并发量为1；换句话说，在同一个时刻，只能执行一个事务。
            存在的问题:
                以上问题都可以规避，但事务的并发性极低。

    温馨提示:
        (1)上面提到的"脏读"，"不可重复读"，"幻读"不是SQL层的数据行的SELECT，而指的是存储引擎的读，是数据页(page)的读取。
            脏读:
                两个独立的事务，若事务1对某个数据页进行修改后但并未提交，此时通常数据会在内存中修改并未同步到磁盘，若在事务2内能读取到事务1修改的数据，我们称之为"脏读"，如果出现了脏读现象，说明隔离性极差。
                对于"脏读"，在生产环境中一般是不允许出现的。
            不可重复读:
                在同一个事物中，两次读取数据页的结果并不相同的现象，我们称之为"不可重复读"。本质上是读取到了由其它事务导致数据页发生变化的脏页数据。
                对于"不可重复读"，在事物的隔离性和数据最终一致性要求比较高的业务中，也是不允许出现的。如果业务能够容忍，也是可以出现性的。
            幻读:
                在一个更新(UPDATE)事务中，由于其他事务的某些操作将数据页修改，导致该事务中出现一些不该出现的数据现象，我们称之为"幻读"。

        (2)综上所述，"脏读"，"不可重复读"，"幻读"违背了事物的隔离性，因此我们在交易类场景中应该避免这类事情发生;
            

    参考连接:
        https://dev.mysql.com/doc/refman/5.7/en/innodb-transaction-isolation-levels.html

```

## 2.修改MySQL默认的隔离级别

### 2.1查看MySQL 5.7默认的隔离级别

```
mysql> SELECT @@transaction_isolation;
+-------------------------+
| @@transaction_isolation |
+-------------------------+
| REPEATABLE-READ         |
+-------------------------+
1 row in set (0.00 sec)

mysql> 


温馨提示:(mysql 5.6查询隔离级别如下)
root@mysql106.oldboyedu.com[(none)]---> select @@global.tx_isolation;
+-----------------------+
| @@global.tx_isolation |
+-----------------------+
| REPEATABLE-READ       |
+-----------------------+
1 row in set (0.00 sec)

root@mysql106.oldboyedu.com[(none)]---> 

```

### 2.2临时修改MySQL默认的隔离级别

```
[root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> SELECT @@transaction_isolation;
+-------------------------+
| @@transaction_isolation |
+-------------------------+
| REPEATABLE-READ         |
+-------------------------+
1 row in set (0.00 sec)

mysql> 
mysql> SET GLOBAL transaction_isolation='READ-UNCOMMITTED';  # 全局修改默认的隔离级别，仅对新打开的会话生效哟~
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> SELECT @@transaction_isolation;
+-------------------------+
| @@transaction_isolation |
+-------------------------+
| REPEATABLE-READ         |
+-------------------------+
1 row in set (0.00 sec)

mysql> 
mysql> 
mysql> QUIT
Bye
[root@docker201.oldboyedu.com ~]# 
[root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> SELECT @@transaction_isolation;  # 很明显，咱们修改成功啦，我们临时将MySQL的默认隔离级别更改为读未提交。
+-------------------------+
| @@transaction_isolation |
+-------------------------+
| READ-UNCOMMITTED        |
+-------------------------+
1 row in set (0.00 sec)

mysql> 

```

### 2.3永久修改MySQL的默认级别

```
    只需要修改"/etc/my.cnf"配置文件即可，设置对应的事务隔离级别，如下所示:
        [root@docker201.oldboyedu.com ~]# tail -1 /oldboyedu/softwares/mysql23307/my.cnf 
        transaction_isolation='READ-UNCOMMITTED'
        [root@docker201.oldboyedu.com ~]# 

    需要注意的是，当我们修改配置文件想让其立即生效，就得重启MySQL实例哟~

```

## 3.READ UNCOMMITTED隔离级别常见的现象案例复现

### 3.1脏读案例演示

```
    脏读概述:
        如下图所示，两个独立的事务，若事务1对某个数据页进行修改后但并未提交，此时数据通常会在内存中修改，若在事务2内能读取到事务1修改的数据，我们称之为"脏读"，如果出现了脏读现象，说明隔离性极差。

    案例:
        会话1操作如下:
            mysql> SELECT @@transaction_isolation;
            +-------------------------+
            | @@transaction_isolation |
            +-------------------------+
            | READ-UNCOMMITTED        |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> BEGIN;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +------------------+------+---------------------------+
            | name             | age  | address                   |
            +------------------+------+---------------------------+
            | oldboyedu88888 |  255 | oldboyedu-address-88888 |
            +------------------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> UPDATE oldboyedu.student SET name='Jason Yin' WHERE id=88888;
            Query OK, 1 row affected (0.30 sec)
            Rows matched: 1  Changed: 1  Warnings: 0
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +-----------+------+---------------------------+
            | name      | age  | address                   |
            +-----------+------+---------------------------+
            | Jason Yin |  255 | oldboyedu-address-88888 |
            +-----------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 

        会话2操作如下:
            mysql> SELECT @@transaction_isolation;
            +-------------------------+
            | @@transaction_isolation |
            +-------------------------+
            | READ-UNCOMMITTED        |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> BEGIN;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +------------------+------+---------------------------+
            | name             | age  | address                   |
            +------------------+------+---------------------------+
            | oldboyedu88888 |  255 | oldboyedu-address-88888 |
            +------------------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +-----------+------+---------------------------+
            | name      | age  | address                   |
            +-----------+------+---------------------------+
            | Jason Yin |  255 | oldboyedu-address-88888 |
            +-----------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 

```

### 3.2不可重复读案例演示

```
    不可重复读概述:
        如下图所示，在同一个事物中，两次读取数据页的结果并不相同的现象，我们称之为"不可重复读"。本质上是读取到了由其它事务导致数据页发生变化的脏页数据。

    案例:
        会话1操作如下:
            mysql> SELECT @@transaction_isolation;
            +-------------------------+
            | @@transaction_isolation |
            +-------------------------+
            | READ-UNCOMMITTED        |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +------------------+------+---------------------------+
            | name             | age  | address                   |
            +------------------+------+---------------------------+
            | oldboyedu88888 |  255 | oldboyedu-address-88888 |
            +------------------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> BEGIN;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> 
            mysql> SELECT @@transaction_isolation;
            +-------------------------+
            | @@transaction_isolation |
            +-------------------------+
            | READ-UNCOMMITTED        |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> BEGIN;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +------------------+------+---------------------------+
            | name             | age  | address                   |
            +------------------+------+---------------------------+
            | oldboyedu88888 |  255 | oldboyedu-address-88888 |
            +------------------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> UPDATE oldboyedu.student SET name='Jason Yin' WHERE id=88888;
            Query OK, 1 row affected (0.30 sec)
            Rows matched: 1  Changed: 1  Warnings: 0
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +-----------+------+---------------------------+
            | name      | age  | address                   |
            +-----------+------+---------------------------+
            | Jason Yin |  255 | oldboyedu-address-88888 |
            +-----------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> UPDATE oldboyedu.student SET name='Jason Yin2020' WHERE id=88888;
            Query OK, 1 row affected (0.00 sec)
            Rows matched: 1  Changed: 1  Warnings: 0
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +---------------+------+---------------------------+
            | name          | age  | address                   |
            +---------------+------+---------------------------+
            | Jason Yin2020 |  255 | oldboyedu-address-88888 |
            +---------------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 

        会话2操作如下:
            mysql> SELECT @@transaction_isolation;
            +-------------------------+
            | @@transaction_isolation |
            +-------------------------+
            | READ-UNCOMMITTED        |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> BEGIN;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +------------------+------+---------------------------+
            | name             | age  | address                   |
            +------------------+------+---------------------------+
            | oldboyedu88888 |  255 | oldboyedu-address-88888 |
            +------------------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +-----------+------+---------------------------+
            | name      | age  | address                   |
            +-----------+------+---------------------------+
            | Jason Yin |  255 | oldboyedu-address-88888 |
            +-----------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> SELECT name,age,address FROM oldboyedu.student WHERE id=88888;
            +---------------+------+---------------------------+
            | name          | age  | address                   |
            +---------------+------+---------------------------+
            | Jason Yin2020 |  255 | oldboyedu-address-88888 |
            +---------------+------+---------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            
```

### 3.3幻读案例演示

```
    不可重复读概述:
        如下图所示，在一个更新(UPDATE)事务中，由于其他事务的某些操作(比如INSERT)将数据页修改，导致该事务中出现一些不该出现的数据(这些数据指的是其它事务INSERT数据所产生的"幻行")现象，我们称之为"幻读"。

    案例:
        会话1操作如下(注意哈，UPDATE操作要在会话2的INSERT操作之前，但必须比会话2的事物后提交，否则看不到实验效果~):
            mysql> SELECT @@transaction_isolation;
            +-------------------------+
            | @@transaction_isolation |
            +-------------------------+
            | READ-UNCOMMITTED        |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> BEGIN;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT id,alarm_type,mobile_number FROM oldboyedu.call_police;
            +----+------------+---------------+
            | id | alarm_type | mobile_number |
            +----+------------+---------------+
            |  1 | 公安       | 110           |
            |  2 | 救护车     | 120           |
            |  3 | 交警       | 122           |
            |  4 | 火警       | 119           |
            +----+------------+---------------+
            4 rows in set (0.00 sec)
            
            mysql> 
            mysql> UPDATE oldboyedu.call_police SET mobile_number=120 WHERE id > 3;
            Query OK, 1 row affected (0.00 sec)
            Rows matched: 1  Changed: 1  Warnings: 0
            
            mysql> 
            mysql> COMMIT;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT id,alarm_type,mobile_number FROM oldboyedu.call_police;
            +----+------------+---------------+
            | id | alarm_type | mobile_number |
            +----+------------+---------------+
            |  1 | 公安       | 110           |
            |  2 | 救护车     | 120           |
            |  3 | 交警       | 122           |
            |  4 | 火警       | 120           |
            |  5 | 公安       | 110           |
            +----+------------+---------------+
            5 rows in set (0.00 sec)
            
            mysql> 

        会话2操作如下(注意哈，INSERT操作要在会话1的UPDATE操作之后，但必须必会话1的事物先提交，否则看不到实验效果~):
            mysql> SELECT @@transaction_isolation;
            +-------------------------+
            | @@transaction_isolation |
            +-------------------------+
            | READ-UNCOMMITTED        |
            +-------------------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> BEGIN;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 
            mysql> SELECT id,alarm_type,mobile_number FROM oldboyedu.call_police;
            +----+------------+---------------+
            | id | alarm_type | mobile_number |
            +----+------------+---------------+
            |  1 | 公安       | 110           |
            |  2 | 救护车     | 120           |
            |  3 | 交警       | 122           |
            |  4 | 火警       | 119           |
            +----+------------+---------------+
            4 rows in set (0.00 sec)
            
            mysql> 
            mysql> INSERT INTO oldboyedu.call_police VALUES(5,'公安',110,'负责处理刑事、治安案件、紧急
            危难求助(迷路等)');Query OK, 1 row affected (0.00 sec)
            
            mysql> 
            mysql> COMMIT;
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 

```


## 4.MySQL默认的隔离级别为"REPEATABLE-READ"

### 4.1可重复度隔离级别案例演示

```
    准备测试表:
        mysql> CREATE TABLE IF NOT EXISTS t1( id int primary key, name varchar(30), age tinyint );
        Query OK, 0 rows affected (0.01 sec)
        
        mysql> 
        mysql> 
        mysql> INSERT INTO t1 VALUES 
            ->     (1,'AAA',10),
            ->     (2,'BBB',20),
            ->     (3,'CCC',30),
            ->     (4,'DDD',40),
            ->     (5,'EEE',50),
            ->     (6,'FFF',60),
            ->     (7,'GGG',70),
            ->     (8,'HHH',80);
        Query OK, 8 rows affected (0.00 sec)
        Records: 8  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SHOW INDEX FROM oldboyedu.t1;
        +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | t1    |          0 | PRIMARY  |            1 | id          | A         |           8 |     NULL | NULL   |      | BTREE      |         |               |
        +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> ALTER TABLE oldboyedu.t1 ADD INDEX my_index_demo(age);  # 本案例中，可以不创建索引哟，但为了下面的测试，建议还是创建辅助索引！
        Query OK, 0 rows affected (0.09 sec)
        Records: 0  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SHOW INDEX FROM oldboyedu.t1;
        +-------+------------+---------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table | Non_unique | Key_name      | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------+------------+---------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | t1    |          0 | PRIMARY       |            1 | id          | A         |           8 |     NULL | NULL   |      | BTREE      |         |               |
        | t1    |          1 | my_index_demo |            1 | age         | A         |           8 |     NULL | NULL   | YES  | BTREE      |         |               |
        +-------+------------+---------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        2 rows in set (0.00 sec)
        
        mysql> 


    会话1执行的命令:
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |   50 |
        |  6 | FFF  |   60 |
        |  7 | GGG  |   70 |
        |  8 | HHH  |   80 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> UPDATE oldboyedu.t1 SET age=125 WHERE age > 50;
        Query OK, 3 rows affected (0.00 sec)
        Rows matched: 3  Changed: 3  Warnings: 0
        
        mysql> 
        mysql> COMMIT;
        Query OK, 0 rows affected (0.01 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |   50 |
        |  6 | FFF  |  125 |
        |  7 | GGG  |  125 |
        |  8 | HHH  |  125 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 

    会话2执行的命令:
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |   50 |
        |  6 | FFF  |   60 |
        |  7 | GGG  |   70 |
        |  8 | HHH  |   80 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |   50 |
        |  6 | FFF  |   60 |
        |  7 | GGG  |   70 |
        |  8 | HHH  |   80 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |   50 |
        |  6 | FFF  |   60 |
        |  7 | GGG  |   70 |
        |  8 | HHH  |   80 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 

```

### 4.2基于辅助索引的两种锁机制，即"GAP"和"next-lock"案例(了解即可)

```
    会话1执行命令:
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |   50 |
        |  6 | FFF  |  125 |
        |  7 | GGG  |  125 |
        |  8 | HHH  |  125 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> UPDATE oldboyedu.t1 SET age=110 WHERE age >= 50;
        Query OK, 4 rows affected (0.00 sec)
        Rows matched: 4  Changed: 4  Warnings: 0
        
        mysql> 
        mysql> COMMIT;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |  110 |
        |  6 | FFF  |  110 |
        |  7 | GGG  |  110 |
        |  8 | HHH  |  110 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 

    会话2执行命令:
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |   50 |
        |  6 | FFF  |  125 |
        |  7 | GGG  |  125 |
        |  8 | HHH  |  125 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> INSERT INTO oldboyedu.t1 VALUES (9,'MMM',18),(10,'NNN',25);
        ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
        mysql> 
        mysql> INSERT INTO oldboyedu.t1 VALUES (9,'MMM',18),(10,'NNN',25);  # 很明显，只要会话1的UPDATE操作未提交，则我们想要执行INSERT操作将始终无法执行成功！这是有其内部的锁机制！
        ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
        mysql> 
        mysql> INSERT INTO oldboyedu.t1 VALUES (9,'MMM',18),(10,'NNN',25);
        Query OK, 2 rows affected (5.02 sec)
        Records: 2  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |  110 |
        |  6 | FFF  |  110 |
        |  7 | GGG  |  110 |
        |  8 | HHH  |  110 |
        |  9 | MMM  |   18 |
        | 10 | NNN  |   25 |
        +----+------+------+
        10 rows in set (0.00 sec)
        
        mysql> 
        
温馨提示:
	SELECT * FROM sys.innodb_lock_waits\G  # 查看所等待信息.

```

### 4.3REPEATABLE-READ隔离级别的优点

```
    (1)防止不可重复性现象:
        利用的就是Undo Log的一致性快照读，也就是说，其它事务修改数据并不会影响当前事务，这也是MVCC的重要功能。

    (2)引入锁机制:
        通过REPEATABLE-READ隔离机制，基本上可以解决99%以上的幻读，MySQL官方为了更加严谨，引入了基于辅助索引的两种锁机制，即"GAP"和"next-lock"。  
```





# 五.MySQL的InnoDB锁机制(了解即可)

## 1.MySQL锁机制概述

```
    开发的小伙伴应该很清楚锁的作用，它主要用于多线程场景中在线程安全进行通信的一种手段，只不过在MySQL中锁被抽象化了。

    MySQL锁的作用:
        (1)保证事务之间的隔离性，也保证了数据的一致性;
        (2)保证资源不会争用，锁是属于资源的，不是某个事务的特性;
        (3)每次事务需要资源的时候，需要申请持有资源的锁;

    MySQL锁的常见类型可以按照资源，粒度，功能来进行分类:
        (1)资源:
            通常指的是内存锁(比如:"mutex","latch")和对象锁(比如:"MDL","Table_lock","record(row) lock","GAP","Next-lock")。

        (2)锁粒度:
            mutex，latch:
                这两个锁属于轻量级内存锁，保证内存数据页资源不被争用，不被置换。了解即可，可参考官方文档: https://dev.mysql.com/doc/refman/5.7/en/glossary.html#glos_mutex
            MDL:
                元数据锁，通常针对DDL语句，备份表(全局表锁)会自动触发。
            Table_lock:
                表锁，通常针对DDL语句，备份表(全局表锁)，LOCK TABLE table_name READ/WRITE会自动触发；当然，也有可能是有行级锁升级为表级锁，即本来该走行级锁的，但最终由于程序员写的SQL不严谨导致本该为行级锁升级为表级锁。
                读锁(LOCK TABLES student READ;)时别的事务可以看,但不能写;
                写锁(LOCK TABLES student WRITE;)时别的事务不可以读也不可以写;
            record(row) lock:
                属于行级锁，也属于索引锁，即锁定聚簇索引(主键,PRIMARY KEY)。
                RR级别基于主键是record锁类型.
            GAP Lock:
                属于行级锁，间隙锁，在"REPEATABLE-READ"隔离级别，普通辅助索引的间隙锁。
            Next-lock:
                属于行级锁，下一键锁，属于"GAP + record(row) lock"，可以理解为普通索引的范围锁。

        (3)功能:
            按照功能分为以下四类锁:
                exclusive lock，简称"X"锁:
                    数据行级别的排他锁，也称为存储引擎层的写锁。
                intention exclusive lock，简称"IX"锁:
                    表级别的意向共享锁。
                shared lock，简称S锁:
                    数据行级别的共享锁，也称为存储引擎层的读锁。
                intention shared lock，简称"IS"锁:
                    表级别的意向排他锁。
            如下图所示，展示各个功能锁之间的兼容性。
        
    参考连接:
        https://dev.mysql.com/doc/refman/5.7/en/innodb-locking.html

```

![1631788213676](10-老男孩教育-MySQL的事物管及行级锁机制.assets/1631788213676.png)

## 2.MySQL的InnoDB存储引擎锁机制案例复现

### 准备测试表("oldboyedu.t1")

```
        mysql> CREATE TABLE IF NOT EXISTS t1( id int primary key, name varchar(30), age tinyint );
        Query OK, 0 rows affected (0.01 sec)
        
        mysql> 
        mysql> 
        mysql> INSERT INTO t1 VALUES 
            ->     (1,'AAA',10),
            ->     (2,'BBB',20),
            ->     (3,'CCC',30),
            ->     (4,'DDD',40),
            ->     (5,'EEE',50),
            ->     (6,'FFF',60),
            ->     (7,'GGG',70),
            ->     (8,'HHH',80);
        Query OK, 8 rows affected (0.00 sec)
        Records: 8  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SHOW INDEX FROM oldboyedu.t1;
        +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | t1    |          0 | PRIMARY  |            1 | id          | A         |           8 |     NULL | NULL   |      | BTREE      |         |               |
        +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> ALTER TABLE oldboyedu.t1 ADD INDEX my_index_demo(age);  # 本案例中，可以不创建索引哟，但为了下面的测试，建议还是创建辅助索引！
        Query OK, 0 rows affected (0.09 sec)
        Records: 0  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SHOW INDEX FROM oldboyedu.t1;
        +-------+------------+---------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table | Non_unique | Key_name      | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------+------------+---------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | t1    |          0 | PRIMARY       |            1 | id          | A         |           8 |     NULL | NULL   |      | BTREE      |         |               |
        | t1    |          1 | my_index_demo |            1 | age         | A         |           8 |     NULL | NULL   | YES  | BTREE      |         |               |
        +-------+------------+---------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        2 rows in set (0.00 sec)
        
        mysql> 

```

### record(row) lock(基于主键id字段加锁)

```
    会话1执行命令:(只针对某一行做操作)
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |  110 |
        |  6 | FFF  |  110 |
        |  7 | GGG  |  110 |
        |  8 | HHH  |  110 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> UPDATE oldboyedu.t1 SET age=120 WHERE id=3;
        Query OK, 1 row affected (0.00 sec)
        Rows matched: 1  Changed: 1  Warnings: 0
        
        mysql> 

    会话2执行命令:(针对会话1操作的同一行进行操作时会阻塞，但处理会话1中未使用的行则并不阻塞)
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |  110 |
        |  6 | FFF  |  110 |
        |  7 | GGG  |  110 |
        |  8 | HHH  |  110 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> UPDATE oldboyedu.t1 SET age=110 WHERE id=3;
        ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
        mysql> 
        mysql> UPDATE oldboyedu.t1 SET age=110 WHERE id=2;
        Query OK, 1 row affected (0.00 sec)
        Rows matched: 1  Changed: 1  Warnings: 0
        
        mysql> 

    温馨提示:
        (1)如下图所示，当执行"UPDATE oldboyedu.t1 SET age=110 WHERE id=3;"命令时发现阻塞了，很有可能被锁住了，
        (2)我们可以通过"SELECT * FROM sys.innodb_lock_waits\G"命令来查看，注意观察"waiting_lock_mode"字段，不难发现锁的类型为"X(写锁)"类型哟~
            mysql> SELECT * FROM sys.innodb_lock_waits\G
            *************************** 1. row ***************************
                            wait_started: 2021-02-03 19:07:03
                                wait_age: 00:00:13
                           wait_age_secs: 13
                            locked_table: `oldboyedu`.`t1`
                            locked_index: PRIMARY
                             locked_type: RECORD
                          waiting_trx_id: 111692
                     waiting_trx_started: 2021-02-03 19:06:32
                         waiting_trx_age: 00:00:44
                 waiting_trx_rows_locked: 1
               waiting_trx_rows_modified: 0
                             waiting_pid: 22
                           waiting_query: UPDATE oldboyedu.t1 SET age=110 WHERE id=3
                         waiting_lock_id: 111692:88:3:4
                       waiting_lock_mode: X
                         blocking_trx_id: 111691
                            blocking_pid: 21
                          blocking_query: SELECT * FROM sys.innodb_lock_waits
                        blocking_lock_id: 111691:88:3:4
                      blocking_lock_mode: X
                    blocking_trx_started: 2021-02-03 19:06:14
                        blocking_trx_age: 00:01:02
                blocking_trx_rows_locked: 1
              blocking_trx_rows_modified: 1
                 sql_kill_blocking_query: KILL QUERY 21
            sql_kill_blocking_connection: KILL 21
            1 row in set, 3 warnings (0.00 sec)
            
            mysql> 

```


### GAP Lock

```
    会话1执行命令:
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |  110 |
        |  6 | FFF  |  110 |
        |  7 | GGG  |  110 |
        |  8 | HHH  |  110 |
        +----+------+------+
        8 rows in set (0.01 sec)
        
        mysql> 
        mysql> UPDATE oldboyedu.t1 SET age=88 WHERE age<20;
        Query OK, 1 row affected (0.00 sec)
        Rows matched: 1  Changed: 1  Warnings: 0
        
        mysql> 
        mysql> EXPLAIN UPDATE oldboyedu.t1 SET age=88 WHERE age<20;
        +----+-------------+-------+------------+-------+---------------+---------------+---------+-------+--
        | id | select_type | table | partitions | type  | possible_keys | key           | key_len | ref   | r
        +----+-------------+-------+------------+-------+---------------+---------------+---------+-------+--
        |  1 | UPDATE      | t1    | NULL       | range | my_index_demo | my_index_demo | 2       | const |  
        +----+-------------+-------+------------+-------+---------------+---------------+---------+-------+--
        1 row in set (0.01 sec)
        
        mysql> 

    会话2执行命令:
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |  110 |
        |  6 | FFF  |  110 |
        |  7 | GGG  |  110 |
        |  8 | HHH  |  110 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> INSERT INTO oldboyedu.t1 VALUES(9,'III',15);
        ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
        mysql> 
        mysql> INSERT INTO oldboyedu.t1 VALUES(9,'III',25);
        Query OK, 1 row affected (0.00 sec)
        
        mysql> 

    温馨提示:
        (1)如下图所示，当执行"INSERT INTO oldboyedu.t1 VALUES(9,'III',15);"命令时发现阻塞了，很有可能被锁住了，
        (2)我们可以通过"SELECT * FROM sys.innodb_lock_waits\G"命令来查看，注意观察"waiting_lock_mode"字段，不难发现锁的类型为"GAP"类型哟~
            mysql> SELECT * FROM sys.innodb_lock_waits\G
            *************************** 1. row ***************************
                            wait_started: 2021-02-03 18:59:53
                                wait_age: 00:00:08
                           wait_age_secs: 8
                            locked_table: `oldboyedu`.`t1`
                            locked_index: my_index_demo
                             locked_type: RECORD
                          waiting_trx_id: 111685
                     waiting_trx_started: 2021-02-03 18:48:17
                         waiting_trx_age: 00:11:44
                 waiting_trx_rows_locked: 7
               waiting_trx_rows_modified: 3
                             waiting_pid: 18
                           waiting_query: INSERT INTO oldboyedu.t1 VALUES(11,'III',15)
                         waiting_lock_id: 111685:88:4:3
                       waiting_lock_mode: X,GAP
                         blocking_trx_id: 111684
                            blocking_pid: 19
                          blocking_query: SELECT * FROM sys.innodb_lock_waits
                        blocking_lock_id: 111684:88:4:3
                      blocking_lock_mode: X
                    blocking_trx_started: 2021-02-03 18:48:40
                        blocking_trx_age: 00:11:21
                blocking_trx_rows_locked: 4
              blocking_trx_rows_modified: 1
                 sql_kill_blocking_query: KILL QUERY 19
            sql_kill_blocking_connection: KILL 19
            1 row in set, 3 warnings (0.01 sec)
            
            mysql> 

```


### 行级锁升级为表级别锁案例

```
    会话1执行命令:
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |  110 |
        |  6 | FFF  |  110 |
        |  7 | GGG  |  110 |
        |  8 | HHH  |  110 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> UPDATE oldboyedu.t1 SET age=88 WHERE age<50;
        Query OK, 4 rows affected (0.01 sec)
        Rows matched: 4  Changed: 4  Warnings: 0
        
        mysql> 
        mysql> EXPLAIN UPDATE oldboyedu.t1 SET age=88 WHERE age<50;
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
        |  1 | UPDATE      | t1    | NULL       | index | my_index_demo | PRIMARY | 4       | NULL |    8 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
        1 row in set (0.00 sec)
        
        mysql> 

    会话2执行命令:
        mysql> SELECT @@transaction_isolation;
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> BEGIN;
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.t1;
        +----+------+------+
        | id | name | age  |
        +----+------+------+
        |  1 | AAA  |   10 |
        |  2 | BBB  |   20 |
        |  3 | CCC  |   30 |
        |  4 | DDD  |   40 |
        |  5 | EEE  |  110 |
        |  6 | FFF  |  110 |
        |  7 | GGG  |  110 |
        |  8 | HHH  |  110 |
        +----+------+------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> INSERT INTO oldboyedu.t1 VALUES(9,'III',33);
        ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
        mysql> 
        mysql> INSERT INTO oldboyedu.t1 VALUES(9,'III',88);
        ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
        mysql> 
        mysql> INSERT INTO oldboyedu.t1 VALUES(9,'III',22);
        ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
        mysql> 

    温馨提示:
        (1)如下图所示，当某个事务执行的更新操作，理论上应该是范围(type=range)锁行，但却上升锁住整个索引字段，即可以理解为锁表。这会直接导致其它事务将无法执行更新操作！本质原因是由于查询的行数超出了总表大小指定的默认比例;
        (2)如下所示，我们可以通过"SELECT * FROM sys.innodb_lock_waits\G"命令来查看当前锁等待的指令，注意观察"waiting_lock_mode"字段，不难发现锁的类型为"X"(写锁)类型哟~
            mysql> SELECT * FROM sys.innodb_lock_waits\G
            *************************** 1. row ***************************
                            wait_started: 2021-02-03 18:38:32
                                wait_age: 00:00:04
                           wait_age_secs: 4
                            locked_table: `oldboyedu`.`t1`
                            locked_index: PRIMARY
                             locked_type: RECORD
                          waiting_trx_id: 111681
                     waiting_trx_started: 2021-02-03 18:27:15
                         waiting_trx_age: 00:11:21
                 waiting_trx_rows_locked: 3
               waiting_trx_rows_modified: 0
                             waiting_pid: 16
                           waiting_query: INSERT INTO oldboyedu.t1 VALUES(9,'III',22)
                         waiting_lock_id: 111681:88:3:1
                       waiting_lock_mode: X
                         blocking_trx_id: 111676
                            blocking_pid: 17
                          blocking_query: SELECT * FROM sys.innodb_lock_waits
                        blocking_lock_id: 111676:88:3:1
                      blocking_lock_mode: X
                    blocking_trx_started: 2021-02-03 18:30:00
                        blocking_trx_age: 00:08:36
                blocking_trx_rows_locked: 9
              blocking_trx_rows_modified: 4
                 sql_kill_blocking_query: KILL QUERY 17
            sql_kill_blocking_connection: KILL 17
            1 row in set, 3 warnings (0.28 sec)
            
            mysql> 

```


### 死锁案例

```
    如下图所示，复现了死锁的案例。
        分析死锁过程:
            (1)左侧事务执行"UPDATE world.city SET name='BeiJing' WHERE id=1;"，该语句执行成功并会对id为1的行加行锁，直到该事务提交后才会释放行锁;
            (2)右侧事务执行"UPDATE world.city SET name='ShangHai' WHERE id=100;"，该语句执行成功并会对id为100的行加行锁，直到该事务提交后才会释放行锁;
            (3)右侧事务执行"UPDATE world.city SET name='AnKang' WHERE id<10;"，该语句执行时需要对"id<10"的所有行进行加锁，但可惜的是第一步中的事物已经占用了"id=1"的行锁始终未提交事务，这意味着右侧的事务将进入阻塞状态以等待左侧事务是否"id=1"的行锁;
            (4)左侧事务执行"UPDATE world.city SET name='ShiJiaZhuang' WHERE id>10;"，该语句执行成功并会对"id>10"的行加行锁;
            (5)MySQL判定右侧事务为死锁，因为其阻塞过程中左侧事务不但没有提交事务，反而执行了新的DML操作，此时一旦判断右侧事务为死锁后，MySQL内部会帮咱们自动回滚右侧事务执行的所有DML操作;

        分析死锁产生的原因:
            (1)"UPDATE world.city SET name='BeiJing' WHERE id=1;"与"UPDATE world.city SET name='ShangHai' WHERE id=100;"并不冲突，因为InnoDB是行级锁;
            (2)同理，"UPDATE world.city SET name='AnKang' WHERE id<10;"和"UPDATE world.city SET name='ShiJiaZhuang' WHERE id>10;"也并不冲突，因为InnoDB是行级锁;
            但是，如果将上面两组语句交叉在不同的事务中执行，就很容易产生行级死锁的现象。
            综上所述，本质上就是两个事务都在等待对方释放资源的情况下而陷入阻塞的状况就是死锁，MySQL帮我们做了优化，自动判断死锁的事物并回滚该事物，生产环境中要尽量避免死锁，从而可以让MySQL不用做额外的回滚工作。

        解决行级死锁方案:
            (1)我们可以将右侧事务"UPDATE world.city SET name='AnKang' WHERE id<10;"修改为"UPDATE world.city SET name='AnKang' WHERE id<10 ADN id>1;"     
            (2)我们也可以将左侧事务"UPDATE world.city SET name='ShiJiaZhuang' WHERE id>10;"修改为"UPDATE world.city SET name='ShiJiaZhuang' WHERE id>10 AND id<100;"

    我们可以通过"SHOW ENGINE INNODB STATUS\G"命令来观察"LATEST DETECTED DEADLOCK"部分的内容信息来查看死锁原因:
        mysql> SHOW ENGINE INNODB STATUS\G
        *************************** 1. row ***************************
          Type: InnoDB
          Name: 
        Status: 
        =====================================
        2021-02-04 07:41:57 0x7f99e55e6700 INNODB MONITOR OUTPUT
        =====================================
        Per second averages calculated from the last 3 seconds
        -----------------
        BACKGROUND THREAD
        -----------------
        srv_master_thread loops: 15 srv_active, 0 srv_shutdown, 19704 srv_idle
        srv_master_thread log flush and writes: 19719
        ----------
        SEMAPHORES
        ----------
        OS WAIT ARRAY INFO: reservation count 132
        OS WAIT ARRAY INFO: signal count 128
        RW-shared spins 0, rounds 110, OS waits 49
        RW-excl spins 0, rounds 33, OS waits 4
        RW-sx spins 0, rounds 0, OS waits 0
        Spin rounds per wait: 110.00 RW-shared, 33.00 RW-excl, 0.00 RW-sx
        ------------------------
        LATEST DETECTED DEADLOCK
        ------------------------
        2021-02-04 07:26:09 0x7f99e566a700
        *** (1) TRANSACTION:
        TRANSACTION 114712, ACTIVE 16 sec starting index read
        mysql tables in use 1, locked 1
        LOCK WAIT 3 lock struct(s), heap size 1136, 2 row lock(s), undo log entries 1
        MySQL thread id 12, OS thread handle 140298955163392, query id 96 localhost root updating
        UPDATE world.city SET name='AnKang' WHERE id<10
        *** (1) WAITING FOR THIS LOCK TO BE GRANTED:
        RECORD LOCKS space id 52 page no 5 n bits 248 index PRIMARY of table `world`.`city` trx id 114712 lock_mode X waiting
        Record lock, heap no 2 PHYSICAL RECORD: n_fields 7; compact format; info bits 0
         0: len 4; hex 80000001; asc     ;;
         1: len 6; hex 00000001c016; asc       ;;
         2: len 7; hex 2f000001821239; asc /     9;;
         3: len 30; hex 4265694a696e672020202020202020202020202020202020202020202020; asc BeiJing                       ; (total 35 bytes);
         4: len 3; hex 414647; asc AFG;;
         5: len 20; hex 4b61626f6c202020202020202020202020202020; asc Kabol               ;;
         6: len 4; hex 801b2920; asc   ) ;;
        
        *** (2) TRANSACTION:
        TRANSACTION 114710, ACTIVE 34 sec fetching rows
        mysql tables in use 1, locked 1
        5 lock struct(s), heap size 1136, 92 row lock(s), undo log entries 90
        MySQL thread id 11, OS thread handle 140298955433728, query id 97 localhost root updating
        UPDATE world.city SET name='ShiJiaZhuang' WHERE id>10
        *** (2) HOLDS THE LOCK(S):
        RECORD LOCKS space id 52 page no 5 n bits 248 index PRIMARY of table `world`.`city` trx id 114710 lock_mode X locks rec but not gap
        Record lock, heap no 2 PHYSICAL RECORD: n_fields 7; compact format; info bits 0
         0: len 4; hex 80000001; asc     ;;
         1: len 6; hex 00000001c016; asc       ;;
         2: len 7; hex 2f000001821239; asc /     9;;
         3: len 30; hex 4265694a696e672020202020202020202020202020202020202020202020; asc BeiJing                       ; (total 35 bytes);
         4: len 3; hex 414647; asc AFG;;
         5: len 20; hex 4b61626f6c202020202020202020202020202020; asc Kabol               ;;
         6: len 4; hex 801b2920; asc   ) ;;
        
        *** (2) WAITING FOR THIS LOCK TO BE GRANTED:
        RECORD LOCKS space id 52 page no 6 n bits 248 index PRIMARY of table `world`.`city` trx id 114710 lock_mode X waiting
        Record lock, heap no 14 PHYSICAL RECORD: n_fields 7; compact format; info bits 0
         0: len 4; hex 80000064; asc    d;;
         1: len 6; hex 00000001c018; asc       ;;
         2: len 7; hex 30000001441cd3; asc 0   D  ;;
         3: len 30; hex 5368616e6748616920202020202020202020202020202020202020202020; asc ShangHai                      ; (total 35 bytes);
         4: len 3; hex 415247; asc ARG;;
         5: len 20; hex 456e7472652052696f7320202020202020202020; asc Entre Rios          ;;
         6: len 4; hex 800328c1; asc   ( ;;
        
        *** WE ROLL BACK TRANSACTION (1)
        ------------
        TRANSACTIONS
        ------------
        Trx id counter 114723
        Purge done for trx's n:o < 114723 undo n:o < 0 state: running but idle
        History list length 1
        LIST OF TRANSACTIONS FOR EACH SESSION:
        ---TRANSACTION 421775103883088, not started
        0 lock struct(s), heap size 1136, 0 row lock(s)
        --------
        FILE I/O
        --------
        ......
        -------------------------------------
        INSERT BUFFER AND ADAPTIVE HASH INDEX
        -------------------------------------
        ......
        ---
        LOG
        ---
        ......
        ----------------------
        BUFFER POOL AND MEMORY
        ----------------------
        ......
        ----------------------
        INDIVIDUAL BUFFER POOL INFO
        ----------------------
        ......
        --------------
        ROW OPERATIONS
        --------------
        ......
        ----------------------------
        END OF INNODB MONITOR OUTPUT
        ============================
        
        1 row in set (0.00 sec)
        
        mysql> 

    当然，我们也可以将死锁的信息记录到日志文件中，仅需修改以下参数重启MySQL实例即可:
        [root@docker201.oldboyedu.com ~]# vim /oldboyedu/softwares/mysql23307/my.cnf 
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# tail -2 /oldboyedu/softwares/mysql23307/my.cnf 
        # 记录所有的死锁信息
        innodb_print_all_deadlocks=1
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# systemctl restart mysqld23307
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 2
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql> 
        mysql> SHOW VARIABLES LIKE '%deadlock%';
        +----------------------------+-------+
        | Variable_name              | Value |
        +----------------------------+-------+
        | innodb_deadlock_detect     | ON    |
        | innodb_print_all_deadlocks | ON    |
        +----------------------------+-------+
        2 rows in set (0.00 sec)
        
        mysql> 
        mysql> select @@innodb_print_all_deadlocks;
        +------------------------------+
        | @@innodb_print_all_deadlocks |
        +------------------------------+
        |                            1 |
        +------------------------------+
        1 row in set (0.00 sec)
        
        mysql> 

```


## 3.MySQL的InnoDB存储引擎一致性问题总结

### 事务的一致性

```
    原子性(Atomicity):
        依赖重做日志("Redo log")和回滚日志("Undo log")。

    隔离性(Isolation):
        依赖隔离级别(Isolation Level)，锁(Lock)，MVCC(通过Undo日志快照功能提供多版本事务并发，即在每个事物启动时申请一个当前最新的数据快照)。

    持久性(Durability):
        依赖"Redo log"的WAL机制(该机制被Hbase也有所借鉴哟~)实现持久性。

    一致性(Consistency):
        保证事务工作前，中，后数据的状态都是完整的。Consistency的特性是受Atomicity，Isolation，Durability来保证一致性的。

```

### 读，写，数据页的一致性

```
    读一致性：
        依赖于隔离级别(Isolation Level)，MVCC等功能。

    写一致性：
        依赖于重做日志("Redo log")，回滚日志("Undo log")以及锁(Lock)。

    数据页一致性：
        依赖于磁盘区域中的double write buffer。

    double write buffer工作流程概述：
        (1)在说double write buffer之前，我们先要搞清楚一个事实，即运行一段时间的MySQL实例其内存数据大多数情况下是随机的，如果我们将随机I/O写入磁盘的话这回浪费磁盘性能，尽管MySQL写入过程是异步的;
        (2)为了提升性能，MySQL会通过double write buffer机制将数据写入到"Undo log"(默认文件名通常为"ibdatga1"整个共享表空间)中，这个写入过程很快，基本上都是以MB为单位，因为这是顺序IO写入;
        (3)当MySQL将内存中的数据通过double write buffer机制写入到"Undo log"后，才会去更新表空间(通常指"*.ibd"文件)，如果在写入过程中，MySQL实例突然崩溃，很有可能写入到"*.ibd"文件的内容并不完整;
        (4)如果在写入表空间("*.ibd")文件过程中程序崩溃，我们可以借助"Undo log"了进行故障恢复("Crash safe Recover"，简称"CSR");
        
    参考连接:
        https://dev.mysql.com/doc/refman/5.7/en/glossary.html#glos_doublewrite_buffer

```

## 4.MySQL的InnoDB存储引擎部分核心参数介绍

### Redo Log buffer刷写参数("INNODB_FLUSH_LOG_AT_TRX_COMMIT")说明

```
    如下所示，我们可以通过参数来"INNODB_FLUSH_LOG_AT_TRX_COMMIT"来控制内存的重做日志(Redo Log buffer)刷新的策略。该参数默认值为1。
        mysql> SELECT @@INNODB_FLUSH_LOG_AT_TRX_COMMIT;
        +----------------------------------+
        | @@INNODB_FLUSH_LOG_AT_TRX_COMMIT |
        +----------------------------------+
        |                                1 |
        +----------------------------------+
        1 row in set (0.00 sec)
        
        mysql> 

    官方提供以下几个有效值:
        0:
            每秒刷新日志到OS cache，而后由操作系统通过fsync到磁盘，间隔多长时间将OS cache同步到磁盘和操作系统的缓存机制有关。
            异常宕机是，会有可能导致丢失1秒内发生的所有事物。
        1:
            在每次事务提交时，会立即刷新Redo Log buffer到磁盘后，COMMIT才会成功。
            这是最安全的策略，也是官方的默认配置。
        2:
            每次事物提交，都立即刷新Redo Log buffer到os cache，再每秒fsync到磁盘。
            异常宕机时，尽管数据库进程挂掉，但只要操作系统没有挂掉，数据是不会丢失的，因为每秒会fsync到磁盘。但我们并不能保证操作系统就一定不会宕机，因此也会有可能丢失1秒内的事物。

    温馨提示:
        (1)综上所述，Redo Log buffer还和操作系统缓存机制有关，所以刷新策略可能和"INNODB_FLUSH_METHOD"参数有一定联系。
        (2)Redo也有"GROUP COMMIT;"的功能。可以理解为: 在每次刷新已提交的Redo时，顺便可以将一些未提交的事物Redo也一次性刷写到磁盘，此时为了区别不同状态的redo，会加一些比较特殊的标记来区分是否COMMIT。

    参考连接:
        https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit
```

### Buffer Pool刷写参数("INNODB_FLUSH_METHOD")说明

```
    如下所示，我们可以通过参数来"INNODB_FLUSH_METHOD"来控制Buffer Pool刷写磁盘是否使用操作系统缓存。该参数默认值为NULL，但在Linux操作系统上的默认值为"fsync"。
        mysql> SELECT @@INNODB_FLUSH_METHOD;
        +-----------------------+
        | @@INNODB_FLUSH_METHOD |
        +-----------------------+
        | NULL                  |
        +-----------------------+
        1 row in set (0.00 sec)
        
        mysql> 

    官方提供以下几个有效值:
        fsync:
            我们知道"Redo Log buffer"和"Buffer Pool"的内存数据写磁盘的时候，需要先写入操作系统缓存(即"OS buffer")，然后在写入磁盘文件。这里MySQL的默认写策略。

        O_DSYNC:
            "Buffer Pool"的内存数据写磁盘的时候，需要先写入操作系统缓存(即"OS buffer")，然后在写入磁盘文件。但是"Redo Log buffer"的内存数据写磁盘的时候，并不会写入OS buffer，而是直接写入到磁盘。该策略生产环境中我们很少使用。

        littlesync:
            此选项用于内部性能测试，当前不受支持。使用风险自负。

        nosync
            此选项用于内部性能测试，当前不受支持。使用风险自负。

        O_DIRECT:
            "Buffer Pool"的内存数据写磁盘的时候，并不会写入OS buffer，而是直接写入到磁盘。但"Redo Log buffer"的内存数据写磁盘的时候，，需要先写入操作系统缓存(即"OS buffer")，然后在写入磁盘文件。
            生产环境推荐使用该策略，并配合固态硬盘使用。

        O_DIRECT_NO_FSYNC
            刷新I/O期间InnoDB使用O_DIRECT，但fsync()在每次写操作后跳过系统调用。

    温馨提示:
        If innodb_flush_method is set to NULL on a Unix-like system, the fsync option is used by default. If innodb_flush_method is set to NULL on Windows, the async_unbuffered option is used by default.

    参考连接:
        https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_flush_method
        https://dev.mysql.com/doc/refman/5.7/en/innodb-architecture.html

```

### 数据缓冲区总大小参数(INNODB_BUFFER_POOL_SIZE)，建议设置操作系统总内存的75%以下。

```
    如下所示，我们可以通过参数来"INNODB_BUFFER_POOL_SIZE"来控制数据缓冲区大小的总大小，包括缓冲数据页和索引页，也是MySQL最大的内存区域，其默认大小为128MB。
        mysql> SELECT @@INNODB_BUFFER_POOL_SIZE;
        +---------------------------+
        | @@INNODB_BUFFER_POOL_SIZE |
        +---------------------------+
        |                 134217728 |
        +---------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT 134217728/1024/1024;
        +---------------------+
        | 134217728/1024/1024 |
        +---------------------+
        |        128.00000000 |
        +---------------------+
        1 row in set (0.00 sec)
        
        mysql> 

    如下所示，我们可以通过下面的方法来临时修改BUFFER POOL的总大小:
        [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 23
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql> 
        mysql> SELECT 134217728/1024/1024;
        +---------------------+
        | 134217728/1024/1024 |
        +---------------------+
        |        128.00000000 |
        +---------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SET GLOBAL INNODB_BUFFER_POOL_SIZE=10737418240;  # 此处我们将BUFFER POOL大小设置为10G
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 
        mysql> SELECT @@INNODB_BUFFER_POOL_SIZE;
        +---------------------------+
        | @@INNODB_BUFFER_POOL_SIZE |
        +---------------------------+
        |                 134217728 |
        +---------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> QUIT
        Bye
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 23
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql> 
        mysql> SELECT @@INNODB_BUFFER_POOL_SIZE;
        +---------------------------+
        | @@INNODB_BUFFER_POOL_SIZE |
        +---------------------------+
        |               10737418240 |
        +---------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT 10737418240/1024/1024/1024;
        +----------------------------+
        | 10737418240/1024/1024/1024 |
        +----------------------------+
        |            10.000000000000 |
        +----------------------------+
        1 row in set (0.00 sec)
        
        mysql> 

    如下所示，我们也快将配置写入配置文件，是其永久生效！
        [root@docker201.oldboyedu.com ~]# vim /oldboyedu/softwares/mysql23307/my.cnf 
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# tail -2 /oldboyedu/softwares/mysql23307/my.cnf 
        # 将BUFFER POOL总大小设置为1G，注意哈，变量名尽量小写！否则MySQL实例启动时可能会不认识大写的变量名称哟~
        innodb_buffer_pool_size=1073741824
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# systemctl restart mysqld23307
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 2
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql> 
        mysql> SELECT @@INNODB_BUFFER_POOL_SIZE;
        +---------------------------+
        | @@INNODB_BUFFER_POOL_SIZE |
        +---------------------------+
        |                1073741824 |
        +---------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> select 1073741824/1024/1024/1024;
        +---------------------------+
        | 1073741824/1024/1024/1024 |
        +---------------------------+
        |            1.000000000000 |
        +---------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> QUIT
        Bye
        [root@docker201.oldboyedu.com ~]# 
        


    温馨提示:
        (1)生产环境中可以适当调大，比如128GB内存的话我们可以设置为80GB左右，但其值建议不要超过操作系统总内存的75%以上。                
        (2)如下所示，我们可以通过"SHOW ENGINE INNODB STATUS\G"命令来查看InnoDB存储引擎状态，注意观察"BUFFER POOL AND MEMORY"下面的信息(可通过"Free buffers"大小来判断是否需要调大内存)，来设置合理的"INNODB_BUFFER_POOL_SIZE"大小;
            mysql> SHOW ENGINE INNODB STATUS\G
            *************************** 1. row ***************************
              Type: InnoDB
              Name: 
            Status: 
            =====================================
            2021-02-03 20:52:29 0x7f7ee0471700 INNODB MONITOR OUTPUT
            =====================================
            Per second averages calculated from the last 1 seconds
            -----------------
            BACKGROUND THREAD
            -----------------
            srv_master_thread loops: 47 srv_active, 0 srv_shutdown, 61277 srv_idle
            srv_master_thread log flush and writes: 61324
            ----------
            SEMAPHORES
            ----------
            OS WAIT ARRAY INFO: reservation count 7068
            OS WAIT ARRAY INFO: signal count 6542
            RW-shared spins 0, rounds 141, OS waits 68
            RW-excl spins 0, rounds 0, OS waits 0
            RW-sx spins 0, rounds 0, OS waits 0
            Spin rounds per wait: 141.00 RW-shared, 0.00 RW-excl, 0.00 RW-sx
            ------------
            TRANSACTIONS
            ------------
            Trx id counter 111693
            Purge done for trx's n:o < 111691 undo n:o < 0 state: running but idle
            History list length 0
            LIST OF TRANSACTIONS FOR EACH SESSION:
            ---TRANSACTION 111692, ACTIVE 6357 sec
            1 lock struct(s), heap size 1136, 1 row lock(s)
            MySQL thread id 22, OS thread handle 140182905632512, query id 207 localhost root
            Trx read view will not see trx with id >= 111691, sees < 111691
            ---TRANSACTION 111691, ACTIVE 6375 sec
            2 lock struct(s), heap size 1136, 1 row lock(s), undo log entries 1
            MySQL thread id 21, OS thread handle 140182905362176, query id 231 localhost root starting
            SHOW ENGINE INNODB STATUS
            Trx read view will not see trx with id >= 111691, sees < 111685
            --------
            FILE I/O
            --------
            I/O thread 0 state: waiting for completed aio requests (insert buffer thread)
            I/O thread 1 state: waiting for completed aio requests (log thread)
            I/O thread 2 state: waiting for completed aio requests (read thread)
            I/O thread 3 state: waiting for completed aio requests (read thread)
            I/O thread 4 state: waiting for completed aio requests (read thread)
            I/O thread 5 state: waiting for completed aio requests (read thread)
            I/O thread 6 state: waiting for completed aio requests (write thread)
            I/O thread 7 state: waiting for completed aio requests (write thread)
            I/O thread 8 state: waiting for completed aio requests (write thread)
            I/O thread 9 state: waiting for completed aio requests (write thread)
            Pending normal aio reads: [0, 0, 0, 0] , aio writes: [0, 0, 0, 0] ,
             ibuf aio reads:, log i/o's:, sync i/o's:
            Pending flushes (fsync) log: 0; buffer pool: 0
            415 OS file reads, 529 OS file writes, 324 OS fsyncs
            0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s
            -------------------------------------
            INSERT BUFFER AND ADAPTIVE HASH INDEX
            -------------------------------------
            Ibuf: size 1, free list len 0, seg size 2, 0 merges
            merged operations:
             insert 0, delete mark 0, delete 0
            discarded operations:
             insert 0, delete mark 0, delete 0
            Hash table size 34673, node heap has 0 buffer(s)
            Hash table size 34673, node heap has 0 buffer(s)
            Hash table size 34673, node heap has 0 buffer(s)
            Hash table size 34673, node heap has 0 buffer(s)
            Hash table size 34673, node heap has 1 buffer(s)
            Hash table size 34673, node heap has 0 buffer(s)
            Hash table size 34673, node heap has 0 buffer(s)
            Hash table size 34673, node heap has 0 buffer(s)
            0.00 hash searches/s, 0.00 non-hash searches/s
            ---
            LOG
            ---
            Log sequence number 61026088
            Log flushed up to   61026088
            Pages flushed up to 61026088
            Last checkpoint at  61026079
            0 pending log flushes, 0 pending chkp writes
            202 log i/o's done, 0.00 log i/o's/second
            ----------------------
            BUFFER POOL AND MEMORY
            ----------------------
            Total large memory allocated 137428992
            Dictionary memory allocated 165061
            Buffer pool size   8191
            Free buffers       7768
            Database pages     422
            Old database pages 0
            Modified db pages  0
            Pending reads      0
            Pending writes: LRU 0, flush list 0, single page 0
            Pages made young 0, not young 0
            0.00 youngs/s, 0.00 non-youngs/s
            Pages read 380, created 42, written 279
            0.00 reads/s, 0.00 creates/s, 0.00 writes/s
            No buffer pool page gets since the last printout
            Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
            LRU len: 422, unzip_LRU len: 0
            I/O sum[0]:cur[0], unzip sum[0]:cur[0]
            --------------
            ROW OPERATIONS
            --------------
            0 queries inside InnoDB, 0 queries in queue
            2 read views open inside InnoDB
            Process ID=901, Main thread ID=140182967809792, state: sleeping
            Number of rows inserted 20, updated 21, deleted 0, read 325
            0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
            ----------------------------
            END OF INNODB MONITOR OUTPUT
            ============================
            
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> 

    参考连接:
        https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_buffer_pool_size

```



# 六.隐式提交(COMMIT)事务控制语句

```
    在工作中我们要特别注意一下事务的隐式提交哟，在以下几种场景中经常会出现事务的隐式提交:
        (1)设置了autocommit=1:
            这种情况想必大家都很清楚了，基本上执行的每一条DML语句都会自动提交，除非您手动使用"BEGIN/START TRANSACTION"命令来开启一个新的事务。
        (2)在同一个会话中，执行DDL等非DML语句时，也会触发隐式提交:
            在同一个会话中，如果我们手动执行了"BEGIN/START TRANSACTION"命令会开启一个新的事务，理论上在执行DML语句时若没有执行"COMMIT"命令则并不会提交。但是在DML语句之后执行了DDL语句时，就会在DDL语句之前隐式加一个"COMMIT"命令哟。
        (3)在同一个会话中，执行DCL，Flush LOGS,CREATE USER,BEGIN等非DML语句时，也会触发隐式提交:
            这种情况下，很典型的案例就是当你指向了"BEGIN/START TRANSACTION"命令后，执行了一系列DML语句后并没有执行"COMMIT"命令进行提交，而是又一次执行了"BEGIN/START TRANSACTION"命令，这个时候也会隐式加一个"COMMIT"命令哟并开启一个新的事务！

    综上所述，我们总结了导致提交的非事务语句(DCL):
        DDL语句：
            CREATE，DROP等。
        DCL语句：
            GRANT，REVOKE，SET PASSWORD等。
        锁定语句：
            LOCK TABLES 和 UNLOCK TABLES。
        
    导致隐式提交的语句实例:
        (1)TRUNCATE TABLE
        (2)LOAD DATA INFILE
        (3)SELECT FOR UPDATE

```



# 七.隐式回滚(ROLLBACK)事务控制语句

```
    在理解了事务的隐式提交后，那么事务的隐式回滚，想必大家应该已经明白的八九不离十了。

    那么我就不多说废话了，通常在以下几种情况下会触发事务的隐式回滚:
        (1)会话关闭;
        (2)数据库宕机;
        (3)事务中的DML语句执行失败;
        
```





# 八.可能会遇到的报错

## 1.[ERROR] [MY-012595] [InnoDB] The error means mysqld does not have the access rights to the directory. ... Doublewrite file create failed: //#ib_16384_0.dblwr[ERROR] [MY-012595] [InnoDB] The error means mysqld does not have the access rights to the directory. ... Doublewrite file create failed: //#ib_16384_0.dblwr

```
问题原因:
	说是MySQL无法读取Doublewrite文件,请检查"innodb_doublewrite_dir"变量是否配置了正确的路径!
	
解决方案:
	我这里的解决方案就是先去检查一下my.cnf配置文件,发现"innodb_doublewrite_dir"配置的有问题,路径和变量值不在一行,存在换行的现象.
	综上所述,更正后问题解决!
```
