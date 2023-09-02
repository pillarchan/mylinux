[TOC]



# 前置知识: MySQL版本说明

```
Alpha版本:
	是内部测试版，一般不向外发布，会有很多Bug 一般只有测试人员使用

Beta版本:
	功能开发完和所有测试之后的产品，不会存在较大的功能和性能Bug

RC版本：
	生产环境之前的一个小版本，根据Beta版本测试结果打补丁后的版本。

GA版本:
	是正式发布的版本

温馨提示:
	选择发布六个月以上的GA版本，查看是否有连续BUG的版本，稳定版本一般几个月不会修复重大BUG。
	
	
MySQL 8.0新增端口推荐阅读:
	https://dev.mysql.com/doc/mysql-port-reference/en/mysql-ports-reference-tables.html#mysql-client-server-ports
```



# 一.数据类型概述

## 1.为什么要有数据类型

```
    众所周知的是计算机的数据存储在磁盘上是以二进制方式存储的。无论你看到的图片，视频，音频，文字，数字等在计算机底层都是使用0和1来存储的，这是不争的事实。

    那么程序员和计算机是如何识别这些二进制的呢？转述下Edwin Brady在《Type-driven Development with Idris》中的说法，类型有以下几个重要角色：
        (1)对机器而言，类型描述了内存中的电荷是怎么解释的。
        (2)对编译器或者解释器而言，类型可以协助确保上面那些电荷、字节在程序的运行中始终如一地被理解。
        (3)对程序员而言，类型可以帮助他们命名、组织概念，帮助编纂文档，支持交互式编辑环境等。
   
```



## 2.如果没有数据类型会怎样?

```
    最简单直接的解释就是，如果没有数据类型，那么存储在磁盘的数据，程序员们将很难处理这些数据。

    想必看了上面的解释可能你或多或少还是有点迷糊咋办呢？接下里我们来看一个案例，来帮助大家理解。
        (1)下面是我整理的一个二维表，不用我多做解释，想必你你能很明白我表达是啥意思。
            id    name    age
            1     张三     20
            2     李四     15
            3     王五     21
            4     赵六     30
            5     小二     19
        (2)接下来，我将上面的数据变化一下，请问你还能说出来我表达的是啥意思吗？看不懂是正常的，因为就是我瞎改的，完全没有规律可言。
            id      name    age
            asd     张三     2sc0
            xs2     李四     ms2
            3.14    王五     21
            4.0     赵六     sd2fsdsadasdsadasdas
            s2d     小二     1cc9
        
    通过上面的这个案例想必你多少对数据类型的作用有一定的了解了，所谓的数据类型就是可以帮助程序员去严格约束每个字段的数据类型。
```



# 二.MySQL内置的数据类型-常见的数字数据类型(Numeric Data Type)  :star:



## 1.整形类型

```
    数字类型是MySQL内置的数据类型之一，数字类型被细分为精确数值型(以下简称"整形")和近似数值型(以下简称"浮点型")。
        
    如下图所示，显示了整形类型大小及存储范围:
        微整型(tinyint):
            只占用一个字节，对应十进制(decimal)取值范围是-128~127(有符号位)或者0~255(无符号位)。
        小整型(smallint):
　　　　　　　只占用两个字节，对应十进制(decimal)取值范围是-32768~32767(有符号位)或者0~65535(无符号位)。
        中等整型(MEDIUMINT)
　　　　　　　只占用三个字节，对应十进制(decimal)取值范围-8388608~8388607(有符号位)或者0~16777215(无符号位)。
        整型(int):
　　　　　　　只占用四个字节的int，对应十进制(decimal)取值范围-2147483648~2147483647(有符号位)或者0~4294967295(无符号位)。
        大整形(BIGINT):
　　　　　　　只占用八个字节的，对应十进制(decimal)取值范围是-9223372036854775808~9223372036854775807(有符号位)或者0~18446744073709551615(无符号位)。
　　　　　　　
    定点类型(DECIMAL，NUMERIC):
        DECIMAL和NUMERIC类型存储精确的数字数据值，这些类型用于对于保持精确性很重要，例如货币数据。在MySQL中，NUMERIC是基于DECIMAL类型实现的，因此下面关于DECIMAL的注释同样适用于NUMERIC。
        以"salary DECIMAL(5,2)"为例,要求DECIMAL(5,2)能够存储具有五位数字和两位小数的任何值，因此可以存储在salary列范围内的值从-999.99到 999.99。遵循四舍五入法则.
        
        
推荐阅读:
	https://dev.mysql.com/doc/refman/5.6/en/data-types.html
```



## 2.浮点型

```
	近似数值型又分为单精度浮点型(float)和双精度浮点型(double)和自定义十进制型(DECIMAL)。
        单精度浮点型(float):
            只占用4字节，对应十进制位有符号位值为: "(-3.402823466E+38，-1.175494351E-38)，0，(1.175494351E-38，3.402823466351E+38)";
            对应十进制位无符号位值为: "0，(1.175494351E-38，3.402823466E+38)"
        双精度浮点型(double):
            只占用8字节，对应十进制位有符号位值为: "(-1.7976931348623157E+308，-2.2250738585072014E-308)，0，(2.225 0738585072014E-308，1.7976931348623157E+308)"
            对应十进制位无符号位值为: 0，(2.2250738585072014E-308，1.7976931348623157E+308)

    位数据类型(BIT):
        位数据类型用于存储位值，其语法为: BIT(M)，这里的M指的的取值范围只能在1-64，即仅能存储8个字节大小。要指定位值，可以使用b'value'表示法。比如:b"111"和b"10000000"分别表示7和128。

```

# 三.MySQL内置的数据类型-常见的字符串数据类型(String Data Type) :star:

## 1.CHAR与VARCHAR

