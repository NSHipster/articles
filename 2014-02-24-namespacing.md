---
title: Namespacing
author: Mattt Thompson
category: Objective-C
excerpt: "Namespacing is the preeminent bugbear of Objective-C. A cosmetic quirk with global implications, the language's lack of identifier containers remains a source of prodigious quantities of caremad for armchair language critics."
status:
    swift: n/a
---

> Why the hell is everything `NS`-whatever?

You'll hear that within the first minute of introducing someone to Objective-C. Guaranteed.

Like a parent faced with the task of explaining the concept of death or the non-existence of Santa, you do your best to be forthcoming with facts, so that they might arrive at a conclusion themselves.

> Why, Jimmy, `NS` stands for `NeXTSTEP` (well, actually, `NeXTSTEP/Sun`, but we'll cover that with "the birds & the bees" talk), and it's used to...

...but by the time the words have left your mouth, you can already sense the disappointment in their face. Their innocence has been lost, and with an audible *sigh* of resignation, they start to ask uncomfortable questions about [@](http://nshipster.com/at-compiler-directives/)

* * *

Namespacing is the preeminent bugbear of Objective-C. A cosmetic quirk with global implications, the language's lack of identifier containers remains a source of prodigious quantities of caremad for armchair language critics.

This is all to say: unlike many other languages that are popular today, Objective-C does not provide a module-like mechanism for avoiding class and method name collisions.

Instead, Objective-C relies on prefixes to ensure that functionality in one part of the app doesn't interfere with similarly named code somewhere else.

We'll jump into those right after a quick digression into type systems:

## Types in C & Objective-C

As noted many times in this publication, Objective-C is built directly on top of the C language. One consequence of this is that Objective-C and C share a type system, requiring that identifiers are globally unique.

You can see this for yourself—try defining a new static variable with the same name as an existing `@interface`, and the compiler will generate an error:

~~~{objective-c}
@interface XXObject : NSObject
@end

static char * XXObject;  // Redefinition of "XXObject" as different kind of symbol
~~~

That said, the Objective-C runtime creates a layer of abstraction on top of the C type system, allowing the following code to compile without even a snicker:

~~~{objective-c}
@protocol Malkovich
@end

@interface Malkovich : NSObject <Malkovich> {
    id Malkovich;
}

@property id Malkovich;
+ (id)Malkovich;
- (id)Malkovich;
@end

@interface Malkovich (Malkovich)
@end

@implementation Malkovich
@synthesize Malkovich;

+ (id)Malkovich {
    id Malkovich = @"Malkovich";
    return Malkovich;
}
@end
~~~

Within the context of the Objective-C runtime, a program is able to differentiate between a class, a protocol, a category, an instance variable, an instance method, and a class method all having the same name.

> That a variable can reappropriate the name of an existing method is a consequence of the C type system (which similarly allows for a variable to shadow the name of its containing function)

## Prefixes

All classes in an Objective-C application must be globally unique. Since many different frameworks are likely have some conceptual overlap—and therefore an overlap in names (users, views, requests / responses, etc.)—convention dictates that class names use 2 or 3 letter prefix.

### Class Prefixes

Apple [recommends](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html) that 2-letter prefixes be reserved for first-party libraries and frameworks, while third-party developers (that's us) opt for 3 letters or more.

A veteran Mac or iOS developer will have likely memorized most if not all of the following abbreviated identifiers:

<table>
    <thead>
        <tr>
            <th>Prefix</th>
            <th>Frameworks</th>
        </tr>
    </thead>
    <tbody>
        <tr><td><tt>AB</tt></td><td>AddressBook / AddressBookUI</td></tr>
        <tr><td><tt>AC</tt></td><td>Accounts</td></tr>
        <tr><td><tt>AD</tt></td><td>iAd</td></tr>
        <tr><td><tt>AL</tt></td><td>AssetsLibrary</td></tr>
        <tr><td><tt>AU</tt></td><td>AudioUnit</td></tr>
        <tr><td><tt>AV</tt></td><td>AVFoundation</td></tr>
        <tr><td><tt>CA</tt></td><td>CoreAnimation</td></tr>
        <tr><td><tt>CB</tt></td><td>CoreBluetooth</td></tr>
        <tr><td><tt>CF</tt></td><td>CoreFoundation / CFNetwork</td></tr>
        <tr><td><tt>CG</tt></td><td>CoreGraphics / QuartzCore / ImageIO</td></tr>
        <tr><td><tt>CI</tt></td><td>CoreImage</td></tr>
        <tr><td><tt>CL</tt></td><td>CoreLocation</td></tr>
        <tr><td><tt>CM</tt></td><td>CoreMedia / CoreMotion</td></tr>
        <tr><td><tt>CV</tt></td><td>CoreVideo</td></tr>
        <tr><td><tt>EA</tt></td><td>ExternalAccessory</td></tr>
        <tr><td><tt>EK</tt></td><td>EventKit / EventKitUI</td></tr>
        <tr><td><tt>GC</tt></td><td>GameController</td></tr>
        <tr><td><tt>GLK</tt><sup>*</sup></td><td>GLKit</td></tr>
        <tr><td><tt>JS</tt></td><td>JavaScriptCore</td></tr>
        <tr><td><tt>MA</tt></td><td>MediaAccessibility</td></tr>
        <tr><td><tt>MC</tt></td><td>MultipeerConnectivity</td></tr>
        <tr><td><tt>MF</tt></td><td>MessageUI*</td></tr>
        <tr><td><tt>MIDI</tt><sup>*</sup></td><td>CoreMIDI</td></tr>
        <tr><td><tt>MK</tt></td><td>MapKit</td></tr>
        <tr><td><tt>MP</tt></td><td>MediaPlayer</td></tr>
        <tr><td><tt>NK</tt></td><td>NewsstandKit</td></tr>
        <tr><td><tt>NS</tt></td><td>Foundation, AppKit, CoreData</td></tr>
        <tr><td><tt>PK</tt></td><td>PassKit</td></tr>
        <tr><td><tt>QL</tt></td><td>QuickLook</td></tr>
        <tr><td><tt>SC</tt></td><td>SystemConfiguration</td></tr>
        <tr><td><tt>Sec</tt><sup>*</sup></td><td>Security*</td></tr>
        <tr><td><tt>SK</tt></td><td>StoreKit / SpriteKit</td></tr>
        <tr><td><tt>SL</tt></td><td>Social</td></tr>
        <tr><td><tt>SS</tt></td><td>Safari Services</td></tr>
        <tr><td><tt>TW</tt></td><td>Twitter</td></tr>
        <tr><td><tt>UI</tt></td><td>UIKit</td></tr>
        <tr><td><tt>UT</tt></td><td>MobileCoreServices</td></tr>
    </tbody>
</table>

#### 3rd-Party Class Prefixes

Until recently, with the advent of [CocoaPods](http://cocoapods.org) and a surge of new iOS developers, the distribution of open source, 3rd-party code had been largely a non-issue for Apple and the rest of the Objective-C community. Apple's naming guidelines came about recently enough that the advice to adopt 3-letter prefixes is only _just_ becoming accepted practice.

Because of this, many established libraries still use 2-letter prefixes. Consider some of these [most-starred Objective-C repositories on GitHub](https://github.com/search?l=Objective-C&q=stars%3A%3E1&s=stars&type=Repositories).

<table>
    <thead>
        <tr>
            <th>Prefix</th>
            <th>Frameworks</th>
        </tr>
    </thead>
    <tbody>
        <tr><td><tt>AF</tt></td><td><a href="https://github.com/AFNetworking/AFNetworking">AFNetworking</a> ("<a href="http://en.wikipedia.org/wiki/Gowalla">Alamofire</a>")</td></tr>
        <tr><td><tt>RK</tt></td><td><a href="https://github.com/RestKit/RestKit">RestKit</a></td></tr>
        <tr><td><tt>GPU</tt></td><td><a href="https://github.com/BradLarson/GPUImage">GPUImage</a></td></tr>
        <tr><td><tt>SD</tt></td><td><a href="https://github.com/rs/SDWebImage">SDWebImage</a></td></tr>
        <tr><td><tt>MB</tt></td><td><a href="https://github.com/jdg/MBProgressHUD">MBProgressHUD</a></td></tr>
        <tr><td><tt>FB</tt></td><td><a href="https://github.com/facebook/facebook-ios-sdk">Facebook SDK</a></td></tr>
        <tr><td><tt>FM</tt></td><td><a href="https://github.com/ccgus/fmdb">FMDB</a> ("<a href="http://flyingmeat.com">Flying Meat</a>")</td></tr>
        <tr><td><tt>JK</tt></td><td><a href="https://github.com/johnezang/JSONKit">JSONKit</a></td></tr>
        <tr><td><tt>FUI</tt></td><td><a href="https://github.com/Grouper/FlatUIKit">FlatUI</a></td></tr>
        <tr><td><tt>NI</tt></td><td><a href="https://github.com/jverkoey/nimbus">Nimbus</a></td></tr>
        <tr><td><tt>RAC</tt></td><td><a href="https://github.com/ReactiveCocoa/ReactiveCocoa">Reactive Cocoa</a></td></tr>
    </tbody>
</table>

Seeing as how [we're already seeing prefix overlap among 3rd-party libraries](https://github.com/AshFurrow/AFTabledCollectionView), make sure that you follow a 3+-letter convention in your own code.

> For especially future-focused library authors, consider using [`@compatibility_alias`](http://nshipster.com/at-compiler-directives/) to provide a seamless migration path for existing users in your next major upgrade.

### Method Prefixes

It's not just classes that are prone to naming collisions: selectors suffer from this too—in ways that are even more problematic than classes.

Consider the category:

~~~{objective-c}
@interface NSString (PigLatin)
- (NSString *)pigLatinString;
@end
~~~

If `-pigLatinString` were implemented by another category (or added to the `NSString` class in a future version of iOS or OS X), any calls to that method would result in undefined behavior, since no guarantee is made as to the order in which methods are defined by the runtime.

This can be guarded against by prefixing the method name, just like the class name (prefixing the category name isn't a bad idea, either):

~~~{objective-c}
@interface NSString (XXXPigLatin)
- (NSString *)xxx_pigLatinString;
@end
~~~

Apple's recommendation that [all category methods use prefixes](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html#//apple_ref/doc/uid/TP40011210-CH6-SW4) is even less widely known or accepted than its policy on class prefixing.

There are many outspoken developers who will passionately argue one side or another. However, weighing the risk of collision against its likelihood, the cost/benefit analysis is not entirely clear-cut:

The main feature of categories is coating useful functionality with syntactic sugar. Any category method could alternatively be implemented as a function taking an explicit argument in place of the implicit `self` of a method.

Collisions can be detected at compile time by setting the `OBJC_PRINT_REPLACED_METHODS` environment variable to `YES`. In practice, collisions are extremely rare, and when they do occur, they're usually an indicator of functionality that is needlessly duplicated across dependencies. Although the worst-case scenario is a runtime exception, it's entirely likely that two methods named the same thing will actually _do_ the same thing, and result in no change in behavior. All of those Swiss Army Knife categories that defined `NSArray -firstObject` continued to march on once the method was officially added.

Just as with constitutional scholarship, there will be strict and loose interpretations of Apple's programming guidelines. Those that see it as a living document would point out that... actually, you know what? If you've read this far and are still undecided, just prefix your damn category methods. If you choose not to, just be mindful that it could bite you in the ass.

#### Swizzling

The one case where method prefixing (or suffixing) is absolutely necessary is when doing method replacement, as discussed in last week's article on [swizzling](http://nshipster.com/method-swizzling/).

~~~{objective-c}
@implementation UIViewController (Swizzling)

- (void)xxx_viewDidLoad {
    [self xxx_viewDidLoad];

    // Swizzled implementation
}
~~~

## Do We _Really_ Need Namespaces?

With all of the recent talk about replacing / reinventing / reimagining Objective-C, it's almost taken as a given that namespacing would be an obvious feature. But what does that actually get us?

**Aesthetics?** Aside from IETF members and military personnel, nobody likes the visual aesthetic of <acronym title="CAPITAL LETTER ACRONYMS">CLA</acronym>s. But would `::`, `/`, or an extra `.` really make matters better? Do we _really_ want to start calling `NSArray` "Foundation Array"? (And what would I do with NSHipster.com ?!)

**Semantics?** Start to look closely at any other language, and how they actually use namespaces, and you'll realize that namespaces don't magically solve all matters of ambiguity. If anything, the additional context makes things worse.

Not to create a straw man, but an imagined implementation of Objective-C namespaces probably look a lot like this:

~~~{objective-c}
@namespace XX
    @implementation Object

    @using F: Foundation;

    - (void)foo {
        F:Array *array = @[@1,@2, @3];

        // ...
    }

    @end
@end
~~~

What we have currently—warts and all—has the notable advantage of non-ambiguity. There is no mistaking `NSString` for anything other than what it is, either by the compiler or when we talk about it as developers. There are no special contextual considerations to consider when reading through code to understand what actors are at play. And best of all: class names are [_exceedingly_ easy to search for](http://lmgtfy.com/?q=NSString).

Either way, if you're interested in this subject, I'd encourage you to take a look at [this namespace feature proposal](http://optshiftk.com/2012/04/draft-proposal-for-namespaces-in-objective-c/) by [Kyle Sluder](http://optshiftk.com). It's a fascinating read.
