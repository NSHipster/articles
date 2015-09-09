---
title: Key-Value Observing
author: Mattt Thompson
category: Cocoa
tag: nshipster, popular
excerpt: "Ask anyone who's been around the NSBlock a few times: Key-Value Observing has the _worst_ API in all of Cocoa. It's awkward, verbose, and confusing. And worst of all, its terrible API belies one of the most compelling features of the framework."
status:
    swift: t.b.c.
---

Ask anyone who's been around the NSBlock a few times: Key-Value Observing has the _worst_ API in all of Cocoa. It's awkward, verbose, and confusing. And worst of all, its terrible API belies one of the most compelling features of the framework.

When dealing with complicated, stateful systems, dutiful book-keeping is essential for maintaining sanity. Lest the left hand not know what the right hand doeth, objects need some way to publish and subscribe to state changes over time.

In Objective-C and Cocoa, there are a number of ways that these events are communicated, each with varying degrees of formality and coupling:

- **`NSNotification`** & **`NSNotificationCenter`** provide a centralized hub through which any part of an application may notify and be notified of changes from any other part of the application. The only requirement is to know what to look for, specifically in the name of the notification. For example, `UIApplicationDidReceiveMemoryWarningNotification
` signals a low memory environment in an application.
- **Key-Value Observing** allows for ad-hoc, evented introspection between specific object instances by listening for changes on a particular key path. For example, a `UIProgressView` might observe the `numberOfBytesRead` of a network request to derive and update its own `progress` property.
- **Delegates** are a popular pattern for signaling events over a fixed set of methods to a designated handler. For example, `UIScrollView` sends `scrollViewDidScroll:` to its delegate each time its scroll offset changes.
- **Callbacks** of various sorts, whether block properties like `NSOperation -completionBlock`, which trigger after `isFinished == YES`, or C function pointers passed as hooks into functions like `SCNetworkReachabilitySetCallback(3)`.

Of all of these methods, Key-Value Observing is arguably the least well-understood. So this week, NSHipster will endeavor to provide some much-needed clarification and notion of best practices to this situation. To the casual observer, this may seem an exercise in futility, but subscribers to this publication know better.

---

`<NSKeyValueObserving>`, or KVO, is an informal protocol that defines a common mechanism for observing and notifying state changes between objects. As an informal protocol, you won't see classes bragging about their conformance to it (it's just implicitly assumed for all subclasses of `NSObject`).

The main value proposition of KVO is rather compelling: any object can subscribe to be notified about state changes in any other object. Most of this is built-in, automatic, and transparent.

> For context, similar manifestations of this observer pattern are the secret sauce of most modern Javascript frameworks, such as [Backbone.js](http://backbonejs.org) and [Ember.js](http://emberjs.com).

## Subscribing

Objects can have observers added for a particular key path, which, as described in [the KVC operators article](http://nshipster.com/kvc-collection-operators/), are dot-separated keys that specify a sequence of properties. Most of the time with KVO, these are just the top-level properties on the object.

The method used to add an observer is `–addObserver:forKeyPath:options:context:`:

~~~{objective-c}
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context
~~~

> - `observer`:  The object to register for KVO notifications. The observer must implement the key-value observing method observeValueForKeyPath:ofObject:change:context:.
> - `keyPath`: The key path, relative to the receiver, of the property to observe. This value must not be `nil`.
> - `options`: A combination of the `NSKeyValueObservingOptions` values that specifies what is included in observation notifications. For possible values, see "NSKeyValueObservingOptions".
> - `context`: Arbitrary data that is passed to `observer` in `observeValueForKeyPath:ofObject:change:context:`.

Yuck. What makes this API so unsightly is the fact that those last two parameters are almost always `0` and `NULL`, respectively.

`options` refers to a bitmask of `NSKeyValueObservingOptions`. Pay particular attention to `NSKeyValueObservingOptionNew` & `NSKeyValueObservingOptionOld` as those are the options you'll most likely use, if any. Feel free to skim over `NSKeyValueObservingOptionInitial` & `NSKeyValueObservingOptionPrior`:

### NSKeyValueObservingOptions

> - `NSKeyValueObservingOptionNew`: Indicates that the change dictionary should provide the new attribute value, if applicable.
> - `NSKeyValueObservingOptionOld`: Indicates that the change dictionary should contain the old attribute value, if applicable.
> - `NSKeyValueObservingOptionInitial`: If specified, a notification should be sent to the observer immediately, before the observer registration method even returns.
The change dictionary in the notification will always contain an `NSKeyValueChangeNewKey` entry if `NSKeyValueObservingOptionNew` is also specified but will never contain an `NSKeyValueChangeOldKey` entry. (In an initial notification the current value of the observed property may be old, but it's new to the observer.) You can use this option instead of explicitly invoking, at the same time, code that is also invoked by the observer's `observeValueForKeyPath:ofObject:change:context:` method. When this option is used with `addObserver:forKeyPath:options:context:` a notification will be sent for each indexed object to which the observer is being added.
- `NSKeyValueObservingOptionPrior`: Whether separate notifications should be sent to the observer before and after each change, instead of a single notification after the change.
The change dictionary in a notification sent before a change always contains an `NSKeyValueChangeNotificationIsPriorKey` entry whose value is `@YES`, but never contains an `NSKeyValueChangeNewKey` entry. When this option is specified the change dictionary in a notification sent after a change contains the same entries that it would contain if this option were not specified. You can use this option when the observer's own key-value observing-compliance requires it to invoke one of the `-willChange...` methods for one of its own properties, and the value of that property depends on the value of the observed object's property. (In that situation it's too late to easily invoke `-willChange...` properly in response to receiving an `observeValueForKeyPath:ofObject:change:context:` message after the change.)

These options allow an object to get the values before and after the change. In practice, this is usually not necessary, since the new value is generally available from the current value of the property.

That said, `NSKeyValueObservingOptionInitial` can be helpful for reducing the code paths when responding to KVO events. For instance, if you have a method that dynamically enables a button based on the `text` value of a field, passing `NSKeyValueObservingOptionInitial` will have the event fire with its initial state once the observer is added.

As for `context`, this parameter is a value that can be used later to differentiate between observations of different objects with the same key path. It's a bit complicated, and will be discussed later.

## Responding

Another aspect of KVO that lends to its ugliness is the fact that there is no way to specify custom selectors to handle observations, as one might be used to from the Target-Action pattern used by controls.

Instead, all changes for observers are funneled through a single method—`-observeValueForKeyPath:ofObject:change:context:`:

~~~{objective-c}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
~~~

Those parameters are the same as what were specified in `–addObserver:forKeyPath:options:context:`, with the exception of `change`, which are populated from whichever `NSKeyValueObservingOptions` `options` were used.

A typical implementation of this method looks something like this:

~~~{objective-c}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:@"state"]) {
    // ...
  }
}
~~~

Depending on how many kinds of objects are being observed by a single class, this method may also introduce `-isKindOfObject:` or `-respondsToSelector:` in order to definitively identify the kind of event being passed. However, the safest method is to do an equality check to `context`—especially when dealing with subclasses whose parents observe the same keypath.

### Correct Context Declarations

What makes a good `context` value? Here's a suggestion:

~~~{objective-c}
static void * XXContext = &XXContext;
~~~

It's that simple: a static value that stores its own pointer. It means nothing on its own, which makes it rather perfect for `<NSKeyValueObserving>`:

~~~{objective-c}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if (context == XXContext) {
      if ([keyPath isEqualToString:NSStringFromSelector(@selector(isFinished))]) {

      }
  }
}
~~~

