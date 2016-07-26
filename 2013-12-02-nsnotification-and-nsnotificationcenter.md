---
title: "NSNotification &<br/>NSNotificationCenter"
author: Mattt Thompson
translator: Chester Liu
category: Cocoa
tags: popular
excerpt: "思想的传播，与沟通的方式有着不可避免的联系。媒体对于信息重要性的影响是如此之大，以至于能够改变要传播的思想本身的含义。千真万确，媒体本身就是信息。"
status:
    swift: 2.0
    reviewed: September 8, 2015
---

思想的传播，与沟通的方式有着不可避免的联系。媒体对于信息重要性的影响是如此之大，以至于能够改变要传播的思想本身的含义。千真万确，媒体本身就是信息。

在社交中，首先要学习的一课，就是要知道你的受众。有些时候沟通是一对一的，例如两个人的对话。其他一些时候，沟通是一对多的，例如电视广播。如果不能区分这两种情况，可能会出现尴尬的场面。

同样的道理除了在人类中适用之外，也适用于计算机进程。在 Cocoa 中，对象之间的通信有很多办法，这些办法的亲近性和解耦程度各有不同：

<table id="notification-center-coupling">
    <thead>
        <tr>
            <td class="empty" colspan="2" rowspan="2"></td>
            <th colspan="2">Audience</th>
        </tr>
        <tr>
            <th>Intimate (One-to-One)</th>
            <th>Broadcast (One-to-Many)</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th rowspan="2">Coupling</th>
            <th>Loose</th>
            <td>
                <ul>
                    <li>Target-Action</li>
                    <li>Delegate</li>
                    <li>Callbacks</li>
                </ul>
            </td>
            <td>
                <ul>
                    <li><tt>Notifications</tt></li>
                </ul>
            </td>
        </tr>
        <tr>
            <th>Strong</th>
            <td>
                <ul>
                    <li>Direct Method Invocation</li>
                </ul>
            </td>
            <td>
                <ul>
                    <li>Key-Value Observing</li>
                </ul>
            </td>
        </tr>
    </tbody>
</table>

