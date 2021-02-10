---
title: Swift Code Formatters
author: Mattt
category: Swift
excerpt: >-
  Lately,
  the Swift community has been buzzing about the latest pitch
  to adopt an official style guide and formatting tool for the language.
  Let's take a look at where we're at today,
  how the proposed `swift-format` tool stacks up,
  and what we might expect in the future.
status:
  swift: 5.0
revisions:
  "2019-03-04": Original publication
  "2019-05-20": Updated and expanded
---

> I just left a hipster coffee shop.
> It was packed with iOS devs,
> whispering amongst each other about how
> they can't wait for Apple to release
> an official style guide and formatter for Swift.

Lately,
the community has been buzzing about
the proposal from
[Tony Allevato](https://github.com/allevato) and
[Dave Abrahams](https://github.com/dabrahams)
to adopt an official style guide and formatting tool for the Swift language.

Hundreds of community members have weighed in on the
[initial pitch](https://forums.swift.org/t/pitch-an-official-style-guide-and-formatter-for-swift/21025)
and [proposal](https://forums.swift.org/t/se-0250-swift-code-style-guidelines-and-formatter/21795/39).
As with all matters of style,
opinions are strong, and everybody has one.
Fortunately,
the discourse from the community
has been generally constructive and insightful,
articulating a diversity of viewpoints, use cases, and concerns.

Since our article was first published back in March,
the proposal,
["SE-0250: Swift Code Style Guidelines and Formatter"](https://github.com/apple/swift-evolution/blob/master/proposals/0250-swift-style-guide-and-formatter.md)
started formal review;
that process was later
[suspended](https://forums.swift.org/t/se-0250-swift-code-style-guidelines-and-formatter/21795/217),
to be reconsidered sometime in the future.

In spite of this,
Swift code formatting remains a topic of interest to many developers.
So this week on NSHipster,
we're taking another look at the current field of
Swift formatters available today ---
including the `swift-format` tool released as part of the proposal ---
and see how they all stack up.
From there,
we'll take a step back and try to put everything in perspective.

But first,
let's start with a question:

---

## What is Code Formatting?

For our purposes,
we'll define <dfn>code formatting</dfn>
as any change made to code that makes it easier to understand
without changing its behavior.
Although this definition extends to differences in equivalent forms,
(e.g. `[Int]` vs. `Array<Int>`),
we'll limit our discussion here to whitespace and punctuation.

Swift, like many other programming languages,
is quite liberal in its acceptance of newlines, tabs, and spaces.
Most whitespace is insignificant,
having no effect on the code around from the compiler's point of view.

When we use whitespace to make code more comprehensible
without changing its behavior,
that's an example of
[<dfn>secondary notation</dfn>](https://en.wikipedia.org/wiki/Secondary_notation);
the <dfn>primary notation</dfn>, of course,
being the code itself.

{% info %}
Another example of secondary notation is <dfn>syntax highlighting</dfn>,
discussed in [a previous NSHipster article](/swiftsyntax/).
{% endinfo %}

Put enough semicolons in the right places,
and you can write pretty much anything in a single line of code.
But all things being equal,
why not use horizontal and vertical whitespace
to visually structure code in a way that's easier for us to understand,
right?

Unfortunately,
the ambiguity created by the compiler's accepting nature of whitespace
can often cause confusion and disagreement among programmers:
_"Should I add a newline before a curly bracket?
How do I break up statements that extend beyond the width of the editor?"_

Organizations often codify guidelines for how to deal with these issues,
but they're often under-specified, under-enforced, and out-of-date.
The role of a <dfn>code formatter</dfn>
is to automatically enforce a set of conventions
so that programmers can set aside their differences
and get to work solving actual problems.

## Formatter Tool Comparison

The Swift community has considered questions of style from the very beginning.
Style guides have existed from the very first days of Swift,
as have various open source tools to automate the process
of formatting code to match them.

To get a sense of the current state of Swift code formatters,
we'll take a look at the following four tools:

| Project                                                                 | Repository URL                                |
| ----------------------------------------------------------------------- | --------------------------------------------- |
| [SwiftFormat](#swiftformat)                                             | <https://github.com/nicklockwood/SwiftFormat> |
| [SwiftLint](#swiftlint)                                                 | <https://github.com/realm/SwiftLint>          |
| [swift-format](#swift-format)                                           | <https://github.com/google/swift/tree/format> |

{% info %}

For brevity,
this article discusses only some of the Swift formatting tools available.
Here are some other ones that you may want to check out:
[Swimat](https://github.com/Jintin/Swimat),
[SwiftRewriter](https://github.com/inamiy/SwiftRewriter),
[swiftfmt](https://github.com/kishikawakatsumi/swiftfmt),
and [Prettier with Swift Plugin](https://github.com/prettier/prettier).

{% endinfo %}

To establish a basis of comparison,
we've contrived the following code sample to evaluate each tool
(using their default configuration):

```swift

        struct ShippingAddress : Codable  {
 var recipient: String
  var streetAddress : String
   var locality :String
    var region   :String;var postalCode:String
    var country:String

    init(     recipient: String,        streetAddress: String,
locality: String,region: String,postalCode: String,country:String               )
{
    self.recipient = recipient
    self.streetAddress = streetAddress
        self.locality  = locality
    self.region        = region;self.postalCode=postalCode
        guard country.count == 2, country == country.uppercased() else { fatalError("invalid country code") }
    self.country=country}}

let applePark = ShippingAddress(recipient:"Apple, Inc.", streetAddress:"1 Apple Park Way", locality:"Cupertino", region:"CA", postalCode:"95014", country:"US")

```

Although code formatting encompasses a wide range of possible
syntactic and semantic transformations,
we'll focus on newlines and indentation,
which we believe to be baseline requirements for any code formatter.

{% info %}
The performance benchmarks in this article are, admittedly, not very rigorous.
But they should provide some indication of general performance characteristics.
Timings are measured in seconds
and taken on a 2017 MacBook Pro
with 2.9 GHz Intel Core i7 processor and 16 GB 2133 MHz LPDDR3 memory.
{% endinfo %}

### SwiftFormat

First up is
[SwiftFormat](https://github.com/nicklockwood/SwiftFormat),
a tool as helpful as it is self-descriptive.

#### Installation

SwiftFormat is distributed via [Homebrew](/homebrew/)
as well as [Mint](https://github.com/yonaskolb/Mint) and
[CocoaPods](/CocoaPods/).

You can install it by running the following command:

```terminal
$ brew install swiftformat
```

In addition,
SwiftFormat also provides an Xcode Source Editor Extension,
found in the [EditorExtension](https://github.com/nicklockwood/SwiftFormat/tree/master/EditorExtension),
which you can use to reformat code in Xcode.
Or, if you're a user of [VSCode](/vscode/),
you can invoke SwiftFormat with
[this plugin](https://marketplace.visualstudio.com/items?itemName=vknabel.vscode-swiftformat).

#### Usage

The `swiftformat` command formats each Swift file
found in the specified file and directory paths.

```terminal
$ swiftformat Example.swift
```

SwiftFormat has a variety of rules that can be configured
either individually via command-line options
or using a configuration file.

#### Example Output

Running the `swiftformat` command on our example
using the default set of rules produces the following result:

```swift
// swiftformat version 0.40.8

struct ShippingAddress: Codable {
    var recipient: String
    var streetAddress: String
    var locality: String
    var region: String; var postalCode: String
    var country: String

    init(recipient: String, streetAddress: String,
         locality: String, region: String, postalCode: String, country: String) {
        self.recipient = recipient
        self.streetAddress = streetAddress
        self.locality = locality
        self.region = region; self.postalCode = postalCode
        guard country.count == 2, country == country.uppercased() else { fatalError("invalid country code") }
        self.country = country
    }
}

let applePark = ShippingAddress(recipient: "Apple, Inc.", streetAddress: "1 Apple Park Way", locality: "Cupertino", region: "CA", postalCode: "95014", country: "US")
```

As you can see,
this is a clear improvement over the original.
Each line is indented according to its scope,
and each declaration has consistent spacing between punctuation.
Both the semicolon in the property declarations
and the newline in the initializer parameters are preserved;
<del>however, the closing curly braces aren't moved to separate lines
as might be expected</del>
<ins>this is [fixed in 0.39.5](https://twitter.com/nicklockwood/status/1103595525792845825).
Great work, [Nick](https://github.com/nicklockwood)!</ins>

{% warning %}
In version 0.38.0 and later,
`swiftformat` emits a warning if no Swift version is specified.
You can specify a version either by
passing the `--swiftversion` command line option or
adding a `.swift-version` file to the current directory.
{% endwarning %}

#### Performance

SwiftFormat is consistently the fastest of the tools tested in this article,
completing in a few milliseconds.

```terminal
$ time swiftformat Example.swift
        0.03 real         0.01 user         0.01 sys
```

### SwiftLint

Next up is,
[SwiftLint](https://github.com/realm/SwiftLint),
a mainstay of the Swift open source community.
With over 100 built-in rules,
SwiftLint can perform a wide variety of checks on your code ---
everything from preferring `AnyObject` over `class` for class-only protocols
to the so-called "Yoda condition rule",
which prescribes variables to be placed on
the left-hand side of comparison operators
(that is, `if n == 42` not `if 42 == n`).

As its name implies,
SwiftLint is not primarily a code formatter;
it's really a diagnostic tool for identifying
convention violation and API misuse.
However, by virtue of its auto-correction faculties,
it's frequently used to format code.

#### Installation

You can install SwiftLint using Homebrew
with the following command:

```terminal
$ brew install swiftlint
```

Alternatively, you can install SwiftLint with
[CocoaPods](/CocoaPods/),
[Mint](https://github.com/yonaskolb/Mint),
or as a [standalone installer package (`.pkg`)](https://github.com/realm/SwiftLint/releases/tag/0.31.0).

#### Usage

To use SwiftLint as a code formatter,
run the `autocorrect` subcommand
passing the `--format` option
and the files or directories to correct.

```terminal
$ swiftlint autocorrect --format --path Example.swift
```

#### Example Output

Running the previous command on our example
yields the following:

```swift
// swiftlint version 0.32.0
struct ShippingAddress: Codable {
    var recipient: String
    var streetAddress: String
    var locality: String
    var region: String;var postalCode: String
    var country: String

    init(     recipient: String, streetAddress: String,
              locality: String, region: String, postalCode: String, country: String               ) {
        self.recipient = recipient
        self.streetAddress = streetAddress
        self.locality  = locality
        self.region        = region;self.postalCode=postalCode
        guard country.count == 2, country == country.uppercased() else { fatalError("invalid country code") }
        self.country=country}}

let applePark = ShippingAddress(recipient: "Apple, Inc.", streetAddress: "1 Apple Park Way", locality: "Cupertino", region: "CA", postalCode: "95014", country: "US")

```

SwiftLint cleans up the worst of the indentation and inter-spacing issues
but leaves other, extraneous whitespace intact
(though it does strip the file's leading newline, which is nice).
Again, it's worth noting that formatting isn't SwiftLint's primary calling;
if anything, it's merely incidental to providing actionable code diagnostics.
And taken from the perspective of _"first, do no harm"_,
it's hard to complain about the results here.

#### Performance

For everything that SwiftLint checks for,
it's remarkably snappy ---
completing in a fraction of a second for our example.

```terminal
$ time swiftlint autocorrect --quiet --format --path Example.swift
        0.09 real         0.04 user         0.01 sys
```

---

### swift-format

Having looked at the current landscape of available Swift formatters,
we now have a reasonable baseline for evaluating the `swift-format` tool
proposed by Tony Allevato and Dave Abrahams.

#### Installation

You can install using [Homebrew](https://brew.sh) with the following command:
```terminal
$ brew install swift-format
```

Alternatively, you can clone its [source repository](https://github.com/apple/swift-format) and build it yourself.
https://github.com/apple/swift-format.

#### Usage

Run the `swift-format` command,
passing one or more file and directory paths
to Swift files that you want to format.

```terminal
$ swift-format Example.swift
```

The `swift-format` command also takes a `--configuration` option,
which takes a path to a JSON file.
For now,
the easiest way to customize `swift-format` behavior
is to dump the default configuration to a file
and go from there.

```terminal
$ swift-format -m dump-configuration > .swift-format.json
```

Running the command above populates the specified file
with the following JSON:

```json
{
  "blankLineBetweenMembers": {
    "ignoreSingleLineProperties": true
  },
  "indentation": {
    "spaces": 2
  },
  "lineBreakBeforeControlFlowKeywords": false,
  "lineBreakBeforeEachArgument": true,
  "lineLength": 100,
  "maximumBlankLines": 1,
  "respectsExistingLineBreaks": true,
  "rules": {
    "AllPublicDeclarationsHaveDocumentation": true,
    "AlwaysUseLowerCamelCase": true,
    "AmbiguousTrailingClosureOverload": true,
    "AvoidInitializersForLiterals": true,
    "BeginDocumentationCommentWithOneLineSummary": true,
    "BlankLineBetweenMembers": true,
    "CaseIndentLevelEqualsSwitch": true,
    "DoNotUseSemicolons": true,
    "DontRepeatTypeInStaticProperties": true,
    "FullyIndirectEnum": true,
    "GroupNumericLiterals": true,
    "IdentifiersMustBeASCII": true,
    "MultiLineTrailingCommas": true,
    "NeverForceUnwrap": true,
    "NeverUseForceTry": true,
    "NeverUseImplicitlyUnwrappedOptionals": true,
    "NoAccessLevelOnExtensionDeclaration": true,
    "NoBlockComments": true,
    "NoCasesWithOnlyFallthrough": true,
    "NoEmptyAssociatedValues": true,
    "NoEmptyTrailingClosureParentheses": true,
    "NoLabelsInCasePatterns": true,
    "NoLeadingUnderscores": true,
    "NoParensAroundConditions": true,
    "NoVoidReturnOnFunctionSignature": true,
    "OneCasePerLine": true,
    "OneVariableDeclarationPerLine": true,
    "OnlyOneTrailingClosureArgument": true,
    "OrderedImports": true,
    "ReturnVoidInsteadOfEmptyTuple": true,
    "UseEnumForNamespacing": true,
    "UseLetInEveryBoundCaseVariable": true,
    "UseOnlyUTF8": true,
    "UseShorthandTypeNames": true,
    "UseSingleLinePropertyGetter": true,
    "UseSpecialEscapeSequences": true,
    "UseSynthesizedInitializer": true,
    "UseTripleSlashForDocumentationComments": true,
    "ValidateDocumentationComments": true
  },
  "tabWidth": 8,
  "version": 1
}
```

After fiddling with the configuration ---
such as setting `lineLength` to the correct value of 80 _(don't @ me)_ ---
you can apply it thusly:

```terminal
$ swift-format Example.swift --configuration .swift-format.json
```

#### Example Output

Using its default configuration,
here's how `swift-format` formats our example:

```swift
// swift-format 0.0.1 (2019-05-15, 115870c)
struct ShippingAddress: Codable {
  var recipient: String
  var streetAddress: String
  var locality: String
  var region: String;
  var postalCode: String
  var country: String

  init(
    recipient: String,
    streetAddress: String,
    locality: String,
    region: String,
    postalCode: String,
    country: String
  ) {
    self.recipient = recipient
    self.streetAddress = streetAddress
    self.locality = locality
    self.region = region
    self.postalCode = postalCode
    guard country.count == 2, country == country.uppercased() else {
      fatalError("invalid country code")
    }
    self.country = country
  }
}

let applePark = ShippingAddress(
  recipient: "Apple, Inc.",
  streetAddress: "1 Apple Park Way",
  locality: "Cupertino",
  region: "CA",
  postalCode: "95014",
  country: "US"
)

```

_Be still my heart!_ 😍
We could do without the original semicolon,
but overall, this is pretty unobjectionable ---
which is exactly what you'd want from an official code style tool.

<div media="screen and (hover: hover)">

### Flexible Output

But in order to fully appreciate the elegance of `swift-format`'s output,
we must compare it across a multitude of different column widths.

Let's see how it handles this new code sample,
replete with cumbersome `UIApplicationDelegate` methods
and `URLSession` construction:

{% info %}
**Hint**:
Try resizing the container below
by clicking and dragging the control at the bottom right corner
_(this feature is only available in [supported browsers](https://caniuse.com/#feat=css-resize))_.
{% endinfo %}

<div class="variable-width">

<div data-width="40">

#### 40 Columns

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder,
  UIApplicationDelegate
{
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions
      launchOptions:
      [UIApplication.LaunchOptionsKey:
      Any]?
  ) -> Bool {

    let url = URL(
      string:
        "https://nshipster.com/swift-format"
    )!
    URLSession.shared.dataTask(
      with: url,
      completionHandler: {
        (data, response, error) in
        guard error == nil,
          let data = data,
          let response = response
          as? HTTPURLResponse,
          (200..<300).contains(
          response.statusCode
        ) else {
          fatalError(
            error?.localizedDescription
              ?? "Unknown error"
          )
        }

        if let html = String(
          data: data,
          encoding: .utf8
        ) {
          print(html)
        }
      }
    ).resume()

    // Override point for customization after application launch.
    return true
  }
}
```

</div>

<div data-width="50">

#### 50 Columns

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder,
  UIApplicationDelegate
{
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let url = URL(
      string: "https://nshipster.com/swift-format"
    )!
    URLSession.shared.dataTask(
      with: url,
      completionHandler: {
        (data, response, error) in
        guard error == nil, let data = data,
          let response = response
          as? HTTPURLResponse,
          (200..<300).contains(
          response.statusCode
        ) else {
          fatalError(
            error?.localizedDescription
              ?? "Unknown error"
          )
        }

        if let html = String(
          data: data,
          encoding: .utf8
        ) {
          print(html)
        }
      }
    ).resume()

    // Override point for customization after application launch.
    return true
  }
}
```

</div>

<div data-width="60">

#### 60 Columns

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let url = URL(
      string: "https://nshipster.com/swift-format"
    )!
    URLSession.shared.dataTask(
      with: url,
      completionHandler: { (data, response, error) in
        guard error == nil, let data = data,
          let response = response as? HTTPURLResponse,
          (200..<300).contains(response.statusCode) else {
          fatalError(
            error?.localizedDescription ?? "Unknown error"
          )
        }

        if let html = String(data: data, encoding: .utf8) {
          print(html)
        }
      }
    ).resume()

    // Override point for customization after application launch.
    return true
  }
}

```

</div>

<div data-width="70">

#### 70 Columns

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let url = URL(string: "https://nshipster.com/swift-format")!
    URLSession.shared.dataTask(
      with: url,
      completionHandler: { (data, response, error) in
        guard error == nil, let data = data,
          let response = response as? HTTPURLResponse,
          (200..<300).contains(response.statusCode) else {
          fatalError(error?.localizedDescription ?? "Unknown error")
        }

        if let html = String(data: data, encoding: .utf8) {
          print(html)
        }
      }
    ).resume()

    // Override point for customization after application launch.
    return true
  }
}

```

</div>

<div data-width="90">

#### 90 Columns

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let url = URL(string: "https://nshipster.com/swift-format")!
    URLSession.shared.dataTask(
      with: url,
      completionHandler: { (data, response, error) in
        guard error == nil, let data = data, let response = response as? HTTPURLResponse,
          (200..<300).contains(response.statusCode) else {
          fatalError(error?.localizedDescription ?? "Unknown error")
        }

        if let html = String(data: data, encoding: .utf8) {
          print(html)
        }
      }
    ).resume()

    // Override point for customization after application launch.
    return true
  }
}
```

</div>
</div>

This kind of flexibility isn't particularly helpful in engineering contexts,
where developers can and should make full use of their screen real estate.
But for those of us who do technical writing
and have to wrestle with things like mobile viewports and page margins,
this is a killer feature.

#### Performance

In terms of performance,
`swift-format` isn't so fast as to feel instantaneous,
but not so slow as to be an issue.

```terminal
$ time swift-format Example.swift
        0.24 real         0.16 user         0.14 sys
```

{% info %}
Since our initial analysis,
In Swift 5.1,
[SwiftSyntax](https://nshipster.com/swiftsyntax/)
(the parser used by `swift-format`)
has been updated with significantly improved performance,
as described in
[this forum post](https://forums.swift.org/t/speeding-up-swiftsyntax-by-using-the-parser-directly/18493).

Our initial benchmarks reflected the Swift 4.2 version of SwiftSyntax,
which predate these optimizations.
Using the latest Swift 5.1 Snapshot
(2019-05-09, LLVM 59470d46d5, Swift 6d7f3f61d9),
we didn't see a significant performance improvement from before,
but we're eager to re-evaluate these results
with future releases of `swift-format` and Swift 5.1.
{% endinfo %}

---

## Conclusion: You Don't Need To Wait to Start Using a Code Formatting Tool

Deciding which conventions we want to adopt as a community
is an important conversation to have,
worthy of the thoughtful and serious consideration we give
to any proposed change to the language.
However,
the question of whether there should be official style guidelines
or an authoritative code formatting tool
shouldn't stop you from taking steps today for your own projects!

We're strongly of the opinion that
**most projects would be improved by the adoption of a code formatting tool**,
provided that it meets the following criteria:

- It's stable
- It's fast (enough)
- It produces reasonable output

And based on our survey of the tools currently available,
we can confidently say that
[SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
and
[`swift-format`](https://github.com/google/swift/tree/format)
both meet these criteria,
and are suitable for use in production.

_(If we had to choose between the two,
we'd probably go with `swift-format` on aesthetic grounds.
But each developer has different preferences
and each team has different needs,
and you may prefer something else.)_

While you're evaluating tools to incorporate into your workflow,
you'd do well to try out
[SwiftLint](https://github.com/realm/swiftlint),
if you haven't already.
In its linting capacity,
SwiftLint can go a long way to systematically improving code quality ---
especially for projects that are
older and larger and have a large number of contributors.

---

The trouble with the debate about code style is that its large and subjective.
By adopting these tools in our day-to-day workflows today,
we not only benefit from better, more maintainable code today,
but we can help move the debate forward,
from vague feelings to precise observations about any gaps that still remain.

{% asset 'articles/swift-format.js' defer="defer" %}
{% asset 'articles/swift-format.css' %}
