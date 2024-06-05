## 部署

### 环境

### ulimit

```
ulimit -SHn 63335 或 
vim /etc/security/limit.conf
* - nofile 65535
```

### 内核参数

```
vm.memory_map_count = 262144
```

### 配置文件

```
/usr/local/elasticsearch-7.15.0/config/elasticsearch.yml
cluster.name
node.name
network.host
discovery.seed_hosts
cluster.initial_master_nodes
```

注意：

​	数据目录中的nodes会导致无法启动，或者无法识别集群

## 概念

### 架构图

filebeat(收集)->kafka(削峰处理)->logstash->es(存储、分析)->kibana(展示)

### The Elastic Stack, 包括Elasticsearch、Kibana、Beats和Logstash(也称为 ELK Stack)。

ElaticSearch：
	简称为ES， ES是一个开源的高扩展的分布式全文搜索引擎，是整个Elastic Stack技术栈的核心。
	它可以近乎实时的存储、检索数据；本身扩展性很好，可以扩展到上百台服务器，处理PB级别的数据。
	
Kibana：
	是一个免费且开放的用户界面，能够让您对Elasticsearch数据进行可视化，并让您在Elastic Stack中进行导航。
	您可以进行各种操作，从跟踪查询负载，到理解请求如何流经您的整个应用，都能轻松完成。

Beats：
	是一个免费且开放的平台，集合了多种单一用途数据采集器。
	它们从成百上千或成千上万台机器和系统向Logstash 或 Elasticsearch发送数据。

Logstash：
	是免费且开放的服务器端数据处理管道，能够从多个来源采集数据，转换数据，然后将数据发送到您最喜欢的“存储库”中。


Elastic Stack的主要优点有如下几个:
	(1)处理方式灵活：
		elasticsearch是实时全文索引，具有强大的搜索功能。
	(2)配置相对简单：
		elasticsearch全部使用JSON 接口，logstash使用模块配置，kibana的配置文件部分更简单。
	(3)检索性能高效：
		基于优秀的设计，虽然每次查询都是实时，但是也可以达到百亿级数据的查询秒级响应。
	(4)集群线性扩展：
		elasticsearch和logstash都可以灵活线性扩展。
	(5)前端操作绚丽：
		kibana的前端设计比较绚丽，而且操作简单。

推荐阅读:
	https://www.elastic.co/guide/index.html
	https://www.elastic.co/guide/cn/elasticsearch/guide/current/index.html
	https://www.elastic.co/guide/cn/kibana/current/index.html
	

### 可收集的日志

```
容器管理工具：
	docker

负载均衡服务器：
	lvs，haproxy，nginx

web服务器：
	httpd，nginx，tomcat

数据库：
	mysql，redis，MongoDB，Hbase，Kudu，ClickHouse，PgSQL

存储：
	nfs，gluterfs，fastdfs，HDFS，Ceph

系统：
	message，security

业务：
	包括但不限于C，C++，Java，PHP，Go，Python，Shell等编程语言研发的App。
```

## ElasticSearch相关术语介绍

### 文档（Document）

文档就是用户存在ElasticSearch的一些数据，它是ElasticSearch中**存储数据的最小单元**。	
文档类似于MySQL数据库中表中的一行数据。每个文档都有唯一的"_id"标识，我们可以自定义"_id"（不推荐），如果不指定ES也会自动生成。	
一个文档是一个可被索引的基础信息单元，也就是一条数据。在一个"index/_doc"里面，我们可以存储任意多的文档。	
文档是以JSON（Javascript Object Notaion)格式来表示，而JSON是一个到处存在的互联网数据交互格式。	
JSON比XML更加轻量级，目前JSON已经成为互联网事实的数据交互标准了，几乎是所有主流的编程语言都支持。

### 字段（Filed）

相当于数据库表的字段，对文档数据根据不同属性进行的分类标识。

在ES中，Document就是一个Json Object，一个json object其实是由多个字段组成的，每个字段它由不同的数据类型。

  推荐阅读：
        https://www.elastic.co/guide/en/elasticsearch/reference/7.12/mapping-types.html

### 索引(index)

一个索引就是**一个拥有相似特征的文档（Document）的集合**。假设你的公司是做电商的，可以将数据分为客户，产品，订单等多个类别，在ES数据库中就对应多个索引。

ES索引、文档、字段关系小结：
	一个索引里面存储了很多的Document 文档，一个文档就是一个json object，一个json object是由多个不同的filed字段组成；

Elasticsearch索引的精髓：一切设计都是为了提高搜索的性能。换句话说，在ES存储的数据，万物皆索引，如果数据没有索引则无法查询数据。

