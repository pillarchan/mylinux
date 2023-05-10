# DOCKER 的应用

## 一.安装

### 1.epel 安装 [Docker Engine installation overview | Docker Documentation](https://docs.docker.com/engine/install/)

```
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
```

### 2.centos 安装

1. 如果之前已经安装过 docker,那么就将之前 docker 环境全部移出

   ```
   $ sudo yum remove docker \
   docker-client \
                     docker-client-latest \
                     docker-common \
                     docker-latest \
                     docker-latest-logrotate \
                     docker-logrotate \
                     docker-engine
   ```

2. 使用 epel yum 安装

   ```
   yum install -y epel-release //安装epel
   yum install -y yum-utils //安装yum工具
   yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo //添加docker yum 仓库

   yum list docker-ce --showduplicate | sort -r //倒序查看版本
   yum install docker-ce-<version> docker-cli-<version> containerd.io //选择版本安装
   如:yum install docker-ce-20.10.0-3.el7 docker-cli-20.10.0-3.el7 containerd.io -y
   systemctl start docker //启动服务
   docker info //查看安装docker信息
   ```

3. 使用国内镜像安装

   ```
   yum install -y yum-utils //安装yum工具
   yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo //添加docker yum 仓库
   yum makecache fast
   yum list docker-ce --showduplicate | sort -r //倒序查看版本
   yum install docker-ce-<version> docker-cli-<version> containerd.io //选择版本安装
   如:yum install docker-ce-20.10.1-3.el7 docker-cli-20.10.1-3.el7 containerd.io -y
   systemctl start docker //启动服务
   docker info //查看安装docker信息
   ```

4. 使用脚本安装(不建议在生产环境中使用)

   ```
   curl -fsSL https://get.docker.com -o get-docker.sh //浏览并下载文件内容到指定文件到当前目前
   sh get-docker.sh //运行该文件
   systemctl start docker
   docker info
   ```

5. 使用 rpm 包安装

   ```
   在 https://download.docker.com/linux/centos/ 或者其它镜像网站下载stable rpm到本地
   yum install /path/to/*.rpm
   systemctl start docker
   docker info
   ```

6. 升级版本

   ```
   要升级Docker Engine，请下载更新的软件包文件并重复安装过程，使用yum -y upgrade而不是yum -y install并指向新文件。
   ```

7. 卸载

   ```
   yum remove docker-ce docker-cli containerd.io //卸载安装的docker
   rm -rf /var/lib/docker
   ```

### 3.配置文件

1.  环境配置文件
    /etc/sysconfig/docker-network
    /etc/sysconfig/docker-storage
    /etc/sysconfig/docker

2.  unit file
    /usr/lib/systemd/system/docker.service

3.  docker registries
    /etc/containers/registries.conf

4.  docker-ce
    /etc/docker/daemon.json
    镜像加速器配置:

         {
            "registry-mirrors":["https://docker.mirrors.ustc.edu.cn","https://registry.docker-cn.com"]

         }

    镜像地址

1)  阿里云 docker hub mirror
    https://registry.cn-hangzhou.aliyuncs.com

如果有账号的, 使用:

[系统分配前缀].mirror.aliyuncs.com
具体上阿里云容器 HUB 控制台查看.

2.  腾讯云 docker hub mirror
    https://mirror.ccs.tencentyun.com

3.  华为云
    https://05f073ad3c0010ea0f4bc00b7105ec20.mirror.swr.myhuaweicloud.com

4.  docker 中国
    https://registry.docker-cn.com

5.  网易
    http://hub-mirror.c.163.com

6.  daocloud
    http://f1361db2.m.daocloud.io

修改步骤

## 二.docker 常用管理命令

