---
title: "NSHipster Quiz #1"
author: Mattt Thompson
category: Trivia
excerpt: "Test your knowledge of general programming knowledge, Cocoa APIs, and Apple trivia in this first-ever NSHipster Quiz. How NSHip are you?"
status:
    swift: n/a
---

On April 9th, the first-ever [NSHipster Pub Quiz](http://www.uikonf.com/2013/04/11/nshipster-pub-quiz.html) was held in Berlin. Think of your traditional pub quiz crossed with "Stump the Experts", with questions about things that you know and care about: computers, programming, Apple trivia—that sort of thing. The event was hosted by [UIKonf](http://www.uikonf.com), and made possible by its organizers [Chris Eidhof](http://twitter.com/chriseidhof), [Matt Patterson](http://twitter.com/fidothe), and [Peter Bihr](http://twitter.com/peterbihr). Thanks again to Chris, Matt, and Peter, and everyone who came out to make it such an amazing event.

All told, a whopping 50-some folks came out, composing a dozen or so teams of up to 6 people, with names such as "NSBeep", "alloc] win_it]", & "- Bug Fixes / - Performance Improvements". At the end of the evening, it was the [CodeKollectiv](http://codekollektiv.com) team that claimed top prize, with a score of 30pts.

Here are the rules to play along at home:

- There are 4 Rounds, with 10 questions each
- Record answers on a separate sheet of paper
- Each correct answer to a question gets you 1 point
- Play with up to 5 friends for maximum enjoyment
- Don't be lame and look things up on the internet or in Xcode

* * *

Round 1: General Knowledge
--------------------------

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

Round 2: APIs
-------------

You will be given the name of the class, and the description of the property or method from the documentation. You need to tell me the name of that method or property.

1. `UIView`: "A flag used to determine how a view lays out its content when its bounds change."
2. `UIAccessibility`: "A brief description of the result of performing an action on the accessibility element, in a localized string."
3. `UIColor`: "Returns a color object whose RGB values are 0.0, 1.0, and 1.0 and whose alpha value is 1.0."
4. `UIAlertView`: "Sent to the delegate when the user clicks a button on an alert view."
5. `UIButton`: "A Boolean value that determines whether tapping the button causes it to glow."
6. `UITableView`: "Reloads the specified rows using a certain animation effect."
7. `UITableViewDataSource`: "Tells the data source to return the number of rows in a given section of a table view."
8. `UIWebView`: "Sets the main page content and base URL."
9. `UIGestureRecognizer`: "Sent to the receiver when one or more fingers touch down in the associated view."
10. `UIDictationPhrase`: "The most likely textual interpretation of a dictated phrase."


Round 3: Picture Round
----------------------

- 1. What is this?

![Question 1]({{ site.asseturl }}/quiz-1/question-1.jpg)

- 2. What is this?

![Question 2]({{ site.asseturl }}/quiz-1/question-2.jpg)

- 3. What is this?

![Question 3]({{ site.asseturl }}/quiz-1/question-3.jpg)

- 4. What is this?

![Question 4]({{ site.asseturl }}/quiz-1/question-4.jpg)

- 5. WTF is this?

![Question 5]({{ site.asseturl }}/quiz-1/question-5.jpg)

- 6. Who is this?

![Question 6]({{ site.asseturl }}/quiz-1/question-6.jpg)

- 7. Who is this?

![Question 7]({{ site.asseturl }}/quiz-1/question-7.jpg)

- 8. Who is this?

![Question 8]({{ site.asseturl }}/quiz-1/question-8.jpg)

- 9. Who is this?

![Question 9]({{ site.asseturl }}/quiz-1/question-9.jpg)

- 10. In this photo, Bill Gates & Steve Jobs are being interviewed at the D5 conference in 2007 by a man and a woman just off-screen to the left. Who are they? (One point for each person)

![Question 10]({{ site.asseturl }}/quiz-1/question-10.jpg)


Round 4: Name That Framework!
-----------------------------

For each question, a list of three classes from the same framework have been listed without their two-letter namespace prefix. Name the framework that they all belong to!

1. Color List, Matrix, Sound
2. Composition, URL Asset, Capture Session
3. Enclosure, Author, Feed
4. Geocoder, Location, Region
5. Merge Policy, Mapping Model, Incremental Store
6. Analysis, Summary, Search
7. Record, Person, MultiValue
8. View, View Controller, Skybox Effect
9. Central Manager, Descriptor, Peripheral Delegate
10. Filter, Face Feature, Vector


* * *

# Answers

Round 1: General Knowledge
--------------------------

1. [NeXTSTEP](http://en.wikipedia.org/wiki/NeXTSTEP)
2. [4000](http://www.macrumors.com/2013/03/04/steve-jobs-4000-latte-prank-order-lives-on-at-san-francisco-starbucks/)
3. [`isReady`, `isExecuting`, `isFinished`, `isCancelled`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html%23//apple_ref/doc/uid/TP40004591-RH2-DontLinkElementID_1)
4. [    textLabel detailTextLabel   ](http://developer.apple.com/library/ios/DOCUMENTATION/UserExperience/Conceptual/TableView_iPhone/Art/tvcellstyle_value2.jpg)
5. [`UITableViewDelegate`](http://developer.apple.com/library/ios/documentation/uikit/reference/UITableViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006942-CH3-SW25)
6. [`signed char`](http://nshipster.com/bool/)
7. [Midnight UTC, 1 January 1970](http://en.wikipedia.org/wiki/Unix_epoch)
8. [4.6.2 (4H1003)](http://en.wikipedia.org/wiki/Xcode)
9. [NSIndexSet](http://nshipster.com/nsindexset/)
10. [16](http://en.wikipedia.org/wiki/IPhone_%281st_generation%29)

Round 2: APIs
-------------

1. `@contentMode`
2. `@accessibilityHint`
3. `+cyanColor`
4. `-alertView:clickedButtonAtIndex:`
5. `@showsTouchWhenHighlighted`
6. `-reloadRowsAtIndexPaths:withRowAnimation:`
7. `-tableView:numberOfRowsInSection:`
8. `-loadHTMLString:baseURL:`
9. `-touchesBegan:withEvent:`
10. `@text`

Round 3: Picture Round
----------------------

1. [Apple I](http://en.wikipedia.org/wiki/Apple_I)
2. [Apple eMac](http://en.wikipedia.org/wiki/EMac)
3. [Apple Bandai Pippin](http://en.wikipedia.org/wiki/Apple_Bandai_Pippin)
4. [Apple QuickTake](http://en.wikipedia.org/wiki/Apple_QuickTake)
5. [New Proposed Apple Campus / "Mothership"](http://www.cultofmac.com/108782/apples-magnificent-mothership-campus-gets-new-renders-and-more-details-report/)
6. [Sir Jonathan "Jony" Ive](http://en.wikipedia.org/wiki/Jonathan_Ive)
7. [Scott Forstall](http://en.wikipedia.org/wiki/Scott_Forstall)
8. [Bob Mansfield](http://en.wikipedia.org/wiki/Bob_Mansfield)
9. [Susan Kare](http://en.wikipedia.org/wiki/Susan_kare)
10. [Kara Swisher & Walt Mossberg ](http://allthingsd.com/20071224/best-of-2007-video-d5-interview-with-bill-gates-and-steve-jobs/)

Round 4: Name That Framework!
-----------------------------

1. [App Kit](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/ObjC_classic/_index.html)
2. [AV Foundation](https://developer.apple.com/library/mac/#documentation/AVFoundation/Reference/AVFoundationFramework/_index.html)
3. [Publication Subscription](http://developer.apple.com/library/mac/#documentation/InternetWeb/Reference/PubSubReference/_index.html#//apple_ref/doc/uid/TP40004649)
4. [Core Location](http://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CoreLocation_Framework/_index.html)
5. [Core Data](http://developer.apple.com/library/ios/#documentation/cocoa/Reference/CoreData_ObjC/_index.html)
6. [Search Kit](https://developer.apple.com/library/mac/#documentation/UserExperience/Reference/SearchKit/Reference/reference.html)
7. [Address Book](http://developer.apple.com/library/ios/#documentation/AddressBook/Reference/AddressBook_iPhoneOS_Framework/_index.html)
8. [GLKit](http://developer.apple.com/library/mac/#documentation/GLkit/Reference/GLKit_Collection/_index.html)
9. [Core Bluetooth](http://developer.apple.com/library/ios/#documentation/CoreBluetooth/Reference/CoreBluetooth_Framework/_index.html)
10. [Core Image](https://developer.apple.com/library/mac/#documentation/graphicsimaging/Conceptual/CoreImaging/ci_intro/ci_intro.html)

* * *

So how did you fare? Tweet out your score to see how you stack up to your peers!
