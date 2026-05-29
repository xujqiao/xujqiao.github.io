---
title: How is this Blog Set Up
date: 2015-11-30 21:01:56
tags:
  - blog
categories:
  - Tells you how to do
---

# 准备工作

## Github

Github是一个神器。Github是Git的一个应用，算是一个远程仓库管理系统，只不过很有名，全世界范围类的程序员都在上面分享自己或者他人的开源系统。仓库类型有两种，一种是Public，中文可以翻译成公有仓库，另一叫Private，私有仓库。普通用户只能创建公有仓库，私有仓库需要人民币。Github提供了一个叫做Github Pages的东西，可以用域名访问你的公有仓库，所以如果你的仓库里是HTML等文件，那么就是网站了，是不是很帅！！当然，也没这么多好事，显然这种网站是静态的，动态网站无法完成。

所以，你首先需要的就是一个Github帐号。注册的时候，需要你填写一个叫做用户名的东西，这个算是标识你的代码仓库的标识符，而且也会被用到Github Pages中，所以尽量取得心满意足一点吧。这里用username表示你申请的用户名。当你完成Github帐号的注册时候，就可以访问这个地址了`https://github.com/username`。

<!-- more -->

```
https://github.com/
```

## Git

Git，不同于Github，前者是一个版本管理系统，而后者代码仓库管理系统+网站。Git是个软件，下载下来安装到电脑上，最好不要用Git-gui这种，虽然图形界面好看，但是不利于学习Git这个神器。访问下面的网址，从头认识Git

```
http://git-scm.com/book/zh/v1/%E8%B5%B7%E6%AD%A5-%E5%85%B3%E4%BA%8E%E7%89%88%E6%9C%AC%E6%8E%A7%E5%88%B6
```

## NodeJs

Nodejs，熟悉js的人应该都知道，这个是用js写后台的东西，js本身是前台语言，但有了Nodejs之后，js也可以用来写后台了。好吧，我也是第一次接触这个，直接安装就好

```
https://nodejs.org/en/
```

## Hexo

Hexo是一个静态文章生成系统，如果你了解或者熟悉Jekll的话，Hexo应该很容易上手。那么问题来了，为什么我不用Jekll，一、我不会Ruby，虽然我知道Ruby很厉害；二、曾经接触过别人用Rail写好的网站源码，我负责维护，结果给我弄出问题了，Ruby的使用要为此新建一个用户，运行还要在该用户下执行类似安装的命令，其他用户如果想运行，也要执行一下，我觉得好烦。正好Hexo不用Ruby，好吧，我发现NodeJs也挺坑的，装里面的插件装得我头疼，也跟我在学校用校园网有关吧

```
https://hexo.io/
```

# 正式开始

## 本地工作

选择一个本地地址，新建一个文件夹并命名，如`E:\Project\blog`，打开Git Shell，进入这个路径

```
hexo init
npm install
```

安装Hexo插件

```
npm install hexo-generator-index --save
npm install hexo-generator-archive --save
npm install hexo-generator-category --save
npm install hexo-generator-tag --save
npm install hexo-server --save
npm install hexo-deployer-git --save
npm install hexo-deployer-heroku --save
npm install hexo-deployer-rsync --save
npm install hexo-deployer-openshift --save
npm install hexo-renderer-marked@0.2 --save
npm install hexo-renderer-stylus@0.2 --save
npm install hexo-generator-feed@1 --save
npm install hexo-generator-sitemap@1 --save
```

Hexo命令

```
hexo new post "post name"
hexo server    #本地查看效果
hexo generate  #生成静态文件，即public/文件夹
```

## 远程仓库

在你自己的`https://github.com/username`中创建一个仓库，名称为`username.github.io`，包括**.**，只要把你的用户名替换前面的username即可。

仓库地址：`https://github.com/username/username.github.io`

## 上传

还是在Git Shell中，切换到之前新建的文件夹路径中，即`E:\Project\blog`

```
hexo generate                     #生成博客静态文件
cd public/                        #切换到生成的文件夹
git init                          #在此文件夹下创建git本地仓库
git remote add origin https://github.com/username/username.github.io    #添加远程仓库地址
git add .                         #添加文件
git commit -m "messge"            #提交
git push -u origin master         #上传
```

到此为止，你的blog已经初步建成，可以访问这个网址赖访问你的Blog，`http://username.github.io`。接下来的操作可以参考Heox的官方文档，以及你使用的Hexo的主题的文档，前提是开发者有写

---

# 额外

## 自定义域名

如果你想用自己的域名来访问你的Github Pages，那么你可以往下看

1. 购买域名

2. 在你的仓库地址`https://github.com/username/username.github.io/`下新建一个文件`CNAME`，接着在里面写上你购买的域名，不用加`http`或`https`，文件内容也只有一行

   `domain.com`

3. 在你购买域名的网站里，添加DNS记录，类型是`CNAME`

   | 主机记录 | 记录类型 | 记录值              | MX优先级 | TTL |
   |----------|----------|---------------------|----------|-----|
   | @        | CNAME    | username.github.io  | -        | TTL |
   | www      | CNAME    | username.github.io  | -        | TTL |

# 推荐参考

- [使用GitHub和Hexo搭建免费静态Blog](http://wsgzao.github.io/post/hexo-guide/)
- [hexo你的博客](http://ibruce.info/2013/11/22/hexo-your-blog/)
- [Hexo性感的主题-NexT](http://theme-next.iissnan.com/)
