---
title: Learning Docker
date: 2016-12-15 23:59:23
tags: [docker]
---

# What Is Docker

Docker 是开源的应用容器引擎，开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发不到其他机器上，实现虚拟化。容器完全使用沙箱机制，互相之间不会有任何接口。
Docker 基于LXC的引擎使用 go 开发。

# How To Use Docker

1. 构建一个镜像
2. 运行容器

其实可以当作一个虚拟机来使用....

# Docker Command

## docker info

查看 docker 的相关信息

## docker pull an image or a repository

从远端拉取一个镜像或者仓库
eg:

    docker pull busybox

## docker run image cmd

运行镜像的一个命令
eg:

    docker run busybox /bin/echo Hello Docker

eg: 后台进程方式运行

    sample_job=$(docker run -d busybox /bin/sh -c "while true; do echo Docker; sleep 1; done")

-d 代表 detach

## docker logs container

查看容器状态日志
eg:

    docker logs $sample_job

## docker help

由于 docker 没有 man，所以 help 就很重要了

## docker stop container

停止容器

## docker restart container

重启容器

## docker rm container

删除容器

## docker commit container image-name

保存容器为镜像

## docker images

查看所有镜像

## docker search (image-name)

搜索镜像

## docker history (image_name)

历史版本

## docker push (image_name)

使用将镜像推送到registry

# DockerFile

使用 DockerFile 自动创建镜像。

    INSTRUCTION arguments

指令不区分大小写，但是命名约定大写

## FROM <image name>

所有的 DockerFile 必须以 FROM 开始,指定镜像基于哪个基础镜像创建。
eg:

    FROM ubuntu

## MAINTAINER <author name>

设置镜像作者

## RUN <command>

运行 Shell 或者 Exec 指令

## ADD <src> <dest>

向容器内复制文件指令

## CMD ["executable", "param1", "param"]
