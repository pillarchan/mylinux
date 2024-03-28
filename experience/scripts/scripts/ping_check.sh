#!/bin/bash
IP_LIST=(
"43.198.206.163" 
"43.198.209.145" 
"16.163.123.111" 
"16.162.100.226"
"8.212.50.16" 
"16.163.138.205" 
"16.163.142.55"
)
str=""
pingtest(){
	ping $1 -W 1 -c 2 &> /dev/null
	res=$?
	#return $result
	if [ $res -eq 0 ];then
		echo "ip:${1} is exsist"
	else
		echo "ip:${1} is down"
		str=${str}${1}" "
	fi
}

for i in ${IP_LIST[@]};do
	pingtest $i
done
send_TG() {
MSG="::IP检测:: 
<pre>IP:
$str 无法连接</pre>"
curl -X POST --data chat_id="6817052383" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot6564045169:AAGKCPmbgGK69SHUu983YFQvmADzmen3q6Q/sendMessage?parse_mode=HTML"
}
if [ ${#str} -gt 0 ]
then
    send_TG $(hostname)
fi

