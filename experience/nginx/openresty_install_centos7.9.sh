#!/bin/bash
#centos7.9 install openresty
yum install gcc perl-devel pcre-devel zlib-devel openssl-devel libmaxminddb libmaxminddb-devel make -y

cd /usr/local/src
tar xf GeoLite2-ASN_20241016.tar.gz
tar xf GeoLite2-City_20241015.tar.gz
tar xf GeoLite2-Country_20241015.tar.gz
tar xf openresty-1.21.4.4.tar.gz
tar xf ngx_http_proxy_connect_module-0.0.7.tar.gz
tar xf 3.4.tar.gz

cd /usr/local/src/openresty-1.21.4.4/
./configure --add-module=/usr/local/src/ngx_http_geoip2_module-3.4 --add-module=/usr/local/src/ngx_http_proxy_connect_module-0.0.7 --with-http_realip_module --with-http_v2_module
patch -d build/nginx-1.21.4/ -p 1 < /usr/local/src/ngx_http_proxy_connect_module-0.0.7/patch/proxy_connect_rewrite_102101.patch

gmake -j4 && gmake install

mkdir -p /usr/local/openresty/site/lualib /usr/local/openresty/site/pod /usr/local/openresty/site/manifest
ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/