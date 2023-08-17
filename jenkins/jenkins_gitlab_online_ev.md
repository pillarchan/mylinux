# jenkins gitlab 线上发布

开发完成后，打tag

jenkins要通参数化构建

打标签命令

```
git tag -a 版本名 -m "描述"
git show 版本名       查看信息
git tag -a 版本名 hash值 -m "描述"    给早期版本打标签

git push -u origin 版本名   将打好的标签版本进行推送
```

