log_path="/www/wwwlogs/*.log"
num=30
white_ip_list=(47.56.174.7 60.217.248 103.219.176 123.129.224 110.42.2 117.24.15 110.80.137 45.248.10 45.248.9 27.159.65 103.88.34 104.21.27.34 172.67.168.221 119.8 159.138 94.74 104.214 20.187 20.189 52.139 52.175 168.63 13 40.83 207.46 34 35 18.166 18.163 18.162 112.209 86.99 86.98 119.8.17 119.8.16 2.51 175.176 112.206 112.211 114.108 180.190 180.191 86.96 94.204 86.97 47.56.146.87 47.242 8.210 117.24.14 112.5.37 45.251.10 103.64.12.209 110.54 2.49 92.98)
function send_tg {
	TELEGRAM_BOT_TOKEN="1105802737:AAHPE1C6YYWbcVuUNsrI0ZeS8ShswTUaMmo"
	local data=$(curl -s "http://ip-api.com/json/$1?lang=zh-CN" | jq .)
	country=$(echo $data | jq .country)
	regionName=$(echo $data | jq .regionName)
	city=$(echo $data | jq .city)
	isp=$(echo $data | jq .isp)
	MSG="<b>自建库反代防火墙黑名单</b><pre>IP：$1
国家：$country
省市：$regionName $city
供应商：$isp 
</pre>"
	curl -X POST --data chat_id="-435385431" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage?parse_mode=HTML"
}
function main {
	while [ $# != 0 ]; do
		if grep "$1" "/www/server/nginx/conf/ip_black.conf"; then
			echo "$1 已在黑名单"
		else
			[[ ${white_ip_list[@]} =~ $1 || ${white_ip_list[@]} =~ $(echo $1 | awk -F"." '{print $1"."$2"."$3}') || ${white_ip_list[@]} =~ $(echo $1 | awk -F"." '{print $1"."$2}') || ${white_ip_list[@]} =~ $(echo $1 | awk -F"." '{print $1}') ]] || {
				echo "$1 添加黑名单"
				echo "deny $1;" >>"/www/server/nginx/conf/ip_black.conf"
				send_tg "$1"
			}
		fi
		shift
	done
	/bin/nginx -s reload
}
ipv4_reg="([0-9]{1,3}[.]){3}[0-9]{1,3}"
ip_list=$(grep "$(date +'%d/%b/%Y:%H:%M' -d "1 minute ago")" $log_path | grep -Ev "static|favicon" | awk '$3~"'$ipv4_reg'"{print $3}' | sort | uniq -c | sort -n | awk '$1>'$num'{print $2}' | xargs)
main $ip_list
