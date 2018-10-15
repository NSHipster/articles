---
title: numericCast(_:)
author: Mattt
category: Swift
excerpt: >
  Getting code to compile is different than doing things correctly.
  But sometimes it takes the former to ultimately get to the latter.
status:
  swift: 4.2
---

Everyone has their favorite analogy to describe programming.

It's woodworking or it's knitting or it's gardening.
Or maybe it's problem solving and storytelling and making art.
That programming is like writing there is no doubt;
the question is whether it's poetry or prose.
And if programming is like music,
it's always jazz for whatever reason.

But perhaps the closest point of comparison for what we do all day
comes from Middle Eastern folk tales:
Open any edition of
_The Thousand and One Nights_ (أَلْف لَيْلَة وَلَيْلَة‎)
and you'll find descriptions of supernatural beings known as
<dfn>jinn</dfn>, <dfn>djinn</dfn>, <dfn>genies</dfn>, or 🧞‍.
No matter what you call them,
you're certainly familiar with their habit of granting wishes,
and the misfortune that inevitably causes.

In many ways,
computers are the physical embodiment of metaphysical wish fulfillment.
Like a genie, a computer will happily go along with whatever you tell it to do,
with no regard for what your actual intent may have been.
And by the time you've realized your error,
it may be too late to do anything about it.

As a Swift developer,
there's a good chance that you've been hit by integer type conversion errors
and thought
"I wish these warnings would go away and my code would finally compile."

If that sounds familiar,
you'll happy to learn about `numericCast(_:)`,
a small utility function in the Swift Standard Library
that may be exactly what you were hoping for.
But be careful what you wish for,
it might just come true.

---

