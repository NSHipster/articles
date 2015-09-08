---
title: Swift System Version Checking
author: Mattt Thompson
category: Swift
excerpt: "C uses preprocessor directives capable of unspeakable evil. Swift has a safe subset of preprocessor directives. So how do we check system version for API compatibility?"
translator: April Peng
excerpt: "C 可以使用邪恶的预处理指令。Swift 有预处理指令的安全子集。那么，我们如何检查系统版本的 API 兼容性？"
---

While it's not accurate to say that Swift is "Objective-C without the C", it's for lack of resemblance to Objective-C, not the absence of C. Swift is _vehemently_ **_not_** C.

说 Swift 是 “没有了 C 的 Objective-C” 不太准确，因为 Swift 与 Objective-C 不相似，并不是脱离了 C。Swift _完全_ **不是** C.

Swift certainly draws inspiration from Haskell, Rust, Python, D, and other modern languages, but one can perhaps best understand the language as a rejection of everything that's broken in C:

Swift 的灵感肯定有不少来自 Haskell、Rust、Python、D， 和其他现代语言，但或许理解这个语言最好的方式是看它怎么和 C 做比较的：

- C is **unsafe** by default. Swift is **safe** by default _(hence the `unsafe` naming of pointer manipulation functions)_.
- C has **undefined behavior**. Swift has **well-defined behavior** _(or at least theoretically; the compiler tools still have some catching up to do)_.
- C uses **preprocessor directives capable of unspeakable evil**. Swift has a **safe subset of preprocessor directives**.

- C 默认是 **不安全的**。Swift 默认是 **安全的** _（因此有 `unsafe` 命名的指针操作函数）_。
- C 有 **未定义行为**。Swift 有 **良好定义的行为** _（或这说至少在理论上，编译器工具仍然需要更新）_。
- C 使用 **邪恶的预处理指令**。 而 Swift 有预处理指令的 **安全子集**。

> One could go as far to say that Swift's type system was specifically designed out of _spite_ for C++.

> 尽可以说，Swift 的类型系统是专门设计出来跟 C++ 对着干的。

In Objective-C, checking for the availability of an API was accomplished through a combination of C preprocessor directives, conditionals on `class`, `respondsToSelector:`, and `instancesRespondToSelector:`:

在 Objective-C，检查一个 API 的可用性是通过结合 C 预处理指令和 `class`，`respondsToSelector:` 和 `instancesRespondToSelector:` 来完成的：

