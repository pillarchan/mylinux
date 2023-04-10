Files="$(find / \
! -path "/sys/*" \
! -path "/proc/*" \
! -path "/run/*" \
! -path "/var/log/*" \
! -path "/var/lib/*" \
! -path "/tmp/*" \
! -path "/var/cache/*" \
! -path "/var/spool/*" \
! -path "/opt/backup/*" \
! -path "/usr/local/mysql/*" \
! -path "/opt/quan-yfb/*" \
! -path "/opt/app_yfb/*" \
! -path "/home/wwwroot/service/runtime/*" \
! -path "/home/wwwroot/ngadmin_v430/data/*" \
! -path "/home/wwwroot/wending/wd_admin/data/Runtime/*" \
! -path "/home/wwwroot/wending/wd_admin_token/runtime/*" \
! -path "/home/wwwroot/wending/wd_service/runtime/*" \
! -path "/home/wwwroot/wending/wd_app/runtime/*" \
! -path "/home/wwwroot/wending/wd_report/runtime/*" \
! -path "/home/wwwroot/wending/wd_proxypay/runtime/*" \
! -path "/home/wwwroot/wending/wd_onlinepay/runtime/*" \
! -path "/home/wwwroot/wending/wd_onlinepay/data/*" \
! -path "/home/wwwroot/wending/wd_admin_token/data/conf/configs/*" \
! -path "/home/wwwroot/wending/wd_app/public/poster/*" \
! -path "/home/wwwroot/wending/wd_service/data/conf/configs/*" \
! -path "/home/wwwroot/wending/wd_report/data/conf/configs/*" \
! -path "/home/wwwroot/wending/wd_app/data/conf/configs/*" \
! -path "/home/wwwroot/wending/wd_app/poster/*" \
! -path "/home/wwwroot/wending/wd_proxypay/data/conf/configs/*" \
! -path "/home/yihao/admin/data/Runtime/*" \
! -path "/home/yihao/app/runtime/*" \
! -path "/home/yihao/online_pay/runtime/*" \
! -path "/home/yihao/admin_token/runtime/*" \
! -path "/home/yihao/proxy_pay/runtime/*" \
! -path "/home/yihao/service/runtime/*" \
! -path "/home/yihao/report/runtime/*" \
! -path "/home/yihao/online_pay/data/conf/configs/*" \
! -path "/home/yihao/report/data/conf/configs/*" \
! -path "/home/yihao/service/data/conf/configs/*" \
! -path "/home/yihao/admin_token/data/conf/configs/*" \
! -path "/home/yihao/proxy_pay/data/conf/configs/*" \
! -path "/home/yihao/app/data/conf/configs/*" \
! -path "/home/yihao/logs/*" \
! -path "/home/wwwroot/ng_qqun/runtime/*" \
! -path "/home/wwwroot/ngservice_v430/runtime/*" \
! -path "/home/wwwroot/ngadmin_v430/public/data/upload/excel/*" \
! -path "/home/group/service/runtime/*" \
! -path "/home/wwwroot/service6/runtime/*" \
! -path "/home/group/admin/data/Runtime/*" \
! -path "/home/group/admin_token/runtime/*" \
! -path "/home/wwwroot/bitclottery/data/runtime/*" \
! -path "/home/wwwroot/token.aierlele.com/runtime/*" \
! -path "/home/wwwroot/admin/data/runtime/*" \
! -path "/home/wwwroot/7c_dfnew_tp5/runtime/*" \
! -path "/home/wwwroot/center/runtime/*" \
! -path "/usr/local/mysql/var*" \
! -path "/home/group/report/runtime/*" \
! -path "/home/group/proxy_pay/data/conf/configs/*" \
! -path "/home/group/logs/*" \
! -path "/home/group/proxy_pay/runtime/data/*" \
! -path "/home/group/app/runtime/*" \
! -path "/home/group/service/runtime/*" \
! -path "/home/group/app/data/conf/configs/*" \
! -path "/home/group/online_pay/runtime/*" \
! -path "/home/group/online_pay/data/conf/configs/*" \
! -path "/home/group/service/data/conf/configs/*" \
! -path "/home/group/report/data/conf/configs/*" \
! -path "/home/group/admin_token/data/conf/configs/*" \
! -path "/home/wwwroot/ngapp_pro/app/runtime/*" \
! -path "/home/wwwroot/app/runtime/*" \
! -path "/home/wwwroot/ngapp_pro/app/runtime/*" \
! -path "/home/wwwroot/ng_dfnew_tp5/runtime/*" \
! -path "/home/wwwroot/7Cpay_v02/runtime/*" \
! -path "/home/wwwroot/ngpay_v02/runtime/*" \
! -path "/home/wwwroot/ngapp_pro/logs/*" \
! -path "/home/wwwlogs/*" \
! -path "/home/wwwroot/ngapp_pro/app/public/poster/*" \
! -path "/home/wwwroot/app/public/poster/*" \
! -path "/home/wwwroot/team_new/team/runtime/*" \
! -path "/home/wwwroot/ngapp_pro/app/poster/*" \
! -path "/home/wwwroot/app/poster/*" \
! -path "/home/wwwroot/quartz/lottery/public/ip.txt" \
! -path "/home/wwwroot/quartz/crontab/src/center/logs/*" \
! -path "/home/group/app/poster/*"\
-type f \
! -name ".viminfo" \
! -name "agentinfo" \
! -name "last_id_log.txt" \
! -name "_home_wwwroot_websockserver_start.php.pid" \
! -name "core.*" \
! -name "nohup.out" \
! -name ".bash_history" \
! -name "dead.letter" \
! -name "*.log" \
! -name "File_Check.sh" \
! -name "dump.rdb" \
! -name "sending.dat" \
! -name "master.dat" \
! -name "Foreign_Address_Check.sh" \
! -name "Proc_Check.sh" \
! -name "AnsiballZ_command.py" \
! -name "uri_301.sh" \
! -name "AnsiballZ_setup.py" \
! -name "AnsiballZ_yum.py" \
! -name "network_flow.dat" \
! -name "heartbeat.tick" \
-mmin -15)"
send_TG() {
MSG="::文件检测:: 
<pre>主机名: $1
$Files</pre>"
curl -X POST --data chat_id="-762822366" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot5240878837:AAFq-JRxvsAgfAh7bQg7Zkm7bVYsgyI4dF4/sendMessage?parse_mode=HTML"
}
if [ ${#Files} -gt 0 ]
then
    send_TG $(hostname)
fi

