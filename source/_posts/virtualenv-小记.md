---
title: virtualenv 小记
date: 2019-07-01 17:15:27
tags: [python]
---

# 前言

最近想要获取url上的固定每日数据，写到原始脚本里发现程序卡死了，思前想后想再写一个脚本，这样也不用怎么修改之前的脚本。因为在服务器上运行还需要一些权限，所以希望能够使用virtualenv配置一下自己的环境。

# 开始实践

在服务器上安装 vitualenv, 然后创建环境就可以运行了

```bash
pip install virtualenv
virtualenv --no-site-packages venv
```

> --no-site-packages 代表安装虚拟环境的时候不需要任何其他多余的包

# 自己对虚拟环境的误解

因为是服务器环境，我发现我并没有root权限不能安装任何python的包。
我就希望将自己笔记本的python 环境打好包，安装到服务器上。
于是我将需要的包和库安装好后，使用virtualenv 配置好，打包传送到服务器上，准备使用virtualenv 开始运行

```bash
./venv/bin/activate
```

服务端的前缀出现了python3 的小括号，感觉目前都比较顺利。
然后查看版本号

```python 
python -V
2.7.5
```

怎么回事？没有变化？应该是变化成了virtualenv 中的 3.7才对
然后调用env中的python 确实是 3.7 
于是 更改python 重新运行，发现这个3.7的python 什么包也照得不到。

看来自己对虚拟环境是有所误解

于是检查了一下venv/bin下的 activate 文件，才发现原来这个文件只是做了个映射

```bash
VIRTUAL_ENV="xxx/venv"
export VIRTUAL_ENV
```

所以想让activate 生效， 还需要更改这里的地址。