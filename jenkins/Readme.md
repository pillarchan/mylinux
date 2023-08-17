# Jenkins

## 1.jenkins 安装

1. 安装 jdk

   ```
   sudo yum install java-1.8.0-openjdk.x86_64
   ```

2. 安装 jenkins

   ```
     sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
     sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
   
   ```

   If you've previously imported the key from Jenkins, the `rpm --import` will fail because you already have a key. Please ignore that and move on.

   ```
     yum install jenkins
   
   ```

   The rpm packages were signed using this key:

   ```
   pub   rsa4096 2020-03-30 [SC] [expires: 2023-03-30]
         62A9756BFD780C377CF24BA8FCEF32E745F2C3D5
   uid                      Jenkins Project
   sub   rsa4096 2020-03-30 [E] [expires: 2023-03-30]
   ```

3.配置文件

```
/etc/sysconfig/jenkins
/var/lib/jenkins/hudson.model.UpdateCenter.xml
/var/lib/jenkins/plugin/   插件位置
```

## 2.初始化

1.修改配置文件实现到国内镜像插件

/var/lib/jenkins/hudson.model.UpdateCenter.xml

```
?xml version='1.1' encoding='UTF-8'?>
<sites>
  <site>
    <id>default</id>    <url>https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json</url> //将此标签中的值换成国内插件镜像地
  </site>
</sites>
```

2.使用 nginx 反代到国内镜像站

1. 将域名解析到本地

   ```
   vim /etc/hosts

   127.0.0.1 updates.jenkins.io
   ```

2. 安装 nginx

   ```
   wget https://nginx.org/download/nginx-1.18.0.tar.gz
   tar zxvf nginx-1.18.0.tar.gz -C /usr/local/src
   cd /usr/local/src/nginx-1.18.0
   ./configure --prefix=/usr/local/nginx
   make && make install
   vim /etc/profile.d/nginx.sh
   ```

3. 修改 nginx 配置文件,添加反代到国内镜像

   ```
   location /download/plugins {
               rewrite /download/plugins(.*) /jenkins/plugins/$1 break;
               proxy_pass http://mirrors.tuna.tsinghua.edu.cn;
               proxy_set_header Host mirrors.tuna.tsinghua.edu.cn;
               proxy_set_header X-Real-IP $remote_addr;
               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
               proxy_set_header REMOTE-HOST $remote_addr;
           }
   ```

## 3.插件安装

可以将插件打包解压到 /var/lib/jenkins/plugins,然后重启jenkins

## 4.构建项目

```
general
1.丢弃旧的构建
```

## 5.war包装

