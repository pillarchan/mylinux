[TOC]



# 一.MySQL的索引基础知识

## 1.什么是索引

```
    索引可以看作是一本书籍(比如"<<西游记>>")的目录，为了快速检索，用空间换时间，显著提高查询效率。换句话说，目录索引可以帮我们快速找到所需的数据页码(比如我们想要看"大闹天宫"的章节)，起到优化查询的功能。

    在MySQL中，索引也叫做"键(KEY)"，它是存储引擎用于快速找到记录的一种数据结构。存储引擎用上述案例类似的方法使用索引，其先在索引中找到对应值，然后根据匹配的索引记录找到对应的数据行。

    索引可以包含一个或多个列的值，如果索引包含多个列，那么列的顺序也十分重要，因为MySQL只能高效地使用索引的最左侧前缀列。创建一个包含两个列的索引，和创建两个只包含一列的索引是大不相同的，后续会有相应的案例说明。

    索引对于良好的性能非常关键，尤其是当表中的数据量越来越大时，索引对性能的影响愈发重要。在数据量较小且负载较低时，不恰当的索引对性能的影响可能还不明显，但当数据量逐渐增大时，性能则会急剧下降。

```



## 2.如果使用的是"Object Relational Mapping"(简称:"ORM")，是否还需要关心索引?

```
    简而言之，是的，仍然需要理解索引，即使是使用对象关系映射(英文全称: "Object Relational Mapping"，简称:"ORM")工具。

    ORM工具大多数时候能够生产符合逻辑的，合法的查询，除非只是生成非常基本的查询(例如仅是根据主键查询)，否则它很难生成适合索引的查询。

    无论是多么复杂的ORM工具，在精妙和复杂的索引面前都是"浮云"。很多时候，即使是查询优化技术专家也很难兼顾到各种情况，跟别提ORM了。
```



## 3.索引的优缺点:star:

```
索引是为了实现优化查询的目的,用磁盘存储空间换查询时间。

优点:
	(1)索引可以降低服务器需要扫描的数据量，减少了IO次数;
	(2)索引可以帮助服务器避免排序和使用临时表;
	(3)索引可以帮助将随机I/O转为顺序I/O;
                                                                
缺点:
	占用额外空间，影响插入速度。                                                         
```



## 4.索引是最好的解决方案吗?

```
    索引并不总是最好的工具。总的来说，只有当索引帮助存储引擎快速找到记录带来的好处大于其带来的额外工作时，索引才会是有效的。
        (1)对于非常小的表，大部分情况下简单的全表扫描更高效;
        (2)对于中到大型的表，索引就非常有效;

    但对于特大型的表，建立和使用索引的代价将随之增长，在这种情况下，则需要一种技术可以直接区分出查询所需的一组数据，而不是一条记录一条记录的匹配。例如使用分区表技术。

    综上所述，我们可以总结以下两点:
        (1)不是说有了索引性能就一定能提升，有了索引咱们还得会利用索引，用正确的方法使用索引，使用不当反而会降低服务器性能。
        (2)由于索引本身是需要占用一定的存储空间的，在数据量较小的情况下设置索引可能看不到明显的优化效果，而且可能还会感觉有性能下降的趋势，因为每插入一条数据，可能都得维护对应的索引记录(这就好像你使用优秀的压缩算法来压缩小文件一样);

```



## 5.索引的"三星系统"

```
    "索引"这个主体完全值得单独写一本书，如果想要深入理解这部分内容，强烈建议阅读由Tapio Lahdenmaki和Mike Leach缩写的Relational Database Index Design and the Optimizers(Wiley 出版社)一书。

    该书详细介绍了如何计算索引的成本和作用，如何评估查询速度，如何分析索引维护的代价和其带来的好处等。当然，英文能力不是特别的好的小伙伴也可以阅读中文翻译版本"<<数据库索引设计与优化>>"

    Lahdenmaki和Leach在书中介绍了如何评价一个索引是否适合某个查询的"三星系统(three-star system)":
        (1)索引将相关的记录放到一起则获得一星;
        (2)如果索引中的数据顺序和查找中的排序顺序一致则获得二星;
        (3)如果索引中的列包含了查询中需要的全部列则获得"三星";
```



## 6.MySQL使用何种算法实现索引技术呢?

```
    经过上述的说明，很多小伙伴对索引特点应该有一定的了解了，也知道索引是有序的概念。那么MySQL底层各个存储引擎到底是如何实现索引的呢？它们的底层算法是怎样的呢？

    一说到有顺序的数据结构，很多小伙伴可能张嘴典型的入门算法，比如：二分查找法，折半查找法，二叉树等等。

    可惜呀，上述的查找方法MySQL均未使用，而是默认使用更高效的B-Tree索引。当然还有其它类型的索引，比如:"哈希索引","数据空间索引(R-Tree)","全文索引"等等。

    除了要了解MySQL的索引类型，我们还得了解高性的索引策略，比如:"独立的列","前缀索引和索引选择性","多列索引","选择合适的索引列顺序","聚簇索引","覆盖索引"等等。
```





# 二.MySQL的高性能的索引策略

## 1.索引策略概述

```
    聚簇索引:
        MySQL的InnoDB底层默认就是基于聚簇索引实现数据的存储和读取的。无需人为构建索引。

    辅助索引作用:
        使用普通列作为条件构建的索引我们称之为"辅助索引"。其能优化非聚簇索引列之外的查询条件的优化。需要人为构建索引，且辅助索引可能会发起回表查询。
        辅助索引分为单列索引，多列索引(也成为"联合索引")，前缀索引等等。

    回表会带来什么影响(总的来说就是对I/O有影响):
        (1)I/O量级变大;
        (2)IOPS会增大;
        (3)随机I/O会增大;

    怎么减少回表:
        (1)将查询尽可能用ID主键查询;
        (2)设计合理的联合索引;
        (3)尽量基于联合索引精确匹配查询条件，这样返回的结果集就越少，从而有效的减少回表次数;
        (4)MySQL的优化器算法MRR: 自行查阅相关资料

    温馨提示:
        对于聚簇索引，对数据做了一些DML操作(比如: "INSERT","UPDATE","DELETE"等SQL语句)数据的变化会立即更新数据，而对于辅助索引，却不是实时更新的。
        接下来我们分析一下数据的查询流程如下所示:
            (1)首先InnoDB在本地磁盘存储索引是以"*.ibd"文件进行存储的，当要查询数据时，需要将磁盘的数据读取到内存中在返回给用户;
            (2)当用户做的是修改操作时，如果改动的是聚簇索引，则会立即将修改同步到磁盘上;
            (3)如果改动的是辅助索引，则不会立即同步数据到磁盘，因为大多数情况下用户做的修改操作都是基于辅助索引来实现的，因此在InnoDB内存结构中，早期版本加入了INSERT BUFFER(基于每个会话级别，内存大小我们可以控制)，现在版本叫CHANGE BUFFER(临时缓冲辅助索引需要的数据更新)，顾名思义，早期主要是对INSERT操作做BUFFER，现在的版本会针对INSERT,UPDATE,DELETE等操作进行BUFFER。换句话说，就是将辅助索引的修改存储在CHANGE BUFFER当中，并不会事实同步到磁盘;
            (4)当用户从磁盘上查询的是辅助索引的数据时，会将数据从磁盘加载到内存，而后再将其余CHANGE BUFFER的内容进行合并(merge)，而后可能需要回表查询聚簇索引的表，由于聚簇索引的数据是事实更新的，因此数据的查询准确性是无误的，而后将最终查询的最新数据返回给客户端;
            (5)如果辅助索引的CHANGE BUFFER的数据被查询到了，说明已经经过在内存merge的阶段，此时会将内存中的数据落地到本地磁盘，在数据落地到磁盘的过程中，这个过程会涉及到加锁的一些流程，后续文章会陆续介绍到;
        如果对InnoDB的存储引擎及查询机制还是有点懵的小伙伴别着急，后续还有专门的章节介绍存储引擎。这里先有个印象！
```



## 2.聚簇索引概述

### MySQL默认存储引擎InnoDB逻辑划分为page,extent,sengment

```
    page(译为:"页"):
        通常指4个连续的block，这意味着一个page默认的大小是16KB，也就是说在底层使用的是连续的16KB存储空间，它是最小的I/O单元。
        综上所述，我们在写入和读取数据时都只能基于page来进行操作，因此你就别想只读取或写入某个字段了，因为在查询的过程中，会直接将一个page取出，对该page进行遍历读取数据或修改数据，对于TB级别的“大表”来说，MySQL可能会显得很吃力。

    extent(译为:"区"，"簇"):
        通常指64个连续的page，这意味着一个extent默认的大小是16KB * 64 = 1MB，也就是说在底层使用的是连续的1MB存储空间。

    segment(译为:"段"，但"分区表"除外!)
        值得注意的是，segment通常指的是表的存储单位，它底层采用的是多个extent来存储数据，但是这多个extent并不一定连续。
        因为数据是持续写入的，我们的表也是大小不一的，有的表只用于测试仅有几KB大小，有的表生产环境比较大，甚至达到TB级别。
        
        
    温馨提示:
    	segment表现为表,但并不是表,因为表对应的是表空间，而表空间对应的是多个segment.
```

![image-20210716171108447](08-老男孩教育-MySQL索引及执行计划.assets\image-20210716171108447.png)



### 聚簇索引B+Tree构建过程

```
    所谓的聚簇索引，我们可以理解为上面提到的聚区(extent)索引，聚簇索引是InnoDB存储引擎独有的，别的存储引擎是没有聚簇索引的(当然，NDB集群自然也是支持聚簇索引的)。

    聚簇索引的作用:
        有了聚簇索引之后，将来在插入数据行，在同一个区(extent)内，都会按照ID值的顺序，有序在磁盘存储数据。这意味着将来在读数据时，顺序写入磁盘的数据也将被顺序读出，减少了磁盘寻道时间，从而大大提升查询效率。
        在MySQL的默认存储引擎InnoDB表中，都是以聚簇索引组织存储数据表的。

    聚簇索引的构建前提:
        (1)建表时，指定了主键列，MySQL InnoDB会将主键自动作为聚簇索引列，如下案例，其中"oldboyedu.student"表中的id字段会作为聚簇索引的列;
        (2)如果没有指定主键列，则会选择唯一键的列，作为聚簇索引列;            
        (3)如果你既没有指定指定主键字段，也没有指定唯一键字段，则InnoDB会生成隐藏的聚簇索引;
            mysql> CREATE DATABASE IF NOT EXISTS oldboyedu DEFAULT CHARACTER SET = utf8mb4;
            Query OK, 1 row affected (0.00 sec)
            
            mysql> 
            mysql> CREATE TABLE IF NOT EXISTS oldboyedu.student (
                ->     id int PRIMARY KEY AUTO_INCREMENT COMMENT '学生编号ID',
                ->     name varchar(30) NOT NULL COMMENT '学生姓名',
                ->     age tinyint UNSIGNED DEFAULT NULL COMMENT '年龄',
                ->     gender enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
                ->     time_of_enrollment  DATETIME(0) COMMENT '报名时间',
                ->     address varchar(255) NOT NULL COMMENT '家庭住址',
                ->     mobile_number bigint UNIQUE KEY NOT NULL COMMENT '手机号码',
                ->     remarks VARCHAR(255) COMMENT '备注信息'
                -> ) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
            Query OK, 0 rows affected (0.31 sec)    
            mysql>     
    
    如下图所示，展示了聚簇索引B+Tree构建过程。
```

![image-20210716172444755](08-老男孩教育-MySQL索引及执行计划.assets\image-20210716172444755.png)



## 3.辅助索引B+Tree结构-使用普通列作为条件构建的索引

### 单列索引

```
    建表语句:
            mysql> CREATE DATABASE IF NOT EXISTS oldboyedu DEFAULT CHARACTER SET = utf8mb4;
            Query OK, 1 row affected (0.00 sec)
            
            mysql> 
            mysql> CREATE TABLE IF NOT EXISTS oldboyedu.student (
                ->     id int PRIMARY KEY AUTO_INCREMENT COMMENT '学生编号ID',
                ->     name varchar(30) NOT NULL COMMENT '学生姓名',
                ->     age tinyint UNSIGNED DEFAULT NULL COMMENT '年龄',
                ->     gender enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
                ->     time_of_enrollment  DATETIME(0) COMMENT '报名时间',
                ->     address varchar(255) NOT NULL COMMENT '家庭住址',
                ->     mobile_number bigint UNIQUE KEY NOT NULL COMMENT '手机号码',
                ->     remarks VARCHAR(255) COMMENT '备注信息'
                -> ) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
            Query OK, 0 rows affected (0.31 sec)    
            mysql>    

    为"oldboyedu.student"表的"name"字段创建辅助索引:
        ALTER TABLE oldboyedu.student ADD INDEX idx(name);

    运行以下查询语句:
        SELECT * FROM oldboyedu.student WHERE name='尹%'

    SQL执行流程分析:
        分析:
            首先根据我们的单列索引name字段来查询，并非利用聚簇索引来查询数据，而且查询的结果是SELECT "*",表示获取所有匹配的行。
        查询流程如下:
            (1)如下图所示，首先单列索引(本案例是name)和聚簇索引(本案例是id)会被单独拿出来而后根据name字段进行排序，当然，这需要占用一定的磁盘空间;
            (2)接下来会根据用户查询的name字段来进行查询，辅助索引会返回匹配的查询结果;
            (3)根据select的投影字段是否需要整行数据，如果需要则会进行回表查询(换句话说，就是再发起依次I/O查询)，这次查询则基于聚簇索引的列来进行数据查询,从而避免了对整表的数据查询;
            

```

### 多列索引(也成为"联合索引")

