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
    curl -X GET/POST http://192.168.76.117:9200/indexname/_search
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
curl -X POST http://192.168.76.117:9200/indexname/_search	
{"query":{"term":{"price":9999}}}
{"query":{"terms":{"price":[250,3999,599,1099]}}}
温馨提示：
	term主要用于精确匹配哪些值，比如数字，日期，布尔值或"not_analyzed"(未经分析的文本数据类型)的字符串。
	terms跟term有点类似，但terms允许指定多个匹配条件，如果某个字段指定了多个值，那么文档需要满足其一条件即可。
```

### 查询包含指定字段的文档

```
curl -X POST http://192.168.76.117:9200/indexname/_search
{"query":{"exists":{"field":"hobby"}}}
exists查询可以用于查找文档中是否包含指定字段或没有某个字段，这个查询只是针对已经查出一批数据来，但是想区分出某个字段是否存在的时候使用。
```

### 过滤查询

```
{"query":{"bool":{"filter":{"term":{"price":9999}}}}}}
match和filter查询对比:
(1)一条过滤(filter)语句会询问每个文档的字段值是否包含着特定值;
(2)查询(match)语句会询问每个文档的字段值与特定值的匹配程序如何:一条查询(match)语句会计算每个文档与查询语句的相关性，会给出一个相关性评分"_score"，并且按照相关性对匹配到的文档进行排序。这种评分方式非常适用于一个没有完全配置结果的全文本搜索。
(3)一个简单的文档列表，快速匹配运算并存入内存是十分方便的，每个文档仅需要1个字节。这些缓存的过滤结果集与后续请求的结果使用是非常高效的;
(4)查询(match)语句不仅要查询相匹配的文档，还需要计算每个文档的相关性，所以一般来说查询语句要比过滤语句更好使，并且查询结果也不可缓存。

温馨提示:
	做精确匹配搜索时，最好用过滤语句，因为过滤语句可以缓存数据。但如果要做全文搜索，需要通过查询语句来完成。
```

### 多词查询

```
(1)默认基于"or"操作符对某个字段进行多词搜索
curl -X GET http://192.168.76.117:9200/indexname/_search
{
    "query": {
        "bool": {
            "must": {
                "match": {
                    "title": {
                        "query": "曲面设计",
                        "operator": "or"
                    }
                }
            }
        }
    },
    "highlight":{
        "fields":{
            "title":{}
        }
    }
}
    
 
(2)基于"and"操作符对某个字段进行多词搜索
curl -X GET http://192.168.76.117:9200/indexname/_search
    {
        "query":{
            "bool":{
                "must":{
                    "match":{
                        "title":{
                            "query":"曲面显示器",
                            "operator":"and"
                        }
                    }
                }
            }
        },
        "highlight":{
            "fields":{
                "title":{}
            }
        }
    }
or与and的区别：
or只要查询的字段中包含有词中的任意一个字就会返回结果
and查询的字段中包含有词中的所有字才会返回结果
```

### 权重案例

```
有些时候，我们可能需要对某些词增加权重来影响这条数据的得分。
curl -X GET http://192.168.76.117:9200/indexname/_search
{
    "query": {
        "bool": {
            "must": {
                "match": {
                    "brand": {
                        "query": "小华罗",
                        "operator": "or"
                    }
                }
            },
            "should": [
                {
                    "match": {
                        "brand": {
                            "query": "小米",
                            "boost": 2
                        }
                    }
                },
                {
                    "match": {
                        "brand": {
                            "query": "华为",
                            "boost": 10
                        }
                    }
                },
                {
                    "match": {
                        "title": {
                            "query": "黑色",
                            "boost": 20
                        }
                    }
                }
            ]
        }
    },
    "highlight": {
        "fields": {
            "title": {},
            "brand": {}
        }
    }
}
权重关键字boost，通过增大它的值，就可以把分值提高，让权重较大的排在前面显示
```

### 聚合查询

```
可以理解为查询+聚合函数，把查询出来的结果再进行函数运算得到想要的结果，比如：求和、匀值、最大值、最小值等

语法格式：
        {
            "aggs": { // 聚合操作
                "name_of_aggregation": { // 该名称可以自定义，可基于相关字段起名称。
                    "function_name": { // 函数名
                        "field": "field_name" // 分组字段
                    }
                }
            },
            "size": 0 // 设置显示hits数据的大小，当size的值为0时，表示不查看原始数据!如果设置大于0，则显示指定的数据条数。如果设置为-1，则只显示10条，如果设置小于-1则报错!简单来说，就是显示多少行查询结果的详细数据
        }
