#!/bin/bash
function changeRule(){
	# 配置 AWS 凭据
	export AWS_ACCESS_KEY_ID="AKIAQRBQJOCZQNOWSAS5"
	export AWS_SECRET_ACCESS_KEY="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"
	export AWS_REGION="ap-east-1"
	aws ec2 authorize-security-group-ingress --group-id $group_id --protocol tcp --port $port --cidr $ip
}
if [ $# -ne 3 ];then
	echo "参数不够"
	exit 2
else
	group_id=$1
	port=$2
	ip=$3
	
	changeRule
fi