```
    为"oldboyedu.student"表的"name"字段创建辅助索引:
        ALTER TABLE oldboyedu.student ADD INDEX idx(name,gender,time_of_enrollment);

    运行以下查询语句:
        SELECT * FROM oldboyedu.student WHERE name='尹%' AND gender='Male';

    SQL执行流程分析:
        分析:
            首先根据我们的辅助索引name字段来查询，并非利用聚簇索引来查询数据，而且查询的结果是SELECT "*",表示获取所有匹配的行。
        查询流程如下:
            (1)如下图所示，首先联合索引(本案例是name和gender)和聚簇索引(本案例是id)会被单独拿出来而后根据name和gender字段进行排序，当然，这需要占用一定的磁盘空间;
            (2)接下来会根据用户查询的name和gender字段来进行查询，辅助索引会返回匹配的查询结果;
            (3)根据select的投影字段是否需要整行数据，如果需要则会进行回表查询(换句话说，就是再发起依次I/O查询)，这次查询则基于聚簇索引的列来进行数据查询,从而避免了对整表的数据查询;

    联合索引:
        联合索引就是由多列构建同一个索引。

    联合索引的最左原则，比如上面的案例"idx(name,gender)"，需要注意以下节点:
        (1)查询条件中，必须要包含最左列，上面例子就是name列(比如"SELECT * FROM oldboyedu.student WHERE name='尹%' AND gender='Male';");
        (2)建立索引时，一定要选择重复值最少的列，作为最左侧列(必须name的重复可能性要比gender重复的可能性要高，究其原因是gender只有Male和Female属性);

    以下SQL通常会全部覆盖索引，尽管我们没有将联合索引放在最左侧，但MySQL的优化器会做一定的语句优化:
        SELECT * FROM oldboyedu.student WHERE name='尹%' AND gender='Male' AND time_of_enrollment='...';
        SELECT * FROM oldboyedu.student WHERE name IN ('尹%',) AND gender IN ('Male',) AND time_of_enrollment IN (...);
        SELECT * FROM oldboyedu.student WHERE gender IN ('Male',) AND name IN ('尹%',) AND time_of_enrollment IN (...);

    以下SQL通常会部分覆盖索引，
        SELECT * FROM oldboyedu.student WHERE name='尹%' AND time_of_enrollment='...';
        SELECT * FROM oldboyedu.student WHERE name IN ('尹%',) AND time_of_enrollment IN (...);
        SELECT * FROM oldboyedu.student WHERE gender IN ('Male',) AND time_of_enrollment IN (...);
    
```

### 前缀索引

```
    前缀索引时针对于我们所选择的索引列值长度过长，会导致索引树高度增高，所以可以选择大字段的前面部分(即前缀部分)作为索引生成条件(这种手段开发的小伙伴应该经常见到，比如: git的版本控制编号)，会导致索引应用时，需要读取更多的索引数据页。

    MySQL中建议索引树高度3-4层。比如生产环境中的一张表有30多个字段，通常数据行数不建议超过1000万行，如果超过了1000万行就得采取一定的措施来拆表进行优化。
```



## 4.B+Tree索引树高度印象因素

```
    (1)索引字段较长:
        解决方案：前缀索引。
        
    (2)数据行过多:
        解决方案: 早期方案是分区表，目前主流的可以采用归档表(可以手动创建归档表，当然也可以利用pt-archive这类工具实现)和分布式架构(通常在大企业中会使用)。
        
    (3)数据类型：
        建议选择合适的数据类型，比如CHAR和VARCHA的选择。
```



# 三.MySQL索引常用的管理命令及索引的压力测试

## 1.索引管理命令

### 1.1什么时候创建索引

```
    按照业务语句的需求创建合适的索引，并不是将所有列都建立索引。索引需要占用一定的存储空间，不是索引越多越好。

    换句话说，建议将索引建立在经常"WHERE","GROUP BY", "ORDER BY","JOIN ON"相关的关键字后常用的字段来建立索引。

    为什么不能乱建索引:    
        (1)如果冗余索引过多，当表的数据发生变化时，很有可能导致索引频繁更新，会阻塞很多正常的业务更新的请求;
        (2)索引过多，可能会导致MySQL的优化器选择出现偏差;

```

### 1.2查看索引信息

#### 1.2.1基于"DESC 表名称"命令查询关注"Key"字段

```
    如下所示，我们可以基于表结构观察该表现有的索引信息:
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

    请仔细观察DESC表结构的Key字段，可能会出现如下三种情况:
        (1)PRI:
            聚簇索引。
        (2)MUL：
            辅助索引。
        (3)UNI:
            唯一索引。
```

#### 1.2.2基于"SHOW INDEX FROM 表名称"查看表索引的详细信息

```
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)

mysql> 



相关字段说明:
	Table: 
		表的名称。
   Non_unique: 
   		该列字段是否有唯一约束,如果没有则为1,如果有,则为0.
     Key_name: 
     	索引的名称,如果是主键的话,则始终为"PRIMARY"
 Seq_in_index: 
		索引中的列序列号，默认以1开头。
  Column_name: 
  		列的名称.
    Collation: 
    	列在索引中的排序方式。这可以有一个值A（升序）、D（降序）或NULL（未排序）
  Cardinality: 
  		索引的基数,简单理解为该索引的评分数。
  		如果一个字段配置了多个索引,这个时候该值越大那么走该索引的可能性就越高。
     Sub_part: 
     	是否未前缀索引，如果是前缀索引,说明并没有将整个字段设置为索引,而是将该字段一部分前缀设置为索引。
     	当该值为NULL时,说明该索引并不是前缀索引。
       Packed: 
       	指示索引KEY的打包方式。如果不是，则为NULL。
         Null: 
         如果列可能包含NUL值，则为YES；如果不包含NULL值，则包含""。
   Index_type: 
   		索引在类型，默认均为BTREE，可以包含的值为: BTREE, FULLTEXT, HASH, RTREE。
        Comment: 
      	有关索引的信息未在其自己的列中描述，比如当前索引被禁用时为"disable"。
Index_comment: 
		创建索引时，为索引提供的带有注释属性的任何注释。
      Visible: 
      索引是否对优化器可见，默认是YES.
	  详情请参考 https://dev.mysql.com/doc/refman/8.0/en/invisible-indexes.html.
   Expression: 
	  MySQL 8.0.13及更高版本支持功能关键部件。
   	  请参见 https://dev.mysql.com/doc/refman/8.0/en/create-index.html#create-index-functional-key-parts

```

### 1.3创建索引

#### 1.3.1使用"ALTER TABLE"语句来创建索引

```
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)

mysql> 
mysql> ALTER TABLE city ADD INDEX index_name(name);  # 创建名称为"index_name"的索引
Query OK, 0 rows affected (0.35 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name  |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
3 rows in set (0.00 sec)

mysql> 

```

#### 1.3.2使用"CREATE INDEX"语句来创建索引

```
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name  |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
3 rows in set (0.00 sec)

mysql> 
mysql> CREATE INDEX my_index_test01 ON city(Population);  # 注意哈,我们还可以使用"CREATE INDEX"语句来创建索引哟~
Query OK, 0 rows affected (0.12 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> 
mysql> DESC city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   | MUL |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   | MUL | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> 
mysql> SHOW INDEX FROM city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
4 rows in set (0.00 sec)

mysql> 

```

#### 1.3.3创建联合索引

```
mysql> SHOW INDEX FROM city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
4 rows in set (0.00 sec)

mysql> DESC city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   | MUL |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   | MUL | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> 
mysql> CREATE INDEX my_index01 ON city(Name,CountryCode,Population);  # 我们可以将多个字段设置为索引
Query OK, 0 rows affected (0.60 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> ALTER TABLE city ADD INDEX my_index02(Name,CountryCode,Population);  # 我们也可以对多个相同字段创建索引！
Query OK, 0 rows affected, 1 warning (0.05 sec)
Records: 0  Duplicates: 0  Warnings: 1

mysql> 
mysql> DESC city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   | MUL |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   | MUL | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> 
mysql> SHOW INDEX FROM city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
10 rows in set (0.00 sec)

mysql> 

```

#### 1.3.4创建前缀索引案例

```
mysql> SHOW INDEX FROM city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
10 rows in set (0.00 sec)

mysql> 
mysql> DESC city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   | MUL |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   | MUL | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> 
mysql> ALTER TABLE city ADD INDEX my_index03(District(5));  # 注意哈，此处我创建的是前缀索引，即District(5)，表示当District字段的数据超过5个长度时，会截取前5个子串作为索引!
Query OK, 0 rows affected (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> CREATE INDEX my_index05 ON city(District(8));
Query OK, 0 rows affected (0.07 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> SHOW INDEX FROM city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index01      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index02      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
12 rows in set (0.02 sec)

mysql> 
mysql> DESC city;
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   | MUL |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   | MUL |         |                |
| Population  | int(11)  | NO   | MUL | 0       |                |
+-------------+----------+------+-----+---------+----------------+
5 rows in set (0.01 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM city WHERE District LIKE 'Zuid';
+----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    1 |   100.00 | Using where |
+----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM city WHERE District LIKE 'Zuid%';
+----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    6 |   100.00 | Using where |
+----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

mysql> 

```

### 1.4修改索引

```
mysql> SHOW INDEX IN clothing;
+----------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table    | Non_unique | Key_name             | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+----------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| clothing |          0 | PRIMARY              |            1 | id          | A         |         120 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyeud_linux      |            1 | item        | A         |         112 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | brand                |            1 | brand       | A         |          81 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | brand                |            2 | producer    | A         |          89 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_index      |            1 | brand       | A         |          81 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_index      |            2 | producer    | A         |          89 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_linux_2021 |            1 | name        | A         |         100 |        5 |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_linux_2021 |            2 | item        | A         |         100 |       10 |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_linux_2021 |            3 | producer    | A         |         100 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+----------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
9 rows in set (0.01 sec)

mysql> 
mysql> ALTER TABLE clothing RENAME INDEX  brand TO oldboyedu_brand;
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> SHOW INDEX IN clothing;
+----------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table    | Non_unique | Key_name             | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+----------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| clothing |          0 | PRIMARY              |            1 | id          | A         |         120 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyeud_linux      |            1 | item        | A         |         112 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_brand      |            1 | brand       | A         |          81 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_brand      |            2 | producer    | A         |          89 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_index      |            1 | brand       | A         |          81 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_index      |            2 | producer    | A         |          89 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_linux_2021 |            1 | name        | A         |         100 |        5 |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_linux_2021 |            2 | item        | A         |         100 |       10 |   NULL |      | BTREE      |         |               | YES     | NULL       |
| clothing |          1 | oldboyedu_linux_2021 |            3 | producer    | A         |         100 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+----------+------------+----------------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
9 rows in set (0.00 sec)

mysql> 
```

### 1.5删除索引

```
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name  |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
3 rows in set (0.00 sec)

mysql> 
mysql> ALTER TABLE city DROP INDEX index_name;
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)

mysql> 

```



## 2.使用执行计划分析命令EXPLAIN来查看本次查询是否用到了咱们创建的索引(后面有详细章节介绍EXPLAIN,这里先混个眼熟)

```
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM city WHERE name = 'shanghai';  # 注意观察type的值，如果是ALL表示本次查询是全局扫描。
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | city  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 4046 |    10.00 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.00 sec)

mysql> 
mysql> ALTER TABLE city ADD INDEX index_name(name);  # 创建名称为"index_name"的索引
Query OK, 0 rows affected (0.35 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name  |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
3 rows in set (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM city WHERE name = 'shanghai';  # 注意观察type的值，如果是"ref"表示本次查询是走的索引，而后possible_keys,key记录了走的是哪个索引。
+----+-------------+-------+------------+------+---------------+------------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key        | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | city  | NULL       | ref  | index_name    | index_name | 140     | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+------------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

mysql> 
mysql> 

```



## 3.压力测试(压力测试可以比"EXPLAIN"命令看起来更有说服力!)

### 3.1创建测试表及存储过程并导入MySQL数据库

```
[root@mysql108.oldboyedu.com ~]# vim student.sql 
[root@mysql108.oldboyedu.com ~]# 
[root@mysql108.oldboyedu.com ~]# cat student.sql 
# author :
#	oldboyedu


# 创建数据库
CREATE DATABASE IF NOT EXISTS oldboyedu DEFAULT CHARACTER SET = utf8mb4;

# 创建表结构
CREATE TABLE IF NOT EXISTS oldboyedu.student (
    id int PRIMARY KEY AUTO_INCREMENT COMMENT '学生编号ID',
    name varchar(30) NOT NULL COMMENT '学生姓名',
    age tinyint UNSIGNED DEFAULT NULL COMMENT '年龄',
    gender enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
    time_of_enrollment  DATETIME(0) COMMENT '报名时间',
    address varchar(255) NOT NULL COMMENT '家庭住址',
    mobile_number bigint UNIQUE KEY NOT NULL COMMENT '手机号码',
    remarks VARCHAR(255) COMMENT '备注信息'
)ENGINE=INNODB DEFAULT CHARSET=utf8mb4;


# 临时修改MySQL默认的分隔符(";")为"$$",因为我们创建存储过程时可能要执行多条SQL语句,里面会写多个";"哟~
DELIMITER $$

# 创建存储过程
CREATE PROCEDURE oldboyedu_proc()
BEGIN 
    DECLARE i INT DEFAULT 1;
    WHILE i <= 100000 
        DO  
            INSERT INTO oldboyedu.student
                (name,age,time_of_enrollment,address,mobile_number) 
            VALUES 
                (CONCAT('老男孩教育_linux_MySQL_',i),CASE WHEN i < 150 THEN i ELSE 255 END,NOW(),CONCAT('oldboyedu-沙河-',i),i); 
        SET 
            i = i +1; 
    END WHILE;
END$$

# 切记要将修改后的分隔符("$$")改回之前默认的分隔符哟~
DELIMITER ;
[root@mysql108.oldboyedu.com ~]# 
[root@mysql108.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock  oldboyedu
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1308
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> SOURCE student.sql;
Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.03 sec)

Query OK, 0 rows affected (0.01 sec)

mysql> 
mysql> 
mysql> 
mysql> SHOW TABLES;
+-----------------------+
| Tables_in_oldboyedu |
+-----------------------+
| student               |
+-----------------------+
1 rows in set (0.01 sec)

mysql> 
mysql> 
mysql> SELECT * FROM student;
Empty set (0.00 sec)

mysql> 
mysql> CALL oldboyedu_proc;  # 调用存储过程,需要等待一段时间,我的机器运行较慢,用时9分13秒钟,因为该语句会往"oldboyedu.student"表中插入10万行数据.
Query OK, 1 row affected (9 min 13.93 sec)

mysql> 
mysql> SELECT COUNT(*) FROM student;
+----------+
| COUNT(*) |
+----------+
|   100000 |
+----------+
1 row in set (0.01 sec)

mysql> 

```

### 3.2编写压力测试的脚本

