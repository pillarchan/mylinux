# -*- coding:utf-8 -*-
from godaddypy import Client, Account
import sys
import time
'''
try:
    domain = sys.argv[1]
except:
    exit('需要输入域名')

if domain.rfind("."):
    domain = domain[0,domain.rindex(".")]
print(domain)

domain_split = domain.split('.')
if len(domain_split) < 3:
    print('输入类似a.b.c')
    exit()
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

'''
key = 'ep2HsNfbSzhM_VhAiXk2Y4RMtDYS7Km6zaw:LkiHKqL4NjK7tkzi5ct1dC'

#def set_recode(zone_name):
PUBLIC_KEY = key.split(':')[0]
SECRET_KEY = key.split(':')[1]
'''
    data = {'data': recode,
            'name': name,
            'ttl': 600,
            'type': recode_type}
'''
try:
        my_acct = Account(api_key=PUBLIC_KEY, api_secret=SECRET_KEY)
        client = Client(my_acct)
        print (client)
        print (my_acct)
        #client.delete_records(zone_name, 'www', 'CNAME')
        #client.delete_records(zone_name, '@', 'A')
        #print(data)
        #client.add_record(zone_name, data)
        #domains = client.get_domains_withlimit(1000)
        i = sys.argv[1]
        #for i in domains :
           # time.sleep(0.5) 
            #print (client.get_domain_info(i))
        date = client.get_domain_info(i)["expires"]
            #with open ('c7_domain_date.txt', 'a+') as f:
            #    f.write(i+'\t')
            #    f.write(date+'\n')
        #print(domains)
        print (date)
except Exception as e:
    print(e)
    exit('操作失败')

#set_recode(real_domain)
