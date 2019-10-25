---
title: Apple Push Notification Device Tokens
author: Mattt
category: Cocoa
excerpt: >-
  Precedent plays an important role throughout software engineering.
  So what does a change in iOS 13 to push notification registration
  have to say about Apple's API design decisions?
status:
  swift: 5.1
---

In law,
the latin phrase
<dfn lang="la">stare decisis</dfn> (_"to stand by things decided"_)
is often used to refer to the doctrine of precedent ---
the idea that,
when deciding a case,
a court should look to previous decisions made
for cases with similar facts and scenarios.
This principle serves as a foundation of the American legal system,
and the English common law from which it derives.

For example,
consider [_Apple v. Pepper_][apple v. pepper],
which was argued before the Supreme Court of the United States
in its most recent session
and sought to settle the following question:

> If Apple and its App Store constitute a monopoly,
> can consumers sue Apple for offering apps at higher-than-competitive prices,
> even when the prices are set by third-party developers?

In its decision,
the Court relied on precedent set in 1977
by a case known as [_Illinois Brick_][illinois brick],
which itself affirmed a ruling made a decade earlier
in a case called [_Hanover Shoe_][hanover shoe].
On its face,
iPhones in 2010's would seem to have little to do with bricks from the 1970's
_(aside from the [obvious connotation](https://www.theiphonewiki.com/wiki/Brick))_,
but within the context of
[United States antitrust law](https://en.wikipedia.org/wiki/United_States_antitrust_law),
the connection between the two was inescapable.

{% info %}

Of course, there are _many_ other cases
that offer simpler and more comprehensive illustrations of
the role of precedent in American jurisprudence,
but we figured this one would be the least likely to cause readers to think
that NSHipster got acqui-hired by
[Atrium](https://www.atrium.co) or something.

{% endinfo %}

Adherence to precedence confers inertia in the decision-making process.
It promotes stability throughout the legal system
and the institutions that rely on a consistent application of laws.

However,
like inertia,
precedence can also be overcome with sufficiently compelling reasons;
we are bound by the past only insofar as to give it due consideration.

---

Bearing all of that in mind,
let's [<dfn>smash cut</dfn>](https://en.wikipedia.org/wiki/Smash_cut)
to our subject for this week's brief:
<dfn>Apple Push Notification Device Tokens</dfn> ---
and in particular,
a single change in iOS 13 that may incidentally break push notifications
for thousands of apps.

## A Push Notifications Primer

Push notifications allow apps to communicate with users
in response to remote events when they aren't currently in use.

Unlike SMS or email,
which allows a sender to communicate with a recipient directly
using a unique identifier (a phone number and email address, respectively),
communication between the app's remote server and the user's local device
are facilitated by the Apple Push Notification service
(<abbr title="Apple Push Notification service">APNs</abbr>).

Here's how that works:

- After launching an app,
  the app calls the method
  [`registerForRemoteNotifications()`](https://developer.apple.com/documentation/uikit/uiapplication/1623078-registerforremotenotifications),
  prompting the user to grant the app permission to send push notifications.
- In response to permission being granted,
  the app delegate calls the method
  [`application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622958-application).

The `deviceToken` parameter in the app delegate method
is an opaque `Data` value ---
kind of like a really long unique phone number or email address ---
that the app's push notification provider uses
to route notifications through APNs to reach
this particular installation of the app.

In principle,
representing this parameter as a `Data` value makes a lot of sense ---
the value itself is meaningless.
However, in practice,
this API design decision has been the source of untold amounts of heartache.

## The Enduring Challenges of Sending Device Tokens Back to the Server

When the app delegate receives its `deviceToken`,
that's not the end of the story.
In order for its to be used to send push notifications,
it needs to be sent from the client to the server.

The question is, _"How"_?

Before you jump to a particular answer,
consider the historical context of iOS 3 (circa 2009),
when push notifications were first introduced:

### _"Back in My Day..."_

You could create an [`NSURLRequest`](https://developer.apple.com/documentation/foundation/nsurlrequest) object,
set its `httpBody` property to the `deviceToken`,
and send it using [`NSURLConnection`](https://developer.apple.com/documentation/foundation/nsurlconnection),
but you'd probably also want to include some additional information ---
like a username or email address ---
to associate it with an account in the app.
That meant that the `data` you set as a request's HTTP body
couldn't just be the device token.

Sending an HTTP `POST` body with`application/x-www-form-urlencoded`
(e.g. `username=jappleseed&deviceToken=____`)
is one possibility for encoding multiple fields into a single payload,
but then the question becomes,
_"How do you encode binary data into text?"_

[Base64](https://en.wikipedia.org/wiki/Base64)
is a great binary-to-text encoding strategy,
but [`NSData -base64EncodedStringWithOptions:`](https://developer.apple.com/documentation/foundation/nsdata/1413546-base64encodedstringwithoptions?language=objc)
wouldn't be available until iOS 7,
four years after push notifications were first introduced in iOS 3.
Without [CocoaPods](/cocoapods/) or a strong open-source ecosystem
to fill in the gaps,
you were left to follow
[blog posts](https://www.cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html)
describing how to roll your own implementation,
hoping that things would work as advertised.

{% info %}

In retrospect,
probably the best answer
(at least in terms of taking advantage of built-in functionality)
would be to serialize an `NSDictionary`
containing the device token and other information
into a property list.

Then again,
support for `.plist` files server-side is historically thin.
So maybe that wouldn't have been any better, after all...

{% endinfo %}

Given the complexity in using Base64 encoding on iOS < 7,
most developers instead opted to take advantage of
what they saw as an easier, built-in alternative:

### NSData, in its Own Words

Developers,
in an attempt to understand what exactly
this `deviceToken` parameter was,
would most likely have passed it into an `NSLog` statement:

```obj-c
NSLog(@"%@", deviceToken);
// Prints "<965b251c 6cb1926d e3cb366f dfb16ddd e6b9086a 8a3cac9e 5f857679 376eab7C>"
```

Unfortunately,
for developers less versed in matters of data and encoding,
this output from `NSLog` may have led them astray:  
_"Oh wow, so `deviceToken` is actually a string!
(I wonder why Apple was making this so difficult in the first place).
But no matter --- I can take it from here."_

```obj-c
// ⚠️ Warning: Don't do this
NSString *token = [[[[deviceToken description]
                    stringByReplacingOccurrencesOfString:@" " withString:@""]
                    stringByReplacingOccurrencesOfString:@"<" withString:@""]
                    stringByReplacingOccurrencesOfString:@">" withString:@""];
```

It's unclear whether push notification service providers spurred this practice
by requiring Base16 / hexadecimal representations from the beginning,
or if they adopted it in response to how folks were
already accustomed to doing it,
but either way,
the practice stuck.
And for nearly a decade,
this was how a significant percentage of apps were handling
push notification device token registration.

That was until Swift 3 and iOS 10.

{% info %}

Granted,
there's no single, canonical way to represent binary data as text ---
the same token could be represented in Base64 as
`"llslHGyxkm3jyzZv37Ft3ea5CGqKPKyeX4V2eTduq3w="`
or in [Ascii85 encoding](https://en.wikipedia.org/wiki/Ascii85) as
`"Q<PXTCpB.?j3'?!hm%%Sk.(b4MEIu3?\NZK2f>[D"`
or in [Base🧑 encoding](https://github.com/Flight-School/Guide-to-Swift-Strings-Sample-Code#base-encoding) as
`"👩🏻‍🦱👩🏻‍🦱👩🏼‍🦳👩🏻‍🦱👨🏻‍🦱👨🏻‍🦰👩🏾👩🏽‍🦳👩🏻‍🦰👩🏻‍🦲👩🏿👩🏻👩🏾👩🏾‍🦰👨🏿👩🏽‍🦱👩🏿👩🏿‍🦳👨🏻👩🏽👩🏿👩👨🏿‍🦰👩🏿‍🦱👨‍🦱👨🏻‍🦰👩🏼‍🦱👨🏼👨🏽👨🏼👩🏾👩👨🏾‍🦲👩🏿‍🦰👨🏾‍🦰👩🏾‍🦳👩👨🏽‍🦳👨🏿‍🦳👩🏽‍🦰👩🏼‍🦱👩🏿👩🏽‍🦲🤡"`.
But if your push notification service provider expects device tokens
in its classic, Base16 hexadecimal string representation,
you should do adopt the approach described above.

{% endinfo %}

### Relitigating the Past with Swift 3

By 2016,
Swift had stabilized and matured to the point that
most if not many developers were choosing to write new apps in Swift,
or at least write all new code in Swift for existing apps.

For those who did,
the transition to Swift 3
was most memorable for its painful migration from Swift 2.
As part of ["the grand API renaming"](https://github.com/apple/swift-evolution/blob/master/proposals/0005-objective-c-name-translation.md)
common Foundation types, including `NSData`,
dropped their `NS` prefix in APIs,
using a bridged, Swift value type in its place.
For the most part,
things worked as expected.
But there were a few differences in behavior ---
largely _undocumented or incidental behavior_
that caused a breaking change.
For example,
consider the following change in
`application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`:

```swift
// Swift 2: deviceToken is NSData
deviceToken.description // "<965b251c 6cb1926d e3cb366f dfb16ddd e6b9086a 8a3cac9e 5f857679 376eab7C>"

// Swift 3: deviceToken is Data
deviceToken.description // "32 bytes"
```

However,
many developers remained undeterred by what was seen as a minor annoyance,
and worked around the issue by recasting to `NSData` and its former behavior:

```swift
// ⚠️ Warning: Don't do this
let tokenData = deviceToken as NSData
let token = tokenData.description

let token = "\(deviceToken)".replacingOccurrences(of: " ", with: "")
                            .replacingOccurrences(of: "<", with: "")
                            .replacingOccurrences(of: ">", with: "")
```

Once again,
doing things the wrong way
managed to keep things working for another couple years.

But that's all coming to an end with iOS 13.

{% warning %}

The impact of this change is significant,
and bears repeating:

If your implementation of
`application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
involves converting `deviceToken` to a `String`
and calling `replacingOccurrences(of:with:)`,
this approach won't work in apps compiled with the iOS 13 SDK.
This is true whether your app is written in Swift or Objective-C.

{% endwarning %}

### Overturned in iOS 13

iOS 13 changes the format of descriptions
for Foundation objects,
including `NSData`:

```swift
// iOS 12
(deviceToken as NSData).description // "<965b251c 6cb1926d e3cb366f dfb16ddd e6b9086a 8a3cac9e 5f857679 376eab7C>"

// iOS 13
(deviceToken as NSData).description // "{length = 32, bytes = 0x965b251c 6cb1926d e3cb366f dfb16ddd ... 5f857679 376eab7c }"
```

Whereas previously,
you could coerce `NSData` to spill its entire contents
by converting it into a `String`,
it now reports its length and a truncated summary of its internal bytes.

So from now on,
if you need to convert your push notification registration `deviceToken`
into a Base16-encoded / hexadecimal string representation,
you should do the following:

```swift
let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
```

For clarity, let's break this down and explain each part:

- The `map` method operates on each element of a sequence.
  Because `Data` is a sequence of bytes in Swift,
  the passed closure is evaluated for each byte in `deviceToken`.
- The [`String(format:)`](https://developer.apple.com/documentation/swift/string/3126742-init) initializer
  evaluates each byte in the data
  (represented by the anonymous parameter `$0`)
  using the [`%02x` format specifier](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html),
  to produce a zero-padded, 2-digit hexadecimal representation of
  the byte / 8-bit integer.
- After collecting each byte representation created by the `map` method,
  `joined()` concatenates each element into a single string.

{% info %}

We'd have preferred to use the `String(_:radix:)` initializer
to create a hexadecimal (radix = 16) string representation
for each `UInt8` byte value,
but without a built-in [left-pad](https://www.theregister.co.uk/2016/03/23/npm_left_pad_chaos/) function
in the Swift standard library
to zero-pad to two digits,
we opted for `printf` format specifiers
([despite our misgivings](/expressiblebystringinterpolation/)).

On Stack Overflow,
[the top-rated answer](https://stackoverflow.com/a/24979958/157142)
advocates for `"%02.2hhx"` instead of `"%02x"`.
It's easy to get lost in the
[IEEE specification](http://www.opengroup.org/onlinepubs/009695399/functions/printf.html),
so here are some minimal code examples to demonstrate the difference
between the two format specifiers:

```swift
// Overflow UInt.max (255)
String(format: "%02.2hhx", 256) // "00"
String(format: "%02x", 256) // "100"

// Underflow UInt.min (0)
String(format: "%02.2hhx", -1) // "ff"
String(format: "%02x", -1) // "ffffffff"
```

`"%02.2hhx"` guarantees that values beyond the range of `UInt`
produce two hexadecimal digits
(though one could argue whether it's better to fail silently here).

But any difference in behavior is moot,
so long as `Data` is a collection whose `Element` is `UInt8`:

```swift
(UInt.min...UInt.max).map {
    String(format: "%02.2hhx", $0) == String(format: "%02x", $0)
}.contains(false) // false
```

Oh, and don't worry about any purported performance differences
between `reduce` and `map` + `join`;
any Δ is going to be negligible,
and totally irrelevant for an infrequent operation such as this.

{% endinfo %}

---

Was Apple irresponsible in making this particular change? \\
We'd argue: _No, not really._

**Developers shouldn't have relied on a specific format for
an object's [`description`](https://developer.apple.com/documentation/objectivec/nsobjectprotocol/1418746-description)**.

Dumping an entire `Data` value's contents becomes untenable at a certain point,
and this change to a more succinct summary
makes debugging larger data blobs significantly easier.

---

Like we said about laws at the start of this article,
precedence is a form of inertia,
not an immutable truth.

<em lang="la">Stare decisis</em> plays an important role
throughout software engineering.
Examples like the ["Referer" \[sic\] header"](https://en.wikipedia.org/wiki/HTTP_referer) ---
even the conventions we have about
[the direction of electricity flow](https://en.wikipedia.org/wiki/Electric_current#Conventions) ---
demonstrate the value of sticking to decisions,
unless an opportunity arises to compel change.

[apple v. pepper]: https://www.oyez.org/cases/2018/17-204 "Apple v. Pepper, 587 U.S. ___ (2019)"
[illinois brick]: https://www.oyez.org/cases/1976/76-404 "Illinois Brick Co. v. Illinois, 431 U.S. 720 (1977)"
[hanover shoe]: https://www.oyez.org/cases/1967/335 "Hanover Shoe, Inc. v. United Shoe Machinery Corporation, 392 US 481 (1968)"
