#!/bin/bash

if [ $# -lt 1 ];then
echo '请加上一个端口参数值不能大于6553'
exit 2
fi

if [ $1 -gt 6553  ];then
echo '请加上一个端口参数值不能大于6553'
exit 2
fi

if [ -e /etc/redhat-release ];then 
	yum remove mariadb-libs.x86_64 -y
fi

if [ -e /etc/os-release ];then 
	apt install libnuma-dev libncurses5 -y
fi

MYPORT=$1
MYUSER="mysql"
MYSQL_SOFTWARE_DIR='/opt/software'
MYSQL_HOME_DIR="${MYSQL_SOFTWARE_DIR}/mysql80"
MYSQL_BIN="${MYSQL_HOME_DIR}/bin"
MYSQL_DATA_DIR="/opt/data/mysql$MYPORT"
MYSQL_LOGS_DIR="/opt/logs/mysql$MYPORT"
MYSQL_ETC_DIR="/opt/etc/mysql$MYPORT"
MYSQL_PACKAGE="$(ls /usr/local/src/ | grep mysql-8.0)"
MYSQL_NAME=$(echo $MYSQL_PACKAGE | awk -F'.tar' '{print $1}')


mkdir -pv /opt/{data,logs,software,etc} $MYSQL_DATA_DIR $MYSQL_ETC_DIR $MYSQL_LOGS_DIR/{tmp,undo,redo,dbw,slow,relay,genaral,binlog}

tar xf /usr/local/src/$MYSQL_PACKAGE -C $MYSQL_SOFTWARE_DIR
ln -sv $MYSQL_SOFTWARE_DIR/$MYSQL_NAME $MYSQL_HOME_DIR
useradd -d $MYSQL_HOME_DIR $MYUSER -s /sbin/nologin

cat >/etc/profile.d/mysql.sh <<EOF
export PATH="$PATH:$MYSQL_BIN"
EOF

source /etc/profile.d/mysql.sh

chown -R $MYUSER:$MYUSER $MYSQL_DATA_DIR $MYSQL_LOGS_DIR $MYSQL_ETC_DIR $MYSQL_HOME_DIR

cat > $MYSQL_ETC_DIR/my.cnf << EOF
[mysql]
prompt="\u@\h \R:\m:\s[\d]>"

[mysqldump]
quick

[mysqld]
user=mysql
basedir=$MYSQL_HOME_DIR
datadir=$MYSQL_DATA_DIR
server-id=1
port=$MYPORT
socket=$MYSQL_DATA_DIR/mysql.sock
mysqlx_port=${MYPORT}0
mysqlx_socket=$MYSQL_DATA_DIR/mysql.sock
skip_name_resolve=1

pid-file=$MYSQL_DATA_DIR/mysql.pid
default-storage-engine=InnoDB
character-set-server=utf8mb4
default_time_zone='+08:00'
innodb_file_per_table=1
innodb_data_file_path=ibdata1:1G;ibdata2:4G

innodb_buffer_pool_instances=2
innodb_buffer_pool_size=384M
innodb_buffer_pool_filename=myib_buffer_pool

#innodb_undo_tablespaces=5

#log
log-error=$MYSQL_LOGS_DIR/error.log
general_log=0
general_log_file=$MYSQL_LOGS_DIR/genaral/mysql80.log

innodb_undo_log_truncate=1
innodb_max_undo_log_size=1073741824
innodb_undo_directory=$MYSQL_LOGS_DIR/undo
innodb_purge_rseg_truncate_frequency=32
innodb_rollback_segments=128

innodb_temp_tablespaces_dir=$MYSQL_LOGS_DIR/tmp
innodb_temp_data_file_path=../../logs/mysql$MYPORT/tmp/ibtmp${MYPORT}1:100M:autoextend:max:500M

#innodb_log_file_size=512M
#innodb_log_files_in_group=4
innodb_redo_log_capacity=2G
innodb_log_group_home_dir=$MYSQL_LOGS_DIR/redo

innodb_doublewrite_dir=$MYSQL_LOGS_DIR/dbw
innodb_doublewrite_files=4

log_bin=$MYSQL_LOGS_DIR/binlog/mybinlog
binlog_format=ROW
sync_binlog=1
#expire_logs_days=3
binlog_expire_logs_seconds=259200
max_binlog_size=100M

slow_query_log=1
slow_query_log_file=$MYSQL_LOGS_DIR/slow/slow.log
long_query_time=1
log_queries_not_using_indexes=1

relay_log=$MYSQL_LOGS_DIR/relay/my-relay-log

autocommit=1
transaction_isolation=REPEATABLE-READ

gtid_mode=ON
enforce_gtid_consistency=ON
#log_slave_updates=ON
log_replica_updates=ON

EOF

cp $MYSQL_HOME_DIR/support-files/mysql.server /etc/init.d/mysqld$MYPORT
sed -ri "s@(^basedir=)@\1\x22$MYSQL_HOME_DIR\x22@" /etc/init.d/mysqld$MYPORT
sed -ri "s@(^datadir=)@\1\x22$MYSQL_DATA_DIR\x22@" /etc/init.d/mysqld$MYPORT
sed -ri "s@(^extra_args=).+@\1\x22$MYSQL_ETC_DIR/my.cnf\x22@" /etc/init.d/mysqld$MYPORT
sed -ri "s@(^mysqld_pid_file_path=)@\1\x22$MYSQL_DATA_DIR/mysql.pid\x22@" /etc/init.d/mysqld$MYPORT
sed -i 's/^[[:space:]]\+\$bindir\/mysqld_safe/& --defaults-file="$extra_args"/' /etc/init.d/mysqld$MYPORT
systemctl daemon-reload


$MYSQL_BIN/mysqld --defaults-file=$MYSQL_ETC_DIR/my.cnf --user=mysql --basedir=$MYSQL_HOME_DIR --datadir=$MYSQL_DATA_DIR --initialize-insecure
#touch $MYSQL_DATA_DIR/mysql.pid
chown -R $MYUSER:$MYUSER $MYSQL_DATA_DIR
sleep 1
/etc/init.d/mysqld$MYPORT start



