---
title: ConcurrentHashMap
date: 2018-10-16 09:31:33
tags: [Java]
---

# 前言

重新学习ConcurrentHashMap

# 正题

## 使用ConcurrentHashMap的原因

- ConcurrentHashMap 是 线程安全且高效的 HashMap
- 并发编程中使用HashMap可能导致程序死循环
- HashTable 效率低下

### HashMap 导致死循环

```java
final HashMap<String, String> map = new Hashmap<String, String>(2);
Thread t new Thread(new Runnable() {
    @Override
    public void run() {
        for (int i = 0; i < 10000; i++) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    map.put(UUID.randomUUID().toString(), "");
                }
            }, "ftf"+i).start();
        }
    }
}, "ftf");
t.start();
t.join();
```

在多线程的情况下，HashMap 的 Entry 链表可能会形成有环形的数据结构，那么 Entry 的 next 节点 就不可能为空，那就有可能无限循环获取 Entry。

### HashTable 效率低下

- HashTable 是使用 synchronized 保证线程安全
- 线程竞争的情况下，当一个线程访问HashTable，其他的线程会阻塞或者轮询（T1 使用put时，T2 既不能get也不能put）

## ConcurrentHashMap 结构

### JDK1.7

![ConcurrentHashMap类图](http://odzz59auo.bkt.clouddn.com/ConcurrentHashMap.jpg)

也就是说，ConcurrentHashMap 是由Segment数组组成，每个Segment里又包含了许多 HashEntry

Segment 又继承了可重入锁，因此Segment实际上也是可重入锁，所以 ConcurrentHashMap 使用的分段锁能够减少线程之间的竞争

ConcurrentHashmap会对元素的hashCode 进行再一次hash 以减少散列冲突

#### get

请一定要记清楚，整个get过程是不加锁的，除非读到的值为空才会加锁重读。不使用加锁原因是 get 操作中使用到的共享变量都被定义成了 volatile 变量，例如 Segment 的 count，还有 HashEntry 的 value。

```java
public V get (Object key) {
    int hash = hash(key.hashCode());
    //segmentFor返回一个segment
    return segmentFor(hash).get(key, hash)
}
```

```java
transient volatile int count;
volatile V value;
```

#### put

put 操作必须加锁，否则不能保证共享变量线程安全。1.7中使用的是自旋锁

```java
public V put(K key, V value) {
    Segment<K,V> s;
    if (value == null)
        throw new NullPointerException();
    int hash = hash(key);
    int j = (hash >>> segmentShift) & segmentMask;
    if ((s = (Segment<K,V>)UNSAFE.getObject          // nonvolatile; recheck
         (segments, (j << SSHIFT) + SBASE)) == null) //  in ensureSegment
        s = ensureSegment(j);
    return s.put(key, hash, value, false);
}
```

插入数据的时候需要有2个操作

1. 检查Segment里的HashEntry数组是否需要扩容
2. 定位元素位置，将元素放入HashEntry里

扩容主要是判断容量是否超过 threshold。扩容操作先执行然后再执行插入，这样的扩容与HashMap有所不同，不会导致无故扩容之后浪费空间。当确定需要扩容后，会先创建一个2倍于当前HashEntry数组，然后插入数据。扩容只会影响当前segment进行扩容，不会影响其他的

#### size

首先，不能简单使用累加，因为累加的过程中可能会添加删除操作
其次，如果都加锁，那这个过程又非常低效
所以首先用尝试不锁住Segment统计2次，如果结果相同，返回该值，如果不同，再锁住所有的 Segment 进行统计

### JDK1.8+

在1.8以及之后的版本，HashMap 和 ConcurrentHashmap 有了较大的改动，
主要改动有：

1. 将原有table数组+链表的结构改成了 table数组+链表+红黑树的结构，如果元素达到一定量，原有的数组会改成红黑树来表示。这么改的原因是让数据能够比较平均地分布到散列表中，查询也能够更快，从原有的O(n)降至O(log(n))，提高性能
2. 取消了Segment。取消了Segment也就是取消了重入锁，直接采用 volatile HashEntry来申明变量。这样一来，每个数据都有保障，也减少了冲突的概率

ConcurrentHashmap 中，hashCode也有其定义。hashCode 在判断2个对象是否相等，或者容器中判断对象是否相等比较有用（key 为 object的时候，就需要更改equals，也要更改hashCode

```java
    public int hashCode() {
        int h = 0;
        Node<K,V>[] t;
        if ((t = table) != null) {
            Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
            for (Node<K,V> p; (p = it.advance()) != null; )
                h += p.key.hashCode() ^ p.val.hashCode();
        }
        return h;
    }
```

#### get

切记 get 方法是不用加锁的，由于本身的数组已经申明了 volatile，通过 happens before 原理保证了数据不会冲突

```java
transient volatile Node<K,V>[] table;

public V get(Object key) {
        Node<K,V>[] tab; Node<K,V> e, p; int n, eh; K ek;
        int h = spread(key.hashCode());
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (e = tabAt(tab, (n - 1) & h)) != null) {
            if ((eh = e.hash) == h) {
                if ((ek = e.key) == key || (ek != null && key.equals(ek)))
                    return e.val;
            }
            else if (eh < 0)
                return (p = e.find(h, key)) != null ? p.val : null;
            while ((e = e.next) != null) {
                if (e.hash == h &&
                    ((ek = e.key) == key || (ek != null && key.equals(ek))))
                    return e.val;
            }
        }
        return null;
    }
```

#### put

插入操作，除了扩容和插入之外，还需要判断是否需要转换成红黑树。插入的过程可以看到使用了 sychronized 关键字。加上addCount的方法，实际上就是使用了CAS+sychronized共同实现的
另外， sychronized 虽然效率低，但他也是**可重入锁**。

```java
final V putVal(K key, V value, boolean onlyIfAbsent) {
        if (key == null || value == null) throw new NullPointerException();
        int hash = spread(key.hashCode());
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh; K fk; V fv;
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
                if (casTabAt(tab, i, null, new Node<K,V>(hash, key, value)))
                    break;                   // no lock when adding to empty bin
            }
            else if ((fh = f.hash) == MOVED)
                tab = helpTransfer(tab, f);
            else if (onlyIfAbsent // check first node without acquiring lock
                     && fh == hash
                     && ((fk = f.key) == key || (fk != null && key.equals(fk)))
                     && (fv = f.val) != null)
                return fv;
            else {
                V oldVal = null;
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                                K ek;
                                if (e.hash == hash &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    oldVal = e.val;
                                    if (!onlyIfAbsent)
                                        e.val = value;
                                    break;
                                }
                                Node<K,V> pred = e;
                                if ((e = e.next) == null) {
                                    pred.next = new Node<K,V>(hash, key, value);
                                    break;
                                }
                            }
                        }
                        else if (f instanceof TreeBin) {
                            Node<K,V> p;
                            binCount = 2;
                            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                           value)) != null) {
                                oldVal = p.val;
                                if (!onlyIfAbsent)
                                    p.val = value;
                            }
                        }
                        else if (f instanceof ReservationNode)
                            throw new IllegalStateException("Recursive update");
                    }
                }
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    if (oldVal != null)
                        return oldVal;
                    break;
                }
            }
        }
        addCount(1L, binCount);
        return null;
    }

```

#### size

官方说如果想计数还是使用 mappingCount() 好...

```java
public int size() {
    long n = sumCount();
    return ((n < 0L) ? 0 :
            (n > (long)Integer.MAX_VALUE) ? Integer.MAX_VALUE :
                (int)n);
}

final long sumCount() {
    CounterCell[] cs = counterCells;
    long sum = baseCount;
    if (cs != null) {
        for (CounterCell c : cs)
            if (c != null)
                sum += c.value;
    }
    return sum;
}
```

counterCells是个全局的变量，表示的是CounterCell类数组。CounterCell是ConcurrentHashmap的内部类，它就是存储一个值。1.8中使用一个volatile类型的变量baseCount记录元素的个数，当插入新数据put()或则删除数据remove()时，会通过addCount()方法更新baseCount初始化时counterCells为空，在并发量很高时，如果存在两个线程同时执行CAS修改baseCount值，则失败的线程会继续执行方法体中的逻辑，执行fullAddCount(x, uncontended)方法，这个方法其实就是初始化counterCells，并将x的值插入到counterCell类中，而x值一般也就是1
所以counterCells存储的都是value为1的CounterCell对象，而这些对象是因为在CAS更新baseCounter值时，由于高并发而导致失败，最终将值保存到CounterCell中，放到counterCells里。这也就是为什么sumCount()中需要遍历counterCells数组，sum累加CounterCell.value值了。

# 小结

工作一年，感觉技术退步了不少，原来张口就来的东西现在说的结结巴巴，原来提手就写的代码，现在还要想想