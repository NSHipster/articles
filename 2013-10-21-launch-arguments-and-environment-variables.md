---
title: "Launch Arguments &<br/>Environment Variables"
author: Mattt Thompson
translator: Chester Liu
category: Xcode
excerpt: "有许多选项可以传递给 target 的 scheme，开启一些有用的调试特性。就像快餐店的秘密菜单一样，它们常常是隐蔽而且不为人知的。"
status:
    swift: n/a
---

走进任何一家美国快餐店，你都会看到五颜六色还发着背光的菜单，上面列出了各种特色菜，套餐和可以单点的餐品。但是懂行的人会很快告诉你，大型连锁快餐店经常还会有一个 _秘密_ 菜单，在厨师和顾客之间口口相传，代代相接。

在麦当劳，你可以点一份 “穷人的巨无霸汉堡”，这个魔咒可以把一个双份奶酪汉堡变成麦当劳标志性的廉价三明治。

在 Chipotle，有一个不成文的规矩是，在原料可用的情况下，他们可以制作出任何食物。因为墨西哥食物本身就是原料混搭的代表，点一些菜单上没有的诸如油炸玉米饼和烤干酪玉米片，他们也会很拿手。

生活就是这样，你只是需要知道怎么去问而已。

由此我们开始介绍 Xcode 启动参数和环境变量。有许多选项可以传递给 target 的 scheme，开启一些有用的调试特性。就像快餐店的秘密菜单一样，它们常常是隐蔽而且不为人知的。

这周的 NSHipster ，我们来一探 Xcode 运行时配置的秘密。让你们，亲爱的读者们，也有机会在 Objective-C 的小餐馆里，点到自己真心想要的菜。

* * *

要在应用中使用启动参数和环境变量，在 Xcode 工具栏中选择你的 target 然后点击 “Edit Scheme...”

![Edit Scheme...]({{ site.asseturl }}/launch-arguments-edit-scheme.png)

在左侧的面板中，选择 “Run[AppName].app”，然后在右侧选择 “Arguments” 选项卡，下面会出现两个可下拉的部分，分别是 “Arguments Passed on Launch” 和 “Environment Variables”。

![Edit Scheme Panel]({{ site.asseturl }}/launch-arguments-edit-scheme-panel.png)

从调试一个应用的 target 这个目的看来，启动参数和环境变量可以认为是相同的——它们都是通过定义一些值来改变应用的运行时行为。在实践中，这两者主要的区别是是启动参数以一个横线（`-`）打头，并且没有单独用于参数值的字段。

## 启动传参

任何启动时传递的参数在运行期间会覆盖掉当前 `NSUserDefaults` 中的值。这个特性可以被用于特定领域的测试和调试工作，不过使用最广泛的场景还是在本地化和 Core Data。

### 本地化

本地化本身是一项非常具有挑战性而且耗费时间的工作。幸运的是，有一些启动参数可以让这个过程变得容易 _很多_ 。

