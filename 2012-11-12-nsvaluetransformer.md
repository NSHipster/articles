---
title: NSValueTransformer
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Of all the Foundation classes, NSValueTransformer is perhaps the one that fared the worst in the shift from OS X to iOS. But you know what? It's ripe for a comeback. With a little bit of re-tooling and some recontextualization, this blast from the past could be the next big thing in your application."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Of all the Foundation classes, `NSValueTransformer` is perhaps the one that fared the worst in the shift from OS X to iOS.

Why? Well, there are two reasons:

The first and most obvious reason is that `NSValueTransformer` was mainly used in AppKit with Cocoa bindings. Here, they could automatically transform values from one property to another without the need of intermediary glue code, like for negating a boolean, or checking whether a value was `nil`. iOS, of course, doesn't have bindings.

The second reason has less to do with iOS than the Objective-C runtime itself. With the introduction of blocks, it got a whole lot easier to pass behavior between objects--significantly easier than, say `NSValueTransformer` or `NSInvocation`. So even if iOS were to get bindings tomorrow, it's uncertain as to whether `NSValueTransformer` would play as significant a role this time around.

But you know what? `NSValueTransformer` is ripe for a comeback. With a little bit of re-tooling and some recontextualization, this blast from the past could be the next big thing in your application.

---

`NSValueTransformer` is an abstract class that transforms one value into another. A transformation specifies what kinds of input values can be handled, and can even supports reversible transformations, where applicable.

A typical implementation would look something like this:

~~~{swift}
class ClassNameTransformer: NSValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let type = value as? AnyClass else { return nil }
		return NSStringFromClass(type)
    }
}
~~~

~~~{objective-c}
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
~~~

`NSValueTransformer` is rarely initialized directly. Instead, it follows a pattern familiar to fans of `NSPersistentStore` or `NSURLProtocol`, where a class is registered, and instances are created from a manager--except in this case, you register the _instance_ to act as a singleton (with a particular name):

~~~{swift}
let ClassNameTransformerName = "ClassNameTransformer"

// Set the value transformer
NSValueTransformer.setValueTransformer(ClassNameTransformer(), forName: ClassNameTransformerName)

// Get the value transformer
let valueTransformer = NSValueTransformer(forName: ClassNameTransformerName)
~~~

~~~{objective-c}
NSString * const ClassNameTransformerName = @"ClassNameTransformer";

// Set the value transformer
[NSValueTransformer setValueTransformer:[[ClassNameTransformer alloc] init] forName:ClassNameTransformerName];

// Get the value transformer
NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:ClassNameTransformerName];
~~~

Typically, the singleton instance would be registered in the `+initialize` method of the value transformer subclass, so it could be used without further setup.

Now, at this point, you probably realize `NSValueTransformer`'s fatal flaw: it's a pain in the ass to set up! Create a class, implement a handful of simple methods, define a constant, _and_ register it in an `+initialize` method? No thanks.

In this age of blocks, we want--nay, _demand_--a way to declare functionality in one (albeit gigantic) line of code.

Nothing [a little metaprogramming](https://github.com/mattt/TransformerKit/blob/master/TransformerKit/NSValueTransformer%2BTransformerKit.m#L36) can't fix. Behold:

~~~{swift}
let TKCapitalizedStringTransformerName = "TKCapitalizedStringTransformerName"

NSValueTransformer.registerValueTransformerWithName(TKCapitalizedStringTransformerName,
    transformedValueClass:NSString.self) { obj in
        guard let str = obj as? String else { return nil }
		return str.capitalizedString
}
~~~
~~~{objective-c}
NSString * const TKCapitalizedStringTransformerName = @"TKCapitalizedStringTransformerName";

[NSValueTransformer registerValueTransformerWithName:TKCapitalizedStringTransformerName
           transformedValueClass:[NSString class]
returningTransformedValueWithBlock:^id(id value) {
  return [value capitalizedString];
}];
~~~

Not to break the 4th wall or anything, but in the middle of writing this article, I was compelled to see what could be done to improve the experience of `NSValueTransformer`. What I came up with was [TransformerKit](https://github.com/mattt/TransformerKit).

The entire library is based on some objc runtime hackery in an `NSValueTransformer` category. Also included with this category are a number of convenient examples, like string case transformers (i.e. `CamelCase`, `llamaCase`, `snake_case`, and `train-case`).

Now with its sexy new getup, we start to form a better understanding of where this could be useful:

- `NSValueTransformers` are the ideal way to represent an ordered chain of fixed transformations. For instance, an app interfacing with a legacy system might transform user input through a succession of string transformations (trim whitespace, remove diacritics, and then capitalize letters) before sending it off to the mainframe.
- Unlike blocks, `NSValueTransformer` encapsulates reversible transformations. Let's say you were wanted to map keys from a REST API representation into a Model object; you could create a reversible transformation that converted `snake_case` to `llamaCase` when initializing, and `llamaCase` to `snake_case` when serializing back to the server.
- Another advantage over blocks is that `NSValueTransformer` subclasses can expose new properties that could be used to configure behavior in a particular way. Access to `ivars` also make it easier to cleanly memoize results, or do any necessary book-keeping along the way.
- Lest we forget, `NSValueTransformer` can be used with Core Data, as a way to encode and decode compound data types from blob fields. It seems to have fallen out of fashion over the years, but serializing simple collections in this way, for example, is an excellent strategy for information that isn't well-modeled as its own entity. Just don't serialize images to a database this way--that's generally a Bad Idea™.

And the list goes on.

---

`NSValueTransformer`, far from a vestige of AppKit, remains Foundation's purest connection to that fundamental concept of computation: input goes in, output comes out.

Although it hasn't aged very well on its own, a little modernization restores `NSValueTransformer` to that highest esteem of NSHipsterdom: the solution that we didn't know we needed, but was there all along.
