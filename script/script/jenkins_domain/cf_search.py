import CloudFlare
import sys
import os,telebot,re
API_KEY = '6025750117:AAFpMfZnmmTM3wf6wJAFOIjyiQERAAF2-vI' 
bot = telebot.TeleBot(API_KEY)
cf = CloudFlare.CloudFlare(email='Yatounihenh@gmail.com', token='3a71c1767c850c8ff116aa281b3b731769866')

@bot.message_handler()
def send_res(message):
    request = message.text.split()
    domain = request[0]
# 设置Cloudflare API密钥和账户邮箱

# 获取要操作的域名

    domain_split = domain.split('.')
    if len(domain_split) < 3:
            record_name = domain   

    elif len(domain_split) > 3:
        record_name1 = domain[0:domain.rindex(".")]
        record_name = record_name1[0:record_name1.rindex(".")]
    else:
        record_name = domain_split[0]

    real_domain = domain_split[len(domain_split)-2]+'.'+domain_split[len(domain_split)-1]
    try:
        zone_id = cf.zones.get(params={'name': real_domain})[0]['id']
        dns_records = cf.zones.dns_records.get(zone_id)
        recordstr = '域名%s解析内容\n'% (real_domain)
        print (recordstr)
        for record in dns_records:
            recordstr += '类型:'+record['type']+' 名称:'+record['name']+' 解析值:'+record['content']+'\n'
            print (recordstr)
        bot.send_message(message.chat.id,recordstr)
    except IndexError:
        bot.send_message(message.chat.id, '域名%s不在CF中' % real_domain)
    
bot.polling()