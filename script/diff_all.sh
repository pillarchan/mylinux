#!/bin/bash
# 根据两次提交的commit id 生成差异化包 差异化包根据build


buildnum=$1  #构建的项目的git差异文件目录路径

workspace=$2 #工作区目录路径 ^[^$|^commit|^parent

cd  $workspace


#NOW_DATE=`date +%F`

diff_file_name=$workspace/diff_all.tar.gz
if [ -e $diff_file_name ]; then
  rm -f $diff_file_name
fi
echo $buildnum
echo $startid
echo $endid
 
 
git diff --name-only --diff-filter=ACMRT $startid $endid|xargs tar --exclude db.php --exclude other.php  --exclude .env --exclude database.php --exclude redis.php --exclude index.php -zcvf diff_all.tar.gz --exclude config.js
