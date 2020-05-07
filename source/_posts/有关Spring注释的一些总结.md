---
title: 有关Spring注释的一些总结
date: 2018-12-11 10:50:58
tags: [Spring]
---

# Spring Boot

## @SpringBootApplication

- org.springframework.boot.autoconfigure.SpringBootApplication
- 项目的引导类
- 使用 `SpringApplication.run(类名.class, args)`进行启动，org.springframework.boot.SpringApplication 会返回 ApplicationContext对象

## @Bean

- 使用@Component @Service 或者 @repository 标注一个Java类可以定义一个Bean
- 使用@Configuration 注解标签来标注一个类，然后在每个要构建的Bean定义一个构造器，在构造器方法上添加@Bean来定义一个Bean

## Actuator

在maven中引入

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

然后可以配置

```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

默认在 /actuator 里之开启了health和info，需要在 application的配置里面添加


```yml
management:
  endpoints:
    web:
      exposure:
        include: health, info, env, metrics
  endpoint:
    health:
      show-details: always
```