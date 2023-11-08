FROM debian:12  
ADD lnmp2.0.tar.gz /usr/local/src/
ADD redis-5.3.7.tgz /usr/local/
RUN apt update && apt install curl gnupg2 ca-certificates lsb-release  systemd init vim rsyslog iputils-ping procps autoconf -y \
	&& cd /usr/local/src/lnmp2.0 && LNMP_Auto="y" DBSelect="0" PHPSelect="9" SelectMalloc="1" CheckMirror="n" ./install.sh lnmp \
	&& cd /usr/local/redis-5.3.7 && phpize \
	&& ./configure --with-php-config=/usr/local/php/bin/php-config \
	&& make && make install > phpredis_install.log \
	&& echo extension_dir=$(cut -d':' -f2 phpredis_install.log | grep -E -o "/usr.+") >> /usr/local/php/etc/php.ini \
	&& echo extension=redis.so >> /usr/local/php/etc/php.ini \
	&& lnmp start
EXPOSE 80 443
#CMD ["/lib/systemd/systemd","--system"]
CMD ["bash"]
