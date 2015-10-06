---
title: guard & defer
author: Nate Cook
category: Swift
excerpt: "Recently, Swift 2.0 introduced two new control statements that aim to simplify and streamline the programs we write: `guard` and `defer`. While the first by its nature makes our code more linear, the other defers execution of its contents. How should we approach these new control statements? How can `guard` and `defer` help us clarify the correspondence between the program and the process?"
status:
    swift: 2.0
---

> "We should do (as wise programmers aware of our limitations) our utmost best to … make the correspondence between the program (spread out in text space) and the process (spread out in time) as trivial as possible."

> —[Edsger W. Dijkstra](https://en.wikipedia.org/wiki/Edsger_W._Dijkstra), "Go To Considered Harmful"

Recently, Swift 2.0 introduced two new control statements that aim to simplify and streamline the programs we write: `guard` and `defer`. While the first by its nature makes our code more linear, the other defers execution of its contents. How should we approach these new control statements? How can `guard` and `defer` help us clarify the correspondence between the program and the process?

Let's defer `defer` and first take on `guard`.

---

## guard

If the multiple optional bindings syntax introduced in [Swift 1.2](/swift-1.2/) heralded a renovation of the [pyramid of doom](http://www.scottlogic.com/blog/2014/12/08/swift-optional-pyramids-of-doom.html), `guard` statements tear it down altogether.

`guard` is a new conditional statement that requires execution to exit the current block if the condition isn't met. Any new optional bindings created in a `guard` statement's condition are available for the rest of the function or block, and the mandatory `else` must exit the current scope, by using `return` to leave a function, `continue` or `break` within a loop, or a `@noreturn` function like `fatalError()`:

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