```
[root@mysql108.oldboyedu.com ~]# cat pressure_test.sh
mysqlslap --defaults-file=/oldboyedu/softwares/mysql23307/my.cnf \
--concurrency=100 \
--iterations=1 \
--create-schema='oldboyedu' \
--query="SELECT * FROM oldboyedu.student WHERE name='oldboyedu99778'" \
--engine=innodb \
--number-of-queries=2000 \
-S /tmp/mysql23307.sock

# 以上关键参数说明如下:
#    --defaults-file:
#	指定MySQL的配置文件路径。
#    --concurrency:
#	指定并发数量，可以理解为并发的连接数。
#    --iterations:
#	指定迭代的次数。
#    --create-schema:
#	指定连接的数据库。
#    --query:
#	指定查询的SQL语句。
#    --engine:
#	指定使用的存储引擎。
#    --number-of-queries:
#	指定查询的总发起的次数。"每个客户端发起在查询 = number-of-queries / concurrency "
#    -S:
#	指定本地连接的套接字位置，默认是"/tmp/mysql.sock"。
#    -u:
#	指定数据库的用户名，不指定则默认使用当前调用的root用户，我此处没有指定。
#    -p:
#	指定连接数据库的密码，默认为空。我并没有指定，因为我测试的数据库是空密码。
[root@mysql108.oldboyedu.com ~]# 

```

### 3.3未创建索引前调用压力测试脚本(非常耗时,竟然用时31秒多!)

```
[root@mysql108.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1308
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> SHOW INDEX FROM oldboyedu.student;
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| student |          0 | PRIMARY       |            1 | id            | A         |       91266 |     NULL | NULL   |      | BTREE      |         |               |
| student |          0 | mobile_number |            1 | mobile_number | A         |       92700 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)

mysql> 
mysql> QUIT
Bye
[root@mysql108.oldboyedu.com ~]# 
[root@mysql108.oldboyedu.com ~]# sh pressure_test.sh  # 非常耗时,竟然用时31秒多!
Benchmark
	Running for engine innodb
	Average number of seconds to run all queries: 31.046 seconds
	Minimum number of seconds to run all queries: 31.046 seconds
	Maximum number of seconds to run all queries: 31.046 seconds
	Number of clients running queries: 100
	Average number of queries per client: 20

[root@mysql108.oldboyedu.com ~]#  

```

### 3.4创建索引后调用压力测试脚本(惊奇的发现,竟然用时不足1秒!)

```
[root@mysql108.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1309
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> SHOW INDEX FROM oldboyedu.student;
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| student |          0 | PRIMARY       |            1 | id            | A         |       91266 |     NULL | NULL   |      | BTREE      |         |               |
| student |          0 | mobile_number |            1 | mobile_number | A         |       92700 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)

mysql> 
mysql> ALTER TABLE oldboyedu.student ADD INDEX my_index(name);
Query OK, 0 rows affected (0.90 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> SHOW INDEX FROM oldboyedu.student;
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| student |          0 | PRIMARY       |            1 | id            | A         |       91266 |     NULL | NULL   |      | BTREE      |         |               |
| student |          0 | mobile_number |            1 | mobile_number | A         |       92700 |     NULL | NULL   |      | BTREE      |         |               |
| student |          1 | my_index      |            1 | name          | A         |       99590 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
3 rows in set (0.00 sec)

mysql> 
mysql> QUIT
Bye
[root@mysql108.oldboyedu.com ~]# 
[root@mysql108.oldboyedu.com ~]# sh pressure_test.sh  # 惊奇的发现,竟然用时不足1秒!
Benchmark
	Running for engine innodb
	Average number of seconds to run all queries: 0.081 seconds
	Minimum number of seconds to run all queries: 0.081 seconds
	Maximum number of seconds to run all queries: 0.081 seconds
	Number of clients running queries: 100
	Average number of queries per client: 20

[root@mysql108.oldboyedu.com ~]# 

```

### 3.5删除索引再次运行压力测试脚本(我们的MySQL数据库是默认未启用缓存功能的,但是有些小伙伴会怀疑是操作系统本身是有缓存的!那么我们就删除索引后再试一遍看看效果!用时33秒以上!)

```
[root@mysql108.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1411
Server version: 5.7.31-log MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> SHOW INDEX FROM oldboyedu.student;
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| student |          0 | PRIMARY       |            1 | id            | A         |       91266 |     NULL | NULL   |      | BTREE      |         |               |
| student |          0 | mobile_number |            1 | mobile_number | A         |       92700 |     NULL | NULL   |      | BTREE      |         |               |
| student |          1 | my_index      |            1 | name          | A         |       99590 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
3 rows in set (0.00 sec)

mysql> 
mysql> ALTER TABLE oldboyedu.student DROP INDEX my_index;
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> SHOW INDEX FROM oldboyedu.student;
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| student |          0 | PRIMARY       |            1 | id            | A         |       91266 |     NULL | NULL   |      | BTREE      |         |               |
| student |          0 | mobile_number |            1 | mobile_number | A         |       92700 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
2 rows in set (0.00 sec)

mysql> 
mysql> QUIT
Bye
[root@mysql108.oldboyedu.com ~]# 
[root@mysql108.oldboyedu.com ~]# sh pressure_test.sh
Benchmark
	Running for engine innodb
	Average number of seconds to run all queries: 33.945 seconds
	Minimum number of seconds to run all queries: 33.945 seconds
	Maximum number of seconds to run all queries: 33.945 seconds
	Number of clients running queries: 100
	Average number of queries per client: 20

[root@mysql108.oldboyedu.com ~]# 

```



# 四.MySQL的执行计划详解

## 1.MySQL的执行计划概述

```
    什么是执行计划:
        MySQL的优化器按照内置的COST计算算法，最终选择最合适的执行计划。

    什么是COST:
        对于计算机来讲，COST就是资源，典型代表是"CPU","I/O",内存资源。

```



## 2.基于"EXPLAIN"或者"DESC"命令来查看SQL的执行计划

```
    如下所示,我们可以基于"EXPLAIN"或者"DESC"命令来查看SQL的执行计划,如下所示:
        mysql> EXPLAIN SELECT * FROM city;
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
        |  1 | SIMPLE      | city  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 4046 |   100.00 | NULL  |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
        1 row in set, 1 warning (0.01 sec)
        
        mysql> 
        mysql> DESC SELECT * FROM city;
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
        |  1 | SIMPLE      | city  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 4046 |   100.00 | NULL  |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> 
        mysql> SHOW INDEX FROM city;
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index01      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index01      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index01      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index02      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index02      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index02      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        12 rows in set (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM city WHERE District LIKE 'Zuid%';
        +----+------------+-------------+--------------+------------+
        | ID | Name       | CountryCode | District     | Population |
        +----+------------+-------------+--------------+------------+
        |  6 | Rotterdam  | NLD         | Zuid-Holland |     593321 |
        |  7 | Haag       | NLD         | Zuid-Holland |     440900 |
        | 23 | Dordrecht  | NLD         | Zuid-Holland |     119811 |
        | 24 | Leiden     | NLD         | Zuid-Holland |     117196 |
        | 26 | Zoetermeer | NLD         | Zuid-Holland |     110214 |
        | 30 | Delft      | NLD         | Zuid-Holland |      95268 |
        +----+------------+-------------+--------------+------------+
        6 rows in set (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE 'Zuid%';
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    6 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.01 sec)
        
        mysql> 
        mysql> DESC SELECT * FROM city WHERE District LIKE 'Zuid%';
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    6 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        
    
        
```



## 3.MySQL执行计划各字段说明

```
    我们只对查询的执行计划个字段进行分析如下所示:
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE 'Zuid%';
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    6 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.01 sec)
        
        mysql> 

    在实际工作当中,我们可能通常会关心以下几个字段:
        select_type:
            查询的类型。
        table:
            查询的表。
        partitions:
            查询的分区信息,暂时先忽略该字段,后续有专门的章节讲解分区表。
        type:
            查询类型，分为全表扫描和基于索引扫描。
                全表扫描:
                    表示不用任何索引，其类型值为"ALL"。
                索引扫描:
                    表示需要使用到索引的扫描，常见的索引扫描类型包括但不限于"index","range","ref","eq_ref","const(system)"等，
            
            常见的索引扫描类型:
                index:
                    需要扫描整个索引字段。
                range:
                    索引的范围查询，不会扫描整个索引字段，
                ref:
                    辅助索引等值查询。
                eq_ref:
                    多表连接中，非驱动表的连接条件是主键或唯一键的时候就是eq_ref索引扫描类型。
                    但请注意，两张表的连接条件字段数据类型要一致才行哟(大多数情况下管理的列字段类型是一样的)！
                const(system):
                    对于聚簇索引的等值查询效率是最高的，但这种查询在生产环境中使用的频率不是特别高。
                    但请注意，system可以理解为一种特殊的const。
            综上所述，如果查询类型走索引的话，这几种索引扫描类型性能依次递增，即index < range < ref < eq_ref < const(system)。
        possible_keys:
            可能会用到的索引。换句话说，所有和本次查询有关的索引，即可能会走的索引。
        key:
            实际使用的索引。换句话说，就是本次查询选择的索引。
        key_len:
            联合索引(即含多列字段的索引)的覆盖长度。对于联合索引，我们希望将来的查询语句，对于联合索引应用越充分越好。我们可以借助key_len来帮助我们判断本次查询走了联合索引的数据长度。
            这里的数据长度指的是联合索引各列最大储值的字节长度，该长度受到了数据类型，字符集的影响。此处我们对数据类型为数字和字符来进行说明如下:
                数字数据类型:
                    常见的数字数据类型有:tinyint,smallint,mediuint,int,bingint,DECIMAL,NUMERIC,float,double,BIT等。
                    对于数字类型的字段类型设置了NOT NULL和没有设置NOT NULL是两回事，因为没有设置NOT NULL属性的话，MySQL会单独占用一个字节来确定该字段是否为空。
                    以"id int NOT NULL"为例，它的数据类型大小是4bytes，其key_len实际占用空间就是4bytes，以"id int"，它的数据类型大小是4bytes，但需要1个字节存储该字段是否为空，因此实际占用空间为5bytes。
                字符:
                    字符集环境说明:
                        我们用三种字符编码来进行说明，别分GBK,UTF8,UTF8MB4为例。
                        注意哈，这三个字符集均内置了ASCII字符编码，我们都知道ASCII字符编码仅需一个字节。而GBK是以2字节编码的，UTF8和UTF8MB4是可变长字符编码，但我们举例说明时只会讨论该字符集存储一个字符时最大能占用的空间为例。
                    数据类型环境说明:
                        常见的字符数据类型有很多，比如:CHAR,VARCHAR,ENUM,BLOB与TEXT等，我这里就以常用的CHAR与VARCHAR来举例说明哈。我们知道VARCHAR需要占用1-2个字节来存储字符的长度。而CHAR则只会占用指定的长度。
                    我们以"utf8mb4"为例，其可以存储的字符占用字节大小的区间范围是1-4字节，此时我们就取最大占用字节数4。
                        对于"name CHAR(30)"为例，它的数据类型大小是30*4，由于没有设置NOT NULL属性30*4+1，"name CHAR(30) NOT NULL"为例，它的数据类型大小是30*4，即120字节。
                        对于"name VARCHAR(30)"为例，它的数据类型大小是30*4+2，由于没有设置NOT NULL属性30*4+2+1，"name VARCHAR(30) NOT NULL"为例，它的数据类型大小是30*4+2，即122字节。
        ref:
            引用的算法，例如"const"，我们可以人为的来修改MySQL内置的优化器算法，后续会有相应章节的介绍。
        rows:
            本次查询需要扫描的数据行数。
        filtered:
            有关过滤的相关信息。
        Extra:
            表示使用额外的信息，该字段的进一步研究咱们会在优化器相关的章节做进一步的学习。该字段可能会出现包括但不限于:"NULL","Using index condition","Using where","Using index for group-by","","Using filesort"等。
            但我们最应该关注的是"Using filesort"这样的额外信息，若出现了我们应该考虑优化SQL语句或者创建索引！
            出现"Using filesort"时,表示本次查询使用到了文件排序，说明在查询中用到了排序操作，比如: "ORDER BY","GROUP BY","DISTINCT"等。
            排序操作会占用CPU时间，因此我们可以考虑创建索引优化查询，因为创建索引后，数据是有序的，就无须再做排序操作了。
```

## 4.查询表(table)案例: 查询涉及到两张表(city,country)，针对一个查询中多个表时，我们要将问题定位到问题表，而后创建适当的索引！

```
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
| Name        | char(35) | NO   | MUL |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   | MUL |         |                |
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
mysql> SHOW INDEX FROM country;
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| country |          0 | PRIMARY  |            1 | Code        | A         |         239 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
1 row in set (0.00 sec)

mysql> 
mysql> SHOW INDEX FROM city;
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name    | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY     |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name  |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index03  |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index05  |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
+-------+------------+-------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
5 rows in set (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT country.name,city.name FROM city JOIN country ON city.countrycode=country.code WHERE city.population>8000000;  # 创建索引之前，发现city表出现了问题，因为它没有走索引，key列为空哟~(也可以顺带看一下rows)
+----+-------------+---------+------------+--------+---------------+---------+---------+------------------------+------+----------+-------------+
| id | select_type | table   | partitions | type   | possible_keys | key     | key_len | ref                    | rows | filtered | Extra       |
+----+-------------+---------+------------+--------+---------------+---------+---------+------------------------+------+----------+-------------+
|  1 | SIMPLE      | city    | NULL       | ALL    | CountryCode   | NULL    | NULL    | NULL                   | 4046 |    10.00 | Using where |
|  1 | SIMPLE      | country | NULL       | eq_ref | PRIMARY       | PRIMARY | 12      | world.city.CountryCode |    1 |   100.00 | NULL        |
+----+-------------+---------+------------+--------+---------------+---------+---------+------------------------+------+----------+-------------+
2 rows in set, 1 warning (0.00 sec)

mysql> 
mysql> CREATE INDEX my_index_test01 ON city(Population);  # 创建索引
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> DESC SELECT country.name,city.name FROM city JOIN country ON city.countrycode=country.code WHERE city.population>8000000;  # 创建索引后，再次观察city表的key字段，发现是走咱们创建的索引了哟~(也可以顺带看一下rows)
+----+-------------+---------+------------+--------+-----------------------------+-----------------+---------+------------------------+------+----------+-------+
| id | select_type | table   | partitions | type   | possible_keys               | key             | key_len | ref                    | rows | filtered | Extra |
+----+-------------+---------+------------+--------+-----------------------------+-----------------+---------+------------------------+------+----------+-------+
|  1 | SIMPLE      | city    | NULL       | ref    | CountryCode,my_index_test01 | my_index_test01 | 4       | const                  |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | country | NULL       | eq_ref | PRIMARY                     | PRIMARY         | 12      | world.city.CountryCode |    1 |   100.00 | NULL  |
+----+-------------+---------+------------+--------+-----------------------------+-----------------+---------+------------------------+------+----------+-------+
2 rows in set, 1 warning (0.01 sec)

mysql> 
mysql> SHOW INDEX FROM city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
6 rows in set (0.00 sec)

mysql> 
mysql> SHOW INDEX FROM country;
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table   | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| country |          0 | PRIMARY  |            1 | Code        | A         |         239 |     NULL | NULL   |      | BTREE      |         |               |
+---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
1 row in set (0.00 sec)

mysql> 
mysql> 

```

