[TOC]



# 一.Data Query Language概述

```
    即"数据查询语言"，简称"DQL"。

    用户通过DQL用于数据查询语言，严格意义上来讲它应该属于DML的一个子类，只不过它实在太重要了，因此我们通常把它单独拿出来说。
```



# 二.SELECT 配合内置函数使用-MySQL数据库独有的使用方式，其他数据库类型则可能不支持这种方式哟~

## 1.查看当前数据库的时间-NOW()

```
mysql> SELECT NOW();
+---------------------+
| NOW()               |
+---------------------+
| 2021-01-13 23:34:52 |
+---------------------+
1 row in set (0.33 sec)

mysql> 

```



## 2.查看当前所在的数据库-DATABASE()

```
mysql> SELECT DATABASE();
+------------+
| DATABASE() |
+------------+
| NULL       |
+------------+
1 row in set (0.01 sec)

mysql> 
mysql> USE oldboyedu
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> SELECT DATABASE();
+-------------+
| DATABASE()  |
+-------------+
| oldboyedu |
+-------------+
1 row in set (0.00 sec)

mysql> 

```



## 3.查看字符串拼接的函数-CONCAT()

```
mysql> SELECT CONCAT("hello world!");
+------------------------+
| CONCAT("hello world!") |
+------------------------+
| hello world!           |
+------------------------+
1 row in set (0.00 sec)

mysql> 
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
mysql> SELECT CONCAT(user,"@",host) AS "完整用户名" FROM mysql.user;
+-------------------------+
| 完整用户名              |
+-------------------------+
| mysql.session@localhost |
| mysql.sys@localhost     |
| root@localhost          |
+-------------------------+
3 rows in set (0.00 sec)

mysql> 
mysql> 

```



## 4.查看当前数据库的版本-VERSION()

```
mysql> SELECT VERSION();
+------------+
| VERSION()  |
+------------+
| 5.7.31-log |
+------------+
1 row in set (0.04 sec)

mysql> 

```



## 5.查看当前登录的用户-USER()

```
mysql> SELECT USER();
+----------------+
| USER()         |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.00 sec)

mysql> 

```



## 6.查看当前的角色

```
SELECT CURRENT_ROLE();
```



## 7.SELECT语句进行算术运算

```
mysql> SELECT  3 * 10;
+--------+
| 3 * 10 |
+--------+
|     30 |
+--------+
1 row in set (0.04 sec)

mysql> 
mysql> SELECT  3 * 10 + 8 * 2;
+----------------+
| 3 * 10 + 8 * 2 |
+----------------+
|             46 |
+----------------+
1 row in set (0.00 sec)

mysql> 

```



## 8.SELECT语句查询数据库的参数

```
mysql> SELECT @@PORT;
+--------+
| @@PORT |
+--------+
|  23307 |
+--------+
1 row in set (0.00 sec)

mysql> 
mysql> SELECT @@DATADIR;
+-------------------------------+
| @@DATADIR                     |
+-------------------------------+
| /oldboyedu/data/mysql23307/ |
+-------------------------------+
1 row in set (0.00 sec)

mysql> 
mysql> 
mysql> SELECT @@SOCKET;
+----------------------+
| @@SOCKET             |
+----------------------+
| /tmp/mysql23307.sock |
+----------------------+
1 row in set (0.08 sec)

mysql> 
mysql> SELECT @@INNODB_FLUSH_LOG_AT_TRX_COMMIT;
+----------------------------------+
| @@INNODB_FLUSH_LOG_AT_TRX_COMMIT |
+----------------------------------+
|                                1 |
+----------------------------------+
1 row in set (0.00 sec)

mysql> 

温馨提示:(如果记不住上述的变量，也可以基于关键字进行模糊查询哟~)
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



## 9.统计行数-COUNT()

```
mysql> SELECT COUNT(*) FROM mysql.user;
+----------+
| COUNT(*) |
+----------+
|       24 |
+----------+
1 row in set (0.00 sec)

mysql> 
```



## 1O.对指定列去重-DISTINCT

```
SELECT DISTINCT(CountryCode) FROM city;
```





## 11.查看MySQL支持的函数类型及帮助信息

```
mysql> HELP Functions
You asked for help about help category: "Functions"
For more information, type 'help <item>', where <item> is one of the following
categories:
   Bit Functions
   Comparison Operators
   Control Flow Functions
   Date and Time Functions
   Encryption Functions
   GROUP BY Functions and Modifiers
   Information Functions
   Locking Functions
   Logical Operators
   Miscellaneous Functions
   Numeric Functions
   Spatial Functions
   String Functions

mysql> 
mysql> HELP  String Functions
You asked for help about help category: "String Functions"
For more information, type 'help <item>', where <item> is one of the following
topics:
   ASCII
   BIN
   BINARY OPERATOR
   BIT_LENGTH
   CAST
   CHAR FUNCTION
   CHARACTER_LENGTH
   CHAR_LENGTH
   CONCAT
   CONCAT_WS
   CONVERT
   ELT
   EXPORT_SET
   EXTRACTVALUE
   FIELD
   FIND_IN_SET
   FORMAT
   FROM_BASE64
   HEX
   INSERT FUNCTION
   INSTR
   LCASE
   LEFT
   LENGTH
   LIKE
   LOAD_FILE
   LOCATE
   LOWER
   LPAD
   LTRIM
   MAKE_SET
   MATCH AGAINST
   MID
   NOT LIKE
   NOT REGEXP
   OCT
   OCTET_LENGTH
   ORD
   POSITION
   QUOTE
   REGEXP
   REPEAT FUNCTION
   REPLACE FUNCTION
   REVERSE
   RIGHT
   RPAD
   RTRIM
   SOUNDEX
   SOUNDS LIKE
   SPACE
   STRCMP
   SUBSTR
   SUBSTRING
   SUBSTRING_INDEX
   TO_BASE64
   TRIM
   UCASE
   UNHEX
   UPDATEXML
   UPPER
   WEIGHT_STRING

mysql> 


举个例子:
mysql> ? UPPER
Name: 'UPPER'
Description:
Syntax:
UPPER(str)

Returns the string str with all characters changed to uppercase
according to the current character set mapping. The default is utf8mb4.

mysql> SELECT UPPER('Hej');
        -> 'HEJ'

See the description of LOWER() for information that also applies to
UPPER(). This included information about how to perform lettercase
conversion of binary strings (BINARY, VARBINARY, BLOB) for which these
functions are ineffective, and information about case folding for
Unicode character sets.

URL: https://dev.mysql.com/doc/refman/8.0/en/string-functions.html


mysql>
```



# 三.单表查询-测试数据环境准备

## 1.SELECT 语法格式

```
mysql> ? SELECT
Name: 'SELECT'
Description:
Syntax:
SELECT
    [ALL | DISTINCT | DISTINCTROW ]
    [HIGH_PRIORITY]
    [STRAIGHT_JOIN]
    [SQL_SMALL_RESULT] [SQL_BIG_RESULT] [SQL_BUFFER_RESULT]
    [SQL_CACHE | SQL_NO_CACHE] [SQL_CALC_FOUND_ROWS]
    select_expr [, select_expr] ...
    [into_option]
    [FROM table_references
      [PARTITION partition_list]]
    [WHERE where_condition]
    [GROUP BY {col_name | expr | position}
      [ASC | DESC], ... [WITH ROLLUP]]
    [HAVING where_condition]
    [ORDER BY {col_name | expr | position}
      [ASC | DESC], ...]
    [LIMIT {[offset,] row_count | row_count OFFSET offset}]
    [PROCEDURE procedure_name(argument_list)]
    [into_option]
    [FOR UPDATE | LOCK IN SHARE MODE]

into_option: {
    INTO OUTFILE 'file_name'
        [CHARACTER SET charset_name]
        export_options
  | INTO DUMPFILE 'file_name'
  | INTO var_name [, var_name] ...
}

SELECT is used to retrieve rows selected from one or more tables, and
can include UNION statements and subqueries. See [HELP UNION], and
https://dev.mysql.com/doc/refman/5.7/en/subqueries.html.

The most commonly used clauses of SELECT statements are these:

o Each select_expr indicates a column that you want to retrieve. There
  must be at least one select_expr.

o table_references indicates the table or tables from which to retrieve
  rows. Its syntax is described in [HELP JOIN].

o SELECT supports explicit partition selection using the PARTITION with
  a list of partitions or subpartitions (or both) following the name of
  the table in a table_reference (see [HELP JOIN]). In this case, rows
  are selected only from the partitions listed, and any other
  partitions of the table are ignored. For more information and
  examples, see
  https://dev.mysql.com/doc/refman/5.7/en/partitioning-selection.html.

  SELECT ... PARTITION from tables using storage engines such as MyISAM
  that perform table-level locks (and thus partition locks) lock only
  the partitions or subpartitions named by the PARTITION option.

  For more information, see
  https://dev.mysql.com/doc/refman/5.7/en/partitioning-limitations-lock
  ing.html.

o The WHERE clause, if given, indicates the condition or conditions
  that rows must satisfy to be selected. where_condition is an
  expression that evaluates to true for each row to be selected. The
  statement selects all rows if there is no WHERE clause.

  In the WHERE expression, you can use any of the functions and
  operators that MySQL supports, except for aggregate (summary)
  functions. See
  https://dev.mysql.com/doc/refman/5.7/en/expressions.html, and
  https://dev.mysql.com/doc/refman/5.7/en/functions.html.

SELECT can also be used to retrieve rows computed without reference to
any table.

URL: https://dev.mysql.com/doc/refman/5.7/en/select.html


mysql> 

