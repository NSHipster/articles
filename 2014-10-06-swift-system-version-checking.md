---
title: Swift System Version Checking
author: Mattt Thompson
category: Swift
tags: swift
excerpt: "C uses preprocessor directives capable of unspeakable evil. Swift has a safe subset of preprocessor directives. So how do we check system version for API compatibility?"
status:
    swift: 4.0
---

While it's not accurate to say that Swift is "Objective-C without the C", it's for lack of resemblance to Objective-C, not the absence of C. Swift is _vehemently_ **_not_** C.

Swift certainly draws inspiration from Haskell, Rust, Python, D, and other modern languages, but one can perhaps best understand the language as a rejection of everything that's broken in C:

- C is **unsafe** by default. Swift is **safe** by default _(hence the `unsafe` naming of pointer manipulation functions)_.
- C has **undefined behavior**. Swift has **well-defined behavior**.
- C uses **preprocessor directives capable of unspeakable evil**. Swift has a **safe subset of preprocessor directives**.

> One could go as far to say that Swift's type system was specifically designed out of _spite_ for C++.

In Objective-C, checking for the availability of an API was accomplished through a combination of C preprocessor directives, conditionals on `class`, `respondsToSelector:`, and `instancesRespondToSelector:`:

~~~{objective-c}
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
if ([NSURLSession class] &&
    [NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
    // ...
}
#endif
~~~

However, as noted previously, Swift's compiler directives are [extremely constrained](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-XID_20), allowing only for compiler flags and conditional compilation against [specific operating systems, architectures, and language versions](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Statements.html#//apple_ref/doc/uid/TP40014097-CH33-ID539):

~~~{swift}
#if DEBUG
     println("OTHER_SWIFT_FLAGS = -D DEBUG")
#endif
~~~

| Function  | Valid Arguments                            |
|-----------|--------------------------------------------|
| `os()`    | `macOS`, `iOS`, `watchOS`, `tvOS`, `Linux` |
| `arch()`  | `x86_64`, `arm`, `arm64`, `i386`           |
| `swift()` | `>=` followed by a version number          |

~~~{swift}
#if os(iOS)
    var image: UIImage?
#elseif os(macOS)
    var image: NSImage?
#endif
~~~

Unfortunately, `os()` does not offer any insight into the specific version of macOS or iOS, which means that checks must be made at runtime. And with Swift's less-forgiving [treatment of `nil`](http://nshipster.com/nil/), checking for constants Objective-C-style results in a crash.

So how do you check the system version in Swift to determine API availability? Read on to find out.

* * *

## ProcessInfo

Anticipating the need for a Swift-friendly API for determining API version at runtime, iOS 8 introduces the `operatingSystemVersion` property and `isOperatingSystemAtLeast` method on `ProcessInfo`. Both APIs use a new `OperatingSystemVersion` value type, which contains the `majorVersion`, `minorVersion`, and `patchVersion`.

> Apple software releases follow [semantic versioning](http://semver.org) conventions.

### isOperatingSystemAtLeast

For a simple check, like "is this app running on iOS 9?", `isOperatingSystemAtLeast` is the most straightforward approach.

~~~{swift}
if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)) {
    println("iOS >= 9.0.0")
}
~~~

### operatingSystemVersion

For more involved version comparison, the `operatingSystemVersion` can be inspected directly. Combine this with Swift pattern matching and `switch` statements for syntactic concision:

~~~{swift}
let os = ProcessInfo().operatingSystemVersion
switch (os.majorVersion, os.minorVersion, os.patchVersion) {
case (8, 0, _):
    println("iOS >= 8.0.0, < 8.1.0")
case (8, _, _):
    println("iOS >= 8.1.0, < 9.0")
case (9, _, _):
    println("iOS >= 9.0.0")
default:
    // this code will have already crashed on iOS 7, so >= iOS 10.0
    println("iOS >= 10.0.0")
}
~~~

## UIDevice systemVersion

As an alternative, one can use the `systemVersion` property `UIDevice`:

~~~{swift}
switch UIDevice.current.systemVersion.compare("8.0.0", options: .numeric) {
case .orderedSame, .orderedDescending:
    print("iOS >= 8")
case .orderedAscending:
    print("iOS < 8.0")
}
~~~

> Use `String.CompareOptions.numeric` when comparing version number strings to ensure that, for example, `"2.5" < "2.10"`.

String comparison and `ComparisonResult` aren't as sexy as a dedicated value type like `OperatingSystemVersion`, but it gets the job done all the same.

## NSAppKitVersion

Another approach to determining API availability is to check framework version numbers. Unfortunately, Foundation's `NSFoundationVersionNumber` and Core Foundation's `kCFCoreFoundationVersionNumber` have historically been out of date, missing constants for past OS releases.

This is a dead-end for iOS, but macOS can pretty reliably check against the version of AppKit, with `NSAppKitVersion`:

~~~{swift}
if NSAppKitVersion.current.rawValue >= .macOS10_10.rawValue {
    println("macOS >= 10.10")
}
~~~

If you pair this with an extension to make `NSAppKitVersion` conform to `Comparable`, you can remove the `.rawValue`s as well.

* * *

To summarize, here's what you need to know about checking the system version in Swift:

- Use `#if os(iOS)` preprocessor directives to distinguish between iOS (UIKit) and macOS (AppKit) targets.
- For minimum deployment targets of iOS 8.0 or above, use `ProcessInfo` `operatingSystemVersion` or `isOperatingSystemAtLeast`.
- For minimum deployment targets of iOS 7.1 or below, use `compare` with `String.CompareOptions.numeric` on `UIDevice` `systemVersion`.
- For macOS deployment targets, compare `NSAppKitVersion` against available AppKit constants.
