---
title: 'Emacs: org-mode'
date: 2017-01-18 11:20:41
tags: [emacs, code]
---

> Time and tide wait for no man

# Preface

已经听了很多人说 org-mode 非常好用，一直不知道怎么用，今天看了看一些文章，发现其实和 markdown 有那么点像，总结总结，想自己做个 GTD。

# Org-mode

## Chapter

md 中的章节使用 "#"，而 org-mode 中使用 "\*"。

不过，org-mode 有一些有趣的操作：

1. S-tab, toggle 所有的 chapter
2. tab, toggle 当前的 chapter
3. M-left/right, 升级/降级 chapter  
4. M-up/down, 调整 chapter 的顺序

## List

### 无序

md 无序队列使用 "\*" 和 "\+"，而 org-mode 使用 "\+" 和 "-"。

注意到的是 md 的间距是不同的：

* 这是 "\*" 的第一行
* 这是第二行

+ 这是 "\+" 的第一行
+ 这是第二行

### 有序

md 的有序使用的是 "1. 2. 3." 这样，而 org-mode 使用的是 "1) 2) 3)"


### 其他

org-mode 提供一种 checkbox 可以检查当前行是否完成，使用 [ ] ，注意括号里面必须有空格：

```
1) [ ] Task1 [%] # or [/]
    1) [ ] step1
    2) [X] step2
    3) [ ] step3
```

标记 "X" 使用 org-toggle-checkbox(C-c C-x C-b，至少我的是这样)，

当然也支持 M-up/down/left/right

M-RET 插入同级列表项
M-S-RET 插入带有 checkbox 的列表项

## Table

## Footnotes
