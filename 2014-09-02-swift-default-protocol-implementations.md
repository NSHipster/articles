---
title: Swift Default Protocol Implementations
author: Mattt Thompson
category: Swift
tags: swift
excerpt: "Protocols are the foundation of generics in Swift, but suffer from the lack of a built-in way to provide default implementations for methods. However, there is an interesting workaround in Swift that you probably haven't noticed."
status:
    swift: 1.2
---

Swift was announced 3 months ago to the day. For many of us, it was among the most shocking and exciting events in our professional lives. In these intervening months, it's safe to say our collective understanding and appreciation of the language has evolved and changed significantly.

First came the infatuation period. We fixated on appearances, on surface-level features like Unicode support (`let 🐶🐮`!) and its new, streamlined syntax. Hell, even its _name_ was objectively better than its predecessor's.

Within a few weeks, though, after having a chance to go through the Swift manual a few times, we started to understand the full implications of this new multi-paradigm language. All of those folks who had affected the zealotry of functional programmers in order to sound smarter (generics!) learned enough to start backing it up. We finally got the distinction between `class` and `struct` down, and picked up a few tricks like [custom operators](http://nshipster.com/swift-operators/) and [literal convertibles](http://nshipster.com/swift-literal-convertible/) along the way. All of that initial excitement could now be channeled productively into apps and libraries and tutorials.

Next week's announcement effectively marks the end of the summer for iOS & OS X developers. It's time to reign in our experimentation and start shipping again.

But hey, we have another few days before things get real again. Let's learn a few more things:

---

Generics are the defining feature of Swift. Working in coordination with the language's powerful type system, a developer can write safer and more performant code than was ever possible with Objective-C.

The underlying mechanism for generics are protocols. A Swift protocol, like an Objective-C [`@protocol`](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html) declares methods and properties to be implemented in order to conform to it.

> Within the Object-Oriented paradigm, types are often conflated with class identity. **When programming in Swift, though, think about polymorphism through _protocols_ first, before resorting to inheritance.**

The one major shortcoming of protocols, both in Swift and Objective-C, is the lack of a built-in way to provide default implementations for methods, as one might accomplish in other languages with [mixins](http://en.wikipedia.org/wiki/Mixin) or [traits](http://en.wikipedia.org/wiki/Trait_%28computer_programming%29).

...but that's not the end of the story. Swift is a fair bit more [Aspect-Oriented](http://en.wikipedia.org/wiki/Aspect-oriented_programming) than it initially lets on.

Consider the `Equatable` protocol, used throughout the standard library:

~~~{swift}
protocol Equatable {
    func ==(lhs: Self, rhs: Self) -> Bool
}
~~~

Given an `Article` `struct` with a `title` and `body` field, implementing `Equatable` is straightforward:

~~~{swift}
struct Article {
    let title: String
    let body: String
}

extension Article: Equatable {}

func ==(lhs: Article, rhs: Article) -> Bool {
    return lhs.title == rhs.title && lhs.body == rhs.body
}
~~~

With everything in place, let's show `Equatable` in action:

~~~{swift}
let title = "Swift Custom Operators: Syntactic Sugar or Menace to Society?"
let body = "..."

let a = Article(title: title, body: body)
let b = Article(title: title, body: body)

a == b // true
a != b // false
~~~

Wait... where did `!=` come from?

`!=` isn't defined by the `Equatable` protocol, and it's certainly not implemented for `Article`. So what's going on?

`!=` is actually drawing its implementation from this function in the standard library:

~~~{swift}
func !=<T : Equatable>(lhs: T, rhs: T) -> Bool
~~~

Because `!=` is implemented as a generic function for `Equatable`, any type that conforms to `Equatable`, including `Article`, automatically gets the `!=` operator as well.

If we really wanted to, we could override the implementation of `!=`:

~~~{swift}
func !=(lhs: Article, rhs: Article) -> Bool {
    return !(lhs == rhs)
}
~~~

For equality, it's unlikely that we could offer something more efficient than the negation of the provided `==` check, but this might make sense in other cases. Swift's type inference system allows more specific declarations to trump any generic or implicit candidates.

The standard library uses generic operators all over the place, like for bitwise operations:

~~~{swift}
protocol BitwiseOperationsType {
    func &(_: Self, _: Self) -> Self
    func |(_: Self, _: Self) -> Self
    func ^(_: Self, _: Self) -> Self
    prefix func ~(_: Self) -> Self

    class var allZeros: Self { get }
}
~~~

Implementing functionality in this way significantly reduces the amount of boilerplate code needed to build on top of existing infrastructure.

## Default Implementation of Methods

However, the aforementioned technique only really works for operators. Providing a default implementation of a protocol method is less convenient.

Consider a protocol `P` with a method `m()` that takes a single `Int` argument:

~~~{swift}
protocol P {
    func m(arg: Int)
}
~~~

The closest one can get to a default implementation is to provide a top-level generic function that takes explicit `self` as the first argument:

~~~{swift}
protocol P {
    func m() /* {
        f(self)
    }*/
}

func f<T: P>(_ arg: T) {
    // ...
}
~~~

> The commented-out code in the protocol helps communicate the provided functional implementation to the consumer.

---

All of this highlights a significant tension between methods and functions in Swift.

The Object-Oriented paradigm is based around the concept of objects that encapsulate both state and behavior. However, in Swift, it's simply impossible to implement certain generic functions as methods on the `struct` or `class` itself.

Take, for instance, the `contains` method:

~~~{swift}
func contains<S : SequenceType where S.Generator.Element : Equatable>(seq: S, x: S.Generator.Element) -> Bool
~~~

Because of the constraint on the element of the sequence generator being `Equatable`, this cannot be declared on a generic container, without thereby requiring elements in that collection to conform to `Equatable`.

Relegating behavior like `contains`, `advance`, or `partition` to top-level functions does a  disservice to the standard library. Not only does it hide functionality from method autocompletion, but it fragments the API across a Object-Oriented and Functional paradigms.

Although it's unlikely that this will be resolved in time for 1.0 (and there are certainly more pressing matters), there are a number of ways this could be resolved:

- Provide mixin or trait functionality that extend protocols to allow them to provide default implementations.
- Allow extensions with generic arguments, such that something like `extension Array<T: Equatable>` could define additional methods, like `func contains(x: T)`, that are only available to associated types that match a particular criteria.
- Automatically bridge function calls with `Self` as the first argument to be available as methods using implicit `self`.
