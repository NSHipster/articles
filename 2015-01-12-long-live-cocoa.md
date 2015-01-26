---
title: "Long Live Cocoa"
author: Nate Cook
translator: Henry Lee
category: ""
excerpt: "Swift 是一个对于我们大多数人而言十分令人兴奋的语言，但是它依旧崭新。Objective-C 的稳定性和 Cocoa 的底蕴也意味着 Swift 确实没有准备好成为巨大改变的驱动力，至少现在没有。Cocoa 的深度和它提供的力量，与 Swift 携手让 Cocoa 变得从未如此相关与有前景。事实上，作为一个 Cocoa 开发者我不认为有比现在更兴奋的时候。"
---

现在正是属于 Watch 的2015年的伊始，也是 Swift 的第一年，也是 NSHipster 的一个小小的新起点。在我们为新设备和下一个 beta 版本的 Xcode 的发布兴奋之前，或者在我们为 WWDC 2015 的行程准备之前，让我们先花点时间看看我们今天用的这些工具，以及他们现在的样子：Objective-C、Swift 和最重要的 Cocoa。

Swift 是一个对于我们大多数人而言十分令人兴奋的语言，但它依旧崭新。Objective-C 的稳定性和 Cocoa 的底蕴也意味着 Swift 确实没有准备好成为[巨大改变](/the-death-of-cocoa/)的驱动力，至少现在没有。Cocoa 的深度和它提供的力量，与 Swift 携手让 Cocoa 变得从未如此相关与有前景。事实上，作为一个 Cocoa 开发者我并不认为有比现在更兴奋的时刻。

* * *

