#!/bin/bash

MYSQL_SOFTWARE_DIR='/opt/software'
MYSQL_HOME_DIR="${MYSQL_SOFTWARE_DIR}/mysql80"
MYSQL_BIN="${MYSQL_HOME_DIR}/bin"
MYSQL_DATA_DIR="/opt/data/mysql3308"
MYSQL_LOGS_DIR="/opt/logs/mysql3308"
MYSQL_ETC_DIR="/opt/etc/mysql3308"
MYSQL_PACKAGE="$(ls /usr/local/src/ | grep mysql-8.0)"
MYSQL_NAME=$(echo $MYSQL_PACKAGE | awk -F'.tar' '{print $1}')

mkdir -pv /opt/{data,logs,software,etc} $MYSQL_DATA_DIR $MYSQL_ETC_DIR $MYSQL_LOGS_DIR/{tmp,undo,redo,dbw,slow,relay}

tar xf /usr/local/src/$MYSQL_PACKAGE -C $MYSQL_SOFTWARE_DIR
ln -sv $MYSQL_SOFTWARE_DIR/$MYSQL_NAME $MYSQL_HOME_DIR
useradd -d $MYSQL_HOME_DIR mysql -s /sbin/nologin

cat >/etc/profile.d/mysql.sh <<EOF
export PATH="$PATH:$MYSQL_BIN"
EOF

source /etc/profile.d/mysql.sh

chown -R mysql:mysql $MYSQL_DATA_DIR $MYSQL_LOGS_DIR $MYSQL_ETC_DIR $MYSQL_HOME_DIR

cat > $MYSQL_ETC_DIR/my.cnf < EOF
[mysqld]
user=mysql
basedir=$MYSQL_HOME_DIR
datadir=$MYSQL_DATA_DIR
server-id=1
port=3308
socket=/tmp/mysql3308.sock
mysqlx_port=33080
mysqlx_socket=/tmp/mysql3308.sock
skip_name_resolve=1
log-error=$MYSQL_LOGS_DIR/mysql3308error.log
pid-file=/opt/data/mysql3308/mysql3308.pid
default-storage-engine=InnoDB
character-set-server=utf8mb4
default_time_zone='+08:00'
innodb_file_per_table=1
innodb_data_file_path=ibdata1:1G;ibdata2:4G
#innodb_undo_tablespaces=5
innodb_undo_log_truncate=1
innodb_max_undo_log_size=1073741824
innodb_undo_directory=$MYSQL_LOGS_DIR/undo
innodb_purge_rseg_truncate_frequency=32
innodb_rollback_segments=128
innodb_temp_tablespaces_dir=$MYSQL_LOGS_DIR/tmp
innodb_temp_data_file_path=../../logs/mysql3308/tmp/ibtmp33081:100M:autoextend:max:500M
#innodb_log_file_size=512M
#innodb_log_files_in_group=4
innodb_redo_log_capacity=2G
innodb_log_group_home_dir=$MYSQL_LOGS_DIR/redo
innodb_doublewrite_dir=$MYSQL_LOGS_DIR/dbw
innodb_doublewrite_files=4
innodb_buffer_pool_instances=2
innodb_buffer_pool_size=384M
innodb_buffer_pool_filename=myib_buffer_pool
general_log=1
general_log_file=$MYSQL_LOGS_DIR/genaral/mysql80.log
autocommit=1
transaction_isolation=REPEATABLE-READ
log_bin=$MYSQL_LOGS_DIR/binlog/mybinlog
binlog_format=ROW
sync_binlog=1
expire_logs_days=3
max_binlog_size=100M
slow_query_log=1
slow_query_log_file=$MYSQL_LOGS_DIR/slow/slow.log
long_query_time=1
log_queries_not_using_indexes=1
relay_log=$MYSQL_LOGS_DIR/relay/my-relay-log
gtid_mode=ON
enforce_gtid_consistency=ON
log_slave_updates=ON

[client]
prompt=[\u \D \d]>
EOF


