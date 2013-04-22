---
layout: post
title: "NSHipster Quiz #1"

ref: "http://www.uikonf.com/2013/03/25/nshipster-quiz-night.html"
framework: Trivia
rating: 10.0
---

On April 9th, the first-ever [NSHipster Pub Quiz](http://www.uikonf.com/2013/04/11/nshipster-pub-quiz.html) was held in Berlin. Think of your traditional pub quiz crossed with "Stump the Experts", with questions about things that you know and care about: computers, programming, Apple trivia—that sort of thing. The event was hosted by [UIKonf](http://www.uikonf.com), and made possible by its organizers [Chris Eidhof](http://twitter.com/chriseidhof), [Matt Patterson](http://twitter.com/fidothe), and [Peter Bihr](http://twitter.com/peterbihr). Thanks again to Chris, Matt, and Peter, and everyone who came out to make it such an amazing event.

All told, a whopping 50-some folks came out, composing a dozen or so teams of up to 6 people, with names such as "NSBeep", "alloc] win_it]", & "- Bug Fixes / - Performance Improvements". At the end of the evening, it was the [CodeKollectiv](http://codekollektiv.com) team that claimed top prize, with a score of 30pts.

Everyone had such a great time, that we'll be doing it again:

**NSHipster will be hosting another trivia night during the week of WWDC 2013 in San Francisco.** More details to come... you know, as soon as Apple actually announces the dates for WWDC.

[Sign up here](http://eepurl.com/ys5K1) to be the first to be notified about Trivia Night. The event is sure to fill up quickly, so keep on the lookout for further announcements.

---

In the meantime, enjoy these questions from the Berlin Pub Quiz.

Here are the rules to play along at home:

- There are 4 Rounds, with 10 questions each
- Record answers on a separate sheet of paper
- Each correct answer to a question gets you 1 point
- Play with up to 5 friends for maximum enjoyment
- Don't be lame and look things up on the internet or in Xcode

---

Round 1: General Knowledge
==========================

0. What does `NS` stand for?
1. When Steve Jobs introduced the iPhone, he made a prank call to Starbucks. How many lattés did he order to-go?
  a. 3000
  b. 4000
  c. 6000
2. NSOperation has 4 properties used as keypaths for operation object states. What are they?
3. On your answer sheet, draw a `UITableViewCell` with `UITableViewCellStyleValue2`.
4. Which UIKit protocol contains the method `–tableView:heightForRowAtIndexPath:`?
5. What is the storage type of `BOOL`? _(i.e. `typedef` equivalent)_
6. When was the Unix Epoch? Hint: NSDate has an initializer referencing this.
7. What is the current version of Xcode?
8. What was the first article written on NSHipster?
9. How many apps were on on the home screen of the first iPhone?

---

### Answers for Round 1

0. [NeXTSTEP](http://en.wikipedia.org/wiki/NeXTSTEP)
1. [4000](http://www.macrumors.com/2013/03/04/steve-jobs-4000-latte-prank-order-lives-on-at-san-francisco-starbucks/)
2. [`isReady`, `isExecuting`, `isFinished`, `isCancelled`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html%23//apple_ref/doc/uid/TP40004591-RH2-DontLinkElementID_1)
3. [    textLabel detailTextLabel   ](http://developer.apple.com/library/ios/DOCUMENTATION/UserExperience/Conceptual/TableView_iPhone/Art/tvcellstyle_value2.jpg)
4. [`UITableViewDelegate`](http://developer.apple.com/library/ios/documentation/uikit/reference/UITableViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006942-CH3-SW25)
5. [`signed char`](http://nshipster.com/bool/)
6. [Midnight UTC, 1 January 1970](http://en.wikipedia.org/wiki/Unix_epoch)
7. [4.6.2 (4H1003)](http://en.wikipedia.org/wiki/Xcode)
8. [NSIndexSet](http://nshipster.com/nsindexset/)
9. [16](http://en.wikipedia.org/wiki/IPhone_%281st_generation%29)

Round 2: APIs
=============

You will be given the name of the class, and the description of the property or method from the documentation. You need to tell me the name of that method or property.

0. `UIView`: "A flag used to determine how a view lays out its content when its bounds change."
1. `UIAccessibility`: "A brief description of the result of performing an action on the accessibility element, in a localized string."
2. `UIColor`: "Returns a color object whose RGB values are 0.0, 1.0, and 1.0 and whose alpha value is 1.0."
3. `UIAlertView`: "Sent to the delegate when the user clicks a button on an alert view."
4. `UIButton`: "A Boolean value that determines whether tapping the button causes it to glow."
5. `UITableView`: "Reloads the specified rows using a certain animation effect."
6. `UITableViewDataSource`: "Tells the data source to return the number of rows in a given section of a table view."
7. `UIWebView`: "Sets the main page content and base URL."
8. `UIGetureRecognizer`: "Sent to the receiver when one or more fingers touch down in the associated view."
9. `UIDictationPhrase`: "The most likely textual interpretation of a dictated phrase."

---

### Answers for Round 2

0. `@contentMode`
1. `@accessibilityHint`
2. `+cyanColor`
3. `-alertView:clickedButtonAtIndex:`
4. `@showsTouchWhenHighlighted`
5. `-reloadRowsAtIndexPaths:withRowAnimation:`
6. `-tableView:numberOfRowsInSection:`
7. `-loadHTMLString:baseURL:`
8. `-touchesBegan:withEvent:`
9. `@text`

Round 3: Picture Round
======================

- 1. What is this?

![Question 1](http://nshipster-quiz-1.s3.amazonaws.com/question-1.jpg)

- 2. What is this?

![Question 2](http://nshipster-quiz-1.s3.amazonaws.com/question-2.jpg)

- 3. What is this?

![Question 3](http://nshipster-quiz-1.s3.amazonaws.com/question-3.jpg)

- 4. What is this?

![Question 4](http://nshipster-quiz-1.s3.amazonaws.com/question-4.jpg)

- 5. WTF is this?

![Question 5](http://nshipster-quiz-1.s3.amazonaws.com/question-5.jpg)

- 6. Who is this?

![Question 6](http://nshipster-quiz-1.s3.amazonaws.com/question-6.jpg)

- 7. Who is this?

![Question 7](http://nshipster-quiz-1.s3.amazonaws.com/question-7.jpg)

- 8. Who is this?

![Question 8](http://nshipster-quiz-1.s3.amazonaws.com/question-8.jpg)

- 9. Who is this?

![Question 9](http://nshipster-quiz-1.s3.amazonaws.com/question-9.jpg)

- 10. In this photo, Bill Gates & Steve Jobs are being interviewed at the D5 conference in 2007 by a man and a woman just off-screen to the left. Who are they? (One point for each person)

![Question 10](http://nshipster-quiz-1.s3.amazonaws.com/question-10.jpg)

---

### Answers for Round 3

0. [Apple I](http://en.wikipedia.org/wiki/Apple_I)
1. [Apple eMac](http://en.wikipedia.org/wiki/EMac)
2. [Apple Bandai Pippin](http://en.wikipedia.org/wiki/Apple_Bandai_Pippin)
3. [Apple QuickTake](http://en.wikipedia.org/wiki/Apple_QuickTake)
4. [New Proposed Apple Campus / "Mothership"](http://www.cultofmac.com/108782/apples-magnificent-mothership-campus-gets-new-renders-and-more-details-report/)
5. [Sir Jonathan "Jony" Ive](http://en.wikipedia.org/wiki/Jonathan_Ive)
6. [Scott Forstall](http://en.wikipedia.org/wiki/Scott_Forstall)
7. [Bob Mansfield](http://en.wikipedia.org/wiki/Bob_Mansfield)
8. [Susan Kare](http://en.wikipedia.org/wiki/Susan_kare)
9. [Kara Swisher & Walt Mossberg ](http://allthingsd.com/20071224/best-of-2007-video-d5-interview-with-bill-gates-and-steve-jobs/)

Round 4: Name That Framework!
=============================

For each question, a list of three classes from the same framework have been listed without their two-letter namespace prefix. Name the framework that they all belong to!

---

0. Color List, Matrix, Sound
1. Composition, URL Asset, Capture Session
2. Enclosure, Author, Feed
3. Geocoder, Location, Region
4. Merge Policy, Mapping Model, Incremental Store
5. Analysis, Summary, Search
6. Record, Person, MultiValue
7. View, View Controller, Skybox Effect
8. Central Manager, Descriptor, Peripheral Delegate
9. Filter, Face Feature, Vector

---

### Answers for Round 4

0. [App Kit](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/ObjC_classic/_index.html)
1. [AV Foundation](https://developer.apple.com/library/mac/#documentation/AVFoundation/Reference/AVFoundationFramework/_index.html)
2. [Publication Subscription](http://developer.apple.com/library/mac/#documentation/InternetWeb/Reference/PubSubReference/_index.html#//apple_ref/doc/uid/TP40004649)
3. [Core Location](http://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CoreLocation_Framework/_index.html)
4. [Core Data](http://developer.apple.com/library/ios/#documentation/cocoa/Reference/CoreData_ObjC/_index.html)
5. [Search Kit](https://developer.apple.com/library/mac/#documentation/UserExperience/Reference/SearchKit/Reference/reference.html)
6. [Address Book](http://developer.apple.com/library/ios/#documentation/AddressBook/Reference/AddressBook_iPhoneOS_Framework/_index.html)
7. [GLKit](http://developer.apple.com/library/mac/#documentation/GLkit/Reference/GLKit_Collection/_index.html)
8. [Core Bluetooth](http://developer.apple.com/library/ios/#documentation/CoreBluetooth/Reference/CoreBluetooth_Framework/_index.html)
9. [Core Image](https://developer.apple.com/library/mac/#documentation/graphicsimaging/Conceptual/CoreImaging/ci_intro/ci_intro.html)

---

So how did you fare? Tweet out your score to see how you stack up to your peers!

And again, be sure to [sign up here](http://eepurl.com/ys5K1) to be the first to know about the next NSHipster Pub Quiz to be held in San Francisco during the week WWDC. Hope to see you there!
