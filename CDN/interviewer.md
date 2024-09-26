# 一台新如何做初始化

配置yum 或 apt 仓库
安装必要常用软件
调整时区
简单的内核优化
net.ipv4.tcp_fin_timeout = 6
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_orphans = 16384
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384

# iptables 简单syn攻击防御

### 1: Drop invalid packets ### 阻止不可用包
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
### 2: Drop TCP packets that are new and are not SYN ### 丢弃新的非 SYN TCP 数据包
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
### 3: Drop SYN packets with suspicious MSS value ###丢弃具有可疑mss值的syn数据包 最大报文长度
最大报文段长度（MSS）表示TCP传往另一端的最大块数据的长度也是接受的长度。
当一个连接建立时，连接的双方都要通告各自的MSS(因此MSS选项只能出现在SYN报文段中)。
如果一方不接收来自另一方的MSS值，则MSS就定为默认值536字节（这个默认值允许20字节的IP首部和20字节的TCP首部以适合576字节IP数据报)。
对于一个以太网，MSS值可达1460字节。
iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
### 4: Block packets with bogus TCP flags ### 阻止带有伪造 TCP 标志的数据包
    SYN 表示建立连接，
    FIN 表示关闭连接，
    ACK 表示响应，
    PSH 表示有 DATA数据传输，
    RST 表示连接重置。

其中，ACK是可能与SYN，FIN等同时使用的，比如SYN和ACK可能同时为1，
它表示的就是建立连接之后的响应，如果只是单个的一个SYN，它表示的只是建立连接，TCP的几次握手就是通过这样的ACK表现出来的。
但SYN与FIN是不会同时为1的，因为前者表示的是建立连接，而后者表示的是断开连接。
RST一般是在FIN之后才会出现为1的情况，表示的是连接重置。
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
### 5: Block spoofed packets ### 丢弃伪造的数据包
iptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP
iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP
iptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP
iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP
iptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP
iptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP
iptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP
iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP
iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP
### 6: 禁ping
iptables -t mangle -A PREROUTING -p icmp -s ?.?.?.? -j ACCEPT
iptables -t mangle -A PREROUTING -p icmp -j DROP
### 7. 丢弃在所有链中丢弃碎片
iptables -t mangle -A PREROUTING -f -j DROP
### 8. raw里不追踪syn
iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT
iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j NOTRACT
### 9. 限制tcp RST 的流量
iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
###
iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
### 11. filter表中丢弃不可用包
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# php-fpm的优化

在 php-fpm.conf 中设置 pm.start_servers 和 pm.max_children 的值
pm.start_servers 是 php-fpm 在启动时创建的进程数。pm.max_children 是 php-fpm 可以创建的最大进程数。
php.ini 中设置 opcache.enable 为 1
在 php.ini 中设置 opcache.memory_consumption 的值 一般设置为内存的25%

# nginx的优化