## 5.查询类型(type)的案例：含全表扫描和索引扫描案例

```
    全表扫描的案例:
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
        mysql> EXPLAIN SELECT * FROM country;  # 不走索引，全表扫描！
        +----+-------------+---------+------------+------+---------------+------+---------+------+------+----------+-------+
        | id | select_type | table   | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
        +----+-------------+---------+------------+------+---------------+------+---------+------+------+----------+-------+
        |  1 | SIMPLE      | country | NULL       | ALL  | NULL          | NULL | NULL    | NULL |  239 |   100.00 | NULL  |
        +----+-------------+---------+------------+------+---------------+------+---------+------+------+----------+-------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM country WHERE 10=10; # 不走索引，全表扫描！
        +----+-------------+---------+------------+------+---------------+------+---------+------+------+----------+-------+
        | id | select_type | table   | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
        +----+-------------+---------+------------+------+---------------+------+---------+------+------+----------+-------+
        |  1 | SIMPLE      | country | NULL       | ALL  | NULL          | NULL | NULL    | NULL |  239 |   100.00 | NULL  |
        +----+-------------+---------+------------+------+---------------+------+---------+------+------+----------+-------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM city WHERE District LIKE 'Zuid%';
        +----+------------+-------------+--------------+------------+
        | ID | Name       | CountryCode | District     | Population |
        +----+------------+-------------+--------------+------------+
        |  6 | Rotterdam  | NLD         | Zuid-Holland |     593321 |
        |  7 | Haag       | NLD         | Zuid-Holland |     440900 |
        | 23 | Dordrecht  | NLD         | Zuid-Holland |     119811 |
        | 24 | Leiden     | NLD         | Zuid-Holland |     117196 |
        | 26 | Zoetermeer | NLD         | Zuid-Holland |     110214 |
        | 30 | Delft      | NLD         | Zuid-Holland |      95268 |
        +----+------------+-------------+--------------+------------+
        6 rows in set (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE 'Zuid%';  # 注意哈，左边不加"%"号是走索引的哟~
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    6 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE '%Zuid%';  # 注意哈，前后都加"%"号是不走索引的哟~
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 4046 |    11.11 | Using where |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE countrycode IN ('CHN','USA');  # 如下输出所示，不难发现使用IN这种方式，貌似也可以走索引哟~(因为IN是已经确定的值)
        +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-----------------------+
        | id | select_type | table | partitions | type  | possible_keys | key         | key_len | ref  | rows | filtered | Extra                 |
        +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-----------------------+
        |  1 | SIMPLE      | city  | NULL       | range | CountryCode   | CountryCode | 12      | NULL |  637 |   100.00 | Using index condition |
        +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-----------------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE countrycode NOT IN ('CHN','USA');  # 如下输出所示，不难发现，使用NOT IN这种方式，是肯定不走索引的！(因为NOT是不确定的值)
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | ALL  | CountryCode   | NULL | NULL    | NULL | 4046 |    85.07 | Using where |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 

    索引扫描的案例:
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
        mysql> SHOW INDEX FROM country;
        +---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table   | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | country |          0 | PRIMARY  |            1 | Code        | A         |         239 |     NULL | NULL   |      | BTREE      |         |               |
        +---------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SHOW INDEX FROM city;
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        6 rows in set (0.00 sec)
        
        mysql> 
        mysql> DESC city;
        +-------------+----------+------+-----+---------+----------------+
        | Field       | Type     | Null | Key | Default | Extra          |
        +-------------+----------+------+-----+---------+----------------+
        | ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
        | Name        | char(35) | NO   | MUL |         |                |
        | CountryCode | char(3)  | NO   | MUL |         |                |
        | District    | char(20) | NO   | MUL |         |                |
        | Population  | int(11)  | NO   | MUL | 0       |                |
        +-------------+----------+------+-----+---------+----------------+
        5 rows in set (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT CountryCode FROM world.city;  # 全索引扫描
        +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys | key         | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | index | NULL          | CountryCode | 12      | NULL | 4046 |   100.00 | Using index |
        +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.01 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE id < 10;  # 范围索引扫描
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL |    9 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE 'Zuid%';  # 注意哈，左边不加"%"号是走索引的哟~
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    6 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE countryCode='CHN';  # 辅助索引等值查询，即只查询等效的某个条件！
        +----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
        | id | select_type | table | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra |
        +----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
        |  1 | SIMPLE      | city  | NULL       | ref  | CountryCode   | CountryCode | 12      | const |  363 |   100.00 | NULL  |
        +----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> DESC SELECT * FROM city JOIN country ON city.countrycode=country.code WHERE city.Population=10500000; # city是驱动表，而country是非驱动表，country.code字段是主键。

+----+-------------+---------+------------+--------+-----------------------------+-----------------+---------+------------------------+------+----------+-------+
| id | select_type | table   | partitions | type   | possible_keys               | key             | key_len | ref                    | rows | filtered | Extra |
+----+-------------+---------+------------+--------+-----------------------------+-----------------+---------+------------------------+------+----------+-------+
|  1 | SIMPLE      | city    | NULL       | ref    | CountryCode,oldboyedu_linux | oldboyedu_linux | 4       | const                  |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | country | NULL       | eq_ref | PRIMARY                     | PRIMARY         | 12      | world.city.CountryCode |    1 |   100.00 | NULL  |
+----+-------------+---------+------------+--------+-----------------------------+-----------------+---------+------------------------+------+----------+-------+
2 rows in set, 1 warning (0.00 sec)

mysql>
        mysql> EXPLAIN SELECT * FROM city WHERE id=1890;  # 注意哈，如果基于主键(默认基于聚簇索引)进行的等值查询，效率是最高的，这一点请思考学习的聚簇索引的原理来分析即可。
        +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
        | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
        +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
        |  1 | SIMPLE      | city  | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
        +----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 

    温馨提示:
        (1)在某些场景下，我们将IN语句改写为UNION ALL，你会发现"type"是有提升的，即从range提升到ref级别，但会发起两次查询！这个还是要慎重考虑一下生产环境需要这样做，最好是进行对比一下，选择更好的方案哟~
            mysql> EXPLAIN SELECT * FROM city WHERE countrycode IN ('CHN','USA');
            +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-----------------------+
            | id | select_type | table | partitions | type  | possible_keys | key         | key_len | ref  | rows | filtered | Extra                 |
            +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-----------------------+
            |  1 | SIMPLE      | city  | NULL       | range | CountryCode   | CountryCode | 12      | NULL |  637 |   100.00 | Using index condition |
            +----+-------------+-------+------------+-------+---------------+-------------+---------+------+------+----------+-----------------------+
            1 row in set, 1 warning (0.00 sec)
            
            mysql> 
            mysql> EXPLAIN SELECT * FROM city WHERE countrycode='CHN' UNION ALL SELECT * FROM city WHERE countrycode='USA';
            +----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
            | id | select_type | table | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra |
            +----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
            |  1 | PRIMARY     | city  | NULL       | ref  | CountryCode   | CountryCode | 12      | const |  363 |   100.00 | NULL  |
            |  2 | UNION       | city  | NULL       | ref  | CountryCode   | CountryCode | 12      | const |  274 |   100.00 | NULL  |
            +----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
            2 rows in set, 1 warning (0.00 sec)
            
            mysql> 
        (2)在主键列使用不等("!=")来过滤条件时，MySQL内置的优化器会将SQL改写为大于和小于的情况，比如"id != 5",就会改写为"id > 5" AND "id < 5"，因此也是一个range的索引哟，如下所示:
            mysql> DESC city;
            +-------------+----------+------+-----+---------+----------------+
            | Field       | Type     | Null | Key | Default | Extra          |
            +-------------+----------+------+-----+---------+----------------+
            | ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
            | Name        | char(35) | NO   | MUL |         |                |
            | CountryCode | char(3)  | NO   | MUL |         |                |
            | District    | char(20) | NO   | MUL |         |                |
            | Population  | int(11)  | NO   | MUL | 0       |                |
            +-------------+----------+------+-----+---------+----------------+
            5 rows in set (0.00 sec)
            
            mysql> 
            mysql> SHOW INDEX FROM city;
            +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            | Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
            +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            | city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
            | city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
            | city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
            | city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
            | city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
            | city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
            +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            6 rows in set (0.00 sec)
            
            mysql> 
            mysql> EXPLAIN SELECT * FROM city WHERE id NOT IN (1,3,5,7);
            +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
            | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
            +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
            |  1 | SIMPLE      | city  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL | 2027 |   100.00 | Using where |
            +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
            1 row in set, 1 warning (0.00 sec)
            
            mysql> 
            mysql> EXPLAIN SELECT * FROM city WHERE id != 20;
            +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
            | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
            +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
            |  1 | SIMPLE      | city  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL | 2042 |   100.00 | Using where |
            +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
            1 row in set, 1 warning (0.00 sec)
            
            mysql> 

        (3)

```

## 6.联合索引的覆盖长度(key_len)

```
    以下是建表语句:
        CREATE TABLE IF NOT EXISTS oldboyedu.student (
            id int PRIMARY KEY AUTO_INCREMENT COMMENT '学生编号ID',
            name varchar(30) NOT NULL COMMENT '学生姓名',
            age tinyint UNSIGNED DEFAULT NULL COMMENT '年龄',
            gender enum('Male','Female') DEFAULT 'Male' COMMENT '性别',
            time_of_enrollment  DATETIME(0) COMMENT '报名时间',
            address varchar(255) NOT NULL COMMENT '家庭住址',
            mobile_number bigint UNIQUE KEY NOT NULL COMMENT '手机号码',
            remarks VARCHAR(255) COMMENT '备注信息'
        )ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
    
    请将"name","age"这几个字段创建为联合索引:
        mysql> DESC oldboyedu.student;
        +--------------------+-----------------------+------+-----+---------+----------------+
        | Field              | Type                  | Null | Key | Default | Extra          |
        +--------------------+-----------------------+------+-----+---------+----------------+
        | id                 | int(11)               | NO   | PRI | NULL    | auto_increment |
        | name               | varchar(30)           | NO   |     | NULL    |                |
        | age                | tinyint(3) unsigned   | YES  |     | NULL    |                |
        | gender             | enum('Male','Female') | YES  |     | Male    |                |
        | time_of_enrollment | datetime              | YES  |     | NULL    |                |
        | address            | varchar(255)          | NO   |     | NULL    |                |
        | mobile_number      | bigint(20)            | NO   | UNI | NULL    |                |
        | remarks            | varchar(255)          | YES  |     | NULL    |                |
        +--------------------+-----------------------+------+-----+---------+----------------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> SHOW INDEX FROM oldboyedu.student;
        +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | student |          0 | PRIMARY       |            1 | id            | A         |       91266 |     NULL | NULL   |      | BTREE      |         |               |
        | student |          0 | mobile_number |            1 | mobile_number | A         |       92700 |     NULL | NULL   |      | BTREE      |         |               |
        +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        2 rows in set (0.00 sec)
        
        mysql> 
        mysql> CREATE INDEX my_index01 ON oldboyedu.student(name,age);
        Query OK, 0 rows affected (1.59 sec)
        Records: 0  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SHOW INDEX FROM oldboyedu.student;
        +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | student |          0 | PRIMARY       |            1 | id            | A         |       91266 |     NULL | NULL   |      | BTREE      |         |               |
        | student |          0 | mobile_number |            1 | mobile_number | A         |       92700 |     NULL | NULL   |      | BTREE      |         |               |
        | student |          1 | my_index01    |            1 | name          | A         |       99590 |     NULL | NULL   |      | BTREE      |         |               |
        | student |          1 | my_index01    |            2 | age           | A         |       99590 |     NULL | NULL   | YES  | BTREE      |         |               |
        +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        4 rows in set (0.00 sec)
        
        mysql> 
        mysql> DESC oldboyedu.student;
        +--------------------+-----------------------+------+-----+---------+----------------+
        | Field              | Type                  | Null | Key | Default | Extra          |
        +--------------------+-----------------------+------+-----+---------+----------------+
        | id                 | int(11)               | NO   | PRI | NULL    | auto_increment |
        | name               | varchar(30)           | NO   | MUL | NULL    |                |
        | age                | tinyint(3) unsigned   | YES  |     | NULL    |                |
        | gender             | enum('Male','Female') | YES  |     | Male    |                |
        | time_of_enrollment | datetime              | YES  |     | NULL    |                |
        | address            | varchar(255)          | NO   |     | NULL    |                |
        | mobile_number      | bigint(20)            | NO   | UNI | NULL    |                |
        | remarks            | varchar(255)          | YES  |     | NULL    |                |
        +--------------------+-----------------------+------+-----+---------+----------------+
        8 rows in set (0.00 sec)
        
        mysql> 

    问: 查询中完全覆盖2列索引,key_len是多少呢?
        (1)分析,我们先将建表语句中的2列索引拿出来如下所示:
            name varchar(30) NOT NULL COMMENT '学生姓名',
            age tinyint UNSIGNED DEFAULT NULL COMMENT '年龄',
        (2)分析各个字段占用的空间大小:
            name字段:
                数据类型为VARCHAR,字符类型为utf8mb4,因此计算该字段大小占用空间"30*4"字节,VARCHAR字符长度额外占用2字节,由于设置的有NOT NULL,因此无需额外占用1字节来确认该字段是否为空,因此总大小为: 30*4+2=122 bytes
            age字段:
                数据类型为tinyint,由于设置的没有NOT NULL,因此需额外占用1字节来确认该字段是否为空,因此计算该字段大小为: 1+1=2 bytes
        (3)得出结论:
            122 + 2 = 124字节.

    编写SQL语句,验证上述理论:
        mysql> SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888';
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        | id   | name            | age  | gender | time_of_enrollment  | address                  | mobile_number | remarks |
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        | 8888 | oldboyedu8888 |  255 | Male   | 2021-01-22 14:15:03 | oldboyedu-address-8888 |          8888 | NULL    |
        +------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888';  # 注意哈,此处我查询只覆盖了1列索引
        +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-------+
        | id | select_type | table   | partitions | type | possible_keys | key        | key_len | ref   | rows | filtered | Extra |
        +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-------+
        |  1 | SIMPLE      | student | NULL       | ref  | my_index01    | my_index01 | 122     | const |    1 |   100.00 | NULL  |
        +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-------+
        1 row in set, 1 warning (0.01 sec)
        
        mysql> 
        mysql> 
        mysql> EXPLAIN SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888' AND age=255;  # 注意哈,此处我查询完全覆盖2列索引
        +----+-------------+---------+------------+------+---------------+------------+---------+-------------+------+----------+-------+
        | id | select_type | table   | partitions | type | possible_keys | key        | key_len | ref         | rows | filtered | Extra |
        +----+-------------+---------+------------+------+---------------+------------+---------+-------------+------+----------+-------+
        |  1 | SIMPLE      | student | NULL       | ref  | my_index01    | my_index01 | 124     | const,const |    1 |   100.00 | NULL  |
        +----+-------------+---------+------------+------+---------------+------------+---------+-------------+------+----------+-------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 

```



