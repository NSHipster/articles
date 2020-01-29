---
title: RawRepresentable
author: Mattt
category: Swift
excerpt: >-
    Programming is about typing.
    And programming languages are typically judged by how much they make you type —
    in both senses of the word.
status:
  swift: 5.1
---

Programming is about typing.
And programming languages are typically judged by how much they make you type ---
in both senses of the word.

Swift is beloved for being able to save us a few keystrokes
without compromising safety or performance,
whether it's through
implicit typing or
automatic synthesis of protocols like
[`Equatable`](/equatable-and-comparable/) and
[`Hashable`](/hashable/).
But the <abbr title="Ice-T's 1991 single 'O.G. Original Gangster'">OG</abbr>
ergonomic feature of Swift is undoubtedly
automatic synthesis of `RawRepresentable` conformance
for enumerations with raw types.
You know...
the language feature that lets you do this:

```swift
enum Greeting: String {
    case hello = "hello"
    case goodbye // implicit raw value of "b"
}

enum SortOrder: Int {
    case ascending = -1
    case same // implicit raw value of 0
    case descending  // implicit raw value of 1
}
```

Though _"enum + RawValue"_ has been carved into the oak tree of our hearts
since first we laid eyes on that language with a fast bird,
few of us have had occasion to consider
what `RawRepresentable` means outside of autosynthesis.
This week,
we invite you to do a little extra typing
and explore some untypical use cases for the `RawRepresentable` protocol.

--------------------------------------------------------------------------------

In Swift,
an enumeration can be declared with
<dfn>raw value syntax</dfn>.

