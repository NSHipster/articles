---
title: Equatable and Comparable
author: Mattt
category: Swift
tags: swift
excerpt: >-
  Objective-C required us to wax philosophic 
  about the nature of equality and identity. 
  To the relief of any developer less inclined towards discursive treatises, 
  this is not as much the case for Swift.
revisions:
  "2014-09-22": Original publication
  "2018-12-19": Updated for Swift 4.2
status:
  swift: 4.2
  reviewed: December 19, 2018
---

Objective-C required us to
[wax philosophic](/equality/)
about the nature of equality and identity.
To the relief of any developer less inclined towards discursive treatises,
this is not as much the case for Swift.

In Swift,
there's the `Equatable` protocol,
which explicitly defines the semantics of equality and inequality
in a manner entirely separate from the question of identity.
There's also the `Comparable` protocol,
which builds on `Equatable` to refine inequality semantics
to creating an ordering of values.
Together, the `Equatable` and `Comparable` protocols
form the central point of comparison throughout the language.

---

## Equatable

Values conforming to the `Equatable` protocol
can be evaluated for equality and inequality.
Conformance to `Equatable` requires
the implementation of the equality operator (`==`).

As an example,
consider the following
[`Binomen`](https://en.wikipedia.org/wiki/Binomial_nomenclature) structure:

```swift
struct Binomen {
    let genus: String
    let species: String
}

let 🐺 = Binomen(genus: "Canis", species: "lupus")
let 🐻 = Binomen(genus: "Ursus", species: "arctos")
```

We can add `Equatable` conformance through an extension,
implementing the required type method for the `==` operator like so:

```swift
extension Binomen: Equatable {
    static func == (lhs: Binomen, rhs: Binomen) -> Bool {
        return lhs.genus == rhs.genus &&
                lhs.species == rhs.species
    }
}

🐺 == 🐺 // true
🐺 == 🐻 // false
```

_Easy enough, right?_

Well actually, it's even easier than that ---
as of Swift 4.1,
the compiler can _automatically synthesize_ conformance
for structures whose stored properties all have types that are `Equatable`.
We could replace all of the code in the extension
by simply adopting `Equatable` in the declaration of `Binomen`:

```swift
struct Binomen: Equatable {
    let genus: String
    let species: String
}

🐺 == 🐺 // true
🐺 == 🐻 // false
```

### The Benefits of Being Equal

Equatability isn't just about using the `==` operator ---
<del>there's also the `!=` operator!</del>
it also lets a value,
among other things,
be found in a collection and
matched in a `switch` statement.

```swift
[🐺, 🐻].contains(🐻) // true

func commonName(for binomen: Binomen) -> String? {
    switch binomen {
    case 🐺: return "gray wolf"
    case 🐻: return "brown bear"
    default: return nil
    }
}
commonName(for: 🐺) // "gray wolf"
```

`Equatable` is also a requirement for conformance to
[`Hashable`](https://nshipster.com/hashable/),
another important type in Swift.

This is all to say that
if a type has equality semantics ---
if two values of that type can be considered equal or unequal --
it should conform to `Equatable`.

### The Limits of Automatic Synthesis

The Swift standard library and most of the frameworks in Apple SDKs
do a great job adopting `Equatable` for types that make sense to be.
So, in practice, you're unlikely to be in a situation
where the dereliction of a built-in type
spoils automatic synthesis for your own type.

Instead, the most common obstacle to automatic synthesis involves tuples.
Consider this poorly-considered
[`Trinomen`](https://en.wikipedia.org/wiki/Trinomen) type:

```swift
struct Trinomen {
    let genus: String
    let species: (String, subspecies: String?) // 🤔
}

extension Trinomen: Equatable {}
// 🛑 Type 'Trinomen' does not conform to protocol 'Equatable'
```

As described in our article about [`Void`](/void/),
tuples aren't <dfn>nominal types</dfn>,
so they can't conform to `Equatable`.
If you wanted to compare two trinomina for equality,
you'd have to write the conformance code for `Equatable`.

_...like some kind of animal_.

### Conditional Conformance to Equality

In addition to automatic synthesis of `Equatable`,
Swift 4.1 added another critical feature:
<dfn>conditional conformance</dfn>.

To illustrate this,
consider the following generic type
that represents a quantity of something:

```swift
struct Quantity<Thing> {
    let count: Int
    let thing: Thing
}
```

Can `Quantity` conform to `Equatable`?
We know that integers are equatable,
so it really depends on what kind of `Thing` we're talking about.

What conditional conformance Swift 4.1 allows us to do is
create an extension on a type with a conditional clause.
We can use that here to programmatically express that
\_"a quantity of a thing is equatable if the thing itself is equatable":

```swift
extension Quantity: Equatable where Thing: Equatable {}
```

And with that declaration alone,
Swift has everything it needs to synthesize conditional `Equatable` conformance,
allowing us to do the following:

```swift
let oneHen = Quantity<Character>(count: 1, thing: "🐔")
let twoDucks = Quantity<Character>(count: 2, thing: "🦆")
oneHen == twoDucks // false
```

{% info %}
Conditional conformance is the same mechanism that provides for
an `Array` whose `Element` is `Equatable` to itself conform to `Equatable`:

```swift
[🐺, 🐻] == [🐺, 🐻] // true
```

{% endinfo %}

### Equality by Reference

For reference types,
the notion of equality becomes conflated with identity.
It makes sense that two `Name` structures with the same values would be equal,
but two `Person` objects can have the same name and still be different people.

For Objective-C-compatible object types,
the `==` operator is already provided from the [`isEqual:`](/equality/) method:

```swift
import Foundation

class ObjCObject: NSObject {}

ObjCObject() == ObjCObject() // false
```

For Swift reference types (that is, classes),
equality can be evaluated using the identity equality operator (`===`):

```swift
class Object: Equatable {
    static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs === rhs
    }
}

Object() == Object() // false
```

That said,
`Equatable` semantics for reference types
are often not as straightforward as a straight identity check,
so before you add conformance to all of your classes,
ask yourself whether it actually makes sense to do so.

## Comparable

Building on `Equatable`,
the `Comparable` protocol allows for values to be considered
less than or greater than other values.

`Comparable` requires implementations for the following operators:

| Operator | Name                     |
| -------- | ------------------------ |
| `<`      | Less than                |
| `<=`     | Less than or equal to    |
| `>=`     | Greater than or equal to |
| `>`      | Greater than             |

...so it's surprising that you can get away with only implementing one of them:
the `<` operator.

Going back to our binomial nomenclature example,
let's extend `Binomen` to conform to `Comparable`
such that values are ordered alphabetically
first by their genus name and then by their species name:

```swift
extension Binomen: Comparable {
    static func < (lhs: Binomen, rhs: Binomen) -> Bool {
        if lhs.genus != rhs.genus {
            return lhs.genus < rhs.genus
        } else {
            return lhs.species < rhs.species
        }
    }
}


🐻 > 🐺 // true ("Ursus" lexicographically follows "Canis")
```

{% warning %}
Implementing the `<` operator
for types that consider more than one property
is deceptively hard to get right the first time.
Be sure to write test cases to validate correct behavior.
{% endwarning %}

This is _quite_ clever.
Since the implementations of each comparison operator
can be derived from just `<` and `==`,
all of that functionality is made available automatically through type inference.

{% info %}
Contrast this with how Ruby and other languages derive
equality and comparison operators from a single operator,
`<=>` _(a.k.a the "UFO operator")_.
A few pitches to bring formalized ordering to Swift
have floated around over the years,
[such as this one](https://gist.github.com/CodaFi/f0347bd37f1c407bf7ea0c429ead380e),
but we haven't seen any real movement in this direction lately.
{% endinfo %}

### Incomparable Limitations with No Equal

Unlike `Equatable`,
the Swift compiler can't automatically synthesize conformance to `Comparable`.
But that's not for lack of trying --- _it's just not possible_.

There are no implicit semantics for comparability
that could be derived from the types of stored properties.
If a type has more than one stored property,
there's no way to determine how they're compared relative to one another.
And even if a type had only a single property whose type was `Comparable`,
there's no guarantee how the ordering of that property
would relate to the ordering of the value as a whole

### Comparable Benefits

Conforming to `Comparable` confers a multitude of benefits.

One such benefit is that
arrays containing values of comparable types
can call methods like `sorted()`, `min()`, and `max()`:

```swift
let 🐬 = Binomen(genus: "Tursiops", species: "truncatus")
let 🌻 = Binomen(genus: "Helianthus", species: "annuus")
let 🍄 = Binomen(genus: "Amanita", species: "muscaria")
let 🐶 = Binomen(genus: "Canis", species: "domesticus")

let menagerie = [🐺, 🐻, 🐬, 🌻, 🍄, 🐶]
menagerie.sorted() // [🍄, 🐶, 🐺, 🌻, 🐬, 🐻]
menagerie.min() // 🍄
menagerie.max() // 🐻
```

Having a defined ordering also lets you create ranges, like so:

```swift
let lessThan10 = ..<10
lessThan10.contains(1) // true
lessThan10.contains(11) // false

let oneToFive = 1...5
oneToFive.contains(3) // true
oneToFive.contains(7) // false
```

---

In the Swift standard library,
`Equatable` is a type without an equal;
`Comparable` a protocol without compare.
Take care to adopt them in your own types as appropriate
and you'll benefit greatly.
