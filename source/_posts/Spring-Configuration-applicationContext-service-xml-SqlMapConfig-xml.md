---
title: Spring Configuration-applicationContext-service.xml & SqlMapConfig.xml
date: 2016-10-19 22:29:47
tags: [code, java, spring, mybatis, xml]
---

# 前言

配置的问题就到尾声了。使用和了解还是不一样，内部原理实现更是复杂，因此我觉得主要问题还是要放到源码的阅读上。

# applicationContext.xml

基本上该配置的都配置了，service 是提供服务的，也不用配别的了，就是配置一下包扫描器，扫描一下 service 包：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
         http://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="com.summer.service"/>
</beans>
```

还有redis 的配置：

```xml
<bean class="redis.clients.jedis.JedisCluster" id="jedisCluster">
    <constructor-arg>
        <set>
            <bean class="redis.clients.jedis.HostAndPort">
                <constructor-arg name="host" value="172.21.14.118" />
                <constructor-arg name="port" value="7001"/>
            </bean>
            <bean class="redis.clients.jedis.HostAndPort">
                <constructor-arg name="host" value="172.21.14.118" />
                <constructor-arg name="port" value="7002"/>
            </bean>
            <bean class="redis.clients.jedis.HostAndPort">
                <constructor-arg name="host" value="172.21.14.118" />
                <constructor-arg name="port" value="7003"/>
            </bean>
            <bean class="redis.clients.jedis.HostAndPort">
                <constructor-arg name="host" value="172.21.14.118" />
                <constructor-arg name="port" value="7004"/>
            </bean>
            <bean class="redis.clients.jedis.HostAndPort">
                <constructor-arg name="host" value="172.21.14.118" />
                <constructor-arg name="port" value="7005"/>
            </bean>
            <bean class="redis.clients.jedis.HostAndPort">
                <constructor-arg name="host" value="172.21.14.118" />
                <constructor-arg name="port" value="7006"/>
            </bean>
        </set>
    </constructor-arg>
</bean>
<bean class="com.summer.rest.component.impl.JedisClientCluster" id="jedisClient"/>
</beans>
```

# SqlMapConfig.xml

这个配置文件是在 applicationContext-dao.xml 文件中，配置 SqlSessionFactoryBean的时候需要注入的文件
这个配置文件是 Mybatis 的配置文件，具体配置了有关 Mybatis 的参数：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

    <settings>
        <!-- Globally enables or disables any caches configured in any mapper under this configuration -->
        <setting name="cacheEnabled" value="true"/>
        <!-- Sets the number of seconds the driver will wait for a response from the database -->
        <setting name="defaultStatementTimeout" value="3000"/>
        <!-- Enables automatic mapping from classic database column names A_COLUMN to camel case classic Java property names aColumn -->
        <setting name="mapUnderscoreToCamelCase" value="true"/>
        <!-- Allows JDBC support for generated keys. A compatible driver is required.
        This setting forces generated keys to be used if set to true,
         as some drivers deny compatibility but still work -->
        <setting name="useGeneratedKeys" value="true"/>
    </settings>

    <plugins>
        <plugin interceptor="com.github.pagehelper.PageHelper">
            <property name="dialect" value="mariadb" />
        </plugin>
    </plugins>
    <!-- Continue going here -->

</configuration>
```

也不长，无非就是连接状态超时时间，是否使用缓存这些。
插件是自己配置的，配置一个分页插件，配置一下 使用的数据库是什么就行了。

# 总结

这里实际上就配置了：

* 包扫描器，context:component-scan，用来扫描包的
* redis 的集群设置。
* 在 Mybatis的配置文件中配置了一个分页插件。

这么算下来感觉整个网站的东西其实还可以，但是做的时候是一个学习的过程，很痛苦，现在好了。其实里面还会配置一些自己写的 Bean 也可以使用注解，当时学习的时候主要是使用注解。
