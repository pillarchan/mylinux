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
	apt install libnuma-dev libncurses5 libncurses6 -y
fi

MYPORT=$1
MYUSER="mysql"
MYSQL_SOFTWARE_DIR='/opt/software'
MYSQL_HOME_DIR="${MYSQL_SOFTWARE_DIR}/mysql80"
MYSQL_BIN="${MYSQL_HOME_DIR}/bin"
MYSQL_DATA_PRE_DIR="/opt/data/mysql$MYPORT"
MYSQL_DATA_DIR="$MYSQL_DATA_PRE_DIR/data"
MYSQL_TMP_DIR="/$MYSQL_DATA_PRE_DIR/tmp"
MYSQL_LOGS_DIR="/opt/logs/mysql$MYPORT"
MYSQL_ETC_DIR="/opt/etc/mysql$MYPORT"
MYSQL_PACKAGE="$(ls /usr/local/src/ | grep mysql-8.0)"
MYSQL_NAME=$(echo $MYSQL_PACKAGE | awk -F'.tar' '{print $1}')
IP=$(hostname -I)
CPUS=$(lscpu | grep -E "CPU\(s\)" | sed -rn "1s/[^0-9]//gp")
MEMORY_PERCENT_BUFFER_POOL=$(free -ml | grep -o -E "[0-9]+" | head -n1 | xargs echo 0.7* | bc | awk '{print int($0)}')
MEMORY_PERCENT_SESSION_BUFFER=$(free -ml | grep -o -E "[0-9]+" | head -n1 | xargs echo 0.1* | bc | awk '{print int($0)}')
MYSQL_START_FILE="/etc/init.d/mysqld$MYPORT"


mkdir -pv /opt/{data,logs,software,etc} $MYSQL_DATA_DIR $MYSQL_TMP_DIR $MYSQL_ETC_DIR $MYSQL_LOGS_DIR/{slow,relay,general,binlog}

tar xf /usr/local/src/$MYSQL_PACKAGE -C $MYSQL_SOFTWARE_DIR
ln -sv $MYSQL_SOFTWARE_DIR/$MYSQL_NAME $MYSQL_HOME_DIR
echo "${MYSQL_HOME_DIR}/lib/" > /etc/ld.so.conf.d/mysql80.conf
ldconfig
sed -ri "/MANDATORY_MANPATH\s+\/usr\/local\/share\/man/ a MANDATORY_MANPATH ${MYSQL_HOME_DIR}/man" /etc/manpath.config

useradd -d $MYSQL_HOME_DIR $MYUSER -s /sbin/nologin

cat >/etc/profile.d/mysql.sh <<EOF
export PATH="$PATH:$MYSQL_BIN"
EOF

source /etc/profile.d/mysql.sh

chown -R $MYUSER:$MYUSER $MYSQL_DATA_DIR $MYSQL_LOGS_DIR $MYSQL_ETC_DIR $MYSQL_HOME_DIR

cat > /etc/my.cnf << EOF
[mysql]
prompt="\u@\h \R:\m:\s[\d]>"
socket=$MYSQL_DATA_DIR/mysql.socket
EOF

cat > $MYSQL_ETC_DIR/my.cnf << EOF
[mysqldump]
quick

[mysqld]
#GENERAL
user=mysql
basedir=$MYSQL_HOME_DIR
datadir=$MYSQL_DATA_DIR
port=${MYPORT}
socket=${MYSQL_DATA_DIR}/mysql.socket
mysqlx_port=${MYPORT}0
mysqlx_socket=${MYSQL_DATA_DIR}/mysqlx.socket

log-error=${MYSQL_LOGS_DIR}/mysql80err.log
pid-file=${MYSQL_DATA_DIR}/mysql80.pid
default_time_zone="+08:00"
log_timestamps=system
default_storage_engine=InnoDB
character_set_server=utf8mb4
transaction_isolation=REPEATABLE-READ
activate_all_roles_on_login=1
tmpdir=${MYSQL_TMP_DIR}
secure_file_priv=${MYSQL_TMP_DIR}
report_host=${IP}
report_port=${MYPORT}

#LOGS
general_log=0
general_log_file=${MYSQL_LOGS_DIR}/general/general.log

slow_query_log=1
slow_query_log_file=${MYSQL_LOGS_DIR}/slow/slow.log
long_query_time=1
log_queries_not_using_indexes=1

#SESSION
read_buffer_size="${MEMORY_PERCENT_SESSION_BUFFER}M"
read_rnd_buffer_size="${MEMORY_PERCENT_SESSION_BUFFER}M"
sort_buffer_size="${MEMORY_PERCENT_SESSION_BUFFER}M"
join_buffer_size="${MEMORY_PERCENT_SESSION_BUFFER}M"