我们在 [关于 Key-Value Observing](http://nshipster.cn/key-value-observing/) 的文章中探讨了通过 API 进行事件传递方式的重要性。这周，我们把视野放到其他的选择上，`NSNotificationCenter` 和 `NSNotification`。

* * *

`NSNotificationCenter` 提供了一个中心化的枢纽，通过它，应用的任何部分都可以向其他部分发送通知，或者接收来自别人的通知。观察者通过通知中心进行注册，对特定的事件注册特定的响应动作。每次这个事件发生时，通知经过分发表分发之后，会通知所有注册这个事件的观察者。

> 每一个运行的 Cocoa 程序都有一个自己管理的默认通知中心，因此通常不会再单独实例化一个新的通知中心。

> 每个 `NSNotification` 对象都有一个 `name`，可以通过一个关联的 `object` 对象和 `userInfo` 字典来提供额外的上下文信息。

举个例子，`UITextField` 在每次文本发生变化时，都会发出一个名为 `UITextFieldTextDidChangeNotification` 的 `NSNotification`。这个通知关联的对象就是文本框本身。对于 `UIKeyboardWillShowNotification` 这个通知来说，`userInfo` 中存入了 frame  的位置和动画时间，关联的 `object` 是 `nil`。

### 添加观察者

各种各样的通知车水马龙地通过 `NSNotificationCenter`。<sup>*</sup> 然而就像在树林中倒下的大树一样，一个通知本身不会有任何实际作用，除非有人在监听着它。

传统的添加观察者的方式是使用 `–addObserver:selector:name:object:`，一个对象（通常是 `self`）把自己添加进去，当某个通知发出时，执行自己特定的 selector。

现代的基于 Block 的用于添加通知观察者的 API 是 `–addObserverForName:object:queue:usingBlock:`。与前面提到的把一个已有的对象注册成观察者不同，这个方法创建一个匿名对象作为观察者，当收到对应的通知时，它在指定的队列（如果队列参数为 `nil` 的话就在调用者的线程）里执行一个 block。另外一点和基于 `@selector` 的方法不同的是，这个方法会返回构造出的观察者对象，在下个部分讲到的反注册的时候会用到它。

> 和最近的一篇文章所声称的相反，`–addObserverForName:object:queue:usingBlock:` _不_ 是有害处的用法。在应用中使用它是很安全的。只需要考虑 block 中引用到 `self` 时的内存管理问题就可以了。这方面需要考虑的问题和其他的 block 风格的 API 是一致的。

上面提到的两个方法使用 `name` 和 `object` 这两个参数来确定通知是否符合观察者的需要。如果设置了 `name`，那么只有对应名称的通知会触发。如果设置成了 `nil`，那么 _所有_ 的名称都会触发。同样的规则也适用于 `object`。如果同时设置了 `name` 和 `object` 那么只有来自特定对象的对应名称的通知才会响应。要是 `name` 和 `object` 都是 `nil`，那么 _所有_ 的通知都会触发响应。

> <sup>*</sup> 控制好你的代码！一个普通的 iOS 应用在启动之后的几秒钟内就会发出几十个通知，其中的大部分你可能都没有听说过，也不需要去关心。

~~~{swift}
let center = NSNotificationCenter.defaultCenter()
center.addObserverForName(nil, object: nil, queue: nil) { notification in
    print("\(notification.name): \(notification.userInfo ?? [:])")
}
~~~
~~~{objective-c}
NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
[center addObserverForName:nil
                    object:nil
                     queue:nil
                usingBlock:^(NSNotification *notification)
{
     NSLog(@"%@", notification.name);
}];
~~~

### 移除观察者

在对象被释放之前移除掉观察者是很重要的，这样可以避免接受到之后的消息。

移除观察者有两个方法：`-removeObserver:` 和 `-removeObserver:name:object:`。和添加观察者类似，`name` 和 `object` 参数用来确定范围。使用 `-removeObserver:`，或者使用 `-removeObserver:name:object` 并把两个参数都设置成 `nil`，将会把观察者从通知中心的分发表当中彻底移除。通过 `-removeObserver:name:object:` 设置参数则只会移除注册对应的名称和/或对象的观察者。

### 发送通知

当然，消费只是一个方面。除了订阅系统内置的通知之外，应用程序也可以自行发布和订阅通知。

通知通过 `+notificationWithName:object:userInfo:` 这个方法创建。

通知的名字通常定义为字符串常量。和其他字符串常量一样，应该在公共接口中使用 `extern` 声明，在实现中进行私有定义。具体的通知名称的值是什么没有太大的关系。变量本身的值是无关紧要的，当然使用可以反向 DNS 查询的标识符也是个不错的选择。只要通知的名称是唯一的（或者显式地指明别名），就能够得到我们想要的结果。

类似的，`userInfo` 里的键值也应该定义成字符串常量。应该在文档中清晰地注明哪个键对应哪种类型的值，因为编译器不能像针对对象那样对字典类型中的值类型进行限制。

~~~{swift}
class FooController : UIViewController {
    enum Notifications {
        static let FooDidBar    = "XXFooDidBarNotification"
        static let FooDidBazoom = "XXFooDidBazoomNotification"
    }

    // ...
}
~~~
~~~{objective-c}
// Foo.h
extern NSString * const XXFooDidBarNotification;

// Foo.m
NSString * const XXFooDidBarNotification = @"XXFooDidBarNotification";
~~~

发送通知可以使用 `postNotificationName:object:userInfo:`，或者它的简化方法 `–postNotificationName:object:`，这个方法会自动把 `userInfo` 置为 `nil`。`–postNotification:` 这个方法也是存在的，不过通常建议把创建通知对象的过程交给系统方法去处理。

前面的部分中我们提到 `name` 和 `object` 用来控制通知分发的作用域。开发者们应当在对象发送通知和接收通知的方式上保持一致，而且把通知的行为在公共接口文档中进行清晰的说明。

由于通知分发是在发送通知的线程上进行的，可能需要使用 `dispatch_async` 和 `dispatch_get_main_queue()` 来保证通知的处理是在主线程进行。大部分情况下不需要考虑，不过还是要把这一点记在心里。

## KVO != NSNotificationCenter

有一点经常让开发者们犯糊涂，`NSNotificationCenter` 的方法签名和 [Key-Value Observing](http://nshipster.cn/key-value-observing/) 非常相似。

#### Key-Value Observing

~~~{swift}
func addObserver(observer: NSObject, forKeyPath keyPath: String, 
    options: NSKeyValueObservingOptions, 
    context: UnsafeMutablePointer<Void>)
~~~
~~~{objective-c}
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context
~~~

#### NSNotificationCenter

~~~{swift}
func addObserver(observer: AnyObject, 
    selector aSelector: Selector,
    name aName: String?, 
    object anObject: AnyObject?)

func addObserverForName(name: String?, 
    object obj: AnyObject?,
    queue: NSOperationQueue?, 
    usingBlock block: (NSNotification) -> Void) -> NSObjectProtocol
~~~
~~~{objective-c}
- (void)addObserver:(id)notificationObserver
           selector:(SEL)notificationSelector
               name:(NSString *)notificationName
             object:(id)notificationSender

- (id)addObserverForName:(NSString *)name
                  object:(id)obj
                   queue:(NSOperationQueue *)queue
              usingBlock:(void (^)(NSNotification *))block
~~~

**Key-Value Observing 是在 keypaths 上添加观察者，而 NSNotificationCenter 是在通知上添加观察者。** 牢记这个区别，就可以自信地去使用这两套 API 了。

* * *

通知在应用内部的沟通中占有非常重要的地位。因为它的分布式，低耦合特性，通知适用于很多种架构设计。对于较大范围循环的重要事件添加通知，API 的表现也很好。性能上损耗可以忽略不计。

在人生中思考通知的意义，可以帮助你改善和其他人的关系。能够在沟通中展现自己的意图，以及给出必要的提醒，是一个成熟踏实的成年人的特征。

...但是不要过分采用这个建议并且把它作为直播自己生活的理由，或者任何东西的理由。说真的，别再拍照片了，赶紧吃你的饭吧，_我说的在理吧_？
