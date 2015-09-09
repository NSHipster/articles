---
title: "IBAction / IBOutlet / IBOutletCollection"
author: Mattt Thompson
category: Cocoa
excerpt: "In programming, what often begins as a necessary instruction eventually becomes a vestigial cue for humans. For developers just starting with Cocoa & Cocoa Touch, the IBAction, IBOutlet, and IBOutletCollection macros are particularly bewildering examples of this phenomenon"
status:
    swift: t.b.c.
---

In programming, what often begins as a necessary instruction eventually becomes a vestigial cue for humans. In the case of Objective-C, [`#pragma` directives](http://nshipster.com/pragma/), [method type encodings](http://nshipster.com/type-encodings/), and all but the most essential [storage classes](http://nshipster.com/c-storage-classes/) have been rendered essentially meaningless, as the compiler becomes increasingly sophisticated. Discarded and disregarded during the compilation phase, they nonetheless remain useful to the development process as a whole, insofar as what they can tell other developers about the code itself.

For developers just starting with Cocoa & Cocoa Touch, the `IBAction`, `IBOutlet`, and `IBOutletCollection` macros are particularly bewildering examples of this phenomenon. With their raison d'être obscured by decades of change, confusion by anyone without sufficient context is completely understandable.

As we'll learn in this week's article, though having outgrown their technical necessity, they remain a vibrant tradition in the culture of Objective-C development.

* * *

Unlike other [two-letter prefixes](http://nshipster.com/namespacing/), `IB` does not refer to a system framework, but rather Interface Builder.

[Interface Builder](http://en.wikipedia.org/wiki/Interface_Builder) can trace its roots to the halcyon days of Objective-C, when it and Project Builder comprised the NeXTSTEP developer tools (circa 1988). Before it was subsumed into Xcode 4, Interface Builder remained remarkably unchanged from its 1.0 release. An iOS developer today would feel right at home on a NeXTSTEP workstation, control-dragging views into outlets.

Back when they were separate applications, it was a challenge to keep the object graph represented in a `.nib` document in Interface Builder synchronized with its corresponding `.h` & `.m` files in [Project Builder](http://en.wikipedia.org/wiki/Project_Builder) (what would eventually become Xcode). `IBOutlet` and `IBAction` were used as keywords, to denote what parts of the code should be visible to Interface Builder.

`IBAction` and `IBOutlet` are, themselves, computationally meaningless, as their macro definitions (in `UINibDeclarations.h`) demonstrate:

~~~{objective-c}
#define IBAction void
#define IBOutlet
~~~

> Well actually, there's more than meets the eye. Scrying the [Clang source code](https://llvm.org/svn/llvm-project/cfe/trunk/test/SemaObjC/iboutlet.m), we see that they're actually defined by [__attribute__](http://nshipster.com/__attribute__/)-backed attributes:

~~~{objective-c}
#define IBOutlet __attribute__((iboutlet))
#define IBAction __attribute__((ibaction))
~~~

## IBAction

As early as 2004 (and perhaps earlier), `IBAction` was no longer necessary for a method to be noticed by Interface Builder. Any method with the signature `-(void){name}:(id)sender` would be visible in the outlets pane.

Nevertheless, many developers find it useful to still use the `IBAction` return type in method declarations to denote that a particular method is connected to by an action. Even projects _not_ using Storyboards / XIBs may choose to employ `IBAction` to call out [target / action](https://developer.apple.com/library/ios/documentation/general/conceptual/Devpedia-CocoaApp/TargetAction.html) methods.

### Naming IBAction Methods

Thanks to strong, and often compiler-enforced conventions, naming is especially important in Objective-C, so the question of how to name IBAction methods is one not taken lightly. Though there is some disagreement, the preferred convention is as follows:

- **Return type of `IBAction`.**
- **Method name of an active verb, describing the specific action performed.** Method names like `didTapButton:` or `didPerformAction:` sound more like things a `delegate` might be sent.
- **Required `sender` parameter of type `id`.** All target / action methods will pass the `sender` of the action (usually the responder) to methods that take a parameter. If omitted in the method signature, things will still work.
- **Optional event parameter of type `UIEvent *`, named `withEvent:`** _(iOS only)_. In UIKit, a second `UIEvent *` parameter, corresponding to the touch, motion, or remote control event triggering the responder, will be passed to target / action methods accepting this second parameter. The convention is to use `withEvent:` in the method signature, to match the `UIResponder` APIs.

For example:

~~~{objective-c}
// YES
- (IBAction)refresh:(id)sender;

- (IBAction)toggleVisibility:(id)sender
                   withEvent:(UIEvent *)event;

// NO
- (IBAction)peformSomeAction;

- (IBAction)didTapButton:(id)sender;
~~~

## IBOutlet

Unlike `IBAction`, `IBOutlet` is still required for hooking up properties in code with objects in a Storyboard or XIB.

An `IBOutlet` connection is usually established between a view or control and its managing view controller (this is often done in addition to any `IBAction`s that a view controller might be targeted to perform by a responder). However, an `IBOutlet` can also be used to expose a top-level property, like another controller or a property that could then be accessed by a referencing view controller.

### When to use `@property` or ivar

As with anything in modern Objective-C, **properties are preferred to direct ivar access**. The same is true of `IBOutlet`s:

~~~{objective-c}
// YES
@interface GallantViewController : UIViewController
@property (nonatomic, weak) IBOutlet UISwitch *switch;
@end

// NO
@interface GoofusViewController : UIViewController {
    IBOutlet UISwitch *_switch
}
@end
~~~

Since properties are the conventional way to expose and access members of a class, both externally and internally, they are preferred in this case as well, if only for consistency.

### When to use `weak` or `strong`

One unfortunate consequence (if you want to call it that) of ARC is the ambiguity of when a `IBOutlet` `@property` should be declared as `weak` or `strong`. The ambiguity arises from the fact that most outlets have no discernible behavioral differences between `weak` or `strong`—it just works.

…except when it doesn't… and things crash, or the compiler warns about `weak` or `strong` use.

So what should one do? **Always declare `IBOutlet` properties as `weak`, except when they need to be `strong`**, as explained by Apple in their [Resource Programming Guide section on Nib Files](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/LoadingResources/CocoaNibs/CocoaNibs.html):

> Outlets should be changed to `strong` when the outlet should be considered to own the referenced object:
>
> - This is often the case with File’s Owner—top level objects in a nib file are frequently considered to be owned by the `File’s Owner`.
> - You may in some situations need an object from a nib file to exist outside of its original container. For example, you might have an outlet for a view that can be temporarily removed from its initial view hierarchy and must therefore be maintained independently.

The reason why most `IBOutlet` views can get away with `weak` ownership is that they are already owned within their respective view hierarchy, by their superview. This chain of ownership eventually works its way up to the `view` owned by the view controller itself. Spurious use of `strong` ownership on a view outlet has the potential to create a retain cycle.

## IBOutletCollection

`IBOutlet`'s obscure step-cousin-in-law-once-removed is `IBOutletCollection`. Introduced in iOS 4, this pseudo-keyword allows collections of `IBOutlet`s to be defined in Interface Builder, by dragging connections to its collection members.

`IBOutletCollection` is `#define`'d in `UINibDeclarations.h` as:

~~~{objective-c}
#define IBOutletCollection(ClassName)
~~~

…which is defined in a much more satisfying way, again, [in the Clang source code](http://opensource.apple.com/source/clang/clang-318.0.45/src/tools/clang/test/SemaObjC/iboutletcollection-attr.m):

~~~{objective-c}
#define IBOutletCollection(ClassName) __attribute__((iboutletcollection(ClassName)))
~~~

Unlike `IBAction` or `IBOutlet`, `IBOutletCollection` takes a class name as an argument, which is, incidentally, as close to Apple-sanctioned [generics](http://en.wikipedia.org/wiki/Generic_programming) as one gets in Objective-C.

As a top-level object, an `IBOutletCollection` `@property` should be declared `strong`, with an `NSArray *` type:

~~~{objective-c}
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;
~~~

There are two rather curious things to note about an `IBOutletCollection` array:

- **Its order is not necessarily guaranteed**. The order of an outlet collection appears to be roughly the order in which their connections are established in Interface Builder. However, there are numerous reports of that order changing across versions of Xcode, or as a natural consequence of version control. Nonetheless, having code rely on a fixed order is strongly discouraged.
- **No matter what type is declared for the property, an `IBOutletCollection` is always an `NSArray`**. In fact, any type can be declared: `NSSet *`, `id <NSFastEnumeration>`—heck, even `UIColor *` (depending on your error flags)! No matter what you put, an `IBOutletCollection` will always be stored as an `NSArray`, so you might as well have that type match up in your declaration to avoid compiler warnings.

With the advent of Objective-C [object literals](http://nshipster.com/at-compiler-directives/), `IBOutletCollection` has fallen slightly out of favor—at least for the common use case of convenience accessors, as in:

~~~{objective-c}
for (UILabel *label in labels) {
    label.font = [UIFont systemFontOfSize:14];
}
~~~

Since declaring a collection of outlets is now as easy as comma-delimiting them within `@[]`, it may make just as much sense to do that as create a distinct collection.

Where `IBOutletCollection` really shines is how it allows you to define a unique collection of outlets under a shared identifier. Another advantage over a code-defined `NSArray` literal is that a collection can contain outlets that themselves are not connected to `File's Owner`.

The next time you're managing a significant or variable number of outlets in an iOS view, take a look at `IBOutletCollection`.

* * *

`IBAction`, `IBOutlet`, and `IBOutletCollection` play important roles in development, on both the compiler level and human level. As Objective-C continues to rapidly evolve as a platform, it is likely that they may someday be as completely vestigial as the wings of flightless birds or eyes of cavefish.

For now, though, it's important to understand what they are, and how to use them, if you plan on creating apps in any capacity.