1. docker info 信息查看
2. docker version 版本查看
3. docker search [OPTIONS] TERM 查询在 hub docker 上的 image
4. docker create [OPTIONS] IMAGE [COMMAND] [ARG...]SSS
5. docker ps 查看容器
6. docker rm 删除容器
7. docker rmi 删除镜像
8. docker start 启动容器
9. docker restart 重启容器
10. docker run [OPTIONS] IMAGE [COMMAND] [ARG...] 创建并启动容器
    -t, --tty Allocate a pseudo-TTY 通过一个终端启动
    -i, --interactive Keep STDIN open even if not attached 交互式访问
    --name string Assign a name to the container 为容器命名
    --network network Connect a container to a network 为容器指定一个网络
    --rm Automatically remove the container when it exits 容器停止时自动删除
    -d, --detach Run container in background and print container ID 在后端运行容器
11. docker pause 暂停容器
12. docker unpause 恢复容器
13. docker kill 结束正在运行的容器
14. docker exec [OPTIONS] CONTAINER COMMAND [ARG...] 在容器中执行命令
15. docker networker ls 查看容器网络
16. docker inspect [OPTIONS] NAME|ID [NAME|ID...] 查看运行中容器的网络地址

## 三.docker 镜像管理命令

1. docker image search 查询在 hub docker 上的 image

2. docker image pull 在 hub docker 上拉取 image

3. docker image ls 查看本地镜像

4. docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]] //提交正在运行中容器为镜像,如不指定平台默认为 hub docker
   如:docker commit -p b1 pillarchan/http:v0.3 Options:
   -a, --author string Author (e.g., "John Hannibal Smith <hannibal@a-team.com>")
   -c, --change list Apply Dockerfile instruction to the created image
   -m, --message string Commit message
   -p, --pause Pause container during commit (default true)

   ```
   docker commit -a "username <user@hehe.com>" -c 'COMMANDTYPE "command_path","param","param","child_param"' -p CONTAINER_NAME repository:tag
   如:docker commit -a "pillar <nanchen55@gmail.com>" -c 'CMD ["/bin/httpd","-f","-h","/data/html"]' -p b1 pillarchan/httpd:v0.3
   ```

5. docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]

   ```
   如:docker tag docker tag pillarchan/http:v0.3 pillarchan/httpd:v0.3
   ```

6. docker push [OPTIONS] NAME[:TAG]

   ```
   如:docker push pillarchan/http:v0.3
   ```

7. docker login [OPTIONS] [SERVER] //登录 docker image 仓库,如不指定平台,默认为 hub docker

   ```
   如:echo 'password' | docker login -u username --password-stdin
   ```

8. docker logout

9. docker save [OPTIONS] IMAGE [IMAGE...]

   ```
   docker save -o /path/to/*.gz pillarchan/httpd:v0.3
   ```

10. docker load [OPTIONS]

    ```
    docker load -i /path/from/*.gz
    ```

## 四.docker 网络管理

1. ip netns 管理命令

   ```
   Usage: ip netns list //查看网络名称空间列表
          ip netns add NAME //添加网络名称空间
          ip netns set NAME NETNSID
          ip [-all] netns delete [NAME] //删除所有或某个网络名称空间
          ip netns identify [PID]
          ip netns pids NAME
          ip [-all] netns exec [NAME] cmd ... //在所有或指定的网络名称空间执行指定命令
          ip netns monitor
          ip netns list-id
   ```