```


## 2.MySQL测试环境配置

```
    如下图所示，是官方提供的测试数据库(https://dev.mysql.com/doc/index-other.html)，我们可以选择一个或多个来进行查询练习，这样就不用咱们自己辛苦花时间来造数据啦。

    官方测试数据库下载地址:
        https://github.com/datacharmer/test_db
        https://downloads.mysql.com/docs/world.sql.gz
        https://downloads.mysql.com/docs/world_x-db.tar.gz
        https://downloads.mysql.com/docs/sakila-db.tar.gz
        https://downloads.mysql.com/docs/menagerie-db.tar.gz

    你可以选择上面任意一个来进行查询练习，本次我们选择的是world数据库来用作练习查询。以下是导入world.sql的语法:
        [root@docker201.oldboyedu.com ~]# ss -ntl
        State       Recv-Q Send-Q                                                 Local Address:Port                                                                Peer Address:Port              
        LISTEN      0      128                                                                *:22                                                                             *:*                  
        LISTEN      0      70                                                              [::]:33060                                                                       [::]:*                  
        LISTEN      0      80                                                              [::]:23306                                                                       [::]:*                  
        LISTEN      0      80                                                              [::]:23307                                                                       [::]:*                  
        LISTEN      0      128                                                             [::]:23308                                                                       [::]:*                  
        LISTEN      0      128                                                             [::]:22                                                                          [::]:*                  
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# wc -l world.sql  # 由于行数较多，我就不打印每局SQL了，感兴趣的小伙伴可以自行下载并参考官网的数据哈。
        5437 world.sql
        [root@docker201.oldboyedu.com ~]# 
        [root@docker201.oldboyedu.com ~]# mysql  -S /tmp/mysql23307.sock  < world.sql 
        [root@docker201.oldboyedu.com ~]# 

    查看数据是否导入成功:
        [root@docker201.oldboyedu.com ~]# mysql  -S /tmp/mysql23307.sock  
        Welcome to the MySQL monitor.  Commands end with ; or \g.
        Your MySQL connection id is 48
        Server version: 5.7.31-log MySQL Community Server (GPL)
        
        Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
        
        Oracle is a registered trademark of Oracle Corporation and/or its
        affiliates. Other names may be trademarks of their respective
        owners.
        
        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
        
        mysql> 
        mysql> SHOW DATABASES;
        +--------------------+
        | Database           |
        +--------------------+
        | information_schema |
        | mysql              |
        | performance_schema |
        | sys                |
        | world              |
        | oldboyedu        |
        +--------------------+
        6 rows in set (0.00 sec)
        
        mysql> 
        mysql> USE world
        Reading table information for completion of table and column names
        You can turn off this feature to get a quicker startup with -A
        
        Database changed
        mysql> 
        mysql> 
        mysql> SHOW TABLES;
        +-----------------+
        | Tables_in_world |
        +-----------------+
        | city            |
        | country         |
        | countrylanguage |
        +-----------------+
        3 rows in set (0.00 sec)
        
        mysql> 
        mysql> DESC city;
        +-------------+----------+------+-----+---------+----------------+
        | Field       | Type     | Null | Key | Default | Extra          |
        +-------------+----------+------+-----+---------+----------------+
        | ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
        | Name        | char(35) | NO   |     |         |                |
        | CountryCode | char(3)  | NO   | MUL |         |                |
        | District    | char(20) | NO   |     |         |                |
        | Population  | int(11)  | NO   |     | 0       |                |
        +-------------+----------+------+-----+---------+----------------+
        5 rows in set (0.03 sec)
        
        mysql> 
        mysql> DESC country;
        +----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+
        | Field          | Type                                                                                  | Null | Key | Default | Extra |
        +----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+
        | Code           | char(3)                                                                               | NO   | PRI |         |       |
        | Name           | char(52)                                                                              | NO   |     |         |       |
        | Continent      | enum('Asia','Europe','North America','Africa','Oceania','Antarctica','South America') | NO   |     | Asia    |       |
        | Region         | char(26)                                                                              | NO   |     |         |       |
        | SurfaceArea    | decimal(10,2)                                                                         | NO   |     | 0.00    |       |
        | IndepYear      | smallint(6)                                                                           | YES  |     | NULL    |       |
        | Population     | int(11)                                                                               | NO   |     | 0       |       |
        | LifeExpectancy | decimal(3,1)                                                                          | YES  |     | NULL    |       |
        | GNP            | decimal(10,2)                                                                         | YES  |     | NULL    |       |
        | GNPOld         | decimal(10,2)                                                                         | YES  |     | NULL    |       |
        | LocalName      | char(45)                                                                              | NO   |     |         |       |
        | GovernmentForm | char(45)                                                                              | NO   |     |         |       |
        | HeadOfState    | char(60)                                                                              | YES  |     | NULL    |       |
        | Capital        | int(11)                                                                               | YES  |     | NULL    |       |
        | Code2          | char(2)                                                                               | NO   |     |         |       |
        +----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+
        15 rows in set (0.03 sec)
        
        mysql> 
        mysql> DESC countrylanguage;
        +-------------+---------------+------+-----+---------+-------+
        | Field       | Type          | Null | Key | Default | Extra |
        +-------------+---------------+------+-----+---------+-------+
        | CountryCode | char(3)       | NO   | PRI |         |       |
        | Language    | char(30)      | NO   | PRI |         |       |
        | IsOfficial  | enum('T','F') | NO   |     | F       |       |
        | Percentage  | decimal(4,1)  | NO   |     | 0.0     |       |
        +-------------+---------------+------+-----+---------+-------+
        4 rows in set (0.54 sec)
        
        mysql> 

```

![1631154309834](E:/linux76后期课程/数据库/笔记/mysql/笔记/06-老男孩教育-MySQL的数据查询语言DQL.assets/1631154309834.png)





# 四.单表查询-"SELECT + FROM"子句使用案例(从单表查询相关的标签开始，其SQL语法属于标准用法，换句话说，其他数据库也支持这样的SQL语法)

## 1.查看全表信息

```
mysql> DESC city;  # 查看列的数据结构
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   |     |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   |     | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> 
mysql> SELECT ID,Name,CountryCode,District,Population FROM city;  # 我们可以查询指定的列
+----+----------------+-------------+---------------+------------+
| ID | Name           | CountryCode | District      | Population |
+----+----------------+-------------+---------------+------------+
|  1 | Kabul          | AFG         | Kabol         |    1780000 |
|  2 | Qandahar       | AFG         | Qandahar      |     237500 |
|  3 | Herat          | AFG         | Herat         |     186800 |
|  4 | Mazar-e-Sharif | AFG         | Balkh         |     127800 |
|  5 | Amsterdam      | NLD         | Noord-Holland |     731200 |
|  6 | Rotterdam      | NLD         | Zuid-Holland  |     593321 |
|  7 | Haag           | NLD         | Zuid-Holland  |     440900 |
|  8 | Utrecht        | NLD         | Utrecht       |     234323 |
|  9 | Eindhoven      | NLD         | Noord-Brabant |     201843 |
| 10 | Tilburg        | NLD         | Noord-Brabant |     193238 |

...(数据较多，此处省略几千行...)

| 4077 | Jabaliya                           | PSE         | North Gaza             |     113901 |
| 4078 | Nablus                             | PSE         | Nablus                 |     100231 |
| 4079 | Rafah                              | PSE         | Rafah                  |      92020 |
+------+------------------------------------+-------------+------------------------+------------+
4079 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM city;  # 如果我们想要查询全部列，其实可以省略不写，因为默认就查询所以列哟~
+----+----------------+-------------+---------------+------------+
| ID | Name           | CountryCode | District      | Population |
+----+----------------+-------------+---------------+------------+
|  1 | Kabul          | AFG         | Kabol         |    1780000 |
|  2 | Qandahar       | AFG         | Qandahar      |     237500 |
|  3 | Herat          | AFG         | Herat         |     186800 |
|  4 | Mazar-e-Sharif | AFG         | Balkh         |     127800 |
|  5 | Amsterdam      | NLD         | Noord-Holland |     731200 |
|  6 | Rotterdam      | NLD         | Zuid-Holland  |     593321 |


...(数据较多，此处省略几千行...)

| 4074 | Gaza                               | PSE         | Gaza                   |     353632 |
| 4075 | Khan Yunis                         | PSE         | Khan Yunis             |     123175 |
| 4076 | Hebron                             | PSE         | Hebron                 |     119401 |
| 4077 | Jabaliya                           | PSE         | North Gaza             |     113901 |
| 4078 | Nablus                             | PSE         | Nablus                 |     100231 |
| 4079 | Rafah                              | PSE         | Rafah                  |      92020 |
+------+------------------------------------+-------------+------------------------+------------+
4079 rows in set (0.00 sec)

mysql> 


```



## 2.查看部分列信息

```
mysql> DESC city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   |     |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   |     | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> 
mysql> SELECT Name,District,Population FROM city;
+----------------+---------------+------------+
| Name           | District      | Population |
+----------------+---------------+------------+
| Kabul          | Kabol         |    1780000 |
| Qandahar       | Qandahar      |     237500 |
| Herat          | Herat         |     186800 |
| Mazar-e-Sharif | Balkh         |     127800 |
| Amsterdam      | Noord-Holland |     731200 |
| Rotterdam      | Zuid-Holland  |     593321 |
| Haag           | Zuid-Holland  |     440900 |
| Utrecht        | Utrecht       |     234323 |
| Eindhoven      | Noord-Brabant |     201843 |
| Tilburg        | Noord-Brabant |     193238 |

...(数据较多，此处省略几千行...)

| Gweru          | Midlands      |     128037 |
| Gaza           | Gaza          |     353632 |
| Khan Yunis     | Khan Yunis    |     123175 |
| Hebron         | Hebron        |     119401 |
| Jabaliya       | North Gaza    |     113901 |
| Nablus         | Nablus        |     100231 |
| Rafah          | Rafah         |      92020 |
+----------------+---------------+------------+
4079 rows in set (0.01 sec)

mysql> 

```



## 3.查询指定的列-分页查询应用

```
mysql> SELECT * FROM city limit 10;  # 查询前10行。
+----+----------------+-------------+---------------+------------+
| ID | Name           | CountryCode | District      | Population |
+----+----------------+-------------+---------------+------------+
|  1 | Kabul          | AFG         | Kabol         |    1780000 |
|  2 | Qandahar       | AFG         | Qandahar      |     237500 |
|  3 | Herat          | AFG         | Herat         |     186800 |
|  4 | Mazar-e-Sharif | AFG         | Balkh         |     127800 |
|  5 | Amsterdam      | NLD         | Noord-Holland |     731200 |
|  6 | Rotterdam      | NLD         | Zuid-Holland  |     593321 |
|  7 | Haag           | NLD         | Zuid-Holland  |     440900 |
|  8 | Utrecht        | NLD         | Utrecht       |     234323 |
|  9 | Eindhoven      | NLD         | Noord-Brabant |     201843 |
| 10 | Tilburg        | NLD         | Noord-Brabant |     193238 |
+----+----------------+-------------+---------------+------------+
10 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM city limit 20,5;  # 从第20行的下一行开始，往后查询5行数据。
+----+----------------+-------------+---------------+------------+
| ID | Name           | CountryCode | District      | Population |
+----+----------------+-------------+---------------+------------+
| 21 | Amersfoort     | NLD         | Utrecht       |     126270 |
| 22 | Maastricht     | NLD         | Limburg       |     122087 |
| 23 | Dordrecht      | NLD         | Zuid-Holland  |     119811 |
| 24 | Leiden         | NLD         | Zuid-Holland  |     117196 |
| 25 | Haarlemmermeer | NLD         | Noord-Holland |     110722 |
+----+----------------+-------------+---------------+------------+
5 rows in set (0.01 sec)

mysql> 

```



## 4.用于去重复的DISTINCT函数

```
mysql> DESC world.city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   |     |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   |     | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> 
mysql> 
mysql> SELECT COUNT(*) FROM world.city;
+----------+
| COUNT(*) |
+----------+
|     4079 |
+----------+
1 row in set (0.00 sec)

mysql> 
mysql> SELECT DISTINCT(CountryCode) FROM world.city;  # 使用DISTINCT函数可以去重
+-------------+
| CountryCode |
+-------------+
| ABW         |
| AFG         |
| AGO         |
| AIA         |
| ALB         |
| AND         |
| ANT         |
| ARE         |

(其中省略几百行...)

| WLF         |
| WSM         |
| YEM         |
| YUG         |
| ZAF         |
| ZMB         |
| ZWE         |
+-------------+
232 rows in set (0.00 sec)

mysql>  

```



# 五.单表查询-"SELECT + FROM + WHERE"子句使用案例

```
    我们可以使用WHERE子句来配合一些常用的比较运算符进行查询，比如: “>=",">","=","<=","<","!="("<>")等等。
```

## 1.查询属于中国的城市

```
mysql> SELECT * FROM city WHERE countrycode='CHN';
+------+---------------------+-------------+----------------+------------+
| ID   | Name                | CountryCode | District       | Population |
+------+---------------------+-------------+----------------+------------+
| 1890 | Shanghai            | CHN         | Shanghai       |    9696300 |
| 1891 | Peking              | CHN         | Peking         |    7472000 |
| 1892 | Chongqing           | CHN         | Chongqing      |    6351600 |
| 1893 | Tianjin             | CHN         | Tianjin        |    5286800 |
| 1894 | Wuhan               | CHN         | Hubei          |    4344600 |
| 1895 | Harbin              | CHN         | Heilongjiang   |    4289800 |
| 1896 | Shenyang            | CHN         | Liaoning       |    4265200 |
| 1897 | Kanton [Guangzhou]  | CHN         | Guangdong      |    4256300 |
| 1898 | Chengdu             | CHN         | Sichuan        |    3361500 |

...(数据较多，此处省略几百行...)

| 2245 | Putian              | CHN         | Fujian         |      91030 |
| 2246 | Linhai              | CHN         | Zhejiang       |      90870 |
| 2247 | Xilin Hot           | CHN         | Inner Mongolia |      90646 |
| 2248 | Shaowu              | CHN         | Fujian         |      90286 |
| 2249 | Junan               | CHN         | Shandong       |      90222 |
| 2250 | Huaying             | CHN         | Sichuan        |      89400 |
| 2251 | Pingyi              | CHN         | Shandong       |      89373 |
| 2252 | Huangyan            | CHN         | Zhejiang       |      89288 |
+------+---------------------+-------------+----------------+------------+
363 rows in set (0.12 sec)

mysql> 

```



## 2.查询属于中国的城市人数大于500万的城市

```
mysql> SELECT * FROM city WHERE countrycode='CHN' AND Population>5000000;
+------+-----------+-------------+-----------+------------+
| ID   | Name      | CountryCode | District  | Population |
+------+-----------+-------------+-----------+------------+
| 1890 | Shanghai  | CHN         | Shanghai  |    9696300 |
| 1891 | Peking    | CHN         | Peking    |    7472000 |
| 1892 | Chongqing | CHN         | Chongqing |    6351600 |
| 1893 | Tianjin   | CHN         | Tianjin   |    5286800 |
+------+-----------+-------------+-----------+------------+
4 rows in set (0.00 sec)

mysql> 

温馨提示:
    由于历史性原因，Peking就是我们现在所说的北京，只不过Peking这个称呼现在已经很少被人提及了。我们通常说北京为BeiJing。
    参考链接
        https://www.sohu.com/a/250225319_100057012
```



## 3.查询中国或美国的城市信息

```
mysql> SELECT * FROM city WHERE CountryCode='CHN' OR CountryCode='USA';  # 我们可以使用逻辑判断的方式来过滤某个字段的信息
mysql> 
mysql>  SELECT * FROM city WHERE CountryCode IN ('CHN','USA');  # 我们也可以使用类似"集合"的方式来过滤某个字段的信息
mysql> 
mysql>  SELECT * FROM city WHERE CountryCode='CHN' UNION ALL SELECT * FROM city WHERE CountryCode='USA';  # 将两次查询结果合并到同一张表中展示。
mysql> 

UNION和UNION ALL的区别:
    相同点：
        在某些情况下可以替代OR或者IN的查询且查询效率可能会更好，他们的作用都是聚合两个查询的结果集。

    不同点：
        需要注意的是，UNION是有DISTINCT函数的效果，即可以去重，但是UNION ALL则不能去重哟，只做结果集的聚合。
```



## 4.查询中国或美国的城市信息并且人数超过800万的城市

```
mysql> SELECT * FROM city WHERE CountryCode IN('CHN', 'USA') AND Population > 8000000 ;
+------+----------+-------------+----------+------------+
| ID   | Name     | CountryCode | District | Population |
+------+----------+-------------+----------+------------+
| 1890 | Shanghai | CHN         | Shanghai |    9696300 |
| 3793 | New York | USA         | New York |    8008278 |
+------+----------+-------------+----------+------------+
2 rows in set (0.00 sec)

mysql> 

温馨提示:
    上述数据并不准确，我猜测这份数据可能是30多年前的数据，我们这也只是用于查询数据而已，不必当然哈，毕竟这是国外提供的数据，他们对我们国情并不知道。
    别的城市不说，就直说咱们首都北京：
        (1)在全国第五次(在20年前，即2000年底)全国人口普查中，北京常住人口1357万多人，注意哈，没有算上流动人口;
        (2)在全国第六次(在10年前，即2010年底)全国人口普查中，北京常住人口1961.2万人;
        (3)随着近10年互联网的发展，在去年2020年的全国人口普查结果还暂时没有找到靠谱的文章，但我大胆预测尽管有疫情原因，很多人选择离开北京，但保守估计也得有2500万常住人口;
    参考链接:
        https://www.dyhzdl.cn/k/doc/de4b5d64dd88d0d232d46a95.html
```



## 5.查询中国或美国的城市信息并且人数在500万到800万之间的城市

```
mysql> SELECT * FROM city WHERE CountryCode IN('CHN', 'USA') AND Population BETWEEN 5000000 AND 8000000 ;
+------+-----------+-------------+-----------+------------+
| ID   | Name      | CountryCode | District  | Population |
+------+-----------+-------------+-----------+------------+
| 1891 | Peking    | CHN         | Peking    |    7472000 |
| 1892 | Chongqing | CHN         | Chongqing |    6351600 |
| 1893 | Tianjin   | CHN         | Tianjin   |    5286800 |
+------+-----------+-------------+-----------+------------+
3 rows in set (0.00 sec)

mysql> 

```



# 六.单表查询-"SELECT + FROM + WHERE + LIKE"子句使用案例-模糊查询要全表扫描，不走索引，生产环境尽量少用!

```
温馨提示:
    LIKE子句尽量要少用，因为它要进行全表扫描。这意味着你设置的索引字段也形同虚，即查询效率极低！但基本使用还是有必要了解一下的哟~
```

## 1.查询city中，国家代号是CH开头的城市信息

```
mysql> SELECT * FROM city WHERE CountryCode LIKE 'CH%';
+------+-------------------+-------------+-------------+------------+
| ID   | Name              | CountryCode | District    | Population |
+------+-------------------+-------------+-------------+------------+
| 3245 | Zürich            | CHE         | Zürich      |     336800 |
| 3246 | Geneve            | CHE         | Geneve      |     173500 |
| 3247 | Basel             | CHE         | Basel-Stadt |     166700 |
| 3248 | Bern              | CHE         | Bern        |     122700 |
| 3249 | Lausanne          | CHE         | Vaud        |     114500 |
|  554 | Santiago de Chile | CHL         | Santiago    |    4703954 |
|  555 | Puente Alto       | CHL         | Santiago    |     386236 |

...(数据较多，此处省略几百行...)

| 2249 | Junan             | CHN         | Shandong    |      90222 |
| 2250 | Huaying           | CHN         | Sichuan     |      89400 |
| 2251 | Pingyi            | CHN         | Shandong    |      89373 |
| 2252 | Huangyan          | CHN         | Zhejiang    |      89288 |
+------+-------------------+-------------+-------------+------------+
397 rows in set (0.00 sec)

mysql> 

```



# 七.单表查询-"SELECT + FROM + WHERE + GROUP BY"子句使用案例-配合聚合函数使用

## 1.查看GROUP BY 相关的聚合函数

```
    我们知道，查看MySQL函数相关的帮助信息如下所示:
        mysql> HELP Functions
        You asked for help about help category: "Functions"
        For more information, type 'help <item>', where <item> is one of the following
        categories:
           Bit Functions
           Comparison Operators
           Control Flow Functions
           Date and Time Functions
           Encryption Functions
           GROUP BY Functions and Modifiers
           Information Functions
           Locking Functions
           Logical Operators
           Miscellaneous Functions
           Numeric Functions
           Spatial Functions
           String Functions
        
        mysql> 

    GROUP BY子句通常配合聚合函数使用，如下所示:
        mysql> HELP Aggregate Functions and Modifiers
        You asked for help about help category: "GROUP BY Functions and Modifiers"
        For more information, type 'help <item>', where <item> is one of the following
        topics:
           AVG  # 计算平均值
           BIT_AND
           BIT_OR
           BIT_XOR
           COUNT  # 统计个数
           COUNT DISTINCT
           GROUP_CONCAT  # 将一列数据的每个元素使用逗号(",")进行分割在一行中显示。简而言之，就是将一列数据写在一行中。
           JSON_ARRAYAGG
           JSON_OBJECTAGG
           MAX  # 最大值
           MIN  # 最小值
           STD
           STDDEV
           STDDEV_POP
           STDDEV_SAMP
           SUM  # 求和
           VARIANCE
           VAR_POP
           VAR_SAMP
        
        mysql> 

    GROUP BY语句的应用场景:
        需要对一张表按照不同数据特点，需要分组计算统计时，会使用:"GROUP BY + 聚合函数"。

    GROUP BY语句使用核心方法:
        (1)根据需求，找出分组条件;
        (2)根据需要，使用合适的聚合函数;

```



## 2.统计每个国家城市的个数

```
mysql> SELECT CountryCode,COUNT(ID) FROM city GROUP BY CountryCode ;
+-------------+-----------+
| CountryCode | COUNT(ID) |
+-------------+-----------+
| ABW         |         1 |
| AFG         |         4 |
| AGO         |         5 |
| AIA         |         2 |
| ALB         |         1 |

......(此处省略两百多行)

| WLF         |         1 |
| WSM         |         1 |
| YEM         |         6 |
| YUG         |         8 |
| ZAF         |        44 |
| ZMB         |         7 |
| ZWE         |         6 |
+-------------+-----------+
232 rows in set (0.00 sec)

mysql> 

```

## 3.统计中国每个省城市的个数

```
mysql> SELECT District,COUNT(ID) FROM city WHERE CountryCode='CHN' GROUP BY District;  # 一条查询语句搞定
+----------------+-----------+
| District       | COUNT(ID) |
+----------------+-----------+
| Anhui          |        16 |
| Chongqing      |         1 |
| Fujian         |        12 |
| Gansu          |         7 |
| Guangdong      |        20 |
| Guangxi        |         9 |
| Guizhou        |         6 |
| Hainan         |         2 |
| Hebei          |        12 |
| Heilongjiang   |        21 |
| Henan          |        18 |
| Hubei          |        22 |
| Hunan          |        18 |
| Inner Mongolia |        13 |
| Jiangsu        |        25 |
| Jiangxi        |        11 |
| Jilin          |        20 |
| Liaoning       |        21 |
| Ningxia        |         2 |
| Peking         |         2 |
| Qinghai        |         1 |
| Shaanxi        |         8 |
| Shandong       |        32 |
| Shanghai       |         1 |
| Shanxi         |         9 |
| Sichuan        |        21 |
| Tianjin        |         1 |
| Tibet          |         1 |
| Xinxiang       |        10 |
| Yunnan         |         5 |
| Zhejiang       |        16 |
+----------------+-----------+
31 rows in set (0.00 sec)

mysql> 
mysql> SELECT District,COUNT(ID) FROM (SELECT * FROM city WHERE CountryCode='CHN') AS china GROUP BY District;  # 利用子查询搞定，尽管也能得到正确的结果但我不推荐使用，因此要发起来两次查询，效率没有上面发起一次查询的效率高;
+----------------+-----------+
| District       | COUNT(ID) |
+----------------+-----------+
| Anhui          |        16 |
| Chongqing      |         1 |
| Fujian         |        12 |
| Gansu          |         7 |
| Guangdong      |        20 |
| Guangxi        |         9 |
| Guizhou        |         6 |
| Hainan         |         2 |
| Hebei          |        12 |
| Heilongjiang   |        21 |
| Henan          |        18 |
| Hubei          |        22 |
| Hunan          |        18 |
| Inner Mongolia |        13 |
| Jiangsu        |        25 |
| Jiangxi        |        11 |
| Jilin          |        20 |
| Liaoning       |        21 |
| Ningxia        |         2 |
| Peking         |         2 |
| Qinghai        |         1 |
| Shaanxi        |         8 |
| Shandong       |        32 |
| Shanghai       |         1 |
| Shanxi         |         9 |
| Sichuan        |        21 |
| Tianjin        |         1 |
| Tibet          |         1 |
| Xinxiang       |        10 |
| Yunnan         |         5 |
| Zhejiang       |        16 |
+----------------+-----------+
31 rows in set (0.00 sec)

mysql> 

```

## 4.统计每个国家的总人口

```
mysql> SELECT CountryCode,SUM(Population) FROM city GROUP BY CountryCode;

```

## 5.统计中国每个省的总人口

```
mysql> SELECT District,SUM(Population) FROM city WHERE CountryCode='CHN' GROUP BY District;

```

## 6.统计中国每个省的城市个数及城市名称列表

```
mysql> SELECT District,SUM(Population),COUNT(ID),GROUP_CONCAT(name) FROM city WHERE CountryCode='CHN' GROUP BY District;  

温馨提示:
    GROUP_CONCAT聚合函数可以将一列数据转成一行并用逗号分割。

```



# 八.单表查询-"SELECT + FROM + WHERE + GROUP BY + HAVING"子句使用案例-配合聚合函数使用

## 1.WHERE子句与HAVING子句的关系

```
    HAVING和WHERE子句功能类似，都是过滤数据，只不过WHERE在GROUP BY子句之前进行过滤，而HAVING在GROUP BY子句后过滤。

    这是MySQL语法的要求，WHERE子句必须在GROUP BY子句之前进行过滤，而HAVING是对GROUP BY子句之后的数据进行第二次过滤。

    综上所述，HAVING子句的应用场景也很明确，即需要在"GROUP BY子句 + 聚合函数"之后再做判断时过滤。
    
```

## 2.统计中国每个省的总人数在800万以上的省份

```
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District;
+----------------+----------+
| District       | p1       |
+----------------+----------+
| Anhui          |  5141136 |
| Chongqing      |  6351600 |
| Fujian         |  3575650 |
| Gansu          |  2462631 |
| Guangdong      |  9510263 |
| Guangxi        |  2925142 |
| Guizhou        |  2512087 |
| Hainan         |   557120 |
| Hebei          |  6458553 |
| Heilongjiang   | 11628057 |
| Henan          |  6899010 |
| Hubei          |  8547585 |
| Hunan          |  5439275 |
| Inner Mongolia |  4121479 |
| Jiangsu        |  9719860 |
| Jiangxi        |  3831558 |
| Jilin          |  7826824 |
| Liaoning       | 15079174 |
| Ningxia        |   802362 |
| Peking         |  7569168 |
| Qinghai        |   700200 |
| Shaanxi        |  4297493 |
| Shandong       | 12114416 |
| Shanghai       |  9696300 |
| Shanxi         |  4169899 |
| Sichuan        |  7456867 |
| Tianjin        |  5286800 |
| Tibet          |   120000 |
| Xinxiang       |  2894705 |
| Yunnan         |  2451016 |
| Zhejiang       |  5807384 |
+----------------+----------+
31 rows in set (0.00 sec)

mysql> 
mysql> 
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Guangdong    |  9510263 |
| Heilongjiang | 11628057 |
| Hubei        |  8547585 |
| Jiangsu      |  9719860 |
| Liaoning     | 15079174 |
| Shandong     | 12114416 |
| Shanghai     |  9696300 |
+--------------+----------+
7 rows in set (0.00 sec)

mysql> 

```



# 九.单表查询-"SELECT + FROM + WHERE + GROUP BY + HAVING + GROUP BY"子句使用案例-配合聚合函数使用

## 1.统计中国每个省的总人数在800万以上的省份，并且按照总人口数从小到大排序输出

```
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Guangdong    |  9510263 |
| Heilongjiang | 11628057 |
| Hubei        |  8547585 |
| Jiangsu      |  9719860 |
| Liaoning     | 15079174 |
| Shandong     | 12114416 |
| Shanghai     |  9696300 |
+--------------+----------+
7 rows in set (0.00 sec)

mysql> 
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000 ORDER BY p1;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Hubei        |  8547585 |
| Guangdong    |  9510263 |
| Shanghai     |  9696300 |
| Jiangsu      |  9719860 |
| Heilongjiang | 11628057 |
| Shandong     | 12114416 |
| Liaoning     | 15079174 |
+--------------+----------+
7 rows in set (0.00 sec)

mysql> 

```

## 2.统计中国每个省的总人数在800万以上的省份，并且按照总人口数从大到小排序输出

```
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Guangdong    |  9510263 |
| Heilongjiang | 11628057 |
| Hubei        |  8547585 |
| Jiangsu      |  9719860 |
| Liaoning     | 15079174 |
| Shandong     | 12114416 |
| Shanghai     |  9696300 |
+--------------+----------+
7 rows in set (0.00 sec)

mysql> 
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000 ORDER BY p1 DESC;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Liaoning     | 15079174 |
| Shandong     | 12114416 |
| Heilongjiang | 11628057 |
| Jiangsu      |  9719860 |
| Shanghai     |  9696300 |
| Guangdong    |  9510263 |
| Hubei        |  8547585 |
+--------------+----------+
7 rows in set (0.00 sec)

mysql> 

```



# 十.单表查询-"SELECT + FROM + WHERE + GROUP BY + HAVING + ORDER BY + LIMIT"子句使用案例-配合聚合函数使用

## 1.LIMIT子句的作用

```
    当从数据库查询的数据集较多时，我们可以利用LIMIT来分页显示结果集。
```

## 2.统计中国每个省的总人数在800万以上的省份，并且按照总人口数从大到小排序输出，但只显示前3名。

```
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000 ORDER BY p1 DESC;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Liaoning     | 15079174 |
| Shandong     | 12114416 |
| Heilongjiang | 11628057 |
| Jiangsu      |  9719860 |
| Shanghai     |  9696300 |
| Guangdong    |  9510263 |
| Hubei        |  8547585 |
+--------------+----------+
7 rows in set (0.00 sec)

mysql> 
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000 ORDER BY p1 DESC LIMIT 3;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Liaoning     | 15079174 |
| Shandong     | 12114416 |
| Heilongjiang | 11628057 |
+--------------+----------+
3 rows in set (0.00 sec)

mysql> 
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000 ORDER BY p1 DESC LIMIT 3 OFFSET 0;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Liaoning     | 15079174 |
| Shandong     | 12114416 |
| Heilongjiang | 11628057 |
+--------------+----------+
3 rows in set (0.01 sec)

mysql> 


温馨提示:
    "LIMIT 3"和"LIMIT 3 OFFSET 0"作用是一样的，只不过OFFSET为0时可以省略不写，OFFSET表示跳过的行数，因此这两个语句表示的意思是跳过0行，显示3行数据。

```

## 3.统计中国每个省的总人数在800万以上的省份，并且按照总人口数从大到小排序输出，但只显示前4-5名。

```
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000 ORDER BY p1 DESC;
+--------------+----------+
| District     | p1       |
+--------------+----------+
| Liaoning     | 15079174 |
| Shandong     | 12114416 |
| Heilongjiang | 11628057 |
| Jiangsu      |  9719860 |
| Shanghai     |  9696300 |
| Guangdong    |  9510263 |
| Hubei        |  8547585 |
+--------------+----------+
7 rows in set (0.00 sec)

mysql> 
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000 ORDER BY p1 DESC LIMIT 3,2;
+----------+---------+
| District | p1      |
+----------+---------+
| Jiangsu  | 9719860 |
| Shanghai | 9696300 |
+----------+---------+
2 rows in set (0.00 sec)

mysql> 
mysql> SELECT District,SUM(Population) AS p1 FROM city WHERE CountryCode='CHN' GROUP BY District HAVING p1 > 8000000 ORDER BY p1 DESC LIMIT 2 OFFSET 3;
+----------+---------+
| District | p1      |
+----------+---------+
| Jiangsu  | 9719860 |
| Shanghai | 9696300 |
+----------+---------+
2 rows in set (0.00 sec)

mysql> 

温馨提示:
    (1)"LIMIT 3,2"表示跳过前3条数据，往下查看2条数据;
    (2)"LIMIT 2 OFFSET 3"是跳过3行，显示2行数据，尽管写法和上面的有所不同，但都能达到相同的查询效果哟;

```



# 十一.多表查询-测试数据环境准备

## 1.为什么要使用多表连接查询呢?

```
    这是由于我们的查询需求导致的,因为需求的数据可能来自多张表,单张表无法满足我们对某些数据的查询要求.

    接下来我们先准备测试环境，建议先不要看建表语句，先根据表结构或表的数据类型，先自行实现数据库测试数据的创建，因为咱们的数据量并不大，写几条SQL也不会太浪费时间，反而是一个练习SQL的机会！

    所谓的多表查询,可以简单理解为将多张表中又关联的部分数据合并成一张"临时表"，而后在这张"临时表"中插入数据。
```

## 2.表结构说明(请先不要查看下面的建表语句，根据给出的表结构请你自行实现建表语句)

```
mysql> USE school;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> SHOW TABLES;
+------------------+
| Tables_in_school |
+------------------+
| course           |
| student          |
| student_score    |
| teacher          |
+------------------+
4 rows in set (0.00 sec)

mysql> 
mysql> DESC student;
+--------+-----------------------+------+-----+---------+----------------+
| Field  | Type                  | Null | Key | Default | Extra          |
+--------+-----------------------+------+-----+---------+----------------+
| id     | int(11)               | NO   | PRI | NULL    | auto_increment |
| name   | varchar(30)           | NO   |     | NULL    |                |
| age    | tinyint(3) unsigned   | NO   |     | NULL    |                |
| gender | enum('Male','Female') | YES  |     | Male    |                |
+--------+-----------------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

mysql> 
mysql> DESC teacher;
+--------+-----------------------+------+-----+---------+----------------+
| Field  | Type                  | Null | Key | Default | Extra          |
+--------+-----------------------+------+-----+---------+----------------+
| id     | smallint(5) unsigned  | NO   | PRI | NULL    | auto_increment |
| name   | varchar(30)           | NO   |     | NULL    |                |
| age    | tinyint(3) unsigned   | NO   |     | NULL    |                |
| gender | enum('Male','Female') | YES  |     | Male    |                |
+--------+-----------------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

mysql> 
mysql> DESC course;
+------------+----------------------+------+-----+---------+-------+
| Field      | Type                 | Null | Key | Default | Extra |
+------------+----------------------+------+-----+---------+-------+
| id         | tinyint(3) unsigned  | NO   | PRI | NULL    |       |
| name       | varchar(30)          | NO   |     | NULL    |       |
| teacher_id | smallint(5) unsigned | NO   |     | NULL    |       |
+------------+----------------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

mysql> 
mysql> DESC student_score;
+------------+----------------------+------+-----+---------+-------+
| Field      | Type                 | Null | Key | Default | Extra |
+------------+----------------------+------+-----+---------+-------+
| student_id | int(11)              | NO   |     | NULL    |       |
| course_id  | tinyint(3) unsigned  | NO   |     | NULL    |       |
| score      | smallint(5) unsigned | NO   |     | NULL    |       |
+------------+----------------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

mysql> 

```

## 3.建表语句-仅供参考

```
mysql> CREATE DATABASE IF NOT EXISTS school DEFAULT CHARACTER SET = utf8mb4;
Query OK, 1 row affected (0.00 sec)

mysql> 
mysql> CREATE TABLE IF NOT EXISTS school.student (
    ->     id int UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT '学生编号',
    ->     name VARCHAR(30) NOT NULL COMMENT '学生姓名',
    ->     age tinyint UNSIGNED NOT NULL COMMENT '学生年龄', 
    ->     gender enum('Male','Female') DEFAULT NULL DEFAULT 'Male' COMMENT '性别'
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.01 sec)

mysql> 
mysql> CREATE TABLE IF NOT EXISTS school.teacher (
    ->     id smallint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT '教师编号',
    ->     name VARCHAR(30) NOT NULL COMMENT '教师姓名',
    ->     age tinyint UNSIGNED NOT NULL COMMENT '学生年龄', 
    ->     gender enum('Male','Female') DEFAULT NULL DEFAULT 'Male' COMMENT '性别'
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.05 sec)

mysql> 
mysql> CREATE TABLE IF NOT EXISTS school.course (
    ->     id tinyint UNSIGNED NOT NULL PRIMARY KEY COMMENT '课程编号',
    ->     name VARCHAR(30) NOT NULL COMMENT '课程名称',
    ->     teacher_id smallint UNSIGNED NOT NULL COMMENT '教师编号'
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.09 sec)

mysql> 
mysql> CREATE TABLE IF NOT EXISTS school.student_score (
    ->     student_id int NOT NULL COMMENT '学生编号',
    ->     course_id tinyint UNSIGNED NOT NULL COMMENT '课程编号',
    ->     score smallint UNSIGNED NOT NULL COMMENT '成绩'
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.01 sec)

mysql> 

```

## 4.往表中插入数据(请根据表中的数据写入相应的SQL)

```
    student表中数据:
        mysql> select * from student;
        +----+--------------+-----+--------+
        | id | name         | age | gender |
        +----+--------------+-----+--------+
        |  1 | 范冰冰       |  20 | Female |
        |  2 | 刘亦菲       |  18 | Female |
        |  3 | 唐嫣         |  21 | Female |
        |  4 | 李诗诗       |  20 | Female |
        |  5 | 杨幂         |  25 | Female |
        |  6 | 任贤齐       |  21 | Male   |
        |  7 | 刘德华       |  28 | Male   |
        |  8 | 邓超         |  30 | Male   |
        |  9 | 杨紫         |  22 | Female |
        | 10 | 郑爽         |  20 | Female |
        | 11 | 霍建华       |  25 | Male   |
        | 12 | 胡歌         |  28 | Male   |
        | 13 | 赵丽颖       |  21 | Female |
        | 14 | 迪丽热巴     |  23 | Female |
        | 15 | 郭德纲       |  35 | Male   |
        +----+--------------+-----+--------+
        15 rows in set (0.00 sec)
        
        mysql> 

    teacher表中数据:
        mysql> select * from teacher;
        +-----+-----------+-----+--------+
        | id  | name      | age | gender |
        +-----+-----------+-----+--------+
        | 201 | 蒋昌建    |  56 | Male   |
        | 202 | 涂磊      |  45 | Female |
        | 203 | 周星驰    |  59 | Female |
        +-----+-----------+-----+--------+
        3 rows in set (0.00 sec)
        
        mysql> 

    course表中数据:
        mysql> select * from course;
        +----+-----------------+------------+
        | id | name            | teacher_id |
        +----+-----------------+------------+
        |  1 | 最强大脑        |        201 |
        |  2 | 爱情保卫战      |        202 |
        |  4 | 喜剧之王        |        203 |
        |  8 | 非你莫属        |        202 |
        | 16 | 功夫            |        203 |
        +----+-----------------+------------+
        5 rows in set (0.00 sec)
        
        mysql> 

    student_score表中数据:
        mysql> select * from student_score;
        +------------+-----------+-------+
        | student_id | course_id | score |
        +------------+-----------+-------+
        |          1 |         1 |    80 |
        |          1 |        16 |    90 |
        |          1 |         4 |    85 |
        |          2 |         1 |    85 |
        |          2 |         8 |    90 |
        |          3 |         2 |    68 |
        |          3 |         4 |    95 |
        |          4 |        16 |    90 |
        |          5 |         1 |    91 |
        |          5 |         2 |    89 |
        |          6 |         1 |    72 |
        |          6 |         4 |    95 |
        |          7 |         1 |    81 |
        |          7 |        16 |    92 |
        |          8 |         1 |    90 |
        |          8 |         8 |    74 |
        |          9 |         1 |    82 |
        |          9 |         2 |    90 |
        |         10 |         4 |    97 |
        |         10 |         8 |    62 |
        |         10 |        16 |    83 |
        |         11 |         1 |    90 |
        |         11 |        16 |    89 |
        |         12 |         8 |    96 |
        |         12 |        16 |    73 |
        |         13 |         1 |   100 |
        |         14 |         2 |   100 |
        |         14 |         4 |   100 |
        |         14 |        16 |    80 |
        |         15 |         8 |    95 |
        |         15 |         1 |    90 |
        +------------+-----------+-------+
        31 rows in set (0.00 sec)
        
        mysql> 
        
```

## 5.往表中插入数据-仅供参考

```
    往student表中插入数据:
        mysql> INSERT INTO student
            ->     (id,name,age,gender)
            -> VALUES
            ->     (1,'范冰冰',20,'Female'),
            ->     (2,'刘亦菲',18,'Female'),
            ->     (3,'唐嫣',21,'Female'),
            ->     (4,'李诗诗',20,'Female'),
            ->     (5,'杨幂',25,'Female'),
            ->     (6,'任贤齐',21,'Male'),
            ->     (7,'刘德华',28,'Male'),
            ->     (8,'邓超',30,'Male'),
            ->     (9,'杨紫',22,'Female'),
            ->     (10,'郑爽',20,'Female'),
            ->     (11,'霍建华',25,'Male'),
            ->     (12,'胡歌',28,'Male'),
            ->     (13,'赵丽颖',21,'FeMale'),
            ->     (14,'迪丽热巴',23,'FeMale'),
            ->     (15,'郭德纲',35,'Male');
        Query OK, 15 rows affected (0.00 sec)
        Records: 15  Duplicates: 0  Warnings: 0
        
        mysql> 

    往teacher表中插入数据:
        mysql> INSERT INTO teacher
            ->     (id,name,age,gender)
            -> VALUES
            ->     (201,'蒋昌建',56,'Male'),
            ->     (202,'涂磊',45,'Female'),
            ->     (203,'周星驰',59,'Female');
        Query OK, 3 rows affected (0.01 sec)
        Records: 3  Duplicates: 0  Warnings: 0
        
        mysql> 


    往course表中插入数据:
        mysql> INSERT INTO course
            ->     (id,name,teacher_id)
            -> VALUES
            ->     (1,'最强大脑',201),
            ->     (2,'爱情保卫战',202),
            ->     (4,'喜剧之王',203),
            ->     (8,'非你莫属',202),
            ->     (16,'功夫',203);
        Query OK, 5 rows affected (0.01 sec)
        Records: 5  Duplicates: 0  Warnings: 0
        
        mysql> 

    往student_score表中插入数据:
        mysql> INSERT INTO student_score
            ->     (student_id,course_id,score)
            -> VALUES
            ->     (1,1,80),
            ->     (1,16,90),
            ->     (1,4,85),
            ->     (2,1,85),
            ->     (2,8,90),
            ->     (3,2,68),
            ->     (3,4,95),
            ->     (4,16,90),
            ->     (5,1,91),
            ->     (5,2,89),
            ->     (6,1,72),
            ->     (6,4,95),
            ->     (7,1,81),
            ->     (7,16,92),
            ->     (8,1,90),
            ->     (8,8,74),
            ->     (9,1,82),
            ->     (9,2,90),
            ->     (10,4,97),
            ->     (10,8,62),
            ->     (10,16,83),
            ->     (11,1,90),
            ->     (11,16,89),
            ->     (12,8,96),
            ->     (12,16,73),
            ->     (13,1,100),
            ->     (14,2,100),
            ->     (14,4,100),
            ->     (14,16,80),
            ->     (15,8,95),
            ->     (15,1,90);
        Query OK, 31 rows affected (0.01 sec)
        Records: 31  Duplicates: 0  Warnings: 0
        
        mysql> 

```

# 十二.多表查询-查询类型

## 1.笛卡尔乘积-生产环境中基本不用（尽管查询的数据不准确，但有助于我们理解内连接和外连接）

```
mysql> SHOW TABLES;
+------------------+
| Tables_in_school |
+------------------+
| course           |
| student          |
| student_score    |
| teacher          |
+------------------+
4 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM teacher;
+-----+-----------+-----+--------+
| id  | name      | age | gender |
+-----+-----------+-----+--------+
| 201 | 蒋昌建    |  56 | Male   |
| 202 | 涂磊      |  45 | Female |
| 203 | 周星驰    |  59 | Female |
+-----+-----------+-----+--------+
3 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM course;
+----+-----------------+------------+
| id | name            | teacher_id |
+----+-----------------+------------+
|  1 | 最强大脑        |        201 |
|  2 | 爱情保卫战      |        202 |
|  4 | 喜剧之王        |        203 |
|  8 | 非你莫属        |        202 |
| 16 | 功夫            |        203 |
+----+-----------------+------------+
5 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM teacher,course;
+-----+-----------+-----+--------+----+-----------------+------------+
| id  | name      | age | gender | id | name            | teacher_id |
+-----+-----------+-----+--------+----+-----------------+------------+
| 201 | 蒋昌建    |  56 | Male   |  1 | 最强大脑        |        201 |
| 202 | 涂磊      |  45 | Female |  1 | 最强大脑        |        201 |
| 203 | 周星驰    |  59 | Female |  1 | 最强大脑        |        201 |
| 201 | 蒋昌建    |  56 | Male   |  2 | 爱情保卫战      |        202 |
| 202 | 涂磊      |  45 | Female |  2 | 爱情保卫战      |        202 |
| 203 | 周星驰    |  59 | Female |  2 | 爱情保卫战      |        202 |
| 201 | 蒋昌建    |  56 | Male   |  4 | 喜剧之王        |        203 |
| 202 | 涂磊      |  45 | Female |  4 | 喜剧之王        |        203 |
| 203 | 周星驰    |  59 | Female |  4 | 喜剧之王        |        203 |
| 201 | 蒋昌建    |  56 | Male   |  8 | 非你莫属        |        202 |
| 202 | 涂磊      |  45 | Female |  8 | 非你莫属        |        202 |
| 203 | 周星驰    |  59 | Female |  8 | 非你莫属        |        202 |
| 201 | 蒋昌建    |  56 | Male   | 16 | 功夫            |        203 |
| 202 | 涂磊      |  45 | Female | 16 | 功夫            |        203 |
| 203 | 周星驰    |  59 | Female | 16 | 功夫            |        203 |
+-----+-----------+-----+--------+----+-----------------+------------+
15 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM teacher JOIN course;  # 如果使用JOIN关键字连接两个表就可以省略逗号(",")哟~
+-----+-----------+-----+--------+----+-----------------+------------+
| id  | name      | age | gender | id | name            | teacher_id |
+-----+-----------+-----+--------+----+-----------------+------------+
| 201 | 蒋昌建    |  56 | Male   |  1 | 最强大脑        |        201 |
| 202 | 涂磊      |  45 | Female |  1 | 最强大脑        |        201 |
| 203 | 周星驰    |  59 | Female |  1 | 最强大脑        |        201 |
| 201 | 蒋昌建    |  56 | Male   |  2 | 爱情保卫战      |        202 |
| 202 | 涂磊      |  45 | Female |  2 | 爱情保卫战      |        202 |
| 203 | 周星驰    |  59 | Female |  2 | 爱情保卫战      |        202 |
| 201 | 蒋昌建    |  56 | Male   |  4 | 喜剧之王        |        203 |
| 202 | 涂磊      |  45 | Female |  4 | 喜剧之王        |        203 |
| 203 | 周星驰    |  59 | Female |  4 | 喜剧之王        |        203 |
| 201 | 蒋昌建    |  56 | Male   |  8 | 非你莫属        |        202 |
| 202 | 涂磊      |  45 | Female |  8 | 非你莫属        |        202 |
| 203 | 周星驰    |  59 | Female |  8 | 非你莫属        |        202 |
| 201 | 蒋昌建    |  56 | Male   | 16 | 功夫            |        203 |
| 202 | 涂磊      |  45 | Female | 16 | 功夫            |        203 |
| 203 | 周星驰    |  59 | Female | 16 | 功夫            |        203 |
+-----+-----------+-----+--------+----+-----------------+------------+
15 rows in set (0.00 sec)

mysql> 

```

## 2.内连接(可以理解是两张表之间的交集)-生产环境中应用最广泛

### 查看每个老师都有哪些课程

```
mysql> SELECT * FROM course;
+----+-----------------+------------+
| id | name            | teacher_id |
+----+-----------------+------------+
|  1 | 最强大脑        |        201 |
|  2 | 爱情保卫战      |        202 |
|  4 | 喜剧之王        |        203 |
|  8 | 非你莫属        |        202 |
| 16 | 功夫            |        203 |
+----+-----------------+------------+
5 rows in set (0.00 sec)

mysql> SELECT * FROM teacher;
+-----+-----------+-----+--------+
| id  | name      | age | gender |
+-----+-----------+-----+--------+
| 201 | 蒋昌建    |  56 | Male   |
| 202 | 涂磊      |  45 | Female |
| 203 | 周星驰    |  59 | Female |
+-----+-----------+-----+--------+
3 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM teacher JOIN course ON teacher.id=course.teacher_id;
+-----+-----------+-----+--------+----+-----------------+------------+
| id  | name      | age | gender | id | name            | teacher_id |
+-----+-----------+-----+--------+----+-----------------+------------+
| 201 | 蒋昌建    |  56 | Male   |  1 | 最强大脑        |        201 |
| 202 | 涂磊      |  45 | Female |  2 | 爱情保卫战      |        202 |
| 203 | 周星驰    |  59 | Female |  4 | 喜剧之王        |        203 |
| 202 | 涂磊      |  45 | Female |  8 | 非你莫属        |        202 |
| 203 | 周星驰    |  59 | Female | 16 | 功夫            |        203 |
+-----+-----------+-----+--------+----+-----------------+------------+
5 rows in set (0.00 sec)

mysql> 

```

### 测试案例基于mysql官方提供的world数据库-使用内连接查询人口数少于100的城市的国家.

``` 
mysql> USE world;
Database changed
mysql> 
mysql> SHOW TABLES;
+-----------------+
| Tables_in_world |
+-----------------+
| city            |
| country         |
| countrylanguage |
+-----------------+
3 rows in set (0.01 sec)

mysql> 
mysql> DESC city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   |     |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   |     | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> 
mysql> DESC country;
+----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+
| Field          | Type                                                                                  | Null | Key | Default | Extra |
+----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+
| Code           | char(3)                                                                               | NO   | PRI |         |       |
| Name           | char(52)                                                                              | NO   |     |         |       |
| Continent      | enum('Asia','Europe','North America','Africa','Oceania','Antarctica','South America') | NO   |     | Asia    |       |
| Region         | char(26)                                                                              | NO   |     |         |       |
| SurfaceArea    | decimal(10,2)                                                                         | NO   |     | 0.00    |       |
| IndepYear      | smallint(6)                                                                           | YES  |     | NULL    |       |
| Population     | int(11)                                                                               | NO   |     | 0       |       |
| LifeExpectancy | decimal(3,1)                                                                          | YES  |     | NULL    |       |
| GNP            | decimal(10,2)                                                                         | YES  |     | NULL    |       |
| GNPOld         | decimal(10,2)                                                                         | YES  |     | NULL    |       |
| LocalName      | char(45)                                                                              | NO   |     |         |       |
| GovernmentForm | char(45)                                                                              | NO   |     |         |       |
| HeadOfState    | char(60)                                                                              | YES  |     | NULL    |       |
| Capital        | int(11)                                                                               | YES  |     | NULL    |       |
| Code2          | char(2)                                                                               | NO   |     |         |       |
+----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+
15 rows in set (0.00 sec)

mysql> 
mysql> SELECT city.name AS '城市',country.name AS '国家',city.Population AS '人口' FROM city JOIN country ON city.countrycode=country.code WHERE city.Population < 100;
+-----------+----------+--------+
| 城市      | 国家     | 人口   |
+-----------+----------+--------+
| Adamstown | Pitcairn |     42 |
+-----------+----------+--------+
1 row in set (0.00 sec)

mysql> 


```

## 3.外连接(可以理解是两者表的差集)-由于我们的测试数据并没有设计好,因此还是以上面world数据库的测试数据为例.

```
LEFT JOIN:
    左表所有数据,右表满足条件的数据.

RIGHT JOIN:
    右表素有数据,左表满足条件的数据.

```

## 4.左外连接-可以理解是两者表的左边圆的差集

```
SELECT 
    city.name AS '城市',country.name AS '国家',city.Population AS '人口' 
FROM 
    city 
LEFT JOIN 
    country 
ON 
    city.countrycode=country.code 
AND 
    city.Population < 100 
ORDER BY 
    city.Population 
DESC;
```

## 5.右外连接--可以理解是两者表的右边圆的差集

```
SELECT 
    city.name AS '城市',country.name AS '国家',city.Population AS '人口' 
FROM 
    city 
RIGHT JOIN 
    country 
ON 
    city.countrycode=country.code 
AND 
    city.Population < 100;
```



# 十三.多表查询(基于自定义表)-内连接查询案例

## 1.统计学员"范冰冰"学习了几门课程

```
    (1)找关联表
        student:
            学生编号(student.id)
            学生姓名(student.name)
        student_score:
            学生所学的课程数量(COUNT(student_score.student_id))
        综上所述，我们就找到了关联表，即"FROM student JOIN student_score"

    (2)找关联条件
        student:
            学生编号(student.id)
        student_score:
            学生编号(student_score.student_id)
        综上所述，我们找到了关联条件，可以得到"FROM student JOIN student_score ON student.id = student_score.student_id"

    (3)罗列其他查询条件
        1)查询的字段信息:
            SELECT student.id AS '学生编号',student.name AS '学生姓名', COUNT(student_score.student_id) AS '学生所学的课程数量'
        2)要过滤的学生姓名:
            WHERE student.name = '范冰冰'

    经过上述的分析，想必你很容易就能理解下面的SQL语句啦:
        mysql> SELECT
            ->     student.id AS '学生编号',student.name AS '学生姓名', COUNT(student_score.student_id) AS '学生所学的课程数量'
            -> FROM
            ->     student JOIN student_score ON student.id = student_score.student_id
            -> WHERE
            ->     student.name = '范冰冰'
            -> GROUP BY
            ->     student.id,student.name;
        +--------------+--------------+-----------------------------+
        | 学生编号     | 学生姓名     | 学生所学的课程数量          |
        +--------------+--------------+-----------------------------+
        |            1 | 范冰冰       |                           3 |
        +--------------+--------------+-----------------------------+
        1 row in set (0.00 sec)
        
        mysql> 

