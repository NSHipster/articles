---
layout: post
title: NSOperation
author: Mattt Thompson
translator: Henry Lee
category: Cocoa
tag: popular
excerpt: "我们都知道，让程序瞬间加载并且快速响应的秘诀在于后台异步执行任务。"
---

我们都知道，让程序瞬间加载并且快速响应的秘诀在于后台异步执行任务。

现在的Objective-C开发者一般有两个选择，分别是[Grand Central Dispatch](http://en.wikipedia.org/wiki/Grand_Central_Dispatch)或者[`NSOperation`](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html)。现在GCD已经逐渐发展成主流了，所以我们来谈谈后者，一个面向对象的解决办法。

`NSOperation`表示了一个独立的计算单元。作为一个抽象类，它给了它的子类一个十分有用而且线程安全的方式来建立状态、优先级、依赖性和取消等的模型。或者，你不是很喜欢再自己继承`NSOperation`的话，框架还提供`NSBlockOperation`，这是一个继承自`NSOperation`且封装了block的实体类。

很多执行任务类型的案例都很好的运用了`NSOperation`，包括[网络请求](https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFURLConnectionOperation.h)，图像压缩，自然语言处理或者其他很多需要返回处理后数据的、可重复的、结构化的、相对长时间运行的任务。

但是仅仅把计算封装进一个对象而不做其他处理显然没有多大用处，我们还需要`NSOperationQueue`来大显身手。

`NSOperationQueue`控制着这些并行操作的执行，它扮演者优先级队列的角色，让它管理的高优先级操作(`NSOperation -queuePriority`)能优先于低优先级的操作运行的情况下，使它管理的操作能基本遵循先进先出的原则执行。此外，在你设置了能并行运行的操作的最大值(`maxConcurrentOperationCount`)之后，`NSOperationQueue`还能并行执行操作。

让一个`NSOperation`操作开始，你可以直接调用`-start`，或者将它添加到`NSOperationQueue`中，添加之后，它会在队列排到它以后自动执行。

现在让我们通过怎样使用和怎样通过继承实现功能来看看`NSOperation`稍微复杂的部分。

## 状态

`NSOperation`包含了一个十分优雅的状态机来描述每一个操作的执行。

> `isReady` → `isExecuting` → `isFinished`

为了替代不那么清晰的`state`属性，状态直接由上面那些keypath的KVO通知决定，也就是说，当一个操作在准备好被执行的时候，它发送了一个KVO通知给`isReady`的keypath，让这个keypath对应的属性`isReady`在被访问的时候返回`YES`。

每一个属性对于其他的属性必须是互相独立不同的，也就是同时只可能有一个属性返回`YES`，从而才能维护一个连续的状态：
- `isReady`: 返回 `YES` 表示操作已经准备好被执行, 如果返回`NO`则说明还有其他没有先前的相关步骤没有完成。
- `isExecuting`: 返回`YES`表示操作正在执行，反之则没在执行。
- `isFinished` : 返回`YES`表示操作执行成功或者被取消了，`NSOperationQueue`只有当它管理的所有操作的`isFinished`属性全标为`YES`以后操作才停止出列，也就是队列停止运行，所以正确实现这个方法对于避免死锁很关键。

## 取消

早些取消那些没必要的操作是十分有用的。取消的原因可能包括用户的明确操作或者某个相关的操作失败。

与之前的执行状态类似，当`NSOperation`的`-cancel`状态调用的时候会通过KVO通知`isCancelled`的keypath来修改`isCancelled`属性的返回值，`NSOperation`需要尽快地清理一些内部细节，而后到达一个合适的最终状态。特别的，这个时候`isCancelled`和`isFinished`的值将是YES，而`isExecuting`的值则为NO。

有一件肯定需要注意的事情就是关于单词"cancel"的拼法特性，尽管各类英语的习惯不尽相同，但是对于`NSOperation`来说：
- `cancel`: 方法调用里只需要一个L（动词）
- `isCancelled`: 属性里需要两个L（形容词）

## 优先级

不可能所有的操作都是一样重要，通过以下的顺序设置`queuePriority`属性可以加快或者推迟操作的执行：

- `NSOperationQueuePriorityVeryHigh`
- `NSOperationQueuePriorityHigh`
- `NSOperationQueuePriorityNormal`
- `NSOperationQueuePriorityLow`
- `NSOperationQueuePriorityVeryLow`

此外，有些操作还可以指定`threadPriority`的值，它的取值范围可以从`0.0`到`1.0`，`1.0`代表最高的优先级。鉴于`queuePriority`属性决定了操作执行的顺序，`threadPriority`则指定了当操作开始执行以后的CPU计算能力的分配，如果你不知道这是什么，好吧，你可能根本没必要知道这是什么。

## 依赖性

根据你应用的复杂度不同，将大任务再分成一系列子任务一般都是很有意义的，而你能通过`NSOperation`的依赖性实现。

比如说，对于服务器下载并压缩一张图片的整个过程，你可能会将这个整个过程分为两个操作（可能你还会用到这个网络子过程再去下载另一张图片，然后用压缩子过程去压缩磁盘上的图片）。显然图片需要等到下载完成之后才能被调整尺寸，所以我们定义网络子操作是压缩子操作的_依赖_，通过代码来说就是：

~~~{objective-c}
[resizingOperation addDependency:networkingOperation];
[operationQueue addOperation:networkingOperation];
[operationQueue addOperation:resizingOperation];
~~~

除非一个操作的依赖的`isFinished`返回`YES`，不然这个操作不会开始。时时牢记将所有的依赖关系添加到操作队列很重要，不然会像走路遇到一条大沟，就走不过去了哟。

此外，确保不要意外地创建依赖循环，像A依赖B，B又依赖A，这也会导致杯具的死锁。

## `completionBlock`

有一个在iOS 4和Snow Leopard新加入的十分有用的功能就是`completionBlock`属性。

每当一个`NSOperation`执行完毕，它就会调用它的`completionBlock`属性一次，这提供了一个非常好的方式让你能在视图控制器(View Controller)里或者模型(Model)里加入自己更多自己的代码逻辑。比如说，你可以在一个网络请求操作的`completionBlock`来处理操作执行完以后从服务器下载下来的数据。

---

对于现在Objective-C程序员必须掌握的工具中，`NSOperation`依然是最基本的一个。尽管GCD对于内嵌异步操作十分理想，`NSOperation`依旧提供更复杂、面向对象的计算模型，它对于涉及到各种类型数据、需要重复处理的任务又是更加理想的。在你的下一个项目里使用它吧，让它及带给用户欢乐，你自己也会很开心的。
