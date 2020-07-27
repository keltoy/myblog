---
title: Emacs Tutorials
date: 2016-11-06 23:20:48
tags: [ emacs ]
---

# Preface

笔记本上的东西还是要放到网上的，当作一个备份了。一开始学习 emacs 的时候有很多坑要踩，现在好了，基本适应了，以后多用用应该问题不大了。

# Emacs

|标记|代表按键|
|:-:|:-:|
|C-  | Control |
|S-  | Shift   |
|M-  | Alt(Option) ／ ESC|
|RET | Return  |
|SPC | Space   |
|DEL | Backspace(Delete)|

总的来说，无论是装逼需要，还是提高效率，Emacs 的学习我个人认为还是挺有用的，慢慢习惯了这个方式之后，其实会发现，想问题的思路被打开了。

几个简单的指令，也是最常用的

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|M-x|execute-extended-command| 执行命令|
|C-u (#)/M-(#) key|  |重复#次 key|
|C-g| keyboard-quit |停止当前输入|
|C-x u| undo | 撤销命令 |
|S-u | revert-buffer | 撤销上次保存后的所有改动|
|| recover-file | 从自动保存文件中恢复|
|| recover-session | 恢复此次会话所有文件|
|\<f10\>| menu-bar-open| 打开菜单栏|

## Help

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|C-h ?| help-for-help|  如何使用帮助，SPC和DEL滚动，ESC退出|
|C-h t| help-withtutorial| 快速指南|
|C-h r| info-emacs-manual| 使用手册|
|C-h i / S-?| info | 说明|
|C-h a| apropos-command| (模糊)搜索指令|
|C-h v| describe-variable| 查看变量说明|
|C-h f| describe-function| 查看函数说明|
|C-h m| describe-mode|当前mode相关文档|
|C-h k KEYS| describe-key KEYS| 查看KEYS对应的命令|
|C-h c KEYS| describe-key-briefly KEYS| 查看KEYS简要说明|
|C-h w| where-is |查看命令对应的快捷键|
|C-h b| describe-bindings| 当前buffer 的所有快捷键|
|KEYS c-h| |以KEYS开头的快捷键列表|
||apropos|查找相关函数，命令，变量，模式等|
|C-h i| describe-input-method| 查看输入方法|



## File

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|C-x C-f|find-file|打开文件或者目录|
|C-x C-c|save-buffers-kill-emacs| 保存退出|
|C-x C-z|suspend-frame| 挂起（最小化）|
|C-x i| insert-file|当前光标处插入文件|
|C-x C-v| find-alternate-file|关闭当前buffer并打开新文件|
|C-x C-s| save-buffer|保存|
|C-x C-w| write-file|另存为|
|C-x RET r|revert-buffer-file-coding-system|以指定编码读取文件|
|C-x RET f|set-buffer-file-coding-system|以指定编码保存文件|
|C-x d| dired| 进入目录列表模式|
|C-x C-d| list-directory|获取文件列表（简洁）|

## Cursor

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|C-f|forward-char| 字符前进|
|C-b|backward-char| 字符后退|
|M-f|forward-word| 单词前进|
|M-b|backward-word| 单词后退|
|M-e|forward-sentence| 句子前进|
|M-a|backward-sentence| 句子后退|
|C-a|move-beginning-of-line| 移动到行首|
|C-e|move-end-of-line|移动到行尾|
|M-}|forward-paragraph|移动到段尾|
|M-{|backward-paragraph|移动到段首|
|M-<|beginning-of-buffer|buffer首|
|M->|end-of-buffer|buffer尾|
|C-p|previous-line|上一行|
|C-n|next-line|下一行|
|M-v|scroll-down-command|下翻页|
|C-v|scroll-up-command|上翻页|
|M-g M-g|goto-line|跳转到指定行|
|C-M-l|reposition-window|当前行到页面顶端／中间|
|C-M-o|split-line|切割行|
||recenter|到当前页面中间行|

## Cut, Del, Copy and Paste

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|C-d|delete-char|删除字符|
|DEL|backward-delete-char-untabify|后退删除|
|M-d|kill-word|从光标处删除词|
|M-DEL|backward-kill-word|删除词首到光标处|
|C-k|kill-line|删除行|
|M-k|kill-sentence|删除句子|
|C-S-Backspace|kill-whole-line|删除整行（目前还没有找到Backspace）|
|C-@|set-mark-command|选中区域|
|C-x C-x| exchange-point-and-mark|交换 mark 点|
|C-w|kill-region|剪切|
|M-w|kill-ring-save|复制|
|C-y|yank|粘贴|
|M-y|yank-pop|粘贴更早内容|
|C-x r k|kill-rectangle|列模式剪切|
|C-x r y|yank-rectangle|列模式粘贴|
|C-x r o|open-rectangle|列模式插入|
|C-x r c|clear-rectangle|列模式清空，变空白|
|C-x r t|string-rectangle|列模式填充|
|C-x r d|delete-rectangle|列模式删除|

## Buffer

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|C-x C-b|list-buffers|查看 buffer|
|C-x b|switch-to-buffer|切换／新建 buffer|
|C-x LEFT/Right|previous-buffer/next-buffer|切换 buffer|
|C-x k| kill-buffer|关闭 buffer|
|C-x s| save-some-buffers|保存所有 buffer|

## window

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|C-x 2|split-window-below|水平分割|
|C-x 3|split-window-right|竖直分割|
|C-x 1|delete-other-windows|关闭其他所有 window|
|C-x 0|delete-window|关闭当前 window|
|C-x o|other-window|切换 window|
|C-M-v|scroll-other-window|滚动其他 windown|
|C-x ^|enlarge-window|扩大 window|
||shrink-window|缩小 window|
|C-x 4 f| find-file-other-window|在其他 window 中打开文件|
|C-x 4 0|kill-buffer-and-window|关闭当前 buffer 和 window|
|C-x 5 2|make-frame-command|新建 frame|
|C-x 5 f| find-file-other-frame|在其他 frame中打开文件|
|C-x 5 o| other-frame|切换其他 frame|
|C-x 5 o| delete-frame|关闭当前 frame|

## Undo, Redo

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|C-/|undo|撤销一次|
|C-_|undo|撤销一次|

## Search, Replace

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|C-s|isearch-forward|向前搜索|
|C-M-s|isearch-forward-regexp|向前正则搜索|
|C-r|isearch-backword|向后搜索|
|C-M-r|isearch-backward-regexp|向后正则搜索|
|M-%|query-replace|替换（SPC,DEL 控制）|
|C-M-%|query-replace-regexp|正则替换|

|查找指令|说明|
|:-:|:-----:|
|^|行首|
|$|行尾|
|\\\<|词首|
|\\\>|词尾|

|替换指令|说明|
|:-:|:-----:|
|.|仅替换当前匹配并退出|
|,|替换，暂停|
|!|替换以下所有匹配|
|^|回到上一个匹配|
|RET/q|退出|

## Other

|指令|命令名称|说明|
|:-:|:-----:|:--:|
|M-c||字母大写|
|M-! cmd||执行cmd shell指令|
||shell|打开 shell|
||term|执行shell|
