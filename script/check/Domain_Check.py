# -*- coding: utf-8 -*-
import time
import pymysql
import telepot
import string
import time
import telepot
import socket
import os
import sys
from telepot.loop import MessageLoop
white_chat_id = [1317379638,5175988241,5164064896,5460594523]
def req_db(sql):
    db = pymysql.connect(host='localhost',
                     user='root',
                     password='',
                     database='domain')
    cursor = db.cursor()
    msg_text = ""
    try:
       cursor.execute(sql)
       results = cursor.fetchall()
       for row in results:
          domain = row[1]
          remark = row[2]
          msg_text = '%s\n描述：%s' % \
                (domain,remark)
    except:
       print("Error: unable to fetch data")
    return msg_text
    db.close()

def adb_shell(cmd):
    result = os.popen(cmd).read()
    return result

def handle(msg):
    content_type, chat_type, chat_id = telepot.glance(msg)
    print(content_type, chat_type, chat_id)
    if chat_id in white_chat_id:
        order_msg=msg['text'].split()
        if order_msg[0] == "search":
            sql = "SELECT * FROM domain.domain_list where domain_name like '%"+order_msg[1]+"%'"
            result = req_db(sql)
            if len(result) != 0:
                bot.sendMessage(chat_id, result)
            else:
                bot.sendMessage(chat_id, "%s 域名不存在"%order_msg[1])
        elif order_msg[0] == "add" and len(order_msg) == 3:
            sql = "SELECT * FROM domain.domain_list where domain_name = '"+order_msg[1]+"'"
            result = req_db(sql)
            if len(result) != 0:
                bot.sendMessage(chat_id, "%s 域名已存在，添加失败"%order_msg[1])
            else:
                sql = "use domain;insert into domain_list (domain_name,remark) values ('"+order_msg[1]+"','"+order_msg[2]+"')"
                adb_shell('mysql -e "'+sql+'"')
                bot.sendMessage(chat_id, "%s 域名添加成功"%order_msg[1])
        elif order_msg[0] == "update" and len(order_msg) == 3:
            sql = "SELECT * FROM domain.domain_list where domain_name = '"+order_msg[1]+"'"
            result = req_db(sql)
            if len(result) == 0:
                bot.sendMessage(chat_id, "%s 域名不存在，修改失败"%order_msg[1])
            else:
                sql = "use domain;UPDATE domain_list SET remark='"+order_msg[2]+"' WHERE domain_name='"+order_msg[1]+"';"
                adb_shell('mysql -e "'+sql+'"')
                bot.sendMessage(chat_id, "%s 域名描述\n修改为%s"%(order_msg[1],order_msg[2]))
        else:
            bot.sendMessage(chat_id, "命令有误,仅支持[查询|添加]域名;修改描述：\nsearch 域名\nadd 域名 描述\nupdate 域名 描述")
    else:
        err_msg = 'ID未加白不能使用,请通知管理员加白ID:%s'%chat_id
        bot.sendMessage(chat_id, err_msg)

TOKEN = '5086774308:AAH2JkYllGXX32xouLvX_Cwq4-isZM85l58'

bot = telepot.Bot(TOKEN)
MessageLoop(bot, handle).run_as_thread()
print ('Listening ...')

while 1:
    time.sleep(10)
