---
title: Swift Default Protocol Implementations
author: Mattt Thompson
translator: Chester Liu
category: Swift
tags: swift
excerpt: "协议是 Swift 当中泛型实现的基础，然而 Swift 中却缺少内建的提供方法默认实现的机制。不过仍然有一种办法可以解决这个问题，这个办法之前你可能没有留意到。"
status:
    swift: 1.2
---

从 Swift 发布到现在已经过去三个月了，对于我们当中的很多人来说，Swift 的发布在整个职业生涯中都算是最令人震惊和激动的事件之一了。在这中间的几个月当中，可以说我们对于这门语言的理解和感激程度有了长足的变化。

首先是热恋期，我们所有的心思都放在外表上，专注于那些浮于表面的特性，例如 Unicode 支持（`let 🐶🐮`!）和全新的现代化的语法。仔细想想，客观上讲，就连这门语言的 _名字_ 都比它的前辈要好。

几个星期之后，有了多次翻阅 Swift 指南的经历，我们开始去理解这门全新的多范式语言底层的内涵。函数式编程的狂热追随者开始支持这门语言。我们终于能够把 `class` 和 `struct` 的区别理解清楚，在这一路上也发现了一些小的技巧，例如 [自定义操作符](http://nshipster.cn/swift-operators/)  和 [字符串可转换性](http://nshipster.cn/swift-literal-convertible/)。所有最初的那些激动心情现在可以被转换成生产力，体现在新的应用，库和教程当中。

下周的公告标志着 iOS 和 OS X 开发者夏天的结束。是时候结束实验，开始实践了。

不过别急，我们还有几天宽裕的时间。让我们再继续学习一些知识：

---

泛型是 Swift 的重要特性。和这门语言强大的类型系统相结合，泛型允许开发者编写出和 Objective-C 中相比更加安全，性能更高的代码，

泛型底层的机制是协议。一个 Swift 协议，和一个 Objective-C [`@protocol`](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithProtocols/WorkingwithProtocols.html) 相似，定义了需要被实现的方法和属性。

> 在面向对象范式当中，类型往往和类的身份是一体的。**而在 Swift 编程中，首先考虑使用 _协议_ 来实现多态，其次再考虑使用继承。**

不管是在 Swift 中还是 Objective-C 中，协议都有一个重要的缺陷，就是缺少内置的方法默认实现，在其他语言中这种特性可能会通过 [mixins](http://en.wikipedia.org/wiki/Mixin) 或者 [traits](http://en.wikipedia.org/wiki/Trait_%28computer_programming%29) 实现。

...不过故事到这里还没有结束。Swift 和它诞生时相比，多了一些 [面向切面](http://en.wikipedia.org/wiki/Aspect-oriented_programming) 的特征。

考虑下面在标准库中被广泛使用的 `Equatable` 协议：

~~~{swift}
protocol Equatable {
    func ==(lhs: Self, rhs: Self) -> Bool
}
~~~

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

这些都准备就绪之后，让我们看看 `Equatable` 是如何工作的：

~~~{swift}
let title = "Swift Custom Operators: Syntactic Sugar or Menace to Society?"
let body = "..."

let a = Article(title: title, body: body)
let b = Article(title: title, body: body)

a == b // true
a != b // false
~~~

等等... `!=` 是从哪里出来的？

`!=` 并没有定义在 `Equatable` 协议当中，而且也肯定没有在 `Article` 中实现。到底怎么回事？

`!=` 实际上是在标准库当中的这个方法里实现的：

~~~{swift}
func !=<T : Equatable>(lhs: T, rhs: T) -> Bool
~~~

由于 `!=` 是 `Equatable` 的泛型方法，任何遵循 `Equatable` 的类型，包括 `Article`，都自动得到了使用 `!=` 操作符的能力。

如果我们想要做的话，可以重载 `!=` 的实现：

~~~{swift}
func !=(lhs: Article, rhs: Article) -> Bool {
    return !(lhs == rhs)
}
~~~

对于相等检验来说，我们不太可能提供比 `==` 的否定检查更加高效的方法，不过这种重载在某些情况下可能是有用处的。Swift 的类型推断系统允许更加准确的声明，用于覆盖掉泛型或者隐式的对应声明。

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

当想要在已有的架构上进行扩展时，通过这种方法来实现功能，可以大幅度地减少对于模板代码的需求。

## 方法默认实现

前面提到的技术只能用于操作符。对于协议当中的方法来说，提供默认实现相对来说要麻烦一些。

对于一个协议 `P` 来说，它有一个方法 `m()`，这个方法以一个 `Int` 作为参数。

~~~{swift}
protocol P {
    func m(arg: Int)
}
~~~

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

> 协议中注释掉的代码用于在方法实现和使用者之间进行交互。

---

上面这些内容都指向了 Swift 当中方法和函数之间的冲突关系。

面向对象范式所基于的思想是，对象封装状态和行为。然而在 Swift 当中，在 `struct` 或者 `class` 内部把某些泛型函数实现成方法是不可能的。

以 `contains` 方法为例：

~~~{swift}
func contains<S : SequenceType where S.Generator.Element : Equatable>(seq: S, x: S.Generator.Element) -> Bool
~~~

因为序列生成器的元素被限定为 `Equatable`，这个方法不能被定义在泛型容器上，除非要求容器中的元素都遵循 `Equatable`。

把 `contains`，`advance` 和 `partition` 这些方法降级成顶层函数会损害标准库 。这样做不仅仅使得方法自动补全功能失效，同时还使得 API 出现了横跨面向对象和函数式编程两种范式的分裂现象。

尽管这个问题在 1.0 的时候不太可能被解决掉（同时也有很多更加紧急的事情需要解决），解决办法还是有很多的：

- 提供 mixin 或者 trait 功能，能够对协议进行扩展，允许提供默认实现。
- 允许 extensions 带有泛型参数，通过类型 `extension Array<T: Equatable>` 这种形式来定义额外的方法，例如 `func contains(x: T)`，这个 extension 只有当有关类型满足特定条件时才可用。 
- 在函数调用时自动把 `Self` 设置为第一个参数，使得 `self` 可以被隐式使用。