#CONNECTION
skip_name_resolve=1
back_log=$MEMORY_PERCENT_SESSION_BUFFER
max_connections=$MEMORY_PERCENT_SESSION_BUFFER
max_connect_errors=10
interactive_timeout=1800
wait_timeout=1800
thread_cache_size=128
max_allowed_packet="${MEMORY_PERCENT_SESSION_BUFFER}M"

#INNODB
innodb_file_per_table=1
innodb_data_file_path=ibdata1:1G:autoextend

innodb_buffer_pool_size="${MEMORY_PERCENT_BUFFER_POOL}M"
innodb_buffer_pool_instances=4
innodb_buffer_pool_load_at_startup=1
innodb_buffer_pool_dump_at_shutdown=1

#innodb_log_file_size=512M
#innodb_log_files_in_group=2
innodb_redo_log_capacity=1G

#innodb_undo_tablespaces=2
innodb_max_undo_log_size=1024M
innodb_undo_log_truncate=1

innodb_io_capacity=200
innodb_io_capacity_max=500
innodb_read_io_threads=${CPUS}
innodb_write_io_threads=${CPUS}

innodb_page_cleaners=${CPUS}
innodb_purge_threads=${CPUS}
innodb_flush_method=O_DIRECT
innodb_flush_neighbors=1
innodb_flush_log_at_trx_commit=1
innodb_autoinc_lock_mode=2
innodb_checksum_algorithm=crc32
innodb_strict_mode=1
innodb_print_all_deadlocks=1
innodb_numa_interleave=1
innodb_open_files=65535
innodb_adaptive_hash_index=OFF

#REPLICATION
server_id=1
log_bin=${MYSQL_LOGS_DIR}/binlog/mysql-bin
relay_log=${MYSQL_LOGS_DIR}/relaylog/relay-bin
sync_binlog=1
binlog_format=ROW
master_info_repository=TABLE
relay_log_info_repository=TABLE
relay_log_recovery=ON
#log_slave_updates=ON
log_replica_updates=ON
binlog_expire_logs_seconds=604800
slave_rows_search_algorithms='INDEX_SCAN,HASH_SCAN'
slave_net_timeout=60
skip_slave_start=ON
binlog_error_action=ABORT_SERVER
#super_read_only=ON

#GTID
gtid_mode=ON
enforce_gtid_consistency=ON
binlog_gtid_simple_recovery=TRUE

#SEMI_REPLICATION
#plugin_load='validate_password.so;rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so'
#rpl_semi_sync_master_enabled=ON
#rpl_semi_sync_slave_enabled=ON
#rpl_semi_sync_master_timeout=10000

#MULTI_THREAD_REPLICATION
slave_parallel_type=LOGICAL_CLOCK
slave_parallel_workers=${CPUS}
slave_preserve_commit_order=ON
binlog_transaction_dependency_tracking= WRITESET_SESSION
binlog_transaction_dependency_history_size=25000
transaction_write_set_extraction=XXHASH64

#OTHERS
open_files_limit=65535
max_heap_table_size=32M 
tmp_table_size=32M
table_open_cache=65535
table_definition_cache=65535
table_open_cache_instances=64
log_bin_trust_function_creators=1
EOF

cp $MYSQL_HOME_DIR/support-files/mysql.server $MYSQL_START_FILE
sed -ri "s@(^basedir=)@\1\x22$MYSQL_HOME_DIR\x22@" $MYSQL_START_FILE
sed -ri "s@(^datadir=)@\1\x22$MYSQL_DATA_DIR\x22@" $MYSQL_START_FILE
sed -ri "s@(^extra_args=).+@\1\x22$MYSQL_ETC_DIR/my.cnf\x22@" $MYSQL_START_FILE
sed -ri "s@(^mysqld_pid_file_path=)@\1\x22$MYSQL_DATA_DIR/mysql.pid\x22@" $MYSQL_START_FILE
sed -i 's/^[[:space:]]\+\$bindir\/mysqld_safe/& --defaults-file="$extra_args"/' $MYSQL_START_FILE
systemctl daemon-reload

chown -R $MYUSER:$MYUSER $MYSQL_DATA_PRE_DIR
chown -R $MYUSER:$MYUSER $MYSQL_LOGS_DIR
$MYSQL_BIN/mysqld --defaults-file=$MYSQL_ETC_DIR/my.cnf --user=$MYUSER  --initialize-insecure
#touch $MYSQL_DATA_DIR/mysql.pid
sleep 3
/etc/init.d/mysqld$MYPORT start

cat > /etc/security/limits.d/mysql.conf << EOF
mysql hard noproc 65535
mysql hard nofile 65535
mysql soft noproc 65535
mysql soft nofile 65535
EOF
