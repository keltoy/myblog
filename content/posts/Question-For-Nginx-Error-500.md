---
title: Question For Nginx Error 500
date: 2017-01-10 12:23:20
tags: [nginx]
---

# Preface

前几天服务器到期了，然后重新申请了之后，发现本地的 node 也出了问题，按照网上的方法也修理不好。

于是自己想使用 docker 来重新建。费了一些时间把 docker 实践了，感觉挺费流量的...不过还好。

昨天，node 自己又好了...优点莫名其妙，后来想想可能跟 python2.7.x 的版本有关系。

然后重新搭建的时候发现 nginx 启动不了， 返回

    500 internal server error

# 500 internal server error

使用 systemctl status nginx.service 发现，启动之后访问 web 目录访问不了。

网上说跟自己的配置有关系，比如 location 配置的有问题等等。

本人检查了很久没有什么问题，确定分号，拼写都没问题，但是还是会报 500 错误。

# Log is key

一筹莫展的时候就想试试各种办法，于是就查询了 /var/log/nginx 下面的错误日志，发现报的错误是

    13: Permission denied

难道是权限不够？对于 755 的权限设置应该是没有问题，于是我改成了 777 虽然觉得没什么效果，但是还是试了一试。
果然，没有效果，依旧拒绝。不过可以确定的是，应该是权限的问题。

可能，是用户的问题。带着这个想法我看了一下 nginx.conf 的用户发现

    user nginx

试试给个最大的权限 修改成 root

    user root

重启一下 nginx

OK！运行成功了。

# Postscript

其实这个问题困扰了我很长时间，每次配nginx的时候都会出现这样那样的问题，不过这次解决之后，下一次应该不会再犯了。