温馨提示:
    为了防止学生重名，因此我们可以使用两个字段来进行分组(即"student.id"和"student.name")，这样就算重名了，其学生编号是不可能重名的，因为我们建表是指定学生编号为主键。
 
```

## 2.统计学员"胡歌"学习的所有课程名称

```
    (1)找关联表
        student:
            学生姓名(student.name)
        course:
            课程编号(course.id)
            课程名称(course.name)
        student_score:
            学生编号(student_score.student_id)
        综上所述，我们就找到了关联表，即"FROM student JOIN student_score ON ... JOIN course ON ..."

    (2)找关联条件
        student:
            学生编号(student.id)
        student_score:
            学生编号(student_score.student_id)
            课程编号(student_score.course_id)
        course:
            课程编号(course.id)
        综上所述，我们找到了关联条件，可以得到"FROM student JOIN student_score ON student.id=student_score.student_id JOIN course ON student_score.course_id=course.id"

    (3)罗列其他查询条件
        1)查询的字段信息:
            SELECT student.id AS '学生编号',student.name AS '学生姓名', course.name AS '课程名称'
        2)要过滤的学生姓名:
            WHERE student.name = '胡歌'

    经过上述的分析，想必你很容易就能理解下面的SQL语句啦:
        mysql> SELECT
            ->     student.id AS '学生编号',student.name AS '学生姓名', GROUP_CONCAT(course.name) AS '课程名称'
            -> FROM
            ->     student JOIN student_score ON student.id=student_score.student_id JOIN course ON student_score.course_id=course.id
            -> WHERE
            ->     student.name = '胡歌'
            -> GROUP BY
            ->     student.id,student.name;
        +--------------+--------------+---------------------+
        | 学生编号     | 学生姓名     | 课程名称            |
        +--------------+--------------+---------------------+
        |           12 | 胡歌         | 功夫,非你莫属       |
        +--------------+--------------+---------------------+
        1 row in set (0.01 sec)
        
        mysql> 

