# jenkins gitlab 线上发布

## 1.通过标签部署

开发完成后，打tag

打标签命令

```
git tag -a 版本名 -m "描述"
git show 版本名       查看信息
git tag -a 版本名 hash值 -m "描述"    给早期版本打标签
git tag -d 版本名 删除
git push -u origin 版本名   将打好的标签版本进行推送
```

jenkins要通参数化构建

需提前安装 git paramater 插件，

参数化构建 > type为tag ，name，描述

构建脚本编写

设置回滚时使用选择参数

思路：备份->构建->覆盖，

内置变量：GIT_COMMIT,GIT_PREVIOUS_SUCCESSFUL_COMMIT

利用jenkins打标签思路：代码上传>jenkins拉取代码>脚本打标签并上传

## 2.Maven部署

环境 jenkins java apache_maven
maven命令

```
mvn package  项目打包
mvn clean 清除打包文件
```

由于maven服务器在国外，需要使用国内镜像源，在 maven/conf/settings.xml中mirror标签对中配置 

java项目可以放在tomcat中，通过官网或国内镜像下载即可，需配置
server.xml service标签中配置

推代码时不要推打包后的代码

创建jenkins maven 项目，配置mvn全局位置，需安安装插件Maven Integration,Jira,Pipeline Maven Integration

### 遇坑 

1. mvn打包hello-world遇到版本问题 原pom.xml中maven-war-plugin版本为2.1.1 环境为java17，安装java1.8并设置toolschain无效，修改pom.xml如下问题解决

   ```
   <plugin>
   				<groupId>org.apache.maven.plugins</groupId>
   				<artifactId>maven-war-plugin</artifactId>
   				<version>3.2.2</version>
   			</plugin>
   ```

   

2. tomcat 自动解压 war包,server.xml设置问题，unpackWARs="true"改为false

   ```
    <Host name="localhost"  appBase="/opt/mymaven"
               unpackWARs="false" autoDeploy="true">
   ```

   

3. 测试sonaqube时，创建新项目时使用已存在key无效



## 3.Maven私服nexus

当公司几乎都是java项目时，可搭建
https://www.sonatype.com/download-oss-sonatype
环境 java 

```
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

安装nexus 启动，启动前需添加nexus用户，并修改limits

```
nexus - nofile 65536
```

仓库选择public
proxy为后端仓库，可以改为国内镜像源

```
proxy>remote storage
http://maven.aliyun.com/nexus/content/groups/public
```

jenkins服务器需要重新配置maven的setting.xml

```
<mirror>
      <id>nexus-local</id>
      <mirrorOf>*</mirrorOf>
      <name>Nexus local</name>
      <url>nexus中repositories maven-public的值</url>
    </mirror>
```

## 4.pipline

分块执行shell命令进行部署的框架

```
pipline{
	agent any
	stages{
		stage('描述'){
			steps{
				echo 'get code'
			}
		}
		stage('unit test'){
			steps{
				
			}
		}
		stage('package'){
			steps{
				
			}
		}
		stage('deploy'){
			steps{
				
			}
		}
	}
}
```

