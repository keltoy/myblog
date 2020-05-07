---
title: How to display grid in Pandas
date: 2016-10-08 17:07:57
tags: [code, python]
---
# 前言

>“Life is short, You need Python.”
-- Bruce Eckel

Manager说是要把处理的数据展示出来......我就想偷个懒直接使用Matplotlib实现得了，省着使用 [D3.js](https://d3js.org/) 了，当然如果需要的话，还是很好转过来的。

首先吧，因为不仅需要展示，还需要处理后的数据，所以为了其他人方便，就吧结果存成了csv格式的了。其他格式都大同小异，js还在学习过程中，而且公司的本调试起来非常不方便，所以才使用的 Python...

# 使用DataFrame展示

 一开始想的就是调用 matplotlib.pylab 画图，表里面的一个 column 作为横轴，另一个column作为纵轴然后就可以了。但是后来我发现没那么复杂，DataFrame 直接就可以调用 plot....

```python
import pandas as import pd
df = pd.read_csv(filename)
df.plot()
```

发现了这个之后感觉我的代码又一次简化了....

# 显示网格

这个其实没啥说的， 看一下 plot 的 api 有一个参数就叫做 grid，把这个赋值成 True，就行了。

```python
df.plot(grid=True)
```

# 显示点

然后我就给了我的Manager。Manager说，不行啊，图上的点都没有突出...
于是图形再次修改，查到 plot 函数是实现 matplotlib 的 plotting 方法的，所以可以使用 marker 参数的，于是又有了如下修改。

```python
df.plot(marker='o', grid=True)
```

其中 'o' 代表的就是每个点使用圆圈标注。

# 调整刻度

这下应该可以了吧？ Manager 又来传话：网格的间距太大，能不能缩小一点？
呃.... 我看了看 API，貌似没有什么可以把网格缩小的方法....
于是，我又一次把问题想复杂了....
网格的大小实际上就是刻度的大小，如果刻度数量太多了，那么 DataFrame 自己会进行调整，但是这样的调整可能太大了，不符合人眼观测。所以，调整轴间距就可以完全满足。xticks 和 yticks，这里我只使用了xticks。调整完毕之后发现一连串的问题，生成的图片太小，根本看不清楚，横轴的标识全都挤在了一起无法辨认，很临界点看着不舒服....
还好，plot 函数还是很强大的，有参数都能解决。

```python
df.plot(figsize=(25,15), marker='o', grid=True, xticks=[n for n in range(0, len(df), 10)], rot=30)
```
基本上就满足了所有的要求，感觉不错，就交给了 Manager，Manager也觉得不错。

# 注意的地方

因为一次需要生成的图很多，所以我写了一个循环，针对每一个 item 生成一幅图。如果使用 jupyter 编写的时候需要图片嵌入到浏览器中，"%matplotlib inline" 这句不能少。
我的横轴坐标是时间轴，不是数组，一开始困扰我的是，如何才能把刻度写成一个列表。后来查了一些资料，好像明白了，DataFrame 在运行的时候，实际上会把横轴的刻度转换成数组，所以，横轴的处理只需要像数组一样处理，就可以...

基本上源码长成这样：

```python
%matplotlib inline
import os
import pandas as pd
import matplotlib.pylab as plt

ls = os.listdir(os.getcwd())

for i in ls:
    df = pd.read_csv(i, index_col=['date'])
    try:
      plot = df.plot(figsize=(25, 15), marker='o', grid=True, xticks=[n for n in range(0, len(df), 10)], rot=30)
      fig = plot.get_figure()
      fig.savefig(i+'.jpg')
      plt.close()
    except:
      print ("omit..." + i)

```

* 每次生成图片的时候需要关闭 matplotlib.pylab，一开始的时候没注意，没有 close，导致循环中的图片是不断累加的，到最后已经无法辨识。
* figsize的默认单位是英寸 (inch)。我还以为是厘米，结果画的图都超大...
* xticks 里的参数 n 和 外层循环的 i 不能重名，原因是像 [i for i in range (42)] 这样的表达式不是使用闭包实现的，所以同名会有冲突
* xticks 中 不能写成 [n+10 for n in range(len(df))] 这样的形式，我试过，只是从第 11 个开始，具体原因，我猜想可能跟 Python 后绑定变量有关系，有待考量。

# 结语
可视化的东西之前接触的比较少，一上来就让我使用 D3.js 去实现，一开始感觉蛮吃力的，因为没有 js 基础。后来慢慢发现 js 的强大，转而比较 Python 发现各有利弊。这是我第一次使用 matplotlib 画图，如果没有 D3.js 基础，或者条件不允许使用 D3.js，matplotlib 快速生成批量图片还是蛮方便的。
