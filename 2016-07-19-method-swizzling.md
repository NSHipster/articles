---
title: Method Swizzling
author: Mattt Thompson
category: Objective-C
translator: Daniel Hu
excerpt: "Method swizzling 用来改变已存在的 selector 映射的方法实现。Method swizzling 通过在运行时修改类的消息分发列表中 selector 与实现的映射使得在运行时修改方法的调用成为可能。"
status:
    swift: n/a
    reviewed: January 28, 2015
---

> 如果轻轻一按就能摧毁整个世界的话<br/>
> 你会怎么做<br/>
> 如果所有人都变贫穷能让你变得富有的话<br/>
> 你会怎么做？<br/>
> 如果你能不用工作，只需要监视别人工作的话<br/>
> 你会怎么做？<br/>
> 如果你不予回报就能拥有所有的爱<br/>
> 你会怎么做？<br/>
> 在这样的权利下我们迷失了自己并对自己的行为全然不知<br/>
> 这时你会怎么做？<br/>
> <cite><strong>The Flaming Lips</strong>, <em><a href="http://en.wikipedia.org/wiki/The_Yeah_Yeah_Yeah_Song_(With_All_Your_Power)">"The Yeah Yeah Yeah Song (With All Your Power)"</a></em></cite>

在上周的 [associated objects](http://nshipster.com/associated-objects/) 文章中，我们开始探索了 Objective-C 的运行时黑魔法。这周我们将会继续深入讨论 Objective-C 的运行时中最具争议的黑魔法：method swizzling。

* * *

Method swizzling 用于改变一个已经存在的 selector 的实现。这项技术使得在运行时通过改变 selector 在类的消息分发列表中的映射从而改变方法的掉用成为可能。例如：我们想要在一款 iOS app 中追踪每一个视图控制器被用户呈现了几次：
这可以通过在每个视图控制器的 viewDidAppear: 方法中添加追踪代码来实现，但这样会大量重复的样板代码。继承是另一种可行的方式，但是这要求所有被继承的视图控制器如 UIViewController, UITableViewController, UINavigationController 都在 viewDidAppear：实现追踪代码，这同样会造成很多重复代码。
幸运的是，这里有另外一种可行的方式：从 category 实现 **method swizzling** 。下面是实现方式：

~~~ {objective-c}
#import <objc/runtime.h>

@implementation UIViewController (Tracking)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        BOOL didAddMethod =
            class_addMethod(class,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", self);
}

@end
~~~

> 计算机科学里，[交换指针指向](http://en.wikipedia.org/wiki/Pointer_swizzling)用来交换基于名字或者位置的指针引用。如果你对 Objective-C 这方面的特性不是很了解的话，这是很值得推荐使用的一个特性，因为 method swizzling 可以通过交换 selector 来改变函数指针的引用。

现在，UIViewController 或其子类的实例对象在调用 viewWillAppear: 的时候会有 log 的输出。

在视图控制器的生命周期，响应事件，绘制视图或者 Foundation 框架的网络栈等方法中插入代码都是 method swizzling 能够为开发带来很好作用的例子。有很多的场景选择method swizzling 会是很合适的解决方式，这显然也会让 Objective-C 开发者的技术变得越来越成熟。

到此我们已经知道为什么，应该在哪些地方使用 method swizzling，下面介绍如何使用 method swizzling：

##+load vs +initialize

**swizzling应该只在+load中完成**
在 Objective-C 的运行时中，每个类有两个方法都会自动调用。+load 是在一个类被初始装载时调用，+initialize 是在应用第一次调用该类的类方法或实例方法前调用的。两个方法都是可选的，并且只有在方法被实现的情况下才会被调用。

##dispatch_once

**swizzling 应该只在 dispatch_once 中完成。**

由于 swizzling 改变了全局的状态，所以我们需要确保每个预防措施在运行时都是可用的。原子操作就是这样一个用于确保代码只会被执行一次的预防措施，就算是在不同的线程中也能确保代码只执行一次。Grand Central Dispatch 的 dispatch_once 满足了所需要的需求，并且应该被当做使用 swizzling 的初始化单例方法的标准。

## Selectors, Methods, & Implementations

在 Objective-C 的运行时中，selectors, methods, implementations 指代了不同概念，然而我们通常会说在消息发送过程中，这三个概念是可以相互转换的。
下面是苹果 [Objective-C Runtime Reference](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/Reference/reference.html#//apple_ref/c/func/method_getImplementation)中的描述：
> - Selector（`typedef struct objc_selector *SEL`）:在运行时 Selectors 用来代表一个方法的名字。Selector 是一个在运行时被注册（或映射）的C类型字符串。Selector由编译器产生并且在当类被加载进内存时由运行时自动进行名字和实现的映射。
> - Method（`typedef struct objc_method *Method`）:方法是一个不透明的用来代表一个方法的定义的类型。
> - Implementation（`typedef id (*IMP)(id, SEL,...)`）:这个数据类型指向一个方法的实现的最开始的地方。该方法为当前CPU架构使用标准的C方法调用来实现。该方法的第一个参数指向调用方法的自身（即内存中类的实例对象，若是调用类方法，该指针则是指向元类对象metaclass）。第二个参数是这个方法的名字selector，该方法的真正参数紧随其后。

理解 selector, method, implementation 这三个概念之间关系的最好方式是：在运行时，类（Class）维护了一个消息分发列表来解决消息的正确发送。每一个消息列表的入口是一个方法（Method），这个方法映射了一对键值对，其中键值是这个方法的名字 selector（SEL），值是指向这个方法实现的函数指针 implementation（IMP）。
Method swizzling 修改了类的消息分发列表使得已经存在的 selector 映射了另一个实现 implementation，同时重命名了原生方法的实现为一个新的 selector。

## 调用 _cmd

下面代码在正常情况下会出现循环：

~~~ {objective-c}
- (void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", NSStringFromClass([self class]));
}
~~~

然而在交换了方法实现后就不会出现循环了。好的程序员应该对这里出现的方法的递归调用有所警觉，这里我们应该理清在 method swizzling 后方法的实现究竟变成了什么。在交换了方法的实现后，xxx_viewWillAppear:方法的实现已经被替换为了 UIViewController -viewWillAppear：的原生实现，所以这里并不是在递归调用。由于 xxx_viewWillAppear: 这个方法的实现已经被替换为了 viewWillAppear: 的实现，所以，当我们在这个方法中再调用 viewWillAppear: 时便会造成递归循环。

> 记住给需要转换的所有方法加个前缀以区别原生方法。

## 思考

很多人认为交换方法实现会带来无法预料的结果。然而采取了以下预防措施后, method swizzling 会变得很可靠：

- **在交换方法实现后记得要调用原生方法的实现（除非你非常确定可以不用调用原生方法的实现）**：APIs 提供了输入输出的规则，而在输入输出中间的方法实现就是一个看不见的黑盒。交换了方法实现并且一些回调方法不会调用原生方法的实现这可能会造成底层实现的崩溃。
- **避免冲突**：为分类的方法加前缀，一定要确保调用了原生方法的所有地方不会因为你交换了方法的实现而出现意想不到的结果。
- **理解实现原理**：只是简单的拷贝粘贴交换方法实现的代码而不去理解实现原理不仅会让 App 很脆弱，并且浪费了学习 Objective-C 运行时的机会。阅读 Objective-C Runtime Reference 并且浏览 <obje/runtime.h> 能够让你更好理解实现原理。
- **持续的预防**：不管你对你理解 swlzzling 框架，UIKit 或者其他内嵌框架有多自信，一定要记住所有东西在下一个发行版本都可能变得不再好使。做好准备，在使用这个黑魔法中走得更远，不要让程序反而出现不可思议的行为。

* * * 

[associated objects](http://nshipster.cn/associated-objects/) 的链接， method swizzling 是 Objective-C 拥有的强大特性，但请谨慎使用。


