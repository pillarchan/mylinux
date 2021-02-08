#!/bin/bash
LOG_PATH=/home/wwwlogs/
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
# nginx日志pid 路径
PID=/usr/local/nginx/logs/nginx.pid

#对照现有日志目录下的日志文件名
mv ${LOG_PATH}app.api.com.log ${LOG_PATH}app-${YESTERDAY}.log
mv ${LOG_PATH}app.com.log ${LOG_PATH}admin-${YESTERDAY}.log
mv ${LOG_PATH}app.service.com.log ${LOG_PATH}service-${YESTERDAY}.log

find $LOG_PATH -mtime +30 -name "*.log" -exec rm -rf {} \;
kill -USR1 `cat ${PID}`
