---
title: ValueTransformer
author: Mattt
category: Cocoa
tags: nshipster
excerpt: >-
  `ValueTransformer` is perhaps the one that fared the worst
  in the shift from macOS to iOS.
  But you know what? It's ripe for a comeback. 
  With a little bit of re-tooling and some recontextualization, this blast from the past could be the next big thing in your application.
revisions:
  "2012-11-12": First Publication
  "2018-10-17": Updated for Swift 4.2
status:
  swift: 4.2
  reviewed: October 17, 2018
---

Of all the Foundation classes,
`ValueTransformer` is perhaps the one that fared the worst
in the shift from macOS to iOS.

Why? Here are two reasons:

First,
`ValueTransformer` was used primarily in AppKit with Cocoa bindings.
There, they could automatically transform values from one property to another,
like for negating a boolean or checking whether a value was `nil`,
without the need of intermediary glue code.
iOS, of course, doesn't have bindings.

The second reason has less to do with iOS than the Objective-C runtime itself.
With the introduction of blocks,
it got a whole lot easier to pass behavior between objects ---
significantly easier than, say `ValueTransformer` or `NSInvocation`.
So even if iOS were to get bindings tomorrow,
it's unclear whether `ValueTransformer`
would play a significant role this time around.

But you know what?
`ValueTransformer` might just be ripe for a comeback.
With a little bit of re-tooling and some recontextualization,
this blast from the past could be the next big thing in your application.

---

`ValueTransformer` is an abstract class that transforms one value into another.
A transformation specifies what kinds of input values can be handled
and whether it supports reversible transformations.

A typical implementation looks something like this:

```swift
class ClassNameTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return false
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let type = value as? AnyClass else { return nil }
        return NSStringFromClass(type)
    }
}
```

```objc
@interface ClassNameTransformer: NSValueTransformer {}
@end

#pragma mark -

@implementation ClassNameTransformer
+ (Class)transformedValueClass {
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    return (value == nil) ? nil : NSStringFromClass([value class]);
}
@end
```

`ValueTransformer` is rarely initialized directly.
Instead, it follows a pattern familiar to fans of
`NSPersistentStore` or `NSURLProtocol`,
where a class is registered and instances are created from a manager ---
except in this case, you register a named _instance_ to act as a singleton:

```swift
extension ClassNameTransformer {
    static let name = NSValueTransformerName(rawValue: "ClassNameTransformer")
}

// Set the value transformer
ValueTransformer.setValueTransformer(ClassNameTransformer(),
                                     forName: ClassNameTransformer.name)

// Get the value transformer
let valueTransformer = ValueTransformer(forName: ClassNameTransformer.name)
```

```objc
NSValueTransformerName const ClassNameTransformerName = @"ClassNameTransformer";

// Set the value transformer
[NSValueTransformer setValueTransformer:[[ClassNameTransformer alloc] init] forName:ClassNameTransformerName];

// Get the value transformer
NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:ClassNameTransformerName];
```

A common pattern is to register the singleton instance
in the `+initialize` method of the value transformer subclass
so it can be used without additional setup.

Now at this point you probably realize `ValueTransformer`'s fatal flaw:
it's super annoying to set up!
Create a class,
implement a handful of simple methods,
define a constant,
_and_ register it in an `+initialize` method? No thanks.

In this age of blocks,
we want --- nay, _demand_ ---
a way to declare functionality in one (albeit gigantic) line of code.

Nothing [a little metaprogramming](https://github.com/mattt/TransformerKit/blob/master/TransformerKit/NSValueTransformer%2BTransformerKit.m#L36) can't fix.
Behold:

```swift
let TKCapitalizedStringTransformerName =
    NSValueTransformerName(rawValue: "TKCapitalizedStringTransformerName")

ValueTransformer.registerValueTransformerWithName(TKCapitalizedStringTransformerName,
    transformedValueClass:NSString.self) { object in
        guard let string = object as? String else { return nil }
        return string.capitalized
}
```

```objc
NSValueTransformerName const TKCapitalizedStringTransformerName = @"TKCapitalizedStringTransformerName";

[NSValueTransformer registerValueTransformerWithName:TKCapitalizedStringTransformerName
           transformedValueClass:[NSString class]
returningTransformedValueWithBlock:^id(id value) {
  return [value capitalizedString];
}];
```

{% info %}
Not to break the 4th wall or anything,
but in the process of writing this article,
I was compelled to see how much I could improve
the experience of using `ValueTransformer`.
What I came up with was
[TransformerKit](https://github.com/mattt/TransformerKit).

At the core of the library is some Obj-C runtime hackery
in an `ValueTransformer` category.
Also included are some helpful examples,
like string case transformers
(i.e. `CamelCase`, `llamaCase`, `snake_case`, and `train-case`).
{% endinfo %}

---

Now with a fresh new look,
we can start to get a better understanding of
how we might take advantage of `ValueTransformer`:

## Making Business Logic More Functional

`ValueTransformer` objects are a great way to represent
an ordered chain of fixed transformations.
For instance, an app interfacing with a legacy system
might transform user input through a succession of string transformations
(trim whitespace, remove diacritics, and then capitalize letters)
before sending it off to the mainframe.

## Thinking Forwards and Backwards

Unlike blocks, value transformers have the concept of reversibility,
which enables some interesting use cases.

Say you were wanted to map keys from a REST API representation into a model.
You could create a reversible transformation that converted `snake_case` to `llamaCase` when initializing,
and `llamaCase` to `snake_case` when serializing back to the server.

## Configuring Functionality

Another advantage over blocks is that
`ValueTransformer` subclasses can expose new properties
that can be used to configure behavior in a particular way.
Access to properties also provides a clean way to cache or memoize results
and do any necessary book-keeping along the way.

## Transforming Your Core Data Stack

Lest we forget,
`ValueTransformer` can be used alongside Core Data
to encode and decode compound data types from blob fields.
It seems to have fallen out of fashion over the years,
but serializing simple collections in this way
can be a winning strategy for difficult-to-model data.
(Just don't use this approach to serialize images or other binary data;
use external storage instead)

---

`ValueTransformer`,
far from a vestige of AppKit,
remains Foundation's purest connection to functional programming:
input goes in, output comes out.

While it's true that Objective-C blocks
and all of the advanced language features in Swift
are superior examples of the functional programming paradigm.
`ValueTransformer` has a special place in Cocoa's history and Xcode's tooling.
For that reason, object orientation is transformed
from an embarrassing liability to its greatest asset.

And though it hasn't aged very well on its own,
a little modernization restores `ValueTransformer`
to that highest esteem of NSHipsterdom:
a solution that we didn't know we needed
but was there all along.
