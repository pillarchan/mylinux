# Jenkins

## 1.jenkins安装

1. 安装jdk

   ```
   sudo yum install java-1.8.0-openjdk.x86_64
   ```

2. 安装jenkins

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
/var/lib/jenkins/plugin/   插件位置
```

## 2.初始化

1.修改配置文件实现到国内镜像插件

/var/lib/jenkins/hudson.model.UpdateCenter.xml

```
?xml version='1.1' encoding='UTF-8'?>
<sites>
  <site>
    <id>default</id>
    <url>https://updates.jenkins.io/update-center.json</url> //将此标签中的值换成国内插件镜像地 
  </site>
</sites>
```

2.使用nginx反代到国内镜像站

1. 将域名解析到本地

   ```
   vim /etc/hosts
   
   127.0.0.1 updates.jenkins.io
   ```

2. 安装nginx

   ```
   wget https://nginx.org/download/nginx-1.18.0.tar.gz
   tar zxvf nginx-1.18.0.tar.gz -C /usr/local/src
   cd /usr/local/src/nginx-1.18.0
   ./configure --prefix=/usr/local/nginx
   make && make install
   vim /etc/profile.d/nginx.sh
   ```

3. 修改nginx配置文件,添加反代到国内镜像

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

## 3.基础配置

1. 系统管理->系统配置
   1. 系统管理员邮件地址
   2. 邮件通知  注意:SMTP中的密码指是SMTP的授权码并非登录密码![image-20210130174639751](https://i.loli.net/2021/01/30/yagUvlEdhTFOeC7.png)
2. 

