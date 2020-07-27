---
title: maven plugins
date: 2020-04-15 22:10:16
tags: [ java, maven]
---


# maven plugins

[toc]

## manven-enforcer-plugin

### 功能

在项目validate的过程时，对项目环境进行检查

### 原理

enforcer 配置之后会默认在validate 后执行enforcer:enforce，对项目环境进行检查

### 使用

```xml
<build>
<plugins>
  <plugin>
    <artifactId>maven-enforcer-plugin</artifactId>
    <version>1.4.1</version>
    <executions>
      <execution>
        <!-- 执行实例的id -->
        <id>default-cli</id>
        <goals>
        <!-- 执行的命令 -->
          <goal>enforce</goal>
        </goals>
        <!-- 执行的阶段 -->
        <phase>validate</phase>
        <configuration>
          <!-- 制定的规则 -->
          <rules>
            <!-- 制定jdk版本 -->
            <requireJavaVersion>
              <!-- 执行失败后的消息提示 -->
              <message>
                <![CDATA[You are running an older version of Java. This application requires at least JDK ${java.version}.]]>
              </message>
              <!-- jdk版本规则 -->
              <version>[${java.version}.0,)</version>
            </requireJavaVersion>
          </rules>
        </configuration>
      </execution>
    </executions>
  </plugin>
</plugins>
</build>
<properties>
<java.version>1.8</java.version>
</properties>

```

还有很多检测可以去官网看看内置的规则

