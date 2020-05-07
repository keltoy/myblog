---
title: Source Code in Java -- Integer
date: 2016-10-11 00:41:30
tags: [code, java, source code]
---

# 前言

> Most of you are familiar with the virtues of a programmer. There are three, of course: laziness, impatience, and hubris.
> -- Larry Wall

细细数来，我好像还没有做过源码的东西，不看看优秀的源码，如何才能够有长远的进步呢？就从 Java 开始，边看边总结这些源码。先看Integer。

# 初识 Integer

首先Integer是一个类，包装 int 的类，为了更好地和其他方法和范型配合，所以需要把基础类型包装成一个类。既然是类当然就可以设置为 null，这是基本类型做不到的，基本类型初始化也只能是 0。
Integer 和 int 在实际操作过程中是可以相等的，Integer 在匹配 int 类型的数据的时候，就会自动装箱和拆箱。
基本上，我对 Integer 的理解也就到这个程度。这样就可以理解为什么以下的结果有所不同：

```java
int i  = 0;
Integer i2 = 0;
Integer i3 = new Integer(0);
Integer i4 = new Integer(0);
Integer i5 = 0;
System.out.println(i == i2); // true
System.out.println(i == i3); // true
System.out.println(i4 == i3); // false
System.out.println(i5 == i2); // true
```
理由其实很简单，每次和整型的操作都有装箱或者拆箱的过程，实际上的值比的就是值；而 new 一个实例这时候就是一个对象，则不完成自动拆箱的过程，也就不会相等了。

# 思考 Integer

但是，就这样还不够。Integer 的内部原理都没有出来，内部的自动装箱和拆箱是如何实现的。这些问题都没看过，很容易出问题。比如说：

```java
        int i0 = 0;
        int j0 = 0;
        Integer i1 = 0;
        Integer i2 = 0;
        Integer i3 = new Integer(0);
        Integer i4 = new Integer(0);
        Integer j1 = 128;
        Integer j2 = 128;
        Integer j3 = new Integer(128);
        Integer j4 = new Integer(128);

        System.out.println("i0 == i1: " + (i0 == i1));
        System.out.println("i0 == i3: " + (i0 == i3));
        System.out.println("i1 == i2: " + (i2 == i1));
        System.out.println("i1 == i3: " + (i1 == i3));
        System.out.println("i3 == i4: " + (i3 == i4));


        System.out.println("j0 == j1: " + (j0 == j1));
        System.out.println("j0 == j3: " + (j0 == j3));
        System.out.println("j1 == j2: " + (j2 == j1));
        System.out.println("j1 == j3: " + (j1 == j3));
        System.out.println("j3 == j4: " + (j3 == j4));
```
结果是：

    i0 == i1: true
    i0 == i3: true
    i1 == i2: true
    i1 == i3: false
    i3 == i4: false
    j0 == j1: false
    j0 == j3: false
    j1 == j2: false
    j1 == j3: false
    j3 == j4: false

