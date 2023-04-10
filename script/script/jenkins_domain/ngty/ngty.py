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
domain_split = domain.split('.')
if len(domain_split) < 3:
    name = '@'
elif len(domain_split) > 3:
    name1 = domain[0:domain.rindex(".")]
    name = name1[0:name1.rindex(".")]
else:
    name = domain_split[0]

real_domain = domain_split[len(domain_split)-2]+'.'+domain_split[len(domain_split)-1]

try:
    recode_type = sys.argv[2]
except:
    exit('需要选择解析类型')

try:
    recode = sys.argv[3]
except:
    exit('需要输入记录内容')

try:
    implement = sys.argv[4]
except:
    exit('需要选择操作方式')

key = 'fYqd8Woju1zD_RcFtd8GacksE2421ikjS73:LbWK9VV3to2Z1wvDhF89Fv'

def set_recode(zone_name):

    PUBLIC_KEY = key.split(':')[0]
    SECRET_KEY = key.split(':')[1]
    data = {'data': recode,
            'name': name,
            'ttl': 600,
            'type': recode_type}

    try:
        my_acct = Account(api_key=PUBLIC_KEY, api_secret=SECRET_KEY)
        client = Client(my_acct)

        if ( (implement) == 'add' ):            
            client.add_record(zone_name, data)
            print (domain+ ('添加成功'))
        elif ( (implement) == 'del' ):
            client.delete_records(zone_name, name, recode_type)
            print(domain+ ('删除成功'))
        elif ( (implement) == 'update' ):
            client.update_record_ip(recode, zone_name, name, recode_type)
            print (domain+ ('更新成功'))
        else:
            print ('操作方式未定义')
            exit()

    except Exception as e:
        print(e)
        exit('操作失败')

set_recode(real_domain)
