# -*- coding:utf-8 -*-
import os,telebot,re
#from dotenv import load_dotenv
from godaddypy import Client, Account
import sys
import time
#load_dotenv()
#API_KEY = os.getenv('API_KEY')
API_KEY = ''
bot = telebot.TeleBot(API_KEY)
accList = [
    {'name':'item','key':':key:secret'},
]


@bot.message_handler(commands=['start'])
def start(message):
    bot.reply_to(message, "我是域名查询机器人,查询说明请输入/help查看")


@bot.message_handler(commands=['help'])
def help(message):
    introduce = '输入要查询的根域名'
    bot.reply_to(message, introduce)

@bot.message_handler()
def send_res(message):
    request = message.text.split()
    domain = request[0]
    count = 0
    for acc in accList:
        PUBLIC_KEY = acc['key'].split(':')[0]
        SECRET_KEY = acc['key'].split(':')[1]
        my_acct = Account(api_key=PUBLIC_KEY, api_secret=SECRET_KEY)
        client = Client(my_acct)
        try:
            domainData = client.get_domain_info(domain)
            print (domainData)
            try:
                domainRecords = client.get_records(domain)
                print (domainRecords)
                nameservers = domainData['nameServers']
                parts = nameservers[0].split(".")
                if ".".join(parts[-2:]) != 'domaincontrol.com':
                    raise Exception
                exprieDate = domainData['expires']
                domainRecordsStr = '%s域名在%s账号,过期日期为：%s\n域名解析内容：\n'% (domain,acc['name'],exprieDate)
                for domainRecord in domainRecords:
                    domainRecordsStr += '类型:'+domainRecord['type']+' 名称:'+domainRecord['name']+' 解析值:'+domainRecord['data']+'\n'
                bot.send_message(message.chat.id,domainRecordsStr)
                break
            except Exception as e :
                exprieDate = domainData['expires']
                nameservers = domainData['nameServers']
                bot.send_message(message.chat.id,'%s域名在%s账号,过期日期为：%s\n但NS不在%s账号,ns_nameservers为：\n%s'% (domain,acc['name'],exprieDate,acc['name'],nameservers))
              #  break
                pass
        except Exception as e :
             count += 1
             pass

    if count==len(accList):    
        bot.send_message(message.chat.id,'此域名不在当前所有账号')    
bot.polling()

