t=$(date -d '- 15 minutes' '+%H:%M:%S')
IP_LIST=$(awk '$3>"'$t'"{print $0}' /var/log/secure | grep Accepted |  grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" | sort | uniq )
send_TG() {
MSG=":: 登入检测 :: <pre>$@</pre>"
curl -X POST --data chat_id="-736954570" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot5240878837:AAFq-JRxvsAgfAh7bQg7Zkm7bVYsgyI4dF4/sendMessage?parse_mode=HTML"
}
for i in $IP_LIST
do
    if [ $i != "16.162.125.103" -a $i != "16.162.0.156" -a $i != "43.198.73.220" -a $i != "18.162.60.253" -a $i != "18.166.56.246" ]
    then
        send_TG $(hostname) $i
    fi
done
