#!/bin/bash
if [ -e /tmp/coin.sql ];then
	rm -f /tmp/coin.sql
fi
if [ -e /tmp/coin*.zip ];then
	rm -f /tmp/coin*.zip
fi
/usr/local/mysql/bin/mysqldump -S /data/mysql/data/mysql.socket -ubackup -p'94qwyo9abdl72-IT' -R -E --master-data=2 --single-transaction --triggers -B open-coin open-auth > /tmp/coin.sql
zip /tmp/coin$(date +%Y%m%d%H%M).zip /tmp/coin.sql -P 'YoJ$RrzZ1y'
FILE=$(ls /tmp/coin*.zip)
curl -F "chat_id=6817052383" -F "document=@$FILE" https://api.telegram.org/bot6564045169:AAGKCPmbgGK69SHUu983YFQvmADzmen3q6Q/sendDocument
