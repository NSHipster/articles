---
title: "NSHipster Quiz #4"
author: Mattt Thompson
category: Trivia
excerpt: "The fourth and final quiz of the year. Do you have what it takes to be the `NSArray -firstObject` among your peers?"
status:
    swift: n/a
---

The fourth and final NSHipster pub quiz of the year was held in the beautiful city of Amsterdam on October 22nd, with help from the good folks at [Appsterdam](http://appsterdam.rs), [The Big Nerd Ranch](http://www.bignerdranch.com/), and [Heroku](http://www.heroku.com).

The competition was fierce, but ultimately the team of [Mike Lee](https://twitter.com/bmf), [Judy Chen](https://twitter.com/judykitteh), [Eloy Dúran](https://twitter.com/alloy), [Alexander Repty](https://twitter.com/arepty), [Maxie Ketschau-Repty](https://twitter.com/Yumyoko), and [Sernin van de Krol](https://twitter.com/paneidos) were victorious. This was, by design, to be the highest-scoring of any pub quiz, with generous portions of extra points, and Team "[Graceful Hoppers](http://en.wikipedia.org/wiki/Grace_Hopper)" came through with an impressive 53 points (which, interestingly enough, only edged out the 2nd place team by ½ of a point).

As always, you can play along at home or at work with your colleagues. Here are the rules:

- There are 4 Rounds, with 10 questions each
- Record answers on a separate sheet of paper
- Each correct answer to a question gets you 1 point (unless otherwise specified)
- Play with up to 5 friends for maximum enjoyment
- Don't be lame and look things up on the Internet or in Xcode

* * *

Round 1: General Knowledge
--------------------------

Current events, miscellaneous tidbits, and random trivia. Following a time-honored traditions for NSHipster quizzes, the first round is always a mis-mash of people, places, and pop culture.

1. What hardware products did Apple announce at its October 22nd Media Event? (1pt for each correct answer)
2. What two products were announced during the _last event_ to be held at the Yerba Buena Center for the Arts, on March 7, 2012? (1pt for each correct answer)
3. Which company's CEO was recently named as Apple's new Head of Retail? (1pt bonus if you know her name)
4. In September of this year, Steve Ballmer held his last meeting as CEO at Microsoft. How many years did he serve in this role?
5. Jony Ive recently designed a (_beautiful_) one-off camera with which famed camera company?
6. Which website's failure has given cause for President Obama to do a post-mortem for the failed Rails app?
7. Doomed former smartphone juggernaut BlackBerry recently released an iOS app. What is it called?
8. Apple prompted some raised eyebrows with the final developer release of Mac OS X Mavericks. What was the controversy?
9. During development, the Gold iPhone 5s was jokingly named after which American "celebrity"?
10. At an average per capita rate of 8.4kg per year, the Netherlands is the world's #5 consumer of what?

Round 2: Foundation Potpourri
-----------------------------

With the fluff out of the way, it's now time to dive into some hardcore Cocoa fundamentals. How well do _you_ know the standard library?

1. `NSPredicate` objects can be decomposed into left and right hand side components of which class?
2. Which of the following is _not_ something `NSDataDetector` can detect? Addresses, Phone Numbers, Product Listings, or Flight Information.
3. Which Foundation collection class allows values to be weakly referenced?
4. What method would you implement in an `NSFormatter` subclass in order to override what's displayed while editing?
5. Which Xcode launch argument can be specified to have NON-LOCALIZED STRINGS YELL AT YOU?
6. Which Core Foundation collection type corresponds to (but does not toll-free bridge) `NSCountedSet`?
7. Which `NSValue` class constructor allows for non-`NSCopying`-conforming objects to be used as keys in an `NSDictionary`?
8. Which `@` compiler directive allows classes to be referred to by another name?
9. Name the 4 Classes that conform to `<NSLocking>` (1 pt. each)
10. What is the name of the method called by the following code:

~~~{objective-c}
array[1] = @"foo";
~~~

Round 3: Picture Round - Indie Devs
-----------------------------------

Following another tradition of the NSHipster quiz is everybody's favorite: the Picture Round! This time, the theme is indie developers. Earn up to 3 points for each set of pictures by naming the **founder**, the **name of the company** they're known for, and the **name of their flagship app** represented by the icon.

1. ![Question 1](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-1.png)
2. ![Question 2](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-2.png)
3. ![Question 3](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-3.png)
4. ![Question 4](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-4.png)
5. ![Question 5](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-5.png)
6. ![Question 6](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-6.png)
7. ![Question 7](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-7.png)
8. ![Question 8](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-8.png)
9. ![Question 9](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-9.png)
10. ![Question 10](http://nshipster-quiz-4.s3.amazonaws.com/nshipster-quiz-4-question-10.png)

Round 4: NSAnagram
------------------

And finally, an admittedly _sadistic_ round that combines wordplay with Cocoa arcana. Each question is an anagram, whose letters can be rearranged to form the name of a class or type in a well-known system framework (hint: Foundation, Core Foundation, UIKit, and AddressBook are represented here). Good luck!

1. Nose Call
2. Uncle Consort Inn
3. Oi! Inaccurate Wit Vividity
4. A Band's Cement Jog
5. Tartan's Screech
6. Kebab's Sad Odor
7. Macs Fret
8. Manservant of Rulers
9. Measurably Rant
10. Ill-Oiled Canonicalized Tuxedo

* * *

# Answers

Round 1: General Knowledge
--------------------------

1. Updated MacBook Pros, Mac Pro, iPad Mini Retina, iPad Air
2. 3rd Generation TV & 3rd Generation iPad
3. Burberry CEO Angela Ahrendts
4. 13 Years
5. Leica
6. healthcare.gov
7. BBM
8. GM Seed was Bumped / 2nd "GM" Release
9. Kim Kardashian
10. Coffee

Round 2: Foundation Potpourri
-----------------------------

1. `NSExpression`
2. Product Listings
3. `NSMapTable`
4. `editingStringForObjectValue:`
5. `-NSShowNonLocalizedStrings`
6. `CFBag`
7. `NSValue +valueWithNonretainedObject:`
8. `@compatibility_alias`
9. `NSLock`, `NSConditionLock`, `NSRecursiveLock`, & `NSCondition`
10. `setObject:atIndexedSubscript:`

Round 3: Picture Round
----------------------

1. [Cabel Sasser](https://twitter.com/cabel) / [Panic](http://panic.com/) / [Transmit](http://panic.com/transmit/)
2. [Dan Wood](https://twitter.com/danwood) / [Karelia](http://www.karelia.com/) / [Sandvox](http://www.karelia.com/products/sandvox/)
3. [Sophia Teutschler](https://twitter.com/_soaps) / [Sophiestication](http://sophiestication.com/) / [Articles](http://sophiestication.com/articles/)
4. [Ken Case](https://twitter.com/kcase) / [The Omni Group](http://www.omnigroup.com/) / [OmniGraffle](http://www.omnigroup.com/omnigraffle/)
5. [Chris Liscio](https://twitter.com/liscio) / [Super Mega Ultra Groovy](http://supermegaultragroovy.com/) / [Capo](http://supermegaultragroovy.com/products/Capo/)
6. [Paul Kafasis](https://twitter.com/PBones) / [Rogue Amoeba](http://rogueamoeba.com/) / [Fission](http://rogueamoeba.com/fission/)
7. [Loren Brichter](https://twitter.com/lorenb) / [atebits](http://www.atebits.com/) / [Letterpress](http://www.atebits.com/letterpress/)
8. [Craig Hockenberry](https://twitter.com/chockenberry) / [The Iconfactory](http://iconfactory.com/) / [Twitterific](http://twitterrific.com/ios)
9. [Daniel Pasco](https://twitter.com/dlpasco) / [Black Pixel](http://blackpixel.com/) / [NetNewsWire](http://netnewswireapp.com/)
10. [Mike Lee](https://twitter.com/bmf) / [New Lemurs](http://newlemurs.com/) / [Lemurs Chemistry](http://newlemurs.com/)

Round 4: NSAnagram
------------------

1. `NSLocale`
2. `NSURLConnection`
3. `UIActivityIndicatorView`
4. `NSManagedObject`
5. `NSCharacterSet`
6. `ABAddressBook`
7. `CFStream`
8. `NSValueTransformer`
9. `NSMutableArray`
10. `UILocalizedIndexedCollation`

* * *

How did you do this time? Tweet out your score to see how you stack up to your peers!
