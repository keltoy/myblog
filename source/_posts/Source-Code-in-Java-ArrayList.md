---
title: Source Code in Java -- ArrayList
date: 2016-10-25 23:46:28
tags: [code, java, source code]
---

# 前言

ArrayList，相信大家都不陌生了，它的源码网上也是到处都是，但是我还是想看看，也许会有不一样的发现。

# 初识 ArrayList

ArrayList，顺序列表，非线程安全的，基本用法和数组类似，但是可以扩容。默认初始大小为 10， 扩容大小为  1.5 倍。基本上就这么多。本身构造也简单。

# 思考 ArrayList

为什么会出现 ArrayList 这个类呢，数组不能够满足要求吗？除了可以扩容，他跟数组有什么区别呢？
扩容为什么是 1.5 倍？
初始大小为什么是 10？

# ArrayList 源码

## ArrayList 变量

基于 1.8 的源码，基本上也没太多可说的，主要针对查找、添加、删除、以及扩容方面进行了解。
首先是 ArrayList 的属性。

```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
{
    private static final long serialVersionUID = 8683452581122892189L;

    /**
     * Default initial capacity.
     */
    private static final int DEFAULT_CAPACITY = 10;

    /**
     * Shared empty array instance used for empty instances.
     */
    private static final Object[] EMPTY_ELEMENTDATA = {};

    /**
     * Shared empty array instance used for default sized empty instances. We
     * distinguish this from EMPTY_ELEMENTDATA to know how much to inflate when
     * first element is added.
     */
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

    /**
     * The array buffer into which the elements of the ArrayList are stored.
     * The capacity of the ArrayList is the length of this array buffer. Any
     * empty ArrayList with elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA
     * will be expanded to DEFAULT_CAPACITY when the first element is added.
     */
    transient Object[] elementData; // non-private to simplify nested class access

    /**
     * The size of the ArrayList (the number of elements it contains).
     *
     * @serial
     */
    private int size;
```

可以看出，ArrayList 支持随机访问，支持序列化，以及拷贝；serialVersionUID 这个变量就是用来实现序列化的。

>简单来说，Java的序列化机制是通过在运行时判断类的serialVersionUID来验证版本一致性的。在进行反序列化时，JVM会把传来的字节流中的serialVersionUID与本地相应实体（类）的serialVersionUID进行比较，如果相同就认为是一致的，可以进行反序列化，否则就会出现序列化版本不一致的异常(InvalidCastException)。

DEFAULT_CAPACITY 定义了初始化容器的大小为 10。也没说为什么，可能和经验有关系。
EMPTY_ELEMENTDATA 定义了一个空数据。DEFAULTCAPACITY_EMPTY_ELEMENTDATA 定义了默认容器空数据。
这俩参数通过注释得知，EMPTY_ELEMENTDATA 是保证所有空数据共享；DEFAULTCAPACITY_EMPTY_ELEMENTDATA 是共享默认大小的空实例。这个实例与之前 EMPTY_ELEMENTDATA 的实例区别在在第一次扩容的时候这个实例才会有所更改。我的理解可能会节省不少空间吧？而且放在 Method Area 中的 runtime constant pool 中，也节约了 gc 的时间？ 以上是我的猜测。
elementData 应该是真正放置数据的地方，注意到的是这个变量使用了 `transient` 也就是数据不会被序列化/反序列化。这么一来，是不能使用序列化对数据进行传输了。然而，根据经验，ArrayList事实上是可以序列化的。个人猜测，可能是重写了序列化实现的方法。
不过我看了看 Serializable 的接口发现里面其实没有申明方法：

