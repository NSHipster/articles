---
title: "NSNotification &<br/>NSNotificationCenter"
author: Mattt
category: Cocoa
tags: popular
excerpt: "Any idea is inextricably linked to how it's communicated. A medium defines the form and scale of significance in such a way to shape the very meaning of an idea. Very truly, the medium is the message."
revisions:
  "2013-12-02": Original publication
  "2026-10-09": Rewritten for Swift 6.2 and iOS 26
status:
  swift: 6.2
  reviewed: October 9, 2026
---

Any idea is inextricably linked to how it's communicated.
A medium defines the form and scale of significance
in such a way to shape the very meaning of an idea.
Very truly, the medium is the message.

One of the first lessons of socialization is to know one's audience.
Sometimes communication is one-to-one, like an in-person conversation,
while at other times, such as a television broadcast, it's one-to-many.
Not being able to distinguish between these two circumstances
leads to awkward situations.

This is as true of humans as it is within a computer process.
In Cocoa, there are a number of approaches to communicating between objects,
with different characteristics of intimacy and coupling:

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
                    <li>Closures</li>
                </ul>
            </td>
            <td>
                <ul>
                    <li><code>Notifications</code></li>
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
                    <li>Observation</li>
                </ul>
            </td>
        </tr>
    </tbody>
</table>

We've discussed the importance of how events are communicated in APIs previously
in our [article on Key-Value Observing](/key-value-observing/).
This week, we'll take a look at the broadcast option,
`NotificationCenter`,
and see how a Cocoa mainstay has adapted to life in Swift 6.

* * *

`NotificationCenter` provides a centralized hub
through which any part of an app may notify
and be notified of changes from any other part of the app.
Observers register with a notification center
to respond to particular events with a specified action.
Each time an event occurs,
the notification center goes through its dispatch table
and messages any registered observers for that event.

Each `Notification` has a `name`,
with additional context optionally provided by
an associated `object` (usually the sender)
and a `userInfo` dictionary.
For example,
`UITextField` posts a `UITextField.textDidChangeNotification`
each time its text changes,
with the text field itself as the `object`.
`UIResponder.keyboardWillShowNotification`, on the other hand,
passes the keyboard's frame and animation timing in `userInfo`.

Every app has a default notification center,
`NotificationCenter.default`,
and it's unusual to need another one.

{% info do %}

If you came to this article from Objective-C,
everything here should look familiar under new names.
`NSNotificationCenter` became `NotificationCenter`,
`NSNotification` got a `Notification` value type,
and `+defaultCenter` became `NotificationCenter.default` in Swift 3.
Notification names, once declared as `extern NSString * const` constants,
are now imported as `Notification.Name`,
a `RawRepresentable` wrapper around those very same strings.
The Objective-C API is still there underneath,
which explains a few of the quirks we'll encounter.

{% endinfo %}

## When to Use Notifications

Notifications are a megaphone.
The poster doesn't know who's listening, or whether anyone is.
It can't get an answer back,
and it doesn't decide what order its listeners hear things in.
That's a feature when you're announcing that something happened
to an audience you can't (or shouldn't) know about in advance:
the app moved to the background,
the user's locale changed,
a sync finished.

For most other kinds of communication,
you'll want something more direct:

- If exactly one object needs to respond,
  or the sender needs an answer
  (_"Should this row be selectable?"_),
  use a **delegate**.
- If a caller wants to know when a particular operation finishes,
  pass a **closure** or make the function `async`.
- If views need to stay in sync with changing state,
  reach for **Observation**
  and the `@Observable` macro.
  Notifications describe events, not state;
  a "user did change" notification is usually a sign
  that someone wanted an observable property.

## Naming Notifications

Declare notification names as static constants
in an extension on `Notification.Name`:

```swift
extension Notification.Name {
    static let kettleDidBoil = Notification.Name("KettleDidBoilNotification")
}
```

Names compare by their raw string value,
so the string needs to be unique across your app
and every framework it links.
Spelling out the constant's own name is a fine choice;
a reverse-DNS identifier is also a classy one.

## Posting Notifications

Post a notification with `post(name:object:userInfo:)`,
passing the sender as `object`
and any additional information in `userInfo`:

```swift
final class Kettle {
    static let temperatureKey = "temperature"

    func boil() {
        // ...
        NotificationCenter.default.post(name: .kettleDidBoil,
                                        object: self,
                                        userInfo: [Kettle.temperatureKey: 100.0])
    }
}
```

`userInfo` is typed `[AnyHashable: Any]?`,
so the compiler can't help you here.
Define constants for its keys
and document the type of value that each one holds.
Developers are also advised to be consistent
in what they pass as `object`,
since observers use it to filter notifications.

## Observing Notifications

All sorts of notifications are constantly passing through `NotificationCenter`.<sup>*</sup>
But like a tree falling in the woods,
a notification is moot unless there's something listening for it.

There are two traditional ways to listen,
and they differ in an important way when it comes to cleaning up.

### Selector-Based Observers

