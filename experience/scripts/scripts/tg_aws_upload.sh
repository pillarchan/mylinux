#!/bin/bash
TOKEN=$(cat /opt/scripts/tg_token.txt)
declare -A domains=(
    [dm]="https://d1pudw69gjw8t1.cloudfront.net"
    [btu]="https://dbwhi1xb189lj.cloudfront.net"
    [kb]="https://d1iwhq6gxwlv3j.cloudfront.net"
	[cw]="https://d1f8cq50uxnhqi.cloudfront.net"
)
bucket=$1
dir=$2
filename=$3

case $bucket in
	"bbimbucket")
	domain=${domains[dm]}
	echo $domain
	;;
	"btubucket")
    domain=${domains[btu]}
	echo $domain
	;;
	"caowangbkt")
    domain=${domains[cw]}
	echo $domain
	;;
	"walletbck")
	domain=${domains[kb]}
	echo $domain
	;;
	*)
	echo "不能为空"
	exit
esac
MSG="<pre>
更新操作人员:${BUILD_USER}
工作名称:${JOB_NAME}
构建编号:${BUILD_NUMBER}
上传成功
生成链接为:${domain}/${dir}/${filename}
</pre>"
curl -X POST --data chat_id="-4132657527" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot${TOKEN}/sendMessage?parse_mode=HTML"