2. ip link 管理命令

   ```
   Usage: ip link add [link DEV] [ name ] NAME
                      [ txqueuelen PACKETS ]
                      [ address LLADDR ]
                      [ broadcast LLADDR ]
                      [ mtu MTU ] [index IDX ]
                      [ numtxqueues QUEUE_COUNT ]
                      [ numrxqueues QUEUE_COUNT ]
                      type TYPE [ ARGS ]

          ip link delete { DEVICE | dev DEVICE | group DEVGROUP } type TYPE [ ARGS ]

          ip link set { DEVICE | dev DEVICE | group DEVGROUP }
                         [ { up | down } ]
                         [ type TYPE ARGS ]
                         [ arp { on | off } ]
                         [ dynamic { on | off } ]
                         [ multicast { on | off } ]
                         [ allmulticast { on | off } ]
                         [ promisc { on | off } ]
                         [ trailers { on | off } ]
                         [ carrier { on | off } ]
                         [ txqueuelen PACKETS ]
                         [ name NEWNAME ]
                         [ address LLADDR ]
                         [ broadcast LLADDR ]
                         [ mtu MTU ]
                         [ netns { PID | NAME } ]
                         [ link-netnsid ID ]
                 [ alias NAME ]
                         [ vf NUM [ mac LLADDR ]
                      [ vlan VLANID [ qos VLAN-QOS ] [ proto VLAN-PROTO ] ]
                      [ rate TXRATE ]
                      [ max_tx_rate TXRATE ]
                      [ min_tx_rate TXRATE ]
                      [ spoofchk { on | off} ]
                      [ query_rss { on | off} ]
                      [ state { auto | enable | disable} ] ]
                      [ trust { on | off} ] ]
                      [ node_guid { eui64 } ]
                      [ port_guid { eui64 } ]
                 [ xdp { off |
                     object FILE [ section NAME ] [ verbose ] |
                     pinned FILE } ]
                 [ master DEVICE ][ vrf NAME ]
                 [ nomaster ]
                 [ addrgenmode { eui64 | none | stable_secret | random } ]
                         [ protodown { on | off } ]

          ip link show [ DEVICE | group GROUP ] [up] [master DEV] [vrf NAME] [type TYPE]

          ip link xstats type TYPE [ ARGS ]

          ip link afstats [ dev DEVICE ]

          ip link help [ TYPE ]

   TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |
             bridge | bond | team | ipoib | ip6tnl | ipip | sit | vxlan |
             gre | gretap | ip6gre | ip6gretap | vti | nlmon | team_slave |
             bond_slave | ipvlan | geneve | bridge_slave | vrf | macsec }

   添加成对的网络
   ip link add name veth1.1 type veth peer name veth1.2
   将网络进行分配
   ip link set dev veth1.1 netns r1
   将网络名称空间中的设备名进行设置
   ip netns exec r1 ip link set dev veth1.1 name eth0
   为网络名称空间中的设备配置IP地址
   ip netns exec r1 ip addr add dev eth0 100.10.1.2
   激活网络名称空间中的设备
   ip netns exec r1 ip lint set dev eth0

   可以将如上操作对宿主机或其它网络名称空间进行配置,配置完成后,ping通测试连接性
   ip netns exec r1 ping 100.10.1.3
   ```

3. 使用 docker 选项启动容器

   ```
   docker run --name b1 --network bridge -h docker1 --dns 8.8.8.8 --dns-search ilinux.io --add-host www.mydocker.com:1.1.1.1 --rm -it busybox:latest
   ```

4. docker run -p 选项的用法 使用 bridge 方式进行连接

   ```
   -p <container port> //动态映射容器商品
   -p <host port>:<container port> //指定端口映射容器端口
   -p <ip>::<container port> //指定IP动态映射容器端口
   -p <ip>:<host port>:<container port> //指定IP指定端口映射容器端口
   ```

5. 使用联合方式进行连接

   ```
   docker run --rm --name b1 -it busybox:latest
   docker run --rm --name b2 --network container:b1 -it busybox:latest //指明共享哪个容器的网络名称空间
   ```

6. 使用共享宿主机的方式进行连接

   ```
   docker run --rm --name b1 --network host -it busybox:latest //指明共享宿主机的网络名称空间
   ```

7. 创建自定义桥

   ```
   docker network create -d bridge --subnet '172.26.0.0/16' --gateway '172.26.0.1' mybr0
   docker network ls
   ```

8. 配置 docker 默认 IP 段

   ```
   编辑配置文件 /etc/docker/daemon.json
   "bip"
   "default-gateway"
   "dns"
   "hosts"
   {
       "registry-mirros":[],
       "bip":"172.33.0.1/16", //填写IP段
       "hosts":["tcp://0.0.0.0:2375","unix:///var/run/docker.sock"] //配置连接远程docker
   }

   注意:为避免docker的socket中hosts配置与/etc/docker/daemon.json中的发生冲突,须做以下修改:
   1./usr/lib/systemd/system/docker.service 文件中的
   ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock 注释掉修改为
   ExecStart=/usr/bin/dockerd
   2.systemctl daemon-reload 重新加载守护进程
   3.systemctl start docker.service 最后启动docker
   ```