[Apache Maven Enforcer Built-In Rules – Built-In Rules](http://maven.apache.org/enforcer/enforcer-rules/index.html)

## maven-checkstyle-plugin

### 功能

提交代码之前做一些代码检查

### 说明

- [checkstyle – Sun's Java Style](https://checkstyle.sourceforge.io/sun_style.html)

- [checkstyle - Goole Style](https://checkstyle.sourceforge.io/google_style.html)

### 实现

```xml
<reporting>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-checkstyle-plugin</artifactId>
      <version>${maven.checkstyle.version}</version>
      <configuration>
        <configLocation>google_checks.xml</configLocation>
      </configuration>
    </plugin>
  </plugins>
</reporting>
```

## maven-shade-plugin

### 功能

1. 将依赖的jar包打包到当前jar包
2. 对依赖的jar包进行重命名

### 说明

在打包命令后，执行了

### 实现

```xml
 <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-shade-plugin</artifactId>
        <version>3.1.1</version>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>shade</goal>
            </goals>
            <configuration>
              <artifactSet>
                <excludes>
                  <exclude>jmock:*</exclude>
                  <exclude>*:xml-apis</exclude>
                  <exclude>org.apache.maven:lib:tests</exclude>
                  <exclude>log4j:log4j:jar:</exclude>
                </excludes>
                <includes>
                    <include>junit:junit</include>
                </includes>
              </artifactSet>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-shade-plugin</artifactId>
        <version>3.1.1</version>
        <executions>
          <execution>
            <phase>package</phase>
            <goals>
              <goal>shade</goal>
            </goals>
            <configuration>
              <filters>
                <filter>
                  <artifact>junit:junit</artifact>
                  <includes>
                    <include>junit/framework/**</include>
                    <include>org/junit/**</include>
                  </includes>
                  <excludes>
                    <exclude>org/junit/experimental/**</exclude>
                    <exclude>org/junit/runners/**</exclude>
                  </excludes>
                </filter>
                <filter>
                  <artifact>*:*</artifact>
                  <excludes>
                    <exclude>META-INF/*.SF</exclude>
                    <exclude>META-INF/*.DSA</exclude>
                    <exclude>META-INF/*.RSA</exclude>
                  </excludes>
                </filter>
              </filters>
            </configuration>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
```

## build-helper-maven-plugin

### 功能

添加多个源码目录

### 实现

```xml
<plugin>
  <groupId>org.codehaus.mojo</groupId>
  <artifactId>build-helper-maven-plugin</artifactId>
  <executions>
    <!-- Add src/main/scala to eclipse build path -->
    <execution>
      <id>add-source</id>
      <phase>generate-sources</phase>
      <goals>
        <goal>add-source</goal>
      </goals>
      <configuration>
        <sources>
          <source>src/main/scala</source>
        </sources>
      </configuration>
    </execution>
    <!-- Add src/test/scala to eclipse build path -->
    <execution>
      <id>add-test-source</id>
      <phase>generate-test-sources</phase>
      <goals>
        <goal>add-test-source</goal>
      </goals>
      <configuration>
        <sources>
          <source>src/test/scala</source>
        </sources>
      </configuration>
    </execution>
  </executions>
</plugin>
```

## scalastyle-maven-plugin

### 功能

类似checkstyle，只不过是用在 scala 上的

### 官网

[GitHub - scalastyle/scalastyle-maven-plugin: Maven plugin for Scalastyle](https://github.com/scalastyle/scalastyle-maven-plugin)

## maven-jar-plugin

### 功能

就是打包执行

### 样例

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-jar-plugin</artifactId>
  <version>3.3.0</version>
  <configuration>
      <archive>                           <!-- 存档 -->
        <addMavenDescriptor/>                 <!-- 添加maven 描述 -->
        <compress/>                           <!-- 压缩 -->
        <forced/>
        <index/>
        <manifest>                            <!-- 配置清单（MANIFEST）-->
          <addClasspath/>                         <!-- 添加到classpath 开关 -->
          <addDefaultImplementationEntries/>
          <addDefaultSpecificationEntries/>
          <addExtensions/>
          <classpathLayoutType/>
          <classpathMavenRepositoryLayout/>
          <classpathPrefix/>                      <!-- classpath 前缀 -->
          <customClasspathLayout/>
          <mainClass/>                            <!-- 程序主函数入口 -->
          <packageName/>                          <!-- 打包名称 -->
          <useUniqueVersions/>                    <!-- 使用唯一版本 -->
        </manifest>
        <manifestEntries>                     <!-- 配置清单（MANIFEST）属性 -->
          <key>value</key>
        </manifestEntries>
        <manifestFile/>                       <!-- MANIFEST 文件位置 -->
        <manifestSections>
          <manifestSection>
            <name/>
            <manifestEntries>
              <key>value</key>
            </manifestEntries>
          <manifestSection/>
        </manifestSections>
        <pomPropertiesFile/>
      </archive>

      <excludes>                          <!-- 过滤掉不希望包含在jar中的文件  -->
          <exclude/>
      </excludes>

      <includes>                          <!-- 添加文件到jar中的文件  -->
          <include/>
      </includes>
  </configuration>
</plugin>
```

## maven-assembly-plugin

### 功能

打包，原来可以有三种方式进行打包

### 样例

```xml
<build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>${maven-assembly-plugin.version}<version>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <!-- 绑定到package生命周期 -->
                        <phase>package</phase>
                        <goals>
                            <!-- 只运行一次 -->
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <!-- 配置描述符文件 -->
                    <descriptor>src/main/assembly/assembly.xml</descriptor>
                    <!-- 也可以使用Maven预配置的描述符
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs> -->
                </configuration>
            </plugin>
        </plugins>
    </build>
```

### 例子

  assembly插件的打包方式是通过descriptor（描述符）来定义的。
Maven预先定义好的描述符有bin，src，project，jar-with-dependencies等。比较常用的是jar-with-dependencies，它是将所有外部依赖JAR都加入生成的JAR包中，比较傻瓜化。
但要真正达到自定义打包的效果，就需要自己写描述符文件，格式为XML。下面是我们的项目中常用的一种配置。

```xml
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>${maven-assembly-plugin.version}<version>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <!-- 绑定到package生命周期 -->
                        <phase>package</phase>
                        <goals>
                            <!-- 只运行一次 -->
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <!-- 配置描述符文件 -->
                    <descriptor>src/main/assembly/assembly.xml</descriptor>
                    <!-- 也可以使用Maven预配置的描述符
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs> -->
                </configuration>
            </plugin>
        </plugins>
    </build>
```

### 说明

1. id与formats
  formats是assembly插件支持的打包文件格式，有zip、tar、tar.gz、tar.bz2、jar、war。可以同时定义多个format。
id则是添加到打包文件名的标识符，用来做后缀。
也就是说，如果按上面的配置，生成的文件就是artifactId−artifactId−{version}-assembly.tar.gz。

2. fileSets/fileSet
  用来设置一组文件在打包时的属性。

3. directory：源目录的路径。

4. includes/excludes：设定包含或排除哪些文件，支持通配符。

5. fileMode：指定该目录下的文件属性，采用Unix八进制描述法，默认值是0644。

6. outputDirectory：生成目录的路径。

7. files/file
  与fileSets大致相同，不过是指定单个文件，并且还可以通过destName属性来设置与源文件不同的名称。

8. dependencySets/dependencySet
  用来设置工程依赖文件在打包时的属性。也与fileSets大致相同，不过还有两个特殊的配置：

9. unpack：布尔值，false表示将依赖以原来的JAR形式打包，true则表示将依赖解成*.class文件的目录结构打包。

10. scope：表示符合哪个作用范围的依赖会被打包进去。compile与provided都不用管，一般是写runtime。

按照以上配置打包好后，将.tar.gz文件上传到服务器，解压之后就会得到bin、conf、lib等规范化的目录结构，十分方便。

## maven-compiler-plugin

### 功能

编译，编译不是maven 版本的代码

### 说明

命令mvn的运行需要依赖JDK，Compiler插件默认使用当前运行mvn命令的JDK去编译Java源代码

### 实例

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.7.0</version>
  <configuration>
    <source>1.8</source>
    <target>1.8</target>
    <fork>true</fork>
    <verbose>true</verbose>
    <encoding>UTF-8</encoding>
  </configuration>
</plugin>

```

## 打包小结

- maven-jar-plugin，默认的打包插件，用来打普通的project JAR包；
- maven-shade-plugin，用来打可执行JAR包，也就是所谓的fat JAR包；
- maven-assembly-plugin，支持自定义的打包结构，也可以定制依赖项等。
