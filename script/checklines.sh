#!/bin/bash
#链接表
urlList=/home/pillar/lineslist.txt
#urlList="E:/work/lineslist.txt"
#枚举去重后的链接表，访问获取响应码，如果不能200,则添加到坏表日志中
for item in $(cat $urlList | uniq); do
    echo $item
    #result=$(curl -i -m 60 --connect-timeout 30 $item | head -1 | cut -d" " -f2)
    elinks -dump $item
    if ! [ $? -eq 0 ]; then
        echo "$item code : $result" >>/home/pillar/check_line_result/badlist$(date +%Y-%m-%d).log
    fi
done
# echo $(curl -i https://bkyapp.ng779.com:9907 | head -1 | cut -d" " -f2)
#/media/pillar/backup/work/badlist$( date +%Y-%m-%d ).log E:/work/$( date +%Y-%m-%d ).log