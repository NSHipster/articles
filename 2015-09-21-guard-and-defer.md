---
title: guard & defer
author: Nate Cook
category: Swift
excerpt: ""
status:
    swift: 2.0
---

Scope this

Two new control structures

Let's defer `defer` and take on `guard` first.

---

## guard

...

The multiple optional bindings syntax introduced in [Swift 1.2](/swift-1.2/) was a renovation of the [pyramid of doom](http://www.scottlogic.com/blog/2014/12/08/swift-optional-pyramids-of-doom.html); `guard` statements tear it down all together.

Let's take a look a before-and-after look at how `guard` can improve our code and help prevent errors. As an example, we'll build a new string-to-`UInt8` initializer. `UInt8` already has a failable initializer that takes  a `String`, but if the conversion fails we don't learn the reason—was the format invalid or was the value out of bounds for the numeric type? Our new initializer throws a `ConversionError` that gives us a little more information.

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

Look how far apart the format check and the invalid format `throw` are—not ideal. Moreover, the actual initialization happens two levels deep, inside a nested `if` statement. And if that isn't enough, there's a bug in the logic of this initializer that isn't immediately apparent. Can you spot the flaw? Did you see it before you knew it was there?

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

Much better. Each error case is handled as soon as it's checked and we can follow the flow of execution straight down the left-hand side. 

Even more importantly, using `guard` prevents the logic flaw in the first attempt—that final `throw` is called every time, since it isn't enclosed in an `else` statement. Since the compiler forces us to break scope inside the else-block of a guard statement, we're guaranteed to execute that particular `throw` at only the right times.

One other note—the middle `guard` statement isn't strictly necessary. Since it isn't unwrapping an optional value, an `if` statement would work perfectly well. Using `guard` in this case simply provides an extra layer of safety—the compiler ensures that you leave the initializer if the test fails, so there's no way to accidentally comment out the `throw` or introduce another error that would lose that part of the initializer's logic.


## `defer`

Between `guard` and the new `throw` statement for error handling, Swift 2.0 certainly seems to be encouraging a style of returning early (an NSHipster favorite) rather than nesting `if` statements. Returning early poses a distinct challenge, however, when resources that have been initialized (and may still be in use) need to be cleaned up before returning.

The new `defer` keyword provides an new and better way to handle this challenge, by declaring a block that will be executed only when execution leaves the current scope. Consider this snippet of a function working with `vImage` from the Accelerate framework, from the newly-updated article on [image resizing](/image-resizing/):

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

We allocate an `UnsafeMutablePointer<UInt8>` for the destination data early on, but need to remember to deallocate at both of the failure points *and* once we no longer need the pointer.

Error prone? Yes. Frustratingly repetitive? Check.

A `defer` statement removes any chance of forgetting to clean up after ourselves *and* simplifies our code. Even though the `defer` block comes immediately after the call to `alloc()`, it won't be executed until the end of the current scope:

```swift
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
```

Before each of those `return nil` statements, and just before the function itself exits, `destData` will be properly deallocated.

Safe and clean. Swift at its best.

> `defer` blocks are executed in the reverse order of their appearance. This reverse order is vital detail that means that everything that *was* in scope when a deferred block was created will *still* be in scope when it's executed.


### (Any Other) Defer Considered Harmful

As handy as the `defer` statement is, don't let its capabilities lead you down a path toward confusing, untraceable code. It may be tempting to use `defer` in cases where you need to a return a value that should also be modified, as in this typical implementation of the postfix `++` operator:

```swift
postfix func ++(inout x: Int) -> Int {
    let current = x
    x += 1
    return current
}
```

*Argh*, thinks the clever developer. *Why create a temporary variable when I can just defer the increment?*

```swift
postfix func ++(inout x: Int) -> Int {
    defer { x += 1 }
    return x
}
```

Clever indeed, but this way lies 




---










