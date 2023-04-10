#!/bin/bash
ago_1_min=$(date -d "1 minute ago" +"%d/%b/%Y:%H:%M")
data=$(grep "$ago_1_min" $1 | awk '$8==403{print $1"] "$3,$5,$4,$6,$7}')
#ip_list=$(grep "$ago_1_min" $1 | awk '$8==403{print $3}'| sort -n|uniq)
#for i in $ip_list
#do
#    if [ "$i" != "119.13.79.5" ]
#    then
#        ipset add black_ip $i -!
#    fi
#done
send_TG() {
MSG="::异常请求:: 
<pre>主机名: $1
$data</pre>
"
curl -X POST --data chat_id="-661168875" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot5240878837:AAFq-JRxvsAgfAh7bQg7Zkm7bVYsgyI4dF4/sendMessage?parse_mode=HTML"
}
if [ ${#data} -gt 0 ]
then
    send_TG $(hostname)
fi
