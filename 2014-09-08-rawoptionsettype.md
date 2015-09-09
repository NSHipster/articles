---
title: RawOptionSetType
author: Mattt Thompson
category: Swift
tags: swift
excerpt: "Swift enumerations are a marked improvement over the `NS_ENUM` macro in Objective-C. Unfortunately, `NS_OPTIONS` does not compare as favorably."
status:
    swift: 1.2
---

In Objective-C, [`NS_ENUM` & `NS_OPTIONS`](http://nshipster.com/ns_enum-ns_options/) are used to annotate C `enum`s in such a way that sets clear expectations for both the compiler and developer. Since being introduced to Objective-C with Xcode 4.5, these macros have become a standard convention in system frameworks, and a best practice within the community.

In Swift, enumerations are codified as a first-class language construct as fundamental as a `struct` or `class`, and include a number of features that make them even more expressive, like raw types and associated values. They're so perfectly-suited to encapsulating closed sets of fixed values, that developers would do well to actively seek out opportunities to use them.

When interacting with frameworks like Foundation in Swift, all of those `NS_ENUM` declarations are automatically converted into an `enum`—often improving on the original Objective-C declaration by eliminating naming redundancies:

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

Unfortunately, for `NS_OPTIONS`, the Swift equivalent is arguably worse:

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

`RawOptionsSetType` is the Swift equivalent of `NS_OPTIONS` (or at least as close as it gets). It is a protocol that adopts the `RawRepresentable`, `Equatable`, `BitwiseOperationsType`, and `NilLiteralConvertible` protocols. An option type can be represented by a `struct` conforming to `RawOptionsSetType`.

Why does this suck so much? Well, the same integer bitmasking tricks in C don't work for enumerated types in Swift. An `enum` represents a type with a closed set of valid options, without a built-in mechanism for representing a conjunction of options for that type. An `enum` could, ostensibly, define a case for all possible combinations of values, but for `n > 3`, the combinatorics make this approach untenable. There are a few different ways `NS_OPTIONS` could be implemented in Swift, but `RawOptionSetType` is probably the least bad.

Compared to the syntactically concise `enum` declaration, `RawOptionsSetType` is awkward and cumbersome, requiring over a dozen lines of boilerplate for computed properties:

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

> As of Xcode 6 Beta 6, `RawOptionSetType` no longer conforms to `BooleanType`, which is required for performing bitwise checks.

One nice thing about doing this in Swift is its built-in binary integer literal notation, which allows the bitmask to be computed visually. And once the options type is declared, the usage syntax is not too bad.

Taken into a larger example for context:

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

A value membership check can be performed with the `&` operator, just like with unsigned integers in C:

~~~{swift}
extension Pizza {
    var isVegetarian: Bool {
        return toppings & Toppings.Pepperoni ? false : true
    }
}

dinner.isVegetarian // false
~~~

* * *

In all fairness, it may be too early to really appreciate what role option types will have in the new language. It could very well be that Swift's other constructs, like tuples or pattern matching—or indeed, even `enum`s—make options little more than a vestige of the past.

Either way, if you're looking to implement an `NS_OPTIONS` equivalent in your code base, here's an [Xcode snippet](http://nshipster.com/xcode-snippets/)-friendly example of how to go about it:

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