```java
package java.io;

/**
 * Serializability of a class is enabled by the class implementing the
 * java.io.Serializable interface. Classes that do not implement this
 * interface will not have any of their state serialized or
 * deserialized.  All subtypes of a serializable class are themselves
 * serializable.  The serialization interface has no methods or fields
 * and serves only to identify the semantics of being serializable. <p>
 *
 * To allow subtypes of non-serializable classes to be serialized, the
 * subtype may assume responsibility for saving and restoring the
 * state of the supertype's public, protected, and (if accessible)
 * package fields.  The subtype may assume this responsibility only if
 * the class it extends has an accessible no-arg constructor to
 * initialize the class's state.  It is an error to declare a class
 * Serializable if this is not the case.  The error will be detected at
 * runtime. <p>
 *
 * During deserialization, the fields of non-serializable classes will
 * be initialized using the public or protected no-arg constructor of
 * the class.  A no-arg constructor must be accessible to the subclass
 * that is serializable.  The fields of serializable subclasses will
 * be restored from the stream. <p>
 *
 * When traversing a graph, an object may be encountered that does not
 * support the Serializable interface. In this case the
 * NotSerializableException will be thrown and will identify the class
 * of the non-serializable object. <p>
 *
 * Classes that require special handling during the serialization and
 * deserialization process must implement special methods with these exact
 * signatures:
 *
 * <PRE>
 * private void writeObject(java.io.ObjectOutputStream out)
 *     throws IOException
 * private void readObject(java.io.ObjectInputStream in)
 *     throws IOException, ClassNotFoundException;
 * private void readObjectNoData()
 *     throws ObjectStreamException;
 * </PRE>
 *
 * <p>The writeObject method is responsible for writing the state of the
 * object for its particular class so that the corresponding
 * readObject method can restore it.  The default mechanism for saving
 * the Object's fields can be invoked by calling
 * out.defaultWriteObject. The method does not need to concern
 * itself with the state belonging to its superclasses or subclasses.
 * State is saved by writing the individual fields to the
 * ObjectOutputStream using the writeObject method or by using the
 * methods for primitive data types supported by DataOutput.
 *
 * <p>The readObject method is responsible for reading from the stream and
 * restoring the classes fields. It may call in.defaultReadObject to invoke
 * the default mechanism for restoring the object's non-static and
 * non-transient fields.  The defaultReadObject method uses information in
 * the stream to assign the fields of the object saved in the stream with the
 * correspondingly named fields in the current object.  This handles the case
 * when the class has evolved to add new fields. The method does not need to
 * concern itself with the state belonging to its superclasses or subclasses.
 * State is saved by writing the individual fields to the
 * ObjectOutputStream using the writeObject method or by using the
 * methods for primitive data types supported by DataOutput.
 *
 * <p>The readObjectNoData method is responsible for initializing the state of
 * the object for its particular class in the event that the serialization
 * stream does not list the given class as a superclass of the object being
 * deserialized.  This may occur in cases where the receiving party uses a
 * different version of the deserialized instance's class than the sending
 * party, and the receiver's version extends classes that are not extended by
 * the sender's version.  This may also occur if the serialization stream has
 * been tampered; hence, readObjectNoData is useful for initializing
 * deserialized objects properly despite a "hostile" or incomplete source
 * stream.
 *
 * <p>Serializable classes that need to designate an alternative object to be
 * used when writing an object to the stream should implement this
 * special method with the exact signature:
 *
 * <PRE>
 * ANY-ACCESS-MODIFIER Object writeReplace() throws ObjectStreamException;
 * </PRE><p>
 *
 * This writeReplace method is invoked by serialization if the method
 * exists and it would be accessible from a method defined within the
 * class of the object being serialized. Thus, the method can have private,
 * protected and package-private access. Subclass access to this method
 * follows java accessibility rules. <p>
 *
 * Classes that need to designate a replacement when an instance of it
 * is read from the stream should implement this special method with the
 * exact signature.
 *
 * <PRE>
 * ANY-ACCESS-MODIFIER Object readResolve() throws ObjectStreamException;
 * </PRE><p>
 *
 * This readResolve method follows the same invocation rules and
 * accessibility rules as writeReplace.<p>
 *
 * The serialization runtime associates with each serializable class a version
 * number, called a serialVersionUID, which is used during deserialization to
 * verify that the sender and receiver of a serialized object have loaded
 * classes for that object that are compatible with respect to serialization.
 * If the receiver has loaded a class for the object that has a different
 * serialVersionUID than that of the corresponding sender's class, then
 * deserialization will result in an {@link InvalidClassException}.  A
 * serializable class can declare its own serialVersionUID explicitly by
 * declaring a field named <code>"serialVersionUID"</code> that must be static,
 * final, and of type <code>long</code>:
 *
 * <PRE>
 * ANY-ACCESS-MODIFIER static final long serialVersionUID = 42L;
 * </PRE>
 *
 * If a serializable class does not explicitly declare a serialVersionUID, then
 * the serialization runtime will calculate a default serialVersionUID value
 * for that class based on various aspects of the class, as described in the
 * Java(TM) Object Serialization Specification.  However, it is <em>strongly
 * recommended</em> that all serializable classes explicitly declare
 * serialVersionUID values, since the default serialVersionUID computation is
 * highly sensitive to class details that may vary depending on compiler
 * implementations, and can thus result in unexpected
 * <code>InvalidClassException</code>s during deserialization.  Therefore, to
 * guarantee a consistent serialVersionUID value across different java compiler
 * implementations, a serializable class must declare an explicit
 * serialVersionUID value.  It is also strongly advised that explicit
 * serialVersionUID declarations use the <code>private</code> modifier where
 * possible, since such declarations apply only to the immediately declaring
 * class--serialVersionUID fields are not useful as inherited members. Array
 * classes cannot declare an explicit serialVersionUID, so they always have
 * the default computed value, but the requirement for matching
 * serialVersionUID values is waived for array classes.
 *
 * @author  unascribed
 * @see java.io.ObjectOutputStream
 * @see java.io.ObjectInputStream
 * @see java.io.ObjectOutput
 * @see java.io.ObjectInput
 * @see java.io.Externalizable
 * @since   JDK1.1
 */
public interface Serializable {
}

```

