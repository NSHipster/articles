---
title: "Long Live Cocoa"
author: Nate Cook
category: ""
excerpt: "Swift is an exciting language for many of us, but it's still brand new. The stability of Objective-C and the history and strength of Cocoa mean that Swift isn't ready to be the driving force behind a major change, at least not quite yet. Cocoa's depth and the power it affords, along with the way it and Swift go hand in hand, make Cocoa as relevant and as promising as ever."
hiddenlang: ""
status:
    swift: 1.0
---

It's the start of a new year—2015, the year of Watch, the first full year for Swift, and a bit of a new start for NSHipster. Before we get caught up in the excitement of new devices and the next beta of Xcode or start planning our trips to WWDC 2015, let's take a moment to look at our tools as they are today: Objective-C, Swift, and most importantly, Cocoa.

Swift is an exciting language for many of us, but it's still brand new. The stability of Objective-C and the history and strength of Cocoa mean that Swift isn't ready to be the driving force behind a [major change](/the-death-of-cocoa/), at least not quite yet. Cocoa's depth and the power it affords, along with the way it and Swift go hand in hand, make Cocoa as relevant and as promising as ever. In fact, I don't think there's been a more exciting time to be a Cocoa developer.


* * *


Cocoa is an impressively deep API—dig a little below the surface of any common tool and you unearth a trove of functionality. You need look no further for proof than the incredible work [Mattt](http://nshipster.com/authors/mattt-thompson/) has done in these very pages over the last few years, illuminating what we didn't know Cocoa could do. To name just a few:

- The foundations of natural language interfaces with [`NSLinguisticTagger`](/nslinguistictagger/) and [`AVSpeechSynthesizer`](/avspeechsynthesizer/)
- Simple data persistence with [`NSCoding` and `NSKeyedArchiver`](/nscoding/)
- Object-oriented concurrent execution with [`NSOperation`](/nsoperation/)
- Normalizing and transliterating multi-language input with [`CFStringTransform`](/cfstringtransform/)
- Detection of all sorts of data with [`NSDataDetector`](/nsdatadetector/)
- Native custom sharing and editing controls with [`UIActivityViewController`](/uiactivityviewcontroller/) and [`UIMenuController`](/uimenucontroller/)
- Built-in [network caching](/nsurlcache/) for our [`NSURL`](/nsurl/) requests

The list goes on and on. (Check it out—right there on the [front page](/#archive).)


### Hand in Hand

What's more, Cocoa and Swift are practically—and in Swift's case, literally—made for each other.

On the Cocoa side, changes to the toolset over the past few years paved the way for Cocoa to be Swift-friendly right out of the gate. Shifting to LLVM/Clang, adding block syntax to Objective-C, pushing the `NS_ENUM` & `NS_OPTIONS` macros, converting initializers to return `instancetype`—all these steps make the Cocoa APIs we're using today far more compatible with Swift than they could have been even a few years ago. Whenever you supply a Swift closure as a `NSURLSession` completion handler, or use the suggested completions for `UIModalTransitionStyle`, you're building on that work, done years ago when Swift was still behind closed doors (or in Chris Lattner's head).

Swift was then designed from the ground up to be used with Cocoa. If I could nominate a single Swift feature as [most confusing to newcomers](http://stackoverflow.com/search?q=swift+unwrapped+unexpectedly), it would be Optionals, with their extra punctuation and unwrapping requirements. Even so, Optionals represent a crowning achievement, one so foundational it fades into the woodwork: Swift is a brand-new language that *doesn't* require a brand-new API. It's a type-safe, memory-safe language whose primary purpose is interacting directly with the enormous C-based Cocoa API, with pointers and raw memory lying all over the place.

This is no small feat. The developer tools team at Apple has been busy annotating the entire API with information about memory management for parameters and return values. Once annotated, functions can be used safely from within Swift, since the compiler knows how to bridge types back and forth from Swift to annotated C code.

Here's an example of similar annotated and unannotated functions. First, the C versions:

````c
// Creates an immutable copy of a string.
CFStringRef CFStringCreateCopy ( CFAllocatorRef alloc, CFStringRef theString );
// Encodes an OSType into a string suitable for use as a tag argument.
CFStringRef UTCreateStringForOSType ( OSType inOSType );
````

Both of these functions return a `CFStringRef`—a reference to a `CFString`. A `CFStringRef` can be bridged to a Swift `CFString` instance, but this is *only* safe if the method has been annotated. In Swift, you can readily see the difference:

````swift
// annotated: returns a memory-managed Swift `CFString`
func CFStringCreateCopy(alloc: CFAllocator!, theString: CFString!) -> CFString!
// unannotated: returns an *unmanaged* `CFString`
func UTCreateStringForOSType(inOSType: OSType) -> Unmanaged<CFString>!
````

Upon receiving an `Unmanaged<CFString>!`, you need to follow up with `.takeRetainedValue()` or `.takeUnretainedValue()` to get a memory-managed `CFString` instance. Which to call? To know that, you have to read the documentation or know the conventions governing whether the result you get back is retained or unretained. By annotating these functions, Apple has done that work for you, already guaranteeing memory safety across a huge swath of Cocoa.


* * *


Moreover, Swift doesn't just embrace Cocoa APIs, it actively improves them. Take the venerable `CGRect`, for example. As a C struct, it can't contain any instance methods, so all the [tools to manipulate `CGRect`s](/cggeometry/) live in top-level functions. These tools are powerful, but you need to know they exist and how to put them to use. These four lines of code, dividing a `CGRect` into two smaller pieces, might require three trips to the documentation:

````objective-c
CGRect nextRect;
CGRect remainingRect;
CGRectDivide(sourceRect, &nextRect, &remainingRect, 250, CGRectMinXEdge);
NSLog("Remaining rect: %@", NSStringFromCGRect(remainingRect));
````

In Swift, structs happily contain both static and instance methods and computed properties, so Core Graphics extends `CGRect` to make finding and using those tools far easier. Because `CGRect*` functions are mapped to instance methods or properties, the code above is reduced to this:

````swift
let (nextRect, remainingRect) = sourceRect.rectsByDividing(250, CGRectEdge.MinXEdge)
println("Remaining rect: \(remainingRect)")
````


### Getting Better All The Time

To be sure, working with Cocoa and Swift together is sometimes awkward. Where that does happen, it often comes from using patterns that are idiomatic to Objective-C. Delegates, target-selector, and `NSInvocation` still have their place, but with closures so easy in Swift, it can feel like overkill to add a whole method (or three) just to accomplish something simple. Bringing more closure- or block-based methods to existing Cocoa types can easily smooth out these bumps.

For example, `NSTimer` has a perfectly fine interface, but it suffers from requiring an Objective-C method to call, either via target-selector or invocation. When defining a timer, chances are I already have everything ready to go. [With a simple `NSTimer` extension](https://gist.github.com/natecook1000/b0285b518576b22c4dc8) using its toll-free bridged Core Foundation counterpart, `CFTimer`, we're in business in no time:

````swift
let message = "Are we there yet?"
let alert = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
alert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))

NSTimer.scheduledTimerWithTimeInterval(10, repeats: true) { [weak self] timer in
    if self?.presentedViewController == nil {
        self?.presentViewController(alert, animated: true, completion: nil)
    }
}
// I swear I'll turn this car around.
````


* * *


None of this is to refute [Mattt's last post](/the-death-of-cocoa/), though—on an infinite time scale, we'll surely be coding against Cocoa's successor on our 42" iPads while looking out across the Titan moonscape. But as long as Cocoa's still around, isn't it *great?*

