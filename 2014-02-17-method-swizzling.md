---
title: Method Swizzling
author: Mattt Thompson
category: Objective-C
excerpt: "Method swizzling is the process of changing the implementation of an existing selector. It's a technique made possible by the fact that method invocations in Objective-C can be changed at runtime, by changing how selectors are mapped to underlying functions in a class's dispatch table."
status:
    swift: n/a
    reviewed: January 28, 2015
---

> If you could blow up the world with the flick of a switch<br/>
> Would you do it?<br/>
> If you could make everybody poor just so you could be rich<br/>
> Would you do it?<br/>
> If you could watch everybody work while you just lay on your back<br/>
> Would you do it?<br/>
> If you could take all the love without giving any back<br/>
> Would you do it?<br/>
> And so we cannot know ourselves or what we'd really do...<br/>
> With all your power ... What would you do?<br/>
> <cite><strong>The Flaming Lips</strong>, <em><a href="http://en.wikipedia.org/wiki/The_Yeah_Yeah_Yeah_Song_(With_All_Your_Power)">"The Yeah Yeah Yeah Song (With All Your Power)"</a></em></cite>

In last week's article about [associated objects](http://nshipster.com/associated-objects/), we began to explore the dark arts of the Objective-C runtime. This week, we venture further, to discuss what is perhaps the most contentious of runtime hackery techniques: method swizzling.

* * *

Method swizzling is the process of changing the implementation of an existing selector. It's a technique made possible by the fact that method invocations in Objective-C can be changed at runtime, by changing how selectors are mapped to underlying functions in a class's dispatch table.

For example, let's say we wanted to track how many times each view controller is presented to a user in an iOS app:

Each view controller could add tracking code to its own implementation of `viewDidAppear:`, but that would make for a ton of duplicated boilerplate code. Subclassing would be another possibility, but it would require subclassing `UIViewController`, `UITableViewController`, `UINavigationController`, and every other view controller class—an approach that would also suffer from code duplication.

Fortunately, there is another way: **method swizzling** from a category. Here's how to do it:

~~~{objective-c}
#import <objc/runtime.h>

@implementation UIViewController (Tracking)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        BOOL didAddMethod =
            class_addMethod(class,
                originalSelector,
                method_getImplementation(swizzledMethod),
                method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", self);
}

@end
~~~

