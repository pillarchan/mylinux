# git命令

## 1.全局设置

```
git config --global user.name 'xxx'
git config --global user.email 'xxx@xxx.xxx'
git config --global color.ui true
git config --global core.eol lf
git config --global core.autocrlf input
git config --global core.safecrlf true
```

## 2.git 常用命令

```
git init 初始化当前目录为代码仓库
git status 查看状况
git add <file> 提交文件至暂存区
git rm --cached <file> 删除暂存区文件
git commit -m "comment" 将暂存区的内容提交到本地仓库
git checkout -- <file> 暂存区的内容覆盖到工作目录
```

## 3.删除文件

```
git rm <file>
git add .
git commit -m'comment'


git rm -rf test2.txt		    #　同时删除工作目录和暂存区的内容　前提是没有提交到本地仓库
```

## 4.文件改名

```
git mv oldname.file newname.file
git add .
git commit -m'rename'
```

