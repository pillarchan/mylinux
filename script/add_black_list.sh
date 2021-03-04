#!/bin/sh
log_path="www/wwwlogs/*.log"
request_count=500
filted_log=$(ls $log_path | grep -v ".*error\.log")
ipv4_reg="([0-9]{1,3}\.){3}[0-9]{1,3}"
ipv6_reg="([[:alnum:]]{4}:){7}[[:alnum:]]{4}"
ip_list=$(grep "$(date +'%d/%b/%Y:%H:%M' -d "3 hours ago")" $filted_log | grep -E -o "$ipv4_reg|$ipv6_reg" | sort | uniq -c | sort -n | awk '$1>'$request_count'{print $2}')

send_tg() {
	TELEGRAM_BOT_TOKEN="1105802737:AAHPE1C6YYWbcVuUNsrI0ZeS8ShswTUaMmo"
	curl -X POST -H 'Content-Type: application/json' \
		-d '{"chat_id": "-435385431", "text": "'$1'", "disable_notification": true}' \
		https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
}
add_black_list() {
	for i in $@; do
		if echo $(firewall-cmd --list-rich-rules) | grep "$i"; then
			echo "$i已加入黑名单"
		else
			if [[ $i =~ $ipv4_reg ]]; then
				firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address='"$i"' drop'
				send_tg "$i添加28圈反代黑名单,30分钟自动解封"
				at now + 30 minutes <<<"firewall-cmd --permanent --zone=public --remove-rich-rule='rule family="ipv4" source address='"$i"' drop';firewall-cmd --reload"
			else
				firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" source address='"$i"' drop'
				send_tg "$i添加28圈反代黑名单,30分钟自动解封"
				at now + 30 minutes <<<"firewall-cmd --permanent --zone=public --remove-rich-rule='rule family="ipv6" source address='"$i"' drop';firewall-cmd --reload"
			fi
		fi
	done
	echo "重载防火墙 $(firewall-cmd --reload)"
}
add_black_list $ip_list
