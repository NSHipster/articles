---
title: Alamofire
author: Mattt Thompson
translator: Chester Liu
category: Open Source
excerpt: "尽管我们离使用 Swift 发布 App 还有几个月的时间，已经有若干使用这门新语言的开源项目开始生根发芽了， Alamofire 便是这些项目中的一个。"
status:
    swift: 1.1
---

Swift has hit a reset button on the iOS developer community. It's really been something to behold for seasoned Objective-C developers.

Swift 像是在 iOS 开发者社区中按下了一个“重启”按钮，成了很多常年使用 Objective-C 的开发者的新宠儿。

Literally overnight, conversations shifted from [namespacing](http://nshipster.com/namespacing/) and [swizzling](http://nshipster.com/method-swizzling/) to [generics](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Generics.html#//apple_ref/doc/uid/TP40014097-CH26-XID_272) and [type inference](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/TypeCasting.html#//apple_ref/doc/uid/TP40014097-CH22-XID_487). At a time of the year when Twitter would normally be abuzz with discussion about the latest APIs or speculation about upcoming hardware announcements, the discourse has been dominated by all things Swift.

一夜之间，大家谈论的主题从命名空间([namespacing](http://nshipster.com/namespacing/)) 和 方法交叉([swizzling](http://nshipster.com/method-swizzling/))，延伸到泛型 ([generics](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Generics.html#//apple_ref/doc/uid/TP40014097-CH26-XID_272)) 和类型推导([type inference](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/TypeCasting.html#//apple_ref/doc/uid/TP40014097-CH22-XID_487))。每年这个时候， Twitter 上通常会充斥着关于最新的 API 的讨论，以及将要发布的硬件设备的传言。然而今年，一切都被 Swift 占领了。

Swift 有着全新的语法，语言规范还处在不断演进的过程当中。Swift 已经吸引了新老开发者的关注，给 iOS & OS X 开发带来了新的想象空间。

A new language with new syntax and evolving conventions, Swift has captured the attention and imagination of iOS & OS X developers both old and new.

尽管我们离使用 Swift 发布 App 还有几个月的时间，已经有若干使用这门新语言的开源项目开始生根发芽了。

Although we still have a few months to wait before we can ship apps in Swift, there is already a proliferation of open source projects built with this new language.

[Alamofire](https://github.com/Alamofire/Alamofire) 便是这些项目中的一个。这一周，我们将深入 Alamofire 的设计与实现，来看看它是如何将 Swift 的语言特性运用到极致。

One such project is [Alamofire](https://github.com/Alamofire/Alamofire). This week, we'll take a look at the design and implementation of Alamofire, and how it's using the language features of Swift to those ends.

> 利益相关：这篇文章，以及其余 NSHipster 的内容，都是由 AFNetworking 和 Alamofire 的作者所创作的。这让我有足够的资格去谈论这些项目的技术细节和选型，但是也确实让我没办法对它们的价值进行客观的评价。因此在阅读下面的内容时，请保持谨慎和怀疑的态度。
> Full Disclosure: this article, as with the rest of NSHipster, is written by the creator of AFNetworking and Alamofire. While this makes me qualified to write about the technical details and direction of these projects, it certainly doesn't allow for an objective take on their relative merits. So take all of this with a grain of salt.

* * *

[Alamofire](https://github.com/Alamofire/Alamofire) 是一个使用 Swift 编写的 HTTP 网络库，它构建于 NSURLSession 和 Foundation 库的 URL 加载系统之上，对高层的网络操作提供了方便的 Swift 接口。

[Alamofire](https://github.com/Alamofire/Alamofire) is an HTTP networking library written in Swift. It leverages NSURLSession and the Foundation URL Loading System to provide first-class networking capabilities in a convenient Swift interface.

使用 Alamofire 很简单，下面是一个 `GET` 请求的示例：

Getting started with Alamofire is easy. Here's how to make a `GET` request:

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .response { (request, response, data, error) in
                     println(request)
                     println(response)
                     println(error)
                   }
```

`Alamofire.request` 是一个 convenience 方法，返回一个 `Alamofire.Request` 对象，这个对象可以通过 `response` 方法链式地添加一个响应的 handler。

`Alamofire.request` is a convenience method that returns an `Alamofire.Request` object, which can be chained to add a response handler with `response`.

默认情况下，`response` 会返回一个服务器响应累加起来得到的 `NSData` 对象。要得到响应的字符串表示，可以使用 `responseString` 方法。

By default, `response` returns the accumulated `NSData` of the server response. To get a string representation of this instead, use the `responseString` method instead.

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .responseString { (request, response, string, error) in
             println(string)
         }
```

类似地，想从请求中得到 JSON 对象的话，可以使用 `responseJSON` 方法：

Similarly, to get a JSON object from the request, use the `responseJSON` method:

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .responseJSON {(request, response, JSON, error) in
             println(JSON)
         }
```

### 链式语法

一个很小的语法差异也有可能对一个语言的通用惯例产生广泛的影响。

Even minor syntactic differences can have wide-reaching implications for language conventions.

在人们对于 Objective-C 的诸多抱怨当中，首当其中的便是使用方括号来表示消息传递([message passing](http://en.wikipedia.org/wiki/Message_passing))。使用 `[ ]` 语法的潜在影响之一，就是很难把方法串联在一起。尽管有 Xcode 自动补全的帮助， `@property` 点(.)语法，以及 [key-value coding key-paths](http://nshipster.com/kvc-collection-operators/)，大家还是很难在代码中看到嵌套层次很深的函数调用。

Chief among the complaints lodged against Objective-C was its use of square brackets for denoting [message passing](http://en.wikipedia.org/wiki/Message_passing). One of the practical implications of `[ ]` syntax is the difficulty in chaining methods together. Even with Xcode autocomplete, `@property` dot syntax, and [key-value coding key-paths](http://nshipster.com/kvc-collection-operators/), it is still rare to see deeply nested invocations.

> Objective-C 2.0 中引入了属性点(.)语法，在很大程度上，这种妥协反而使得语法上的矛盾更严重了。最近这些年语法惯例才重新开始稳定下来。
> In many ways, the concession of introducing dot syntax for properties in Objective-C 2.0 only served to escalate tensions further, although conventions have started to solidify in recent years.

在 Swift 中,所有的方法调用都是使用点(.)语法，参数使用括号传递，在传递过程中会保持顺序，并进行参数的形参化。方法可以返回 `Self` 来让多个方法串联在一起。

In Swift, though, all methods are invoked using dot syntax with ordered and parameterized arguments passed inside parentheses, allowing methods returning `Self` to have successive methods chained together.

Alamofire 采用了这种模式，让网络请求的声明变得更加简洁和局部化。

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

> 请求可以同时有多个 handler，当服务器完成响应时，每个 handler 都会异步地执行。
> Requests can have multiple response handlers, which each execute asynchronously once the server has finished sending its response.

### 结尾闭包

### Trailing Closures

闭包在 Swift 中得到了深度的支持，如果一个方法的最后一个参数是闭包的话，可以使用结尾闭包语法。

Closures are deeply integrated into Swift, so much so that if a methods's last argument is a closure type, a trailing closure can be used instead.

上面例子中的链式方法调用展示了这种用法。在典型的使用场景中，这个用法相当方便，让我们可以省略语法中繁琐的部分。

The chained methods in the previous example show this in action. For typical usage, it's really convenient to omit the syntactic cruft.

### 可选参数 & 灵活的方法签名
### Optional Arguments &  Flexible Method Signatures

在和网络 API 交互的过程中，一个很常见的需求是使用 URL query 或者 HTTP 请求体(body)来发送请求参数：
When communicating with web APIs, it's common to send parameters with URL queries or HTTP body data:

```swift
Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
// GET http://httpbin.org/get?foo=bar
```

这个方法实际上跟前面的例子中是同一个方法。`parameters` 这个参数默认值是 `nil`。这个方法还有第四个参数，也是可选的：`encoding` 参数。

This is actually the same method as before. By default the `parameters` argument is `nil`. There's a fourth argument, and it's optional as well: the parameter `encoding`.

### ParameterEncoding & 枚举类型
### ParameterEncoding & Enums

下面要讲到的是 Swift 中非常酷的一个特性：枚举。在 C 和 Objective-C 中枚举基本上就是整数类型的一个 `typedef`，然而在 Swift 当中，枚举类型支持形参传递，还可以有自己的方法。

This brings us to one of the cooler features of Swift: enums. Whereas C / Objective-C enums are merely `typedef`'d integer declarations, Swift enums support parameterized arguments and can have associated functionality.

Alamofire 使用 `ParameterEncoding` 这个枚举类型，把编码参数的逻辑全都封装到一个 HTTP 消息表示中：

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

通过形参化地使用 `ParameterEncoding` 的这些 case，我们可以指定不同的 JSON 或者 Property List 序列化选项。

The parameterized arguments of `ParameterEncoding` cases allows for different JSON and Property List serialization options to be specified.

对每个 `ParameterEncoding` 的 case 来说，`encode` 方法可以把请求和参数进行处理，转换成新的请求（同时还有一个 optional 的错误返回值）。

The `encode` method on each `ParameterEncoding` case transforms a request and set of parameters into a new request (with optional error return value).

对于复杂的，多层嵌套结构的参数，建议使用 JSON 格式进行参数编码：

Given a complex, nested set of parameters, encoding and sending as JSON is recommended:

> 对于 URL-encoded 后的参数来说，并没有一个统一的标准规定参数的数据结构。也就是说，不同的 Web 应用可能会对参数进行不同的解析处理。更糟糕的是，有一些特定的数据结构根本就没办法用字符串形式进行清晰的表达。这就是为什么在 Web API 提供支持的情况下，对于所有比键值对(key-value)结构复杂的数据，都建议使用 JSON（或者 XML 和 plist）来进行编码。
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

Alamofire 中还使用枚举类型来表示 RFC 2616 §9 中定义的 HTTP 方法：
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

这些值作为第一个参数传递给了 `request` 方法：
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

### 懒加载属性
### Lazy Properties

Swift 的另一个新特性是可以对属性进行懒加载（即按需加载）。一个使用 `lazy` 标示的属性，只会在它第一次在代码中被使用的时候才开始进行计算，赋值，并且把值返回。
Another new feature of Swift is the ability to lazily evaluate properties. A property with the `lazy` annotation will only evaluate, set, and return the value of an expression after it's called for the first time in code.

`Alamofire.Manager` 对象利用了这个特性，实现了默认 HTTP 头部 (`Accept-Encoding`, `Accept-Language`, & `User-Agent`) 的延时构造，把构造推迟到第一个请求被创建时：

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

在 Objective-C 中，一个类对外暴露出 `readonly` 的不可变属性，要想同时在类的内部实现其可变，需要在变量声明时使用一些小技巧(译者注：参考[这里](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html)。

In Objective-C, exposing `readonly`, immutable properties backed by mutable variables in the private implementation required some non-obvious declaration trickery.

Xcode 6 β4 给 Swift 带来了访问控制特性，让我们可以更加方便地设计一个安全的，对外不可变的 API：

With the introduction of access control to Swift in Xcode 6 β4, it's much easier to design a safe, immutable public API:

```swift
private var mutableData: NSMutableData
override var data: NSData! {
    return self.mutableData
}
```

### 还有很多，很多...
### And Much, Much More...

> 在组成 Alamofire 的不到 1000 行的代码中还有很多干货。
There's a lot baked into the < 1000 LOC comprising Alamofire. Any aspiring Swift developer or API author would be advised to [peruse through the source code](https://github.com/Alamofire/Alamofire) to get a better sense of what's going on.

* * *

> 可能有人会想，AFNetworking
> For anyone wondering where this leaves AFNetworking, don't worry: **AFNetworking is stable and reliable, and isn't going anywhere.** In fact, over the coming months, a great deal of work is going to be put into improving test coverage and documentation for AFNetworking 2 and its first-party extensions.

> It's also important to note that AFNetworking can be easily used from Swift code, just like any other Objective-C code. Alamofire is a separate project investigating the implications of new language features and conventions on the problem of making HTTP requests.

Alamofire 1.0 is scheduled to coincide with the 1.0 release of Swift... whenever that is. Part of that milestone is [complete documentation](http://nshipster.com/swift-documentation/), and 100% Unit Test Coverage, making use of the new [Xcode 6 testing infrastructure](http://nshipster.com/xctestcase/) & [httpbin](http://httpbin.org) by [Kenneth Reitz](http://www.kennethreitz.org).

We're all doing our best to understand how to design, implement, and distribute code in Swift. Alamofire is just one of many exciting new libraries that will guide the development of the language and community in the coming months and years. For anyone interested in being part of this, I welcome your contributions. As the mantra goes: [pull requests welcome](https://github.com/Alamofire/Alamofire/compare/).