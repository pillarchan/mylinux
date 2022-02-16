# ELK

## 什么是ELK

“ELK”是三个开源项目的首字母缩写，这三个项目分别是：Elasticsearch、Logstash 和 Kibana。Elasticsearch 是一个搜索和分析引擎。Logstash 是服务器端数据处理管道，能够同时从多个来源采集数据，转换数据，然后将数据发送到诸如 Elasticsearch 等“存储库”中。Kibana 则可以让用户在 Elasticsearch 中使用图形和图表对数据进行可视化。

Elastic Stack 是 ELK Stack 的更新换代产品。

## 基础知识

1. RESTful Resource Status Trancfer 资源状态转换。网络数据传输，由于对象无法传输，必须转换为字符串，而es识别json格式的字符串，就可以将对象信息以json格式的字符串传递，序列化之后作为查询对象使用
2. es是面对文档型数据库，一条数据就是一个文档，包括有索引，类型，文档，字段，而在7.x的版本中，类型概念已经不存在了
3. 排倒索引，通过一个关键字，查询到ID，再通过ID找到关联的文件内容的过程

## 安装配置

## 如何使用

1. 创建索引

   1. 开启es服务之后，使用PUT方式，提交 uri/索引名 就可以创建索引，当索引创建成功之后就不能创建同名索引了

2. 查询索引

   1. 使用GET方式，提交 uri/索引名 就可以查询索引
   2. 查询所有索引，则需要使用 uri/_cat/indicies?v

3. 删除索引

   1. 使用DELETE方式，提交 uri/索引名删除即可

4. 创建文档

   1. 使用POST方式，将json格式的数据 提交 uri/索引名/_doc, 即可创建文档，但此方式由于不是幂等行，所以创建出来的ID不同
   2. 使用POST或PUT方式，将json格式的数据 提交 uri/索引名/_doc/自定义ID, 即可创建文档，但此方式由于是幂等行，所以用于创建自定义ID

5. 查询文档

   1. 使用GET方式，提交 uri/索引名/_doc/ID 即可查询
   2. 使用GET方式，提交 uri/索引名/_search 即可查询全部文档

6. 全量数据更新和局部数据更新

   1. 使用PUT方式, 将新json格式数据，提交到 uri/索引名/_doc/ID,即可全量更新数据

   2. 使用POST方式，将json格式数据，提交到 uri/索引名/_update/ID,即可局部修改数据

      ```
      {
      	"doc":{
      		"key":"value"
      	}
      }
      ```

   3. 使用DELETE方式，提交到 uri/索引名/_doc/ID,即可局部修改数据