---
title: NSURLCache
author: Mattt Thompson
category: Cocoa
excerpt: "NSURLCache provides a composite in-memory and on-disk caching mechanism for URL requests to your application. As part of Foundation's URL Loading System, any request loaded through NSURLConnection will be handled by NSURLCache."
status:
    swift: 1.1
---

`NSURLCache` provides a composite in-memory and on-disk caching mechanism for URL requests to your application. As part of Foundation's [URL Loading System](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i), any request loaded through `NSURLConnection` will be handled by `NSURLCache`.

Network caching reduces the number of requests that need to be made to the server, and improve the experience of using an application offline or under slow network conditions.

When a request has finished loading its response from the server, a cached response will be saved locally. The next time the same request is made, the locally-cached response will be returned immediately, without connecting to the server. `NSURLCache` returns the cached response _automatically_ and _transparently_.

As of iOS 5, a shared `NSURLCache` is set for the application by default. [Quoth the docs](https://developer.apple.com/library/ios/documentation/cocoa/Reference/Foundation/Classes/NSURLCache_Class/Reference/Reference.html#//apple_ref/occ/clm/NSURLCache/setSharedURLCache:):

> Applications that do not have special caching requirements or constraints should find the default shared cache instance acceptable. An application with more specific needs can create a custom NSURLCache object and set it as the shared cache instance using setSharedURLCache:. The application should do so before any calls to this method.

Those having such special caching requirements can set a shared URL cache in `-application:didFinishLaunchingWithOptions:` on iOS, or  `–applicationDidFinishLaunching:` on OS X:

~~~{swift}
func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
    NSURLCache.setSharedURLCache(URLCache)

    return true
}
~~~

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

Caching policies are specified in both the request (by the client) and in the response (by the server). Understanding these policies and how they relate to one another is essential to finding the optimal behavior for your application.

## `NSURLRequestCachePolicy`

`NSURLRequest` has a `cachePolicy` property, which specifies the caching behavior of the request according to the following constants:

- `NSURLRequestUseProtocolCachePolicy`: Caching logic defined in the protocol implementation is used for a particular URL load request. This is the default policy.
- `NSURLRequestReloadIgnoringLocalCacheData`: Data should be loaded from the originating source. No existing cache data should be used.
- `NSURLRequestReloadIgnoringLocalAndRemoteCacheData`: Not only should the local cache data be ignored, but proxies and other intermediates should be instructed to disregard their caches so far as the protocol allows.
- `NSURLRequestReturnCacheDataElseLoad`: Existing cached data should be used, regardless of its age or expiration date. If there is no existing data in the cache corresponding to the request, the data is loaded from the originating source.
- `NSURLRequestReturnCacheDataDontLoad`: Existing cache data should be used, regardless of its age or expiration date. If there is no existing data in the cache corresponding to the request, no attempt is made to load the data from the originating source, and the load is considered to have failed, (i.e. "offline" mode).
- `NSURLRequestReloadRevalidatingCacheData`: Existing cache data may be used provided the origin source confirms its validity, otherwise the URL is loaded from the origin source.

It may not surprise you that these values are poorly understood and often confused with one another.

Adding to the confusion is the fact that `NSURLRequestReloadIgnoringLocalAndRemoteCacheData` and `NSURLRequestReloadRevalidatingCacheData` [_aren't even implemented_](https://gist.github.com/mattt/4753073#file-nsurlrequest-h-L95-L108)! ([Link to Radar](http://openradar.appspot.com/radar?id=1755401)).

So here's what you _actually_ need to know about `NSURLRequestCachePolicy`:

<table>
  <thead>
    <tr>
      <th>Constant</th>
      <th>Meaning</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>UseProtocolCachePolicy</tt></td>
      <td>Default behavior</td>
    </tr>
    <tr>
      <td><tt>ReloadIgnoringLocalCacheData</tt></td>
      <td>Don't use the cache</td>
    </tr>
    <tr>
      <td><del><tt>ReloadIgnoringLocalAndRemoteCacheData</tt></del></td>
      <td><del>Seriously, don't use the cache</del></td>
    </tr>
    <tr>
      <td><tt>ReturnCacheDataElseLoad</tt></td>
      <td>Use the cache (no matter how out of date), or if no cached response exists, load from the network</td>
    </tr>
    <tr>
      <td><tt>ReturnCacheDataDontLoad</tt></td>
      <td>Offline mode: use the cache (no matter how out of date), but <em>don't</em> load from the network</td>
    </tr>
    <tr>
      <td><del><tt>ReloadRevalidatingCacheData</tt></del></td>
      <td><del>Validate cache against server before using</del></td>
    </tr>
  </tbody>
</table>

## HTTP Cache Semantics

Because `NSURLConnection` is designed to support multiple protocols—including both `FTP` and `HTTP`/`HTTPS`—the URL Loading System APIs specify caching in a protocol-agnostic fashion. For the purposes of this article, caching will be explained in terms of HTTP semantics.

HTTP requests and responses use [headers](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) to communicate metadata such as character encoding, MIME type, and caching directives.

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

~~~{swift}
// MARK: NSURLConnectionDataDelegate

func connection(connection: NSURLConnection!, willCacheResponse cachedResponse: NSCachedURLResponse!) -> NSCachedURLResponse! {
    var mutableUserInfo = NSMutableDictionary(dictionary: cachedResponse.userInfo)
    var mutableData = NSMutableData(data: cachedResponse.data)
    var storagePolicy: NSURLCacheStoragePolicy = .AllowedInMemoryOnly

    // ...

    return NSCachedURLResponse(response: cachedResponse.response, data: mutableData, userInfo: mutableUserInfo, storagePolicy: storagePolicy)
}
~~~

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

~~~{swift}
func connection(connection: NSURLConnection!, willCacheResponse cachedResponse: NSCachedURLResponse!) -> NSCachedURLResponse! {
    return nil
}
~~~

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

`NSURLCache` reminds us of how important it is to be familiar with the systems we interact with. Chief among them when developing for iOS or OS X is, of course, the [URL Loading System](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i).

Untold numbers of developers have hacked together an awkward, fragile system for network caching functionality, all because they weren't aware that `NSURLCache` could be setup in two lines and do it 100× better. Even more developers have never known the benefits of network caching, and never attempted a solution, causing their apps to make untold numbers of unnecessary requests to the server.

So be the change you want to see in the world, and be sure to always start you app on the right foot, by setting a shared `NSURLCache` in `-application:didFinishLaunchingWithOptions:`.
