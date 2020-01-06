---
title: "@"
author: Mattt
category: Objective-C
tags: nshipster
excerpt: >-
  If we were to go code-watching for Objective-C, 
  what would we look for? 
  Square brackets, 
  ridiculously long method names, 
  and `@`'s. 
revisions:
  2020-01-06: Updated for Xcode 11
---

Birdwatchers refer to it as 
_(and I swear I'm not making this up)_ 
[<dfn>"Jizz"</dfn>](https://en.wikipedia.org/wiki/Jizz_%28birding%29):
the general characteristics that form an overall impression of a thing.

Walking through the forests of the Pacific Northwest,
a birder would know a nighthawk from other little brown jobs
from its distinct vocalization,
or a grey-cheeked thrush by its white-dark-white underwing pattern.
Looking up in the sky,
there'd be no mistaking a Flying-V formation of migratory geese
from the undulating murmuration of starlings.
And while a twitcher would be forgiven for
mistaking a coot for a duck at the water's edge,
their scaley, non-webbed feet are an obvious tell to an ornithophile.

The usefulness of jizz isn't limited to amateur ornithology, either.
We can distinguish varieties of programming languages
based on their defining characteristics:
Go with its tell-tale couplets of `if err`,
Rust with its unpronounceable, consonant-laden keywords, `pub`, `fn`, and `mut`,
Perl with its special characters that read like Q\*bert swearing.
Lisp's profusion of parentheses is an old cliché at this point;
our favorite telling is 
[that one joke](https://discuss.fogcreek.com/joelonsoftware3/default.asp?cmd=show&ixPost=94232&ixReplies=38) 
about the stolen last page of a Lisp program's printed source code.

```lisp
                )))
              ) )
            ))) ) ))
           )))))
          )))
        ))
      )))) ))
    )))) ))
  )))
)
```

* * *

If we were to go code-watching for the elusive Objective-C species, 
what would we look for?
Square brackets,
ridiculously long method names,
and `@`'s.

`@`, or "at" sign compiler directives, 
are as central to understanding Objective-C's gestalt 
as its ancestry and underlying mechanisms. 
Those little cinnamon roll glyphs are the sugary glue 
that allows Objective-C to be such a powerful, expressive language, 
and yet still compile down to C.
So varied and disparate are its uses that 
the only accurate way to describe what `@` means on its own is 
_"shorthand for something to do with Objective-C"_. 
They cover a broad range in usefulness and obscurity,
from staples like `@interface` and `@implementation` 
to ones you could go your whole career without spotting, 
like `@defs` and `@compatibility_alias`.
But to anyone aspiring to be an NSHipster, 
knowledge of every `@` directives 
is tantamount to a birder's familiarity with
the frenetic hovering of a hummingbird,
the commanding top knot of a Mountain quail, or
the eponymous "cuckoo" of _Coccyzus americanus_.

## Interface & Implementation

`@interface` and `@implementation` are the first things you encounter 
when you start learning Objective-C:

```objc
// MyObject.h
@interface MyObject
<#...#>
@end

// MyObject.m
@implementation MyObject
<#...#>
@end
```

What you don't learn about until later on are categories and class extensions.

Categories allow you to extend the behavior of existing classes 
by adding new class or instance methods. 
As a convention, 
categories are defined in their own `.{h,m}` files:

```objc
// MyObject+CategoryName.h
@interface MyObject (CategoryName)
  - (void)foo;
  - (BOOL)barWithBaz:(NSInteger)baz;
@end

// MyObject+CategoryName.m
@implementation MyObject (CategoryName)
  - (void)foo {
    <#...#>
  }

  - (BOOL)barWithBaz:(NSInteger)baz {
    return YES;
  }
@end
```

Categories are particularly useful for convenience methods on standard framework classes 
_(just don't go overboard with your utility functions)_.

Extensions look like categories
but omit the category name. 
They're typically declared before an `@implementation` 
to specify a private interface
or override properties declared in the public interface:

```objc
// MyObject.m
@interface MyObject ()
@property (readwrite, nonatomic, strong) NSString *name;
- (void)somePrivateMethod;
@end

@implementation MyObject
<#...#>
@end
```

### Properties

Property directives are likewise, 
learned early on:

`@property`
: Declares a class or instance property.

`@synthesize`
: Automatically synthesizes getter / setter methods 
  to an underlying instance or class variable 
  for a declared property.

`@dynamic`
: Instructs the compiler that you'll provide your own 
  implementation for property getter and/or setter methods.

{% info %}

All `@property` declarations are now automatically synthesized by default
(since Xcode 4.4),
so you're much less likely to find them in Objective-C code bases these days.

{% endinfo %}

### Property Attributes


`@property` declarations comprise their own little sub-phylum of syntax,
with attributes for specifying:

- Accessor names 
  (`getter` / `setter`)
- Access types
  (`readwrite` / `readonly`)
- [Atomicity](https://en.wikipedia.org/wiki/Linearizability) 
  (`atomic` / `nonatomic`)
- [Nullability](https://clang.llvm.org/docs/analyzer/developer-docs/nullability.html)
  (`nullable` / `nonnullable` / `null_resettable`)
- [Ownership](https://clang.llvm.org/docs/AutomaticReferenceCounting.html#ownership-qualification)
  (`weak` / `strong` / `copy` / `retain` / `unsafe_unretained`)

And that's not all ---
there's also the `class` attribute,
which lets you declare a class property using 
the same, familiar instance property syntax,
as well as [the forthcoming `direct` attribute](/direct/),
which will let you opt in to direct method dispatch.

### Forward Class Declarations

Occasionally,
`@interface` declarations will reference an external type in a property or as a parameter. 
Rather than adding an `#import` statement in the interface, 
you can use a forward class declaration in the header
and import the necessary in the implementation.

`@class`
: Creates a forward declaration,
  allowing a class to be referenced before its actual declaration.

Shorter compile times, 
less chance of cyclical references; 
you should get in the habit of doing this if you aren't already.

### Instance Variable Visibility

It's a matter of general convention that 
classes provide state and mutating interfaces through properties and methods, 
rather than directly exposing ivars.
Nonetheless, 
in cases where ivars _are_ directly manipulated, 
there are the following visibility directives:

`@public`
: Instance variable can be read and written to directly
  using the following notation: 

```objc
object->_ivar = <#...#>
```

`@package`
: Instance variable is public, 
  except outside of the framework in which it is specified 
  (64-bit architectures only)

`@protected`
: Instance variable is only accessible to its class and derived classes

`@private`
: Instance variable is only accessible to its class

```objc
@interface Person : NSObject {
  @public
  NSString *name;
  int age;

  @private
  int salary;
}
@end
```

## Protocols

There's a distinct point early in an Objective-C programmer's evolution
when they realize that they can define their own protocols.

The beauty of protocols is that they let you design contracts 
that can be adopted outside of a class hierarchy. 
It's the egalitarian mantra at the heart of the American Dream: 
It doesn't matter who you are or where you come from; 
anyone can achieve anything if they work hard enough.

`@protocol`...`@end`
defines a set of methods to be implemented by any conforming class, 
as if they were added to the interface of that class directly.

Architectural stability and expressiveness without the burden of coupling?
Protocols are awesome.

### Requirement Options

You can further tailor a protocol by specifying methods as required or optional. 
Optional methods are stubbed in the interface, 
so as to be auto-completed in Xcode, 
but do not generate a warning if the method isn't implemented. 
Protocol methods are required by default.

The syntax for `@required` and `@optional` follows that of the visibility macros:

```objc
@protocol CustomControlDelegate
  - (void)control:(CustomControl *)control didSucceedWithResult:(id)result;
@optional
  - (void)control:(CustomControl *)control didFailWithError:(NSError *)error;
@end
```

## Exception Handling

Objective-C communicates unexpected state primarily through `NSError`. 
Whereas other languages would use exception handling for this, 
Objective-C relegates exceptions to truly exceptional behavior.

`@` directives are used for the traditional convention of `try/catch/finally` blocks:

```objc
@try{
  // attempt to execute the following statements
  [self getValue:&value error:&error];

  // if an exception is raised, or explicitly thrown...
  if (error) {
    @throw exception;
  }
} @catch(NSException *e) {
  <#...#>
} @finally {
  // always executed after @try or @catch
  [self cleanup];
}
```

## Literals

Literals are shorthand notation for specifying fixed values,
and their availability in a language 
is directly correlated with programmer happiness. 
By that measure, 
Objective-C has long been a language of programmer misery.

### Object Literals

For years, 
Objective-C only had literals for `NSString` values.
But with the release of the 
[Apple LLVM 4.0 compiler](http://clang.llvm.org/docs/ObjectiveCLiterals.html), 
there are now literals for `NSNumber`, `NSArray`, and `NSDictionary`.

`@""`
: An `NSString` object initialized with 
  the text inside the quotation marks.

`@42` / `@3.14` / `@YES` / `@'Z'`
: An `NSNumber` object initialized with 
  the adjacent value using the pertinent class constructor, 
  such that 
  `@42` → `[NSNumber numberWithInteger:42]` and 
  `@YES` → `[NSNumber numberWithBool:YES]`. 
  _(You can use suffixes to further specify type, 
  like `@42U` → `[NSNumber numberWithUnsignedInt:42U]`)_

`@[]`
: An `NSArray` object initialized with 
  a comma-delimited list of objects as its contents. 
  It uses the `+arrayWithObjects:count:` class constructor method, 
  which is a more precise alternative to the more familiar 
  `+arrayWithObjects:`. 

`@{}`
: An `NSDictionary` object initialized with key-value pairs as its contents 
  using the format: `@{@"someKey" : @"theValue"}`.

`@()` 
:  A boxed expression using the appropriate object literal for the enclosed value 
  _(for example, `NSString` for `const char*`, 
  `NSNumber` for `int`, and so on)_. 
  This is also the designated way to use number literals with `enum` values.

### Objective-C Literals

Selectors and protocols can be passed as method parameters.
`@selector()` and `@protocol()` serve as pseudo-literal directives 
that return a pointer to a particular selector (`SEL`) or protocol (`Protocol *`).

`@selector()`
: Provides an `SEL` pointer to a selector with the specified name. 
  Used in methods like `-performSelector:withObject:`.

`@protocol()`
: Provides a `Protocol *` pointer to the protocol with the specified name. 
  Used in methods like `-conformsToProtocol:`.

### C Literals

Literals can also work the other way around, 
transforming Objective-C objects into C values. 
These directives in particular allow us to peek underneath the Objective-C veil 
to see what's really going on.

Did you know that all Objective-C classes and objects are just glorified `struct`s? 
Or that the entire identity of an object hinges on a single `isa` field in that `struct`?

For most of us, 
most of the time, 
this is an academic exercise. 
But for anyone venturing into low-level optimizations, 
this is simply the jumping-off point.

`@encode()`
: Provides the [type encoding](/type-encodings/) of a type.
  This value can be used as the first argument in 
  `NSCoder -encodeValueOfObjCType:at:`.

`@defs()`
: Provides the layout of an Objective-C class. 
  For example, 
  `struct { @defs(NSObject) }` 
  declares a struct with the same fields as an `NSObject`:

{% warning %}
`@defs` is unavailable in the modern Objective-C runtime.
{% endwarning %}

## Optimizations

Some `@` compiler directives provide shortcuts for common optimizations.

`@autoreleasepool {<#...#>}`
: If your code contains a tight loop that creates lots of temporary objects,
  you can use the `@autoreleasepool` directive to 
  aggressively deallocate these short-lived, locally-scoped objects.
  `@autoreleasepool` replaces and improves upon the old `NSAutoreleasePool`, 
  which was significantly slower and unavailable with ARC.

`@synchronized(<#object#>) {<#...#>}`
: Guarantees the safe execution of a particular block within a specified context 
  (usually `self`). 
  Locking in this way is expensive, however, 
  so for classes aiming for a particular level of thread safety, 
  a dedicated `NSLock` property 
  or the use of low-level primitives like GCD
  are preferred.

## Compatibility

When Apple introduces a new API,
it's typically available for the latest SDK only.
If you want to start using these APIs in your app
without dropping backward compatibility,
you can create a <dfn>compatibility alias</dfn>. 

For example,
back when [UICollectionView](/uicollectionview/) was first introduced in iOS 6,
many developers incorporated a 3rd-party library called
[PSTCollectionView](https://github.com/steipete/PSTCollectionView),
which uses `@compatibility_alias` to provide a backwards-compatible, 
drop-in replacement for `UICollectionView`:

```objc
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@compatibility_alias UICollectionViewController PSTCollectionViewController;
@compatibility_alias UICollectionView PSTCollectionView;
@compatibility_alias UICollectionReusableView PSTCollectionReusableView;
@compatibility_alias UICollectionViewCell PSTCollectionViewCell;
@compatibility_alias UICollectionViewLayout PSTCollectionViewLayout;
@compatibility_alias UICollectionViewFlowLayout PSTCollectionViewFlowLayout;
@compatibility_alias UICollectionViewLayoutAttributes PSTCollectionViewLayoutAttributes;
@protocol UICollectionViewDataSource <PSTCollectionViewDataSource> @end
@protocol UICollectionViewDelegate <PSTCollectionViewDelegate> @end
#endif
```

You can use the same approach today to strategically adopt new APIs in your app,
alongside the next and final `@` compiler directive in this week's article:

## Availability

Achieving backwards or cross-platform compatibility in your app
can often feel like a high-wire act.
If you so much as glance towards an unavailable class or method,
it could mean curtains for your app.
That's why the new features in Clang 5.0 came as such a relief.
Now developers have a compiler-provide safety net
to warn them whenever an unavailable API is referenced
for one of your supported targets.

`@available`
: Use in an `if` statement to have the compiler 
  conditionally execute a code path based on the platform availability.


For example,
if you wanted to use a `fancyNewMethod` in the latest version of macOS,
but provide a fallback for older versions of macOS:

```objc
- (void)performCalculation {
  if (@available(macOS 10.15, *)) {
    [self fancyNewMethod];
  } else {
    [self oldReliableMethod];
  }
}
```

{% info %}

`@available` expressions in Objective-C
have the same syntax as their [Swift counterpart](/available/), `#available`.

{% endinfo %}

---

Much like the familiar call of a warbler
or the tell-tale plumage of a peacock,
the `@` sigil plays a central role 
in establishing Objective-C's unique identity.
It's a versatile, power-packed character 
that embodies the underlying design and mechanisms of the language.
So be on the lookout for its many faces 
as you wander through codebases, new or familiar. 
