---
title: Swift Documentation
author: Mattt Thompson & Nate Cook
authors:
    - Mattt Thompson
    - Nate Cook
category: Swift
tags: swift
excerpt: "Code structure and organization is a matter of pride for developers. Clear and consistent code signifies clear and consistent thought. Read on to learn about the recent changes to documentation with Xcode 6 & Swift."
translator: April Peng
excerpt: "代码的结构和组织关乎了开发童鞋们的节操问题。明确和一致的代码表示了明确和一贯的思想。请仔细阅读，来了解最近在 Xcode 6 和 Swift 文档的变化"
revisions:
    "2014-07-28": Original publication.
    "2015-05-05": Extended detail on supported markup; revised examples.
---

Code structure and organization is a matter of pride for developers. Clear and consistent code signifies clear and consistent thought. Even though the compiler lacks a discerning palate when it comes to naming, whitespace, or documentation, it makes all of the difference for human collaborators.

代码的结构和组织关乎了开发童鞋们的节操问题。明确和一致的代码表示了明确和一贯的思想。编译器并没有一个挑剔的口味，但当谈到命名，空格或文档，人类的差异就体现出来了。

Readers of NSHipster will no doubt remember the [article about documentation published last year](http://nshipster.com/documentation/), but a lot has changed with Xcode 6 (fortunately, for the better, in most cases). So this week, we'll be documenting the here and now of documentation for aspiring Swift developers.

NSHipster 的读者无疑会记得[去年发表的关于文档的文章](http://nshipster.cn/documentation/)，但很多东西已经在 Xcode 6 中发生了变化（幸运的是，基本上算是变得更好了）。因此，这一周，我们将在此为嗷嗷待哺的 Swift 开发者们记录一下文档说明。

Let's dive in.

好了，来让我们仔细看看。

* * *

Since the early 00's, [Headerdoc](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1) has been the documentation standard preferred by Apple. Starting off as little more than a Perl script parsing trumped-up [Javadoc](http://en.wikipedia.org/wiki/Javadoc) comments, Headerdoc would eventually be the engine behind Apple's developer documentation online and in Xcode.

从 00 年代早期，[Headerdoc](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1) 就一直作为苹果首选的文档标准。从 Perl 脚本解析勉强的 [Javadoc](http://en.wikipedia.org/wiki/Javadoc) 注释作为出发点，Headerdoc 最终成为了苹果在线文档及 Xcode 中的开发者文档的后台引擎。

With the announcements of WWDC 2014, the developer documentation was overhauled with a sleek new design that could accommodate switching between Swift & Objective-C. (If you've [checked out any of the new iOS 8 APIs online](https://developer.apple.com/library/prerelease/ios/documentation/HomeKit/Reference/HomeKit_Framework/index.html#//apple_ref/doc/uid/TP40014519), you've seen this in action)

随着 WWDC 2014 的发布，开发者文档被翻修并进行了时尚的新设计，包含了 Swift 和 Objective-C 的切换。 （如果你[看过任何新的 iOS 8 的在线 API](https://developer.apple.com/library/prerelease/ios/documentation/HomeKit/Reference/HomeKit_Framework/index.html#//apple_ref/doc/uid/TP40014519)，那你已经见过这个新设计了）

**What really comes as a surprise is that the _format of documentation_ appears to have changed as well.**

**真正让人意外的是，_文档的格式_ 也发生了变化。**

In the midst of Swift code, Headerdoc comments are not parsed correctly when invoking Quick Documentation (`⌥ʘ`):

在 Swift 的代码里调用快速文档 (Quick Documentation)（`⌥ʘ`）时 Headerdoc 没有正确解析注释：

~~~{swift}
/**
    Lorem ipsum dolor sit amet.

    @param bar Consectetur adipisicing elit.

    @return Sed do eiusmod tempor.
*/
func foo(bar: String) -> AnyObject { ... }
~~~

![Unrecognized Headerdoc](http://nshipster.s3.amazonaws.com/swift-documentation-headerdoc.png)

What _is_ parsed, however, is something markedly different:

但如果修改一下标记方式，就 _可以_ 被正确解析：

![New Recognized Format](http://nshipster.s3.amazonaws.com/swift-documentation-new-format.png)

~~~{swift}
/**
    Lorem ipsum dolor sit amet.

    :param: bar Consectetur adipisicing elit.

    :returns: Sed do eiusmod tempor.
*/
func foo(bar: String) -> AnyObject { ... }
~~~

So what is this strange new documentation format? It turns out that SourceKit (the private framework powering Xcode, previously known for its high FPS crashes) includes a basic parser for [reStructuredText](http://docutils.sourceforge.net/docs/user/rst/quickref.html). Only a subset of the [specification](http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#field-lists) is implemented, but there's enough in there to cover basic formatting.

那么，这个陌生的新文件格式是个什么情况？事实证明，SourceKit（Xcode 使用的私有框架，在此前以其高 FPS 崩溃闻名）包括一个解析 [reStructuredText](http://docutils.sourceforge.net/docs/user/rst/quickref.html) 的基本解析器。虽然仅实现了 [specification](http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#field-lists) 的一个子集，但涵盖基本的格式已经足够了。


#### Basic Markup

#### 基本标记

Documentation comments are distinguished by using `/** ... */` for multi-line comments or `/// ...` for single-line comments. Inside comment blocks, paragraphs are separated by blank lines. Unordered lists can be made with several bullet characters: `-`, `+`, `*`, `•`, etc, while ordered lists use Arabic numerals (1, 2, 3, ...) followed by a period `1.` or right parenthesis `1)` or surrounded by parentheses on both sides `(1)`:

文档注释通过使用 `/** ... */` 的多行注释或 `///...` 的单行注释来进行区分。在注释块里面，段落由空行分隔。无序列表可由多个项目符号字符组成：`-`、`+`、 `*`、 `•` 等，同时有序列表使用阿拉伯数字（1，2，3，...），后跟一个点符 `1.` 或右括号 `1)` 或两侧括号括起来 `(1)`：

~~~{swift}
/**
	You can apply *italic*, **bold**, or `code` inline styles.
	
	- Lists are great,
	- but perhaps don't nest
	- Sub-list formatting

	  - isn't the best.

	1. Ordered lists, too
	2. for things that are sorted;
	3. Arabic numerals
	4. are the only kind supported.
*/
~~~

#### Definition & Field Lists

#### 定义与字段列表

Defininition and field lists are displayed similarly in Xcode's Quick Documentation popup, with definition lists a little more compact:

定义和字段列表跟 Xcode 里的快速文档弹出内容显示的差不多，定义列表会更紧凑一些：

~~~{swift}
/**
	Definition list
		A list of terms and their definitions.
	Format
		Terms left-justified, definitions indented underneath.
		
	:Field header:
		Field lists are spaced out a little more.
		
	:Another field: Field lists can start the body immediately, without a line break and indentation.
		Subsequent indented lines are treated as part of the body, too.
*/
~~~

Two special fields are used to document parameters and return values: `:param:` and `:returns:`, respectively. `:param:` is followed by the name of the paramenter, then the description. Return values don't have a name, so the description begins immediately after `:returns:`:

两个特殊字段用于记录参数和返回值：分别为：`:param:` 和 `:returns:`。`:param:` 后跟的是参数的名称，然后是说明。返回值没有名字，所以  `:returns:` 后就是说明：

~~~{swift}
/**
	Repeats a string `times` times.

	:param: str     The string to repeat.
	:param: times   The number of times to repeat `str`.

	:returns: A new string with `str` repeated `times` times.
*/
func repeatString(str: String, times: Int) -> String {
	return join("", Array(count: times, repeatedValue: str))
}
~~~

#### Code blocks

### 代码块

Code blocks can be embedded in documentation comments as well, which can be useful for demonstrating proper usage or implementation details. Inset the code block by at least two spaces:

代码块也可以嵌入到文档的注释里，这对于演示正确的使用方式或实现细节很有用。用至少两个空格来插入代码块：

~~~{swift}
/**
	The area of the `Shape` instance.
	
	Computation depends on the shape of the instance. For a triangle, `area` will be equivalent to:
	
	  let height = triangle.calculateHeight()
	  let area = triangle.base * height / 2
*/
var area: CGFloat { get }
~~~

## Documentation Is My New Bicycle

## 文档是我的新工具

How does this look when applied to an entire class? Quite nice, actually:

当这个应用在整个类的时候看起来怎么样？事实上，看起来相当的不错：

~~~{swift}
import Foundation

/// 🚲 A two-wheeled, human-powered mode of transportation.
class Bicycle {
    /**
        Frame and construction style.

        - Road: For streets or trails.
        - Touring: For long journeys.
        - Cruiser: For casual trips around town.
        - Hybrid: For general-purpose transportation.
    */
    enum Style {
        case Road, Touring, Cruiser, Hybrid
    }

    /**
        Mechanism for converting pedal power into motion.

        - Fixed: A single, fixed gear.
        - Freewheel: A variable-speed, disengageable gear.
    */
    enum Gearing {
        case Fixed
        case Freewheel(speeds: Int)
    }

    /**
        Hardware used for steering.

        - Riser: A casual handlebar.
        - Café: An upright handlebar.
        - Drop: A classic handlebar.
        - Bullhorn: A powerful handlebar.
    */
    enum Handlebar {
        case Riser, Café, Drop, Bullhorn
    }

    /// The style of the bicycle.
    let style: Style

    /// The gearing of the bicycle.
    let gearing: Gearing

    /// The handlebar of the bicycle.
    let handlebar: Handlebar

    /// The size of the frame, in centimeters.
    let frameSize: Int

    /// The number of trips travelled by the bicycle.
    private(set) var numberOfTrips: Int

    /// The total distance travelled by the bicycle, in meters.
    private(set) var distanceTravelled: Double

    /**
        Initializes a new bicycle with the provided parts and specifications.

        :param: style The style of the bicycle
        :param: gearing The gearing of the bicycle
        :param: handlebar The handlebar of the bicycle
        :param: centimeters The frame size of the bicycle, in centimeters

        :returns: A beautiful, brand-new, custom built just for you.
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
        Take a bike out for a spin.

        :param: meters The distance to travel in meters.
    */
    func travel(distance meters: Double) {
        if meters > 0 {
            distanceTravelled += meters
            ++numberOfTrips
        }
    }
}
~~~

Option-click on the `Style` `enum` declaration, and the description renders beautifully with a bulleted list:

在 `Style` 的 `enum` 声明里使用 Option-click，说明就精美的以符号列表呈现了：

![Swift enum Declaration Documentation](http://nshipster.s3.amazonaws.com/swift-documentation-enum-declaration.png)

Open Quick Documentation for the method `travel`, and the parameter is parsed out into a separate field, as expected:

对 `travel` 方法快速查看文档，参数一如预期的被解析成单独的字段：

![Swift func Declaration Documentation](http://nshipster.s3.amazonaws.com/swift-documentation-method-declaration.png)


## MARK / TODO / FIXME

In Objective-C, [the pre-processor directive `#pragma mark`](http://nshipster.com/pragma/) is used to divide functionality into meaningful, easy-to-navigate sections. In Swift, there are no pre-processor directives (closest are the similarly-octothorp'd [build configurations][1]), but the same can be accomplished with the comment `// MARK: `.

在 Objective-C 里，[预处理指令 `#pragma mark`](http://nshipster.com/pragma/) 用来把功能区分成有意义的，易于导航的章节。在 Swift 里，没有预处理指令（最接近的是相似的-井号[编译配置][1]），但同样可以用注释达到效果 `// MARK: `。

As of Xcode 6β4, the following comments will be surfaced in the Xcode source navigator:

在 Xcode 6β4 中，以下注释将出现在 Xcode 的代码导航（source navigator）中：

- `// MARK: ` _(等同于 `#pragma`，记号后紧跟一个横杠 (`-`) 会被编译成水平分割线)_
- `// TODO: `
- `// FIXME: `

> Other conventional comment tags, such as `NOTE` and `XXX` are not recognized by Xcode.

> 其他常规注释标记，如 `NOTE` 和 `XXX` 在 Xcode 中不能被识别。

To show these new tags in action, here's how the `Bicycle` class could be extended to adopt the `Printable` protocol, and implement `description`.

要显示这些新的标签，下面是 `Bicycle` 类如何扩展的使用 `Printable` 协议，并实现 `description` 的。

![Xcode 6 Documentation Source Navigator MARK / TODO / FIXME](http://nshipster.s3.amazonaws.com/swift-documentation-xcode-source-navigator.png)

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
        
        // FIXME: Use a distance formatter
        descriptors.append("with a total of \(distanceTravelled) meters traveled over \(numberOfTrips) trips.")
        
        // TODO: Allow bikes to be named?
        
        return join(", ", descriptors)
    }
}
~~~

Bringing everything together in code:

把所有东西都放到代码里来：

~~~{swift}
let bike = Bicycle(style: .Road, gearing: .Freewheel(speeds: 8), handlebar: .Drop, frameSize: 53)

bike.travel(distance: 1_500) // Trip around the town
bike.travel(distance: 200) // Trip to the store

println(bike)
// "A road bike for streets or trails, with a 8-speed freewheel gear, and classic, drop handlebars, on a 53" frame, with a total of 1700.0 meters traveled over 2 trips."
~~~

* * *

Although the tooling and documentation around Swift is still rapidly evolving, one would be wise to adopt good habits early, by using the new light markup language conventions for documentation, as well as `MARK: ` comments in Swift code going forward.

虽然 Swift 的工具和文档仍在迅速发展，但在早期就通过使用新的轻量级标记语言规范生成文档，以及使用 `MARK: ` 注释来养成良好的习惯是很明智的。

Go ahead and add it to your `TODO: ` list.

快去试试这些技巧，把它加到你的 `TODO: ` 列表里吧。

[1]: https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-XID_25