例：
{
    "query": {
        "match_all": {}
    },
    "aggs": {
        "price_avg": {
            "avg": {
                "field": "price"
            }
        }
    },
    "size": 0
}
```

### 相关官文

DSL语句:
https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html
        
聚合函数:
https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html

## 自定义数据类型及关系映射(mapping)概述

### ElasticSearch中支持的类型

```
	创建的索引以及插入数据，都是由Elasticsearch Dynamic Mapping进行自动判断。

	有些时候需要进行明确的字段类型的，否则，自动判断的类型和实际需求是不相符的。

	此处针对字符串类型做一个简单的说明：（因为上面的案例的确用到了）
        string类型（deprecated，已废弃）:
            在ElasticSearch旧版本中使用较多，从ElasticSearch 5.x开始不再支持string，由text和keyword类型代替。

        text类型:
            当一个字段要被全文搜索的，比如Email内容，产品描述，应该使用text类型。
            设置text类型以后，字段内容会被分析，在生成倒排索引以前，字符串会被分词器分成一个一个词项。
            text类型的字段不用于排序，很少用于聚合。
            换句话说，text类型是可拆分的。

        keyword类型:
            适用于索引结构化的字段，比如email地址，主机名，状态码，标签，IP地址等。
            如果字段需要进行过滤(比如查找已发布博客中status属性为published的文章)，排序，聚合。keyword类型的字段只能通过精确值搜索到。
            换句话说，keyword类型是不可拆分的。
		还有其它更多的类型，不一一叙述
		常用的:
boolean
keyword
Numbers:
	byte
	short
	integer
	long
	double
date
    推荐阅读：
        https://www.elastic.co/guide/en/elasticsearch/reference/7.12/mapping-types.html

```

### 数据类型-自定义映射关系案例1-text-keyword-date-byte

```
创建index和mapping
{
    "settings": {
        "index": {
            "number_of_shards": 3,
            "number_of_replicas": 1
        }
    },
    "mappings": {
        "properties": {
            "name": {
                "type": "text"
            },
            "age": {
                "type": "byte"
            },
            "birthday": {
                "type": "date",
                "format": "yyyy-MM-DD"
            },
            "gender": {
                "type": "keyword"
            }
        }
    }
}
批量添加数据
{"create":{"_index":"employee"}}
{"name":"Tom","age":22,"birthday":"1994-09-09","gender":"male"}
{"create":{"_index":"employee"}}
{"name":"Jerry","age":21,"birthday":"1995-09-09","gender":"female"}
{"create":{"_index":"employee"}}
{"name":"Max","age":23,"birthday":"1993-09-09","gender":"female"}
{"create":{"_index":"employee"}}
{"name":"John","age":24,"birthday":"1992-09-09","gender":"male"}
{"create":{"_index":"employee"}}
{"name":"Rola","age":20,"birthday":"1996-09-09","gender":"female"}

测试查询
{
    "query":{
        "match":{
            "gender":"male"
        }
    }
}
```

### 数据类型-自定义映射关系案例1-ip

```
创建index和mapping
{
    "settings": {
        "index": {
            "number_of_shards": 3,
            "number_of_replicas": 1
        }
    },
    "mappings": {
        "properties": {
            "ip_addr": {
                "type": "ip"
            }
        }
    }
}
批量添加数据
{"create":{"_index":"inner_ip"}}
{"ip_addr":"192.168.10.111"}
{"create":{"_index":"inner_ip"}}
{"ip_addr":"192.168.10.113"}
{"create":{"_index":"inner_ip"}}
{"ip_addr":"192.168.10.112"}
{"create":{"_index":"inner_ip"}}
{"ip_addr":"127.0.0.1"}
{"create":{"_index":"inner_ip"}}
{"ip_addr":"172.16.11.123"}

测试查询
{
    "query":{
        "term":{
            "ip_addr":"192.168.10.0/24"
        }
    }
}
```

## 管理集群常用的API

### 1.查看集群的健康状态信息

```
curl -X GET  http://192.168.76.117:9200/_cluster/health?wait_for_status=yellow&timeout=50s&pretty

