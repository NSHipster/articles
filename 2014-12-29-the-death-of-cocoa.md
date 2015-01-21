---
layout: post
title: The Death of Cocoa
category: ""
author: Mattt Thompson
translator: Henry Lee
excerpt: "对于我们大多数而言，苹果的简洁、优雅和它软硬件的结合是我们为什么在这个平台开发的原因，尽管如此，即使Swift才开始被使用几个月，Cocoa已经开始失去它原有的光芒了。"
---
Cocoa实际就是Objective-C的标准库，包含了许多语言里最基本的框架，例如Foundation、AppKit和Core Data。而Cocoa Touch基本上是用UIKit替换AppKit，而且它能与Cocoa在公用很多系统框架。
对于我们大多数而言，苹果的简洁、优雅和它软硬件的结合是我们为什么在这个平台开发的原因。实际上，我们在这个网站上也从来不吝啬对Cocoa设计与功能的吹捧。

尽管如此，即使Swift才开始被使用几个月，Cocoa已经开始失去它原有的光芒了。我们都见到了Swift作为终结Objective-C的开始，但是Cocoa呢？_(这
已经不是苹果第一次把它的标准库淘汰了，记得Carbon么)_

Swift的现代语言特性使它产出的代码更安全也更有效率。但是，如果你觉得Swift不过是编译器工具团队的一次小小的分心其实也是能被原谅的，因为很少一部分Switf的好处最终帮到传统应用的开发。

让Objective-C与Swift代码各种各样互相交互在一开始是一个战略上的、在论证后必要的决策。让团队里更有冒险精神的工程师把Swift介绍给既有工程对于这门新语言的广泛接受是十分关键的。但是对于所有资源映射和API校对的工作来说，有一个论点被提出来了：Cocoa已经开始成为了一个不利因素。

如果我们用Swift基本库重新建立一套Foundation会怎么样？我们会如何不同地实现呢？我们又能从过去的错误里学到什么？这在NSHipster里看起来像是个奇怪的主题，因为NSHipster毕竟是一个基于对Objective-C和Cocoa的喜爱才建立起来的网站，但是，这依旧是一个值得尝试的主题。

所以，为了结束作为iOS开发者历史性的一年，让我们来稍微花些时间往前看看未来的可能。

***

>如果说我看得更远，那是因为我站在巨人的肩膀上。  
><cite>艾萨克·牛顿</cite>

我们的高效率生产力其实都是欠的标准库的。

