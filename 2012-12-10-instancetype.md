---
title: instancetype
author: Mattt Thompson
category: Objective-C
excerpt: "Objective-C is a rapidly evolving language, in a way that you just don't see in established programming languages. Developments range from the mundane to paradigm-changing, but telling the difference takes practice. Because we're talking about low-level language features, it's difficult to understand what implications they may have higher up with API design."
status:
    swift: n/a
---

Want to know what's coming next in Objective-C? [Keep your ear to the ground](http://clang.llvm.org/docs/LanguageExtensions.html).

Objective-C is a rapidly evolving language, in a way that you just don't see in established programming languages. ARC, object literals, subscripting, blocks: in the span of just three years, so much of how we program in Objective-C has been changed (for the better).

All of this innovation is a result of Apple's philosophy of vertical integration. Just as Apple's investment in designing [its own chipsets](http://en.wikipedia.org/wiki/Apple_A4) gave them leverage to compete aggressively with their mobile hardware, so too has their investment in [LLVM](http://llvm.org) allowed their software to keep pace.

Clang developments range from the mundane to paradigm-changing, but telling the difference takes practice. Because we're talking about low-level language features, it's difficult to understand what implications they may have higher up with API design.

One such example is `instancetype`, the subject of this week's article.

---

In Objective-C, conventions aren't just a matter of coding best-practices, they are implicit instructions to the compiler.

For example, `alloc` and `init` both have return types of `id`, yet in Xcode, the compiler makes all of the correct type checks. How is this possible?

In Cocoa, there is a convention that methods with names like `alloc`, or `init` always return objects that are an instance of the receiver class. These methods are said to have a **related result type**.

Class constructor methods, although they similarly return `id`, don't get the same type-checking benefit, because they don't follow that naming convention.

You can try this out for yourself:

~~~{objective-c}
[[[NSArray alloc] init] mediaPlaybackAllowsAirPlay]; // ❗ "No visible @interface for `NSArray` declares the selector `mediaPlaybackAllowsAirPlay`"

[[NSArray array] mediaPlaybackAllowsAirPlay]; // (No error)
~~~

Because `alloc` and `init` follow the naming convention for being a related result type, the correct type check against `NSArray` is performed. However, the equivalent class constructor `array` does not follow that convention, and is interpreted as `id`.

`id` is useful for opting-out of type safety, but losing it when you _do_ want it sucks.

The alternative, of explicitly declaring the return type (`(NSArray *)` in the previous example) is a slight improvement, but is annoying to write, and doesn't play nicely with subclasses.

This is where the compiler steps in to resolve this timeless edge case to the Objective-C type system:

`instancetype` is a contextual keyword that can be used as a result type to signal that a method returns a related result type. For example:

~~~{objective-c}
@interface Person
+ (instancetype)personWithName:(NSString *)name;
@end
~~~

> `instancetype`, unlike `id`, can only be used as the result type in a method declaration.

With `instancetype`, the compiler will correctly infer that the result of `+personWithName:` is an instance of a `Person`.

Look for class constructors in Foundation to start using `instancetype` in the near future. New APIs, such as [UICollectionViewLayoutAttributes](http://developer.apple.com/library/ios/#documentation/uikit/reference/UICollectionViewLayoutAttributes_class/Reference/Reference.html) are using `instancetype` already.

## Further Implications

Language features are particularly interesting because, again, it's often unclear of what impact they'll have on higher-level aspects of software design.

While `instancetype` may seem to be a rather mundane, albeit welcome addition to the compiler, it can be used to some rather clever ends.

[Jonathan Sterling](https://twitter.com/jonsterling) wrote [this quite interesting article](http://www.jonmsterling.com/posts/2012-02-05-typed-collections-with-self-types-in-objective-c.html), detailing how `instancetype` could be used to encode statically-typed collections, without [generics](http://en.wikipedia.org/wiki/Generic_programming):

~~~{objective-c}
NSURL <MapCollection> *sites = (id)[NSURL mapCollection];
[sites put:[NSURL URLWithString:@"http://www.jonmsterling.com/"]
        at:@"jon"];
[sites put:[NSURL URLWithString:@"http://www.nshipster.com/"]
        at:@"nshipster"];

NSURL *jonsSite = [sites at:@"jon"]; // => http://www.jonmsterling.com/
~~~

Statically-typed collections would make APIs more expressive--no longer would a developer be unsure about what kinds of objects are allowed in a collection parameter.

Whether or not this becomes an accepted convention in Objective-C, it's fascinating to how a low-level feature like `instancetype` can be used to change shape of the language (in this case, making it look more like [C#][1]).

---

`instancetype` is just one of the many language extensions to Objective-C, with more being added with each new release.

Know it, love it.

And take it as an example of how paying attention to the low-level details can give you insights into powerful new ways to transform Objective-C.

[1]: http://en.wikipedia.org/wiki/C_Sharp_(programming_language)