```
    CHAR和VARCHAR的区别如下图所示，CHAR是固定的长度大小，而VARCHAR是可变的长度大小且会多出1-2个字节来存储这个长度大小。
        CHAR：
            定长字符类型，最大可存储255个字符。
            举例: CHAR(4)，存储真实数据"AB"，实际在数据库存储的样子是"AB  "，即实际长度不足4字节，则使用空格填充。
        VARCHAR:
            不定长字符类型，最大可存储65535个字符。VARCHAR的优点是实际存储的字符长度随着写入数据的实际字符长度变化而变化，因此需要维护一个定义字符长度。
            举例: VARCHAR(4)，存储真实数据"AB"，实际在数据库存储的样子就是"AB"，但会占用1个字节来维护实际数据的长度为2，则实际存储占用的空间应该是3字节。

    综上所述，我们需要验证一下:
        mysql> CREATE DATABASE myworld DEFAULT CHARACTER SET = utf8mb4;
        Query OK, 1 row affected (0.00 sec)
        
        mysql> USE myworld;
        Database changed
        mysql> 
        mysql> CREATE TABLE teacher(name CHAR(5), address VARCHAR(5));
        Query OK, 0 rows affected (0.02 sec)
        
        mysql> 
        mysql> INSERT INTO teacher VALUES('ABC','ABC');
        Query OK, 1 row affected (0.03 sec)
        
        mysql> 
        mysql> INSERT INTO teacher VALUES('oldboy2020','oldboy2020');  # 由于'oldboy2020'的字符长度已经达到了7个，因此无法成功插入数据哟~
        ERROR 1406 (22001): Data too long for column 'name' at row 1
        mysql> 
        mysql> INSERT INTO teacher VALUES('oldboy20','oldboy20');
        Query OK, 1 row affected (0.00 sec)
        
        mysql> 
        mysql> INSERT INTO teacher VALUES('10','10');
        Query OK, 1 row affected (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM teacher;
        +-------------+-------------+
        | name        | address     |
        +-------------+-------------+
        | ABC         | ABC         |
        | oldboy20    | oldboy20    |
        | 10          | 10          |
        +-------------+-------------+
        3 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT length(name) AS name_len, length(address) AS address_len FROM teacher;  # 注意哈，length函数显式的是真实数据的长度，它无法显示出VARCHAR字符用于存储实际数据大小的长度哟~
        +----------+-------------+
        | name_len | address_len |
        +----------+-------------+
        |        3 |           3 |
        |       11 |          11 |
        |        2 |           2 |
        +----------+-------------+
        3 rows in set (0.00 sec)
        
        mysql> 
        
    温馨提示:
        (1)VARCHAR内部维护了存储每条数据的真实长度的变量，它们只能占用1-2个字节，这是由于VARCHAR最多只能存储65535个字符，因此仅需2个字节就能表示65535种状态;
        (2)在MySQL Community 5.6版本中，如果我们定了某个字段的数据类型为CHAR(5)或VARCHAR(5)，则意味着该字段仅能存储5个字符，若超出5个字符，则多余的部分将被截断;但是在MySQL Community 5.7或者MySQL Community 8.0版本中不允许插入成功;这主要是SQL_MODE在背后捣鬼，很明显MySQL Community 5.7以上不采用MySQL Community 5.6那种截断数据的方式，目的是让程序员明白，数据存在丢失的风险！
        (3)对于英文，符号和数字，每个字符均占用1个字节长度，但对于特殊字符，比如中文，日文，韩文等就得考虑字符集的因素，我们以中文为例，若指定GBK字符编码，则常用的汉字通常占用2个字节，但对于utf8mb4字符编码而言，则常用的汉字通常占用3个字节，而对于emoji表情字符底层对应4个字节去存储。
    
    彩蛋:
        (1)你是否有这样的疑问呢？VARCHAR(65535)或者CHAR(65535)能存储65535个汉字吗？
            答案是否定的，你不信的话可以定义一个表而后使用SQL的循环语句试试看哟~
        (2)为什么很多人喜欢使用varchar(255)呢?
            1)对于InnoDB存储引擎，单一字段或前缀长度最长是767字节(bytes)，如果字符集是utf8mb4且该字段只存储中文的话，那么767/3=255个汉子，这就是为什么开发人员习惯设置为varchar(255)的原因;
            2)但需要注意的是，如果字符集是utf8mb4,且该字段只存储emoji表情字符时，767/4=191个表情字符哟;
            3)对了，别忘记varchar类型会有1-2个字节来存储实际数据的长度，当实际数据长度小于255个字符时，只需要1个字节就能存储255种状态，但如果实际数据长度大于255，则需要2个字节来存储长度，因为2个字节可以表示65535中状态;
            4)当我们使用的是默认存储引擎innodb且设置了varchar(M)，我们用其存储中文超过了255个字符时，那么MySQL底层会自动帮我们将该字段整列数据都转换为Text数据类型哟。
            综上所述，我们平时开发室如果设置varchar(255)是一种开发习惯而已，但实际上也很少会将一个字段的内容显示设置超过255个中文字符，如果真有这样的需求，建议直接使用text的文件类型。
```



## 2.ENUM

```
    枚举(ENUM)是一个字符串对象，其值从表创建时列规范中显式枚举的允许值列表中选择。比如性别，省份，城市基本上都是固定的，很少发生变动的数据，我们就可以将其设定为枚举型。

    以下是ENUM定义的一个官方参考案例:
        mysql> USE myworld;
        Database changed
        mysql> 
        mysql> SHOW TABLES;
        +-----------------------+
        | Tables_in_myworld |
        +-----------------------+
        | teacher               |
        +-----------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> CREATE TABLE shirts (
            ->     name VARCHAR(40),
            ->     size ENUM('x-small', 'small', 'medium', 'large', 'x-large')
            -> );
        Query OK, 0 rows affected (0.02 sec)
        
        mysql> INSERT INTO shirts (name, size) VALUES ('dress shirt','large'), ('t-shirt','medium'),('polo shirt','small');
        Query OK, 3 rows affected (0.00 sec)
        Records: 3  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SELECT name, size FROM shirts WHERE size = 'medium';
        +---------+--------+
        | name    | size   |
        +---------+--------+
        | t-shirt | medium |
        +---------+--------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM shirts;
        +-------------+--------+
        | name        | size   |
        +-------------+--------+
        | dress shirt | large  |
        | t-shirt     | medium |
        | polo shirt  | small  |
        +-------------+--------+
        3 rows in set (0.00 sec)
        
        mysql> 
        mysql> UPDATE shirts SET size = 'small' WHERE size = 'large';
        Query OK, 1 row affected (0.04 sec)
        Rows matched: 1  Changed: 1  Warnings: 0
        
        mysql> 
        mysql> SELECT * FROM shirts;
        +-------------+--------+
        | name        | size   |
        +-------------+--------+
        | dress shirt | small  |
        | t-shirt     | medium |
        | polo shirt  | small  |
        +-------------+--------+
        3 rows in set (0.00 sec)
        
        mysql> 

```



## 3.BINARY与VARBINARY(了解即可)

```
    BINARY和VARBINARY类型与CHAR和VARCHAR类似，只是它们存储二进制字符串而不是非二进制字符串。

    也就是说，它们存储字节字符串而不是字符串。这意味着它们具有二进制字符集和排序规则，比较和排序基于值中字节的数值。

    允许的最大长度对于BINARY和VARBINARY与CHAR和VARCHAR相同，只是BINARY和VARBINARY的长度是以字节而不是字符来度量的。
    BANARY(M)   0<=M<=255
```



## 4.BLOB与TEXT(了解即可)

```
    BLOB是一个二进制大对象，它可以保存可变数量的数据。这四种BLOB类型是TINYBLOB、BLOB、MEDIUMBLOB和LONGBLOB。它们仅在所能容纳的值的最大长度上不同。

    TEXT是一个文本大对象，这四种文本类型是TINYTEXT、TEXT、MEDIUMTEXT和LONGTEXT。它们对应于四种BLOB类型，具有相同的最大长度和存储要求。
L+1 bytes L<2^8 , L+2 bytes L<2^16 ,L+1 bytes L<2^24, L+1 bytes L<2^32
```





## 5.SET(了解即可)

