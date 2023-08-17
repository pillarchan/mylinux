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

java项目可以放在tomcat中，通过官网下载即可

推代码时不要推打包后的代码

创建jenkins maven 项目，配置mvn全局位置

## 3.Maven私服nexus

当公司几乎都是java项目时，可搭建
https://www.sonatype.com/download-oss-sonatype
环境 java 
安装nexus 启动
仓库选择public
proxy为后端仓库，可以改为国内镜像源
jenkins服务器需要重新配置maven的setting.xml

```

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

