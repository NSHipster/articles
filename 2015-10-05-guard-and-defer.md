---
title: guard & defer
author: Nate Cook
translator: Croath Liu
category: Swift
excerpt: "最近更新的 Swift 2.0 带来了两个新的能够简化程序和提高效率的控制流表达形式：`guard` 和 `defer`。前者可以让代码编写更流畅，后者能够让执行推迟。我们应该如何使用这两个新的声明方式呢？`guard` 和 `defer` 将如何帮我们厘清程序和进程间的对应关系呢？"
status:
    swift: 2.0
---

> "我们应该（聪明的程序员明白自己的局限性）尽力……让文本里的程序（program）和时间轴上的进程（process）的对应尽量简单。"

> —[Edsger W. Dijkstra](https://en.wikipedia.org/wiki/Edsger_W._Dijkstra), "Go To 有害论"

最近更新的 Swift 2.0 带来了两个新的能够简化程序和提高效率的控制流表达形式：`guard` 和 `defer`。前者可以让代码编写更流畅，后者能够让执行推迟。我们应该如何使用这两个新的声明方式呢？`guard` 和 `defer` 将如何帮我们厘清程序和进程间的对应关系呢？

我们推迟一下 `defer` 先看 `guard`。

---

## guard

如果说在 [Swift 1.2](/swift-1.2/) 中介绍的并行 optional 绑定领导了对 [厄运金字塔](http://www.scottlogic.com/blog/2014/12/08/swift-optional-pyramids-of-doom.html) 的革命，那么 `guard` 声明则与之一并将金字塔摧毁。

`guard` 是一个新的条件声明，表示如果条件不满足时退出当前 block。任何被声明成 `guard` 的 optional 绑定在其他函数或 block 中都是可用的，并强制在 `else` 中用 `return` 来退出函数、`continue` 或 `break` 退出循环，或者用一个类似  `fatalError()` 的 `@noreturn` 函数来退出，以离开当前的上下文：

```swift
for imageName in imageNamesList {
    guard let image = UIImage(named: imageName) 
        else { continue }
    
    // do something with image
}
```

Let's take a before-and-after look at how `guard` can improve our code and help prevent errors. As an example, we'll build a new string-to-`UInt8` initializer. `UInt8` already declares a failable initializer that takes a `String`, but if the conversion fails we don't learn the reason—was the format invalid or was the value out of bounds for the numeric type? Our new initializer throws a `ConversionError` that provides more information.

```swift
enum ConversionError : ErrorType {
    case InvalidFormat, OutOfBounds, Unknown
}

extension UInt8 {
    init(fromString string: String) throws {
        // check the string's format
        if let _ = string.rangeOfString("^\\d+$", options: [.RegularExpressionSearch]) {

            // make sure the value is in bounds
            if string.compare("\(UInt8.max)", options: [.NumericSearch]) != NSComparisonResult.OrderedAscending {
                throw ConversionError.OutOfBounds
            }
            
            // do the built-in conversion
            if let value = UInt8(string) {
                self.init(value)
            } else {
                throw ConversionError.Unknown
            }
        }
        
        throw ConversionError.InvalidFormat
    }
}
```

Note how far apart the format check and the invalid format `throw` are in this example. Not ideal. Moreover, the actual initialization happens two levels deep, inside a nested `if` statement. And if that isn't enough, there's a bug in the logic of this initializer that isn't immediately apparent. Can you spot the flaw? What's really going to bake your noodle later on is, would you still have noticed it if I hadn't said anything?

Next, let's take a look at how using `guard` transforms this initializer:

```swift
extension UInt8 {
    init(fromString string: String) throws {
        // check the string's format
        guard let _ = string.rangeOfString("^\\d+$", options: [.RegularExpressionSearch]) 
            else { throw ConversionError.InvalidFormat }
        
        // make sure the value is in bounds
        guard string.compare("\(UInt8.max)", options: [.NumericSearch]) != NSComparisonResult.OrderedDescending 
            else { throw ConversionError.OutOfBounds }

        // do the built-in conversion
        guard let value = UInt(string) 
            else { throw ConversionError.Unknown }
        
        self.init(value)
    }
}
```

Much better. Each error case is handled as soon as it has been checked, so we can follow the flow of execution straight down the left-hand side. 

Even more importantly, using `guard` prevents the logic flaw in our first attempt; that final `throw` is called every time because it isn't enclosed in an `else` statement. With `guard`, the compiler forces us to break scope inside the else-block, guaranteeing the execution of that particular `throw` only at the right times.

Also note that the middle `guard` statement isn't strictly necessary. Since it doesn't unwrap an optional value, an `if` statement would work perfectly well. Using `guard` in this case simply provides an extra layer of safety—the compiler ensures that you leave the initializer if the test fails, so there's no way to accidentally comment out the `throw` or introduce another error that would lose part of the initializer's logic.


## defer

Between `guard` and the new `throw` statement for error handling, Swift 2.0 certainly seems to be encouraging a style of early return (an NSHipster favorite) rather than nested `if` statements. Returning early poses a distinct challenge, however, when resources that have been initialized (and may still be in use) must be cleaned up before returning.

The new `defer` keyword provides a safe and easy way to handle this challenge, by declaring a block that will be executed only when execution leaves the current scope. Consider this snippet of a function working with `vImage` from the Accelerate framework, taken from the newly-updated article on [image resizing](/image-resizing/):

```swift
func resizeImage(url: NSURL) -> UIImage? {
    // ...
    let dataSize: Int = ...
    let destData = UnsafeMutablePointer<UInt8>.alloc(dataSize)
    var destBuffer = vImage_Buffer(data: destData, ...)
    
    // scale the image from sourceBuffer to destBuffer
    var error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, ...)
    guard error == kvImageNoError
        else {
            destData.dealloc(dataSize)  // 1
            return nil
        }
    
    // create a CGImage from the destBuffer
    guard let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, ...) 
        else {
            destData.dealloc(dataSize)  // 2
            return nil
        }
    destData.dealloc(dataSize)          // 3
    // ...
}
```

Here an `UnsafeMutablePointer<UInt8>` is allocated for the destination data early on, but we need to remember to deallocate at both failure points *and* once we no longer need the pointer.

Error prone? Yes. Frustratingly repetitive? Check.

A `defer` statement removes any chance of forgetting to clean up after ourselves while also simplifying our code. Even though the `defer` block comes immediately after the call to `alloc()`, its execution is delayed until the end of the current scope:

```swift
func resizeImage(url: NSURL) -> UIImage? {
    // ...
    let dataSize: Int = ...
    let destData = UnsafeMutablePointer<UInt8>.alloc(dataSize)
    defer {
        destData.dealloc(dataSize)
    }
    
    var destBuffer = vImage_Buffer(data: destData, ...)
    
    // scale the image from sourceBuffer to destBuffer
    var error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, ...)
    guard error == kvImageNoError 
        else { return nil }
    
    // create a CGImage from the destBuffer
    guard let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, ...) 
        else { return nil }
    // ...
}
```

Thanks to `defer`, `destData` will be properly deallocated no matter which exit point is used to return from the function.

Safe and clean. Swift at its best.

> `defer` blocks are executed in the reverse order of their appearance. This reverse order is a vital detail, ensuring everything that was in scope when a deferred block was created will still be in scope when the block is executed.


### (Any Other) Defer Considered Harmful

As handy as the `defer` statement is, be aware of how its capabilities can lead to confusing, untraceable code. It may be tempting to use `defer` in cases where a function needs to a return a value that should also be modified, as in this typical implementation of the postfix `++` operator:

```swift
postfix func ++(inout x: Int) -> Int {
    let current = x
    x += 1
    return current
}
```

In this case, `defer` offers a clever alternative. Why create a temporary variable when we can just defer the increment? 

```swift
postfix func ++(inout x: Int) -> Int {
    defer { x += 1 }
    return x
}
```

Clever indeed, yet this inversion of the function's flow harms readability. Using `defer` to explicitly alter a program's flow, rather than to clean up allocated resources, will lead to a twisted and tangled execution process.


---

"As wise programmers aware of our limitations," we must weigh the benefits of each language feature against its costs. A new statement like `guard` leads to a more linear, more readable program; apply it as widely as possible. Likewise, `defer` solves a significant challenge but forces us to keep track of its declaration as it scrolls out of sight; reserve it for its minimum intended purpose to guard against confusion and obscurity.

