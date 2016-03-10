---
title: NSOrderedSet
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Why isn't NSOrderedSet a subclass of NSSet? The answer may surprise you."
status:
    swift: 2.0
    reviewed: September 15, 2015
---

Here's a question: why isn't `NSOrderedSet` a subclass of `NSSet`?

It seems perfectly logical, after all, for `NSOrderedSet`--a class that enforces the same uniqueness constraint of `NSSet`--to be a _subclass_ of `NSSet`. It has the same methods as `NSSet`, with the addition of some `NSArray`-style methods like `objectAtIndex:`. By all accounts, it would seem to perfectly satisfy the requirements of the [Liskov substitution principle](http://en.wikipedia.org/wiki/Liskov_substitution_principle), that:

> If `S` is a subtype of `T`, then objects of type `T` in a program may be replaced with objects of type `S` without altering any of the desirable properties of that program.

So why is `NSOrderedSet` a subclass of `NSObject` and not `NSSet` or even `NSArray`?

_Mutable / Immutable Class Clusters_

[Class Clusters](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html%23//apple_ref/doc/uid/TP40002974-CH4-SW34) are a design pattern at the heart of the Foundation framework; the essence of Objective-C's simplicity in everyday use.

But class clusters offer simplicity at the expense of extensibility, which becomes especially tricky when it comes to mutable / immutable class pairs like `NSSet` / `NSMutableSet`.

As expertly demonstrated by [Tom Dalling](http://tomdalling.com) in [this Stack Overflow question](http://stackoverflow.com/questions/11278995/why-doesnt-nsorderedset-inherit-from-nsset), the method `-mutableCopy` creates an inconsistency that is inherent to Objective-C's constraint on single inheritance.

To start, let's look at how `-mutableCopy` is supposed to work in a class cluster:

~~~{swift}
let immutable = NSSet()
let mutable = immutable.mutableCopy() as! NSMutableSet

mutable.isKindOfClass(NSSet.self) // true
mutable.isKindOfClass(NSMutableSet.self) // true
~~~

~~~{objective-c}
NSSet* immutable = [NSSet set];
NSMutableSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // YES
~~~

Now let's suppose that `NSOrderedSet` was indeed a subclass of `NSSet`:

~~~{swift}
// class NSOrderedSet: NSSet {...}

let immutable = NSOrderedSet()
let mutable = immutable.mutableCopy() as! NSMutableOrderedSet

mutable.isKindOfClass(NSSet.self) // true
mutable.isKindOfClass(NSMutableSet.self) // false (!)
~~~

~~~{objective-c}
// @interface NSOrderedSet : NSSet

NSOrderedSet* immutable = [NSOrderedSet orderedSet];
NSMutableOrderedSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // NO (!)
~~~

<img src="{{ site.asseturl }}/nsorderedset-case-1.svg" />

That's no good... since `NSMutableOrderedSet` couldn't be used as a method parameter of type `NSMutableSet`. So what happens if we make `NSMutableOrderedSet` a subclass of `NSMutableSet` as well?

~~~{swift}
// class NSOrderedSet: NSSet {...}
// class NSMutableOrderedSet: NSMutableSet {...}

let immutable = NSOrderedSet()
let mutable = immutable.mutableCopy() as! NSMutableOrderedSet

mutable.isKindOfClass(NSSet.self) // true
mutable.isKindOfClass(NSMutableSet.self) // true
mutable.isKindOfClass(NSOrderedSet.self) // false (!)
~~~

~~~{objective-c}
// @interface NSOrderedSet : NSSet
// @interface NSMutableOrderedSet : NSMutableSet

NSOrderedSet* immutable = [NSOrderedSet orderedSet];
NSMutableOrderedSet* mutable = [immutable mutableCopy];

[mutable isKindOfClass:[NSSet class]]; // YES
[mutable isKindOfClass:[NSMutableSet class]]; // YES
[mutable isKindOfClass:[NSOrderedSet class]]; // NO (!)
~~~

<img src="{{ site.asseturl }}/nsorderedset-case-2.svg" />

This is perhaps even worse, as now `NSMutableOrderedSet` couldn't be used as a method parameter expecting an `NSOrderedSet`.

No matter how we approach it, we can't stack a mutable / immutable class pair on top of another existing mutable / immutable class pair. It just won't work in Objective-C.

Rather than subject ourselves to the perils of [multiple inheritance](http://en.wikipedia.org/wiki/Multiple_inheritance), we could use Protocols to get us out of this pickle (as it does every other time the spectre of multiple inheritance is raised). Indeed, Foundation's collection classes _could_ become more aspect-oriented by adding protocols:

* `NSArray : NSObject <NSOrderedCollection>`
* `NSSet : NSObject <NSUniqueCollection>`
* `NSOrderedSet : NSObject <NSOrderedCollection, NSUniqueCollection>`

However, to reap any benefit from this arrangement, all of the existing APIs would have to be restructured to have parameters accept `id <NSOrderedCollection>` instead of `NSArray`. But the transition would be painful, and would likely open up a whole can of edge cases... which would mean that it would never be fully adopted... which would mean that there's less incentive to adopt this approach when defining your own APIs... which are less fun to write because there's now two incompatible ways to do something instead of one... which...

...wait, why would we use `NSOrderedSet` in the first place, anyway?

---

`NSOrderedSet` was introduced in iOS 5 & OS X Lion. The only APIs changed to add support for `NSOrderedSet`, though, were part of [Core Data](http://developer.apple.com/library/mac/#releasenotes/DataManagement/RN-CoreData/_index.html).

This was fantastic news for anyone using Core Data at the time, as it solved one of the long-standing annoyances of not having a way to arbitrarily order relationship collections. Previously, you'd have to add a `position` attribute, which would be re-calculated every time a collection was modified. There wasn't a built-in way to validate that your collection positions were unique or that the sequence didn't have any gaps.

In this way, `NSOrderedSet` is an _answer to our [prayers](http://bugreport.apple.com/)_.

Unfortunately, its very existence in Foundation has created something between an attractive nuisance and a red herring for API designers.

Although it is perfectly suited to that one particular use case in Core Data, `NSOrderedSet` is probably not a great choice for the majority of APIs that could potentially use it. In cases where a simple collection of objects is passed as a parameter, a simple `NSArray` does the trick--even if there is an implicit understanding that you shouldn't have duplicate entries. This is even more the case when order matters for a collection parameter--just use `NSArray` (there should be code to deal with duplicates in the implementation anyway). If uniqueness does matter, or the semantics of sets makes sense for a particular method, `NSSet` has and remains a great choice.

---

So, as a general rule: **`NSOrderedSet` is useful for intermediary and internal representations, but you probably shouldn't introduce it as a method parameters unless it's particularly well-suited to the semantics of the data model.**

If nothing else, `NSOrderedSet` illuminates some of the fascinating implications of Foundation's use of the class cluster design pattern. In doing so, it allows us better understand the trade-off between simplicity and extensibility as we make these choices in our own application designs.