温馨提示:
	(1)wait_for_status表示等待ES集群达到状态的级别;
	(2)timeout表示指定等待的超时时间;
	(3)pretty表示美观的输出响应体，尤其是在浏览器输入;

以下是对响应结果进行简单的说明:
    cluster_name
        集群的名称。
    status
        集群的运行状况，基于其主要和副本分片的状态。
        常见的状态为：
            green：
                所有分片均已分配。
            yellow：
                所有主分片均已分配，但未分配一个或多个副本分片。如果群集中的节点发生故障，则在修复该节点之前，某些数据可能不可用。
            red：
                未分配一个或多个主分片，因此某些数据不可用。在集群启动期间，这可能会短暂发生，因为已分配了主要分片。
    timed_out：
        如果false响应在timeout参数指定的时间段内返回（30s默认情况下）。
    number_of_nodes：
        集群中的节点数。
    number_of_data_nodes：
        作为专用数据节点的节点数。
    active_primary_shards：
        活动主分区的数量。
    active_shards：
        活动主分区和副本分区的总数。
    relocating_shards：
        正在重定位的分片的数量。
    initializing_shards：
        正在初始化的分片数。
    unassigned_shards：
        未分配的分片数。
    delayed_unassigned_shards：
        其分配因超时设置而延迟的分片数。
    number_of_pending_tasks：
        尚未执行的集群级别更改的数量。
    number_of_in_flight_fetch：
        未完成的访存次数。
    task_max_waiting_in_queue_millis：
        自最早的初始化任务等待执行以来的时间（以毫秒为单位）。
    active_shards_percent_as_number：
        群集中活动碎片的比率，以百分比表示。

```

### 2.获取集群的配置信息

```
http://192.168.76.117:9200/_cluster/settings?include_defaults

修改
http://192.168.76.117:9200/_cluster/settings
{
    "persistent": {
        "cluster.routing.allocation.enable": "all"
        //"cluster.routing.allocation.enable": "primaries"
        //"cluster.routing.allocation.enable": "none"
    }
}
shard分配策略
	集群分片分配是指将索引的shard分配到其他节点的过程，会在如下情况下触发：
		(1)集群内有节点宕机，需要故障恢复；
		(2)增加副本；
		(3)索引的动态均衡，包括集群内部节点数量调整、删除索引副本、删除索引等情况；
	上述策略开关，可以动态调整，由参数cluster.routing.allocation.enable控制，启用或者禁用特定分片的分配。该参数的可选参数有：
		all(默认值):
			允许为所有类型分片分配分片；
        primaries:
            仅允许分配主分片的分片；
        new_primaries :
            仅允许为新索引的主分片分配分片；
        none:
            任何索引都不允许任何类型的分片；
温馨提示:
	(1)默认情况下，此API调用仅返回已显式定义的设置，包括"persistent"(持久设置)和"transient"(临时设置);
	(2)其中include_defaults表示的是默认设置；
```

### 3.查看集群的统计信息

```
curl -X GET http://192.168.76.117:9200/_cluster/stats
curl -X GET http://192.168.76.117:9200/_cluster/stats/nodes/<node_filter>
_all
_master
_local

路径参数说明:
https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.html#cluster-nodes

返回参数说明:
	https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-stats.html#cluster-stats-api-response-body
```

### 4.查看集群shard分配的分配情况

```
http://192.168.76.117:9200/_cluster/allocation/explain
查看主分片
{
    "index":"indexname",
    "shard":0,
    "primary":true
}
查看副本分片
{
    "index":"indexname",
    "shard":0,
    "primary":false
}
温馨提示:
	当您试图诊断shard未分配的原因，此API非常有用。
```

### 5.其他操作

```
推荐阅读: https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster.html
```

# 文档分词器及自定义分词案例

## 1.文档分析

```
	文档分析包含下面的过程:
		(1)将一块文本分成适合于倒排索引的独立的词条;
		(2)将这些词条统一化为标准格式以提高它们的"可搜索性"，或者recall分词器执行上面的工作。分析器实际上是将三个功能封装到了一个package里:
			字符过滤器:
				首先，字符串按顺序通过每个字符过滤器。他们的任务是在分词前整理字符串。一个字符过滤器可以用来去掉HTML，或者将&转化成and。
			分词器:
				其次，字符串被分词器分为单个的词条。一个简单的分词器遇到空格和标点的时候，可能会将文本拆分成词条。
			Token过滤器:
				最后，词条按照顺序通过每个token过滤器。这个过程可能会改变词条(例如，小写化，Quick)，删除词条(例如，像a,and,the等无用词)，或者增加词条(例如，像jump和leap这种同义词)。