> 想了解更多有关本地化的信息，可以查看我们关于 [`NSLocalizedString`](http://nshipster.cn/nslocalizedstring/) 的文章。

#### NSDoubleLocalizedStrings

为了模拟德语当中经常会破坏 UI 而且不会被空格折行的长复合词（类似 _götterdämmere Weltanschauung_），于是有了 `NSDoubleLocalizedStrings` 这个选项。

根据 [IBM 的国际化指南](http://www-01.ibm.com/software/globalization/guidelines/a3.html)，在把英语翻译成很多欧洲语言的时候，文字的长度可能会变成原来的二倍乃至三倍。

<table>
<thead>
<tr>
<th>Number of Characters in Text</th>
<th>Additional Physical Space Required</th>
</tr>
<tbody>
<tr><td>≤ 10</td><td>100% to 200%</td></tr>
<tr><td>11 – 20</td><td>80% to 100%</td></tr>
<tr><td>21 – 30</td><td>60% to 80%</td></tr>
<tr><td>31 – 50</td><td>40% to 60%</td></tr>
<tr><td>51 – 70</td><td>31% to 40%</td></tr>
<tr><td>70</td><td>30%</td></tr>
</tbody>
</table>

当你在等待第一批翻译工作完成的时候，或者你只是想看看多语言环境下 UI 到底能被破坏成什么样子，指定下面这个启动选项：

~~~
-NSDoubleLocalizedStrings YES
~~~

![NSDoubleLocalizedStrings - Before & After]({{ site.asseturl }}/launch-arguments-nsdoublelocalizedstrings.png)

#### NSShowNonLocalizedStrings

项目经理为了让你完成本地化工作而大喊大叫？现在你也可以让你的应用对你大喊大叫了！

如果你使用了 `NSShowNonLocalizedStrings` 这个启动选择，所有没有被本地化的字符串全都会变成大写，多么美妙！（译者注：英文中使用大写字母有对人大声喊叫的含义）

~~~
-NSShowNonLocalizedStrings YES
~~~

#### AppleLanguages

所有启动参数中最有用的大概是 `AppleLanguages`。

一般情况下，要想更改系统语言环境需要经过设置 -> 通用 -> 国际化 -> 语言，然后等待模拟器或者设备重启。现在使用下面这个简单的启动参数就可以完成同样的事情：

~~~
-AppleLanguages (es)
~~~

> `AppleLanguages` 的值可以是语言的名称（"Spanish"），也可以是语言的编码（`es`）。考虑到本地化文件是使用 ISO 639 编码来定位的，因此使用编码比使用语言名称要好一些。

### Core Data

在所有的系统框架当中，Core Data 可能是最依赖于调试的。各种 Managed objects 在 context 和 thread 中传来传去，各种通知来回发送，发生的事情太多，以至于很难一直对程序进行跟踪。这时候就需要下面这些至关重要的启动参数了：

#### SQL 调试

大部分 Core Data 技术栈使用 SQLite 作为持续存储层，如果你的应用和大部分应用都类似的话，你可以在 Core Data 工作的时候到观察 SQL 语句和统计信息.

设置下面这个启动参数：

~~~
-com.apple.CoreData.SQLDebug 3
~~~

...然后让子弹飞一会儿。

~~~
CoreData: sql: pragma cache_size=1000
CoreData: sql: SELECT Z_VERSION, Z_UUID, Z_PLIST FROM Z_METADATA
CoreData: sql: SELECT 0, t0.Z_PK, t0.Z_OPT, t0.ZAUTHOR, t0.ZTITLE, t0.ZCOPYRIGHT FROM ZBOOK t0 ORDER BY t0.ZAUTHOR, t0.ZTITLE
CoreData: annotation: sql connection fetch time: 0.0001s
CoreData: annotation: total fetch execution time: 0.0010s for 20 rows.
~~~

`com.apple.CoreData.SQLDebug` 接收的值在 `1` 到 `3` 直接，值越高代表输出会越详细。

#### 日志语法高亮

想让你的调试语句 _更加炫酷_ 一些？把 `com.apple.CoreData.SyntaxColoredLogging` 这个选项也扔进去，然后做好被各种颜色轰炸的准备：

~~~
-com.apple.CoreData.SyntaxColoredLogging YES
~~~

#### 迁移调试

在其他的持久层当中，迁移数据是一件易事。然而出于某种原因，Core Data 成功地把这件事变成了噩梦。当事情的发展和预期不符，你没有别人可以去责备，只能默默埋怨自己的无知，你感觉自己确实不配使用这样一个直观的，经过良好设计的 <del>ORM</del> <ins>图持久化框架</ins>时，有一个选项可以帮到你：

~~~
-com.apple.CoreData.MigrationDebug
~~~

* * *

## 环境变量

启动参数是针对可执行文件的，环境变量的应用范围更广一些，和全局变量有类似的地方（不过没有被程序员下意识地嘲笑的那部分）。

使用下面几个设置来配置环境，通过定制内存管理策略来帮助调试程序。

> 除非特别声明，环境变量通过传递 `YES` 和 `NO` 来打开和关闭某个特定功能。

### 僵尸!

僵尸在媒体上被过度渲染，在 Objective-C 里却没有得到足够的重视。不管怎样，每个人都知道，要想了解僵尸是需要付出一定的代价的。

设置 `NSZombie` 有关的环境变量，可以让你控制应用的 _脑子啊啊啊！_ 。具体说，当对象被释放之后，它们会被“僵尸化”，使它们能够继续接受消息。这个特性可以用于追踪运行时出现的 `EXC_BAD_ACCESS` 异常。

<table>
<thead>
<tr>
<th>Name</th><th>Effect</th></tr>
</thead>
<tbody>
<tr><td><tt>NSZombieEnabled</tt></td></td><td>If set to <tt>YES</tt>, deallocated objects are 'zombified'; this allows you to quickly debug problems where you send a message to an object that has already been freed.</td></tr>
<tr><td><tt>NSDeallocateZombies</tt></td><td>If set to <tt>YES</tt>, the memory for 'zombified' objects is actually freed.</td></tr>
</tbody>
</table>

### 内存分配器

内存分配器包含了几个可以通过环境变量打开的调试钩子。苹果在[Memory Usage Performance Guidelines](https://developer.apple.com/library/mac/documentation/performance/Conceptual/ManagingMemory/Articles/MallocDebug.html) 中解释道：

> Guard Mallock 是一个特殊版本的 malloc 库，在调试时会替换掉标准库的实现。Guard Malloc 使用了若干技术，可以让你的应用在内存错误发生的时候崩溃掉。例如，它在不同的虚拟内存页上分配多个分开的内存块，然后当内存被释放掉的时候，删除掉整个内存页。之后企图访问被释放掉的内存时，会直接造成内存异常，而不是随便获取一块儿可能含有其他数据的内存区域。当崩溃发生时，你可以直接在调试器中检查失败的位置，定位具体的问题。

下面是最有用的几个选项：

<table>
<thead>
<tr><th>Name</th><th>Effect</th></tr>
</thead>
<tbody>
<tr><td><tt>MallocScribble</tt></td><td>Fill allocated memory with 0xAA and scribble deallocated memory with <tt>0x55</tt>.</td></tr>
<tr><td><tt>MallocGuardEdges</tt></td><td>Add guard pages before and after large allocations.</td></tr>
<tr><td><tt>MallocStackLogging</tt></td><td>Record backtraces for each memory block to assist memory debugging tools; if the block is allocated and then immediately freed, both entries are removed from the log, which helps reduce the size of the log.</td></tr>
<tr><td><tt>MallocStackLoggingNoCompact</tt></td><td>Same as <tt>MallocStackLogging</tt> but keeps all log entries.</td></tr>
</tbody>
</table>

### I/O 缓冲

尽管可能性不大，你还是可能会碰到，一些情况下你需要让 `stdout` 中的日志以非缓冲模式输出（确保在前一个输出被打印出来之后再打印下一个）。你可以通过设置 `NSUnbufferedIO` 环境变量做到这一点：

<table>
<thead>
<tr><th>Name</th><th>Effect</th></tr>
</thead>
<tbody>
<tr><td><tt>NSUnbufferedIO</tt></td><td>If set to YES, Foundation will use unbuffered I/O for <tt>stdout</tt> (<tt>stderr</tt> is unbuffered by default).</td></tr>
</tbody>
</table>

* * *

就像秘密菜单会受到哥德尔不完备定理的限制一样，我们不可能列出所有能让 Xcode 拿出特色菜的秘密咒语。然而你还是可以通过苹果的 [Technical Note TN2239: iOS Debugging Magic][TN2239] 和 [Technical Note TN2124: OS X Debugging Magic][TN2124] 获取更多的有关内容（同时学习到 _一堆的_ runtime 内部知识）。

希望这篇文章里展示的秘密知识能够持续地为你所用。聪明地使用它们，并且把它们传递给你的同事吧，就像散播那些都市传奇和八卦谣言一样。

[TN2239]: https://developer.apple.com/library/ios/technotes/tn2239/_index.html
[TN2124]: https://developer.apple.com/library/mac/technotes/tn2124/_index.html
