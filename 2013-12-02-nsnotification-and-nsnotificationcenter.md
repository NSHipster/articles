---
title: "NSNotification &<br/>NSNotificationCenter"
author: Mattt Thompson
category: Cocoa
tags: popular
excerpt: "Any idea is inextricably linked to how its communicated. A medium defines the form and scale of significance in such a way to shape the very meaning of an idea. Very truly, the medium is the message."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Any idea is inextricably linked to how it's communicated. A medium defines the form and scale of significance in such a way to shape the very meaning of an idea. Very truly, the medium is the message.

One of the first lessons of socialization is to know one's audience. Sometimes communication is one-to-one, like an in-person conversation, while at other times, such as a television broadcast, it's one-to-many. Not being able to distinguish between these two circumstances leads to awkward situations.

This is as true of humans as it is within a computer process. In Cocoa, there are a number of approaches to communicating between objects, with different characteristics of intimacy and coupling:

<table id="notification-center-coupling">
    <thead>
        <tr>
            <td class="empty" colspan="2" rowspan="2"></td>
            <th colspan="2">Audience</th>
        </tr>
        <tr>
            <th>Intimate (One-to-One)</th>
            <th>Broadcast (One-to-Many)</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th rowspan="2">Coupling</th>
            <th>Loose</th>
            <td>
                <ul>
                    <li>Target-Action</li>
                    <li>Delegate</li>
                    <li>Callbacks</li>
                </ul>
            </td>
            <td>
                <ul>
                    <li><tt>Notifications</tt></li>
                </ul>
            </td>
        </tr>
        <tr>
            <th>Strong</th>
            <td>
                <ul>
                    <li>Direct Method Invocation</li>
                </ul>
            </td>
            <td>
                <ul>
                    <li>Key-Value Observing</li>
                </ul>
            </td>
        </tr>
    </tbody>
</table>

We've discussed the importance of how events are communicated in APIs previously in our [article on Key-Value Observing](http://nshipster.com/key-value-observing/). This week, we'll expand our look at the available options, with `NSNotificationCenter` & `NSNotification`.

* * *

`NSNotificationCenter` provides a centralized hub through which any part of an application may notify and be notified of changes from any other part of the application. Observers register with a notification center to respond to particular events with a specified action. Each time an event occurs, the notification goes through its dispatch table, and messages any registered observers for that event.

> Each running Cocoa program manages its own default notification center, so it's unusual for a new notification center to be instantiated separately.

Each `NSNotification` object has a `name`, with additional context optionally provided by an associated `object` and `userInfo` dictionary.

For example, `UITextField` posts an `NSNotification` with the name `UITextFieldTextDidChangeNotification` each time its text changes. The object associated with that notification is the text field itself. In the case of `UIKeyboardWillShowNotification`, frame positioning and animation timing are passed in `userInfo`, while the notification's associated `object` is `nil`.

### Adding Observers

All sorts of notifications are constantly passing through `NSNotificationCenter`.<sup>*</sup>  But like a tree falling in the woods, a notification is moot unless there's something listening for it.

The traditional way to add an observer is `–addObserver:selector:name:object:`, in which an object (usually `self`) adds itself to have the specified selector performed when a matching notification is posted.

The modern, block-based API for adding notification observers is `–addObserverForName:object:queue:usingBlock:`. Instead of registering an existing object as an observer for a notification, this method creates its own anonymous object to be the observer, which performs a block on the specified queue (or the calling thread, if `nil`) when a matching notification is posted. Unlike its similarly named `@selector`-based counterpart, this method actually returns the constructed observer object, which is necessary for unregistering the observer, as discussed in the next section.

> Contrary to a recent article claiming otherwise, `–addObserverForName:object:queue:usingBlock:` should _not_ be considered harmful. It's perfectly safe and suitable for use in applications. Just make sure to understand memory management rules when referencing `self` in blocks. Any concerns in this respect are the same as for any other block-based API.

The `name` and `object` parameters of both methods are used to decide whether the criteria of a posted notification match the observer. If `name` is set, only notifications with that name will trigger, but if `nil` is set, then _all_ names will match. The same is true of `object`. So, if both `name` and `object` are set, only notifications with that name _and_ the specified object will trigger. However, if both `name` and `object` are `nil`, then _all_ notifications posted will trigger.

> <sup>*</sup>See for yourself! An ordinary iOS app fires dozens of notifications just in the first second of being launched—many that you've probably never heard of before, nor will ever have to think about again.

