#!/bin/bash
# 根据两次提交的commit id 生成差异化包 差异化包根据build


buildnum=$1  #构建的项目的git差异文件目录路径

workspace=$2 #工作区目录路径 ^[^$|^commit|^parent

cd  $workspace


#NOW_DATE=`date +%F`

diff_file_name=$workspace/diff_online.tar.gz
if [ -e $diff_file_name ]; then
  rm -f $diff_file_name
fi
echo $buildnum
echo $startid
echo $endid
# 匹配不同的过滤规则
case $workspace in
    *NgOnline*)
    git diff --name-only --diff-filter=ACMRT $startid $endid|xargs tar \
    --exclude db.php \
    --exclude .env \
    --exclude database.php \
    --exclude .gitignore \
    --exclude index.php \
    --exclude InitChannelBehavior.class.php \
    --exclude redis.php \
    --exclude Core.rar \
    -zcvf diff_online.tar.gz
    ;;
    *)
    git diff --name-only --diff-filter=ACMRT $startid $endid|xargs tar \
    --exclude db.php \
    --exclude .env  \
    --exclude other.php \
    --exclude database.php \
    --exclude .gitignore \
    --exclude index.php \
    --exclude InitChannelBehavior.class.php \
    --exclude redis.php \
    --exclude config.php \
    --exclude Core.rar \
    --exclude lottery.php \
    --exclude sms_config.php \
    --exclude timer_server_config.php \
    --exclude amqp.php \
    -zcvf diff_online.tar.gz
esac