温馨提示:
    GROUP_CONCAT(course.name)是将"course.name"列转成行,否则会引发SQL_MODE异常哟.

```

## 3.查询周星驰老师教的学生姓名

```
mysql> SELECT 
    ->     CONCAT(teacher.name,"_",teacher.id, "_", course.id) AS 教师, GROUP_CONCAT(student.name) AS 学生
    -> FROM
    ->     teacher 
    -> JOIN 
    ->     course ON teacher.id=course.teacher_id
    -> JOIN
    ->     student_score ON student_score.course_id=course.id
    -> JOIN
    ->     student ON student.id=student_score.student_id
    -> WHERE
    ->     teacher.name='周星驰'
    -> GROUP BY
    ->     teacher.id,teacher.name,course.id;
+------------------+--------------------------------------------------------------------+
| 教师             | 学生                                                               |
+------------------+--------------------------------------------------------------------+
| 周星驰_203_4     | 唐嫣,迪丽热巴,任贤齐,范冰冰,郑爽                                   |
| 周星驰_203_16    | 范冰冰,霍建华,刘德华,郑爽,胡歌,李诗诗,迪丽热巴                     |
+------------------+--------------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> 

温馨提示:
    基于"teacher.id","teacher.name"和"course.id"三个字段来进行分组的目的是避免有重复的教师姓名以及一个老师可以教学多门课程。

