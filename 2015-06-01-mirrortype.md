---
title: MirrorType
author: Nate Cook
category: Swift
excerpt: "Reflection in Swift is a limited affair, providing read-only access to a subset of type metadata. While far from the rich array of run-time hackery familiar to seasoned Objective-C developers, Swift's tools enable the immediate feedback and sense of exploration offered by Xcode Playgrounds. This week, we'll reflect on reflection in Swift, its mirror types, and `MirrorType`, the protocol that binds them together."
status:
    swift: 1.2
---

Reflection in Swift is a limited affair, providing read-only access to a subset of type metadata. While far from the rich array of run-time hackery familiar to seasoned Objective-C developers, Swift's tools enable the immediate feedback and sense of exploration offered by Xcode Playgrounds.

Perhaps Swift's strict type checking obviates the need for reflection. With variable types typically known at compile time, there might not be cause for further examination or branching. Then again, a hefty number of Cocoa APIs dole out `AnyObject` instances at the drop of a hat, leaving us to cast about for the matching type.

This week, we'll reflect on reflection in Swift, its mirror types, and `MirrorType`, the protocol that binds them together.


* * *


## `MirrorType`

The entry point for reflection is the `reflect` function, which can take an instance of any type as its single parameter and returns a `MirrorType`. Now, `MirrorType` is something of an oddity for the Swift standard libary: a protocol used as a type. Other than the ubiquitous `AnyObject`, to date no other protocol is used this way. The particular `MirrorType`-conforming instance that you receive depends on the type passed to `reflect`—Swift's internals define mirrors for types such as `Array`, `Dictionary`, `Optional`, and `Range`, along with more generic mirrors for structs, classes, tuples, and metatypes.

`MirrorType` provides the nascent reflection API that Swift offers, wrapping a value along with its type information, information about its children, and different representations of the instance. Mirrors have the following properties:

> - `value`: access to the original reflected value, but with type `Any`.
> - `valueType`: the `Type` of the original reflected value—equivalent to `value.dynamicType`.
> - `count`: the number of logical children. For a collection, like `Array` or `Set`, this is the number of elements; for a struct, this is the number of stored properties.
> - `disposition`: a value from the `MirrorDisposition` enumeration, intended to help the IDE choose how to display the value. `MirrorDisposition` has eleven cases:
    - `IndexContainer`, `KeyContainer`, `MembershipContainer`, `Container`: used for collections.
    - `Optional`: used for optional values. Implicitly unwrapped optionals are skipped over by `reflect()` to fetch the reflection of the unwrapped value.
    - `Aggregate`: used for Swift types that bridge to Objective-C and for Objective-C types that have been augmented for use with Swift. For example, `Float` has an `Aggregate` disposition while the non-bridged `Float80` returns `Struct`, and `UIView` (extended for `Reflectable` conformance), has an `Aggregate` disposition while the unadorned `UIBarButtonItem` returns `ObjCObject`.
    - `ObjCObject`: by contrast with `Aggregate`, used for unextended Objective-C classes.
    - `Tuple`: used for tuple values.
    - `Struct`, `Class`, `Enum`: used as fallback cases for types that don't fall into any of the above categories.
