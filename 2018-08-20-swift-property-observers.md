---
title: Swift Property Observers
author: Mattt
category: Swift
excerpt: >
  Modern software development has become what might be seen as
  the quintessence of Goldbergian contraption.
  Yet there are occasions when action-at-a-distance 
  may do more to clarify rather than confound.
status:
  swift: 4.2
---

By the 1930's,
Rube Goldberg had become a household name,
synonymous with the fantastically complicated and whimsical inventions
depicted in comic strips like
["Self-Operating Napkin."](https://upload.wikimedia.org/wikipedia/commons/a/a9/Rube_Goldberg%27s_%22Self-Operating_Napkin%22_%28cropped%29.gif)
Around the same time,
Albert Einstein popularized the phrase "spooky action at a distance"
in his [critique](https://en.wikipedia.org/wiki/EPR_paradox)
of the prevailing interpretation of quantum mechanics by Niels Bohr.

Nearly a century later,
modern software development has become what might be seen as
the quintessence of a Goldbergian contraption ---
sprawling ever closer into that spooky realm by way of quantum computers.

As software developers,
we're encouraged to reduce action-at-a-distance in our code whenever possible.
This is codified in impressive-sounding guidelines like the
[Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle),
[Principle of Least Astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment),
and [Law of Demeter](https://en.wikipedia.org/wiki/Law_of_Demeter).
Yet despite their misgivings about code that produces side effects,
there are sometimes occasions where such techniques
may clarify rather than confound.

Such is the focus of this week's article about property observers in Swift,
which offer a built-in, lightweight alternative
to more formalized solutions like
model-view-viewmodel (MVVM)
functional reactive programming (FRP).

---

There are two kinds of properties in Swift:
<dfn>stored properties</dfn>, which associate state with an object, and
<dfn>computed properties</dfn>, which perform a calculation based on that state.
For example,

```swift
struct S {
    // Stored Property
    var stored: String = "stored"

    // Computed Property
    var computed: String {
        return "computed"
    }
}
```

When you declare a stored property,
you have the option to define <dfn>property observers</dfn>
with blocks of code to be executed when a property is set.
The `willSet` observer runs before the new value is stored
and the `didSet` observer runs after.
And they run regardless of whether the old value is equal to the new value.

```swift
struct S {
    var stored: String {
        willSet {
            print("willSet was called")
            print("stored is now equal to \(self.stored)")
            print("stored will be set to \(newValue)")
        }

        didSet {
            print("didSet was called")
            print("stored is now equal to \(self.stored)")
            print("stored was previously set to \(oldValue)")
        }
    }
}
```

For example,
running the following code prints the resulting text to the console:

```swift
var s = S(stored: "first")
s.stored = "second"
```

- <samp>willSet was called</samp>
- <samp>stored is now equal to first</samp>
- <samp>stored will be set to second</samp>
- <samp>didSet was called</samp>
- <samp>stored is now equal to second</samp>
- <samp>stored was previously set to first</samp>

> An important caveat is that observers don't run
> when you set a property in an initializer.
> As of Swift 4.2,
> you can work around that by wrapping the setter call in a `defer` block,
> but that's
> [a bug that will soon be fixed](https://twitter.com/jckarter/status/926459181661536256),
> so you shouldn't depend on this behavior.

---

Swift property observers have been part of the language
from the very beginning.
To better understand why,
let's take a quick look at how things work in Objective-C:

## Properties in Objective-C

In Objective-C,
all properties are, in a sense, computed.
Each time a property is accessed through dot notation,
the call is translated into an equivalent getter or setter method invocation.
This, in turn, is compiled into a message send
that executes a function that reads or writes an instance variable.

```objc
// Dot accessor
person.name = @"Johnny";

// ...is equivalent to
[person setName:@"Johnny"];

// ...which gets compiled to
objc_msgSend(person, @selector(setName:), @"Johnny");

// ...whose synthesized implementation yields
person->_name = @"Johnny";
```

Side effects are something you generally want to avoid in programming
because they make it difficult to reason about program behavior.
But many Objective-C developers had come to rely on the ability to
inject additional behavior into getter or setter methods as needed.

Swift's design for properties formalized these patterns
and created a distinction between side effects
that decorate state access (stored properties)
and those that redirect state access (computed properties).
For stored properties, the `willSet` and `didSet` observers
replace the code that you'd otherwise include alongside ivar access.
For computed properties, the `get` and `set` accessors
replace code that you might implement for `@dynamic` properties in Objective-C.

As a result,
we get more consistent semantics
and better guarantees about mechanisms like
Key-Value Observing (KVO) and
Key-Value Coding (KVC) that interact with properties.

---

So what can you do with property observers in Swift?
Here are a couple ideas for your consideration:

---

## Validating / Normalizing Values

Sometimes you want to impose additional constraints
on what values are acceptable for a type.

For example,
if you were developing an app that interfaced with a government bureaucracy,
you'd need to ensure that the user wouldn't be able to submit a form
if it was missing a required field,
or contained an invalid value.

If, say,
a form required that names use capital letters without accents,
you could use the `didSet` property observer
to automatically strip diacritics and uppercase the new value:

```swift
var name: String? {
    didSet {
        self.name = self.name?
                        .applyingTransform(.stripDiacritics,
                                            reverse: false)?
                        .uppercased()
    }
}
```

Setting a property in the body of an observer (fortunately)
doesn't trigger additional callbacks,
so we don't create an infinite loop here.
This is the same reason why this won't work as a `willSet` observer;
any value set in the callback is immediately overwritten
when the property is set to its `newValue`.

While this approach can work for one-off problems,
repeat use like this is a strong indicator of business logic that
could be formalized in a type.

A better design would be to create a `NormalizedText` type
that encapsulates the requirements of text to be entered in such a form:

```swift
struct NormalizedText {
    enum Error: Swift.Error {
        case empty
        case excessiveLength
        case unsupportedCharacters
    }

    static let maximumLength = 32

    var value: String

    init(_ string: String) throws {
        if string.isEmpty {
            throw Error.empty
        }

        guard let value = string.applyingTransform(.stripDiacritics,
                                                   reverse: false)?
                                .uppercased(),
              value.canBeConverted(to: .ascii)
        else {
             throw Error.unsupportedCharacters
        }

        guard value.count < NormalizedText.maximumLength else {
            throw Error.excessiveLength
        }

        self.value = value
    }
}
```

A failable or throwing initializer
can surface errors to the caller
in a way that a `didSet` observer can't.
Now, when a troublemaker like
_Jøhnny_
from _[Llanfair­pwllgwyngyll­gogery­chwyrn­drobwll­llan­tysilio­gogo­goch](https://en.wikipedia.org/wiki/Llanfairpwllgwyngyll)_
comes a'knocking,
we can give him what's for!
(Which is to say,
communicate errors to him in a reasonable manner
rather than failing silently or allowing invalid data)

## Propagating Dependent State

Another potential use case for property observers
is propagating state to dependent components in a view controller.

Consider the following example of a `Track` model
and a `TrackViewController` that presents it:

```swift
struct Track {
    var title: String
    var audioURL: URL
}

class TrackViewController: UIViewController {
    var player: AVPlayer?

    var track: Track? {
        willSet {
            self.player?.pause()
        }

        didSet {
            guard let track = self.track else {
                return
            }

            self.title = track.title

            let item = AVPlayerItem(url: track.audioURL)
            self.player = AVPlayer(playerItem: item)
            self.player?.play()
        }
    }
}
```

When the `track` property of the view controller is set,
the following happens automatically:

1. Any previous track's audio is paused
2. The `title` of the view controller is set to the new track title
3. The new track's audio is loaded and played

_Pretty cool, right?_

You could even cascade this behavior across multiple observed properties a la
[that one scene from _Mousehunt_](https://www.youtube.com/watch?v=TVAhhVrpkwM).

---

As a general rule,
side effects are something to avoid when programming,
because they make it difficult to reason about complex behavior.
Keep that in mind the next time you reach for this new tool.

And yet, from the tippy top of this teetering tower of abstraction,
it can be tempting --- and perhaps sometimes rewarding ---
to embrace the chaos of the system.
Always following the rules is such a _Bohr_.