According to [the documentation](https://developer.apple.com/documentation/swift/rawrepresentable):

> For any enumeration with a string, integer, or floating-point raw type,
> the Swift compiler automatically adds `RawRepresentable` conformance.

When developers first start working with Swift,
they inevitably run into situations where raw value syntax doesn't work:

- Enumerations with raw values other than `Int` or `String`
- Enumerations with associated values

Upon seeing those bright, red error sigils,
many of us fall back to a more conventional enumeration,
failing to realize that what we wanted to do wasn't impossible,
but rather just slightly beyond what the compiler can do for us.

--------------------------------------------------------------------------------

## RawRepresentable with C Raw Value Types

The primary motivation for raw value enumerations is 
to improve interoperability.
Quoting again from the docs:

> Using the raw value of a conforming type
> streamlines interoperation with Objective-C and legacy APIs.

This is true of Objective-C frameworks in the Apple SDK,
which declare enumerations with [`NS_ENUM`](/ns_enum-ns_options/).
But interoperability with other C libraries is often less seamless.

Consider the task of interfacing with 
[libcmark](https://github.com/commonmark/cmark),
a library for working with Markdown according to the
[CommonMark spec](http://spec.commonmark.org/).
Among the imported data types is `cmark_node_type`,
which has the following C declaration:

```c
typedef enum {
  /* Error status */
  CMARK_NODE_NONE,

  /* Block */
  CMARK_NODE_DOCUMENT,
  CMARK_NODE_BLOCK_QUOTE,
  <#...#>
  CMARK_NODE_HEADING,
  CMARK_NODE_THEMATIC_BREAK,

  CMARK_NODE_FIRST_BLOCK = CMARK_NODE_DOCUMENT,
  CMARK_NODE_LAST_BLOCK = CMARK_NODE_THEMATIC_BREAK,

  <#...#>
} cmark_node_type;
```

We can immediately see a few details that would need to be ironed out
along the path of Swiftification ---
notably, 
1\) the sentinel `NONE` value, which would instead be represented by `nil`, and
2\) the aliases for the first and last block values,
which wouldn't be encoded by distinct enumeration cases.

Attempting to declare a Swift enumeration
with a raw value type of `cmark_node_type` results in a compiler error.

```swift
enum NodeType: cmark_node_type {} // Error
```

However, 
that doesn't totally rule out `cmark_node_type` from being a `RawValue` type.
Here's what we need to make that happen:

```swift
enum NodeType: RawRepresentable {
    case document
    case blockQuote
    <#...#>

    init?(rawValue: cmark_node_type) {
        switch rawValue {
        case CMARK_NODE_DOCUMENT: self = .document
        case CMARK_NODE_BLOCK_QUOTE: self = .blockQuote
        <#...#>
        default:
            return nil
        }
    }

    var rawValue: cmark_node_type {
        switch self {
        case .document: return CMARK_NODE_DOCUMENT
        case .blockQuote: return CMARK_NODE_BLOCK_QUOTE
        <#...#>
        }
    }
}
```

It's a far cry from being able to say `case document = CMARK_NODE_DOCUMENT`,
but this approach offers a reasonable solution
that falls within the existing semantics of the Swift standard library.

{% info %}

You can omit a protocol's associated type requirement
if the type can be determined from the protocol's other requirements.

For instance,
the `RawRepresentable` protocol requires 
a `rawValue` property that returns a value of the associated `RawValue` type;
a conforming type can implicitly satisfy the associated type requirement
by declaring its property requirement with a concrete type
(in the example above, `cmark_node_type`).

{% endinfo %}

That debunks the myth about
`Int` and `String` being the only types that can be a raw value.
What about that one about associated values?

## RawRepresentable and Associated Values

In Swift,
an enumeration case can have one or more <dfn>associated values</dfn>.
Associated values are a convenient way to introduce some flexibility
into the closed semantics of enumerations
and all the benefits they confer.

[As the old adage goes](https://github.com/apple/swift/blob/master/docs/Driver.md#output-file-maps):

> There are three numbers in computer science: 0, 1, and N.

```swift
enum Number {
    case zero
    case one
    case n(Int)
}
```

Because of the associated value on `n`,
the compiler can't automatically synthesize an `Int` raw value type.
But that doesn't mean we can't roll up our sleeves and pick up the slack.

```swift
extension Number: RawRepresentable {
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .zero
        case 1: self = .one
        case let n: self = .n(n)
        }
    }

    var rawValue: Int {
        switch self {
        case .zero: return 0
        case .one: return 1
        case let .n(n): return n
        }
    }
}

Number(rawValue: 1) // .one
```

Another myth busted!

Let's continue this example to clear up 
a misconception we found in the documentation.

## RawRepresentable as Raw Values for Another Enumeration

Consider the following from 
the `RawRepresentable` docs: 

> For any enumeration with a string, integer, or floating-point raw type, 
> the Swift compiler automatically adds `RawRepresentable` conformance.

This is, strictly speaking, true.
But it actually under-sells what the compiler can do.
The actual requirements for raw values are as follows:

- The raw value for an enumeration case must be a literal
- A raw value type must be `Equatable` & `RawRepresentable`

Let's see what happens if we satisfy that for our `Number` type from before.

```swift
extension Number: Equatable {} // conformance is automatically synthesized

extension Number: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.init(rawValue: value)!
    }
}

-1 as Number // .n(-1)
0 as Number // .zero
1 as Number // .one
2 as Number // .n(2)
```

If we declare a new enumeration,
<code lang="zh-Hans">数</code>
(literally "Number")
with a `Number` raw value...

```swift
enum 数: Number {
    case 一 = 1
    case 二 = 2
    case 三 = 3
}

数.二 // 二
数.二.rawValue // .n(2)
数.二.rawValue.rawValue // 2
```

_Wait, that actually works? Neat!_

What's really interesting is that our contrived little enumeration type
benefits from the same, small memory footprint
that you get from using enumerations in more typical capacities:

```swift
MemoryLayout.size(ofValue: 数.三) // 1 (bytes)
MemoryLayout.size(ofValue: 数.三.rawValue) // 9 (bytes)
MemoryLayout.size(ofValue: 数.三.rawValue.rawValue) // 8 (bytes)
```

If raw values aren't limited to `String` or `Int`,
as once believed,
you may start to wonder:
_How far can we take this?_

## RawRepresentable with Metatype Raw Values

Probably the biggest selling point of enumerations in Swift
is how they encode a closed set of values.

```swift
enum Element {
    case earth, water, air, fire
}
```

Unfortunately,
there's no equivalent way to "close off" which types conform to a protocol.

```swift
public protocol Elemental {}
public struct Earth: Elemental {}
public struct Water: Elemental {}
public struct Air: Elemental {}
public struct Fire: Elemental {}
```

Without built-in support for type unions 
or an analog to the `open` access modifier for classes,
there's nothing that an API provider can do,
for example,
to prevent a consumer from doing the following:

```swift
struct Aether: Elemental {}
```

Any switch statement over a type-erased `Elemental` value
using `is` checks will necessarily have a `default` case.

Until we have a first-class language feature for providing such guarantees,
we can recruit enumerations and raw values for a reasonable approximation:

```swift
extension Element: RawRepresentable {
    init?(rawValue: Element.Type) {
        switch rawValue {
        case is Earth.Type:
            self = .earth
        case is Water.Type:
            self = .water
        case is Air.Type:
            self = .air
        case is Fire.Type:
            self = .fire
        default:
            return nil
        }
    }

    var rawValue: Element.Type {
        switch self {
        case .earth: return Earth.self
        case .water: return Water.self
        case .air: return Air.self
        case .fire: return Fire.self
        }
    }
}
```

{% warning %} 

This doesn't work for protocols with an associated type requirement.
Sorry to disappoint anyone looking for an easy workaround for
_"Protocol can only be used as a generic constraint
because it has Self or associated type requirements"_

{% endwarning %}

--------------------------------------------------------------------------------

Returning one last time to the docs,
we're reminded that:

> With a `RawRepresentable` type, 
> you can switch back and forth between 
> a custom type and an associated `RawValue` type 
> without losing the value of the original `RawRepresentable` type.

From the earliest days of the language, 
`RawRepresentable` has been relegated to 
the thankless task of C interoperability.
But looking now with a fresh set of eyes,
we can now see it for in all its 
[injective](https://en.wikipedia.org/wiki/Injective_function) glory.

So the next time you find yourself with an enumeration
whose cases broker in discrete, defined counterparts,
consider adopting `RawRepresentable` to formalize the connection.
