'''
from bs4 import BeautifulSoup
import requests
# 请求页面
response = requests.get("https://www.meiguodizhi.com/")

print(response)
# 解析 HTML 内容
soup = BeautifulSoup(response.content, "html.parser")

# 查找元素
input_element = soup.find("input", class_="boder-none data_Full_Name")

# 获取 value 值
#value = input_element["value"]
print("1")
print(input_element)
'''
from selenium import webdriver
from selenium.webdriver.common.by import By
driver = webdriver.Chrome()
url="https://www.meiguodizhi.com/"
driver.get(url)
driver.implicitly_wait(10)
# 查找所有 div 元素
inputs = driver.find_elements(By.TAG_NAME,"input")

# 查找第一个 class 为 "my-class" 的 div 元素
myinput = driver.find_element(By.XPATH,"//input[@class='boder-none data_Full_Name']")


# 获取 div 元素的 id 属性
myInputValue = myinput.get_attribute("value")
print(1,inputs)
print(myinput)

print(myInputValue)


