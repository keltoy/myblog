---
title: Spring Configuration-applicationContext-trans.xml
date: 2016-10-19 22:12:27
tags: [code, java, spring, xml]
---

# 前言

数据库的操作，一般都少不了事务，单独一个文件配置事务，是因为确实比较重要。

# applicationContext.xml

这里配置的时候需要用到aop的切面操作还有通知，注意要加上正确的地址，否则总会报错。
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx.xsd http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd">
```

基本上就是注意 xmlns:tx 和 xmlns:aop 的位置。
开始配置事务。
先配置事务管理，需要把之前在 dao 层配置的数据库连接池引用过来。

```xml
    <bean class="org.springframework.jdbc.datasource.DataSourceTransactionManager" id="dataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>
```

然后配置通知，配置哪些方法需要通知，这些方法使用什么传播形式。传播形式和会话紧密相关。

```xml
    <tx:advice transaction-manager="dataSourceTransactionManager" id="txAdvice">
        <tx:attributes>
            <tx:method name="save*" propagation="REQUIRED"/>
            <tx:method name="insert*" propagation="REQUIRED"/>
            <tx:method name="add*" propagation="REQUIRED"/>
            <tx:method name="create*" propagation="REQUIRED"/>
            <tx:method name="delete*" propagation="REQUIRED"/>
            <tx:method name="update*" propagation="REQUIRED"/>
            <tx:method name="find*" propagation="SUPPORTS"/>
            <tx:method name="select*" propagation="SUPPORTS"/>
            <tx:method name="get*" propagation="SUPPORTS"/>
        </tx:attributes>
    </tx:advice>
```

然后配置 aop，使用什执行哪些包的什么返回值的 什么参数需要使用以上的通知。

```xml
    <aop:config>
        <aop:advisor advice-ref="txAdvice"
                     pointcut="execution(* com.summer.service.*.*(..))"/>
    </aop:config>
</beans>
```

# 总结

这个配置文件配置了：

* 配置管理， Bean，DataSourceTransactionManager，用来管理事务，这里要注入连接池。
* 通知， tx:advice， 用于配置方法的传播方式。
* aop 配置，aop:config，用于配置 aop 的切点在哪，以及使用通知。

这里说的很简单，因为我想以后详细记录一下源码部分，现在只是一个整理思路的过程。自己在搭建的时候，遇到了很多坑，还是希望自己有所收获吧。

# 参考

[我的项目](https://github.com/TomorrowOnceMore/SummerMVC/blob/master/summer-manager/summer-manager-web/src/main/resources/spring/applicationContext-trans.xml)
