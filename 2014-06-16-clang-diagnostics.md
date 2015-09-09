---
title: Clang Diagnostics
author: Mattt Thompson
category: Objective-C
excerpt: "Diagnostics combine logic with analytics to arrive at a conclusion. It's science and engineering at their purest. It's human reasoning at its most potent. For us developers, our medium of code informs the production of subsequent code, creating a positive feedback loop that has catapulted the development of technology exponentially over the last half century. For us Objective-C developers specifically, the most effective diagnostics come from Clang."
status:
    swift: n/a
---

Diagnostics combine logic with analytics to arrive at a conclusion. It's science and engineering at their purest. It's human reasoning at its most potent.

Within the medical profession, a diagnosis is made through instinct backed by lab samples. For industrial manufacturing, one diagnoses a product fault through an equal application of statistics and gumption.

For us developers, our medium of code informs the production of subsequent code, creating a positive feedback loop that has catapulted the development of technology exponentially over the last half century. For us Objective-C developers specifically, the most effective diagnostics come from Clang.

Clang is the C / Objective-C front-end to the LLVM compiler. It has a deep understanding of the syntax and semantics of Objective-C, and is much of the reason that Objective-C is such a capable language today.

That amazing readout you get when you "Build & Analyze" (`⌘⇧B`) is a function of the softer, more contemplative side of Clang: its code diagnostics.

In our article about [`#pragma`](http://nshipster.com/pragma/), we quipped:

> Pro tip: Try setting the `-Weverything` flag and checking the "Treat Warnings as Errors" box your build settings. This turns on Hard Mode in Xcode.

Now, we stand by this advice, and encourage other developers to step up their game and treat build warnings more seriously. However, there are some situations in which you and Clang reach an impasse. For example, consider the following `switch` statement:

~~~{objective-c}
switch (style) {
    case UITableViewCellStyleDefault:
    case UITableViewCellStyleValue1:
    case UITableViewCellStyleValue2:
    case UITableViewCellStyleSubtitle:
        // ...
    default:
        return;
}
~~~

When certain flags are enabled, Clang will complain that the "default label in switch which covers all enumeration values". However, if we _know_ that, zooming out into a larger context, `style` is (for better or worse) derived from an external representation (e.g. JSON resource) that allows for unconstrained `NSInteger` values, the `default` case is a necessary safeguard. The only way to insist on this inevitability is to use `#pragma` to ignore a warning flag temporarily:

> `push` & `pop` are used to save and restore the compiler state, similar to Core Graphics or OpenGL contexts.

~~~{objective-c}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcovered-switch-default"
switch (style) {
    case UITableViewCellStyleDefault:
    case UITableViewCellStyleValue1:
    case UITableViewCellStyleValue2:
    case UITableViewCellStyleSubtitle:
        // ...
    default:
        return;
}
#pragma clang diagnostic pop
~~~

> Again, and this cannot be stressed enough, Clang is right at least 99% of the time. Actually fixing an analyzer warning is _strongly_ preferred to ignoring it. Use `#pragma clang diagnostic ignored` as a method of last resort.

This week, as a public service, we've compiled a (mostly) comprehensive list of Clang warning strings and their associated flags, which can be found here:

**[F\*\*\*ingClangWarnings.com](http://fuckingclangwarnings.com)**

You can also find the compiler and analyzer flags for any warning you might encounter by `^`-Clicking the corresponding entry in the Xcode Issue Navigator and selecting "Reveal in Log". (If this option is disabled, try building the project again).

* * *

Corrections? Additions? Open a [Pull Request](https://github.com/mattt/fuckingclangwarnings.com/pulls) to submit your change. Any help would be greatly appreciated.
