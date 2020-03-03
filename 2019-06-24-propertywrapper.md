---
title: Swift Property Wrappers
author: Mattt
category: Swift
excerpt: >-
  Swift property wrappers go a long way to making SwiftUI possible,
  but they may play an even more important role
  in shaping the future of the language as a whole.
status:
  swift: 5.1
---

Years ago,
we [remarked](/at-compiler-directives/) that the "at sign" (`@`) ---
along with square brackets and ridiculously-long method names ---
was a defining characteristic of Objective-C.
Then came Swift,
and with it an end to these curious little 🥨-shaped glyphs
...or so we thought.

At first,
the function of `@` was limited to Objective-C interoperability:
`@IBAction`, `@NSCopying`, `@UIApplicationMain`, and so on.
But in time,
Swift has continued to incorporate an ever-increasing number of `@`-prefixed
[attributes](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html).

We got our first glimpse of Swift 5.1 at [WWDC 2019](/wwdc-2019/)
by way of the SwiftUI announcement.
And with each "mind-blowing" slide came a hitherto unknown attribute:
`@State`, `@Binding`, `@EnvironmentObject`...

We saw the future of Swift,
and it was full of `@`s.

---

We'll dive into SwiftUI once it's had a bit longer to bake.

But this week,
we wanted to take a closer look at a key language feature for SwiftUI ---
something that will have arguably the biggest impact on the
<em lang="fr">«je ne sais quoi»</em> of Swift in version 5.1 and beyond:
<dfn>property wrappers</dfn>

---

## About Property <del>Delegates</del> <ins>Wrappers</ins>

