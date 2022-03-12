import time
import telepot
import string
import time
import telepot
import string
import socket
import os
from telepot.loop import MessageLoop
white_chat_id = [1317379638,761175875]

def is_ip(ip):
    try:
        socket.inet_pton(socket.AF_INET, ip)
    except AttributeError:
        try:
            socket.inet_aton(ip)
        except socket.error:
            return False
        return ip.count('.') == 3
    except socket.error:
        return False
    return True

def handle(msg):
    content_type, chat_type, chat_id = telepot.glance(msg)
    print(content_type, chat_type, chat_id)
    if chat_id in white_chat_id:
        order_msg=msg['text'].split()
        if len(order_msg) == 2:
            if "addip" == order_msg[0]:        
                if is_ip(order_msg[1]):
                    result = os.system('ansible-playbook /opt/wangwang/add_ww_admin_ip.yml -i /etc/ansible/hosts.wwadmin -e ip='+order_msg[1])
                    if result == 0:
                        bot.sendMessage(chat_id, '添加成功')
                    else:
                        bot.sendMessage(chat_id, '添加失败')
                else:
                    bot.sendMessage(chat_id, 'IP格式有误，格式如：1.1.1.1')
            else:
                bot.sendMessage(chat_id, msg['text']+'命令不对，命令必须是addip')
        else:
            bot.sendMessage(chat_id, msg['text']+'格式不对，需要输入如：addip 1.1.1.1')
    else:
        err_msg = 'ID未加白不能使用,请通知管理员加白ID:%s'%chat_id
        bot.sendMessage(chat_id, err_msg)

TOKEN = 'TOKEN_code'

bot = telepot.Bot(TOKEN)
MessageLoop(bot, handle).run_as_thread()
print ('Listening ...')

# Keep the program running.
while 1:
    time.sleep(10)