### 分片（Shards）

我们假设平均1个文档占用2k大小，那么按照utf-8对中文的字符编码，该文档能存储682（2 * 1024 / 3）个汉字。
如果我们要存储30亿条数据，则需要使用5722GB(3000000000 * 2k，不足6T)存储空间，
一个索引可以存储超出单个节点硬件限制的大量数据。比如，一个具有30亿文档数据的索引占据6TB的磁盘空间。
如果一个集群有3台服务器，单个节点的磁盘存储空间仅有4T磁盘空间，很明显某一个节点是无法存储下6TB数据的。或者单个节点处理搜索请求，响应太慢。
为了解决这个问题，elasticsearch提供了将索引划分成多份的能力，每一份都称之为分片。
当你创建一个索引的时候，你可以指定你想要的分片数量。每个分片本身也是一个功能完善并且独立的"索引"，这个"索引"可以被放置到集群中的任何节点上。
分片很重要，主要有两方面的原因：
	(1)允许你水平分割/扩展你的内容容量，当然你也可以选择垂直扩容；
	(2)允许你在各节点上的分片进行分布式，并行的操作，从而显著提升性能（包括但不限于CPU，内存，磁盘，网卡的使用），最显著的是吞吐量的提升;
至于一个分片怎么分布，它的文档怎样聚合和搜索请求，是完全由elasticsearch管理的，对于作为用户的你来说，这些都是透明的，无需过分关心。
温馨提示：
	一个Lucene索引我们在Elasticsearch称作分片。
	一个ElasticSearch索引是分片的集合。
	当ElasticSearch在索引中搜索的时候，她发送查询到每一个属于索引的分片(Lucene索引)，然后合并每个分片的结果到一个全局的结果集。

### 副本（Replicas）

​	无论是在公司内部的物理机房，还是在云环境中，节点故障随时都有可能发生，可能导致这些故障的原因包括但不限于服务器掉电，Raid阵列中的磁盘损坏，网卡损坏，同机柜交换机损坏等。
​	在某个分片/节点不知为何就处于离线状态，或者由于任何原因消失了，这种情况下，有一个故障转移机制是非常有用并且是强烈推荐的。
​	为此目的，elasticsearch允许你创建分片的一份或多份拷贝，这些拷贝叫做复制分片（我们也习惯称之为“副本”）。
​	副本之所以重要，主要有以下两个原因：
​		（1）在分片/节点失败的情况下，提供了高可用性。因为这个原因，注意到复制分片从不与主分片(primary shard)置于同一个节点上是非常重要的;
​		(2)扩展你的搜索量/吞吐量，因为搜索可以在所有的副本上并行运行；
​	总之，每个索引可以被分配成多个分片。一个索引也可以被复制0次(意思是没有副本分片，仅有主分片)或多次。
​	一旦复制了，每个索引就有了主分片(作为复制源的原来的分片)和复制分片(主分片的拷贝)之别。分片和复制的数量可以在索引创建的时候指定。
​	在索引创建之后，你可以在任何时候动态地改变复制的数量，但是你事后不能改变分片的数量。
​	默认情况下，elasticsearch中的每个索引被分片1个主分片和1个复制分片，这样的话一个索引总共就有2个分片，我们需要根据索引需求确定分片个数。

### 分配（Allocation）

所谓的分配就是将分片分配给某个节点的过程，包括主分片或者副本。如果是副本，还包含从主分片复制数据的过程，这个过程由master节点完成的。

### 类型（type）

在elasticsearch 5.x及更早的版本，在一个索引中，我们可以定义一种或多种类型。但在ES 7.x版本中，仅支持"_doc"类型。

一个索引是你的索引的一个逻辑上的分类/分区，其语义完全由你来定，通常，会为具有一组共同字段的文档定义一个类型。







## ES索引的管理

### 查

```
通过工具postman 访问查询 http://192.168.76.117:9200/_cat/indices?v 或
curl http://192.168.76.117:9200/_cat/indices?v

health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 6IGvk9eJQHqa6E7PZtqefA   1   1         33            0     61.3mb         30.6mb

以下是对响应结果进行简单的说明:
	health:
		green:
			所有分片均已分配。
		yellow:
			所有主分片均已分配，但未分配一个或多个副本分片。如果群集中的节点发生故障，则在修复该节点之前，某些数据可能不可用。
		red:
			未分配一个或多个主分片，因此某些数据不可用。在集群启动期间，这可能会短暂发生，因为已分配了主要分片。
	status:
		索引状态，分为打开和关闭状态。
	index:
		索引名称。
	uuid:
		索引唯一编号。
	pri:
		主分片数量。
	rep:
		副本数量。
	docs.count:
		可用文档数量。
	docs.deleted:
		文档删除状态(逻辑删除)。
	store.size:
		主分片和副分片整体占空间大小。
	pri.store.size:
		主分片占空间大小。
```

