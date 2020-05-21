---
title: jmap jstack jstat
date: 2020-05-21 16:03:03
tags: [java, jmap, jstack]
---
[toc]

## jps (Java Virtual Machine Process)

用来输出JVM 进程状态信息

```bash
jps [options] [hostid]
```

如果不指定 hostid 那么久默认当前服务器

option 命令：

- -q 不输出类名，jar名和传入main方法的参数
- -m 输出传入main方法的参数
- -l 输出main类或者Jar的权限名
- -v 输出传入JVM的参数

## jmap（查看内存，对象）

可以输出所有内存中对象的工具，甚至是将VM 中的heap，以二进制输出成文本；打印出某个java进程(pid)内存中的所有对象的情况

```bash
jmap [option] pid
jmap [option] executable core
jmap [option] [service-id@]remote-hostname-or-IP

```

其中：

- option 选项参数
- pid 打印配置信息的进程id
- executable 产生核心dump的java 可执行文件
- core 需要打印配置信息的核心文件
- server-id 可选唯一id，如果相同的远程主机上运行了多台调试服务器，可以用来标识服务器
- remote-hostname-or-IP 远程调试服务器的主机名或ip

option的取值有：
- \<none\> 查看进程的内存映像信息
- -heap 显示java堆详细信息
- -histo[:live] 统计java对象堆的直方图
- -clstats 打印类加载器信息
- -finalizerinfo 显示在F-Queue队列等待Finalizer线程执行finalizer方法的对象
- dump:\<dump-options\> 生成堆转储快照
- F: 当-dump没有响应时， 使用 -dump 或者 -histo参数。在这个模式下,live子参数无效.
- J\<flag\> 指定传递给运行jmap的JVM的参数

## jstack（查看线程）

jstack 能获得运行java程序的java stack 和native stack

与jmap 类似，可以查看进程id中的信息

```bash
jstack [option] pid
jstack [option] executable core
jstack [option] [service-id@]remote-hostname-or-IP

```

```bash
jstack [-l] <pid>
        (to connect to running process) 连接活动线程
    jstack -F [-m] [-l] <pid>
        (to connect to a hung process) 连接阻塞线程
    jstack [-m] [-l] <executable> <core>
        (to connect to a core file) 连接dump的文件
    jstack [-m] [-l] [server_id@]<remote server IP or hostname>
        (to connect to a remote debug server) 连接远程服务器
```

option 的取值

- -l 长列表，展示关于锁的额外信息
- -F 强制线程dump。在jstack \<pid\> 没有响应时使用（进程挂起/阻塞）
- -m 展示java 和 native 线程栈信息（mix模式）

```text
"JPS event loop" #10 prio=5 os_prio=31 tid=0x00007f9a8b1ba000 nid=0xa903 runnable [0x0000700010178000]
   java.lang.Thread.State: RUNNABLE
	at sun.nio.ch.KQueueArrayWrapper.kevent0(Native Method)
	at sun.nio.ch.KQueueArrayWrapper.poll(KQueueArrayWrapper.java:198)
	at sun.nio.ch.KQueueSelectorImpl.doSelect(KQueueSelectorImpl.java:117)
	at sun.nio.ch.SelectorImpl.lockAndDoSelect(SelectorImpl.java:86)
	- locked <0x000000079442d0f0> (a io.netty.channel.nio.SelectedSelectionKeySet)
	- locked <0x000000079442d108> (a java.util.Collections$UnmodifiableSet)
	- locked <0x000000079442d0a0> (a sun.nio.ch.KQueueSelectorImpl)
	at sun.nio.ch.SelectorImpl.select(SelectorImpl.java:97)
	at io.netty.channel.nio.SelectedSelectionKeySetSelector.select(SelectedSelectionKeySetSelector.java:62)
	at io.netty.channel.nio.NioEventLoop.select(NioEventLoop.java:824)
	at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:457)
	at io.netty.util.concurrent.SingleThreadEventExecutor$6.run(SingleThreadEventExecutor.java:1044)
	at io.netty.util.internal.ThreadExecutorMap$2.run(ThreadExecutorMap.java:74)
	at java.lang.Thread.run(Thread.java:748)

   Locked ownable synchronizers:
	- None
```

dump 信息说明：