### Better Key Paths

Passing strings as key paths is strictly worse than using properties directly, as any typo or misspelling won't be caught by the compiler, and will cause things to not work.

A clever workaround to this is to use `NSStringFromSelector` and a `@selector` literal value:

~~~{objective-c}
NSStringFromSelector(@selector(isFinished))
~~~

Since `@selector` looks through all available selectors in the target, this won't prevent all mistakes, but it will catch most of them—including breaking changes made by Xcode automatic refactoring.

~~~{objective-c}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isKindOfClass:[NSOperation class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(isFinished))]) {

        }
    } else if (...) {
        // ...
    }
}
~~~

## Unsubscribing

When an observer is finished listening for changes on an object, it is expected to call `–removeObserver:forKeyPath:context:`. This will often either be called in `-observeValueForKeyPath:ofObject:change:context:`, or `-dealloc` (or a similar destruction method).

### Safe Unsubscribe with `@try` / `@catch`

Perhaps the most pronounced annoyance with KVO is how it gets you at the end. If you make a call to `–removeObserver:forKeyPath:context:` when the object is _not_ registered as an observer (whether because it was already unregistered or not registered in the first place), an exception is thrown. The kicker is that _there's no built-in way to even check if an object is registered_!

Which causes one to rely on a rather unfortunate cudgel `@try` with an unhandled `@catch`:

~~~{objective-c}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isFinished))]) {
        if ([object isFinished]) {
          @try {
              [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished))];
          }
          @catch (NSException * __unused exception) {}
        }
    }
}
~~~

Granted, _not_ handling a caught exception, as in this example, is waving the `[UIColor whiteColor]` flag of surrender. Therefore, one should only really use this technique when faced with intermittent crashes which cannot be remedied by normal book-keeping (whether due to race conditions or undocumented behavior from a superclass).

## Automatic Property Notifications

KVO is made useful by its near-universal adoption. Because of this, much of the work necessary to get everything hooked up correctly is automatically taken care of by the compiler and runtime.

> Classes can opt-out of automatic KVO by overriding `+automaticallyNotifiesObserversForKey:` and returning `NO`.

But what about compound or derived values? Let's say you have an object with a `@dynamic`, `readonly` `address` property, which reads and formats its `streetAddress`, `locality`, `region`, and `postalCode`?

Well, you can implement the method `keyPathsForValuesAffectingAddress` (or its less magical catch-all, `+keyPathsForValuesAffectingValueForKey:`):

~~~{objective-c}
+ (NSSet *)keyPathsForValuesAffectingAddress {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(streetAddress)), NSStringFromSelector(@selector(locality)), NSStringFromSelector(@selector(region)), NSStringFromSelector(@selector(postalCode)), nil];
}
~~~

---

So there you have it: some general observations and best practices for KVO. To an enterprising NSHipster, KVO can be a powerful substrate on top of which clever and powerful abstractions can be built. Use it wisely, and understand the rules and conventions to make the most of it in your own application.
