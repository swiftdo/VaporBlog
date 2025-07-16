# HelloVapor

基于 Swift Vapor 开发的博客系统。

对应课程：[Swift Vapor 实战](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzI4MDM2MDAzOA==&action=getalbum&album_id=4011584829035593730&from_itemidx=1&from_msgid=2247486416#wechat_redirect)


## supervisor 


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

## 功能规划


## 功能规划

* 前端 
  * [x] 文章、分类、标签
  * [x] 引入 markdown 编辑器，传值问题，隐藏 id
  * [x] 实现分页
  * [x] 文章阅读量
  * [ ] 文章显示时间
  * [ ] 文章添加评论
    * [ ] 评论添加回复功能
  * [ ] tag 对应的文章列表
  * [ ] category 对应的文章列表
  * [ ] 文章搜索
  * [ ] 站点用户访问统计
  * [ ] 通知消息中心
  * [ ] 意见反馈
  * [ ] 文章支持收藏和点赞
  * [ ] 个人中心，个人资料编辑
  * [ ] 我的收藏，我的评论，我的文章，我的点赞文章
  * [ ] 举报功能
  * [ ] 用户访问数统计
  * [ ] 社交分享功能
* 后端管理平台
  * [ ] 用户管理
  * [ ] 登录
  * [ ] 角色 权限 菜单管理
  * [ ] 分类管理
  * [ ] 标签管理
  * [ ] 文章管理
  * [ ] 评论管理
  * [ ] 操作日志
  * [ ] 友情链接管理
  * [ ] 站点配置管理
  * [ ] 统计分析
  * [ ] 独立文件系统，基于 gitlab 实现文章文件管理


