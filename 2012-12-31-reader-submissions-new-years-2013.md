---
layout: post
title: "Reader Submissions -<br/>New Year's 2013"
category: "Reader Submissions"
category: ""
description: "为了庆祝即将到来的 `year++`，我觉得编译一个你们最喜爱的tips和tricks的列表一定很好玩。读者可以提交他们最喜爱的和Objective-C之间的琐事、各种框架的奥秘、Xcode的隐藏功能之类的你认为很酷的东西。"
translator: "Croath Liu"
---

为了庆祝即将到来的 `year++`，我觉得编译一个_你们_最喜爱的tips和tricks的列表一定很好玩——给你们所有人一个机会展示你的NSHipster能力。

感谢[Cédric Luthi](https://github.com/0xced)、 [Jason Kozemczak](https://github.com/jaykz52)、[Jeff Kelley](https://github.com/SlaunchaMan)，[Joel Parsons](https://github.com/joelparsons)、[Maximilian Tagher](https://github.com/MaxGabriel)、[Rob Mayoff](https://github.com/mayoff)、[Vadim Shpakovski](https://github.com/shpakovski)，同时感谢[@alextud](https://github.com/alextud)对[answering the call](https://gist.github.com/4148342)的_完美_提交。


在Category中关联对象
--------------------------------

第一条tip简直太棒了，被你们提到了两次，分别是 [Jason Kozemczak](https://github.com/jaykz52)和[Jeff Kelley](https://github.com/SlaunchaMan)提名的。

Category是Objective-C非常著名的特性，通过它你可以给已存在的类添加新方法。但是鲜为人知的是，你可以通过一些`objc`运行时的hack给已存在类添加新_属性_，赞！

### NSObject+IndieBandName.h

~~~{objective-c}
@interface NSObject (IndieBandName)
@property (nonatomic, strong) NSString *indieBandName;
@end
~~~

### NSObject+IndieBandName.m

~~~{objective-c}
#import "NSObject+Extension.h"
#import <objc/runtime.h>

static const void *IndieBandNameKey = &IndieBandNameKey;

@implementation NSObject (IndieBandName)
@dynamic indieBandName;

- (NSString *)indieBandName {
    return objc_getAssociatedObject(self, IndieBandNameKey);
}

- (void)setIndieBandName:(NSString *)indieBandName {
    objc_setAssociatedObject(self, IndieBandNameKey, indieBandName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
~~~

通过这种方法，你所有的乐团对象都可以用他们乐队的名字来存储和访问。哦对了，表演在本周三晚上开始，一定要来哦。

这确实是一个很酷的trick，但只应该作为最后选择。当你想这么干的时候，问问你自己这个特别的属性是否能从已有的属性导出、是否能被其他的类管理。

对象关联的一个很好的例子就是[AFNetworking](https://github.com/AFNetworking/AFNetworking)在它的[`UIImageView` category](https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/UIImageView%2BAFNetworking.m#L39)中对一个图片请求的operation添加一个属性。

LLDB View Hierarchy Dump
------------------------

[Rob Mayoff](https://github.com/mayoff)用了一个非常隐晦而强大的咒语让debugging view变得如此方便。在你的home目录下建立一个 `.lldbinit`，如果它之前不存在的话，添加下面的命令：

### ~/.lldbinit

    command regex rd 's/^[[:space:]]*$/po [[[UIApplication sharedApplication] keyWindow] recursiveDescription]/' 's/^(.+)$/po [%1 recursiveDescription]/'

现在你可以用LLDB debugger获取你的应用中任何页面任何view的递归层次了。你可以自己试试，在一个view controller里面设一个断点，然后输入 `rd self.view`。你会被一些内建UI控制器面纱下面的秘密惊到哦！


用 LLDB 打印 `CGPathRef` 的内容
------------------------------------

当我们还在看关于LLDB的东西时，[Rob Mayoff](https://github.com/mayoff)发来了一个很有用的咒语，可以在调试器中打印出 `CGPathRef` 的内容：

    p (void)CGPathPrint(pathRef, 0)

如果你正在做一些复杂的 Core Graphics 绘制，请一定要牢记这个。

用 `+initialize`，不用 `+load`
------------------------------------

[Vadim Shpakovski](https://github.com/shpakovski)给了一些关于类加载和初始化的建议。Objective-C有两个神奇的方法：`+load` 和 `+initialize`，这两个方法在类被使用时会自动调用。但是两个方法的不同点会导致应用层面上性能的显著差异。

关于这一点[Mike Ash](http://www.mikeash.com/)有[一篇文章](http://www.mikeash.com/pyblog/friday-qa-2009-05-22-objective-c-class-loading-and-initialization.html)解释的非常好：

> 如果你实现了 `+load` 方法，那么当类被加载时它会自动被调用。这个调用非常早。如果你实现了一个应用或框架的 `+load`，并且你的应用链接到这个框架上了，那么 `＋load` 会在 `main()` 函数之前被调用。如果你在一个可加载的bundle中实现了 `+load`，那么它会在bundle加载的过程中被调用。

> `+initialize` 方法的调用看起来会更合理，通常在它里面写代码比在 `+load` 里写更好。`+initialize` 很有趣，因为它是懒调用的，也有可能完全不被调用。类第一次被加载时，`+initialize` 不会被调用。类接收消息时，运行时会先检查 `+initialize` 有没有被调用过。如果没有，会在消息被处理前调用。

**那篇文章太长了根本读不下去？那就直接记住，实现 `+initialize`，不要实现 `+load`，你更需要这种智能调用行为。**

Xcode Snippets
--------------

[Maximilian Tagher](https://github.com/MaxGabriel) 大声疾呼Xcode Snippets的好处。

优秀的开发者都以充分了解和最大利用开发工具为荣。无论[是好](https://twitter.com/javisoto/status/285531250373046272)或[是坏](http://www.textfromxcode.com)，这都说明了解Xcode就要像了解我们的手背那样熟悉。Objective-C冗长无比，但"少说多干"才是生产力的代表，[Xcode Snippets](http://developer.apple.com/library/mac/#recipes/xcode_help-source_editor/CreatingaCustomCodeSnippet/CreatingaCustomCodeSnippet.html#//apple_ref/doc/uid/TP40009975-CH14-SW1)是帮你走上这条路的最佳方法之一。

如果你不知道从哪开始，下载并且fork[这些Xcode Snippets](https://github.com/mattt/Xcode-Snippets)。

记录完成时间的宏定义
----------------------------------

这儿有一个很有用的宏定义，可以非常方便地记录某一块代码的运行时间。本段代码由[@alextud](https://github.com/alextud)提供：

~~~{objective-c}
NS_INLINE void MVComputeTimeWithNameAndBlock(const char *caller, void (^block)()) {
    CFTimeInterval startTimeInterval = CACurrentMediaTime();
    block();
    CFTimeInterval nowTimeInterval = CACurrentMediaTime();
    NSLog(@"%s - Time Running is: %f", caller, nowTimeInterval - startTimeInterval);
}

#define MVComputeTime(...) MVComputeTimeWithNameAndBlock(__PRETTY_FUNCTION__, (__VA_ARGS__))
~~~

用block写迭代方法
-------------------------

[Joel Parsons](https://github.com/joelparsons)提交了一个很有用的建议：用 `-enumerateObjectsWithOptions:usingBlock:` 方法对 `NSArray` 和其他集合类型进行迭代操作。传一个
`NSEnumerationConcurrent` 参数，你就可以享受带 `NSFastEnumeration` 协议的 `for..in` 那样高效率的并行block迭代了。

但是你要注意，不是所有的迭代都自动是并行执行的，所以千万不要把你所有的 `for...in` 都不分青红皂白地换成了这种方式，否则你的应用就该不知道在什么地方崩溃啦。

对 `NSString` 判断相等方法的逆向工程实现
----------------------------------------------------------------

[Cédric Luthi](https://github.com/0xced)通过[对 `NSString` 判断相等方法的逆向工程实现](https://gist.github.com/2275014)展示了他独有的智慧和对Cocoa内部机制的无比了解。很赞！

`NSLayoutConstraint.constant` 动画
-------------------------------------

所有[Cocoa Auto Layout](https://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/Introduction.html#//apple_ref/doc/uid/TP40010853)的粉丝都应该来看看这个，来自[Vadim Shpakovski](https://github.com/shpakovski)：

~~~{objective-c}
viewConstraint.constant = <#Constant Value From#>;
[view layoutIfNeeded];

viewConstraint.constant = <#Constant Value To#>;
[view setNeedsUpdateConstraints];

[UIView animateWithDuration:ConstantAnimationDuration animations:^{
     [view layoutIfNeeded];
}];
~~~

细心的读者可能已经做好本条的笔记了，顺便说一句，上面这些代码也可以写成一个优秀的Xcode Snippet哦。

打印 `NSCache` Usage
------------------------

看完了这么一堆小技巧，我们再次用[Cédric Luthi](https://github.com/0xced)提供的一个小窍门来结尾，这次我们发掘私有方法 `cache_print` 来窥探[`NSCache`](http://nshipster.cn/nscache/)的内部结构：

~~~{objective-c}
extern void cache_print(void *cache);

- (void) printCache:(NSCache *)cache {
    cache_print(*((void **)(__bridge void *)cache + 3));
}
~~~

这段代码样例只能用在iOS上，并且只能用作debug（提交到Apple Store之前要移除这些代码！）。

---

最后再次感谢这段时间提交建议的每个人。类似的活动肯定还会有的，所以请随时发给我你们最喜爱的和Objective-C之间的琐事、各种框架的奥秘、Xcode的隐藏功能之类的你认为对于一个[@NSHipster](https://twitter.com/nshipster)来说很酷的东西！

最后，感谢各位读者，因为有你们的支持NSHipster才能走过本年度如此完美的最后几个月。我们在2013年有很多特别赞的想法，并且非常想分享给你。
