---
title: Alamofire
author: Mattt Thompson
translator: Chester Liu
category: Open Source
excerpt: "尽管我们离使用 Swift 发布 App 还有几个月的时间，已经有若干使用这门新语言的开源项目开始生根发芽了， Alamofire 便是这些项目中的一个。"
status:
    swift: 1.1
---

Swift 像是在 iOS 开发者社区中按下了一个“重启”按钮，成了很多常年使用 Objective-C 的开发者的新宠儿。

一夜之间，大家谈论的主题从命名空间([namespacing](http://nshipster.com/namespacing/)) 和 方法交叉([swizzling](http://nshipster.com/method-swizzling/))，延伸到泛型 ([generics](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Generics.html#//apple_ref/doc/uid/TP40014097-CH26-XID_272)) 和类型推导([type inference](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/TypeCasting.html#//apple_ref/doc/uid/TP40014097-CH22-XID_487))。每年这个时候， Twitter 上通常会充斥着关于最新的 API 的讨论，以及将要发布的硬件设备的传言。然而今年，一切都被 Swift 占领了。

Swift 有着全新的语法，语言规范还处在不断演进的过程当中。Swift 已经吸引了新老开发者的关注，给 iOS & OS X 开发带来了新的想象空间。

尽管我们离使用 Swift 发布 App 还有几个月的时间，已经有若干使用这门新语言的开源项目开始生根发芽了。

[Alamofire](https://github.com/Alamofire/Alamofire) 便是这些项目中的一个。这一周，我们将深入 Alamofire 的设计与实现，来看看它是如何将 Swift 的语言特性运用到极致。

> 利益相关：这篇文章，以及其余 NSHipster 的内容，都是由 AFNetworking 和 Alamofire 的作者所创作的。这让我有足够的资格去谈论这些项目的技术细节和选型，但是也确实让我没办法对它们的价值进行客观的评价。因此在阅读下面的内容时，请保持谨慎和怀疑的态度。

* * *

[Alamofire](https://github.com/Alamofire/Alamofire) 是一个使用 Swift 编写的 HTTP 网络库，它构建于 NSURLSession 和 Foundation 库的 URL 加载系统之上，对高层的网络操作提供了方便的 Swift 接口。

使用 Alamofire 很简单，下面是一个 `GET` 请求的示例：

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .response { (request, response, data, error) in
                     println(request)
                     println(response)
                     println(error)
                   }
```

`Alamofire.request` 是一个 convenience 方法，返回一个 `Alamofire.Request` 对象，这个对象可以通过 `response` 方法链式地添加一个响应的 handler。

默认情况下，`response` 会返回一个服务器响应累加起来得到的 `NSData` 对象。要得到响应的字符串表示，可以使用 `responseString` 方法。

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .responseString { (request, response, string, error) in
             println(string)
         }
```

类似地，想从请求中得到 JSON 对象的话，可以使用 `responseJSON` 方法：

```swift
Alamofire.request(.GET, "http://httpbin.org/get")
         .responseJSON {(request, response, JSON, error) in
             println(JSON)
         }
```

### 链式语法

一个很小的语法差异也有可能对一个语言的通用惯例产生广泛的影响。

在人们对于 Objective-C 的诸多抱怨当中，首当其中的便是使用方括号来表示消息传递([message passing](http://en.wikipedia.org/wiki/Message_passing))。使用 `[ ]` 语法的潜在影响之一，就是很难把方法串联在一起。尽管有 Xcode 自动补全的帮助， `@property` 点(.)语法，以及 [key-value coding key-paths](http://nshipster.com/kvc-collection-operators/)，大家还是很难在代码中看到嵌套层次很深的函数调用。

> Objective-C 2.0 中引入了属性点(.)语法，在很大程度上，这种妥协反而使得语法上的矛盾更严重了。最近这些年语法惯例才重新开始稳定下来。

在 Swift 中,所有的方法调用都是使用点(.)语法，参数使用括号传递，在传递过程中会保持顺序，并进行参数的形参化。方法可以返回 `Self` 来让多个方法串联在一起。

Alamofire 采用了这种模式，让网络请求的声明变得更加简洁和局部化。

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

### 结尾闭包

闭包在 Swift 中得到了深度的支持，如果一个方法的最后一个参数是闭包的话，可以使用结尾闭包语法。

上面例子中的链式方法调用展示了这种用法。在典型的使用场景中，这个用法相当方便，让我们可以省略语法中繁琐的部分。

### 可选参数 & 灵活的方法签名

在和网络 API 交互的过程中，一个很常见的需求是使用 URL query 或者 HTTP 请求体(body)来发送请求参数：

```swift
Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
// GET http://httpbin.org/get?foo=bar
```

这个方法实际上跟前面的例子中是同一个方法。`parameters` 这个参数默认值是 `nil`。这个方法还有第四个参数，也是可选的：`encoding` 参数。

### ParameterEncoding & 枚举类型

下面要讲到的是 Swift 中非常酷的一个特性：枚举。在 C 和 Objective-C 中枚举基本上就是整数类型的一个 `typedef` 声明，然而在 Swift 当中，枚举类型支持形参化使用，还可以有自己的方法。


Alamofire 使用 `ParameterEncoding` 这个枚举类型，把编码参数的逻辑全都封装到一个 HTTP 消息表示中：

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

对每个 `ParameterEncoding` 的 case 来说，`encode` 方法可以把请求和参数进行处理，转换成新的请求（同时还有一个可选的错误返回值）。

对于复杂的，多层嵌套结构的参数，建议使用 JSON 格式进行参数编码：


> 对于要进行 URL-encoded 的参数来说，并没有一个统一的标准规定参数的数据结构。也就是说，不同的 Web 应用可能会对参数进行不同的解析处理。更糟糕的是，有一些特定的数据结构根本就没办法用字符串形式进行清晰的表达。这就是为什么在 Web API 提供支持的情况下，对于所有比键值对(key-value)结构复杂的数据，都建议使用 JSON（或者 XML 和 plist）来进行编码。

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

Swift 的另一个新特性是可以对属性进行懒加载。一个使用 `lazy` 标示的属性，只会在它第一次在代码中被使用的时候才开始进行计算，赋值，并且把值返回。

`Alamofire.Manager` 对象利用了这个特性，实现了默认 HTTP 头部 (`Accept-Encoding`, `Accept-Language`, & `User-Agent`) 的延时构造，把构造推迟到第一个请求被创建时：

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

### 使对内可变的属性对外不可变

在 Objective-C 中，一个类对外暴露出 `readonly` 的不可变属性，要想同时在类的内部实现其可变，需要在变量声明时使用一些小技巧(译者注：参考[这里](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html)。

Xcode 6 β4 给 Swift 带来了访问控制特性，让我们可以更加方便地设计一个安全的，对外不可变的 API：

```swift
private var mutableData: NSMutableData
override var data: NSData! {
    return self.mutableData
}
```

### 还有很多，很多...

> 在组成 Alamofire 的不到 1000 行的代码中还有很多干货。对于所有有志于 Swift 语言的开发者和 API 作者们，我都建议你们[深入项目的源代码]((https://github.com/Alamofire/Alamofire)，以更好地了解底层的实现内幕。

* * *

> 可能有人会想，那 AFNetworking 呢？放心，**AFNetworking 依然稳定而且可靠，并且会继续被维护**。实际上，最近这几个月以来，很多开发者在 AFNetworking 以及它的一方扩展上投入了大量的工作，以提高测试覆盖率，同时完善文档。

> 另外，AFNetworking 也可以很方便地在 Swift 使用，和使用其它的 Objective-C 代码没有区别。Alamofire 作为一个单独的项目，从发送 HTTP 请求这个问题出发，致力于对新语言的特性和范式进行探索。

Alamofire 1.0 计划在 Swift 1.0 版本发布时同时释出（具体什么时候就看苹果了）。里程碑当中的一部分包括[完成全部文档](http://nshipster.com/swift-documentation/)，以及借助于 [Xcode 6 的测试支持](http://nshipster.com/xctestcase/) 和 [Kenneth Reitz](http://www.kennethreitz.org) 编写的 [httpbin](http://httpbin.org)，实现 100% 的单元测试覆盖率。

我们每个人都在尽最大努力去理解如何设计，实现以及发布 Swift 代码。Alamofire 只是众多激动人心的新库当中的一个，它们将会在接下来的数月乃至数年时间当中，指导语言本身以及社区的发展。对于想参与其中的人，欢迎你们做出贡献。俗话说得好：[pull requests 永远不嫌多](https://github.com/Alamofire/Alamofire/compare/)
