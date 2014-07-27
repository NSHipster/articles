---
layout: post
title: NSURLCache
author: Mattt Thompson
translator: Ricky Tan
category: Cocoa
tag: popular
excerpt: "NSURLCache 为您的应用的 URL 请求提供了内存中以及磁盘上的综合缓存机制。作为基础类库 URL 加载系统的一部分，任何通过 NSURLConnection 加载的请求都将被 NSURLCache 处理。"
---

`NSURLCache` 为您的应用的 URL 请求提供了内存中以及磁盘上的综合缓存机制。 作为基础类库 [URL 加载系统](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i) 的一部分，任何通过 `NSURLConnection` 加载的请求都将被 `NSURLCache` 处理。

网络缓存减少了需要向服务器发送请求的次数，同时也提升了离线或在低速网络中使用应用的体验。

当一个请求完成下载来自服务器的回应，一个缓存的回应将在本地保存。下一次同一个请求再发起时，本地保存的回应就会马上返回，不需要连接服务器。`NSURLCache` 会 _自动_ 且 _透明_ 地返回回应。

为了好好利用 `NSURLCache`，你需要初始化并设置一个共享的 URL 缓存。在 iOS 中这项工作需要在 `-application:didFinishLaunchingWithOptions:` 完成，而 Mac OS X 中是在 `–applicationDidFinishLaunching:`：

~~~{objective-c}
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                       diskCapacity:20 * 1024 * 1024
                                                           diskPath:nil];
  [NSURLCache setSharedURLCache:URLCache];
}
~~~

缓存策略由请求（客户端）和回应（服务端）分别指定。理解这些策略以及它们如何相互影响，是为您的应用程序找到最佳行为的关键。

## `NSURLRequestCachePolicy`

`NSURLRequest` 有个 `cachePolicy` 属性，它根据以下常量指定了请求的缓存行为：

- `NSURLRequestUseProtocolCachePolicy`： 对特定的 URL 请求使用网络协议中实现的缓存逻辑。这是默认的策略。
- `NSURLRequestReloadIgnoringLocalCacheData`：数据需要从原始地址加载。不使用现有缓存。
- `NSURLRequestReloadIgnoringLocalAndRemoteCacheData`：不仅忽略本地缓存，同时也忽略代理服务器或其他中间介质目前已有的、协议允许的缓存。
- `NSURLRequestReturnCacheDataElseLoad`：无论缓存是否过期，先使用本地缓存数据。如果缓存中没有请求所对应的数据，那么从原始地址加载数据。
- `NSURLRequestReturnCacheDataDontLoad`：无论缓存是否过期，先使用本地缓存数据。如果缓存中没有请求所对应的数据，那么放弃从原始地址加载数据，请求视为失败（即：“离线”模式）。
- `NSURLRequestReloadRevalidatingCacheData`：从原始地址确认缓存数据的合法性后，缓存数据就可以使用，否则从原始地址加载。

你并不会惊奇于这些值不被透彻理解且经常搞混淆。

