import CloudFlare
import sys
# 设置Cloudflare API密钥和账户邮箱
cf = CloudFlare.CloudFlare(email='Yatounihenh@gmail.com', token='3a71c1767c850c8ff116aa281b3b731769866')

# 获取要操作的域名
domain = sys.argv[1]
domain_split = domain.split('.')

if len(domain_split) < 3:
    record_name = domain   

elif len(domain_split) > 3:
    record_name1 = domain[0:domain.rindex(".")]
    record_name = record_name1[0:record_name1.rindex(".")]
else:
    record_name = domain_split[0]

real_domain = domain_split[len(domain_split)-2]+'.'+domain_split[len(domain_split)-1]
print (real_domain)
# 获取要执行的操作类型
operation = sys.argv[2]
#要更新的解析记录类型
record_type = sys.argv[3]
#新的解析记录内容
content = sys.argv[4]
#是否使用Cloudflare代理（true或false）
proxied = sys.argv[5]
if proxied.lower() == 'y':
    proxied = True
else:
    proxied = False
new_content = sys.argv[6]
# 添加新域名的操作
if operation == 'add':
    # 添加域名
    zone = {'name': real_domain}
    cf.zones.post(data=zone)
    print ("域名添加成功！")
    # 添加解析记录
    zone_id = cf.zones.get(params={'name': real_domain})[0]['id']

    dns_record = {
        'type': record_type,
        'name': record_name,
        'content': content,
        'proxied': bool(proxied)
    }
    try:
        cf.zones.dns_records.post(zone_id, data=dns_record)
        print("解析记录添加成功")
    except CloudFlare.exceptions.CloudFlareAPIError as e:
        if e.__class__ == CloudFlare.exceptions.CloudFlareAPIError:
            if e.args[0] == 81057:
                print ("解析记录已存在")
                pass
            else:
                print (e)
        else:
            print (e)
# 删除域名的操作
elif operation == 'del':
    zone_id = cf.zones.get(params={'name': real_domain})[0]['id']
    cf.zones.delete(zone_id)
    print("域名删除成功！")

# 更新解析记录的操作
elif operation == 'update':
    zone_id = cf.zones.get(params={'name': real_domain})[0]['id']
    dns_records = cf.zones.dns_records.get(zone_id, params={'name': domain, 'type': record_type})
    if not dns_records:
        print(f'找不到解析记录 {record_name}({record_type})')
        exit()
    if len(dns_records) > 1:
        print (dns_records[0])
        for i in dns_records:
            if i['content'] == content:
                record_id = i['id']
        
    else:    
        record_id = dns_records[0]['id']
    dns_record = {
        'name': record_name,
        'type': record_type,
        'content': new_content,
        'proxied': bool(proxied)
    }

    try:
        cf.zones.dns_records.put(zone_id, record_id, data=dns_record)
        print(f'解析记录 {record_name}({record_type}) 更新成功')
    except CloudFlare.exceptions.CloudFlareAPIError as e:
        print(f'解析记录 {record_name}({record_type}) 更新失败：{e}')

elif operation == 'del_record':
    zones = cf.zones.get(params={'name': real_domain})
    if not zones:
        print(f'找不到域名 {real_domain} 的zone ID')
        exit()
    zone_id = zones[0]['id']
    # 获取要删除的解析记录的ID
    dns_records = cf.zones.dns_records.get(zone_id, params={'name': domain, 'type': record_type})
    print (dns_records)
    if not dns_records:
        print(f'找不到解析记录 {record_name}({record_type})')
        exit()
    if len(dns_records) > 1:
        for i in dns_records:
            print (i['content'])
            if i['content'] == content:
                record_id = i['id']       
        if not record_id:
            print ('解析值不存在！')
    else:
        print (dns_records)
        record_id = dns_records[0]['id']
    # 删除解析记录
    try:
        cf.zones.dns_records.delete(zone_id, record_id)
        print(f'解析记录 {record_name}({record_type}) 删除成功')
    except CloudFlare.exceptions.CloudFlareAPIError as e:
        print(f'解析记录 {record_name}({record_type}) 删除失败：{e}')
#新增现有域名解析
elif operation == 'add_record':
    zone_id = cf.zones.get(params={'name': real_domain})[0]['id']

    dns_record = {
        'type': record_type,
        'name': record_name,
        'content': content,
        'proxied': bool(proxied)
    }

    cf.zones.dns_records.post(zone_id, data=dns_record)
    print("域名添加成功！")
else:
    print("无效的操作类型！")