- "JPS event loop" 是我们为线程起的名称
- daemon 是否是守护线程 存在这个关键字则是守护线程，不存在这个关键字则不是守护线程
- prio 是我们为线程设置的优先级
- os_prio 操作系统线程的优先级，如果系统不支持系统线程优先级，则os_prio=0
- tid Java线程id
- nid 线程对应操作系统本地线程id,每一个java线程都有一个对应的操作系统线程
- runnable 当前线程处于运行状态，如果是等待状态，会显示 wait on condition
- java.lang.Thread.State 线程状态，会详细说明原因
  - NEW 线程刚刚被创建，也就是已经new过了，但是还没有调用start()方法，jstack命令不会列出处于此状态的线程信息
  - RUNNABLE #java.lang.Thread.State:RUNNABLE 表示这个线程是**可运行的**。一个单核CPU在同一时刻，只能运行一个线程。
  - BLOCKED #java.lang.Thread.State:BLOCKED (on object monitor) 线程处于阻塞状态，正在等待一个monitor lock。通常情况下，是因为本线程与其他线程公用了一个锁。其他在线程正在使用这个锁进入某个synchronized同步方法块或者方法，而本线程进入这个同步代码块也需要这个锁，最终导致本线程处于阻塞状态。
  - WAITING 等待状态，调用以下方法可能会导致一个线程处于等待状态
    - Object.wait 不指定超时时间 # java.lang.Thread.State: WAITING (on object monitor) 对于wait()方法，一个线程处于等待状态，通常是在等待其他线程完成某个操作。本线程调用某个对象的wait()方法，其他线程处于完成之后，调用同一个对象的notify或者notifyAll()方法。Object.wait()方法只能够在同步代码块中调用。调用了wait()方法后，会释放锁。
    - Thread.join  with no timeout
    - LockSupport.park #java.lang.Thread.State: WAITING (parking)

  - TIMED_WAITING 线程等待指定的事件，对于以下方法的调用，可能会导致线程会处于这个状态
    - Thread.sleep #java.lang.Thread.State: TIMED_WAITING(sleeping)
    - Object.wait 指定超时时间 #java.lang.Thread.State: TIMED_WAITING (on object monitor)
    - Thread.join  with timeout
    - LockSupport.parkNanos #java.lang.Thread.State: TIMED_WAITING (parking)
    - LockSupport.parkUntil #java.lang.Thread.State: TIMED_WAITING (parking)
  - TERMINATED 线程终止

查看进程下有哪些线程(和nid 对应)

```bash
cat /proc/<pid>/task
```

通过 $$ top -Hp $$ 命令查看进程内所有线程的cpu和内容使用情况

名词解释

- Monitor

在多线程的Java程序中，实现线程之间的同步，就会使用到Monitor。Monitor是Java中用以实现线程之间的互斥与协作的手段，它可以是对象或者类的锁。每个对象都有，有且仅有一个。
每个 Monitor在某个时刻，只能被一个线程拥有，该线程就是Active Thread而其它线程都是Waiting Thread，分别在两个队列 Entry Set和Wait Set里面等候。在Entry Set中等待的线程状态是 Waiting for monitorentry, 而在 Wait Set中等待的线程状态是in Object.wait()

- Entry Set

Entry Set 表示线程通过synchronized要求获取对象的锁。如果对象未被锁住，则进入（The Owner）拥有者，否则在进入区等待；一旦对象所被其他现场释放，则立即参与竞争
Entry Set里面的线程。我们称被 synchronized保护起来的代码段为临界区。当一个线程申请进入临界区时，它就进入了 “Entry Set”队列。对应代码：

```java
synchronized(obj) {
.......
}
```

- The Owner

The Owner 表示某一线程成功竞争到对象锁

- Wait Set

Wait Set 表示线程通过对象的wait方法，释放对象的锁并在等待区被唤醒

调用修饰
线程在方法调用时，额外的重要操作, 是线程Dump分析的重要信息。修饰上方的方法调用

locked<地址> 目标: 使用synchronized申请对象锁成功，监视器(monitor)的the owner（拥有者）
waiting to lock<地址> 目标: 使用synchronized申请对象锁未成功，在entry set等待
waiting on <地址> 目标: 使用synchronized申请对象锁成功后，释放锁在wait set等待

parking to wait for <地址> 目标: 需要与堆栈中的parking to wait for (atjava.util.concurrent.SynchronousQueue$TransferStack)结合来看。

1. 此线程是在等待某个条件的发生，将自己唤醒
2. SynchronousQueue不是一个队列，其实是线程之间移交信息额机制。当我们吧一个元素放入到 SynchronousQueue中时，必需有另一个线程正在等待接收移交的任务。这就是本线程在等待的条件

## jstat（性能分析）

主要利用JVM内建的指令对Java应用程序的资源和性能进行实时的命令行的监控，包括了对Heap size和垃圾回收状况的监控

