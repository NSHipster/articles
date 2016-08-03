---
title: NSCalendarUnitYear
author: Mattt Thompson
translator: Chester Liu
category: Swift
excerpt: "NSHipster.com 已经走过了两个年头。每周我们都会发表一篇新文章，探讨 Objective-C 或者 Cocoa 当中一些不为人知的话题（除了几周例外）。我们用蛋糕来庆祝一下。"
status:
    swift: 2.0
    reviewed: September 9, 2015
---

从两年前 [一篇关于 NSIndexSet 的小文章](http://nshipster.cn/nsindexset/) 发布到现在，NSHipster.com 已经走过了两个年头。每周我们都会发表一篇新文章，探讨 Objective-C 或者 Cocoa 当中一些不为人知的话题（除了几周例外），这些文章的读者覆盖超过 180 个国家，人数高达数百万。

> 这篇文章实际上是我们的第 101 篇文章，意味着 [按照电视工业的标准](http://en.wikipedia.org/wiki/100_episodes)，这个站点已经可以在电视上广播了。（湖南卫视我们来了！）

我们用蛋糕来庆祝一下：

<svg version="1.1" id="birthday-cake" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
     viewBox="0 0 100 100" enable-background="new 0 0 100 100" xml:space="preserve" style="width:300px; height: 300px; margin: 1em auto;">
    <path d="M27.5,32.5c0,0-24.6,13.8-25,33.6c0,0.1,0,0.2,0,0.4V95c0,1.1,0.9,2,2,1.9L88,93.1c1.1-0.1,2.1-0.1,2.2-0.1
        c0.1,0,0.2-0.9,0.2-2c0,0,0-25.5,0-26.5c0-2-2-3-2-3 M88.5,89.4c0,1-0.9,1.9-2,2L6.5,94.9c-1.1,0-2-0.8-2-1.8c0,0,0-4.7,0-10.1
        l84-3.9C88.5,84.5,88.5,89.4,88.5,89.4z M88.5,76L4.5,80c0-5.8,0-11.3,0-11.8c0-0.9,1-1.1,1-1.1l82-3.6c0,0,1,0,1,0.9
        C88.5,64.9,88.5,70.3,88.5,76z"/>
    <path d="M41.8,8.4c0,4.1-1.8,5.6-4.1,5.6c-2.3,0-4.1-1.5-4.1-5.6S37.8,1,37.8,1S41.8,4.3,41.8,8.4z"/>
    <path fill="#FFFFFF" stroke="#000000" stroke-miterlimit="10" d="M42,47.5c0,2.5-2,4.5-4.5,4.5l0,0c-2.5,0-4.5-2-4.5-4.5V19.8
        c0-2.5,2-4.5,4.5-4.5l0,0c2.5,0,4.5,2,4.5,4.5V47.5z"/>
</svg>

很可爱吧？让我们看看它在代码里面是什么样子：

~~~{swift}
var cakePath = UIBezierPath()
cakePath.moveToPoint(CGPointMake(31.5, 32.5))
cakePath.addCurveToPoint(CGPointMake(6.5, 66.1), controlPoint1: CGPointMake(31.5, 32.5), controlPoint2: CGPointMake(6.9, 46.3))
cakePath.addCurveToPoint(CGPointMake(6.5, 66.5), controlPoint1: CGPointMake(6.5, 66.2), controlPoint2: CGPointMake(6.5, 66.3))
cakePath.addLineToPoint(CGPointMake(6.5, 95))

...
~~~

等等，这是什么，Objective-C？操作 `UIBezierPath`，不是什么突破性质的黑科技，不过通过一些代码，我们可以让这件事变得简单一些。

通过 [自定义操作符](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/AdvancedOperators.html#//apple_ref/doc/uid/TP40014097-CH27-XID_28)，我们来在这个蛋糕上加入一些语法“糖”，怎么样？

~~~{swift}
infix operator ---> { associativity left }
func ---> (left: UIBezierPath, right: (CGFloat, CGFloat)) -> UIBezierPath {
    let (x, y) = right
    left.moveToPoint(CGPointMake(x, y))

    return left
}

infix operator +- { associativity left }
func +- (left: UIBezierPath, right: (CGFloat, CGFloat)) -> UIBezierPath {
    let (x, y) = right
    left.addLineToPoint(CGPointMake(x, y))

    return left
}

infix operator +~ { associativity left }
func +~ (left: UIBezierPath, right: ((CGFloat, CGFloat), (CGFloat, CGFloat), (CGFloat, CGFloat))) -> UIBezierPath {
    let ((x1, y1), (x2, y2), (x3, y3)) = right
    left.addCurveToPoint(CGPointMake(x1, y1), controlPoint1: CGPointMake(x2, y2), controlPoint2: CGPointMake(x3, y3))

    return left
}
~~~

> 看到了吗？ `--->` 替代了 `moveToPoint`，`+-` 替代了 `addLineToPoint`，`+~` 替代了 `addCurveToPoint`。这个声明同时还去掉了对于 `CGPointMake` 的冗余调用，转而使用简单的坐标元组。

Swift 对于开发者组织代码这个方面，提供了非常大的灵活性。这种“最小约束”思想的代表特性之一，就是可以添加自定义的前缀，中缀和后缀操作符。 Swift 语法约束自定义操作符由下面这些字符当中的一个或者多个组成（在操作符不和保留字符冲突的情况下，例如用于 optional 值的 `?` 和 `!`）

`/ = - + * % < > ! & | ^ . ~.`

自定义操作符是一个强大的工具，可以用来精简逻辑，减少冗余和不必要的重复，等等等等。和诸如模式匹配和链式语法这些语言特性结合起来，可以用于创建完美适用于当前问题的 DSL。

只是...你懂得，不要让这种力量冲昏头脑。

在加入完整的 Emoji 支持之后（`let 🐶🐮`），对于从 Objective-C 转过来的开发者来说，自定义操作符差不多是最闪亮的新特性了。和其他的闪亮新特性一样，它注定要毁掉一些人的三观。

### Swift 崭新特性的危害——戏剧化展示

> `场景：旧金山，2017年`
> 
> `灰胡子`：今天我接手了一些旧的 Swift 代码，我发现了这行代码——我对`$灯`发誓——它长这样 `😾 |--~~> 💩`。
> 
> `语法哥`： _摇了摇头_
> 
> `灰胡子`：这货到底是什么意思？这是一坨翔在<abbr title="↓↘︎→P">放大招</abbr>，还是要被开瓶器教做人 ？
> 
> `语法哥`：的确，如果这不算是哲学难题，我不知道还有什么是了。
> 
> `灰胡子`：不管它了，这个语句实际上是重新载入了附近的餐馆。
> 
> `语法哥`：哥们儿，AFNetworking 的 4.0 版本真的变得诡异了。
> 
> `灰胡子`：是啊。

这个寓言告诉我们一个道理：**有节制地使用自定义操作符和 emoji**。

（或者管他呢，下面的示例代码完全忽略了这个建议）

~~~{swift}
// Happy 2nd Birthday, NSHipster
// 😗💨🎂✨2️⃣

var 🍰 = UIBezierPath()
🍰 ---> ((31.5, 32.5))
     +~ ((6.5, 66.1), (31.5, 32.5), (6.9, 46.3))
     +~ ((6.5, 66.5), (6.5, 66.2), (6.5, 66.3))
     +- ((6.5, 95))
     +~ ((8.5, 96.9), (6.5, 96.1), (7.4, 97))
     +- ((92, 93.1))
     +~ ((94.2, 93), (93.1, 93), (94.1, 93))
     +~ ((94.4, 91), (94.3, 93), (94.4, 92.1))
     +~ ((94.4, 64.5), (94.4, 91), (94.4, 65.5))
     +~ ((92.4, 61.5), (94.4, 62.5), (92.4, 61.5))
   ---> ((92.5, 89.4))
     +~ ((90.5, 91.4), (92.5, 90.4), (91.6, 91.3))
     +- ((10.5, 94.9))
     +~ ((8.5, 93.1), (9.4, 94.9), (8.5, 94.1))
     +~ ((8.5, 83), (8.5, 93.1), (8.5, 88.4))
     +- ((92.5, 79.1))
     +~ ((92.5, 89.4), (92.5, 84.5), (92.5, 89.4))
🍰.closePath()

🍰 ---> ((92.5, 76))
     +- ((8.5, 80))
     +~ ((8.5, 68.2), (8.5, 74.2), (8.5, 68.7))
     +~ ((9.5, 67.1), (8.5, 67.3), (9.5, 67.1))
     +- ((91.5, 63.5))
     +~ ((92.5, 64.4), (91.5, 63.5), (92.5, 63.5))
     +~ ((92.5, 76), (92.5, 64.9), (92.5, 70.3))
🍰.closePath()


var 📍 = UIBezierPath()
📍 ---> ((46, 47.5))
     +~ ((41.5, 52), (46, 50), (44, 52))
     +- ((41.5, 52))
     +~ ((37, 47.5), (39, 52), (37, 50))
     +- ((37, 19.8))
     +~ ((41.5, 15.3), (37, 17.3), (39, 15.3))
     +- ((41.5, 15.3))
     +~ ((46, 19.8), (44, 15.3), (46, 17.3))
     +- ((46, 47.5))
📍.closePath()


var 🔥 = UIBezierPath()
🔥.miterLimit = 4

🔥 ---> ((45.8, 8.4))
     +~ ((41.7, 14), (45.8, 12.5), (44, 14))
     +~ ((37.6, 8.4), (39.4, 14), (37.6, 12.5))
     +~ ((41.8, 1), (37.6, 4.3), (41.8, 1))
     +~ ((45.8, 8.4), (41.8, 1), (45.8, 4.3))
🔥.closePath()


UIColor.blackColor().setFill()
🍰.fill()
🔥.fill()

UIColor.whiteColor().setFill()
UIColor.blackColor().setStroke()
📍.fill()
📍.stroke()
~~~

我和你一样感到惊讶，这东西居然能过编译。

太差劲了。

* * *

无论如何，NSHipster，两周年快乐！

谢谢你们，在你们的帮助下，过去这几年的经历对我来说简直美好的难以置信。接下来的日子，我会做好本职工作，继续我们的航程。
