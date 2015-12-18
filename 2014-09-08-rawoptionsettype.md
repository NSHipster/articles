---
title: RawOptionSetType
author: Mattt Thompson
translator: Chester Liu
category: Swift
tags: swift
excerpt: "Swift 的枚举类型和 Objective-C 中的 `NS_ENUM` 宏相比是一种显著的进步。不幸的是， `NS_OPTIONS` 就没有那么令人愉快了"
status:
    swift: 1.2
---

在 Objective-C 中，[`NS_ENUM` & `NS_OPTIONS`](http://nshipster.com/ns_enum-ns_options/)被用于注释 C 语言中的 `enum` 类型，它实现的很漂亮，给编译器和开发者都设置了清晰的期望。自从在 Xcode 4.5 中被引进以后，这两个宏已经成为了系统框架中的标准规范，也是社区公认的最佳实践。

在 Swift 中，枚举类型成了和 `struct` 与 `class` 一样的一等语言结构，包含了很多富于表现力的新特性，例如原始类型(raw types)和关联值(associated values)。枚举非常适合于封装一组固定值的封闭集合，开发者们在代码中都很积极地尝试去使用它。

当要在 Swift 中和 Foundation 这样的框架进行交互时，`NS_ENUM` 定义会自动转换成 `enum`。通常情况下和原有的 Objective-C 代码相比，这种转换是一种进步，因为去除了名字当中的重复部分：

~~~{swift}
enum UITableViewCellStyle : Int {
    case Default
    case Value1
    case Value2
    case Subtitle
}
~~~

~~~{objective-c}
typedef NS_ENUM(NSInteger, UITableViewCellStyle) {
   UITableViewCellStyleDefault,
   UITableViewCellStyleValue1,
   UITableViewCellStyleValue2,
   UITableViewCellStyleSubtitle
};
~~~

不幸的是，对于 `NS_OPTIONS` 来说，它的 Swift 替代品可以说是相当糟糕：

~~~{swift}
struct UIViewAutoresizing : RawOptionSetType {
    init(_ value: UInt)
    var value: UInt
    static var None: UIViewAutoresizing { get }
    static var FlexibleLeftMargin: UIViewAutoresizing { get }
    static var FlexibleWidth: UIViewAutoresizing { get }
    static var FlexibleRightMargin: UIViewAutoresizing { get }
    static var FlexibleTopMargin: UIViewAutoresizing { get }
    static var FlexibleHeight: UIViewAutoresizing { get }
    static var FlexibleBottomMargin: UIViewAutoresizing { get }
}
~~~

~~~{objective-c}
typedef NS_OPTIONS(NSUInteger, UIViewAutoresizing) {
   UIViewAutoresizingNone                 = 0,
   UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,
   UIViewAutoresizingFlexibleWidth        = 1 << 1,
   UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
   UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
   UIViewAutoresizingFlexibleHeight       = 1 << 4,
   UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};
~~~

* * *

`RawOptionsSetType` 是 `NS_OPTIONS` 类型在 Swift 当中的替代品（至少是最接近的东西了）。它是一个协议，遵守 `RawRepresentable`, `Equatable`, `BitwiseOperationsType`, 和 `NilLiteralConvertible` 这几个协议。一个选项(option)类型可以用一个遵守 `RawOptionsSetType` 协议的 `struct` 表示。

为什么这货这么差劲？主要是因为 C 语言中位运算的技巧不能用于 Swift 中的枚举类型。一个 `enum` 代表着一系列可用选项的封闭集合，但是并没有内建一个用来表示若干选项的交集的机制。表面上，一个 `enum` 可以定义出选项值所有可能的组合，但是对于 `n > 3` 的情况，组合数学告诉我们这种办法是不靠谱的。在 Swift 中实现 `NS_OPTIONS` 有很多种方式，`RawOptionSetType` 可能还不是最差的。

和语法上清晰而明确的 `enum` 声明相比，`RawOptionsSetType` 显得笨拙而冗长，需要一些模板代码来支持计算属性(computed properties)：

~~~{swift}
struct Toppings : RawOptionSetType, BooleanType {
    private var value: UInt = 0

    init(_ value: UInt) {
        self.value = value
    }

    // MARK: RawOptionSetType

    static func fromMask(raw: UInt) -> Toppings {
        return self(raw)
    }

    // MARK: RawRepresentable

    static func fromRaw(raw: UInt) -> Toppings? {
        return self(raw)
    }

    func toRaw() -> UInt {
        return value
    }

    // MARK: BooleanType

    var boolValue: Bool {
        return value != 0
    }


    // MARK: BitwiseOperationsType

    static var allZeros: Toppings {
        return self(0)
    }

    // MARK: NilLiteralConvertible

    static func convertFromNilLiteral() -> Toppings {
        return self(0)
    }

    // MARK: -

    static var None: Toppings           { return self(0b0000) }
    static var ExtraCheese: Toppings    { return self(0b0001) }
    static var Pepperoni: Toppings      { return self(0b0010) }
    static var GreenPepper: Toppings    { return self(0b0100) }
    static var Pineapple: Toppings      { return self(0b1000) }
}
~~~

> 在 Xcode 6 Beta 6 中，`RawOptionSetType` 不再遵守 `BooleanType` 协议，如果想支持按位检查的话还是需要支持 `BooleanType`。

在 Swift 中这种写法的一个好处是，Swift 内建的二进制整数字面值支持进行视觉上的按位运算。当 options 类型定义完成之后，使用它的语法还不算特别难看。

以下面这个大一些的例子为例：

~~~{swift}
struct Pizza {
    enum Style {
        case Neopolitan, Sicilian, NewHaven, DeepDish
    }

    struct Toppings : RawOptionSetType { ... }

    let diameter: Int
    let style: Style
    let toppings: Toppings

    init(inchesInDiameter diameter: Int, style: Style, toppings: Toppings = .None) {
        self.diameter = diameter
        self.style = style
        self.toppings = toppings
    }
}

let dinner = Pizza(inchesInDiameter: 12, style: .Neopolitan, toppings: .Pepperoni | .GreenPepper)
~~~

对于值的归属检查，可以使用 `&` 运算符，就像在 C 中操作无符号整数一样：

~~~{swift}
extension Pizza {
    var isVegetarian: Bool {
        return toppings & Toppings.Pepperoni ? false : true
    }
}

dinner.isVegetarian // false
~~~

* * *

平心而论，现在来谈论选项(option)类型在 Swift 语言当中的角色还为时过早。很有可能 Swift 中的其他结构，例如元组(tuple)和模式匹配(pattern matching)，也可能就是 `enum` 本身，会让选项类型变得不仅仅只是来自过去的遗迹。

不管怎样，如果你想在代码中实现类似 `NS_OPTIONS` 的结构，下面是一段 [Xcode snippet](http://nshipster.com/xcode-snippets/)，可以帮助你快速上手：

~~~{swift}
struct <# Options #> : RawOptionSetType, BooleanType {
    let rawValue: UInt
    init(nilLiteral: ()) { self.value = 0 }
    init(_ value: UInt = 0) { self.value = value }
    init(rawValue value: UInt) { self.value = value }
    var boolValue: Bool { return value != 0 }
    var rawValue: UInt { return value }
    static var allZeros: <# Options #> { return self(0) }

    static var None: <# Options #>         { return self(0b0000) }
    static var <# Option #>: <# Options #>     { return self(0b0001) }
    // ...
}
~~~