## 7.额外(Extra)信息出现"Using filesort"时，需要DBA及时解决哟~

```
mysql> SHOW INDEX FROM world.city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
6 rows in set (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM world.city;
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
|  1 | SIMPLE      | city  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 4046 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

mysql> 
mysql> 
mysql> SHOW INDEX FROM world.city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
6 rows in set (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM world.city;
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
|  1 | SIMPLE      | city  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 4046 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM world.city WHERE CountryCode='CHN';
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | city  | NULL       | ref  | CountryCode   | CountryCode | 12      | const |  363 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM world.city WHERE CountryCode='CHN' ORDER BY Population;  # 注意哈，一旦出现了"Using filesort"，这说明咱们应该考虑优化该条语句的查询啦~
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+---------------------------------------+
| id | select_type | table | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra                                 |
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+---------------------------------------+
|  1 | SIMPLE      | city  | NULL       | ref  | CountryCode   | CountryCode | 12      | const |  363 |   100.00 | Using index condition; Using filesort |
+----+-------------+-------+------------+------+---------------+-------------+---------+-------+------+----------+---------------------------------------+
1 row in set, 1 warning (0.00 sec)

mysql> 
mysql> ALTER TABLE world.city ADD INDEX my_index_demo(CountryCode,Population);  # 我们需要对CountryCode和Population这两个字段创建一个联合索引。
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> 
mysql> SHOW INDEX FROM world.city;
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_demo   |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
| city  |          1 | my_index_demo   |            2 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
8 rows in set (0.00 sec)

mysql> 
mysql> EXPLAIN SELECT * FROM world.city WHERE CountryCode='CHN' ORDER BY Population;  # 由于上面我们创建的是联合索引，不难发现本次MySQL优化器选择的是咱们创建的联合索引，而"Using filesort"并没有在"Extra"中出现！
+----+-------------+-------+------------+------+---------------------------+---------------+---------+-------+------+----------+-----------------------+
| id | select_type | table | partitions | type | possible_keys             | key           | key_len | ref   | rows | filtered | Extra                 |
+----+-------------+-------+------------+------+---------------------------+---------------+---------+-------+------+----------+-----------------------+
|  1 | SIMPLE      | city  | NULL       | ref  | CountryCode,my_index_demo | my_index_demo | 12      | const |  363 |   100.00 | Using index condition |
+----+-------------+-------+------------+------+---------------------------+---------------+---------+-------+------+----------+-----------------------+
1 row in set, 1 warning (0.00 sec)

mysql> 

```



# 五.MySQL的索引应用规范参考

## 1.建立索引的原则

```
    为了使索引的使用效率更高，在创建索引时，必须考虑在哪些字段上创建索引和创建什么类型的索引。那么索引设计原则又是怎样的呢?

    接下来我们了解一下MySQL中的索引创建规则。
```

## 2.创建表时一定要有主键，一般是个无关列(比如"id"列，这一点很多ORM框架都实现了该规范)

```
    创建表一定要指定主键，主键可以是一个和你业务无关的列，再问为什么之前，请仔细回顾一下InnoDB存储引擎中聚簇索引的原理。
    
    举个例子:
        比如"id"列，这一点很多ORM框架都实现了该规范，以python实现的django框架为例，它就是一个不错的选择。
```

## 3.选择唯一性索引

```
    唯一性索引的值是唯一的，可以更快速的通过该索引来确定某条记录。

    举个例子:
        学生表中的学号是具有唯一性的字段，我们为该字段建立唯一性索引可以很快的确定某个学生的信息。如果使用姓名的话，可能会存在同名的现象，从而降低查询速度。

    如果非要使用重复值较多的列作为查询条件，例如: "gender enum('Male','Female') DEFAULT 'Male' COMMENT '性别'"字段，可以采取以下两张常见的优化方案:
        (1)可以将表逻辑拆分为两张表，一张表存储"Male"类型，另一张表存储"Female";
        (2)可以将此列和其它的查询列，做联合索引。别忘记在查询时，记得将重复值最少的列放在最左侧的原则哟;

```

## 4.为经常需要使用"WHERE","ORDER BY","GROUP BY","JOIN ON"等操作的字段建立索引

```
    为经常需要使用"WHERE","ORDER BY","GROUP BY","JOIN ON"等操作的字段建立索引是非常有效的一种优化手段。

    这是因为当我们为某些字段创建索引后，该字段就意味着是有序存储，这样避免当用户频繁使用上述关键字进行查询时进行排序啦~即可以有效避免执行计划中Extra字段值为"Using filesort"的出现哟~

    温馨提示:
        如果经常作为条件的列，且该列重复值较多，可以考虑建立联合索引。
```

## 5.如果索引字段的值很长，最好使用值的前缀来索引

```
    如果索引字段的值很长，最好使用值的前缀来索引。

    这种策略也被应用在其它的软件上，比如git的版本控制，不难发现我们在做版本回滚时，无需指定该版本的完整编号，而仅需要指定前缀即可，当然，玩过docker的小伙伴也应该发现在创建容器时也有用到类似的策略哟~

    温馨提示:("%匹配字符%"是不走索引的，但"匹配字符%"是可以走索引的哟~)
        mysql> SHOW INDEX FROM world.city;
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index_demo   |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index_demo   |            2 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        8 rows in set (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE 'Zuid%';  # 注意哈，左边不加"%"号是走索引的哟~
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    6 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE '%Zuid%';  # 注意哈，前后都加"%"号是不走索引的哟~
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 4046 |    11.11 | Using where |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 

```

## 6.限制索引的数目，定期清除不经常使用的索引

```
    索引的数目并不是越多越好，这是因为索引的维护是需要耗费成本的。

    当我们为一个表创建了过多的索引，可能会存在以下几个常见的问题:
        (1)索引数目越多，MySQL优化器的负担会加重，有可能会影响到优化器的选择;
        (2)修改表时，对索引的重构和更新很麻烦，这意味着索引数目越多会增加更多的耗时;
        (3)当然，每个索引都需要占用磁盘空间，索引越多，需要的磁盘空间就越大;

    温馨提示:
        percona-toolkit中有个工具可以专门分析索引是否有用，如果你要做一名合格的DBA，建议学习使用一下该工具。当然，如果你有比该工具更强大且更好的工具也就没有必要在学习该工具了，了解即可。
```

## 7.删除不在使用或者很少使用的索引

```
    表中的数据被大量更新，或者数据的使用方式被改变后，原有的一些索引可能不在需要，数据库管理员应该定期找出这些索引，并将它们删除，从而减少索引对更新操作的影响。    

    温馨提示:
        以MySQL 5.7为例，我们可以查看sys数据库中存储了哪些索引我不经常使用，可以考虑删除:
            mysql> select VERSION();
            +------------+
            | VERSION()  |
            +------------+
            | 5.7.31-log |
            +------------+
            1 row in set (0.00 sec)
            
            mysql> 
            mysql> SELECT * FROM sys.schema_unused_indexes;
            +---------------+-----------------+-------------+
            | object_schema | object_name     | index_name  |
            +---------------+-----------------+-------------+
            | world         | city            | index_name  |
            | world         | city            | my_index05  |
            | world         | city            | my_index03  |
            | world         | countrylanguage | CountryCode |
            | oldboyedu   | student         | my_index01  |
            +---------------+-----------------+-------------+
            5 rows in set (0.00 sec)
            
            mysql> 

        当然，我们也可以借助第三方工具来管理索引，比如用"pt-duplicate-key-checker"工具来删除不需要的索引。

```

## 8.大表加索引，要在业务不繁忙期间操作

```
    需要注意的是，在为大表建立索引时，要在业务不繁忙的期间操作。

    这一点不仅仅用在建立索引，凡是对生产表做修改操作时，都应该尽量选择在低峰期做维护操作，这样尽管做了不当操作导致数据库宕机，也可以将成本降到最低。
```

## 9.尽量少在经常更新值的字段上创建索引

```
    众所周知维护索引是需要一定成本的，在修改表时，对索引的重构和更新很麻烦，如果我们为修改表的某个字段过于频繁建立了索引，这意味着会频繁的更新索引信息，导致较多的IOPS的递增。
```



# 六.MySQL的不走索引的情况(了解即可)

## 1.没有查询条件，或者查询条件没有建立索引的索引

```
    在业务数据库中，特别是数据量比较大的表是没有全表扫描这种需求的。因此在查询过程中，我们应该尽量避免全表扫描。

    一张大表的数据达到几十GB时我们若进行全表扫描，缺陷是很明显的，对于用户而言，查看是非常痛苦的，对于服务器而言可能是I/O性能很容易达到上限，甚至可能导致MySQL服务器的守护进程直接挂掉。

    全表扫描案例:
        SQL案例:
            mysql> SELECT * FROM oldboyedu.student;
            mysql> SELECT * FROM oldboyedu.student WHERE 10=10;
        优化方案:
            mysql> SELECT * FROM oldboyedu.student ORDER BY id,name LIMIT 0,5;  
        温馨提示:
            上述优化方案中，建议在id和name上做联合索引，因为通常id是主键，这意味着id是唯一且非空，而后和name字段做联合索引，尽管其name字段相同，但id字段绝对不可能相同而确定唯一的一个人

    全表扫描案例:
        SQL案例:
            mysql> SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888';  # name列没有索引的情况下
        优化方案:
            (1)换成有索引的列作为查询条件;
            (2)将name列建立索引(如果细心地小伙伴可能会考虑到现实生活中同名的情况，因此可以考虑使用联合索引);

```

## 2.查看结果集是原表中的大部分数据，应该是15%-30%

```
    查询的结果集，超过了总行数的15%-30%时，优化器觉得就没有必要走索引了。

    需要注意这个百分比，归根结底是跟数据库的预读能力及其相关参数设置有关，请允许我买个关子，我们在后续的章节会介绍到哟~

    温馨提示:
        具体情况需要结合实际业务本身特色来判断，思考有没有更好的查询方式，如果没有更好的SQL改写方案，就尽量不要在MySQL存放这个数据库， 而是可以考虑存放到类似Redis这样的缓存数据库中。

```

## 3.索引本身失效，统计数据不真实