The original API is `addObserver(_:selector:name:object:)`,
in which an object (usually `self`) registers to have
an `@objc` method called when a matching notification is posted:

```swift
import UIKit

final class TeaViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(kettleDidBoil(_:)),
                                               name: .kettleDidBoil,
                                               object: nil)
    }

    @objc func kettleDidBoil(_ notification: Notification) {
        guard let temperature = notification.userInfo?[Kettle.temperatureKey] as? Double
        else { return }
        // Pour tea at temperature...
    }
}
```

The `name` and `object` parameters determine which notifications match.
If `name` is set, only notifications with that name trigger the observer;
if it's `nil`, _all_ names match.
The same goes for `object`.
So passing `nil` for both
gets you every notification posted to that center.

It used to be a cardinal rule of Cocoa
that you remove observers before they're deallocated,
lest the notification center message a dangling pointer.
That's no longer the case.
Apple's documentation states that if your app targets
iOS 9 or macOS 10.11 and later,
you don't need to unregister an observer
added with `addObserver(_:selector:name:object:)`;
the system cleans up the next time it would have posted to it.

### Block-Based Observers

The other option is `addObserver(forName:object:queue:using:)`,
which takes a closure instead of a target and selector.
Rather than registering an existing object,
this method creates an observer object for you and returns it,
and that return value is how you unregister later.

Unlike selector-based observers,
these aren't cleaned up automatically.
The notification center strongly holds both the returned object
and the closure until you call `removeObserver(_:)`.
Forget to, and the closure keeps running
(along with anything it captured)
long after the object that registered it has gone.
Capture `self` weakly,
hold on to the token,
and remove it when you're done:

```swift
final class TeaViewController: UIViewController {
    private var observer: (any NSObjectProtocol)?

    override func viewDidLoad() {
        super.viewDidLoad()
        observer = NotificationCenter.default.addObserver(
            forName: .kettleDidBoil,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let temperature = notification.userInfo?[Kettle.temperatureKey] as? Double
            else { return }

            MainActor.assumeIsolated {
                self?.pour(at: temperature)
            }
        }
    }

    isolated deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func pour(at temperature: Double) { /* ... */ }
}
```

That `MainActor.assumeIsolated` and `isolated deinit`
deserve some explanation,
which we'll get to in a moment.

> <sup>*</sup>See for yourself!
> An ordinary app posts dozens of notifications
> in the first second after launch,
> many of which you've probably never heard of
> and will never have to think about again.
>
> ```swift
> let token = NotificationCenter.default.addObserver(forName: nil,
>                                                    object: nil,
>                                                    queue: nil) { notification in
>     print(notification.name.rawValue)
> }
> ```

## Threads and Actors

Posting a notification is synchronous.
`post(name:object:userInfo:)` calls each matching observer in turn
and doesn't return until they've all finished.
Selector-based observers, and block-based observers registered with a `nil` queue,
run on whatever thread posted the notification.
Pass an `OperationQueue` (such as `.main`)
to have the block run there instead.

That arrangement predates Swift concurrency,
and it shows.
Consider the examples above in the Swift 6 language mode,
where `UIViewController` is isolated to the main actor:

