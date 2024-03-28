#!/bin/bash
TOKEN=$(cat /opt/scripts/tg_token.txt)
MSG="<pre>
更新操作人员:${BUILD_USER}
工作名称:${JOB_NAME}
构建编号:${BUILD_NUMBER}
上传成功
</pre>"
curl -X POST --data chat_id="-4132657527" --data-urlencode "text=${MSG}" "https://api.telegram.org/bot${TOKEN}/sendMessage?parse_mode=HTML"
