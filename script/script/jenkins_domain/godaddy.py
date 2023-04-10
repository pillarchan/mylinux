# -*- coding:utf-8 -*-
from godaddypy import Client, Account
import sys

try:
    domain = sys.argv[1]
except:
    exit('需要输入域名')

key = 'epBem3jhHQKd_M4hAEWPapndtXvP7TaC6oE:RQvaNNRUAXA7f6KfHuyWDo'
ns1 = 'aliza.ns.cloudflare.com'
ns2 = 'johnathan.ns.cloudflare.com'

records=['ns1', 'ns2']

def change_ns_godaddy(zone_name):

    PUBLIC_KEY = key.split(':')[0]
    SECRET_KEY = key.split(':')[1]
    records = [ns1, ns2]

    try:
        my_acct = Account(api_key=PUBLIC_KEY, api_secret=SECRET_KEY)
        client = Client(my_acct)
        client.update_domain(zone_name, nameServers=records)
        print('修改域名%s NS记录成功' %zone_name)
    except Exception as e:
        print(e)
        exit('修改域名%s NS记录失败,请检查' %zone_name)


change_ns_godaddy(domain)
