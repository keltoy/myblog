---
title: HBase 个人总结
date: 2020-06-24 17:39:30
tags: [ hbase ]
---


[toc]

## 存储原理

### HMaster

- 主节点
- 管理RegionServer, Region

### HRegionServer

- 从节点
- 数据，表数据存储

#### HLog

预写日志

- 1个RegionServer可能有多个HLog
- 存储在HDFS上

#### Region

- 1个RegionServer可能有多个Region
- 每个Region 只属于一张表，只保存一张表的数据

##### Store

- 每1个列族对应1个Store

###### MemStore

- 1个Store 对应1个MemStore

###### StoreFile

- 存储到HDFS上
- 1个Store 对应多个MemStore
- 对 __HFile__ 的包装

#### BlockCache

- 1个RegionServer一般只有1个BlockCache
- 加快读取数据

### client

- 客户端

## 写流程

### 写入流程

1. 预写日志HLog WAL
2. 客户端与zookeeper建立连接，读取zookeeper上的meta信息(meta-region-server)，找到存放meta信息的regionServer
3. 客户端连接存放该表meta信息的regionServer，找到保存meta表的region(meta 只有1个region)
4. 通过meta表的信息，定位到相应的region
5. 向memstore写入数据(默认128M)
6. 如果memstore超过128M 则需要flush溢写数据到storeFile(HFile)
7. 如果storeFile超过阈值，则触发minor compation 将几个小的HFile合并成1个HFile
8. 周期执行，将所有storeFile 最终进行合并触发major compation
9. 数据量过大时需要执行split，将1个region 分成2个region

### flush流程

为了避免flush影响写入性能，通过2个MemStore完成稳定写入

#### flush写入流程

1. 当前写入MemStore设置为Snapshot，不容许新写入操作写入
2. 另开内存空间作为MemStore，后续的写入操作写入这里
3. Snapshot的MemStore写入完毕，对应内存空间释放

#### flush触发条件

1. memstore 大小达到了上限(hbase.hregion.memstore.flush.size 默认128M)
2. region 所有的memstore大小总和达到了上限(hbase.hregion.memstore.block.multiplier * hbase.hregion.memstore.flush.size 默认 2 * 128M)
3. RegionServer 中所有的memstore的大小总和超过低水位阈值(hbase.regionserver.global.memstore.size.lower.limit * hbase.regionserver.globlal.memstore.size,前者默认0.95)，先flush最大的，然后是次大的，以此类推
4. 如果写入速度大于flush写出速度，导致总memstore大小超过高水位阈值 hbase.regionserver.global.memstore.size(默认jvm内存的40%)，此时regionServer会阻塞更新并执行flush,直到memstore大小低于低水为值


### minor compaction

#### 小合并触发条件

1. 至少需要3个满足条件的storefile时 才会启动(可配置)
2. 一次 minor compaction 最多选取10个storefile(可配置)
3. 文件大小小于128m的storefile 一定会加入到minor compaction的storefile中(可配置)
4. 文件大于Long.MAX_VALUE的文件，一定排除minor compaction(可配置)

```xml
<property>
<name>hbase.hstore.compactionThreshold</name>
<value>3</value>
</property>

<property>
<name>hbase.hstore.compaction.max</name>
<value>3</value>
</property>

<property>
<name>hbase.hstore.compaction.min.size</name>
<value>134217728</value>
</property>

<property>
<name>hbase.hstore.compaction.max.size</name>
<value>9223372036854775807</value>
</property>

```

### major compaction

1. 将所有Store中的 HFile 合并成一个HFile
2. 清理3类无意义的数据被删除的数据，ttl过期数据 版本号超过设定版本号的数据

一般不会让hbase 自动执行，挑选一个不繁忙的时间段，进行定时执行(7天左右)

默认情况下是7天执行一次，生产环境中，将其关闭(将时间设置为0)

```xml
<property>
<name>hbase.hregion.majorcompaction</name>
<!-- 设置为0时 为关闭自动执行major compaction-->
<value>604800000</value>
</property>
```