Property wrappers were first
[pitched to the Swift forums](https://forums.swift.org/t/pitch-property-delegates/21895)
back in March of 2019 ---
months before the public announcement of SwiftUI.

In his original pitch,
Swift Core Team member Douglas Gregor
described the feature (then called _"property delegates"_)
as a user-accessible generalization of functionality
currently provided by language features like the `lazy` keyword.

Laziness is a virtue in programming,
and this kind of broadly useful functionality
is characteristic of the thoughtful design decisions
that make Swift such a nice language to work with.
When a property is declared as `lazy`,
it defers initialization of its default value until first access.
For example,
you could implement equivalent functionality yourself
using a private property whose access is wrapped by a computed property,
but a single `lazy` keyword makes all of that unnecessary.

<details>
{::nomarkdown}
<summary><em>Expand to lazily evaluate this code expression.</em></summary>
{:/}

```swift
struct <#Structure#> {
    // Deferred property initialization with lazy keyword
    lazy var deferred = <#...#>

    // Equivalent behavior without lazy keyword
    private var _deferred: <#Type#>?
    var deferred: <#Type#> {
        get {
            if let value = _deferred { return value }
            let initialValue = <#...#>
            _deferred = initialValue
            return initialValue
        }

        set {
            _deferred = newValue
        }
    }
}
```

</details>

[SE-0258: Property Wrappers](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md)
is currently in its third review
(scheduled to end yesterday, at the time of publication),
and it promises to open up functionality like `lazy`
so that library authors can implement similar functionality themselves.

The proposal does an excellent job outlining its design and implementation.
So rather than attempt to improve on this explanation,
we thought it'd be interesting to look at
some new patterns that property wrappers make possible ---
and, in the process,
get a better handle on how we might use this feature in our projects.

So, for your consideration,
here are four potential use cases for the new `@propertyWrapper` attribute:

- [Constraining Values](#constraining-values)
- [Transforming Values on Property Assignment](#transforming-values-on-property-assignment)
- [Changing Synthesized Equality and Comparison Semantics](#changing-synthesized-equality-and-comparison-semantics)
- [Auditing Property Access](#auditing-property-access)

---

## Constraining Values

SE-0258 offers plenty of practical examples, including
`@Lazy`, `@Atomic`, `@ThreadSpecific`, and `@Box`.
But the one we were most excited about
was that of the `@Constrained` property wrapper.

Swift's standard library offer [correct](https://en.wikipedia.org/wiki/IEEE_754),
performant, floating-point number types,
and you can have it in any size you want ---
so long as it's
[32](https://developer.apple.com/documentation/swift/float) or
[64](https://developer.apple.com/documentation/swift/double)
<span class="nowrap">(or [80](https://developer.apple.com/documentation/swift/float80))</span> bits long
<span class="nowrap">_([to paraphrase Henry Ford](https://en.wikiquote.org/wiki/Henry_Ford))_</span>.

If you wanted to implement a custom floating-point number type
that enforced a valid range of values,
this has been possible since
[Swift 3](https://github.com/apple/swift-evolution/blob/master/proposals/0067-floating-point-protocols.md).
However, doing so would require conformance to a
labyrinth of protocol requirements.

{::nomarkdown}

<figure id="swift-number-protocols">

{% asset swift-property-wrappers-number-protocols.svg @inline %}

<figcaption>

Credit:
<a href="https://flight.school/books/numbers/">Flight School Guide to Swift Numbers</a></figcaption>

</figure>

{:/}

Pulling this off is no small feat,
and often far too much work to justify
for most use cases.

Fortunately,
property wrappers offer a way to parameterize
standard number types with significantly less effort.

### Implementing a value clamping property wrapper

Consider the following `Clamping` structure.
As a property wrapper (denoted by the `@propertyWrapper` attribute),
it automatically "clamps" out-of-bound values
within the prescribed range.

```swift
@propertyWrapper
struct Clamping<Value: Comparable> {
    var value: Value
    let range: ClosedRange<Value>

    init(initialValue value: Value, _ range: ClosedRange<Value>) {
        precondition(range.contains(value))
        self.value = value
        self.range = range
    }

    var wrappedValue: Value {
        get { value }
        set { value = min(max(range.lowerBound, newValue), range.upperBound) }
    }
}
```

You could use `@Clamping`
to guarantee that a property modeling
[acidity in a chemical solution](https://en.wikipedia.org/wiki/PH)
within the conventional range of 0 – 14.

```swift
struct Solution {
    @Clamping(0...14) var pH: Double = 7.0
}

let carbonicAcid = Solution(pH: 4.68) // at 1 mM under standard conditions
```

Attempting to set pH values outside that range
results in the closest boundary value (minimum or maximum)
to be used instead.

```swift
let superDuperAcid = Solution(pH: -1)
superDuperAcid.pH // 0
```

{% info %}

You can use property wrappers in implementations of other property wrappers.
For example,
this `UnitInterval` property wrapper delegates to `@Clamping`
for constraining values between 0 and 1, inclusive.

```swift
@propertyWrapper
struct UnitInterval<Value: FloatingPoint> {
    @Clamping(0...1)
    var wrappedValue: Value = .zero

    init(initialValue value: Value) {
        self.wrappedValue = value
    }
}
```

For example,
you might use the `@UnitInterval` property wrapper
to define an `RGB` type that expresses
red, green, blue intensities as percentages.

```swift
struct RGB {
    @UnitInterval var red: Double
    @UnitInterval var green: Double
    @UnitInterval var blue: Double
}

let cornflowerBlue = RGB(red: 0.392, green: 0.584, blue: 0.929)
```

{% endinfo %}

#### Related Ideas

- A `@Positive` / `@NonNegative` property wrapper
  that provides the unsigned guarantees to signed integer types.
- A `@NonZero` property wrapper
  that ensures that a number value is either greater than or less than `0`.
- `@Validated` or `@Whitelisted` / `@Blacklisted` property wrappers
  that restrict which values can be assigned.

## Transforming Values on Property Assignment

Accepting text input from users
is a perennial headache among app developers.
There are just so many things to keep track of,
from the innocent banalities of string encoding
to malicious attempts to inject code through a text field.
But among the most subtle and frustrating problems
that developers face when accepting user-generated content
is dealing with leading and trailing whitespace.

A single leading space can
invalidate URLs,
confound date parsers,
and sow chaos by way of off-by-one errors:

```swift
import Foundation

URL(string: " https://nshipster.com") // nil (!)

ISO8601DateFormatter().date(from: " 2019-06-24") // nil (!)

let words = " Hello, world!".components(separatedBy: .whitespaces)
words.count // 3 (!)
```

When it comes to user input,
clients most often plead ignorance
and just send everything _as-is_ to the server.
`¯\_(ツ)_/¯`.

While I'm not advocating for client apps to take on more of this responsibility,
the situation presents another compelling use case for Swift property wrappers.

---

Foundation bridges the `trimmingCharacters(in:)` method to Swift strings,
which provides, among other things,
a convenient way to lop off whitespace
from both the front or back of a `String` value.
Calling this method each time you want to ensure data sanity is, however,
less convenient.
And if you've ever had to do this yourself to any appreciable extent,
you've certainly wondered if there might be a better approach.

In your search for a less ad-hoc approach,
you may have sought redemption through the `willSet` property callback...
only to be disappointed that you can't use this
to change events already in motion.

```swift
struct Post {
    var title: String {
        willSet {
            title = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            /* ⚠️ Attempting to store to property 'title' within its own willSet,
                   which is about to be overwritten by the new value              */
        }
    }
}
```

From there,
you may have realized the potential of `didSet`
as an avenue for greatness...
only to realize later that `didSet` isn't called
during initial property assignment.

```swift
struct Post {
    var title: String {
        // 😓 Not called during initialization
        didSet {
            self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
```

{% info %}
Setting a property in its own `didSet` callback
thankfully doesn't cause the callback to fire again,
so you don't have to worry about accidental infinite self-recursion.
{% endinfo %}

Undeterred,
you may have tried any number of other approaches...
ultimately finding none to yield an acceptable combination of
ergonomics and performance characteristics.

If any of this rings true to your personal experience,
you can rejoice in the knowledge that your search is over:
property wrappers are the solution you've long been waiting for.

### Implementing a Property Wrapper that Trims Whitespace from String Values

Consider the following `Trimmed` struct
that trims whitespaces and newlines from incoming string values.

```swift
import Foundation

@propertyWrapper
struct Trimmed {
    private(set) var value: String = ""

    var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    init(initialValue: String) {
        self.wrappedValue = initialValue
    }
}
```

By marking each `String` property in the `Post` structure below
with the `@Trimmed` annotation,
any string value assigned to `title` or `body` ---
whether during initialization or via property access afterward ---
automatically has its leading or trailing whitespace removed.

```swift
struct Post {
    @Trimmed var title: String
    @Trimmed var body: String
}

let quine = Post(title: "  Swift Property Wrappers  ", body: "<#...#>")
quine.title // "Swift Property Wrappers" (no leading or trailing spaces!)

quine.title = "      @propertyWrapper     "
quine.title // "@propertyWrapper" (still no leading or trailing spaces!)
```

#### Related Ideas

- A `@Transformed` property wrapper that applies
  [ICU transforms](https://developer.apple.com/documentation/foundation/nsstring/1407787-applyingtransform)
  to incoming string values.
- A `@Normalized` property wrapper that allows a `String` property
  to customize its [normalization form](https://unicode.org/reports/tr15/#Norm_Forms).
- A `@Quantized` / `@Rounded` / `@Truncated` property
  that quantizes values to a particular degree (e.g. "round up to nearest ½"),
  but internally tracks precise intermediate values
  to prevent cascading rounding errors.

## Changing Synthesized Equality and Comparison Semantics

{% warning %}
This behavior is contingent on an implementation detail
of synthesized protocol conformance
and may change before this feature is finalized
(though we hope this continues to work as described below).
{% endwarning %}

In Swift,
two `String` values are considered equal
if they are [<dfn>canonically equivalent</dfn>](https://unicode.org/reports/tr15/#Canon_Compat_Equivalence).
By adopting these equality semantics,
Swift strings behave more or less as you'd expect in most circumstances:
if two strings comprise the same characters,
it doesn't matter whether any individual character is composed or precomposed
--- that is,
<span class="nowrap">"é" (`U+00E9 LATIN SMALL LETTER E WITH ACUTE`)</span>
is equal to
<span class="nowrap">"e" (`U+0065 LATIN SMALL LETTER E`)</span> +
<span class="nowrap">"◌́" (`U+0301 COMBINING ACUTE ACCENT`)</span>.

But what if your particular use case calls for different equality semantics?
Say you wanted a <dfn>case insensitive</dfn> notion of string equality?

There are plenty of ways you might go about implementing this today
using existing language features:

- You could take the `lowercased()` result anytime you do `==` comparison,
  but as with any manual process, this approach is error-prone.
- You could create a custom `CaseInsensitive` type that wraps a `String` value,
  but you'd have to do a lot of additional work to make it
  as ergonomic and functional as the standard `String` type.
- You could define a custom comparator function to wrap that comparison ---
  heck, you could even define your own
  [custom operator](/swift-operators/#defining-custom-operators) for it ---
  but nothing comes close to an unqualified `==` between two operands.

None of these options are especially compelling,
but thanks to property wrappers in Swift 5.1,
we'll finally have a solution that gives us what we're looking for.

{% info %}

As with numbers,
Swift takes a protocol-oriented approach
that delegates string responsibilities
across a constellation of narrowly-defined types.

{::nomarkdown}

<details>
<summary>For the curious, here's a diagram showing the relationship between all of the string types in the Swift standard library:</summary>

<figure>

{% asset swift-property-wrappers-string-protocols.svg @inline %}

<figcaption>

Credit:
<a href="https://flight.school/books/strings/">Flight School Guide to Swift Strings</a></figcaption>

</figure>

</details>

{:/}

While you _could_ create your own `String`-equivalent type,
the [documentation](https://developer.apple.com/documentation/swift/stringprotocol)
carries a strong directive to the contrary:

> Do not declare new conformances to StringProtocol.
> Only the `String` and `Substring` types in the standard library
> are valid conforming types.

{% endinfo %}

### Implementing a case-insensitive property wrapper

The `CaseInsensitive` type below
implements a property wrapper around a `String` / `SubString` value.
The type conforms to `Comparable` (and by extension, `Equatable`)
by way of the bridged `NSString` API
[`caseInsensitiveCompare(_:)`](https://developer.apple.com/documentation/foundation/nsstring/1414769-caseinsensitivecompare):

```swift
import Foundation

@propertyWrapper
struct CaseInsensitive<Value: StringProtocol> {
    var wrappedValue: Value
}

extension CaseInsensitive: Comparable {
    private func compare(_ other: CaseInsensitive) -> ComparisonResult {
        wrappedValue.caseInsensitiveCompare(other.wrappedValue)
    }

    static func == (lhs: CaseInsensitive, rhs: CaseInsensitive) -> Bool {
        lhs.compare(rhs) == .orderedSame
    }

    static func < (lhs: CaseInsensitive, rhs: CaseInsensitive) -> Bool {
        lhs.compare(rhs) == .orderedAscending
    }

    static func > (lhs: CaseInsensitive, rhs: CaseInsensitive) -> Bool {
        lhs.compare(rhs) == .orderedDescending
    }
}
```

{% info %}
Although the greater-than operator (`>`)
[can be derived automatically](https://nshipster.com/equatable-and-comparable/#comparable),
we implement it here as a performance optimization
to avoid unnecessary calls to the underlying `caseInsensitiveCompare` method.
{% endinfo %}

Construct two string values that differ only by case,
and they'll return `false` for a standard equality check,
but `true` when wrapped in a `CaseInsensitive` object.

```swift
let hello: String = "hello"
let HELLO: String = "HELLO"

hello == HELLO // false
CaseInsensitive(wrappedValue: hello) == CaseInsensitive(wrappedValue: HELLO) // true
```

So far, this approach is indistinguishable from
the custom "wrapper type" approach described above.
And this is normally where we'd start the long slog of
implementing conformance to `ExpressibleByStringLiteral`
and all of the other protocols
to make `CaseInsensitive` start to feel enough like `String`
to feel good about our approach.

Property wrappers allow us to forego all of this busywork entirely:

```swift
struct Account: Equatable {
    @CaseInsensitive var name: String

    init(name: String) {
        $name = CaseInsensitive(wrappedValue: name)
    }
}

var johnny = Account(name: "johnny")
let JOHNNY = Account(name: "JOHNNY")
let Jane = Account(name: "Jane")

johnny == JOHNNY // true
johnny == Jane // false

johnny.name == JOHNNY.name // false

johnny.name = "Johnny"
johnny.name // "Johnny"
```

Here, `Account` objects are checked for equality
by a case-insensitive comparison on their `name` property value.
However, when we go to get or set the `name` property,
it's a _bona fide_ `String` value.

_That's neat, but what's actually going on here?_

Since Swift 4,
the compiler automatically synthesizes `Equatable` conformance
to types that adopt it in their declaration
and whose stored properties are all themselves `Equatable`.
Because of how compiler synthesis is implemented (at least currently),
wrapped properties are evaluated through their wrapper
rather than their underlying value:

```swift
// Synthesized by Swift Compiler
extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.$name == rhs.$name
    }
}
```

#### Related Ideas

- Defining `@CompatibilityEquivalence`
  such that wrapped `String` properties with the values `"①"` and `"1"`
  are considered equal.
- A `@Approximate` property wrapper to refine
  equality semantics for floating-point types
  (See also [SE-0259](https://github.com/apple/swift-evolution/blob/master/proposals/0259-approximately-equal.md))
- A `@Ranked` property wrapper that takes a function
  that defines strict ordering for, say, enumerated values;
  this could allow, for example,
  the playing card rank `.ace` to be treated either low or high
  in different contexts.

## Auditing Property Access

Business requirements may stipulate certain controls
for who can access which records when
or prescribe some form of accounting for changes over time.

Once again,
this isn't a task typically performed by, _say_, an iOS app;
most business logic is defined on the server,
and most client developers would like to keep it that way.
But this is yet another use case too compelling to ignore
as we start to look at the world through property-wrapped glasses.

### Implementing a Property Value Versioning

The following `Versioned` structure functions as a property wrapper
that intercepts incoming values and creates a timestamped record
when each value is set.

```swift
import Foundation

@propertyWrapper
struct Versioned<Value> {
    private var value: Value
    private(set) var timestampedValues: [(Date, Value)] = []

    var wrappedValue: Value {
        get { value }

        set {
            defer { timestampedValues.append((Date(), value)) }
            value = newValue
        }
    }

    init(initialValue value: Value) {
        self.wrappedValue = value
    }
}
```

A hypothetical `ExpenseReport` class could
wrap its `state` property with the `@Versioned` annotation
to keep a paper trail for each action during processing.

```swift
class ExpenseReport {
    enum State { case submitted, received, approved, denied }

    @Versioned var state: State = .submitted
}
```

#### Related Ideas

- An `@Audited` property wrapper
  that logs each time a property is read or written to.
- A `@Decaying` property wrapper
  that divides a set number value each time
  the value is read.

---

However,
this particular example highlights a major limitation in
the current implementation of property wrappers
that stems from a longstanding deficiency of Swift generally:
**Properties can't be marked as `throws`.**

Without the ability to participate in error handling,
property wrappers don't provide a reasonable way to
enforce and communicate policies.
For example,
if we wanted to extend the `@Versioned` property wrapper from before
to prevent `state` from being set to `.approved` after previously being `.denied`,
our best option is `fatalError()`,
which isn't really suitable for real applications:

```swift
class ExpenseReport {
    @Versioned var state: State = .submitted {
        willSet {
            if newValue == .approved,
                $state.timestampedValues.map { $0.1 }.contains(.denied)
            {
                fatalError("J'Accuse!")
            }
        }
    }
}

var tripExpenses = ExpenseReport()
tripExpenses.state = .denied
tripExpenses.state = .approved // Fatal error: "J'Accuse!"
```

This is just one of several limitations
that we've encountered so far with property wrappers.
In the interest of creating a balanced perspective on this new feature,
we'll use the remainder of this article to enumerate them.

## Limitations

{% warning %}

Some of the shortcomings described below
may be more a limitation of my current understanding or imagination
than that of the proposed language feature itself.

Please [reach out](https://twitter.com/NSHipster/)
with any corrections or suggestions you might have for reconciling them!

{% endwarning %}

### Properties Can't Participate in Error Handling

Properties, unlike functions,
can't be marked as `throws`.

As it were,
this is one of the few remaining distinctions between
these two varieties of type members.
Because properties have both a getter and a setter,
it's not entirely clear what the right design would be
if we were to add error handling ---
especially when you consider how to play nice with syntax for other concerns
like access control, custom getters / setters, and callbacks.

As described in the previous section,
property wrappers have but two methods of recourse
to deal with invalid values:

1. Ignoring them (silently)
2. Crashing with `fatalError()`

Neither of these options is particularly great,
so we'd be very interested by any proposal that addresses this issue.

### Wrapped Properties Can't Be Aliased

Another limitation of the current proposal is that
you can't use instances of property wrappers as property wrappers.

Our `UnitInterval` example from before,
which constrains wrapped values between 0 and 1 (inclusive),
could be succinctly expressed as:

```swift
typealias UnitInterval = Clamping(0...1) // ❌
```

However, this isn't possible.
Nor can you use instances of property wrappers to wrap properties.

```swift
let UnitInterval = Clamping(0...1)
struct Solution { @UnitInterval var pH: Double } // ❌
```

All this actually means in practice is more code replication than would be ideal.
But given that this problem arises out of a fundamental distinction
between types and values in the language,
we can forgive a little duplication if it means avoiding the wrong abstraction.

### Property Wrappers Are Difficult To Compose

Composition of property wrappers is not a commutative operation;
the order in which you declare them
affects how they'll behave.

Consider the interplay between an attribute that
performs [string inflection](https://nshipster.com/valuetransformer/#thinking-forwards-and-backwards)
and other string transforms.
For example,
a composition of property wrappers
to automatically normalize the URL "slug" in a blog post
will yield different results if spaces are replaced with dashes
before or after whitespace is trimmed.

```swift
struct Post {
    <#...#>
    @Dasherized @Trimmed var slug: String
}
```

But getting that to work in the first place is easier said than done!
Attempting to compose two property wrappers that act on `String` values fails,
because the outermost wrapper is acting on a value of the innermost wrapper type.

```swift
@propertyWrapper
struct Dasherized {
    private(set) var value: String = ""

    var wrappedValue: String {
        get { value }
        set { value = newValue.replacingOccurrences(of: " ", with: "-") }
    }

    init(initialValue: String) {
        self.wrappedValue = initialValue
    }
}

struct Post {
    <#...#>
    @Dasherized @Trimmed var slug: String // ⚠️ An internal error occurred.
}
```

There's a way to get this to work,
but it's not entirely obvious or pleasant.
Whether this is something that can be fixed in the implementation
or merely redressed by documentation remains to be seen.

### Property Wrappers Aren't First-Class Dependent Types

A <dfn>dependent type</dfn> is a type defined by its value.
For instance,
"a pair of integers in which the latter is greater than the former" and
"an array with a prime number of elements"
are both dependent types
because their type definition is contingent on its value.

Swift's lack of support for dependent types in its type system
means that any such guarantees must be enforced at run time.

The good news is that property wrappers
get closer than any other language feature proposed thus far
in filling this gap.
However,
they still aren't a complete replacement for true value-dependent types.

You can't use property wrappers to,
for example,
define a new type with a constraint on which values are possible.

```swift
typealias pH = @Clamping(0...14) Double // ❌
func acidity(of: Chemical) -> pH {}
```

Nor can you use property wrappers
to annotate key or value types in collections.

```swift
enum HTTP {
    struct Request {
        var headers: [@CaseInsensitive String: String] // ❌
    }
}
```

These shortcomings are by no means deal-breakers;
property wrappers are extremely useful
and fill an important gap in the language.

It'll be interesting to see whether the addition of property wrappers
will create a renewed interest in bringing dependent types to Swift,
or if they'll be seen as "good enough",
obviating the need to formalize the concept further.

### Property Wrappers Are Difficult to Document

**Pop Quiz**:
Which property wrappers are made available by the SwiftUI framework?

Go ahead and visit
[the official SwiftUI docs](https://developer.apple.com/documentation/swiftui)
and try to answer.

😬

In fairness, this failure isn't unique to property wrappers.

If you were tasked with determining
which protocol was responsible for a particular API in the standard library
or which operators were supported for a pair of types
based only on what was documented on `developer.apple.com`,
you're likely to start considering a mid-career pivot away from computers.

This lack of comprehensibility is made all the more dire
by Swift's increasing complexity.

### Property Wrappers Further Complicate Swift

Swift is a much, _much_ more complex language than Objective-C.
That's been true since Swift 1.0 and has only become more so over time.

The profusion of `@`-prefixed features in Swift ---
whether it's  
[`@dynamicMemberLookup`](https://github.com/apple/swift-evolution/blob/master/proposals/0195-dynamic-member-lookup.md)
and
[`@dynamicCallable`](https://github.com/apple/swift-evolution/blob/master/proposals/0216-dynamic-callable.md)
from Swift 4,
or
[`@differentiable` and `@memberwise`](https://forums.swift.org/t/pre-pitch-swift-differentiable-programming-design-overview/25992)
from [Swift for Tensorflow](https://github.com/tensorflow/swift) ---
makes it increasingly difficult
to come away with a reasonable understanding of Swift APIs
based on documentation alone.
In this respect,
the introduction of `@propertyWrapper` will be a force multiplier.

How will we make sense of it all?
(That's a genuine question, not a rhetorical one.)

---

Alright, let's try to wrap this thing up ---

Swift property wrappers allow library authors access to the kind of
higher-level behavior previously reserved for language features.
Their potential for improving safety and reducing complexity of code is immense,
and we've only begun to scratch the surface of what's possible.

Yet, for all of their promise,
property wrappers and its cohort of language features debuted alongside SwiftUI
introduce tremendous upheaval to Swift.

Or, as Nataliya Patsovska
put it in [a tweet](https://twitter.com/nataliya_bg/status/1140519869361926144):

> iOS API design, short history:
>
> - Objective C - describe all semantics in the name, the types don’t mean much
> - Swift 1 to 5 - name focuses on clarity and basic structs, enums, classes and protocols hold semantics
> - Swift 5.1 - @wrapped \$path @yolo
>
> <cite><a href="https://twitter.com/nataliya_bg/">@nataliya_bg</a></cite>

Perhaps we'll only know looking back
whether Swift 5.1 marked a tipping point or a turning point
for our beloved language.