```
    集合(SET)是可以有零个或多个值的字符串对象，每个值必须从创建表时指定的允许值列表中选择。值得注意的是，创建集合的各元素的值不应该重复，这是集合的特点。

    由多个集合成员组成的集合列值由逗号(",")分隔的成员指定。这样做的结果是集合成员值本身不应包含逗号。一个集合列最多可以有64个不同的成员。

    接下来，我们看下面的一组案例:
        mysql> CREATE TABLE myset (col SET('a', 'b', 'c', 'd'));
        Query OK, 0 rows affected (0.29 sec)
        
        mysql> 
        mysql> INSERT INTO myset (col) VALUES ('a,d'), ('d,a'), ('a,d,a'), ('a,d,d'), ('d,a,d');
        Query OK, 5 rows affected (0.00 sec)
        Records: 5  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SELECT * FROM myset;  # 注意观察我们插入的顺序，在观察查看的顺序，很明显数据是被排序过了....
        +------+
        | col  |
        +------+
        | a,d  |
        | a,d  |
        | a,d  |
        | a,d  |
        | a,d  |
        +------+
        5 rows in set (0.00 sec)
        
        mysql> 
        mysql> INSERT INTO myset (col) VALUES ('b,c'), ('1,2');  # 数据插入失败，因为'1','2'并不在咱们定义的集合'a','b','c','d'中
        ERROR 1265 (01000): Data truncated for column 'col' at row 2
        mysql> 
        mysql> INSERT INTO myset (col) VALUES ('b,c');
        Query OK, 1 row affected (0.01 sec)
        
        mysql> 
        mysql> SELECT * FROM myset;
        +------+
        | col  |
        +------+
        | a,d  |
        | a,d  |
        | a,d  |
        | a,d  |
        | a,d  |
        | b,c  |
        +------+
        6 rows in set (0.00 sec)
        
        mysql> 
        mysql> INSERT INTO myset (col) VALUES ('a,c,b,a,a,a'),('d,d,a,c,c,b,b');
        Query OK, 2 rows affected (0.01 sec)
        Records: 2  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SELECT * FROM myset;
        +---------+
        | col     |
        +---------+
        | a,d     |
        | a,d     |
        | a,d     |
        | a,d     |
        | a,d     |
        | b,c     |
        | a,b,c   |
        | a,b,c,d |
        +---------+
        8 rows in set (0.00 sec)
        
        mysql> 

```



# 四.MySQL内置的数据类型-常见的日期和时间数据类型(Date and Time Data Types)

![image-20210710091516737](D:/learn/第4阶段-DBA/01-老N孩教育-MySQL数据库多版本部署，数据类型详解及DML语句入门/笔记/02-老男孩教育-SQL基础.assets/image-20210710091516737.png)

```
    用于表示时间值的日期和时间数据类型是DATE，TIME，DATETIME，TIMESTAMP，和YEAR。

    DATE:(MySQL 5.6.4之前占用3字节)
        支持的范围是“1000-01-01”到“9999-12-31”。MySQL以'YYYY-MM-DD'格式显示日期值，但允许使用字符串或数字为日期列赋值。

    TIME:(MySQL 5.6.4之前占用3字节)
        范围是“-838:59:59.000000”到“838:59:59.000000”。MySQL以“hh:mm:ss[.fraction]”格式显示时间值，但允许使用字符串或数字为时间列赋值。
        可以给出0到6范围内的可选fsp值，以指定小数秒精度。值为0表示没有小数部分。如果省略，则默认精度为0。

    DATETIME:(MySQL 5.6.4之前占用8字节)
        日期(DATE)和时间(TIME)的组合。支持的范围是“1000-01-01 00:00:00.000000”到“9999-12-31 23:59:59.999999”。
        MySQL以“YYYY-MM-DD hh:MM:ss[.fraction]”格式显示DATETIME值，但允许使用字符串或数字为DATETIME列赋值。
        可以给出0到6范围内的可选fsp值，以指定小数秒精度。值为0表示没有小数部分。如果省略，则默认精度为0。
        可以使用DEFAULT和ON UPDATE列定义子句指定DATETIME列的当前日期和时间的自动初始化和更新，如官方文档的第11.2.5节“TIMESTAMP和DATETIME的自动初始化和更新”所述。

    TIMESTAMP:(MySQL 5.6.4之前占用4字节)
        时间戳值存储为自epoch('1970-01-01 00:00:00'UTC)以来的秒数。其范围是“1970-01-01 00:00:01.000000”UTC到“2038-01-19 03:14:07.999999”UTC(格林尼治时间)。
        存储时，MySQL将TIMESTAMP值从当前时区转换为UTC时间进行存储，查询时，将数据从UTC转换为检索的当前时区。因此TIMESTAMP会受到时区的影响，而DATETIME不会发生这种情况。
        时间戳不能表示值“1970-01-01 00:00:00”，因为这相当于从纪元开始的0秒，而值0保留用于表示“0000-00-00 00:00:00”时间戳值“零”。

    YEAR:(MySQL 5.6.4之前占用1字节)
        用4个数字来表示一个年份。MySQL以YYYY格式显示年份值，但允许使用字符串或数字为年份列赋值。值显示为1901-2155或0000。
        SUM()和AVG()聚合函数不能处理时态值。(它们将值转换为数字，丢失第一个非数字字符之后的所有内容。)要解决此问题，请转换为数字单位，执行聚合操作，然后转换回时间值。
```

![image-20210710091601927](D:/learn/第4阶段-DBA/01-老N孩教育-MySQL数据库多版本部署，数据类型详解及DML语句入门/笔记/02-老男孩教育-SQL基础.assets/image-20210710091601927.png)





# 五.其它MySQL内置的数据类型

```
    MySQL除了上面提到的常用数据类型外，还支持Spatial Data Types，The JSON Data Type等等。我这里就不一一举例了，感兴趣的小伙伴可自行阅读官网。


    其实我们不用刻意去背诵哪些MySQL数据库的内置数据类型，如果你想看只需通过如下命令就能查看
        mysql> HELP CONTENTS
        You asked for help about help category: "Contents"
        For more information, type 'help <item>', where <item> is one of the following
        categories:
           Account Management
           Administration
           Compound Statements
           Contents
           Data Definition
           Data Manipulation
           Data Types
           Functions
           Geographic Features
           Help Metadata
           Language Structure
           Plugins
           Procedures
           Storage Engines
           Table Maintenance
           Transactions
           User-Defined Functions
           Utility
        
        mysql> 
        mysql> HELP Data Types  # 查看数据类型
        You asked for help about help category: "Data Types"
        For more information, type 'help <item>', where <item> is one of the following
        topics:
           AUTO_INCREMENT
           BIGINT
           BINARY
           BIT
           BLOB
           BLOB DATA TYPE
           BOOLEAN
           CHAR
           CHAR BYTE
           DATE
           DATETIME
           DEC
           DECIMAL
           DOUBLE
           DOUBLE PRECISION
           ENUM
           FLOAT
           INT
           INTEGER
           LONGBLOB
           LONGTEXT
           MEDIUMBLOB
           MEDIUMINT
           MEDIUMTEXT
           SET DATA TYPE
           SMALLINT
           TEXT
           TIME
           TIMESTAMP
           TINYBLOB
           TINYINT
           TINYTEXT
           VARBINARY
           VARCHAR
           YEAR DATA TYPE
        
        mysql> 

```



# 六.常用的字段约束及字段属性

```
常用的字段约束(Constraints)相关的关键字
	UNIQUE KEY Constraints:
        唯一约束，顾名思义，作用是保证该列字段的必须是不重复的值。

    PRIMARY KEY Constraints:
        主键约束，作用是保证该列字段唯一且非空，每张表只能有一个主键，称为聚簇索引。

    FOREIGN KEY Constraints:
        外键约束，作用是允许跨表交叉引用相关数据，外键约束有助于保持数据的一致性。
        
常用的字段属性
    UNSIGNED :
        无符号约束，即取消字段的符号位，通常作用在数字数据类型字段上。换句话说，就是让该字段非负数。
        无符号约束，作用是保证该列字段无符号，主要针对的是数字列，即可以保证非负数，比如人的年龄。

    NOT NULL:
        非空约束，作用是保证该列字段必须非空，通常建议大家将每个列都设置为非空。若不指定非空约束则默认该字段允许为空(NULL)！

    DEFAULT:
        默认值，若插入一条数据后，用户未提交某列的值，则该列将使用默认值。

    COMMENT:
        用于注释信息。

    AUTO_INCREMENT:
        用于自动增长的字段，该属性不能单独使用。通常和PRIMARY KEY Constraints配合使用。
        比如你为某个"id PRIMARY KEY"字段指定了AUTO_INCREMENT属性，若插入数据时未给该字段赋值，则该字段会根据上一条的记录自动增长。
        
```



