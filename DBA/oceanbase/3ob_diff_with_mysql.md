# 03、与 MySQL 兼容性对比

OceanBase 数据库的 MySQL 模式兼容 MySQL 5.7/8.0 的绝大部分功能和语法。由于产品架构不同，或者客户需求不大，有些功能并没有被支持。本节主要从以下几方面介绍 OceanBase 数据库的 MySQL 模式与原生 MySQL 数据库的不同：

 数据类型

 SQL 语法

 过程性语言

 系统视图

 字符集和字符序

 函数与表达式

 分区支持

 备份恢复

 存储引擎

 优化器

 暂不支持的功能

## 数据类型

OceanBase 数据库支持的数据类型有：

###  数值类型

 整数类型： BOOL / BOOLEAN / TINYINT 、 SMALLINT 、 MEDIUMINT 、INT / INTEGER 和 BIGINT 。

 定点类型： DECIMAL 和 NUMERIC 。

 浮点类型： FLOAT 和 DOUBLE 。

 Bit-Value 类型： BIT 。

 日期时间类型： DATETIME 、 TIMESTAMP 、 DATE 、 TIME  和 YEAR 。

 字符类型： CHAR 、 VARCHAR 、 BINARY  和 VARBINARY 。

 大对象类型： TINYBLOB 、 BLOB 、 MEDIUMBLOB  和 LONGBLOB 。

文本类型： TINYTEXT 、 TEXT 、 MEDIUMTEXT  和 LONGTEXT 。

 枚举类型： ENUM 。

 集合类型： SET 。

 JSON 数据类型

 空间数据类型

### SQL 语法

#### SELECT

 支持大部分查询功能，包括支持单、多表查询；支持子查询；支持内联接、半联接以及外联接；支持分组、聚合；常见的概率、线性回归等数据挖掘函数等。

 支持对多个 SELECT  查询的结果进行 UNION 、 UNION ALL 、 MINUS 、EXCEPT  或 INTERSECT  等集合操作。

支持通过如下方式查看执行计划：

#### EXPLAIN [explain_type] dml_statement;

explain_type：

 BASIC 

 | OUTLINE

 | EXTENDED

 | EXTENDED_NOADDR

 | PARTITIONS 

 | FORMAT = {TRADITIONAL| JSON}

dml_statement:

 SELECT statement 

 | DELETE statement

 | INSERT statement

 | REPLACE statement

 | UPDATE statement

 不支持 SELECT ... FOR SHARE ...  语法。

#### INSERT

 支持单行和多行插入，以及指定分区插入。

 支持 INSERT INTO ... SELECT ...  语句。

#### UPDATE

 支持单列和多列更新。

 支持使用子查询。

支持集合更新。

#### DELETE

 支持单表和多表删除。

#### TRUNCATE

 支持完全清空指定表。

 不支持在进行事务处理和表锁定的过程中操作。

## 过程性语言

OceanBase 数据库兼容了大部分 MySQL 数据库的 PL 功能，主要支持的 PL 功能如下：

###  数据类型

###  存储过程

###  自定义函数

###  触发器

###  异常处理

此外，OceanBase 数据库特有的 MySQL PL 系统包，包括 DBMS_RESOURCE_MANAGER 、DBMS_STATS 、 DBMS_UDR  和 DBMS_XPLAN  等。

更多 PL 功能的详细信息请参见 PL 参考

## 系统视图

OceanBase 数据库实现了 information_schema 和 mysql 这两个内部数据库中的大部分视图，但是由于架构不同，OceanBase 数据库并不保证所有视图均能实现以及视图中所有的列含义与 MySQL 相同。

更多系统视图的说明信息请参考《参考指南》文档中 系统视图 章节。

## 字符集和字符序

OceanBase 数据库兼容 MySQL 数据库的部分字符集和字符序，具体支持情况如下：

 字符集：binary、utf8mb4、gbk、utf16、gb18030 和 latin1。

