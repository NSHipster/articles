---
title: Swift Default Protocol Implementations
author: Mattt Thompson
translator: Chester Liu
category: Swift
tags: swift
excerpt: "Protocols are the foundation of generics in Swift, but suffer from the lack of a built-in way to provide default implementations for methods. However, there is an interesting workaround in Swift that you probably haven't noticed."
excerpt: "协议是 Swift 当中泛型实现的基础，然而 Swift 中却缺少内建的提供方法默认实现的机制。不过仍然有一种办法可以解决这个问题，这个办法之前你可能没有留意到。"
status:
    swift: 1.2
---

Swift was announced 3 months ago to the day. For many of us, it was among the most shocking and exciting events in our professional lives. In these intervening months, it's safe to say our collective understanding and appreciation of the language has evolved and changed significantly.

从 Swift 发布到现在已经过去三个月了，对于我们当中的很多人来说，Swift 的发布在整个职业生涯中都算是最令人震惊和激动的事件之一了。在这中间的几个月当中，可以说我们对于这门语言的理解和感激程度有了长足的变化。

First came the infatuation period. We fixated on appearances, on surface-level features like Unicode support (`let 🐶🐮`!) and its new, streamlined syntax. Hell, even its _name_ was objectively better than its predecessor's.

首先是热恋期，我们所有的心思都放在外表上，专注于那些浮于表面的特性，例如 Unicode 支持（`let 🐶🐮`!）和全新的现代化的语法。仔细想想，客观上讲，就连这门语言的 _名字_ 都比它的前辈要好。

