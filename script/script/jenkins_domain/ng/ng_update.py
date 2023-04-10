# -*- coding:utf-8 -*-
from godaddypy import Client, Account
import sys

try:
    domain = sys.argv[1]
    ip = sys.argv[2]
    name = sys.argv[3]
    record = sys.argv[4]
except:
    exit('需要输入域名')
'''
if domain.rfind("."):
    domain = domain[0,domain.rindex(".")]
print(domain)
'''
domain_split = domain.split(".")
real_domain = domain_split[len(domain_split)-2]+'.'+domain_split[len(domain_split)-1]

key = 'epBem3jmiNBH_W69ZP86KsoJTteBt3xvVtu:NdPWc5gYyFYbso7REdsze4'

def set_recode(zone_name):

    PUBLIC_KEY = key.split(':')[0]
    SECRET_KEY = key.split(':')[1]

    try:
        my_acct = Account(api_key=PUBLIC_KEY, api_secret=SECRET_KEY)
        client = Client(my_acct)
        print(zone_name)
        client.update_record_ip(ip, zone_name, name, record)
       # client.delete_records(zone_name, 'www', "CNAME")
       # client.delete_records(zone_name, '@', 'A')
    except Exception as e:
        print(e)
        exit('操作失败')

set_recode(real_domain)
