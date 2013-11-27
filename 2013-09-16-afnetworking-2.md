---
layout: post
title: AFNetworking 2.0

ref: "https://github.com/AFNetworking/AFNetworking"
framework: "Open Source"
rating: 9.9
description: "AFNetworking是iOS和Mac OS X的开发中被最广泛使用的开源项目之一。它几乎已经成为绝对的主流。但你有没有听说过它的续集呢？"
---

[AFNetworking](http://afnetworking.com)是当前iOS和Mac OS X
的开发中被最广泛使用的开源项目之一。它帮助了数以千计的叫好又叫座的应用，又为很多其它的很棒的开源的库和框架提供了基础。同时，拥有8700个星，2200个叉，和130名贡献者，这个项目同时也是社区里最活跃，最有影响力的项目之一。

据说，AFNetworking几乎已经成为绝对的主流。

_但你有没有听说过它的续集呢？_  
[AFNetworking 2.0](https://github.com/AFNetworking/AFNetworking/).

这一周的NSHipster：独家来看看NSHipster的未来。

> 全面披露：NSHipster是由[AFNetworking的作者](https://twitter.com/mattt)所撰写的，所以这并不是对AFNetworking以及它的优点的客观看法。你所能得到的，是关于AFNetworkiing目前的和即将发布的版本的个人的，诚实的看法。

## AFNetworking的大想法

始于2011年五月，AFNetworking作为一个[基于位置的社交网络](http://en.wikipedia.org/wiki/Gowalla)的[苹果例程](https://developer.apple.com/library/ios/samplecode/mvcnetworking/Introduction/Intro.html)的不起眼的延伸，它的成功是天时地利的产物。 当[ASIHTTPRequest](https://github.com/pokeb/asi-http-request)成为网络问题的实际解决方案时，AFNetworking的核心思想正好迎合上开发者想要寻找一个更加现代的解决方案的时机。
### NSURLConnection + NSOperation

`NSURLConnection`是Foundation URL加载系统的基石。一个`NSURLConnection`异步地加载一个`NSURLRequest`对象，以`NSURLResponse`／`NSHTTPURLResponse`来调用它的委托的方法，并且其相关联的`NSData`被发送到并由服务器加载；委托还可以用来实现处理`NSURLAuthenticationChallenge`，重定向响应，或者用来决定相关的`NSCachedURLResponse`如何被存储在共享的`NSURLCache`上。

[`NSOperation`](http://nshipster.com/nsoperation)是一个模拟一个计算单元的抽象的类，它拥有有用的构造，如状态，优先级，相依性和取消。

AFNetworking的第一个重大突破就是将这两者结合。`AFURLConnectionOperation`作为`NSOperation`的子类，也遵循`NSURLConnectionDelegate`的方法，并且追踪一个请求从开始到结束的状态，同时它也可以存储如请求，响应，响应数据等的中间状态。 

### Blocks

iOS 4引入的block和Grand Central Dispatch从根本上改善了应用程序的开发过程。相比于在应用中用delegate乱七八糟的实现逻辑，开发者们可以在block属性中本地化相关的功能。GCD可以轻松地来回调度工作，而不是和一对乱七八糟地线程，调用和操作队列作斗争。

更重要的是，`NSURLConnectionDelegate`方法可以通过设置block属性为每一个请求进行自定义操作（比如，设置`setWillSendRequestForAuthenticationChallengeBlock:`来覆盖默认的连接实现方式`connection:willSendRequestForAuthenticationChallenge:`）。

现在，我们可以创建`AFURLConnectionOperation`并把它安排进`NSOperationQueue`，通过设置`NSOperation`的新的属性`completionBlock`，我们还可以指定当操作完成时如何处理响应和响应数据（或者在请求的周期中遇到的任何错误）。

### 序列化 & 验证

让我们更深入一些，请求操作的责任可以延伸到验证HTTP状态码和验证服务器响应的内容类型，比如，对于有`application/json`MIME类型的响应，我们可以将NSData序列化为JSON对象。 

从服务器加载JSON，XML，Property List或者图像可以被抽象的类比成一个潜在的文件的加载操作，这样开发者可以将这个过程想象成一个承诺而不是异步联网。

## 介绍AFNetworking 2.0

AFNetworking的成功在于它在易于使用性和可扩展性之间取得平衡。但这并不是说它就没有提升的空间。 

随着它的第二次重要发布，AFNetworking旨在调和原设计的怪异之处，同时为下一代的iOS和Mac OS X应用程序增加强大的新的架构。

### 动机

- **NSURLSession兼容性** - `NSURLSession`是iOS 7新引入的用于替代`NSURLConnection`的类。`NSURLConnection`并没有被弃用，并且一段时间应该都不会，但是`NSURLSession`将会成为Foundation中的网络的未来，并且会是一个美好的未来，因为它改进了它的前身的很多缺点。（参考WWDC 2013的Session 705“What’s New in Foundation Networking”，这会是一个很好的概述）。刚开始有的人推测，`NSURLSession`的出现将会使我们不再需要AFNetworking；虽然它们有一些重叠，但AFNetworking还是可以提供更高层次的抽象应用。__AFNetworking 2.0不仅能做到这一点，还借助并扩展了`NSURLSession`来铺平道路上的坑坑洼洼，并且最大程度的扩展了它的实用性。__
- **模块化** - 对于AFNetworking的主要批评之一就是它的笨重。虽然它的构架使得它在类的层面上有不错的模块性，但它的包装使得它不能允许个别功能被逐一选择。随着时间的推移，尤其是`AFHTTPClient`变的不堪重负（它的任务包括创建请求，序列化查询字符串参数，确定响应解析行为，生成和管理操作，监控网络可达性）。 __在AFNetworking 2.0中，你可以挑选并通过[CocoaPods subspecs](https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format#subspecs)仅仅选择你所需要的组件。__
- **实时性** - 有了这个新版本，AFNetworking旨在将实时性功能提上日程。在接下来的18个月，实时性将从目前最棒的1%的功能之一变成用户默认的功能。 __AFNetworking 2.0采用[Rocket](http://rocket.github.io)技术，它利用如[服务器发送事件](http://dev.w3.org/html5/eventsource/)以及[JSON补丁](http://tools.ietf.org/html/rfc6902)的网络标准在现有的REST网络服务上架构语义上的实时服务。__

### 演员阵容

#### `NSURLConnection`组件 _(iOS 6 & 7)_

- `AFURLConnectionOperation` - `NSOperation`的一个子类，负责管理`NSURLConnection`并且实现其委托方法。
- `AFHTTPRequestOperation` - `AFURLConnectionOperation`的一个子类，专门用来生成HTTP请求，它可以区分可接受的和不可接受的状态代码和内容类型。它在2.0版本中的最大区别是，_你可以直接使用这个类，而不用将它作为子类_，原因可以在“序列化”一节中找到。
- `AFHTTPRequestOperationManager` - 通过HTTP使用web服务来封装通讯的常见模式的一个类，并通过`AFHTTPRequestOperation`由`NSURLConnection`支持。 

#### `NSURLSession`组件 _(iOS 7)_

- `AFURLSessionManager` - 创建和管理基于特定`NSURLSessionConfiguration`对象的`NSURLSession`对象的类，它还能创建和管理那个session的数据，下载和上传任务，实现那个session和其相关联的任务的委托方法。Because of the odd gaps in `NSURLSession`'s API design, __any code working with `NSURLSession` would be improved by `AFURLSessionManager`__. 
- `AFHTTPSessionManager` - `AFURLSessionManager`的子类，通过HTTP网络服务封装通信的常见模式，通过`AFURLSessionManager`由`NSURLSession`支持。

---

> **总的来说**：为了支持新的`NSURLSession`API以及旧的但并不过时且还很有用的`NSURLConnection`，AFNetworking 2.0的核心组件被分成请求操作以及会话任务。`AFHTTPRequestOperationManager`和`AFHTTPSessionManager`提供类似的功能，在需要的时候（比如在iOS6和7之间转换），它们的接口可以相对容易的互换。

> 之前所有绑定在`AFHTTPClient`的功能，比如序列化，安全性，可达性，都在几个模块中被拆分为可以被`NSURLSession`以及`NSURLConnection`支持的API共享。

---

#### 序列化

AFNetworking 2.0新构架的突破之一是使用序列化来创建请求以及解析响应。序列化的灵活设计允许更多的业务逻辑被转移到网络层，并使得先前内置的默认行为可以更容易被定制。

- `<AFURLRequestSerializer>` - 符合这个协议的对象是用来装饰请求的，它将请求参数转换成查询字符串或者实体内容描述，以及设置必要的报头。对于那些不喜欢`AFHTTPClient`编码查询字符串参数的方式的人来说，应该会觉得这个新方法更对你们的胃口。
- `<AFURLResponseSerializer>` - 符合这个协议的对象负责验证响应和与响应相关的数据，并将它们序列化为有用的表达，比如JSON对象，图像，甚至[Mantle](https://github.com/blog/1299-mantle-a-model-framework-for-objective-c)支持的模型对象。相较于无休止的继承`AFHTTPClient`，`AFHTTPRequestOperation`现在有一个被设置到合适的处理器的`responseSerializer`属性。同样的，再也没有[以`NSURLProtocol`为灵感的请求操作类注册](http://cocoadocs.org/docsets/AFNetworking/1.3.1/Classes/AFHTTPClient.html#//api/name/registerHTTPOperationClass:)了，取而代之的还是那个令人欢喜的`responseSerializer`属性。谢天谢地。

#### 安全性

感谢[Dustin Barker](https://github.com/dstnbrkr)，[Oliver Letterer](https://github.com/OliverLetterer)，[Kevin Harwood](https://github.com/kcharwood)还有其他人所作出的贡献，AFNetworking带有内置的[SSL pinning](http://blog.lumberlabs.com/2012/04/why-app-developers-should-care-about.html)支持，这对于处理敏感信息的应用是十分重要的。

- `AFSecurityPolicy` - 评估服务器对安全连接针对指定的固定证书或公共密钥的信任。tl;dr 将你的服务器证书添加到你的应用程序包，以帮助防止[中间人攻击](http://en.wikipedia.org/wiki/Man-in-the-middle_attack)。

#### 可达性

`AFHTTPClient`削弱了的另一个功能是网络可达性。现在你可以直接使用它，或者使用`AFHTTPRequestOperationManager`／`AFHTTPSessionManager`的属性。

- `AFNetworkReachabilityManager` - 这个类监控当前网络的可达性，提供可达性变化时的回调块和通知。

#### 实时性

- `AFEventSource` - [`EventSource`DOM API](http://en.wikipedia.org/wiki/Server-sent_events)的Objective-C实现。一个持久的HTTP连接由主机建立，并将事件传输到事件源并派发到听众。传输到事件源的消息的格式为[JSON补丁](http://tools.ietf.org/html/rfc6902)文件，并被翻译成`AFJSONPatchOperation`对象数组。这些补丁的操作可以被应用到从服务器获取的持久性数据集。
~~~{objective-c}
NSURL *URL = [NSURL URLWithString:@"http://example.com"];
AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:URL];
[manager GET:@"/resources" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    [resources addObjectsFromArray:responseObject[@"resources"]];

    [manager SUBSCRIBE:@"/resources" usingBlock:^(NSArray *operations, NSError *error) {
        for (AFJSONPatchOperation *operation in operations) {
            switch (operation.type) {
                case AFJSONAddOperationType:
                    [resources addObject:operation.value];
                    break;
                default:
                    break;
            }
        }
    } error:nil];
} failure:nil];
~~~

#### UIKit Extensions

UIKit中的所有类都被AFNetworking 2.0选取并且都扩充了几个新的列表。

- `AFNetworkActivityIndicatorManager`：在请求操作和任务开始和停止加载时，自动开启或终止状态栏上的网络活动指示标志。
- `UIImageView+AFNetworking`：增加了`imageResponseSerializer`属性，它可以让远程加载在image view上的图像轻松的自动调整大小或者应用过滤器。比如，[`AFCoreImageSerializer`](https://github.com/AFNetworking/AFCoreImageSerializer)可以在响应的图像显示之前应用Core Image filter。
- `UIButton+AFNetworking` *(新)*：与`UIImageView+AFNetworking`类似，从远程资源加载`image`和`backgroundImage`。
- `UIActivityIndicatorView+AFNetworking` *(新)*：根据指定的请求操作和会话任务的状态自动开始以及停止`UIActivityIndicatorView`。
- `UIProgressView+AFNetworking` *(新)*：自动跟踪上载或下载指定的请求操作或者会话任务的进度。
- `UIWebView+AFNetworking` *(新)*: 为加载URL请求提供了更强大的API，并且支持进度回调和内容转换。

---

这就是我们的AFNetworking旋风之旅的结尾了。为了下一代应用的新的功能，以及一个全新的构架与所有的现有的功能的结合，有很多值得我们兴奋的东西。

### 旗开得胜

将下列代码加入[`Podfile`](http://cocoapods.org)你就可以开始使用AFNetworking 2.0了：

~~~{ruby}
platform :ios, '7.0'
pod "AFNetworking", "2.0.0"
~~~

对于由当前1.x版本转移到新的AFNetworking版本的用户，你会发现[AFNetworking 2.0迁移指南](https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-2.0-Migration-Guide)非常有用。

如果你遇到bug或者其它的奇怪的地方，请通过[在GitHub开启一个问题](https://github.com/afnetworking/afnetworking/issues?state=open)来帮助我们改进。您的帮助让我们不胜感激。

对于一般的使用问题，请随时tweet我[@AFNetworking](https://twitter.com/AFNetworking)，或者给我发邮件<m@mattt.me>.

Oh yeah，还有一件事...

---

## AFNetworking: the Definitive Guide

我很高兴的宣布，AFNetworking将会正式出版书了！

**"AFNetworking: the Definitive Guide"**将由[O'Reilly](http://oreilly.com)出版，希望就在接下来的几个月之中。你可以[在这里注册书出版时通过邮箱通知](http://eepurl.com/Flnvn)，或者[关注@AFNetworking](https://twitter.com/AFNetworking)。
