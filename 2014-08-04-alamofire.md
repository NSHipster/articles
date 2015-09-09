---
title: Alamofire
author: Mattt Thompson
category: Open Source
excerpt: "Although we still have a few months to wait before we can ship apps in Swift, there is already a proliferation of open source projects built with this new language. One such project is Alamofire."
status:
    swift: 1.1
---

Swift has hit a reset button on the iOS developer community. It's really been something to behold for seasoned Objective-C developers.

Literally overnight, conversations shifted from [namespacing](http://nshipster.com/namespacing/) and [swizzling](http://nshipster.com/method-swizzling/) to [generics](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Generics.html#//apple_ref/doc/uid/TP40014097-CH26-XID_272) and [type inference](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/TypeCasting.html#//apple_ref/doc/uid/TP40014097-CH22-XID_487). At a time of the year when Twitter would normally be abuzz with discussion about the latest APIs or speculation about upcoming hardware announcements, the discourse has been dominated by all things Swift.

A new language with new syntax and evolving conventions, Swift has captured the attention and imagination of iOS & OS X developers both old and new.

Although we still have a few months to wait before we can ship apps in Swift, there is already a proliferation of open source projects built with this new language.

One such project is [Alamofire](https://github.com/Alamofire/Alamofire). This week, we'll take a look at the design and implementation of Alamofire, and how it's using the language features of Swift to those ends.

> Full Disclosure: this article, as with the rest of NSHipster, is written by the creator of AFNetworking and Alamofire. While this makes me qualified to write about the technical details and direction of these projects, it certainly doesn't allow for an objective take on their relative merits. So take all of this with a grain of salt.

* * *

[Alamofire](https://github.com/Alamofire/Alamofire) is an HTTP networking library written in Swift. It leverages NSURLSession and the Foundation URL Loading System to provide first-class networking capabilities in a convenient Swift interface.

Getting started with Alamofire is easy. Here's how to make a `GET` request:

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .response { (request, response, data, error) in
                     println(request)
                     println(response)
                     println(error)
                   }
```

`Alamofire.request` is a convenience method that returns an `Alamofire.Request` object, which can be chained to add a response handler with `response`.

By default, `response` returns the accumulated `NSData` of the server response. To get a string representation of this instead, use the `responseString` method instead.

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .responseString { (request, response, string, error) in
             println(string)
         }
```

Similarly, to get a JSON object from the request, use the `responseJSON` method:

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .responseJSON {(request, response, JSON, error) in
             println(JSON)
         }
```

### Chaining

Even minor syntactic differences can have wide-reaching implications for language conventions.

Chief among the complaints lodged against Objective-C was its use of square brackets for denoting [message passing](http://en.wikipedia.org/wiki/Message_passing). One of the practical implications of `[ ]` syntax is the difficulty in chaining methods together. Even with Xcode autocomplete, `@property` dot syntax, and [key-value coding key-paths](http://nshipster.com/kvc-collection-operators/), it is still rare to see deeply nested invocations.

> In many ways, the concession of introducing dot syntax for properties in Objective-C 2.0 only served to escalate tensions further, although conventions have started to solidify in recent years.

In Swift, though, all methods are invoked using dot syntax with ordered and parameterized arguments passed inside parentheses, allowing methods returning `Self` to have successive methods chained together.

Alamofire uses this pattern for succinct, localized networking declarations:

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .authenticate(HTTPBasic: user, password: password)
         .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
             println(totalBytesRead)
         }
         .responseJSON { (request, response, JSON, error) in
             println(JSON)
         }
         .responseString { (request, response, string, error) in
             println(string)
         }
```

> Requests can have multiple response handlers, which each execute asynchronously once the server has finished sending its response.

### Trailing Closures

Closures are deeply integrated into Swift, so much so that if a methods's last argument is a closure type, a trailing closure can be used instead.

The chained methods in the previous example show this in action. For typical usage, it's really convenient to omit the syntactic cruft.

### Optional Arguments &  Flexible Method Signatures

When communicating with web APIs, it's common to send parameters with URL queries or HTTP body data:

```swift
Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
// GET http://httpbin.org/get?foo=bar
```

This is actually the same method as before. By default the `parameters` argument is `nil`. There's a fourth argument, and it's optional as well: the parameter `encoding`.

### ParameterEncoding & Enums

This brings us to one of the cooler features of Swift: enums. Whereas C / Objective-C enums are merely `typedef`'d integer declarations, Swift enums support parameterized arguments and can have associated functionality.

Alamofire encapsulates all of the logic for encoding parameters into an HTTP message representation with the `ParameterEncoding` enum:

```swift
enum ParameterEncoding {
    case URL
    case JSON
    case PropertyList(format: NSPropertyListFormat,
                      options: NSPropertyListWriteOptions)

    func encode(request: NSURLRequest,
                parameters: [String: AnyObject]?) ->
                    (NSURLRequest, NSError?)
    { ... }
}
```

The parameterized arguments of `ParameterEncoding` cases allows for different JSON and Property List serialization options to be specified.

The `encode` method on each `ParameterEncoding` case transforms a request and set of parameters into a new request (with optional error return value).

Given a complex, nested set of parameters, encoding and sending as JSON is recommended:


> There are no standards defining the encoding of data structures into URL-encoded query parameters, meaning that parsing behavior can vary between web application implementations. Even worse, there are certain structures that cannot be unambiguously represented by a query string. This is why JSON (or XML or plist) encoding is recommended for anything more complex than key-value, if the web API supports it.

```swift
let parameters = [
    "foo": "bar",
    "baz": ["a", 1],
    "qux": [
        "x": 1,
        "y": 2,
        "z": 3
    ]
]

Alamofire.request(.POST, "http://httpbin.org/post", parameters: parameters, encoding: .JSON(options: nil))
         .responseJSON {(request, response, JSON, error) in
            println(JSON)
         }
```

Another enum is used in Alamofire to represent the HTTP methods defined in RFC 2616 §9:

```swift
public enum Method: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}
```

These values are passed as the first argument in `request`:

```swift
Alamofire.request(.POST, "http://httpbin.org/get")
```

```swift
Alamofire.request(.POST, "http://httpbin.org/get", parameters: ["foo": "bar"])
```

```swift
Alamofire.request(.POST, "http://httpbin.org/get", parameters: ["foo": "bar"], encoding: .JSON(options: nil))
```

### Lazy Properties

Another new feature of Swift is the ability to lazily evaluate properties. A property with the `lazy` annotation will only evaluate, set, and return the value of an expression after it's called for the first time in code.

An `Alamofire.Manager` object takes advantage of this to defer construction of the default HTTP headers (`Accept-Encoding`, `Accept-Language`, & `User-Agent`) until the first request is constructed:

```swift
lazy var defaultHeaders: [String: String] = {
    // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
    let acceptEncoding: String = "Accept-Encoding: gzip;q=1.0,compress;q=0.5"

    // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
    let acceptLanguage: String = {
        // ...
    }()

    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    let userAgent: String = {
        // ...
    }()

    return ["Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent]
}()
```

### Public Immutable Property Backed By Private Mutable Property

In Objective-C, exposing `readonly`, immutable properties backed by mutable variables in the private implementation required some non-obvious declaration trickery.

With the introduction of access control to Swift in Xcode 6 β4, it's much easier to design a safe, immutable public API:

```swift
private var mutableData: NSMutableData
override var data: NSData! {
    return self.mutableData
}
```

### And Much, Much More...

There's a lot baked into the < 1000 LOC comprising Alamofire. Any aspiring Swift developer or API author would be advised to [peruse through the source code](https://github.com/Alamofire/Alamofire) to get a better sense of what's going on.

* * *

> For anyone wondering where this leaves AFNetworking, don't worry: **AFNetworking is stable and reliable, and isn't going anywhere.** In fact, over the coming months, a great deal of work is going to be put into improving test coverage and documentation for AFNetworking 2 and its first-party extensions.

> It's also important to note that AFNetworking can be easily used from Swift code, just like any other Objective-C code. Alamofire is a separate project investigating the implications of new language features and conventions on the problem of making HTTP requests.

Alamofire 1.0 is scheduled to coincide with the 1.0 release of Swift... whenever that is. Part of that milestone is [complete documentation](http://nshipster.com/swift-documentation/), and 100% Unit Test Coverage, making use of the new [Xcode 6 testing infrastructure](http://nshipster.com/xctestcase/) & [httpbin](http://httpbin.org) by [Kenneth Reitz](http://www.kennethreitz.org).

We're all doing our best to understand how to design, implement, and distribute code in Swift. Alamofire is just one of many exciting new libraries that will guide the development of the language and community in the coming months and years. For anyone interested in being part of this, I welcome your contributions. As the mantra goes: [pull requests welcome](https://github.com/Alamofire/Alamofire/compare/).