# 七. 字符集(Charset)

## 1.什么是字符集

```
    字符集只是一个规则集合的名字，对应到真实生活中，字符集就是对某种语言的称呼。例如：英语，汉语，日语。
```



## 2.字符集的组成

```
    对于一个字符集来说要正确编码转码一个字符需要三个关键元素：字库表(character repertoire)、编码字符集(coded character set)和字符编码(character encoding form)。
            
    字库表:
        是一个相当于所有可读或者可显示字符的数据库，字库表决定了整个字符集能够展现表示的所有字符的范围。
            
    编码字符集:
        即用一个编码值(code point)来表示一个字符在字库中的位置。
            
    字符编码:
        将编码字符集和实际存储数值之间的转换关系。一般来说都会直接将(code point)的值作为编码后的值直接存储。例如在ASCII中A在表中排第65位，而编码后A的数值是0100 0001也即十进制的65的二进制转换结果。
        我们平时在MySQL常用的字符集为: utf8,gbk,utf8mb4等，但推荐使用后者，即utf8mb4。
```



## 3.在MySQL中常用的字符编码可以通过"SHOW CHARSET;"命令来查看

```
SHOW CHARSET;  


温馨提示:
	推荐使用utf8mb4字符编码。
```

![image-20210710182630330](D:/learn/第4阶段-DBA/01-老N孩教育-MySQL数据库多版本部署，数据类型详解及DML语句入门/笔记/02-老男孩教育-SQL基础.assets/image-20210710182630330.png)





# 八.校对规则(Collation)

## 1.校对规则概述

```
    每种字符集，有多种校对规则，也可以称之为"排序规则"。

    综上所述，如果我们对字符集设置了不同的校对规则，那么它们将会影响到排序的操作。
```



## 2.查看MySQL支持的校对规则(需要注意的是，MySQL Community 8.0版本的校验规则和MySQL Community 5.7有所不同)

```
    我们可以使用"SHOW COLLATION"查看所有字符集的校对规则。但我们通常情况下不会太关心每一个字符集的校对规则，因为各种字符集的校对规则加起来200多行了(MySQL Community 5.7有220多行，MySQL Community 8.0有270多行)。

    我们通常只关心创建库所对应的字符集的校对规则，比如我们创建的库其字符集为"utf8mb4"，因此只查看"utf8mb4"字符集对应的校对规则语法格式如下所示:
    	SHOW COLLATION WHERE Charset='utf8mb4';
```

![image-20210710183218059](D:/learn/第4阶段-DBA/01-老N孩教育-MySQL数据库多版本部署，数据类型详解及DML语句入门/笔记/02-老男孩教育-SQL基础.assets/image-20210710183218059.png)





# 九.MySQL的字符终端客户端工具mysql交互式常用命令概述

## 1.查看mysql客户端自带的命令的帮助信息

