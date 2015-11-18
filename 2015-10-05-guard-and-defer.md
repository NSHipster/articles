---
title: guard & defer
author: Nate Cook
translator: Croath Liu
category: Swift
excerpt: "最近更新的 Swift 2.0 带来了两个新的能够简化程序和提高效率的控制流表达形式：`guard` 和 `defer`。前者可以让代码编写更流畅，后者能够让执行推迟。我们应该如何使用这两个新的声明方式呢？`guard` 和 `defer` 将如何帮我们厘清程序和进程间的对应关系呢？"
status:
    swift: 2.0
---

> 「我们应该（聪明的程序员明白自己的局限性）尽力……让文本里的程序（program）和时间轴上的进程（process）的对应尽量简单。」

> —[Edsger W. Dijkstra](https://en.wikipedia.org/wiki/Edsger_W._Dijkstra), 《Go To 有害论》

最近更新的 Swift 2.0 带来了两个新的能够简化程序和提高效率的控制流表达形式：`guard` 和 `defer`。前者可以让代码编写更流畅，后者能够让执行推迟。我们应该如何使用这两个新的声明方式呢？`guard` 和 `defer` 将如何帮我们厘清程序和进程间的对应关系呢？

我们 defer（推迟）一下 `defer` 先看 `guard`。

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

我们来对比一下使用 `guard` 关键字之后能如何帮助我们避免错误。例如，我们创建一个字符串转为 `UInt8` 的初始化方法。`UInt8` 已经实现了一个可以接受 `String` 的初始化方法并且可以抛出错误，但是如果上下文出现了我们不能预知的问题，比如说格式错误了，或者超出了数值边界，应该怎么办呢？我们新实现的初始化方法将抛出一个能够提供更多错误信息的 `ConversionError`。

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

注意这个例子中格式检查和抛出错误格式的代码距离有多远，写出这样的代码并不理想。此外，真正的初始化被放在了两层深的 `if` 嵌套中。如果我们的代码写的有问题，里面有 bug 的话，根本不能一眼看出问题在哪。这里面有什么问题你能立刻发现吗？如果我不告诉你的话，你能知道到底是哪部分代码出了问题吗？

下面我们来用 `guard` 改善一下这段代码：

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

这样就好多了。每一个错误都在相应的检查之后立刻被抛出，所以我们可以按照左手边的代码顺序来梳理工作流的顺序。

更重要的是，用 `guard` 能够避免我们第一次写代码时候的逻辑错误，第一次我们写的最后一个 `throw` 每次都被调用了，因为它不在 `else` 里面。使用 `guard` 编译器会强制我们在 else-block 里跳出当前上下文，这保证了 `throw` 只在他们应该出现的时候被调用。

同时请注意中间那个 `guard` 语句并不是严格必需的。因为它并不能转换一个 optional 值，所以只用 `if` 语句也能完美工作，在这种情况下使用 `guard` 只是从控制层面保证了安全 —— 让编译器确保如果测试失败也能够退出初始化函数，所以就没有必要为每一个 `throw` 或可能产生错误的地方写注释来避免逻辑混淆了。

## defer

在错误处理方面，`guard` 和新的 `throw` 语法之间，Swift 2.0 也鼓励用尽早返回错误（这也是 NSHipster 最喜欢的方式）来代替嵌套 if 的处理方式。尽早返回让处理更清晰了，但是已经被初始化（可能也正在被使用）的资源必须在返回前被处理干净。

新的 `defer` 关键字为此提供了安全又简单的处理方式：声明一个 block，当前代码执行的闭包退出时会执行该 block。下面的代码是使用 Accelerate framework 对 `vImage` 进行操作的一些函数（这个函数是从 [image resizing](http://nshipster.com/image-resizing/) 这篇文章中截取的）：

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

这里有一个在最开始就创建的 `UnsafeMutablePointer<UInt8>` 用于存储目标数据，但是我 *既要* 在错误发生后销毁它，*又要* 在正常流程下不再使用它时对其进行销毁。

这种设计很容易导致错误，而且不停地在做重复工作。

`defer` 语句能让我们在做完主体工作之后不会忘记脏数据，也能让代码更简洁。虽然 `defer` block 紧接着 `alloc()` 出现，但会等到当前上下文结束的时候才真正执行：

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

多亏了 `defer`，`destData` 才能无论在哪个点退出函数都可以被释放。

安全又干净，Swift 优势发挥到极致。

> `defer` 的 block 执行顺序和书写的顺序是相反的，这种相反的顺序是必要的，是为了确保每样东西的 defer block 在被创建的时候，该元素依然在当前上下文中存在。


### (其他情况下)  Defer 会带来坏处

虽然 `defer` 像一个语法糖一样，但也要小心使用避免形成容易误解、难以阅读的代码。在某些情况下你可能会尝试用 `defer` 来对某些值返回之前做最后一步的处理，例如说在后置运算符 `++` 的实现中：

```swift
postfix func ++(inout x: Int) -> Int {
    let current = x
    x += 1
    return current
}
```

在这种情况下，可以用 `defer` 来进行一个很另类的操作。如果能在 defer 中处理的话为什么要创建临时变量呢？ 

```swift
postfix func ++(inout x: Int) -> Int {
    defer { x += 1 }
    return x
}
```

这种写法确实聪明，但这样却颠倒了函数的逻辑顺序，极大降低了代码的可读性。应该严格遵循 `defer` 在整个程序最后运行以释放已申请资源的原则，其他任何使用方法都可能让代码乱成一团。

---

「聪明的程序员明白自己的局限性」，我们必须权衡每种语言特性的好处和其成本。类似于 `guard` 的新特性能让代码流程上更线性，可读性更高，就应该尽可能使用。同样 `defer` 也解决了重要的问题，但是会强迫我们一定要找到它声明的地方才能追踪到其销毁的方法，因为声明方法很容易被滚动出了视野之外，所以应该尽可能遵循它出现的初衷尽可能少地使用，避免造成混淆和晦涩。