```

## 4.查询周星驰所教课程的平均分数

```
mysql> SELECT 
    ->     CONCAT(teacher.name, "@", teacher.id, "_", course.name, "@", course.id) AS 教师, AVG(student_score.score) AS 学生的平均成绩
    -> FROM
    ->     teacher 
    -> JOIN 
    ->     course ON teacher.id=course.teacher_id
    -> JOIN
    ->     student_score ON student_score.course_id=course.id
    -> JOIN
    ->     student ON student.id=student_score.student_id
    -> WHERE
    ->     teacher.name='周星驰'
    -> GROUP BY
    ->     teacher.id,teacher.name,course.id;
+------------------------------+-----------------------+
| 教师                         | 学生的平均成绩        |
+------------------------------+-----------------------+
| 周星驰@203_喜剧之王@4        |               94.4000 |
| 周星驰@203_功夫@16           |               85.2857 |
+------------------------------+-----------------------+
2 rows in set (0.00 sec)

mysql> 

温馨提示:
    基于"teacher.id","teacher.name"和"course.id"三个字段来进行分组的目的是避免有重复的教师姓名以及一个老师可以教学多门课程。

```

## 5.每位老师所教课程的平均分,并按平均分降序排序

```
mysql> SELECT 
    ->     CONCAT(teacher.name, "@", teacher.id, "_", course.name, "@", course.id) AS 教师, AVG(student_score.score) AS 学生的平均成绩
    -> FROM
    ->     teacher 
    -> JOIN 
    ->     course ON teacher.id=course.teacher_id
    -> JOIN
    ->     student_score ON student_score.course_id=course.id
    -> JOIN
    ->     student ON student.id=student_score.student_id
    -> GROUP BY
    ->     teacher.id,teacher.name,course.id
    -> ORDER BY
    ->     学生的平均成绩 DESC;
