---
title: "自主构建docker镜像"
date: 2025-06-01 10:02:00
categories:
  - 技术
tags:
  - "Docker"
  - "镜像构建"
---

# 自主构建docker镜像

[TOC]

> 组里提倡docker化部署服务，由于公司内机器都是xxx，因此转到docker上本能拉取一段xxx的镜像。结果，xxx镜像居然高达1G！心想，在其之上再部署自己的服务，导出的镜像岂不肯定大于1G！虽然内网速度快，还是觉得镜像太大了。
> 
> 这次想docker化的服务是squid，hub上最新的版本是3.5，而squid最新版已经到4.10。并且，3.5版本的docker化squid的镜像【[sameersbn/squid](https://hub.docker.com/r/sameersbn/squid/)】只有45M，容量并不大。
> 
> 因此，为了能用上最新版squid，又不想在1G的xxx上部署，于是萌生自己构建镜像，且越小越好

<!-- more -->

## 容器中编译

### 基础镜像选择

构建镜像的过程，需要一个基础镜像，就是Dockerfile中`from`关键字后面的内容

基于前期对docker化3.5版本的squid软件镜像大小的查看，如果想构建一个最小化的docker镜像，在xxx这种大容量的镜像基础上再构建的方法肯定是不行的。docker基于层，不同层的容量会叠加，所以最终的镜像大小肯定会更大，从而放弃了这种方法

既然xxx镜像太大，那如果换个小一点的镜像，构建的整体镜像应该会比较小。并且，如果docker有一个空镜像，那构建出的镜像应该更小。

通过网上查阅，发现有两种选择

1. 空镜像——【[scratch](https://hub.docker.com/_/scratch)】

scratch是docker的空镜像，这种镜像大小几乎为0。优点是完全按照自己的想法构建，环境啊、软件啊可以自己添补。缺点是，对新手不友好，没有最基本的linux环境都没有，刚上手有点懵。

2. 简化过的镜像——【[alpine](https://hub.docker.com/_/alpine)】

alpine 操作系统是一个面向安全的轻型 Linux 发行版。它不同于通常 Linux 发行版，Alpine 采用了 musl libc 和 busybox 以减小系统的体积和运行时资源消耗，但功能上比 busybox 又完善的多，因此得到开源社区越来越多的青睐。在保持瘦身的同时，Alpine 还提供了自己的包管理工具 apk，可以通过 https://pkgs.alpinelinux.org/packages 网站上查询包信息，也可以直接通过 apk 命令直接查询和安装各种软件。摘自[链接](https://yeasy.gitbooks.io/docker_practice/cases/os/alpine.html)

尝试加斟酌再三，选择了alpine，对新手比较友好，后期对docker更熟悉了，可以尝试scratch


### 实操

1. 基础镜像拉取

```bash
docker pull alpine:latest
docker image ls

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
alpine              latest              a187dde48cd2        4 days ago          5.6MB
# 容量真小
```

2. squid最新版源码下载

```bash
wget -c http://www.squid-cache.org/Versions/v4/squid-4.10.tar.gz
```

3. 编译安装

依赖的编译环境，可以依据configure的结果进行安装

```bash
# 容器外，将squid-4.10复制到容器内
docker cp squid-4.10.tar.gz container:/tmp
# 容器内，编译安装
apk add gcc g++ perl make
tar -xf /tmp/squid-4.10.tar.gz
cd /tmp/squid-4.10
./configure --prefix=/usr/local/squid
make -j8
make install
```

4. 编译环境瘦身

我是用的方法很简单，每删除一个环境，就尝试下软件能否正常运行。如果可以，则删除下一个环境，如果不行，则安装回来

经过我的测试，`perl`和`make`，在软件运行时可以不用

```bash
apk del perl make
```

5. 完善功能

。。。


## dockerfile撰写

至此，自主编译瘦身版squid的docker镜像就完成了，通过命令`docker export -o squid-4.10_alpine.tar 容器ID`导出容器，发现只有268M，和基于xxxx的1G+相比，符合预期

为了更简洁的构建镜像，可以将上述过程编写成dockerfile，这样下次就可以让docker自动化生成镜像

### dockerfile内容

```dockerfile
FROM alpine:latest

LABEL maintainer="xujqiao"

RUN mkdir -p /usr/src/squid
WORKDIR /usr/src/squid
COPY squid-4.10.tar.gz /root/

RUN buildDeps='gcc g++ make perl' \
    removeDeps='make perl' \
    && apk update \
    && apk add $buildDeps \
    && rm /usr/src/squid/* -rf \
    && tar -xzf /root/squid-4.10.tar.gz -C /usr/src/squid --strip-components=1 \
    && ./configure --prefix=/usr/local/squid \
    && find ./ -type f -name "Makefile" -print0 | xargs -0 sed -i 's#-g ##g' \
    && make -j8 \
    && make install \
    && rm /root/squid-4.10.tar.gz -f \
    && rm /usr/src/squid -rf \
    && rm /var/lib/apt/lists/* -rf \
    && apk del $removeDeps

EXPOSE 3128/tcp

CMD ["/usr/local/squid/sbin/squid","-N"]
```

* **chmod 777 -R /usr/local/squid/var/logs**

不添加这条命令，会出现**permission denied**

* **["/usr/local/squid/sbin/squid","-N"]**

命令一定要运行在前台模式，不可以后台！不可以后台！不可以后台！

（坑的我都没吃午饭）

* **启动命令，宿主目录权限需要调整**

由于需要将docker中的log映射到宿主机，因此宿主机映射的目录的权限需要调整

```bash
# 宿主目录的权限需要调整
mkdir -p /var/log/squid && chmod 777 /var/log/squid

docker run \
    -d -it \
    -p 3128:3128 \ # 映射端口
    -v /var/log/squid:/usr/local/squid/var/logs \ # 映射目录，目录权限需要调整
    -v /etc/localtime:/etc/localtime:ro \ # 解决容器时间与宿主相差8小时
    --name mysquid \ # 容器名称
    --user root \ # 指定用户运行命令
    --restart always \ # 自动拉起
    squid
```

### 构建建议

1. dockerfile的命令

dockerfile的命令尽可能一行写完，尤其涉及到删除

因为docker采用unionfs，下一层的删除操作类似db里的逻辑删除，上一层的大小未改变，从而使得构建的镜像大小没有因为删除而变小

2. 源码下载

可以把`copy squid-4.10.tar.gz /root/`替换成wget

但需要注意后续`./configure`时的生成的`makefile`文件会存储在**相对目录**下，而不是源码的目录

## 后续

1. 镜像大小探究

使用`docker history 镜像id`，查看镜像的大小细节，发现编译那部分产生了257M的内容。

而上文提供到的45Msquid容器，从其dockerfile查看，就是在ubuntu中使用apt-get命令安装了squid-3.5.27

应该是gcc和g++中大部分库在squid运行时并不需要

```bash
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
a35479277152        52 seconds ago      /bin/sh -c #(nop)  CMD ["/usr/local/squid/sb…   0B                  
a2bb67dd85bc        53 seconds ago      /bin/sh -c #(nop)  EXPOSE 31181/tcp             0B                  
96451ca69933        53 seconds ago      /bin/sh -c #(nop) COPY file:4d43ec7416664969…   47B                 
ab3227594a80        54 seconds ago      /bin/sh -c #(nop) COPY file:d32f18fc579a18e4…   4.07kB              
6a56fc64ab53        56 seconds ago      /bin/sh -c #(nop) WORKDIR /                     0B                  
d7bca7ff37fa        56 seconds ago      /bin/sh -c buildDeps='gcc g++ make perl'    …   257MB               
7127d431988c        6 minutes ago       /bin/sh -c #(nop) COPY file:574d46e3a19aded6…   5.26MB              
d39bbebdb873        6 minutes ago       /bin/sh -c #(nop) WORKDIR /usr/src/squid        0B                  
104c50f963d0        6 minutes ago       /bin/sh -c mkdir -p /usr/src/squid              0B                  
24fa51c3c8b7        6 minutes ago       /bin/sh -c #(nop)  LABEL maintainer=xujqiao     0B                  
1246495ec59e        6 minutes ago       /bin/sh -c #(nop)  ENV no_proxy=.oa.com         0B                  
5f3a3a0c5d03        6 minutes ago       /bin/sh -c #(nop)  ENV https_proxy=http://de…   0B                  
7c6abe6257fb        6 minutes ago       /bin/sh -c #(nop)  ENV http_proxy=http://dev…   0B                  
a187dde48cd2        4 days ago          /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B                  
<missing>           4 days ago          /bin/sh -c #(nop) ADD file:0c4555f363c2672e3…   5.6MB
```


2. 镜像大小再探究

后续进入在容器里发现，`/usr/local/squid/sbin/squid`居然高达**76M**！C/C++编写的软件，编译出来的可执行程序竟然这么大！应该是Makefile中开启了`-g`这种选项，应该是configure是没有开启优化的选项

查看squid的Makefile，都出现了-g。尝试了一些configure的选项，并未成功把这个选项去重。从而手动把源码中Makefile里-g选项删除，重新编译发现可执行文件只有11M

```bash

find /root/ -type f -name "Makefile" -print0 | xargs -0 sed -i 's#-g ##g'

ll -h squid 
-rwxr-xr-x 1 xujqiao users 11M Mar 28 16:35 squid
```
