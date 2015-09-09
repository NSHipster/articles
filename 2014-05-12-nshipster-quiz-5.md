---
title: "NSHipster Quiz #5"
author: Mattt Thompson
category: Trivia
excerpt: "This fifth incarnation of the NSHipster Quiz took on a distinct North-of-the-Border flavor, as part of the NSNorth conference in Ottawa, Ontario. Think you're up to the challenge, eh?"
status:
    swift: n/a
---

This past weekend, I had the honor of speaking at [NSNorth](http://nsnorth.ca/), in Ottawa, Ontario. The conference focused on the aspects of community, culture, and family in programming, and I cannot think of a conference in recent memory that better exemplified these themes, both in its speakers and attendees.

With the help of NSNorth's organizers, [Dan Byers](https://twitter.com/_danbyers) and [Philippe Casgrain](https://twitter.com/philippec), we were able to put together an NSHipster Pub Quiz. Because of time constraints, the format was a bit different than usual, with just 2 rounds instead of 4, and an activity sheet.

Nevertheless, the content was as challenging and the competition was as fierce as always, with the team led by (and named after) [Jessie Char](https://twitter.com/jessiechar) taking first place with an impressive 24 points.

As always, you can play along at home or at work with your colleagues. Here are the rules:

- There are 2 Rounds and an activity sheet, with 10 questions each
- Record answers on a separate sheet of paper
- Each correct answer to a question gets you 1 point (unless otherwise specified)
- Play with up to 5 friends for maximum enjoyment
- Don't be lame and look things up on the Internet or in Xcode

* * *

Round 1: General Knowledge
--------------------------

Current events, miscellaneous tidbits, and random trivia. Following a time-honored traditions for NSHipster quizzes, the first round is always a mis-mash of people, places, and pop culture.

1. In 2011, Apple deprecated OS X's Common Data Security Architecture, leaving them unaffected by what recent vulnerability.
2. According to rumors, Apple will be partnering with which company to add song recognition functionality to Siri in iOS 8?
3. The White House expressed disappointment over a "selfie" of Boston Red Sox player David Ortiz and President Obama, due to allegations that it was a promotional stunt for which company?
4. In Sony's forthcoming Steve Jobs biopic, which actor was recently rumored to being approached by director Danny Boyle to play the lead role? For a bonus point: which actor was previously confirmed for this role, before director David Fincher backed out of the project?
5. In Apple's Q2 Earnings call, Tim Cook announced the company had acquired 24 companies so far in 2014, including Burstly, which is better known for what service for iOS developers?
6. After a rumored $3.2 billion acquisition bid by Apple, which American record producer, rapper and entrepreneur has described himself as "the first billionaire in hip hop"? For a bonus point: what is his _legal_ (i.e. non-stage) name?
7. A widespread (and recently debunked) rumor of Apple announcing Lightning-cable-powered biometric ear buds was originally disclosed on which social network for Silicon Valley insiders?
8. Oracle won an important victory in the U.S. Court of Appeals against Google in their suit regarding copyright claims of what?
9. What hot new social networking app allows you to anonymously chat with patrons of its eponymous, popular American chain restaurant?
10. If one were to sit down at a NeXTstation and open "/NextLibrary/Frameworks/AppKit.framework/Resources/", they would find the file "NSShowMe.tiff". Who is pictured in this photo?

![NSShowMe.tiff](http://nshipster.s3.amazonaws.com/NSShowMe.tiff)

Round 2: Core Potpourri
-----------------------

With the fluff out of the way, it's now time to dive into some hardcore Cocoa fundamentals. How well do _you_ know the standard library?

1. What unit does a Bluetooth peripheral measure RSSI, or received signal strength intensity in?
2. What is the return value of the following code: `UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, @"image/jpeg", NULL)`?
3. What function must be called before calling `SecTrustGetCertificateCount` on a `SecTrustRef`?
4. What UIKit class can be used to show the definition of a word?
5. An `SCNetworkReachabilityRef` can be created from three different sets of arguments. Fill in the blank `SCNetworkReachabilityCreateWith_______`. (1 pt. each)
6. `mach_absolute_time()` returns a count of Mach absolute time units. What function can be used to convert this into something more useful, like nanoseconds?
7. How many arguments does `CGRectDivide` take?
8. What function would you call to generate a random integer between `1` and `N`
9. What CoreFoundation function can, among other things, transliterate between different writing systems?
10. What is LLVM's logo? And, for a bonus point: What is GCC's logo?

Activity Sheet: NSAnagram
-------------------------

First introduced in [NSHipster Quiz #4](http://nshipster.com/nshipster-quiz-4/), NSAnagram has become loved and hated, in equal parts, by those who have dared to take the challenge. Each question is an anagram, whose letters can be rearranged to form the name of a class or type in a well-known system framework (hint: Foundation, CoreFoundation, CoreLocation, StoreKit, and UIKit are represented here). Good luck!

1. Farms To Rent
2. Zest On Mine!
3. A Stressful Nude
4. Non-payment Attacks, Sir!
5. Allegiant Ace, Conglomerated
6. Mental Burlesque Ruts
7. Ulcer Porn: OFF
8. Forgive Traded Crap
9. Cautionary Mini Dam
10. Coil Infatuation... Coil

* * *

# Answers

Round 1: General Knowledge
--------------------------

1. Heartbleed
2. Shazam
3. Samsung
4. Leonardo DiCaprio, previously Christian Bale)
5. TestFlight
6. Dr. Dre, a.k.a Andre Romelle Young
7. Secret
8. Java APIs
9. [WhatsApplebees](http://whatsapplebees.com)
10. A young Scott Forstall

Round 2: Core Potpourri
-----------------------

1. [decibels (dB)](http://en.wikipedia.org/wiki/Received_signal_strength_indication)
2. [`public.jpeg`](https://developer.apple.com/library/ios/documentation/miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html)
3. [`SecTrustEvaluate`](https://developer.apple.com/library/mac/documentation/security/Reference/certifkeytrustservices/Reference/reference.html)
4. [`UIReferenceLibraryViewController`](http://nshipster.com/dictionary-services/)
5. [`Address`, `AddressPair`, `Name`](https://developer.apple.com/library/mac/documentation/SystemConfiguration/Reference/SCNetworkReachabilityRef/Reference/reference.html)
6. [`mach_timebase_info()`](https://developer.apple.com/library/ios/qa/qa1643/_index.html)
7. [5](https://developer.apple.com/library/mac/documentation/graphicsimaging/reference/CGGeometry/Reference/reference.html#//apple_ref/c/func/CGRectDivide)
8. [`arc4random_uniform`](https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man3/arc4random_uniform.3.html)
9. [`CFStringTransform`](https://developer.apple.com/library/mac/documentation/corefoundation/Reference/CFMutableStringRef/Reference/reference.html#//apple_ref/doc/uid/20001504-CH201-BCIGCACA)
10. [LLVM's Logo is a **wyvern**, or **dragon**](http://llvm.org/Logo.html). [GCC's Logo is an **egg** (with a **gnu** bursting out of it)](http://gcc.gnu.org)

Round 3: NSAnagram
------------------

1. `NSFormatter`
2. `NSTimeZone`
3. `NSUserDefaults`
4. `SKPaymentTransaction`
5. `CLLocationManagerDelegate`
6. `NSMutableURLRequest`
7. `CFRunLoopRef`
8. `CGDataProviderRef`
9. `UIDynamicAnimator`
10. `UILocalNotification`

* * *

How did you do this time? Tweet out your score to see how you stack up to your peers!