很长很长的说明。大概看看突然想起来了，实现 `Serializable` 是需要重写 writeObject 和 readObject 等方法。我猜测是重写了该方法。

size 变量就是数据的大小了。

## ArrayList 构造方法

继续查看源代码，可以看到 ArrayList 的 constructors：

```java
/**
 * Constructs an empty list with the specified initial capacity.
 *
 * @param  initialCapacity  the initial capacity of the list
 * @throws IllegalArgumentException if the specified initial capacity
 *         is negative
 */
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: "+
                                           initialCapacity);
    }
}

/**
 * Constructs an empty list with an initial capacity of ten.
 */
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}

/**
 * Constructs a list containing the elements of the specified
 * collection, in the order they are returned by the collection's
 * iterator.
 *
 * @param c the collection whose elements are to be placed into this list
 * @throws NullPointerException if the specified collection is null
 */
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {
        // c.toArray might (incorrectly) not return Object[] (see 6260652)
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        // replace with empty array.
        this.elementData = EMPTY_ELEMENTDATA;
    }
}

```

这里定义了三个 constructor， 我其实挺好奇默认构造方法的实现，和给定参数为 0 构造函数，这俩还不一样。默认的构造方法，是一个空对象数组 DEFAULTCAPACITY_EMPTY_ELEMENTDATA。

## ArrayList 扩容等方法

查看关于容量的源码：

```java
    /**
     * Increases the capacity of this <tt>ArrayList</tt> instance, if
     * necessary, to ensure that it can hold at least the number of elements
     * specified by the minimum capacity argument.
     *
     * @param   minCapacity   the desired minimum capacity
     */
    public void ensureCapacity(int minCapacity) {
        int minExpand = (elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA)
            // any size if not default element table
            ? 0
            // larger than default for default empty table. It's already
            // supposed to be at default size.
            : DEFAULT_CAPACITY;

        if (minCapacity > minExpand) {
            ensureExplicitCapacity(minCapacity);
        }
    }

```

ensureCapacity 保证容量，如果不是默认空数据，那么 minExpand 为 0，否则为 DEFAULT_CAPACITY，也就是 10。 如果 minCapacity 大于 minExpand，也就是说需要扩展的大小比默认大小还大，那么就调用 ensureExplicitCapacity，显式扩容。
源码中并没有使用这个方法，而是下面的方法。

