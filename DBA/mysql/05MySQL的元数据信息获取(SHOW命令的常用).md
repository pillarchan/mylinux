[TOC]



# 一.元数据概述

```
    在数据库中存储数据的基本逻辑单元是表，我们通常可以往表中插入数据，修改数据，删除数据和查询数据。那么问题来了，基于表存储数据，那么表本身的信息存储在哪里呢？

    一张表包含了数据字典，数据行记录，索引，数据库状态，权限，日志等信息。除了数据行记录和索引外，其他的都可以理解为和元数据相关的信息，我们可以直接在information_schema数据库中进行查询元数据信息。

    数据字典：
        含义:
            即表中定义的字段信息。
        存储路径:
            数据存储在安装数据库实例配置的数据目录(即"datadir")下。
            对于MyISAM存储引擎而言: 表在对应数据库目录下以"表名.frm"命名(如:"mysql数据库的user.frm")。
            对于MySQL 8.0版本以前，InnoDB存储引擎而言: 表在对应数据库目录下以"表名.frm"命名(如:"world数据库的city.frm")和idbdata1中存储。

    数据行记录:
        含义:
            存储的真实数据。
        存储路径:
            数据存储在安装数据库实例配置的数据目录(即"datadir")下。
            对于MyISAM存储引擎而言: 表在对应数据库目录下以"表名.MYD"命名(如:"mysql数据库的user.MYD")。
            对于MySQL 8.0版本以前，InnoDB存储引擎而言: 表在对应数据库目录下以"表名.ibd"命名(如:"world数据库的city.ibd")。

    索引:
        含义:
            暂时可以先理解为一本书的目录，用于加快查询的。
        存储路径:
            数据存储在安装数据库实例配置的数据目录(即"datadir")下。
            对于MyISAM存储引擎而言: 表在对应数据库目录下以"表名.MYI"命名(如:"mysql数据库的user.MYI")。
            对于MySQL 8.0版本以前，InnoDB存储引擎而言: 表在对应数据库目录下以"表名.ibd"命名(如:"world数据库的city.ibd")。

    数据库状态:
        含义:
            也叫元数据信息信息，它存储了当前数据库实例的一些状态信息，用于运行MySQL实例本身的配置信息。
        存储路径:
            存储元数据信息的库都是MySQL内置的数据库，如:"information_schema，mysql，performance_schema，sys"

    权限:
        含义:
            顾名思义，就是存储MySQL用户的权限相关的表信息。
        存储路径:
            对应存储权限的表基本上都在mysql数据库中，比如:"columns_priv","db","tables_priv","user"等等都是跟权限有关的表哟~

    日志:
        含义:
            顾名思义，就是存储MySQL日志信息。
        存储路径:
            对应的有专门的日志文件，比如有用于存储MySQL错误日志的文件，也有对应二进制日志的文件，后面在主从复制会提及这些内容。
```



# 二.通过information_schema"临时"数据库查询数据

## 1.information_schema概述

```
    当我们使用"SHOW DATABASES;"语句查看现有的数据库信息时，不难发现会有"information_schema"这样的一个数据库，但我们通过在"datadir"所指向的目录并未发现有"information_schema"这个数据库目录，这是为什么呢?

    每次数据库启动，会自动在内存中生成"information_schema"数据库，该数据库用于生成查询MySQL部分元数据信息视图。换句话说，"information_schema"压根就不落地，它一直在内存中存储，因此我们去磁盘上是看不到对应的数据库目录的。

    所谓的视图，就可以理解为SELECT语句的执行方法，不保存数据本身。"information_schema"中的视图，保存的就是查询元数据的方法，这些查询方法是由MySQL官方自带的，我们直接使用即可。

    
```



## 2.information_schema.tables常用字段信息概述

```
    在information_schema数据库的tables表中，保存了所有表字段信息，其表结构如下所示：
        mysql> DESC information_schema.tables;
        +-----------------+---------------------+------+-----+---------+-------+
        | Field           | Type                | Null | Key | Default | Extra |
        +-----------------+---------------------+------+-----+---------+-------+
        | TABLE_CATALOG   | varchar(512)        | NO   |     |         |       |
        | TABLE_SCHEMA    | varchar(64)         | NO   |     |         |       |
        | TABLE_NAME      | varchar(64)         | NO   |     |         |       |
        | TABLE_TYPE      | varchar(64)         | NO   |     |         |       |
        | ENGINE          | varchar(64)         | YES  |     | NULL    |       |
        | VERSION         | bigint(21) unsigned | YES  |     | NULL    |       |
        | ROW_FORMAT      | varchar(10)         | YES  |     | NULL    |       |
        | TABLE_ROWS      | bigint(21) unsigned | YES  |     | NULL    |       |
        | AVG_ROW_LENGTH  | bigint(21) unsigned | YES  |     | NULL    |       |
        | DATA_LENGTH     | bigint(21) unsigned | YES  |     | NULL    |       |
        | MAX_DATA_LENGTH | bigint(21) unsigned | YES  |     | NULL    |       |
        | INDEX_LENGTH    | bigint(21) unsigned | YES  |     | NULL    |       |
        | DATA_FREE       | bigint(21) unsigned | YES  |     | NULL    |       |
        | AUTO_INCREMENT  | bigint(21) unsigned | YES  |     | NULL    |       |
        | CREATE_TIME     | datetime            | YES  |     | NULL    |       |
        | UPDATE_TIME     | datetime            | YES  |     | NULL    |       |
        | CHECK_TIME      | datetime            | YES  |     | NULL    |       |
        | TABLE_COLLATION | varchar(32)         | YES  |     | NULL    |       |
        | CHECKSUM        | bigint(21) unsigned | YES  |     | NULL    |       |
        | CREATE_OPTIONS  | varchar(255)        | YES  |     | NULL    |       |
        | TABLE_COMMENT   | varchar(2048)       | NO   |     |         |       |
        +-----------------+---------------------+------+-----+---------+-------+
        21 rows in set (0.00 sec)
        
        mysql> 

    我们运维工作中常关注的有以下几个字段:
        TABLE_SCHEMA:
            存储表所在的库。
        TABLE_NAME:
            存储表的名称。
        ENGINE:
            存储表的引擎。
        TABLE_ROWS:
            存储表的行数。
        AVG_ROW_LENGTH:
            平均行长度。
        DATA_LENGTH:
            表所占用的存储空间大小。
        INDEX_LENGTH:
            表的索引占用空间大小。
        DATA_FREE:
            表中是否有碎片。

```



## 3.数据库资产统计-统计每个库，所有表的名称及个数

