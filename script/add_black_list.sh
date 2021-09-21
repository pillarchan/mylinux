log_path="/www/wwwlogs/*.log"
num=30
white_ip_list=()

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
