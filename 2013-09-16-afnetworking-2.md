---
layout: post
title: AFNetworking 2.0
author: Mattt Thompson
translator: Zihan Xu
category: Open Source
excerpt: "AFNetworking 是 iOS 和 Mac OS X 开发中最广泛使用的开源项目之一。它十分流行，但你有没有听说过它的新版呢？"
---

[AFNetworking](http://afnetworking.com) 是当前 iOS 和 Mac OS X
开发中最广泛使用的开源项目之一。它帮助了成千上万叫好又叫座的应用，也为其它出色的开源库提供了基础。这个项目是社区里最活跃、最有影响力的项目之一，拥有 8700 个 star、2200 个 fork 和 130 名贡献者。

从各方面来看，AFNetworking 几乎已经成为主流。

_但你有没有听说过它的新版呢？_
[AFNetworking 2.0](https://github.com/AFNetworking/AFNetworking/)。

这一周的 NSHipster：独家揭晓 AFNetworking 的未来。

> 声明：NSHipster 由 [AFNetworking 的作者](https://twitter.com/mattt) 撰写，所以这并不是对 AFNetworking 及它的优点的客观看法。你能看到的是个人关于 AFNetworking 目前及未来版本的真实看法。

## AFNetworking 的大体思路

始于 2011 年 5 月，AFNetworking 作为一个[已死的 LBS 项目](http://en.wikipedia.org/wiki/Gowalla)中对 [Apple 范例代码](https://developer.apple.com/library/ios/samplecode/mvcnetworking/Introduction/Intro.html)的延伸，它的成功更是由于时机。彼时 [ASIHTTPRequest](https://github.com/pokeb/asi-http-request) 是网络方面的主流方案，AFNetworking 的核心思路使它正好成为开发者渴求的更现代的方案。

### NSURLConnection + NSOperation

`NSURLConnection` 是 Foundation URL 加载系统的基石。一个 `NSURLConnection` 异步地加载一个 `NSURLRequest` 对象，调用 delegate 的 `NSURLResponse` / `NSHTTPURLResponse` 方法，其 `NSData` 被发送到服务器或从服务器读取；delegate 还可用来处理 `NSURLAuthenticationChallenge`、重定向响应、或是决定 `NSCachedURLResponse` 如何存储在共享的 `NSURLCache` 上。

[`NSOperation`](http://nshipster.com/nsoperation) 是抽象类，模拟单个计算单元，有状态、优先级、依赖等功能，可以取消。

AFNetworking 的第一个重大突破就是将两者结合。`AFURLConnectionOperation` 作为 `NSOperation` 的子类，遵循 `NSURLConnectionDelegate` 的方法，可以从头到尾监视请求的状态，并储存请求、响应、响应数据等中间状态。

### Blocks

iOS 4 引入的 block 和 Grand Central Dispatch 从根本上改善了应用程序的开发过程。相比于在应用中用 delegate 乱七八糟地实现逻辑，开发者们可以用 block 将相关的功能放在一起。GCD 能够轻易来回调度工作，不用面对乱七八糟的线程、调用和操作队列。

更重要的是，对于每个 request operation，可以通过 block 自定义 `NSURLConnectionDelegate` 的方法（比如，通过 `setWillSendRequestForAuthenticationChallengeBlock:` 可以覆盖默认的 `connection:willSendRequestForAuthenticationChallenge:` 方法）。

现在，我们可以创建 `AFURLConnectionOperation` 并把它安排进 `NSOperationQueue`，通过设置 `NSOperation` 的新属性 `completionBlock`，指定操作完成时如何处理 response 和 response data（或是请求过程中遇到的错误）。

### 序列化 & 验证

更深入一些，request operation 操作也可以负责验证 HTTP 状态码和服务器响应的内容类型，比如，对于 `application/json` MIME 类型的响应，可以将 NSData 序列化为 JSON 对象。

从服务器加载 JSON、XML、property list 或者图像可以抽象并类比成潜在的文件加载操作，这样开发者可以将这个过程想象成一个 promise 而不是异步网络连接。

## 介绍 AFNetworking 2.0

AFNetworking 胜在易于使用和可扩展之间取得的平衡，但也并不是没有提升的空间。

在第二个大版本中，AFNetworking 旨在消除原有设计的怪异之处，同时为下一代 iOS 和 Mac OS X 应用程序增加一些强大的新架构。

### 动机

- **兼容 NSURLSession** - `NSURLSession` 是 iOS 7 新引入的用于替代 `NSURLConnection` 的类。`NSURLConnection` 并没有被弃用，今后一段时间应该也不会，但是 `NSURLSession` 是 Foundation 中网络的未来，并且是一个美好的未来，因为它改进了之前的很多缺点。（参考 WWDC 2013 Session 705 “What’s New in Foundation Networking”，一个很好的概述）。起初有人推测，`NSURLSession` 的出现将使 AFNetworking 不再有用。但实际上，虽然它们有一些重叠，AFNetworking 还是可以提供更高层次的抽象。__AFNetworking 2.0 不仅做到了这一点，还借助并扩展 `NSURLSession` 来铺平道路上的坑洼，并最大程度扩展了它的实用性。__

- **模块化** - 对于 AFNetworking 的主要批评之一是笨重。虽然它的构架使在类的层面上是模块化的，但它的包装并不允许选择独立的一些功能。随着时间的推移，`AFHTTPClient` 尤其变得不堪重负（其任务包括创建请求、序列化 query string 参数、确定响应解析行为、生成和管理 operation、监视网络可达性）。 __在 AFNetworking 2.0 中，你可以挑选并通过 [CocoaPods subspecs](https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format#subspecs) 选择你所需要的组件。__

- **实时性** - 在新版本中，AFNetworking 尝试将实时性功能提上日程。在接下来的 18 个月，实时性将从最棒的 1% 变成用户都期待的功能。 __AFNetworking 2.0 采用 [Rocket](http://rocket.github.io) 技术，利用 [Server-Sent Event](http://dev.w3.org/html5/eventsource/) 和 [JSON Patch](http://tools.ietf.org/html/rfc6902) 等网络标准在现有的 REST 网络服务上构建语义上的实时服务。__

### 演员阵容

#### `NSURLConnection` 组件 _(iOS 6 & 7)_

- `AFURLConnectionOperation` - `NSOperation` 的子类，负责管理 `NSURLConnection` 并且实现其 delegate 方法。
- `AFHTTPRequestOperation` - `AFURLConnectionOperation` 的子类，用于生成 HTTP 请求，可以区别可接受的和不可接受的状态码及内容类型。2.0 版本中的最大区别是，__你可以直接使用这个类，而不用继承它__，原因可以在“序列化”一节中找到。
- `AFHTTPRequestOperationManager` - 包装常见 HTTP web 服务操作的类，通过 `AFHTTPRequestOperation` 由 `NSURLConnection` 支持。

#### `NSURLSession` 组件 _(iOS 7)_

- `AFURLSessionManager` - 创建、管理基于 `NSURLSessionConfiguration` 对象的 `NSURLSession` 对象的类，也可以管理 session 的数据、下载/上传任务，实现 session 和其相关联的任务的 delegate 方法。因为 `NSURLSession` API 设计中奇怪的空缺，__任何和 `NSURLSession` 相关的代码都可以用 `AFURLSessionManager` 改善__。
- `AFHTTPSessionManager` - `AFURLSessionManager` 的子类，包装常见的 HTTP web 服务操作，通过 `AFURLSessionManager` 由 `NSURLSession` 支持。

---

> **总的来说**：为了支持新的 `NSURLSession` API 以及旧的未弃用且还有用的 `NSURLConnection`，AFNetworking 2.0 的核心组件分成了 request operation 和 session 任务。`AFHTTPRequestOperationManager` 和 `AFHTTPSessionManager` 提供类似的功能，在需要的时候（比如在 iOS 6 和 7 之间转换），它们的接口可以相对容易的互换。

> 之前所有绑定在 `AFHTTPClient `的功能，比如序列化、安全性、可达性，被拆分成几个独立的模块，可被基于 `NSURLSession` 和 `NSURLConnection` 的 API 使用。

---

#### 序列化

AFNetworking 2.0 新构架的突破之一是使用序列化来创建请求、解析响应。可以通过序列化的灵活设计将更多业务逻辑转移到网络层，并更容易定制之前内置的默认行为。

- `<AFURLRequestSerializer>` - 符合这个协议的对象用于处理请求，它将请求参数转换为 query string 或是 entity body 的形式，并设置必要的 header。那些不喜欢 `AFHTTPClient` 使用 query string 编码参数的家伙，你们一定喜欢这个。

- `<AFURLResponseSerializer>` - 符合这个协议的对象用于验证、序列化响应及相关数据，转换为有用的形式，比如 JSON 对象、图像、甚至基于 [Mantle](https://github.com/blog/1299-mantle-a-model-framework-for-objective-c) 的模型对象。相比没完没了地继承 `AFHTTPClient`，现在 `AFHTTPRequestOperation` 有一个 `responseSerializer` 属性，用于设置合适的 handler。同样的，再也没有[没用的受 `NSURLProtocol` 启发的 request operation 类注册](http://cocoadocs.org/docsets/AFNetworking/1.3.1/Classes/AFHTTPClient.html#//api/name/registerHTTPOperationClass:)，取而代之的还是很棒的 `responseSerializer` 属性。谢天谢地。

#### 安全性

感谢 [Dustin Barker](https://github.com/dstnbrkr)、[Oliver Letterer](https://github.com/OliverLetterer)、[Kevin Harwood](https://github.com/kcharwood) 等人做出的贡献，AFNetworking 现在带有内置的 [SSL pinning](http://blog.lumberlabs.com/2012/04/why-app-developers-should-care-about.html) 支持，这对于处理敏感信息的应用是十分重要的。

- `AFSecurityPolicy` - 评估服务器对安全连接针对指定的固定证书或公共密钥的信任。tl;dr 将你的服务器证书添加到 app bundle，以帮助防止 [中间人攻击](http://en.wikipedia.org/wiki/Man-in-the-middle_attack)。

#### 可达性

从 `AFHTTPClient` 解藕的另一个功能是网络可达性。现在你可以直接使用它，或者使用 `AFHTTPRequestOperationManager` / `AFHTTPSessionManager` 的属性。

- `AFNetworkReachabilityManager` - 这个类监控当前网络的可达性，提供回调 block 和 notificaiton，在可达性变化时调用。

#### 实时性

- `AFEventSource` - [`EventSource` DOM API](http://en.wikipedia.org/wiki/Server-sent_events) 的 Objective-C 实现。建立一个到某主机的持久 HTTP 连接，可以将事件传输到事件源并派发到听众。传输到事件源的消息的格式为 [JSON Patch](http://tools.ietf.org/html/rfc6902) 文件，并被翻译成 `AFJSONPatchOperation` 对象的数组。可以将这些 patch operation 应用到之前从服务器获取的持久性数据集。
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

#### UIKit 扩展

之前 AFNetworking 中的所有 UIKit category 都被保留并增强，还增加了一些新的 category。

- `AFNetworkActivityIndicatorManager`：在请求操作开始、停止加载时，自动开始、停止状态栏上的网络活动指示图标。
- `UIImageView+AFNetworking`：增加了 `imageResponseSerializer` 属性，可以轻松地让远程加载到 image view 上的图像自动调整大小或应用滤镜。比如，[`AFCoreImageSerializer`](https://github.com/AFNetworking/AFCoreImageSerializer) 可以在 response 的图像显示之前应用 Core Image filter。
- `UIButton+AFNetworking` *(新)*：与 `UIImageView+AFNetworking` 类似，从远程资源加载 `image` 和 `backgroundImage`。
- `UIActivityIndicatorView+AFNetworking` *(新)*：根据指定的请求操作和会话任务的状态自动开始、停止 `UIActivityIndicatorView`。
- `UIProgressView+AFNetworking` *(新)*：自动跟踪某个请求或会话任务的上传/下载进度。
- `UIWebView+AFNetworking` *(新)*: 为加载 URL 请求提供了更强大的API，支持进度回调和内容转换。

---

于是终于要结束 AFNetworking 旋风之旅了。为下一代应用设计的新功能，结合为已有功能设计的全新架构，有很多东西值得兴奋。

### 旗开得胜

将下列代码加入 [`Podfile`](http://cocoapods.org) 就可以开始把玩 AFNetworking 2.0 了：

~~~{ruby}
platform :ios, '7.0'
pod "AFNetworking", "2.0.0"
~~~

For anyone coming over to AFNetworking from the current 1.x release, you may find [the AFNetworking 2.0 Migration Guide](https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-2.0-Migration-Guide) especially useful.

对于由 AFNetworking 1.x 版本转移到新版本的用户，你可以找到 [AFNetworking 2.0 迁移指南](https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-2.0-Migration-Guide)。

如果你遇到 bug 或者其它的奇怪的地方，请通过[在 GitHub 开启一个问题](https://github.com/afnetworking/afnetworking/issues?state=open)来帮助我们改进。非常感谢您的帮助。

对于一般的使用问题，请随时 tweet 我 [@AFNetworking](https://twitter.com/AFNetworking)，或者给我发邮件。
