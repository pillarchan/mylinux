# git操作

## 1.全局设置

```
git config --global user.name 'xxx'
git config --global user.email 'xxx@xxx.xxx'
git config --global color.ui true
git config --global core.eol lf
git config --global core.autocrlf input
git config --global core.safecrlf false
```

## 2.git 常用命令

```
git init 初始化当前目录为代码仓库
git status 查看状况
git add <file> 提交文件至暂存区
git rm --cached <file> 删除暂存区文件
git commit -m "comment" 将暂存区的内容提交到本地仓库
```

## 3.删除文件

```
git rm <file> 提交本地仓库后才能执行
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

## 5.文件比对

```
比对是工作目录，暂存区，本地仓库
git diff 比对的是工作目录，暂存区
git diff --cached 比对的是暂存区，本地仓库

```

## 6.查看日志

```
git log 查看所有的日志信息
git log --oneline 一行简单显示所有的日志信息
git log --oneline --decorate    查看当前的指针指向哪个版本
git log -p                      显示每个版本具体的变化内容
git log --oneline -1 -p 		显示最后的一个版本的详细信息
git reflog 查看所有
```

## 7.恢复

```
git reset HEAD <file> 本地仓库内容覆盖到暂存区
git checkout -- <file> 暂存区的内容覆盖到工作目录
git reset --hard hax 通过哈希值回滚
```

## 8.分支

```
git branch 查看分支
git branch name 创建分支
git checkout name 切换分支
git merge name 分支合并 指当前分支去合并其它分支
git branch -d name 删除分支

分支合并流程
创建》切换子分支》修改代码》切换主分支》合并》删除子分支

冲突合并
当不同分支同一文件都有修改提交的动作，则会引起冲突，手动解决，删除不需要的代码再次提交
```

## gitlab

### 1.安装

官网：https://about.gitlab.com 查看文档，对应服务器的系统进行安装即可

```
https://packages.gitlab.com/gitlab/gitlab-ce
cat /etc/gitlab/initial_root_password 
修改配置，重载配置，启动服务
/etc/gitlab/gitlab.rb
gitlab-ctl reconfigure
gitlab-ctl start
```



### 2.创建流程

1. 创建用户组

2. 在用户组中创建项目

3. 服务器设置远程仓库

   ```
   在本地目录下
   git remote add xxxx
   git remote -v 查看
   ```

4. 设置免密登录

   ```
   ssh-keygen 创建公钥，私钥，将公钥复制到对应用户的gitlab界面ssh中
   ```

5. 仓库main/master保护