## 五.docker 数据持久化管理

1. docker manager volume 通过 docker run -v /container/dir 选项进行创建,但随着容器的删除,volume 的存储路径也会消失

   ```
   docker run --rm --name b1 -p 80:80 -v /data/html -it busybox:lastest
   docker inspect b1 //查看磁盘上的volume所在位置
   //Mounts.Source 中就是外部存储路径
    "Mounts": [
               {
                   "Type": "volume",
                   "Name": "0290e5c4330ea13fc73eb48c8c2d9f5235ef22e047c4d09860b9f0774b89ad63",
                   "Source": "/var/lib/docker/volumes/0290e5c4330ea13fc73eb48c8c2d9f5235ef22e047c4d09860b9f0774b89ad63/_data",
                   "Destination": "/data/html",
                   "Driver": "local",
                   "Mode": "",
                   "RW": true,
                   "Propagation": ""
               }
           ]
   ```

2. docker bind volume 通过 docker run -v path/volume/dir:/container/dir 选项进行创建,容器的删除后 volume 的存储路径依然存在

   ```
   docker run --rm --name b1 -p 80:80 -v /data/volume/b1/html:/data/html -it busybox:lastest
   docker inspect -f {{.Mounts}} b1 //查看磁盘上的volume所在位置
   [{bind  /data/volume/b1/html /data/html   true rprivate}] //可以看错存储的位置就是自定义的路径
   ```

3. docker sharing volume 通过选项 --volumes-from 创建出的容器去复制共享容器的存储空间

   ```
   docker run --name b1 -p 80:80 -v /data/infracone/volume:/data/ -it busybox:lastest
   docker run --rm --name b2 --network container:b1 --volumes-from b1 -it busybox:lastest
   ```

## 六.docker File

dockerfile 是结合 docker build 命令来创建镜像的文件,创建并编写 Dockerfile 文件后,使用 docker build 命令读取 Dockerfile 文件中指令行,由上至行逐行进行构建至到镜像创建完成.

常用指令(指令按书写规范一般为大写)

1. FROM 构建的基础镜像

   ```
   FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
   FROM [--platform=<platform>] <image>[@<digest>] [AS <name>]
   ```

2. LABEL 标签用来定义镜像描述之类,如作者,版本等等

   ```
   LABEL <key>=<value> <key>=<value> <key>=<value> ...
   ```

3. COPY 将宿主机中的以 Dockferile 文件为相对路径中文件复制到容器中目标目录,当复制某个目录时其实质是复制目录中的文件

   ```
   COPY [--chown=<user>:<group>] <src>... <dest>
   COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
   ```

4. ADD 将宿主机中的以 Dockferile 文件为相对路径中文件或目录复制到容器中目标目录,还可以使用 url

   ```
   ADD [--chown=<user>:<group>] <src>... <dest>
   ADD [--chown=<user>:<group>] ["<src>",... "<dest>"]

   ADD test.txt /data/   //将与Dockerfile文件为相同路径下的test.txt文件复制到容器的/data目录中
   ADD test/ /data/   //将与Dockerfile文件为相同路径下的test目录复制到容器的/data目录中
   ADD test.tar.gz /data/   //将与Dockerfile文件为相同路径下的test.tar.gz文件复制到容器的/data目录中并自动解压
   ADD https://nginx.org/download/nginx-1.18.0.tar.gz /data/   //将url中的文件复制到容器的/data目录中,但这种方式不会自动解压,需要手动解压
   ```

5. ENV 自定义环境变量

   ```
   ENV <key>=<value> ...
   如要自定义多个变量,可以使用\进行换行书写,变量名尽量为大写,引用变量时使用$变量名或${变量名},也可以通过${变量名:-默认值}的方式来设定变量值为空时的默认值
   如:ENV WEB_PAKAGE="nginx-1.18.0.tar.gz" \
       DOC_ROOT="/data/" \
       INSTALL_DIR="/usr/local/"
   LABEL author='pillar <pillar@163.com>'
   COPY ./data/html/index.html ${DOC_ROOT/web/html:-/data/web/html/}
   ```

