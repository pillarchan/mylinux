
import requests
import time
import sys
try:
    domain = sys.argv[1]
except:
    exit('需要输入域名')
key = "20b6a7deb67bdb36486d3b053cd06a8c"
node_ids = "30,31,32,36,37,38"
#host = "spfsst.nggngapi.com"

url = f"https://api.boce.com/v3/task/create/curl?key={key}&node_ids={node_ids}&host={domain}"

response = requests.get(url)

if response.status_code == 200:
    print(response.json())
else:
    print("请求出错，状态码为：", response.status_code)
id = response.json()['data']['id']
print (id)

url2 = f"https://api.boce.com/v3/task/curl/{id}?key={key}"
while True:
    response2 = requests.get(url2)   
    print (response2.json()['done'])
    if response2.json()['done'] == True:
        break
    time.sleep(10)
print (response2.json())
list = (response2.json()['list'])
for i in list:
    print ('地区:', i['node_name'],'解析ip：', i['remote_ip'],'解析ip地：', i['ip_region'],'返回码：', i['http_code'],'总时间', i['time_total'],'解析时间', i['time_namelookup'],'连接时间', i['time_connect'],'下载时间', i['download_time'], '错误码', i['error_code'])