Let's start by dispelling any magical thinking
about what `numericCast(_:)` does by
[looking at its implementation](https://github.com/apple/swift/blob/7f7b4f12d3138c5c259547c49c3b41415cd4206e/stdlib/public/core/Integers.swift#L3508-L3510):

```swift
public func numericCast<T : BinaryInteger, U : BinaryInteger>(_ x: T) -> U {
  return U(x)
}
```

(As we learned in [our article about `Never`](/never),
even the smallest amount of Swift code can have a big impact.)

The [`BinaryInteger`](https://developer.apple.com/documentation/swift/binaryinteger) protocol
was introduced in Swift 4
as part of an overhaul to how numbers work in the language.
It provides a unified interface for working with integers,
both signed and unsigned, and of all shapes and sizes.

When you convert an integer value to another type,
it's possible that the value can't be represented by that type.
This happens when you try to convert a signed integer
to an unsigned integer (for example, `-42` as a `UInt`),
or when a value exceeds the representable range of the destination type
(for example, `UInt8` can only represent numbers between `0` and `255`).

`BinaryInteger` defines four strategies of conversion between integer types,
each with different behaviors for handling out-of-range values:

- **Range-Checked Conversion**
  ([`init(_:)`](https://developer.apple.com/documentation/swift/binaryinteger/2885704-init))
  - Trigger a runtime error for out-of-range values
- **Exact Conversion**
  ([`init?(exactly:)`](https://developer.apple.com/documentation/swift/binaryinteger/2925955-init))
  - Return `nil` for out-of-range values
- **Clamping Conversion**
  ([`init(clamping:)`](https://developer.apple.com/documentation/swift/binaryinteger/2886143-init))
  - Use the closest representable value for out-of-range values
- **Bit Pattern Conversion**
  ([`init(truncatingIfNeeded:)`](https://developer.apple.com/documentation/swift/binaryinteger/2925529-init))
  - Truncate to the width of the target integer type

The correct conversion strategy
depends on the situation in which it's being used.
Sometimes it's desireable to clamp values to a representable range;
other times, it's better to get no value at all.
In the case of `numericCast(_:)`,
range-checked conversion is used for convenience.
The downside is that
calling this function with out-of-range values
causes a runtime error
(specifically, it traps on overflow in `-O` and `-Onone`).

{% info %}

For more information about the changes to how numbers work in Swift 4,
see [SE-0104: "Protocol-oriented integers"](https://github.com/apple/swift-evolution/blob/master/proposals/0104-improved-integers.md).

This subject is also discussed at length in the
[Flight School Guide to Numbers](https://gumroad.com/l/swift-numbers).

{% endinfo %}

## Thinking Literally, Thinking Critically

Before we go any further,
let's take a moment to talk about integer literals.

[As we've discussed in previous articles](https://nshipster.com/swift-literals/),
Swift provides a convenient and extensible way to represent values in source code.
When used in combination with the language's use of type inference,
things often "just work"
...which is nice and all, but can be confusing when things "just don't".

Consider the following example
in which arrays of signed and unsigned integers
are initialized from identical literal values:

```swift
let arrayOfInt: [Int] = [1, 2, 3]
let arrayOfUInt: [UInt] = [1, 2, 3]
```

Despite their seeming equivalence,
we can't, for example, do this:

```swift
arrayOfInt as [UInt] // Error: Cannot convert value of type '[Int]' to type '[UInt]' in coercion
```

One way to reconcile this issue
would be to pass the `numericCast` function as an argument to `map(_:)`:

```swift
arrayOfInt.map(numericCast) as [UInt]
```

This is equivalent to passing the `UInt` range-checked initializer directly:

```swift
arrayOfInt.map(UInt.init)
```

But let's take another look at that example,
this time using slightly different values:

```swift
let arrayOfNegativeInt: [Int] = [-1, -2, -3]
arrayOfNegativeInt.map(numericCast) as [UInt] // 🧞‍ Fatal error: Negative value is not representable
```

As a run-time approximation of compile-time type functionality
`numericCast(_:)` is closer to `as!` than `as` or `as?`.

Compare this to what happens if you instead pass
the exact conversion initializer, `init?(exactly:)`:

```swift
let arrayOfNegativeInt: [Int] = [-1, -2, -3]
arrayOfNegativeInt.map(UInt.init(exactly:)) // [nil, nil, nil]
```

`numericCast(_:)`, like its underlying range-checked conversion,
is a blunt instrument,
and it's important to understand what tradeoffs you're making
when you decide to use it.

## The Cost of Being Right

In Swift,
the general guidance is to use `Int` for integer values
(and `Double` for floating-point values)
unless there's a _really_ good reason to use a more specific type.
Even though the `count` of a `Collection` is nonnegative by definition,
we use `Int` instead of `UInt`
because the cost of going back and forth between types
when interacting with other APIs
outweighs the potential benefit of a more precise type.
For the same reason,
it's almost always better to represent even small number,
like [weekday numbers](/datecomponents),
with an `Int`,
despite the fact that any possible value would fit into an 8-bit integer
with plenty of room to spare.

The best argument for this practice
is a 5-minute conversation with a C API from Swift.

Older and lower-level C APIs are rife with
architecture-dependent type definitions
and finely-tuned value storage.
On their own, they're manageable.
But on top of all the other inter-operability woes
like headers to pointers,
they can be a breaking point for some
(and I don't mean the debugging kind).

`numericCast(_:)` is there for when you're tired of seeing red
and just want to get things to compile.

## Random Acts of Compiling

The [example in the official docs](https://developer.apple.com/documentation/swift/2884564-numericcast)
should be familiar to many of us:

Prior to [SE-0202](https://github.com/apple/swift-evolution/blob/master/proposals/0202-random-unification.md),
the standard practice for generating numbers in Swift (on Apple platforms)
involved importing the `Darwin` framework
and calling the `arc4random_uniform(3)` function:

```c
uint32_t arc4random_uniform(uint32_t __upper_bound)
```

`arc4random` requires not one but two separate type conversions in Swift:
first for the upper bound parameter (`Int` → `UInt32`)
and second for the return value (`UInt32` → `Int`):

```swift
import Darwin

func random(in range: Range<Int>) -> Int {
    return Int(arc4random_uniform(UInt32(range.count))) + range.lowerBound
}
```

_Gross._

By using `numericCast(_:)`, we can make things a little more readable,
albeit longer:

```swift
import Darwin

func random(in range: Range<Int>) -> Int {
    return numericCast(arc4random_uniform(numericCast(range.count))) + range.lowerBound
}
```

`numericCast(_:)` isn't doing anything here
that couldn't otherwise be accomplished with type-appropriate initializers.
Instead, it serves as an indicator
that the conversion is perfunctory ---
the minimum of what's necessary to get the code to compile.

But as we've learned from our run-ins with genies,
we should be careful what we wish for.

Upon closer inspection,
it's apparent that the example usage of `numericCast(_:)` has a critical flaw:
_it traps on values that exceed `UInt32.max`!_

```swift
random(in: 0..<0x1_0000_0000) // 🧞‍ Fatal error: Not enough bits to represent the passed value
```

If we [look at the Standard Library implementation](https://github.com/apple/swift/blob/7f7b4f12d3138c5c259547c49c3b41415cd4206e/stdlib/public/core/Integers.swift#L2537-L2560)
that now lets do `Int.random(in: 0...10)`,
we'll see that it uses clamping, rather than range-checked, conversion.
And instead of delegating to a convenience function like `arc4random_uniform`,
it [populates values from a buffer of random bytes](https://github.com/apple/swift/blob/7f7b4f12d3138c5c259547c49c3b41415cd4206e/stdlib/public/core/Random.swift#L156-L177).

---

Getting code to compile is different than doing things correctly.
But sometimes it takes the former to ultimately get to the latter.
When used judiciously,
`numericCast(_:)` is a convenient tool to resolve issues quickly.
It also has the added benefit of
signaling potential misbehavior more clearly than
a conventional type initializer.

Ultimately, programming is about describing _exactly_ what we want ---
often with painstaking detail.
There's no genie-equivalent CPU instruction for "Do the Right Thing"
(and even if there was,
[would we really trust it](https://github.com/FixIssue/FixCode)?)
Fortunately for us,
Swift allows us to do this in a way that's
safer and more concise than many other languages.
And honestly, who could wish for anything more?
