# Monogdb 社区版

官方文档：https://www.mongodb.com/docs/manual/

## 1.安装

### 	1.下载地址

### 		https://www.mongodb.com/try/download/community

###     2.安装server

1. 环境安装

   ```
   apt install libcurl4 libgssapi-krb5-2 libldap-common libwrap0 libsasl2-2 libsasl2-modules libsasl2-modules-gssapi-mit openssl liblzma5 -y
   ```

2. 下载包

   ```
   wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-debian12-7.0.8.tgz
   ```

3. 解压

   ```
   tar xf mongodb-linux-x86_64-debian12-7.0.8.tgz
   ```

4. 建立软链接

   ```
   ln -sv mongodb-linux-x86_64-debian12-7.0.8/ mongodb
   ```

5. 编辑profile文件

   ```
   echo 'export PATH="$PATH:/usr/local/mongodb70/bin"' > /etc/profile.d/mongo.sh
   source /etc/profile.d/mongo.sh
   ```

### 	3.安装mongosh

1. 下载包

   ```
   wget https://downloads.mongodb.com/compass/mongosh-2.2.3-linux-x64.tgz
   ```

2. 解压

   ```
   tar xf mongosh-2.2.3-linux-x64.tgz
   ```

3. 建立软链接

   ```
   ln -sv mongosh-2.2.3-linux-x64/ mongosh
   ```

4. 编辑profile文件

   ```
   echo 'export PATH="$PATH:/usr/local/mongosh/bin"' > /etc/profile.d/mongo.sh
   source /etc/profile.d/mongo.sh
   
   ```

5. 添加库文件

   ```
   cp mongosh/bin/mongosh_crypt_v1.so /usr/local/lib/
   ```

### 4.创建mongodb目录

```
mkdir -pv /data/mongodb/testshard/{auth,conf,configsvr/{data,log},shard1/{data,log},shard2/{data,log},shard3/{data,log},mongos/{data,log}}
```

## 2.配置

### 	1.文件格式

​		yml格式与 properties格式，主用yml格式

###     2.配置选项

1. shardsvr

   ```
   systemLog:
     path: /data/mongodb/testshard/shard1/log/shard1.log
     logAppend: true
     logRotate: reopen
     destination: file
     timeStampFormat: iso8601-local
   processManagement:
     fork: true
     pidFilePath: /data/mongodb/testshard/shard1/data/shard1.pid
     timeZoneInfo: /usr/share/zoneinfo/
   net:
      port: 27101
      bindIp: 0.0.0.0
   #   bindIpAll: <boolean>
      maxIncomingConnections: 5000
      unixDomainSocket:
         enabled: true
         pathPrefix: /data/mongodb/testshard/shard1/data
         filePermissions: 0700  
   security: 
     keyFile: /data/mongodb/testshard/auth/keyfile.key
     authorization: enabled
   setParameter:
      maxValidateMemoryUsageMB: 1024
      connPoolMaxConnsPerHost: 1000
   storage:
      dbPath: /data/mongodb/testshard/shard1/data
      journal:
         commitIntervalMs: 100
      directoryPerDB: true
      syncPeriodSecs: 60
      engine: wiredTiger
      wiredTiger:
         engineConfig:
            cacheSizeGB: 1
            journalCompressor: zlib
            directoryForIndexes: true
         collectionConfig:
            blockCompressor: zlib
         indexConfig:
            prefixCompression: true
   operationProfiling:
      mode: slowOp
      slowOpThresholdMs: 100
      slowOpSampleRate: 1.0
   replication:
      oplogSizeMB: 2048
      replSetName: test_shard1
   sharding:
      clusterRole: shardsvr
   ```

2. configsvr

   ```
   systemLog:
     path: /data/mongodb/testshard/configsvr/log/configsvr.log
     logAppend: true
     logRotate: reopen
     destination: file
     timeStampFormat: iso8601-local
   processManagement:
     fork: true
     pidFilePath: /data/mongodb/testshard/configsvr/data/configsvr.pid
     timeZoneInfo: /usr/share/zoneinfo/
   net:
      port: 27100
      bindIp: 0.0.0.0
   #   bindIpAll: <boolean>
      maxIncomingConnections: 2000
      unixDomainSocket:
         enabled: true
         pathPrefix: /data/mongodb/testshard/configsvr/data
         filePermissions: 0700  
   security: 
     keyFile: /data/mongodb/testshard/auth/keyfile.key
     authorization: enabled
   setParameter:
      maxValidateMemoryUsageMB: 1024
      connPoolMaxConnsPerHost: 1000
   storage:
      dbPath: /data/mongodb/testshard/configsvr/data
      journal:
         commitIntervalMs: 100
      directoryPerDB: true
      syncPeriodSecs: 60
      engine: wiredTiger
      wiredTiger:
         engineConfig:
            cacheSizeGB: 1
            journalCompressor: zlib
            directoryForIndexes: true
         collectionConfig:
            blockCompressor: zlib
         indexConfig:
            prefixCompression: true
   operationProfiling:
      mode: slowOp
      slowOpThresholdMs: 100
      slowOpSampleRate: 1.0
   replication:
      oplogSizeMB: 2048
      replSetName: repl_test_config
   sharding:
      clusterRole: configsvr
   ```