字符序：utf8mb4_general_ci、utf8mb4_bin、binary、gbk_chinese_ci、gbk_bin、utf16_general_ci、utf16_bin、utf8mb4_unicode_ci、utf16_unicode_ci、gb18030_chinese_ci、gb18030_bin、latin1_swedish_ci 和 latin1_bin。

## 功能适用性

 OceanBase 数据库社区版暂不支持 utf8mb4_unicode_ci 和 utf16_unicode_ci。

## 函数

与 MySQL 数据库对比，OceanBase 数据库的 MySQL 模式不支持如下函数：

 字符串函数： LOAD_FILE()  和 MATCH() 。

 XML 函数： ExtractValue()  和 UpdateXML() 。

 锁定函数： GET_LOCK() 、 IS_FREE_LOCK() 、 IS_USED_LOCK() 、RELEASE_ALL_LOCKS()  和 RELEASE_LOCK() 。

 其他函数： MASTER_POS_WAIT()  。

OceanBase 数据库所支持的分析（窗口）函数是 MySQL 数据库的超集，即 MySQL数据库的分析（窗口）函数都支持。

## 分区支持

OceanBase 数据库与 MySQL 数据库对分区的支持差异如下：

 OceanBase 数据库支持一级分区，模板化和非模板化二级分区；MySQL 数据库不支持非模板化二级分区。

 OceanBase 数据库的二级分区支持 Hash、Key、Range、Range Columns、List和 List Columns 分区；MySQL 数据库的二级分区仅支持 Hash 分区和 Key 分区。

更多分区的说明及使用请参见 分区管理 。

## 备份恢复

OceanBase 数据库兼容了部分 MySQL 数据库的备份恢复特性，主要支持情况如下：

 **支持全量备份和增量备份。**

 不支持集群级别的备份恢复。

 **仅支持热备份**，不支持冷备份。

 不支持租户内部部分数据库和表级的备份恢复。

 不支持备份数据的有效性验证。

## 存储引擎

与 MySQL 数据库基于数据块的 InnoDB 和 Myisam 引擎不同，OceanBase 数据库使用的是基于 LSM-Tree 架构的存储引擎。

## 优化器

OceanBase 数据库在优化器方面与 MySQL 数据库的区别，主要表现在以下几个方面：

###  查看执行计划的命令

 输出的列信息仅包含 ID 、 OPERATOR 、 NAME 、 EST. ROWS 和 COST 以及算子的详细信息。

 不支持使用 SHOW WARNINGS 显示额外的信息。

###  查看统计信息

 支持执行 ANALYZE TABLE 语句手动查询数据字典表存储有关列值的直方图统计信息。

 支持通过视图自动查看表统计信息和列统计信息。

 查询改写优化

 支持外联接优化

 支持外联接简化

 支持块嵌套循环和批量 Key 访问联接

 支持条件过滤

 支持常量叠算优化

 支持 IS NULL 优化 (索引不存储 NULL 值)

 支持 ORDER BY 优化

 支持 GROUP BY 优化

 支持 DISTINCT 消除

 支持 LIMIT 下压

 支持 Window 函数优化

 支持避免全表扫描

 支持谓词下压

 Optimizer Hint 机制

 支持联接顺序 Optimizer Hints

支持表级别的 Optimizer Hints

 支持索引级别的 Optimizer Hints

 语法支持 INDEX Hint、 FULL Hint、 ORDERED Hint 和 LEADING Hint 等，**不支持 USE INDEX 和 FORCE INDEX** 。

 兼容 MySQL 数据库的并行执行能力包括并行查询、并行复制和并行写入等，且OceanBase 数据库已经支持并行算子，包括并行聚集、并行联接、并行分组以及并行排序等。

 OceanBase 数据库还支持计划缓存和预编译，MySQL 数据库并不支持。

更多优化器的详细信息请参见 SQL 调优指南。

## 暂不支持的功能

 不支持 SELECT ... FOR SHARE ...  语法。

 对于备份恢复功能，不支持集群级别的备份恢复，不支持冷备份，不支持租户内部

部分数据库和表级的备份恢复，备份数据的有效性验证。

 对于优化器，查看执行计划的命令不支持使用 SHOW WARNINGS  显示额外的信息。

