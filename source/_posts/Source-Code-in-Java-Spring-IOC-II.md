---
title: Source Code in Java -- Spring IOC - II
date: 2016-11-10 23:09:39
tags: [code, source code, java, spring]
---

# Preface

>简单来说 IoC 容器的初始化是由 refresh() 方法启动的，这个方法标志着 IoC 容器正式启动。具体来说这个启动包括 BeanDefinition 的 Resource 定位、载入和注册三个基本过程。

关于这段话我首先不能理解的就是无缘无故出来的这个BeanDefinition，我在浏览这些源码的时候也没看到。因此，为了好好了解 Spring IoC，我还需要进一步查看内部源码和解释。

# What is BeanDefinition?

>对 IoC 来说，BeanDefinition 就是对依赖反转模式中管理的对象依赖关系的数据抽象。\
>Spring 通过定义 BeanDefinition 来管理基于 Spring 的应用中的各种对象以及它们之间的相互依赖关系。BeanDefinition 抽象了我们对 Bean 的定义，是让容器起作用的主要数据类型。

我的理解 BeanDefinition 有点像 Bean 的元数据，又有点像抽象类，又有点像 schema。

# Resource location of BeanDefinition

![ClassPathXmlApplicationContext]( http://odzz59auo.bkt.clouddn.com/ClassPathXmlApplicationContext.png)

再次拿出来这幅图来讲一下，像 ClassPathXmlApplicationContext 这样的方法定位资源的方式还是使用的 DefaultResourceLoader。而这个 DefaultResourceLoader 实现的是 ResourceLoader 接口：

```java
public interface ResourceLoader {

	/** Pseudo URL prefix for loading from the class path: "classpath:" */
	String CLASSPATH_URL_PREFIX = ResourceUtils.CLASSPATH_URL_PREFIX;


	/**
	 * Return a Resource handle for the specified resource.
	 * The handle should always be a reusable resource descriptor,
	 * allowing for multiple {@link Resource#getInputStream()} calls.
	 * <p><ul>
	 * <li>Must support fully qualified URLs, e.g. "file:C:/test.dat".
	 * <li>Must support classpath pseudo-URLs, e.g. "classpath:test.dat".
	 * <li>Should support relative file paths, e.g. "WEB-INF/test.dat".
	 * (This will be implementation-specific, typically provided by an
	 * ApplicationContext implementation.)
	 * </ul>
	 * <p>Note that a Resource handle does not imply an existing resource;
	 * you need to invoke {@link Resource#exists} to check for existence.
	 * @param location the resource location
	 * @return a corresponding Resource handle
	 * @see #CLASSPATH_URL_PREFIX
	 * @see org.springframework.core.io.Resource#exists
	 * @see org.springframework.core.io.Resource#getInputStream
	 */
	Resource getResource(String location);

	/**
	 * Expose the ClassLoader used by this ResourceLoader.
	 * <p>Clients which need to access the ClassLoader directly can do so
	 * in a uniform manner with the ResourceLoader, rather than relying
	 * on the thread context ClassLoader.
	 * @return the ClassLoader (only {@code null} if even the system
	 * ClassLoader isn't accessible)
	 * @see org.springframework.util.ClassUtils#getDefaultClassLoader()
	 */
	ClassLoader getClassLoader();

}
```

其中 CLASSPATH_URL_PREFIX 就是 "classpath:"：

```java
public static final String CLASSPATH_URL_PREFIX = "classpath:";
```

在 DefaultResourceLoader 中 getClassLoader 的实现如下：

```java
/**
	 * Return the ClassLoader to load class path resources with.
	 * <p>Will get passed to ClassPathResource's constructor for all
	 * ClassPathResource objects created by this resource loader.
	 * @see ClassPathResource
	 */
	@Override
	public ClassLoader getClassLoader() {
		return (this.classLoader != null ? this.classLoader : ClassUtils.getDefaultClassLoader());
	}
```

其中，
```java
/**
 * Return the default ClassLoader to use: typically the thread context
 * ClassLoader, if available; the ClassLoader that loaded the ClassUtils
 * class will be used as fallback.
 * <p>Call this method if you intend to use the thread context ClassLoader
 * in a scenario where you clearly prefer a non-null ClassLoader reference:
 * for example, for class path resource loading (but not necessarily for
 * {@code Class.forName}, which accepts a {@code null} ClassLoader
 * reference as well).
 * @return the default ClassLoader (only {@code null} if even the system
 * ClassLoader isn't accessible)
 * @see Thread#getContextClassLoader()
 * @see ClassLoader#getSystemClassLoader()
 */
public static ClassLoader getDefaultClassLoader() {
  ClassLoader cl = null;
  try {
    cl = Thread.currentThread().getContextClassLoader();
  }
  catch (Throwable ex) {
    // Cannot access thread context ClassLoader - falling back...
  }
  if (cl == null) {
    // No thread context class loader -> use class loader of this class.
    cl = ClassUtils.class.getClassLoader();
    if (cl == null) {
      // getClassLoader() returning null indicates the bootstrap ClassLoader
      try {
        cl = ClassLoader.getSystemClassLoader();
      }
      catch (Throwable ex) {
        // Cannot access system ClassLoader - oh well, maybe the caller can live with null...
      }
    }
  }
  return cl;
}
```

这里就要讲讲了：

* 首先如果当前线程的 ClassLoader 不为空，那么就返回当前 ClassLoader；
* 如果没有获取到，获取 ClassUtils 的 ClassLoader；
* 如果还没有获取到，则调用 ClassLoader 获取系统 ClassLoader

```java
@CallerSensitive
    public static ClassLoader getSystemClassLoader() {
        initSystemClassLoader();
        if (scl == null) {
            return null;
        }
        SecurityManager sm = System.getSecurityManager();
        if (sm != null) {
            checkClassLoaderPermission(scl, Reflection.getCallerClass());
        }
        return scl;
    }
```

这个就有点复杂了，大致意思应该就是获取系统调用的 ClassLoader。

那么，ClassPathXmlApplicationContext 是如何获取资源的呢？

```java
/**
	 * Create a new ClassPathXmlApplicationContext with the given parent,
	 * loading the definitions from the given XML files.
	 * @param configLocations array of resource locations
	 * @param refresh whether to automatically refresh the context,
	 * loading all bean definitions and creating all singletons.
	 * Alternatively, call refresh manually after further configuring the context.
	 * @param parent the parent context
	 * @throws BeansException if context creation failed
	 * @see #refresh()
	 */
	public ClassPathXmlApplicationContext(String[] configLocations, boolean refresh, ApplicationContext parent)
			throws BeansException {

		super(parent);
		setConfigLocations(configLocations);
		if (refresh) {
			refresh();
		}
	}

```

AbstractApplicationContext 中对继承的这个构造方法有了具体的说明：

```java
/**
 * Create a new AbstractApplicationContext with no parent.
 */
public AbstractApplicationContext() {
  this.resourcePatternResolver = getResourcePatternResolver();
}

/**
 * Create a new AbstractApplicationContext with the given parent context.
 * @param parent the parent context
 */
public AbstractApplicationContext(ApplicationContext parent) {
  this();
  setParent(parent);
}

/**
 * {@inheritDoc}
 * <p>The parent {@linkplain ApplicationContext#getEnvironment() environment} is
 * {@linkplain ConfigurableEnvironment#merge(ConfigurableEnvironment) merged} with
 * this (child) application context environment if the parent is non-{@code null} and
 * its environment is an instance of {@link ConfigurableEnvironment}.
 * @see ConfigurableEnvironment#merge(ConfigurableEnvironment)
 */
@Override
public void setParent(ApplicationContext parent) {
  this.parent = parent;
  if (parent != null) {
    Environment parentEnvironment = parent.getEnvironment();
    if (parentEnvironment instanceof ConfigurableEnvironment) {
      getEnvironment().merge((ConfigurableEnvironment) parentEnvironment);
    }
  }
}
```

由此，我们可以看出，创建一个新的 ApplicationContext 的时候，先要定义一下资源模式解析器，设置父类；然后设置配置文件地址，最后还需要 refresh 一下，载入 BeanDefinition。

>通过 IoC 容器的初始化的 refresh 来启动整个调用，使用的 IoC 容器是 DefaultListableBeanFactory。

虽然这么说，我其实没看出来。这里只能先留下来，等着今后再深入的时候进行。

# Postscript

写到这里其实发现 要想搞透 Spring 还是挺难的，不能一下子全部消化，我还需一步一步来，慢慢深入。

# References

Spring 技术内幕
