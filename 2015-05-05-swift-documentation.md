---
title: Swift Documentation
author: Mattt & Nate Cook
authors:
  - Nate Cook
  - Mattt
category: Swift
tags: swift
excerpt: Code structure and organization is a matter of pride for developers.
  Clear and consistent code signifies clear and consistent thought.
revisions:
  "2014-07-28": Original publication
  "2015-05-05": Expanded details
  "2015-09-30": Updated for Xcode 7 & Swift 2.0
  "2018-07-11": Updated for Xcode 10 & Swift 4.2
status:
  swift: 4.2
  reviewed: July 11, 2018
---

Code structure and organization is a matter of pride for developers.
Clear and consistent code signifies clear and consistent thought.
Even though the compiler lacks a discerning palate when it comes to
naming, whitespace, or documentation,
it makes all the difference for human collaborators.

This week,
we'll be documenting the here and now
of documentation in Swift.

---

Since the early 00's,
[Headerdoc](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1)
has been Apple's preferred documentation standard.
Starting off as little more than a Perl script that parsed trumped-up
[Javadoc](https://en.wikipedia.org/wiki/Javadoc) comments,
Headerdoc would eventually be the engine behind
Apple's developer documentation online and in Xcode.

But like so much of the Apple developer ecosystem,
Swift changed everything.
In the spirit of
"Out with the old, in with the new",
Xcode 7 traded Headerdoc
for fan favorite
[Markdown](https://daringfireball.net/projects/markdown/) ---
specifically, _Swift-flavored Markdown_.

## Documentation Comments & Swift-Flavored Markdown

Even if you've never written a line of Markdown before,
you can get up to speed in just a few minutes.
Here's pretty much everything you need to know:

### Basic Markup

Documentation comments look like normal comments,
but with a little something extra.
Single-line documentation comments have three slashes (`///`).
Multi-line documentation comments
have an extra star in their opening delimiter (`/** ... */`).

Standard Markdown rules apply inside documentation comments:

- Paragraphs are separated by blank lines.
- Unordered lists are marked by bullet characters
  (`-`, `+`, `*`, or `•`).
- Ordered lists use numerals (1, 2, 3, ...)
  followed by either
  a period (`1.`)
  or a right parenthesis (`1)`).
- Headers are preceded by `#` signs
  or underlined with `=` or `-`.
- Both [links](https://daringfireball.net/projects/markdown/syntax#link)
  and [images](https://daringfireball.net/projects/markdown/syntax#img) work,
  with web-based images pulled down and displayed directly in Xcode.

```swift
/**
    # Lists

    You can apply *italic*, **bold**, or `code` inline styles.

    ## Unordered Lists

    - Lists are great,
    - but perhaps don't nest
    - Sub-list formatting

      - isn't the best.

    ## Ordered Lists

    1. Ordered lists, too
    2. for things that are sorted;
    3. Arabic numerals
    4. are the only kind supported.
*/
```

### Summary & Description

The leading paragraph of a documentation comment
becomes the documentation _Summary_.
Any additional content is grouped together into the _Discussion_ section.

> If a documentation comment
> starts with anything other than a paragraph,
> all of its content is put into the Discussion.

### Parameters & Return Values

Xcode recognizes a few special fields
and makes them separate from a symbol's description.
The parameters, return value, and throws sections
are broken out in the Quick Help popover and inspector
when styled as a bulleted item followed by a colon (`:`).

- **Parameters:**
  Start the line with `Parameter <param name>:`
  and the description of the parameter.
- **Return values:**
  Start the line with `Returns:`
  and information about the return value.
- **Thrown errors:**
  Start the line with `Throws:`
  and a description of the errors that can be thrown.
  Since Swift doesn't type-check thrown errors beyond `Error` conformance,
  it's especially important to document errors properly.

```swift
/**
 Creates a personalized greeting for a recipient.

 - Parameter recipient: The person being greeted.

 - Throws: `MyError.invalidRecipient`
           if `recipient` is "Derek"
           (he knows what he did).

 - Returns: A new string saying hello to `recipient`.
 */
func greeting(to recipient: String) throws -> String {
    guard recipient != "Derek" else {
        throw MyError.invalidRecipient
    }

    return "Greetings, \(recipient)!"
}
```

Are you documenting a function whose method signature
has more arguments than a Hacker News thread about tabs vs. spaces?
Break out your parameters into a bulleted list
underneath a `Parameters:` callout:

```swift
/// Returns the magnitude of a vector in three dimensions
/// from the given components.
///
/// - Parameters:
///     - x: The *x* component of the vector.
///     - y: The *y* component of the vector.
///     - z: The *z* component of the vector.
func magnitude3D(x: Double, y: Double, z: Double) -> Double {
    return sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
}
```

### Additional Fields

In addition to `Parameters`, `Throws` and `Returns`,
Swift-flavored Markdown
defines a handful of other fields,
which can be loosely organized in the following way:

|                                  |                                                                                                                              |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Algorithm/Safety Information** | `Precondition` <br/> `Postcondition` <br/> `Requires` <br/> `Invariant` <br/> `Complexity` <br/> `Important` <br/> `Warning` |
| **Metadata**                     | `Author` <br/> `Authors` <br/> `Copyright` <br/>`Date` <br/> `SeeAlso` <br/> `Since` <br/> `Version`                         |
| **General Notes & Exhortations** | `Attention` <br/> `Bug` <br/> `Experiment` <br/> `Note` <br/> `Remark` <br/> `ToDo`                                          |

Each of these fields is rendered in Quick Help as a bold header
followed by a block of text:

> **Field Header:**  
> The text of the subfield is displayed starting on the next line.

### Code blocks

Demonstrate the proper usage or implementation details of a function
by embedding code blocks.
Inset code blocks by at least four spaces:

```swift
/**
    The area of the `Shape` instance.

    Computation depends on the shape of the instance.
    For a triangle, `area` is equivalent to:

        let height = triangle.calculateHeight()
        let area = triangle.base * height / 2
*/
var area: CGFloat { get }
```

Fenced code blocks are also recognized,
delimited by either three backticks (` \``) or tildes ( `~`):

````swift
/**
    The perimeter of the `Shape` instance.

    Computation depends on the shape of the instance, and is
    equivalent to:

    ```
    // Circles:
    let perimeter = circle.radius * 2 * Float.pi

    // Other shapes:
    let perimeter = shape.sides.map { $0.length }
                               .reduce(0, +)
    ```
*/
var perimeter: CGFloat { get }
````

## Documentation Is My New Bicycle

How does this look when applied to an entire class?
Quite nice, actually!

```swift
/// 🚲 A two-wheeled, human-powered mode of transportation.
class Bicycle {
    /// Frame and construction style.
    enum Style {
        /// A style for streets or trails.
        case road

        /// A style for long journeys.
        case touring

        /// A style for casual trips around town.
        case cruiser

        /// A style for general-purpose transportation.
        case hybrid
    }

    /// Mechanism for converting pedal power into motion.
    enum Gearing {
        /// A single, fixed gear.
        case fixed

        /// A variable-speed, disengageable gear.
        case freewheel(speeds: Int)
    }

    /// Hardware used for steering.
    enum Handlebar {
        /// A casual handlebar.
        case riser

        /// An upright handlebar.
        case café

        /// A classic handlebar.
        case drop

        /// A powerful handlebar.
        case bullhorn
    }

    /// The style of the bicycle.
    let style: Style

    /// The gearing of the bicycle.
    let gearing: Gearing

    /// The handlebar of the bicycle.
    let handlebar: Handlebar

    /// The size of the frame, in centimeters.
    let frameSize: Int

    /// The number of trips traveled by the bicycle.
    private(set) var numberOfTrips: Int

    /// The total distance traveled by the bicycle, in meters.
    private(set) var distanceTraveled: Double

    /**
     Initializes a new bicycle with the provided parts and specifications.

     - Parameters:
        - style: The style of the bicycle
        - gearing: The gearing of the bicycle
        - handlebar: The handlebar of the bicycle
        - frameSize: The frame size of the bicycle, in centimeters

     - Returns: A beautiful, brand-new bicycle,
                custom-built just for you.
     */
    init(style: Style,
         gearing: Gearing,
         handlebar: Handlebar,
         frameSize centimeters: Int)
    {
        self.style = style
        self.gearing = gearing
        self.handlebar = handlebar
        self.frameSize = centimeters

        self.numberOfTrips = 0
        self.distanceTraveled = 0
    }

    /**
     Take a bike out for a spin.

     Calling this method increments the `numberOfTrips`
     and increases `distanceTraveled` by the value of `meters`.

     - Parameter meters: The distance to travel in meters.
     - Precondition: `meters` must be greater than 0.
     */
    func travel(distance meters: Double) {
        precondition(meters > 0)
        distanceTraveled += meters
        numberOfTrips += 1
    }
}
```

Option-click on the initializer declaration,
and the description renders beautifully with a bulleted list:

![Swift enum Declaration Documentation]({% asset swift-documentation-initializer-declaration.png @path %})

Open Quick Documentation for the method `travel`,
and the parameter is parsed out into a separate field,
as expected:

![Swift func Declaration Documentation]({% asset swift-documentation-method-declaration.png @path %})

## MARK / TODO / FIXME

In Objective-C,
[the pre-processor directive `#pragma mark`](https://nshipster.com/pragma/)
is used to divide functionality into meaningful, easy-to-navigate sections.
In Swift, there are no pre-processor directives
(closest are the similarly-octothorp'd
[build configurations](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-XID_25)),
but the same can be accomplished with the comment `// MARK:`.

The following comments are surfaced in the Xcode source navigator:

- `// MARK:`
  _(As with `#pragma`, marks followed by a single dash (`-`)
  are preceded with a horizontal divider)_
- `// TODO:`
- `// FIXME:`

> Other conventional comment tags,
> such as `NOTE` and `XXX` are not recognized by Xcode.

To show these new tags in action,
here's how the `Bicycle` class could be extended to adopt
the `CustomStringConvertible` protocol,
and implement the `description` property.

![Xcode Documentation Source Navigator MARK / TODO / FIXME]({% asset swift-documentation-xcode-source-navigator.png @path %})

```swift
// MARK: CustomStringConvertible

extension Bicycle: CustomStringConvertible {
    public var description: String {
        var descriptors: [String] = []

        switch self.style {
        case .road:
            descriptors.append("A road bike for streets or trails")
        case .touring:
            descriptors.append("A touring bike for long journeys")
        case .cruiser:
            descriptors.append("A cruiser bike for casual trips around town")
        case .hybrid:
            descriptors.append("A hybrid bike for general-purpose transportation")
        }

        switch self.gearing {
        case .fixed:
            descriptors.append("with a single, fixed gear")
        case .freewheel(let n):
            descriptors.append("with a \(n)-speed freewheel gear")
        }

        switch self.handlebar {
        case .riser:
            descriptors.append("and casual, riser handlebars")
        case .café:
            descriptors.append("and upright, café handlebars")
        case .drop:
            descriptors.append("and classic, drop handlebars")
        case .bullhorn:
            descriptors.append("and powerful bullhorn handlebars")
        }

        descriptors.append("on a \(frameSize)\" frame")

        // FIXME: Use a distance formatter
        descriptors.append("with a total of \(distanceTraveled) meters traveled over \(numberOfTrips) trips.")

        // TODO: Allow bikes to be named?

        return descriptors.joined(separator: ", ")
    }
}
```

Bringing everything together in code:

```swift
var bike = Bicycle(style: .road,
                   gearing: .freewheel(speeds: 8),
                   handlebar: .drop,
                   frameSize: 53)

bike.travel(distance: 1_500) // Trip around the town
bike.travel(distance: 200) // Trip to the store

print(bike)
// "A road bike for streets or trails, with a 8-speed freewheel gear, and classic, drop handlebars, on a 53" frame, with a total of 1700.0 meters traveled over 2 trips."
```

---

At the time of writing,
there's no official tool for transforming documentation comments
into something more tangible
than Quick Help panels in Xcode,

Fortunately,
where necessity arises,
open source (often) delivers.

## Jazzy

[Jazzy](https://github.com/realm/jazzy)
is a terrific open-source command-line utility
that transforms your project's documentation comments
into a set of Apple-like HTML documentation
(but that nice vintage style, before that whole redesign).
Jazzy uses Xcode's SourceKitService
to read your beautifully written type and method descriptions.

Install Jazzy as a gem,
then run from the root of your project folder
to generate documentation.

```text
$ gem install jazzy
$ jazzy
Running xcodebuild
Parsing ...
building site
jam out ♪♫ to your fresh new docs in `docs`
```

[Take a peek](https://swift-documentation-example.nshipster.com/classes/bicycle)
at a Jazzy-generated documentation for the `Bicycle` class.

---

Although the tooling and documentation around Swift is still developing,
one would be wise to adopt good habits early,
by using the new Markdown capabilities for documentation,
as well as `MARK:` comments in Swift code going forward.

Go ahead and add it to your `TODO:` list.
