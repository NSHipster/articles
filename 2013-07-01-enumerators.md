---
title: "NSFastEnumeration / NSEnumerator"
author: Mattt Thompson
category: Cocoa
excerpt: "Enumeration is where computation gets interesting. It's one thing to encode logic that's executed once, but applying it across a collection—that's what makes programming so powerful."
status:
    swift: n/a
---

Enumeration is where computation gets interesting. It's one thing to encode logic that's executed once, but applying it across a collection—that's what makes programming so powerful.

Each programming paradigm has its own way to iterate over a collection:

- **Procedural** increments a pointer within a loop
- **Object Oriented** applies a function or block to each object in a collection
- **Functional** works through a data structure recursively

Objective-C, to echo one of the central themes of this blog, plays a fascinating role as a bridge between the Procedural traditions of C and the Object Oriented model pioneered in Smalltalk. In many ways, enumeration is where the proverbial rubber hits the road.

This article will cover all of the different ways collections are enumerated in Objective-C & Cocoa. How do I love thee? Let me count the ways.

---

## C Loops (`for/while`)

`for` and `while` loops are the "classic" method of iterating over a collection. Anyone who's taken Computer Science 101 has written code like this before:

~~~{objective-c}
for (NSUInteger i = 0; i < [array count]; i++) {
  id object = array[i];
  NSLog(@"%@", object)
}
~~~

