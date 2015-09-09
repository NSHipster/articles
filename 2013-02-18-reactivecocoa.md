---
title: ReactiveCocoa
author: Mattt Thompson
category: Open Source
excerpt: "Breaking from a tradition of covering Apple APIs exclusively, this edition of NSHipster will look at an open source project that exemplifies a brave new era of open source contribution to Objective-C: ReactiveCocoa."
status:
    swift: n/a
---

Languages are living works. They are nudged and challenged and bastardized and mashed-up in a perpetual cycle of undirected and rapid evolution. Technologies evolve, requirements change, corporate stewards and open source community come and go; obscure dialects are vaulted to prominence on the shoulders of exciting new frameworks, and thrust into a surprising new context after a long period of dormancy.

Objective-C has a remarkable history spanning four acts in as many decades:

**In its 1<sup>st</sup> act**, Objective-C was adopted as the language of NeXT, powering [NeXTSTEP](http://en.wikipedia.org/wiki/NeXTSTEP) and [the world's first web server](http://en.wikipedia.org/wiki/Web_server#History).

**In its 2<sup>nd</sup> act**, Objective-C positioned itself in the heart Apple's technology stack (after a prolonged turf war with Java) with Apple's acquisition of NeXT.

**In its 3<sup>rd</sup> act**, Objective-C rose to unprecedented significance with the release of iOS, making it the most important language of mobile computing.

**Objective-C's 4<sup>th</sup> act takes us to the present day**, with an influx of new iOS developers from the Ruby, Python, and Javascript communities sparking a revolution in open source participation. For the first time, Objective-C is being directly shaped and guided by the contributions of individuals outside of Apple.

Breaking from a tradition of covering Apple APIs exclusively, this edition of NSHipster will look at an open source project that exemplifies this brave new era for Objective-C: [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).

---

> For a complete look at ReactiveCocoa, refer to the project's [README](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/README.md), [Framework Overview](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md) and [Design Guidelines](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/DesignGuidelines.md).

[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) is an open source library that brings Functional Reactive Programming paradigm to Objective-C. It was created by [Josh Abernathy](https://github.com/joshaber) & [Justin Spahr-Summers](https://github.com/jspahrsummers) in the development of [GitHub for Mac](http://mac.github.com). Last week, ReactiveCocoa reached a major milestone with its [1.0 release](https://github.com/ReactiveCocoa/ReactiveCocoa/tree/v1.0.0).

[Functional Reactive Programming](http://en.wikipedia.org/wiki/Functional_reactive_programming) (FRP) is a way of thinking about software in terms of transforming inputs to produce output continuously over time. [Josh Abernathy frames the paradigm thusly](http://blog.maybeapps.com/post/42894317939/input-and-output):

> Programs take input and produce output. The output is the result of doing something with the input. Input, transform, output, done.
>
> The input is all the sources of action for your app. It's taps. It's keyboard events. It's timer triggers, GPS events, and web service responses. These things are all inputs. They all feed into the app, and the app combines them all in some way to produce a result: the output.
>
> The output is often a change in the app's UI. A switch is toggled or a list gets a new item. Or it could be more than that. It could be a new file on the device's disk, or it could be an API request. These things are the outputs of the app.
>
> But unlike the classic input/output design, this input and output happens more than once. It's not just a single input → work → output—the cycle continues while the app is open. The app is always consuming inputs and producing outputs based on them.

To illustrate the difference between the conventional, imperative paradigm of Objective-C programming versus a functional reactive approach, consider the common example of validating a signup form:

### Conventional

~~~{objective-c}
- (BOOL)isFormValid {
    return [self.usernameField.text length] > 0 &&
            [self.emailField.text length] > 0 &&
            [self.passwordField.text length] > 0 &&
            [self.passwordField.text isEqual:self.passwordVerificationField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    self.createButton.enabled = [self isFormValid];

    return YES;
}
~~~

In the conventional example, logic is fragmented across different methods in the view controller, with calls to `self.createButton.enabled = [self isFormValid];` interspersed throughout delegate methods and view lifecycle callbacks.

Compare this with equivalent code using ReactiveCocoa:

### ReactiveCocoa

~~~{objective-c}
RACSignal *formValid = [RACSignal
  combineLatest:@[
    self.username.rac_textSignal,
    self.emailField.rac_textSignal,
    self.passwordField.rac_textSignal,
    self.passwordVerificationField.rac_textSignal
  ]
  reduce:^(NSString *username, NSString *email, NSString *password, NSString *passwordVerification) {
    return @([username length] > 0 && [email length] > 0 && [password length] > 8 && [password isEqual:passwordVerification]);
  }];

RAC(self.createButton.enabled) = formValid;
~~~

Here, all of the logic for validating form input is contained in a single chain of logic and responsibility. Each time any of the text fields is updated, their inputs are reduced into a single boolean value, which automatically enables / disables the create button.

## Overview

ReactiveCocoa is comprised of two major components: [signals](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md#signals) (`RACSignal`) and [sequences](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md#sequences) (`RACSequence`).

Both signals and sequences are kinds of [streams](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md#streams), sharing many of the same operators. ReactiveCocoa has done well to abstract a wide scope of functionality into a semantically dense, consistent design: signals are a _push_-driven stream, and sequences are a _pull_-driven stream.

### `RACSignal`

> - **Handling Asynchronous Or Event-driven Data Sources**: Much of Cocoa programming is focused on reacting to user events or changes in application state.
> - **Chaining Dependent Operations**: Dependencies are most often found in network requests, where a previous request to the server needs to complete before the next one can be constructed.
> - **Parallelizing Independent Work**: Working with independent data sets in parallel and then combining them into a final result is non-trivial in Cocoa, and often involves a lot of synchronization.

> Signals send three different types of events to their subscribers:
>
> * The **next** event provides a new value from the stream. Unlike Cocoa collections, it is
   completely valid for a signal to include `nil`.
> * The **error** event indicates that an error occurred before the signal could
   finish. The event may include an `NSError` object that indicates what went
   wrong. Errors must be handled specially – they are not included in the
   stream's values.
> * The **completed** event indicates that the signal finished successfully, and
   that no more values will be added to the stream. Completion must be handled
   specially – it is not included in the stream of values.
>
> The lifetime of a signal consists of any number of `next` events, followed by
one `error` or `completed` event (but not both).

### `RACSequence`

> - **Simplifying Collection Transformations**: Higher-order functions like `map`, `filter`, `fold/reduce` are sorely missing from `Foundation`.

> Sequences are a kind of collection, similar in purpose to `NSArray`. Unlike
an array, the values in a sequence are evaluated _lazily_ (i.e., only when they
are needed) by default, potentially improving performance if only part of
a sequence is used. Just like Cocoa collections, sequences cannot contain `nil`.
>
> `RACSequence` allows any Cocoa collection to be manipulated in a uniform and declarative way.

~~~{objective-c}
RACSequence *normalizedLongWords = [[words.rac_sequence
    filter:^ BOOL (NSString *word) {
        return [word length] >= 10;
    }]
    map:^(NSString *word) {
        return [word lowercaseString];
    }];
~~~

## Precedents in Cocoa

Capturing and responding to changes has a long tradition in Cocoa, and ReactiveCocoa is a conceptual and functional extension of that. It is instructive to contrast RAC with those Cocoa technologies:

### RAC vs. KVO

[Key-Value Observing](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html) is at the heart of all magic in Cocoa—indeed, it is used extensively by ReactiveCocoa to react to property changes. However, KVO is neither pleasant nor easy to use: its API is overwrought with unused parameters and sorely lacking a blocks-based interface.

### RAC vs. Bindings

[Bindings](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaBindings/CocoaBindings.html) are magic—voodoo, really.

Although essential to managing the complexity of a OS X application, Bindings' cultural relevance has waned for years, as the focus has shifted to iOS and UIKit, which notably lacks support. Bindings replace a lot of boilerplate glue code and allow programming to be done in Interface Builder, but they're severely limited and _impossible_ to debug. RAC offers a clear, understandable, and extensible code-based API that works in iOS and is apt to replace all but the most trivial uses of bindings in your OS X application.

---

Objective-C was built from Smalltalk's ideas on top of C's metal, but its cultural imports go far beyond its original pedigree.

`@protocol` was a rejection of C++'s multiple inheritance, favoring an abstract data type pattern comparable to a Java `Interface`. Objective-C 2.0 introduced `@property / @synthesize`, a contemporary of C#'s `get; set;` shorthand for getter and setter methods (as well as dot syntax, which is still a point of contention for NeXTSTEP hard-liners). Blocks injected some functional programming flavor to the language, which paired nicely with Grand Central Dispatch--a queue-based concurrency API almost certainly influenced by Fortran / C / C++ standard [OpenMP](http://en.wikipedia.org/wiki/OpenMP). Subscripting and object literals, a standard feature in scripting languages like Ruby and Javascript, now finally brought to Objective-C thanks to a Clang language extension.

ReactiveCocoa brings a healthy dose of functional and reactive programming influence to Objective-C, and was itself influenced by C#'s [Rx library](http://msdn.microsoft.com/en-us/data/gg577609.aspx), [Clojure](http://en.wikipedia.org/wiki/Clojure), and [Elm][2].

Good ideas are contagious. ReactiveCocoa is a reminder that good ideas can come from unlikely places, and that a fresh perspective can make all of the difference with familiar problems.

[1]: http://en.wikipedia.org/wiki/State_(computer_science)#Program_state
[2]: http://en.wikipedia.org/wiki/Elm_(programming_language)