+------------------------------+-----------------------+
| 教师                         | 学生的平均成绩        |
+------------------------------+-----------------------+
| 周星驰@203_喜剧之王@4        |               94.4000 |
| 涂磊@202_爱情保卫战@2        |               86.7500 |
| 蒋昌建@201_最强大脑@1        |               86.1000 |
| 周星驰@203_功夫@16           |               85.2857 |
| 涂磊@202_非你莫属@8          |               83.4000 |
+------------------------------+-----------------------+
5 rows in set (0.00 sec)

mysql> 

温馨提示:
    基于"teacher.id","teacher.name"和"course.id"三个字段来进行分组的目的是避免有重复的教师姓名以及一个老师可以教学多门课程。

```

## 6.查询周星驰所教的不及格(分数大于等于85分为及格)的学生姓名

```
mysql> SELECT 
    ->     CONCAT(teacher.name, "@", teacher.id, "_", course.name, "@", course.id) AS 教师, GROUP_CONCAT(student.name) AS 学生
    -> FROM
    ->     teacher 
    -> JOIN 
    ->     course ON teacher.id=course.teacher_id
    -> JOIN
    ->     student_score ON student_score.course_id=course.id
    -> JOIN
    ->     student ON student.id=student_score.student_id
    -> WHERE
    ->     teacher.name='周星驰' AND student_score.score < 85
    -> GROUP BY
    ->     teacher.id,teacher.name,course.id;
+-------------------------+----------------------------+
| 教师                    | 学生                       |
+-------------------------+----------------------------+
| 周星驰@203_功夫@16      | 郑爽,胡歌,迪丽热巴         |
+-------------------------+----------------------------+
1 row in set (0.00 sec)

mysql> 

温馨提示:
    基于"teacher.id","teacher.name"和"course.id"三个字段来进行分组的目的是避免有重复的教师姓名以及一个老师可以教学多门课程。

```

## 7.查询所有老师所教学生不及格(分数大于等于85分为及格)的学生姓名

```
mysql> SELECT 
    ->     CONCAT(teacher.name, "@", teacher.id, "_", course.name, "@", course.id) AS 教师, GROUP_CONCAT(student.name) AS 学生
    -> FROM
    ->     teacher 
    -> JOIN 
    ->     course ON teacher.id=course.teacher_id
    -> JOIN
    ->     student_score ON student_score.course_id=course.id
    -> JOIN
    ->     student ON student.id=student_score.student_id
    -> WHERE
    ->     student_score.score < 85
    -> GROUP BY
    ->     teacher.id,teacher.name,course.id;