```
    我们在服务器通常会使用MySQL server自带的工具，即mysql客户端来连接MySQL server，因此对于mysql客户端命令的使用有一个基本的了解很有必要，尽管它们并非是SQL语言，如下所示:
        mysql> HELP
        
        For information about MySQL products and services, visit:
           http://www.mysql.com/
        For developer information, including the MySQL Reference Manual, visit:
           http://dev.mysql.com/
        To buy MySQL Enterprise support, training, or other products, visit:
           https://shop.mysql.com/
        
        List of all MySQL commands:
        Note that all text commands must be first on line and end with ';'
        ?         (\?) Synonym for `help'.
        clear     (\c) Clear the current input statement.
        connect   (\r) Reconnect to the server. Optional arguments are db and host.
        delimiter (\d) Set statement delimiter.
        edit      (\e) Edit command with $EDITOR.
        ego       (\G) Send command to mysql server, display result vertically.
        exit      (\q) Exit mysql. Same as quit.
        go        (\g) Send command to mysql server.
        help      (\h) Display this help.
        nopager   (\n) Disable pager, print to stdout.
        notee     (\t) Don't write into outfile.
        pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
        print     (\p) Print current command.
        prompt    (\R) Change your mysql prompt.
        quit      (\q) Quit mysql.
        rehash    (\#) Rebuild completion hash.
        source    (\.) Execute an SQL script file. Takes a file name as an argument.
        status    (\s) Get status information from the server.
        system    (\!) Execute a system shell command.
        tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
        use       (\u) Use another database. Takes database name as argument.
        charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
        warnings  (\W) Show warnings after every statement.
        nowarning (\w) Don't show warnings after every statement.
        resetconnection(\x) Clean session context.
        
        For server side help, type 'help contents'
        
        mysql> 
    
    温馨提示:
        我们在执行mysql工具的命令时无需添加分号(";")，通常使用分号(";")的SQL语句主要是MySQL server端执行SQL语句的默认结尾标识符。

```



## 2.mysql工具常用命令-结束当前SQL语句的执行("\c")

```
    如果你执行SQL语句的过程中，发现自己写的语句写错了，不想执行当前语句时，可以使用"\c"来终止命令的执行，如下所示:
        mysql> SHOW TABLES;
        +-----------------------+
        | Tables_in_myworld |
        +-----------------------+
        | myset                 |
        | shirts                |
        | t1                    |
        | teacher               |
        +-----------------------+
        4 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM teacher;
        +-------------+-------------+
        | name        | address     |
        +-------------+-------------+
        | ABC         | ABC         |
        | 尹正杰20    | 尹正杰20    |
        | 10          | 10          |
        +-------------+-------------+
        3 rows in set (0.00 sec)
        
        mysql> 
        mysql> 
        mysql> SELECT * FROM t12233213213;  # 很明显，我们查看的表名称写措时，若强行执行该SQL语句就会抛出异常！
        ERROR 1146 (42S02): Table 'myworld.t12233213213' doesn't exist
        mysql> 
        mysql> SELECT * FROM t12233213213\c  # 如果我们放弃当前SQL语句的执行，则可以使用"\c"选项来取消。
        mysql> 

```



## 3.mysql工具常用命令-垂直显示结果("\G")

```
    所谓的垂直化显示结果，就是将每一行的数据拿出来单独显示，我们知道一行中有多个列，那么可以将每一行的每一列作为key，其值作为value进行查看，如下所示:
        mysql> SELECT * FROM teacher;
        +-------------+-------------+
        | name        | address     |
        +-------------+-------------+
        | ABC         | ABC         |
        | 尹正杰20    | 尹正杰20    |
        | 10          | 10          |
        +-------------+-------------+
        3 rows in set (0.01 sec)
        
        mysql> 
        mysql> SELECT * FROM teacher\G
        *************************** 1. row ***************************
           name: ABC
        address: ABC
        *************************** 2. row ***************************
           name: 尹正杰20
        address: 尹正杰20
        *************************** 3. row ***************************
           name: 10
        address: 10
        3 rows in set (0.00 sec)
        
        mysql> 
        mysql> 
        
    如果你觉得上面的案例貌似体会不到它的妙用之处，那么看下面的这个案例，你就会发现"\G"的用处还是蛮牛的，因为可读性更强！
        mysql> SELECT * FROM mysql.user LIMIT 1;
        +-----------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------
        +------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------+-------------+--------------+---------------+-------------+-----------------+----------------------+-----------------------+-----------------------+------------------+-----------------------+-------------------+----------------+| Host      | User | Select_priv | Insert_priv | Update_priv | Delete_priv | Create_priv | Drop_priv | Reload_priv | Shutdown_priv | Process_priv | File_priv | Grant_priv | References_priv 
        | Index_priv | Alter_priv | Show_db_priv | Super_priv | Create_tmp_table_priv | Lock_tables_priv | Execute_priv | Repl_slave_priv | Repl_client_priv | Create_view_priv | Show_view_priv | Create_routine_priv | Alter_routine_priv | Create_user_priv | Event_priv | Trigger_priv | Create_tablespace_priv | ssl_type | ssl_cipher | x509_issuer | x509_subject | max_questions | max_updates | max_connections | max_user_connections | plugin                | authentication_string | password_expired | password_last_changed | password_lifetime | account_locked |+-----------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------
        +------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------+-------------+--------------+---------------+-------------+-----------------+----------------------+-----------------------+-----------------------+------------------+-----------------------+-------------------+----------------+| localhost | root | Y           | Y           | Y           | Y           | Y           | Y         | Y           | Y             | Y            | Y         | Y          | Y               
        | Y          | Y          | Y            | Y          | Y                     | Y                | Y            | Y               | Y                | Y                | Y              | Y                   | Y                  | Y                | Y          | Y            | Y                      |          |            |             |              |             0 |           0 |               0 |                    0 | mysql_native_password |                       | N                | 2021-01-10 21:15:36   |              NULL | N              |+-----------+------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------
        +------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------+-------------+--------------+---------------+-------------+-----------------+----------------------+-----------------------+-----------------------+------------------+-----------------------+-------------------+----------------+1 row in set (0.00 sec)
        
        mysql> 
        mysql> 
        mysql> 
        mysql> SELECT * FROM mysql.user LIMIT 1 \G
        *************************** 1. row ***************************
                          Host: localhost
                          User: root
                   Select_priv: Y
                   Insert_priv: Y
                   Update_priv: Y
                   Delete_priv: Y
                   Create_priv: Y
                     Drop_priv: Y
                   Reload_priv: Y
                 Shutdown_priv: Y
                  Process_priv: Y
                     File_priv: Y
                    Grant_priv: Y
               References_priv: Y
                    Index_priv: Y
                    Alter_priv: Y
                  Show_db_priv: Y
                    Super_priv: Y
         Create_tmp_table_priv: Y
              Lock_tables_priv: Y
                  Execute_priv: Y
               Repl_slave_priv: Y
              Repl_client_priv: Y
              Create_view_priv: Y
                Show_view_priv: Y
           Create_routine_priv: Y
            Alter_routine_priv: Y
              Create_user_priv: Y
                    Event_priv: Y
                  Trigger_priv: Y
        Create_tablespace_priv: Y
                      ssl_type: 
                    ssl_cipher: 
                   x509_issuer: 
                  x509_subject: 
                 max_questions: 0
                   max_updates: 0
               max_connections: 0
          max_user_connections: 0
                        plugin: mysql_native_password
         authentication_string: 
              password_expired: N
         password_last_changed: 2021-01-10 21:15:36
             password_lifetime: NULL
                account_locked: N
        1 row in set (0.00 sec)
        
        mysql> 

```



## 4.mysql工具常用命令-退出当前字符终端("ctrl +d","quit","exit","\q")

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> ^DBye
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 14
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> quit
Bye
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 15
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> exit
Bye
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 16
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> \q
Bye
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# 

```



## 5.mysql工具常用命令-将所有执行的SQL语句及内容附加到给定的输出文件中("tee /file/to/path")，可用于后期的日志审计

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 17
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> tee /tmp/mysql23307.log
Logging to file '/tmp/mysql23307.log'
mysql> 
mysql> USE myworld;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_myworld |
+-----------------------+
| myset                 |
| shirts                |
| t1                    |
| teacher               |
+-----------------------+
4 rows in set (0.04 sec)

mysql> 
mysql> SELECT * FROM teacher\G
*************************** 1. row ***************************
   name: ABC
address: ABC
*************************** 2. row ***************************
   name: 尹正杰20
address: 尹正杰20
*************************** 3. row ***************************
   name: 10
address: 10
3 rows in set (0.00 sec)

mysql> 
mysql> QUIT
Bye
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# ll /tmp/mysql23307.log 
-rw-r--r-- 1 root root 808 1月  12 09:58 /tmp/mysql23307.log
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# cat /tmp/mysql23307.log 
mysql> 
mysql> USE myworld;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_myworld |
+-----------------------+
| myset                 |
| shirts                |
| t1                    |
| teacher               |
+-----------------------+
4 rows in set (0.04 sec)

mysql> 
mysql> SELECT * FROM teacher\G
*************************** 1. row ***************************
   name: ABC
address: ABC
*************************** 2. row ***************************
   name: 尹正杰20
address: 尹正杰20
*************************** 3. row ***************************
   name: 10
address: 10
3 rows in set (0.00 sec)

mysql> 
mysql> QUIT
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# 

```



## 6.mysql工具常用命令-停止将所有执行的SQL语句及内容继续往输出文件中追加("notee")。

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 18
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> tee /tmp/mysql23307-002.log
Logging to file '/tmp/mysql23307-002.log'
mysql> 
mysql> USE myworld
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_myworld |
+-----------------------+
| myset                 |
| shirts                |
| t1                    |
| teacher               |
+-----------------------+
4 rows in set (0.03 sec)

mysql> 
mysql> DESC shirts;
+-------+----------------------------------------------------+------+-----+---------+-------+
| Field | Type                                               | Null | Key | Default | Extra |
+-------+----------------------------------------------------+------+-----+---------+-------+
| name  | varchar(40)                                        | YES  |     | NULL    |       |
| size  | enum('x-small','small','medium','large','x-large') | YES  |     | NULL    |       |
+-------+----------------------------------------------------+------+-----+---------+-------+
2 rows in set (0.31 sec)

mysql> 
mysql> notee
Outfile disabled.
mysql> 
mysql> DESC teacher;
+---------+------------+------+-----+---------+-------+
| Field   | Type       | Null | Key | Default | Extra |
+---------+------------+------+-----+---------+-------+
| name    | char(5)    | YES  |     | NULL    |       |
| address | varchar(5) | YES  |     | NULL    |       |
+---------+------------+------+-----+---------+-------+
2 rows in set (0.05 sec)

mysql> 
mysql> DESC t1;
+-------+-------------+------+-----+-------------------+-----------------------------+
| Field | Type        | Null | Key | Default           | Extra                       |
+-------+-------------+------+-----+-------------------+-----------------------------+
| t     | time(3)     | YES  |     | NULL              |                             |
| dt    | datetime(6) | YES  |     | NULL              |                             |
| ts    | timestamp   | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP |
+-------+-------------+------+-----+-------------------+-----------------------------+
3 rows in set (0.04 sec)

mysql> 
mysql> QUIT
Bye
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# ll /tmp/mysql23307-002.log 
-rw-r--r-- 1 root root 1080 1月  12 10:03 /tmp/mysql23307-002.log
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# cat /tmp/mysql23307-002.log 
mysql> 
mysql> USE myworld
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_myworld |
+-----------------------+
| myset                 |
| shirts                |
| t1                    |
| teacher               |
+-----------------------+
4 rows in set (0.03 sec)

mysql> 
mysql> DESC shirts;
+-------+----------------------------------------------------+------+-----+---------+-------+
| Field | Type                                               | Null | Key | Default | Extra |
+-------+----------------------------------------------------+------+-----+---------+-------+
| name  | varchar(40)                                        | YES  |     | NULL    |       |
| size  | enum('x-small','small','medium','large','x-large') | YES  |     | NULL    |       |
+-------+----------------------------------------------------+------+-----+---------+-------+
2 rows in set (0.31 sec)

mysql> 
mysql> notee
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# 

```



## 7.mysql工具常用命令-导入本地SQL脚本并执行("SOURCE")

```
[root@docker201.myworld.com ~]# vim test.sql
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# cat test.sql
USE myworld;
SHOW TABLES;
DESC teacher;
SELECT user,host,authentication_string FROM mysql.user;
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 20
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SOURCE ~/test.sql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
+-----------------------+
| Tables_in_myworld |
+-----------------------+
| myset                 |
| shirts                |
| t1                    |
| teacher               |
+-----------------------+
4 rows in set (0.00 sec)

+---------+------------+------+-----+---------+-------+
| Field   | Type       | Null | Key | Default | Extra |
+---------+------------+------+-----+---------+-------+
| name    | char(5)    | YES  |     | NULL    |       |
| address | varchar(5) | YES  |     | NULL    |       |
+---------+------------+------+-----+---------+-------+
2 rows in set (0.00 sec)

+---------------+-----------+-------------------------------------------+
| user          | host      | authentication_string                     |
+---------------+-----------+-------------------------------------------+
| root          | localhost |                                           |
| mysql.session | localhost | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE |
| mysql.sys     | localhost | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE |
+---------------+-----------+-------------------------------------------+
3 rows in set (0.00 sec)

mysql> 

```



## 8.mysql工具常用命令-执行当前操作系统的命令(SYSTEM)

```
mysql> SYSTEM ls -l /
总用量 20
lrwxrwxrwx.   1 root root    7 12月 24 13:13 bin -> usr/bin
dr-xr-xr-x.   5 root root 4096 12月 24 13:17 boot
drwxr-xr-x   19 root root 3220 1月  10 11:17 dev
drwxr-xr-x.  74 root root 8192 1月  12 08:23 etc
drwxr-xr-x.   3 root root   20 1月   7 08:09 home
lrwxrwxrwx.   1 root root    7 12月 24 13:13 lib -> usr/lib
lrwxrwxrwx.   1 root root    9 12月 24 13:13 lib64 -> usr/lib64
drwxr-xr-x.   2 root root    6 4月  11 2018 media
drwxr-xr-x.   2 root root    6 4月  11 2018 mnt
drwxr-xr-x.   3 root root   24 1月   4 22:22 opt
dr-xr-xr-x  124 root root    0 1月  10 11:16 proc
dr-xr-x---.   4 root root  275 1月  12 10:07 root
drwxr-xr-x   25 root root  680 1月  10 20:38 run
lrwxrwxrwx.   1 root root    8 12月 24 13:13 sbin -> usr/sbin
drwxr-xr-x.   2 root root    6 4月  11 2018 srv
dr-xr-xr-x   13 root root    0 1月  12 10:09 sys
drwxrwxrwt.  12 root root 4096 1月  12 10:02 tmp
drwxr-xr-x.  13 root root  155 12月 24 13:13 usr
drwxr-xr-x.  19 root root  267 12月 24 13:17 var
drwxr-xr-x    5 root root   47 1月   7 22:22 myworld
mysql> 

```



## 9.mysql工具常用命令-从服务器获取状态信息("STATUS")

```
mysql> STATUS
--------------
mysql  Ver 14.14 Distrib 5.7.31, for linux-glibc2.12 (x86_64) using  EditLine wrapper

Connection id:		20
Current database:	myworld
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server version:		5.7.31-log MySQL Community Server (GPL)
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	latin1
Db     characterset:	utf8mb4
Client characterset:	utf8
Conn.  characterset:	utf8
UNIX socket:		/tmp/mysql23307.sock
Uptime:			1 day 11 hours 41 min 51 sec

Threads: 2  Questions: 159  Slow queries: 0  Opens: 144  Flush tables: 1  Open tables: 137  Queries per second avg: 0.001
--------------

mysql> 

```



## 10.mysql工具常用命令-修改当前命令行的提示符信息("PROMPT")

```
mysql> PROMPT docker201.myworld.com[mysql]-->
PROMPT set to 'docker201.myworld.com[mysql]-->'
docker201.myworld.com[mysql]-->
docker201.myworld.com[mysql]-->
docker201.myworld.com[mysql]-->
docker201.myworld.com[mysql]-->STATUS
--------------
mysql  Ver 14.14 Distrib 5.7.31, for linux-glibc2.12 (x86_64) using  EditLine wrapper

Connection id:		20
Current database:	myworld
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server version:		5.7.31-log MySQL Community Server (GPL)
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	latin1
Db     characterset:	utf8mb4
Client characterset:	utf8
Conn.  characterset:	utf8
UNIX socket:		/tmp/mysql23307.sock
Uptime:			1 day 11 hours 45 min 16 sec

Threads: 2  Questions: 162  Slow queries: 0  Opens: 144  Flush tables: 1  Open tables: 137  Queries per second avg: 0.001
--------------

docker201.myworld.com[mysql]-->
docker201.myworld.com[mysql]-->
docker201.myworld.com[mysql]-->

```



# 十.MySQL的字符终端客户端工具mysql非交互式常用命令概述

## 1.基于指定的本地套接字文件连接MySQL数据库

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 22
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> \q
Bye
[root@docker201.myworld.com ~]# 
```



## 2.启动mysql客户端连接时临时指定提示符信息

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock --prompt="\u@[\D]-->"
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 23
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

root@[Tue Jan 12 10:19:57 2021]-->
root@[Tue Jan 12 10:19:58 2021]-->STATUS
--------------
mysql  Ver 14.14 Distrib 5.7.31, for linux-glibc2.12 (x86_64) using  EditLine wrapper

Connection id:		23
Current database:	
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server version:		5.7.31-log MySQL Community Server (GPL)
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	latin1
Db     characterset:	latin1
Client characterset:	utf8
Conn.  characterset:	utf8
UNIX socket:		/tmp/mysql23307.sock
Uptime:			1 day 11 hours 49 min 3 sec

Threads: 2  Questions: 173  Slow queries: 0  Opens: 144  Flush tables: 1  Open tables: 137  Queries per second avg: 0.001
--------------

root@[Tue Jan 12 10:20:01 2021]-->
root@[Tue Jan 12 10:20:02 2021]-->QUIT
Bye
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# 

```



## 3.基于指定用户登录

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock -u root 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 28
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select user();
+----------------+
| user()         |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.00 sec)

