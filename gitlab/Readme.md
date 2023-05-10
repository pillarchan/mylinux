# CentOS 7 搭建 gitlab 环境

### 一，更新系统

```powershell
yum update -y
```

#### 这个执行中间可能会需要 5 到 10 分钟左右，根据自己的网速快慢来决定执行的快慢，大家只需要耐心等待下就好了

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5520eeb06b1447d8dbaec1bf39a1fb6~tplv-k3u1fbpfcp-zoom-1.image)

### 二，安装 sshd

#### 2.1 安装 sshd 依赖

```powershell
yum install -y curl policycoreutils-python openssh-server
```

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d38f91d66e3149ed961db06be5ef224b~tplv-k3u1fbpfcp-zoom-1.image)

#### 2.2 接下来我们启用并启动 sshd：

```powershell
systemctl enable sshd
systemctl start sshd
```

#### 2.3 接下来我们配置下防火墙：

​ 打开 /etc/sysctl.conf 文件，在文件最后添加新的一行

```powershell
net.ipv4.ip_forward = 1
```

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/36a8efff0f324150acf15754b327bb8a~tplv-k3u1fbpfcp-zoom-1.image)

##### 我们只需要 sysctl.conf 在最后添加一行，按下 esc 加:wq 保存即可

### 三，接下来我们在安装 postfix

##### GitLab 需要使用 postfix 来发送邮件。当然，也可以使用 SMTP 服务器。

#### 3.1 安装 postfix

```powershell
yum install -y postfix
```

##### 打开 /etc/postfix/main.cf 文件，在第 119 行附近找到 inet_protocols = all，将 all 改为 ipv4

```powershell
inet_protocols = ipv4
```

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ebb675ea7a7b4c7692f469558bd9d9c6~tplv-k3u1fbpfcp-zoom-1.image)

#### 3.2 启用并启动 postfix：

```powershell
systemctl enable postfix
systemctl start postfix
```

### 3.3 配置 swap 交换分区

> ​ 由于 GitLab 较为消耗资源，我们需要先创建交换分区，以降低物理内存的压力。 在实际生产环境中，如果服务器配置够高，则不必配置交换分区。

### 3.4 新建 2 GB 大小的交换分区：

```powershell
dd if=/dev/zero of=/root/swapfile bs=1M count=2048
```

### 3.5 接下来我们对其格式化

```powershell
mkswap /root/swapfile
swapon /root/swapfile
```

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2cfc850de13f42ebb9786b386a5aef31~tplv-k3u1fbpfcp-zoom-1.image)

##### 添加自启用。打开 /etc/fstab 文件，在文件最后添加新的一行

```powershell
/root/swapfile swap swap defaults 0 0
```

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/42558515d80144f18a50cc25efa374c4~tplv-k3u1fbpfcp-zoom-1.image)

### 四，接下里我们安装 git

#### 4.1 安装 GitLab

> 将软件源修改为国内源 由于网络环境的原因，将 repo 源修改为清华大学 。

##### 在 /etc/yum.repos.d 目录下新建 gitlab-ce.repo 文件并保存。内容如下：

```powershell
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1
```

#### 4.2 修改完 yum 源，因此先重新生成缓存：

（此步骤执行时间较长，一般需要 3~5 分钟左右，请耐心等待）

```powershell
yum makecache
```

#### 4.3 安装 GitLab：

（此步骤执行时间较长，一般需要 3~5 分钟左右，请耐心等待）

```powershell
yum install -y gitlab-ce
```

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/597c47be90c2460d9c167c6b9c9660d7~tplv-k3u1fbpfcp-zoom-1.image) ![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b7bc9b0a8a6242448624f3d45d10d4a8~tplv-k3u1fbpfcp-zoom-1.image)

#### 五， 初始化 GitLab

##### 5.1 配置 GitLab 的域名（非必需）

###### 打开 /etc/gitlab/gitlab.rb 文件，在第 13 行附近找到 external_url 'http://gitlab.example.com'，将单引号中的内容改为自己的域名（带上协议头，末尾无斜杠）

```powershell
external_url 'http://119.29.102.85'
```

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/89df5a9a926c4a019f2064b451549bdc~tplv-k3u1fbpfcp-zoom-1.image)

#### 5.2 初始化 GitLab ==特别重要！==

###### 使用如下命令初始化 GitLab：

（此步骤执行时间较长，一般需要 5~10 分钟左右，请耐心等待）

```powershell
sudo gitlab-ctl reconfigure
```

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9bbb14a3b0a64ebb95db0ad2bf8af315~tplv-k3u1fbpfcp-zoom-1.image) ![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6608764925604340a75d331a4e0ce5ec~tplv-k3u1fbpfcp-zoom-1.image)

###### 当看到这个就说明我们 gitlab 已经安装成功了。

##### 5.3 启动成功之后我们通过浏览器访问下

![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f16f2536dc5643e1b3ec1982ce08f388~tplv-k3u1fbpfcp-zoom-1.image) ![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/99b4f30d7ad7442499d2c3f9032ec9b9~tplv-k3u1fbpfcp-zoom-1.image)

##### 当我们看到进入我们就可以对我们代码进行管理了。

回到我们开始的话题，有些朋友安装成功后看到的界面可能是这个 ![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/68fdb26ed25c4ce2a7688416adf3b78e~tplv-k3u1fbpfcp-zoom-1.image)

#### 这种情况出现的原因：

##### 原因 1、8080 端口被 tomcat 占用

###### 解决办法：更换端口

安装 tomcat 默认的是 8080 端口，netstat -ntpl 查看端口情况 ![在这里插入图片描述](https:////p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5928bce0c28240fca7667b6d49427990~tplv-k3u1fbpfcp-zoom-1.image) 最简单的方式我们就是把 8080 端口 kill 掉，然后改下端口号 为了避免 8080 端口冲突问题，可以修改下的默认端口，vim 打开/etc/gitlab/gitlab.rb 配置文件

#### 执行重新启动

```powershell
sudo gitlab-ctl reconfigure
sudo gitlab-ctl stop
sudo gitlab-ctl start
```

相关操作

> 启动服务：gitlab -ctl start
> 查看状态：gitlab -ctl status
> 停掉服务：gitlab -ctl stop
> 重启服务：gitlab -ctl restart
> 让配置生效：gitlab -ctl reconfigure

#### 原因 2、gitlab 占用内存太多，导致服务器崩溃。尤其是使用阿里云服务器最容易出现 502

##### 解决办法：默认情况下，主机的 swap 功能是没有启用的，解决办法是启动 swap 分区，就是我们上面启用的这里就不再过多解释了