### 查看是否存在

```
通过工具postman 访问查询 http://192.168.76.117:9200/indexname 或
curl -X HEAD http://192.168.76.117:9200/indexname

返回值为200则存在，若404则不存在
```

### 增

```
通过工具postman 访问查询 http://192.168.76.117:9200/indexname 或
curl -x PUT -d  http://192.168.76.117:9200/indexname

可选提交的数据如下:
    {
        "settings": {
            "index": {
                "number_of_replicas": "1",
                "number_of_shards": "3"
            }
        }
    }
    
    温馨提示:
	(1)对于提交的参数说明:
		"number_of_replicas"参数表示副本数。
		"number_of_shards"参数表示分片数。
	(2)对于返回的参数说明:
		"acknowledged"参数表示响应结果，如果为"true"表示操作成功。
		"shards_acknowledged"参数表示分片结果,如果为"true"表示操作成功。
		"index"表示索引名称。
	(3)创建索引库的分片数默认为1片，在7.0.0之前的Elasticsearch版本中，默认为5片。
	(4)如果重复添加索引，会返回错误信息;
```

### 删

```
通过工具postman 访问查询 http://192.168.76.117:9200/newindex 或
curl -x DELETE  http://192.168.76.117:9200/newindex

通配符删除

通过工具postman 访问查询 http://192.168.76.117:9200/newindex—_* 或
curl -x DELETE  http://192.168.76.117:9200/newindex_*
```

### 索引别名管理

```
通过工具postman 访问查询 http://192.168.76.117:9200/_aliases或
curl -X POST http://192.168.76.117:9200/_aliases

提交数据如下:
	（1）添加别名：
        {
          "actions" : [
            { "add" : { "index" : "linux-2020-10-3", "alias" : "linux2020" } },
            { "add" : { "index" : "linux-2020-10-3", "alias" : "linux2021" } }
          ]
        }
        
	（2）删除别名
        {
          "actions" : [
            { "remove" : { "index" : "linux-2020-10-3", "alias" : "linux2025" } }
          ]
        }

	（3）重命名别名
        {
          "actions" : [
            { 
                "remove" : { "index" : "linux-2020-10-3", "alias" : "linux2023" } 
            },
            {
                "add": { "index" :"linux-2020-10-3" , "alias" : "linux2025" }
            }
          ]
        }
	
	（4）为多个索引同时添加别名
        {
          "actions" : [
            {
                "add": { "index" :"bigdata3" , "alias" : "linux666" }
            },
            {
                "add": { "index" :"bigdata2" , "alias" : "linux666" }
            },
            {
                "add": { "index" :"linux-2020-10*" , "alias" : "linux666" }
            }
          ]
        }


温馨提示:
	(1)索引别名是用于引用一个或多个现有索引的辅助名称。大多数Elasticsearch API接受索引别名代替索引;
	(2)加索引后请结合"elasticsearch-head"的WebUI进行查看;
	(3)一个索引可以关联多个别名，一个别名也能被多个索引关联;
	
```

### 索引状态开启与关闭

```
关闭某一个索引：
	通过工具postman 访问查询 http://192.168.76.117:9200/linux-2020-10-1/_close或
	curl -X POST http://192.168.76.117:9200/linux-2020-10-1/_close
关闭批量索引：
	通过工具postman 访问查询 http://192.168.76.117:9200/linux-2020-*/_close或
	curl -X POST http://192.168.76.117:9200/linux-2020-*/_close
温馨提示:
	(1)如果将索引关闭，则意味着该索引将不能执行任何打开索引状态的所有读写操作，当然这样也会为服务器节省一定的集群资源消耗；
	(2)生产环境中，我们可以将需要删除的索引先临时关闭掉，可以先关闭7个工作日，然后在执行删除索引，因为光关闭索引尽管能减少消耗但存储空间依旧是占用的;
	(3)关闭索引后，记得查看现有索引信息，并结合"elasticsearch-head"插件的WebUI界面进行查看哟;

打开某一索引:
	通过工具postman 访问查询 http://192.168.76.117:9200/linux-2020-10-3/_open
	curl -X POST  http://192.168.76.117:9200/linux-2020-10-3/_open
打开批量索引:
	通过工具postman 访问查询 http://192.168.76.117:9200/linux-2020-*/_open
	curl -X POST  http://192.168.76.117:9200/linux-2020-*/_open
```

