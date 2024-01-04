Files="$(find /home \
! -path "/home/ruyi/server/runtime/*" \
! -path "/home/ruyi/server/Upload/*" \
! -path "/home/ruyi/logs/*" \
-type f \
! -name "*.log" \
! -name "updatetotalinfo.txt" \
-mmin -15)"
send_TG() {
MSG="::文件检测:: 
<pre>主机名: $(hostname)
$Files</pre>"
curl -X POST --data chat_id="6817052383" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot6564045169:AAGKCPmbgGK69SHUu983YFQvmADzmen3q6Q/sendMessage?parse_mode=HTML"
}
if [ ${#Files} -gt 0 ]
then
    send_TG $(hostname)
fi
