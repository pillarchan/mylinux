#!/usr/bin/python3
 
import pymysql,sys
 
# 打开数据库连接
db = pymysql.connect(host='192.168.76.137',
                     user='admin',
                     password='Q4ti4cq_9gtA',
                     port=3307,
                     database='mysql')
 
# 使用 cursor() 方法创建一个游标对象 cursor
cursor = db.cursor()

def addUser(username,ip): 
# 使用 execute()  方法执行 SQL 查询 
    sqlStr1="CREATE USER %s@'%s' IDENTIFIED BY 'z15Pbgfnwznv78Zj'" % (username,ip)
    sqlStr2="GRANT sim_user TO %s@'%s'" % (username,ip)
    cursor.execute(sqlStr1) 
    cursor.execute(sqlStr2) 


def multiAddUser(start,end):
    for i in range (start,end):
        ip="192.168.76.%s" % (i)
        try:
            addUser("db1_user",ip)
            db.commit()
            print('%s@%s添加成功' % ("db1_user",ip))
        except:
            db.rollback()
            print('%s@%s添加失败' % ("db1_user",ip))

arg1 = int(sys.argv[1])
arg2 = int(sys.argv[2])


multiAddUser(arg1,arg2)
# 关闭数据库连接
db.close()