```
    索引有自我维护的能力，对于表内容变化比较频繁的情况下，有可能会出现统计信息不准确(数据过旧)，从而导致索引失效。通常的解决方案就是删除该索引后重建索引即可解决。

    案例展示:
        有一条"SELECT"语句平常查询时很快，突然有一天该SQL语句查询很慢，会是什么原因导致的呢?
            (1)可能是统计数据不真实，导致索引失效，即不走索引的话数据的查询相对来说会比较耗时;
            (2)当然，我们不能排除数据库实例所在的数据库服务器的资源消耗殆尽的情况下，无论是发起任何DML语句反应速度均会变慢哟;
            (3)如果有人使用了"悲观锁",也有可能会导致查询数据失败，在后续章节会介绍到;

    温馨提示:
        mysql> SELECT * FROM mysql.innodb_table_stats;  # 查看表的统计信息，注意哈，观察last_update和n_rows对应的行数，我们可以打开一个终端删除数据，你会发现不会立即刷新当前记录的表
        +---------------+-----------------+---------------------+--------+----------------------+--------------------------+
        | database_name | table_name      | last_update         | n_rows | clustered_index_size | sum_of_other_index_sizes |
        +---------------+-----------------+---------------------+--------+----------------------+--------------------------+
        | mysql         | gtid_executed   | 2021-01-10 21:15:36 |      0 |                    1 |                        0 |
        | school        | course          | 2021-01-15 05:57:48 |      5 |                    1 |                        0 |
        | school        | student         | 2021-01-15 05:37:54 |     15 |                    1 |                        0 |
        | school        | student_score   | 2021-01-15 06:20:40 |     31 |                    1 |                        0 |
        | school        | teacher         | 2021-01-15 05:48:57 |      3 |                    1 |                        0 |
        | sys           | sys_config      | 2021-01-10 21:15:36 |      6 |                    1 |                        0 |
        | world         | city            | 2021-01-25 08:39:36 |   4046 |                   25 |                      103 |
        | world         | country         | 2021-01-14 12:09:41 |    239 |                    7 |                        0 |
        | world         | countrylanguage | 2021-01-14 12:10:01 |    984 |                    6 |                        4 |
        | oldboyedu   | staff           | 2021-01-18 23:40:41 |      0 |                    1 |                        1 |
        | oldboyedu   | student         | 2021-01-25 10:07:30 |  99613 |                  673 |                      386 |
        +---------------+-----------------+---------------------+--------+----------------------+--------------------------+
        11 rows in set (0.28 sec)
        
        mysql> 
        mysql> OPTIMIZE TABLE mysql.innodb_table_stats;  # 我们可以使用该语句手动更新表的状态信息哟，但如果删除的数据较少，可能不会立即更新!需要等待一段时间，这个时候可以考虑删除city表的1000行数据来测试一下(反正该表有4046多条数据)
        +--------------------------+----------+----------+-------------------------------------------------------------------+
        | Table                    | Op       | Msg_type | Msg_text                                                          |
        +--------------------------+----------+----------+-------------------------------------------------------------------+
        | mysql.innodb_table_stats | optimize | note     | Table does not support optimize, doing recreate + analyze instead |
        | mysql.innodb_table_stats | optimize | status   | OK                                                                |
        +--------------------------+----------+----------+-------------------------------------------------------------------+
        2 rows in set (0.35 sec)
        
        mysql> 
        mysql> SELECT * FROM mysql.innodb_index_stats;  # 我们也可以观察当前表的索引信息哟~
        +---------------+-----------------+-----------------+---------------------+--------------+------------+-------------+-----------------------------------+
        | database_name | table_name      | index_name      | last_update         | stat_name    | stat_value | sample_size | stat_description                  |
        +---------------+-----------------+-----------------+---------------------+--------------+------------+-------------+-----------------------------------+
        | mysql         | gtid_executed   | PRIMARY         | 2021-01-10 21:15:36 | n_diff_pfx01 |          0 |           1 | source_uuid                       |
        | mysql         | gtid_executed   | PRIMARY         | 2021-01-10 21:15:36 | n_diff_pfx02 |          0 |           1 | source_uuid,interval_start        |
        | mysql         | gtid_executed   | PRIMARY         | 2021-01-10 21:15:36 | n_leaf_pages |          1 |        NULL | Number of leaf pages in the index |
        | mysql         | gtid_executed   | PRIMARY         | 2021-01-10 21:15:36 | size         |          1 |        NULL | Number of pages in the index      |
        | school        | course          | PRIMARY         | 2021-01-15 05:57:48 | n_diff_pfx01 |          5 |           1 | id                                |
        | school        | course          | PRIMARY         | 2021-01-15 05:57:48 | n_leaf_pages |          1 |        NULL | Number of leaf pages in the index |
        | school        | course          | PRIMARY         | 2021-01-15 05:57:48 | size         |          1 |        NULL | Number of pages in the index      |
        | school        | student         | PRIMARY         | 2021-01-15 05:37:54 | n_diff_pfx01 |         15 |           1 | id                                |
        | school        | student         | PRIMARY         | 2021-01-15 05:37:54 | n_leaf_pages |          1 |        NULL | Number of leaf pages in the index |
        | school        | student         | PRIMARY         | 2021-01-15 05:37:54 | size         |          1 |        NULL | Number of pages in the index      |
        | school        | student_score   | GEN_CLUST_INDEX | 2021-01-15 06:20:40 | n_diff_pfx01 |         31 |           1 | DB_ROW_ID                         |
        | school        | student_score   | GEN_CLUST_INDEX | 2021-01-15 06:20:40 | n_leaf_pages |          1 |        NULL | Number of leaf pages in the index |
        | school        | student_score   | GEN_CLUST_INDEX | 2021-01-15 06:20:40 | size         |          1 |        NULL | Number of pages in the index      |
        | school        | teacher         | PRIMARY         | 2021-01-15 05:48:57 | n_diff_pfx01 |          3 |           1 | id                                |
        | school        | teacher         | PRIMARY         | 2021-01-15 05:48:57 | n_leaf_pages |          1 |        NULL | Number of leaf pages in the index |
        | school        | teacher         | PRIMARY         | 2021-01-15 05:48:57 | size         |          1 |        NULL | Number of pages in the index      |
        | sys           | sys_config      | PRIMARY         | 2021-01-10 21:15:36 | n_diff_pfx01 |          6 |           1 | variable                          |
        | sys           | sys_config      | PRIMARY         | 2021-01-10 21:15:36 | n_leaf_pages |          1 |        NULL | Number of leaf pages in the index |
        | sys           | sys_config      | PRIMARY         | 2021-01-10 21:15:36 | size         |          1 |        NULL | Number of pages in the index      |
        | world         | city            | CountryCode     | 2021-01-14 12:09:51 | n_diff_pfx01 |        232 |           6 | CountryCode                       |
        | world         | city            | CountryCode     | 2021-01-14 12:09:51 | n_diff_pfx02 |       4079 |           6 | CountryCode,ID                    |
        | world         | city            | CountryCode     | 2021-01-14 12:09:51 | n_leaf_pages |          6 |        NULL | Number of leaf pages in the index |
        | world         | city            | CountryCode     | 2021-01-14 12:09:51 | size         |          7 |        NULL | Number of pages in the index      |
        | world         | city            | PRIMARY         | 2021-01-14 12:09:51 | n_diff_pfx01 |       4046 |          20 | ID                                |
        | world         | city            | PRIMARY         | 2021-01-14 12:09:51 | n_leaf_pages |         24 |        NULL | Number of leaf pages in the index |
        | world         | city            | PRIMARY         | 2021-01-14 12:09:51 | size         |         25 |        NULL | Number of pages in the index      |
        | world         | city            | index_name      | 2021-01-22 13:41:36 | n_diff_pfx01 |       3998 |          12 | Name                              |
        | world         | city            | index_name      | 2021-01-22 13:41:36 | n_diff_pfx02 |       4079 |          12 | Name,ID                           |
        | world         | city            | index_name      | 2021-01-22 13:41:36 | n_leaf_pages |         12 |        NULL | Number of leaf pages in the index |
        | world         | city            | index_name      | 2021-01-22 13:41:36 | size         |         13 |        NULL | Number of pages in the index      |
        | world         | city            | my_index03      | 2021-01-22 15:22:35 | n_diff_pfx01 |       1225 |           4 | District                          |
        | world         | city            | my_index03      | 2021-01-22 15:22:35 | n_diff_pfx02 |       4079 |           4 | District,ID                       |
        | world         | city            | my_index03      | 2021-01-22 15:22:35 | n_leaf_pages |          4 |        NULL | Number of leaf pages in the index |
        | world         | city            | my_index03      | 2021-01-22 15:22:35 | size         |          5 |        NULL | Number of pages in the index      |
        | world         | city            | my_index05      | 2021-01-22 15:26:36 | n_diff_pfx01 |       1320 |           5 | District                          |
        | world         | city            | my_index05      | 2021-01-22 15:26:36 | n_diff_pfx02 |       4079 |           5 | District,ID                       |
        | world         | city            | my_index05      | 2021-01-22 15:26:36 | n_leaf_pages |          5 |        NULL | Number of leaf pages in the index |
        | world         | city            | my_index05      | 2021-01-22 15:26:36 | size         |          6 |        NULL | Number of pages in the index      |
        | world         | city            | my_index_demo   | 2021-01-25 08:39:36 | n_diff_pfx01 |        232 |           5 | CountryCode                       |
        | world         | city            | my_index_demo   | 2021-01-25 08:39:36 | n_diff_pfx02 |       4052 |           5 | CountryCode,Population            |
        | world         | city            | my_index_demo   | 2021-01-25 08:39:36 | n_diff_pfx03 |       4079 |           5 | CountryCode,Population,ID         |
        | world         | city            | my_index_demo   | 2021-01-25 08:39:36 | n_leaf_pages |          5 |        NULL | Number of leaf pages in the index |
        | world         | city            | my_index_demo   | 2021-01-25 08:39:36 | size         |          6 |        NULL | Number of pages in the index      |
        | world         | city            | my_index_test01 | 2021-01-24 11:46:09 | n_diff_pfx01 |       3897 |           4 | Population                        |
        | world         | city            | my_index_test01 | 2021-01-24 11:46:09 | n_diff_pfx02 |       4079 |           4 | Population,ID                     |
        | world         | city            | my_index_test01 | 2021-01-24 11:46:09 | n_leaf_pages |          4 |        NULL | Number of leaf pages in the index |
        | world         | city            | my_index_test01 | 2021-01-24 11:46:09 | size         |          5 |        NULL | Number of pages in the index      |
        | world         | country         | PRIMARY         | 2021-01-14 12:09:41 | n_diff_pfx01 |        239 |           6 | Code                              |
        | world         | country         | PRIMARY         | 2021-01-14 12:09:41 | n_leaf_pages |          6 |        NULL | Number of leaf pages in the index |
        | world         | country         | PRIMARY         | 2021-01-14 12:09:41 | size         |          7 |        NULL | Number of pages in the index      |
        | world         | countrylanguage | CountryCode     | 2021-01-14 12:10:01 | n_diff_pfx01 |        233 |           3 | CountryCode                       |
        | world         | countrylanguage | CountryCode     | 2021-01-14 12:10:01 | n_diff_pfx02 |        984 |           3 | CountryCode,Language              |
        | world         | countrylanguage | CountryCode     | 2021-01-14 12:10:01 | n_leaf_pages |          3 |        NULL | Number of leaf pages in the index |
        | world         | countrylanguage | CountryCode     | 2021-01-14 12:10:01 | size         |          4 |        NULL | Number of pages in the index      |
        | world         | countrylanguage | PRIMARY         | 2021-01-14 12:10:01 | n_diff_pfx01 |        233 |           5 | CountryCode                       |
        | world         | countrylanguage | PRIMARY         | 2021-01-14 12:10:01 | n_diff_pfx02 |        984 |           5 | CountryCode,Language              |
        | world         | countrylanguage | PRIMARY         | 2021-01-14 12:10:01 | n_leaf_pages |          5 |        NULL | Number of leaf pages in the index |
        | world         | countrylanguage | PRIMARY         | 2021-01-14 12:10:01 | size         |          6 |        NULL | Number of pages in the index      |
        | oldboyedu   | staff           | PRIMARY         | 2021-01-18 23:40:41 | n_diff_pfx01 |          0 |           1 | id                                |
        | oldboyedu   | staff           | PRIMARY         | 2021-01-18 23:40:41 | n_leaf_pages |          1 |        NULL | Number of leaf pages in the index |
        | oldboyedu   | staff           | PRIMARY         | 2021-01-18 23:40:41 | size         |          1 |        NULL | Number of pages in the index      |
        | oldboyedu   | staff           | mobile_number   | 2021-01-18 23:40:41 | n_diff_pfx01 |          0 |           1 | mobile_number                     |
        | oldboyedu   | staff           | mobile_number   | 2021-01-18 23:40:41 | n_leaf_pages |          1 |        NULL | Number of leaf pages in the index |
        | oldboyedu   | staff           | mobile_number   | 2021-01-18 23:40:41 | size         |          1 |        NULL | Number of pages in the index      |
        | oldboyedu   | student         | PRIMARY         | 2021-01-25 10:07:30 | n_diff_pfx01 |      99613 |          20 | id                                |
        | oldboyedu   | student         | PRIMARY         | 2021-01-25 10:07:30 | n_leaf_pages |        537 |        NULL | Number of leaf pages in the index |
        | oldboyedu   | student         | PRIMARY         | 2021-01-25 10:07:30 | size         |        673 |        NULL | Number of pages in the index      |
        | oldboyedu   | student         | mobile_number   | 2021-01-25 10:07:30 | n_diff_pfx01 |     100116 |          20 | mobile_number                     |
        | oldboyedu   | student         | mobile_number   | 2021-01-25 10:07:30 | n_leaf_pages |        108 |        NULL | Number of leaf pages in the index |
        | oldboyedu   | student         | mobile_number   | 2021-01-25 10:07:30 | size         |        161 |        NULL | Number of pages in the index      |
        | oldboyedu   | student         | my_index01      | 2021-01-25 10:07:30 | n_diff_pfx01 |      99925 |          20 | name                              |
        | oldboyedu   | student         | my_index01      | 2021-01-25 10:07:30 | n_diff_pfx02 |      99925 |          20 | name,age                          |
        | oldboyedu   | student         | my_index01      | 2021-01-25 10:07:30 | n_diff_pfx03 |      99925 |          20 | name,age,id                       |
        | oldboyedu   | student         | my_index01      | 2021-01-25 10:07:30 | n_leaf_pages |        175 |        NULL | Number of leaf pages in the index |
        | oldboyedu   | student         | my_index01      | 2021-01-25 10:07:30 | size         |        225 |        NULL | Number of pages in the index      |
        +---------------+-----------------+-----------------+---------------------+--------------+------------+-------------+-----------------------------------+
        75 rows in set (0.27 sec)
        
        mysql> 
        
```

## 4.查询条件使用函数在索引列上，或者对索引列进行运算，运算包括:"+","-","*","/","!"等

```
    算数运算案例:
        错误案例:(查询并不走主键索引!)
            mysql> EXPLAIN SELECT * FROM oldboyedu.student WHERE id-1=9998;
            +----+-------------+---------+------------+------+---------------+------+---------+------+-------+----------+-------------+
            | id | select_type | table   | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra       |
            +----+-------------+---------+------------+------+---------------+------+---------+------+-------+----------+-------------+
            |  1 | SIMPLE      | student | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 99613 |   100.00 | Using where |
            +----+-------------+---------+------------+------+---------------+------+---------+------+-------+----------+-------------+
            1 row in set, 1 warning (0.00 sec)
            
            mysql> 
        正确案例:(查询并走主键索引!)
            mysql> EXPLAIN SELECT * FROM oldboyedu.student WHERE id=9999;
            +----+-------------+---------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
            | id | select_type | table   | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
            +----+-------------+---------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
            |  1 | SIMPLE      | student | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
            +----+-------------+---------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
            1 row in set, 1 warning (0.00 sec)
            
            mysql> 
            mysql> EXPLAIN SELECT * FROM oldboyedu.student WHERE id=9998+1;
            +----+-------------+---------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
            | id | select_type | table   | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
            +----+-------------+---------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
            |  1 | SIMPLE      | student | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
            +----+-------------+---------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
            1 row in set, 1 warning (0.00 sec)
            
            mysql> 

    温馨提示:
        除了上述的算术运算案例，起始对应的函数运算，子查询等均有可能会出现类似的情况。

```

## 5.隐式转换导致索引失效，这一点应当引起重视，也是开发中经常犯的错误，这样会导致索引失效