## ES文档管理

### 增

```
	通过工具postman 访问查询 http://192.168.76.117:9200/indexname/_doc[/id_num]
	curl -X POST  http://192.168.76.117:9200/indexname/_doc[/id_num]
	
	方法2：
		通过工具postman 访问查询 http://192.168.76.117:9200/indexname/_doc[/id_num]
		curl -X PUT  http://192.168.76.117:9200/indexname/_doc[/id_num]
	方法3：
		通过工具postman 访问查询 http://192.168.76.117:9200/indexname/_create[/id_num]
		curl -X PUT  http://192.168.76.117:9200/indexname/_create[/id_num]
	
	建议：不要去自定义_id，除非可以做到去重，如果需要用到id可以自行添加一个id字段
	
	肯定是有请求体的json如：
	{
		"name":"haha",
		"age":39,
		"department":"IT",
		"ID":10001
	}
```

### 查

```
全查：
	通过工具postman 访问查询 http://192.168.76.117:9200/indexname/_search
	curl -X POST  http://192.168.76.117:9200/indexname/_search
根据_id查
	通过工具postman 访问查询 http://192.168.76.117:9200/indexname/_doc/<_id>
	curl -X POST  http://192.168.76.117:9200/indexname/_doc/<_id>
```

### 改

```
	通过工具postman 访问查询 http://192.168.76.117:9200/indexname/_update/<_id>
	curl -X POST  http://192.168.76.117:9200/indexname/_update/<_id>
	
	{
		"doc":{
			"field":"xxx"
		}
	}
```

### 删

```
	通过工具postman 访问查询 http://192.168.76.117:9200/indexname/_doc/<_id>
	curl -X DELETE  http://192.168.76.117:9200/indexname/_doc/<_id>
```

## ES文档管理批量操作

### 增

```
通过工具postman 访问查询 http://192.168.76.117:9200/_bulk
curl -X POST http://192.168.76.117:9200/_bulk
	
请求体格式
{"action":{metadata}}\n
{"field1":"xxx","field2":"xxx","field3":"xxx",...}\n
{"action":{metadata}}\n
{"field1":"xxx","field2":"xxx","field3":"xxx",...}\n

例：
curl -X POST http://192.168.76.117:9200/_bulk
{"create":{"_index":"company_primary","_type":"_doc","_id":"100001"}}
{"name":"Michel","age":20,"department":"administrator"}
{"create":{"_index":"company_primary","_type":"_doc","_id":"100002"}}
{"name":"Jason","age":21,"department":"developer"}

实际操作中，metadata可以只指定_index。最后一行一定要留空行：
{"create":{"_index":"company_primary"}}
{"name":"Michel","age":20,"department":"administrator"}
{"create":{"_index":"company_primary"}}
{"name":"Jason","age":21,"department":"developer"}

```

### 查

```
通过工具postman 访问查询 http://192.168.76.117:9200/indexname/_mget
curl -X POST  http://192.168.76.117:9200/indexname/_mget

{
    "ids":["qlPA448BkL65zOK-H9-x","qVPA448BkL65zOK-H9-x"]
}
必须要知道id
```

### 删

```
通过工具postman 访问查询 http://192.168.76.117:9200/_bulk
curl -X POST http://192.168.76.117:9200/_bulk
	
请求体格式
{"action":{metadata}}\n
{"action":{metadata}}\n
{"action":{metadata}}\n

例：
curl -X POST http://192.168.76.117:9200/_bulk
{"delete":{"_index":"company_primary","_type":"_doc","_id":"100001"}}
{"delete":{"_index":"company_primary","_type":"_doc","_id":"100002"}}
{"delete":{"_index":"company_primary","_type":"_doc","_id":"100002"}}

最后一行一定要留空行

```

## ES DSL查询

### 条件查询

```
curl http://192.168.76.117:9200/indexname/_search

{
    "query":{
        "match":{
            "field":"xxx"
        }
    }
}

全量查
{
    "query":{
        "match_all":{}
    }
}
```

### 分页查询