> - `objectIdentifier`: the unique object identifier for a class or metatype instance.
> - `summary`: a string description of the value.
> - `quickLookObject`: a [`QuickLookObject`](http://swiftdoc.org/type/QuickLookObject/) instance holding a visual or text representation of the value. Its behavior is similar to the `debugQuickLookObject` [we covered a few weeks back](/quick-look-debugging/).

Additionally, a mirror has an `Int`-based subscript that returns a `(String, MirrorType)` tuple for each child. That's the *name* of the property/key/index and a *mirror* of the value.

So how can we put `MirrorType` to use? Let's suppose we have a group of numbers in a tuple that we want to use for a lottery ticket, but we need to convert them to an `[Int]` array first:

```swift
let lotteryTuple = (4, 8, 15, 16, 23, 42)
```

Rather than extracting the pieces of the tuple one by one (i.e., `lotteryType.0`, `lotteryTuple.1`, etc.), we can use `reflect()` to iterate over the elements:

```swift
// create a mirror of the tuple
let lotteryMirror = reflect(lotteryTuple)

// loop over the elements of the mirror to build an array
var lotteryArray: [Int] = []
for i in 0..<lotteryMirror.count {
    let (index, mirror) = lotteryMirror[i]
    if let number = mirror.value as? Int {
        lotteryArray.append(number)
    }
}
println(lotteryArray)   // [4, 8, 15, 16, 23, 42]
```

Not bad.


### Mapping a Mirror

If we could map over the elements in a mirror, reflecting over an instance's properties or elements would be a bit easier. Let's write a `mapReflection` function that takes an instance of any type and a transforming closure:

```swift
func mapReflection<T, U>(x: T, @noescape transform: (String, MirrorType) -> U) -> [U] {
    var result: [U] = []
    let mirror = reflect(x)
    for i in 0..<mirror.count {
        result.append(transform(mirror[i]))
    }
    return result
}
```

Now we can quite simply print all the logical children of any instance:

```swift
let printChild: (String, MirrorType) -> () = {
    println("\($0): \($1.value)")
}

mapReflection(lotteryTuple, printChild)
// .0: 4
// .1: 8
// ...

mapReflection(lotteryArray, printChild)
// [0]: 4
// [1]: 8
// ...

mapReflection(CGRect.zeroRect, printChild)
// origin: (0.0, 0.0)
// size: (0.0, 0.0)
```

That output might look familiar to those who have used Swift's `dump` function before. `dump` uses reflection recursively to print out an instance's children, their children, and so on:

```swift
dump(CGRect.zeroRect)
// ▿ (0.0, 0.0, 0.0, 0.0)
//   ▿ origin: (0.0, 0.0)
//     - x: 0.0
//     - y: 0.0
//   ▿ size: (0.0, 0.0)
//     - width: 0.0
//     - height: 0.0
```


## Custom-Cut Mirrors

Beyond `dump`, Xcode also uses mirrors extensively for the display of values in a [Playground](/xcplayground/), both in the results pane on the right side of a Playground window and in captured value displays. Custom types don't start out with a custom mirror, so their display can leave something to be desired. Let's look at the default behavior of a custom type in a Playground and then see how a custom `MirrorType` can improve that display.

For our custom type, we'll use a simple struct to hold information about a WWDC session:

```swift
/// Information for a single WWDC session.
struct WWDCSession {
    /// An enumeration of the different WWDC tracks.
    enum Track : String {
        case Featured         = "Featured"
        case AppFrameworks    = "App Frameworks"
        case Distribution     = "Distribution"
        case DeveloperTools   = "Developer Tools"
        case Media            = "Media"
        case GraphicsAndGames = "Graphics & Games"
        case SystemFrameworks = "System Frameworks"
        case Design           = "Design"
    }
    
    let number: Int
    let title: String
    let track: Track
    let summary: String?
}

let session801 = WWDCSession(number: 801,
    title: "Designing for Future Hardware",
    track: .Design,
    summary: "Design for tomorrow's products today. See examples...")
```

By default, reflection on a `WWDCSession` instance uses the built-in `_StructMirror` type. This provides a property-based summary on the right (useful) but only the class name in a captured value pane (not so useful):

![Default WWDCSession Representation]({{ site.asseturl }}/mirrortype-default.gif)

To provide a richer representation of a `WWDCSession`, we'll implement a new type, `WWDCSessionMirror`. This type must conform to `MirrorType`,  including all the properties listed above:

```swift
struct WWDCSessionMirror: MirrorType {
    private let _value: WWDCSession
    
    init(_ value: WWDCSession) {
        _value = value
    }
    
    var value: Any { return _value }
    
    var valueType: Any.Type { return WWDCSession.self }
    
    var objectIdentifier: ObjectIdentifier? { return nil }

    var disposition: MirrorDisposition { return .Struct }
        
    // MARK: Child properties
    
    var count: Int { return 4 }

    subscript(index: Int) -> (String, MirrorType) {
        switch index {
        case 0:
            return ("number", reflect(_value.number))
        case 1:
            return ("title", reflect(_value.title))
        case 2:
            return ("track", reflect(_value.track))
        case 3:
            return ("summary", reflect(_value.summary))
        default:
            fatalError("Index out of range")
        }
    }
    
    // MARK: Custom representation
    
    var summary: String {
        return "WWDCSession \(_value.number) [\(_value.track.rawValue)]: \(_value.title)"
    }
    
    var quickLookObject: QuickLookObject? {
        return .Text(summary)
    }
}
```

In the `summary` and `quickLookObject` properties, we provide our custom representation of a `WWDCSession`—a nicely formatted string. Note, in particular, that the implementation of `count` and the subscript are completely manual. The default mirror types ignore `private` and `internal` access modifiers, so a custom mirror *could* be used to hide implementation details, even from reflection.

Lastly, we must link `WWDCSession` to its custom mirror by adding conformance to the `Reflectable` protocol. Conformance only requires a single new method, `getMirror()`, which returns a `MirrorType`—in this case, our shiny new `WWDCSessionMirror`:

```swift
extension WWDCSession : Reflectable {
    func getMirror() -> MirrorType {
        return WWDCSessionMirror(self)
    }
}
```

That's it! The Playground now uses our custom representation instead of the default:

![Custom WWDCSession Representation]({{ site.asseturl }}/mirrortype-custom.gif)

> In the absence of `Printable` conformance, `println()` and `toString()` will also pull the string representation from an instance's mirror.


* * *


In its current form, Swift reflection is more novelty than powerful feature. With new Swift functionality surely right around the corner at WWDC, this article may prove to have a very short shelf life indeed. But in the mean time, should you find the need for introspection, you'll know just where to look.


