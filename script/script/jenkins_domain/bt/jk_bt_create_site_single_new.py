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
        cookie_file = '/opt/script/jenkins_domain/bt/' + self.__get_md5(self.__BT_PANEL) + '.cookie';
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

    def search_sites(self, search_str):
        url = self.__BT_PANEL + '/data?action=getData'

        p_data = self.__get_key_data()
        p_data['limit'] = 1000
        p_data['table'] = 'sites'
        #p_data['tojs'] = 'get_site_list'
        p_data['search'] = search_str

        result = self.__http_post_cookie(url,p_data)
        return json.loads(result)

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
                str_result = "%s %s" %(rslt_site,rslt_siteId)
                print(str_result)
            else:
                str_result = site
                print(str_result)


    def create_site(self, site):
        """create a single site"""
        url = self.__BT_PANEL + '/site?action=AddSite'
        p_data = self.__get_key_data()

        webname = {}
        webname['domain'] = str(site).strip()
        webname['domainlist'] = ["www.%s" %webname['domain']]
        webname['count'] = 0
        path = '/www/wwwroot/%s' %site

        p_data['webname'] = json.dumps(webname)
        p_data['path'] = path
        p_data['type_id'] = 0
        p_data['type'] = '静态'
        p_data['version'] = ''
        p_data['port'] = 80
        p_data['ps'] = ''
        p_data['ftp'] = 'false'
        p_data['sql'] = 'false'

        # print(p_data)
        # jsondata = json.load(p_data)

        try:
            response = self.__http_post_cookie(url,p_data)
            # return response
            return json.loads(response)
        except Exception as ex:
            now = datetime.datetime.now()
            str_log = "error: %s %s %s\n" %(now.strftime("%Y/%m/%d, %H:%M:%S"),url,ex)
            print(str_log)

        # response = {"siteStatus": 'true', "siteId": 734, "ftpStatus": 'false', "databaseStatus": 'false'}


    def get_file(self,filepath):
        url = self.__BT_PANEL + '/files?action=GetFileBody'
        p_data = self.__get_key_data()
        p_data['path'] = filepath

        try:
            response = self.__http_post_cookie(url,p_data)
            print(response)
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
            return json.loads(response)
        except Exception as ex:
            now = datetime.datetime.now()
            str_log = "error: %s %s %s\n" %(now.strftime("%Y/%m/%d, %H:%M:%S"),url,ex)
            print(str_log)


    def create_site_single(self,domain,upm,pid,sid):
        now = datetime.datetime.now()
        success_sites = {}
        str_result = {}
        site = str(domain).strip()

        if (site != ''):
            add_result = self.create_site(site)
            str_result[site] = {}

            upm = str(upm).strip()
            pid = str(pid).strip()
            sid = str(sid).strip()

            if add_result.get('siteStatus') != None:
                if (add_result['siteStatus'] == True):
                    str_result[site]['创建成功'] = add_result['siteId']
                    success_sites[site] = add_result['siteId']
                    str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                    print(str_log)

                    ### 修改 跳转 URL
                    file = c_file()
                    data = file.set_index_html_new('/opt/script/jenkins_domain/bt/index_new.html',upm,pid,sid)
                    path = '/www/wwwroot/%s/index.html' %site
                    sav_result = self.save_file(path,data)
                    str_result[site] = "index.html修改:  %s" %sav_result 
                    str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                    print(str_log)

                else:
                    str_result[site]['error'] = "%s" %add_result
                    sys.exit(1)
            else:
                str_result[site]['创建失败'] = '%s' %add_result
                str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                print(str_log)
                sys.exit(1)

        ## 申请证书
        if bool(success_sites):
            for site in success_sites:
                now = datetime.datetime.now()
                str_result = {}

                ssl_result = self.apply_cert(site,success_sites[site])
                str_result[site] = "证书申请: %s" %ssl_result
                str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                #print(str_log)

                if ssl_result != None:
                    if (ssl_result['status'] == True):
                        str_result[site] = "申请证书成功"
                        str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                        print(str_log)

                        ## 保存证书
                        #time.sleep(2)
                        now = datetime.datetime.now()
                        key = ssl_result['private_key']
                        src  = ssl_result['cert'] + ssl_result['root']
                        set_ssl_rsp = self.set_ssl(site,key,src)
                        str_result[site] = set_ssl_rsp
                        str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                        print(str_log)

                        ## 强制 https
                        #time.sleep(2)
                        set_https_rsp = self.set_to_https(site)
                        now = datetime.datetime.now()
                        str_result[site] = "set_http_to_https: %s" %set_https_rsp
                        str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                        print(str_log)

                        ## 修改 跳转 URL
                        #time.sleep(2)
                        # upm = str(upm).strip()
                        # pid = str(pid).strip()
                        # sid = str(sid).strip()
                        #file = c_file()
                        #data = file.set_index_html_new('/opt/script/jenkins_domain/bt/index_new.html',upm,pid,sid)
                        #path = '/www/wwwroot/%s/index.html' %site
                        #sav_result = self.save_file(path,data)
                        #str_result[site] = "修改跳转URL: %s" %sav_result
                        #str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                        #print(str_log)

                    else:
                        print(str_log)
                        sys.exit(1)
                else:
                    print(str_log)
                    sys.exit(1)

    def set_to_https(self,site):
        url = self.__BT_PANEL + '/site?action=HttpToHttps'
        p_data = self.__get_key_data()
        p_data['siteName'] = site

        try:
            response = self.__http_post_cookie(url,p_data)
            return json.loads(response)
        except Exception as ex:
            now = datetime.datetime.now()
            str_log = "error: %s %s %s\n" %(now.strftime("%Y/%m/%d, %H:%M:%S"),url,ex)
            print(str_log)

    ## 已创建的站点 修改index.html跳转连接
    def replace_index_html(self,domain,upm,pid,sid):
        """sitelist is a dict {site: URL}"""
        now = datetime.datetime.now()
        str_result = {}
        site = str(domain).strip()

        if (site != ''):
            str_result[site] = {}            
            upm = str(upm).strip()
            pid = str(pid).strip()
            sid = str(sid).strip()
            ##更改index.html连接
            file = c_file()
            data = file.set_index_html_new('/opt/script/jenkins_domain/bt/index_new.html',upm,pid,sid)
            ## 保存到bt
            path = '/www/wwwroot/%s/index.html' %site
            sav_result = self.save_file(path,data)

            #if '"status": true' in sav_result:
            #    str_result[site]['modified'] = "成功"
            #    str_result[site]['path'] = "%s %s" %(path,URL)
            #else:
            #    str_result[site]['modified'] = "失败"
            #    str_result[site]['error'] = "%s" %(sav_result)
            #    str_result[site]['debug'] = "%s %s" %(path,URL)

            str_result[site] = "%s" %(sav_result)
            str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
            # logging.info(str_log)
            print(str_log)

    def apply_cert(self,site,siteId):
        # test rted.cc
        # LetsEncrypt
        url = self.__BT_PANEL + '/acme?action=apply_cert_api'
        www = "www.%s" %site
        domains = []
        domains.append(site)
        domains.append(www)

        p_data = self.__get_key_data()
        p_data['domains'] = json.dumps(domains)
        p_data['auth_type'] = "http"
        p_data['auth_to'] = siteId
        p_data['auto_wildcard'] = 0
        p_data['id'] = siteId
        # print(p_data)

        try:
            response = self.__http_post_cookie(url,p_data)
            return json.loads(response)
        except Exception as ex:
            now = datetime.datetime.now()
            str_log = "error: %s %s %s\n" %(now.strftime("%Y/%m/%d, %H:%M:%S"),url,ex)
            print(str_log)

    def only_apply_cert(self,domain,siteId):
        """ {site: siteId}"""

        now = datetime.datetime.now()
        str_result = {}
        site = str(domain).strip()
        if (site != ''):
            str_result = {}

            ssl_result = self.apply_cert(site,siteId)
            str_result[site] = ssl_result
            str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
            print(str_log)

            if ssl_result != None:
                if (ssl_result['status'] == True):
                    ## set ssl
                    time.sleep(2)
                    now = datetime.datetime.now()
                    key = ssl_result['private_key']
                    src  = ssl_result['cert'] + ssl_result['root']
                    set_ssl_rsp = self.set_ssl(site,key,src)
                    str_result[site] = set_ssl_rsp
                    str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                    print(str_log)
                    ## http to https
                    time.sleep(2)
                    set_https_rsp = self.set_to_https(site)
                    now = datetime.datetime.now()
                    str_result[site] = "set_http_to_https: %s" %set_https_rsp
                    str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
                    print(str_log)
                else:
                    sys.exit(1)
            else:
                sys.exit(1)
        else:
            print('域名不能为空')
            sys.exit(1)

    def set_ssl(self,site,key,csr):
        url = self.__BT_PANEL + '/site?action=SetSSL'

        p_data = self.__get_key_data()
        p_data['type'] = 1
        p_data['siteName'] = site
        p_data['key'] = key
        p_data['csr'] = csr

        try:
            response = self.__http_post_cookie(url,p_data)
            return json.loads(response)
        except Exception as ex:
            now = datetime.datetime.now()
            str_log = "error: %s %s %s\n" %(now.strftime("%Y/%m/%d, %H:%M:%S"),url,ex)
            print(str_log)

    def only_create_site(self,domain,upm,pid,sid):
        now = datetime.datetime.now()
        success_sites = {}
        str_result = {}
        site = str(domain).strip()
        if (site != ''):
            add_result = self.create_site(site)
            str_result[site] = {}
            if add_result.get('siteStatus') != None:
                if (add_result['siteStatus'] == True):
                    str_result[site]['id'] = add_result['siteId']
                    success_sites[site] = add_result['siteId']

                    upm = str(upm).strip()
                    pid = str(pid).strip()
                    sid = str(sid).strip()
                    ##更改index.html连接
                    file = c_file()
                    data = file.set_index_html_new('/opt/script/jenkins_domain/bt/index_new.html',upm,pid,sid)
                    ## 保存到bt
                    path = path = '/www/wwwroot/%s/index.html' %site
                    sav_result = self.save_file(path,data)

                    str_result[site]["index.html修改"] = sav_result

                else:
                    str_result[site]['error'] = "%s" %add_result
            else:
                str_result[site]['error'] = '%s' %add_result

            str_log = "%s %s" %(now.strftime("%Y/%m/%d, %H:%M:%S"),str_result)
            # logging.info(str_log)
            print(str_log)