Cocoa 是一个可以非常深的 API，你只要把一些常用工具从表面挖深一点点，你就会发现一堆被藏起来的功能。无须太远，你可以直接从 [Mattt](http://nshipster.com/authors/mattt-thompson/) 这几年来做过的不可思议的工作中找到证据，这些证据告诉我们，其实还有很多我们并不知道的 Cocoa 能做到的。举几个例子来说：

- 一些基础的自然语言接口：[`NSLinguisticTagger`](http://nshipster.cn/nslinguistictagger/) 和 [`AVSpeechSynthesizer`](http://nshipster.com/avspeechsynthesizer/)
- 简单数据持久化：[`NSCoding` 和 `NSKeyedArchiver`](http://nshipster.cn/nscoding/)
- 面向对象的并行执行接口：[`NSOperation`](http://nshipster.cn/nsoperation/)
- 规范并翻译多种语言的输入：[`CFStringTransform`](http://nshipster.cn/cfstringtransform/)
- 检测所有种类的数据：[`NSDataDetector`](http://nshipster.com/nsdatadetector/)
- 原生的自定义分享与编辑的控件：[`UIActivityViewController`](http://nshipster.com/uiactivityviewcontroller/) 和 [`UIMenuController`](http://nshipster.com/uimenucontroller/)
- 内建的给 [NSURL](http://nshipster.cn/nsurl/) 请求的缓存：[NSURLCache](http://nshipster.cn/nsurlcache/)

这个列表还可以有很多，要查看的话，请出门右转到[首页](/#archive)。

### 携起手来

另外，对于 Swift 来说，Cocoa 和 Swift 实际上本来就是为了对方而生的。

对于 Cocoa，这几年工具集的改变为 Swift 版本的 Cocoa 铺平了道路，使得 Swift 一出生就能在 Cocoa 下可用。 编译器转换到 LLVM/Clang、为 Objective-C 添加 block 语法、推动 `NS_ENUM` 和 `NS_OPTIONS` 宏、将初始化方法的返回改为 `instancetype`，所有这些步骤都让我们现在在用的 Cocoa API 相比于几年前更与 Swift 兼容。当你想用 Swift 闭包作为 `NSURLSession` 的完成句柄，或者使用 `UIModalTransitionStyle` 建议的完成处理的时候，你就在这些的工作的基础上做事，这些基础工作的完成可能在 Swift 发布几年前（或者还在 Swift 还在 Chris Lattner 脑海里的时候）。

Swift 的设计初衷还就是为了在 Cocoa 下的精心使用。如果我提名一项很多[初学者都很苦恼](http://stackoverflow.com/search?q=swift+unwrapped+unexpectedly)的 Swift 特性，那一定是有多余的符号和解包要求的 Optional。尽管如此，Optional 代表着至高的成就，这个成就太基础了，反倒感觉销声匿迹了：Swift 是一个崭新的语言，但是它*不需要*全新的 API。它是一个类型安全、内存的安全、主要目的是为了直接与满是指针与原始内存的无数 C 语言 Cocoa 交互的语言。

这不是一个小小的壮举。苹果的开发者工具团队已经在忙于标注整个关于参数与返回值的内存管理信息，一旦标注完成，那 C 函数就可以在 Swift 里自如地使用，因为编译器知道怎样把类型从 Swift 和标注好了的 C 代码来回桥接。

这里是一个做了内存标注的和没有做的函数例子，首先 C 版本：

````c
// 创建一个不可变的字符串
CFStringRef CFStringCreateCopy ( CFAllocatorRef alloc, CFStringRef theString );
// 讲一个 OSType编码进字符串好让它可以用作一个标签参数
CFStringRef UTCreateStringForOSType ( OSType inOSType );
````

两个函数都返回了一个 `CFStringRef`，一个 `CFString` 的引用。 一个 `CFStringRef` 可以与 Swift 里的 `CFString` 实力桥接，但是这这只在这个方法已经被标注了一个后。在 Swift 里，你能很容易地看出区别：

````swift
// 标注了的: 返回一个已经被内存管理的 `CFString`
func CFStringCreateCopy(alloc: CFAllocator!, theString: CFString!) -> CFString!
// 没被标注的: 返回一个没有被内存管理的 `CFString`
func UTCreateStringForOSType(inOSType: OSType) -> Unmanaged<CFString>!
````

在收到了一个 `Unmanaged<CFString>!` 以后，你接下来需要用 `.takeRetainedValue()` 和 `.takeUnretainedValue()` 来得到一个已经内存管理好的 `CFString` 实例，而究竟调用那个，你需要去看文档或者知道管理结果是否是 retained 或者 unretained 的既有习惯。而标注了这些方法以后，苹果为你做了这些工作，保证了在 Cocoa 的很大范围内的内存安全。

* * *

另外的是，Swift 不仅拥抱了 Cocoa 的接口，它还提高了 Cocoa 的接口。例如可敬的 `CGRect`，作为一个 C 结构体，它不能包含任何类方法，所以所有的[操作 `CGRect` 的方法](/cggeometry/)都存在在上层函数里。这些工具很强大，但是你需要确切知道他们的存在并去用他们。这里是将一个 `CGRect` 分成四份的四行代码，可能需要查三次文档：

````objective-c
CGRect nextRect;
CGRect remainingRect;
CGRectDivide(sourceRect, &nextRect, &remainingRect, 250, CGRectMinXEdge);
NSLog("Remaining rect: %@", NSStringFromCGRect(remainingRect));
````

但是在 Swift 里，结构体也欣然地有了实例方法和计算过的属性，所以 Core Graphics 拓展了 `CGRect ` 来让找到并且使用这些方法变得更加容易了。由于 `CGRect *` 的方法全都被放进了实力函数或者属性里，上面的代码可以简化成这样：

````swift
let (nextRect, remainingRect) = sourceRect.rectsByDividing(250, CGRectEdge.MinXEdge)
println("Remaining rect: \(remainingRect)")
````

### 一直都在变好

自然，同时使用 Cocoa 和 Swift 有时候是难堪的。 当难堪缺失发生的时候，一般是在用 Objective-C 的惯用模式的时候。代理、target-selector 和 `NSInvocation` 依旧有他们的位置，不过 Swift 有了更好用的闭包，有时候似乎为了完成一件简单的事情而增加一个或者多个函数，但是给 Cocoa 带来更多闭包或者 block 的函数能让现有的 Cocoa 类型轻松地越过障碍。

例如，`NSTimer` 有一个很好的接口，不管是通过 target-selector 还是 `NSInovation` 的模式，他需要一个 Objective-C 的方法来调用。当定义这个计时器的时候，我们很可能有了所有需要的东西，[有了这个使用自动桥接的 Core Foundation对应类 `CFTimer` 写的简单的`NSTimer`拓展](https://gist.github.com/natecook1000/b0285b518576b22c4dc8)，我们分分钟就开始进入业务逻辑：

````swift
let message = "Are we there yet?"
let alert = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
alert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))

NSTimer.scheduledTimerWithTimeInterval(10, repeats: true) { [weak self] timer in
    if self?.presentedViewController == nil {
        self?.presentViewController(alert, animated: true, completion: nil)
    }
}
// I swear I'll turn this car around.
````

* * *

其实这篇文章完全没有在反驳[Mattt的上一篇文章](/the-death-of-cocoa/)，越过无垠的时间轴，我们肯定有一天会在土卫六的表面用我们的 42 吋iPad来用 Cocoa 的继承者来编码，但是只要 Cocoa 存在一天，难道不是依旧*很棒*么？