Within a few weeks, though, after having a chance to go through the Swift manual a few times, we started to understand the full implications of this new multi-paradigm language. All of those folks who had affected the zealotry of functional programmers in order to sound smarter (generics!) learned enough to start backing it up. We finally got the distinction between `class` and `struct` down, and picked up a few tricks like [custom operators](http://nshipster.com/swift-operators/) and [literal convertibles](http://nshipster.com/swift-literal-convertible/) along the way. All of that initial excitement could now be channeled productively into apps and libraries and tutorials.

几个星期之后，有了多次翻阅 Swift 指南的经历，我们开始去理解这门全新的多范式语言底层的内涵。函数式编程的狂热追随者开始支持这门语言。我们终于能够把 `class` 和 `struct` 的区别理解清楚，在这一路上也发现了一些小的技巧，例如 [自定义操作符](http://nshipster.cn/swift-operators/)  和 [字符串可转换性](http://nshipster.cn/swift-literal-convertible/)。所有最初的那些激动心情现在可以被转换成生产力，体现在新的应用，库和教程当中。

Next week's announcement effectively marks the end of the summer for iOS & OS X developers. It's time to reign in our experimentation and start shipping again.

下周的公告标志着 iOS 和 OS X 开发者夏天的结束。是时候结束实验，开始实践了。

But hey, we have another few days before things get real again. Let's learn a few more things:

不过别急，我们还有几天宽裕的时间。让我们再继续学习一些知识：

---

Generics are the defining feature of Swift. Working in coordination with the language's powerful type system, a developer can write safer and more performant code than was ever possible with Objective-C.

泛型是 Swift 的重要特性。和这门语言强大的类型系统相结合，泛型允许开发者编写出和 Objective-C 中相比更加安全，性能更高的代码，

The underlying mechanism for generics are protocols. A Swift protocol, like an Objective-C [`@protocol`](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html) declares methods and properties to be implemented in order to conform to it.

泛型底层的机制是协议。一个 Swift 协议，和一个 Objective-C [`@protocol`](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html) 相似，定义了需要被实现的方法和属性。

> Within the Object-Oriented paradigm, types are often conflated with class identity. **When programming in Swift, though, think about polymorphism through _protocols_ first, before resorting to inheritance.**

> 在面向对象范式当中，类型往往和类的身份是一体的。**而在 Swift 编程中，首先考虑使用 _协议_ 来实现多态，其次再考虑使用继承。**

The one major shortcoming of protocols, both in Swift and Objective-C, is the lack of a built-in way to provide default implementations for methods, as one might accomplish in other languages with [mixins](http://en.wikipedia.org/wiki/Mixin) or [traits](http://en.wikipedia.org/wiki/Trait_%28computer_programming%29).

不管是在 Swift 中还是 Objective-C 中，协议都有一个重要的缺陷，就是缺少内置的方法默认实现，在其他语言中这种特性可能会通过 [mixins](http://en.wikipedia.org/wiki/Mixin) 或者 [traits](http://en.wikipedia.org/wiki/Trait_%28computer_programming%29) 实现。

...but that's not the end of the story. Swift is a fair bit more [Aspect-Oriented](http://en.wikipedia.org/wiki/Aspect-oriented_programming) than it initially lets on.

...不过故事到这里还没有结束。Swift 和它诞生时相比，多了一些 [面向切面](http://en.wikipedia.org/wiki/Aspect-oriented_programming) 的特征。

Consider the `Equatable` protocol, used throughout the standard library:

考虑下面在标准库中被广泛使用的 `Equatable` 协议：

~~~{swift}
protocol Equatable {
    func ==(lhs: Self, rhs: Self) -> Bool
}
~~~

Given an `Article` `struct` with a `title` and `body` field, implementing `Equatable` is straightforward:

给出一个 `Article` 结构体，其中有 `title` 和 `body` 属性，实现 `Equatable` 的方法简单直接：

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

这些都准备就绪之后，让我们看看 `Equatable` 是如何工作的：

~~~{swift}
let title = "Swift Custom Operators: Syntactic Sugar or Menace to Society?"
let body = "..."

let a = Article(title: title, body: body)
let b = Article(title: title, body: body)

a == b // true
a != b // false
~~~

Wait... where did `!=` come from?

等等... `!=` 是从哪里出来的？

`!=` isn't defined by the `Equatable` protocol, and it's certainly not implemented for `Article`. So what's going on?

`!=` 并没有定义在 `Equatable` 协议当中，而且也肯定没有在 `Article` 中实现。到底怎么回事？

`!=` is actually drawing its implementation from this function in the standard library:

`!=` 实际上是在标准库当中的这个方法里实现的：

~~~{swift}
func !=<T : Equatable>(lhs: T, rhs: T) -> Bool
~~~

Because `!=` is implemented as a generic function for `Equatable`, any type that conforms to `Equatable`, including `Article`, automatically gets the `!=` operator as well.

由于 `!=` 是 `Equatable` 的泛型方法，任何遵循 `Equatable` 的类型，包括 `Article`，都自动得到了使用 `!=` 操作符的能力。

If we really wanted to, we could override the implementation of `!=`:

如果我们想要做的话，可以重载 `!=` 的实现：

~~~{swift}
func !=(lhs: Article, rhs: Article) -> Bool {
    return !(lhs == rhs)
}
~~~

For equality, it's unlikely that we could offer something more efficient than the negation of the provided `==` check, but this might make sense in other cases. Swift's type inference system allows more specific declarations to trump any generic or implicit candidates.

对于相等检验来说，我们不太可能提供比 `==` 的否定检查更加高效的方法，不过这种重载在某些情况下可能是有用处的。Swift 的类型推断系统允许更加准确的声明，用于覆盖掉泛型或者隐式的对应声明。

The standard library uses generic operators all over the place, like for bitwise operations:

标准库中大量使用泛型操作符，例如位运算操作：

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

当想要在已有的架构上进行扩展时，通过这种方法来实现功能，可以大幅度地减少对于模板代码的需求。

## Default Implementation of Methods

## 方法默认实现

However, the aforementioned technique only really works for operators. Providing a default implementation of a protocol method is less convenient.

前面提到的技术只能用于操作符。对于协议当中的方法来说，提供默认实现相对来说要麻烦一些。

Consider a protocol `P` with a method `m()` that takes a single `Int` argument:

对于一个协议 `P` 来说，它有一个方法 `m()`，这个方法以一个 `Int` 作为参数。

~~~{swift}
protocol P {
    func m(arg: Int)
}
~~~

The closest one can get to a default implementation is to provide a top-level generic function that takes explicit `self` as the first argument:

我们能实现的最接近默认实现的办法，是提供一个顶层的泛型函数，它显式地接受 `self` 作为第一个参数：

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

> 协议中注释掉的代码用于在方法实现和使用者之间进行交互。

---

All of this highlights a significant tension between methods and functions in Swift.

上面这些内容都指向了 Swift 当中方法和函数之间的冲突关系。

The Object-Oriented paradigm is based around the concept of objects that encapsulate both state and behavior. However, in Swift, it's simply impossible to implement certain generic functions as methods on the `struct` or `class` itself.

面向对象范式所基于的思想是，对象封装状态和行为。然而在 Swift 当中，在 `struct` 或者 `class` 内部把某些泛型函数实现成方法是不可能的。

Take, for instance, the `contains` method:

以 `contains` 方法为例：

~~~{swift}
func contains<S : SequenceType where S.Generator.Element : Equatable>(seq: S, x: S.Generator.Element) -> Bool
~~~

Because of the constraint on the element of the sequence generator being `Equatable`, this cannot be declared on a generic container, without thereby requiring elements in that collection to conform to `Equatable`.

因为序列生成器的元素被限定为 `Equatable`，这个方法不能被定义在泛型容器上，除非要求容器中的元素都遵循 `Equatable`。

Relegating behavior like `contains`, `advance`, or `partition` to top-level functions does a  disservice to the standard library. Not only does it hide functionality from method autocompletion, but it fragments the API across a Object-Oriented and Functional paradigms.

把 `contains`，`advance` 和 `partition` 这些方法降级成顶层函数会损害标准库 。这样做不仅仅使得方法自动补全功能失效，同时还使得 API 出现了横跨面向对象和函数式编程两种范式的分裂现象。

Although it's unlikely that this will be resolved in time for 1.0 (and there are certainly more pressing matters), there are a number of ways this could be resolved:

尽管这个问题在 1.0 的时候不太可能被解决掉（同时也有很多更加紧急的事情需要解决），解决办法还是有很多的：

- Provide mixin or trait functionality that extend protocols to allow them to provide default implementations.
- 提供 mixin 或者 trait 功能，能够对协议进行扩展，允许提供默认实现。
- Allow extensions with generic arguments, such that something like `extension Array<T: Equatable>` could define additional methods, like `func contains(x: T)`, that are only available to associated types that match a particular criteria.
- 允许 extensions 带有泛型参数，通过类型 `extension Array<T: Equatable>` 这种形式来定义额外的方法，例如 `func contains(x: T)`，这个 extension 只有当有关类型满足特定条件时才可用。 
- Automatically bridge function calls with `Self` as the first argument to be available as methods using implicit `self`.
- 在函数调用时自动把 `Self` 设置为第一个参数，使得 `self` 可以被隐式使用。