```

## 2.内置分析器


	内置分析器:
		ES还附带了可以直接使用的预包装的分析器。接下来我们会列出最重要的分析器。为了证明它们的差异，我们看看每个分析器会从下面的字符串得到哪些词条。
		"Set the shape to semi-transparent by calling set_trans(5)"
	
	标准分析器:
		标准分析器是ES默认使用的分词器。它是分析各种语言文本最常用的选择。它根据Unicode联盟定义的单词边界划分文本。删除部分标点。最后将词条小写。所以它会分析出以下词条:
		set,the,shape,to,semi,transparent,by,calling,set_trans,5
		
	简单分析器:
		简单分析器在任何不是字母的地方分隔文本，将词条小写。所以它会产生以下词条:
		set,the,shape,to,semi,transparent,by,calling,set,trans
		
	空格分析器:
		空格分析器在空格的地方划分文本，所以它会产生以下词条:
		Set,the,shape,to,semi-transparent,by,calling,set_trans(5)
		
	语言分析器:
		特定语言分析器可用于很多语言。它们可以考虑指定语言的特点。例如，英语分析器还附带了无用词(常用单词，例如and或者the，它们对相关性没有多少影响)，它们会被删除。由于理解英语语法的规则，这个分词器可以提取英语单词的词干。所以英语分词器会产生下面的词条:
		set,shape,semi,transpar,call,set_tran,5
		注意看"transparent","calling"和"set_trans"已经变成词根格式。


## 3.分析器使用场景

```
	当我们索引一个文档，它的全文域被分析成词条以用来创建倒排索引。但是，当我们在全文域搜索的时候，我们需要将字符串通过相同的分析过程，以保证我们搜索的词条格式与索引中的词条格式一致。
	
```

## 4.测试分析器-标准分析器("standard")

```
有些时候很难理解分词的过程和实际被存储到索引的词条，特别是你刚接触ES。为了理解发生了上面，你可以使用analyze API来看文本时如何被分析的。

在消息体里，指定分析器和要分析的文本:
curl -X GET/POST http://192.168.76.117:9200/_analyze
    {
        "analyzer": "standard",
        "text":"My name is Jason Yin and I'm 18 years old!"
    }
```

## 5.ES内置的中文分词并不友好

```
在消息体里，指定分析器和要分析的文本:
curl -X GET/POST http://192.168.76.117:9200/_analyze
    {
        "text":"我爱北京天安门"
    }
```

## 6.中文分词器概述

```
	中文分词的难点在于，在汉语中没有明显的词汇分界点，如在英语中，空格可以作为分隔符，如果分隔符不正确就会造成歧义。常用中文分词器有IK，jieba，THULAC等，推荐使用IK分词器。

	"IK Analyzer"是一个开源的，基于Java语言开发的轻量级的中文分词工具包。从2006年12月推出1.0版本开始，IK Analyzer已经推出了3个大版本。最初，它是以开源项目Luence为应用主体的，结合词典分词和文法分析算法的中文分词组件。

	新版本的IK Analyzer 3.0则发展为面向Java的公用分词组件，独立于Lucene项目，同时提供对Lucene的默认优化实现。采用了特有的"正向迭代最新力度切分算法"，具有"80万字/秒"的高速处理能力。
	
	采用了多子处理器分析模式，支持: 英文字母(IP地址，Email，URL)，数字(日期，常用中文数量词，罗马数字，科学计数法)，中文词汇()姓名，地名处理等分词处理。优化的词典存储，更小的内存占用。

	IK分词器Elasticsearch插件地址:
		https://github.com/medcl/elasticsearch-analysis-ik
```

## 7.安装IK分词器插件

```
解压分词器到集群节点的插件目录即可 unzip -d
修改权限 chown -R
重启服务使得配置生效 kill -9 && su user -c "elasticsearch -d"
```

## 8.测试IK分词器

```
curl -X GET/POST http://192.168.76.117:9200/_analyze	
    {
        "analyzer": "ik_max_word",
        "text":"我爱北京天安门"
    }