3. mongos

```
systemLog:
  path: /data/mongodb/testshard/mongos/log/mongos.log
  logAppend: true
  logRotate: reopen
  destination: file
  timeStampFormat: iso8601-local
processManagement:
  fork: true
  pidFilePath: /data/mongodb/testshard/mongos/data/mongos.pid
  timeZoneInfo: /usr/share/zoneinfo/
net:
   port: 27000
   bindIpAll: true
   maxIncomingConnections: 2000
   unixDomainSocket:
      enabled: true
      pathPrefix: /data/mongodb/testshard/mongos/data
      filePermissions: 0700  
security: 
  keyFile: /data/mongodb/testshard/auth/keyfile.key
sharding:
   repl_test_config/192.168.76.151:27100,192.168.76.151:27100,192.168.76.153:27100
```

### 3.keyfile文件

```
openssl rand -base64 512 > /data/mongodb/testshard/auth/keyfile.key
```

注意：使用 keyfile.key 文件，此文件权限必须为600或400，否则启动失败，使用的keyfile.key文件内容必须一致

### 4.服务的启动与停止

```
1.启动
mongod -f /data/mongodb/testshard/conf/configsvr.conf
mongod -f /data/mongodb/testshard/conf/shard1.conf
mongod -f /data/mongodb/testshard/conf/shard2.conf
mongod -f /data/mongodb/testshard/conf/shard3.conf

2.停止
mongod -f /data/mongodb/testshard/conf/configsvr.conf --shutdown
mongod -f /data/mongodb/testshard/conf/shard1.conf --shutdown
mongod -f /data/mongodb/testshard/conf/shard2.conf --shutdown
mongod -f /data/mongodb/testshard/conf/shard3.conf --shutdown
```

### 5.副本集初始化

1. 配置文件

   ```
   config = { _id:"repl_test_config",members:[{_id:0,host:"192.168.76.151:27100"},{_id:1,host:"192.168.76.152:27100"},{_id:2,host:"192.168.76.153:27100"}] }
   config = { _id:"test_shard1",members:[{_id:0,host:"192.168.76.151:27101"},{_id:1,host:"192.168.76.152:27101"},{_id:2,host:"192.168.76.153:27101"}] }
   config = { _id:"test_shard2",members:[{_id:0,host:"192.168.76.151:27102"},{_id:1,host:"192.168.76.152:27102"},{_id:2,host:"192.168.76.153:27102"}] }
   config = { _id:"test_shard3",members:[{_id:0,host:"192.168.76.151:27103"},{_id:2,host:"192.168.76.152:27103"},{_id:1,host:"192.168.76.153:27103"}] }
   ```

   

## 3.用户管理

### 1.角色

#### 	1.内置角色

1. ### Database User Roles

   1. read
   2. readWrite

2. ### Database Administration Roles

   1. dbAdmin 提供执行管理任务的能力，例如与架构相关的任务、索引和收集统计信息。 此角色不授予用户和角色管理权限。
   2. dbOwner  数据库所有者可以对数据库执行任何管理操作。 该角色结合了 readWrite、db Admin 和 user Admin 角色授予的权限。
   3. userAdmin 提供在当前数据库上创建和修改角色和用户的能力。 由于 userAdmin 角色允许用户向任何用户（包括他们自己）授予任何权限，因此该角色还间接提供对数据库或集群（如果范围仅限于管理数据库）的超级用户访问权限。

3. Cluster Administration Roles

   1. clusterAdmin 提供最大的集群管理访问权限。 该角色结合了 clusterManager、clusterMonitor 和 hostManager 角色授予的权限。 此外，该角色还提供 dropDatabase 操作。
   2. clusterManager 提供对集群的管理和监控操作。 具有此角色的用户可以访问配置数据库和本地数据库，它们分别用于分片和复制。
   3. clusterMonitor 提供对监控工具的只读访问，例如 MongoDB Cloud Manager 和 Ops Manager 监控代理。
   4. hostManager 提供监控和管理服务器的能力。

4. Backup and Restoration Roles

   1. backup
   2. restore

5. All-Database Roles

   1. readAnyDatabase
   2. readWriteAnyDatabase
   3. userAdminAnyDatabase
   4. dbAdminAnyDatabase

6. Superuser Roles

   1. root

#### 	2.自定义角色

### 2.用户

