---
title: UIAppearance
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "UIAppearance allows the appearance of views and controls to be consistently defined across the entire application."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Style vs. Substance.
Message vs. Medium.
Rhetoric vs. Dialectic.

Is beauty merely skin deep, or is it somehow informed by deeper truths?
What does it mean for something to possess good design?
Are aesthetic judgments relative, or absolute?

These are deep questions that have been pondered by philosophers, artists, and makers alike for millennia.

And while we all continue our search for beauty and understanding in the universe, the app marketplace has been rather clear on this subject:

**Users will pay a premium for good-looking software.**

When someone purchases an iPhone, they are buying into Apple's philosophy that things that work well should look good, too. The same goes for when we choose to develop for iOS—a sloppy UI reflects poorly on the underlying code.

It used to be that even trivial UI customization on iOS required AppStore-approval-process-taunting ju-ju like method swizzling. Fortunately, with iOS 5, developers were given an easier way: `UIAppearance`.

---

`UIAppearance` allows the appearance of views and controls to be consistently defined across the entire application.

In order to have this work within the existing structure of UIKit, Apple devised a rather clever solution: `UIAppearance` is a protocol that returns a proxy that will forward any configuration to instances of a particular class. Why a proxy instead of a property or method on `UIView` directly? Because there are non-`UIView` objects like `UIBarButtonItem` that render their own composite views.
Appearance can be customized for all instances, or scoped to particular view hierarchies:

> - `+appearance`: Returns the appearance proxy for the receiver.
> - `+appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass,...`: Returns the appearance proxy for the receiver in a given containment hierarchy.
>
> To customize the appearance of all instances of a class, you use `appearance()` to get the appearance proxy for the class. For example, to modify the tint color for all instances of UINavigationBar:

```swift
UINavigationBar.appearance().tintColor = myColor
```
```objective-c
[[UINavigationBar appearance] setTintColor:myColor];
```

> To customize the appearances for instances of a class when contained within an instance of a container class, or instances in a hierarchy, you use `appearanceWhenContainedInInstancesOfClasses(_:)` to get the appearance proxy for the class (the older, variadic `appearanceWhenContainedIn` method has been deprecated):

```swift
UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self])
				.tintColor = myNavBarColor
UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self, UIPopoverController.self])
				.tintColor = myNavBarColor
UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UIToolbar.self])
				.tintColor = myNavBarColor
UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UIToolbar.self, UIPopoverController.self])
				.tintColor = myNavBarColor
```
```objective-c
[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]]
       setTintColor:myNavBarColor];
[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], [UIPopoverController class]]]
        setTintColor:myPopoverNavBarColor];
[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class]]]
        setTintColor:myToolbarColor];
[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [UIPopoverController class]]]
        setTintColor:myPopoverToolbarColor];
```

## Determining Which Properties Work With `UIAppearance`

One major downside to `UIAppearance`'s proxy approach is that it's difficult to know which selectors are compatible.

<del>Because <tt>+appearance</tt> returns an <tt>id</tt>, Xcode can't provide any code-completion information. This is a major source of confusion and frustration with this feature.</del>

<ins>As of iOS 7, UIAppearance now returns <a href="http://nshipster.com/instancetype/"><tt>instancetype</tt></a>, which allows for code completion to work as expected. Huzzah!</ins>

In order to find out what methods work with `UIAppearance`, you have to [look at the headers](http://stackoverflow.com/questions/9424112/what-properties-can-i-set-via-an-uiappearance-proxy):

```
$ cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/
  Developer/SDKs/iPhoneOS*.sdk/System/Library/Frameworks/UIKit.framework/Headers
$ grep -H UI_APPEARANCE_SELECTOR ./* | sed 's/ __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0) UI_APPEARANCE_SELECTOR;//'
```

`UIAppearance` looks for the `UI_APPEARANCE_SELECTOR` macro in method signatures. Any method with this annotation can be used with the `appearance` proxy.

For your convenience, [here is the list of properties as of iOS 7.0](https://gist.github.com/mattt/5135521).

## Implementing `<UIAppearance>` in Custom UIView Subclasses

Much like how [`NSLocalizedString`](http://nshipster.com/nslocalizedstring/) and [`#pragma`](http://nshipster.com/pragma/) are marks of quality in Objective-C code, having custom UI classes conform to `UIAppearance` is not only a best-practice, but it demonstrates a certain level of care being put into its implementation.

[Peter Steinberger](https://twitter.com/steipete) has [this great article](http://petersteinberger.com/blog/2013/uiappearance-for-custom-views/), which describes some of the caveats about implementing `UIAppearance` in custom views. It's a must-read for anyone who aspires to greatness in their open source UI components.

## Alternatives

Another major shortcoming of `UIAppearance` is that style rules are _imperative_, rather than _declarative_. That is, styling is applied at runtime in code, rather than being interpreted from a list of style rules.

Yes, if there's one idea to steal from web development, it's the separation of content and presentation. Say what you will about CSS, but stylesheets are _amazing_.

Stylesheet enthusiasts on iOS now have some options. [Pixate](http://www.pixate.com) is a commercial framework that uses CSS to style applications. [NUI](https://github.com/tombenner/nui), an open-source project by [Tom Benner](https://github.com/tombenner), does much the same with a CSS/SCSS-like language. Another open source project along the same lines is [UISS](https://github.com/robertwijas/UISS) by [Robert Wijas](https://github.com/robertwijas), which allows `UIAppearance` rules to be read from JSON.

---

Cocoa developers have a long history of obsessing about visual aesthetics, and have often gone to extreme ends to achieve their desired effects. Recall the [Delicious Generation](http://en.wikipedia.org/wiki/Delicious_Generation) of Mac developers, and applications like [Disco](http://discoapp.com), which went so far as to [emit virtual smoke when burning a disc](http://www.youtube.com/watch?v=8Dwi47XOqwI).

This spirit of dedication to making things look good is alive and well in iOS. As a community and as an ecosystem, we have relentlessly pushed the envelope in terms of what users should expect from their apps. And though this makes our jobs more challenging, it makes the experience of developing for iOS all the more enjoyable.

Settle for nothing less than the whole package.
Make your apps beautiful from interface to implementation.