```
mysql> SELECT 
    ->     TABLE_SCHEMA,COUNT(TABLE_NAME),GROUP_CONCAT(TABLE_NAME)
    -> FROM
    ->     information_schema.tables
    -> GROUP BY
    ->     TABLE_SCHEMA\G
*************************** 1. row ***************************
            TABLE_SCHEMA: information_schema
       COUNT(TABLE_NAME): 61
GROUP_CONCAT(TABLE_NAME): INNODB_CMPMEM_RESET,INNODB_BUFFER_PAGE_LRU,COLUMN_PRIVILEGES,TABLE_PRIVILEGES,USER_PRIVILEGES,PROFILING,INNODB_FT_INDEX_CACHE,INNODB_CMP_PER_INDEX
,COLUMNS,TABLE_CONSTRAINTS,TRIGGERS,PARTITIONS,PROCESSLIST,INNODB_FT_INDEX_TABLE,COLLATION_CHARACTER_SET_APPLICABILITY,INNODB_CMP_RESET,TABLESPACES,PARAMETERS,PLUGINS,INNODB_FT_DEFAULT_STOPWORD,COLLATIONS,INNODB_FT_BEING_DELETED,TABLES,INNODB_BUFFER_PAGE,OPTIMIZER_TRACE,CHARACTER_SETS,INNODB_CMP,STATISTICS,INNODB_CMP_PER_INDEX_RESET,KEY_COLUMN_USAGE,INNODB_SYS_VIRTUAL,INNODB_SYS_TABLESTATS,SESSION_VARIABLES,INNODB_SYS_FIELDS,GLOBAL_VARIABLES,INNODB_FT_CONFIG,SESSION_STATUS,INNODB_SYS_FOREIGN,INNODB_SYS_TABLES,GLOBAL_STATUS,INNODB_SYS_DATAFILES,SCHEMA_PRIVILEGES,INNODB_SYS_COLUMNS,FILES,INNODB_SYS_INDEXES,INNODB_TRX,SCHEMATA,INNODB_SYS_FOREIGN_COLS,INNODB_BUFFER_POOL_STATS,EVENTS,INNODB_TEMP_TABLE_INFO,INNODB_LOCKS,INNODB_METRICS,INNODB_CMPMEM,ROUTINES,ENGINES,INNODB_FT_DELETED,INNODB_LOCK_WAITS,VIEWS,INNODB_SYS_TABLESPACES,REFERENTIAL_CONSTRAINTS*************************** 2. row ***************************
            TABLE_SCHEMA: mysql
       COUNT(TABLE_NAME): 31
GROUP_CONCAT(TABLE_NAME): proxies_priv,func,time_zone_transition_type,procs_priv,event,time_zone_transition,proc,engine_cost,time_zone_name,plugin,db,time_zone_leap_second,
ndb_binlog_index,columns_priv,time_zone,innodb_table_stats,slave_worker_info,tables_priv,innodb_index_stats,slave_relay_log_info,slow_log,help_keyword,help_topic,slave_master_info,help_category,help_relation,servers,gtid_executed,server_cost,general_log,user*************************** 3. row ***************************
            TABLE_SCHEMA: performance_schema
       COUNT(TABLE_NAME): 87
GROUP_CONCAT(TABLE_NAME): events_transactions_summary_by_host_by_event_name,replication_group_member_stats,rwlock_instances,users,events_statements_history,memory_summary_b
y_user_by_event_name,metadata_locks,socket_instances,events_waits_summary_global_by_event_name,events_transactions_summary_by_account_by_event_name,replication_connection_status,events_statements_current,memory_summary_by_thread_by_event_name,memory_summary_global_by_event_name,user_variables_by_thread,setup_timers,events_waits_summary_by_instance,events_waits_summary_by_user_by_event_name,replication_connection_configuration,events_transactions_history_long,events_stages_summary_global_by_event_name,memory_summary_by_host_by_event_name,threads,events_waits_summary_by_host_by_event_name,events_waits_summary_by_thread_by_event_name,setup_objects,events_statements_summary_global_by_event_name,events_transactions_history,replication_applier_status_by_worker,memory_summary_by_account_by_event_name,table_lock_waits_summary_by_table,events_stages_summary_by_user_by_event_*************************** 4. row ***************************
            TABLE_SCHEMA: school
       COUNT(TABLE_NAME): 6
GROUP_CONCAT(TABLE_NAME): teacher,staff_view,student_score,staff,student,course
*************************** 5. row ***************************
            TABLE_SCHEMA: sys
       COUNT(TABLE_NAME): 101
GROUP_CONCAT(TABLE_NAME): x$schema_table_statistics_with_buffer,user_summary_by_file_io_type,x$schema_table_lock_waits,host_summary_by_statement_type,x$memory_by_host_by_cu
rrent_bytes,schema_tables_with_full_table_scans,x$io_global_by_wait_by_latency,x$host_summary_by_file_io_type,x$user_summary_by_file_io,memory_by_user_by_current_bytes,user_summary_by_file_io,x$schema_index_statistics,host_summary_by_statement_latency,schema_table_statistics_with_buffer,x$io_global_by_wait_by_bytes,x$latest_file_io,x$host_summary_by_file_io,x$user_summary,memory_by_thread_by_current_bytes,waits_global_by_latency,user_summary,x$schema_flattened_keys,host_summary_by_stages,schema_table_statistics,x$io_global_by_file_by_latency,x$statements_with_temp_tables,memory_by_host_by_current_bytes,waits_by_user_by_latency,x$host_summary,sys_config,x$ps_schema_table_statistics_io,host_summary_by_file_io_type,statements_with_sorting,schema_table_lock_waits,x$io_global_by_file_by_bytes,x$statements_with_sorting,latest_file_io,waits_by_host_by_latency,x$ps_digest_a*************************** 6. row ***************************
            TABLE_SCHEMA: world
       COUNT(TABLE_NAME): 3
GROUP_CONCAT(TABLE_NAME): countrylanguage,country,city
*************************** 7. row ***************************
            TABLE_SCHEMA: oldboyedu
       COUNT(TABLE_NAME): 1
GROUP_CONCAT(TABLE_NAME): student
7 rows in set, 2 warnings (0.00 sec)

mysql> 

```



## 4.数据库资产统计-统计每个库的占用空间总大小

```
mysql> SELECT 
    ->     TABLE_SCHEMA,SUM(AVG_ROW_LENGTH * TABLE_ROWS + INDEX_LENGTH)/1024/1024
    -> FROM
    ->     information_schema.tables
    -> GROUP BY
    ->     TABLE_SCHEMA;
+--------------------+-----------------------------------------------------------+
| TABLE_SCHEMA       | SUM(AVG_ROW_LENGTH * TABLE_ROWS + INDEX_LENGTH)/1024/1024 |
+--------------------+-----------------------------------------------------------+
| information_schema |                                                      NULL |
| mysql              |                                                2.34711838 |
| performance_schema |                                                0.00000000 |
| school             |                                                0.09372616 |
| sys                |                                                0.01562119 |
| world              |                                                0.76367092 |
| oldboyedu        |                                                0.03124619 |
+--------------------+-----------------------------------------------------------+
7 rows in set (0.02 sec)

mysql> 
mysql> SELECT 
    ->     TABLE_SCHEMA,SUM(DATA_LENGTH)/1024/1024
    -> FROM
    ->     information_schema.tables
    -> GROUP BY
    ->     TABLE_SCHEMA;
+--------------------+----------------------------+
| TABLE_SCHEMA       | SUM(DATA_LENGTH)/1024/1024 |
+--------------------+----------------------------+
| information_schema |                 0.15625000 |
| mysql              |                 2.25995541 |
| performance_schema |                 0.00000000 |
| school             |                 0.07812500 |
| sys                |                 0.01562500 |
| world              |                 0.59375000 |
| oldboyedu        |                 0.01562500 |
+--------------------+----------------------------+
7 rows in set (0.02 sec)

mysql> 

```



## 5.数据库资产统计-查询非系统数据库中(即"information_schema","mysql","performance_schema","sys"这四个数据库被排除在外)，即业务数据库中所包含的非InnoDB的表

```
mysql> SELECT
    ->     TABLE_SCHEMA,TABLE_NAME
    -> FROM
    ->     information_schema.tables
    -> WHERE
    ->     ENGINE != 'InnoDB' 
    -> AND 
    ->     TABLE_SCHEMA NOT IN ("information_schema","mysql","performance_schema","sys");
Empty set (0.00 sec)

mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_oldboyedu |
+-----------------------+
| student               |
+-----------------------+
1 row in set (0.00 sec)

mysql> 
mysql> CREATE TABLE staff (
    ->     id int(11) PRIMARY KEY AUTO_INCREMENT COMMENT '员工编号',
    ->     name varchar(30) NOT NULL COMMENT '员工姓名',
    ->     birthday  DATETIME(0) COMMENT '出生日期',
    ->     gender enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
    ->     address varchar(255) NOT NULL COMMENT '家庭住址',
    ->     mobile_number bigint UNIQUE KEY NOT NULL COMMENT '手机号码',
    ->     salary int NOT NULL COMMENT '薪资待遇',
    ->     departing tinyint NOT NULL DEFAULT 0 COMMENT '离职信息,0代表全职,1代表兼职,2代表离职',
    ->     remarks VARCHAR(255) COMMENT '备注信息'
    -> ) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_oldboyedu |
+-----------------------+
| staff                 |
| student               |
+-----------------------+
2 rows in set (0.00 sec)

mysql> 
mysql> SELECT
    ->     TABLE_SCHEMA,TABLE_NAME
    -> FROM
    ->     information_schema.tables
    -> WHERE
    ->     ENGINE != 'InnoDB' 
    -> AND 
    ->     TABLE_SCHEMA NOT IN ("information_schema","mysql","performance_schema","sys");
+--------------+------------+
| TABLE_SCHEMA | TABLE_NAME |
+--------------+------------+
| oldboyedu  | staff      |
+--------------+------------+
1 row in set (0.00 sec)

mysql> 

```