class c_file:

    def read_xlsx(self,exlfile):
        """ read every row A and B values into a dict """

        self.wb = load_workbook(exlfile)
        ws = self.wb.worksheets[0]
        #delete title row
        ws.delete_rows(0)

        p_dict = {}
        for row in ws.values:
            p_dict[row[0]] = row[1]

        return p_dict

    def set_index_html(self,f_index,URL):

        f = open(f_index, 'r')
        html_content = f.read()
        f.close()

        str_repl = "window.location.href = '%s'" %str(URL).strip()
        replaced = re.sub('window\.location\.href.*',str_repl,html_content)

        return replaced

    def set_index_html_new(self,f_index,upm,pid,sid):
        ##https://${randomStr(12)}.${domain}:60443/jpm?upm=用户id&pid=推广路径&sid=1001
        ## read file index.html
        f = open(f_index, 'r')
        html_content = f.read()
        f.close()
        ## replace rewrite_url
        upm = str(upm).strip()
        pid = str(pid).strip()
        sid = str(sid).strip()
        str_repl="upm=%s&pid=%s&sid=%s`" %(upm,pid,sid)

        replaced = re.sub('upm.*',str_repl,html_content)
        return replaced


if __name__ == '__main__':
    script,domain,action,upm,pid,sid = sys.argv

    str_domain = str(domain).strip()
    str_action = str(action).strip()
    str_upm = str(upm).strip()
    str_pid = str(pid).strip()
    str_sid = str(sid).strip()

    bt_tz = bt_api()

    if str_action == 'create_site':
        bt_tz.create_site_single(str_domain,str_upm,str_pid,str_sid)
    elif str_action == 'only_create_site':
        bt_tz.only_create_site(str_domain,str_upm,str_pid,str_sid)
    elif  str_action == 'search':
        bt_tz.search(str_domain)
    elif  str_action == 'apply_cert':
        bt_tz.only_apply_cert(str_domain,str_upm,str_pid,str_sid)
    elif  str_action == 'replace_URL':
        bt_tz.replace_index_html(str_domain,str_upm,str_pid,str_sid)
    else:
        print('操作不存在')