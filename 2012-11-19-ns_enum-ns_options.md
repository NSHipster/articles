---
title: "NS_ENUM & NS_OPTIONS"
author: Mattt Thompson
category: Cocoa
tags: nshipster, popular
excerpt: "A skilled Objective-C developer is able to gracefully switch between Objective and Procedural paradigms, and use each to their own advantage."
status:
    swift: n/a
---

When everything is an object, nothing is.

So, there are a few ways you could parse that, but for the purposes of this article, this is all to say: sometimes it's nice to be able to drop down to the C layer of things.

Yes--that non-objective part of our favorite Smalltalk-inspired hybrid language, C can be a great asset. It's fast, it's battle-tested, it's the very foundation of modern computing. But more than that, C is the escape hatch for when the Object-Oriented paradigm cracks under its own cognitive weight.

Static functions are nicer than shoe-horned class methods.
Enums are nicer than string constants.
Bitmasks are nicer than arrays of string constants.
Preprocessor directives are nicer than runtime hacks.

A skilled Objective-C developer is able to gracefully switch between Objective and Procedural paradigms, and use each to their own advantage.

And on that note, this week's topic has to do with two simple-but-handy macros: `NS_ENUM` and `NS_OPTIONS`.

---

Introduced in Foundation with iOS 6 / OS X Mountain Lion, the `NS_ENUM` and `NS_OPTIONS` macros are the new, preferred way to declare `enum` types.

> If you'd like to use either macro when targeting a previous version of iOS or OS X, you can simply inline like so:

~~~{objective-c}
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif
~~~

`enum`, or enumerated value types, are the C way to define constants for fixed values, like days of the week, or available styles of table view cells. In an `enum` declaration, constants without explicit values will automatically be assigned values sequentially, starting from `0`.

There are several legal ways that `enum`s can be defined. What's confusing is that there are subtle functional differences between each approach, and without knowing any better, someone is just as likely to use them interchangeably.

For instance:

~~~{objective-c}
enum {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
};
~~~

...declares integer values, but no type.

Whereas:

~~~{objective-c}
typedef enum {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
} UITableViewCellStyle;
~~~

...defines the `UITableViewCellStyle` type, suitable for specifying the type of method parameters.

However, Apple had previously defined all of their `enum` types as:

~~~{objective-c}
typedef enum {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
};

typedef NSInteger UITableViewCellStyle;
~~~

...which ensures a fixed size for `UITableViewCellStyle`, but does nothing to hint the relation between the aforementioned `enum` and the new type to the compiler.

Thankfully, Apple has decided on "One Macro To Rule Them All" with `NS_ENUM`.

## `NS_ENUM`

Now, `UITableViewCellStyle` is declared with:

~~~{objective-c}
typedef NS_ENUM(NSInteger, UITableViewCellStyle) {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
};
~~~

The first argument for `NS_ENUM` is the type used to store the new type. In a 64-bit environment, `UITableViewCellStyle` will be 8 bytes long--same as `NSInteger`. Make sure that the specified size can fit all of the defined values, or else an error will be generated. The second argument is the name of the new type (as you probably guessed). Inside the block, the values are defined as usual.

This approach combines the best of all of the aforementioned approaches, and even provides hints to the compiler for type-checking and `switch` statement completeness.

## `NS_OPTIONS`

`enum` can also be used to define a [bitmask][1]. Using a convenient property of binary math, a single integer value can encode a combination of values all at once using the bitwise `OR` (`|`), and decoded with bitwise `AND` (`&`). Each subsequent value, rather than automatically being incremented by 1 from 0, are manually given a value with a bit offset: `1 << 0`, `1 << 1`, `1 << 2`, and so on. If you imagine the binary representation of a number, like `10110` for 22, each bit can be though to represent a single boolean. In UIKit, for example, `UIViewAutoresizing` is a bitmask that can represent any combination of flexible top, bottom, left, and right margins, or width and height.

Rather than `NS_ENUM`, bitmasks should now use the `NS_OPTIONS` macro.

The syntax is exactly the same as `NS_ENUM`, but this macro alerts the compiler to how values can be combined with bitmask `|`. Again, you must be careful that all of the enumerated values fit within the specified type.

---

`NS_ENUM` and `NS_OPTIONS` are handy additions to the Objective-C development experience, and reaffirm the healthy dialectic between its objective and procedural nature. Keep this in mind as you move forward in your own journey to understand the logical tensions that underpin everything around us.

[1]: http://en.wikipedia.org/wiki/Mask_(computing)
