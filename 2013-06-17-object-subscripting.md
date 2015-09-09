---
title: Object Subscripting
author: Mattt Thompson
category: Objective-C
excerpt: "Xcode 4.4 quietly introduced a syntactic revolution to Objective-C. Like all revolutions, however, its origins and agitators require some effort to trace."
status:
    swift: n/a
---

Xcode 4.4 quietly introduced a syntactic revolution to Objective-C. Like all revolutions, however, its origins and agitators require some effort to trace: Xcode 4.4 shipped with Apple LLVM Compiler 4.0, which incorporated changes effective in the Clang front-end as of version 3.1.

> For the uninitiated, [Clang](http://clang.llvm.org/index.html) is the open source C language family front end to the [LLVM](http://www.llvm.org) compiler. Clang is responsible for all of the killer language features in Objective-C going back a few years, such as "Build & Analyze", ARC, blocks, and a nearly 3× performance boost when compiling over GCC.

Clang 3.1 added three features to Objective-C whose aesthetic & cosmetic impact is comparable to the changes brought about in Objective-C 2.0: [`NSNumber` Literals][num], [Collection Literals][col], and [Object Subscripting][sub].

[num]: http://clang.llvm.org/docs/ObjectiveCLiterals.html#nsnumber-literals
[col]: http://clang.llvm.org/docs/ObjectiveCLiterals.html#container-literals
[sub]: http://clang.llvm.org/docs/ObjectiveCLiterals.html#object-subscripting

In a single Xcode release, Objective-C went from this:

~~~{objective-c}
NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:42] forKey:@"foo"];
id value = [dictionary objectForKey:@"foo"];
~~~

...to this:

~~~{objective-c}
NSDictionary *dictionary = @{@"foo": @42};
id value = dictionary[@"foo"];
~~~

Concision is the essence of clarity.

Shorter code means typing less, but it also means understanding more. Even a sprinkle of syntactic sugar can be enough to transform a language, and unlock new design patterns.

Collection literals become preferable to property lists for configuration.<br/>
Single-element array parameters become more acceptable.<br/>
APIs requiring boxed numeric values become more palatable.<br/>

However, what remains relatively under-utilized even now—a year after the these language features were added—is object subscripting. Perhaps after reading the rest of this article, though, you'll help to change this.

---

Elements in a C array are laid out contiguously in memory, and are referenced by the address of the first element. To get the value at a particular index, one would offset this address by the size of an array element, multiplied by the desired index. This pointer arithmetic is provided by the `[]` operator.

Over time, scripting languages began to take greater liberties with this familiar convention, expanding its role to get & set values in arrays, as well as hashes and objects.

With Clang 3.1, everything has come full-circle: what began as a C operator and co-opted by scripting languages, has now been rolled back into Objective-C. And like the aforementioned scripting languages of yore, the `[]` subscripting operator in Objective-C has been similarly overloaded to handle both integer-indexed and object-keyed accessors.

~~~{objective-c}
dictionary[@"foo"] = @42;
array[0] = @"bar"
~~~

> If Objective-C is a superset of C, how can Object Subscripting overload the `[]` C operator? The modern Objective-C runtime prohibits pointer arithmetic on objects, making this semantic pivot possible.

Where this really becomes interesting is when you extend your own classes with subscripting support:

### Custom Indexed Subscripting

To add custom-indexed subscripting support to your class, simply declare and implement the following methods:

~~~{objective-c}
- (id)objectAtIndexedSubscript:(*IndexType*)idx;
- (void)setObject:(id)obj atIndexedSubscript:(*IndexType*)idx;
~~~

`*IndexType*` can be any integral type, such as `char`, `int`, or `NSUInteger`, as used by `NSArray`.

### Custom Keyed Subscripting

Similarly, custom-keyed subscripting can be added to your class by declaring and implementing these methods:

~~~{objective-c}
- (id)objectForKeyedSubscript:(*KeyType*)key;
- (void)setObject:(id)obj forKeyedSubscript:(*KeyType*)key;
~~~

`*KeyType*` can be any Objective-C object pointer type.

> In fact, for non-general-purpose collections, indexed and keyed subscripting can get and set *any* Objective-C object pointer type, not just `id`. 

## Custom Subscripting as DSL

The whole point in describing all of this is to encourage unconventional thinking about this whole language feature. At the moment, a majority of custom subscripting in classes is used as a convenience accessor to a private collection class. But there's nothing to stop you from, for instance, doing this:

~~~{objective-c}
routes[@"GET /users/:id"] = ^(NSNumber *userID){
  // ...
}
~~~

...or this:

~~~{objective-c}
id piece = chessBoard[@"E1"];
~~~

...or this:

~~~{objective-c}
NSArray *results = managedObjectContext[@"Product WHERE stock > 20"];
~~~

Because of how flexible and concise subscripting is, it is extremely well-purposed for creating [DSL](http://en.wikipedia.org/wiki/Domain-specific_language)s. When defining custom subscripting methods on your own class, there are no restrictions on how they are implemented. You can use this syntax to provide a shorthand for defining application routes, search queries, compound property accessors, or plain-old KVO.

---

This is, of course, dangerous thinking. Subscripting isn't your new bicycle. It isn't a giant hammer. Hell, _it isn't even a giant screwdriver!_ If there is one thing Object Subscripting DSLs are, it's trouble. Here be dragons.

That said, it does open up some interesting opportunities to bend syntactic conventions to useful ends.
