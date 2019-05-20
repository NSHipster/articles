---
title: Swift Literals
author: Mattt
category: Swift
tags: swift
excerpt: >-
  Literals are representations of values in source code.
  The different kinds of literals that Swift provides ---
  and how it makes them available ---
  has a profound impact on how we write and think about code.
revisions:
  "2014-08-18": Original publication
  "2018-08-22": Updated for Swift 4.2
status:
  swift: 4.2
---

In 1911,
linguist [Franz Boas](https://en.wikipedia.org/wiki/Franz_Boas)
observed that speakers of
[Eskimo–Aleut languages](https://en.wikipedia.org/wiki/Eskimo–Aleut_languages)
used different words to distinguish falling snowflakes from snow on the ground.
By comparison, English speakers typically refer to both as "snow,"
but create a similar distinction between raindrops and puddles.

Over time,
this simple empirical observation
has warped into an awful cliché that
"Eskimos [sic] have 50 different words for snow" ---
which is unfortunate,
because Boas' original observation was empirical,
and the resulting weak claim of linguistic relativity is uncontroversial:
languages divide semantic concepts into separate words
in ways that may (and often do) differ from one another.
Whether that's more an accident of history
or reflective of some deeper truth about a culture is unclear,
and subject for further debate.

It's in this framing that you're invited to consider
how the different kinds of literals in Swift
shape the way we reason about code.

---

A <dfn>literal</dfn> is a representation of a value in source code,
such as a number or a string.

Swift provides the following kinds of literals:

| Name                      | Default Inferred Type | Examples                          |
| ------------------------- | --------------------- | --------------------------------- |
| Integer                   | `Int`                 | `123`, `0b1010`, `0o644`, `0xFF`, |
| Floating-Point            | `Double`              | `3.14`, `6.02e23`, `0xAp-2`       |
| String                    | `String`              | `"Hello"`, `""" . . . """`        |
| Extended Grapheme Cluster | `Character`           | `"A"`, `"é"`, `"🇺🇸"`              |
| Unicode Scalar            | `Unicode.Scalar`      | `"A"`, `"´"`, `"\u{1F1FA}"`       |
| Boolean                   | `Bool`                | `true`, `false`                   |
| Nil                       | `Optional`            | `nil`                             |
| Array                     | `Array`               | `[1, 2, 3]`                       |
| Dictionary                | `Dictionary`          | `["a": 1, "b": 2]`                |

The most important thing to understand about literals in Swift
is that they specify a value, but not a definite type.

When the compiler encounters a literal,
it attempts to infer the type automatically.
It does this by looking for each type
that could be initialized by that kind of literal,
and narrowing it down based on any other constraints.

If no type can be inferred,
Swift initializes the default type for that kind of literal ---
`Int` for an integer literal,
`String` for a string literal,
and so on.

```swift
57 // Integer literal
"Hello" // String literal
```

In the case of `nil` literals,
the type can never be inferred automatically
and therefore must be declared.

```swift
nil // ! cannot infer type
nil as String? // Optional<String>.none
```

For array and dictionary literals,
the associated types for the collection
are inferred based on its contents.
However, inferring types for large or nested collections
is a complex operation and
may significantly increase the amount of time it takes to compile your code.
You can keep things snappy by adding an explicit type in your declaration.

```swift
// Explicit type in the declaration
// prevents expensive type inference during compilation
let dictionary: [String: [Int]] = [
    "a": [1, 2],
    "b": [3, 4],
    "c": [5, 6],
    // ...
]
```

### Playground Literals

In addition to the standard literals listed above,
there are a few additional literal types for code in Playgrounds:

| Name  | Default Inferred Type | Examples                                             |
| ----- | --------------------- | ---------------------------------------------------- |
| Color | `NSColor` / `UIColor` | `#colorLiteral(red: 1, green: 0, blue: 1, alpha: 1)` |
| Image | `NSImage` / `UIImage` | `#imageLiteral(resourceName: "icon")`                |
| File  | `URL`                 | `#fileLiteral(resourceName: "articles.json")`        |

In Xcode or Swift Playgrounds on the iPad,
these octothorpe-prefixed literal expressions
are automatically replaced by an interactive control
that provides a visual representation of the referenced color, image, or file.

```swift
// Code
#colorLiteral(red: 0.7477839589, green: 0.5598286986, blue: 0.4095913172, alpha: 1)

// Rendering
🏽
```

{% asset color-literal-picker.png %}

This control also makes it easy for new values to be chosen:
instead of entering RGBA values or file paths,
you're presented with a color picker or file selector.

---

Most programming languages have literals for
Boolean values, numbers, and strings,
and many have literals for arrays, dictionaries, and regular expressions.

Literals are so ingrained in a developer's mental model of programming
that most of us don't actively consider what the compiler is actually doing.

Having a shorthand for these essential building blocks
makes code easier to both read and write.

## How Literals Work

Literals are like words:
their meaning can change depending on the surrounding context.

```swift
["h", "e", "l", "l", "o"] // Array<String>
["h" as Character, "e", "l", "l", "o"] // Array<Character>
["h", "e", "l", "l", "o"] as Set<Character>
```

In the example above,
we see that an array literal containing string literals
is initialized to an array of strings by default.
However, if we explicitly cast the first array element as `Character`,
the literal is initialized as an array of characters.
Alternatively, we could cast the entire expression as `Set<Character>`
to initialize a set of characters.

_How does this work?_

In Swift,
the compiler decides how to initialize literals
by looking at all the visible types that implement the corresponding
<dfn>literal expression protocol</dfn>.

| Literal                   | Protocol                                      |
| ------------------------- | --------------------------------------------- |
| Integer                   | `ExpressibleByIntegerLiteral`                 |
| Floating-Point            | `ExpressibleByFloatLiteral`                   |
| String                    | `ExpressibleByStringLiteral`                  |
| Extended Grapheme Cluster | `ExpressibleByExtendedGraphemeClusterLiteral` |
| Unicode Scalar            | `ExpressibleByUnicodeScalarLiteral`           |
| Boolean                   | `ExpressibleByBooleanLiteral`                 |
| Nil                       | `ExpressibleByNilLiteral`                     |
| Array                     | `ExpressibleByArrayLiteral`                   |
| Dictionary                | `ExpressibleByDictionaryLiteral`              |

To conform to a protocol,
a type must implement its required initializer.
For example,
the `ExpressibleByIntegerLiteral` protocol
requires `init(integerLiteral:)`.

What's really great about this approach
is that it lets you add literal initialization
for your own custom types.

## Supporting Literal Initialization for Custom Types

Supporting initialization by literals when appropriate
can significantly improve the ergonomics of custom types,
making them feel like they're built-in.

For example,
if you wanted to support
[fuzzy logic](https://en.wikipedia.org/wiki/Fuzzy_logic),
in addition to standard Boolean fare,
you might implement a `Fuzzy` type like the following:

```swift
struct Fuzzy: Equatable {
    var value: Double

    init(_ value: Double) {
        precondition(value >= 0.0 && value <= 1.0)
        self.value = value
    }
}
```

A `Fuzzy` value represents a truth value that ranges between
completely true and completely false
over the numeric range 0 to 1 (inclusive).
That is, a value of 1 means completely true,
0.8 means mostly true,
and 0.1 means mostly false.

In order to work more conveniently with standard Boolean logic,
we can extend `Fuzzy` to adopt the `ExpressibleByBooleanLiteral` protocol.

```swift
extension Fuzzy: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self.init(value ? 1.0 : 0.0)
    }
}
```

> In practice,
> there aren't many situations in which it'd be appropriate
> for a type to be initialized using Boolean literals.
> Support for string, integer, and floating-point literals are much more common.

Doing so doesn't change the default meaning of `true` or `false`.
We don't have to worry about existing code breaking
just because we introduced the concept of half-truths to our code base
("_view did appear animated... maybe?_").
The only situations in which `true` or `false` initialize a `Fuzzy` value
would be when the compiler could infer the type to be `Fuzzy`:

```swift
true is Bool // true
true is Fuzzy // false

(true as Fuzzy) is Fuzzy // true
(false as Fuzzy).value // 0.0
```

Because `Fuzzy` is initialized with a single `Double` value,
it's reasonable to allow values to be initialized with
floating-point literals as well.
It's hard to think of any situations in which
a type would support floating-point literals but not integer literals,
so we should do that too
(however, the converse isn't true;
there are plenty of types that work with integer but not floating point numbers).

```swift
extension Fuzzy: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.init(Double(value))
    }
}

extension Fuzzy: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        self.init(value)
    }
}
```

With these protocols adopted,
the `Fuzzy` type now looks and feels like
a _bona fide_ member of Swift standard library.

```swift
let completelyTrue: Fuzzy = true
let mostlyTrue: Fuzzy = 0.8
let mostlyFalse: Fuzzy = 0.1
```

(Now the only thing left to do is implement the standard logical operators!)

If convenience and developer productivity is something you want to optimize for,
you should consider implementing whichever literal protocols
are appropriate for your custom types.

## Future Developments

Literals are an active topic of discussion
for the future of the language.
Looking forward to Swift 5,
there are a number of current proposals
that could have terrific implications for how we write code.

### Raw String Literals

At the time of writing,
[Swift Evolution proposal 0200](https://github.com/apple/swift-evolution/blob/master/proposals/0200-raw-string-escaping.md)
is in active review.
If it's accepted,
future versions of Swift will support "raw" strings,
or string literals that ignores escape sequences.

From the proposal:

> Our design adds customizable string delimiters.
> You may pad a string literal with one or more
> `#` (pound, Number Sign, U+0023) characters [...]
> The number of pound signs at the start of the string
> (in these examples, zero, one, and four)
> must match the number of pound signs at the end of the string.

```swift
"This is a Swift string literal"

#"This is also a Swift string literal"#

####"So is this"####
```

This proposal comes as a natural extension of the new multi-line string literals
added in Swift 4
([SE-0165](https://github.com/apple/swift-evolution/blob/master/proposals/0168-multi-line-string-literals.md)),
and would make it even easier to do work with data formats like JSON and XML.

If nothing else,
adoption of this proposal
could remove the largest obstacle to using Swift on Windows:
dealing with file paths like `C:\Windows\All Users\Application Data`.

### Literal Initialization Via Coercion

Another recent proposal,
[SE-0213: Literal initialization via coercion](https://github.com/apple/swift-evolution/blob/master/proposals/0213-literal-init-via-coercion.md)
is already implemented for Swift 5.

From the proposal:

> `T(literal)` should construct `T`
> using the appropriate literal protocol if possible.

> Currently types conforming to literal protocols
> are type-checked using regular initializer rules,
> which means that for expressions like `UInt32(42)`
> the type-checker is going to look up a set of available initializer choices
> and attempt them one-by-one trying to deduce the best solution.

In Swift 4.2,
initializing a `UInt64` with its maximum value
results in a compile-time overflow
because the compiler first tries to initialize an `Int` with the literal value.

```swift
UInt64(0xffff_ffff_ffff_ffff) // overflows in Swift 4.2
```

Starting in Swift 5,
not only will this expression compile successfully,
but it'll do so a little bit faster, too.

---

The words available to a language speaker
influence not only what they say,
but how they think as well.
In the same way,
the individual parts of a programming language
hold considerable influence over how a developer works.

The way Swift carves up the semantic space of values
makes it different from languages that don't,
for example,
distinguish between integers and floating points
or have separate concepts for strings, characters, and Unicode scalars.
So it's no coincidence that when we write Swift code,
we often think about numbers and strings at a lower level
than if we were hacking away in, say, JavaScript.

Along the same lines,
Swift's current lack of distinction
between string literals and regular expressions
contributes to the relative lack of regex usage compared to other
scripting languages.

That's not to say that having or lacking certain words
makes it impossible to express certain ideas ---
just a bit fuzzier.
We can understand "untranslatable" words like
["Saudade"](https://en.wikipedia.org/wiki/Saudade) in Portuguese,
["Han"](https://en.wikipedia.org/wiki/Han_%28cultural%29) in Korean, or
["Weltschmerz"](https://en.wikipedia.org/wiki/Weltschmerz) in German.

We're all human.
We all understand pain.

By allowing any type to support literal initialization,
Swift invites us to be part of the greater conversation.
Take advantage of this
and make your own code feel like a natural extension of the standard library.
