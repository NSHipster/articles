---
layout: post
title: NSURLProtocol

ref: "https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURLProtocol_Class/Reference/Reference.html"
framework: Foundation
rating: 7.4
published: true

description: Foundation库的URL加载系统是每个iOS工程师应该熟练掌握的。而在Foundation库中所有与网络相关的类和接口中，NSURLProtocol或许是最黑科技的了。
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

## Subclassing NSURLProtocol

As mentioned previously, `NSURLProtocol` is an abstract class, which means it will be subclassed rather than used directly.

### Determining if a Subclass Can Handle a Request

The first task of an `NSURLProtocol` subclass is to define what requests to handle. For example, if you want to serve bundle resources when available, it would only want to respond to requests that matched the name of an existing resource.

This logic is specified in `+canInitWithRequest:`. If `YES`, the specified request is handled. If `NO`, it's passed down the line to the next URL Protocol.

### Providing a Canonical Version of a Request

If you wanted to modify a request in any particular way, `+canonicalRequestForRequest:` is your opportunity. It's up to each subclass to determine what "canonical" means, but the gist is that a protocol should ensure that a request has only one canonical form (although many different requests may normalize into the same canonical form).

### Getting and Setting Properties on Requests

`NSURLProtocol` provides methods that allow you to add, retrieve, and remove arbitrary metadata to a request object--without the need for a private category or swizzling:

- `+propertyForKey:inRequest:`
- `+setProperty:forKey:inRequest:`
- `+removePropertyForKey:inRequest:`

This is especially important for subclasses created to interact with protocols that have information not already provided by `NSURLRequest`. It can also be useful as a way to pass state between other methods in your implementation.

### Loading Requests

The most important methods in your subclass are `-startLoading` and `-stopLoading`. What goes into either of these methods is entirely dependent on what your subclass is trying to accomplish, but there is one commonality: communicating with the protocol client.

Each instance of a `NSURLProtocol` subclass has a `client` property, which is the object that is communicating with the URL Loading system. It's not `NSURLConnection`, but the object does conform to a protocol that should look familiar to anyone who has implemented `NSURLConnectionDelegate`

#### `<NSURLProtocolClient>`

* `-URLProtocol:cachedResponseIsValid:`
* `-URLProtocol:didCancelAuthenticationChallenge:`
* `-URLProtocol:didFailWithError:`
* `-URLProtocol:didLoadData:`
* `-URLProtocol:didReceiveAuthenticationChallenge:`
* `-URLProtocol:didReceiveResponse:cacheStoragePolicy:`
* `-URLProtocol:wasRedirectedToRequest:redirectResponse:`
* `-URLProtocolDidFinishLoading:`

In your implementation of `-startLoading` and `-stopLoading`, you will need to send each delegate method to your `client` when appropriate. For something simple, this may mean sending several in rapid succession, but it's important nonetheless.

### Registering the Subclass with the URL Loading System

Finally, in order to actually use an `NSURLProtocol` subclass, it needs to be registered into the URL Loading System.

When a request is loaded, each registered protocol is asked "hey, can you handle this request?". The first one to respond with `YES` with `+canInitWithRequest:` gets to handle the request. URL protocols are consulted in reverse order of when they were registered, so by calling `[NSURLProtocol registerClass:[MyURLProtocol class]];` in `-application:didFinishLoadingWithOptions:`, your protocol will have priority over any of the built-in protocols.

---

Like the URL Loading System that contains it, `NSURLProtocol` is incredibly powerful, and can be used in exceedingly clever ways. As a relatively obscure class, we've only just started to mine its potential for how we can use it to make our code cleaner, faster, and more robust.

So go forth and hack! I can't wait to see what y'all come up with!