~~~{objective-c}
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
if ([NSURLSession class] &&
    [NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
    // ...
}
#endif
~~~

However, as noted previously, Swift's compiler directives are [extremely constrained](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-XID_20), allowing only for compiler flags and conditional compilation against specific operating systems and architectures:

然而，正如前面所提到的，Swift 的编译器指令是 [极度严格的](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-XID_20),只允许编译器标志和有条件的针对特定操作系统和架构进行编译：

~~~{swift}
#if DEBUG
     println("OTHER_SWIFT_FLAGS = -D DEBUG")
#endif
~~~

| Function | Valid Arguments                    |
|----------|------------------------------------|
| `os()`   | `OSX`, `iOS`                      |
| `arch()` | `x86_64`, `arm`, `arm64`, `i386`   |

~~~{swift}
#if os(iOS)
    var image: UIImage?
#elseif os(OSX)
    var image: NSImage?
#endif
~~~

Unfortunately, `os()` does not offer any insight into the specific version of OS X or iOS, which means that checks must be made at runtime. And with Swift's less-forgiving [treatment of `nil`](http://nshipster.com/nil/), checking for constants Objective-C-style results in a crash.

不幸的是，`os()` 不提供任何检查特定 OS X 或 iOS 版本的方法，这意味着，检查必须在运行时进行。而由于 Swift [对待 `nil`](http://nshipster.com/nil/) 不太宽容的方式，检查 Objective-C 风格的常量将导致崩溃。

So how do you check the system version in Swift to determine API availability? Read on to find out.

那么，你如何查看 Swift 的系统版本以确定 API 是否可用？请接着阅读来找出答案。

* * *

## NSProcessInfo

Anticipating the need for a Swift-friendly API for determining API version at runtime, iOS 8 introduces the `operatingSystemVersion` property and `isOperatingSystemAtLeastVersion` method on `NSProcessInfo`. Both APIs use a new `NSOperatingSystemVersion` value type, which contains the `majorVersion`, `minorVersion`, and `patchVersion`.

考虑到需要用 Swift 友好的 API 在运行时检查 API 版本的需求，iOS 8 引入了 `NSProcessInfo` 的 `operatingSystemVersion` 属性和 `isOperatingSystemAtLeastVersion` 方法。这两个 API 使用一个新的 `NSOperatingSystemVersion` 类型值，其中包含了 `majorVersion`，`minorVersion`，和 `patchVersion`。

> Apple software releases follow [semantic versioning](http://semver.org) conventions.

> 苹果软件发布了如下的 [语义化版本](http://semver.org) 约定。

### isOperatingSystemAtLeastVersion

For a simple check, like "is this app running on iOS 8?", `isOperatingSystemAtLeastVersion` is the most straightforward approach.

对于一个简单的检查，比如 “这个应用程序是在 iOS 8 上运行吗？”，`isOperatingSystemAtLeastVersion` 是最直接的方法。

~~~{swift}
if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0)) {
    println("iOS >= 8.0.0")
}
~~~

### operatingSystemVersion

For more involved version comparison, the `operatingSystemVersion` can be inspected directly. Combine this with Swift pattern matching and `switch` statements for syntactic concision:

对于更复杂的版本比较，`operatingSystemVersion` 可以直接检查。把 Swift 的模式匹配和 `switch` 语句结合起来：

~~~{swift}
let os = NSProcessInfo().operatingSystemVersion
switch (os.majorVersion, os.minorVersion, os.patchVersion) {
case (8, _, _):
    println("iOS >= 8.0.0")
case (7, 0, _):
    println("iOS >= 7.0.0, < 7.1.0")
case (7, _, _):
    println("iOS >= 7.1.0, < 8.0.0")
default:
    println("iOS < 7.0.0")
}
~~~

## UIDevice systemVersion

Ironically, the new `NSProcessInfo` APIs aren't especially useful at the time of writing, since they're unavailable for iOS 7.

讽刺的是，新的 `NSProcessInfo` API 在写这篇文章的时候还不是特别有用，因为他们在 iOS 7 不可用。

As an alternative, one can use the `systemVersion` property `UIDevice`:

作为替代方案，可以使用 `UIDevice` 的 `systemVersion` 属性：

~~~{swift}
switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
case .OrderedSame, .OrderedDescending:
    println("iOS >= 8.0")
case .OrderedAscending:
    println("iOS < 8.0")
}
~~~

> Use `NSStringCompareOptions.NumericSearch` when comparing version number strings to ensure that, for example, `"2.5" < "2.10"`.

> 在比较版本号字符串时，确保使用 `NSStringCompareOptions.NumericSearch`，例如，`"2.5" < "2.10"`。

String comparison and `NSComparisonResult` aren't as sexy as a dedicated value type like `NSOperatingSystemVersion`, but it gets the job done all the same.

字符串比较和 `NSComparisonResult` 并不像 `NSOperatingSystemVersion` 专用值类型那么好用，但它能够完成所有相同的工作。

## NSAppKitVersionNumber

Another approach to determining API availability is to check framework version numbers. Unfortunately, Foundation's `NSFoundationVersionNumber` and Core Foundation's `kCFCoreFoundationVersionNumber` have historically been out of date, missing constants for past OS releases.

另一种方法来确定 API 的可用性是检查框架的版本号。不幸的是，Foundation 的 `NSFoundationVersionNumber` 和 Core Foundation 的 `kCFCoreFoundationVersionNumber` 已经过时了，以往操作系统的发布常数已经找不到了。

This is a dead-end for iOS, but OS X can pretty reliably check against the version of AppKit, with `NSAppKitVersionNumber`:

这对于 iOS 是一个死胡同，但 OS X 可以非常可靠地用 `NSAppKitVersionNumber` 检查 AppKit 的版本：

~~~{swift}
if rint(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9 {
    println("OS X >= 10.10")
}
~~~

> Apple uses `rint` in sample code to round off version numbers for `NSAppKitVersionNumber` comparison.

> 苹果在示例代码中使用 `rint` 来四舍五入版本号 `NSAppKitVersionNumber` 进行比较。

* * *

To summarize, here's what you need to know about checking the system version in Swift:

总之，这就是你需要知道的关于检查 Swift 系统版本的所有内容了：

- Use `#if os(iOS)` preprocessor directives to distinguish between iOS (UIKit) and OS X (AppKit) targets.
- For minimum deployment targets of iOS 8.0 or above, use `NSProcessInfo` `operatingSystemVersion` or `isOperatingSystemAtLeastVersion`.
- For minimum deployment targets of iOS 7.1 or below, use `compare` with `NSStringCompareOptions.NumericSearch` on `UIDevice` `systemVersion`.
- For OS X deployment targets, compare `NSAppKitVersionNumber` against available AppKit constants.

- 使用 `#if os(iOS)` 预处理指令来判断 iOS（UIKit） 和 OS X（AppKit） 的区别。
- 仅支持 iOS 8.0 或以上版本的，可以使用 `NSProcessInfo` 的 `operatingSystemVersion` 或 `isOperatingSystemAtLeastVersion`。
- 要支持 iOS 7.1 或以下版本的，比较 `UIDevice` 的 `systemVersion` 和 `NSStringCompareOptions.NumericSearch`。
- 对于 OS X，比较 `NSAppKitVersionNumber` 和 AppKit 常数。
