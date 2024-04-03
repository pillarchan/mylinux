import pymysql
import time
import sys
hostname = '192.168.76.139'
username = 'router_user'
password = '123456'
database = 'information_schema'
def check_mysql(hostname, port, username, password, database, mode):
    try:
        conn = pymysql.connect(
            host=hostname,
            port=port,
            user=username,
            password=password,
            database=database
        )
        cursor = conn.cursor()
        cursor.execute("SELECT @@hostname")
        result = cursor.fetchone()
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] 当前节点: {result[0]}")
        cursor.close()
        conn.close()
        return True
    except pymysql.Error as e:
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] 操作失败:", e)
        return False
if len(sys.argv) > 1:
    mode = sys.argv[1]
    if mode == 'rw':
        port = 6446
    else:
        port = 6447
else:
    print("请提供命令行参数 mode (rw/ro)")
    sys.exit(1)
while True:
    check_mysql(hostname, port, username, password, database, mode)
    time.sleep(1)