---
layout: post
title: instancetype
category: Cocoa
excerpt: "Objective-C 是一门正迅速发展的语言，这种发展速度在别的现有语言中是不曾有过的。从普通到范例转变的发展，真要说清它们之间的差异还得慢慢来。因为我们正在讨论的是底层语言的特性，对于API设计的更深层含义还比较难理解。"
author: Mattt Thompson
translator: JJ Mao
---

想知道Objective-C接下去会发生什么吗？[请多关注Objective-C最新动向](http://clang.llvm.org/docs/LanguageExtensions.html)。

Objective-C 是一门正迅速发展的语言，这种发展速度在别的现有语言中是不曾有过的。ARC，object literals，subscripting，blocks：在短短的三年时间里，Objective-C编程的许多方式发生了改变（变得更好）。

这一切的创新都是Apple垂直整合的成果。正如Apple在设计[自主研发芯片](http://en.wikipedia.org/wiki/Apple_A4)中的投资一样，利用杠杠作用与手机硬件展开激烈的竞争。在[LLVM](http://llvm.org) 上的投资也是一样，使软件跟上业界最新步伐。

Clang从普通到范例转变的发展，真要说清它们之间的差异还得慢慢来。因为我们正在讨论的是底层语言的特性，对于API设计的更深层含义还比较难理解。

其中一个例子就是 `instancetype` ，这也是本周文章的主题。

---

Objective-C的一些使用惯例不仅仅是好的编程习惯，更是给编译器的隐藏指令。

例如， `alloc` 和 `init` 的返回类型都是 `id` ，然而在Xcode中，编译器会检查所有正确类型。它是怎么做到的呢？

在Cocoa中，约定 `alloc` 或 `init` 的方法总是返回接收器类实例的对象。据说这些方法有一个**相关返回类型**。

虽然类构造方法也是返回 `id` ，但是类构造方法并没有做同样的类型检查，因为它们不遵循命名规范。

你可以自己试着这样：

~~~{objective-c}
[[[NSArray alloc] init] mediaPlaybackAllowsAirPlay]; // ❗ "No visible @interface for `NSArray` declares the selector `mediaPlaybackAllowsAirPlay`"

[[NSArray array] mediaPlaybackAllowsAirPlay]; // (No error)
~~~

由于 `alloc` 和 `init` 作为相关返回类型遵循命名规范，执行对 `NSArray` 的正确类型检查。然而，等价类构造函数 `array` 不遵循命名规范，它被认为是 `id` 类型。

`id` 类型对于禁用类型安全性检查非常有用，但当你 _确实_ 需要它的时候却没有时，情况会变得非常糟糕。

另一种显示声明返回类型（在之前例子中的 `(NSArray *)`）的方式有了稍微的改进，但是它不利于子类的发挥。

所以编译器从这里介入以解决Objective-C类型系统的这个永恒边界情况：

`instancetype` 关键字，它可以表示一个方法的相关返回类型。例如：

~~~{objective-c}
@interface Person
+ (instancetype)personWithName:(NSString *)name;
@end
~~~

> `instancetype` 与 `id` 不一样, `instancetype` 只能在方法声明中作为返回类型使用。

使用 `instancetype` ，编译器将正确的推断出 `+personWithName:` 是 `Person` 的一个实例。

为了在不久的将来使用 `instancetype` ，你可以在Foundation中查找类构造函数。例如[UICollectionViewLayoutAttributes](http://developer.apple.com/library/ios/#documentation/uikit/reference/UICollectionViewLayoutAttributes_class/Reference/Reference.html) 就已经正在使用 `instancetype` 了。

## 深层含义

语言特性十分有趣，因为它在高级软件设计方面的的影响往往是模糊的。

然而 `instancetype` 看似普通，尽管它能为编译器锦上添花，但它可用于更棒的结果。

[Jonathan Sterling](https://twitter.com/jonsterling) 写了[这篇十分有趣的文章](http://www.jonmsterling.com/posts/2012-02-05-typed-collections-with-self-types-in-objective-c.html), 文章中详细描述了 `instancetype` 在没有[泛型](http://en.wikipedia.org/wiki/Generic_programming)的情况下是如何用于静态类型collections编码的:

~~~{objective-c}
NSURL <MapCollection> *sites = (id)[NSURL mapCollection];
[sites put:[NSURL URLWithString:@"http://www.jonmsterling.com/"]
        at:@"jon"];
[sites put:[NSURL URLWithString:@"http://www.nshipster.com/"]
        at:@"nshipster"];

NSURL *jonsSite = [sites at:@"jon"]; // => http://www.jonmsterling.com/
~~~

静态类型collections会使APIs更富有表现力--开发者可以确定一个collection参数中允许使用的对象类型。

不论这是否能在Objective-C中成为公认的规范，更令人着迷的是像 `instancetype` 这样的底层特性是如何用于改变语言轮廓的(在这种情况下，使其看似更像[C#][1]）。

---

`instancetype` 只是众多语言之中的一种对Objective-C的扩展，使它更多的被添加到每个新版本中。

认识它并爱上它。

以此作为如何关注底层细节的例子，将给你带来全新的视角以强有力的方式去改变Objective-C。

[1]: http://en.wikipedia.org/wiki/C_Sharp_(programming_language)
