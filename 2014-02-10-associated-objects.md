---
title: Associated Objects
author: Mattt Thompson
category: Objective-C
excerpt: "Associated Objects is a feature of the Objective-C 2.0 runtime, which allows objects to associate arbitrary values for keys at runtime. It's dark juju, to be handled with as much caution as any other function from objc/runtime.h"
status:
    swift: n/a
---

~~~{objective-c}
#import <objc/runtime.h>
~~~

Objective-C developers are conditioned to be wary of whatever follows this ominous incantation. And for good reason: messing with the Objective-C runtime changes the very fabric of reality for all of the code that runs on it.

In the right hands, the functions of `<objc/runtime.h>` have the potential to add powerful new behavior to an application or framework, in ways that would otherwise not be possible. In the wrong hands, it drains the proverbial [sanity meter](http://en.wikipedia.org/wiki/Eternal_Darkness:_Sanity's_Requiem#Sanity_effects) of the code, and everything it may interact with (with [terrifying side-effects](http://www.youtube.com/watch?v=RSXcajQnasc#t=0m30s)).

Therefore, it is with great trepidation that we consider this [Faustian bargain](http://en.wikipedia.org/wiki/Deal_with_the_Devil), and look at one of the subjects most-often requested by NSHipster readers: associated objects.

* * *

Associated Objects—or Associative References, as they were originally known—are a feature of the Objective-C 2.0 runtime, introduced in OS X Snow Leopard (available in iOS 4). The term refers to the following three C functions declared in `<objc/runtime.h>`, which allow objects to associate arbitrary values for keys at runtime:

- `objc_setAssociatedObject`
- `objc_getAssociatedObject`
- `objc_removeAssociatedObjects`

Why is this useful? It allows developers to **add custom properties to existing classes in categories**, which [is an otherwise notable shortcoming for Objective-C](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html).

#### NSObject+AssociatedObject.h

~~~{objective-c}
@interface NSObject (AssociatedObject)
@property (nonatomic, strong) id associatedObject;
@end
~~~

#### NSObject+AssociatedObject.m

~~~{objective-c}
@implementation NSObject (AssociatedObject)
@dynamic associatedObject;

- (void)setAssociatedObject:(id)object {
     objc_setAssociatedObject(self, @selector(associatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, @selector(associatedObject));
}
~~~

It is often recommended that they key be a `static char`—or better yet, the pointer to one. Basically, an arbitrary value that is guaranteed to be constant, unique, and scoped for use within getters and setters:

~~~{objective-c}
static char kAssociatedObjectKey;

objc_getAssociatedObject(self, &kAssociatedObjectKey);
~~~

However, a much simpler solution exists: just use a selector.

<blockquote class="twitter-tweet" lang="en"><p>Since <tt>SEL</tt>s are guaranteed to be unique and constant, you can use <tt>_cmd</tt> as the key for <tt>objc_setAssociatedObject()</tt>. <a href="https://twitter.com/search?q=%23objective&amp;src=hash">#objective</a>-c <a href="https://twitter.com/search?q=%23snowleopard&amp;src=hash">#snowleopard</a></p>&mdash; Bill Bumgarner (@bbum) <a href="https://twitter.com/bbum/statuses/3609098005">August 28, 2009</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## Associative Object Behaviors

Values can be associated onto objects according to the behaviors defined by the enumerated type `objc_AssociationPolicy`:

<table>
    <thead>
        <tr>
            <th>Behavior</th>
            <th><tt>@property</tt> Equivalent</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_ASSIGN</tt>
            </td>
            <td>
                <tt>@property (assign)</tt> or <tt>@property (unsafe_unretained)</tt>
            </td>
            <td>
                Specifies a weak reference to the associated object.
            </td>
        </tr>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_RETAIN_NONATOMIC</tt>
            </td>
            <td>
                <tt>@property (nonatomic, strong)</tt>
            </td>
            <td>
                Specifies a strong reference to the associated object, and that the association is not made atomically.
            </td>
        </tr>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_COPY_NONATOMIC</tt>
            </td>
            <td>
                <tt>@property (nonatomic, copy)</tt>
            </td>
            <td>
                Specifies that the associated object is copied, and that the association is not made atomically.
            </td>
        </tr>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_RETAIN</tt>
            </td>
            <td>
                <tt>@property (atomic, strong)</tt>
            </td>
            <td>
                Specifies a strong reference to the associated object, and that the association is made atomically.
            </td>
        </tr>
        <tr>
            <td>
                <tt>OBJC_ASSOCIATION_COPY</tt>
            </td>
            <td>
                <tt>@property (atomic, copy)</tt>
            </td>
            <td>
                Specifies that the associated object is copied, and that the association is made atomically.
            </td>
        </tr>
    </tbody>
</table>

Weak associations to objects made with `OBJC_ASSOCIATION_ASSIGN` are not zero `weak` references, but rather follow a behavior similar to `unsafe_unretained`, which means that one should be cautious when accessing weakly associated objects within an implementation.

> According to the Deallocation Timeline described in [WWDC 2011, Session 322](https://developer.apple.com/videos/wwdc/2011/#322-video) (~36:00), associated objects are erased surprisingly late in the object lifecycle, in `object_dispose()`, which is invoked by `NSObject -dealloc`.

## Removing Values

One may be tempted to call `objc_removeAssociatedObjects()` at some point in their foray into associated objects. However, [as described in the documentation](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/Reference/reference.html#//apple_ref/c/func/objc_removeAssociatedObjects), it's unlikely that you would have an occasion to invoke it yourself:

>The main purpose of this function is to make it easy to return an object to a "pristine state”. You should not use this function for general removal of associations from objects, since it also removes associations that other clients may have added to the object. Typically you should use objc_setAssociatedObject with a nil value to clear an association.

## Patterns

- **Adding private variables to facilitate implementation details**. When extending the behavior of a built-in class, it may be necessary to keep track of additional state. This is the _textbook_ use case for associated objects. For example, AFNetworking uses associated objects on its `UIImageView` category to [store a request operation object](https://github.com/AFNetworking/AFNetworking/blob/2.1.0/UIKit%2BAFNetworking/UIImageView%2BAFNetworking.m#L57-L63), used to asynchronously fetch a remote image at a particular URL.
- **Adding public properties to configure category behavior.** Sometimes, it makes more sense to make category behavior more flexible with a property, than in a method parameter. In these situations, a public-facing property is an acceptable situation to use associated objects. To go back to the previous example of AFNetworking, its category on `UIImageView`, [its `imageResponseSerializer`](https://github.com/AFNetworking/AFNetworking/blob/2.1.0/UIKit%2BAFNetworking/UIImageView%2BAFNetworking.h#L60-L65) allows image views to optionally apply a filter, or otherwise change the rendering of a remote image before it is set and cached to disk.
- **Creating an associated observer for KVO**. When using [KVO](http://nshipster.com/key-value-observing/) in a category implementation, it is recommended that a custom associated-object be used as an observer, rather than the object observing itself.

## Anti-Patterns

- **Storing an associated object, when the value is not needed**. A common pattern for views is to create a convenience method that populates fields and attributes based on a model object or compound value. If that value does not need to be recalled later, it is acceptable, and indeed preferable, not to associate with that object.
- **Storing an associated object, when the value can be inferred.** For example, one might be tempted to store a reference to a custom accessory view's containing `UITableViewCell`, for use in `tableView:accessoryButtonTappedForRowWithIndexPath:`, when this can retrieved by calling `cellForRowAtIndexPath:`.
- **Using associated objects instead of X**, where X is any one the following:
    - [Subclassing](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html) for when inheritance is a more reasonable fit than composition.
    - [Target-Action](https://developer.apple.com/library/ios/documentation/general/conceptual/Devpedia-CocoaApp/TargetAction.html) for adding interaction events to responders.
    - [Gesture Recognizers](https://developer.apple.com/library/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/GestureRecognizer_basics/GestureRecognizer_basics.html) for any situations when target-action doesn't suffice.
    - [Delegation](https://developer.apple.com/library/ios/documentation/general/conceptual/DevPedia-CocoaCore/Delegation.html) when behavior can be delegated to another object.
    - [NSNotification & NSNotificationCenter](http://nshipster.com/nsnotification-and-nsnotificationcenter/) for communicating events across a system in a loosely-coupled way.

* * *

Associated objects should be seen as a method of last resort, rather than a solution in search of a problem (and really, categories themselves really shouldn't be at the top of the toolchain to begin with).

Like any clever trick, hack, or workaround, there is a natural tendency for one to actively seek out occasions to use it—especially just after learning about it. Do your best to understand and appreciate when it's the right solution, and save yourself the embarrassment of being scornfully asked "why in the name of $DEITY" you decided to go with _that_ solution.
