---
title: Sequence Parquet And Avro
date: 2020-07-24 17:54:40
tags: [ data ]
---

[toc]

# 背景

大数据常用文件格式，在hive spark 使用时都需要注意，现在在使用flink 的时候发现格式问题还挺头疼的，准备整理整理，认清楚各个文件格式是怎么一回事



# 文件格式

## Sequence File

- sequenceFile文件是Hadoop用来存储二进制形式的[Key,Value]对而设计的一种平面文件(Flat File)。
- 可以把SequenceFile当做是一个容器，把所有的文件打包到SequenceFile类中可以高效的对小文件进行存储和处理。
- SequenceFile文件并不按照其存储的Key进行排序存储，SequenceFile的内部类Writer提供了append功能。
- SequenceFile中的Key和Value可以是任意类型Writable或者是自定义Writable。
- 在存储结构上，SequenceFile主要由一个Header后跟多条Record组成，Header主要包含了Key classname，value classname，存储压缩算法，用户自定义元数据等信息，此外，还包含了一些同步标识，用于快速定位到记录的边界。每条Record以键值对的方式进行存储，用来表示它的字符数组可以一次解析成：记录的长度、Key的长度、Key值和value值，并且Value值的结构取决于该记录是否被压缩。

Sequence File 有3中压缩方式

1. 无压缩：不启用压缩，那么每个记录就由它的记录长度、键的长度，和键、值组成
2. 记录压缩 ：和无压缩格式基本相同，不同的是值字节是用定义在头部的编码器来压缩的 ![2018092711023447](/2018092711023447.jpeg)
3. 块压缩：块压缩一次多个记录，因此比记录压缩更紧凑，推荐![2018092711030968](/2018092711030968.jpeg)



## Parquet

Apache Parquet是一种能够有效存储嵌套数据的列式存储格式。

- Parquet文件由一个文件头（header），一个或多个紧随其后的文件块（block），以及一个用于结尾的文件尾（footer）构成。
- Parquet文件的每个文件块负责存储一个行组，行组由列块组成，且一个列块负责存储一列数据。每个列块中的的数据以页为单位。
- 行组 可以理解为一个个block，这个特性让parquet是可分割的，因此可以被mapreduce split来处理
- 不论是行组，还是page，都有具体的统计信息，根据这些统计信息可以做很多优化
- 每个行组由一个个 Column chunk组成，也就是一个个列。Column chunk又细分成一个个page，每个page下就是该列的数据集合。列下面再细分page主要是为了添加索引，page容量设置的小一些可以增加索引的速度，但是设置太小也会导致过多的索引和统计数据，不仅占用空间，还会降低扫描索引的时间。
- parquet可以支持嵌套的数据结构，它使用了Dremel的 Striping/Assembly 算法来实现对嵌套型数据结构的打散和重构
- parquet的索引和元数据全部放在footer块

![image-20200727163014664](/image-20200727163014664.png)

## Avro

avro文件格式大致如下

1. header, followed by
2. one or more file data blocks

其中，datablock又可分为

1. numEntries：该datablock中的记录条数；
2. blockSize：该datablock的大小；
3. data：存储的数据；
4. sync：同步位

整个avro的文件布局如下：

![image-20200727170432036](/image-20200727170432036.png)

与Thrift 的区别：

Avro和Thrift都是跨语言，基于二进制的高性能的通讯中间件. 它们都提供了数据序列化的功能和RPC服务. 总体功能上类似，但是哲学不一样. Thrift出自Facebook用于后台各个服务间的通讯,Thrift的设计强调统一的编程接口的多语言通讯框架. Avro出自Hadoop之父Doug Cutting, 在Thrift已经相当流行的情况下Avro的推出，其目标不仅是提供一套类似Thrift的通讯中间件更是要建立一个新的，标准性的云计算的数据交换和存储的Protocol。 这个和Thrift的理念不同，Thrift认为没有一个完美的方案可以解决所有问题，因此尽量保持一个Neutral框架，插入不同的实现并互相交互。而Avro偏向实用，排斥多种方案带来的 可能的混乱，主张建立一个统一的标准，并不介意采用特定的优化。Avro的创新之处在于融合了显式,declarative的Schema和高效二进制的数据表达，强调数据的自我描述，克服了以往单纯XML或二进制系统的缺陷。Avro对Schema动态加载功能，是Thrift编程接口所不具备的，符合了Hadoop上的Hive/Pig及NOSQL 等既属于ad hoc，又追求性能的应用需求.

# 总结

Sequence File 和 Parquet File 实际上只是对于数据的存储压缩等做了限制，而Aveo 实际上也做了对数据的格式的限制

