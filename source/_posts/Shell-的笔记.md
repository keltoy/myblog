---
title: Shell 的笔记
date: 2019-07-04 11:13:56
tags: [Shell]
---

# Preface

翻开上学的时候破破烂烂的本子，看到刚开始学习 linux 的一些shell 总结，还是将这些记到网上好一些，有些还是挺实用的，我感觉

# 慢慢更新 ...

## \$[] \$(()) expr

这两个括号可以执行基本的算数操作（也就是 + - * / ）

```bash
 #!/bin/sh bash
result=3
r=4
echo $(($r + $result))
echo $[$r + $result]
echo `expr 3 + 4`
```

> 注意的是空格，赋值语句 = 两边不能有 空格；expr 后的表达式需要 __空格__

## bc 

具体功能就是调用计算器

```bash
" 4 * 0.56 "|bc
```

> 依然注意 __空格__ bc 前的|不能跟空格

## 标准输入输出

|符号|说明|
|--:|---:|
|0  |stadin 标准输入|
|1  |stadout 标准输出|
|2  |staderr 错误输出|
|>  |覆盖写入重定向|
|>> |追加写入 |
|<  |读取文件 |

```bash
cmd 2>stderr.txt 1>stdout.txt
cmd >output.txt 2>&1
cmd &> output.txt #上面的简写
cat <<EOF >log.txt # 将EOF之前的数据写入log.txt
```

除此以外，还有 3,4,5 备用标准输入输出

```bash
exec 3<input.txt
cat <&3 # 输出input.txt的数据
```

```bash
exec 4>output.txt
echo newline >&4
cat output.txt # 输出newline
```

```bash
exec 5>>output.txt
echo append >&5
cat output.txt # 输出的数据会增加append 这一行 
```

## tee

输出到文件，标准输入输出还是会输出

### 参数
-a: 追加文件

```bash
cat a* | tee out.txt | cat -n
```
结果保存到了 out.txt, 不影响后续操作

## 数组

```bash
array_var=(1 2 3 4 5)
# 或者
array_var[0]=1
array_var[2]=3
echo ${array_var[0]}
```

声明关联数组

```bash
declare -A ass_array
ass_array=([key1]=var1 [key2]]=var2)
ass_array=[key3]=var3
echo ${! ass_array[*]} 列出key
echo ${! ass_array[@]} 列出key
```


## $ 相关

| 名称 | 说明 |
|:---:|:----:|
| $$ | shell本身的 pid|
| ${CMD} | 执行CMD命令 |
| $! | shell最后运行的后台process的PID |
| $? | 最后运行命令的结束代码(exit(0)) | 
| $- | 查看 使用set 命令设置的flag |
| $* | 所有的 参数列表 一般 [$*] 表示所有的形参 |
| $@ | 所有的参数，类似$* 也是 [$@] |
| $# | 添加到shell的参数个数 |
| $0 | shell 的文件名 |
| $1 | 第一个参数|
| \${\$1:- \$2} | 如果$1不为空则使用$1 否则$2|

## tput

终端的一些设置

```bash
tput cols # 获取终端列数
tput lnes # 获取终端行数
tput longname # 打印当前终端名
tput cup 100 100 # 将光标移动到 100 100
tput setb [0-7] # 设置终端背景色 在zsh 好行不行
tput setf [0-7] # 设置终端前景色 在zsh 好像不行
tput bold # 文本样式改为粗体
tput smul # 下划线
tput rmul # 下划线
tput ed # 删除当天光标，位置到行尾
tput rc # 恢复光标位置
tput sc # 存储光标位置
```

# set 

设置一些参数和环境

```bash
set -x # 执行时显示参数和命令，可以查看
set +x # 禁止显示参数和命令
set -v # 读取时会显示输入
set +v # 读取时禁止显示输入
set -e # 如果执行的语句不为true 或者会说返回值不为0 则直接退出 脚本
```
也可以写在第一行解释器里

```bash
#1bin/bash -xv
```

# 分隔符 IFS

使用 IFS 对 分割符对数据分割，例如
```bash
data="name,sex,rollno,location"
oldIFS=$IFS
IFS=,
for item in $data;
do
echo Item:$item
done
IFS=$oldIFS
```

## 循环

```bash
for var in list;
...
for ((i=0;i<10;i++))
{
...
}
while condition
...
until condition
...
{1..50} # 序列
```

## read

就是读取，写交互脚本的时候比较常用

```bash
read -n num var # 读取num个字符保存到var中
read -s var # 不回显信息，经常用作密码
read -p "hint" var # 显示提示
read -t timeout var # 定时输入，单位：秒
read -d delim_char var # 使用界定符结束行
```

## 算数比较 [ ] test

注意 括号 和参数之间都有空格

```bash
[ $var -ne 0 -a $var2 -gt 2 ] # var != 0 and var2 > 2
[ $var -ne 0 -o $var2 -gt 2 ] # var != 0 or var2 > 2

```

-a: and
-o: or
-f 是否文件或目录存在
-x 是否为可执行文件
-d 目录是否存在
-e 文件是否存在
-c 是否是字符设备文件的路径
-b 是否是块设备文件的路径
-w 是否可写
-r 是否可读
-L 是否是符号链接

另外 test 也有类似的用法

```bash
if [$var -eq 0]; 
if test $var -eq 0 # save as above
```

## 字符串比较 [[ ]]

还是注意 括号和参数之间都要有空格

```bash
[[ $str1 = $str2 ]]
[[ $str1 == $str2 ]] # same as above

[[ -z $str ]] # 是否是空字符串
[[ -n $str ]] # 是否不为空
```

= 或 == 相等
!= 不等
\> 字母序列大于
< 字母序列小于

## cat 拼接

```bash
echo 'this is a test' | cat - file.txt # 输出和文件拼接到一起
cat -s file # 删除空行
cat file | tr -s '\n' #移除空白行
cat -T file #显示隐藏字符（制表符)
cat -n file #打印行号
```

## find 查找

常用指令

```bash
find base_path # 获取base_path下所有的文件和目录

find . -type d -print # 获取当前目录下所有子目录并打印出来

find . \( -name ".txt" -o -name "*.pdf" \) -print

find . -type f -atime -7 -print #访问7天内
find . -type f -atime 7 -print #访问第7天
find . -type f -atime +7 -print #7天之前访问

find . -type f -size +2k #大于2k的文件

find . \( -name ".git" -prune \) -o \( -type f -print \)
```

-print 打印
-printo 以\o作为界定符
-type 类型 d: 目录, f: 文件, l: 链接 s: socket c:设备 p: FIFO
-name 名称，可以用 "*" 表示任意
-iname 忽略大小写
-path "xxx" 目录下有xxx的
-regex 正则
-iregex 不区分大小写
-atime 访问时间
-mtime 修改（内容）时间
-ctime 更改（meta own ）时间 时间为天
-newer xxx 比xxx修改时间更长的文件
-size 文件大小 b块 c字节 w字 k千字节 M兆 G吉
-delete 删除找到的这些文件或目录
-perm 644 权限
-user root 文件owner是root的
-exec command 执行指令
-prune 忽略
-o or 或者

找到用户是root 并都改成slynux

```bash
find . -type f -user root -exec chown slynux {} \; 
```

```bash
-exec ./commands.sh {} \;
-exec printf "xxxx%s" {} \;
```

