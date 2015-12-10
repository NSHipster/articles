---
title: Swift Documentation
author: Mattt Thompson & Nate Cook
authors:
    - Mattt Thompson
    - Nate Cook
category: Swift
tags: swift
excerpt: "Code structure and organization is a matter of pride for developers. Clear and consistent code signifies clear and consistent thought. Read on to learn about the recent changes to documentation with Xcode 7 & Swift 2.0."
revisions:
    "2014-07-28": Original publication.
    "2015-05-05": Extended detail on supported markup; revised examples.
    "2015-09-30": Revised for Xcode 7 & Swift 2.0.
status:
    swift: 2.0
    reviewed: September 30, 2015
---

Code structure and organization is a matter of pride for developers. Clear and consistent code signifies clear and consistent thought. Even though the compiler lacks a discerning palate when it comes to naming, whitespace, or documentation, it makes all of the difference for human collaborators.

Readers of NSHipster will no doubt remember the [article about documentation published last year](http://nshipster.com/documentation/), but a lot has changed with Xcode 6 (fortunately, for the better, in most cases). So this week, we'll be documenting the here and now of documentation for aspiring Swift developers.

Let's dive in.

* * *

Since the early 00's, [Headerdoc](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1) has been the documentation standard preferred by Apple. Starting off as little more than a Perl script parsing trumped-up [Javadoc](http://en.wikipedia.org/wiki/Javadoc) comments, Headerdoc would eventually be the engine behind Apple's developer documentation online and in Xcode.

With the announcements of WWDC 2014, the developer documentation was overhauled with a sleek new design that could accommodate switching between Swift & Objective-C. (If you've [checked out any of the new iOS 8 APIs online](https://developer.apple.com/library/prerelease/ios/documentation/HomeKit/Reference/HomeKit_Framework/index.html#//apple_ref/doc/uid/TP40014519), you've seen this in action)

**What really comes as a surprise is that the _format of documentation_ appears to have changed as well.**

In the midst of Swift code, Headerdoc comments are not parsed correctly when invoking Quick Documentation (`⌥ʘ`):

```swift
/**
    Lorem ipsum dolor sit amet.

    @param bar Consectetur adipisicing elit.

    @return Sed do eiusmod tempor.
*/
func foo(bar: String) -> AnyObject { ... }
```

![Unrecognized Headerdoc](http://nshipster.s3.amazonaws.com/swift-documentation-headerdoc.png)

What _is_ parsed, however, is something markedly different:

![New Recognized Format](http://nshipster.s3.amazonaws.com/swift-documentation-new-format.png)

```swift
/**
    Lorem ipsum dolor sit amet.

    - parameter bar: Consectetur adipisicing elit.

    - returns: Sed do eiusmod tempor.
*/
func foo(bar: String) -> AnyObject { ... }
```

So what is this not-so-strange new documentation format? After a yearlong sojourn in the lands of [reStructuredText](http://docutils.sourceforge.net/docs/user/rst/quickref.html), Xcode 7 has settled on a Swift-flavored version of [Markdown](https://daringfireball.net/projects/markdown/).


#### Basic Markup

Documentation comments are distinguished by using `/** ... */` for multi-line comments or `///` for single-line comments. Inside comment blocks, the conventions you've gotten used to when writing Markdown everywhere else apply: 

- Paragraphs are separated by blank lines
- Unordered lists can use a variety of bullet characters: `-`, `+`, `*`, `•`
- Ordered lists use Arabic numerals (1, 2, 3, ...) followed by a period `1.` or right parenthesis `1)`:
- Headers can be marked with preceding `#` signs or by underlining with `=` or `-`.
- Even [links](https://daringfireball.net/projects/markdown/syntax#link) and [images](https://daringfireball.net/projects/markdown/syntax#img) work, with web-based images pulled down and displayed directly in Xcode.

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

#### Parameters & Return Values

Xcode 7 recognizes and makes separate from a symbol's description a few special fields. The parameters, return value, and a new "throws" section (to go with Swift 2.0's new `throws` keyword) are broken out in the Quick Help popover and inspector when styled as a bulleted item followed by a colon (`:`).

- **Parameters:** Start the line with `Parameter <param name>: ` and the description of the parameter.
- **Return values:** Start the line with `Returns: ` and information about the return value.
- **Thrown errors:** Start the line with `Throws: ` and a description of the errors that can be thrown. Since Swift doesn't type-check thrown errors beyond `ErrorType` conformance, it's especially important to document errors properly.

```swift
/**
	Repeats a string `times` times.

	- Parameter str:   The string to repeat.
	- Parameter times: The number of times to repeat `str`.

    - Throws: `MyError.InvalidTimes` if the `times` parameter 
        is less than zero.

	- Returns: A new string with `str` repeated `times` times.
*/
func repeatString(str: String, times: Int) throws -> String {
    guard times >= 0 else { throw MyError.InvalidTimes }
	return Repeat(count: 5, repeatedValue: "Hello").joinWithSeparator("")
}
```

A longer list of parameters can be broken out into a sublist by using the `Parameters:` prefix. Simply indent each parameter in a bulleted list below.

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

#### Description Fields

Swift-flavored Markdown includes another set of field headers to break out particular sections of a type or method's description, formatted just as `Returns` and `Throws` above. Loosely organized, the recognized headers are:

- *Algorithm/Safety Information:* `Precondition`, `Postcondition`, `Requires`, `Invariant`, `Complexity`, `Important`, `Warning`
- *Metadata*: `Author`, `Authors`, `Copyright`, `Date`, `SeeAlso`, `Since`, `Version`
- *General Notes & Exhortations:* `Attention`, `Bug`, `Experiment`, `Note`, `Remark`, `ToDo`

No matter which you choose, all fields are rendered as a bold header followed by a block of text:

> **Field Header:**   
> The text of the subfield is displayed starting on the next line.


#### Code blocks

Code blocks can be embedded in documentation comments as well, which can be useful for demonstrating proper usage or implementation details. Inset the code block by at least four spaces:

```swift
/**
	The area of the `Shape` instance.
	
	Computation depends on the shape of the instance. 
	For a triangle, `area` will be equivalent to:
	
	    let height = triangle.calculateHeight()
	    let area = triangle.base * height / 2
*/
var area: CGFloat { get }
```

Fenced code blocks are also recognized, with three backticks (`\``) or tildes (`~`) marking the beginning and end of a block:

```swift
/**
	The perimeter of the `Shape` instance.
	
	Computation depends on the shape of the instance, and is
	equivalent to: 
	
	```
	// Circles:
    let perimeter = circle.radius * 2 * CGFloat(M_PI)
    
    // Other shapes:
    let perimeter = shape.sides.map { $0.length }
                               .reduce(0, combine: +)
    ```
*/
var perimeter: CGFloat { get }
```

## Documentation Is My New Bicycle

How does this look when applied to an entire class? Quite nice, actually:

```swift
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

        - Parameters:
            - style: The style of the bicycle
            - gearing: The gearing of the bicycle
            - handlebar: The handlebar of the bicycle
            - frameSize: The frame size of the bicycle, in centimeters

        - Returns: A beautiful, brand-new bicycle, custom built
          just for you.
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
```

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

```swift
// MARK: CustomStringConvertible

extension Bicycle: CustomStringConvertible {
    public var description: String {
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
        
        return descriptors.joinWithSeparator(", ")
    }
}
```

Bringing everything together in code:

```swift
let bike = Bicycle(style: .Road, gearing: .Freewheel(speeds: 8), handlebar: .Drop, frameSize: 53)

bike.travel(distance: 1_500) // Trip around the town
bike.travel(distance: 200) // Trip to the store

print(bike)
// "A road bike for streets or trails, with a 8-speed freewheel gear, and classic, drop handlebars, on a 53" frame, with a total of 1700.0 meters traveled over 2 trips."
```


## Jazzy

[Jazzy](https://github.com/realm/jazzy) is a terrific open-source command-line utility that transforms your project's documentation comments into a set of Apple-like HTML documentation. Jazzy uses Xcode's SourceKitService to read your beautifully written type and method descriptions. Install Jazzy as a gem, then simply run from the root of your project folder.

```text
$ [sudo] gem install jazzy
$ jazzy
Running xcodebuild
Parsing ...
building site
jam out ♪♫ to your fresh new docs in `docs`
```

[Take a peek](/swift-documentation-example/Classes/Bicycle.html) at a Jazzy-generated docset for the `Bicycle` class.


* * *

Although the tooling and documentation around Swift is still rapidly evolving, one would be wise to adopt good habits early, by using the new Markdown capabilities for documentation, as well as `MARK: ` comments in Swift code going forward.

Go ahead and add it to your `TODO: ` list.

[1]: https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-XID_25