```java
private void ensureCapacityInternal(int minCapacity) {
    if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
        minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
    }

    ensureExplicitCapacity(minCapacity);
}
```

ensureCapacityInternal，这个方法在其他的方法中有所调用。跟之前的类似，也是比较默认容器大小和 minCapacity 的大小。不同的地方在于，不论如何这里都会进行 ensureExplicitCapacity，如果调用 ensureCapacity， 那么

$$
minCapacity \le  minExpand
$$

不会进行任何操作。我的理解是，在初始化的时候会省去很多不必要的开销。

```java
private void ensureExplicitCapacity(int minCapacity) {
    modCount++;

    // overflow-conscious code
    if (minCapacity - elementData.length > 0)
        grow(minCapacity);
}
```

这个方法才是保证扩容的真正方法。
modCount， 这个变量是从 AbstractList<E> 继承过来的：

    protected transient int modCount = 0;

猜一下也知道，用来记录扩容次数的。不论是否扩容，都会加一。然后，如果需要的容量比现在的长度还大，就扩容。


```java
/**
 * The maximum size of array to allocate.
 * Some VMs reserve some header words in an array.
 * Attempts to allocate larger arrays may result in
 * OutOfMemoryError: Requested array size exceeds VM limit
 */
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

/**
 * Increases the capacity to ensure that it can hold at least the
 * number of elements specified by the minimum capacity argument.
 *
 * @param minCapacity the desired minimum capacity
 */
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```

这里介绍的很清楚，MAX_ARRAY_SIZE 再大可能对某些虚拟机产生 OutOfMemoryError。为什么要减 8？因为要有 8 个自己去存储这个大小。
$$ 2^{31} = 2,147,483,648 $$
这个还是要存起来的。
grow 方法会对原油的数据大小进行扩容。新的大小是旧的大小的 1.5 倍（取下界）？如果这个大小比需要的大小还小，那么这个大小设置为需要的大小；如果超出了 MAX_ARRAY_SIZE，就更换策略，使用 hugeCapacity 进行扩容。
这里的扩容方式跟之前说的不太一样，我猜测是因为位运算比普通运算要快。

```java
private static int hugeCapacity(int minCapacity) {
    if (minCapacity < 0) // overflow
        throw new OutOfMemoryError();
    return (minCapacity > MAX_ARRAY_SIZE) ?
        Integer.MAX_VALUE :
        MAX_ARRAY_SIZE;
}
```

注意这里会引发 OutOfMemoryError 错误。这里最大也只能到整型的最大。

