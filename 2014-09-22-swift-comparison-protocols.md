---
layout: post
title: Swift Comparison Protocols
category: "Swift"
translator: Croath Liu
excerpt: "Objective-C 让我们对相等性和唯一性的本质慢慢有了带有哲学色彩的思考。为了解救那些不愿意向论文一样的哲理卑身屈膝的开发者，Swift 为此作出了很多改进。"
---

Objective-C 让我们对相等性和唯一性的本质慢慢有了[带有哲学色彩的思考](http://nshipster.com/equality/)。为了解救那些不愿意向论文一样的哲理卑身屈膝的开发者，Swift 为此作出了很多改进。

在 Swift 中，`Equatable` 是一个基本类型，由此也演变出了 `Comparable` 和 `Hashable` 两种类型。这三个一起组成了这门语言关于对象比较的核心元素。

* * *

## Equatable

`Equatable` 类型的值可以用于判定是否相等。声明一个 `Equatable` 类型有很多好处，尤其是需要比较的值被放进了一个 `Array` 的时候。

要成为一个 `Equatable` 类型，必须实现 `==` 操作符函数，这个函数同时要接受其相应类型的值作为参数：

~~~{swift}
func ==(lhs: Self, rhs: Self) -> Bool
~~~

对于带有多类型的相等，是根据每个类型的元素是否相等来判定的。例如有一个 `Complex` 类型，它带有一个遵从 `SignedNumberType` 类型的 `T` 类型：

> 使用 `SignedNumberType` 作为基本数字类型便捷操作方法，它继承于 `Comparable`（也是一种 `Equatable`，下面的章节会提到）和 `IntegerLiteralConvertible`。`Int`、`Double` 和 `Float` 都遵从这个规则。

~~~{swift}
struct Complex<T: SignedNumberType> {
    let real: T
    let imaginary: T
}
~~~

因为 [复数（complex number）](http://en.wikipedia.org/wiki/Complex_number) 由实部和虚部组成，当且仅当两个复数的两部分均相等时才能说这两个复数相等：

~~~{swift}
extension Complex: Equatable {}

// MARK: Equatable

func ==<T>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
    return lhs.real == rhs.real && lhs.imaginary == rhs.imaginary
}
~~~

结果：

~~~swift
let a = Complex<Double>(real: 1.0, imaginary: 2.0)
let b = Complex<Double>(real: 1.0, imaginary: 2.0)

a == b // true
a != b // false
~~~

> 我们在 [the article about Swift Default Protocol Implementations](http://nshipster.com/swift-default-protocol-implementations/) 提到过，对于 `!=` 的实现会被标准库自动转向到对于 `==` 的实现方法上。

对于引用类型，相等要通过唯一内存指向来判断。于是世界就更科学了：两个一样的 `Name` 是相等的，但拥有相同名字的两个 `Person` 可能是两个人。

Objective-C 中对于对象的比较，`==` 操作符的运算结果就是来自 `isEqual:` 方法的结果：

~~~{swift}
class ObjCObject: NSObject {}

ObjCObject() == ObjCObject() // false
~~~

对于 Swift 中的引用类型，可以根据 `ObjectIdentifier` 构建对象来判断两个对象是否相等：

~~~{swift}
class Object: Equatable {}

// MARK: Equatable

func ==(lhs: Object, rhs: Object) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

Object() == Object() // false
~~~

## Comparable

在 `Equatable` 基础上建立的 `Comparable` 提供了更具体的不等条件，能够判断左边的值是比右边大还是比右边小。

遵循 `Comparable` 协议的类型应该实现以下几种操作符：

~~~{swift}
func <=(lhs: Self, rhs: Self) -> Bool
func >(lhs: Self, rhs: Self) -> Bool
func >=(lhs: Self, rhs: Self) -> Bool
~~~

这里有一件有趣的事：我们暂时不看_提供_了什么方法，找找什么方法_不见_了？

首先最能引起注意的就是 `==` 不见了，因为 `>=` 是 `>` 和 `==` 的组合。因为 `Comparable` 继承自 `Equatable`，所以它也应该提供 `==` 方法。

其次，如果仔细观察会发现一个细节，同时这也是理解其本质的关键点：`<` 也不见了。“小于” 方法去哪了？其实它在 `_Comparable` 协议中。为什么知道这一点很重要呢？像我们在 [the article about Swift Default Protocol Implementations](http://nshipster.com/swift-default-protocol-implementations/) 中提到的，Swift 标准库提供了完全基于 `_Comparable` 的 `Comparable` 协议。这个设计_简直完美_。因为所有的比较方法都可以仅由 `<` 和 `==` 推论出，这就让实用性大大增加了。

> 与此不同的是 Ruby 中比较操作符的实现方法，它仅由一个 `<=>` （也叫 “UFO 操作符”）操作符来做判断。[这里有写明 Swift 具体是如何实现的](https://gist.github.com/mattt/7e4db72ce1b6c8a18bb4)。

更复杂的样例可以见 `CSSSelector` 结构，它实现了 selector 的 [cascade ordering](http://www.w3.org/TR/CSS2/cascade.html#cascading-order)：

~~~{swift}
import Foundation

struct CSSSelector {
    let selector: String

    struct Specificity {
        let id: Int
        let `class`: Int
        let element: Int

        init(_ components: [String]) {
            var (id, `class`, element) = (0, 0, 0)
            for token in components {
                if token.hasPrefix("#") {
                    id++
                } else if token.hasPrefix(".") {
                    `class`++
                } else {
                    element++
                }
            }

            self.id = id
            self.`class` = `class`
            self.element = element
        }
    }

    let specificity: Specificity

    init(_ string: String) {
        self.selector = string

        // Naïve tokenization, ignoring operators, pseudo-selectors, and `style=`.
        let components: [String] = self.selector.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.specificity = Specificity(components)
    }
}
~~~

我们知道 CSS Selector 是通过评分和顺序来判断相等的，两个 selector 当且仅当它们的评分和顺序都相同时才指向相同元素：

~~~{swift}
extension CSSSelector: Equatable {}

// MARK: Equatable

func ==(lhs: CSSSelector, rhs: CSSSelector) -> Bool {
    // Naïve equality that uses string comparison rather than resolving equivalent selectors
    return lhs.selector == rhs.selector
}
~~~

抛开这种方法，selector 是通过 specificity 来确定相等性的：

~~~{swift}
extension CSSSelector.Specificity: Comparable {}

// MARK: Comparable

func <(lhs: CSSSelector.Specificity, rhs: CSSSelector.Specificity) -> Bool {
    return lhs.id < rhs.id ||
        lhs.`class` < rhs.`class` ||
        lhs.element < rhs.element
}

// MARK: Equatable

func ==(lhs: CSSSelector.Specificity, rhs: CSSSelector.Specificity) -> Bool {
    return lhs.id == rhs.id &&
           lhs.`class` == rhs.`class` &&
           lhs.element == rhs.element
}
~~~

把这些都结合在一起：

> 为了理解的更为清楚，我们这里认为 `CSSSelector` [遵从 `StringLiteralConvertible` 协议](http://nshipster.com/swift-literal-convertible/).

~~~{swift}
let a: CSSSelector = "#logo"
let b: CSSSelector = "html body #logo"
let c: CSSSelector = "body div #logo"
let d: CSSSelector = ".container #logo"

b == c // false
b.specificity == c.specificity // true
c.specificity < a.specificity // false
d.specificity > c.specificity // true
~~~

## Hashable

另一个重要的协议是从 `Equatable` 演变而来的 `Hashable`。

只有 `Hashable` 类型可以被存储在 Swift 的 `Dictionary` 中：

~~~{swift}
struct Dictionary<Key : Hashable, Value> : CollectionType, DictionaryLiteralConvertible { ... }
~~~

一个遵从 `Hashable` 协议的类型必须提供 `hashValue` 属性的 getter。

~~~{swift}
protocol Hashable : Equatable {
    /// Returns the hash value.  The hash value is not guaranteed to be stable
    /// across different invocations of the same program.  Do not persist the hash
    /// value across program runs.
    ///
    /// The value of `hashValue` property must be consistent with the equality
    /// comparison: if two values compare equal, they must have equal hash
    /// values.
    var hashValue: Int { get }
}
~~~

这里如果详解[最佳哈希方法](http://en.wikipedia.org/wiki/Perfect_hash_function) 就远远跑题了，但还好我们不用提及这个，因为大多数值都可以通过 `XOR` 运算来生成比较好的哈希值了。

下面这些 Swift 内建类型都实现了 `hashValue`：

- `Double`
- `Float`, `Float80`
- `Int`, `Int8`, `Int16`, `Int32`, `Int64`
- `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64`
- `String`
- `UnicodeScalar`
- `ObjectIdentifier`

据此也能总结出[生物学中的二项式明明方法](http://en.wikipedia.org/wiki/Binomial_nomenclature)的表示法：

~~~{swift}
struct Binomen {
    let genus: String
    let species: String
}

// MARK: Hashable

extension Binomen: Hashable {
    var hashValue: Int {
        return genus.hashValue ^ species.hashValue
    }
}

// MARK: Equatable

func ==(lhs: Binomen, rhs: Binomen) -> Bool {
    return lhs.genus == rhs.genus && rhs.species == rhs.species
}
~~~

这样就能对某个生物类型去做哈希，进而可以把他们作为其拉丁命名的 key 了：

~~~{swift}
var commonNames: [Binomen: String] = [:]
commonNames[Binomen(genus: "Canis", species: "lupis")] = "Grey Wolf"
commonNames[Binomen(genus: "Canis", species: "rufus")] = "Red Wolf"
commonNames[Binomen(genus: "Canis", species: "latrans")] = "Coyote"
commonNames[Binomen(genus: "Canis", species: "aureus")] = "Golden Jackal"
~~~