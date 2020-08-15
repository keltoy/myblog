---
title: "Kylin_And_Doris"
date: 2020-08-03T16:10:51+08:00
draft: true
toc: true
images:
tags:
  - untagged
---

[toc]

# 前言

Kylin 和 Doris 都是 开源OLAP 对比这两款数据库，实际上也是是 MOLAP 和 ROLAP的代表

​    MOLAP (Multidimension OLAP)，存储模式使得分区的聚合和其源数据的复本以多维结构存储在分析服务器计算机上

​    ROLAP (Relational OLAP)，存储模式使得分区的聚合存储在关系数据库的表（在分区数据源中指定）中

​    HOLAP (Hybrid OLAP)，支持所有的三种存储模式。应用存储设计向导，可以选择最适合于分区的存储模式。或者也可使用基于使用的优化向导，以便根据已发送到多维数据集的查询选择存储模式并优化聚合设计。当使用三种存储模式之一时，还可以使用显式定义的筛选来限制读入到分区内的源数据