## 6.查询业务数据库中所包含的非InnoDB的表转换为InnoDB

```
    现将非"InnoDB"存储引擎的数据库及表查询出来，而后再使用CONCAT内建函数来将查询结果进行拼接用于修改存储引擎的语句，因为我们想要将非InnoDB的存储引擎均改为InnoDB的存储引擎。
        mysql> SELECT
            ->     CONCAT("ALTER TABLE ", TABLE_SCHEMA, ".", TABLE_NAME, " ENGINE=InnoDB;")
            -> FROM
            ->     information_schema.tables
            -> WHERE
            ->     ENGINE != 'InnoDB' 
            -> AND 
            ->     TABLE_SCHEMA NOT IN ("information_schema","mysql","performance_schema","sys");
        +--------------------------------------------------------------------------+
        | CONCAT("ALTER TABLE ", TABLE_SCHEMA, ".", TABLE_NAME, " ENGINE=InnoDB;") |
        +--------------------------------------------------------------------------+
        | ALTER TABLE oldboyedu.staff ENGINE=InnoDB;                             |
        +--------------------------------------------------------------------------+
        1 row in set (0.00 sec)
        
        mysql> 

    接下来我们将上面的查询语句写入到本地的文件中，方便以后迁移调用该SQL脚本即可。
        mysql> SELECT
            ->     CONCAT("ALTER TABLE ", TABLE_SCHEMA, ".", TABLE_NAME, " ENGINE=InnoDB;")
            -> FROM
            ->     information_schema.tables
            -> WHERE
            ->     ENGINE != 'InnoDB' 
            -> AND 
            ->     TABLE_SCHEMA NOT IN ("information_schema","mysql","performance_schema","sys")
            -> INTO 
            ->     OUTFILE '/tmp/alter_engine.sql';
        Query OK, 1 row affected (0.00 sec)
        
        mysql> 
        mysql> SYSTEM cat /tmp/alter_engine.sql
        ALTER TABLE oldboyedu.staff ENGINE=InnoDB;
        mysql> 
        mysql> quit
        Bye
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# cat /tmp/alter_engine.sql 
        ALTER TABLE oldboyedu.staff ENGINE=InnoDB;
        [root@docker201.oldboyedu.com ~]# 

    接下来就是执行我们导出的SQL语句，当然我们也可以将导出的SQL脚步迁移到其他服务器上，如果有相同的需求，也可以执行该脚本！
        [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock -e "SHOW CREATE TABLE oldboyedu.staff\G"
        *************************** 1. row ***************************
               Table: staff
        Create Table: CREATE TABLE `staff` (
          `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '员工编号',
          `name` varchar(30) NOT NULL COMMENT '员工姓名',
          `birthday` datetime DEFAULT NULL COMMENT '出生日期',
          `gender` enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
          `address` varchar(255) NOT NULL COMMENT '家庭住址',
          `mobile_number` bigint(20) NOT NULL COMMENT '手机号码',
          `salary` int(11) NOT NULL COMMENT '薪资待遇',
          `departing` tinyint(4) NOT NULL DEFAULT '0' COMMENT '离职信息,0代表全职,1代表兼职,2代表离职',
          `remarks` varchar(255) DEFAULT NULL COMMENT '备注信息',
          PRIMARY KEY (`id`),
          UNIQUE KEY `mobile_number` (`mobile_number`)
        ) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# ll /tmp/alter_engine.sql 
        -rw-rw-rw- 1 mysql mysql 45 1月  18 23:35 /tmp/alter_engine.sql
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# cat /tmp/alter_engine.sql 
        ALTER TABLE oldboyedu.staff ENGINE=InnoDB;
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock < /tmp/alter_engine.sql 
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock -e "SHOW CREATE TABLE oldboyedu.staff\G"
        *************************** 1. row ***************************
               Table: staff
        Create Table: CREATE TABLE `staff` (
          `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '员工编号',
          `name` varchar(30) NOT NULL COMMENT '员工姓名',
          `birthday` datetime DEFAULT NULL COMMENT '出生日期',
          `gender` enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
          `address` varchar(255) NOT NULL COMMENT '家庭住址',
          `mobile_number` bigint(20) NOT NULL COMMENT '手机号码',
          `salary` int(11) NOT NULL COMMENT '薪资待遇',
          `departing` tinyint(4) NOT NULL DEFAULT '0' COMMENT '离职信息,0代表全职,1代表兼职,2代表离职',
          `remarks` varchar(255) DEFAULT NULL COMMENT '备注信息',
          PRIMARY KEY (`id`),
          UNIQUE KEY `mobile_number` (`mobile_number`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        [root@docker201.oldboyedu.com ~]# 

    温馨提示:
        如果出现了"ERROR 1290 (HY000): The MySQL server is running with the --secure-file-priv option so it cannot execute this statement"这样的报错提示，不要慌，我们需要修改一下配置文件重启数据库实例即可。
            [root@docker201.oldboyedu.com ~]# cat /oldboyedu/softwares/mysql23307/my.cnf 
            [mysqld]
            secure-file-priv=/tmp  # 添加该行内容即可后，记得重启数据库实例，否则配置无法立即生效！
            basedir=/oldboyedu/softwares/mysql/mysql
            datadir=/oldboyedu/data/mysql23307
            socket=/tmp/mysql23307.sock
            log_error=/oldboyedu/data/mysql23307/mysql-err.log
            port=23307
            server_id=7
            log_bin=/oldboyedu/data/mysql23307/mysql-bin
            [root@docker201.oldboyedu.com ~]# 
            [root@docker201.oldboyedu.com ~]# systemctl restart mysqld23307
            [root@docker201.oldboyedu.com ~]# 

        我们设置了"--secure-file-priv"目的是设置从SQL中导出查询数据到本地的文件路径，通常情况下，不设置该参数是不允许导出数据的哟，这也是为了安全起见，我们不能随便就将数据从本地导出啦~
        
```





# 三.通过SHOW命令获取元数据信息

```
    SHOW语句是MySQL独有的查询语句，当然，现在也有很多数据库借鉴了MySQL数据库的SQL语法，你会发现他们也是支持SHOW语句的哟~
    
    我们可以使用SHOW语句来查询数据库的状态，参数等元数据信息的查询。
```



## 1.查看数据库信息

```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| school             |
| sys                |
| world              |
| oldboyedu        |
+--------------------+
7 rows in set (0.00 sec)

mysql> 

```



## 2.查看当前数据库下的表信息

```
mysql> USE oldboyedu;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_oldboyedu |
+-----------------------+
| student               |
+-----------------------+
1 row in set (0.00 sec)

mysql> 

```



## 3.查看创建某个数据库时使用的SQL语句

```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| school             |
| sys                |
| world              |
| oldboyedu        |
+--------------------+
7 rows in set (0.00 sec)

mysql> 
mysql> SHOW CREATE DATABASE oldboyedu\G
*************************** 1. row ***************************
       Database: oldboyedu
Create Database: CREATE DATABASE `oldboyedu` /*!40100 DEFAULT CHARACTER SET utf8mb4 */
1 row in set (0.00 sec)

mysql> 

```



## 4.查看创建某个表时使用的SQL语句

```
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_oldboyedu |
+-----------------------+
| student               |
+-----------------------+
1 row in set (0.01 sec)

mysql> 
mysql> SHOW CREATE TABLE student\G
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
  `deleted` tinyint(4) NOT NULL DEFAULT '0' COMMENT '标记改行是否已经被删除，如果为1表示被标记已经删除，如果为0则表示未删除.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `mobile_number` (`mobile_number`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4
1 row in set (0.00 sec)

mysql> 

```



## 5.查看某个数据库下的所有表

```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| school             |
| sys                |
| world              |
| oldboyedu        |
+--------------------+
7 rows in set (0.00 sec)

mysql> 
mysql> SHOW TABLES FROM oldboyedu;
+-----------------------+
| Tables_in_oldboyedu |
+-----------------------+
| student               |
+-----------------------+
1 row in set (0.00 sec)

mysql> 

```



## 6.查询所有用户的连接情况

```
mysql> SHOW PROCESSLIST;  # 查看所有用户连接情况
+----+------+-----------+-------------+---------+------+----------+------------------+
| Id | User | Host      | db          | Command | Time | State    | Info             |
+----+------+-----------+-------------+---------+------+----------+------------------+
|  2 | root | localhost | oldboyedu | Query   |    0 | starting | SHOW PROCESSLIST |
+----+------+-----------+-------------+---------+------+----------+------------------+
1 row in set (0.00 sec)

mysql> 
mysql> SHOW FULL PROCESSLIST;  # 如果使用上面的"SHOW PROCESSLIST"语句查看连接情况时，发现Info显示的信息不全(通常是该用户执行的SQL可能过长)，则可以使用"SHOW FULL PROCESSLIST"来查看更加详细的信息。
+----+------+-----------+-------------+---------+------+----------+-----------------------+
| Id | User | Host      | db          | Command | Time | State    | Info                  |
+----+------+-----------+-------------+---------+------+----------+-----------------------+
|  2 | root | localhost | oldboyedu | Query   |    0 | starting | SHOW FULL PROCESSLIST |
+----+------+-----------+-------------+---------+------+----------+-----------------------+
1 row in set (0.00 sec)

mysql> 

```



## 7.查看字符集

```
mysql> SHOW CHARSET;
+----------+---------------------------------+---------------------+--------+
| Charset  | Description                     | Default collation   | Maxlen |
+----------+---------------------------------+---------------------+--------+
| big5     | Big5 Traditional Chinese        | big5_chinese_ci     |      2 |
| dec8     | DEC West European               | dec8_swedish_ci     |      1 |
| cp850    | DOS West European               | cp850_general_ci    |      1 |
| hp8      | HP West European                | hp8_english_ci      |      1 |
| koi8r    | KOI8-R Relcom Russian           | koi8r_general_ci    |      1 |
| latin1   | cp1252 West European            | latin1_swedish_ci   |      1 |
| latin2   | ISO 8859-2 Central European     | latin2_general_ci   |      1 |
| swe7     | 7bit Swedish                    | swe7_swedish_ci     |      1 |
| ascii    | US ASCII                        | ascii_general_ci    |      1 |
| ujis     | EUC-JP Japanese                 | ujis_japanese_ci    |      3 |
| sjis     | Shift-JIS Japanese              | sjis_japanese_ci    |      2 |
| hebrew   | ISO 8859-8 Hebrew               | hebrew_general_ci   |      1 |
| tis620   | TIS620 Thai                     | tis620_thai_ci      |      1 |
| euckr    | EUC-KR Korean                   | euckr_korean_ci     |      2 |
| koi8u    | KOI8-U Ukrainian                | koi8u_general_ci    |      1 |
| gb2312   | GB2312 Simplified Chinese       | gb2312_chinese_ci   |      2 |
| greek    | ISO 8859-7 Greek                | greek_general_ci    |      1 |
| cp1250   | Windows Central European        | cp1250_general_ci   |      1 |
| gbk      | GBK Simplified Chinese          | gbk_chinese_ci      |      2 |
| latin5   | ISO 8859-9 Turkish              | latin5_turkish_ci   |      1 |
| armscii8 | ARMSCII-8 Armenian              | armscii8_general_ci |      1 |
| utf8     | UTF-8 Unicode                   | utf8_general_ci     |      3 |
| ucs2     | UCS-2 Unicode                   | ucs2_general_ci     |      2 |
| cp866    | DOS Russian                     | cp866_general_ci    |      1 |
| keybcs2  | DOS Kamenicky Czech-Slovak      | keybcs2_general_ci  |      1 |
| macce    | Mac Central European            | macce_general_ci    |      1 |
| macroman | Mac West European               | macroman_general_ci |      1 |
| cp852    | DOS Central European            | cp852_general_ci    |      1 |
| latin7   | ISO 8859-13 Baltic              | latin7_general_ci   |      1 |
| utf8mb4  | UTF-8 Unicode                   | utf8mb4_general_ci  |      4 |
| cp1251   | Windows Cyrillic                | cp1251_general_ci   |      1 |
| utf16    | UTF-16 Unicode                  | utf16_general_ci    |      4 |
| utf16le  | UTF-16LE Unicode                | utf16le_general_ci  |      4 |
| cp1256   | Windows Arabic                  | cp1256_general_ci   |      1 |
| cp1257   | Windows Baltic                  | cp1257_general_ci   |      1 |
| utf32    | UTF-32 Unicode                  | utf32_general_ci    |      4 |
| binary   | Binary pseudo charset           | binary              |      1 |
| geostd8  | GEOSTD8 Georgian                | geostd8_general_ci  |      1 |
| cp932    | SJIS for Windows Japanese       | cp932_japanese_ci   |      2 |
| eucjpms  | UJIS for Windows Japanese       | eucjpms_japanese_ci |      3 |
| gb18030  | China National Standard GB18030 | gb18030_chinese_ci  |      4 |
+----------+---------------------------------+---------------------+--------+
41 rows in set (0.00 sec)

mysql> 

```



## 8.查看校对规则

```
mysql> SHOW COLLATION;
+--------------------------+----------+-----+---------+----------+---------+
| Collation                | Charset  | Id  | Default | Compiled | Sortlen |
+--------------------------+----------+-----+---------+----------+---------+
| big5_chinese_ci          | big5     |   1 | Yes     | Yes      |       1 |
| big5_bin                 | big5     |  84 |         | Yes      |       1 |
| dec8_swedish_ci          | dec8     |   3 | Yes     | Yes      |       1 |
| dec8_bin                 | dec8     |  69 |         | Yes      |       1 |
| cp850_general_ci         | cp850    |   4 | Yes     | Yes      |       1 |
| cp850_bin                | cp850    |  80 |         | Yes      |       1 |
| hp8_english_ci           | hp8      |   6 | Yes     | Yes      |       1 |
| hp8_bin                  | hp8      |  72 |         | Yes      |       1 |
| koi8r_general_ci         | koi8r    |   7 | Yes     | Yes      |       1 |
| koi8r_bin                | koi8r    |  74 |         | Yes      |       1 |
| latin1_german1_ci        | latin1   |   5 |         | Yes      |       1 |
| latin1_swedish_ci        | latin1   |   8 | Yes     | Yes      |       1 |
| latin1_danish_ci         | latin1   |  15 |         | Yes      |       1 |
| latin1_german2_ci        | latin1   |  31 |         | Yes      |       2 |
| latin1_bin               | latin1   |  47 |         | Yes      |       1 |
| latin1_general_ci        | latin1   |  48 |         | Yes      |       1 |
| latin1_general_cs        | latin1   |  49 |         | Yes      |       1 |
| latin1_spanish_ci        | latin1   |  94 |         | Yes      |       1 |
| latin2_czech_cs          | latin2   |   2 |         | Yes      |       4 |
| latin2_general_ci        | latin2   |   9 | Yes     | Yes      |       1 |
| latin2_hungarian_ci      | latin2   |  21 |         | Yes      |       1 |
| latin2_croatian_ci       | latin2   |  27 |         | Yes      |       1 |
| latin2_bin               | latin2   |  77 |         | Yes      |       1 |
| swe7_swedish_ci          | swe7     |  10 | Yes     | Yes      |       1 |
| swe7_bin                 | swe7     |  82 |         | Yes      |       1 |
| ascii_general_ci         | ascii    |  11 | Yes     | Yes      |       1 |
| ascii_bin                | ascii    |  65 |         | Yes      |       1 |
| ujis_japanese_ci         | ujis     |  12 | Yes     | Yes      |       1 |
| ujis_bin                 | ujis     |  91 |         | Yes      |       1 |
| sjis_japanese_ci         | sjis     |  13 | Yes     | Yes      |       1 |
| sjis_bin                 | sjis     |  88 |         | Yes      |       1 |
| hebrew_general_ci        | hebrew   |  16 | Yes     | Yes      |       1 |
| hebrew_bin               | hebrew   |  71 |         | Yes      |       1 |
| tis620_thai_ci           | tis620   |  18 | Yes     | Yes      |       4 |
| tis620_bin               | tis620   |  89 |         | Yes      |       1 |
| euckr_korean_ci          | euckr    |  19 | Yes     | Yes      |       1 |
| euckr_bin                | euckr    |  85 |         | Yes      |       1 |
| koi8u_general_ci         | koi8u    |  22 | Yes     | Yes      |       1 |
| koi8u_bin                | koi8u    |  75 |         | Yes      |       1 |
| gb2312_chinese_ci        | gb2312   |  24 | Yes     | Yes      |       1 |
| gb2312_bin               | gb2312   |  86 |         | Yes      |       1 |
| greek_general_ci         | greek    |  25 | Yes     | Yes      |       1 |
| greek_bin                | greek    |  70 |         | Yes      |       1 |
| cp1250_general_ci        | cp1250   |  26 | Yes     | Yes      |       1 |
| cp1250_czech_cs          | cp1250   |  34 |         | Yes      |       2 |
| cp1250_croatian_ci       | cp1250   |  44 |         | Yes      |       1 |
| cp1250_bin               | cp1250   |  66 |         | Yes      |       1 |
| cp1250_polish_ci         | cp1250   |  99 |         | Yes      |       1 |
| gbk_chinese_ci           | gbk      |  28 | Yes     | Yes      |       1 |
| gbk_bin                  | gbk      |  87 |         | Yes      |       1 |
| latin5_turkish_ci        | latin5   |  30 | Yes     | Yes      |       1 |
| latin5_bin               | latin5   |  78 |         | Yes      |       1 |
| armscii8_general_ci      | armscii8 |  32 | Yes     | Yes      |       1 |
| armscii8_bin             | armscii8 |  64 |         | Yes      |       1 |
| utf8_general_ci          | utf8     |  33 | Yes     | Yes      |       1 |
| utf8_bin                 | utf8     |  83 |         | Yes      |       1 |
| utf8_unicode_ci          | utf8     | 192 |         | Yes      |       8 |
| utf8_icelandic_ci        | utf8     | 193 |         | Yes      |       8 |
| utf8_latvian_ci          | utf8     | 194 |         | Yes      |       8 |
| utf8_romanian_ci         | utf8     | 195 |         | Yes      |       8 |
| utf8_slovenian_ci        | utf8     | 196 |         | Yes      |       8 |
| utf8_polish_ci           | utf8     | 197 |         | Yes      |       8 |
| utf8_estonian_ci         | utf8     | 198 |         | Yes      |       8 |
| utf8_spanish_ci          | utf8     | 199 |         | Yes      |       8 |
| utf8_swedish_ci          | utf8     | 200 |         | Yes      |       8 |
| utf8_turkish_ci          | utf8     | 201 |         | Yes      |       8 |
| utf8_czech_ci            | utf8     | 202 |         | Yes      |       8 |
| utf8_danish_ci           | utf8     | 203 |         | Yes      |       8 |
| utf8_lithuanian_ci       | utf8     | 204 |         | Yes      |       8 |
| utf8_slovak_ci           | utf8     | 205 |         | Yes      |       8 |
| utf8_spanish2_ci         | utf8     | 206 |         | Yes      |       8 |
| utf8_roman_ci            | utf8     | 207 |         | Yes      |       8 |
| utf8_persian_ci          | utf8     | 208 |         | Yes      |       8 |
| utf8_esperanto_ci        | utf8     | 209 |         | Yes      |       8 |
| utf8_hungarian_ci        | utf8     | 210 |         | Yes      |       8 |
| utf8_sinhala_ci          | utf8     | 211 |         | Yes      |       8 |
| utf8_german2_ci          | utf8     | 212 |         | Yes      |       8 |
| utf8_croatian_ci         | utf8     | 213 |         | Yes      |       8 |
| utf8_unicode_520_ci      | utf8     | 214 |         | Yes      |       8 |
| utf8_vietnamese_ci       | utf8     | 215 |         | Yes      |       8 |
| utf8_general_mysql500_ci | utf8     | 223 |         | Yes      |       1 |
| ucs2_general_ci          | ucs2     |  35 | Yes     | Yes      |       1 |
| ucs2_bin                 | ucs2     |  90 |         | Yes      |       1 |
| ucs2_unicode_ci          | ucs2     | 128 |         | Yes      |       8 |
| ucs2_icelandic_ci        | ucs2     | 129 |         | Yes      |       8 |
| ucs2_latvian_ci          | ucs2     | 130 |         | Yes      |       8 |
| ucs2_romanian_ci         | ucs2     | 131 |         | Yes      |       8 |
| ucs2_slovenian_ci        | ucs2     | 132 |         | Yes      |       8 |
| ucs2_polish_ci           | ucs2     | 133 |         | Yes      |       8 |
| ucs2_estonian_ci         | ucs2     | 134 |         | Yes      |       8 |
| ucs2_spanish_ci          | ucs2     | 135 |         | Yes      |       8 |
| ucs2_swedish_ci          | ucs2     | 136 |         | Yes      |       8 |
| ucs2_turkish_ci          | ucs2     | 137 |         | Yes      |       8 |
| ucs2_czech_ci            | ucs2     | 138 |         | Yes      |       8 |
| ucs2_danish_ci           | ucs2     | 139 |         | Yes      |       8 |
| ucs2_lithuanian_ci       | ucs2     | 140 |         | Yes      |       8 |
| ucs2_slovak_ci           | ucs2     | 141 |         | Yes      |       8 |
| ucs2_spanish2_ci         | ucs2     | 142 |         | Yes      |       8 |
| ucs2_roman_ci            | ucs2     | 143 |         | Yes      |       8 |
| ucs2_persian_ci          | ucs2     | 144 |         | Yes      |       8 |
| ucs2_esperanto_ci        | ucs2     | 145 |         | Yes      |       8 |
| ucs2_hungarian_ci        | ucs2     | 146 |         | Yes      |       8 |
| ucs2_sinhala_ci          | ucs2     | 147 |         | Yes      |       8 |
| ucs2_german2_ci          | ucs2     | 148 |         | Yes      |       8 |
| ucs2_croatian_ci         | ucs2     | 149 |         | Yes      |       8 |
| ucs2_unicode_520_ci      | ucs2     | 150 |         | Yes      |       8 |
| ucs2_vietnamese_ci       | ucs2     | 151 |         | Yes      |       8 |
| ucs2_general_mysql500_ci | ucs2     | 159 |         | Yes      |       1 |
| cp866_general_ci         | cp866    |  36 | Yes     | Yes      |       1 |
| cp866_bin                | cp866    |  68 |         | Yes      |       1 |
| keybcs2_general_ci       | keybcs2  |  37 | Yes     | Yes      |       1 |
| keybcs2_bin              | keybcs2  |  73 |         | Yes      |       1 |
| macce_general_ci         | macce    |  38 | Yes     | Yes      |       1 |
| macce_bin                | macce    |  43 |         | Yes      |       1 |
| macroman_general_ci      | macroman |  39 | Yes     | Yes      |       1 |
| macroman_bin             | macroman |  53 |         | Yes      |       1 |
| cp852_general_ci         | cp852    |  40 | Yes     | Yes      |       1 |
| cp852_bin                | cp852    |  81 |         | Yes      |       1 |
| latin7_estonian_cs       | latin7   |  20 |         | Yes      |       1 |
| latin7_general_ci        | latin7   |  41 | Yes     | Yes      |       1 |
| latin7_general_cs        | latin7   |  42 |         | Yes      |       1 |
| latin7_bin               | latin7   |  79 |         | Yes      |       1 |
| utf8mb4_general_ci       | utf8mb4  |  45 | Yes     | Yes      |       1 |
| utf8mb4_bin              | utf8mb4  |  46 |         | Yes      |       1 |
| utf8mb4_unicode_ci       | utf8mb4  | 224 |         | Yes      |       8 |
| utf8mb4_icelandic_ci     | utf8mb4  | 225 |         | Yes      |       8 |
| utf8mb4_latvian_ci       | utf8mb4  | 226 |         | Yes      |       8 |
| utf8mb4_romanian_ci      | utf8mb4  | 227 |         | Yes      |       8 |
| utf8mb4_slovenian_ci     | utf8mb4  | 228 |         | Yes      |       8 |
| utf8mb4_polish_ci        | utf8mb4  | 229 |         | Yes      |       8 |
| utf8mb4_estonian_ci      | utf8mb4  | 230 |         | Yes      |       8 |
| utf8mb4_spanish_ci       | utf8mb4  | 231 |         | Yes      |       8 |
| utf8mb4_swedish_ci       | utf8mb4  | 232 |         | Yes      |       8 |
| utf8mb4_turkish_ci       | utf8mb4  | 233 |         | Yes      |       8 |
| utf8mb4_czech_ci         | utf8mb4  | 234 |         | Yes      |       8 |
| utf8mb4_danish_ci        | utf8mb4  | 235 |         | Yes      |       8 |
| utf8mb4_lithuanian_ci    | utf8mb4  | 236 |         | Yes      |       8 |
| utf8mb4_slovak_ci        | utf8mb4  | 237 |         | Yes      |       8 |
| utf8mb4_spanish2_ci      | utf8mb4  | 238 |         | Yes      |       8 |
| utf8mb4_roman_ci         | utf8mb4  | 239 |         | Yes      |       8 |
| utf8mb4_persian_ci       | utf8mb4  | 240 |         | Yes      |       8 |
| utf8mb4_esperanto_ci     | utf8mb4  | 241 |         | Yes      |       8 |
| utf8mb4_hungarian_ci     | utf8mb4  | 242 |         | Yes      |       8 |
| utf8mb4_sinhala_ci       | utf8mb4  | 243 |         | Yes      |       8 |
| utf8mb4_german2_ci       | utf8mb4  | 244 |         | Yes      |       8 |
| utf8mb4_croatian_ci      | utf8mb4  | 245 |         | Yes      |       8 |
| utf8mb4_unicode_520_ci   | utf8mb4  | 246 |         | Yes      |       8 |
| utf8mb4_vietnamese_ci    | utf8mb4  | 247 |         | Yes      |       8 |
| cp1251_bulgarian_ci      | cp1251   |  14 |         | Yes      |       1 |
| cp1251_ukrainian_ci      | cp1251   |  23 |         | Yes      |       1 |
| cp1251_bin               | cp1251   |  50 |         | Yes      |       1 |
| cp1251_general_ci        | cp1251   |  51 | Yes     | Yes      |       1 |
| cp1251_general_cs        | cp1251   |  52 |         | Yes      |       1 |
| utf16_general_ci         | utf16    |  54 | Yes     | Yes      |       1 |
| utf16_bin                | utf16    |  55 |         | Yes      |       1 |
| utf16_unicode_ci         | utf16    | 101 |         | Yes      |       8 |
| utf16_icelandic_ci       | utf16    | 102 |         | Yes      |       8 |
| utf16_latvian_ci         | utf16    | 103 |         | Yes      |       8 |
| utf16_romanian_ci        | utf16    | 104 |         | Yes      |       8 |
| utf16_slovenian_ci       | utf16    | 105 |         | Yes      |       8 |
| utf16_polish_ci          | utf16    | 106 |         | Yes      |       8 |
| utf16_estonian_ci        | utf16    | 107 |         | Yes      |       8 |
| utf16_spanish_ci         | utf16    | 108 |         | Yes      |       8 |
| utf16_swedish_ci         | utf16    | 109 |         | Yes      |       8 |
| utf16_turkish_ci         | utf16    | 110 |         | Yes      |       8 |
| utf16_czech_ci           | utf16    | 111 |         | Yes      |       8 |
| utf16_danish_ci          | utf16    | 112 |         | Yes      |       8 |
| utf16_lithuanian_ci      | utf16    | 113 |         | Yes      |       8 |
| utf16_slovak_ci          | utf16    | 114 |         | Yes      |       8 |
| utf16_spanish2_ci        | utf16    | 115 |         | Yes      |       8 |
| utf16_roman_ci           | utf16    | 116 |         | Yes      |       8 |
| utf16_persian_ci         | utf16    | 117 |         | Yes      |       8 |
| utf16_esperanto_ci       | utf16    | 118 |         | Yes      |       8 |
| utf16_hungarian_ci       | utf16    | 119 |         | Yes      |       8 |
| utf16_sinhala_ci         | utf16    | 120 |         | Yes      |       8 |
| utf16_german2_ci         | utf16    | 121 |         | Yes      |       8 |
| utf16_croatian_ci        | utf16    | 122 |         | Yes      |       8 |
| utf16_unicode_520_ci     | utf16    | 123 |         | Yes      |       8 |
| utf16_vietnamese_ci      | utf16    | 124 |         | Yes      |       8 |
| utf16le_general_ci       | utf16le  |  56 | Yes     | Yes      |       1 |
| utf16le_bin              | utf16le  |  62 |         | Yes      |       1 |
| cp1256_general_ci        | cp1256   |  57 | Yes     | Yes      |       1 |
| cp1256_bin               | cp1256   |  67 |         | Yes      |       1 |
| cp1257_lithuanian_ci     | cp1257   |  29 |         | Yes      |       1 |
| cp1257_bin               | cp1257   |  58 |         | Yes      |       1 |
| cp1257_general_ci        | cp1257   |  59 | Yes     | Yes      |       1 |
| utf32_general_ci         | utf32    |  60 | Yes     | Yes      |       1 |
| utf32_bin                | utf32    |  61 |         | Yes      |       1 |
| utf32_unicode_ci         | utf32    | 160 |         | Yes      |       8 |
| utf32_icelandic_ci       | utf32    | 161 |         | Yes      |       8 |
| utf32_latvian_ci         | utf32    | 162 |         | Yes      |       8 |
| utf32_romanian_ci        | utf32    | 163 |         | Yes      |       8 |
| utf32_slovenian_ci       | utf32    | 164 |         | Yes      |       8 |
| utf32_polish_ci          | utf32    | 165 |         | Yes      |       8 |
| utf32_estonian_ci        | utf32    | 166 |         | Yes      |       8 |
| utf32_spanish_ci         | utf32    | 167 |         | Yes      |       8 |
| utf32_swedish_ci         | utf32    | 168 |         | Yes      |       8 |
| utf32_turkish_ci         | utf32    | 169 |         | Yes      |       8 |
| utf32_czech_ci           | utf32    | 170 |         | Yes      |       8 |
| utf32_danish_ci          | utf32    | 171 |         | Yes      |       8 |
| utf32_lithuanian_ci      | utf32    | 172 |         | Yes      |       8 |
| utf32_slovak_ci          | utf32    | 173 |         | Yes      |       8 |
| utf32_spanish2_ci        | utf32    | 174 |         | Yes      |       8 |
| utf32_roman_ci           | utf32    | 175 |         | Yes      |       8 |
| utf32_persian_ci         | utf32    | 176 |         | Yes      |       8 |
| utf32_esperanto_ci       | utf32    | 177 |         | Yes      |       8 |
| utf32_hungarian_ci       | utf32    | 178 |         | Yes      |       8 |
| utf32_sinhala_ci         | utf32    | 179 |         | Yes      |       8 |
| utf32_german2_ci         | utf32    | 180 |         | Yes      |       8 |
| utf32_croatian_ci        | utf32    | 181 |         | Yes      |       8 |
| utf32_unicode_520_ci     | utf32    | 182 |         | Yes      |       8 |
| utf32_vietnamese_ci      | utf32    | 183 |         | Yes      |       8 |
| binary                   | binary   |  63 | Yes     | Yes      |       1 |
| geostd8_general_ci       | geostd8  |  92 | Yes     | Yes      |       1 |
| geostd8_bin              | geostd8  |  93 |         | Yes      |       1 |
| cp932_japanese_ci        | cp932    |  95 | Yes     | Yes      |       1 |
| cp932_bin                | cp932    |  96 |         | Yes      |       1 |
| eucjpms_japanese_ci      | eucjpms  |  97 | Yes     | Yes      |       1 |
| eucjpms_bin              | eucjpms  |  98 |         | Yes      |       1 |
| gb18030_chinese_ci       | gb18030  | 248 | Yes     | Yes      |       2 |
| gb18030_bin              | gb18030  | 249 |         | Yes      |       1 |
| gb18030_unicode_520_ci   | gb18030  | 250 |         | Yes      |       8 |
+--------------------------+----------+-----+---------+----------+---------+
222 rows in set (0.00 sec)

mysql> 

```



## 9.查看MySQL支持的存储引擎

```
mysql> SHOW ENGINES;
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

```



## 10.查看MySQL支持的权限信息

```
mysql> SHOW PRIVILEGES;
+-------------------------+---------------------------------------+-------------------------------------------------------+
| Privilege               | Context                               | Comment                                               |
+-------------------------+---------------------------------------+-------------------------------------------------------+
| Alter                   | Tables                                | To alter the table                                    |
| Alter routine           | Functions,Procedures                  | To alter or drop stored functions/procedures          |
| Create                  | Databases,Tables,Indexes              | To create new databases and tables                    |
| Create routine          | Databases                             | To use CREATE FUNCTION/PROCEDURE                      |
| Create temporary tables | Databases                             | To use CREATE TEMPORARY TABLE                         |
| Create view             | Tables                                | To create new views                                   |
| Create user             | Server Admin                          | To create new users                                   |
| Delete                  | Tables                                | To delete existing rows                               |
| Drop                    | Databases,Tables                      | To drop databases, tables, and views                  |
| Event                   | Server Admin                          | To create, alter, drop and execute events             |
| Execute                 | Functions,Procedures                  | To execute stored routines                            |
| File                    | File access on server                 | To read and write files on the server                 |
| Grant option            | Databases,Tables,Functions,Procedures | To give to other users those privileges you possess   |
| Index                   | Tables                                | To create or drop indexes                             |
| Insert                  | Tables                                | To insert data into tables                            |
| Lock tables             | Databases                             | To use LOCK TABLES (together with SELECT privilege)   |
| Process                 | Server Admin                          | To view the plain text of currently executing queries |
| Proxy                   | Server Admin                          | To make proxy user possible                           |
| References              | Databases,Tables                      | To have references on tables                          |
| Reload                  | Server Admin                          | To reload or refresh tables, logs and privileges      |
| Replication client      | Server Admin                          | To ask where the slave or master servers are          |
| Replication slave       | Server Admin                          | To read binary log events from the master             |
| Select                  | Tables                                | To retrieve rows from table                           |
| Show databases          | Server Admin                          | To see all databases with SHOW DATABASES              |
| Show view               | Tables                                | To see views with SHOW CREATE VIEW                    |
| Shutdown                | Server Admin                          | To shut down the server                               |
| Super                   | Server Admin                          | To use KILL thread, SET GLOBAL, CHANGE MASTER, etc.   |
| Trigger                 | Tables                                | To use triggers                                       |
| Create tablespace       | Server Admin                          | To create/alter/drop tablespaces                      |
| Update                  | Tables                                | To update existing rows                               |
| Usage                   | Server Admin                          | No privileges - allow connect only                    |
+-------------------------+---------------------------------------+-------------------------------------------------------+
31 rows in set (0.00 sec)

mysql> 

```



## 11.查看某个用户的权限信息

```
mysql> SELECT user,host FROM mysql.user;
+---------------+-----------+
| user          | host      |
+---------------+-----------+
| mysql.session | localhost |
| mysql.sys     | localhost |
| root          | localhost |
+---------------+-----------+
3 rows in set (0.00 sec)

mysql> 
mysql> SHOW GRANTS FOR 'root'@'localhost';
+---------------------------------------------------------------------+
| Grants for root@localhost                                           |
+---------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION |
| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION        |
+---------------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> 

```



## 12.查看MySQL实例的变量信息

```
mysql> SHOW VARIABLES;
......(太多变量了，我直接省略了)

| wait_timeout                                             | 28800                                                                                              
| warning_count                                            | 0         
517 rows in set (0.00 sec)

mysql> 
mysql> SHOW VARIABLES LIKE '%trx%';  # 如果你还记得变量中包含哪些字母可以使用这种方式进行模糊查询;
+--------------------------------+-------+
| Variable_name                  | Value |
+--------------------------------+-------+
| innodb_api_trx_level           | 0     |
| innodb_flush_log_at_trx_commit | 1     |
+--------------------------------+-------+
2 rows in set (0.00 sec)

mysql> 

```



## 13.查看某张表的索引信息

```
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_oldboyedu |
+-----------------------+
| student               |
+-----------------------+
1 row in set (0.00 sec)

mysql> 
mysql> SHOW INDEX FROM student;
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| student |          0 | PRIMARY       |            1 | id            | A         |           7 |     NULL | NULL   |      | BTREE      |         |               |
| student |          0 | mobile_number |            1 | mobile_number | A         |           7 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)

mysql>

```



## 14.查询INNODB引擎状态

```
mysql> SHOW ENGINE INNODB STATUS\G
*************************** 1. row ***************************
  Type: InnoDB
  Name: 
Status: 
=====================================
2021-01-18 10:08:43 0x7f2780187700 INNODB MONITOR OUTPUT
=====================================
Per second averages calculated from the last 18 seconds
-----------------
BACKGROUND THREAD
-----------------
srv_master_thread loops: 6 srv_active, 0 srv_shutdown, 43298 srv_idle
srv_master_thread log flush and writes: 43304
----------
SEMAPHORES
----------
OS WAIT ARRAY INFO: reservation count 14
OS WAIT ARRAY INFO: signal count 14
RW-shared spins 0, rounds 5, OS waits 2
RW-excl spins 0, rounds 0, OS waits 0
RW-sx spins 0, rounds 0, OS waits 0
Spin rounds per wait: 5.00 RW-shared, 0.00 RW-excl, 0.00 RW-sx
------------
TRANSACTIONS
------------
Trx id counter 3335
Purge done for trx's n:o < 0 undo n:o < 0 state: running but idle
History list length 0
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 421282879260496, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
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
466 OS file reads, 65 OS file writes, 7 OS fsyncs
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
Hash table size 34673, node heap has 2 buffer(s)
Hash table size 34673, node heap has 3 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
Hash table size 34673, node heap has 0 buffer(s)
0.00 hash searches/s, 0.00 non-hash searches/s
---
LOG
---
Log sequence number 4153700
Log flushed up to   4153700
Pages flushed up to 4153700
Last checkpoint at  4153691
0 pending log flushes, 0 pending chkp writes
10 log i/o's done, 0.00 log i/o's/second
----------------------
BUFFER POOL AND MEMORY
----------------------
Total large memory allocated 137428992
Dictionary memory allocated 165056
Buffer pool size   8191
Free buffers       7725
Database pages     461
Old database pages 0
Modified db pages  0
Pending reads      0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 0, not young 0
0.00 youngs/s, 0.00 non-youngs/s
Pages read 426, created 35, written 48
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
No buffer pool page gets since the last printout
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 461, unzip_LRU len: 0
I/O sum[0]:cur[0], unzip sum[0]:cur[0]
--------------
ROW OPERATIONS
--------------
0 queries inside InnoDB, 0 queries in queue
0 read views open inside InnoDB
Process ID=942, Main thread ID=139807525136128, state: sleeping
Number of rows inserted 20, updated 0, deleted 0, read 22778
0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
----------------------------
END OF INNODB MONITOR OUTPUT
============================

1 row in set (0.00 sec)

mysql> 

```



## 15.查看数据库状态信息

```
mysql> SHOW STATUS\G
...(信息较多，我此处就直接省略了)

*************************** 355. row ***************************
Variable_name: Threads_running
        Value: 1
*************************** 356. row ***************************
Variable_name: Uptime
        Value: 43467
*************************** 357. row ***************************
Variable_name: Uptime_since_flush_status
        Value: 43467
357 rows in set (0.00 sec)

mysql> 
mysql> SHOW STATUS LIKE '%Threads%';  # 注意哈，我们也可以使用模糊查询来查看某个变量哟~
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| Delayed_insert_threads | 0     |
| Slow_launch_threads    | 0     |
| Threads_cached         | 0     |
| Threads_connected      | 1     |
| Threads_created        | 1     |
| Threads_running        | 1     |
+------------------------+-------+
6 rows in set (0.00 sec)

mysql> 

```



## 16.查看所有数据库参数

```
*************************** 515. row ***************************
Variable_name: version_compile_os
        Value: linux-glibc2.12
*************************** 516. row ***************************
Variable_name: wait_timeout
        Value: 28800
*************************** 517. row ***************************
Variable_name: warning_count
        Value: 0
517 rows in set (0.00 sec)

mysql> 
mysql> SHOW VARIABLES LIKE '%warning%';  # 我们可以使用模糊查询来过滤某个某些字段信息，这种情况下多用于我们忘记了某个参数的全称，只记得部分单词的时候使用。
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| log_warnings  | 2     |
| sql_warnings  | OFF   |
| warning_count | 0     |
+---------------+-------+
3 rows in set (0.00 sec)

mysql> 

```



## 17.查看所有二进制日志文件

```
mysql> SHOW BINARY LOGS;
+------------------+-----------+
| Log_name         | File_size |
+------------------+-----------+
| mysql-bin.000001 |       177 |
| mysql-bin.000002 |    728334 |
| mysql-bin.000003 |      5587 |
| mysql-bin.000004 |       154 |
+------------------+-----------+
4 rows in set (0.00 sec)

mysql> 

```



## 18.查看二进制日志事件

```
mysql> SHOW BINLOG EVENTS;
+------------------+-----+----------------+-----------+-------------+---------------------------------------+
| Log_name         | Pos | Event_type     | Server_id | End_log_pos | Info                                  |
+------------------+-----+----------------+-----------+-------------+---------------------------------------+
| mysql-bin.000001 |   4 | Format_desc    |         7 |         123 | Server ver: 5.7.31-log, Binlog ver: 4 |
| mysql-bin.000001 | 123 | Previous_gtids |         7 |         154 |                                       |
| mysql-bin.000001 | 154 | Stop           |         7 |         177 |                                       |
+------------------+-----+----------------+-----------+-------------+---------------------------------------+
3 rows in set (0.00 sec)

mysql> 

```



## 19.查询主库二进制的位置点信息

```
mysql> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000004 |      154 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

mysql> 

```



## 20.查看从库状态信息(需要配置MySQL主从复制才能看到哟~否则查看为空)

```
mysql> SHOW SLAVE STATUS;
Empty set (0.00 sec)

mysql> 

```



## 21.查看中继日志事件

```
mysql> SHOW RELAYLOG EVENTS;
Empty set (0.00 sec)

mysql> 

```



## 22.查看SHOW命令的帮助信息

```
mysql> HELP SHOW  # 使用HELP关键字可以查看SHOW语句的帮助信息，但通常情况下我更习惯使用"?"来查看某个命令的帮助信息哟~
mysql> 
mysql> ? SHOW  # 如果你懒得打字，就可以使用"?"来对某个命令进行查询操作哟！
Name: 'SHOW'
Description:
SHOW has many forms that provide information about databases, tables,
columns, or status information about the server. This section describes
those following:

SHOW {BINARY | MASTER} LOGS
SHOW BINLOG EVENTS [IN 'log_name'] [FROM pos] [LIMIT [offset,] row_count]
SHOW CHARACTER SET [like_or_where]
SHOW COLLATION [like_or_where]
SHOW [FULL] COLUMNS FROM tbl_name [FROM db_name] [like_or_where]
SHOW CREATE DATABASE db_name
SHOW CREATE EVENT event_name
SHOW CREATE FUNCTION func_name
SHOW CREATE PROCEDURE proc_name
SHOW CREATE TABLE tbl_name
SHOW CREATE TRIGGER trigger_name
SHOW CREATE VIEW view_name
SHOW DATABASES [like_or_where]
SHOW ENGINE engine_name {STATUS | MUTEX}
SHOW [STORAGE] ENGINES
SHOW ERRORS [LIMIT [offset,] row_count]
SHOW EVENTS
SHOW FUNCTION CODE func_name
SHOW FUNCTION STATUS [like_or_where]
SHOW GRANTS FOR user
SHOW INDEX FROM tbl_name [FROM db_name]
SHOW MASTER STATUS
SHOW OPEN TABLES [FROM db_name] [like_or_where]
SHOW PLUGINS
SHOW PROCEDURE CODE proc_name
SHOW PROCEDURE STATUS [like_or_where]
SHOW PRIVILEGES
SHOW [FULL] PROCESSLIST
SHOW PROFILE [types] [FOR QUERY n] [OFFSET n] [LIMIT n]
SHOW PROFILES
SHOW RELAYLOG EVENTS [IN 'log_name'] [FROM pos] [LIMIT [offset,] row_count]
SHOW SLAVE HOSTS
SHOW SLAVE STATUS [FOR CHANNEL channel]
SHOW [GLOBAL | SESSION] STATUS [like_or_where]
SHOW TABLE STATUS [FROM db_name] [like_or_where]
SHOW [FULL] TABLES [FROM db_name] [like_or_where]
SHOW TRIGGERS [FROM db_name] [like_or_where]
SHOW [GLOBAL | SESSION] VARIABLES [like_or_where]
SHOW WARNINGS [LIMIT [offset,] row_count]

like_or_where: {
    LIKE 'pattern'
  | WHERE expr
}

If the syntax for a given SHOW statement includes a LIKE 'pattern'
part, 'pattern' is a string that can contain the SQL % and _ wildcard
characters. The pattern is useful for restricting statement output to
matching values.

Several SHOW statements also accept a WHERE clause that provides more
flexibility in specifying which rows to display. See
https://dev.mysql.com/doc/refman/5.7/en/extended-show.html.

URL: https://dev.mysql.com/doc/refman/5.7/en/show.html


mysql> 

```





# 四.可能会遇到的错误

## 1.ERROR 1290 (HY000): The MySQL server is running with the --secure-file-priv option so it cannot execute this statement

```
问题原因:
	未指定"secure_file_priv"这个变量导致,改变了默认值为"NULL".

解决方案:
	在"[mysqld]"标签下配置"secure_file_priv"变量(比如"secure_file_priv=/tmp)即可,并重启服务。
	
	
温馨提示:
	如果自定义了MySQL的配置文件,可以使用"mysqld_safe --defaults-file=~/.my.cnf"方式启动.
```

![1631187037040](07-老男孩教育-MySQL的元数据信息获取(含SHOW命令的常用案例).assets/1631187037040.png)