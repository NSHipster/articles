---
title: Swift Comparison Protocols
author: Mattt Thompson
category: Swift
tags: swift
excerpt: "Objective-C required us to wax philosophic about the nature of equality and identity. To the relief of any developer less inclined towards handwavy treatises, this is not as much the case for Swift."
status:
    swift: 1.2
---

Objective-C required us to [wax philosophic](http://nshipster.com/equality/) about the nature of equality and identity. To the relief of any developer less inclined towards handwavy treatises, this is not as much the case for Swift.

In Swift, `Equatable` is a fundamental type, from which `Comparable` and `Hashable` are both derived. Together, these protocols form the central point of comparison throughout the language.

* * *

## Equatable

Values of the `Equatable` type can be evaluated for equality and inequality. Declaring a type as equatable bestows several useful abilities, notably the ability values of that type to be found in a containing `Array`.

For a type to be `Equatable`, there must exist an implementation of the `==` operator function, which accepts a matching type:

~~~{swift}
func ==(lhs: Self, rhs: Self) -> Bool
~~~

For value types, equality is determined by evaluating the equality of each component property. As an example, consider a `Complex` type, which takes a generic type `T`, which conforms to `SignedNumberType`:

> `SignedNumberType` is a convenient choice for a generic number type, as it inherits from both `Comparable` (and thus `Equatable`, as described in the section) and `IntegerLiteralConvertible`, which `Int`, `Double`, and `Float` all conform to.

~~~{swift}
struct Complex<T: SignedNumberType> {
    let real: T
    let imaginary: T
}
~~~

Since a [complex number](http://en.wikipedia.org/wiki/Complex_number) is comprised of a real and imaginary component, two complex numbers are equal if and only if their respective real and imaginary components are equal:

~~~{swift}
extension Complex: Equatable {}

// MARK: Equatable

func ==<T>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
    return lhs.real == rhs.real && lhs.imaginary == rhs.imaginary
}
~~~

The result:

~~~swift
let a = Complex<Double>(real: 1.0, imaginary: 2.0)
let b = Complex<Double>(real: 1.0, imaginary: 2.0)

a == b // true
a != b // false
~~~

> As described in [the article about Swift Default Protocol Implementations](http://nshipster.com/swift-default-protocol-implementations/), an implementation of `!=` is automatically derived from the provided `==` operator by the standard library.

For reference types, the equality becomes conflated with identity. It makes sense that two `Name` structs with the same values would be equal, but two `Person` objects can have the same name, but be different people.

For Objective-C-compatible object types, the `==` operator is already provided from the `isEqual:` method:

~~~{swift}
class ObjCObject: NSObject {}

ObjCObject() == ObjCObject() // false
~~~

For Swift reference types, equality can be evaluated as an identity check on an `ObjectIdentifier` constructed with an instance of that type:

~~~{swift}
class Object: Equatable {}

// MARK: Equatable

func ==(lhs: Object, rhs: Object) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

Object() == Object() // false
~~~

## Comparable

Building on `Equatable`, the `Comparable` protocol allows for more specific inequality, distinguishing cases where the left hand value is greater than or less than the right hand value.

Types conforming to the `Comparable` protocol provide the following operators:

~~~{swift}
func <=(lhs: Self, rhs: Self) -> Bool
func >(lhs: Self, rhs: Self) -> Bool
func >=(lhs: Self, rhs: Self) -> Bool
~~~

What's interesting about this list, however, is not so much what is _included_, but rather what's _missing_.

The first and perhaps most noticeable omission is `==`, since `>=` is a logical disjunction of `>` and `==` comparisons. As a way of reconciling this, `Comparable` inherits from `Equatable`, which provides `==`.

The second omission is a bit more subtle, and is actually the key to understanding what's going on here: `<`. What happened to the "less than" operator? It's defined by the `_Comparable` protocol. Why is this significant? As described in [the article about Swift Default Protocol Implementations](http://nshipster.com/swift-default-protocol-implementations/), the Swift Standard Library provides a default implementation of the `Comparable` protocol based entirely on the existential type `_Comparable`. This is actually _really_ clever. Since the implementations of all of the comparison functions can be derived from just `<` and `==`, all of that functionality is made available automatically through type inference.

> Contrast this with, for example, how Ruby derives equality and comparison operators from a single operator, `<=>` (a.k.a the "UFO operator"). [Here's how this could be implemented in Swift](https://gist.github.com/mattt/7e4db72ce1b6c8a18bb4).

As a more complex example, consider a `CSSSelector` struct, which implements [cascade ordering](http://www.w3.org/TR/CSS2/cascade.html#cascading-order) of selectors:

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

Where as CSS selectors are evaluated by specificity rank and order, two selectors are only really equal if they resolve to the same elements:

~~~{swift}
extension CSSSelector: Equatable {}

// MARK: Equatable

func ==(lhs: CSSSelector, rhs: CSSSelector) -> Bool {
    // Naïve equality that uses string comparison rather than resolving equivalent selectors
    return lhs.selector == rhs.selector
}
~~~

Instead, selectors are actually compared in terms of their specificity:

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

Bringing everything together:

> For clarity, assume `CSSSelector` [conforms to `StringLiteralConvertible`](http://nshipster.com/swift-literal-convertible/).

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

Another important protocol derived from `Equatable` is `Hashable`.

Only `Hashable` types can be stored as the key of a Swift `Dictionary`:

~~~{swift}
struct Dictionary<Key : Hashable, Value> : CollectionType, DictionaryLiteralConvertible { ... }
~~~

For a type to conform to `Hashable`, it must provide a getter for the `hashValue` property.

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

Determining the [optimal hashing value](http://en.wikipedia.org/wiki/Perfect_hash_function) is way outside the scope of this article. Fortunately, most values can derive an adequate hash value from an `XOR` of the hash values of its component properties.

The following built-in Swift types implement `hashValue`:

- `Double`
- `Float`, `Float80`
- `Int`, `Int8`, `Int16`, `Int32`, `Int64`
- `UInt`, `UInt8`, `UInt16`, `UInt32`, `UInt64`
- `String`
- `UnicodeScalar`
- `ObjectIdentifier`

Based on this, here's how a struct representing [Binomial Nomenclature in Biological Taxonomy](http://en.wikipedia.org/wiki/Binomial_nomenclature):

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
    return lhs.genus == rhs.genus && lhs.species == rhs.species
}
~~~

Being able to hash this type makes it possible to key common name to the "Latin name":

~~~{swift}
var commonNames: [Binomen: String] = [:]
commonNames[Binomen(genus: "Canis", species: "lupis")] = "Grey Wolf"
commonNames[Binomen(genus: "Canis", species: "rufus")] = "Red Wolf"
commonNames[Binomen(genus: "Canis", species: "latrans")] = "Coyote"
commonNames[Binomen(genus: "Canis", species: "aureus")] = "Golden Jackal"
~~~
