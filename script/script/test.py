# -*- coding:utf-8 -*-
import os,telebot,re
from godaddypy import Client, Account
import sys
import time
import datetime
API_KEY = '5772026263:AAGj76NR6xbOGAao0Yhd92QmjkIj96-HVVw'
bot = telebot.TeleBot(API_KEY)
today = datetime.date.today()
#{'name': 'bw', 'key': 'epBem3jhHQKd_M4hAEWPapndtXvP7TaC6oE:RQvaNNRUAXA7f6KfHuyWDo'},
accList = [
    {'name':'c7','key':'ep2HsNfbSzhM_VhAiXk2Y4RMtDYS7Km6zaw:LkiHKqL4NjK7tkzi5ct1dC'},
    {'name':'ng','key':'epBem3jmiNBH_W69ZP86KsoJTteBt3xvVtu:NdPWc5gYyFYbso7REdsze4'},
    {'name':'quan','key':'epBem3jmhMai_V12qzjRgCspntdYZmYiUUy:S2deVnKbg6EdjNr6VVKgRW'},
    {'name':'wd','key':'epBvCugcDXPE_UiPcHjwvwhZBs4C5y9ehe8:9rRCem4ggZzmZiLYwvgJbd'},
    {'name':'yh','key':'fYqd8WomMfeT_FLinEouTPPGrLM8EapPJQy:FMVSoYNM8dwKYxHXXFTwqC'},
    {'name':'ngty','key':'fYqd8Woju1zD_RcFtd8GacksE2421ikjS73:LbWK9VV3to2Z1wvDhF89Fv'},
    {'name':'cgbw','key':'gGpZXZc5E9yz_NccV5r5mRoQFcJfXEez9K5:6q4GAtZjTMSewrShsVNCQj'},
    {'name':'备案','key':'eoBUwws2xS2B_7BWr6nY1z8XvZQHCb9ABiP:G1fAPjrLXegRT8Kybar8J4'},
    {'name':'newbw','key':'e5CRvU9Vwwms_Q3pfmrEbS8gprsucSHJNWu:HhBRJr7BGXdyLYQD9PphQJ'},
    {'name':'HHtt2018','key':'dLP8vnVJhMSp_Q25J1bHDqtp4yi49aBbty5:RSvKsy4MEsqZb4CpE4s9AD'},
    {'name':'yytt012','key':'e5CRvU3Bmg8c_8oivgnZPhJ5gac5pLeZBNq:E91cMdXX6mLmaCD1GWF9xw'},
    {'name':'dphu46x9vt','key':'eoWxfSgbuBNm_QCoorN5wFsDME6i8dhCqPZ:DESPiQDmqzsDV8BB34t2EH'},
    {'name':'ng288','key':'eorKozKF3K5H_Bi5EHNBwgshj1GmBwD1Tx8:6xv1fhWMA3pP3cxa5sWWA8'},
    {'name':'kaitiming99','key':'e4CVJkNqiLWj_Ssp6oTJtXC67WMT8NbVora:7ibibvkYdhUzWuSZUAeoPt'},
    {'name':'baowshangyong','key':'epBswwyZxfSR_UQFvJvK2vKTrU9CxoEUcRQ:GxBFQJ3yETvHpVRskuBJUF'},
    {'name':'bofangqi','key':'epMafSyAm4Ej_5gYZumptvcNmjcJgzMnrT9:TapHz5zSGyHL8t2yXYSnzS'},
    {'name':'haomengj','key':'fYWJBx3ApCbC_2XME721PUjBtZJPPPZJZC3:GpBpjmmdykg2qnkfwgCX1Z'},
    {'name':'aldjl78','key':'fYLQWYTD8X3s_H1TqXb9TN9fg1JGsP1VhgL:M6sCdfi2kKZqn18rwQhq9G'},
]

i = 0
for acc in accList:
    PUBLIC_KEY = acc['key'].split(':')[0]
    SECRET_KEY = acc['key'].split(':')[1]
    my_acct = Account(api_key=PUBLIC_KEY, api_secret=SECRET_KEY)
    client = Client(my_acct)
    i += 1
    domains = client.get_domains_withlimit(1000)

    for domain in domains:
        domainData = client.get_domain_info(domain)
        try:
            exprieDate = domainData['expires']

            abc = exprieDate.split('T')[0]
            #timeArray = time.strftime(abc,"%Y-%m-%d")
            #timeStamp = int(time.mktime(timeArray))
            abc=datetime.datetime.strptime(abc, "%Y-%m-%d").date()
            time.sleep(1)
            ex =  abc - today
            exs = -ex
        except Exception as e:
            pass
        if 0 < ex.days and ex.days <=  3 :
            bot.send_message(-693909373, domain + '\n还有'+ str(ex.days) + '天过期')
        #elif ex.days < 0:
            #bot.send_message(5164064896, domain+ '已过期'+ str(-ex.days)+ '天')
