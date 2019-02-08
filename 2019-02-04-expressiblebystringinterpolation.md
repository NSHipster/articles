---
title: ExpressibleByStringInterpolation
author: Mattt
category: Swift
excerpt: >-
  Swift 5 overhauls how values in string literals are interpolated,
  and incidentally overturned several decades' worth 
  of problematic programming conventions.
status:
  swift: 5.0
---

Swift is designed ---
first and foremost ---
to be a [safe](https://swift.org/about/#safety) language.
Numbers and collections are checked for overflow,
variables are always initialized before first use,
optionals ensure that non-values are handled correctly,
and any potentially unsafe operations are named accordingly.

These language features go a long way to eliminate
some of the most common programming errors,
but we'd be remiss to let our `guard` down.

Today, I want to talk about one of the most exciting new features in Swift 5:
an overhaul to how values in string literals are interpolated
by way of the `ExpressibleByStringInterpolation` protocol.
A lot of folks are excited about the cool things you can do with it.
(And rightfully so! We'll get to all of that in just a moment)
But I think it's important to take a broader view of this feature
to understand the full scope of its impact.

---

Format strings are _awful_.

After incorrect `NULL` handling, buffer overflows, and uninitialized variables,
[`printf` / `scanf`](https://en.wikipedia.org/wiki/printf)-style format strings
are arguably the most problematic holdovers from C-style programming language.

In the past 20 years,
security professionals have documented
[hundreds of vulnerabilities](https://nvd.nist.gov/vuln/search/results?form_type=Advanced&results_type=overview&search_type=all&cwe_id=CWE-134)
related to format string vulnerabilities.
It's so commonplace that it's assigned its very own
[Common Weakness Enumeration](https://en.wikipedia.org/wiki/Common_Weakness_Enumeration)
(<abbr title="Common Weakness Enumeration">CWE</abbr>) category.

Not only are they insecure,
but they're hard to use.
Yes, _hard_ to use.

Consider the `dateFormat` property on `DateFormatter`,
which takes an [`strftime`](https://en.wikipedia.org/wiki/strftime)
format string.
If we wanted to create a string representation of a date
that included its 4-digit year,
we'd use `"YYYY"`, as in `"Y"` for year
..._right?_

```swift
let formatter = DateFormatter()
formatter.dateFormat = "YYYY-MM-dd"

formatter.string(from: Date()) // 2019-02-04 (🤨)
```

It sure looks that way,
at least for the first 360-ish days of the year.
But what if we jump to the last day of the year?

```swift
let dateComponents = DateComponents(year: 2019,
                                    month: 12,
                                    day: 31)
let date = Calendar.current.date(from: dateComponents)!
formatter.string(from: date) // 2020-12-31 (😱)
```

_Huh what?_
Turns out `"YYYY"` is the format for the
[ISO week-numbering year](http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns),
which returns 2020 for December 31st, 2019
because the following day is a Wednesday
in the first week of the new year.

What we _actually_ want is `"yyyy"`.

```swift
formatter.dateFormat = "yyyy-MM-dd"
formatter.string(from: date) // 2019-12-31 (😄)
```

Format strings are the worst kind of hard to use,
because they're so easy to use _incorrectly_.
And date format strings are the worst of the worst,
because it may not be clear that you're doing it wrong until it's too late.
They're _literal_ time bombs in your codebase.

{% error %}
Take a moment now,
if you haven't already,
to audit your code base for use of `"YYYY"` in date format strings
when you actually meant to use `"yyyy"`.
{% enderror %}

---

The problem up until now has been that
APIs have had to choose between
dangerous-but-expressive <dfn>domain-specific languages</dfn>
(<abbr title="domain-specific languages">DSLs</abbr>),
such as format strings,
and the correct-but-less-flexible method calls.

New in Swift 5,
the `ExpressibleByStringInterpolation` protocol
allows for these kinds of APIs to be both correct and expressive.
And in doing so,
it overturns decades' worth of problematic behavior.

So without further ado,
let's look at what `ExpressibleByStringInterpolation` is and how it works:

---

## ExpressibleByStringInterpolation

Types that conform to the `ExpressibleByStringInterpolation` protocol
can customize how interpolated values
(that is, values escaped by `\(<#...#>)`)
in string literals.

You can take advantage of this new protocol either by
extending the default `String` interpolation type
(`DefaultStringInterpolation`)
or by creating a new type that conforms to `ExpressibleByStringInterpolation`.

{% info %}
For more information,
see Swift Evolution proposal
[SE-0228: "Fix ExpressibleByStringInterpolation"](https://github.com/apple/swift-evolution/blob/master/proposals/0228-fix-expressiblebystringinterpolation.md).
{% endinfo %}

## Extending Default String Interpolation

By default,
and prior to Swift 5,
all interpolated values in a string literal
were sent to directly to a `String` initializer.
Now with `ExpressibleByStringInterpolation`,
you can specify additional parameters
as if you were calling a method
(indeed, that's what you're doing under the hood).

As an example,
let's revisit the previous mixup of `"YYYY"` and `"yyyy"`
and see how this confusion could be avoided
with `ExpressibleByStringInterpolation`.

By extending `String`'s default interpolation type
(aptly-named `DefaultStringInterpolation`),
we can define a new method called `appendingInterpolation`.
The type of the first, unnamed parameter
determines which interpolation methods are available
for the value to be interpolated.
In our case,
we'll define an `appendInterpolation` method that takes a `Date` argument
and an additional `component` parameter of type `Calendar.Component`
that we'll use to specify which

```swift
import Foundation

#if swift(<5)
#error("Download Xcode 10.2 Beta 2 to see this in action")
#endif

extension DefaultStringInterpolation {
    mutating func appendInterpolation(_ value: Date,
                                      component: Calendar.Component)
    {
        let dateComponents =
            Calendar.current.dateComponents([component],
                                            from: value)

        self.appendInterpolation(
            dateComponents.value(for: component)!
        )
    }
}
```

Now we can interpolate the date for each of the individual components:

```swift
"\(date, component: .year)-\(date, component: .month)-\(date, component: .day)"
// "2019-12-31"
```

It's verbose, yes.
But you'd never mistake `.yearForWeekOfYear`,
the calendar component equivalent of `"YYYY"`,
for what you actually want.

But really,
we shouldn't be formatting dates by hand like this anyway.
We should be delegating that responsibility to a `DateFormatter`:

You can overload interpolations just like any other Swift method,
and having multiple with the same name but different type signatures.
For example,
we can define interpolators for dates and numbers
that take a `formatter` of the corresponding type.

```swift
import Foundation

extension DefaultStringInterpolation {
    mutating func appendInterpolation(_ value: Date,
                                      formatter: DateFormatter)
    {
        self.appendInterpolation(
            formatter.string(from: value)
        )
    }

    mutating func appendInterpolation<T>(_ value: T,
                                         formatter: NumberFormatter)
        where T : Numeric
    {
        self.appendInterpolation(
            formatter.string(from: value as! NSNumber)!
        )
    }
}
```

This allows for a consistent interface to equivalent functionality,
such as formatting interpolated dates and numbers.

```swift
let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .full
dateFormatter.timeStyle = .none
"Today is \(Date(), formatter: dateFormatter)"
// "Today is Monday, February 4, 2019"

let numberformatter = NumberFormatter()
numberformatter.numberStyle = .spellOut

"one plus one is \(1 + 1, formatter: numberformatter)"
// "one plus one is two"
```

## Implementing a Custom String Interpolation Type

In addition to extending `DefaultStringInterpolation`,
you can define custom string interpolation behavior on a custom type
that conforms to `ExpressibleByStringInterpolation`.
You might do that if any of the following is true:

- You want to differentiate between literal and interpolated segments
- You want to restrict which types can be interpolated
- You want to support different interpolation behavior
  than provided by default
- You want to avoid burdening the built-in string interpolation type
  with excessive API surface area

For a simple example of this,
consider a custom type that escapes values in XML,
similar to one of the loggers
[that we described last week](/textoutputstream/#escaping-streamed-output).
Our goal: to provide a nice templating API
that allows us to write XML / HTML
and interpolate values in a way that automatically escapes characters
like `<` and `>`.

We'll start simply with a wrapper around a single `String` value.

```swift
struct XMLEscapedString: LosslessStringConvertible {
  var value: String

  init?(_ value: String) {
    self.value = value
  }

  var description: String {
    return self.value
  }
}
```

We add conformance to `ExpressibleByStringInterpolation` in an extension,
just like any other protocol.
It inherits from `ExpressibleByStringLiteral`,
which requires an `init(stringLiteral:)` initializer.
`ExpressibleByStringInterpolation` itself requires
an `init(stringInterpolation:)` initializer
that takes an instance of the required, associated `StringInterpolation` type.

This associated `StringInterpolation` type is responsible for
collecting all of the literal segments
and interpolated values
from the string literal.
All literal segments are passed to the `appendLiteral(_:)` method.
For interpolated values,
the compiler finds the `appendInterpolation` method
that matches the specified parameters.
In this case,
both literal and interpolated values are collected into a mutable string.

{% info %}
The `StringInterpolationProtocol`,
requires an initializer, `init(literalCapacity:interpolationCount:)`;
as an optional optimization,
the capacity and interpolation counts
can be used to, for example,
allocate enough space to hold the resulting string.
{% endinfo %}

```swift
import Foundation

extension XMLEscapedString: ExpressibleByStringInterpolation {
  init(stringLiteral value: String) {
    self.init(value)!
  }

  init(stringInterpolation: StringInterpolation) {
    self.init(stringInterpolation.value)!
  }

  struct StringInterpolation: StringInterpolationProtocol {
    var value: String = ""

    init(literalCapacity: Int, interpolationCount: Int) {
        self.value.reserveCapacity(literalCapacity)
    }

    mutating func appendLiteral(_ literal: String) {
        self.value.append(literal)
    }

    mutating func appendInterpolation<T>(_ value: T)
        where T: CustomStringConvertible
    {
        let escaped = CFXMLCreateStringByEscapingEntities(
            nil, value.description as NSString, nil
        )! as NSString

        self.value.append(escaped as String)
    }
  }
}
```

With all of this in place,
we can now initialize `XMLEscapedString` with a string literal
that automatically escapes interpolated values.
(_No XSS exploits for us, thank you!_)

```swift
let name = "<bobby>"
let markup: XMLEscapedString = """
<p>Hello, \(name)!</p>
"""
print(markup)
// <p>Hello, &lt;bobby&gt;!</p>
```

One of the best parts of this functionality
is how transparent its implementation is.
For behavior that feels quite magical,
you'll never have to wonder how it works.

Compare the string literal above
to the equivalent API calls below:

```swift

var interpolation =
    XMLEscapedString.StringInterpolation(literalCapacity: 15,
                                         interpolationCount: 1)
interpolation.appendLiteral("<p>Hello, ")
interpolation.appendInterpolation(name)
interpolation.appendLiteral("!</p>")

let markup = XMLEscapedString(stringInterpolation: interpolation)
// <p>Hello, &lt;bobby&gt;!</p>
```

Reads just like poetry, doesn't it?

{% info %}
For a more advanced example of `ExpressibleByStringInterpolation`,
check out the
[Unicode Styling playground](https://github.com/Flight-School/Guide-to-Swift-Strings-Sample-Code/tree/master/Chapter%203/Unicode%20Styling.playground)
included in the sample code for the
[Flight School Guide to Swift Strings](https://flight.school/books/strings)
{% endinfo %}

---

Seeing how `ExpressibleByStringInterpolation` works,
it's hard not to look around and find countless opportunities
for where it could be used:

- **Formatting**
  String interpolation offers a safer and easier-to-understand
  alternative to date and number format strings.
- **Escaping**
  Whether its escaping entities in
  URLs, XML documents, shell command arguments,
  or values in SQL queries,
  extensible string interpolation makes correct behavior seamless and automatic.
- **Decorating**
  Use string interpolation to create a type-safe DSL
  for creating attributed strings for apps
  and terminal output with ANSI control sequences for color and effects,
  or pad unadorned text to match the desired alignment.
- **Localizating**
  Rather than relying on a a script that scans source code
  looking for matches on "NSLocalizedString",
  string interpolation allows us to build tools that leverage the compiler
  to find all instances of localized strings.

If you take all of these and factor in possible future support for
[compile-time constant expression](https://forums.swift.org/t/compile-time-constant-expressions-for-swift/12879),
what you find is that Swift 5
may have just stumbled onto the new best way to deal with formatting.
