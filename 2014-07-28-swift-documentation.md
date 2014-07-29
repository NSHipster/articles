---
layout: post
title: Swift Documentation
category: Swift
excerpt: "Code structure and organization is a matter of pride for developers. Clear and consistent code signifies clear and consistent thought. Read on to learn about the recent changes to documentation with Xcode 6 & Swift."
---

Code structure and organization is a matter of pride for developers. Clear and consistent code signifies clear and consistent thought. Even though the compiler lacks a discerning palate when it comes to naming, whitespace, or documentation, it makes all of the difference for human collaborators.

Readers of NSHipster will no doubt remember the [article about documentation published last year](http://nshipster.com/documentation/), but a lot has changed with Xcode 6 (fortunately, for the better, in most cases). So this week, we'll be documenting the here and now of documentation for aspiring Swift developers.

Let's dive in.

* * *

> Ironically, much of the following is currently undocumented, and is subject to change or correction.

Since the early 00's, [Headerdoc](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/HeaderDoc/intro/intro.html#//apple_ref/doc/uid/TP40001215-CH345-SW1) has been the documentation standard preferred by Apple. Starting off as little more than a Perl script parsing trumped-up [Javadoc](http://en.wikipedia.org/wiki/Javadoc) comments, Headerdoc would eventually be the engine behind Apple's developer documentation online and in Xcode.

With the announcements of WWDC 2014, the developer documentation was overhauled with a sleek new design that could accommodate switching between Swift & Objective-C. (If you've [checked out any of the new iOS 8 APIs online](https://developer.apple.com/library/prerelease/ios/documentation/HomeKit/Reference/HomeKit_Framework/index.html#//apple_ref/doc/uid/TP40014519), you've seen this in action)

**What really comes as a surprise is that the _format of documentation_ appears to have changed as well.**

In the latest Xcode 6 beta, Headerdoc comments are not parsed correctly when invoking Quick Documentation (`⌥ʘ`):

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

![New Recognized Format](http://nshipster.s3.amazonaws.com/swift-documentation-new-format.png)

~~~{swift}
/**
    Lorem ipsum dolor sit amet.

    :param: bar Consectetur adipisicing elit.

    :returns: Sed do eiusmod tempor.
*/
func foo(bar: String) -> AnyObject { ... }
~~~

It gets weirder.

Jump into a bridged Swift header for an Objective-C API, like say, HomeKit's `HMCharacteristic`, and option-clicking _does_ work. (Also, the documentation there uses `/*!` to open documentation, rather than the conventional `/**`).

Little is known about this new documentation format... but in these Wild West times of strict typing and loose morals, that's not enough to keep us from using it ourselves:

> **Update**: Sources from inside Cupertino have confirmed that SourceKit (the private framework powering Xcode that y'all probably know best for crashing in Playgrounds) includes a primitive parser for [reStructuredText](http://docutils.sourceforge.net/docs/user/rst/quickref.html). How reST is, well, re-structured and adapted to satisfy Apple's use case is something that remains to be seen.

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
    public enum Style {
        case Road, Touring, Cruiser, Hybrid
    }

    /**
        Mechanism for converting pedal power into motion.

        - Fixed: A single, fixed gear.
        - Freewheel: A variable-speed, disengageable gear.
    */
    public enum Gearing {
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

        :param: style The style of the bicycle
        :param: gearing The gearing of the bicycle
        :param: handlebar The handlebar of the bicycle
        :param: centimeters The frame size of the bicycle, in centimeters

        :returns: A beautiful, brand-new, custom built just for you.
    */
    init(style: Style, gearing: Gearing, handlebar: Handlebar, frameSize centimeters: Int) {
        self.style = style
        self.gearing = gearing
        self.handlebar = handlebar
        self.frameSize = centimeters

        self.numberOfTrips = 0
        self.distanceTravelled = 0.0
    }

    /**
        Take a bike out for a spin.

        :param: meters The distance to travel in meters.
    */
    func travel(distance meters: Double) {
        if meters > 0.0 {
            self.distanceTravelled += meters
            self.numberOfTrips++
        }
    }
}
~~~

Option-click on the `Style` `enum` declaration, and the description renders beautifully with a bulleted list:

![Swift enum Declaration Documentation](http://nshipster.s3.amazonaws.com/swift-documentation-enum-declaration.png)

Open Quick Documentation for the method `travel`, and the parameter is parsed out into a separate field, as expected:

![Swift func Declaration Documentation](http://nshipster.s3.amazonaws.com/swift-documentation-method-declaration.png)

> Again, not much is known about this new documentation format yet... as it's currently undocumented. But this article will be updated as soon as more is known. In the meantime, feel free to adopt the conventions described so far, as they're at least useful for the time being.

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
            descriptors += "A road bike for streets or trails"
        case .Touring:
            descriptors += "A touring bike for long journeys"
        case .Cruiser:
            descriptors += "A cruiser bike for casual trips around town"
        case .Hybrid:
            descriptors += "A hybrid bike for general-purpose transportation"
        }

        switch self.gearing {
        case .Fixed:
            descriptors += "with a single, fixed gear"
        case .Freewheel(let n):
            descriptors += "with a \(n)-speed freewheel gear"
        }

        switch self.handlebar {
        case .Riser:
            descriptors += "and casual, riser handlebars"
        case .Café:
            descriptors += "and upright, café handlebars"
        case .Drop:
            descriptors += "and classic, drop handlebars"
        case .Bullhorn:
            descriptors += "and powerful bullhorn handlebars"
        }

        descriptors += "on a \(self.frameSize)\" frame"

        // FIXME: Use a distance formatter
        descriptors += "with a total of \(self.distanceTravelled) meters traveled over \(self.numberOfTrips) trips"

        // TODO: Allow bikes to be named?

        return join(", ", descriptors) + "."
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
