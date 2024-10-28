#!/bin/bash
#centos7.9 install openresty
dnf install gcc perl-devel pcre-devel zlib-devel openssl-devel libmaxminddb make -y
cd /usr/local/src

wget https://github.com/maxmind/libmaxminddb/releases/download/1.11.0/libmaxminddb-1.11.0.tar.gz
tar libmaxminddb-1.11.0.tar.gz
cd libmaxminddb-1.11.0
./configure 
make && make install
ls /usr/local/lib
echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf
ldconfig

wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/refs/tags/v0.6.4.tar.gz
wget https://openresty.org/download/openresty-1.21.4.4.tar.gz
tar xf GeoLite2-ASN_20241016.tar.g z
tar xf GeoLite2-City_20241015.tar.gz
tar xf GeoLite2-Country_20241015.tar.gz
tar xf openresty-1.21.4.4.tar.gz
tar xf ngx_http_proxy_connect_module-0.0.7.tar.gz
tar xf 3.4.tar.gz
tar xf v0.6.4.tar.gz

cd /usr/local/src/openresty-1.21.4.4/
./configure --with-http_sub_module --with-pcre-jit --with-ipv6 --add-module=/usr/local/src/ngx_http_substitutions_filter_module-0.6.4 --add-module=/usr/local/src/ngx_http_geoip2_module-3.4 --with-http_realip_module --with-http_v2_module --add-module=/usr/local/src/ngx_http_proxy_connect_module-0.0.7patch -d build/nginx-1.21.4/ -p 1 < /usr/local/src/ngx_http_proxy_connect_module-0.0.7/patch/proxy_connect_rewrite_102101.patch
gmake -j4 && gmake install