调整 worker_processes 和 worker_connections 的值
启用 epoll
启用 keepalive
启用 gzip 压缩
缓存静态文件
Nginx 可以缓存静态文件，例如图像、CSS 和 JavaScript 文件。这可以避免每次请求都从磁盘读取文件，从而提高性能。
要缓存静态文件，请在 http { section 中设置 location /static { root /path/to/static/files; add_header Cache-Control "public, max-age=31536000"; }。
使用 sendfile 模块来提高文件传输性能。
使用 proxy_cache 模块来缓存动态内容。
使用 FastCGI 模块来处理 PHP 请求。
使用 Brotli 模块来压缩 HTTP 响应。

expires：设置文件的缓存过期时间。
cache-control：设置更复杂的缓存控制指令。

proxy_cache on;
proxy_cache_path /var/cache/nginx/;
proxy_cache_valid 1d;
proxy_cache_max_size 1g;

# Nginx 监控的一般指标可以分为

## 工作进程指标

worker_processes：当前正在运行的 worker 进程数。
active_connections：当前活动的连接数。
handled_connections：已经处理的连接数。
requests_processed：已经处理的请求数。
bytes_served：已经传送的字节数。

## 连接指标

accepts：接受的新连接数。
handled_requests：已经处理的请求数。
requests_failed：失败的请求数。
bytes_read：已经读取的字节数。
bytes_written：已经写入的字节数。

## 缓存指标

cache_hits：缓存命中的次数。
cache_misses：缓存未命中的次数。
bytes_cached：缓存的字节数。

# mysql一般监控哪些指标

## **连接情况**

- **当前连接数**：表示当前正在连接到MySQL数据库的客户端数量。
- **已建立连接数**：表示自MySQL服务器启动以来建立的连接总数。
- **已断开连接数**：表示自MySQL服务器启动以来断开的连接总数。
- **连接拒绝数**：表示由于连接数达到最大值或其他原因而被拒绝的连接数。

## **性能指标**

- **QPS**（每秒查询数）：表示每秒执行的查询数量。
- **TPS**（每秒事务数）：表示每秒执行的事务数量。
- **平均查询时间**：表示平均每个查询执行所花费的时间。
- **慢查询**：表示执行时间超过指定阈值的查询。

## **缓存命中率**

- **Key cache 命中率**：表示查询中使用的键能够从key cache中命中并直接返回的比例。
- **Query cache 命中率**：表示查询能够从query cache中命中的比例。
- **Table cache 命中率**：表示表能够从table cache中命中的比例。

## **InnoDB**

- **InnoDB 缓冲池命中率**：表示InnoDB缓冲池能够命中读取请求的比例。
- **InnoDB 脏页比例**：表示InnoDB缓冲池中脏页（已修改但未提交到磁盘的页）的比例。
- **InnoDB I/O**：表示InnoDB从磁盘读取或写入数据的速率。

## **其他指标**

- **CPU使用率**：表示CPU被MySQL使用的比例。
- **内存使用率**：表示内存被MySQL使用的比例。
- **磁盘I/O**：表示MySQL使用的磁盘I/O速率。

# linux 漏洞扫描工具

## Nessus

## nmap

Nmap（Network Mapper）是一款开源的网络探测和安全审计工具。它可以用来发现网络上的主机、服务和端口，并识别安全漏洞。Nmap 的核心功能包括：

- **主机发现**：Nmap 可以扫描网络并识别所有活跃的主机。它可以使用各种技术来发现主机，包括发送 ICMP 响应、TCP SYN 数据包和 UDP 数据包。
- **端口扫描**：Nmap 可以扫描主机上的端口以确定它们是否开放、关闭或被过滤。它可以使用各种技术来扫描端口，包括 TCP SYN 数据包、TCP ACK 数据包和 UDP 数据包。
- **版本检测**：Nmap 可以识别运行在主机上的服务和应用程序的版本。它可以发送特定的数据包或请求来获取有关服务的版本信息。
- **操作系统检测**：Nmap 可以识别主机的操作系统。它可以发送特定的数据包或请求来获取有关操作系统的详细信息。
- **脚本支持**：Nmap 支持 Nmap 脚本语言，该语言可以用于编写自定义扫描和分析功能。

Nmap 可用于多种目的，包括：

- **网络安全审计**：Nmap 可用于识别网络中的安全漏洞。它可以扫描网络并识别开放的端口、运行的服务和应用程序的版本以及主机的操作系统。这些信息可用于识别可能被攻击者利用的漏洞。
- **网络管理**：Nmap 可用于管理网络。它可以扫描网络并识别所有活跃的主机、服务和应用程序。这些信息可用于跟踪网络的资产并确保所有系统正常运行。
- **网络研究**：Nmap 可用于研究网络。它可以扫描网络并收集有关主机、服务和应用程序的信息。这些信息可用于了解网络的架构和功能。

Nmap 是一款功能强大的工具，可用于多种目的。它是任何网络安全专业人员或网络管理员的必备工具。

以下是一些 Nmap 的常见用法：

- **扫描新网络**：当您连接到新的网络时，Nmap 可以用来扫描网络并识别所有活跃的主机、服务和应用程序。这些信息可用于了解网络的架构并确定您需要访问的系统。
- **识别安全漏洞**：Nmap 可用来扫描网络并识别开放的端口、运行的服务和应用程序的版本以及主机的操作系统。这些信息可用于识别可能被攻击者利用的漏洞。
- **跟踪网络资产**：Nmap 可用来扫描网络并跟踪所有活跃的主机、服务和应用程序。这些信息可用于确保所有系统正常运行并识别任何未经授权的设备。
- **测试网络安全防御**：Nmap 可用来测试网络的安全防御。它可以用来扫描网络并尝试识别可以被攻击者利用的漏洞。

Nmap 是一款功能强大的工具，可用于多种目的。它是任何网络安全专业人员或网络管理员的必备工具。

# Linux 服务器日常巡检的内容主要包括以下几项：

**1. 系统基本信息检查**

- 检查系统版本、内核版本、发行版等信息，确保系统处于最新状态。
- 检查系统运行时间，了解服务器运行状况。
- 检查系统用户和组，确保只有授权用户才能访问服务器。
- 检查系统权限，确保文件和目录的权限设置正确。

**2. CPU、内存、磁盘使用情况检查**

- 检查 CPU 使用率，确保 CPU 负载不过高。
- 检查内存使用率，确保内存没有被占满。
- 检查磁盘使用空间，确保磁盘空间充足。
- 检查磁盘 I/O 性能，确保磁盘 I/O 速度正常。

**3. 网络服务检查**

- 检查网络服务状态，确保所有必要的服务都已启动并正常运行。
- 检查网络连接，确保服务器能够正常连接到网络。
- 检查防火墙规则，确保防火墙规则正确配置。
- 检查网络安全日志，是否有可疑活动。

**4. 安全检查**

- 检查系统日志，是否有安全事件发生。
- 检查安全漏洞，并及时修复。
- 检查系统安全配置，确保安全配置符合安全要求。
- 检查病毒和木马，并及时查杀。

**5. 应用服务检查**

- 检查应用服务状态，确保所有必要的应用服务都已启动并正常运行。
- 检查应用服务日志，是否有错误信息或警告信息。
- 检查应用服务性能，确保应用服务能够满足性能要求。

**6. 其他检查**

- 检查系统备份情况，确保系统备份正常进行。
- 检查系统更新情况，并及时安装系统更新。
- 检查计划任务，确保计划任务正常执行。

**以下是一些具体的巡检命令：**

- `uname -a`：查看系统基本信息。
- `top`：查看 CPU、内存、进程等信息。
- `df -h`：查看磁盘使用情况。
- `netstat -anp`：查看网络连接状态。
- `iptables -L`：查看防火墙规则。
- `grep -i "error\|fail" /var/log/messages`：查看系统日志。
- `nmap localhost`：扫描本地主机上的端口。
- `ps aux`：查看所有正在运行的进程。
- `systemctl status <service-name>`：查看服务状态。
- `tail -f /var/log/<service-name>.log`：查看服务日志。

# SSL证书工作的原理

**SSL证书的工作原理**

SSL证书的工作原理可以分为以下几个步骤：

1. **客户端请求连接**：当用户访问一个使用SSL证书的网站时，浏览器会首先向服务器发送一个请求。这个请求包含一些信息，例如客户端支持的加密协议版本和客户端拥有的加密密钥。
2. **服务器发送证书**：服务器会收到客户端的请求并向客户端发送其SSL证书。SSL证书包含以下信息：
   - 公钥：用于加密通信。
   - 证书颁发机构（CA）的公钥：用于验证证书的真实性。
   - 网站的域名和其他信息。
3. **客户端验证证书**：浏览器会使用CA的公钥来验证SSL证书的真实性。如果证书有效，浏览器会将服务器的公钥提取出来并存储在本地。
4. **客户端建立加密连接**：浏览器会使用服务器的公钥来加密一个随机生成的会话密钥。然后，浏览器会将加密后的会话密钥发送给服务器。
5. **服务器解密会话密钥**：服务器会使用其私钥来解密会话密钥。解密后的会话密钥将用于加密和解密客户端和服务器之间的所有通信。
6. **建立安全连接**：客户端和服务器现在可以使用会话密钥来加密和解密所有通信。这将确保通信的安全性和私密性。
7. 客户端发起https访问请求到服务端,会携带自己所支持的加密协议版本和密钥，服务器会将SSL证书发送给客户端进行校验，SSL证书中包含一个公钥。
   然后进行校验成功后，客户端会生成一个随机串，并使用服务端返回的证书公钥进行加密
   然后把加密后随机字符串再发送服务端，服务端利用自己私钥进行解密，得到客户端生成的字符串
   服务器再利用这个随机串与客户端进行加密通信

# DDoS SYN 攻击流程

DDoS SYN 攻击是一种利用 TCP/IP 连接建立过程中的漏洞来发起的一种拒绝服务攻击。攻击者会向目标服务器发送大量伪造的 SYN 数据包，这些数据包会请求建立新的连接，但随后却不会完成连接建立过程。这会导致目标服务器的 SYN 队列溢出，从而无法响应正常客户端的连接请求。

**DDoS SYN 攻击的具体流程如下：**

1. **攻击者收集大量的僵尸主机**：攻击者会使用各种手段来收集大量的僵尸主机，例如传播恶意软件、利用漏洞等。这些僵尸主机将被用来发送 SYN 数据包。
2. **攻击者伪造 SYN 数据包**：攻击者会伪造大量的 SYN 数据包，这些数据包的源 IP 地址通常是随机的，目的是为了隐藏攻击者的真实身份。
3. **攻击者向目标服务器发送 SYN 数据包**：攻击者会使用僵尸主机向目标服务器发送大量的 SYN 数据包。这些数据包会请求建立新的连接，但随后却不会完成连接建立过程。
4. **目标服务器的 SYN 队列溢出**：当目标服务器收到大量 SYN 数据包时，其 SYN 队列会迅速填满。这会导致目标服务器无法响应正常客户端的连接请求。
5. 攻击者收集大量的肉机对被攻击端发送大量的伪装syn请求，被攻击端响应请求并建立连接，但是不会完成整个连接，也就是不会完成四次挥手，从而导致syn队列溢出，占满网络资源,正常的请求无法进来，达到攻击的目的

# 只知道有一个应用程序，如何查找文件的位置

pstree

ps -aux | grep 

lsof -p pid

只知道有一个应用程序，如何查找文件的位置
先通过pstree查看进程树，再使用ps -aux | grep 进程名找到pid 查到这里就应该能查到目录了，如果不行的话
就可以再使用lsof -p pid 查找

# 闭包

简单的一句话就是内部（内嵌）函数调用外部函数的变量



# CDN DNS智能解析的基本原理

用户访问域名： 当用户在浏览器中输入域名或点击链接时，浏览器会首先向本地DNS服务器发起域名解析请求。

本地DNS服务器查询： 本地DNS服务器会首先查询自己的缓存，如果缓存中没有该域名的解析记录，则会向根DNS服务器发起递归查询。

根DNS服务器查询： 根DNS服务器会将请求转交给负责该顶级域的授权DNS服务器。

授权DNS服务器查询： 授权DNS服务器会查询自己的数据库，并返回该域名的权威DNS服务器的地址。

权威DNS服务器查询： 用户的浏览器会向权威DNS服务器发起查询，请求该域名的解析记录。

权威DNS服务器返回CDN解析记录： 权威DNS服务器会返回该域名的CDN解析记录，其中包含多个CDN边缘节点的IP地址。

用户浏览器解析IP地址： 用户的浏览器会根据其地理位置和网络状况，从CDN解析记录中选择最近的CDN边缘节点的IP地址，并直接向该节点发起请求。

CDN边缘节点响应请求： CDN边缘节点会从其缓存中获取请求的内容，如果缓存中没有，则会从源服务器获取内容，并将内容返回给用户。

# CDN 将内容发布到边缘服务器的过程

1. **内容源服务器将内容上传到 CDN 的中心服务器**：内容源服务器可以是网站服务器、应用程序服务器或任何其他存储内容的服务器。内容源服务器将内容上传到 CDN 的中心服务器。中心服务器通常位于互联网骨干网上，以便快速访问。
2. **CDN 将内容复制到边缘服务器**：CDN 会将内容从中心服务器复制到边缘服务器。边缘服务器通常位于离用户较近的位置，以便快速交付内容。CDN 会根据各种因素来选择边缘服务器的位置，例如用户的位置、内容的流行程度和网络状况。
3. **用户请求内容**：当用户访问一个使用 CDN 的网站或应用程序时，他们的浏览器会向 CDN 的边缘服务器发送请求。
4. **CDN 将内容交付给用户**：边缘服务器会从本地缓存中检索内容并将其交付给用户。如果边缘服务器没有本地缓存的内容，则会从中心服务器请求内容并将其缓存到本地，然后将内容交付给用户。



# CDN回源限速

是指对CDN回源请求进行限速，以控制从源站获取内容的速度。回源限速可以帮助保护源站免受过载攻击，并确保源站能够正常为CDN节点提供内容。

**CDN回源限速的配置方法**

不同的CDN供应商提供的回源限速配置方法可能有所不同。以下是一般性的配置步骤：

1. **登录CDN控制台**：首先，您需要登录您的CDN控制台。您可以从CDN供应商的网站上找到控制台的登录地址。
2. **找到回源限速配置页面**：登录控制台后，您需要找到回源限速配置页面。该页面的位置可能因CDN供应商而异。
3. **选择要限速的域名**：在回源限速配置页面上，您需要选择要限速的域名。
4. **设置限速规则**：选择域名后，您需要设置限速规则。限速规则通常包括以下参数：
   - **限速类型**：限速类型可以是总限速、URL限速或用户限速。
   - **限速值**：限速值是指每秒允许的回源请求数。
   - **限速时间段**：限速时间段是指限速规则生效的时间段。
5. **保存设置**：设置限速规则后，您需要保存设置。



# S3 桶域名回源时要注意哪个关键点

```
回源时要使用aws提供的 s3://的域名进行回源
```

# 域名被墙的处理方式

```
使用VPN：VPN是一种可以改变服务器IP地址的加密技术，通过使用VPN，可以将原本的IP地址更换为一个未被封锁的IP地址，从而绕过封锁。
使用代理服务器：代理服务器是一种可以转发请求并返回响应的服务器，通过使用代理服务器，可以将请求转发到一个未被封锁的服务器上，从而获取被封锁的域名。
更换DNS服务器：DNS服务器是将域名转换为IP地址的系统，如果默认的DNS服务器被污染，可以通过更换DNS服务器来获取被封锁的域名。
使用Tor网络：Tor网络是一种基于洋葱路由技术的匿名网络，通过使用Tor网络，可以将请求进行多次加密和转发，从而绕过封锁。
更换域名
域名做301跳转
```

# 域名预防被劫持

```
DNS劫持就是指用户访问一个被标记的地址时，DNS服务器故意将此地址指向一个错误的IP地址的行为。范例，网通和电信、铁通的某些用户有时候会发现自己打算访问一个地址，却被转向了各种推送广告等网站。
那么，如何预防被劫持呢？
1、为域名注册商和注册用邮箱设置复杂密码且经常更换。使用单独的DNS服务，也需要对密码进行上述设置。同时注意不要在多个重要注册地使用相同的用户名和密码；
DNS劫持就是指用户访问一个被标记的地址时，DNS服务器故意将此地址指向一个错误的IP地址的行为。范例，网通和电信、铁通的某些用户有时候会发现自己打算访问一个地址，却被转向了各种推送广告等网站。
2、将域名更新设置为锁定状态，不允许通过DNS服务商网站修改记录，使用此方法后，需要做域名解析都要通过服务商来完成，时效性较差；
3、定期检查域名帐户信息、域名whois信息，査看事件管理器，清理Web网点中存在的可疑文件。每天site网站检查是否有预期外网页。详细检查网站索引和外链信息，有异常一定要检查清楚；
4、加强网站的防SQL注入功能，SQL注入是利用SQL语句的特点向数据库写内容，从而获取到权限的方法；
5、配置Web站点文件夹及文件操作权限。Windows网络操作系统中，使用超级管理员权限， 对Web站点文件及文件夹配置权限，多数设置为读权限，谨慎使用写权限，如果无法获取超级管理员权限，这样木马程序便无法生根，网站域名被劫持的可能便可以降低很多；
6、利用事务签名对区域传送和区域更新进行数字签名；
7、删除运行在DNS服务器上的不必要服务，如FTP；
8、在网络外围和DNS服务器上使用防火墙服务。将访问限制在那些DNS功能需要的端口服务上。
```

# K8S

## deployment的启动流程

```
当要启动一个pod时，不管是通过命令式还是声明式的方式
1. apiServer 对创建请求要进行格式解析，认证、权限验证
2. 创建请求通过后，就会将数据写入ETCD
3. controller manager通过WATCH监听到LIST中资源的变换，比如：pod副本数的增减
4. scheduler 根据用户的请求类型、节点的打分机制进行pod的调度
5. 完成调度后将数据写入ETCD
6. kubelet上报各个worker节点状态信息和pod状态信息给apiServer
7. apiServer接受并更新各节点状态信息存储到ETCD
8. 并将scheduler调度的pod的结果返回给对应的worker节点

副本数量，污点，节点选择器，亲和性
kubelet启动的一个容器
1. kubelet 通过 cri(containerd runtime interface)调用pod去创建容器
2. 如果使用的是docker 那就要使用docker-shim去创建dockerd的守护进程
3. docker或者contaninerd 调用runc的机制去创建容器
4. 启动pause容器提供网络基础
5. 启动初始化容器提供基础环境
6. 启动业务容器，这里还会涉及到生命周期和探针，postStart容器启动后做什么，preStop容器启动前做什么，startupProbe检测，readinessProbe检测，livenessProbe检测
```

## 有几种探针，作用是什么

```
startupProbe检测
容器启动时检测，如果失败则容器启动不成功
readinessProbe检测
容器加载时检测，如果失败则容器启动不成功
livenessProbe检测
容器运行时检测，如果失败则容器重启
```

## 自动扩缩容

```
HPA资源，水平 Pod 自动扩缩容，当监控某个值达到了阈值时，就自动增加或减少pod的数量，当然pod的数量也是会设置的，前提会依赖于metrics-server资源
```

## pod为什么一直重启
