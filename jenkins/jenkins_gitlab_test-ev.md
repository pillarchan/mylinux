# gitlab_jenkins_test_ev

## 1.安装gitlab

https://about.gitlab.com
可根据官网文档安装即可

```
需修改配置文件 
/etc/gitlab/gitlab.rb
external_url 'url的值'

修改后,使用命令 
gitlab-ctl reconfigure 重载配置
gitlab-ctl start 然后启动
gitlab-ctl restart
gitlab-ctl stop
```



## 2.创建项目

1. 创建用户组，创建项目
2. 导入代码，使用git命令上传或url导入
3. 创建用户，添加至用户组，设置密码及权限

## 3.安装jenkins 

1. https://www.jenkins.io/zh/ 查看官方文档进行安装
2. 环境 java
3. 启动后，设置admin密码
4. jenkins目录 /var/lib/jenkins

## 4.安装插件 重启jenkins

1. 国内需修改国内镜像，文件 /var/lib/jenkins/hudson.model.UpdateCenter.xml，如：https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
2. 使用已打包好的插件，复制到/var/lib/jenkins/plugins，完后需要重启jenkins

## 5.jenkins创建项目

1. 创建freestyle项目

2. 配置项目

   ```
   丢弃旧的构建
   源码管理 需要做jenkins到gitlab的免密登录
   ```

## 6.拉取测试项目到jenkins本地

配置好构建项目后，就可以使用构建拉取代码到工作空间
/var/lib/jenkins/workspace/xxx

## 7.调用脚本推送代码到web服务器

配置构建选项 可使用shell脚本进行脚本编辑部署项目到应用服务器，需要做jenkins到应用服务器的免密登录

## 8.配置自动触发 git的master发生变化 jenkins会自动构建

1. 构建触发器中 创建Secret token
2. gitlab中对应项目中配置webhooks  URL和Secret token
3. 会遇到不支持本地网络，修改amdin>network>outbound request勾选Allow requests to the local network from web hooks and services保存

## 9.安装sonarqube服务 安装数据库 上传soarqube服务 配置数据库

1. 官网https://www.sonarsource.com/products/sonarqube

2. 根据官网版本要求安装环境 java postgresql

3. 配置postgresql

   ```
   /var/lib/pgsql/12/data/pg_hba.conf
   
   # TYPE  DATABASE        USER            ADDRESS                 METHOD
   
   # "local" is for Unix domain socket connections only
   local   all             all                                     trust
   # IPv4 local connections:
   host    all             all             127.0.0.1/32            trust
   
   ```

   使用postgresql创建sonarqube的数据库与schema

   ```
   修改密码 \password
   建库 CREATE DATABASE XXX
   使用库 \c xxx
   建schema CREATE SCHEMA xxx
   ```

4. 解压sonarqube,创建sonarqube用户并修改目录的属主属组

5. 配置sonarqube连接到本地数据库  文件sonarqube-7.0/conf/sonar.properties

   ```
   sonar.jdbc.username=
   sonar.jdbc.password=
   sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonar?currentSchema=sonar
   ```

6. 配置sonarqube 所需内核参数

   ```
   * hard nofile 65536
   * soft nofile 65536
   * hard nproc 65536
   * soft nproc 65536
   
   echo 524288 > /proc/sys/vm/max_map_count
   echo 131072 > /proc/sys/fs/file-max
   
   /etc/security/limits.d/99-sonarqube.conf
   sonarqube   -   nofile   131072
   sonarqube   -   nproc    8192
   ```

6. 使用sonar用户启动sonarqube

   ```
   su - sonar -c "/usr/local/sonarqube-9.9.1.69595/bin/linux-x86-64/sonar.sh start"
   ```

8. 访问页面，修改密码，创建项目，注意由页面自动生成的代码和token需保存，包括有客户端安装代码和客户端执行代码，以免以后不好找

## 10.jenkins安装客户端 先在命令行测试是否可以推送代码到sonarqube服务器

1. 使用自动生成的代码在jenkins服务器上进行客户端安装，需要注意java版本，因为jenkins也需要java支持，所以在这之前需要提前做版本选择
2. 客户端安装完成后，就可以使用扫描执行代码，在工作空间对应的目录进行测试扫描了

## 11.jenkins集成sonarqube 系统管理配置服务器的信息全局工具配置客户端的信息测试是否ok

1. 安装sonarqube的插件

2. 系统设置中配置sonarqube服务器地址

3. 配置凭证

4. 工具配置 sonarqube scanner，如果是解压安装的，需配置软件所在目录

5. 构建步骤增加sonarqube并配置参数

   ```
   sonar.projectName=${JOB_NAME}
   sonar.projectKey=html
   sonar.sources=. 
   sonar.login=
   ```

## 12.jenkins集成微信上半部

pip install name -i https://pypi.tuna.tsinghua.edu.cn/simple

```text
[global] 
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
```