- The closure passed to `addObserver(forName:object:queue:using:)` is `@Sendable`,
  so the compiler treats it as running on an arbitrary thread,
  even when you've asked for `.main`.
  `MainActor.assumeIsolated` tells the compiler what you already know
  (and traps at runtime if you're wrong).
  `Notification` isn't `Sendable`,
  so pull out the values you need _before_ crossing over.
- A `deinit` is nonisolated by default,
  and can't touch a non-`Sendable` property like `observer`.
  Swift 6.2's `isolated deinit` runs the deinitializer on the main actor;
  it requires iOS 18.4, macOS 15.4, or later.
- The `@objc` thunk for a main-actor method checks its isolation at runtime.
  If something posts `.kettleDidBoil` from a background thread,
  `kettleDidBoil(_:)` won't just run on the wrong thread; it'll crash.

The usual remedy for that last one is to make sure
notifications that UI code observes are posted on the main thread.
The better remedy is an API that lets the compiler know.
We'll get there.

## Async Sequences

Since iOS 15 and macOS 12,
you can receive notifications as an `AsyncSequence`
with `notifications(named:object:)`:

```swift
let temperatures = NotificationCenter.default
    .notifications(named: .kettleDidBoil)
    .compactMap({ $0.userInfo?[Kettle.temperatureKey] as? Double })

for await temperature in temperatures {
    print("Boiled at \(temperature)°C")
}
```

There's no token to manage;
observation lasts as long as the loop does,
and the loop runs until its task is cancelled.
In SwiftUI, a `.task` modifier takes care of that for you.

Once again,
`Notification` isn't `Sendable`,
so Apple recommends using `map` or `compactMap`
to extract `Sendable` values from each notification
before they cross an actor boundary,
as we do here.

## Combine Publishers

If you're using Combine,
`publisher(for:object:)` returns a publisher
that emits each matching notification:

```swift
import Combine

var cancellables: Set<AnyCancellable> = []

NotificationCenter.default.publisher(for: .kettleDidBoil)
    .compactMap { $0.userInfo?[Kettle.temperatureKey] as? Double }
    .receive(on: DispatchQueue.main)
    .sink { temperature in
        print("Boiled at \(temperature)°C")
    }
    .store(in: &cancellables)
```

Like a selector-based observer,
the publisher emits on whatever thread posted the notification,
hence the `receive(on:)`.
Observation ends when the `AnyCancellable` is cancelled or deallocated.

## Typed Messages

For all its convenience,
`Notification` has always been a bit of a grab bag:
a stringly-typed name,
an `Any?` object,
and a dictionary of `Any` values
that you cast and hope for the best.
And as we've seen,
it carries no information about where it's posted.

iOS 26 and macOS 26 add a Swift-native alternative:
<dfn>messages</dfn>.
A message is a type that conforms to one of two protocols,
depending on how it's delivered:

`NotificationCenter.MainActorMessage`
: Posted from, and delivered synchronously on, the main actor.

`NotificationCenter.AsyncMessage`
: Posted from any isolation and delivered asynchronously.
  Messages must be `Sendable`.

Each message declares a `Subject` (the type that posts it)
and stored properties for its payload in place of `userInfo`.
Here's our kettle again:

```swift
@MainActor
final class Kettle {
    func boil() {
        // ...
        NotificationCenter.default.post(KettleDidBoil(temperature: 100),
                                        subject: self)
    }
}

struct KettleDidBoil: NotificationCenter.MainActorMessage {
    typealias Subject = Kettle

    var temperature: Double
}
```

`post(_:subject:)` for a `MainActorMessage` is itself `@MainActor`,
so the compiler won't let you post from a background thread.

To observe a message,
call `addObserver(of:for:using:)`
with a subject and the message type.
The closure is `@MainActor`,
and the message comes typed, no casting required:

```swift
let token = NotificationCenter.default.addObserver(of: kettle,
                                                   for: KettleDidBoil.self) { message in
    print("Boiled at \(message.temperature)°C")
}
```

Leave out the subject
(`addObserver(for: KettleDidBoil.self)`)
to hear from every kettle in the house.

The return value is a `NotificationCenter.ObservationToken`.
Unlike the opaque object returned by the block-based API,
observation ends automatically when this token goes away,
so you can store it in a property and forget about it.
(You can still end observation early with `removeObserver(_:)`.)
It's also `Sendable`,
so none of the `deinit` business from before applies.

For a more fluent call site,
define a <dfn>message identifier</dfn>
using `NotificationCenter.BaseMessageIdentifier`:

```swift
extension NotificationCenter.MessageIdentifier
    where Self == NotificationCenter.BaseMessageIdentifier<KettleDidBoil>
{
    static var didBoil: Self { .init() }
}

let token = NotificationCenter.default.addObserver(of: kettle, for: .didBoil) { message in
    print("Boiled at \(message.temperature)°C")
}
```

With an identifier,
you can also pass a metatype like `Kettle.self` as the subject
to observe messages from any instance of that type.

Apple's frameworks already define messages for many of their notifications,
along with identifiers like these.
Foundation's `TimeZone.SystemTimeZoneDidChangeMessage`
carries the `previousTimeZone` that you once dug out of `userInfo`:

```swift
let token = NotificationCenter.default.addObserver(of: TimeZone.self,
                                                   for: .systemTimeZoneDidChange) { message in
    let identifier = message.previousTimeZone?.identifier ?? "(unknown)"
    print("Time zone changed from \(identifier).")
}
```

These framework messages interoperate with their notification counterparts:
post the notification and message observers hear about it, and vice versa.
Your own messages can do the same by implementing
the protocol's `name`, `makeMessage(_:)`, and `makeNotification(_:)` requirements,
which is how you'd keep Objective-C code in the conversation.
Otherwise, the default `name` is derived from the message type's name,
and you never need to think about it.

`AsyncMessage` types are posted with the same `post(_:subject:)` method
from any isolation.
Their observers take an `async` closure,
and you can also receive them as an async sequence
with `messages(of:for:bufferSize:)`:

```swift
for await _ in NotificationCenter.default.messages(of: ProcessInfo.self,
                                                   for: .powerStateDidChange) {
    if ProcessInfo.processInfo.isLowPowerModeEnabled {
        // Take it easy...
    }
}
```

Because `AsyncMessage` observers run asynchronously,
they're a poor fit for anything that must happen
before the poster carries on.
If observers need to respond before `post` returns,
use a `MainActorMessage`.

* * *

Notifications are an essential tool for communicating across an app.
Because of their decoupled, one-to-many nature,
they're well-suited to announcing significant events
to anyone who might care.
And now that messages give them types and actor isolation,
they're a lot easier to use correctly.

As it were,
thinking about notifications in your own life
can do wonders for improving your relationships with others.
Communicating intent and giving sufficient notice
are the trappings of a mature, grounded individual.

...but don't take that advice too far
and use it to justify live-streaming your every waking moment.
Seriously, stop taking pictures, and just eat your damn food, _amiright_?
