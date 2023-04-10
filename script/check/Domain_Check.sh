current_date=$(date -d "$(date '+%Y-%m-%d')" +%s)
send_TG() {
MSG="<b>域名到期检测</b><pre>域名：${1}
还有${2}天到期，请及时续期！
</pre>"
curl -X POST --data chat_id="-736954570" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot5240878837:AAFq-JRxvsAgfAh7bQg7Zkm7bVYsgyI4dF4/sendMessage?parse_mode=HTML"
}
data=$(mysql -u root -s -e "select domain_name from domain.domain_list;")
for i in $data
do
    domain_name=$(echo $i | awk -F"." '{print $(NF-1)"."$NF}')
    expiration_date=$(date -d "$(jwhois $i | egrep "Expiration|Expiry"| awk -F' |T' '{print $(NF-1)}')" +%s)
    res=$((($expiration_date-$current_date)/86400))
    if [ $res -lt 32 -a $res -gt 0 ]
    then
        send_TG $domain_name $res
    fi
done