说明一下，测试数据的时候，我的 JDK 版本为 1.8。
我当时觉得很奇妙，按理说 i0 == i1 和 j0 == j1 应该没有什么区别，为什么一个是 true，一个是 false？我当时的理解是，肯定有一个做了拆箱操作，另一个实际上是对象的比较。如果这样的猜测是正确的，那么也就是说拆箱操作是有选择的。
于是，对于这样的猜测，我看了一下字节码：
```java
        byte i0 = 0;
        byte j0 = 0;
        Integer i1 = Integer.valueOf(0);
        Integer i2 = Integer.valueOf(0);
        Integer i3 = new Integer(0);
        Integer i4 = new Integer(0);
        Integer j1 = Integer.valueOf(128);
        Integer j2 = Integer.valueOf(128);
        Integer j3 = new Integer(128);
        Integer j4 = new Integer(128);
        System.out.println("i0 == i1: " + (i0 == i1.intValue()));
        System.out.println("i0 == i3: " + (i0 == i3.intValue()));
        System.out.println("i1 == i2: " + (i2 == i1));
        System.out.println("i1 == i3: " + (i1 == i3));
        System.out.println("i3 == i4: " + (i3 == i4));
        System.out.println("j0 == j1: " + (j0 == j1.intValue()));
        System.out.println("j0 == j3: " + (j0 == j3.intValue()));
        System.out.println("j1 == j2: " + (j2 == j1));
        System.out.println("j1 == j3: " + (j1 == j3));
        System.out.println("j3 == j4: " + (j3 == j4));
```
可以看出拆箱的过程就是使用 Integer.valueOf()的过程。现在转入 Integer 类中查看这是如何操作的：
```java
/**
     * Returns an {@code Integer} instance representing the specified
     * {@code int} value.  If a new {@code Integer} instance is not
     * required, this method should generally be used in preference to
     * the constructor {@link #Integer(int)}, as this method is likely
     * to yield significantly better space and time performance by
     * caching frequently requested values.
     *
     * This method will always cache values in the range -128 to 127,
     * inclusive, and may cache other values outside of this range.
     *
     * @param  i an {@code int} value.
     * @return an {@code Integer} instance representing {@code i}.
     * @since  1.5
     */
    public static Integer valueOf(int i) {
        if (i >= IntegerCache.low && i <= IntegerCache.high)
            return IntegerCache.cache[i + (-IntegerCache.low)];
        return new Integer(i);
    }
```
这段代码倒是简单，上面的注释看起来好像很重要。大概意思是说`从 1.5以后java的包装类支持自动装箱操作了，时间和空间都还不错，调用这个方法总是缓存 -128 到 127 的结果，也可以韩村这个范围之外的其他值。`
为什么是 -128 到 127， 还有，IntegerCache又是什么？围绕这两个问题，继续跳转，发现 IntegerCache实际上就在当前文件里，属于 Integer的一个内部类：
```java
/**
     * Cache to support the object identity semantics of autoboxing for values between
     * -128 and 127 (inclusive) as required by JLS.
     *
     * The cache is initialized on first usage.  The size of the cache
     * may be controlled by the {@code -XX:AutoBoxCacheMax=<size>} option.
     * During VM initialization, java.lang.Integer.IntegerCache.high property
     * may be set and saved in the private system properties in the
     * sun.misc.VM class.
     */

    private static class IntegerCache {
        static final int low = -128;
        static final int high;
        static final Integer cache[];

        static {
            // high value may be configured by property
            int h = 127;
            String integerCacheHighPropValue =
                sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
            if (integerCacheHighPropValue != null) {
                try {
                    int i = parseInt(integerCacheHighPropValue);
                    i = Math.max(i, 127);
                    // Maximum array size is Integer.MAX_VALUE
                    h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
                } catch( NumberFormatException nfe) {
                    // If the property cannot be parsed into an int, ignore it.
                }
            }
            high = h;

            cache = new Integer[(high - low) + 1];
            int j = low;
            for(int k = 0; k < cache.length; k++)
                cache[k] = new Integer(j++);

            // range [-128, 127] must be interned (JLS7 5.1.7)
            assert IntegerCache.high >= 127;
        }

        private IntegerCache() {}
    }

```

还是先看注释，上来就说 `cache 是支持自动装包的对象同等语义，Java语言规范 (Java Language Specification, JLS) 规定了其范围是-128, 127，cache在第一次使用的时候初始化，可以使用 -XX:AutoBoxCacheMax=<size> 更改cache的high，保存到 sun.misc.VM 类中。`
代码开起来比较简单，就是初始化一下。
那就是说，如果是 大于 -128， 小于 127，那么valueOf直接从 cache 中取出值，否则呢就创建一个Integer的对象：
```java
/**
    * The value of the {@code Integer}.
    *
    * @serial
    */
   private final int value;

   /**
    * Constructs a newly allocated {@code Integer} object that
    * represents the specified {@code int} value.
    *
    * @param   value   the value to be represented by the
    *                  {@code Integer} object.
    */
   public Integer(int value) {
       this.value = value;
   }

   /**
        * Returns the value of this {@code Integer} as an
        * {@code int}.
        */
   public int intValue() {
        return value;
   }
```
没啥说的。

