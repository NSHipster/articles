---
title: The Death of Cocoa
author: Mattt Thompson
category: ""
excerpt: "For many of us, the simplicity, elegance, and performance of Apple's hardware and software working together are the reason why we build on their platforms. And yet, after just a few months of working with Swift, Cocoa has begun to lose its luster."
status:
    swift: 1.0
---

Cocoa is the de facto standard library of Objective-C, containing many of the essential frameworks for working in the language, such as Foundation, AppKit, and Core Data. Cocoa Touch is basically just Cocoa with UIKit substituted for AppKit, and is often used interchangeably with Cocoa to refer to the system frameworks on iOS.

For many of us, the simplicity, elegance, and performance of Apple's hardware and software working together are the reason why we build on their platforms. Indeed, no shortage of words have been penned on this site in adulation of Cocoa's design and functionality.

And yet, after just a few months of working with Swift, Cocoa has begun to lose its luster. We all saw Swift as the beginning of the end for Objective-C, but Cocoa? _(It wouldn't be the first time an Apple standard library would be made obsolete. Remember Carbon?)_

Swift is designed with modern language features that allow for safer, more performant code. However, one could be forgiven for seeing Swift as little more than a distraction for the compiler tools team, as very few of Swift's advantages trickle down into conventional application usage.

Having Objective-C and Swift code interoperate in a meaningful way from launch was a strategic—and arguably necessary—decision. Allowing the more adventurous engineers within a team a low-risk way to introduce Swift into existing code bases has been crucial to the wide adoption the new language has already seen. But for all of the effort that's been put into source mapping and API auditing, there's an argument to be made that Cocoa has become something of a liability.

What if we were to build a new Foundation from the Swift Standard Library? What would we do differently, and how could we learn from the mistakes of our past? This may seem an odd thesis for NSHipster, a site founded upon a great deal of affection for Objective-C and Cocoa, but it's one worth exploring.

So to close out this historic year for Apple developers, let's take a moment to look forward at the possibilities going forward.

* * *

> If I have seen further it is by standing on the shoulders of giants.
> <cite>Isaac Newton</cite>

We owe all of our productivity to standard libraries.

When done well, standard libraries not only provide a common implementation of the most useful programming constructs, but they clarify those concepts in a transferable way. It's when a language's standard library diverges from existing (or even internal) convention that [things go south](http://eev.ee/blog/2012/04/09/php-a-fractal-of-bad-design/).

For example, [`NSURLComponents`](http://nshipster.com/nsurl/) conforms to [RFC 3986](http://www.ietf.org/rfc/rfc3986)—a fact made explicit [in the documentation](https://developer.apple.com/library/prerelease/ios/documentation/Foundation/Reference/NSURLComponents_class/index.html). Not only do API consumers osmotically absorb the proper terminology and concepts as a byproduct of usage, but newcomers to the API that are already familiar with RFC 3986 can hit the ground running. (And how much easier it is to write documentation; just "RTFM" with a link to the spec!)

Standard libraries should implement standards.

When we talk about technologies being intuitive, what we usually mean is that they're familiar. Standards from the IETF, ISO, and other bodies should be the common ground on which any new standard library should be built.

Based on this assertion, let's take a look at some specific examples of what Cocoa does, and how a new Swift standard library could improve.

### Numbers

`NSNumber` exists purely as an object wrapper around integer, float, double, and boolean primitives. Without such concerns in Swift, there is no practical role for such a construct.

Swift's standard library has done a remarkable job in structuring its numeric primitives, through a clever combination of [top-level functions and operators](http://nshipster.com/swift-default-protocol-implementations/) and type hierarchies. (And bonus points for including [literals for binary, octal, and hexadecimal in addition to decimal](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_487)). For lack of any real complaints about what's currently there, here are some suggestions for what might be added:

- A suitable replacement for `NSDecimalNumber`. Swift `Double`s are [documented as having 64-bit](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_484), while `NSDecimalNumber` can represent ["any number that can be expressed as `mantissa x 10^exponent` where mantissa is a decimal integer up to 38 digits long, and exponent is an integer from `–128` through `127`"](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSDecimalNumber_Class/index.html). In the meantime, [this gist](https://gist.github.com/mattt/1ed12090d7c89f36fd28) provides some of the necessary additions to work with `NSDecimalNumber` in Swift as one would any of the native numeric types.
- Complex number support, such as what's described in [this gist](https://gist.github.com/mattt/0576b9e4396ab5645aa9).
- Simple native methods for [generating random numbers](http://nshipster.com/random/). [This gist](https://gist.github.com/mattt/f2ee2eed3570d1a9d644) has some examples of what that might look like.
- Methods that take advantage of overloading to provide a uniform interface to performing calculations on one or many numbers, such as those in [Surge](https://github.com/mattt/surge).
- For Playgrounds, a framework with built-in mathematical notation, such as [Euler](https://github.com/mattt/euler), could make for a neat teaching tool.

### Strings

The peril of strings is that they can encode so many different kinds of information. [As written previously](http://nshipster.com/nslocalizedstring/):

> Strings are perhaps the most versatile data type in computing. They're passed around as symbols, used to encode numeric values, associate values to keys, represent resource paths, store linguistic content, and format information.

`NSString` is perhaps _too_ versatile, though. Although it handles Unicode like a champ, the entire API is burdened by the conflation of strings as paths. `stringByAppendingPathComponent:` and its ilk are genuinely useful, but this usefulness ultimately stems from a misappropriation of strings as URLs.

Much of this is due to the fact that `@"this"` (a string literal) is much more convenient than `[NSURL URLWithString:@"that"]` (a constructor). However, with [Swift's literal convertibles](http://nshipster.com/swift-literal-convertible/), it can be just as easy to build URL or Path values.

One of the truly clever design choices for Swift's `String` is the internal use of encoding-independent Unicode characters, with exposed "views" to specific encodings:

> - A collection of UTF-8 code units (accessed with the string’s `utf8` property)
> - A collection of UTF-16 code units (accessed with the string’s `utf16` property)
> - A collection of 21-bit Unicode scalar values, equivalent to the string’s UTF-32 encoding form (accessed with the string's `unicodeScalars` property)

One of the only complaints of Swift `String`s are how much of its functionality is hampered by the way functionality is hidden in top-level functions. Most developers are trained to type `.` and wait for method completion for something like "count"; it's less obvious to consult the top-level `countElements` function. (Again, as described in the [Default Protocol Implementations article](http://nshipster.com/swift-default-protocol-implementations/), this could be solved if either Xcode or Swift itself allowed automatic bridging of explicit and implicit self in functions).

### URI, URL, and URN

An ideal URL implementation would be a value-type (i.e. `struct`) implementation of `NSURLComponents`, which would take over all of the aforementioned path-related APIs currently in `NSString`. [Something along these lines](https://gist.github.com/mattt/d2fa3107e41c63e875e5). A clear implementation of URI schemes, according to [RFC 4395](http://tools.ietf.org/html/rfc4395), could mitigate the conflation of file (`file://`) URLs as they are currently in `NSURL`. A nice implementation of URNs, according to [RFC 2141](https://www.ietf.org/rfc/rfc2141) would do wonders for getting developers to realize what a URN is, and how URIs, URLs, and URNs all relate to one another. _(Again, it's all about transferrable skills)_.

### Data Structures

Swift's functional data structures, from generators to sequences to collections, are, well, beautiful. The use of `Array` and `Dictionary` literals for syntactic sugar strikes a fine balance with the more interesting underlying contours of the Standard Library.

Building on these strong primitives, it is remarkably easy to create production-ready implementations of the data structures from an undergraduate Computer Science curriculum. Armed with Wikipedia and a spare afternoon, pretty much anyone could do it—or at least get close.

It'd be amazing if the Swift standard library provided canonical implementations of a bunch of these (e.g. Tree, Singly- Doubly-Linked Lists, Queue / Stack). But I'll only make the case for one: Set.

The three big collections in Foundation are `NSArray`, `NSDictionary`, and `NSSet` (and their mutable counterparts). Of these, `Set` is the only one currently missing. As a fundamental data structure, they are applicable to a wide variety of use cases. Specifically for Swift, though, `Set` could resolve one of the more awkward corners of the language—[RawOptionSetType](http://nshipster.com/rawoptionsettype/).

> For your consideration, [Nate Cook](http://nshipster.com/authors/nate-cook/) has built [a nice, complete implementation of `Set`](http://natecook.com/blog/2014/08/creating-a-set-type-in-swift/).

### Dates & Times

The calendaring functionality is some of the oldest and most robust in Cocoa. Whereas with most other languages, date and time programming is cause for fear, one does not get the same sense of dread when working with `NSDate` and `NSCalendar`. However, it suffers from being difficult to use and impossible to extend.

In order to do any calendaring calculations, such as getting the date one month from today, one would use `NSCalendar` and [`NSDateComponents`](http://nshipster.com/nsdatecomponents/). That's the _correct_ way to do it, at least... a majority of developers probably still use `dateWithTimeIntervalSinceNow:` with a constant number of seconds hardcoded. Tragically, it's not enough for an API to do things the right way, it must also be easier than doing it the wrong way.

Another shortfall (albeit incredibly minor) of `NSCalendar` is that it doesn't allow for new calendars to be added. For someone doing their darnedest to advocate conversion to the [French Republican Calendar](http://en.wikipedia.org/wiki/French_Republican_Calendar), this is bothersome.

Fortunately, all of the new language features of Swift could be used to solve both of these problems in a really elegant way. It'd take some work to implement, but a calendaring system based on generics could really be something. If anyone wants to take me up on that challenge, [here are some ideas](https://gist.github.com/mattt/7edb54f8f4fde4a3783e).

### Interchange Formats

One of the most astonishing things about Objective-C is how long it took for it to have a standard way of working with JSON (iOS 5 / OS X Lion!). Developers hoping to work with the _most popular interchange format for new web services_ were forced to choose from one of a handful of mutually incompatible third-party libraries.

However, `NSJSONSerialization` is such a miserable experience in Swift that we're repeating history with a new crop of third-party alternatives:

```swift
let data: NSData
var error: NSError? = nil
if let JSON = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary {
    for product in JSON["products"]! as NSArray {
        let name: String = product["name"] as String
        let price: Double = product["price"] as Double
    }
}
```

```objective-c
NSData *data;
NSError *error = nil;
id JSON = [NSJSONSerialization JSONObjectWithData:data
                                          options:0
                                            error:&error];
if (!error) {
    for (id product in JSON[@"products"]) {
        NSString *name = product[@"name"];
        NSNumber *price = product[@"price"];

        // ...
    }
}
```

> In defense of Apple, I once asked an engineer at a WWDC Lab why it took so long for iOS to support JSON. Their answer made a lot of sense. Paraphrasing:
>> Apple is a company with a long view of technology. It's _really_ difficult to tell whether a technology like JSON is going to stick, or if it's just another fad. Apple once released a framework for [PubSub](https://developer.apple.com/library/mac/documentation/InternetWeb/Reference/PubSubReference/_index.html), which despite not being widely known or used, still has to be supported for the foreseeable future. Each technology is a gamble of engineering resources.

Data marshaling and serialization are boring tasks, and boring tasks are exactly what a standard library should take care of. Apple knew this when developing Cocoa, which has robust implementations for both text and binary [property lists](http://en.wikipedia.org/wiki/Property_list), which are the lifeblood of iOS and OS X. It may be difficult to anticipate what other interchange formats will be viable in the long term, but providing official support for emerging technologies on a probationary basis would do a lot to improve things for developers.

### Regular Expressions

Regexes are a staple of scripting languages—enough so that they often have a dedicated syntax for literals, `/ /`. If Swift ever moves on from Cocoa, it would be well-advised to include a successor to `NSRegularExpression`, such as [this wrapper](https://gist.github.com/mattt/3f12f56d72b8d2ebbe62).

### Errors

Objective-C is rather exceptional in [how it uses error pointers](http://nshipster.com/nserror/) (`NSError **`) to communicate runtime failures rather than `@throw`-ing exceptions. It's a pattern every Cocoa developer should be familiar with:

```objective-c
NSError *error = nil;
BOOL success = [[NSFileManager defaultManager] moveItemAtPath:@"/path/to/target"
                                                       toPath:@"/path/to/destination"
                                                        error:&error];
if (!success) {
    NSLog(@"%@", error);
}
```

The `out` parameter for `error` is a workaround for the fact that Objective-C can only have a single return value. If something goes wrong, the `NSError` instance will be populated with a new object with details about the issue.

In Swift, this pattern is unnecessary, since a method can return a tuple with an optional value and error instead:

```swift
func moveItemAtPath(from: String toPath to: String) -> (Bool, NSError?) { ... }
```

We can even take things a step further and define a generic `Result` type, with associated values for success and failure cases:

```swift
struct Error { ... }

public enum Result<T> {
    case Success(T)
    case Failure(Error)
}
```

Using this new pattern, error handling is enforced by the compiler in order to exhaust all possible cases:

```swift
HTTPClient.getUser { (result) in
    switch result {
    case .Success(let user):  // Success
    case .Failure(let error): // Failure
    }
}
```

Patterns like this have emerged from a community eager to improve on existing patterns in pure Swift settings. It would be helpful for a standard library to codify the most useful of these patterns in order to create a shared vocabulary that elevates the level of discourse among developers.

### AppKit & UIKit

AppKit and UIKit are entire topics unto themselves. It's much more likely that the two would take further steps to unify than be rewritten or adapted to Swift anytime soon. A much more interesting question is whether Swift will expand beyond the purview of iOS & OS X development, such as for systems or web scripting, and how that would fundamentally change the role of Cocoa as a de facto standard library.

* * *

## Thinking Further

Perhaps we're thinking too small about what a standard library can be.

The Wolfram Language has [The Mother of All Demos](https://www.youtube.com/watch?v=_P9HqHVPeik#t=1m02.5s) ([with apologies to Douglas Engelbart](http://en.wikipedia.org/wiki/The_Mother_of_All_Demos)) for a programming language.

> Granted, Wolfram is a parallel universe of computation where nothing else exists, and the language itself is a hot mess.

Here's an overview of the [functionality offered in its standard library](http://reference.wolfram.com/language/):

|  |  |  |  |
|----------------------------|-------------------------|--------------------------------|--------------------------|
| 2D / 3D Visualization | Graph Analysis | Data Analytics | Image Processing |
| Audio Processing | Machine Learning | Equation Solving | Algebraic Computation |
| Arbitrary Precision | Calculus Computation | Matrix Computation | String Manipulation |
| Combinatorial Optimization | Computational Geometry | Database Connectivity | Built-In Testing |
| Device Connectivity | Functional Programming | Natural Language Understanding | Sequence Analysis |
| Time Series | Geographic Data | Geomapping | Weather Data |
| Physics & Chemistry Data | Genomic Data | Units & Measures | Control Theory |
| Reliability Analysis | Parallel Computation | Engineering Data | Financial Data |
| Financial Computation | Socioeconomic Data | Popular Culture Data | Boolean Computation |
| Number Theory | Document Generation | Table Formatting | Mathematical Typesetting |
| Interactive Controls | Interface Building | Form Construction | XML Templating |

Conventional wisdom would suggest that, yes: it is unreasonable for a standard library to encode [the production budget of the movie _Avatar_](http://reference.wolfram.com/language/ref/MovieData.html#Examples), [the max speed of a McDonnell Douglas F/A-18 Hornet](http://reference.wolfram.com/language/ref/AircraftData.html#Example), or [the shape of France](http://reference.wolfram.com/language/ref/CountryData.html#Example). That is information that can be retrieved by querying IMDB, scraping Wikipedia, and importing from a GIS system.

But other things, like [converting miles to kilometers](http://reference.wolfram.com/language/ref/UnitConvert.html#Example), [clustering values](http://reference.wolfram.com/language/ref/FindClusters.html), or [knowing the size of the Earth](http://reference.wolfram.com/language/ref/PlanetData.html#Example)—these are things that would be generally useful to a variety of different applications.

Indeed, what sets Cocoa apart from most other standard libraries is all of the specific information it encodes in `NSLocale` and `NSCalendar`, but most of this comes from the [Unicode Common Locale Data Repository (CLDR)](http://cldr.unicode.org).

What's to stop a standard library from pulling in other data sources? Why not expose an interface to [libphonenumber](https://github.com/googlei18n/libphonenumber), or expand on what [HealthKit is already doing](http://nshipster.com/nsformatter/#mass,-length,-&-energy-formatters) for fundamental units?

Incorporating this kind of data in an organized, meaningful way is too much to expect for a third-party framework, and too important to delegate to the free market of open source.

> Yes, in many ways, the question of the role of a standard library is the same as the question of what roles the public and private sectors have in society. Third-Party Libertarians, meet Third-Party Librarytarians.

* * *

Swift is compelling not just in terms of what the language itself can do, but what it means to Apple, to iOS & OS X developers, and the developer community at large. There are so many factors in play that questions of technical feasibility cannot be extricated from their social and economic consequences.

Will Swift be released under an open source license? Will Swift unseat Javascript as the only viable web scripting language by adding interpreter to Safari? Ultimately, these will be the kinds of deciding factors for what will become of the Swift Standard Library. If Swift is to become a portable systems and scripting language, it would first need to extricate itself from the Objective-C runtime and a web of heavy dependencies.

What is almost certain, however, is that Cocoa, like Objective-C, is doomed. It's not as much a question of whether, but when. _(And we're talking years from now; no one is really arguing that Objective-C & Cocoa are going away entirely all at once)_.

**The Swift Standard Library is on a collision course with Cocoa, and if the new language continues to gain momentum, one should expect to see further fracturing and reinvention within the system frameworks.**

For 30 years, these technologies have served us well, and the best we can do to honor their contributions is to learn from their mistakes and make sure that what replaces them are insanely great.