mysql> 
mysql> quit
Bye
[root@docker201.myworld.com ~]# 

```



## 4.登录时指定密码(不推荐使用)

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock -u root -p  # 注意哈，我们可以在字符"-p"紧挨着写密码进行登录，但不推荐这样做，因为可以使用history命令查看到当前root密码。
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 29
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> select user();
+----------------+
| user()         |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.00 sec)

mysql> 
mysql> 

```



## 5.连接MySQL server中指定的数据库

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock -D myworld
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 30
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_myworld |
+-----------------------+
| myset                 |
| shirts                |
| t1                    |
| teacher               |
+-----------------------+
4 rows in set (0.00 sec)

mysql> 
mysql> QUIT
Bye
[root@docker201.myworld.com ~]# 

```



## 6.在命令行中执行SQL命令

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock -e "SELECT user,host,authentication_string FROM mysql.user"
+---------------+-----------+-------------------------------------------+
| user          | host      | authentication_string                     |
+---------------+-----------+-------------------------------------------+
| root          | localhost |                                           |
| mysql.session | localhost | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE |
| mysql.sys     | localhost | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE |
+---------------+-----------+-------------------------------------------+
[root@docker201.myworld.com ~]# 

```



## 7.显示MySQL数据库的版本

```
[root@docker201.myworld.com ~]# mysql -S /tmp/mysql23307.sock -V
mysql  Ver 14.14 Distrib 5.7.31, for linux-glibc2.12 (x86_64) using  EditLine wrapper
[root@docker201.myworld.com ~]# 

```