+------------------------------+--------------------------------------+
| 教师                         | 学生                                 |
+------------------------------+--------------------------------------+
| 蒋昌建@201_最强大脑@1        | 范冰冰,任贤齐,刘德华,杨紫            |
| 涂磊@202_爱情保卫战@2        | 唐嫣                                 |
| 涂磊@202_非你莫属@8          | 邓超,郑爽                            |
| 周星驰@203_功夫@16           | 郑爽,胡歌,迪丽热巴                   |
+------------------------------+--------------------------------------+
4 rows in set (0.00 sec)

mysql> 

温馨提示:
    基于"teacher.id","teacher.name"和"course.id"三个字段来进行分组的目的是避免有重复的教师姓名以及一个老师可以教学多门课程。

```

## 8.查询平均成绩大于90分的同学的姓名，学号和平均成绩

```
mysql> SELECT 
    ->     student.name AS 姓名, student_score.student_id AS 学号, AVG(student_score.score) AS 平均分
    -> FROM
    ->     student_score
    -> JOIN
    ->     student ON student.id=student_score.student_id
    -> GROUP BY
    ->     student_score.student_id
    -> HAVING
    ->     平均分 > 90;
+--------------+--------+-----------+
| 姓名         | 学号   | 平均分    |
+--------------+--------+-----------+
| 赵丽颖       |     13 |  100.0000 |
| 迪丽热巴     |     14 |   93.3333 |
| 郭德纲       |     15 |   92.5000 |
+--------------+--------+-----------+
3 rows in set (0.00 sec)

mysql> 

```

## 9.查询所有同学的学号、姓名、选课数、总成绩

```
mysql> SELECT 
    ->     student.id AS 学号, student.name AS 姓名, COUNT(student_score.course_id) AS 选课数量, SUM(student_score.score) AS 总成绩
    -> FROM
    ->     student 
    -> JOIN 
    ->     student_score ON student_score.student_id=student.id
    -> GROUP BY
    ->     学号,姓名;
+--------+--------------+--------------+-----------+
| 学号   | 姓名         | 选课数量     | 总成绩    |
+--------+--------------+--------------+-----------+
|      1 | 范冰冰       |            3 |       255 |
|      2 | 刘亦菲       |            2 |       175 |
|      3 | 唐嫣         |            2 |       163 |
|      4 | 李诗诗       |            1 |        90 |
|      5 | 杨幂         |            2 |       180 |
|      6 | 任贤齐       |            2 |       167 |
|      7 | 刘德华       |            2 |       173 |
|      8 | 邓超         |            2 |       164 |
|      9 | 杨紫         |            2 |       172 |
|     10 | 郑爽         |            3 |       242 |
|     11 | 霍建华       |            2 |       179 |
|     12 | 胡歌         |            2 |       169 |
|     13 | 赵丽颖       |            1 |       100 |
|     14 | 迪丽热巴     |            3 |       280 |
|     15 | 郭德纲       |            2 |       185 |
+--------+--------------+--------------+-----------+
15 rows in set (0.00 sec)

mysql> 


温馨提示:
    基于"student.id"和"student.name"两个字段来进行分组的目的是避免有重复的学生姓名。

```

## 10.查询各科成绩最高和最低的分：以如下形式显示：课程名称，课程ID，最高分，最低分

```
mysql> SELECT 
    ->     course.name AS 课程名称, student_score.course_id AS 课程ID, MAX(student_score.score) AS 最高分, MIN(student_score.score) AS 最低分
    -> FROM
    ->     student_score 
    -> JOIN 
    ->     course ON student_score.course_id=course.id
    -> GROUP BY
    ->     课程ID;
+-----------------+----------+-----------+-----------+
| 课程名称        | 课程ID   | 最高分    | 最低分    |
+-----------------+----------+-----------+-----------+
| 最强大脑        |        1 |       100 |        72 |
| 爱情保卫战      |        2 |       100 |        68 |
| 喜剧之王        |        4 |       100 |        85 |
| 非你莫属        |        8 |        96 |        62 |
| 功夫            |       16 |        92 |        73 |
+-----------------+----------+-----------+-----------+
5 rows in set (0.01 sec)

mysql> 

```

## 11.统计各位老师,所教课程的及格率(分数大于等于85分为及格)

```
mysql> SELECT 
    ->     CONCAT(teacher.name, "@", teacher.id) AS 教师, CONCAT(COUNT(CASE WHEN student_score.score > 85 THEN 1 END)/COUNT(student_score.student_id) * 100,"%") AS 及格率
    -> FROM
    ->     teacher 
    -> JOIN 
    ->     course ON teacher.id=course.teacher_id
    -> JOIN
    ->     student_score ON student_score.course_id=course.id
    -> GROUP BY
    ->     teacher.id,teacher.name;
+---------------+-----------+
| 教师          | 及格率    |
+---------------+-----------+
| 蒋昌建@201    | 50.0000%  |
| 涂磊@202      | 66.6667%  |
| 周星驰@203    | 66.6667%  |
+---------------+-----------+
3 rows in set (0.00 sec)

mysql> 

温馨提示:
    MySQL也支持简单的分支判断语句，如下所示，具体案例可参考上面的案例。
        CASE WHEN
            判断条件
        THEN 
            条件成立则需要执行的代码 
        END

```

## 12.统计每门课程:优秀(95分以上),良好(90-95),一般(85-90),不及格(小于80)的学生列表

```
    基于CASE语句实现，案例如下:(推荐使用，想比下面的多条WHERE语句实现性能更好，避免了多次查询!)
        mysql> SELECT 
            ->     course.name AS 课程名称, 
            ->     GROUP_CONCAT(CASE WHEN student_score.score > 95 THEN student.name END) AS 优秀,
            ->     GROUP_CONCAT(CASE WHEN student_score.score > 90 AND student_score.score < 95 THEN student.name END) AS 良好,
            ->     GROUP_CONCAT(CASE WHEN student_score.score > 85 AND student_score.score < 90 THEN student.name END) AS 一般,
            ->     GROUP_CONCAT(CASE WHEN student_score.score < 85 THEN student.name END) AS 不及格
            -> FROM
            ->     course 
            -> JOIN
            ->     student_score ON student_score.course_id=course.id
            -> JOIN
            ->     student ON student_score.student_id=student.id
            -> GROUP BY
            ->     course.name;
        +-----------------+---------------------+-----------+-----------+--------------------------------------+
        | 课程名称        | 优秀                | 良好      | 一般      | 不及格                               |
        +-----------------+---------------------+-----------+-----------+--------------------------------------+
        | 功夫            | NULL                | 刘德华    | 霍建华    | 郑爽,迪丽热巴,胡歌                   |
        | 喜剧之王        | 迪丽热巴,郑爽       | NULL      | NULL      | NULL                                 |
        | 最强大脑        | 赵丽颖              | 杨幂      | NULL      | 刘德华,任贤齐,范冰冰,杨紫            |
        | 爱情保卫战      | 迪丽热巴            | NULL      | 杨幂      | 唐嫣                                 |
        | 非你莫属        | 胡歌                | NULL      | NULL      | 郑爽,邓超                            |
        +-----------------+---------------------+-----------+-----------+--------------------------------------+
        5 rows in set (0.00 sec)
        
        mysql> 

    基于多条WHERE语句实现如下:
        mysql> SELECT 
            ->     course.name AS 课程名称,  GROUP_CONCAT(student.name) AS 优秀
            -> FROM
            ->     course 
            -> JOIN
            ->     student_score ON student_score.course_id=course.id
            -> JOIN
            ->     student ON student_score.student_id=student.id
            -> WHERE
            ->     student_score.score > 95
            -> GROUP BY
            ->     course.name;
        +-----------------+---------------------+
        | 课程名称        | 优秀                |
        +-----------------+---------------------+
        | 喜剧之王        | 迪丽热巴,郑爽       |
        | 最强大脑        | 赵丽颖              |
        | 爱情保卫战      | 迪丽热巴            |
        | 非你莫属        | 胡歌                |
        +-----------------+---------------------+
        4 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT 
            ->     course.name AS 课程名称,  GROUP_CONCAT(student.name) AS 良好
            -> FROM
            ->     course 
            -> JOIN
            ->     student_score ON student_score.course_id=course.id
            -> JOIN
            ->     student ON student_score.student_id=student.id
            -> WHERE
            ->     student_score.score > 90 AND student_score.score < 95
            -> GROUP BY
            ->     course.name;
        +--------------+-----------+
        | 课程名称     | 良好      |
        +--------------+-----------+
        | 功夫         | 刘德华    |
        | 最强大脑     | 杨幂      |
        +--------------+-----------+
        2 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT 
            ->     course.name AS 课程名称,  GROUP_CONCAT(student.name) AS 一般
            -> FROM
            ->     course 
            -> JOIN
            ->     student_score ON student_score.course_id=course.id
            -> JOIN
            ->     student ON student_score.student_id=student.id
            -> WHERE
            ->     student_score.score > 85 AND student_score.score < 90
            -> GROUP BY
            ->     course.name;
        +-----------------+-----------+
        | 课程名称        | 一般      |
        +-----------------+-----------+
        | 功夫            | 霍建华    |
        | 爱情保卫战      | 杨幂      |
        +-----------------+-----------+
        2 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT 
            ->     course.name AS 课程名称,  GROUP_CONCAT(student.name) AS 不及格
            -> FROM
            ->     course 
            -> JOIN
            ->     student_score ON student_score.course_id=course.id
            -> JOIN
            ->     student ON student_score.student_id=student.id
            -> WHERE
            ->     student_score.score < 85
            -> GROUP BY
            ->     course.name;
        +-----------------+--------------------------------------+
        | 课程名称        | 不及格                               |
        +-----------------+--------------------------------------+
        | 功夫            | 迪丽热巴,胡歌,郑爽                   |
        | 最强大脑        | 杨紫,刘德华,任贤齐,范冰冰            |
        | 爱情保卫战      | 唐嫣                                 |
        | 非你莫属        | 郑爽,邓超                            |
        +-----------------+--------------------------------------+
        4 rows in set (0.00 sec)
        
        mysql> 

```

## 13.其它综合练习

```
    (1)查询每门课程被选修的学生数
    (2)查询出只选修了一门课程的全部学生的学号和姓名
    (3)查询选修课程门数超过1门的学生信息
    (4)查询平均成绩大于85的所有学生的学号、姓名和平均成绩 

mysql> DESC student;
+--------+-----------------------+------+-----+---------+----------------+
| Field  | Type                  | Null | Key | Default | Extra          |
+--------+-----------------------+------+-----+---------+----------------+
| id     | int(11)               | NO   | PRI | NULL    | auto_increment |
| name   | varchar(30)           | NO   |     | NULL    |                |
| age    | tinyint(3) unsigned   | NO   |     | NULL    |                |
| gender | enum('Male','Female') | YES  |     | Male    |                |
+--------+-----------------------+------+-----+---------+----------------+
4 rows in set (0.00 sec)

mysql> 
mysql> DESC course;
+------------+----------------------+------+-----+---------+-------+
| Field      | Type                 | Null | Key | Default | Extra |
+------------+----------------------+------+-----+---------+-------+
| id         | tinyint(3) unsigned  | NO   | PRI | NULL    |       |
| name       | varchar(30)          | NO   |     | NULL    |       |
| teacher_id | smallint(5) unsigned | NO   |     | NULL    |       |
+------------+----------------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

mysql> 
mysql> DESC student_score;
+------------+----------------------+------+-----+---------+-------+
| Field      | Type                 | Null | Key | Default | Extra |
+------------+----------------------+------+-----+---------+-------+
| student_id | int(11)              | NO   |     | NULL    |       |
| course_id  | tinyint(3) unsigned  | NO   |     | NULL    |       |
| score      | smallint(5) unsigned | NO   |     | NULL    |       |
+------------+----------------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

mysql> 

