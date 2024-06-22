# harbor镜像私有库搭建

## 1.安装docker

```
略，可以参照官方文档
需要安装docker compose
国内还需配置镜像库地址 /etc/docker/daemon.json
{
	registry-mirrors:[]
}
```

## 2.下载harbor

```
https://github.com/goharbor/harbor
```

## 3.自签证书

```
cd /usr/local/harbor
mkdir -pv certs/{ca,server,client}
cd certs
#ca 自签机构
#创建ca私钥
openssl genrsa -out ca/ca.key 4096
#根据私钥创建ca自签证书
openssl req -new -nodes -x509 -sha512 -days 3650 \
-subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=myharbor.com" \
-key ca/ca.key -out ca/ca.crt

server
#创建服务端私钥
openssl genrsa -out server/harbor.myharbor.com.key 4096
#根据私钥生成服务端证书申请
openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=harbor.myharbor.com" \
    -key server/harbor.myharbor.com.key \
    -out server/harbor.myharbor.com.csr
#生成x509 v3扩展文件
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=myharbor.com
DNS.2=myharbor
DNS.3=harbor.myharbor.com
EOF
#使用"v3.ext"给harbor主机签发证书
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca/ca.crt -CAkey ca/ca.key -CAcreateserial \
    -in server/harbor.myharbor.com.csr \
    -out server/harbor.myharbor.com.crt
openssl x509 -inform PEM -in server/harbor.myharbor.com.crt -out server/harbor.myharbor.com.cert

client
cp server/harbor.myharbor.com.{cert,key} client/
cp ca/ca.crt client/
```



## 4.配置文件安装harbor

```
harbor.yml 
hostname: harbor.myharbor.com
...
https:
  port: 443
  certificate: /oldboyedu/softwares/harbor/certs/server/harbor.myharbor.com.crt
  private_key: /oldboyedu/softwares/harbor/certs/server/harbor.myharbor.com.key
harbor_admin_password: 1
...

./install.sh
```

## 5.验证登录

```
准备myharbor docker 证书
mkdir -pv /etc/docker/certs.d/harbor.myharbor.com
cp -r /usr/local/harbor/certs/client/* /etc/docker/certs.d/harbor.myharbor.com

配置/etc/hosts
ip harbor.myharbor.com
docker login -u xxx -p xxx https://harbor.myharbor.com


显示successful则成功
不用时需要 docker logout 安全退出
```

