---
layout: post
title: Associated Objects
category: Objective-C
tag: popular
excerpt: "对象关联是Objective-C 2.0在运行时的新特性，这个特性允许你将任何键值在运行时关联到对象上。对象关联是黑暗符咒一样，应该和其他来自objc/runtime.h的函数一样被小心谨慎地对待"
author: Mattt Thompson
translator: Croath Liu
---

~~~{objective-c}
#import <objc/runtime.h>
~~~

Objective-C开发者应该小心谨慎地遵循这个危险咒语的各种准则。一个很好的原因的就是：混乱的运行时代码会改变运行在其架构之上的所有代码。

从利的角度来讲， `<objc/runtime.h>` 中的函数具有其他方式做不到的、能为应用和框架提供强大功能的能力。而从弊的角度来讲，它可能会会毁掉代码的[sanity meter](http://en.wikipedia.org/wiki/Eternal_Darkness:_Sanity's_Requiem#Sanity_effects)，一切代码和逻辑都可能被异常糟糕的副作用影响([terrifying side-effects](http://www.youtube.com/watch?v=RSXcajQnasc#t=0m30s))。

因此，我们怀着巨大的恐惧来思考这个与“魔鬼的交易”([Faustian bargain](http://en.wikipedia.org/wiki/Deal_with_the_Devil))，一起来看看这个最多地被NSHipster读者们要求讲讲的主题之一：对象关联（associated objects）。

* * *

对象关联（或称为关联引用）本来是Objective-C 2.0运行时的一个特性，起始于OS X Snow Leopard和iOS 4。相关参考可以查看 `<objc/runtime.h>` 中定义的以下三个允许你将任何键值在运行时关联到对象上的函数：

- `objc_setAssociatedObject`
- `objc_getAssociatedObject`
- `objc_removeAssociatedObjects`

为什么我说这个很有用呢？因为这允许开发者**对已经存在的类在扩展中添加自定义的属性**，这几乎弥补了[Objective-C最大的缺点](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html)。

#### NSObject+AssociatedObject.h

~~~{objective-c}
@interface NSObject (AssociatedObject)
@property (nonatomic, strong) id associatedObject;
@end
~~~

#### NSObject+AssociatedObject.m

~~~{objective-c}
@implementation NSObject (AssociatedObject)
@dynamic associatedObject;

- (void)setAssociatedObject:(id)object {
     objc_setAssociatedObject(self, @selector(associatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, @selector(associatedObject));
}
~~~

通常推荐的做法是添加的属性最好是 `static char` 类型的，当然更推荐是指针型的。通常来说该属性应该是常量、唯一的、在适用范围内用getter和setter访问到：

~~~{objective-c}
static char kAssociatedObjectKey;

objc_getAssociatedObject(self, &kAssociatedObjectKey);
~~~

然而可以用更简单的方式实现：用selector。

<blockquote class="twitter-tweet" lang="en"><p>Since <tt>SEL</tt>s are guaranteed to be unique and constant, you can use <tt>_cmd</tt> as the key for <tt>objc_setAssociatedObject()</tt>. <a href="https://twitter.com/search?q=%23objective&amp;src=hash">#objective</a>-c <a href="https://twitter.com/search?q=%23snowleopard&amp;src=hash">#snowleopard</a></p>&mdash; Bill Bumgarner (@bbum) <a href="https://twitter.com/bbum/statuses/3609098005">August 28, 2009</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## 关联对象的行为

属性可以根据定义在枚举类型 `objc_AssociationPolicy` 上的行为被关联在对象上：

<table>
    <thead>
        <tr>
            <th>Behavior</th>
            <th><tt>@property</tt> Equivalent</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_ASSIGN</tt>
            </td>
            <td>
                <tt>@property (assign)</tt> 或 <tt>@property (unsafe_unretained)</tt>
            </td>
            <td>
                指定一个关联对象的弱引用。
            </td>
        </tr>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_RETAIN_NONATOMIC</tt>
            </td>
            <td>
                <tt>@property (nonatomic, strong)</tt>
            </td>
            <td>
                指定一个关联对象的强引用，不能被原子化使用。
            </td>
        </tr>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_COPY_NONATOMIC</tt>
            </td>
            <td>
                <tt>@property (nonatomic, copy)</tt>
            </td>
            <td>
                指定一个关联对象的copy引用，不能被原子化使用。
            </td>
        </tr>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_RETAIN</tt>
            </td>
            <td>
                <tt>@property (atomic, strong)</tt>
            </td>
            <td>
                指定一个关联对象的强引用，能被原子化使用。
            </td>
        </tr>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_COPY</tt>
            </td>
            <td>
                <tt>@property (atomic, copy)</tt>
            </td>
            <td>
                指定一个关联对象的copy引用，能被原子化使用。
            </td>
        </tr>
    </tbody>
</table>

以 `OBJC_ASSOCIATION_ASSIGN` 类型关联在对象上的弱引用不代表0 retian的 `weak` 弱引用，行为上更像 `unsafe_unretained` 属性，所以当在你的视线中调用weak的关联对象时要相当小心。

> 根据[WWDC 2011, Session 322](https://developer.apple.com/videos/wwdc/2011/#322-video) (第36分钟左右)发布的内存销毁时间表，被关联的对象在生命周期内要比对象本身释放的晚很多。它们会在被 `NSObject -dealloc` 调用的 `object_dispose()` 方法中释放。

## 删除属性

你可以会在刚开始接触对象关联时想要尝试去调用 `objc_removeAssociatedObjects()` 来进行删除操作，但[如文档中所述](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/Reference/reference.html#//apple_ref/c/func/objc_removeAssociatedObjects)，你不应该自己手动调用这个函数：

> 此函数的主要目的是在“初试状态”时方便地返回一个对象。你不应该用这个函数来删除对象的属性，因为可能会导致其他客户对其添加的属性也被移除了。规范的方法是：调用 `objc_setAssociatedObject` 方法并传入一个 `nil` 值来清除一个关联。

## 优秀样例

- **添加私有属性用于更好地去实现细节。**当扩展一个内建类的行为时，保持附加属性的状态可能非常必要。注意以下说的是一种非常_教科书式_的关联对象的用例：AFNetworking在 `UIImageView` 的category上用了关联对象来[保持一个operation对象](https://github.com/AFNetworking/AFNetworking/blob/2.1.0/UIKit%2BAFNetworking/UIImageView%2BAFNetworking.m#L57-L63)，用于从网络上某URL异步地获取一张图片。
- **添加public属性来增强category的功能。**有些情况下这种(通过关联对象)让category行为更灵活的做法比在用一个带变量的方法来实现更有意义。在这些情况下，可以用关联对象实现一个一个对外开放的属性。回到上个AFNetworking的例子中的 `UIImageView` category，[它的 `imageResponseSerializer`](https://github.com/AFNetworking/AFNetworking/blob/2.1.0/UIKit%2BAFNetworking/UIImageView%2BAFNetworking.h#L60-L65)方法允许图片通过一个滤镜来显示、或在缓存到硬盘之前改变图片的内容。
- **创建一个用于KVO的关联观察者。**当在一个category的实现中使用[KVO](http://nshipster.com/key-value-observing/)时，建议用一个自定义的关联对象而不是该对象本身作观察者。ng an associated observer for KVO**. When using [KVO](http://nshipster.com/key-value-observing/) in a category implementation, it is recommended that a custom associated-object be used as an observer, rather than the object observing itself.

## 反例

- **当值不需要的时候建立一个关联对象。**一个常见的例子就是在view上创建一个方便的方法去保存来自model的属性、值或者其他混合的数据。如果那个数据在之后根本用不到，那么这种方法虽然是没什么问题的，但用关联到对象的做法并不可取。
- **当一个值可以被其他值推算出时建立一个关联对象。**例如：在调用 `cellForRowAtIndexPath:` 时存储一个指向view的 `UITableViewCell` 中accessory view的引用，用于在 `tableView:accessoryButtonTappedForRowWithIndexPath:` 中使用。
- **用关联对象替代X**，这里的X可以代表下列含义：
    - 当继承比扩展原有的类更方便时用[子类化](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html)。
    - 为事件的响应者添加[响应动作](https://developer.apple.com/library/ios/documentation/general/conceptual/Devpedia-CocoaApp/TargetAction.html)。
    - 当响应动作不方便使用时使用的[手势动作捕捉](https://developer.apple.com/library/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/GestureRecognizer_basics/GestureRecognizer_basics.html)。
    - 行为可以在其他对象中被代理实现时要用[代理(delegate)](https://developer.apple.com/library/ios/documentation/general/conceptual/DevPedia-CocoaCore/Delegation.html)。
    - 用[NSNotification 和 NSNotificationCenter](http://nshipster.com/nsnotification-and-nsnotificationcenter/)进行松耦合化的跨系统的事件通知。
* * *

比起其他解决问题的方法，关联对象应该被视为最后的选择（事实上category也不应该作为首选方法）。

和其他精巧的trick、hack、workaround一样，一般人都会在刚学习完之后乐于寻找场景去使用一下。尽你所能去理解和欣赏它在正确使用时它所发挥的作用，同时当你选择_这个_解决办法时，也要避免当被轻蔑地问起“这是个什么玩意？”时的尴尬。
