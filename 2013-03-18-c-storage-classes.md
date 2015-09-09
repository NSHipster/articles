---
title: C Storage Classes
author: Mattt Thompson
category: Objective-C
tags: nshipster
excerpt: "In C, the scope and lifetime of a variable or function within a program is determined by its storage class. Understanding these storage classes allows us to decipher common incantations found throughout Objective-C"
status:
    swift: n/a
---

It's time, once again, to take a few steps back from the world of Objective-C, and look at some underlying C language features. Hold onto your fedoras, ladies & gents, as we dive into C storage classes in this week's edition of NSHipster.

---

In C, the _scope_ and _lifetime_ of a variable or function within a program is determined by its _storage class_. Each variable has a _lifetime_, or the context in which they store their value. Functions, along with variables, also exist within a particular _scope_, or visibility, which dictates which parts of a program know about and can access them.

There are 4 storage classes in C:

- `auto`
- `register`
- `static`
- `extern`

At least a few of these will look familiar to anyone who has done a cursory amount of Objective-C programming. Let's go into more detail with each one:

## `auto`

There's a good chance you've never seen this keyword in the wild. That's because `auto` is the default storage class, and therefore doesn't need to be explicitly used often.

Automatic variables have memory automatically allocated when a program enters a block, and released when the program leaves that block. Access to automatic variables is limited to only the block in which they are declared, as well as any nested blocks.

## `register`

Most Objective-C programmers probably aren't familiar with `register` either, as it's just not widely used in the `NS` world.

`register` behaves just like `auto`, except that instead of being allocated onto the stack, they are stored in a [register](http://en.wikipedia.org/wiki/Processor_register).

Registers offer faster access than RAM, but because of the complexities of memory management, putting variables in registers does not guarantee a faster program—in fact, it may very well end up slowing down execution by taking up space on the register unnecessarily. As it were, using `register` is actually just a _suggestion_ to the compiler to store the variable in the register; implementations may choose whether or not to honor this.

`register`'s lack of popularity in Objective-C is instructive: it's probably best not to bother with it, as it's much more likely to cause a headache than speed up your app in any noticeable way.

## `static`

Finally, one that everyone's sure to recognize: `static`.

As a keyword, `static` gets used in a lot of different, incompatible ways, so it can be confusing to figure out exactly what it means in every instance. When it comes to storage classes, `static` means one of two things.

1. A `static` variable inside a method or function retains its value between invocations.
2. A `static` variable declared globally can be called by any function or method, so long as those functions appear in the same file as the `static` variable. The same goes for `static` functions.

### Static Singletons

A common pattern in Objective-C is the `static` singleton, wherein a statically-declared variable is initialized and returned in either a function or class method. `dispatch once` is used to guarantee that the variable is initialized _exactly_ once in a thread-safe manner:

~~~{objective-c}
+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      _sharedInstance = [[self alloc] init];
  });

  return _sharedInstance;
}
~~~

The singleton pattern is useful for creating objects that are shared across the entire application, such as an HTTP client or a notification manager, or objects that may be expensive to create, such as formatters.

## `extern`

Whereas `static` makes functions and variables globally visible within a particular file, `extern` makes them visible globally to _all files_.

Global variables are not a great idea, generally speaking. Having no constraints on how or when state can be mutated is just asking for impossible-to-debug bugs. That said, there are two common and practical uses for `extern` in Objective-C.

### Global String Constants

Any time your application uses a string constant with a non-linguistic value in a public interface, it should declare it as an external string constant. This is especially true of keys in `userInfo` dictionaries, `NSNotification` names, and `NSError` domains.

The pattern is to declare an `extern` `NSString * const` in a public header, and define that `NSString * const` in the implementation:

#### AppDelegate.h

~~~{objective-c}
extern NSString * const kAppErrorDomain;
~~~

#### AppDelegate.m

~~~{objective-c}
NSString * const kAppErrorDomain = @"com.example.yourapp.error";
~~~

It doesn't particularly matter what the value of the string is, so long as it's unique. Using a string constant establishes a strict contract, that the constant variable is used instead of the string's literal value itself.

### Public Functions

Some APIs may wish to expose helper functions publicly. For auxiliary concerns and state-agnostic procedures, functions are a great way to encapsulate these behaviors—and if they're particularly useful, it may be worth making them available globally.

The pattern follows the same as in the previous example:

#### TransactionStateMachine.h

~~~{objective-c}
typedef NS_ENUM(NSUInteger, TransactionState) {
    TransactionOpened,
    TransactionPending,
    TransactionClosed,
};

extern NSString * NSStringFromTransactionState(TransactionState state);
~~~

#### TransactionStateMachine.m

~~~{objective-c}
NSString * NSStringFromTransactionState(TransactionState state) {
  switch (state) {
    case TransactionOpened:
      return @"Opened";
    case TransactionPending:
      return @"Pending";
    case TransactionClosed:
      return @"Closed";
    default:
      return nil;
  }
}
~~~

---

To understand anything is to make sense of its context. What we may see as obvious and self-evident, is all but unknown to someone without our frame of reference. Our inability to truly understand or appreciate the differences in perspective and information between ourselves and others is perhaps our most basic shortcoming.

That is why, in our constructed logical universe of 0's and 1's, we take such care to separate contexts, and structure our assumptions based on these explicit rules. C storage classes are essential to understanding how a program operates. Without them, we are left to develop as one might walk on egg shells. So take heed of these simple rules of engagement and go forth to code with confidence.