```
    首先创建一张测试表，我们要仔细观察"mobile_number"字段的数据类型为"CHAR"，先留个"彩蛋"继续往下看。
        mysql> CREATE TABLE IF NOT EXISTS oldboyedu.call_police (
            ->     id int PRIMARY KEY AUTO_INCREMENT COMMENT '编号ID',
            ->     alarm_type varchar(30) NOT NULL COMMENT '报警类型',
            ->     mobile_number CHAR(8) NOT NULL COMMENT '电话号码',
            ->     remarks VARCHAR(255) COMMENT '备注信息'
            -> )ENGINE=INNODB DEFAULT CHARSET=utf8mb4;
        Query OK, 0 rows affected (0.02 sec)
        
        mysql> 
        mysql> SHOW INDEX FROM oldboyedu.call_police;
        +-------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table       | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | call_police |          0 | PRIMARY  |            1 | id          | A         |           0 |     NULL | NULL   |      | BTREE      |         |               |
        +-------------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        1 row in set (0.00 sec)
        
        mysql> 

    接近着，我们为测试表的mobile_number"字段创建一个索引:
        mysql> CREATE INDEX  index_demo ON oldboyedu.call_police(mobile_number); 
        Query OK, 0 rows affected (0.02 sec)
        Records: 0  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SHOW INDEX FROM oldboyedu.call_police;
        +-------------+------------+------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table       | Non_unique | Key_name   | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------------+------------+------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | call_police |          0 | PRIMARY    |            1 | id            | A         |           0 |     NULL | NULL   |      | BTREE      |         |               |
        | call_police |          1 | index_demo |            1 | mobile_number | A         |           0 |     NULL | NULL   |      | BTREE      |         |               |
        +-------------+------------+------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        2 rows in set (0.00 sec)
        
        mysql> 

    下面的语句就是往测试表中插入数据:
        mysql> INSERT INTO oldboyedu.call_police
            ->     (alarm_type,mobile_number,remarks)
            -> VALUES
            ->     ("公安",110,"负责处理刑事、治安案件、紧急危难求助(迷路等)"),
            ->     ("救护车",120,"紧急医疗救援中心"),
            ->     ("交警",122,"交通事故处理"),
            ->     ("火警",119,"火灾隐患举报、火灾救援、技术援助(如车祸、人员被困)、化学援助(化学物质泄露)、生物援助(病虫害)");
        Query OK, 4 rows affected (0.00 sec)
        Records: 4  Duplicates: 0  Warnings: 0
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.call_police;
        +----+------------+---------------+-----------------------------------------------------------------------------------------------------------------------------------------+
        | id | alarm_type | mobile_number | remarks                                                                                                                                 |
        +----+------------+---------------+-----------------------------------------------------------------------------------------------------------------------------------------+
        |  1 | 公安       | 110           | 负责处理刑事、治安案件、紧急危难求助(迷路等)                                                                                                |
        |  2 | 救护车     | 120           | 紧急医疗救援中心                                                                                                                          |
        |  3 | 交警       | 122           | 交通事故处理                                                                                                                             |
        |  4 | 火警       | 119           | 火灾隐患举报、火灾救援、技术援助(如车祸、人员被困)、化学援助(化学物质泄露)、生物援助(病虫害)                                                    |
        +----+------------+---------------+-----------------------------------------------------------------------------------------------------------------------------------------+
        4 rows in set (0.00 sec)
        
        mysql> 

    重点来了，注意观察下面2条查询语句，得到的结果是相同的，但是不难发现一个是走索引的，一个是不走索引的，很明显，相同的数据类型查询方式是走索引的，不同的数据类型方式查询是不走索引的哟~
        mysql> SELECT * FROM oldboyedu.call_police WHERE mobile_number=110;  # "mobile_number"字段的数据类型是CHAR，但我们的确可以基于数字类型查询到结果哟~
        +----+------------+---------------+-------------------------------------------------------------------+
        | id | alarm_type | mobile_number | remarks                                                           |
        +----+------------+---------------+-------------------------------------------------------------------+
        |  1 | 公安       | 110           | 负责处理刑事、治安案件、紧急危难求助(迷路等)                      |
        +----+------------+---------------+-------------------------------------------------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> SELECT * FROM oldboyedu.call_police WHERE mobile_number='110';  # "mobile_number"字段的数据类型是CHAR，我们基于字符串自然是可以查询到结果的！
        +----+------------+---------------+-------------------------------------------------------------------+
        | id | alarm_type | mobile_number | remarks                                                           |
        +----+------------+---------------+-------------------------------------------------------------------+
        |  1 | 公安       | 110           | 负责处理刑事、治安案件、紧急危难求助(迷路等)                      |
        +----+------------+---------------+-------------------------------------------------------------------+
        1 row in set (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM oldboyedu.call_police WHERE mobile_number=110;  # 不难发现，我们基于数字查询是不走索引的，尽管"possible_keys"有数据，但是实际上"key"却为NULL。
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        | id | select_type | table       | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | call_police | NULL       | ALL  | index_demo    | NULL | NULL    | NULL |    4 |    25.00 | Using where |
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        1 row in set, 3 warnings (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM oldboyedu.call_police WHERE mobile_number='110';  # 而我们基于字符串类型查询数据是走索引的，不难发现key的值使我们创建的索引"index_demo"。
        +----+-------------+-------------+------------+------+---------------+------------+---------+-------+------+----------+-------+
        | id | select_type | table       | partitions | type | possible_keys | key        | key_len | ref   | rows | filtered | Extra |
        +----+-------------+-------------+------------+------+---------------+------------+---------+-------+------+----------+-------+
        |  1 | SIMPLE      | call_police | NULL       | ref  | index_demo    | index_demo | 32      | const |    1 |   100.00 | NULL  |
        +----+-------------+-------------+------------+------+---------------+------------+---------+-------+------+----------+-------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 

```

## 6.不等于("<>")符号，"NOT IN"等不走辅助索引（MySQL 8 测试貌似这种说法不成立!）

```
    注意哈，不等于("<>")符号，"NOT IN"等不走辅助索引:
        mysql> EXPLAIN SELECT * FROM oldboyedu.call_police WHERE mobile_number <> '110';
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        | id | select_type | table       | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | call_police | NULL       | ALL  | index_demo    | NULL | NULL    | NULL |    4 |   100.00 | Using where |
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM oldboyedu.call_police WHERE mobile_number NOT IN ('110','119');
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        | id | select_type | table       | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | call_police | NULL       | ALL  | index_demo    | NULL | NULL    | NULL |    4 |   100.00 | Using where |
        +----+-------------+-------------+------------+------+---------------+------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.01 sec)
        
        mysql> 

    温馨提示:
        (1)单独的">","<","IN"等有可能走索引，也可能不走索引，和结果集范围有关，尽量结合业务添加LIMIT;
        (2)OR或者IN尽量改写成UNION，但请注意，OR或者IN中的成员过多的话，可能会导致效果并不明显，甚至有可能性能变差;

```

## 7.LIKE关键字结合百分号前缀(即"%_")也不走索引

```
        mysql> SHOW INDEX FROM city;
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | Table | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        | city  |          0 | PRIMARY         |            1 | ID          | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | CountryCode     |            1 | CountryCode | A         |         232 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | index_name      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index_test01 |            1 | Population  | A         |        3897 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index01      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index01      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index01      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index02      |            1 | Name        | A         |        3998 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index02      |            2 | CountryCode | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index02      |            3 | Population  | A         |        4046 |     NULL | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index03      |            1 | District    | A         |        1225 |        5 | NULL   |      | BTREE      |         |               |
        | city  |          1 | my_index05      |            1 | District    | A         |        1320 |        8 | NULL   |      | BTREE      |         |               |
        +-------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
        12 rows in set (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE 'Zuid%';  # 注意哈，左边不加"%"号是走索引的哟~
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys         | key        | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | range | my_index03,my_index05 | my_index03 | 20      | NULL |    6 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+-----------------------+------------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
        mysql> EXPLAIN SELECT * FROM city WHERE District LIKE '%Zuid%';  # 注意哈，前后都加"%"号是不走索引的哟~
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | city  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 4046 |    11.11 | Using where |
        +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
        1 row in set, 1 warning (0.00 sec)
        
        mysql> 
```



# 七.MySQL优化器针对索引的算法(DBA方向的小伙伴可以了解一下，上课不讲)

## 1.MySQL默认启用的优化器算法概述

```
    关于MySQL官方的优化文档可参考以下链接:
        https://dev.mysql.com/doc/refman/8.0/en/optimization.html

    生产环境中，我们可能更关系的是查询的优化，如下所示:
        https://dev.mysql.com/doc/refman/8.0/en/select-optimization.html

    以下是查询MySQL默认启用的优化参数:
        mysql> SELECT @@OPTIMIZER_SWITCH\G
        *************************** 1. row ***************************
        @@OPTIMIZER_SWITCH: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=off,mrr=on,mrr_cost_based
        =on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on
        1 row in set (0.00 sec)
        
        mysql> 

    可能很多小伙伴对上述的优化参数不是特别清除,那么我们本章节就会专门介绍一些典型的优化器算法,目的是帮助咱们更加深入理解MySQL的底层实现,并未面试环节做铺垫。

```

## 2.优化器算法的使用管理

```
    以下是查询MySQL默认启用的优化参数:
        mysql> SELECT @@OPTIMIZER_SWITCH\G
        *************************** 1. row ***************************
        @@OPTIMIZER_SWITCH: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=off,mrr=on,mrr_cost_based
        =on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on
        1 row in set (0.00 sec)
        
        mysql> 

    以下是几种常见的修改MySQL默认的优化参数:
        (1)编辑my.cnf配置文件，启动数据库时默认的加载参数，缺点是需要重启MySQL数据库实例才能生效;
        (2)使用SET命令来修改参数，只是临时修改，好处是无需重启数据库实例，如下所示:
            mysql> SELECT @@OPTIMIZER_SWITCH\G
            *************************** 1. row ***************************
            @@OPTIMIZER_SWITCH: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=off,mrr=on,mrr_cost_based
            =on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on1 row in set (0.00 sec)
            
            mysql> 
            mysql> SET GLOBAL OPTIMIZER_SWITCH='index_condition_pushdown=on';  # 修改后并不会立即生效，如下所示，需要退出当前终端后方能生效！
            Query OK, 0 rows affected (0.01 sec)
            
            mysql> 
            mysql> SELECT @@OPTIMIZER_SWITCH\G
            *************************** 1. row ***************************
            @@OPTIMIZER_SWITCH: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=off,mrr=on,mrr_cost_based
            =on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on1 row in set (0.00 sec)
            
            mysql> 
            mysql> QUIT
            Bye
            [root@mysql108.oldboyedu.com ~]# 
            [root@mysql108.oldboyedu.com ~]# mysql -S /tmp/mysql23307.sock
            Welcome to the MySQL monitor.  Commands end with ; or \g.
            Your MySQL connection id is 14
            Server version: 5.7.31-log MySQL Community Server (GPL)
            
            Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
            
            Oracle is a registered trademark of Oracle Corporation and/or its
            affiliates. Other names may be trademarks of their respective
            owners.
            
            Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
            
            mysql> 
            mysql> SELECT @@OPTIMIZER_SWITCH\G  # 再次查看，发现上一次会话修改的配置生效啦~
            *************************** 1. row ***************************
            @@OPTIMIZER_SWITCH: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=on,mrr=on,mrr_cost_based=
            on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on1 row in set (0.00 sec)
            
            mysql> 
        (3)使用hints语句进行修改
            参考链接:
                https://dev.mysql.com/doc/refman/8.0/en/optimizer-hints.html
```

## 3.MySQL索引的自优化-"Adaptive Hash Index"(简称"AHI")

```
    自适应哈希索引(英文名称为: "Adaptive Hash Index"，简称"AHI")能够自动评估"热数据"的内存索引page并生成对应的HASH索引表。

    AHI可以帮助InnoDB存储引擎快速读取索引页，加快索引读取的速度。可以理解为建立索引的索引。

    参考链接:
        https://dev.mysql.com/doc/refman/5.7/en/innodb-architecture.html

    温馨提示:
        尽管我们所说MySQL内置有AHI类型的索引，但对于InnoDB存储引擎而言，最终实现还是基于Btree算法实现的。

```

## 4.MySQL索引的自优化-Change Buffer

```
    对于聚簇索引，对数据做了一些DML操作(比如: "INSERT","UPDATE","DELETE"等SQL语句)数据的变化会立即更新数据，而对于辅助索引，却不是实时更新的。
       
    在InnoDB内存结构中，早期版本加入了"INSERT BUFFER"(基于每个会话级别，内存大小我们可以控制)，现在版本称"CHANGE BUFFER"，其功能是在内存中临时缓冲辅助索引需要的数据更新(即不会将数据直接写入到磁盘，以减少I/O次数)。

    顾名思义，早期主要是对INSERT操作做BUFFER，现在的版本会针对INSERT,UPDATE,DELETE等操作进行BUFFER。换句话说，就是将辅助索引的修改存储在CHANGE BUFFER当中，并不会事实同步到磁盘;

    接下来我们分析一下数据的查询流程如下所示:
        (1)首先InnoDB在本地磁盘存储索引是以"*.ibd"文件进行存储的，当要查询数据时，需要将磁盘的数据读取到内存中在返回给用户;
        (2)当用户做的是修改操作时，如果改动的是聚簇索引，则会立即将修改同步到磁盘上;
        (3)如果改动的是辅助索引，则不会立即同步数据到磁盘，因为大多数情况下用户做的修改操作都是基于辅助索引来实现的。换句话说，就是将辅助索引的修改存储在CHANGE BUFFER(内存)中，并不会事实同步到磁盘;
        (4)当用户从磁盘上查询的是辅助索引的数据时，会将数据从磁盘加载到内存，而后再将其余CHANGE BUFFER的内容进行合并(merge)，而后可能需要回表查询聚簇索引的表，由于聚簇索引的数据是事实更新的，因此数据的查询准确性是无误的，而后将最终查询的最新数据返回给客户端;
        (5)如果辅助索引的CHANGE BUFFER的数据被查询到了，说明已经经过在内存merge的阶段，此时会将内存中的数据落地到本地磁盘，在数据落地到磁盘的过程中，这个过程会涉及到加锁的一些流程，后续文章会陆续介绍到;
        
    如果对InnoDB的存储引擎及查询机制还是有点懵的小伙伴别着急，后续还有专门的章节介绍存储引擎。这里先有个印象！

```

## 5.MySQL索引的优化器算法-"Index Condition Pushdown"(简称"ICP")，了解即可(可惜案例不太准确，待修改!):

