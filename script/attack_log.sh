if [ $# -lt 2 ];then 
	echo "给参数";exit 2
else	
ls *$1* | xargs cat >> log/$2.log; awk -F' ' '{print $1" "$7" "$11}' log/$2.log | sort | uniq -c | sort -n >> log/$2_attack.log
#echo $1 $2
fi
