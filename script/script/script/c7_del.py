# -*- coding:utf-8 -*-
from godaddypy import Client, Account
import sys

try:
    domain = sys.argv[1]
except:
    exit('需要输入域名')
'''
if domain.rfind("."):
    domain = domain[0,domain.rindex(".")]
print(domain)
'''
domain_split = domain.split(".")
real_domain = domain_split[len(domain_split)-2]+'.'+domain_split[len(domain_split)-1]

key = 'ep2HsNfbSzhM_VhAiXk2Y4RMtDYS7Km6zaw:LkiHKqL4NjK7tkzi5ct1dC'

def set_recode(zone_name):

    PUBLIC_KEY = key.split(':')[0]
    SECRET_KEY = key.split(':')[1]

    try:
        my_acct = Account(api_key=PUBLIC_KEY, api_secret=SECRET_KEY)
        client = Client(my_acct)
        print(zone_name)
        client.update_record_ip('3.3.3.3', zone_name, '@', 'A')
       #client.delete_records(zone_name, 'www', "CNAME")
        client.delete_records(zone_name, '@', 'A')
    except Exception as e:
        print(e)
        exit('操作失败')

set_recode(real_domain)