~~~{swift}
let center = NSNotificationCenter.defaultCenter()
center.addObserverForName(nil, object: nil, queue: nil) { notification in
    print("\(notification.name): \(notification.userInfo ?? [:])")
}
~~~
~~~{objective-c}
NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
[center addObserverForName:nil
                    object:nil
                     queue:nil
                usingBlock:^(NSNotification *notification)
{
     NSLog(@"%@", notification.name);
}];
~~~

### Removing Observers

It's important for objects to remove observers before they're deallocated, in order to prevent further messages from being sent.

There are two methods for removing observers: `-removeObserver:` and `-removeObserver:name:object:`. Again, just as with adding observers, `name` and `object` are used to define scope. `-removeObserver:`, or `-removeObserver:name:object` with `nil` for both parameters, will remove the observer from the notification center dispatch table entirely, while specifying parameters for `-removeObserver:name:object:` will only remove the observer for registrations with that name and/or object.

### Posting Notifications

Of course, consuming is but one side of the story. In addition to subscribing to system-provided notifications, applications may want to publish and subscribe to their own.

Notifications are created with `+notificationWithName:object:userInfo:`.

Notification names are generally defined as string constants. Like any string constant, it should be declared `extern` in a public interface, and defined privately in the corresponding implementation. It doesn't matter too much what a notification name's value is defined to be; the name of the variable itself is commonplace, but a reverse-DNS identifier is also a classy choice. So long as notification names are unique (or explicitly aliased), everything will work as expected.

Keys for `userInfo` should likewise be defined as string constants. It's important to clearly document the expected kinds of values for each key, since the compiler can't enforce constraints on dictionaries the same way it can for an object. 

~~~{swift}
class FooController : UIViewController {
    enum Notifications {
        static let FooDidBar    = "XXFooDidBarNotification"
        static let FooDidBazoom = "XXFooDidBazoomNotification"
    }

    // ...
}
~~~
~~~{objective-c}
// Foo.h
extern NSString * const XXFooDidBarNotification;

// Foo.m
NSString * const XXFooDidBarNotification = @"XXFooDidBarNotification";
~~~

Notifications are posted with `–postNotificationName:object:userInfo:` or its convenience method `–postNotificationName:object:`, which passes `nil` for `userInfo`. `–postNotification:` is also available, but it's generally preferable to have the notification object creation handled by the method itself.

Recall from the previous section how `name` and `object` act to scope notification dispatch. Developers are advised to be consistent in how objects are posted with notifications, and to have this behavior documented clearly in the public interface.

Since notification dispatch happens on the posting thread, it may be necessary to `dispatch_async` to `dispatch_get_main_queue()` so that a notification is handled on the main thread. This is not usually necessary, but it's important to keep in mind.

## KVO != NSNotificationCenter

Something that often slips up developers is how similar the method signatures for [Key-Value Observing](http://nshipster.com/key-value-observing/) are to those of `NSNotificationCenter`:

#### Key-Value Observing

~~~{swift}
func addObserver(observer: NSObject, forKeyPath keyPath: String, 
    options: NSKeyValueObservingOptions, 
    context: UnsafeMutablePointer<Void>)
~~~
~~~{objective-c}
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context
~~~

#### NSNotificationCenter

~~~{swift}
func addObserver(observer: AnyObject, 
    selector aSelector: Selector,
    name aName: String?, 
    object anObject: AnyObject?)

func addObserverForName(name: String?, 
    object obj: AnyObject?,
    queue: NSOperationQueue?, 
    usingBlock block: (NSNotification) -> Void) -> NSObjectProtocol
~~~
~~~{objective-c}
- (void)addObserver:(id)notificationObserver
           selector:(SEL)notificationSelector
               name:(NSString *)notificationName
             object:(id)notificationSender

- (id)addObserverForName:(NSString *)name
                  object:(id)obj
                   queue:(NSOperationQueue *)queue
              usingBlock:(void (^)(NSNotification *))block
~~~

**Key-Value Observing adds observers for keypaths, while NSNotificationCenter adds observers for notifications.** Keep this distinction clear in your mind, and proceed to use both APIs confidently.

* * *

Notifications are an essential tool for communicating across an application. Because of its distributed, low-coupling characteristics, notifications are well-suited to a wide range of architectures. APIs would do well to add them for any significant events that might benefit from greater circulation—the performance overhead for this sort of chattiness is negligible.

As it were, thinking about notifications in your own life can do wonders for improving your relationships with others. Communicating intent and giving sufficient notice are the trappings of a mature, grounded individual.

...but don't take that advice too far and use it to justify life-streaming, or anything. Seriously, stop taking pictures, and just eat your damn food, _amiright_?