## 8.获取程序默认使用的配置

```
[root@docker201.myworld.com ~]# mysql --print-defaults 
mysql would have been started with the following arguments:

[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# mysql --print-defaults -S /tmp/mysql23307.sock 
mysql would have been started with the following arguments:
-S /tmp/mysql23307.sock 
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# mysql --print-defaults -S /tmp/mysql23307.sock -u root -p -P 23307
mysql would have been started with the following arguments:
-S /tmp/mysql23307.sock -u root -p -P 23307 
[root@docker201.myworld.com ~]# 
[root@docker201.myworld.com ~]# 

```



## 9.其它用法

```
[root@docker201.myworld.com ~]# man mysql
```



# 十一.将MySQL客户端的配置写入配置文件，这些配置就会永久生效。

```
[root@docker201.myworld.com ~]# cat /etc/my.cnf-2021-01-10  # 注意哈，当前的配置文件并不会生效，这是我之前修改的备份文件 
[mysqld]
user=mysql
basedir=/myworld/softwares/mysql/mysql
datadir=/myworld/data/mysql
log_error=/myworld/logs/mysql/mysql.err
socket=/tmp/mysql.sock

[mysql]  # 指定mysql客户单工具的默认配置参数
socket=/tmp/mysql.sock
prompt="\u@[\d]->"
[root@docker201.myworld.com ~]# 

关于prompt参数说明:
    \u:
        表示用户名。
    \d:
        表示当前所在的数据库。
    \D:
    	显示时间。

```





# 十二.SQL的介绍

```
    所谓的SQL就是结构化查询语言，它们是关系型数据库中通用的一类语言，SQL是用于访问和处理数据库的标准的计算机语言。

    什么是SQL:
        (1)指结构化查询语言
        (2)使我们有能力访问数据库
        (3)是一种ANSI(美国国家标准化组织)的标准计算机语言

    SQL能做什么:
        (1)面向数据库执行查询
        (2)可从数据库取回数据
        (3)可在数据库中插入新的记录
        (4)可更新数据库中的数据
        (5)可从数据库删除记录
        (6)可创建新数据库
        (7)可在数据库中创建新表
        (8)可在数据库中创建存储过程
        (9)可在数据库中创建视图
        (10)可以设置表、存储过程和视图的权限
        ....

    SQL是一种标准:
        (1)SQL是一门ANSI的标准计算机语言，用来访问和操作数据库系统。SQL 语句用于取回和更新数据库中的数据。SQL 可与数据库程序协同工作，比如 MS Access、DB2、Informix、MS SQL Server、Oracle、Sybase 以及其他数据库系统。
        (2)不幸地是，存在着很多不同版本的 SQL 语言，但是为了与 ANSI 标准相兼容，它们必须以相似的方式共同地来支持一些主要的关键词（比如 SELECT、UPDATE、DELETE、INSERT、WHERE 等等）。
        (3)除了SQL标准之外，大部分SQL数据库程序都拥有它们自己的私有扩展！

    参考连接:
        https://www.w3school.com.cn/sql/sql_intro.asp
```



# 十三.SQL常用类型

## 1.mysql 客户端自带的命令