But as anyone who has used C-style loops knows, this method is prone to [off-by-one errors](http://en.wikipedia.org/wiki/Off-by-one_error)—particularly when used in a non-standard way.

Fortunately, Smalltalk significantly improved this state of affairs with an idea called [list comprehensions](http://en.wikipedia.org/wiki/List_comprehension), which are commonly known today as `for/in` loops.

## List Comprehension (`for/in`)

By using a higher level of abstraction, declaring the intention of iterating through all elements of a collection, not only are we less prone to error, but there's a lot less to type:

~~~{objective-c}
for (id object in array) {
    NSLog(@"%@", object);
}
~~~

In Cocoa, comprehensions are available to any class that implements the `NSFastEnumeration` protocol, including `NSArray`, `NSSet`, and `NSDictionary`.

### `<NSFastEnumeration>`

`NSFastEnumeration` contains a single method:

~~~{objective-c}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
~~~

> - `state`: Context information that is used in the enumeration to, in addition to other possibilities, ensure that the collection has not been mutated.
> - `stackbuf`: A C array of objects over which the sender is to iterate.
> - `len`: The maximum number of objects to return in stackbuf.

One single, _deceptively complicated_ method. There's that `stackbuf` out pointer parameter, and a `state` parameter of type `NSFastEnumerationState *`. Let's take a closer look at that...

### `NSFastEnumerationState`

~~~{objective-c}
typedef struct {
      unsigned long state;
      id *itemsPtr;
      unsigned long *mutationsPtr;
      unsigned long extra[5];
} NSFastEnumerationState;
~~~

> - `state`: Arbitrary state information used by the iterator. Typically this is set to 0 at the beginning of the iteration.
> - `itemsPtr`: A C array of objects.
> - `mutationsPtr`: Arbitrary state information used to detect whether the collection has been mutated.
> - `extra`: A C array that you can use to hold returned values.

Under every elegant abstraction is an underlying implementation deserving to be hidden from the eyes of God. `itemsPtr`? `mutationsPtr`? `extra`‽ Seriously, what gives?

> For the curious, [Mike Ash has a fantastic blog post](http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html) where he dives into the internals, providing several reference implementations of `NSFastEnumeration`.

What you should know about `NSFastEnumeration` is that it is _fast_. At least as fast if not significantly faster than rolling your own `for` loop, in fact. The secret behind its speed is how `-countByEnumeratingWithState:objects:count:` buffers collection members, loading them in as necessary. Unlike a single-threaded `for` loop implementation, objects can be loaded concurrently, making better use of available system resources.

Apple recommends that you use `NSFastEnumeration` `for/in`-style enumeration for your collections wherever possible and appropriate. And to be honest, for how easy it is to use and how well it performs, that's a pretty easy sell. Seriously, use it.

## `NSEnumerator`

But of course, before `NSFastEnumeration` (circa OS X Leopard / iOS 2.0), there was the venerable `NSEnumerator`.

For the uninitiated, `NSEnumerator` is an abstract class that implements two methods:

~~~{objective-c}
- (id)nextObject
- (NSArray *)allObjects
~~~

`nextObject` returns the next object in the collection, or `nil` if unavailable. `allObjects` returns all of the remaining objects, if any. `NSEnumerator`s can only go forward, and only in single increments.

To enumerate through all elements in a collection, one would use `NSEnumerator` thusly:

~~~{objective-c}
id object = nil;
NSEnumerator *enumerator = ...;
while ((object = [enumerator nextObject])) {
    NSLog(@"%@", object);
}
~~~

...or because `NSEnumerator` itself conforms to `<NSFastEnumeration>` in an attempt to stay hip to the way kids do things these days:

~~~{objective-c}
for (id object in enumerator) {
    NSLog(@"%@", object);
}
~~~

If you're looking for a convenient way to add fast enumeration to your own non-collection-class-backed objects, `NSEnumerator` is likely a much more palatable option than getting your hands messy with `NSFastEnumeration`'s implementation details.

Some quick points of interest about `NSEnumeration`:

- Reverse an array in one line of code with (and excuse the excessive dot syntax) `array.reverseObjectEnumerator.allObjects`.
- Add LINQ-style operations with [`NSEnumeratorLinq`](https://github.com/k06a/NSEnumeratorLinq), a third-party library using chained `NSEnumerator` subclasses.
- Shake things up with your collection classes in style with [`TTTRandomizedEnumerator`](https://github.com/mattt/TTTRandomizedEnumerator), another third-party library, which iterates through elements in a random order.

## Enumerate With Blocks

Finally, with the introduction of blocks in OS X Snow Leopard / iOS 4, came a new block-based way to enumerate collections:

~~~{objective-c}
[array enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
    NSLog(@"%@", object);
}];
~~~

Collection classes like `NSArray`, `NSSet`, `NSDictionary`, and `NSIndexSet` include a similar set of block enumeration methods.

One of the advantages of this approach is that the current object index (`idx`) is passed along with the object itself. The `BOOL` pointer allows for early returns, equivalent to a `break` statement in a regular C loop.

Unless you actually need the numerical index while iterating, it's almost always faster to use a `for/in` `NSFastEnumeration` loop instead.

One last thing to be aware of are the expanded method variants with an `options` parameter:

~~~{objective-c}
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts
                         usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
~~~

### `NSEnumerationOptions`

~~~{objective-c}
enum {
   NSEnumerationConcurrent = (1UL << 0),
   NSEnumerationReverse = (1UL << 1),
};
typedef NSUInteger NSEnumerationOptions;
~~~

> - `NSEnumerationConcurrent`: Specifies that the Block enumeration should be concurrent. The order of invocation is nondeterministic and undefined; this flag is a hint and may be ignored by the implementation under some circumstances; the code of the Block must be safe against concurrent invocation.
> - `NSEnumerationReverse`: Specifies that the enumeration should be performed in reverse. This option is available for `NSArray` and `NSIndexSet` classes; its behavior is undefined for `NSDictionary` and `NSSet` classes, or when combined with the `NSEnumerationConcurrent` flag.

Again, fast enumeration is almost certain to be much faster than block enumeration, but these options may be useful if you're resigned to using blocks.

---

So there you have all of the conventional forms of enumeration in Objective-C and Cocoa.

What's especially interesting is that in looking at these approaches, we learn a lesson about the power of abstraction. Higher levels of abstraction are not just easier to write and comprehend, but can often be much faster than doing it the "hard way".

High-level commands that declare intention, like "iterate through all of the elements of this collection" lend themselves to high-level compiler optimization in a way that just isn't possible with pointer arithmetic in a loop. Context is a powerful thing, and designing APIs and functionality accordingly ultimately fulfill that great promise of abstraction: to solve larger problems more easily.
