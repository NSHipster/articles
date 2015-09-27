---
title: Swift Documentation
author: Mattt Thompson & Nate Cook
authors:
    - Mattt Thompson
    - Nate Cook
category: Swift
tags: swift
excerpt: "Code structure and organization is a matter of pride for developers. Clear and consistent code signifies clear and consistent thought. Read on to learn about the recent changes to documentation with Xcode 7 & Swift 2."
revisions:
    "2014-07-28": Original publication.
    "2015-05-05": Extended detail on supported markup; revised examples.
    "2015-09-26": Updated to new format in Xcode 7.
status:
    swift: 2.0
---

Code structure and organization is a matter of pride for developers. Clear and consistent code signifies clear and consistent thought. Even though the compiler lacks a discerning palate when it comes to naming, whitespace, or documentation, it makes all of the difference for human collaborators.

Readers of NSHipster will no doubt remember the [article about documentation published last year](http://nshipster.com/documentation/), but a lot has changed with Xcode 6 and again in Xcode 7 (fortunately, for the better, in most cases). So this week, we'll be documenting the here and now of documentation for aspiring Swift developers.

Let's dive in.

* * *

Since the early 00's, [Headerdoc](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1) has been the documentation standard preferred by Apple. Starting off as little more than a Perl script parsing trumped-up [Javadoc](http://en.wikipedia.org/wiki/Javadoc) comments, Headerdoc would eventually be the engine behind Apple's developer documentation online and in Xcode.

With the announcements of WWDC 2014, the developer documentation was overhauled with a sleek new design that could accommodate switching between Swift & Objective-C. (If you've [checked out any of the new iOS 8 APIs online](https://developer.apple.com/library/prerelease/ios/documentation/HomeKit/Reference/HomeKit_Framework/index.html#//apple_ref/doc/uid/TP40014519), you've seen this in action)

**What really comes as a surprise is that the _format of documentation_ appears to have changed as well.**

In the midst of Swift code, Headerdoc comments are not parsed correctly when invoking Quick Documentation (`⌥ʘ`):

~~~{swift}
/**
    Lorem ipsum dolor sit amet.

    @param bar Consectetur adipisicing elit.

    @return Sed do eiusmod tempor.
*/
func foo(bar: String) -> AnyObject { ... }
~~~

![Unrecognized Headerdoc](http://nshipster.s3.amazonaws.com/swift-documentation-headerdoc.png)

What _is_ parsed, however, is something markedly different:

~~~{swift}
/**
    Lorem ipsum dolor sit amet.

    - Parameter bar: Consectetur adipisicing elit.

    - Returns: Sed do eiusmod tempor.
*/
func foo(bar: String) -> AnyObject { ... }
~~~

![New Recognized Format](http://nshipster.s3.amazonaws.com/swift-documentation-new-format.png)

So what is this strange new documentation format? It turns out Xcode 7 now suports Markdown with some recognized keywords for special flavoring.


#### Basic Markup

Documentation comments are distinguished by using `/** ... */` for multi-line comments or `/// ...` for single-line and multi-line comments. Inside comment blocks, paragraphs are separated by blank lines. Unordered lists can be made with several bullet characters: `-`, `+`, `*`, `•`, etc, while ordered lists use Arabic numerals (1, 2, 3, ...) followed by a period `1.` or right parenthesis `1)` or surrounded by parentheses on both sides `(1)`:

~~~{swift}
/**
	You can apply *italic*, **bold**, or `code` inline styles.

	- Lists are great,
	- but perhaps don't nest
	- Sub-list formatting

	  - isn't the best.

	1. Ordered lists, too
	2. for things that are sorted;
	3. Arabic numerals
	4. are the only kind supported.
*/
~~~

#### Definition & Field Lists

Defininition and field lists are displayed similarly in Xcode's Quick Documentation popup. Field lists are marked by a top-level list that starts with a recognized keyword like `Parameter`. Any text that does not belong to a keyword-ed top-level list will render as the symbol definition.

~~~{swift}
/**
    The description of the current symbol. First paragraph appers is
    visible in auto complete.

    The rest appears in Quick Help.
    - Along with lists
    - And any other content

    - Parameter aParam: Description for the parameter.
      Any text adyacent is treated as part of the same paragraph.

    - Parameter anotherParam: The next parameter.
*/
~~~

Parameters are marked by the `Parameter` keyword followed by the parameter name, a colon, and then the description. Return values dont have names so these are marked with `Returns:` followed by the description.

~~~{swift}
/**
    Repeats a string `times` times.

    - Parameter str: The string to repeat.
    - Parameter times: The number of times to repeat `str`.

    - Returns: A new string with `str` repeated `times` times.
*/
func repeatString(str: String, times: Int) -> String {
	return join("", Array(count: times, repeatedValue: str))
}
~~~


#### Other Field

Other top-level list keywords that receive a special treatment like `Parameter` and `Returns` are:

- Attention
- Author
- Authors
- Bug
- Complexity
- Copyright
- Date
- Experiment
- Important
- Invariant
- Note
- Postcondition
- Precondition
- Remark
- Requires
- See
- SeeAlso
- Since
- TODO
- Version
- Warning

#### Code blocks

Code blocks can be embedded in documentation comments as well, which can be useful for demonstrating proper usage or implementation details. Inset the code block by at least four spaces:

~~~{swift}
/**
    The area of the `Shape` instance.

    Computation depends on the shape of the instance. For a triangle, `area` will be equivalent to:

        let height = triangle.calculateHeight()
        let area = triangle.base * height / 2
*/
var area: CGFloat { get }
~~~

## Documentation Is My New Bicycle

How does this look when applied to an entire class? Quite nice, actually:

~~~{swift}
import Foundation

/// 🚲 A two-wheeled, human-powered mode of transportation.
class Bicycle {
    /**
        Frame and construction style.

        - Road: For streets or trails.
        - Touring: For long journeys.
        - Cruiser: For casual trips around town.
        - Hybrid: For general-purpose transportation.
    */
    enum Style {
        case Road, Touring, Cruiser, Hybrid
    }

    /**
        Mechanism for converting pedal power into motion.

        - Fixed: A single, fixed gear.
        - Freewheel: A variable-speed, disengageable gear.
    */
    enum Gearing {
        case Fixed
        case Freewheel(speeds: Int)
    }

    /**
        Hardware used for steering.

        - Riser: A casual handlebar.
        - Café: An upright handlebar.
        - Drop: A classic handlebar.
        - Bullhorn: A powerful handlebar.
    */
    enum Handlebar {
        case Riser, Café, Drop, Bullhorn
    }

    /// The style of the bicycle.
    let style: Style

    /// The gearing of the bicycle.
    let gearing: Gearing

    /// The handlebar of the bicycle.
    let handlebar: Handlebar

    /// The size of the frame, in centimeters.
    let frameSize: Int

    /// The number of trips travelled by the bicycle.
    private(set) var numberOfTrips: Int

    /// The total distance travelled by the bicycle, in meters.
    private(set) var distanceTravelled: Double

    /**
        Initializes a new bicycle with the provided parts and specifications.

        - Parameter style: The style of the bicycle
        - Parameter gearing: The gearing of the bicycle
        - Parameter handlebar: The handlebar of the bicycle
        - Parameter centimeters: The frame size of the bicycle, in centimeters

        - Returns: A beautiful, brand-new, custom built just for you.
    */
    init(style: Style, gearing: Gearing, handlebar: Handlebar, frameSize centimeters: Int) {
        self.style = style
        self.gearing = gearing
        self.handlebar = handlebar
        self.frameSize = centimeters

        self.numberOfTrips = 0
        self.distanceTravelled = 0
    }

    /**
        Take a bike out for a spin.

        - Parameter meters: The distance to travel in meters.
    */
    func travel(distance meters: Double) {
        if meters > 0 {
            distanceTravelled += meters
            ++numberOfTrips
        }
    }
}
~~~

Option-click on the `Style` `enum` declaration, and the description renders beautifully with a bulleted list:

![Swift enum Declaration Documentation](http://nshipster.s3.amazonaws.com/swift-documentation-enum-declaration.png)

Open Quick Documentation for the method `travel`, and the parameter is parsed out into a separate field, as expected:

![Swift func Declaration Documentation](http://nshipster.s3.amazonaws.com/swift-documentation-method-declaration.png)


## MARK / TODO / FIXME

In Objective-C, [the pre-processor directive `#pragma mark`](http://nshipster.com/pragma/) is used to divide functionality into meaningful, easy-to-navigate sections. In Swift, there are no pre-processor directives (closest are the similarly-octothorp'd [build configurations][1]), but the same can be accomplished with the comment `// MARK: `.

As of Xcode 6β4, the following comments will be surfaced in the Xcode source navigator:

- `// MARK: ` _(As with `#pragma`, marks followed by a single dash (`-`) will be preceded with a horizontal divider)_
- `// TODO: `
- `// FIXME: `

> Other conventional comment tags, such as `NOTE` and `XXX` are not recognized by Xcode.

To show these new tags in action, here's how the `Bicycle` class could be extended to adopt the `Printable` protocol, and implement `description`.

![Xcode 6 Documentation Source Navigator MARK / TODO / FIXME](http://nshipster.s3.amazonaws.com/swift-documentation-xcode-source-navigator.png)

~~~{swift}
// MARK: Printable

extension Bicycle: Printable {
    var description: String {
        var descriptors: [String] = []

        switch self.style {
        case .Road:
            descriptors.append("A road bike for streets or trails")
        case .Touring:
            descriptors.append("A touring bike for long journeys")
        case .Cruiser:
            descriptors.append("A cruiser bike for casual trips around town")
        case .Hybrid:
            descriptors.append("A hybrid bike for general-purpose transportation")
        }

        switch self.gearing {
        case .Fixed:
            descriptors.append("with a single, fixed gear")
        case .Freewheel(let n):
            descriptors.append("with a \(n)-speed freewheel gear")
        }

        switch self.handlebar {
        case .Riser:
            descriptors.append("and casual, riser handlebars")
        case .Café:
            descriptors.append("and upright, café handlebars")
        case .Drop:
            descriptors.append("and classic, drop handlebars")
        case .Bullhorn:
            descriptors.append("and powerful bullhorn handlebars")
        }

        descriptors.append("on a \(frameSize)\" frame")

        // FIXME: Use a distance formatter
        descriptors.append("with a total of \(distanceTravelled) meters traveled over \(numberOfTrips) trips.")

        // TODO: Allow bikes to be named?

        return join(", ", descriptors)
    }
}
~~~

Bringing everything together in code:

~~~{swift}
let bike = Bicycle(style: .Road, gearing: .Freewheel(speeds: 8), handlebar: .Drop, frameSize: 53)

bike.travel(distance: 1_500) // Trip around the town
bike.travel(distance: 200) // Trip to the store

println(bike)
// "A road bike for streets or trails, with a 8-speed freewheel gear, and classic, drop handlebars, on a 53" frame, with a total of 1700.0 meters traveled over 2 trips."
~~~

* * *

Although the tooling and documentation around Swift is still rapidly evolving, one would be wise to adopt good habits early, by using the new light markup language conventions for documentation, as well as `MARK: ` comments in Swift code going forward.

Go ahead and add it to your `TODO: ` list.

[1]: https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-XID_25
