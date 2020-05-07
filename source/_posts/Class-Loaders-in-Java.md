---
title: Class Loaders in Java
date: 2016-10-13 12:13:07
tags: [code, java]
---
# 前言

好像一直没搞明白，但是每次都会被问到，总结总结，看看自己的理解到哪一步了。

# 初识 Class Loaders

首先，类加载器的架构：

```
+-----------------+
|                 |
| +-------------+ |              +--------------------------------+
| | Bootstrap   | | >>>>>>>>>>>> | Load JRE/lib/rt.jar            |
| | ClassLoader | | >>>>>>>>>>>> | specified by -Xbootclasspath   |
| +-------------+ |              +--------------------------------+
|                 |
| +-------------+ |              +--------------------------------+
| | Extension   | | >>>>>>>>>>>> | Load JRE/lib/ext/*.jar         |
| | ClassLoader | | >>>>>>>>>>>> | specified by -Djava.ext.dirs   |
| +-------------+ |              +--------------------------------+
|                 |
| +-------------+ |              +--------------------------------+
| | App         | | >>>>>>>>>>>> | Load CLASSPATH                 |
| | ClassLoader | | >>>>>>>>>>>> | specified by -Djava.class.path |
| +-------------+ |              +--------------------------------+
|                 |
| +-------------+ |              +--------------------------------+
| | Custom      | | >>>>>>>>>>>> | Use subclass of                |
| | ClassLoader | | >>>>>>>>>>>> | java.lang.ClassLoader          |
| +-------------+ |              +--------------------------------+
|                 |
+-----------------+
```

* Bootstrap ClassLoader
负责加载$JAVA_HOME中jre/lib/rt.jar里所有的class，由C++实现，不是ClassLoader子类;

