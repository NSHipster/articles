---
title: "NSNotification &<br/>NSNotificationCenter"
author: Mattt Thompson
translator: Chester Liu
category: Cocoa
tags: popular
excerpt: "Any idea is inextricably linked to how its communicated. A medium defines the form and scale of significance in such a way to shape the very meaning of an idea. Very truly, the medium is the message."
excerpt: "思想的传播，与沟通的方式有着不可避免的联系。媒体对于信息重要性的影响是如此之大，以至于能够改变要传播的思想本身的含义。千真万确，媒体本身就是信息。"
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Any idea is inextricably linked to how it's communicated. A medium defines the form and scale of significance in such a way to shape the very meaning of an idea. Very truly, the medium is the message.

思想的传播，与沟通的方式有着不可避免的联系。媒体对于信息重要性的影响是如此之大，以至于能够改变要传播的思想本身的含义。千真万确，媒体本身就是信息。

One of the first lessons of socialization is to know one's audience. Sometimes communication is one-to-one, like an in-person conversation, while at other times, such as a television broadcast, it's one-to-many. Not being able to distinguish between these two circumstances leads to awkward situations.

在社交中，首先要学习的一课，就是要知道你的受众。有些时候沟通是一对一的，例如两个人的对话。其他一些时候，沟通是一对多的，例如电视广播。如果不能区分这两种情况，可能会发生尴尬。

This is as true of humans as it is within a computer process. In Cocoa, there are a number of approaches to communicating between objects, with different characteristics of intimacy and coupling:

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

We've discussed the importance of how events are communicated in APIs previously in our [article on Key-Value Observing](http://nshipster.com/key-value-observing/). This week, we'll expand our look at the available options, with `NSNotificationCenter` & `NSNotification`.