6. EXPOSE 设置要对外可访问的端口,默认协议为 tcp

   ```
   EXPOSE <port> [<port>/<protocol>...]
   EXPOSE 80 443
   ```

7. VOLUME 设置容器卷

   ```
   VOLUME ["/data"]
   相当于是使用了 -v contanier/path 进行容器和宿主机的存储关联,一旦容器被删除,关联存储目录也会一并删除,所以在删除容器之前需要将数据导出备份
   ```

8. RUN 在容器构建时的执行命令

   ```
   RUN <command> (shell form, the command is run in a shell, which by default is /bin/sh -c on Linux or cmd /S /C on Windows)
   RUN ["executable", "param1", "param2"] (exec form)

   RUN cd $INSTALL_DIR \
       && tar xf $WEB_PAKAGE \
       && mv $WEB_PAKAGE /data/ \
       && ls $DOC_ROOT \
       && httpd -f -h /data/web/html
   ```

9. CMD 在容器启动时的执行命令,指令可出现多次,但仅运行最后一次出现的指令

   ```
   CMD ["executable","param1","param2"] (exec form, this is the preferred form)  //当使用这种形式执行命令时,因为与shell表单不同，exec表单不会调用命令shell。这意味着不会进行常规的外壳处理。例如， CMD [ "echo", "$HOME" ]将不会对进行变量替换$HOME。如果要进行shell处理，则可以使用shell形式或直接执行shell，例如：CMD [ "sh", "-c", "echo $HOME" ]。当使用exec表单并直接执行shell时（例如在shell表单中），是由shell进行环境变量扩展，而不是docker。
   在EXEC形式被解析为一个JSON阵列，这意味着必须使用双引号（“）周围的话不单引号（'）。

   CMD ["param1","param2"] (as default parameters to ENTRYPOINT) //使用这种形式执行命令时,CMD会作为ENTRYPOINT的参数

   CMD command param1 param2 (shell form) //使用这种形式执行命令时,则直接为使用/bin/sh -c 执行命令
   ```

10. ENTRYPOINT 在容器启动时执行命令,可在此指令中运行 shell 脚本

    ```
    ENTRYPOINT ["executable", "param1", "param2"]
    ENTRYPOINT command param1 param2

    ENTRYPOINT中执行的shell脚本文件中,加上exec $@ 用于接收所有参数
    ```

    ### Understand how CMD and ENTRYPOINT interact

    Both `CMD` and `ENTRYPOINT` instructions define what command gets executed when running a container. There are few rules that describe their co-operation.

    1. Dockerfile should specify at least one of `CMD` or `ENTRYPOINT` commands.
    2. `ENTRYPOINT` should be defined when using the container as an executable.
    3. `CMD` should be used as a way of defining default arguments for an `ENTRYPOINT` command or for executing an ad-hoc command in a container.
    4. `CMD` will be overridden when running the container with alternative arguments.

    The table below shows what command is executed for different `ENTRYPOINT` / `CMD` combinations:

    |                                | No ENTRYPOINT              | ENTRYPOINT exec_entry p1_entry | ENTRYPOINT [“exec_entry”, “p1_entry”]          |
    | :----------------------------- | :------------------------- | :----------------------------- | :--------------------------------------------- |
    | **No CMD**                     | _error, not allowed_       | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry                            |
    | **CMD [“exec_cmd”, “p1_cmd”]** | exec_cmd p1_cmd            | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry exec_cmd p1_cmd            |
    | **CMD [“p1_cmd”, “p2_cmd”]**   | p1_cmd p2_cmd              | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry p1_cmd p2_cmd              |
    | **CMD exec_cmd p1_cmd**        | /bin/sh -c exec_cmd p1_cmd | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd |

11. USER 指定容器用户名

    ```
    USER <user>[:<group>]
    USER <UID>[:<GID>]
    ```