```

nohup java -jar /usr/local/src/jenkins_2.361.4.war --httpPort=58080 > /var/lib/jenkins/jenkins.log 2>&1 &

/etc/profile.d/jenkins.sh 
export JENKINS_HOME="/var/lib/jenkins"



HELP文档
Running from: /usr/local/src/jenkins_2.361.4.war
webroot: $user.home/.jenkins
Jenkins Automation Server Engine 2.361.4
Usage: java -jar jenkins.war [--option=value] [--option=value]

Options:
   --webroot                = folder where the WAR file is expanded into. Default is ${JENKINS_HOME}/war
   --pluginroot             = folder where the plugin archives are expanded into. Default is ${JENKINS_HOME}/plugins
                              (NOTE: this option does not change the directory where the plugin archives are stored)
   --extractedFilesFolder   = folder where extracted files are to be located. Default is the temp folder
   --logfile                = redirect log messages to this file
   --enable-future-java     = allows running with new Java versions which are not fully supported (class version 55 and above)
   --javaHome               = Override the JAVA_HOME variable
   --toolsJar               = The location of tools.jar. Default is JAVA_HOME/lib/tools.jar
   --config                 = load configuration properties from here. Default is ./winstone.properties
   --prefix                 = add this prefix to all URLs (eg http://localhost:8080/prefix/resource). Default is none
   --commonLibFolder        = folder for additional jar files. Default is ./lib

   --extraLibFolder         = folder for additional jar files to add to Jetty classloader

   --logThrowingLineNo      = show the line no that logged the message (slow). Default is false
   --logThrowingThread      = show the thread that logged the message. Default is false
   --debug                  = set the level of debug msgs (1-9). Default is 5 (INFO level)

   --httpPort               = set the http listening port. -1 to disable, Default is 8080
   --httpListenAddress      = set the http listening address. Default is all interfaces
   --httpKeepAliveTimeout   = how long idle HTTP keep-alive connections are kept around (in ms; default 5000)?
   --httpsPort              = set the https listening port. -1 to disable, Default is disabled
   --httpsListenAddress     = set the https listening address. Default is all interfaces
   --httpsKeepAliveTimeout  = how long idle HTTPS keep-alive connections are kept around (in ms; default 5000)?
   --httpsKeyStore          = the location of the SSL KeyStore file. Default is ./winstone.ks
   --httpsKeyStorePassword  = the password for the SSL KeyStore file. Default is null
   --httpsKeyManagerType    = the SSL KeyManagerFactory type (eg SunX509, IbmX509). Default is SunX509
   --httpsRedirectHttp      = redirect http requests to https (requires both --httpPort and --httpsPort)
   --http2Port              = set the http2 listening port. -1 to disable, Default is disabled
   --httpsSniHostCheck      = if the SNI Host name must match when there is an SNI certificate. Check disabled per default
   --httpsSniRequired       = if a SNI certificate is required. Disabled per default
   --http2ListenAddress     = set the http2 listening address. Default is all interfaces
   --excludeCipherSuites    = set the ciphers to exclude (comma separated, use blank quote " " to exclude none) (default is
                           // Exclude weak / insecure ciphers 
                           "^.*_(MD5|SHA|SHA1)$", 
                           // Exclude ciphers that don't support forward secrecy 
                           "^TLS_RSA_.*$", 
                           // The following exclusions are present to cleanup known bad cipher 
                           // suites that may be accidentally included via include patterns. 
                           // The default enabled cipher list in Java will not include these 
                           // (but they are available in the supported list). 
                           "^SSL_.*$", 
                           "^.*_NULL_.*$", 
                           "^.*_anon_.*$" 
   --controlPort            = set the shutdown/control port. -1 to disable, Default disabled

   --useJasper              = enable jasper JSP handling (true/false). Default is false
   --sessionTimeout         = set the http session timeout value in minutes. Default to what webapp specifies, and then to 60 minutes
   --sessionEviction        = set the session eviction timeout for idle sessions in seconds. Default value is 180. -1 never evict, 0 evict on exit
   --mimeTypes=ARG          = define additional MIME type mappings. ARG would be EXT=MIMETYPE:EXT=MIMETYPE:...
                              (e.g., xls=application/vnd.ms-excel:wmf=application/x-msmetafile)
   --requestHeaderSize=N    = set the maximum size in bytes of the request header. Default is 8192.
   --responseHeaderSize=N    = set the maximum size in bytes of the response header. Default is 8192.
   --maxParamCount=N        = set the max number of parameters allowed in a form submission to protect
                              against hash DoS attack (oCERT #2011-003). Default is 10000.
   --useJmx                 = Enable Jetty Jmx
   --qtpMaxThreadsCount     = max threads number when using Jetty Queued Thread Pool
   --jettyAcceptorsCount    = Jetty Acceptors number
   --jettySelectorsCount    = Jetty Selectors number
   --usage / --help         = show this message
 Security options:
   --realmClassName               = Set the realm class to use for user authentication. Defaults to ArgumentsRealm class

   --argumentsRealm.passwd.<user> = Password for user <user>. Only valid for the ArgumentsRealm realm class
   --argumentsRealm.roles.<user>  = Roles for user <user> (comma separated). Only valid for the ArgumentsRealm realm class

   --fileRealm.configFile         = File containing users/passwds/roles. Only valid for the FileRealm realm class

 Access logging:
   --accessLoggerClassName        = Set the access logger class to use for user authentication. Defaults to disabled
   --simpleAccessLogger.format    = The log format to use. Supports combined/common/resin/custom (SimpleAccessLogger only)
   --simpleAccessLogger.file      = The location pattern for the log file(SimpleAccessLogger only)
```

## 6.遇坑

1. 未设置密码退出，不知道密码或忘记密码

   ```
   jenkins 停止服务后 修改 config.xml中
   <useSecurity>true</useSecurity> true 为 false
   修改前先备份文件
   重启服务后，访问页面 全局安全配置 Authentication>安全域>jenkins own database 保存后再到用户管理修改密码
   修改后，记得停服，恢复文件，再重启服务
   ```

   2.报错
   
   ```
   AWT is not properly configured on this server. Perhaps you need to run your container with "-Djava.awt.headless=true"? See also: https://www.jenkins.io/redirect/troubleshooting/java.awt.headless
   
   环境 java17 缺少fontconfig
   https://wiki.jenkins.io/display/JENKINS/Jenkins+got+java.awt.headless+problem#:~:text=You%20need%20to%20run%20the%20web%20container%20in,also%20shows%20the%20java.awt.headless%20is%20set%20to%20true.
   ```
   
   
   
   
