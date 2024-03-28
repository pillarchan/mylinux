#!/bin/bash
if [ -e /tmp/sport.sql ];then
	rm -f /tmp/sport.sql
fi
if [ -e /tmp/sport*.zip ];then
	rm -f /tmp/sport*.zip
fi
docker exec -i mysql5740 sh -c 'exec mysqldump -uroot -p"UCGmd0gl3KCWkufO" -R -E --master-data=2 --single-transaction -B sport' > /tmp/sport.sql
zip /tmp/sport$(date +%Y%m%d%H%M).zip /tmp/sport.sql -P 'YoJ$RrzZ1y'
FILE=$(ls /tmp/sport*.zip)
curl -F "chat_id=6817052383" -F "document=@$FILE" https://api.telegram.org/bot6564045169:AAGKCPmbgGK69SHUu983YFQvmADzmen3q6Q/sendDocument
