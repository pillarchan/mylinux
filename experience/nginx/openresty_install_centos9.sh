#!/bin/bash
#centos9 install openresty
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

cd /usr/local/src
wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/refs/tags/v0.6.4.tar.gz
wget https://openresty.org/download/openresty-1.21.4.4.tar.gz
tar xf GeoLite2-ASN_20241016.tar.gz
tar xf GeoLite2-City_20241015.tar.gz
tar xf GeoLite2-Country_20241015.tar.gz
tar xf openresty-1.21.4.4.tar.gz
tar xf ngx_http_proxy_connect_module-0.0.7.tar.gz
tar xf 3.4.tar.gz
tar xf v0.6.4.tar.gz

cd /usr/local/src/openresty-1.21.4.4/
./configure --with-http_sub_module \
			--with-pcre-jit \
			--with-ipv6 \
			--add-module=/usr/local/src/ngx_http_substitutions_filter_module-0.6.4 \
			--add-module=/usr/local/src/ngx_http_geoip2_module-3.4 \
			--with-http_realip_module --with-http_v2_module \
			--add-module=/usr/local/src/ngx_http_proxy_connect_module-0.0.7
patch -d build/nginx-1.21.4/ -p 1 < /usr/local/src/ngx_http_proxy_connect_module-0.0.7/patch/proxy_connect_rewrite_102101.patch
gmake && gmake install

mkdir -p /usr/local/openresty/site/lualib /usr/local/openresty/site/pod /usr/local/openresty/site/manifest
ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/local/openresty/bin/openresty

cat > /usr/lib/systemd/system/openresty.service << 'EOF'
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/usr/local/openresty/nginx/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /usr/local/openresty/nginx/nginx.pid
ExecStartPre=/usr/local/openresty/nginx/sbin/nginx -t
ExecStart=/usr/local/openresty/nginx/sbin/nginx
ExecReload=/usr/local/openresty/nginx/sbin/nginx -s reload
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo "openresty installed sucessfully"

