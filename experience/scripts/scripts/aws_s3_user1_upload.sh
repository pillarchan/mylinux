#!/bin/bash
regexp=".+\.(zip|apk|json)$"
bucket=$1
dir=$2
release_name=$3

function upload(){
	# 配置 AWS 凭据
	export AWS_ACCESS_KEY_ID="AKIAQRBQJOCZ3GMKMIX7"
	export AWS_SECRET_ACCESS_KEY="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"
	export AWS_REGION="ap-east-1"
	# 配置 S3 存储桶
	if [ -e "${WORKSPACE}/awss3/${release_name}" ];then
		# 上传文件
		aws s3 cp ${WORKSPACE}/awss3/${release_name} s3://${bucket}/${dir}/ --acl public-read
	else
		echo "上传失败"
	    exit 2
	fi
	res2=$(echo $?)
	if [ $res2 -ne 0 ];then
		echo "上传失败"
		exit 2
	fi
}

if [ -e ${WORKSPACE}/awss3/release ];then
	mv ${WORKSPACE}/awss3/release ${WORKSPACE}/awss3/${release_name}
else
	echo "文件不存在"
	exit 2
fi 
if [ $release_name -eq 0 ];then
	echo "请文件名输入正确的文件名"
    exit 2
elif [ ${#release_name} -eq 0 ];then
	echo "文件名不能为空"
    exit 2
elif ! [[ "$release_name" =~ $regexp ]];then
	echo "文件后缀名不正确"
	exit 2
else
	upload
fi
