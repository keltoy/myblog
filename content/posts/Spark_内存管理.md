---
title: "Spark_内存管理"
date: 2020-08-27T20:40:45+08:00
draft: false
toc: true
images:
plantuml: true
tags:
  - untagged
---

# 前言

Spark是基于内存的计算引擎，就是说它高效的使用了分布式节点上的内存资源，尽可能多的使用内存，而不是将数据写入磁盘。内存管理机制就是其中的核心Spark 是基于内存进行处理，不用每次计算后写入磁盘，再取出来进行计算，这样就节省了IO时间，所有的临时数据都放在内存中。

# Spark管理的内存

- 系统区，Spark运行自身的代码需要的空间
- 用户区，udf等代码需要一定的空间来执行
- 存储区，为了计算速度加快，Spark会将存储的数据放入内存中进行计算，存储区就是为了放入数据使用的
- 执行区，Spark操作数据的单元是partition，Spark在执行一些shuffle、join、sort、aggregation之类的操作，需要把partition加载到内存进行计算，会用到部分内存


# 总结

{{< mermaid >}}
sequenceDiagram
    participant Alice
    participant Bob
    Alice->John: Hello John, how are you?
    loop Healthcheck
        John->John: Fight against hypochondria
    end
    Note right of John: Rational thoughts <br/>prevail...
    John-->Alice: Great!
    John->Bob: How about you?
    Bob-->John: Jolly good!
{{< /mermaid >}}

fasdfsdfdsf
{{< gravizo "DOT Language (GraphViz) Example" >}}
@startuml
* Debian
** Ubuntu
*** KDE Neon
** LMDE
@startuml
{{< /gravizo >}}
