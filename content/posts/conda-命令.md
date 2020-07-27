---
title: conda 命令
date: 2020-04-08 13:43:00
tags: [python]
---

## 前言

之前都是使用 pip 和 virtualenv 管理python 的包管理和环境管理，最近体验了一下 jupyterlab， 好多插件的使用都需要安装nodejs，virtualenv 只能管理python 的环境，于是就想到了conda 试试conda 的环境管理能不能，惊喜的发现可以，所以以后的使用应该都迁移到 conda上来了

## conda简介

说明原文[conda 文档](https://docs.conda.io/en/latest/)

conda 是开源的跨操作系统的包管理系统和环境管理系统，可以管理多种语言，运行安装都比较简单

## conda 包管理

```bash
# 添加一个渠道，获取软件包的渠道 常用的有 bioconda, conda-forge, genomedk
conda config --add channel 

# 设置去掉url显示
conda config --set show_channel_urls yes

# 渠道列表
conda config --get channels

# 搜索包
conda search [-c channel] packagename

# 安装包
conda install packagename=versionnumber

# 包列表
conda list

# 删除包
conda remove packagename

```

## conda 环境管理

```bash
# 环境列表
conda env --list

# 环境信息
conda info --envs

# 创建python3环境
conda create -n name python=3

# 激活环境
conda activate environmentname

# 退出环境
conda deactivate

# 删除环境
conda remove -n environmentname --all

```
