---
title: Xcode Key Bindings & Gestures
author: Mattt Thompson
category: Xcode
tag: popular
translator: Croath Liu
excerpt: "Xcode 快捷键和手势不仅节省了宝贵的工作时间，而且能让你在工作过程中感到更自信、能力变得更强，这样的工作方式也更合理。"
---

在某种程度上来说将编程当作一门手艺来和纯粹的手工艺比如说木工来比较，挺烦人的。特别是说到大家应该像木匠和石匠一样了解和掌握所使用的工具的时候…得了吧，哥们别这么说了。那种对技巧有强烈要求的人才会这么说，比如忍者可能会说“让你的剑保持锋利尖锐并隐藏在黑暗中”，摇滚明星会说“一天必须要给吉他调两次音，给自己的头发定两次型”。

而作为一个 NSHipster 的建议既简单又有一点轻微的寓言式的意味：“Xcode 就是 NSHipster 的小胡子（见我们的 logo），你要勤于修剪它，给它打点蜡来保持锋利的边角，不要生虫（此处原文是一个双关，free of bugs，也表示没有 bug）。”

无论怎样我们先看看几周前发布的 [Xcode Snippets](http://nshipster.com/xcode-snippets/) 通过减少重复代码键入对你的生产力提高有多少。本周，我们继续这个话题来看快捷键和手势。

Xcode 快捷键和手势不仅节省了宝贵的工作时间，而且能让你在工作过程中感到更自信、能力变得更强，这样的工作方式也更合理。学习下列技巧你将成为 Xcode 资深用户。

---

> 此处提供一些通用的按键符以供参考（也可以参考这个 [我们不要脸地借用来的国际语音学字母表](http://en.wikipedia.org/wiki/Click_consonant)）：

<table id="xcode-key-bindings-modifiers">
  <thead>
    <tr>
      <th>Command</th>
      <th>Control</th>
      <th>Option</th>
      <th>Shift</th>
      <th>Click</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>⌘</tt></td>
      <td><tt>⌃</tt></td>
      <td><tt>⌥</tt></td>
      <td><tt>⇧</tt></td>
      <td><tt>ʘ</tt></td>
    </tr>
  </tbody>
</table>

## 快速打开 (`⇧⌘O`)

![Open Quickly](http://nshipster.s3.amazonaws.com/xcode-shortcuts-quick-open.png)

学习快速打开可以更少依赖 Project Navigator。这个功能太讨人喜欢了，Xcode 通过带有部分匹配和位置匹配功能的快速打开帮助你输入的字符找到你想要的东西。

---

## 快速查看文档 (`⌥ʘ` / 三指轻拍) <br/> 打开文档 (`⌥ʘʘ`)

![Quick Documentation](http://nshipster.s3.amazonaws.com/xcode-shortcuts-quick-documentation.gif)

快速查看文档可能是开发者需要学习的第一个 Xcode 快捷键。只需要在任意类、变量、常量上按住 alt 点击（或三指轻拍），Xcode 就会该处显示出一个简洁的文档。Alt 加双击会打开文档窗口并进入相关界面。

## 跳到定义 (`⌘ʘ`)

对于 Xcode 使用者来说另一个同样有名的快捷键就是跳到定义，这个动作会打开编辑窗口到相关的 `@interface` 定义或 `.h` 文件中常量定义的地方。这个功能对于在类似于 Foundation 这样陌生的系统框架中看代码时很实用，能帮你看到它们的背后 _到底_ 发生了什么。

## 副本间切换 (`^⌘↑` / `^⌘↓` / 三指竖划)

![Jump to Next Counterpart](http://nshipster.s3.amazonaws.com/xcode-shortcuts-counterpart.gif)

下面这个，但不是最后一个，就是副本间切换，这可能是每天用得最多的快捷键了。在 `.h` 文件和与其对应的 `.m` 实现文件中使用三指上下划的动作（如果你喜欢的话也可以使用 `^⌘↑` / `^⌘↓` ）来进行快速切换。

---

## 注释选中部分 / 当前行 (`⌘/`)

![Comment Selection](http://nshipster.s3.amazonaws.com/xcode-shortcuts-comment.gif)

是的你 _可以_ 通过对代码增删断点的方式来进行调试，但是这里有一个更简单强大的方法可以对代码进行注释或取消注释。这个快捷键可以对当前行或选中部分添加添加 `//` 注释。

## 显示 Standard Editor (`⌘↵`) <br/> 显示 Assistant Editor (`⌥⌘↵`) <br/> 显示 Version Editor (`⌥⇧⌘↵`)

![Editors](http://nshipster.s3.amazonaws.com/xcode-shortcuts-editors.gif)

Assistant Editor 那么好用但却没有几个工程师可以准确记住开关它的快捷键。现在在你的脑子里记住 `⌘↵` 和 `⌥⌘↵`，以后你就能让 Xcode 帮助你更多了。

![Assistant Editor Position](http://nshipster.s3.amazonaws.com/xcode-shortcuts-assistant-editor-position.png)

另一方面，如果不太满意编辑器的排列方式，在 View > Assistant Editor 中可以选择垂直活着水平排列。

---

![Panels](http://nshipster.s3.amazonaws.com/xcode-shortcuts-panels.gif)

编辑器的左右两侧就像一个三明治，导航栏和工具栏将代码夹在它们爱的怀抱里。在需要内心平静时，学习如何显示有用的部分以及如何让它们 GTFO，能够实现生产力的最大化。

## 显示/隐藏导航条 (`⌘0`)

## 选择导航栏 (`⌘1, ..., ⌘8`)

1. Project Navigator
2. Symbol Navigator
3. Find Navigator
4. Issue Navigator
5. Test Navigator
6. Debug Navigator
7. Breakpoint Navigator
8. Log Navigator

## 显示/隐藏工具条 (`⌥⌘0`)

## 选择工具栏 (`⌥⌘1, ⌥⌘2, ...`)

### 源文件

1. File Inspector
2. Quick Help

### Interface Builder

1. File Inspector
2. Quick Help
3. Identity Inspector
4. Attributes Inspector
5. Size Inspector
6. Connections Inspector

## 显示/隐藏调试区域 (`⇧⌘Y`) <br/> 激活 Console (`⇧⌘C`)

![Show / Hide Debug Area](http://nshipster.s3.amazonaws.com/xcode-shortcuts-debug-area.gif)

有人怀念 Xcode 3 中能够独立分离的调试窗口吗？反正我是很怀念。

知道如何一键打开和关闭调试区域以及激活 console 可能没什么大用，但多多少少会帮助你减少痛苦或损失。

---

## 查找 (`⌘F`) /<br/>查找替换 (`⌥⌘F`) /<br/>在工程中查找 (`⇧⌘F`) /<br/>在工程中查找和替换 (`⌥⇧⌘F`)

![Find](http://nshipster.s3.amazonaws.com/xcode-shortcuts-find.gif)

因为 Xcode 对代码进行重构的能力实在是太弱了...或者说大多数时候都帮不上忙。另一方面，Xcode 支持对纯文本的引用、定义以及正则搜索。

## 拼写和语法检查 (`⌘:`)

![Spelling & Grammar](http://nshipster.s3.amazonaws.com/xcode-shortcuts-spelling-and-grammar.png)

Clang 如此强大也不能在注释中更正你那噩梦一般的语法和标点使用。特别是当有人将代码开源时，你需要用 OS X 内建的拼写和语法检查帮自己一把。

---

![Xcode Shortcut Preferences](http://nshipster.s3.amazonaws.com/xcode-shortcuts-preferences.png)

当然了还有更有趣的事情！像任何拿得出手的编辑器一样，Xcode 允许你对每一个菜单项和 app 中的所有行为自定义快捷键。

这里提供一些可能有用的非正式快捷键，可能会帮得到你：

- `^w`: 关闭文档 (replaces Delete to Mark)
- `^⌘/`: 显示 / 隐藏工具栏
- `^⌘F`: _None_ (去掉 Full Screen 模式 (至少在 Mavericks 之前能用))

你想分享给大家更多有用的快捷键吗？在 Twitter 上 [@NSHipster](https://twitter.com/NSHipster) 来告诉我们！
