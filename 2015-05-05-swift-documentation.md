---
title: Swift Documentation
author: Mattt Thompson & Nate Cook
authors:
    - Mattt Thompson
    - Nate Cook
category: Swift
tags: swift
translator: April Peng
excerpt: "代码的结构和组织关乎了开发童鞋们的节操问题。明确和一致的代码表示了明确和一贯的思想。请仔细阅读，来了解最近在 Xcode 6 和 Swift 文档的变化"
revisions:
    "2014-07-28": Original publication.
    "2015-05-05": Extended detail on supported markup; revised examples.
---

代码的结构和组织关乎了开发童鞋们的节操问题。明确和一致的代码表示了明确和一贯的思想。编译器并没有一个挑剔的口味，但当谈到命名，空格或文档，人类的差异就体现出来了。

NSHipster 的读者无疑会记得[去年发表的关于文档的文章](http://nshipster.cn/documentation/)，但很多东西已经在 Xcode 6 中发生了变化（幸运的是，基本上算是变得更好了）。因此，这一周，我们将在此为嗷嗷待哺的 Swift 开发者们记录一下文档说明。

好了，来让我们仔细看看。

* * *

从 00 年代早期，[Headerdoc](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1) 就一直作为苹果首选的文档标准。从 Perl 脚本解析勉强的 [Javadoc](http://en.wikipedia.org/wiki/Javadoc) 注释作为出发点，Headerdoc 最终成为了苹果在线文档及 Xcode 中的开发者文档的后台引擎。

随着 WWDC 2014 的发布，开发者文档被翻修并进行了时尚的新设计，包含了 Swift 和 Objective-C 的切换。 （如果你[看过任何新的 iOS 8 的在线 API](https://developer.apple.com/library/prerelease/ios/documentation/HomeKit/Reference/HomeKit_Framework/index.html#//apple_ref/doc/uid/TP40014519)，那你已经见过这个新设计了）

**真正让人意外的是，_文档的格式_ 也发生了变化。**

在 Swift 的代码里调用快速文档 (Quick Documentation)（`⌥ʘ`）时 Headerdoc 没有正确解析注释：

~~~{swift}
/**
    让我们随便来写点什么.

    @param 啦啦啦啦，这货是参数。

    @return 咯咯咯咯，这货是返回值。
*/
func foo(bar: String) -> AnyObject { ... }
~~~

![Unrecognized Headerdoc]({{ site.asseturl }}/swift-documentation-headerdoc.png)

但如果修改一下标记方式，就 _可以_ 被正确解析：

![New Recognized Format]({{ site.asseturl }}/swift-documentation-new-format.png)

~~~{swift}
/**
    让我们随便来写点什么.

    :param: 啦啦啦啦，这货是参数。

    :returns: 咯咯咯咯，这货是返回值。
*/
func foo(bar: String) -> AnyObject { ... }
~~~

那么，这个陌生的新文件格式是个什么情况？事实证明，SourceKit（Xcode 使用的私有框架，在此前以其高 FPS 崩溃闻名）包括一个解析 [reStructuredText](http://docutils.sourceforge.net/docs/user/rst/quickref.html) 的基本解析器。虽然仅实现了 [specification](http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#field-lists) 的一个子集，但涵盖基本的格式已经足够了。


#### 基本标记

文档注释通过使用 `/** ... */` 的多行注释或 `///...` 的单行注释来进行区分。在注释块里面，段落由空行分隔。无序列表可由多个项目符号字符组成：`-`、`+`、 `*`、 `•` 等，同时有序列表使用阿拉伯数字（1，2，3，...），后跟一个点符 `1.` 或右括号 `1)` 或两侧括号括起来 `(1)`：

~~~{swift}
/**
	你可以制作 *斜体*, **粗体**, 或 `代码` 的字体风格.
	
	- 列表很不错,
	- 但最好不要叠套
	- 子列表的格式

	  - 就不太好了.

	1. 有序列表也一样
	2. 对那些有序的东西来说;
	3. 阿拉伯数字
	4. 是唯一支持的格式.
*/
~~~


#### 定义与字段列表

定义和字段列表跟 Xcode 里的快速文档弹出内容显示的差不多，定义列表会更紧凑一些：

~~~{swift}
/**
	Definition list
		一些术语以及它们的定义.
	Format
		左对齐术语，放在缩进的定义下面.
		
	:Field header:
		字段列表隔开一些。
		
	:Another field: 字段列表可以紧跟开始，不需要另起一行并缩进。
		随后缩进的行也被视为内容的一部分.
*/
~~~

两个特殊字段用于记录参数和返回值：分别为：`:param:` 和 `:returns:`。`:param:` 后跟的是参数的名称，然后是说明。返回值没有名字，所以  `:returns:` 后就是说明：

~~~{swift}
/**
	重复一个字符串 `times` 次.

	:param: str     需要重复的字符串.
	:param: times   需要重复 `str` 的次数.

	:returns: 一个重复了 `str` `times` 次的新字符串.
*/
func repeatString(str: String, times: Int) -> String {
	return join("", Array(count: times, repeatedValue: str))
}
~~~

### 代码块

代码块也可以嵌入到文档的注释里，这对于演示正确的使用方式或实现细节很有用。用至少两个空格来插入代码块：

~~~{swift}
/**
	`Shape` 实例的面积.
	
	计算取决于该实例的形状。如果是三角形，`area` 将相当于:
	
	  let height = triangle.calculateHeight()
	  let area = triangle.base * height / 2
*/
var area: CGFloat { get }
~~~

## 我的自行车类的新文档

当这个应用在整个类的时候看起来怎么样？事实上，看起来相当的不错：

~~~{swift}
import Foundation

/// 🚲 一个两轮的，人力驱动的交通工具.
class Bicycle {
    /**
        车架样式.

        - Road: 用于街道或步道.
        - Touring: 用于长途.
        - Cruiser: 用于城镇周围的休闲之旅.
        - Hybrid: 用于通用运输.
    */
    enum Style {
        case Road, Touring, Cruiser, Hybrid
    }

    /**
        转换踏板功率为运动的机制。

        - Fixed: 一个单一的，固定的齿轮。
        - Freewheel: 一个可变速，脱开的齿轮。
    */
    enum Gearing {
        case Fixed
        case Freewheel(speeds: Int)
    }

    /**
        用于转向的硬件。

        - Riser: 一个休闲车把。
        - Café: 一个正常车把。
        - Drop: 一个经典车把.
        - Bullhorn: 一个超帅车把.
    */
    enum Handlebar {
        case Riser, Café, Drop, Bullhorn
    }

    /// 自行车的风格
    let style: Style

    /// 自行车的齿轮
    let gearing: Gearing

    /// 自行车的车把
    let handlebar: Handlebar

    /// 车架大小, 厘米为单位.
    let frameSize: Int

    /// 自行车行驶的旅程数
    private(set) var numberOfTrips: Int

    /// 自行车总共行驶的距离，米为单位
    private(set) var distanceTravelled: Double

    /**
        使用提供的部件及规格初始化一个新自行车。

        :param: style 自行车的风格
        :param: gearing 自行车的齿轮
        :param: handlebar 自行车的车把
        :param: centimeters 自行车的车架大小，单位为厘米

        :returns: 一个漂亮的，全新的，为你度身定做.
    */
    init(style: Style, gearing: Gearing, handlebar: Handlebar, frameSize centimeters: Int) {
        self.style = style
        self.gearing = gearing
        self.handlebar = handlebar
        self.frameSize = centimeters

        self.numberOfTrips = 0
        self.distanceTravelled = 0
    }

    /**
        把自行车骑出去遛一圈

        :param: meters 行驶的距离，单位为米
    */
    func travel(distance meters: Double) {
        if meters > 0 {
            distanceTravelled += meters
            ++numberOfTrips
        }
    }
}
~~~

在 `Style` 的 `enum` 声明里使用 Option-click，说明就精美的以符号列表呈现了：

![Swift enum Declaration Documentation]({{ site.asseturl }}/swift-documentation-enum-declaration.png)

对 `travel` 方法快速查看文档，参数一如预期的被解析成单独的字段：

![Swift func Declaration Documentation]({{ site.asseturl }}/swift-documentation-method-declaration.png)


## MARK / TODO / FIXME

在 Objective-C 里，[预处理指令 `#pragma mark`](http://nshipster.com/pragma/) 用来把功能区分成有意义的，易于导航的章节。在 Swift 里，没有预处理指令（最接近的是相似的-井号[编译配置][1]），但同样可以用注释达到效果 `// MARK: `。

在 Xcode 6β4 中，以下注释将出现在 Xcode 的代码导航（source navigator）中：

- `// MARK: ` _(等同于 `#pragma`，记号后紧跟一个横杠 (`-`) 会被编译成水平分割线)_
- `// TODO: `
- `// FIXME: `

> 其他常规注释标记，如 `NOTE` 和 `XXX` 在 Xcode 中不能被识别。

要显示这些新的标签，下面是 `Bicycle` 类如何扩展的使用 `Printable` 协议，并实现 `description` 的。

![Xcode 6 Documentation Source Navigator MARK / TODO / FIXME]({{ site.asseturl }}/swift-documentation-xcode-source-navigator.png)

~~~{swift}
// MARK: Printable

extension Bicycle: Printable {
    var description: String {
        var descriptors: [String] = []
        
        switch self.style {
        case .Road:
            descriptors.append("A road bike for streets or trails")
        case .Touring:
            descriptors.append("A touring bike for long journeys")
        case .Cruiser:
            descriptors.append("A cruiser bike for casual trips around town")
        case .Hybrid:
            descriptors.append("A hybrid bike for general-purpose transportation")
        }
        
        switch self.gearing {
        case .Fixed:
            descriptors.append("with a single, fixed gear")
        case .Freewheel(let n):
            descriptors.append("with a \(n)-speed freewheel gear")
        }
        
        switch self.handlebar {
        case .Riser:
            descriptors.append("and casual, riser handlebars")
        case .Café:
            descriptors.append("and upright, café handlebars")
        case .Drop:
            descriptors.append("and classic, drop handlebars")
        case .Bullhorn:
            descriptors.append("and powerful bullhorn handlebars")
        }
        
        descriptors.append("on a \(frameSize)\" frame")
        
        // FIXME: 使用格式化的距离
        descriptors.append("with a total of \(distanceTravelled) meters traveled over \(numberOfTrips) trips.")
        
        // TODO: 允许自行车被命名吗？
        
        return join(", ", descriptors)
    }
}
~~~

把所有东西都放到代码里来：

~~~{swift}
let bike = Bicycle(style: .Road, gearing: .Freewheel(speeds: 8), handlebar: .Drop, frameSize: 53)

bike.travel(distance: 1_500) // 到处晃一晃
bike.travel(distance: 200) // 骑车去市场

println(bike)
// “公路自行车，具有 8 速飞轮齿轮，经典，下降车把，53” 框架，总的行驶距离 2 次共 1700.0 米。“
~~~

* * *

虽然 Swift 的工具和文档仍在迅速发展，但在早期就通过使用新的轻量级标记语言规范生成文档，以及使用 `MARK: ` 注释来养成良好的习惯是很明智的。

快去试试这些技巧，把它加到你的 `TODO: ` 列表里吧。

[1]: https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-XID_25


**译者注：为了方便大家理解，把这篇文章中的注释翻译成了中文，在实际项目中我们仍然推荐用英文书写。**

