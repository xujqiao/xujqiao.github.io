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

---

# 2026年5月29日 更新：迁移到 GitHub Actions 自动部署

原来的部署方式是手动 `hexo generate` 后把 `public/` 目录推送到 GitHub，每次写文章都要重复这个流程。而且远程仓库只存了构建产物（HTML/CSS/JS），源码没有版本管理，换电脑就没了。这次迁移把源码和自动部署都解决了。

## 新的仓库结构

之前仓库里只有 `public/` 的构建产物，现在改成**存源码**，让 GitHub Actions 自动构建部署：

```
blog/
├── _config.yml              # 主配置
├── package.json             # 依赖声明
├── package-lock.json        # 依赖锁定
├── .gitignore               # 排除 node_modules/、public/ 等
├── .github/
│   └── workflows/
│       └── deploy.yml        # Actions 自动构建配置
├── scaffolds/               # 文章模板
├── source/                  # 文章和页面
│   ├── _posts/              # .md 文章 + 资产文件夹
│   ├── about/
│   ├── tags/
│   └── categories/
└── themes/
    └── next/                # NexT 主题
```

**不需要上传的**（`.gitignore` 自动排除）：`node_modules/`、`public/`、`db.json`、`.deploy_git/`

## GitHub Actions 工作流

在 `.github/workflows/deploy.yml` 中配置自动构建：

```yaml
name: Deploy Hexo to GitHub Pages

on:
  push:
    branches:
      - master

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm

      - name: Install dependencies
        run: npm install

      - name: Generate static files
        run: npx hexo clean && npx hexo generate

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

原理很简单：GitHub 提供一台 Linux 服务器，帮你执行 `npm install` → `hexo generate` → 部署，跟在本地终端操作一模一样。构建进度在仓库的 **Actions** 页面可以实时查看。

## 配置步骤

1. **GitHub Pages 设置**：进入仓库 Settings → Pages，Source 改为 **GitHub Actions**（不再是 Deploy from a branch）

2. **推送源码**：把整个 `blog/` 目录推送到 `master` 分支

3. **以后写文章**：

```bash
hexo new post "文章标题"
# 编辑文章...
git add -A
git commit -m "新文章"
git push origin master
```

推送后 Actions 自动构建部署，1-2 分钟后网站更新。

## 踩坑记录

### themes/next 的 submodule 陷阱

NexT 主题是通过 `git clone` 安装的，目录下自带 `.git`，导致 git 把它当 submodule 处理——推送到远程后只有一个指针，没有实际文件。Actions 构建时找不到主题，页面白屏。

**解决方法**：删掉主题目录下的 `.git`，重新 `git add`：

```bash
rm -rf themes/next/.git
git rm --cached themes/next
git add themes/next/
```

### hexo deploy 不会删除远程旧文件

`hexo deploy` 是增量推送，不会删除 `.deploy_git/` 里远程已有的多余文件（比如旧站的 `vendors/`）。如果需要完全覆盖远程仓库，直接把 `public/` 初始化为新的 git 仓库并强制推送：

```bash
cd public
git init
git add -A
git commit -m "Rebuild"
git push -f origin HEAD:master
```

### 封面图在首页不显示

文章中引用图片用相对路径 `src="cover.jpg"`，文章页没问题，但首页 URL 是根路径 `/`，浏览器会把图片解析成 `/cover.jpg` → 404。

**解决方法**：用 Hexo 的 `asset_path` 标签生成绝对路径：

```html
<img src="{% asset_path cover.jpg %}" />
```

### 首页全文显示，没有"阅读全文"按钮

Hexo 需要在文章中插入 `<!-- more -->` 分隔符，首页才会截断显示并出现"阅读全文"按钮。
