#!/usr/bin/env python3
#############################
## from demo.py
## requirement:
## python3 -m pip install requests
## python3 -m pip install openpyxl

import time,hashlib,sys,os,json,datetime
import logging
import re
import requests
from openpyxl import Workbook
from openpyxl import load_workbook

class bt_api:
    __BT_KEY = 'CFDzCcYnkyLHouQu0pwfYgDB5ee9LwHB'
    __BT_PANEL = 'http://103.37.0.130:12580'
    __BT_NAME = "103.37.0.130"

    #如果希望多台面板，可以在实例化对象时，将面板地址与密钥传入
    def __init__(self,bt_panel = None,bt_key = None):
        if bt_panel:
            self.__BT_PANEL = bt_panel
            self.__BT_KEY = bt_key
        if (self.__BT_PANEL == 'http://23.248.251.242:8888'):
            self.__BT_NAME = '23.248.251.242'

    #计算MD5
    def __get_md5(self,s):
        m = hashlib.md5()
        m.update(s.encode('utf-8'))
        return m.hexdigest()

    #构造带有签名的关联数组
    def __get_key_data(self):
        now_time = int(time.time())
        p_data = {
                    'request_token':self.__get_md5(str(now_time) + '' + self.__get_md5(self.__BT_KEY)),
                    'request_time':now_time
                 }
        return p_data

    #发送POST请求并保存Cookie
    #@url 被请求的URL地址(必需)
    #@data POST参数，可以是字符串或字典(必需)
    #@timeout 超时时间默认1800秒
    #return string
    def __http_post_cookie(self,url,p_data,timeout=1800):
        cookie_file = '/tmp/' + self.__get_md5(self.__BT_PANEL) + '.cookie';
        if sys.version_info[0] == 2:
            #Python2
            import urllib,urllib2,ssl,cookielib

            #创建cookie对象
            cookie_obj = cookielib.MozillaCookieJar(cookie_file)

            #加载已保存的cookie
            if os.path.exists(cookie_file):cookie_obj.load(cookie_file,ignore_discard=True,ignore_expires=True)

            ssl._create_default_https_context = ssl._create_unverified_context

            data = urllib.urlencode(p_data)
            req = urllib2.Request(url, data)
            opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookie_obj))
            response = opener.open(req,timeout=timeout)

            #保存cookie
            cookie_obj.save(ignore_discard=True, ignore_expires=True)
            return response.read()
        else:
            #Python3
            import urllib.request,ssl,http.cookiejar
            cookie_obj = http.cookiejar.MozillaCookieJar(cookie_file)
            if os.path.isfile(cookie_file):
                cookie_obj.load(cookie_file,ignore_discard=True,ignore_expires=True)
            handler = urllib.request.HTTPCookieProcessor(cookie_obj)
            data = urllib.parse.urlencode(p_data).encode('utf-8')
            req = urllib.request.Request(url, data)
            opener = urllib.request.build_opener(handler)
            response = opener.open(req,timeout = timeout)
            cookie_obj.save(ignore_discard=True, ignore_expires=True)
            result = response.read()
            if type(result) == bytes: result = result.decode('utf-8')
            return result

    def search(self, domain):
        now = datetime.datetime.now()
        str_result = ''
        if (domain != ''):
            site = str(domain).strip()
            search_rslt = self.search_sites(site)
            if (bool(search_rslt['data'])):
                rslt_site = search_rslt['data'][0]['name']
                rslt_siteId = search_rslt['data'][0]['id']
                # print(search_rslt)
                str_result = "%s\t%s" %(rslt_site,rslt_siteId)
                print(str_result)
            else:
                str_result = site
                print(str_result)

    def get_all_sites(self):
        url = self.__BT_PANEL + '/data?action=getData'

        p_data = self.__get_key_data()
        p_data['limit'] = 5000
        p_data['tojs'] = 'get_site_list'
        p_data['table'] = 'sites'

        result = self.__http_post_cookie(url,p_data)
        return json.loads(result)

    # def search_url(self,site):


    def get_file(self,filepath):
        url = self.__BT_PANEL + '/files?action=GetFileBody'
        p_data = self.__get_key_data()
        p_data['path'] = filepath

        try:
            response = self.__http_post_cookie(url,p_data)
            # print(response)
            return json.loads(response)
        except Exception as ex:
            now = datetime.datetime.now()
            str_log = "error: %s %s %s\n" %(now.strftime("%Y/%m/%d, %H:%M:%S"),url,ex)
            print(str_log)

    def save_file(self,filepath,content):
        url = url = self.__BT_PANEL + '/files?action=SaveFileBody'
        p_data = self.__get_key_data()

        p_data['path'] = filepath
        p_data['data'] = content
        p_data['encoding'] = 'utf-8'

        try:
            response = self.__http_post_cookie(url,p_data)
            return response
        except Exception as ex:
            now = datetime.datetime.now()
            str_log = "error: %s %s %s\n" %(now.strftime("%Y/%m/%d, %H:%M:%S"),url,ex)
            print(str_log)


if __name__ == '__main__':
    script,orig_domain,new_domain = sys.argv

    sites = {}
    search_str = str(orig_domain).strip()
    repl_str = str(new_domain).strip()

    if (search_str == "" or repl_str == ""):
        print("域名不可为空!!")
        sys.exit(1)

    bt_tz = bt_api()
    rsp = bt_tz.get_all_sites()

    if bool(rsp['data']):
        for i in rsp['data']:
            ## 获取站点 和 根目录
            sites[i['name']] = i['path']

    if bool(sites):
        for i in sites:
            filepath = '%s/index.html' %sites[i]
            ## 获取 index.html 内容
            content = bt_tz.get_file(filepath)
            if content.get('data') != None:
                search_rs = re.search(search_str,content['data'])
                if search_rs != None:
                    print(i)
                    sub_rs = re.sub(search_str,repl_str,content['data'])
                    save_rs = bt_tz.save_file(filepath,sub_rs)
                    print(json.loads(save_rs))
            else:
                print("%s 没找到 index.html" %i)

