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





#jenkins
#!/bin/bash
path=$JENKINS_HOME/workspace/$JOB_NAME
echo $BUILD_ID
echo $path
/home/online.sh  $BUILD_ID  $path


declare -A dict
dict=(
    [FILES]="$(tar tf diff_online.tar.gz |xargs)"
    [P_NAME]="ww28game_inner"
    [I_NAME]="card"
    [I_PATH]="/data/28game/card"
    [B_PATH]="/opt/backup/"
)

ansible ${dict['P_NAME']} -m shell \
-a "cd ${dict['I_PATH']} && tar czf ${dict['B_PATH']}/${dict['I_NAME']}-$BUILD_NUMBER.tar.gz ${dict['FILES']} 2> /dev/null; echo backup codes"


#bots
CHANGE_FILES=$(tar tf diff_online.tar.gz)
description=$(git log --pretty=%s $endid -1)
MSG="<b>项目：$JOB_NAME</b><pre>构建者：$BUILD_USER
构建编号：$BUILD_ID
构建分支：$git
开始节点：$startid
结束节点：$endid
描述：$description
更新文件：
$CHANGE_FILES</pre>"
curl -X POST --data chat_id="${GROUP_ID}" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot${TOKEN_ID}/sendMessage?parse_mode=HTML"
