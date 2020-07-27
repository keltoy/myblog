---
title: Spring Configuration - web.xml
date: 2016-10-18 23:46:34
tags: [code, java, spring, xml]
---

# 前言

关于 Spring 这个框架无需多说了，很经典了，这里先复习一下它的配置。话说不复习还真容易忘了。

# Spring 配置

主要还是通过学习的项目，对 Spring, Spring MVC 和 Mybatis 这三大框架的配置进行复习，主要对 Spring的框架配置进行复习。

## web.xml

此文件的目录是 `src/main/webapp/WEB-INF/`，该目录下还有 css, js, jsp 这三个目录。

```xml
<!DOCTYPE web-app PUBLIC
        "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
        "http://java.sun.com/dtd/web-app_2_3.dtd" >

<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://java.sun.com/xml/ns/javaee" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" id="WebApp_ID" version="2.5">
```

以上内容基本不怎么更改，使用默认的就行。
设置项目名称：

```xml
    <display-name>summer</display-name>
```
定制欢迎页，就是设置首页方式，首次访问的时候就会跳转到 `welcome-file` 设置的文件中。

```xml
    <welcome-file-list>
        <welcome-file>index.html</welcome-file>
        <welcome-file>index.htm</welcome-file>
        <welcome-file>index.jsp</welcome-file>
        <welcome-file>default.html</welcome-file>
        <welcome-file>default.htm</welcome-file>
        <welcome-file>default.jsp</welcome-file>
    </welcome-file-list>
```

`context-param` 用来声明应用范围(整个WEB项目)内的上下文初始化参数。个人理解就是加载 Spring 配置文件，初始化 Spring 容器。
`param-name` 设定上下文的参数名称。必须是唯一名称。
`param-value` 设定的参数名称的值，可以设置为目录文件。

```xml
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath:spring/applicationContext*.xml</param-value>
    </context-param>
```

设置监听器。引用他人的介绍：

>ContextLoaderListener的作用就是启动Web容器时，自动装配ApplicationContext的配置信息。
>因为它实现了ServletContextListener这个接口，在web.xml配置这个监听器，启动容器时，就会默认执行它实现的方法。
>ContextLoaderListener启动的上下文为根上下文，DispatcherServlet所创建的上下文的的父上下文即为此根上下文，可在FrameworkServlet中的initWebApplicationContext中看出。

```xml
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>
```

设置过滤器。这里需要说明的就是过滤器和Spring AOP 中的拦截器的区别和联系。

Spring的拦截器与Servlet的Filter有相似之处，比如二者都是AOP编程思想的体现，都能实现权限检查、日志记录等。

* 使用范围不同：Filter是Servlet规范规定的，只能用于Web程序中。而拦截器既可以用于Web程序，也可以用于Application、Swing程序中。

* 规范不同：Filter是在Servlet规范中定义的，是Servlet容器支持的。而拦截器是在Spring容器内的，是Spring框架支持的。

* 使用的资源不同：同其他的代码块一样，拦截器也是一个Spring的组件，归Spring管理，配置在Spring文件中，因此能使用Spring里的任何资源、对象，例如Service对象、数据源、事务管理等，通过IoC注入到拦截器即可；而Filter则不能。

* 深度不同：Filter在只在Servlet前后起作用。而拦截器能够深入到方法前后、异常抛出前后等，因此拦截器的使用具有更大的弹性。所以在Spring构架的程序中，要优先使用拦截器。

可以看出

| |Filter|Interceptor|
|-|------|-----------|
|规范|Servlet 规范规定的|Spring 容器规定的|
|使用范围|只能用于 Web|可以用去其他程序|
|使用资源|基本不能使用资源|可以使用 Spring 配置的任何资源|
|深度|只在 Servlet 前后起作用| 可以深入到方法，异常前后|

还有他人总结的区别：

1. 拦截器是基于java的反射机制的，而过滤器是基于函数回调。
2. 拦截器不依赖与servlet容器，过滤器依赖与servlet容器。
3. 拦截器只能对action请求起作用，而过滤器则可以对几乎所有的请求起作用。
4. 拦截器可以访问action上下文、值栈里的对象，而过滤器不能访问。
5. 在action的生命周期中，拦截器可以多次被调用，而过滤器只能在容器初始化时被调用一次。
6. 拦截器可以获取IOC容器中的各个bean，而过滤器就不行，这点很重要，在拦截器里注入一个service，可以调用业务逻辑。

我的理解是，拦截器因为是Spring的一个模块，因此可以不在 Web 中使用，可以调用 Spring 的资源，可以升入到方法；
而过滤器要依赖于 Servlet， 所以只呢个在 Web 中使用，初始化容器，初始化 Servlet 的时候调用。

主要顺序是：

```
Filter pre -> service -> dispatcher -> preHandle -> Controller -> postHandle -> afterCompletion -> Filter after
```

当客户端发出Web资源的请求时，Web服务器根据应用程序配置文件设置的过滤规则进行检查，若客户请求满足过滤规则，则对客户请求／响应进行拦截，对请求头和请求数据进行检查或改动，并依次通过过滤器链，最后把请求／响应交给请求的Web资源处理。请求信息在过滤器链中可以被修改，也可以根据条件让请求不发往资源处理器，并直接向客户机发回一个响应。当资源处理器完成了对资源的处理后，响应信息将逐级逆向返回。同样在这个过程中，用户可以修改响应信息，从而完成一定的任务。
基本上过滤器也是在拦截请求和响应，过滤 request 和 response 信息。
这里就配置了字符编码的信息，过滤掉乱码的情况 `url-pattern` 设置所有情况。

```xml
    <filter>
        <filter-name>characterEncodingFilter</filter-name>
        <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>characterEncodingFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>
```

接下来配置 servlet。
DispatcherServlet是前端控制器设计模式的实现，提供Spring Web MVC的集中访问点，而且负责职责的分派，而且与Spring IoC容器无缝集成，从而可以获得Spring的所有好处。
前段控制使用的是 Spring MVC，因此这里要配置 Spring MVC 的配置文件。`load-on-startup` 也需要配置，否则服务器也启动不起来。
然后对配置的 servlet 配置映射。

```xml
    <servlet>
        <servlet-name>dispatcherServlet</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:spring/springmvc.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>dispatcherServlet</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```

# 总结

在 web.xml 文件中，我配置了这几项内容：
* 项目名称，display-name。
* 定制欢迎页方式，welcome-file-list。
* 设置上下文初始化参数（加载 Spring 配置文件，初始化 Spring 容器），context-param。
* 设置监听器（默认的Context就行），listener。
* 设置过滤器和过滤器映射，filter， filter-mapping。
* 还有设置servlet（servletDispatcher）。

# 参考

[我的项目](https://github.com/TomorrowOnceMore/SummerMVC/blob/master/summer-manager/summer-manager-web/src/main/resources/spring/springmvc.xml)

[SpringMVC容器初始化篇----ContextLoaderListener](http://blog.csdn.net/zjw10wei321/article/details/40145241)

[Java过滤器与SpringMVC拦截器之间的关系与区别](http://blog.csdn.net/chenleixing/article/details/44573495)
