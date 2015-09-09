---
title: AFNetworking 2.0
author: Mattt Thompson
category: Open Source
excerpt: "AFNetworking is one of the most widely used open source projects for iOS and OS X development. It's about as mainstream as it gets. But have you heard about the sequel?"
status:
    swift: n/a
---

[AFNetworking](http://afnetworking.com) is one of the most widely used open source projects for iOS and OS X development. It powers thousands of popular and critically acclaimed apps, and serves as the foundation for dozens of other great open source libraries and frameworks. With thousands of stars and forks, and hundreds of contributors, the project is also among the most active and influential in the community.

By all accounts, AFNetworking is about as mainstream as it gets.

_But have you heard about the sequel?_
[AFNetworking 2.0](https://github.com/AFNetworking/AFNetworking/).

This week on NSHipster: an exclusive look at the future of AFNetworking.

> Full Disclosure: NSHipster is written by the [author of AFNetworking](https://twitter.com/mattt), so this is anything but an objective account of AFNetworking or its merits. What you're getting is the personal, honest take of AFNetworking in its current and forthcoming releases.

## AFNetworking's Big Ideas

Started in May 2011 as a humble extension of an [Apple code sample](https://developer.apple.com/library/ios/samplecode/mvcnetworking/Introduction/Intro.html) from a [doomed location-based social network](http://en.wikipedia.org/wiki/Gowalla), AFNetworking's success was a product of timing more than anything. At a time when [ASIHTTPRequest](https://github.com/pokeb/asi-http-request) was the de facto networking solution, AFNetworking's core ideas caught on among developers looking for a more modern solution.

### NSURLConnection + NSOperation

`NSURLConnection` is the backbone of the Foundation URL Loading system. An `NSURLConnection` loads an `NSURLRequest` object asynchronously, calling methods on its delegates as the `NSURLResponse` / `NSHTTPURLResponse` and its associated `NSData` is sent to and loaded from the server; the delegate may also implement behavior for handling an `NSURLAuthenticationChallenge`, a redirect responses, or determine how the associated `NSCachedURLResponse` is stored to the shared `NSURLCache`.

[`NSOperation`](http://nshipster.com/nsoperation) is an abstract class that models a single unit of computation, with useful constructs like state, priority, dependencies, and cancellation.

The first major breakthrough of AFNetworking was combining the two. `AFURLConnectionOperation`, an `NSOperation` subclass conforms to `NSURLConnectionDelegate` methods, and tracks the state of the request from start to finish, while storing intermediary state, such as request, response, and response data.

### Blocks

iOS 4 radically improved the process of developing apps with its introduction of blocks and Grand Central Dispatch. Instead of scattering implementation logic across your application with delegates, developers could localize related functionality in block properties. Rather than struggle with a miasma of threads, invocations, and operation queues, GCD could dispatch work back and forth with ease.

What's more, `NSURLConnectionDelegate` methods could be customized for each request operation by setting a corresponding block property (e.g. `setWillSendRequestForAuthenticationChallengeBlock:` to override the default implementation of `connection:willSendRequestForAuthenticationChallenge:`)

Now, an `AFURLConnectionOperation` could be created and scheduled on an `NSOperationQueue`, with behavior specified on what to do with the response and response data (or any error encountered during the request lifecyle) when finished by setting the new `completionBlock` property on `NSOperation`.

### Serialization & Validation

Going even further, request operations could have their responsibilities extended to validate HTTP status codes and content type to validate the server response, and, for instance, serialize `NSData` into JSON objects for responses with an `application/json` MIME type.

Loading JSON, XML, property lists, or images from the server was abstracted to more closely resemble a latent file loading operation, such that a developer could think in terms of promises rather than asynchronous networking.

## Introducing AFNetworking 2.0

In many ways, AFNetworking succeeded in striking a balance between ease-of-use and extensibility. That's not to say that there wasn't room for improvement.

With its second major release, AFNetworking aims to reconcile many of the quirks of the original design, while adding powerful new constructs to power the next generation of iOS and OS X apps.

### Motivations

- **NSURLSession Compatibility** - `NSURLSession` is a replacement for `NSURLConnection` introduced in iOS 7. `NSURLConnection` isn't deprecated, and likely won't be for some time, but `NSURLSession` is the future of networking in Foundation, and it's a bright future at that, addressing many of the shortcomings of its predecessor. (See WWDC 2013 Session 705 "What’s New in Foundation Networking" for a good overview). Some had initially speculated that `NSURLSession` would obviate the need for AFNetworking; although there is overlap, there is still much that a higher-level abstraction can provide. __AFNetworking 2.0 does just this, embracing and extending `NSURLSession` to pave over some of the rough spots, and maximize its usefulness.__
- **Modularity** - One of the major criticisms of AFNetworking is how bulky it is. Although its architecture lent itself well to modularity on a class level, its packaging didn't allow for individual features to be selected à la carte. Over time, `AFHTTPClient` in particular became overburdened in its responsibilities (creating requests, serializing query string parameters, determining response parsing behavior, creating and managing operations, monitoring network reachability). __In AFNetworking 2.0, you can pick and choose only the components you need using [CocoaPods subspecs](https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format#subspecs).__

### Meet the Cast

#### `NSURLConnection` Components _(iOS 6 & 7)_

- `AFURLConnectionOperation` - A subclass of `NSOperation` that manages an `NSURLConnection` and implements its delegate methods.
- `AFHTTPRequestOperation` - A subclass of `AFURLConnectionOperation` specifically for making HTTP requests, which creates a distinction between acceptable and unacceptable status codes and content types. The main difference in 2.0 is that _you'll actually use this class directly, rather than subclass it_, for reasons explained in the "Serialization" section.
- `AFHTTPRequestOperationManager` - A class that encapsulates the common patterns of communicating with a web service over HTTP, backed by `NSURLConnection` by way of `AFHTTPRequestOperation`.

#### `NSURLSession` Components _(iOS 7)_

- `AFURLSessionManager` - A class that creates and manages an `NSURLSession` object based on a specified `NSURLSessionConfiguration` object, as well as data, download, and upload tasks for that session, implementing the delegate methods for both the session and its associated tasks. Because of the odd gaps in `NSURLSession`'s API design, __any code working with `NSURLSession` would be improved by `AFURLSessionManager`__.
- `AFHTTPSessionManager` - A subclass of `AFURLSessionManager` that encapsulates the common patterns of communicating with an web service over HTTP, backed by `NSURLSession` by way of `AFURLSessionManager`.

---

> **So to recap**: in order to support the new `NSURLSession` APIs as well as the old-but-not-deprecated-and-still-useful `NSURLConnection`, the core components of AFNetworking 2.0 are split between request operation and session tasks. `AFHTTPRequestOperationManager` and `AFHTTPSessionManager` provide similar functionality, with nearly interchangeable interfaces that can be swapped out rather easily, should the need arise (such as porting between iOS 6 and 7).

> All of the other functionality previous tied up in `AFHTTPClient`, such as serialization, security, and reachability, has been split out across several modules that are shared between `NSURLSession` and `NSURLConnection`-backed APIs.

---

#### Serialization

One of the breakthroughs of AFNetworking 2.0's new architecture is use of serializers for creating requests and parsing responses. The flexible design of serializers allows for more business logic to be transferred over to the networking layer, and for previously built-in default behavior to be easily customized.

- `<AFURLRequestSerializer>` - Objects conforming to this protocol are used to decorate requests by translating parameters into either a query string or entity body representation, as well as setting any necessary headers. Anyone who had beef about the way `AFHTTPClient` encoded query string parameters should find this new approach to be more to your liking.
- `<AFURLResponseSerializer>` - Objects conforming to this protocol are responsible for validating and serializing a response and its associated data into useful representations, such as JSON objects, images, or even [Mantle](https://github.com/blog/1299-mantle-a-model-framework-for-objective-c)-backed model objects. Rather than endlessly subclassing `AFHTTPClient`, `AFHTTPRequestOperation` now has a single `responseSerializer` property, which is set to the appropriate handler. Likewise, the [`NSURLProtocol`-inspired request operation class registration nonsense](http://cocoadocs.org/docsets/AFNetworking/1.3.1/Classes/AFHTTPClient.html#//api/name/registerHTTPOperationClass:) is no more—replaced by that single delightful `responseSerializer` property. Thank goodness.

#### Security

Thanks to the contributions of [Dustin Barker](https://github.com/dstnbrkr), [Oliver Letterer](https://github.com/OliverLetterer), and [Kevin Harwood](https://github.com/kcharwood) and others, AFNetworking comes with built-in support for [SSL pinning](http://blog.lumberlabs.com/2012/04/why-app-developers-should-care-about.html), which is critical for apps that deal with sensitive information.

- `AFSecurityPolicy` - A class that evaluates the server trust of secure connections against its specified pinned certificates or public keys. tl;dr Add your server certificate to your app bundle to help prevent against [man-in-the-middle attacks](http://en.wikipedia.org/wiki/Man-in-the-middle_attack).

#### Reachability

Another piece of functionality now decoupled from `AFHTTPClient` is network reachability. Now you can use it on its own, or as a property on `AFHTTPRequestOperationManager` / `AFHTTPSessionManager`.

- `AFNetworkReachabilityManager` - This class monitors current network reachability, providing callback blocks and notifications for when reachability changes.

#### Real-time

- `AFEventSource` - An Objective-C implementation of the [`EventSource` DOM API](http://en.wikipedia.org/wiki/Server-sent_events). A persistent HTTP connection is opened to a host, which streams events to the event source, to be dispatched to listeners. Messages streamed to the event source formatted as [JSON Patch](http://tools.ietf.org/html/rfc6902) documents are translated into arrays of `AFJSONPatchOperation` objects. These patch operations can be applied to the persistent data set fetched from the server.

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

All of the UIKit categories in AFNetworking 2.0 have been extracted and expanded, with several new additions to the list.

- `AFNetworkActivityIndicatorManager`: Automatically start and stop the network activity indicator in the status bar as request operations and tasks begin and finish loading.
- `UIImageView+AFNetworking`: Adds `imageResponseSerializer` property, which makes it easy to automatically resize or apply a filter to images loaded remotely to an image view. For example, [`AFCoreImageSerializer`](https://github.com/AFNetworking/AFCoreImageSerializer) could be used to apply Core Image filters to the response image before being displayed.
- `UIButton+AFNetworking` *(New)*: Similar to `UIImageView+AFNetworking`, loads `image` and `backgroundImage` from remote source.
- `UIActivityIndicatorView+AFNetworking` *(New)*: Automatically start and stop a `UIActivityIndicatorView` according to the state of a specified request operation or session task.
- `UIProgressView+AFNetworking` *(New)*: Automatically track the upload or download progress of a specified request operation or session task.
- `UIWebView+AFNetworking` *(New)*: Provides a more sophisticated API for loading URL requests, with support for progress callbacks and content transformation.

---

Thus concludes our whirlwind tour of AFNetworking 2.0. New features for the next generation of apps, combined with a fresh new architecture for all of the existing functionality. There's a lot to be excited about.

### Hit the Ground Running

You can start playing around with AFNetworking 2.0 by putting the following in your [`Podfile`](http://cocoapods.org):

~~~{ruby}
platform :ios, '7.0'
pod "AFNetworking", "2.5.0"
~~~

For anyone coming over to AFNetworking from the current 1.x release, you may find [the AFNetworking 2.0 Migration Guide](https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-2.0-Migration-Guide) especially useful.