12. HEALTHCHECK 检测运行中的容器

    ```
    HEALTHCHECK [OPTIONS] CMD command (check container health by running a command inside the container)
    HEALTHCHECK NONE (disable any healthcheck inherited from the base image)

    The options that can appear before CMD are:
    --interval=DURATION (default: 30s)
    --timeout=DURATION (default: 30s)
    --start-period=DURATION (default: 0s)
    --retries=N (default: 3)

    The command’s exit status indicates the health status of the container. The possible values are:

    0: success - the container is healthy and ready for use
    1: unhealthy - the container is not working correctly
    2: reserved - do not use this exit code
    ```

13. ARG 设置 docker building 期间的变量

    ```
    ARG <name>[=<default value>]
    ```

14. ONBUILD docker 构建镜像时的触发器,当时基础镜像含有 ONBUILD 指令,在构建镜像时就会执行 ONBUILD 指令中的命令

    ```
    ONBUILD <INSTRUCTION>

    ONBUILD ADD . /app/src
    ONBUILD RUN /usr/local/bin/python-build --dir /app/src
    ```

15. STOPSIGNAL STOPSIGNAL 指令设置将被发送到容器退出的系统调用信号。 该信号可以是与内核 syscall 表中的位置匹配的有效无符号数字（例如 9），也可以是格式为 SIGNAME 的信号名称（例如 SIGKILL）。

    ```
    STOPSIGNAL signal
    ```

16. SHELL SHELL 指令允许覆盖用于命令的 shell 形式的默认 shell。 在 Linux 上，默认外壳程序为[“ / bin / sh”，“ -c”]，在 Windows 上，默认外壳程序为[“ cmd”，“ / S”，“ / C”]。 必须在 Dockerfile 中以 JSON 形式编写 SHELL 指令。

    ```
    SHELL ["executable", "parameters"]
    ```

17. 一个小型的综合 nginx 容器案例
    Dockerfile:

    ```
    FROM nginx:1.18.0-alpine

    ARG author="pillar <pillar@163.com>" \
        version="v3.0"

    LABEL author=$author version=$version

    ENV DOC_WEB_ROOT="/data/web/html/" \
        PORT=80 \
        HOSTNAME="myweb.com" \
        USERNANE="www"
    ADD configure.sh /bin
    RUN mkdir -p $DOC_WEB_ROOT &&\
        echo "<h1>my nginx test web</h1>" > $DOC_WEB_ROOT/index.html && \
        mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak

    EXPOSE 80 8080

    VOLUME /data

    ENTRYPOINT ["/bin/configure.sh"]

    CMD ["nginx","-g","daemon off;"]
    HEALTHCHECK  --interval=3s --timeout=3s --retries=2 --start-period=3s CMD curl -f 172.33.0.2:10010 || exit 1
    ```

    configure.sh :

    ```
    #!/bin/sh

    cat > /etc/nginx/conf.d/myweb.conf << EOF
    server {
        server_name ${HOSTNAME:-myweb.com};
        listen ${PORT:-80};
        root ${DOC_WEB_ROOT:-/data/web/html};
    }
    EOF

    exec "$@"
    ```

## 七.私有镜像库的制作

1. 使用 docker-registry 或 docker-distribution 通过 yum 进行安装来创建私有镜像库

   ```
   yum install -y docker-registry //安装私有镜像库
   rpm -ql docker-distribution //查看安装后的目录
   vim /etc/docker-distribution/registry/config.yml //查看或修改配置文件

   私有镜像库默认使用https访问,因此,在要上传镜像的服务器的/etc/docker/daemon.json 文件中需要添加"insecure-registries":[] 项,使其可以使用http访问上传
   域名需要解析或直接修改/etc/hosts 文件添加

   再使用docker命令打标签,推送到私有镜像仓库即可
   ```

2. 使用 vmware-harbor 来进行对私有镜像库的管理

   ```
   访问vmware-harbor的github找到release 选择版本进行下载,有online和offline两种
   下载后解压安装,需要提前安装docker-compose
   使用http方式访问需要配置/etc/docker/daemon.json   "insecure-registries":[]
   ```

八.docker 资源限制及验证

1.
