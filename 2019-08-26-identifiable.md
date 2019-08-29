---
title: Identifiable
author: Mattt
category: Swift
excerpt: >-
  Swift 5.1 gives us yet another occasion to ponder ontological questions
  and weigh in the relative merits of various built-in types
  as stable identifiers.
status:
  swift: 5.1
---

> What constitutes the identity of an object?

Philosophers have contemplated such matters throughout the ages.
Whether it's to do with
[reconstructed seafaring vessels from antiquity](https://en.wikipedia.org/wiki/Ship_of_Theseus)
or [spacefaring vessels from science fiction](https://scifi.stackexchange.com/questions/13437/in-star-trek-does-the-original-die-in-teleportation),
questions of Ontology reveal our perception and judgment to be
much less certain than we'd like to believe.

Our humble publication has frequented this topic with some regularity,
whether it was attempting to make sense of
[equality in Objective-C](/equality/)
or appreciating the much clearer semantics of Swift
<em lang="fr">vis-à-vis</em> the [`Equatable` protocol](/equatable-and-comparable/).

Swift 5.1 gives us yet another occasion to ponder this old chestnut
by virtue of the new `Identifiable` protocol.
We'll discuss the noumenon of this phenomenal addition to the standard library,
and help you identify opportunities to
realize its potential in your own projects.

But let's dispense with the navel gazing and
jump right into some substance:

---

Swift 5.1 adds the `Identifiable` protocol to the standard library,
declared as follows:

```swift
protocol Identifiable {
    associatedtype ID: Hashable
    var id: ID { get }
}
```

Values of types adopting the `Identifiable` protocol
provide a stable identifier for the entities they represent.

For example,
a `Parcel` object may use the `id` property requirement
to track the package en route to its final destination.
No matter where the package goes,
it can always be looked up by its `id`:

```swift
import CoreLocation

struct Parcel: Identifiable {
    let id: String
    var location: CLPlacemark?
}
```

{% info %}

Our first introduction to the `Identifiable` protocol
actually came by way of SwiftUI;
it's
[thanks to the community](https://forums.swift.org/t/move-swiftuis-identifiable-protocol-and-related-types-into-the-standard-library/25713)
that the type was brought into the fold of the standard library.

Though
[as evidenced by GitHub search results](https://github.com/search?q=%22protocol+Identifiable%22&type=Code),
many of us were already working with `Identifiable` protocols of similar design...
which prompts the question:
_When was the `Identifiable` protocol really introduced?_ 🤔

{% endinfo %}

The Swift Evolution proposal for `Identifiable`,
[SE-0261](https://github.com/apple/swift-evolution/blob/master/proposals/0261-identifiable.md),
was kept small and focused in order to be incorporated quickly.
So, if you were to ask,
_"What do you actually get by conforming to `Identifiable`?"_,
the answer right now is _"Not much."_
As mentioned in the [future directions](https://github.com/apple/swift-evolution/blob/master/proposals/0261-identifiable.md#future-directions),
conformance to `Identifiable` has the potential to unlock
simpler and/or more optimized versions of other functionality,
such as the new [ordered collection diffing](https://github.com/apple/swift-evolution/blob/master/proposals/0240-ordered-collection-diffing.md) APIs.

But the question remains:
_"Why bother conforming to `Identifiable`?"_

The functionality you get from adopting `Identifiable` is primarily semantic,
and require some more explanation.
It's sort of like asking,
_"Why bother conforming to `Equatable`?"_

And actually, that's not a bad place to start.
Let's talk first about `Equatable` and its relation to `Identifiable`:

## Identifiable vs. Equatable

`Identifiable` distinguishes the identity of an entity from its state.

A parcel from our previous example
will change locations frequently as it travels to its recipient.
Yet a normal equality check (`==`)
would fail the moment it leaves its sender:

```swift
extension Parcel: Equatable {}

var specialDelivery = Parcel(id: "123456789012")
specialDelivery.location = CLPlacemark(
                             location: CLLocation(latitude: 37.3327,
                                                  longitude: -122.0053),
                             name: "Cupertino, CA"
                           )

specialDelivery == Parcel(id: "123456789012") // false
specialDelivery.id == Parcel(id: "123456789012").id // true
```

While this is an expected outcome from a small, contrived example,
the very same behavior can lead to confusing results further down the stack,
where you're not as clear about how different parts work with one another.

```swift
var trackedPackages: Set<Parcel> = <#...#>
trackedPackages.contains(Parcel(id: "123456789012")) // false (?)
```

On the subject of `Set`,
let's take a moment to talk about the `Hashable` protocol.

## Identifiable vs. Hashable

In [our article about `Hashable`](/hashable/),
we described how `Set` and `Dictionary` use a calculated hash value
to provide constant-time (`O(1)`) access to elements in a collection.
Although the hash value used to bucket collection elements
may bear a passing resemblance to identifiers,
`Hashable` and `Identifiable` have some important distinctions
in their underlying semantics:

- Unlike identifiers,
  hash values are typically _state-dependent_,
  changing when an object is mutated.
- Identifiers are _stable_ across launches,
  whereas hash values are calculated by randomly generated hash seeds,
  making them _unstable_ between launches.
- Identifiers are _unique_,
  whereas hash values may _collide_,
  requiring additional equality checks when fetched from a collection.
- Identifiers can be _meaningful_,
  whereas hash values are _chaotic_
  by virtue of their hashing functions.

In short,
hash values are similar to
but no replacement for identifiers.

_So what makes for a good identifier, anyway?_

## Choosing ID Types

Aside from conforming to `Hashable`,
`Identifiable` doesn't make any other demands of
its associated `ID` type requirement.
So what are some good candidates?

If you're limited to only what's available in the Swift standard library,
your best options are `Int` and `String`.
Include Foundation,
and you expand your options with `UUID` and `URL`.
Each has its own strengths and weaknesses as identifiers,
and can be more or less suited to a particular situation:

### Int as ID

The great thing about using integers as identifiers
is that (at least on 64-bit systems),
you're unlikely to run out of them anytime soon.

Most systems that use integers to identify records
assign them in an <dfn>auto-incrementing</dfn> manner,
such that each new ID is 1 more than the last one.
Here's a simple example of how you can do this in Swift:

```swift
struct Widget: Identifiable {
    private static var idSequence = sequence(first: 1, next: {$0 + 1})

    let id: Int

    init?() {
        guard let id = Widget.idSequence.next() else { return nil}
        self.id = id
    }
}

Widget()?.id // 1
Widget()?.id // 2
Widget()?.id // 3
```

If you wanted to guarantee uniqueness across launches,
you might instead initialize the sequence with a value
read from a persistent store like `UserDefaults`.
And if you found yourself using this pattern extensively,
you might consider factoring everything into a self-contained
[property wrapper](/propertywrapper/).

Monotonically increasing sequences have a lot of benefits,
and they're easy to implement.

This kind of approach can provide unique identifiers for records,
but only within the scope of the device on which the program is being run
(and even then, we're glossing over a lot with respect to concurrency
and shared mutable state).

If you want to ensure that an identifier is unique across
_every_ device that's running your app, then
congratulations ---you've hit
[a fundamental problem in computer science](https://en.wikipedia.org/wiki/Consensus_%28computer_science%29).
But before you start in on
[vector clocks](https://en.wikipedia.org/wiki/Vector_clock) and
[consensus algorithms](https://en.wikipedia.org/wiki/Consensus_algorithm),
you'll be relieved to know that there's a
much simpler solution:
<dfn>UUIDs</dfn>.

{% error %}

Insofar as this is a concern for your app,
don't expose serial identifiers to end users.
Not only do you inadvertently disclose information about your system
(_"How many customers are there? Just sign up and check the user ID!"_),
but you open the door for unauthorized parties to
enumerate all of the records in your system
(_"Just start at id = 1 and keep incrementing until a record doesn't exist"_).

Granted, this is more of a concern for web apps,
which often use primary keys in URLs,
but it's something to be aware of nonetheless.

{% enderror %}

### UUID as ID

[<abbr title="universally unique identifier">UUID</abbr>s](https://en.wikipedia.org/wiki/Universally_unique_identifier), or
universally unique identifiers,
(mostly) sidestep the problem of consensus with probability.
Each UUID stores 128 bits ---
minus 6 or 7 format bits, depending on the
[version](https://en.wikipedia.org/wiki/Universally_unique_identifier#Versions) ---
which, when randomly generated,
make the chances of <dfn>collision</dfn>,
or two UUIDs being generated with the same value,
_astronomically_ small.

[As discussed in a previous article](/uuid-udid-unique-identifier/),
Foundation provides a built-in implementation of (version-4) UUIDs
by way of the
[`UUID` type](https://developer.apple.com/documentation/foundation/uuid).
Thus making adoption to `Identifiable` with UUIDs trivial:

```swift
import Foundation

struct Gadget: Identifiable {
    let id = UUID()
}

Gadget().id // 584FB4BA-0C1D-4107-9EE5-C555501F2077
Gadget().id // C9FECDCC-37B3-4AEE-A514-64F9F53E74BA
```

Beyond minor ergonomic and cosmetic issues,
`UUID` serves as an excellent alternative to `Int`
for generated identifiers.

However,
your model may already be uniquely identified by a value,
thereby obviating the need to generate a new one.
Under such circumstances,
that value is likely to be a `String`.

{% info %}
On macOS,
you can generate a random UUID from Terminal
with the built-in `uuidgen` command:

```terminal
$ uuidgen
39C884B8-0A11-4B4F-9107-3AB909324DBA
```

{% endinfo %}

### String as ID

We use strings as identifiers all the time,
whether it takes the form of a username or a checksum or a translation key
or something else entirely.

The main drawback to this approach is that,
thanks to The Unicode® Standard,
strings encode thousands of years of written human communication.
So you'll need a strategy for handling identifiers like
"⽜", "𐂌", "", and "🐮"
...and that's to say nothing of the more pedestrian concerns,
like leading and trailing whitespace and case-sensitivity!

Normalization is the key to successfully using strings as identifiers.
The easiest place to do this is in the initializer,
but, again, if you find yourself repeating this code over and over,
[property wrappers](/propertywrapper/) can help you here, too.

```swift
import Foundation

fileprivate extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}

struct Whosit: Identifiable {
    let id: String

    init?(id: String) {
        guard let id = id.trimmingCharacters(in: CharacterSet.letters.inverted)
                         .lowercased()
                         .nonEmpty
        else {
            return nil
        }

        self.id = id
    }
}

Whosit(id: "Cow")?.id // cow
Whosit(id: "--- cow ---")?.id // cow
Whosit(id: "🐮") // nil
```

### URL as ID

URLs (or <dfn>URIs</dfn> if you want to be pedantic)
are arguably the most ubiquitous kind of identifier
among all of the ones described in this article.
Every day, billions of people around the world use URLs
as a way to point to a particular part of the internet.
So URLs a natural choice for an `id` value
if your models already include them.

URLs look like strings,
but they use [syntax](https://tools.ietf.org/html/rfc3986)
to encode multiple components,
like scheme, authority, path, query, and fragment.
Although these formatting rules dispense with much of the invalid input
you might otherwise have to consider for strings,
they still share many of their complexities ---
with a few new ones, just for fun.

The essential problem is that
equivalent URLs may not be equal.
Intrinsic, syntactic details like
case sensitivity,
the presence or absence of a trailing slash (`/`),
and the order of query components
all affect equality comparison.
So do extrinsic, semantic concerns like
a server's policy to upgrade `http` to `https`,
redirect from `www` to the apex domain,
or replace an IP address with a
which might cause different URLs to resolve to the same webpage.

```swift
URL(string: "https://nshipster.com/?a=1&b=2")! ==
    URL(string: "http://www.NSHipster.com?b=2&a=1")! // false

try! Data(contentsOf: URL(string: "https://nshipster.com?a=1&b=2")!) ==
     Data(contentsOf: URL(string: "http://www.NSHipster.com?b=2&a=1")!) // true
```

{% info %}
Many of the same concerns apply to file URLs as well,
which have the additional prevailing concern of resolving relative paths.
{% endinfo %}

If your model gets identifier URLs for records from a trusted source,
then you may take URL equality as an article of faith;
if you regard the server as the ultimate source of truth,
it's often best to follow their lead.

But if you're working with URLs in any other capacity,
you'll want to employ some combination of
[URL normalizations](https://en.wikipedia.org/wiki/URL_normalization)
before using them as an identifier.

Unfortunately, the Foundation framework doesn't provide
a single, suitable API for URL canonicalization,
but `URL` and `URLComponents` provide enough on their own
to let you roll your own
(_though we'll leave that as an exercise for the reader_):

```swift
import Foundation

fileprivate extension URL {
    var normalizedString: String { <#...#> }
}

struct Whatsit: Identifiable {
    let url: URL
    var id: { url.normalizedString }
}

Whatsit(url: "https://example.com/123").id // example.com/123
Whatsit(id: "http://Example.com/123/").id // example.com/123
```

## Creating Custom Identifier ID Types

`UUID` and `URL` both look like strings,
but they use syntax rules to encode information in a structured way.
And depending on your app's particular domain,
you may find other structured data types that
would make for a suitable identifier.

Thanks to the flexible design of the `Identifiable` protocol,
there's nothing to stop you from implementing your own `ID` type.

For example,
if you're working in a retail space,
you might create or repurpose an existing
[`UPC`](https://en.wikipedia.org/wiki/Universal_Product_Code) type
to serve as an identifier:

```swift
struct UPC: Hashable {
    var digits: String
    <#implementation details#>
}

struct Product: Identifiable {
    let id: UPC
    var name: String
    var price: Decimal
}
```

## Three Forms of ID Requirements

As `Identifiable` makes its way into codebases,
you're likely to see it used in one of three different ways:

The newer the code,
the more likely it will be for `id` to be a <dfn>stored</dfn> property ---
most often this will be declared as a constant (that is, with `let`):

```swift
import Foundation

// Style 1: id requirement fulfilled by stored property
extension Product: Identifiable {
    let id: UUID
}
```

Older code that adopts `Identifiable`,
by contrast,
will most likely satisfy the `id` requirement
with a <dfn>computed</dfn> property
that returns an existing value to serve as a stable identifier.
In this way,
conformance to the new protocol is purely additive,
and can be done in an extension:

```swift
import Foundation

struct Product {
    var uuid: UUID
}

// Style 2: id requirement fulfilled by computed property
extension Product: Identifiable {
    var id { uuid }
}
```

If by coincidence the existing class or structure already has an `id` property,
it can add conformance by simply declaring it in an extension
_(assuming that the property type conforms to `Hashable`)_.

```swift
import Foundation

struct Product {
    var id: UUID
}

// Style 3: id requirement fulfilled by existing property
extension Product: Identifiable {}
```

No matter which way you choose,
you should find adopting `Identifiable` in a new or existing codebase
to be straightforward and noninvasive.

---

As we've said [time](/numericcast/) and [again](/never/),
often it's the smallest additions to the language and standard library
that have the biggest impact on how we write code.
(This speaks to the thoughtful,
[protocol-oriented](https://developer.apple.com/videos/play/wwdc2015/408/)
design of Swift's standard library.)

Because what `Identifiable` does is kind of amazing:
**it extends reference semantics to value types**.

When you think about it,
reference types and value types differ not in what information they encode,
but rather how we treat them.

For reference types,
the stable identifier is the address in memory
in which the object resides.
This fact can be plainly observed
by the default protocol implementation of `id` for `AnyObject` types:

```swift
extension Identifiable where Self: AnyObject {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}
```

Ever since Swift first came onto the scene,
the popular fashion has been to eschew all reference types for value types.
And this neophilic tendency has only intensified
with the announcement of SwiftUI.
But taking such a hard-line approach makes a value judgment
of something better understood to be a difference in outlook.

It's no coincidence that much of the terminology of programming
is shared by mathematics and philosophy.
As developers, our work is to construct logical universes, after all.
And in doing so,
we're regularly tasked with reconciling our own mental models
against that of every other abstraction we encounter down the stack ---
down to the very way that we understand electricity and magnetism to work.