我们在 [关于 Key-Value Observing](http://nshipster.cn/key-value-observing/) 的文章中探讨了通过 API 进行事件传递方式的重要性。这周，我们把视野放到其他的选择上，`NSNotificationCenter` 和 `NSNotification`。

* * *

`NSNotificationCenter` provides a centralized hub through which any part of an application may notify and be notified of changes from any other part of the application. Observers register with a notification center to respond to particular events with a specified action. Each time an event occurs, the notification goes through its dispatch table, and messages any registered observers for that event.

`NSNotificationCenter` 提供了一个中心化的枢纽，通过它，应用的任何部分都可以向其他部分发送通知，或者接收来自别人的通知。观察者通过通知中心进行注册，对特定的事件注册特定的响应动作。每次这个事件发生时，通知经过分发表分发之后，会通知所有注册这个事件的观察者。

> Each running Cocoa program manages its own default notification center, so it's unusual for a new notification center to be instantiated separately.

> 每一个运行的 Cocoa 程序都有一个自己管理的默认通知中心，因此通常不会再单独实例化一个新的通知中心。

Each `NSNotification` object has a `name`, with additional context optionally provided by an associated `object` and `userInfo` dictionary.

> 每个 `NSNotification` 对象都有一个 `name`，可以通过一个关联的 `object` 对象和 `userInfo` 字典来提供额外的上下文信息。

For example, `UITextField` posts an `NSNotification` with the name `UITextFieldTextDidChangeNotification` each time its text changes. The object associated with that notification is the text field itself. In the case of `UIKeyboardWillShowNotification`, frame positioning and animation timing are passed in `userInfo`, while the notification's associated `object` is `nil`.

举个例子，`UITextField` 在每次文本发生变化时，都会发出一个名为 `UITextFieldTextDidChangeNotification` 的 `NSNotification`。这个通知关联的对象就是文本框本身。对于 `UIKeyboardWillShowNotification` 这个通知来说，`userInfo` 中存入了 frame  的位置和动画时间，关联的 `object` 是 `nil`。

### Adding Observers

### 添加观察者

All sorts of notifications are constantly passing through `NSNotificationCenter`.<sup>*</sup>  But like a tree falling in the woods, a notification is moot unless there's something listening for it.

各种各样的通知车水马龙地通过 `NSNotificationCenter`。<sup>*</sup> 然而就像在树林中倒下的大树一样，一个通知本身不会有任何实际作用，除非有人在监听着它。

The traditional way to add an observer is `–addObserver:selector:name:object:`, in which an object (usually `self`) adds itself to have the specified selector performed when a matching notification is posted.

传统的添加观察者的方式是使用 `–addObserver:selector:name:object:`，一个对象（通常是 `self`）把自己添加进去，当某个通知发出时，执行自己特定的 selector。

The modern, block-based API for adding notification observers is `–addObserverForName:object:queue:usingBlock:`. Instead of registering an existing object as an observer for a notification, this method creates its own anonymous object to be the observer, which performs a block on the specified queue (or the calling thread, if `nil`) when a matching notification is posted. Unlike its similarly named `@selector`-based counterpart, this method actually returns the constructed observer object, which is necessary for unregistering the observer, as discussed in the next section.

现代的基于 Block 的用于添加通知观察者的 API 是 `–addObserverForName:object:queue:usingBlock:`。与前面提到的把一个已有的对象注册成观察者不同，这个方法创建一个匿名对象作为观察者，当收到对应的通知时，它在指定的队列（如果队列参数为 `nil` 的话就在调用者的线程）里执行一个 block。另外一点和基于 `@selector` 的方法不同的是，这个方法会返回构造出的观察者对象，在下个部分讲到的反注册的时候会用到它。

> Contrary to a recent article claiming otherwise, `–addObserverForName:object:queue:usingBlock:` should _not_ be considered harmful. It's perfectly safe and suitable for use in applications. Just make sure to understand memory management rules when referencing `self` in blocks. Any concerns in this respect are the same as for any other block-based API.

> 和最近的一篇文章所声称的相反，`–addObserverForName:object:queue:usingBlock:` _不_ 是有害处的用法。在应用中使用它是很安全的。只需要考虑 block 中引用到 `self` 时的内存管理问题就可以了。这方面需要考虑的问题和其他的 block 风格的 API 是一致的。


The `name` and `object` parameters of both methods are used to decide whether the criteria of a posted notification match the observer. If `name` is set, only notifications with that name will trigger, but if `nil` is set, then _all_ names will match. The same is true of `object`. So, if both `name` and `object` are set, only notifications with that name _and_ the specified object will trigger. However, if both `name` and `object` are `nil`, then _all_ notifications posted will trigger.

上面提到的两个方法使用 `name` 和 `object` 这两个参数来确定通知是否符合观察者的需要。如果设置了 `name`，那么只有对应名称的通知会触发。如果设置成了 `nil`，那么 _所有_ 的名称都会触发。同样的规则也适用于 `object`。如果同时设置了 `name` 和 `object` 那么只有来自特定对象的对应名称的通知才会响应。要是 `name` 和 `object` 都是 `nil`，那么 _所有_ 的通知都会触发响应。

> <sup>*</sup>See for yourself! An ordinary iOS app fires dozens of notifications just in the first second of being launched—many that you've probably never heard of before, nor will ever have to think about again.

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

### Removing Observers

### 移除观察者

It's important for objects to remove observers before they're deallocated, in order to prevent further messages from being sent.

在对象被释放之前移除掉观察者是很重要的，这样可以避免接受到之后的消息。

There are two methods for removing observers: `-removeObserver:` and `-removeObserver:name:object:`. Again, just as with adding observers, `name` and `object` are used to define scope. `-removeObserver:`, or `-removeObserver:name:object` with `nil` for both parameters, will remove the observer from the notification center dispatch table entirely, while specifying parameters for `-removeObserver:name:object:` will only remove the observer for registrations with that name and/or object.

移除观察者有两个方法：`-removeObserver:` 和 `-removeObserver:name:object:`。和添加观察者类似，`name` 和 `object` 参数用来确定范围。使用 `-removeObserver:`，或者使用 `-removeObserver:name:object` 并把两个参数都设置成 `nil`，将会把观察者从通知中心的分发表当中彻底移除。通过 `-removeObserver:name:object:` 设置参数则只会移除注册对应的名称和/或对象的观察者。

### Posting Notifications

### 发送通知

Of course, consuming is but one side of the story. In addition to subscribing to system-provided notifications, applications may want to publish and subscribe to their own.

当然，消费只是一个方面。除了订阅系统内置的通知之外，应用程序也可以自行发布和订阅通知。

Notifications are created with `+notificationWithName:object:userInfo:`.

通知通过 `+notificationWithName:object:userInfo:` 这个方法创建。

Notification names are generally defined as string constants. Like any string constant, it should be declared `extern` in a public interface, and defined privately in the corresponding implementation. It doesn't matter too much what a notification name's value is defined to be; the name of the variable itself is commonplace, but a reverse-DNS identifier is also a classy choice. So long as notification names are unique (or explicitly aliased), everything will work as expected.

通知的名字通常定义为字符串常量。和其他字符串常量一样，应该在公共接口中使用 `extern` 声明，在实现中进行私有定义。具体的通知名称的值是什么没有太大的关系。变量本身的值是无关紧要的，当然使用可以反向 DNS 查询的标识符也是个不错的选择。只要通知的名称是唯一的（或者显式地指明别名），就能够得到我们想要的结果。

Keys for `userInfo` should likewise be defined as string constants. It's important to clearly document the expected kinds of values for each key, since the compiler can't enforce constraints on dictionaries the same way it can for an object. 

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

Notifications are posted with `–postNotificationName:object:userInfo:` or its convenience method `–postNotificationName:object:`, which passes `nil` for `userInfo`. `–postNotification:` is also available, but it's generally preferable to have the notification object creation handled by the method itself.

发送通知可以使用 `postNotificationName:object:userInfo:`，或者它的简化方法 `–postNotificationName:object:`，这个方法会自动把 `userInfo` 置为 `nil`。`–postNotification:` 这个方法也是存在的，不过通常建议把创建通知对象的过程交给系统方法自己去做。

Recall from the previous section how `name` and `object` act to scope notification dispatch. Developers are advised to be consistent in how objects are posted with notifications, and to have this behavior documented clearly in the public interface.

前面的部分中我们提到 `name` 和 `object` 用来控制通知分发的作用域。开发者们应当在对象发送通知和接收通知的方式上保持一致，而且把通知的行为在公共接口文档中进行清晰的说明。

Since notification dispatch happens on the posting thread, it may be necessary to `dispatch_async` to `dispatch_get_main_queue()` so that a notification is handled on the main thread. This is not usually necessary, but it's important to keep in mind.

由于通知分发是在发送通知的线程上进行的，可能需要使用 `dispatch_async` 和 `dispatch_get_main_queue()` 来保证通知的处理是在主线程进行。大部分情况下不需要考虑，不过还是要把这一点记在心里。

## KVO != NSNotificationCenter

Something that often slips up developers is how similar the method signatures for [Key-Value Observing](http://nshipster.com/key-value-observing/) are to those of `NSNotificationCenter`:

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

**Key-Value Observing adds observers for keypaths, while NSNotificationCenter adds observers for notifications.** Keep this distinction clear in your mind, and proceed to use both APIs confidently.

**Key-Value Observing 是在 keypaths 上添加观察者，而 NSNotificationCenter 是在通知上添加观察者。** 牢记这个区别，就可以自信地去使用这两套 API 了。

* * *

Notifications are an essential tool for communicating across an application. Because of its distributed, low-coupling characteristics, notifications are well-suited to a wide range of architectures. APIs would do well to add them for any significant events that might benefit from greater circulation—the performance overhead for this sort of chattiness is negligible.

通知在应用内部的沟通中占有非常重要的地位。因为它的分布式，低耦合特性，通知适用于很多种架构设计。对于较大范围循环的重要事件添加通知，API 的表现也很好。性能上损耗可以忽略不计。

As it were, thinking about notifications in your own life can do wonders for improving your relationships with others. Communicating intent and giving sufficient notice are the trappings of a mature, grounded individual.

在人生中思考通知的意义，能够帮助你改善和其他人的关系。能够在沟通中展现自己的意图，以及给出必要的提醒，是一个成熟踏实的成年人的特征。

...but don't take that advice too far and use it to justify life-streaming, or anything. Seriously, stop taking pictures, and just eat your damn food, _amiright_?

...但是不要过分采用这个建议并且把它作为直播自己生活的理由，或者任何东西的理由。说真的，别再拍照片了，赶紧吃你的饭吧，_我说的在理吧_？
