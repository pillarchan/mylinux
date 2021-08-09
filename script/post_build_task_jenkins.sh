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
