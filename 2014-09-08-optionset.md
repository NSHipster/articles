---
title: OptionSet
author: Mattt
category: Swift
excerpt: >-
  Objective-C uses the `NS_OPTIONS` macro
  to define set of values that may be combined together.
  Swift imports those types as structures 
  conforming to the `OptionSet` protocol.
  But could new language features in Swift provide a better option?
revisions:
  "2014-09-09": First Publication
  "2018-11-07": Updated for Swift 4.2
status:
  swift: 4.2
  reviewed: November 7, 2018
---

Objective-C uses the
[`NS_OPTIONS`](https://nshipster.com/ns_enum-ns_options/)
macro to define <dfn>option</dfn> types,
or sets of values that may be combined together.
For example,
values in the `UIViewAutoresizing` type in UIKit
can be combined with the bitwise OR operator (`|`)
and passed to the `autoresizingMask` property of a `UIView`
to specify which margins and dimensions should automatically resize:

```objc
typedef NS_OPTIONS(NSUInteger, UIViewAutoresizing) {
    UIViewAutoresizingNone                 = 0,
    UIViewAutoresizingFlexibleLeftMargin   = 1 << 0,
    UIViewAutoresizingFlexibleWidth        = 1 << 1,
    UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
    UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
    UIViewAutoresizingFlexibleHeight       = 1 << 4,
    UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};
```

Swift imports this and other types defined using the `NS_OPTIONS` macro
as a structure that conforms to the `OptionSet` protocol.

```swift
extension UIView {
    struct AutoresizingMask: OptionSet {
        init(rawValue: UInt)

        static var flexibleLeftMargin: UIView.AutoresizingMask
        static var flexibleWidth: UIView.AutoresizingMask
        static var flexibleRightMargin: UIView.AutoresizingMask
        static var flexibleTopMargin: UIView.AutoresizingMask
        static var flexibleHeight: UIView.AutoresizingMask
        static var flexibleBottomMargin: UIView.AutoresizingMask
    }
}
```

{% info %}
The renaming and nesting of imported types
are the result of a separate mechanism.
{% endinfo %}

At the time `OptionSet` was introduced (and `RawOptionSetType` before it),
this was the best encapsulation that the language could provide.
Towards the end of this article,
we'll demonstrate how to take advantage of
language features added in Swift 4.2
to improve upon `OptionSet`.

...but that's getting ahead of ourselves.

This week on NSHipster,
let's take a by-the-books look at using imported `OptionSet` types,
and how you can create your own.
After that, we'll offer a different option
for setting options.

## Working with Imported Option Set Types

[According to the documentation](https://developer.apple.com/documentation/swift/optionset),
there are over 300 types in Apple SDKs that conform to `OptionSet`,
from `ARHitTestResult.ResultType` to `XMLNode.Options`.

No matter which one you're working with,
the way you use them is always the same:

To specify a single option,
pass it directly
(Swift can infer the type when setting a property
so you can omit everything up to the leading dot):

```swift
view.autoresizingMask = .flexibleHeight
```

`OptionSet` conforms to the
[`SetAlgebra`](https://developer.apple.com/documentation/swift/setalgebra)
protocol,
so to you can specify multiple options with an array literal ---
no bitwise operations required:

```swift
view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
```

To specify no options,
pass an empty array literal (`[]`):

```swift
view.autoresizingMask = [] // no options
```

## Declaring Your Own Option Set Types

You might consider creating your own option set type
if you have a property that stores combinations from a closed set of values
and you want that combination to be stored efficiently using a bitset.

To do this,
declare a new structure that adopts the `OptionSet` protocol
with a required `rawValue` instance property
and type properties for each of the values you wish to represent.
The raw values of these are initialized with increasing powers of 2,
which can be constructed using the left bitshift (`<<`) operation
with incrementing right-hand side values.
You can also specify named aliases for specific combinations of values.

For example,
here's how you might represent topping options for a pizza:

```swift
struct Toppings: OptionSet {
    let rawValue: Int

    static let pepperoni    = Toppings(rawValue: 1 << 0)
    static let onions       = Toppings(rawValue: 1 << 1)
    static let bacon        = Toppings(rawValue: 1 << 2)
    static let extraCheese  = Toppings(rawValue: 1 << 3)
    static let greenPeppers = Toppings(rawValue: 1 << 4)
    static let pineapple    = Toppings(rawValue: 1 << 5)

    static let meatLovers: Toppings = [.pepperoni, .bacon]
    static let hawaiian: Toppings = [.pineapple, .bacon]
    static let all: Toppings = [
        .pepperoni, .onions, .bacon,
        .extraCheese, .greenPeppers, .pineapple
    ]
}
```

Taken into a larger example for context:

```swift
struct Pizza {
    enum Style {
        case neapolitan, sicilian, newHaven, deepDish
    }

    struct Toppings: OptionSet { ... }

    let diameter: Int
    let style: Style
    let toppings: Toppings

    init(inchesInDiameter diameter: Int,
         style: Style,
         toppings: Toppings = [])
    {
        self.diameter = diameter
        self.style = style
        self.toppings = toppings
    }
}

let dinner = Pizza(inchesInDiameter: 12,
                   style: .neapolitan,
                   toppings: [.greenPeppers, .pineapple])
```

Another advantage of `OptionSet` conforming to `SetAlgebra` is that
you can perform set operations like determining membership,
inserting and removing elements,
and forming unions and intersections.
This makes it easy to, for example,
determine whether the pizza toppings are vegetarian-friendly:

```swift
extension Pizza {
    var isVegetarian: Bool {
        return toppings.isDisjoint(with: [.pepperoni, .bacon])
    }
}

dinner.isVegetarian // true
```

## A Fresh Take on an Old Classic

Alright, now that you know how to use `OptionSet`,
let's show you how not to use `OptionSet`.

As we mentioned before,
new language features in Swift 4.2 make it possible
to have our <del>cake</del> <ins>pizza pie</ins> and eat it too.

First, declare a new `Option` protocol
that inherits `RawRepresentable`, `Hashable`, and `CaseIterable`.

```Swift
protocol Option: RawRepresentable, Hashable, CaseIterable {}
```

Next, declare an enumeration with `String` raw values
that adopts the `Option` protocol:

```swift
enum Topping: String, Option {
    case pepperoni, onions, bacon,
         extraCheese, greenPeppers, pineapple
}
```

Compare the structure declaration from before
to the following enumeration.
Much nicer, right?
Just wait --- it gets even better.

Automatic synthesis of `Hashable` provides effortless usage with `Set`,
which gets us halfway to the functionality of `OptionSet`.
Using conditional conformance,
we can create an extension for any `Set` whose element is a `Topping`
and define our named topping combos.
As a bonus, `CaseIterable` makes it easy to order a pizza with _"the works"_:

```swift
extension Set where Element == Topping {
    static var meatLovers: Set<Topping> {
        return [.pepperoni, .bacon]
    }

    static var hawaiian: Set<Topping> {
        return [.pineapple, .bacon]
    }

    static var all: Set<Topping> {
        return Set(Element.allCases)
    }
}

typealias Toppings = Set<Topping>
```

And that's not all `CaseIterable` has up its sleeves;
by enumerating over the `allCases` type property,
we can automatically generate the bitset values for each case,
which we can combine to produce the equivalent `rawValue`
for any `Set` containing `Option` types:

```swift
extension Set where Element: Option {
    var rawValue: Int {
        var rawValue = 0
        for (index, element) in Element.allCases.enumerated() {
            if self.contains(element) {
                rawValue |= (1 << index)
            }
        }

        return rawValue
    }
}
```

Because `OptionSet` and `Set` both conform to `SetAlgebra`
our new `Topping` implementation can be swapped in for the original one
without needing to change anything about the `Pizza` itself.

{% warning %}
This approach assumes that the order of cases provided by `CaseIterable`
is stable across launches.
If it isn't, the generated raw value for combinations of options
may be inconsistent.
{% endwarning %}

---

So, to summarize:
you're likely to encounter `OptionSet`
when working with Apple SDKs in Swift.
And although you _could_ create your own structure that conforms to `OptionSet`,
you probably don't need to.
You could use the fancy approach outlined at the end of this article,
or do with something more straightforward.

Whichever option you choose,
you should be all set.
