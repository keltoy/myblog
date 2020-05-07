---
title: Spring Configuration-applicationContext-dao.xml
date: 2016-10-19 21:23:55
tags: [code, java, spring, xml]
---

# 前言

原本 applicationContext.xml 是一个文件，这里将它拆开是为了更好了解业务的配置。

# applicationContext.xml

这里才是真正开始配置 Spring 的参数。
首先还是 xml 文件的头。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd
       "
       default-lazy-init="false">
```

依然注意 `default-lazy-init="false"` 这一句，有人说不加也可以，是默认的，但是我使用的 Spring4， IDEA 搭建的时候不行。
接下来要配置外在配置，属性持有。这里有一个问题，那就是，在 Spring MVC 我已经配过了，为什么这里还要配一次？这个实际上就是父子容器的问题。

```xml
    <context:property-placeholder location="classpath:properties/*.properties"/>
```

既然是 dao 层配置，那么还需要配置数据库连接池。前两天翻书的时候，发现 druid 还支持 storm。

```xml
    <bean class="com.alibaba.druid.pool.DruidDataSource" id="dataSource" destroy-method="close">
        <property name="driverClassName" value="${jdbc.driver}" />
        <property name="username" value="${jdbc.username}" />
        <property name="password" value="${jdbc.password}" />
        <property name="url" value="${jdbc.url}" />
        <property name="maxActive" value="10" />
        <property name="minIdle" value="5" />
    </bean>
```

配置完数据库连接池，还需要配置 SqlSessionFactory, 用来与数据库创建会话。这让我想起来 Hibernate 的一级缓存 session 和二级缓存 sessionFactory。总的来说，就是把连接池和数据库的配置注入进来。

```xml
    <bean class="org.mybatis.spring.SqlSessionFactoryBean" id="sessionFactory">
        <property name="dataSource" ref="dataSource"/>
        <property name="configLocation" value="classpath:mybatis/SqlMapConfig.xml" />
    </bean>
```

数据库连接池和SqlSessionFactory都配置完成了，那么还需要将数据库配置注入到 Spring 中。使用 scannerConfigurer 自动扫描包，设置 dao 层目录，和刚才设置的 SqlSessionFactory。这里要注意的是属性的名字，好像是类名。

```xml
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer" id="scannerConfigurer">
        <property name="basePackage" value="com.summer.mapper"/>
        <property name="sqlSessionFactoryBeanName" value="sessionFactory" />
    </bean>
</beans>
```

# 总结

配置 dao 层的配置文件，配置了以下几个模块:

* 属性持有， placeholder， 用于注入外在属性。
* 数据库连接池，Bean， DataSource，这里可能会使用到 placeholder 里面的参数。
* 会话缓存，Bean，SqlSessionFactory，初始化 Mybatis。
* 扫描配置， Bean，用来把Mybatis 注入 Spring，并且指定扫描的包名。

不过感觉好像少了点什么....

# 参考

[我的项目](https://github.com/TomorrowOnceMore/SummerMVC/blob/master/summer-manager/summer-manager-web/src/main/resources/spring/applicationContext-dao.xml)
