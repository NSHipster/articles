---
layout: post
title: NSURLProtocol
ref: "https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURLProtocol_Class/Reference/Reference.html"
category: Foundation
rating: 7.4
published: true
description: Foundation库的URL加载系统是每个iOS工程师应该熟练掌握的。而在Foundation库中所有与网络相关的类和接口中，NSURLProtocol或许是最黑科技的了。
translator: "Croath Liu"
---

iOS根本离不开网络——不论是从服务端读写数据、向系统分发计算任务，还是从云端加载图片、音频、视频等。

正因如此，Foundation库的[URL加载系统](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i)是每个iOS工程师应该熟练掌握的。

当应用程序面临处理问题的抉择时，通常会选择最高级别的框架来解决这个问题。所以如果给定的任务是通过`http://`, `https://` 或 `ftp://`进行通讯，那么与 `NSURLConnection` 相关的方法就是最好的选择了。苹果关于网络的类涵盖甚广，包括从URL加载、还存管理到认证与存储cookie等多个领域，完全可以满足现代Objective-C应用开发的需要：

<figure id="url-loading-system">
  <figcaption>URL加载系统</figcaption>
  <table>
    <thead>
      <tr>
        <td colspan="2"><strong>URL加载</strong></td>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td colspan="2">NSURLConnection</td>
      </tr>
      <tr>
        <td>NSURLRequest</td>
        <td>NSMutableURLRequest</td>
      </tr>
      <tr>
        <td>NSURLResponse</td>
        <td>NSHTTPURLResponse</td>
      </tr>
    </tbody>
    <thead>
      <tr>
        <td colspan="2"><strong>缓存管理</strong></td>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td colspan="2">NSURLCache</td>
      </tr>
      <tr>
        <td colspan="2">NSCacheURLRequest</td>
      </tr>
      <tr>
        <td colspan="2">NSCachedURLResponse</td>
      </tr>
    </tbody>
    <thead>
      <tr>
        <td colspan="2"><strong>认证 &amp; 证书</strong></td>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td colspan="2">NSURLCredential</td>
      </tr>
      <tr>
        <td colspan="2">NSURLCredentialStorage</td>
      </tr>
      <tr>
        <td colspan="2">NSURLAuthenticationChallenge</td>
      </tr>
      <tr>
        <td colspan="2">NSURLProtectionSpace</td>
      </tr>
    </tbody>
    <thead>
      <tr>
        <td colspan="2"><strong>Cookie存储</strong></td>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td colspan="2">NSHTTPCookie</td>
      </tr>
      <tr>
        <td colspan="2">NSHTTPCookieStorage</td>
      </tr>
    </tbody>
    <thead>
      <tr>
        <td colspan="2"><strong>协议支持</strong></td>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td colspan="2">NSURLProtocol</td>
      </tr>
    </tbody>
  </table>
</figure>

虽然URL加载系统包含的内容众多，但代码的设计上却非常良好，没有把复杂的操作暴露出来，开发者只需要在用到的时候进行设置。任何通过 `NSURLConnection` 进行的请求都会被系统的其他部分所拦截，这也使得当可用时显式地从硬盘加载缓存成为了可能。

说到这里，我们进入了本周的正题：`NSURLProtocol`。

---

`NSURLProtocol` 或许是URL加载系统中最功能强大但同时也是最晦涩的部分了。它是一个抽象类，你可以通过子类化来定义新的或已经存在的URL加载行为。

听了我说了这些乱七八糟的如果你还没有抓狂，这里有一些关于_希望加载请求时不用改变其他部分代码_的例子，供你参考：

