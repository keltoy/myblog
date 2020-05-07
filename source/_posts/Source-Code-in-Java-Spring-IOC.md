---
title: Source Code in Java -- Spring IoC
date: 2016-11-02 23:46:46
tags: [code, source code, java, spring]
---

# Preface

Spring 的源码在网上基本上都被研究透了，我之前的理解实际上也是基于书本和基于一些项目。既然是阅读源码，那么 Spring 的源码是不得不看的。

# Spring IoC 设计

网上找的一张图，和书上的一样，先拿过来用了：

![Spring IoC 容器](http://odzz59auo.bkt.clouddn.com/Spring.png)

挺多的，但是不复杂，从名字就可以看出来每个类或者接口。

>这个接口系统是以 BeanFactory 和 ApplicationContext 为核心的。

因此主要也是介绍这两个接口。

## BeanFactory

* 提供的是最基本的 IoC 容器功能
* 可以使用转义符“&”获取FactoryBean
* 设计的 getBean 方法是使用 IoC 容器的主要方法。

对于这个转义符，我没弄明白，书上是这么介绍的：

> 用户使用容器时，可以使用转义符“&”来得到 FactoryBean 本身，用来区分通过容器来获取 FactoryBean 产生的对象和获取 FacoryBean 产生的对象和获取 FactoryBean 本身。

简单来说，就是加上“&”之后获取的是 FactoryBean，而不是 FactoryBean 产生的对象。

需要注意的是 BeanFactory 是 IoC容器或者对象工厂，FactoryBean 是 Bean。

```java
public interface BeanFactory {

	/**
	 * Used to dereference a {@link FactoryBean} instance and distinguish it from
	 * beans <i>created</i> by the FactoryBean. For example, if the bean named
	 * {@code myJndiObject} is a FactoryBean, getting {@code &myJndiObject}
	 * will return the factory, not the instance returned by the factory.
	 */
	String FACTORY_BEAN_PREFIX = "&";


	/**
	 * Return an instance, which may be shared or independent, of the specified bean.
	 * <p>This method allows a Spring BeanFactory to be used as a replacement for the
	 * Singleton or Prototype design pattern. Callers may retain references to
	 * returned objects in the case of Singleton beans.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to retrieve
	 * @return an instance of the bean
	 * @throws NoSuchBeanDefinitionException if there is no bean definition
	 * with the specified name
	 * @throws BeansException if the bean could not be obtained
	 */
	Object getBean(String name) throws BeansException;

	/**
	 * Return an instance, which may be shared or independent, of the specified bean.
	 * <p>Behaves the same as {@link #getBean(String)}, but provides a measure of type
	 * safety by throwing a BeanNotOfRequiredTypeException if the bean is not of the
	 * required type. This means that ClassCastException can't be thrown on casting
	 * the result correctly, as can happen with {@link #getBean(String)}.
	 * <p>Translates aliases back to the corresponding canonical bean name.
	 * Will ask the parent factory if the bean cannot be found in this factory instance.
	 * @param name the name of the bean to retrieve
	 * @param requiredType type the bean must match. Can be an interface or superclass
	 * of the actual class, or {@code null} for any match. For example, if the value
	 * is {@code Object.class}, this method will succeed whatever the class of the
	 * returned instance.
	 * @return an instance of the bean
	 * @throws NoSuchBeanDefinitionException if there is no such bean definition
	 * @throws BeanNotOfRequiredTypeException if the bean is not of the required type
	 * @throws BeansException if the bean could not be created
	 */
	<T> T getBean(String name, Class<T> requiredType) throws BeansException;
  ...

```

这里截取一些源代码，实际上 getBean 还有很多，BeanFactory 只是一个接口，因此只有常量和方法的声明。
然后废话一句，虽然不影响学习，但是 XmlBeanFactory 早已被弃用了。

## ApplicationContext

* 除了基本功能，还提供附加服务
* 支持不同的信息源
* 访问资源
* 支持应用事件

```java
/**
 * Central interface to provide configuration for an application.
 * This is read-only while the application is running, but may be
 * reloaded if the implementation supports this.
 *
 * <p>An ApplicationContext provides:
 * <ul>
 * <li>Bean factory methods for accessing application components.
 * Inherited from {@link org.springframework.beans.factory.ListableBeanFactory}.
 * <li>The ability to load file resources in a generic fashion.
 * Inherited from the {@link org.springframework.core.io.ResourceLoader} interface.
 * <li>The ability to publish events to registered listeners.
 * Inherited from the {@link ApplicationEventPublisher} interface.
 * <li>The ability to resolve messages, supporting internationalization.
 * Inherited from the {@link MessageSource} interface.
 * <li>Inheritance from a parent context. Definitions in a descendant context
 * will always take priority. This means, for example, that a single parent
 * context can be used by an entire web application, while each servlet has
 * its own child context that is independent of that of any other servlet.
 * </ul>
 *
 * <p>In addition to standard {@link org.springframework.beans.factory.BeanFactory}
 * lifecycle capabilities, ApplicationContext implementations detect and invoke
 * {@link ApplicationContextAware} beans as well as {@link ResourceLoaderAware},
 * {@link ApplicationEventPublisherAware} and {@link MessageSourceAware} beans.
 *
 * @author Rod Johnson
 * @author Juergen Hoeller
 * @see ConfigurableApplicationContext
 * @see org.springframework.beans.factory.BeanFactory
 * @see org.springframework.core.io.ResourceLoader
 */
public interface ApplicationContext extends EnvironmentCapable, ListableBeanFactory, HierarchicalBeanFactory, MessageSource, ApplicationEventPublisher, ResourcePatternResolver
```

ApplicationContext 也是一个接口，从 extends 的接口就可以看出来，这些附加的信息是基于这些接口来实现的。
MessageSource 支持不同的信息源， ApplicationEventPublisher 支持应用事件，
ResourcePatternResolver 支持访问资源。

注意到该几口还支持 getAutowireCapableBeanFactory()。

```java
	String getId();
	String getApplicationName();
	String getDisplayName();
	long getStartupDate();
	ApplicationContext getParent();
	/**
	 * Expose AutowireCapableBeanFactory functionality for this context.
	 * <p>This is not typically used by application code, except for the purpose of
	 * initializing bean instances that live outside of the application context,
	 * applying the Spring bean lifecycle (fully or partly) to them.
	 * <p>Alternatively, the internal BeanFactory exposed by the
	 * {@link ConfigurableApplicationContext} interface offers access to the
	 * {@link AutowireCapableBeanFactory} interface too. The present method mainly
	 * serves as a convenient, specific facility on the ApplicationContext interface.
	 * <p><b>NOTE: As of 4.2, this method will consistently throw IllegalStateException
	 * after the application context has been closed.</b> In current Spring Framework
	 * versions, only refreshable application contexts behave that way; as of 4.2,
	 * all application context implementations will be required to comply.
	 * @return the AutowireCapableBeanFactory for this context
	 * @throws IllegalStateException if the context does not support the
	 * {@link AutowireCapableBeanFactory} interface, or does not hold an
	 * autowire-capable bean factory yet (e.g. if {@code refresh()} has
	 * never been called), or if the context has been closed already
	 * @see ConfigurableApplicationContext#refresh()
	 * @see ConfigurableApplicationContext#getBeanFactory()
	 */
	AutowireCapableBeanFactory getAutowireCapableBeanFactory() throws IllegalStateException;
```

## ClassPathXmlApplicationContext

测试的时候最常用的就是 ClassPathXmlApplicationContext 这个方法了。 从源代码可以了解到 ClassPathXmlApplicationContext 的关系

![ClassPathXmlApplicationContext]( http://odzz59auo.bkt.clouddn.com/ClassPathXmlApplicationContext.png)

可以看出，ClassPathXmlApplicationContext 和 ApplicationContext 有关系的。
ClassPathXmlApplicationContext 中有很多构造方法，但实际上调用的只有两个，

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

/**
 * Create a new ClassPathXmlApplicationContext with the given parent,
 * loading the definitions from the given XML files and automatically
 * refreshing the context.
 * @param paths array of relative (or absolute) paths within the class path
 * @param clazz the class to load resources with (basis for the given paths)
 * @param parent the parent context
 * @throws BeansException if context creation failed
 * @see org.springframework.core.io.ClassPathResource#ClassPathResource(String, Class)
 * @see org.springframework.context.support.GenericApplicationContext
 * @see org.springframework.beans.factory.xml.XmlBeanDefinitionReader
 */
public ClassPathXmlApplicationContext(String[] paths, Class<?> clazz, ApplicationContext parent)
		throws BeansException {

	super(parent);
	Assert.notNull(paths, "Path array must not be null");
	Assert.notNull(clazz, "Class argument must not be null");
	this.configResources = new Resource[paths.length];
	for (int i = 0; i < paths.length; i++) {
		this.configResources[i] = new ClassPathResource(paths[i], clazz);
	}
	refresh();
}
```

其中，super(parent) 设置了 parent，不过一般都是 null，还有获取访问资源，通过 AbstractApplicationContext 设置：

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
```

setConfigLocations() 在 AbstractRefreshableConfigApplicationContext 的定义，设置配置地址：

```java
/**
	 * Set the config locations for this application context in init-param style,
	 * i.e. with distinct locations separated by commas, semicolons or whitespace.
	 * <p>If not set, the implementation may use a default as appropriate.
	 */
	public void setConfigLocation(String location) {
		setConfigLocations(StringUtils.tokenizeToStringArray(location, CONFIG_LOCATION_DELIMITERS));
	}

	/**
	 * Set the config locations for this application context.
	 * <p>If not set, the implementation may use a default as appropriate.
	 */
	public void setConfigLocations(String... locations) {
		if (locations != null) {
			Assert.noNullElements(locations, "Config locations must not be null");
			this.configLocations = new String[locations.length];
			for (int i = 0; i < locations.length; i++) {
				this.configLocations[i] = resolvePath(locations[i]).trim();
			}
		}
		else {
			this.configLocations = null;
		}
	}
```

实际上，在另一个方法中，也设置了configLocations。
refresh() 方法。
>这个方法的作用是创建加载Spring容器配置（包括.xml配置，property文件和数据库模式等）

# 初始化 IoC 容器

从之前的源码中也能看出来，初始化的过程都是在 refresh 这个方法中实现的。
在 AbstractApplicationContext override：

```java
@Override
	public void refresh() throws BeansException, IllegalStateException {
		synchronized (this.startupShutdownMonitor) {
			// Prepare this context for refreshing.
			prepareRefresh();
			// Tell the subclass to refresh the internal bean factory.
			// 主要创建一个beanFactory，加载配置文件中的beanDefinition
      // 通过 String[] configLocations = getConfigLocations()获取资源路径，然后加载beanDefinition
			ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();
			// Prepare the bean factory for use in this context.
			// 给beanFactory注册一些标准组建，如ClassLoader，StandardEnvironment，BeanProcess
			prepareBeanFactory(beanFactory);
			try {
				// Allows post-processing of the bean factory in context subclasses.
				postProcessBeanFactory(beanFactory);
				// Invoke factory processors registered as beans in the context.
				invokeBeanFactoryPostProcessors(beanFactory);
				// Register bean processors that intercept bean creation.
				registerBeanPostProcessors(beanFactory);
				// Initialize message source for this context.
				initMessageSource();
				// Initialize event multicaster for this context.
				initApplicationEventMulticaster();
				// Initialize other special beans in specific context subclasses.
				onRefresh();
				// Check for listener beans and register them.
				registerListeners();
				// Instantiate all remaining (non-lazy-init) singletons.
				finishBeanFactoryInitialization(beanFactory);
				// Last step: publish corresponding event.
				finishRefresh();
			}
			catch (BeansException ex) {
				if (logger.isWarnEnabled()) {
					logger.warn("Exception encountered during context initialization - " +
							"cancelling refresh attempt: " + ex);
				}
				// Destroy already created singletons to avoid dangling resources.
				destroyBeans();
				// Reset 'active' flag.
				cancelRefresh(ex);
				// Propagate exception to caller.
				throw ex;
			}
			finally {
				// Reset common introspection caches in Spring's core, since we
				// might not ever need metadata for singleton beans anymore...
				resetCommonCaches();
			}
		}
	}
	/**
	 * Prepare this context for refreshing, setting its startup date and
	 * active flag as well as performing any initialization of property sources.
	 */
	protected void prepareRefresh() {
		this.startupDate = System.currentTimeMillis();
		this.closed.set(false);
		this.active.set(true);
		if (logger.isInfoEnabled()) {
			logger.info("Refreshing " + this);
		}
		// Initialize any placeholder property sources in the context environment
		initPropertySources();
		// Validate that all properties marked as required are resolvable
		// see ConfigurablePropertyResolver#setRequiredProperties
		getEnvironment().validateRequiredProperties();
		// Allow for the collection of early ApplicationEvents,
		// to be published once the multicaster is available...
		this.earlyApplicationEvents = new LinkedHashSet<ApplicationEvent>();
	}
```

主要说明可以参考[这个博客](http://blog.csdn.net/bubaxiu/article/details/41380683)，本人还是需要再深入。

书上说， IoC 容器的启动分为三个过程的实现：

* BeanDefinition 的 Resource 定位
* BeanDefinition 的 Resource 载入
* BeanDefinition 的 Resource 注册

>第一个过程是 Resource 定位过程。 这个 Resource 定位指的是 BeanDefinition 的资源定位，它由 ResourceLoader 通过统一的 Resource 接口来完成，这个 Resource 对各种形式的 BeanDefinition 的使用都提供了统一的接口。

比如 FileSystemResource、ClassPathResource 等等。

>第二个过程是 BeanDefinition 的载入。这个载入过程是把用户定义好的 Bean 表示成 IoC 容器内部的数据结构，而这个容器内部的数据结构就是 BeanDefinition。

BeanDefinition 是 POJO 对象在 IoC 容器中的抽象，通过此定义的数据结构使 IoC 容器能够方便对 Bean进行管理。

>第三个过程是向 IoC 容器注册这些 BeanDefinition 的过程。这个过程是通过调用 BeanDefinitionRegistry 接口的实现来完成的。这个注册过程把载入过程中解析得到的 BeanDefinition 向 IoC 容器进行注册。

IoC 容器内部将 BeanDefinition 注入到 HashMap 中去， IoC 容器就是通过这个 HashMap 来持有这些 BeanDefinition 数据的。

# Postscript
开始看的时候才发现，内部的东西真的好多，目前先到这里，以后会继续学习 Spring IoC 相关更多内容。

# References

[Spring源码阅读--AbstractApplicationContext refresh()方法调用](http://blog.csdn.net/bubaxiu/article/details/41380683)

Spring 技术内幕
