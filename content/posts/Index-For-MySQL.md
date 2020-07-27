---
title: Index For MySQL
date: 2016-12-30 23:16:42
tags: [MySQL]
---

# Preface

>Beautiful is better than ugly.

之前被问到索引的分类，被分为唯一性索引和普通索引，有点懵逼。回头再看看，总结一下。

# Keys

* PRIMARY  主键索引建立主键索引其实跟 UNIQUE 没什么区别
* INDEX 普通的索引
* UNIQUE 唯一性索引
* FULLTEXT 全文索引，这个 innodb 在 MySQL 5.5 之前不支持
* SPAIAL 空间索引

这么分其实很混乱，这几个 key 好像不是一个维度的。

# Types of Index
在《高性能 MySQL》是这么分的：

* B-Tree 索引
* 哈希索引
* 空间数据索引
* 全文索引
* 其他索引

 