- [拦截图片加载请求，转为从本地文件加载](http://stackoverflow.com/questions/5572258/ios-webview-remote-html-with-local-image-files)
- [为了测试对HTTP返回内容进行mock和stub](http://www.infinite-loop.dk/blog/2011/09/using-nsurlprotocol-for-injecting-test-data/)
- 对发出请求的header进行格式化
- 对发出的媒体请求进行签名
- 创建本地代理服务，用于数据变化时对URL请求的更改
- 故意制造畸形或非法返回数据来测试程序的鲁棒性
- 过滤请求和返回中的敏感信息
- 在既有协议基础上完成对 `NSURLConnection` 的实现且与原逻辑不产生矛盾

再次强调 `NSURLProtocol` 核心思想最重要的一点：用了它，你不必改动应用在网络调用上的其他部分，就可以改变URL加载行为的全部细节。

或者这么说吧： `NSURLProtocol` 就是一个苹果允许的中间人攻击。

## 子类化NSURLProtocol

之前提到过 `NSURLProtocol` 是一个抽象类，所以不能够直接使用必须被子类化之后才能使用。

### 让子类识别并控制请求

子类化 `NSURLProtocol` 的第一个任务就是告诉它要控制什么类型的网络请求。比如说如果你想要当本地有资源的时候请求直接使用本地资源文件，那么相关的请求应该对应已有资源的文件名。

这部分逻辑定义在 `+canInitWithRequest:` 中，如果返回 `YES`，该请求就会被其控制。返回 `NO` 则直接跳入下一Protocol。

### 提供请求规范

如果你想要用特定的某个方式来修改一个请求，应该使用 `+canonicalRequestForRequest:` 方法。每一个subclass都应该依据某一个规范，也就是说，一个protocol应该保证只有唯一的规范格式（虽然很多不同的请求可能是同一种规范格式）。

### 获取和设置请求的属性

`NSURLProtocol` 提供方法允许你来添加、获取、删除一个request对象的任意metadata，而且不需要私有扩展或者方法欺骗(swizzle)：

- `+propertyForKey:inRequest:`
- `+setProperty:forKey:inRequest:`
- `+removePropertyForKey:inRequest:`

在操作protocol时对尚未赋予特定信息的 `NSURLRequest` 进行操作时，上述方法都是特别重要的。这些对于和其他方法之间的状态传递也非常有用。

### 加载请求

你的子类中最重要的方法就是 `-startLoading` 和 `-stopLoading`。不同的自定义子类在调用这两个方法是会传入不同的内容，但共同点都是要围绕protocol客户端进行操作。

每个 `NSURLProtocol` 的子类实例都有一个 `client` 属性，该属性对URL加载系统进行相关操作。它不是 `NSURLConnection`，但看起来和一个实现了 `NSURLConnectionDelegate` 协议的对象非常相似。

#### `<NSURLProtocolClient>`

* `-URLProtocol:cachedResponseIsValid:`
* `-URLProtocol:didCancelAuthenticationChallenge:`
* `-URLProtocol:didFailWithError:`
* `-URLProtocol:didLoadData:`
* `-URLProtocol:didReceiveAuthenticationChallenge:`
* `-URLProtocol:didReceiveResponse:cacheStoragePolicy:`
* `-URLProtocol:wasRedirectedToRequest:redirectResponse:`
* `-URLProtocolDidFinishLoading:`

在对 `-startLoading` 和 `-stopLoading` 的实现中，你需要在恰当的时候让 `client` 调用每一个delegate方法。简单来说就是连续调用那些方法，不过这是至关重要的。

### 向URL加载系统注册子类

最后，为了使用 `NSURLProtocol` 子类，需要向URL加载系统进行注册。

当请求被加载时，系统会向每一个注册过的protocol询问：“Hey你能控制这个请求吗？”第一个通过 `+canInitWithRequest:` 回答为 `YES` 的protocol就会控制该请求。URL protocol会被以注册顺序的反序访问，所以当在 `-application:didFinishLoadingWithOptions:` 方法中调用 `[NSURLProtocol registerClass:[MyURLProtocol class]];` 时，你自己写的protocol比其他内建的protocol拥有更高的优先级。

---

就像控制请求的URL加载系统一样， `NSURLProtocol` 也一样的无比强大，可以通过各种灵活的方式使用。它作为一个相对晦涩难解的类，我们挖掘出了它的潜力来让我们的代码更清爽健壮。

所以开始hack吧！我已经等不及看你们用它做出什么有趣的事情了！
