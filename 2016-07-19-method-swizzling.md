#Method Swizzling翻译
> 如果轻轻一按就能摧毁整个世界的话
> 你会怎么做？
> 如果所有人都变得贫穷能让你变得富有的话
> 你会怎么做？
> 如果你能不用工作，只需要监视别人工作的话
> 你会怎么做？
> 如果你不予回报就能拥有所有的爱
> 你会怎么做？
> 在这样的权利下我们迷失了自己并对自己的行为全然不知
> 这时你会怎么做？
> -- The Flaming Lips, "The Yeah Yeah Yeah Song(With All Your Power)"

在上周的[associated objects](http://nshipster.com/associated-objects/)文章中，我们开始探索了Objective-C的运行时黑魔法。这周我们将会继续深入讨论Objective-C的运行时中最具争议的黑魔法：method swizzling。
Method swizzling用于改变一个已经存在的selector的实现。这项技术使得在运行时通过改变selector在类的消息分发列表中的映射从而改变方法的掉用成为可能。例如：我们想要在一款iOS app中追踪每一个视图控制器被用户呈现了几次：
这可以通过在每个视图控制器的viewDidAppear:方法中添加追踪代码来实现，但这样会大量重复的样板代码。继承是另一种可行的方式，但是这要求所有被继承的视图控制器如UIViewController, UITableViewController, UINavigationController都在viewDidAppear：实现追踪代码，这同样会造成很多重复代码。
幸运的是，这里有另外一种可行的方式：从category实现method swizzling。下面是实现方式：
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
现在，UIViewController或其子类的实例对象在调用viewWillAppear:的时候会有log的输出。
在视图控制器的生命周期，响应事件，绘制视图或者Foundation框架的网络栈等方法中插入代码都是method swizzling能够为开发带来很好作用的例子。有很多的场景选择method swizzling会是很合适的解决方式，这显然也会让Objective-C开发者的技术变得越来越成熟。
到此我们已经知道为什么，应该在哪些地方使用method swizzling，下面是如何使用method swizzling：
##+load vs +initialize
swizzling应该只在+load中完成。
在Objective-C的运行时中，每个类有两个方法都会自动调用。+load是在一个类被初始装载时调用，+initialize是在应用第一次调用该类的类方法或实例方法前调用的。两个方法都是可选的，并且只有在方法被实现的情况下才会被调用。
##dispatch_once
swizzling应该只在dispatch_once中完成
由于swizzling改变了全局的状态，所以我们需要确保每个预防措施在运行时都是可用的。原子操作就是这样一个用于确保代码只会被执行一次的预防措施，就算是在不同的线程中也能确保代码只执行一次。Grand Central Dispatch的dispatch_once满足了所需要的需求，并且应该被当做使用swizzling的初始化单例方法的标准。
##Selectors, Methods, & Implementations
在Objective-C的运行时中，selectors, methods, implementations指代了不同概念，然而我们通常会说在消息发送过程中，这三个概念是可以相互转换的。
下面是苹果[Objective-C Runtime Reference](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/Reference/reference.html#//apple_ref/c/func/method_getImplementation)中的描述：
> - Selector（typedef struct objc_selector *SEL）:在运行时Selectors用来代表一个方法的名字。Selector是一个在运行时被注册（或映射）的C类型字符串。Selector由编译器产生并且在当类被加载进内存时由运行时自动进行名字和实现的映射。
> 
- Method（typedef struct objc_method *Method）:方法是一个不透明的用来代表一个方法的定义的类型。
- Implementation（typedef id (*IMP)(id, SEL,...)）:这个数据类型指向一个方法的实现的最开始的地方。该方法为当前CPU架构使用标准的C方法调用来实现。该方法的第一个参数指向调用方法的自身（即内存中类的实例对象，若是调用类方法，该指针则是指向元类对象metaclass）。第二个参数是这个方法的名字selector，该方法的真正参数紧随其后。

理解selector, method, implementation这三个概念之间关系的最好方式是：在运行时，类（Class）维护了一个消息分发列表来解决消息的正确发送。每一个消息列表的入口是一个方法（Method），这个方法映射了一对键值对，其中键值是这个方法的名字selector（SEL），值是指向这个方法实现的函数指针implementation（IMP）。
Method swizzling修改了类的消息分发列表使得已经存在的selector映射了另一个实现implementation，同时重命名了原生方法的实现为一个新的selector。
##调用 _cmd
下面的代码似乎会出现循环：
~~~{objective-c}
(void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", NSStringFromClass([self class]));
}
~~~
然而，这并不会。在交换方法的实现过程中，xxx_viewWillAppear:已经被赋予了UIViewController -viewWillAppear：的原生实现。在一个方法的实现中又调用了该方法会出现错误，这是一个好程序员应有的直觉，但这里我们应该理清到底发生了什么。然而，当我们在这个方法中调用viewWillAppear:时是会造成无限循环的，因为这个方法的实现已经在运行时被交换为了viewWillAppear：的实现。
> 记住给你需要转换的所有方法加个前缀。

##思考
交换方法实现被很多人认为是一个不好的黑魔法，会带来不可预测的行为，无法预料的结果。然而当采取了以下预防措施后,method swizzling会变得相当可靠：
- 永远记得调用原生方法的实现（除非你有非常确定的理由不需要调用）：APIs提供了输入输出的规则，而在输入输出中间的方法实现就是一个看不见的黑盒（因为看不到源码）。交换了方法实现并且一些回调方法不会调用原生方法的实现O这可能会造成底层实现的崩溃。
- 避免冲突：为分类的方法加前缀，一定要确保代码的其他地方不会因为你交换了方法的实现而造成了意想不到的结果。
- 理解实现原理：只是简单的拷贝粘贴交换方法实现的代码而不去理解实现原理不仅会让App很脆弱，并且浪费了学习Objective-C的运行时的机会。阅读Objective-C Runtime Reference并且浏览<obje/runtime.h>来充分理解一下这里发生了什么。
- 持续的预防：不管你对你理解swlzzling框架，UIKit或者其他内嵌框架有多自信，一定要记住所有东西在下一个发行版本都可能变得不再好使。做好准备，在使用这个黑魔法中走得更远，不要让程序反而出现不可思议的行为。