在做得好的情况下，标准库不仅提供了一些最常用基础架构的实现，而且他们用一种可转移的方式澄清了很多概念。这也是一门语言标准库偏离现有的习俗开始[变糟糕](http://eev.ee/blog/2012/04/09/php-a-fractal-of-bad-design/)的时候。

例如，[`NSURLComponents`](http://nshipster.com/nsurl/)符合[RFC 3986](http://www.ietf.org/rfc/rfc3986)标准，并在[文档](https://developer.apple.com/library/prerelease/ios/documentation/Foundation/Reference/NSURLComponents_class/index.html)上标注得很清晰。不仅API消费者自动地吸收了作为用法副产品的术语和概念，而且对于已经熟悉RFC 3986的新API使用者依旧能积极地开工（究竟写文档有多容易呢？你还是点开链接自己去读文档吧）。

标准库须实现标准。

当我们说科技应该更直觉化，我们一般的意思是他们应该与我们之前熟悉的东西相似。从IETF、ISO等来的标准应该作为新标准库建立的根基。

基于这个断言，让我们来看看一些Cocoa做过的具体的例子，并看看一个新的Swift基本库在哪些地方可以提高。Swift里没有了这样的概念，也就没有建构它的实际内容了。


### Numbers

`Number`是一个纯粹封装了整数、浮点数、双精度数和布尔值等原始数据类型的对象。没有了以上顾虑的Swift，倒是没有建立这个结构的必要了。

Swift标准库已经通过绝妙的[上层函数与操作符](http://nshipster.com/swift-default-protocol-implementations/)的结合与类型继承在建立数值基元上做了很棒的工作(额外加分项还有包括 [二进制文件的文字化、八进制十六进制与十进制的相加](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_487))。由于缺乏一些现在比较真实的反馈，这里只有一些可能被加进来的建议：

- `NSDecimalNumber`的一个合适的替换。Swift的`Double`在[文档上](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_484)说是有64位的，而`NSDecimalNumber`是可以代表["可以表示为`小数部分x10^次方`的任意数，小数部分是一个高达38位的十进制数，而指数部分则是可以从`-128`到`127`的整数"](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSDecimalNumber_Class/index.html)。同时，[这个代码段](https://gist.github.com/mattt/1ed12090d7c89f36fd28)也为Swift的`NSDecimalNumber`提供了一些必要的补充。

- 复数的支持，例如在这个[代码段](https://gist.github.com/mattt/0576b9e4396ab5645aa9)里说的

- 更简单的本地的随机数[生成方法](http://nshipster.com/random/)。[这个代码段](https://gist.github.com/mattt/f2ee2eed3570d1a9d644)提供了一些类似的例子。

- 一些通过Swift的重载为多个数的运算提供统一的接口，例如[Surge](https://github.com/mattt/surge)里做的。

- 在Playgrounds里增加增加一些内置的计算框架，例如[Euler](https://github.com/mattt/euler)所作的，那在Playgrounds还能变成一个很好的教学工具。

### String

字符串的危险在于它能够编码如此不同的信息，例如在[前文所述](http://nshipster.com/nslocalizedstring/)。

> 字符串可能是在计算里最通用的数据类型了。他们能传递符号、编码数值、连接键值、表示支援了路径、储存与发信息和格式化的内容。

尽管如此，`NSString`可能有些_太过_通用了。尽管它处理Unicode的时候信手拈来，但是整个API被字符串和路径的混合所负累，`stringByAppendingPathComponent:`和与它类似的方法都十分有用，但是这个有用最终导致了把URL当做字符串的滥用。

以上其实是因为像类似于`@"this"`（一个字符串本身）比`[NSURL URLWithString:@"that"]`（一个构造函数）要方便多了。但是，有了[Swift字符串转换工具](http://nshipster.com/swift-literal-convertible/)，建立URL或者路径将会更容易。

Swift的`String`一个真心聪明的设计选择是，它在内部使用了与编码无关的Unicode字符串，并暴露了以下编码方式：

> - UTF-8字符集（通过`String`的`utf8`属性访问）
> - UTF-16字符集（通过`String`的`utf16`属性访问）
> - 21位的Unicode标量，相当于字符串的UTF-32编码 （通过`String`的`unicodeScalars`属性访问）

Swift的`String`的唯一一个抱怨就是，它的功能有多少被它上层函数隐蔽的方式所掩盖了。许多开发者都被训练成打一个`.`然后等待着方法自动完成蹦出来类似`count`的属性，用类似`countElements`之类的上层函数查阅起来相较而言肯定没那么明显。（再一次强调，正如在[协议默认实现](http://nshipster.com/swift-default-protocol-implementations/)）一篇文章里描述的一样，这可以通过Xcode或者Swift本身桥接模糊函数来解决。

###URI、URL和URN

一个理想的URL实现应该是一个由`NSURLComponents`构成的值的类型（也就是`结构`），它能避免所有之前提到的在`NSString`里路径相关的API，[还有这些](https://gist.github.com/mattt/d2fa3107e41c63e875e5)。根据[RFC 4395](http://tools.ietf.org/html/rfc4395)，一个清晰的URL策略实现应该减少文件路径的耦合，而这正是`NSURL`在做的。根据[RFC 2141](https://www.ietf.org/rfc/rfc2141)，一个漂亮的URN实现一定会让开发者意识到URN是什么、URIs、URL和URN是如何互相联系的，并因此让开发者感觉满眼惊奇_(再一次，这些都是一些可传递的技巧)_。

### 数据结构

从发生器、序列到集合，Swift的基础数据结构还挺美好的。`Array`和`Dictionary`语法糖的余咏很好地平衡了越来越有趣的底层标注库的边界。

在如此强壮的基础类型的基础上，一个只上了本科计算机科学的人都能用这些数据结构的结合十分容易地创造产品。加上维基百科和一个闲暇的下午，基本上每个人都能做到、至少能几近能做到。

如果Swift标准库能提供类似树、单向链表、双向链表、栈、列表等结构的标准实现那就更好了，不过我只做一个举例：数据集（Set）。

在Foundation框架里的三大集合分别是`NSArray`、`NSDictionary`、和 `NSSet`（以及他们的可变对应），而在Swift里，`Set`是唯一缺失的。作为一个基础数据结构，它能应用到很广泛的案例当中。特别是对于Swift，集合能解决越来越尴尬的语言问题的其中一个[RawOptionSetType](http://nshipster.com/rawoptionsettype/)。

> 另外，[Nate Cook](http://nshipster.com/authors/nate-cook/)已经实现了一个[漂亮、完备的`Set`实现](http://natecook.com/blog/2014/08/creating-a-set-type-in-swift/)供您参考。


### 日期和时间

日历功能是Cocoa里历史最悠久也是最健壮的功能之一了吧。相较于其他语言令人恐惧的日期编程，你不会在用`NSDate`或者`NSCalendar`的时候有类似的恐惧。尽管如此，它还是越来越难用并且难以扩展。

为了进行日历计算，例如计算从今天起一个月以后的日期，你会用到`NSCalendar`和[`NSDateComponents`](http://nshipster.com/nsdatecomponents/)，这_是正确的_做法，但是至少，大部分开发者还在用`dateWithTimeIntervalSinceNow:`并用一个常数秒来计算时间间隔。悲剧的是，没有一个API能直接立马做以上功能，不过那也好过通过一个错的方式做到。

另一个`NSCalendar`的一个小失误是它没有提供新的日历功能，对于有时候我们要实现[法国公历](http://en.wikipedia.org/wiki/French_Republican_Calendar)的时候，还是很麻烦的。

不过幸运的是，Swift的所有新语言特性能用来非常优雅地解决这些问题，我已经完成了实现了一些，但是一个有通用术语的日历系统还是需要蛮多功夫的。如果你想带我一起完成这个挑战，[这是我的一些想法](https://gist.github.com/mattt/7edb54f8f4fde4a3783e)。

### 数据交换格式

Objective-C还有一个令人震惊的是，他花了这么久（iOS 5 / OS X Lion!）才提供了一个标准方法来处理JSON。希望用_最流行的Web服务的交换格式_的开发者只能被迫使用一堆互不兼容的第三方库。

尽管如此，`NSJSONSerialization`在Swift里依然是一场灾难，我们只能继续用第三方类库。


```Objective-c
NSData *data;
NSError *error = nil;
id JSON = [NSJSONSerialization JSONObjectWithData:data
                                          options:0
                                            error:&error];
if (!error) {
    for (id product in JSON[@"products"]) {
        NSString *name = product[@"name"];
        NSNumber *price = product[@"price"];

        // ...
    }
}
```

```swift
let data: NSData
var error: NSError? = nil
if let JSON = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary {
    for product in JSON["products"]! as NSArray {
        let name: String = product["name"] as String
        let price: Double = product["price"] as Double
    }
}
```

> 帮苹果辩护一下的话，我曾经在WWDC Lab上问过一个苹果的工程师，为什么iOS经过了那么长时间才开始支持JSON，他们的回答还是十分在理的，如下：
>> 苹果是一家有十分长远技术眼光的公司，而其实是_十分_困难去看清一个像JSON的技术是否能持久，还是只是昙花一现。苹果曾经发布过一个给[PubSub](https://developer.apple.com/library/mac/documentation/InternetWeb/Reference/PubSubReference/_index.html)用的框架，这个框架并没有被广泛知道或使用，但是苹果仍需要为一些可预测的未来给它提供支持，每项技术都是对工程师资源的读博。

数据处排列和序列化是无聊的任务，无聊的任务更应该交给一个标注库去处理，苹果在开发Cocoa的时候就知道这个道理，他们据此开发了健壮的字符串和二进制文件机制[属性列表](http://en.wikipedia.org/wiki/Property_list)，它是iOS和OSX的生命之源。也许长期预计其他的数据交换格式的发展是一件困难的事情，但是提供为紧急的技术提供官方支持的基础试用版本能够帮开发者提供提高很多。

### 正则表达式

正杂表达式是一叠脚本语言，它足够可以有一本详尽的语法说明了`/ /`。如果Swift是从Cocoa演化过来，那最好能加入一个`NSRegularExpression`的继承者，例如这个[封装](https://gist.github.com/mattt/3f12f56d72b8d2ebbe62)。

### 错误

Objective-C还是习惯用[错误指针](http://nshipster.com/nserror/)(`NSError **`)来处理运行时异常，而不是用`@throw`来抛出。以下是每一个Cocoa开发者应该熟悉的范式：

```objective-c
NSError *error = nil;
BOOL success = [[NSFileManager defaultManager] moveItemAtPath:@"/path/to/target"
                                                       toPath:@"/path/to/destination"
                                                        error:&error];
if (!success) {
    NSLog(@"%@", error);
}
```
返回的`error`是一个针对Objective-C只能有一个返回值的处理，如果有错误产生，`NSError`的实例会被赋予一个包含错误详情的值，然后被返回。

在Swift里，这一个范式其实是不必要了的，因为方法在Swift里能返回元组，顺便就把一个optional的真正的返回值和可能错误返回了：

```swift
func moveItemAtPath(from: String toPath to: String) -> (Bool, NSError?) { ... }
```

我们甚至还能更进一步，来定义一个拥有泛型的`Result`类型，在成功与失败的时候返回相应的值：

```swift
struct Error { ... }

public enum Result<T> {
    case Success(T)
    case Failure(Error)
}
```
用了上面这个范式，错误处理将被编译器强制着要考虑所有情况：

```swift
HTTPClient.getUser { (result) in
    switch result {
    case .Success(let user):  // Success
    case .Failure(let error): // Failure
    }
}
```
为了极大提升现有的纯Swift设置，上面这种范式已经在社区里出现。它对于编纂一些最有用的标准库并在为开发者提升讨论效率而创建的一个共有的话语习惯是十分有用的。

### AppKit和UIKit

AppKit和UIKit是整篇讨论的主题，似乎他们俩在各自分开走路一步以后，又会在Swfit这里融合起来。一个更有意思的问题是，是否Swfit会拓展到iOS和OS X开发智商，例如系统级别的或者Web脚本，而这又会从根本上改变Cocoa作为一个基本库的角色。

* * *


## 想得更远一些


或许我们把一个基本库能成为的东西想得太小了。

作为一种变成语言，Wolfram在这里有[所有Demo之母](https://www.youtube.com/watch?v=_P9HqHVPeik#t=1m02.5s)（[抱歉冒犯了，Douglas Engelbart](http://en.wikipedia.org/wiki/The_Mother_of_All_Demos)）。

> 姑且认为，Wolfram是一个另一个平行宇宙里的计算方式，其他一切都不存在，它的语言本身也是一团糟。

这是一个他[标准库](http://reference.wolfram.com/language/)提供功能的概览:

|  |  |  |  |
|----------------------------|-------------------------|--------------------------------|--------------------------|
| 2D / 3D 视觉化 | 图像分析 | 数据分析 | 图像处理 |
| 音频处理 | 机器学习 | 方程求解 | 数值运算 |
| 任意精度 | 微积分计算 | 矩阵运算 | 字符串处理 |
| 组合优化 | 计算几何 | 数据库连接 | 内建测试 |
| 设备连接 | 函数式编程 | 自然语言理解 | 序列分析 |
| 时序 | 地理数据 | 地理映射 | 天气信息 |
| 物理化学数据 | 基因组数据 | 单位与测量 | 控制论 |
| 可靠性分析 | 并行计算 | 工程数据 | 金融数据 |
| 金融计算 | 社会经济学数据 | 大众文化数据 | 布尔运算 |
| 数论 | 文档生成 | 表格式化 | 数学排版 |
| 交互式控件 | 接口架设 | 组织好的结构 | XML模板 |


传统的智者肯定会建议说道，是的，让一个标准库去计算[电影《阿凡达》的预算](http://reference.wolfram.com/language/ref/MovieData.html#Examples)、[McDonnell Douglas F/A-18 Hornet的最快飞行速度](http://reference.wolfram.com/language/ref/AircraftData.html#Example)或者[法国的形状](http://reference.wolfram.com/language/ref/CountryData.html#Example)是完全不可能的，那分别是查询IMDb、抓取维基百科和导入GIS系统应该做的。

但是另外的，像[转换英里到公里](http://reference.wolfram.com/language/ref/UnitConvert.html#Example)、计算[聚类值](http://reference.wolfram.com/language/ref/FindClusters.html)和[知道地球的大小](http://reference.wolfram.com/language/ref/PlanetData.html#Example)这些东西，是对不同应用环境都是大体有用的。

确实，把Cocoa和其他标准库区分开的是它在`NSLocale`和`NSCalendar`里的一些特定信息，但是其他的更多信息来自于[Unicode Common Locale Data Repository (CLDR)](http://cldr.unicode.org).

那究竟是什么让标注库停止吸收其他数据源里的内容呢？为什么不暴露一个接口去访问[libphonenumber](https://github.com/googlei18n/libphonenumber)，或者拓展[HealthKit已经做了的](http://nshipster.com/nsformatter/#mass,-length,-&-energy-formatters)到一些更基本的单位？

把这些数据以一种更有意义更有效的方式组织起来，恐怕对于第三方框架来说太多了，也寄托了太多的沉重负担给开源世界的自由市场。

> 是的，多年以来，一个标准库的角色问题，就如同社会里公开与隐私的问题，无党派自由主义者遇到了另一个无党派自由主义。

* * *

Swift的紧迫不光在这个语言本身能做到什么，而是在与它对于苹果公司，对于iOS和OS X开发者以及更广泛的开发者社区他能做到什么。技术上的可行性问题永远不能从其带来的经济社会后果摆脱，实在有太多因素要考虑。

Swift会以开源的形式发布么？在Safari里加上解释器以后，Swift会不会成为撼动Javascript这个唯一的Web脚本语言？最终，这些问题都会影响到Swift标准库到底是什么样子。如果Swift会变成一个移动系统的脚本语言，那它首先得从Objective-C运行时和一堆沉重的依赖中摆脱出来。

有一点肯定的是，Cocoa，如同Objective-C一样，注定要逝去，这基本不是一个会不会的问题，而是什么时候的问题_(当然，我们说的是现在开始后的几年时间，应该不会有人争辩Objective-C和Cocoo会立即消亡吧)_。

**Swift标准库正处于与Cocoa冲突的一个过程，只要新的语言再继续增加势头，我们将会很快看到旧物的破碎与新的系统框架的重新诞生。**

三十年来，这些技术很好地为我们服务，我们最好的纪念这些贡献的方式是从他们的错误中学习，让这些技术的取代者们超牛逼。

























