---
title: "Listen! It's not our server name"
date: 2025-06-01 10:06:00
categories:
  - 技术
tags:
  - "Nginx"
  - "运维"
---

# Listen! It's not our server name

> 最近在修改某台机器的Nginx配置时，对一段习以为常的配置产生了疑问。
> 配置文件如下，疑问有两个，1. 为什么nginx监听的不是`192.168.0.12:80`; 2. server_name配置项的作用是什么


```nginx
server {
	listen 80;
	server_name 192.168.0.12;
	....
}
```
```bash
sudo netstat -antpl | grep 80
tcp        0      0 0.0.0.0:80         0.0.0.0:*               LISTEN      1408/nginx: master  
```

<!-- more -->

带着这两个疑问，查找了nginx官方文档中相关配置的解释[server_name][server_name]，[listen][listen]，加上自己的实验，发现真正的结果是这样的



1. `listen`
`listen`用于将nginx绑定到指定的端口上，其格式为`listen [host:]port`。
如果不指定`host`，则`nginx`的默认监听`ip`是`0.0.0.0`，即机器的所有网卡
只有指定了相应的ip，才会监听特定网卡的特定端口

2. `server_name`
`server_name`是工作在应用层的配置项，用于检查请求的HTTP报文中Host字段对应的值是否与配置项匹配。
如果`listen匹配`且`server_name也匹配`，则请求被此部分server块步骤
如果`listen匹配`但`server_name不匹配`，则寻找其他监听list配置匹配的server块
如果`listen匹配的server块有多个`，则使用`nginx.conf`文件中物理顺序在最前面的server块（也可以手动在·listen配置项·的最后添加·default·字样，指定默认server块）
如果只有一个，则无论`server_name是否匹配`，都使用该server块


下面是一些实验

```nginx
# server_1
server {
    listen  10.0.2.15:10008;
    server_name example.com;

    location / { 
        echo "example.com";
    }   
}   
# server_2
server {
    listen  10.0.2.15:10008 default;
    server_name example.net;

    location / { 
        echo "example.net";
    }   
}   

# server_3
server {
    listen 10008;
    location / { 
        echo "whole interfaces";
    }   
}     
```

```bash

tcp        0      0 0.0.0.0:10008           0.0.0.0:*               LISTEN      1584/nginx: master  

1. 请求127.0.0.1:10008，命中server_3
curl "http://127.0.0.1:10008"
> whole interfaces


2. 请求10.0.2.15:10008，命中server_2，如果没有default，将命中server_1
curl "http://10.0.2.15:10008"
> example.net

在hosts中添加
10.0.2.15 example.net
10.0.2.15 example.com
10.0.2.15 example.cn

3. 请求example.com:10008，命中server_1
curl "http://example.com:10008"
> example.com

4. 请求example.net:10008，命中server_2
curl "http://example.net:10008"
> example.net

5. 请求example.cn:10008，命中server_2
curl "http://example.cn:10008"
> example.net
```









[server_name]: http://nginx.org/en/docs/http/server_names.html "server_name"
[listen]: http://nginx.org/en/docs/http/ngx_http_core_module.html#listen "listen"