## ArrayList 增删改查

 ```java
 /**
    * Returns the element at the specified position in this list.
    *
    * @param  index index of the element to return
    * @return the element at the specified position in this list
    * @throws IndexOutOfBoundsException {@inheritDoc}
    */
   public E get(int index) {
       rangeCheck(index);

       return elementData(index);
   }

   /**
    * Replaces the element at the specified position in this list with
    * the specified element.
    *
    * @param index index of the element to replace
    * @param element element to be stored at the specified position
    * @return the element previously at the specified position
    * @throws IndexOutOfBoundsException {@inheritDoc}
    */
   public E set(int index, E element) {
       rangeCheck(index);

       E oldValue = elementData(index);
       elementData[index] = element;
       return oldValue;
   }

   /**
    * Appends the specified element to the end of this list.
    *
    * @param e element to be appended to this list
    * @return <tt>true</tt> (as specified by {@link Collection#add})
    */
   public boolean add(E e) {
       ensureCapacityInternal(size + 1);  // Increments modCount!!
       elementData[size++] = e;
       return true;
   }

   /**
    * Inserts the specified element at the specified position in this
    * list. Shifts the element currently at that position (if any) and
    * any subsequent elements to the right (adds one to their indices).
    *
    * @param index index at which the specified element is to be inserted
    * @param element element to be inserted
    * @throws IndexOutOfBoundsException {@inheritDoc}
    */
   public void add(int index, E element) {
       rangeCheckForAdd(index);

       ensureCapacityInternal(size + 1);  // Increments modCount!!
       System.arraycopy(elementData, index, elementData, index + 1,
                        size - index);
       elementData[index] = element;
       size++;
   }

   /**
    * Removes the element at the specified position in this list.
    * Shifts any subsequent elements to the left (subtracts one from their
    * indices).
    *
    * @param index the index of the element to be removed
    * @return the element that was removed from the list
    * @throws IndexOutOfBoundsException {@inheritDoc}
    */
   public E remove(int index) {
       rangeCheck(index);

       modCount++;
       E oldValue = elementData(index);

       int numMoved = size - index - 1;
       if (numMoved > 0)
           System.arraycopy(elementData, index+1, elementData, index,
                            numMoved);
       elementData[--size] = null; // clear to let GC do its work

       return oldValue;
   }

   /**
    * Removes the first occurrence of the specified element from this list,
    * if it is present.  If the list does not contain the element, it is
    * unchanged.  More formally, removes the element with the lowest index
    * <tt>i</tt> such that
    * <tt>(o==null&nbsp;?&nbsp;get(i)==null&nbsp;:&nbsp;o.equals(get(i)))</tt>
    * (if such an element exists).  Returns <tt>true</tt> if this list
    * contained the specified element (or equivalently, if this list
    * changed as a result of the call).
    *
    * @param o element to be removed from this list, if present
    * @return <tt>true</tt> if this list contained the specified element
    */
   public boolean remove(Object o) {
       if (o == null) {
           for (int index = 0; index < size; index++)
               if (elementData[index] == null) {
                   fastRemove(index);
                   return true;
               }
       } else {
           for (int index = 0; index < size; index++)
               if (o.equals(elementData[index])) {
                   fastRemove(index);
                   return true;
               }
       }
       return false;
   }

   /*
    * Private remove method that skips bounds checking and does not
    * return the value removed.
    */
   private void fastRemove(int index) {
       modCount++;
       int numMoved = size - index - 1;
       if (numMoved > 0)
           System.arraycopy(elementData, index+1, elementData, index,
                            numMoved);
       elementData[--size] = null; // clear to let GC do its work
   }

   /**
    * Removes all of the elements from this list.  The list will
    * be empty after this call returns.
    */
   public void clear() {
       modCount++;

       // clear to let GC do its work
       for (int i = 0; i < size; i++)
           elementData[i] = null;

       size = 0;
   }

   /**
    * Appends all of the elements in the specified collection to the end of
    * this list, in the order that they are returned by the
    * specified collection's Iterator.  The behavior of this operation is
    * undefined if the specified collection is modified while the operation
    * is in progress.  (This implies that the behavior of this call is
    * undefined if the specified collection is this list, and this
    * list is nonempty.)
    *
    * @param c collection containing elements to be added to this list
    * @return <tt>true</tt> if this list changed as a result of the call
    * @throws NullPointerException if the specified collection is null
    */
   public boolean addAll(Collection<? extends E> c) {
       Object[] a = c.toArray();
       int numNew = a.length;
       ensureCapacityInternal(size + numNew);  // Increments modCount
       System.arraycopy(a, 0, elementData, size, numNew);
       size += numNew;
       return numNew != 0;
   }

   /**
    * Inserts all of the elements in the specified collection into this
    * list, starting at the specified position.  Shifts the element
    * currently at that position (if any) and any subsequent elements to
    * the right (increases their indices).  The new elements will appear
    * in the list in the order that they are returned by the
    * specified collection's iterator.
    *
    * @param index index at which to insert the first element from the
    *              specified collection
    * @param c collection containing elements to be added to this list
    * @return <tt>true</tt> if this list changed as a result of the call
    * @throws IndexOutOfBoundsException {@inheritDoc}
    * @throws NullPointerException if the specified collection is null
    */
   public boolean addAll(int index, Collection<? extends E> c) {
       rangeCheckForAdd(index);

       Object[] a = c.toArray();
       int numNew = a.length;
       ensureCapacityInternal(size + numNew);  // Increments modCount

       int numMoved = size - index;
       if (numMoved > 0)
           System.arraycopy(elementData, index, elementData, index + numNew,
                            numMoved);

       System.arraycopy(a, 0, elementData, index, numNew);
       size += numNew;
       return numNew != 0;
   }

   /**
    * Removes from this list all of the elements whose index is between
    * {@code fromIndex}, inclusive, and {@code toIndex}, exclusive.
    * Shifts any succeeding elements to the left (reduces their index).
    * This call shortens the list by {@code (toIndex - fromIndex)} elements.
    * (If {@code toIndex==fromIndex}, this operation has no effect.)
    *
    * @throws IndexOutOfBoundsException if {@code fromIndex} or
    *         {@code toIndex} is out of range
    *         ({@code fromIndex < 0 ||
    *          fromIndex >= size() ||
    *          toIndex > size() ||
    *          toIndex < fromIndex})
    */
   protected void removeRange(int fromIndex, int toIndex) {
       modCount++;
       int numMoved = size - toIndex;
       System.arraycopy(elementData, toIndex, elementData, fromIndex,
                        numMoved);

       // clear to let GC do its work
       int newSize = size - (toIndex-fromIndex);
       for (int i = newSize; i < size; i++) {
           elementData[i] = null;
       }
       size = newSize;
   }

   /**
    * Checks if the given index is in range.  If not, throws an appropriate
    * runtime exception.  This method does *not* check if the index is
    * negative: It is always used immediately prior to an array access,
    * which throws an ArrayIndexOutOfBoundsException if index is negative.
    */
   private void rangeCheck(int index) {
       if (index >= size)
           throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
   }

 ```

 以上的代码基本上没有特别难懂的，基本上都是依靠 Arrays 的方法实现的，没有特别说明的。

 ## ArrayList 其他方法

 ```java
 /**
     * Save the state of the <tt>ArrayList</tt> instance to a stream (that
     * is, serialize it).
     *
     * @serialData The length of the array backing the <tt>ArrayList</tt>
     *             instance is emitted (int), followed by all of its elements
     *             (each an <tt>Object</tt>) in the proper order.
     */
    private void writeObject(java.io.ObjectOutputStream s)
        throws java.io.IOException{
        // Write out element count, and any hidden stuff
        int expectedModCount = modCount;
        s.defaultWriteObject();

        // Write out size as capacity for behavioural compatibility with clone()
        s.writeInt(size);

        // Write out all elements in the proper order.
        for (int i=0; i<size; i++) {
            s.writeObject(elementData[i]);
        }

        if (modCount != expectedModCount) {
            throw new ConcurrentModificationException();
        }
    }

    /**
     * Reconstitute the <tt>ArrayList</tt> instance from a stream (that is,
     * deserialize it).
     */
    private void readObject(java.io.ObjectInputStream s)
        throws java.io.IOException, ClassNotFoundException {
        elementData = EMPTY_ELEMENTDATA;

        // Read in size, and any hidden stuff
        s.defaultReadObject();

        // Read in capacity
        s.readInt(); // ignored

        if (size > 0) {
            // be like clone(), allocate array based upon size not capacity
            ensureCapacityInternal(size);

            Object[] a = elementData;
            // Read in all elements in the proper order.
            for (int i=0; i<size; i++) {
                a[i] = s.readObject();
            }
        }
    }
 ```

与之前猜测的一样，这里确实重写了 writeObject 和 readObject，用来实现序列化。

除此之外还有 SubList 和 Iterator 的实现，没有太多需要说明的，因为本身就比较简单。

# 总结

ArrayList 在所有集合中应该算是比较简单的，没有同步，没有复杂的分块，也是用的最多的一种集合。需要注意的地方一个是它的最大值，一个是扩容的机制。

# 参考

[serialVersionUID的作用](http://www.cnblogs.com/guanghuiqq/archive/2012/07/18/2597036.html)

[Why the maximum array size of ArrayList is Integer.MAX_VALUE - 8?](http://stackoverflow.com/questions/35756277/why-the-maximum-array-size-of-arraylist-is-integer-max-value-8)
