---
title: Spring Configuration-springmvc.xml
date: 2016-10-19 14:25:28
tags: [code, java, spring, xml]
---

# 前言

web.xml 配置好了之后（实际上也可以最后配置），还需要配置 web.xml 里面的涉及到一些文件。
先配置 `servlet` 标签中涉及到的 springmvc.xml。
DispatcherServlet 是前端控制器设计模式的实现，对于前段控制对应的就是 Spring MVC。

# springmvc.xml

springmvc.xml 的配置是在 `web.xml` 中的 `servlet` 标签中的 `init-param` 中设置。这里可以更改 xml 的位置和名称。我记得如果不配，默认是会在 WEB-INF 中创建一个 DispatcherServlet 的文件。现在我指定在了 resources 目录里面，将 Spring 的配置都放在一起。

首先都是 Spring MVC 的头，

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc.xsd"
        default-lazy-init="false">
```

这里还是要注意这个 `default-lazy-init="false"` 这句。

配置外在应用参数。有些参数写在xml虽然可以，但是经常会更改，这些数据可以放到 properties 的文件里，比如用户名，管理员密码等。

```xml
    <context:property-placeholder location="classpath:properties/resource.properties"/>
```

配组件扫描。由于这个项目使用的是注解形式搭建的，所以需要组件扫描器扫描特定包中的注解。这里要说明的是，因为 Spring MVC 主要面向的是前段控制层，所以 Spring MVC 扫描的是 Controller 包的注解。

```xml
    <context:component-scan base-package="com.summer.controller"/>
```

接下来配置的是注解驱动。这个还是蛮重要的，如果不配置，导致注解不能被解析，`@RequestMapping` 不能使用。

```xml
    <mvc:annotation-driven />
```

接下来配置视图解析器，个人理解就是读取 jsp 文件的：

```xml
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver" id="viewResolver">
        <property name="prefix" value="/WEB-INF/jsp/" />
        <property name="suffix" value=".jsp" />
    </bean>
```

然后设置静态资源映射，就是 css 和 js 文件：

```xml
    <mvc:resources mapping="/js/**" location="/WEB-INF/js/" />
    <mvc:resources mapping="/css/**" location="/WEB-INF/css/" />
```

如果需要上传文件，还需要配置多部分解析器（可选）：

```xml
    <bean class="org.springframework.web.multipart.commons.CommonsMultipartResolver" id="multipartResolver">
        <property name="defaultEncoding" value="UTF-8" />
        <property name="maxUploadSize" value="5242880" />
    </bean>
</beans>
```
# 注意
在配置 Spring MVC 的配置文件时会牵扯到一些父子容器的问题。简单的说就是子容器(Spring MVC) 可以访问父容器（Spring）的对象，而父容器不能访问子容器的对象。使用 `@Value` 对参数进行注入。

# 总结

很简单的一个配置文件。这个文件主要配置的都是控制和视图方面的 `bean`。这个文件中一共配置了：
* 属性持有，context:property-placeholder，用来加载外在参数。
* 组件扫描，context:component-scan，用来注册注解。
* 注解驱动，mvc:annotation-driven，用来解析注解。
* 资源视图解析器，bean，InternalResourceViewResolver就行，用来加载jsp的。
* 静态资源映射，mvc:resources，用来配置 js 和 css 文件。
* 多部分解析器（可选），bean， CommonsMultipartResolver，用于上传文件。

# 参考

[我的项目](https://github.com/TomorrowOnceMore/SummerMVC/blob/master/summer-manager/summer-manager-web/src/main/resources/spring/springmvc.xml)

[Spring 和SpringMVC 的父子容器关系](http://www.cnblogs.com/zyzcj/p/5286190.html)