```bash
# 手动触发
major_compact tableName
```

## 读流程

### 读取流程

1. 客户端与zookeeper建立连接，读取zookeeper上的meta信息(meta-region-server)，找到存放meta信息的regionServer
2. 客户端连接存放该表meta信息的regionServer，找到保存meta表的region(meta 只有1个region)
3. 通过meta表的信息，定位到相应的region
4. 先读取memstore是否存在
5. 如果不存在读取blockcache
6. 如果不存在读取HFile数据

### meta 信息

保存了

1. hbase集群有哪些表
2. 每张表有哪些region
3. 这些region 保存在哪些regionServer上
4. region的开始rowkey和结束rowkey(startrowkey endrowkey)


## Region拆分机制(split)

Region拆分有如下几个钟策略

### ConstantSizeRegionSplitPolicy

0.94版本前的切分逻辑

当region大小大于阈值后就会触发切分，分成2个等分的region
hbase.hregion.max.filesize=10G

弊端:

1. 对大表小表没有区分，会导致 设置过大，小表不切分，设置过小，大表产生大量region
2. 设置过大，对业务不友好
3. 设置过小，对集群管理，资源使用, failover不好

### IncreasingToUpperBoundRegionSplitPolicy

0.94版本-2.0版本默认切分策略

region split 计算公式:

    min(regioncount^3 * 128M * 2, 10G) , 当region达到了该size的时候进行split
  
例如：

$$ 第1次split,regioncount=1: 1^3*256 = 256M $$
$$ 第2次split,regioncount=1: 2^3*256 = 2048M $$
$$ 第3次split,regioncount=1: 3^3*256 = 6912M $$
$$ 第4次split,regioncount=1: 4^3*256 = 163841M  大于10G 所以取10G$$

第4次后都是以10G进行split

### SteppingSplitPolicy

2.0版本后默认切分策略

    如果region = 1，则切分阈值为 flush size  * 2
    否则，切分阈值为MaxRegionFileSize

好处是小表不会产生大量小region

### KeyPrefixRegionSplitPolicy

根据rowkey前缀对数据进行分组，将前缀前n位相同的用户放在同一个region中

### DelimitedKeyPrefixRegionSplitPolicy

保证相同前缀在同一region中，这次使用指定分隔符delimiter来切分

### DisabledRegionSplitPolicy

不启动自动拆分

## Hbase 表预分区 pre-splitting

Region 切分非常耗时，为了

1. 提升数据读写效率
2. 负载均衡，防止数据倾斜
3. 方便集群容灾调度region
4. 优化Map数量

所以需要预分区

### pre-splitting 原理

每个region维护者startRow 和 endRowKey，如果加入的数据符合某个region维护的rowkey范围，则该数据交给这个region维护

### 手动指定预分区

```bash
create 'person', 'info1', 'info2', SPLIT => ['1000', '2000', '3000', '4000']

# 文件内容
# aaa
# bbb
# ccc
# ddd
create 'student', 'info', SPLIT_FILE => '/xxx/xxx/split.txt'
```

### HexStringSplit算法

将 00000000 - FFFFFFFF 之间的数据 n等分

```bash
create 'mytable', 'base_info', 'extra_info', {NUMREGIONS => 15, SPLITALGO => 'HexStringSplit'}

```

## Region 合并

Region 合并不是为了性能，而是出于维护的目的， 比如删除了大量的数据

### 通过 Merge 冷合并Region

1. 合并之前需要先关闭hbase
2. 创建一张表
3. 查找到region的信息(名称) 端口 60010

```bash
create 'test', 'info1', SPLIT => ['1000', '2000', '3000']

hbase org.apache.hadoop.hbase.util.Merge test regionname1, regionname2
```

### 通过online_merge 热合并Region

1. 不需要关闭hbase集群
2. online_merge 传参是Region的hash值，就是Region名称最后面的那个字符串

```bash
merge_region regionhash1, reginhash2

```


![HBase.png](/hbase.png)

[思维导图](/Hbase.emmx)
