

# IPFS官网

https://docs.ipfs.tech/

# 概念

```
IPFS 是允许计算机发送和接收数据一组协议、软件包和规范。因此，用户可以以多种不同的方式与 IPFS 交互和使用 IPFS。与想要在 IPFS 上存储文件的人相比，构建网络应用程序的开发人员将使用一组不同的工具来与 IPFS 交互。选择最适合您用途的工具。
```

# 安装

## 1.下载

```
wget https://dist.ipfs.tech/kubo/v0.30.0/kubo_v0.30.0_linux-amd64.tar.gz
```

## 2.解压运行

```
tar xf kubo_v0.30.0_linux-amd64.tar.gz
cd kubo
bash install.sh
```

## 3.设置数据保存路径

```
mkdir -pv /data/ipfs
ln -sv /data/ipfs /root/.ipfs
```

## 4.初始化

```
[root@centos7k8snode2 ipfs]# 
/data/ipfs

[root@centos7k8snode2 ipfs]# ipfs init

[root@centos7k8snode2 ipfs]# ls
api  blocks  config  datastore  datastore_spec  gateway  keystore  repo.lock  version
```

## 5.设置外部访问并启动服务

```
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://192.168.76.147:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST","GET","HEAD"]'

config文件
找到Addresses和``Gateway，将里面``的127.0.0.1改成自己的服务器地址
或者 
"AppendAnnounce": [
  "/ip4/<public-ip>/tcp/<port>",
  "/ip4/<public-ip>/udp/<port>/quic-v1",
  "/ip4/<public-ip>/udp/<port>/quic-v1/webtransport"
 ],


nohup /usr/local/bin/ipfs daemon &>/var/log/ipfs.log &
```

# 跳转应用

## 1.进入界面

## 2.编写页面

```
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>test href</title>
    <script>
      (function () {
        window.location.href = "https://www.google.com";
      })();
    </script>
  </head>
  <body></body>
</html>
```

## 3.导入

![image-20241006224119978](D:\learn\mylinux\experience\IPFS\image-20241006224119978.png)

## 4.生成IPNS发布密钥

![image-20241006224538226](D:\learn\mylinux\experience\IPFS\image-20241006224538226.png)

## 5.准备发布，选择密钥

![image-20241006224706299](D:\learn\mylinux\experience\IPFS\image-20241006224706299.png)

## 6.发布成功，测试访问![image-20241006225033086](D:\learn\mylinux\experience\IPFS\image-20241006225033086.png)

```
http://192.168.76.147:8080/ipns/k51qzi5uqu5dl3kwy8ot099smd3lisaculko1p0xe5asintqcjo8m0dc064zlo
```

