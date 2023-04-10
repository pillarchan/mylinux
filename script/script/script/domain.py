# -*- coding:utf-8 -*-
import os,telebot,re
from dotenv import load_dotenv
from godaddypy import Client, Account
import sys
import time
load_dotenv()
API_KEY = os.getenv('API_KEY')
bot = telebot.TeleBot(API_KEY)

accList = [
    {'name':'c7','key':'ep2HsNfbSzhM_VhAiXk2Y4RMtDYS7Km6zaw:LkiHKqL4NjK7tkzi5ct1dC'},
    {'name':'bw','key':'epBem3jhHQKd_M4hAEWPapndtXvP7TaC6oE:RQvaNNRUAXA7f6KfHuyWDo'},
    {'name':'ng','key':'epBem3jmiNBH_W69ZP86KsoJTteBt3xvVtu:NdPWc5gYyFYbso7REdsze4'},
    {'name':'quan','key':'epBem3jmhMai_V12qzjRgCspntdYZmYiUUy:S2deVnKbg6EdjNr6VVKgRW'},
    {'name':'wd','key':'epBvCugcDXPE_UiPcHjwvwhZBs4C5y9ehe8:9rRCem4ggZzmZiLYwvgJbd'},
    {'name':'yh','key':'fYqd8WomMfeT_FLinEouTPPGrLM8EapPJQy:FMVSoYNM8dwKYxHXXFTwqC'},
    {'name':'ngty','key':'fYqd8Woju1zD_RcFtd8GacksE2421ikjS73:LbWK9VV3to2Z1wvDhF89Fv'},
    {'name':'cgbw','key':'gGpZXZc5E9yz_NccV5r5mRoQFcJfXEez9K5:6q4GAtZjTMSewrShsVNCQj'},
    {'name':'备案','key':'eoBUwws2xS2B_7BWr6nY1z8XvZQHCb9ABiP:G1fAPjrLXegRT8Kybar8J4'},
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
            try:
                domainRecords = client.get_records(domain)
                exprieDate = domainData['expires']
                domainRecordsStr = '%s域名在%s账号,过期日期为：%s\n域名解析内容：\n'% (domain,acc['name'],exprieDate)
                for domainRecord in domainRecords:
                    domainRecordsStr += '类型:'+domainRecord['type']+' 名称:'+domainRecord['name']+' 解析值:'+domainRecord['data']+'\n'
                bot.send_message(message.chat.id,domainRecordsStr)
                break
            except Exception as e :
                bot.send_message(message.chat.id,'%s域名在%s账号,但NS不在%s账号'% (domain,acc['name'],acc['name']))
                break
                pass
        except Exception as e :
             count += 1
             pass

    if count==len(accList):    
        bot.send_message(message.chat.id,'此域名不在当前所有账号')    
bot.polling()