```
    索引条件下推(英文名称为: "Index Condition Pushdown"，简称"ICP")是在MySQL 5.6版本引入的一种优化方案，它是将SQL优化的能力下推到存储引擎层进行过滤。

    可能光看上面的一句话很难理解啥事ICP，没关系，我们来通过下面的案例来体会一下ICP的作用:
        (1)先查看"oldboyedu.student"表结构并创建联合索引:
            mysql> DESC oldboyedu.student;
            +--------------------+-----------------------+------+-----+---------+----------------+
            | Field              | Type                  | Null | Key | Default | Extra          |
            +--------------------+-----------------------+------+-----+---------+----------------+
            | id                 | int(11)               | NO   | PRI | NULL    | auto_increment |
            | name               | varchar(30)           | NO   |     | NULL    |                |
            | age                | tinyint(3) unsigned   | YES  |     | NULL    |                |
            | gender             | enum('Male','Female') | YES  |     | Male    |                |
            | time_of_enrollment | datetime              | YES  |     | NULL    |                |
            | address            | varchar(255)          | NO   |     | NULL    |                |
            | mobile_number      | bigint(20)            | NO   | UNI | NULL    |                |
            | remarks            | varchar(255)          | YES  |     | NULL    |                |
            +--------------------+-----------------------+------+-----+---------+----------------+
            8 rows in set (0.00 sec)
            
            mysql> 
            mysql> SHOW INDEX FROM oldboyedu.student;
            +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            | Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
            +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            | student |          0 | PRIMARY       |            1 | id            | A         |       99613 |     NULL | NULL   |      | BTREE      |         |               |
            | student |          0 | mobile_number |            1 | mobile_number | A         |       99613 |     NULL | NULL   |      | BTREE      |         |               |
            +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            2 rows in set (0.00 sec)
            
            mysql> 
            mysql> CREATE INDEX my_index01 ON oldboyedu.student(name,age,gender);  # 创建3个字段的联合索引
            Query OK, 0 rows affected (0.72 sec)
            Records: 0  Duplicates: 0  Warnings: 0
            
            mysql> 
            mysql> SHOW INDEX FROM oldboyedu.student;
            +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            | Table   | Non_unique | Key_name      | Seq_in_index | Column_name   | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
            +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            | student |          0 | PRIMARY       |            1 | id            | A         |       99613 |     NULL | NULL   |      | BTREE      |         |               |
            | student |          0 | mobile_number |            1 | mobile_number | A         |       99613 |     NULL | NULL   |      | BTREE      |         |               |
            | student |          1 | my_index01    |            1 | name          | A         |       99613 |     NULL | NULL   |      | BTREE      |         |               |
            | student |          1 | my_index01    |            2 | age           | A         |       99613 |     NULL | NULL   | YES  | BTREE      |         |               |
            | student |          1 | my_index01    |            3 | gender        | A         |       99613 |     NULL | NULL   | YES  | BTREE      |         |               |
            +---------+------------+---------------+--------------+---------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
            5 rows in set (0.00 sec)
            
            mysql> 

        (2)执行SQL语句
            mysql> SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888';
            +--------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
            | id     | name            | age  | gender | time_of_enrollment  | address                  | mobile_number | remarks |
            +--------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
            | 100008 | oldboyedu8888 |   20 | Female | 2021-01-25 19:58:38 | 石家庄                   |   13355556666 | NULL    |
            | 100009 | oldboyedu8888 |   20 | Female | 2021-01-25 19:58:38 | 石家庄                   |   13355556667 | NULL    |
            | 100010 | oldboyedu8888 |   20 | Female | 2021-01-25 19:58:38 | 石家庄                   |   13355556668 | NULL    |
            | 100011 | oldboyedu8888 |   20 | Female | 2021-01-25 19:58:38 | 石家庄                   |   13355556669 | NULL    |
            | 100012 | oldboyedu8888 |   25 | Male   | 2021-01-25 19:58:38 | 石家庄                   |   13388889999 | NULL    |
            | 100013 | oldboyedu8888 |   25 | Male   | 2021-01-25 19:58:38 | 石家庄                   |   13388899999 | NULL    |
            | 100014 | oldboyedu8888 |   25 | Male   | 2021-01-25 19:58:38 | 石家庄                   |   13388999999 | NULL    |
            | 100015 | oldboyedu8888 |   25 | Male   | 2021-01-25 19:58:38 | 石家庄                   |   13389999999 | NULL    |
            |   8888 | oldboyedu8888 |  255 | Male   | 2021-01-22 14:15:03 | oldboyedu-address-8888 |          8888 | NULL    |
            +--------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
            9 rows in set (0.01 sec)
            
            mysql> 
            mysql> EXPLAIN SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888';
            +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-------+
            | id | select_type | table   | partitions | type | possible_keys | key        | key_len | ref   | rows | filtered | Extra |
            +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-------+
            |  1 | SIMPLE      | student | NULL       | ref  | my_index01    | my_index01 | 122     | const |    9 |   100.00 | NULL  |
            +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-------+
            1 row in set, 1 warning (0.00 sec)
            
            mysql> 
            mysql> SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888' AND gender='Male';
            +--------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
            | id     | name            | age  | gender | time_of_enrollment  | address                  | mobile_number | remarks |
            +--------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
            | 100012 | oldboyedu8888 |   25 | Male   | 2021-01-25 19:58:38 | 石家庄                   |   13388889999 | NULL    |
            | 100013 | oldboyedu8888 |   25 | Male   | 2021-01-25 19:58:38 | 石家庄                   |   13388899999 | NULL    |
            | 100014 | oldboyedu8888 |   25 | Male   | 2021-01-25 19:58:38 | 石家庄                   |   13388999999 | NULL    |
            | 100015 | oldboyedu8888 |   25 | Male   | 2021-01-25 19:58:38 | 石家庄                   |   13389999999 | NULL    |
            |   8888 | oldboyedu8888 |  255 | Male   | 2021-01-22 14:15:03 | oldboyedu-address-8888 |          8888 | NULL    |
            +--------+-----------------+------+--------+---------------------+--------------------------+---------------+---------+
            5 rows in set (0.00 sec)
            
            mysql> 
            mysql> EXPLAIN SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888' AND gender='Male';
            +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-----------------------+
            | id | select_type | table   | partitions | type | possible_keys | key        | key_len | ref   | rows | filtered | Extra                 |
            +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-----------------------+
            |  1 | SIMPLE      | student | NULL       | ref  | my_index01    | my_index01 | 122     | const |    9 |    50.00 | Using index condition |
            +----+-------------+---------+------------+------+---------------+------------+---------+-------+------+----------+-----------------------+
            1 row in set, 1 warning (0.00 sec)
            
            mysql> 

        (3)分析"SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888' AND gender='Male';"的SQL在有ICP和无ICP的执行方案:
            我们先分析"SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888' AND gender='Male';"在MySQL的server层的索引应用情况如下所示:
                该SQL仅使用到了联合索引的my_index01的name字段的索引,并没有用到联合索引的gender索引.
                
            在没有优化ICP方案之前:
                如下图所示，这意味着执行该SQL语句在底层调用时，只会用到"name"字段的索引，并不会使用到gender的索引。
                换句话说，就是在"SELECT * FROM oldboyedu.student WHERE name='oldboyedu8888';"的结果集上，再次过滤整个"gender"字段。

            在有优化ICP方案之后:
                如下图所示，这意味着执行该SQL语句在底层调用时，不但能用到"name"字段的索引，还会用到gender的索引。
                换句话说，就是直接过滤"name='oldboyedu8888' AND gender='Male';"这两个条件，一次性拿到结果。

        温馨提示:
            通过上述案例发现,在MySQL 5.7版本中，貌似给我们并没有默认启用ICP优化机制的错觉，但实际上是默认就启用了ICP策略，以下是查看方式:
                mysql> SELECT @@OPTIMIZER_SWITCH\G
                @@OPTIMIZER_SWITCH: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=off,mrr=on,mrr_cost_based
                =on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on1 row in set (0.00 sec)
                
                mysql> 
            此处我们理解ICP作用即可，如果想要具体案例推荐阅读以下链接:
                https://www.cnblogs.com/Terry-Wu/p/9273177.html
            
            上面的案例可能不足以说明本次问题，可自行参考官网文档:
                https://dev.mysql.com/doc/refman/8.0/en/index-condition-pushdown-optimization.html
                
```


## 6.MySQL索引的优化器算法-"Multi Range Read"(简称"MRR")，了解即可:

```
    "Multi Range Read"(简称"MRR")的功能可以将部分随机I/O转换为顺序I/O，最大的优点是减少了回表查询的次数。
    
    如果我们查询是基于辅助索引，通常语句基于聚簇索引进行回表查询，但这样会导致回表的次数过多，而且I/O的顺序大多数是随机的。

    为了改善上述情况下，MRR可以将辅助索引查询的结果在基于聚簇索引进行回表查询之前先进行排序，这样就将随机的I/O索引查询转换为顺序的I/O索引查询，即查询相同的数据量避免磁盘底层多次拨动磁头占用过多的磁盘寻到时间。
            
    温馨提示:
        MRR可以将部分随机I/O转换为顺序I/O这种概率是比较低的，比如排序后的id分别为10,100,1000,10000，它们是升序排序的，但很遗憾它们并不连续哟，因此并不是顺序I/O。
        但的确是减少了回表的次数，假设原顺序是"10000","10","1000","100",你会发现最少得回表查询多次，而"10","100","1000","10000"他们是顺序的，只需回表查询一次即可，减少了磁盘的寻道时间。即减少了IOPS。

    推荐阅读:
        https://mariadb.com/kb/en/multi-range-read-optimization/


    禁用"mrr_cost_based"参数:
        如下所示,默认是启用了"mrr"和"mrr_cost_based"两个功能:
            mysql> SELECT @@OPTIMIZER_SWITCH\G
            *************************** 1. row ***************************
            @@OPTIMIZER_SWITCH: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=off,mrr=on,mrr_cost_based
            =on,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on
            1 row in set (0.00 sec)
            
            mysql> 
        在绝大多数情况下,都会应用"mrr_cost_based"功能,很少会用到"mrr"功能哟,因此我们为了只是用mrr功能,可以先将"mrr_cost_based"功能临时关闭哟,如下所示:
            mysql> SET GLOBAL OPTIMIZER_SWITCH='mrr_cost_based=OFF';
            Query OK, 0 rows affected (0.00 sec)
            
            mysql> 

```

## 7.MySQL索引的优化器算法-Nested-Loop Join(简称:"NLJ")，包括下面的BNLJ算法，了解即可，如果生产环境中使用的是MySQL 8.0系列的话可以忽略这两种算法了。

```
    一种简单的Nested-Loop Join(简称:"NLJ")算法(Algorithm)一次从一个循环中的第一个表中读取行，然后将每一行传递给一个嵌套循环，该循环处理联接中的下一个表。重复此过程的次数与要连接的表的次数相同。

    假定将使用以下联接类型执行三个表t1，t2和 之间的 t3联接：
        Table   Join Type
        t1      range
        t2      ref
        t3      ALL
        
    如果使用简单的NLJ算法，则按以下方式处理联接：
        for each row in t1 matching range {
          for each row in t2 matching reference key {
            for each row in t3 {
              if row satisfies join conditions, send to client
            }
          }
        }

    因为NLJ算法从外循环到内循环一次传递一行，所以它通常会多次读取在内循环中处理的表。

    温馨提示:
        对于"A JOIN B ON A.xx = B.yy WHERE ...",可以通过"LEFT JOIN"强制驱动表。

    推荐阅读:
        https://dev.mysql.com/doc/refman/8.0/en/nested-loop-joins.html#nested-loop-join-algorithm

```



## 8.MySQL索引的优化器算法-Block Nested-Loop Join(简称"BNLJ")，可以理解是对"NLJ"的一种优化(减少CPU消耗和I/O次数)，可惜该算法在MySQL 8.0.20版本中已弃用!

```
    Block Nested-Loop Join(简称"BNLJ")嵌套算法(Algorithm)使用对在外部循环中读取的行的缓冲来减少必须读取内部循环中的表的次数。

    对于先前为BNLJ算法描述的示例连接（不带缓冲），使用连接缓冲按如下方式进行连接：
        for each row in t1 matching range {
          for each row in t2 matching reference key {
            store used columns from t1, t2 in join buffer
            if buffer is full {
              for each row in t3 {
                for each t1, t2 combination in join buffer {
                  if row satisfies join conditions, send to client
                }
              }
              empty join buffer
            }
          }
        }
        
        if buffer is not empty {
          for each row in t3 {
            for each t1, t2 combination in join buffer {
              if row satisfies join conditions, send to client
            }
          }
        }

    例如，如果将10行读入缓冲区并将缓冲区传递到下一个内部循环，则可以将内部循环中读取的每一行与缓冲区中的所有10行进行比较。这将内部表必须读取的次数减少了一个数量级。

    很多小伙伴看到BNLJ的算法后，发现其时间复杂度是O(N^3)，其底层的实现效率可想而知，因此在MySQL 8.0.18之前，当无法使用索引时，此算法(BNLJ)适用于等联接。在MySQL 8.0.18及更高版本中，在这种情况下采用了哈希联接优化。

    从MySQL 8.0.20开始，MySQL不再使用BNLJ，并且在以前使用过块嵌套循环的所有情况下都使用哈希联接。

    推荐阅读:
        https://dev.mysql.com/doc/refman/8.0/en/nested-loop-joins.html#block-nested-loop-join-algorithm
        https://dev.mysql.com/doc/refman/8.0/en/bnl-bka-optimization.html#bnl-optimization
        https://dev.mysql.com/doc/refman/8.0/en/hash-joins.html

```

## 9.MySQL索引的优化器算法-Batched Key Access Joins(简称"BKAJ")

``` 
    Batched Key Access Joins(简称"BKAJ")主要作用是来优化非驱动表的关联列有辅助索引的情况。简单可以理解"BKAJ" = "BNLJ" + "MRR"的功能

    BKAJ的算法默认是没有开启的，如果要临时开启可以使用SET命令，如下所示:
        mysql> SELECT @@OPTIMIZER_SWITCH\G
        *************************** 1. row ***************************
        @@OPTIMIZER_SWITCH: index_merge=on,index_merge_union=on,index_merge_sort_union=on,index_merge_intersection=on,engine_condition_pushdown=on,index_condition_pushdown=off,mrr=on,mrr_cost_based
        =off,block_nested_loop=on,batched_key_access=off,materialization=on,semijoin=on,loosescan=on,firstmatch=on,duplicateweedout=on,subquery_materialization_cost_based=on,use_index_extensions=on,condition_fanout_filter=on,derived_merge=on1 row in set (0.00 sec)
        
        mysql> 
        mysql> SET GLOBAL OPTIMIZER_SWITCH='batched_key_access=on';
        Query OK, 0 rows affected (0.00 sec)
        
        mysql> 

    推荐阅读:
        https://dev.mysql.com/doc/refman/8.0/en/bnl-bka-optimization.html#bka-optimization

```