> In computer science, [pointer swizzling](http://en.wikipedia.org/wiki/Pointer_swizzling) is the conversion of references based on name or position to direct pointer references.  While the origins of Objective-C's usage of the term are not entirely known, it's understandable why it was co-opted, since method swizzling involves changing the reference of a function pointer by its selector.

Now, when any instance of `UIViewController`, or one of its subclasses invokes `viewWillAppear:`, a log statement will print out.

Injecting behavior into the view controller lifecycle, responder events, view drawing, or the Foundation networking stack are all good examples of how method swizzling can be used to great effect. There are a number of other occasions when swizzling would be an appropriate technique, and they become increasingly apparent the more seasoned an Objective-C developer becomes.

Regardless of _why_ or _where_ one chooses to use swizzling, the _how_ remains absolute:

## +load vs. +initialize

**Swizzling should always be done in `+load`.**

There are two methods that are automatically invoked by the Objective-C runtime for each class. `+load` is sent when the class is initially loaded, while `+initialize` is called just before the application calls its first method on that class or an instance of that class. Both are optional, and are executed only if the method is implemented.

Because method swizzling affects global state, it is important to minimize the possibility of race conditions. `+load` is guaranteed to be loaded during class initialization, which provides a modicum of consistency for changing system-wide behavior. By contrast, `+initialize` provides no such guarantee of when it will be executed—in fact, it may _never_ be called, if that class is never messaged directly by the app.

## dispatch_once

**Swizzling should always be done in a `dispatch_once`.**

Again, because swizzling changes global state, we need to take every precaution available to us in the runtime. Atomicity is one such precaution, as is a guarantee that code will be executed exactly once, even across different threads. Grand Central Dispatch's `dispatch_once` provides both of these desirable behaviors, and should be considered as much a standard practice for swizzling as they are for [initializing singletons](http://nshipster.com/c-storage-classes/).

## Selectors, Methods, & Implementations

In Objective-C, _selectors_, _methods_, and _implementations_ refer to particular aspects of the runtime, although in normal conversation, these terms are often used interchangeably to generally refer to the process of message sending.

Here is how each is described in Apple's [Objective-C Runtime Reference](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/Reference/reference.html#//apple_ref/c/func/method_getImplementation):

> - Selector (`typedef struct objc_selector *SEL`): Selectors are used to represent the name of a method at runtime. A method selector is a C string that has been registered (or "mapped") with the Objective-C runtime. Selectors generated by the compiler are automatically mapped by the runtime when the class is loaded .
> - Method (`typedef struct objc_method *Method `): An opaque type that represents a method in a class definition.
> - Implementation (`typedef id (*IMP)(id, SEL, ...)`): This data type is a pointer to the start of the function that implements the method. This function uses standard C calling conventions as implemented for the current CPU architecture. The first argument is a pointer to self (that is, the memory for the particular instance of this class, or, for a class method, a pointer to the metaclass). The second argument is the method selector. The method arguments follow.

The best way to understand the relationship between these concepts is as follows: a class (`Class`) maintains a dispatch table to resolve messages sent at runtime; each entry in the table is a method (`Method`), which keys a particular name, the selector (`SEL`), to an implementation (`IMP`), which is a pointer to an underlying C function.

To swizzle a method is to change a class's dispatch table in order to resolve messages from an existing selector to a different implementation, while aliasing the original method implementation to a new selector.

## Invoking `_cmd`

It may appear that the following code will result in an infinite loop:

~~~{objective-c}
- (void)xxx_viewWillAppear:(BOOL)animated {
    [self xxx_viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", NSStringFromClass([self class]));
}
~~~

Surprisingly, it won't. In the process of swizzling, `xxx_viewWillAppear:` has been reassigned to the original implementation of `UIViewController -viewWillAppear:`. It's good programmer instinct for calling a method on `self` in its own implementation to raise a red flag, but in this case, it makes sense if we remember what's _really_ going on. However, if we were to call `viewWillAppear:` in this method, it _would_ cause an infinite loop, since the implementation of this method will be swizzled to the `viewWillAppear:` selector at runtime.

> Remember to prefix your swizzled method name, the same way you might any other contentious category method.

## Considerations

Swizzling is widely considered a voodoo technique, prone to unpredictable behavior and unforeseen consequences. While it is not the safest thing to do, method swizzling is reasonably safe, when the following precautions are taken:

- **Always invoke the original implementation of a method (unless you have a good reason not to)**: APIs provide a contract for input and output, but the implementation in-between is a black box. Swizzling a method and not calling the original implementation may cause underlying assumptions about private state to break, along with the rest of your application.
- **Avoid collisions**: Prefix category methods, and make damn well sure that nothing else in your code base (or any of your dependencies) are monkeying around with the same piece of functionality as you are.
- **Understand what's going on**: Simply copy-pasting swizzling code without understanding how it works is not only dangerous, but is a wasted opportunity to learn a lot about the Objective-C runtime. Read through the [Objective-C Runtime Reference](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/Reference/reference.html#//apple_ref/c/func/method_getImplementation) and browse `<objc/runtime.h>` to get a good sense of how and why things happen. _Always endeavor to replace magical thinking with understanding._
- **Proceed with caution**: No matter how confident you are about swizzling Foundation, UIKit, or any other built-in framework, know that everything could break in the next release. Be ready for that, and go the extra mile to ensure that in playing with fire, you don't get `NSBurned`.

> Feeling gun shy about invoking the Objective-C runtime directly? [Jonathan ‘Wolf’ Rentzsch](https://twitter.com/rentzsch) provides a battle-tested, CocoaPods-ready library called [JRSwizzle](https://github.com/rentzsch/jrswizzle) that will take care of everything for you.

* * *

Like [associated objects](http://nshipster.com/associated-objects/), method swizzling is a powerful technique when you need it, but should be used sparingly.