* Extension ClassLoader
负责加载java平台中扩展功能的一些jar包，包括$JAVA_HOME中jre/lib/*.jar或-Djava.ext.dirs指定目录下的jar包;

* App ClassLoader
负责记载classpath中指定的jar包及目录中class;

* Custom ClassLoader
属于应用程序根据自身需要自定义的ClassLoader，如tomcat、jboss都会根据J2EE规范自行实现ClassLoader.


加载过程中会先检查类是否被已加载，检查顺序是自底向上，从Custom ClassLoader到BootStrap ClassLoader逐层检查，只要某个classloader已加载就视为已加载此类，保证此类只所有ClassLoader加载一次。而加载的顺序是自顶向下，也就是由上层来逐层尝试加载此类。这个过程叫做双亲委派制度。

# 思考 Class Loaders

看起来就是这么回事。既然知道了有这么多 ClassLoader 类，那我忍不住要问类是如何加载的？翻一翻讲 ClassLoader 的书，或者博客，他们都会告诉我分为三个部分：

1. 加载：查找并加载类的二进制数据；
2. 链接，分为三步；
 + 验证：确保被加载类的正确性；
 + 准备：为类的静态变量分配内存，并将其初始化为默认值；
 + 解析：把类中的符号引用转换为直接引用；
3. 初始化：为类的静态变量赋予正确的初始值。

嗯嗯。

# 再识 Class Loaders

我们知道，Java 类的生命周期分为 7 个阶段：

    加载 -> 验证 -> 准备 -> 解析 -> 初始化 -> 使用 -> 卸载

这个其实我才知道...
而这其中，验证、准备和解析统称为链接。
加载、验证、准备、初始化还有卸载这五个阶段的顺序是确定的。
解析有可能在初始化后才执行，说是为了执行 java 类的运行时绑定，呃，说是什么就是什么吧...
这里说一下，Java 在编译过程中，实际上只是生成 .class 文件，也就是生成了字节码，然后再使用JVM进行解释。虽然有JIT优化，把 .class 文件的二进制代码编译成本地代码直接运行，但是从原理来讲，还是解释型的。

## 加载

什么情况下对类加载？这个我在 [Java 虚拟机规范 (The Java® Virtual Machine Specification)](http://docs.oracle.com/javase/specs/jvms/se8/html/index.html) 没有找到确定的情况，但是这个操作是在初始化之前的。有人说加载过程交给 JVM 实现自由把握，不论怎么说，类的加载就是在虚拟机开始后，通过调用 Class Loaders 加载了类。

## 链接

链接分为验证、准备和解析三个部分，JVMS 中原话是这么说的：

>Linking a class or interface involves verifying and preparing that class or interface, its direct superclass, its direct superinterfaces, and its element type (if it is an array type), if necessary. Resolution of symbolic references in the class or interface is an optional part of linking.
>This specification allows an implementation flexibility as to when linking activities (and, because of recursion, loading) take place, provided that all of the following properties are maintained:
>A class or interface is completely loaded before it is linked.
>A class or interface is completely verified and prepared before it is initialized.
>Errors detected during linkage are thrown at a point in the program where some action is taken by the program that might, directly or indirectly, require linkage to the class or interface involved in the error.
>For example, a Java Virtual Machine implementation may choose to resolve each symbolic reference in a class or interface individually when it is used ("lazy" or "late" resolution), or to resolve them all at once when the class is being verified ("eager" or "static" resolution). This means that the resolution process may continue, in some implementations, after a class or interface has been initialized. Whichever strategy is followed, any error detected during resolution must be thrown at a point in the program that (directly or indirectly) uses a symbolic reference to the class or interface.
>Because linking involves the allocation of new data structures, it may fail with an OutOfMemoryError.

大概意思就是说，链接包括验证和准备这两个类或接口，以及他们的直接父类和接口，还有数组类型的元素类型。解析不一定在链接里。
链接的时机灵活，但必须满足以下几点：
* 类或接口链接之前，必须被成功加载过；
* 类或接口初始化之前， 必须被成功验证和准备过；
* 程序执行了某种可能需要直接或间接链接一个类或接口的动作，在链接该类或接口过程中检测到了错误，错误的抛出点应该是执行动作的那个点。

这个过程可能会引发OutOfMemoryError。

我的理解就是，链接的开始必须在加载开始之后，在初始化之前完成。

## 验证

以下的内容是我在网上找到的一些内容，虚拟机规范是在太长了，等慢慢看完了再来了解这方面的内容。

>验证是连接阶段的第一步，这一阶段的目的是为了确保Class文件的字节流中包含的信息符合当前虚拟机的要求，并且不会危害虚拟机自身的安全。
>Java语言本身是相对安全的语言，使用Java编码是无法做到如访问数组边界以外的数据、将一个对象转型为它并未实现的类型等，如果这样做了，编译器将拒绝编译。但是，Class文件并不一定是由Java源码编译而来，可以使用任何途径，包括用十六进制编辑器(如UltraEdit)直接编写。如果直接编写了有害的“代码”(字节流)，而虚拟机在加载该Class时不进行检查的话，就有可能危害到虚拟机或程序的安全。
>不同的虚拟机，对类验证的实现可能有所不同，但大致都会完成下面四个阶段的验证 ：文件格式验证、元数据验证、字节码验证和符号引用验证。
>1. 文件格式验证，是要验证字节流是否符合Class文件格式的规范，并且能被当前版本的虚拟机处理。如验证魔数是否0xCAFEBABE；主、次版本号是否正在当前虚拟机处理范围之内；常量池的常量中是否有不被支持的常量类型……该验证阶段的主要目的是保证输入的字节流能正确地解析并存储于方法区中，经过这个阶段的验证后，字节流才会进入内存的方法区中存储，所以后面的三个验证阶段都是基于方法区的存储结构进行的。
>2. 元数据验证，是对字节码描述的信息进行语义分析，以保证其描述的信息符合Java语言规范的要求。可能包括的验证如：这个类是否有父类；这个类的父类是否继承了不允许被继承的类；如果这个类不是抽象类，是否实现了其父类或接口中要求实现的所有方法……
>3. 字节码验证，主要工作是进行数据流和控制流分析，保证被校验类的方法在运行时不会做出危害虚拟机安全的行为。如果一个类方法体的字节码没有通过字节码验证，那肯定是有问题的；但如果一个方法体通过了字节码验证，也不能说明其一定就是安全的。
>4. 符号引用验证，发生在虚拟机将符号引用转化为直接引用的时候，这个转化动作将在“解析阶段”中发生。验证符号引用中通过字符串描述的权限定名是否能找到对应的类；在指定类中是否存在符合方法字段的描述符及简单名称所描述的方法和字段；符号引用中的类、字段和方法的访问性(private、protected、public、default)是否可被当前类访问。

>验证阶段对于虚拟机的类加载机制来说，不一定是必要的阶段。如果所运行的全部代码确认是安全的， 可以使用 -Xverify：none 参数来关闭大部分的类验证措施，以缩短虚拟机类加载时间。

## 准备

继续查看规范：


>Preparation involves creating the static fields for a class or interface and initializing such fields to their default values (§2.3, §2.4). This does not require the execution of any Java Virtual Machine code; explicit initializers for static fields are executed as part of initialization (§5.5), not preparation.

这个阶段是创建类或接口的静态字段，不执行任何字节码指令。初始化阶段会有显示的初始化器来初始化这些字段，所以准备阶段不初始化字段。
这里有个小问题就是，准备阶段不初始化，但是他会给定这些静态字段的缺省值，比如 0，null。
静态代码实际上是存在 Method Area 中的。

## 解析

继续查看规范：

>The Java Virtual Machine instructions anewarray, checkcast, getfield, getstatic, instanceof, invokedynamic, invokeinterface, invokespecial, invokestatic, invokevirtual, ldc, ldc_w, multianewarray, new, putfield, and putstatic make symbolic references to the run-time constant pool. Execution of any of these instructions requires resolution of its symbolic reference.
>Resolution is the process of dynamically determining concrete values from symbolic references in the run-time constant pool.

虚拟机指令将符号引用指向 run-time constant pool。
解析就是根据 run-time constant pool 里的符号引用来动态决定具体值的过程。
好绕口，什么是符号引用？
看一看别人的博客，是这么介绍的：

> 解析阶段是虚拟机将常量池内的符号引用替换为直接引用的过程。
>符号引用（Symbolic Reference）：符号引用以一组符号来描述所引用的目标，符号可以是任何形式的字面量，只要使用时能无歧义地定位到目标即可。符号引用与虚拟机实现的内存布局无关，引用的目标并不一定已经加载到内存中。
>直接引用（Direct Reference）：直接引用可以是直接指向目标的指针、相对偏移量或是一个能间接定位到目标的句柄。直接引用是与虚拟机实现的内存布局相关的，如果有了直接引用，那么引用的目标必定已经在内存中存在。

## 初始化

什么情况初始化，虚拟机规范有明确的要求：

>Initialization of a class or interface consists of executing its class or interface initialization method (§2.9).

>A class or interface C may be initialized only as a result of:

>· The execution of any one of the Java Virtual Machine instructions new, getstatic, putstatic, or invokestatic that references C (§new, §getstatic, §putstatic, §invokestatic). These instructions reference a class or interface directly or indirectly through either a field reference or a method reference.
>Upon execution of a new instruction, the referenced class is initialized if it has not been initialized already.
>Upon execution of a getstatic, putstatic, or invokestatic instruction, the class or interface that declared the resolved field or method is initialized if it has not been initialized already.
>·The first invocation of a java.lang.invoke.MethodHandle instance which was the result of method handle resolution (§5.4.3.5) for a method handle of kind 2 (REF_getStatic), 4 (REF_putStatic), 6 (REF_invokeStatic), or 8 (REF_newInvokeSpecial).
>This implies that the class of a bootstrap method is initialized when the bootstrap method is invoked for an invokedynamic instruction (§invokedynamic), as part of the continuing resolution of the call site specifier.
>· Invocation of certain reflective methods in the class library (§2.12), for example, in class Class or in package java.lang.reflect.
>· If C is a class, the initialization of one of its subclasses.
>· If C is an interface that declares a non-abstract, non-static method, the initialization of a class that implements C directly or indirectly.
>· If C is a class, its designation as the initial class at Java Virtual Machine startup (§5.2).
>Prior to initialization, a class or interface must be linked, that is, verified, prepared, and optionally resolved.

就是说有这么几种情况，类或者接口会初始化：
* Java 虚拟机调用这些指令 new, getstatic, putstatic, or invokestatic,使用一个字段引用。个人理解就是创建实例的过程，例如 `Object obj = new Object` 这样。new 指令在引用的时候就初始化， 其他指令在申明解析字段和方法的时候进行初始化。
* java.lang.invoke.MethodHandle 实例的第一次调用，调用执行的结果为 JVM 解析出的方法句柄。
* 调用反射方法。
* 子类初始化之前，父类要初始化。
* 作为 JVM 启动初始类。

对于第二条关于 java.lang.invoke.MethodHandle 这一条不是很明白什么意思，所链接的 5.4.3.5 的介绍也都是在介绍解析。不过从方法上可以看出来，这一条应该是跟静态方法，或者说类方法有很大关系。这里偷个懒，从之前的博客中找到了一些蛛丝马迹：

>访问类的静态变量 (除常量【 被final修辞的静态变量】 原因:常量一种特殊的变量，因为编译器把他们当作值(value)而不是域(field)来对待。如果你的代码中用到了常变量(constant variable)，编译器并不会生成字节码来从对象中载入域的值，而是直接把这个值插入到字节码中。这是一种很有用的优化，但是如果你需要改变final域的值那么每一块用到那个域的代码都需要重新编译。
>访问类的静态方法

也就是说，静态方法和静态变量的调用也会初始化类。

>类初始化是类加载过程的最后一步，前面的类加载过程，除了在加载阶段用户应用程序可以通过自定义类加载器参与之外，其余动作完全由虚拟机主导和控制。到了初始化阶段，才真正开始执行类中定义的Java程序代码。
>初始化阶段是执行类构造器\<clinit\>()方法的过程。\<clinit\>()方法是由编译器自动 收集类中的所有类变量的赋值动作和静态语句块(static{}块)中的语句合并产生的 。


# 运行 Class Loaders

我们知道，类加载过程：
`父类静态初始化块 -> 子类静态初始化块 -> 父类非静态初始化块 ->父类的构造方法 -> 子类非静态初始化块 -> 子类的构造方法`
不过我还是想试试，这里借用别人的例子：
```java
public class Parent {

    public static int t = parentStaticMethod2();
    {
        System.out.println("父类非静态初始化块");
    }
    static
    {
        System.out.println("父类静态初始化块");
    }
    public Parent()
    {
        System.out.println("父类的构造方法");
    }
    public static int parentStaticMethod()
    {
        System.out.println("父类类的静态方法");
        return 10;
    }
    public static int parentStaticMethod2()
    {
        System.out.println("父类的静态方法2");
        return 9;
    }

    @Override
    protected void finalize() throws Throwable
    {
        // TODO Auto-generated method stub
        super.finalize();
        System.out.println("销毁父类");
    }

}
```
```java
public class Child extends Parent {
    private static int staticVirable = childStaticMethod2();
    {
        System.out.println("子类非静态初始化块");
    }
    static
    {
        System.out.println("子类静态初始化块");
    }
    public Child()
    {
        System.out.println("子类的构造方法");
    }
    public static int childStaticMethod()
    {
        System.out.println("子类的静态方法");
        return 1000;
    }
    public static int childStaticMethod2() {
        System.out.println("子类静态方法2");
        return 0;
        }
    @Override
    protected void finalize() throws Throwable
    {
        // TODO Auto-generated method stub
        super.finalize();
        System.out.println("销毁子类");
    }
}
```
```java
@org.junit.Test
public void testLoadOrder() {
    Child.parentStaticMethod();
}
```

很有意思的情况，它的输出是：

```
父类的静态方法2
父类静态初始化块
父类类的静态方法
```

虽然我调用的是 Child 类的方法，但是 Child 貌似并没有初始化。我个人觉得，这里的设计是不是跟 C++ 的 virtual table 差不多，只不过 Java 中所有的对象都是引用，因此都要建立这一张表呢？
不论如何，我们知道了调用父类的方法只会初始化父类，而不会初始化当前类。
继续观察结果，还会发现一些有意思的地方。我调用的是 parentStaticMethod，但是首先输出的是 parentStaticMethod2 的内容。也就是说，在类初始化之前，就已经调用了。因为 parentStaticMethod2 在静态变量中调用的，，也就说明了，静态变量要比类的初始化先完成。
原因是什么，我猜想是，静态变量应该是放在 Method Area 中，跟类的初始化是分离的，调用了静态变量之后，才会初始化类。
这里有人作出了解释：
>这是因为在编译的时候，常量（static final 修饰的）会存入调用类的常量池【一般说的是main函数所在的类的常量池】，调用的时候本质上没有引用到定义常量的类，而是直接访问了自己的常量池。所以，这里调用的时候，并没有初始化。

不过经过测试，貌似静态变量调用的时候也不会立即初始化。
那么更改一下输出：

```java
@org.junit.Test
public void testLoadOrder() {
    Child.parentStaticMethod2();
}
```

现加载常量池的变量
可以发现结果应该跟我们想的一样：

 ```
父类的静态方法2
父类静态初始化块
父类的静态方法2
 ```

现在引入子类的调用方法，写一个 Test ：

```java
@org.junit.Test
public void testLoadOrder2() {
    Child child = new Child();
}
```

输出的结果：

```
父类的静态方法2
父类静态初始化块
子类静态方法2
子类静态初始化块
父类非静态初始化块
父类的构造方法
子类非静态初始化块
子类的构造方法
```

可以看出，static 变量 和 static 块先进行初始化，然后再执行非静态和构造函数。必须等待 static 的数据父类和子类都处理结束，才会进行非 static 的初始化，也就是实例的初始化是在所有类 初始化的后面。

# 再思 Class Loaders

初始化顺序的问题结束了，还需要总结一下。这里我就不总结了，直接拿别人的总结，不过这些内容我没有在 Java虚拟机规范中找到。

>触发类初始化的上述的几条的引用称为“主动引用” ，除此情况之外，均不会触发类的初始化，称为 “被动引用”。
> 接口的加载过程与类的加载过程稍有不同。接口中不能使用static{}块。当一个接口在初始化时，并不要求其父接口全部都完成了初始化，只有真正在使用到父接口时（例如引用接口中定义的常量）才会初始化。
>子类调用父类的静态变量，子类不会被初始化。只有父类被初始化。 。 对于静态字段，只有直接定义这个字段的类才会被初始化.
>通过数组定义来引用类，不会触发类的初始化
>访问类的常量，不会初始化类
>
# 三识 Class Loaders

既然明白了这些，感觉应该很透彻了。
那么，执行这样一段代码：

```java
public class ClassLoaderSingleton {
    private static ClassLoaderSingleton singleton = new ClassLoaderSingleton();
    public static int count1;
    public static int count2 = 0;

    private ClassLoaderSingleton() {
        count1++;
        count2++;
    }

    public static ClassLoaderSingleton getInstance() {
        return singleton;
    }

}

public class Main {
    public static void main(String[] args) {
        ClassLoaderSingleton singleton = ClassLoaderSingleton.getInstance();
        System.out.println("count1=" + singleton.count1);
        System.out.println("count2=" + singleton.count2);
    }
}
```
输出的结果为：

```
count1=1
count2=0
```

这样应该不会再出错了。
* singleton 调用 getInstance()， 调用了静态类方法，触发类初始化。
* 准备过程中为变量赋默认值。
* 类的静态变量分配内存并且执行静态方法，这个时候， singleton = null; count1 = 0; count2 = 0;
* 类初始化，为静态变量和执行静态代码块。然后执行构造方法。调用构造方法后 count1 = 1; count2 = 1;
* 然后继续赋值，此时 count1 没有赋值操作，所以 count1 = 1; count2 有值，所以 count2 = 0;

# 三思 Class Loaders

本以为看到这里应该不会再出现问题了，发现自己太连清了...

```java
public class ClassLoaderLimit {
    int a = 4;
    static {
        b = 2;
        System.out.println("init");
        System.out.println(b); // 编译错误
    }
    static int b = 0;
    public static final String hello = "Hello World";
}
```
这样是不能编译的，原因是：

>这是因为在类初始化的时候，就规定了，静态语句块中只能访问到定义在静态语句块之前的变量，定义在它之后的，只能赋值，不能访问。

也就是说 static 块是要保证顺序的，只要把 static int b 放到 static 块之前就可以了。

# 总结

原本只是想写写执行顺序和运行周期，然后发现越拉越长，遇到的问题也越来越多....代码都是拷贝他人的，但是能够解决问题就好。
最后盗了一张图，看图说话...
![Java 编译和运行](http://odzz59auo.bkt.clouddn.com/classloader.png)
# 参考

[The Java® Virtual Machine Specification](http://docs.oracle.com/javase/specs/jvms/se8/html/)

[从一道面试题来认识java类加载时机与过程 - 天魂地煞](http://www.tuicool.com/articles/QZnENv)

[Java 类的加载时机](http://blog.csdn.net/imzoer/article/details/8038249)

[Java 中类的加载顺序](http://www.cnblogs.com/guoyuqiangf8/archive/2012/10/31/2748909.html)

[Java 程序编译和运行的过程](http://www.360doc.com/content/14/0218/23/9440338_353675002.shtml)