```
curl http://192.168.76.117:9200/indexname/_search

{
    "query":{
        "match":{
            "field":"xxx"
        }
    },
	"from": 10,
    "size": 3
}

全量查
{
    "query":{
        "match_all":{}
    },
    "from": 10,
    "size": 3
}
	字段说明：
        from:
            指定跳过的数据偏移量大小，默认是0。
            查询指定页码的from值 = ”(页码 - 1) * 每页数据条数“。
        size:
            指定显示的数据条数大小，默认是10。

	在集群系统中深度分页：
		我们应该当心分页太深或者一次请求太多的结果，结果在返回前会被排序。
		但是记住一个搜索请求常常涉及多个分片。
		每个分片生成排好序的结果，它们接着需要集中起来排序以确保整体排序顺序。
		
	为了理解为什么深度分页是有问题的，让我们假设在一个有5个主分片的索引中搜索:
        (1)当我们请求结果的第一页(结果1到10)时，每个分片产生自己最顶端10个结果然后返回它们给请
        求节点(requesting node)，它在排序这所有的50个结果以筛选出顶端的10个结果；
        (2)现在假设我们请求第1000页，结果10001到10010，工作方式都相同，不同的时每个分片都必须
        产生顶端的10010个结果，然后请求节点排序这50050个结果并丢弃50040个;
        (3)你可以看到在分布式系统中，排序结果的花费随着分页的深入而成倍增长，这也是为什么网络
        搜索引擎中任何语句返回多余1000个结果的原因；
        
        
   客户端请求分页查询时，会先请求到协调节点，如果数据有分片，并且存在不同的分片上，协调节点向其它分片请求数据，此时不同分片上的被请求的数据结果经过升序降序排序后先返回给协调节点，协调节点会再次排序将指定的多少条记录返回给客户端
```

### 只查看返回数据的指定字段

```
curl http://192.168.76.117:9200/indexname/_search

{
    "query":{
        "match_all":{}
    },
	"from": 10,
    "size": 3,
    "_source":["title","price"]
}
```

### 查看指定字段并排序

```
curl http://192.168.76.117:9200/indexname/_search

{
    "query": {
        "match_all": {}
    },
    "from": 9,
    "size": 3,
    "sort":{
        "price":{
            "order":"asc"
        }
    }
}

desc降序 asc升序
```

### 多条件查询

```
    	bool查询可以用来合并多个条件查询结果的布尔逻辑，这些参数可以分别继承一个查询或者一个查询条件的数组。
    	bool查询包含以下操作符:
    		must:
            	多个查询条件的完全匹配，相当于"and"。
            must_not:
            	多个查询条件的相反匹配，相当于"not"。
            should:
                至少有一个查询条件匹配，相当于"or"。
{"query":{"bool":{"must":[{"match":{"brand":"DELL"}},{"match":{"price":3999}}]}}}
{"query":{"bool":{"should":[{"match":{"brand":"DELL"}},{"match":{"price":3999}}],"minimum_should_match":2}}}
{"query":{"bool":{"should":[{"match":{"brand":"DELL"}},{"match":{"price":3999}}],"minimum_should_match":"65%"}}}
	评分计算规则：
		(1)bool查询会为每个文档计算相关度评分"_score"，再将所有匹配的must和should语句的分数"_score"求和，最后除以must和should语句的总数。
		(2)must_not语句不会影响评分，它的作用只是将不相关的文档排除。
		(3)默认情况下，should中的内容不是必须匹配的，如果查询语言中没有must，那么就会至少匹配其中一个。当然，也可以通过"minimum_should_match"来指定匹配度，该值可以是数字(例如"2")也可以是百分比(如"65%")。
```

### 范围查询

```
{"query":{"bool":{"filter":{"range":{"price":{"lt":1000,"gt":200}}}}}}

关键字段filter
lt,gt,lte,gte
```

### 全文检索

```
{"query":{"match":{"brand":"小苹华"}}}

当使用match匹配时，match查询会在真正查询之前用分词器先分析，会将用户要查询的词汇进行分开匹配，从而查询到结果
默认的中文分词器并不太适合使用，生产环境建议更换分词器，比如IK分词器等。
```

### 全文匹配

```
{"query":{"match_phrase":{"brand":"小苹华"}}}

当使用match_phrase匹配时，match_phrase会将用户要查询的内容进行视为一个整体支查询结果
```

### 语法高亮

```
    curl -X GET/POST http://192.168.76.117:9200/shopping/_search
        {
            "query":{
                "match_phrase":{
                    "brand":"苹果"
                }
            },
            "highlight":{
                "fields":{
                    "brand":{}
                }
            }
        }
 与query同级，会将以查询条件返回结果的词进行高亮标记       
```

### 精确匹配查询

```
curl -X POST http://elk101.oldboyedu.com:9200/shopping/_search	
{"query":{"term":{"price":9999}}}
{"query":{"terms":{"price":[250,3999,599,1099]}}}
温馨提示：
	term主要用于精确匹配哪些值，比如数字，日期，布尔值或"not_analyzed"(未经分析的文本数据类型)的字符串。
	terms跟term有点类似，但terms允许指定多个匹配条件，如果某个字段指定了多个值，那么文档需要满足其一条件即可。
```

