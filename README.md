# HelloVapor

基于 Swift Vapor 开发的博客系统。

对应课程：[Swift Vapor 实战](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzI4MDM2MDAzOA==&action=getalbum&album_id=4011584829035593730&from_itemidx=1&from_msgid=2247486416#wechat_redirect)


## supervisor 

```

```conf
# /etc/supervisor/conf.d/vaporblog-oldbird-run.conf
[program:vaporblog-oldbird-run]
command=/www/wwwroot/vaporblog.oldbird.run/HelloVapor serve --env production --auto-migrate --port 11806 
directory=/www/wwwroot/vaporblog.oldbird.run
autostart=true
autorestart=true
user=root
stdout_logfile=/var/log/supervisor/%(program_name)-stdout.log
stderr_logfile=/var/log/supervisor/%(program_name)-stderr.log
```

