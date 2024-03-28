#!/bin/bash
urlList=/home/domain_list.txt
str=""
for item in $(cat $urlList | uniq); do
    result=$(curl -i -m 60 --connect-timeout 30 $item -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" | head -1 | cut -d" " -f2)
    if [ $result -eq 200 -o $result -eq 302 -o $result -eq 404 ]; then
        echo "$item is variable"
    else
        str=$str$item" "
    fi
done

send_TG() {
MSG="::域名检测:: 
<pre>域名:
$str 无法连接</pre>"
curl -X POST --data chat_id="6817052383" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot6564045169:AAGKCPmbgGK69SHUu983YFQvmADzmen3q6Q/sendMessage?parse_mode=HTML"
}
if [ ${#str} -gt 0 ]
then
    send_TG $(hostname)
fi