```



# 十四.多表查询(基于MySQL官方提供的测试数据)-内连接查询案例

## 1.查询一下"Shanghai"这个城市的国建，城市名称，城市人口数和该城市的所在国家的国土面积。

```
    (1)找关联表
        city:
            城市名(city.Name)
            城市人口数(city.Population)
        country:
            国家名称(country.Name)
            国土面积(country.SurfaceArea)
        综上所述，我们就找到了关联表，即"FROM city JOIN country"

    (2)找关联条件
        city:
            国家代码(city.CountryCode)
        country:
            国家代码(country.Code)
        综上所述，我们找到了关联条件，可以得到"FROM city JOIN country ON city.CountryCode = country.Code"

    (3)罗列其他查询条件
        1)查询的字段信息:
            SELECT city.Name AS '城市名称', city.Population AS '人口数量', country.Name AS '国家名称', country.SurfaceArea AS '国家面积'
        2)要过滤的城市名称:
            WHERE city.Name = 'shanghai'

    经过上述的分析，想必你很容易就能理解下面的SQL语句啦:
        mysql> SELECT
            ->     city.Name AS '城市名称', city.Population AS '人口数量', country.Name AS '国家名称', country.SurfaceArea AS '国家面积'
            -> FROM
            ->     city JOIN country ON city.CountryCode = country.Code
            -> WHERE
            ->     city.Name = 'shanghai';
        +--------------+--------------+--------------+--------------+
        | 城市名称     | 人口数量     | 国家名称     | 国家面积     |
        +--------------+--------------+--------------+--------------+
        | Shanghai     |      9696300 | China        |   9572900.00 |
        +--------------+--------------+--------------+--------------+
        1 row in set (0.00 sec)
        
        mysql> 
        

```



# 十五.多表查询(基于MySQL官方提供的测试数据)-外连接查询案例

## 1.外连接查询的作用就是强制指定"驱动表"

```
    我们来看下面的语法一句SQL,这是一个左外连接的查询语句,请思考MySQL底层是如何实现的呢?
        mysql> SELECT
            ->     city.Name AS '城市名称', city.Population AS '人口数量', country.Name AS '国家名称', country.SurfaceArea AS '国家面积'
            -> FROM
            ->     city LEFT JOIN country ON city.CountryCode = country.Code;

    多表连接查询的底层实现的基本逻辑如下所示:
        拿第一张表(对应上面的city表)的每一行数据和第二张表(对应上面的country表)的所有行数据进行对比,将符合"city.CountryCode = country.Code"条件行拿出来单独放在一张临时表中,我们可以对这临时生成的表进行操作.
        综上所述,想必很多伙伴立马就反应过来了,说这不就是一个嵌套for循环就能实现了么,其实就是这样,只不过官方称为"next loop",而且将外层循环的表称为"驱动表"(对应上面的city表).

    温馨提示:
        (1)对于外连接来讲，推荐将结果集小的表设置为驱动表更加合适(也就是放在靠前的位置，即两张表关联查询的话第一张表的位置就是驱动表),可以降低next loop的次数。换句话说，这样可以降低外层循环的次数。

        (2)对于内连接来讲，我们是没法控制驱动表是谁，完全MySQL内置的由优化器自行决定。但如果你真的确定需要人为干预，需要将内连接写成外连接的方式(如下所示，将JOIN改写为LEFT JOIN就可以强制让左边的表为驱动表)。
            mysql> SELECT
                ->     city.Name AS '城市名称', city.Population AS '人口数量', country.Name AS '国家名称', country.SurfaceArea AS '国家面积'
                -> FROM
                ->     city  JOIN country ON city.CountryCode = country.Code  # 注意哈，这里的JOIN语句是内连接
                -> WHERE
                ->     city.Name = 'Shanghai';
            +--------------+--------------+--------------+--------------+
            | 城市名称     | 人口数量     | 国家名称     | 国家面积     |
            +--------------+--------------+--------------+--------------+
            | Shanghai     |      9696300 | China        |   9572900.00 |
            +--------------+--------------+--------------+--------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> SELECT
                ->     city.Name AS '城市名称', city.Population AS '人口数量', country.Name AS '国家名称', country.SurfaceArea AS '国家面积'
                -> FROM
                ->     city LEFT JOIN country ON city.CountryCode = country.Code  # 注意哈，这里的LEFT JOIN是强制让左边的表为"驱动表"。
                -> WHERE
                ->     city.Name = 'Shanghai';
            +--------------+--------------+--------------+--------------+
            | 城市名称     | 人口数量     | 国家名称     | 国家面积     |
            +--------------+--------------+--------------+--------------+
            | Shanghai     |      9696300 | China        |   9572900.00 |
            +--------------+--------------+--------------+--------------+
            1 row in set (0.01 sec)
            
            mysql> 
        (3)同理，我们可以将JOIN 改写为RIGHT JOIN就可以强制让右边的表为驱动表。
            mysql> SELECT
                ->     city.Name AS '城市名称', city.Population AS '人口数量', country.Name AS '国家名称', country.SurfaceArea AS '国家面积'
                -> FROM
                ->     city RIGHT JOIN country ON city.CountryCode = country.Code  # 注意哈，这里的RIGHT JOIN是强制让左边的表为"驱动表"。
                -> WHERE 
                ->     city.Name = 'Shanghai';
            +--------------+--------------+--------------+--------------+
            | 城市名称     | 人口数量     | 国家名称     | 国家面积     |
            +--------------+--------------+--------------+--------------+
            | Shanghai     |      9696300 | China        |   9572900.00 |
            +--------------+--------------+--------------+--------------+
            1 row in set (0.00 sec)
            
            mysql> 

        综上所述，我们得出一个结论: "外连接查询的作用就是强制指定驱动表"。
```

## 2.针对不同的场景，选择较小的表作为"驱动表"。

```
    (1)建议选择选择较小的contry表作为"驱动表":
        mysql> SELECT COUNT(*) FROM country;  # 注意观察country和city表的数据大小，选择合适的驱动表。
        +----------+
        | COUNT(*) |
        +----------+
        |      239 |
        +----------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT COUNT(*) FROM city;  # 注意哈，city表的行数比country的行数要多得多，因此我们通常不会将其设置为驱动表。
        +----------+
        | COUNT(*) |
        +----------+
        |     4079 |
        +----------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT
            ->     city.Name AS '城市名称', city.Population AS '人口数量', country.Name AS '国家名称', country.SurfaceArea AS '国家面积'
            -> FROM
            ->     country LEFT JOIN city ON country.Code=city.CountryCode
            -> LIMIT 10;
        +----------------+--------------+--------------+--------------+
        | 城市名称       | 人口数量     | 国家名称     | 国家面积     |
        +----------------+--------------+--------------+--------------+
        | Oranjestad     |        29034 | Aruba        |       193.00 |
        | Kabul          |      1780000 | Afghanistan  |    652090.00 |
        | Qandahar       |       237500 | Afghanistan  |    652090.00 |
        | Herat          |       186800 | Afghanistan  |    652090.00 |
        | Mazar-e-Sharif |       127800 | Afghanistan  |    652090.00 |
        | Luanda         |      2022000 | Angola       |   1246700.00 |
        | Huambo         |       163100 | Angola       |   1246700.00 |
        | Lobito         |       130000 | Angola       |   1246700.00 |
        | Benguela       |       128300 | Angola       |   1246700.00 |
        | Namibe         |       118200 | Angola       |   1246700.00 |
        +----------------+--------------+--------------+--------------+
        10 rows in set (0.00 sec)
        
        mysql> 

    (2)由于WHERE子句的存在，将city表的数据做了过滤，此时建议选择选择较小的city表作为"驱动表":
        mysql> SELECT COUNT(*) FROM country;
        +----------+
        | COUNT(*) |
        +----------+
        |      239 |
        +----------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT COUNT(*) FROM city WHERE city.name='Shanghai';  # 被WHERE过滤后，只有一行数据
        +----------+
        | COUNT(*) |
        +----------+
        |        1 |
        +----------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT
            ->     city.Name AS '城市名称', city.Population AS '人口数量', country.Name AS '国家名称', country.SurfaceArea AS '国家面积'
            -> FROM
            ->     city LEFT JOIN country ON city.CountryCode=country.Code
            -> WHERE 
            ->     city.name='Shanghai';
        +--------------+--------------+--------------+--------------+
        | 城市名称     | 人口数量     | 国家名称     | 国家面积     |
        +--------------+--------------+--------------+--------------+
        | Shanghai     |      9696300 | China        |   9572900.00 |
        +--------------+--------------+--------------+--------------+
        1 row in set (0.00 sec)
        
        mysql> 

```

# 十六.SELECT的别名应用

## 1.列别名应用案例

```
    列别名作用:
        可以定制显示的别名，可以在"HAVING ..."或者"ORDER BY ..."子句中调用，但不能在WHERE子句中调用哟~这是由于SQL执行顺序WHERE子句在SELECT子句之前执行的。

    参考案例:
        mysql> SELECT
            ->     District,SUM(Population)
            -> FROM
            ->     city
            -> WHERE
            ->     CountryCode='CHN'
            -> GROUP BY
            ->     District
            -> HAVING
            ->     SUM(Population) > 8000000
            -> ORDER BY
            ->     SUM(Population) DESC
            -> LIMIT
            ->     5 OFFSET 0;
        +--------------+-----------------+
        | District     | SUM(Population) |
        +--------------+-----------------+
        | Liaoning     |        15079174 |
        | Shandong     |        12114416 |
        | Heilongjiang |        11628057 |
        | Jiangsu      |         9719860 |
        | Shanghai     |         9696300 |
        +--------------+-----------------+
        5 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT
            ->     District AS 省, SUM(Population) AS 总人数
            -> FROM
            ->     city
            -> WHERE
            ->     CountryCode='CHN'
            -> GROUP BY
            ->     District  # 注意哈,在GROUP BY 子句中不能使用AS别名"省",这是因为GROUP BY子句在SELECT之前执行!
            -> HAVING
            ->     总人数 > 8000000
            -> ORDER BY
            ->     总人数 DESC
            -> LIMIT
            ->     5 OFFSET 0;
        +--------------+-----------+
        | 省           | 总人数    |
        +--------------+-----------+
        | Liaoning     |  15079174 |
        | Shandong     |  12114416 |
        | Heilongjiang |  11628057 |
        | Jiangsu      |   9719860 |
        | Shanghai     |   9696300 |
        +--------------+-----------+
        5 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT
            ->     District AS '省', SUM(Population) AS '总人数'  # 注意哈,千万别画蛇添足,在AS后面的变量不要使用单引号(')引起来,因为这样可能导致查询不到数据哟~
            -> FROM
            ->     city
            -> WHERE
            ->     CountryCode='CHN'
            -> GROUP BY
            ->     District
            -> HAVING
            ->     '总人数' > 8000000
            -> ORDER BY
            ->     '总人数' DESC
            -> LIMIT
            ->     5 OFFSET 0;
        Empty set, 1 warning (0.00 sec)
        
        mysql> 
        
```

## 2.表别名应用案例

```
    表别名作用:
        全局调用定义的别名，这是因为给表起别名是在FROM子句中定义的，从SQL的执行顺序你也知道，FROM子句是最先执行的，因此在其后的所有子句均可以访问到哟~

    参考案例:
        mysql> SELECT
            ->     student.id AS '学生编号',student.name AS '学生姓名', GROUP_CONCAT(course.name) AS '课程名称'
            -> FROM
            ->     student JOIN student_score ON student.id=student_score.student_id JOIN course ON student_score.course_id=course.id
            -> WHERE
            ->     student.name = '胡歌'
            -> GROUP BY
            ->     student.id,student.name;
        +--------------+--------------+---------------------+
        | 学生编号     | 学生姓名     | 课程名称            |
        +--------------+--------------+---------------------+
        |           12 | 胡歌         | 功夫,非你莫属       |
        +--------------+--------------+---------------------+
        1 row in set (0.01 sec)
        
        mysql> 
        mysql> SELECT
            ->     x.id AS '学生编号',x.name AS '学生姓名', GROUP_CONCAT(z.name) AS '课程名称'
            -> FROM
            ->     student AS x JOIN student_score AS y ON x.id=y.student_id JOIN course z ON y.course_id=z.id  # 注意SQL的执行顺序: 我们给表起的别名实在WHERE之前就操作了,因此在其它子句中均可以使用哟~
            -> WHERE
            ->     x.name = '胡歌'
            -> GROUP BY
            ->     x.id,x.name;
        +--------------+--------------+---------------------+
        | 学生编号     | 学生姓名     | 课程名称            |
        +--------------+--------------+---------------------+
        |           12 | 胡歌         | 功夫,非你莫属       |
        +--------------+--------------+---------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        
```

 

