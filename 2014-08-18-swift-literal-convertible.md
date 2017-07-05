---
title: Swift Literal Convertibles
author: Mattt Thompson
translator: Chester Liu
category: Swift
tags: swift
excerpt: "上周我们探讨了如何在 Swift 中重载和创建自定义操作符，这个语言特性十分强大，同时也颇具争议。从各方面来看，本周的文章也恐将两极分化，因为它的内容是 Swift 当中一个无处不在，然而又不被人注意的特性：字面值可转换性。"
status:
    swift: 1.2
---

上周我们探讨了如何在 Swift 中 [重载和创建自定义操作符](http://nshipster.cn/swift-operators/)，这个语言特性十分强大，同时也颇具争议。

从各方面来看，本周的文章也恐将两极分化，因为它的内容是 Swift 当中一个无处不在，然而又不被人注意的特性：字面值可转换性。

* * *

在代码当中，一个 _字面值_ 是一个固定值的表示。绝大部分语言都为一些基本类型定义了字面值，包括逻辑值，数字，字符串等，通常也有数组和字典。

```swift
let int = 57
let float = 6.02
let string = "Hello"
```

字面值对于开发者而言，是编程时已经根深蒂固的一个概念，以至于我们当中的大多数人不会去主动思考编译器真正做了些什么（因此也并不了解类似 [字符串驻留](http://en.wikipedia.org/wiki/String_interning) 等巧妙的技巧，一种幸福的无知）。

简单了解一下这些最基础的内容，有助于让代码变得更加好读好写。

在 Swift 中，通过 _字面值可转换协议（literal convertible protocols）_ ，开发者可以控制通过字面值创建值的过程。

标准库定义了 10 个这种协议：

- `ArrayLiteralConvertible`
- `BooleanLiteralConvertible`
- `DictionaryLiteralConvertible`
- `ExtendedGraphemeClusterLiteralConvertible`
- `FloatLiteralConvertible`
- `NilLiteralConvertible`
- `IntegerLiteralConvertible`
- `StringLiteralConvertible`
- `StringInterpolationConvertible`
- `UnicodeScalarLiteralConvertible`

任意遵循了上面某个协议的 `class` 或 `struct` 都可以通过对应的字面值来静态初始化一个自己的实例。

这个特性使得字面值在整个语言中都能够玩得转。

以 optionals 做为例子。

## NilLiteralConvertible 和 Optionals

有关 Swift 的 optionals 最好的一点就是，它的底层机制实际上是使用语言自身定义的：

```swift
enum Optional<T> : Reflectable, NilLiteralConvertible {
    case None
    case Some(T)
    init()
    init(_ some: T)
    init(nilLiteral: ())

    func map<U>(f: (T) -> U) -> U?
    func getMirror() -> MirrorType
}
```

注意 `Optional` 遵循了 `NilLiteralConvertible` 接口：

```swift
protocol NilLiteralConvertible {
    init(nilLiteral: ())
}
```

考虑下面两个语句：

```swift
var a: AnyObject = nil // !
var b: AnyObject? = nil
```

`var a` 的声明会导致编译器报警 `Type 'AnyObject' does not conform to the protocol 'NilLiteralConvertible`，而 `var b` 的声明可以正常工作。

从底层看来，当一个字面值被赋值的时候，Swift 编译器查询对应的 `protocol`（在这里是 `NilLiteralConvertible`），然后调用对应的初始化器（`init(nilLiteral: ())`）。

尽管 `init(nilLiteral: ())` 的实现没有公开，最终的结果是，被设置为 `nil` 的 `Optional` 变成了 `.None`。

## StringLiteralConvertible 和正则表达式

Swift 字面值可转换性可以用来为自定义对象提供方便的快速初始化方法。

回忆一下我们上周的 [`Regex`](http://nshipster.cn/swift-operators/) 例子：

```swift
struct Regex {
    let pattern: String
    let options: NSRegularExpressionOptions!

    private var matcher: NSRegularExpression {
        return NSRegularExpression(pattern: self.pattern, options: self.options, error: nil)
    }

    init(pattern: String, options: NSRegularExpressionOptions = nil) {
        self.pattern = pattern
        self.options = options
    }

    func match(string: String, options: NSMatchingOptions = nil) -> Bool {
        return self.matcher.numberOfMatchesInString(string, options: options, range: NSMakeRange(0, string.utf16Count)) != 0
    }
}
```

有 Ruby 和 Perl 背景的程序员可能会对 Swift 缺少正则表达式字面值感到失望，这个缺憾可以使用 `StringLiteralConvertible` 协议来弥补：
 
```swift
extension Regex: StringLiteralConvertible {
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.pattern = "\(value)"
    }
    
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.pattern = value
    }
    
    init(stringLiteral value: StringLiteralType) {
        self.pattern = value
    }
}
```

> `StringLiteralConvertible` 自身继承自 `ExtendedGraphemeClusterLiteralConvertible` 协议，这个协议又继承自 `UnicodeScalarLiteralConvertible`。`ExtendedGraphemeClusterLiteralType` 是表示长度为 1 的 `String` 的内部类型，`UnicodeScalarLiteralType` 是表示一个 `Character` 的数据类型。为了实现必要的 `init` 方法，`ExtendedGraphemeClusterLiteralType` 和 `UnicodeScalarLiteralType` 可以分别用 `typealias` 定义成别名 `StringLiteralType` 和 `Character`。

现在我们可以这么做：

```swift
let string: String = "foo bar baz"
let regex: Regex = "foo"

regex.match(string) // true
```

...或者更简单一些：

```swift
"foo".match(string) // true
```

和 [自定义运算符 `=~`](http://nshipster.cn/swift-operators) 结合起来，还可以写成更加符合习惯的语法：

```swift
"foo bar baz" =~ "foo" // true
```

---

有些人可能会叹息，认为这个特性标志着代码可读性和可理解性的终结，另外一些人可能只是认为它弥补了这门新语言当中缺失的一部分。

主要问题还是在于你之前的习惯，以及你是否认同开发者有资格为语言添加特性，以更好地满足自己的需求。

> 不管怎样，我希望我们都能认同一点——这个语言特性 _很有趣_ ，而且值得深入挖掘。在这样的精神下，我们继续探索的路程，进一步展示更多的用例。

---

## ArrayLiteralConvertible 和 Sets

作为一个对不可变性和安全性有着深刻要求的语言，Swift 的标准库当中并没有内建的集合类型支持，这多少有点奇怪。

数组很好用，我懂，但是却没有集合的 `O(1)` 复杂度查询和幂等性 ... _\*叹息声\*_

所以下面带来一个 `Set` 在 Swift 当中可能的实现，使用内置的 `Dictionary` 类型做为下层支持：

```swift
struct Set<T: Hashable> {
    typealias Index = T
    private var dictionary: [T: Bool] = [:]

    var count: Int {
        return self.dictionary.count
    }

    var isEmpty: Bool {
        return self.dictionary.isEmpty
    }

    func contains(element: T) -> Bool {
        return self.dictionary[element] ?? false
    }

    mutating func put(element: T) {
        self.dictionary[element] = true
    }

    mutating func remove(element: T) -> Bool {
        if self.contains(element) {
            self.dictionary.removeValueForKey(element)
            return true
        } else {
            return false
#         }
    }
}
```

> 一个实际使用的，标准库水平的 `Set` 实现带有的 Swift 风格特性会 _多出许多_ ，例如生成器，序列和各种各样协议的行为。这些内容就足以单独写一篇文章来介绍了。

当然，一个标准集合类型只有好用才显得有用。`NSSet` 运气并不好，没有受到一等公民的待遇，像数组和字典那样在 [Apple LLVM Compiler 4.0](http://clang.llvm.org/docs/ObjectiveCLiterals.html) 当中加入对于字面值语法的支持，但是我们可以使用 `ArrayLiteralConvertible` 协议来纠正这个错误：

```swift
protocol ArrayLiteralConvertible {
    typealias Element
    init(arrayLiteral elements: Element...)
}
```

扩展 `Set` 类型来遵循这个协议的做法很简明直接：

```swift
extension Set: ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        for element in elements {
            put(element)
        }
    }
}
```

这就足够了，现在我们已经实现了想达到的效果：

```swift
let set: Set = [1,2,3]
set.contains(1) // true
set.count // 3
```

> 然而这个例子也凸显了字面值可转换特性的一个值得担忧的地方：**类型推导歧义**。因为像 `Array` 和 `Set` 这样的集合类型之间有大量的 API 是重复的，很容易写出具有歧义的代码，即在类型不同时具有不同表现（例如，集合添加元素是幂等的，而数组则是增加的，因此添加两个相同的元素之后 count 的值会出现差异）。

## StringLiteralConvertible 和 URLs

Alright, one last example creative use of literal convertibles: URL literals.

好了，最后一个富有创意的字面值可转换性用法：URL 字面值。

`NSURL` 是 URL 加载系统的法定”通货“，它有优秀的符合 [RFC 2396](https://www.ietf.org/rfc/rfc2396.txt) 的内部组件自省特性。不幸的是，它太难初始化了，以至于第三方框架的作者们往往选择放弃它，去使用差一些但是更加方便的字符串类型作为方法参数。

在 `NSURL` 上使用一个简单的扩展，就可以兼顾两者的好处了：

```swift
extension NSURL: StringLiteralConvertible {
    public class func convertFromExtendedGraphemeClusterLiteral(value: String) -> Self {
        return self(string: value)
    }

    public class func convertFromStringLiteral(value: String) -> Self {
        return self(string: value)
    }
}
```

字面值可转换性的另一个不错的特性是，类型推导甚至不需要变量定义也可以工作：

```swift
"http://nshipster.com/".host // nshipster.com
```

* * *

作为社区中的一员，判断 Swift 的功能当中哪些是特性，哪些是 bug 正是我们的责任。我们来决定哪些设计是模式，哪些设计是反模式，哪些是惯例，哪些是危险用法。

诸如字面值可转换性，自定义操作符，和其它所有的 Swift 功能将来会如何协调工作，现在还尚不清晰。这个网站的文章在某些时候会对事情应该怎么做进行一些规定性的说明，但是对于这篇文章而言，并不是这种情况。

接下来要做的事情就是探索和学习。
