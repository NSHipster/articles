---
title: "@"
author: Mattt Thompson
category: Objective-C
tags: nshipster
excerpt: "If we were to go code-watching for Objective-C, what would we look for? Square brackets, ridiculously-long method names, and `@`'s. \"at\" sign compiler directives are as central to understanding Objective-C's gestalt as its ancestry and underlying mechanisms. It's the sugary glue that allows Objective-C to be such a powerful, expressive language, and yet still compile all the way down to C."
status:
    swift: n/a
---

Birdwatchers refer to it as (and I swear I'm not making this up) ["Jizz"](http://en.wikipedia.org/wiki/Jizz_%28birding%29): those indefinable characteristics unique to a particular kind of thing.

This term can be appropriated to describe how seasoned individuals might distinguish [Rust](http://www.rust-lang.org) from [Go](http://golang.org), or [Ruby](http://www.ruby-lang.org) from [Elixir](http://elixir-lang.org) at a glance.

Some just stick out like sore thumbs:

Perl, with all of its short variable names with special characters, reads like [Q\*bert swearing](http://imgur.com/WyG2D).

Lisp, whose profusion of parentheses is best captured by [that old joke](http://discuss.fogcreek.com/joelonsoftware3/default.asp?cmd=show&ixPost=94232&ixReplies=38) about the Russians in the 1980's proving that they had stolen the source code of some SDI missile interceptor code by showing the last page:

~~~ lisp
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
~~~

So if we were to go code-watching for the elusive Objective-C species, what would we look for? That's right:

- Square brackets
- Ridiculously-long method names
- `@`'s

`@`, or "at" sign compiler directives, are as central to understanding Objective-C's gestalt as its ancestry and underlying mechanisms. It's the sugary glue that allows Objective-C to be such a powerful, expressive language, and yet still compile all the way down to C.

Its uses are varied and disparate, to the point that the only accurate way to describe what `@` means by itself is "shorthand for something to do with Objective-C". They cover a broad range in usefulness and obscurity, from staples like `@interface` and `@implementation` to ones you could go your whole career without running into, like `@defs` and `@compatibility_alias`.

But to anyone aspiring to be an NSHipster, intimate familiarity with `@` directives is tantamount to a music lover's ability to enumerate the entire Beatles catalog in chronological order (and most importantly, having unreasonably strong opinions about each of them).

## Interface & Implementation

`@interface` and `@implementation` are the first things you learn about when you start Objective-C:

- `@interface`...`@end`
- `@implementation`...`@end`

What you don't learn about until later on, are categories and class extensions.

Categories allow you to extend the behavior of existing classes by adding new class or instance methods. As a convention, categories are defined in their own `.{h,m}` files, like so:

#### MyObject+CategoryName.h

~~~{objective-c}
@interface MyObject (CategoryName)
  - (void)foo;
  - (BOOL)barWithBaz:(NSInteger)baz;
@end
~~~

#### MyObject+CategoryName.m

~~~{objective-c}
@implementation MyObject (CategoryName)
  - (void)foo {
    // ...
  }

  - (BOOL)barWithBaz:(NSInteger)baz {
    return YES;
  }
@end
~~~

Categories are particularly useful for convenience methods on standard framework classes (just don't go overboard with your utility functions).

> Pro Tip: Rather than littering your code with random, arbitrary color values, create an `NSColor` / `UIColor` color palette category that defines class methods like `+appNameDarkGrayColor`. You can then add a semantic layer on top of that by creating method aliases like `+appNameTextColor`, which returns `+appNameDarkGrayColor`.

Extensions look like categories, but omit the category name. These are typically declared before an `@implementation` to specify a private interface, and even override properties declared in the interface:

~~~{objective-c}
@interface MyObject ()
@property (readwrite, nonatomic, strong) NSString *name;
- (void)doSomething;
@end

@implementation MyObject
@synthesize name = _name;

// ...

@end
~~~

### Properties

Property directives are likewise concepts learned early on:

- `@property`
- `@synthesize`
- `@dynamic`

One interesting note with properties is that as of Xcode 4.4, it is no longer necessary to explicitly synthesize properties. Properties declared in an `@interface` are automatically synthesized (with leading underscore ivar name, i.e. `@synthesize propertyName = _propertyName`) in the implementation.

### Forward Class Declarations

Occasionally, `@interface` declarations will reference an external class in a property or as a parameter type. Rather than adding `#import` statements for each class, it's good practice to use forward class declarations in the header, and import them in the implementation.

- `@class`

Shorter compile times, less chance of cyclical references; you should definitely get in the habit of doing this if you aren't already.

### Instance Variable Visibility

It's a matter of general convention that classes provide state and mutating interfaces through properties and methods, rather than directly exposing ivars.

Although ARC makes working with ivars much safer by taking care of memory management, the aforementioned automatic property synthesis removes the one place where ivars would otherwise be declared.

Nonetheless, in cases where ivars _are_ directly manipulated, there are the following visibility directives:

- `@public`: instance variable can be read and written to directly, using the notation `person->age = 32"`
- `@package`: instance variable is public, except outside of the framework in which it is specified (64-bit architectures only)
- `@protected`: instance variable is only accessible to its class and derived classes
- `@private`: instance variable is only accessible to its class

~~~{objective-c}
@interface Person : NSObject {
  @public
  NSString *name;
  int age;

  @private
  int salary;
}
~~~

## Protocols

There's a distinct point early in an Objective-C programmer's evolution, when she realizes that she can define her own protocols.

The beauty of protocols is that they allow programmers to design contracts that can be adopted outside of a class hierarchy. It's the egalitarian mantra at the heart of the American Dream: that it doesn't matter who you are, or where you come from: anyone can achieve anything if they work hard enough.

...or at least that's idea, right?

- `@protocol`...`@end`: Defines a set of methods to be implemented by any class  conforming to the protocol, as if they were added to the interface of that class.

Architectural stability and expressiveness without the burden of coupling--protocols are awesome.

### Requirement Options

You can further tailor a protocol by specifying methods as required or optional. Optional methods are stubbed in the interface, so as to be auto-completed in Xcode, but do not generate a warning if the method is not implemented. Protocol methods are required by default.

The syntax for `@required` and `@optional` follows that of the visibility macros:

~~~{objective-c}
@protocol CustomControlDelegate
  - (void)control:(CustomControl *)control didSucceedWithResult:(id)result;
@optional
  - (void)control:(CustomControl *)control didFailWithError:(NSError *)error;
@end
~~~

## Exception Handling

Objective-C communicates unexpected state primarily through `NSError`. Whereas other languages would use exception handling for this, Objective-C relegates exceptions to truly exceptional behavior, including programmer error.

`@` directives are used for the traditional convention of `try/catch/finally` blocks:

~~~{objective-c}
@try{
  // attempt to execute the following statements
  [self getValue:&value error:&error];

  // if an exception is raised, or explicitly thrown...
  if (error) {
    @throw exception;
  }
} @catch(NSException *e) {
  // ...handle the exception here
}  @finally {
  // always execute this at the end of either the @try or @catch block
  [self cleanup];
}
~~~

## Literals

Literals are shorthand notation for specifying fixed values. Literals are more
-or-less directly correlated with programmer happiness. By this measure, Objective-C has long been a language of programmer misery.

### Object Literals

Until recently, Objective-C only had literals for `NSString`. But with the release of the [Apple LLVM 4.0 compiler](http://clang.llvm.org/docs/ObjectiveCLiterals.html), literals for `NSNumber`, `NSArray` and `NSDictionary` were added, with much rejoicing.

- `@""`: Returns an `NSString` object initialized with the Unicode content inside the quotation marks.
- `@42`, `@3.14`, `@YES`, `@'Z'`: Returns an `NSNumber` object initialized with pertinent class constructor, such that `@42` → `[NSNumber numberWithInteger:42]`, or `@YES` → `[NSNumber numberWithBool:YES]`. Supports the use of suffixes to further specify type, like `@42U` → `[NSNumber numberWithUnsignedInt:42U]`.
- `@[]`: Returns an `NSArray` object initialized with the comma-delimited list of objects as its contents. It uses +arrayWithObjects:count: class constructor method, which is a more precise alternative to the more familiar `+arrayWithObjects:`. For example, `@[@"A", @NO, @2.718]` → `id objects[] = {@"A", @NO, @2.718}; [NSArray arrayWithObjects:objects count:3]`.
- `@{}`: Returns an `NSDictionary` object initialized with the specified key-value pairs as its contents, in the format: `@{@"someKey" : @"theValue"}`.
- `@()`: Dynamically evaluates the boxed expression and returns the appropriate object literal based on its value (i.e. `NSString` for `const char*`, `NSNumber` for `int`, etc.). This is also the designated way to use number literals with `enum` values.

### Objective-C Literals

Selectors and protocols can be passed as method parameters. `@selector()` and `@protocol()` serve as pseudo-literal directives that return a pointer to a particular selector (`SEL`) or protocol (`Protocol *`).

- `@selector()`: Returns an `SEL` pointer to a selector with the specified name. Used in methods like `-performSelector:withObject:`.
- `@protocol()`: Returns a `Protocol *` pointer to the protocol with the specified name. Used in methods like `-conformsToProtocol:`.

### C Literals

Literals can also work the other way around, transforming Objective-C objects into C values. These directives in particular allow us to peek underneath the Objective-C veil, to begin to understand what's really going on.

Did you know that all Objective-C classes and objects are just glorified `struct`s? Or that the entire identity of an object hinges on a single `isa` field in that `struct`?

For most of us, at least most of the time, coming into this knowledge is but an academic exercise. But for anyone venturing into low-level optimizations, this is simply the jumping-off point.

- `@encode()`: Returns the [type encoding](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html) of a type. This type value can be used as the first argument encode in `NSCoder -encodeValueOfObjCType:at:`.
- `@defs()`: Returns the layout of an Objective-C class. For example, to declare a struct with the same fields as an `NSObject`, you would simply do:

~~~{objective-c}
struct {
  @defs(NSObject)
}
~~~

> Ed. As pointed out by readers [@secboffin](http://twitter.com/secboffin) & [@ameaijou](http://twitter.com/ameaijou), `@defs` is unavailable in the modern Objective-C runtime.

## Optimizations

There are some `@` compiler directives specifically purposed for providing shortcuts for common optimizations.

- `@autoreleasepool{}`: If your code contains a tight loop that creates lots of temporary objects, you can use the `@autoreleasepool` directive to optimize for these short-lived, locally-scoped objects by being more aggressive about how they're deallocated. `@autoreleasepool` replaces and improves upon the old `NSAutoreleasePool`, which is significantly slower, and unavailable with ARC.
- `@synchronized(){}`: This directive offers a convenient way to guarantee the safe execution of a particular block within a specified context (usually `self`). Locking in this way is expensive, however, so for classes aiming for a particular level of thread safety, a dedicated `NSLock` property or the use of low-level locking functions like `OSAtomicCompareAndSwap32(3)` are recommended.

## Compatibility

In case all of the previous directives were old hat for you, there's a strong likelihood that you didn't know about this one:

- `@compatibility_alias`: Allows existing classes to be aliased by a different name.

For example [PSTCollectionView](https://github.com/steipete/PSTCollectionView) uses `@compatibility_alias` to significantly improve the experience of using the backwards-compatible, drop-in replacement for [UICollectionView](http://nshipster.com/uicollectionview/):

~~~{objective-c}
// Allows code to just use UICollectionView as if it would be available on iOS SDK 5.
// http://developer.apple.    com/legacy/mac/library/#documentation/DeveloperTools/gcc-3.   3/gcc/compatibility_005falias.html
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@compatibility_alias UICollectionViewController PSTCollectionViewController;
@compatibility_alias UICollectionView PSTCollectionView;
@compatibility_alias UICollectionReusableView PSTCollectionReusableView;
@compatibility_alias UICollectionViewCell PSTCollectionViewCell;
@compatibility_alias UICollectionViewLayout PSTCollectionViewLayout;
@compatibility_alias UICollectionViewFlowLayout PSTCollectionViewFlowLayout;
@compatibility_alias UICollectionViewLayoutAttributes     PSTCollectionViewLayoutAttributes;
@protocol UICollectionViewDataSource <PSTCollectionViewDataSource> @end
@protocol UICollectionViewDelegate <PSTCollectionViewDelegate> @end
#endif
~~~

Using this clever combination of macros, a developer can develop with `UICollectionView` by including `PSTCollectionView`--without worrying about the deployment target of the final project. As a drop-in replacement, the same code works more-or-less identically on iOS 6 as it does on iOS 4.3.

---

So to review:

**Interfaces & Implementation**

- `@interface`...`@end`
- `@implementation`...`@end`
- `@class`

**Instance Variable Visibility**

- `@public`
- `@package`
- `@protected`
- `@private`

**Properties**

- `@property`
- `@synthesize`
- `@dynamic`

**Protocols**

- `@protocol`
- `@required`
- `@optional`

**Exception Handling**

- `@try`
- `@catch`
- `@finally`
- `@throw`

**Object Literals**

- `@""`
- `@42`, `@3.14`, `@YES`, `@'Z'`
- `@[]`
- `@{}`
- `@()`

**Objective-C Literals**

- `@selector()`
- `@protocol()`

**C Literals**

- `@encode()`
- `@defs()`

**Optimizations**

- `@autoreleasepool{}`
- `@synchronized{}`

**Compatibility**

- `@compatibility_alias`

Thus concludes this exhaustive rundown of the many faces of `@`. It's a versatile, power-packed character, that embodies the underlying design and mechanisms of the language.

> This should be a complete list, but there's always a chance that some new or long-forgotten ones slipped between the cracks. If you know of any `@` directives that were left out, be sure to let [@NSHipster](https://twitter.com/nshipster) know.
