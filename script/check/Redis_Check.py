import redis
import string
import time
import telepot
import socket
import os
import sys
from telepot.loop import MessageLoop
from loguru import logger

# 加白TG ID
white_chat_id = [
    1778785954, #task
    1317379638, #wayne
    1037683267, #ivan
    5347998164, #michael
    2132138283, #tony
    2141838381, #bell
    5318569296, #shooter
    5675701082, #jindao
    6090264960, #shooter
    5945161461, #康师傅
    5118704891, #土豆
]

# 平台redis信息
redis_info = {
    "ng": {"host":"18.166.142.75","password":"","port":"6379"},
    "c7": {"host":"18.166.168.116","password":"","port":"16379"},
    "28q": {"host":"18.166.85.167","password":"","port":"16379"},
    "wd": {"host":"16.162.60.69","password":"","port":"16379"},
    "yh": {"host":"18.167.237.239","password":"","port":"16379"},
    "club": {"host":"18.166.200.79","password":"","port":"16379"},
}

# redis可用命令
use_cmd = [
    "lrange",
    "get",
    "hget",
    "hgetall",
    "keys",
    "type",
    "zrange",
    "scard",
    "sismember",
    "ttl",
    "zscore",
    "llen",
]

def adb_shell(cmd):
    result = os.popen(cmd).read()
    return result
def handle(msg):
    content_type, chat_type, chat_id = telepot.glance(msg)
    if chat_id in white_chat_id:
        logger.add('/opt/check/all.log')
        order_msg=msg['text'].split()
        if order_msg[0] == "redis-cli" and order_msg[3] in use_cmd and order_msg[1] in redis_info: 
            cmd = "redis-cli -h "+ str(redis_info[order_msg[1]]['host']) +" -p "+ \
                  str(redis_info[order_msg[1]]['port']) +" -n "+ str(order_msg[2]) +\
                  " -a \""+ str(redis_info[order_msg[1]]['password']) +"\" "
            for i in order_msg[3:]:
                cmd += str(i) + " "
            res = adb_shell(cmd) 
            try:
                logger.info('用户(id)：%s(%s)|查询命令：%s' % (str(msg['from']['username']),str(msg['from']['id']),str(msg['text'])))
                logger.remove(handler_id=None)
                bot.sendMessage(chat_id, "\U00002714\n%s\n@%s" % (res,msg['from']['username']))
            except telepot.exception.TelegramError as err:
                logger.error('用户(id)：%s(%s)|查询命令：%s|消息内容过多' % (str(msg['from']['username']),str(msg['from']['id']),str(msg['text'])))
                logger.remove(handler_id=None)
                bot.sendMessage(chat_id,"\U00002757%d\n%s\n@%s" % (err.error_code, err.description, msg['from']['username']))
        else:
            platform = ""
            for i in redis_info.keys():
                platform += i + " "
            logger.warning('用户(id)：%s(%s)|查询命令：%s|命令执行有误' % (str(msg['from']['username']),str(msg['from']['id']),str(msg['text'])))
            logger.remove(handler_id=None)
            bot.sendMessage(chat_id, "\U0001F4D6Help\n命令有误,仅支持Redis查询相关的命令:\n平台编号："\
                            + platform +"\n支持命令："+ str(use_cmd[0:]) +"\n例：redis-cli ng 0 keys *test*")
    else:
        err_msg = '\U00002757403\nID未加白不能使用,请通知管理员加白ID:%s\n@%s'% (chat_id,msg['from']['username'])
        logger.error('用户(id)：%s(%s)|查询命令：%s|没有加白用户ID' % (str(msg['from']['username']),str(msg['from']['id']),str(msg['text'])))
        logger.remove(handler_id=None)
        bot.sendMessage(chat_id, err_msg)

TOKEN = '5384652943:AAEDyoZO4dnftbQE_foOY1oiwE3_vi89WEM'

bot = telepot.Bot(TOKEN)
MessageLoop(bot, handle).run_as_thread()
print ('Listening ...')

while 1:
    time.sleep(10)

