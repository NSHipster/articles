---
title: Swift Literal Convertibles
author: Mattt Thompson
category: Swift
tags: swift
excerpt: "Last week, we wrote about overloading and creating custom operators in Swift, a language feature that is as powerful as it is controversial. By all accounts, this week's issue threatens to be equally polarizing, as it covers a feature of Swift that is pervasive, yet invisible: literal convertibles."
status:
    swift: 1.2
---

Last week, we wrote about [overloading and creating custom operators](http://nshipster.com/swift-operators/) in Swift, a language feature that is as powerful as it is controversial.

By all accounts, this week's issue threatens to be equally polarizing, as it covers a feature of Swift that is pervasive, yet invisible: literal convertibles.

* * *

In code, a _literal_ is notation representing a fixed value. Most languages define literals for logical values, numbers, strings, and often arrays and dictionaries.

```swift
let int = 57
let float = 6.02
let string = "Hello"
```

Literals are so ingrained in a developer's mental model of programming that most of us don't actively consider what the compiler is actually doing (thereby remaining blissfully unaware of neat tricks like [string interning](http://en.wikipedia.org/wiki/String_interning)).

Having a shorthand for these essential building blocks makes code easier to both read and write.

In Swift, developers are provided a hook into how values are constructed from literals, called _literal convertible protocols_.

The standard library defines 10 such protocols:

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

Any `class` or `struct` conforming to one of these protocols will be eligible to have an instance of itself statically initialized from the corresponding literal.

It's what allows literal values to "just work" across the language.

Take optionals, for example.

## NilLiteralConvertible and Optionals

One of the best parts of optionals in Swift is that the underlying mechanism is actually defined in the language itself:

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

Notice that `Optional` conforms to the `NilLiteralConvertible` protocol:

```swift
protocol NilLiteralConvertible {
    init(nilLiteral: ())
}
```

Now consider the two statements:

```swift
var a: AnyObject = nil // !
var b: AnyObject? = nil
```

The declaration of `var a` generates the compiler warning `Type 'AnyObject' does not conform to the protocol 'NilLiteralConvertible`, while the declaration `var b` works as expected.

Under the hood, when a literal value is assigned, the Swift compiler consults the corresponding `protocol` (in this case `NilLiteralConvertible`), and calls the associated initializer (`init(nilLiteral: ())`).

Although the implementation of `init(nilLiteral: ())` is private, the end result is that an `Optional` set to `nil` becomes `.None`.

## StringLiteralConvertible and Regular Expressions

Swift literal convertibles can be used to provide convenient shorthand initializers for custom objects.

Recall our [`Regex`](http://nshipster.com/swift-operators/) example from last week:

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

Developers coming from a Ruby or Perl background may be disappointed by Swift's lack of support for regular expression literals, but this can be retcon'd in using the `StringLiteralConvertible` protocol:

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

> `StringLiteralConvertible` itself inherits from the `ExtendedGraphemeClusterLiteralConvertible` protocol, which in turn inherits from `UnicodeScalarLiteralConvertible`. `ExtendedGraphemeClusterLiteralType` is an internal type representing a `String` of length 1, while `UnicodeScalarLiteralType` is an internal type representing a `Character`. In order to implement the required `init`s, `ExtendedGraphemeClusterLiteralType` and `UnicodeScalarLiteralType` can be `typealias`'d to `StringLiteralType` and `Character`, respectively.

Now, we can do this:

```swift
let string: String = "foo bar baz"
let regex: Regex = "foo"

regex.match(string) // true
```

...or more simply:

```swift
"foo".match(string) // true
```

Combined with the [custom operator `=~`](http://nshipster.com/swift-operators), this can be made even more idiomatic:

```swift
"foo bar baz" =~ "foo" // true
```

---

Some might bemoan this as the end of comprehensibility, while others will see this merely as filling in one of the missing parts of this new language.

It's all just a matter of what you're used to, and whether you think a developer is entitled to add features to a language in order for it to better suit their purposes.

> Either way, I hope we can all agree that this language feature is _interesting_, and worthy of further investigation. So in that spirit, let's venture forth and illustrate a few more use cases.

---

## ArrayLiteralConvertible and Sets

For a language with such a deep regard for immutability and safety, it's somewhat odd that there is no built-in support for sets in the standard library.

Arrays are nice and all, but the `O(1)` lookup and idempotence of sets... _\*whistful sigh\*_

So here's a simple example of how `Set` might be implemented in Swift, using the built-in `Dictionary` type:

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
        }
    }
}
```

> A real, standard library-calibre implementation of `Set` would involve a _lot_ more Swift-isms, like generators, sequences, and all manner of miscellaneous protocols. It's enough to write an entirely separate article about.

Of course, a standard collection class is only as useful as it is convenient to use. `NSSet` wasn't so lucky to receive the first-class treatment when array and dictionary literal syntax was introduced with the [Apple LLVM Compiler 4.0](http://clang.llvm.org/docs/ObjectiveCLiterals.html), but we can right the wrongs of the past with the `ArrayLiteralConvertible` protocol:

```swift
protocol ArrayLiteralConvertible {
    typealias Element
    init(arrayLiteral elements: Element...)
}
```

Extending `Set` to adopt this protocol is relatively straightforward:

```swift
extension Set: ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        for element in elements {
            put(element)
        }
    }
}
```

But that's all it takes to achieve our desired results:

```swift
let set: Set = [1,2,3]
set.contains(1) // true
set.count // 3
```

> This example does, however, highlight a legitimate concern for literal convertibles: **type inference ambiguity**. Because of the significant API overlap between collection classes like `Array` and `Set`, one could ostensibly write code that would behave differently depending on how the type was resolved (e.g. set addition is idempotent, whereas arrays accumulate, so the count after adding two equivalent elements would differ)

## StringLiteralConvertible and URLs

Alright, one last example creative use of literal convertibles: URL literals.

`NSURL` is the fiat currency of the URL Loading System, with the nice feature of introspection of its component parts according to [RFC 2396](https://www.ietf.org/rfc/rfc2396.txt). Unfortunately, it's so inconvenient to instantiate, that third-party framework authors often decide to ditch them in favor of worse-but-more-convenient strings for method parameters.

With a simple extension on `NSURL`, one can get the best of both worlds:

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

One neat feature of literal convertibles is that the type inference works even without a variable declaration:

```swift
"http://nshipster.com/".host // nshipster.com
```

* * *

As a community, it's up to us to decide what capabilities of Swift are features and what are bugs. We'll be the ones to distinguish pattern from anti-pattern; convention from red flag.

So it's unclear, at the present moment, how things like literal convertibles, custom operators, and all of the other capabilities of Swift will be reconciled. This publication has, at times, been more or less prescriptive on how things should be, but in this case, that's not the case here.

All there is to be done is to experiment and learn.