# 再识 Integer

貌似解决了上面的例子为什么会产生不同值，到这里应该不会再出错了。但是还没有结束。这么做有什么好处？为什么要这样设计？
如果使用 Integer 装箱的值超出了 cache 的范围，那么就会创建一个 Integer 对象，那么这个对象应该会被放到 JVM 的 Heap 上；而 cache 本身，因为是 final 类型，本身也是存在于 内部静态类中，所以我想应该是放在了 Method Area 的 Runtime Constant pool 中了吧？ 如果是这样的话，确实在范围内的速度要比范围外的稍微快一些。注意到这里的cache 使用了 flyweight pattern，也就是说，这么做带来的好处应该有是如果是更快地装箱和拆箱，节省内存，往大了说，减少 GC 的工作。那么为什么这么设计？我在 [JLS](http://docs.oracle.com/javase/specs/jls/se8/html/jls-5.html#jls-5.1.7) 中找到了这么一段话。

If the value p being boxed is an integer literal of type int between -128 and 127 inclusive (§3.10.1), or the boolean literal true or false (§3.10.3), or a character literal between '\u0000' and '\u007f' inclusive (§3.10.4), then let a and b be the results of any two boxing conversions of p. It is always the case that a == b.

Ideally, boxing a primitive value would always yield an identical reference. In practice, this may not be feasible using existing implementation techniques. The rule above is a pragmatic compromise, requiring that certain common values always be boxed into indistinguishable objects. The implementation may cache these, lazily or eagerly. For other values, the rule disallows any assumptions about the identity of the boxed values on the programmer's part. This allows (but does not require) sharing of some or all of these references. Notice that integer literals of type long are allowed, but not required, to be shared.

This ensures that in most common cases, the behavior will be the desired one, without imposing an undue performance penalty, especially on small devices. Less memory-limited implementations might, for example, cache all char and short values, as well as int and long values in the range of -32K to +32K.

A boxing conversion may result in an OutOfMemoryError if a new instance of one of the wrapper classes (Boolean, Byte, Character, Short, Integer, Long, Float, or Double) needs to be allocated and insufficient storage is available.

大概就是为了兼容一些小型设备吧....

# 三识 Integer

那么为什么要设计 Integer 这个类呢，原因貌似挺简单的，因为 Java 并不是一个纯面向对象的语言，如果是 ruby 应该不用这么麻烦，但是为了兼容基本类型，所以才需要这样的包装类。

那么既然要设计这样一个类，为什么还是个不变的类型？虽然不变类型有很多好处，但是像 i++ 这样的操作还需要拆箱、新建、装箱繁琐的操作后才行，为什么设计的时候不能设计成可变的类型呢？
我觉得既然 Integer 是 int 的包装类，是不是也要兼容 int 的一些属性呢？因为常识中，1 != 2 ，不管怎么说 1 也变不到 2 吧；如果设计成了可变的，那么多线程就会出现很多问题，需要考虑线程安全，有可能会出现 race condition 吧；还有就是，String 是不变的，为了兼容这一堆的转换，也不能设计成可变的吧。如果真想用可变的，其实 concurrent.atomic 包下的 AtomicInteger 应该能够满足需求了吧？

# 结语

以前一直以为源码是很晦涩很难懂的，所以一直没有勇气把源码读完，今天这个是一个尝试，以后还会读取更多的源码。个人虽然不是很喜欢Java的臃肿，但是它的设计的确很好，能够学到很多东西。这次只是介绍了几个方法，其实这个类中的方法还挺多的，但我觉得这个还是要自己看看，其他方法大同小异，主要是吸取它的优秀思想和设计。

# 参考
[java integer pool why](http://www.4byte.cn/question/645476/java-integer-pool-why.html)

[JLS](http://docs.oracle.com/javase/specs/jls/se8/html/jls-5.html#jls-5.1.7)

[why do we have both Integer and int ](https://www.quora.com/In-Java-why-do-we-have-both-Integer-and-int)

[why integer in java is immutable](http://stackoverflow.com/questions/22793616/why-integer-in-java-is-immutable)
