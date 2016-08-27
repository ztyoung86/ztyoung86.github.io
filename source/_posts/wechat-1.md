---
title: 使用 Flask 开发微信公众号（1）：开发基础
date: 2016-08-27 12:03:42
description:
categories: 瞎折腾
tags:
 - Flask
 - Python
 - 微信公众号
---

很早就想开一个自己的公众号，在上面写（zhuang）文（zhuang）章（bi），顺便实现一些有趣的功能。但一开始发现涉及的技术还蛮多，想着再多了解一下相关技术在开始也好，免得浪费太多时间影响积极性（呵呵），于是最后拖了好久根本没有开始……

最近在[实验楼](https://www.shiyanlou.com/)上面看到了这个课程——[基于 Flask 及爬虫实现微信娱乐机器人](https://www.shiyanlou.com/courses/581)，于是恰好跟着里面把步骤过一下。

这篇文章其实是第一节的课程报告，不会有太多细节（这一部分可以直接去参考课程文档），当是自己的一个记录吧。

<!-- more -->

当然，我自己对微信公众号的开发应该不会止于三节课的内容吧（但愿），之后的内容应该会写的详细些，那时之后的事情了……

----

## 服务器配置
### 1. VPS
直接使用的 [DigitalOcean](https://www.digitalocean.com/) 的 VPS，通过[我的邀请码](https://m.do.co/c/bf02a827348c)注册可获得 10 美元（可免费使用最低配2个月，一般测试小项目，搭个 shadow socks 够用了），我使用的是最低配的 ubuntu-12.04-LTS，具体教程不写了，网上有很多。

### 2. Flask  服务挂起
使用 nginx + uWSGI + flask 的架构，参考[Flask 官方文档](http://flask.pocoo.org/docs/0.11/deploying/uwsgi/)（中文版点[这里](http://docs.jinkan.org/docs/flask/deploying/uwsgi.html)）。遇到一些问题，主要还是因为对 nginx 和 uWSGI 不够熟悉，google + 官方文档基本能够解决。

这里分享一下几个关键的配置文件吧：

1.`wechat_nginx.conf`

```nginx
# the upstream component nginx needs to connect to
upstream flask {
    server unix:////var/run/wechat_uwsgi.sock; # for a file socket
}

server {
    listen 80;
    server_name {your-host-IP};
    access_log /var/log/nginx/wechat.access.log;
    error_log /var/log/nginx/wechat.error.log;
    charset     utf-8;

    # max upload size
    client_max_body_size 75M;   # adjust to taste

    #location /media  {
    #    alias /path/to/your/mysite/media;  # your project's media files - amend as required
    #}

    #location /static {
    #    alias /path/to/your/mysite/static; # your project's static files - amend as required
    #}

    location / { try_files $uri @wechat; }
    location /wechat { try_files $uri @wechat; }
    location @wechat {
        include uwsgi_params;
        uwsgi_pass flask;
    }
}
```

2.`wechat_uwsgi.ini`

```ini
# wechat_uwsgi.ini file
[uwsgi]

# add an http router/server on the specified address
http    = 127.0.0.1:9000

# the base directory (full path)
chdir   = /path/to/your/flask-project
# load a WSGI module
module  = wechat
# set default WSGI callable name
callable = app

# the socket (use the full path to be safe
socket  = /var/run/wechat_uwsgi.sock
pidfile = /var/run/wechat_uwsgi.pid

# ... with appropriate permissions - may be needed
chmod-socket    = 666

# automatically rewrite SCRIPT_NAME and PATH_INFO
manage-script-name  = true

# process-related settings
# master
master  = true
# maximum number of worker processes
processes   = 4

# clear environment on exit
vacuum  = true

# background the process & log
daemonize = /var/log/uwsgi/wechat.log
```

## 微信公众平台的配置请求
这一步基本按照实验文档来的，不过有一个地方要注意一下。文档中使用了`hashlib` 库，但是没有`import`进来，这会造成在访问时报 `500 Internal Error`。

解决：在代码开始添加`hashlib` 即可。

我的 `wechat.py`：

```python
import hashlib
from flask import Flask, request, make_response
app = Flask(__name__)

@app.route('/')
def index():
    return "Hello World!"

@app.route('/auth',methods=['GET','POST'])
def wechat_auth():
    if request.method == 'GET':
        print 'coming Get'
        data = request.args
        token = "4yN275N7g3cY7t2znnG7U7h4MbU7wT42"
        signature = data.get('signature','')
        timestamp = data.get('timestamp','')
        nonce = data.get('nonce','')
        echostr = data.get('echostr','')
        s = [timestamp,nonce,token]
        s.sort()
        s = ''.join(s)
        if (hashlib.sha1(s).hexdigest() == signature):
            return make_response(echostr)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
```
我把验证放在了`/auth`，在微信平台的验证路径改成 对应的即可。


----
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="知识共享许可协议" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>本作品采用<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">知识共享署名-非商业性使用-相同方式共享 4.0 国际许可协议</a>进行许可。