curl -X GET/POST http://192.168.76.117:9200/_analyze
    {
        "analyzer": "ik_smart",  // 会将文本做最粗粒度的拆分。
        "text":"我爱北京天安门"
    }
IK分词器说明:
	"ik_max_word":
		会将文本做最细粒度的拆分。
	"ik_smart":
		会将文本做最粗粒度的拆分。
温馨提示：
	由于我将IK分词器只安装在了elk103节点上，因此我这里指定的ES节点就是按照的结点，生产环境中建议大家同步到所有节点。

```

## 9.自定义词汇

```
自定义词汇，文件名称可自行定义:
 vim /elasticsearch/plugins/ik/config/oldboy_custom.dic
艾欧里亚
德玛西亚
 cat /elasticsearch/plugins/ik/config/oldboy_custom.dic

将上面自定义词汇的文件名称写入IK分词器的配置文件中:
 cat /elasticsearch/plugins/ik/config/IKAnalyzer.cfg.xml 
﻿<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
	<comment>IK Analyzer 扩展配置</comment>
	<!--用户可以在这里配置自己的扩展字典 -->
	<entry key="ext_dict">
		xxx
	</entry>
	 <!--用户可以在这里配置自己的扩展停止词字典-->
	<entry key="ext_stopwords"></entry>
	<!--用户可以在这里配置远程扩展字典 -->
	<!-- <entry key="remote_ext_dict">words_location</entry> -->
	<!--用户可以在这里配置远程扩展停止词字典-->
	<!-- <entry key="remote_ext_stopwords">words_location</entry> -->
</properties>

重启ES服务使得配置生效
温馨提示:
	(1)建议将IK分词器同步到集群的所有节点;
	(2)修改"IKAnalyzer.cfg.xml"的配置文件时，我只修改了key="ext_dict"这一行配置项目，如下所示:
	"<entry key="ext_dict">custom.dic</entry>"
```

## 10.测试自定义词汇是否生效

```
curl -X GET/POST http://192.168.76.117:9200/_analyze
    {
        "analyzer":"ik_smart",
        "text": "嗨，兄弟，你LOL哪个区的，我艾欧里亚和德玛西亚都有号"
    }
```

# 索引模板

## 1.索引模板的作用

```
	索引模板是创建索引的一种方式。将数据写入指定索引时，如果该索引不存在，则根据索引名称能匹配相应索引模板话，会根据模板的配置建立索引。
	
	推荐阅读:
		https://www.elastic.co/guide/en/elasticsearch/reference/master/index-templates.html
```

## 2.查看内置的索引板

```
	查看所有的索引模板信息:
		curl -X GET http://192.168.76.117:9200/_template?pretty
	查看某个索引模板信息:
		curl -X GET http://192.168.76.117:9200/_template/indexname?pretty
```

## 3.创建索引模板

```
curl -X PUT http://192.168.76.117:9200/_template/indexname
    {
        "index_patterns": [
            "indexname*"
        ],
        "settings": {
            "index": {
                "number_of_shards": 5,
                "number_of_replicas": 0,
                "refresh_interval": "30s"
            }
        },
        "mappings": {
            "properties": {
                "@timestamp": {
                    "type": "date"
                },
                "name": {
                    "type": "keyword"
                },
                "address": {
                    "type": "text"
                }
            }
        }
    }
```

## 4.删除索引模板

```
curl -X DELETE http://192.168.76.117:9200/_template/indexname
```

## 5.修改索引模板(注意修改是覆盖修改哟~)

```
curl -X PUT http://192.168.76.117:9200/_template/indexname
    {
        "index_patterns": [
            "indexname*"
        ],
        "settings": {
            "index": {
                "number_of_shards": 10,
                "number_of_replicas": 0,
                "refresh_interval": "30s"
            }
        },
        "mappings": {
            "properties": {
                "id": {
                    "type": "keyword"
                },
                "name": {
                    "type": "keyword"
                },
                "gender": {
                    "type": "keyword"
                }
            }
        }
    }
```

## 6.创建索引进行测试

```
不指定副本和分片创建索引：
	curl -X PUT  http://192.168.76.117:9200/indexname	
指定副本和分片创建索引:
	curl -X PUT  http://192.168.76.117:9200/indexname
        {
            "settings":{
                "index":{
                    "number_of_replicas":1,
                    "number_of_shards":3
                }
            }
        }     
```