```bash
jstat -<option> [-t] [-h<lines>] <vmid> [<interval> [<count>]]
jstat -help | -options
```

参数:

- -option 参数选项
- -t 在打印的列加上timestamp列，用于显示系统运行的时间
- -h n 设置隔n行显示一个header
- vmid 进程pid
- interval 执行每次的间隔时间， 单位毫秒
- count 指定输出多少次记录

option参数都有:

1. -class 显示ClassLoader的相关信息
2. -compiler 显示JIT编译的相关信息
3. -gc 显示和gc相关的堆信息
4. -gccapacity 显示各个代的容量以及使用情况
5. -gcmetacapacity 显示metaspace(元空间)的大小
6. -gcnew 显示新生代的信息
7. -gcnewcapacity 显示新生代大小和使用情况
8. -gcold 显示老年代的大小
9. -gcoldcapacity 显示老年代的大小
10. -gcutil 显示垃圾收集信息
11. -gccause 显示垃圾收集信息，同时显示最后一次或当前正在发生的垃圾回收的诱因
12. -printcompilation 输出JIT编译的方法信息

class: 显示加载class的数量，及所占空间等信息

| Loaded | Bytes | Unloaded | Bytes | Time |
|:----:|:----:|:----:|:----:|:----:|
|已经装载的类的数量|装载类所占用的字节数|已卸载类的数量|卸载类的字节数|装载和卸载类所花费的时间|

compiler: 显示VM实时编译(JIT)的数量等信息

| Compiled | Failed | Invalid | Time | FailedType | FailedMethod |
|:----:|:----:|:----:|:----:|:----:|:----:|
|编译任务执行的数量|编译任务执行失败的数量|编译任务执行无效的数量|编译任务消耗的时间|最后一个编译失败任务的类型|最后一个编译失败所在类及方法|

gc: 显示gc相关的堆信息，被查看gc的次数、及时间

参数略长，转置一下
| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|S0C |年轻代中第一个survivor的容量(字节)|from|
|S1C |年轻代中第二个survivor的容量(字节)|to|
|S0U |年轻代中第一个survivor目前已使用的空间| |
|S1U |年轻代中第二个survivor目前已使用的空间| |
|EC  |年轻代中的Eden的容量| |
|EU  |年轻代中的Eden目前已使用的容量| |
|OC  |老年代的容量| |
|OU  | 老年代已使用空间| |
|MC  | metaspace的容量| |
|MU  | metaspace目前已使用空间| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|YGCT | 从应用程序启动到采样时老年代中(full gc)gc所用时间| |
|FGC | 从应用程序启动到采样时老年代中(full gc)gc所用事件(单位: 秒)| |
|FGCT | 从应用程序启动到采样时年轻代中gc所用时间| |
|GCT | 从应用程序启动到采样时gc所用时间| |

gccapacity: 显示 VM内存中堆栈的使用大小和占比大小

| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|NGCMN |年轻代中初始化(最小)的大小|单位字节|
|NGCMX |年轻代的最大容量|单位字节|
|NGC |年轻代的当前容量|单位字节|
|S0C |年轻代中第一个survivor的容量(字节)|from|
|S1C |年轻代中第二个survivor的容量(字节)|to|
|EC  |年轻代中的Eden的容量| |
|OGCMN  |老年代中初始化(最小)的大小| |
|OGCMX  |老年代最大容量| |
|OGC  |老年代当前新生成的容量| |
|OC  |老年代的容量| |
|OU  | 老年代已使用空间| |
|MC  | metaspace的容量| |
|CCSMN  |最小压缩类空间大小| |
|CCSMX  |最大压缩类空间大小| |
|CCSC  |当前压缩类空间大小| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|FGC | 从应用程序启动到采样时老年代中(full gc)gc所用事件(单位: 秒)| |

gcmetacapacity: metaspace中对象的信息及占用量

| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|MCMN|最小元数据容量|单位字节|
|MCMX |最大元数据容量|单位字节|
|MC  | metaspace的容量| |
|CCSMN  |最小压缩类空间大小| |
|CCSMX  |最大压缩类空间大小| |
|CCSC  |当前压缩类空间大小| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|FGC | 从应用程序启动到采样时老年代中(full gc)gc所用事件(单位: 秒)| |
|FGCT | 从应用程序启动到采样时年轻代中gc所用时间| |
|GCT | 从应用程序启动到采样时gc所用时间| |

gcnew: 年轻代对象的信息


| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|S0C |年轻代中第一个survivor的容量(字节)|from|
|S1C |年轻代中第二个survivor的容量(字节)|to|
|S0U |年轻代中第一个survivor目前已使用的空间| |
|S1U |年轻代中第二个survivor目前已使用的空间| |
|TT|持有次数限制| |
|MTT|最大持有次数限制| |
|DSS|期望的survivor大小| |
|EC  |年轻代中的Eden的容量| |
|EU  |年轻代中的Eden目前已使用的容量| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|YGCT | 从应用程序启动到采样时老年代中(full gc)gc所用时间| |

gcnewcapacity: 年轻代对象的信息及占用量

| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|NGCMN |年轻代中初始化(最小)的大小|单位字节|
|NGCMX |年轻代的最大容量|单位字节|
|NGC |年轻代的当前容量|单位字节|
|S0C |年轻代中第一个survivor的容量(字节)|from|
|S0CMX |年轻代中第一个survivor的最大容量(字节)|from|
|S1C |年轻代中第二个survivor的容量(字节)|to|
|S1CMX |年轻代中第二个survivor的最大容量(字节)|to|
|EC  |年轻代中的Eden的容量| |
|ECMX  |年轻代中的Eden的最大容量| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|FGC | 从应用程序启动到采样时老年代中(full gc)gc所用事件(单位: 秒)| |

gcold: 老年代对象信息

| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|MC  | metaspace的容量| |
|MU  | metaspace目前已使用空间| |
|CCSC  |压缩类空间大小| |
|CCSU  |压缩类空间使用大小| |
|OC  |老年代的容量| |
|OU  | 老年代已使用空间| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|FGC | 从应用程序启动到采样时老年代中(full gc)gc所用事件(单位: 秒)| |
|FGCT | 从应用程序启动到采样时年轻代中gc所用时间| |
|GCT | 从应用程序启动到采样时gc所用时间| |

gcoldcapacity: 老年代

| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|OGCMN |老年代中初始化(最小)的大小|单位字节|
|OGCMX |老年代的最大容量|单位字节|
|OGC |老年代代的当前新生成的容量|单位字节|
|OC  |老年代的容量| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|FGC | 从应用程序启动到采样时老年代中(full gc)gc所用事件(单位: 秒)| |
|FGCT | 从应用程序启动到采样时年轻代中gc所用时间| |
|GCT | 从应用程序启动到采样时gc所用时间| |

gcutil: 统计gc信息

| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|S0 |年轻代中第一个survivor已使用的占当前容量的百分比|from|
|S1C |年轻代中第二个survivor已使用的占当前容量的百分比|to|
|E  |年轻代中的Eden已使用的占当前容量百分比| |
|O  |老年代已使用的占当前容量的百分比| |
|M  | metaspace已使用的占当前容量的百分比| |
|CCS  |压缩类空间已使用的占当前容量百分比| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|YGCT | 从应用程序启动到采样时老年代中(full gc)gc所用时间| |
|FGC | 从应用程序启动到采样时老年代中(full gc)gc所用事件(单位: 秒)| |
|FGCT | 从应用程序启动到采样时年轻代中gc所用时间| |
|GCT | 从应用程序启动到采样时gc所用时间| |

gccause: 统计gc信息，并显示最后一次或当前正在发生的gc诱因

| 名称 | 说明 | 备注 |
|:----:|:----:|:----:|
|S0 |年轻代中第一个survivor已使用的占当前容量的百分比|from|
|S1C |年轻代中第二个survivor已使用的占当前容量的百分比|to|
|E  |年轻代中的Eden已使用的占当前容量百分比| |
|O  |老年代已使用的占当前容量的百分比| |
|M  | metaspace已使用的占当前容量的百分比| |
|CCS  |压缩类空间已使用的占当前容量百分比| |
|YGC | 从应用程序启动到采样时年轻代中gc所用事件(单位: 秒)| |
|YGCT | 从应用程序启动到采样时老年代中(full gc)gc所用时间| |
|FGC | 从应用程序启动到采样时老年代中(full gc)gc所用事件(单位: 秒)| |
|FGCT | 从应用程序启动到采样时年轻代中gc所用时间| |
|GCT | 从应用程序启动到采样时gc所用时间| |
|LGCC |最后一次GC的原因| |
|GCC | 当前GC 原因或没有执行GC(No GC)| |

printcompilation: 当前VM 执行的信息

| Compiled | Size | Type | Method |
|:----:|:----:|:----:|:----:|
|编译任务的数据|方法生成字节码的大小|编译类型|类名和方法名，用来标识编译的方法，类名使用或作为一个命名空间分隔符。方法名是给定类中的方法，由 -XX:+PrintComplation选项设置的|

# 总结
有了这几个工具，就可以排查线上的某些问题了