`NSURLRequestReloadIgnoringLocalAndRemoteCacheData` 和 `NSURLRequestReloadRevalidatingCacheData` [_根本没有实现_](https://gist.github.com/mattt/4753073#file-nsurlrequest-h-L95-L108)（[Link to Radar](http://openradar.appspot.com/radar?id=1755401)）更加加深了混乱程度！

关于`NSURLRequestCachePolicy`，以下才是你 _实际_ 需要了解的东西：

<table>
  <thead>
    <tr>
      <th>常量</th>
      <th>意义</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>UseProtocolCachePolicy</tt></td>
      <td>默认行为</td>
    </tr>
    <tr>
      <td><tt>ReloadIgnoringLocalCacheData</tt></td>
      <td>不使用缓存</td>
    </tr>
    <tr>
      <td><del><tt>ReloadIgnoringLocalAndRemoteCacheData</tt></del></td>
      <td><del>我是认真地，不使用任何缓存</del></td>
    </tr>
    <tr>
      <td><tt>ReturnCacheDataElseLoad</tt></td>
      <td>使用缓存（不管它是否过期），如果缓存中没有，那从网络加载吧</td>
    </tr>
    <tr>
      <td><tt>ReturnCacheDataDontLoad</tt></td>
      <td>离线模式：使用缓存（不管它是否过期），但是<em>不</em>从网络加载</td>
    </tr>
    <tr>
      <td><del><tt>ReloadRevalidatingCacheData</tt></del></td>
      <td><del>在使用前去服务器验证</del></td>
    </tr>
  </tbody>
</table>

## HTTP 缓存语义

因为 `NSURLConnection` 被设计成支持多种协议——包括 `FTP`、`HTTP`、`HTTPS`——所以 URL 加载系统用一种协议无关的方式指定缓存。为了本文的目的，缓存用术语 HTTP 语义来解释。

HTTP 请求和回应用 [headers](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) 来交换元数据，如字符编码、MIME 类型和缓存指令等。

### Request Cache Headers

在默认情况下，`NSURLRequest` 会用当前时间决定是否返回缓存的数据。为了更精确地控制，允许使用以下请求头：

* `If-Modified-Since` - 这个请求头与 `Last-Modified` 回应头相对应。把这个值设为同一终端最后一次请求时返回的 `Last-Modified` 字段的值。
* `If-None-Match` - 这个请求头与与 `Etag` 回应头相对应。使用同一终端最后一次请求的 `Etag` 值。

### Response Cache Headers

`NSHTTPURLResponse` 包含多个 HTTP 头，当然也包括以下指令来说明回应应当如何缓存：

* `Cache-Control` - 这个头必须由服务器端指定以开启客户端的 HTTP 缓存功能。这个头的值可能包含 `max-age`（缓存多久），是公共 `public` 还是私有 `private`，或者不缓存 `no-cache` 等信息。详情请参阅 [`Cache-Control` section of RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9)。

除了 `Cache-Control` 以外，服务器也可能发送一些附加的头用于根据需要有条件地请求（如上一节所提到的）：

* `Last-Modified` - 这个头的值表明所请求的资源上次修改的时间。例如，一个客户端请求最近照片的时间线，`/photos/timeline`，`Last-Modified` 的值可以是最近一张照片的拍摄时间。
* `Etag` - 这是 “entity tag” 的缩写，它是一个表示所请求资源的内容的标识符。在实践中，`Etag` 的值可以是类似于资源的 [`MD5`](http://en.wikipedia.org/wiki/MD5) 之类的东西。这对于那些动态生成的、可能没有明显的 `Last-Modified` 值的资源非常有用。

## `NSURLConnectionDelegate`

一旦收到了服务器的回应，`NSURLConnection` 的代理就有机会在 `-connection:willCacheResponse:` 中指定缓存数据。

`NSCachedURLResponse` 是个包含 `NSURLResponse` 以及它对应的缓存中的 `NSData` 的类。

在 `-connection:willCacheResponse:` 中，`cachedResponse` 对象会根据 URL 连接返回的结果自动创建。因为 `NSCachedURLResponse` 没有可变部分，为了改变 `cachedResponse` 中的值必须构造一个新的对象，把改变过的值传入 `–initWithResponse:data:userInfo:storagePolicy:`，例如：

~~~{objective-c}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSMutableDictionary *mutableUserInfo = [[cachedResponse userInfo] mutableCopy];
    NSMutableData *mutableData = [[cachedResponse data] mutableCopy];
    NSURLCacheStoragePolicy storagePolicy = NSURLCacheStorageAllowedInMemoryOnly;

    // ...

    return [[NSCachedURLResponse alloc] initWithResponse:[cachedResponse response]
                                                    data:mutableData
                                                userInfo:mutableUserInfo
                                           storagePolicy:storagePolicy];
}
~~~

如果 `-connection:willCacheResponse:` 返回 `nil`，回应将不会缓存。

~~~{objective-c}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}
~~~

如果不实现此方法，`NSURLConnection` 就简单地使用本来要传入 `-connection:willCacheResponse:` 的那个缓存对象，所以除非你需要改变一些值或者阻止缓存，否则这个代理方法不必实现。

## 注意事项

正如它那个毫无关系但是名字相近的小伙伴 [`NSCache`](http://nshipster.cn/nscache/) 一样，`NSURLCache` 也是有一些特别的。

在 iOS 5，磁盘缓存开始支持，但仅支持 HTTP，非 HTTPS（iOS 6 中增加了此支持）。Peter Steinberger [关于这个主题写了一篇优秀的文章](http://petersteinberger.com/blog/2012/nsurlcache-uses-a-disk-cache-as-of-ios5/)，在深入研究内部细节后实现[他自己的 NSURLCache 子类](https://github.com/steipete/SDURLCache)。

[Daniel Pasco 在 Black Pixel 上的另一篇文章](http://blackpixel.com/blog/2012/05/caching-and-nsurlconnection.html) 描述了一些与服务器通信时不设置缓存头的意外的默认行为。

---

`NSURLCache` 提醒着我们熟悉我们正在操作的系统是多么地重要。开发 iOS 或 Mac OS X 程序时，这些系统中的重中之重，非 [URL Loading System](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i)莫属。

无数开发者尝试自己做一个简陋而脆弱的系统来实现网络缓存的功能，殊不知 `NSURLCache` 只要两行代码就能搞定且好上100倍。甚至更多开发者根本不知道网络缓存的好处，也从未尝试过，导致他们的应用向服务器作了无数不必要的网络请求。

所以如果你想看到世界的变化，你想确保你有程序总以正确的方式开启，在 `-application:didFinishLaunchingWithOptions:` 设置一个共享的 `NSURLCache` 吧。
