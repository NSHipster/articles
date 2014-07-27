---
layout: post
title: "NSOrderedSet"
category: Cocoa
excerpt: "为什吗`NSOrderedSet`不是继承自`NSSet`的捏？答案可能会让你大吃一惊。"
author: Mattt Thompson
translator: Candyan
---

有个问题：为什吗`NSOrderedSet`不是继承自`NSSet`的捏？

毕竟 `NSOrderedSet`是一个 `NSSet` 的_子类_这个逻辑看起来是很完美的。它跟 `NSSet` 具有相同的方法，还添加了一些 `NSArray`风格的方法，像 `objectAtIndex:`。据大家所说，它似乎完全满足了[里氏替换原则](http://zh.wikipedia.org/zh-cn/%E9%87%8C%E6%B0%8F%E6%9B%BF%E6%8D%A2%E5%8E%9F%E5%88%99)的要求，其大致含义为：

> 在一段程序中， 如果 `S` 是 `T`的子类型，那么`T`类型的对象就有可能在没有任何警告的情况下被替换为`S`类型的对象。

所以，为什吗`NSOrderedSet`是`NSObject`的一个子类，而不是`NSSet`甚至是`NSArray`的子类哪？

_可变/不可变的类簇_

[类簇](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html%23//apple_ref/doc/uid/TP40002974-CH4-SW34)是Foundation framework核心所使用的一种设计模式；也是日常使用Objective-C简洁性的本质。

当类簇提供简单的可扩展性的同时，他也把有些事情变得很棘手，尤其是对于一对可变/不可变类像 `NSSet` / `NSMutableSet`来说。

正如 [Tom Dalling](http://tomdalling.com) 在这个 [Stack Overflow](http://stackoverflow.com/questions/11278995/why-doesnt-nsorderedset-inherit-from-nsset) 回答里面巧妙的演示，`-mutableCopy` 这个方法的创建是跟Objective-C对单继承的约束矛盾的。

开始，让我们来看下 `-mutableCopy` 在类簇中是如果工作的：

~~~{objective-c}
NSSet* immutable = [NSSet set];
NSMutableSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // YES
~~~

现在让我们假设下`NSOrderedSet`事实上是`NSSet`的子类：

~~~{objective-c}
// @interface NSOrderedSet : NSSet

NSOrderedSet* immutable = [NSOrderedSet orderedSet];
NSMutableOrderedSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // NO (!)
~~~

<object data="http://nshipster.s3.amazonaws.com/nsorderedset-case-1.svg" type="image/svg+xml">
  <img src="http://nshipster.s3.amazonaws.com/nsorderedset-case-1.png" />
</object>

这样不太好。。。因为这样`NSMutableOrderedSet`就不能被用来做`NSMutableSet`类型的方法参数了。那么如果我们让`NSMutableOrderedSet`作为`NSMutableSet`的子类会发生什么事情哪？

~~~{objective-c}
// @interface NSOrderedSet : NSSet
// @interface NSMutableOrderedSet : NSMutableSet

NSOrderedSet* immutable = [NSOrderedSet orderedSet];
NSMutableOrderedSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // YES
[mutable isKindOfClass:[NSOrderedSet class]]; // NO (!)
~~~

<object data="http://nshipster.s3.amazonaws.com/nsorderedset-case-2.svg" type="image/svg+xml">
  <img src="http://nshipster.s3.amazonaws.com/nsorderedset-case-2.png" />
</object>

这样也许更糟，因为，现在`NSMutableOrderedSet`就不能被用来做`NSOrderedSet`类型的方法参数了。

无论怎样去处理它，我们都不能在现有的一对可变/不可变的类上去实现另外一对可变/不可变的类。这在Objective-C上是行不通的。

我们可以使用协议来让我们摆脱这个困境（每隔一段时间，多继承的幽灵就会冒出来），而不是自己去承担[多继承](http://en.wikipedia.org/wiki/Multiple_inheritance)的风险。
事实上，通过添加以下的协议，Foundation的集合类__可以__变的更加[面向侧面](http://zh.wikipedia.org/zh-cn/%E9%9D%A2%E5%90%91%E4%BE%A7%E9%9D%A2%E7%9A%84%E7%A8%8B%E5%BA%8F%E8%AE%BE%E8%AE%A1)：

* `NSArray : NSObject <NSOrderedCollection>`
* `NSSet : NSObject <NSUniqueCollection>`
* `NSOrderedSet : NSObject <NSOrderedCollection, NSUniqueCollection>`

然而，为了从这种方式中受益，所有现有的API都不得不重新调整来接收一个 `id<NSOrderedCollectioin>` 参数而不是 `NSArray`。但是这个过度将会是痛苦的，并且可能会打开一整条边界。。。这将意味着它可能永远不会被完全的采纳。。。这将意味着在定义你自己的API时，没有动力去采用这种方法。。。这样写也太烦了，因为现在有两种相互不兼容的方式来做事情而不是一个。。这。。。

。。。等等，为什么我们起初要使用 `NSOrderedSet` 哪？

---
在iOS 5 和Mac OS X 10.7 中介绍了 `NSOrderedSet`。然后，唯一的API变化就是在[Core Data](http://developer.apple.com/library/mac/#releasenotes/DataManagement/RN-CoreData/_index.html)部分增加了对`NSOrderedSet`的支持。

这是对使用Core Data的人来说极好的消息，因为它解决了一个长期存在的烦恼（没有办法对一个关系集合做任意的排序）。从前，你不得不添加一个`位置`属性，当每次集合被修改时都要重新计算这个属性。没有一个内置的方法去验证你的位置集合是一个唯一的或者没有间隙的序列。

`NSOrderedSet`用这种方式_对我们的[请求](http://bugreport.apple.com/)做出了回应_。

不幸的是，对于API的设计者来说，在Foundation中它的存在创建了一个在诱人的麻烦和误导之间的东西。

尽管它在Core Data中有着非常合适的特殊用例，但对于大多数可能使用它的API来说，`NSOrderedSet`也许不是一个很好的选择。在那种仅仅需要一个简单的集合对象作为参数传递的情况下，一个简单的 `NSArray` 对象就可以了—即使这里有个隐含的意思，里面不应该有重复的元素。当顺序对于一个集合参数很重要时，在这种情况下就使用 `NSArray`好了（在实现上，应该有代码来处理重复的元素）。如果唯一性很重要，或者对于一个特定的方法来说集合的语义是有意义的，`NSSet` 仍然是一个很好的选择。

---

因此，作为一般规则：**`NSOrderedSet` 对于中间和内部表示是有用的，但是你可能不应该把它作为方法参数，除非这是一个特别适用的数据模型。**

不说其他的， `NSOrderedSet`阐释了Foundation在使用类簇上的一些迷人影响。在这样做的时候，他可以让我们更好的理解和权衡简单性和可扩展性，有助于帮助我们做自己的应用设计时做出选择。
