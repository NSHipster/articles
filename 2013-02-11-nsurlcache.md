---
layout: post
title: NSURLCache
translator: Ricky Tan
ref: "https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURLCache_Class/Reference/Reference.html"
framework: Foundation
rating: 8.7
description: "NSURLCache 为您的应用的 URL 请求提供了内存中以及磁盘上的综合缓存机制。作为基础类库 URL 加载系统的一部分，任何通过 NSURLConnection 加载的请求都将被 NSURLCache 处理。"
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

By default, `NSURLRequest` will use the current time to determine whether a cached response should be returned. For more precise cache control, the following headers can be specified:

* `If-Modified-Since` - This request header corresponds to the `Last-Modified` response header. Set the value of this to the `Last-Modified` value received from the last request to the same endpoint.
* `If-None-Match` - This request header corresponds to the `Etag` response header. Use the `Etag` value received previously for the last request to that endpoint.

### Response Cache Headers

An `NSHTTPURLResponse` contains a set of HTTP headers, which can include the following directives for how that response should be cached:

* `Cache-Control` - This header must be present in the response from the server to enable HTTP caching by a client. The value of this header may include information like its `max-age` (how long to cache a response), and whether the response may be cached with `public` or `private` access, or `no-cache` (not at all). See the [`Cache-Control` section of RFC 2616](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9) for full details.

In addition to `Cache-Control`, a server may send additional headers that can be used to conditionally request information as needed (as mentioned in the previous section):

* `Last-Modified` - The value of this header corresponds to the date and time when the requested resource was last changed. For example, if a client requests a timeline of recent photos, `/photos/timeline`, the `Last-Modified`
value could be set to when the most recent photo was taken.
* `Etag` - An abbreviation for "entity tag", this is an identifier that represents the contents requested resource. In practice, an `Etag` header value could be something like the [`MD5`](http://en.wikipedia.org/wiki/MD5) digest of the resource properties. This is particularly useful for dynamically generated resources that may not have an obvious `Last-Modified` value.

## `NSURLConnectionDelegate`

Once the server response has been received, the `NSURLConnection` delegate has an opportunity to specify the cached response in `-connection:willCacheResponse:`.

`NSCachedURLResponse` is a class that contains both an `NSURLResponse` with the cached `NSData` associated with the response.

In `-connection:willCacheResponse:`, the `cachedResponse` object has been automatically created from the result of the URL connection. Because there is no mutable counterpart to `NSCachedURLResponse`, in order to change anything about `cachedResponse`, a new object must be constructed, passing any modified values into `–initWithResponse:data:userInfo:storagePolicy:`, for instance:

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

If `-connection:willCacheResponse:` returns `nil`, the response will not be cached.

~~~{objective-c}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}
~~~

When left unimplemented, `NSURLConnection` will simply use the cached response that would otherwise be passed into `-connection:willCacheResponse:`, so unless you need to change or prevent caching, this method does not need to be implemented in the delegate.

## Caveats

Just like its unrelated-but-similarly-named cohort, [`NSCache`](http://nshipster.com/nscache/), `NSURLCache` is not without some peculiarities.

As of iOS 5, disk caching is supported, but only for HTTP, not HTTPS, requests (though iOS 6 added support for this). Peter Steinberger [wrote an excellent article on this subject](http://petersteinberger.com/blog/2012/nsurlcache-uses-a-disk-cache-as-of-ios5/), after digging into the internals while implementing [his own NSURLCache subclass](https://github.com/steipete/SDURLCache).

[Another article by Daniel Pasco at Black Pixel](http://blackpixel.com/blog/2012/05/caching-and-nsurlconnection.html) describes some unexpected default behavior when communicating with servers that don't set cache headers.

---

`NSURLCache` reminds us of how important it is to be familiar with the systems we interact with. Chief among them when developing for iOS or Mac OS X is, of course, the [URL Loading System](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i).

Untold numbers of developers have hacked together an awkward, fragile system for network caching functionality, all because they weren't aware that `NSURLCache` could be setup in two lines and do it 100× better. Even more developers have never known the benefits of network caching, and never attempted a solution, causing their apps to make untold numbers of unnecessary requests to the server.

So be the change you want to see in the world, and be sure to always start you app on the right foot, by setting a shared `NSURLCache` in `-application:didFinishLaunchingWithOptions:`.