```
    我们在服务器通常会使用MySQL server自带的工具，即mysql客户端来连接MySQL server，因此对于mysql客户端命令的使用有一个基本的了解很有必要，尽管它们并非是SQL语言，如下所示:
        mysql> HELP
        
        For information about MySQL products and services, visit:
           http://www.mysql.com/
        For developer information, including the MySQL Reference Manual, visit:
           http://dev.mysql.com/
        To buy MySQL Enterprise support, training, or other products, visit:
           https://shop.mysql.com/
        
        List of all MySQL commands:
        Note that all text commands must be first on line and end with ';'
        ?         (\?) Synonym for `help'.
        clear     (\c) Clear the current input statement.
        connect   (\r) Reconnect to the server. Optional arguments are db and host.
        delimiter (\d) Set statement delimiter.
        edit      (\e) Edit command with $EDITOR.
        ego       (\G) Send command to mysql server, display result vertically.
        exit      (\q) Exit mysql. Same as quit.
        go        (\g) Send command to mysql server.
        help      (\h) Display this help.
        nopager   (\n) Disable pager, print to stdout.
        notee     (\t) Don't write into outfile.
        pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
        print     (\p) Print current command.
        prompt    (\R) Change your mysql prompt.
        quit      (\q) Quit mysql.
        rehash    (\#) Rebuild completion hash.
        source    (\.) Execute an SQL script file. Takes a file name as an argument.
        status    (\s) Get status information from the server.
        system    (\!) Execute a system shell command.
        tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
        use       (\u) Use another database. Takes database name as argument.
        charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
        warnings  (\W) Show warnings after every statement.
        nowarning (\w) Don't show warnings after every statement.
        resetconnection(\x) Clean session context.
        
        For server side help, type 'help contents'
        
        mysql> 
    
    上述的每个命令我们可能不会一一介绍，但常用的选项我会有对应的文章进行编写。

```



## 2.MySQL server端自带的命令

```
    我们可以通过"HELP CONTENTS"命令来查看MySQL对数据库SQL语言的分类，如下所示:
        mysql> HELP CONTENTS
        You asked for help about help category: "Contents"
        For more information, type 'help <item>', where <item> is one of the following
        categories:
           Account Management
           Administration
           Compound Statements
           Contents
           Data Definition
           Data Manipulation
           Data Types
           Functions
           Geographic Features
           Help Metadata
           Language Structure
           Plugins
           Procedures
           Storage Engines
           Table Maintenance
           Transactions
           User-Defined Functions
           Utility
        
        mysql> 
    
    刚刚看到上述的分类可能迷糊，没关系，我们可以查看某一个类型对应了哪些SQL语句，比如我们来查看数据定义相关的SQL语句，如下所示:
        mysql> HELP Data Definition
        You asked for help about help category: "Data Definition"
        For more information, type 'help <item>', where <item> is one of the following
        topics:
           ALTER DATABASE
           ALTER EVENT
           ALTER FUNCTION
           ALTER INSTANCE
           ALTER LOGFILE GROUP
           ALTER PROCEDURE
           ALTER SCHEMA
           ALTER SERVER
           ALTER TABLE
           ALTER TABLESPACE
           ALTER VIEW
           CREATE DATABASE
           CREATE EVENT
           CREATE FUNCTION
           CREATE INDEX
           CREATE LOGFILE GROUP
           CREATE PROCEDURE
           CREATE SCHEMA
           CREATE SERVER
           CREATE TABLE
           CREATE TABLESPACE
           CREATE TRIGGER
           CREATE VIEW
           DROP DATABASE
           DROP EVENT
           DROP FUNCTION
           DROP INDEX
           DROP PROCEDURE
           DROP SCHEMA
           DROP SERVER
           DROP TABLE
           DROP TABLESPACE
           DROP TRIGGER
           DROP VIEW
           FOREIGN KEY
           RENAME TABLE
           TRUNCATE TABLE
        
        mysql> 

    温馨提示:
        尽管上述的对于SQL的分类繁多，我们不可能一一讲解，但我们会讲解常用的SQL语句，当然，我们会将常用的SQL进行再次分类如下:
            Data Definition Language：
                即"数据定义语言"，简称DDL。是用于描述数据库中要存储的现实世界实体的语言。
            Data Manipulation Language:
                即"数据操纵语言"，简称"DML"。用户通过它可以实现对数据库的基本操作(例如，对表中数据的插入、删除和修改)。
            Data Query Language：
                即"数据查询语言"，简称"DQL"。用户通过它用于数据查询语言，其语法格式：SELECT ... FROM ... WHERE。严格一样上来讲它应该属于DML的一个子类，只不过它实在太重要了，因此我们通常把它单独拿出来说。
            Data Control Language:
                即"数据控制语言"，简称"DCL"。是用来授予或回收访问数据库的某种特权，并控制数据库操纵事务发生的时间及效果，对数据库实行监视等。
            Transaction Control Language:
                即"事物控制语言"，简称"TCL"。有些学术派将DCL中的事物相关的操作归纳为事务控制语言，关键字：COMMIT、ROLLBACK、SAVEPOINT。

```



# 十四.MySQL Community 5.6，MySQL Community 5.7和MySQL Community 8.0的SQL_MODE各有不同

```
    SQL_MODE:
        规范SQL语句书写方式。我们可以通过"SELECT @@SQL_MODE;"命令来查看当前MySQL数据库实例的默认SQL_MODE。
            mysql> SELECT @@SQL_MODE;
            +-------------------------------------------------------------------------------------------------------------------------------------------+
            | @@SQL_MODE                                                                                                                                |
            +-------------------------------------------------------------------------------------------------------------------------------------------+
            | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION |
            +-------------------------------------------------------------------------------------------------------------------------------------------+
            1 row in set (0.00 sec)
            
            mysql> 

    案例1 ---> ERROR_FOR_DIVISION_BY_ZERO:
        综上所述，SQL_MODE定义了很多不允许的操作，比如在现实的数学角度，除法运算中，除数不能为零。
        为了保证符合现实的数学逻辑，也需要保证除数不能为0，所以MySQL通过设定SQL_MODE="ERROR_FOR_DIVISION_BY_ZERO"参数值，规范我们的除法运算，从而保证不会出现违背现实数学逻辑的SQL语句。
    
    案例2 ---> NO_ZERO_IN_DATE，NO_ZERO_DATE
        在现实情况下，我们描述日期时，0年0月0日在现实中是不被允许的。因此可以通过设定SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE"参数值，以规范我们写入日期的格式。

    案例3 --->
        下面的表结构来自官方提供的测试数据(再讲DQL时会有如何获取对应的资源)，想要统计中国每个省总人口数，城市个数，城市名列表等信息。ONLY_FULL_GROUP_BY的SQL_MODE报错案例如下所示:(MySQL 5.6版本可能测试不出来，推荐MySQL 5.7+)
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
                5 rows in set (0.01 sec)
                
                mysql> 
                mysql> SELECT District,SUM(Population),COUNT(ID),name FROM city WHERE CountryCode='CHN' GROUP BY District;
                ERROR 1055 (42000): Expression #4 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'world.city.Name' which is not functionally dependent on columns in GROUP BY cla
                use; this is incompatible with sql_mode=only_full_group_by
                mysql>
 
        以上案例报错原因分析:
            根据上述报错信息已经说明了，说是表达式中第四个查询字段("#4")不在GROUP BY子句中，并且'world.city.Name'这个列未聚合(nonaggregated)，换句话说，就是'world.city.Name'这个列没有使用聚合函数。
            综上所述，在使用GROUP BY子句中，其查询字段要么在GROUP BY子句中，要么就得使用聚合函数，若不这样做，则MySQL 5.7+版本就会抛出上述错误，因为SQL_MODE定义了"ONLY_FULL_GROUP_BY"规则。
            这是因为MySQL不支持结果集是1行对多行的显示方式，因为'world.city.Name'是一个字段列，对应多行数据，而SUM(Population),COUNT(ID)只显示一行，而"GROUP BY District"自带去重效果，他们的每个元素对应一行数据。    

        解决方案:
            mysql> SELECT District,SUM(Population),COUNT(ID),GROUP_CONCAT(name) FROM city WHERE CountryCode='CHN' GROUP BY District;  # GROUP_CONCAT聚合函数可以将一列数据转成一行并用逗号分割。


    温馨提示:
        随着数据库的版本不一致，其对应的SQL_MODE可能也有所不同，如下所示。
        MySQL Community 5.6的默认启用的SQL_MODE如下所示:
            [root@docker201.yinzhengjie.com ~]# mysql -S /tmp/mysql23306.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 1
            Server version: 5.6.49-log MySQL Community Server (GPL)
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> SELECT @@SQL_MODE;
            +------------------------+
            | @@SQL_MODE             |
            +------------------------+
            | NO_ENGINE_SUBSTITUTION |
            +------------------------+
            1 row in set (0.00 sec)
            
            mysql> 

        MySQL Community 5.7的默认启用的SQL_MODE如下所示:
            [root@docker201.yinzhengjie.com ~]# mysql -S /tmp/mysql23307.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 4
            Server version: 5.7.31-log MySQL Community Server (GPL)
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> 
            mysql> SELECT @@SQL_MODE;
            +-------------------------------------------------------------------------------------------------------------------------------------------+
            | @@SQL_MODE                                                                                                                                |
            +-------------------------------------------------------------------------------------------------------------------------------------------+
            | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION |
            +-------------------------------------------------------------------------------------------------------------------------------------------+
            1 row in set (0.00 sec)
            
            mysql> 

        MySQL Community 8.0的默认启用的SQL_MODE如下所示:
            [root@docker201.yinzhengjie.com ~]# mysql -S /tmp/mysql23308.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 8
            Server version: 8.0.21 MySQL Community Server - GPL
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> SELECT @@SQL_MODE;
            +-----------------------------------------------------------------------------------------------------------------------+
            | @@SQL_MODE                                                                                                            |
            +-----------------------------------------------------------------------------------------------------------------------+
            | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION |
            +-----------------------------------------------------------------------------------------------------------------------+
            1 row in set (0.00 sec)
            
            mysql> 

```





# 十五.SQL的范式

```
第一范式(1NF)
	数据表的每一列都要保持它的原子特性，也就是列不能再被分割。
	
第二范式(2NF)
	属性必须完全依赖于主键。
	
第三范式(3NF)
	所有的非主属性不依赖于其他的非主属性。
```

