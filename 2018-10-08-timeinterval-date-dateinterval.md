---
title: TimeInterval, Date, and DateInterval
author: Mattt
category: Cocoa
excerpt: >
  Our limited understanding of time
  is reflected in ---
  or perhaps exacerbated by ---
  the naming of the Foundation date and time APIs.
  It's about time we got them straight.
status:
  swift: 4.2
---

Nestled between Madrid's Centro and Salamanca districts,
just a short walk from the sprawling Buen Retiro Park,
The Prado Museum boasts an extensive collection of works
from Europe's most celebrated painters.
But if, during your visit,
you begin to tire of portraiture commissioned by 17th-century Spanish monarchs,
consider visiting the northernmost room of the 1st floor --- _Sala 002_.
There you'll find
[this Baroque era painting by the French artist Simon Vouet](https://www.museodelprado.es/en/the-collection/art-work/time-defeated-by-hope-and-beauty/ebaeb191-f3ff-43b1-9207-fb36a3e5ad5a).

You'd be forgiven for wondering why
this pair of young women,
brandishing a hook and spear,
stand menacingly over a cowering old man
while a mob of cherubim tears at his back.
It is, of course, allegorical:
reading the adjacent placard,
you'll learn that this piece is entitled
_Time defeated by Hope and Beauty_.
The old man? That's Time.
See the hourglass in his hand and scythe at his feet?

Take a moment, standing in front of this painting,
to reflect on the enigmatic nature of time.

Think now about how our limited understanding of time
is reflected in ---
or perhaps exacerbated by ---
the naming of the Foundation date and time APIs.

It's about time we got them straight.

---

Seconds are the fundamental unit of time.
They're also the only unit that has a fixed duration.

Months vary in length
(_30 days hath September..._),
as do years
(_53 weeks hath 71 years every cycle of 400..._)
certain years pick up an extra day
(_leap years are misnamed if you think about it_),
and days gain and lose an hour from daylight saving time
(_thanks, Benjamin Franklin_).
And that's to say nothing of leap seconds,
which are responsible for such oddities as
the 61 second minute,
the 3601 second hour,
and, of course, the 1209601 second fortnight.

`TimeInterval` (neé `NSTimeInterval`) is a typealias for `Double`
that represents duration as a number of seconds.
You'll see it as a parameter or return type
for APIs that deal with a duration of time.
Being a double-precision floating-point number,
`TimeInterval` can represent submultiples in its fraction,
(though for anything beyond millisecond precision,
you'll want to use something else).

## Date and Time

It's unfortunate that the Foundation type representing time is named `Date`.
Colloquially, one typically distinguishes "dates" from "times"
by saying that the former has to do with calendar days
and the latter has more to do with the time of day.
But `Date` is entirely orthogonal from calendars,
and contrary to its name represents an absolute point in time.

{% info %}

Why `NSDate` and not `NSTime`?
Our guess is that the originators of this API wanted
to match its [counterpart in `java.util.date`](https://docs.oracle.com/javase/7/docs/api/java/util/Date.html)
when <abbr title="Enterprise Objects Framework">EOF</abbr>
targeted both Java and Objective-C.

{% endinfo %}

Another source of confusion for `Date` is that,
despite representing an absolute point in time,
it's [defined by a time interval since a reference date](https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/Date.swift#L17-L20):

```swift
public struct Date : ReferenceConvertible, Comparable, Equatable {
    public typealias ReferenceType = NSDate

    fileprivate var _time: TimeInterval

    // ...
}
```

The reference date, in this case,
is the first instant of January 1, 2001, Greenwich Mean Time (GMT).

{% info %}

While we're on the subject of conjectural sidebars,
does anyone know why Apple created a new standard
instead of using, say, the Unix Epoch (January 1, 1970)?
2001 was the year that Mac OS X was first released,
but `NSDate` pre-NSDates that from its NeXT days.
Was it perhaps a hedge against
[Y2K](https://en.wikipedia.org/wiki/Year_2000_problem)?

{% endinfo %}

## Date Intervals and Time Intervals

`DateInterval` is a recent addition to Foundation.
Introduced in iOS 10 and macOS Sierra,
this type represents a closed interval between two absolute points in time
(again, in contrast to `TimeInterval`, which represents a duration in seconds).

So what is this good for?
Consider the following use cases:

### Getting the Date Interval of a Calendar Unit

In order to know the time of day
for a point in time ---
or what day it is in the first place ---
you need to consult a calendar.
From there, you can determine the range of a particular calendar unit,
like a day, month, or year.
The `Calendar` method `dateInterval(of:for:)`
makes this really easy to do:

```swift
let calendar = Calendar.current
let date = Date()
let dateInterval = calendar.dateInterval(of: .month, for: date)
```

Because we're invoking `Calendar`,
we can be confident in the result that we get back.
Look how it handles daylight saving transition without breaking a sweat:

```swift
let dstComponents = DateComponents(year: 2018,
                                   month: 11,
                                   day: 4)
calendar.dateInterval(of: .day,
                      for: calendar.date(from: dstComponents)!)?.duration
// 90000 seconds
```

_It's {{ site.time | format: '%Y' }}.
Don't you think that it's time you stopped hard-coding `secondsInDay = 86400`?_

## Calculating Intersections of Date Intervals

For this example,
let's return to The Prado Museum
and admire its extensive collection of paintings by Rubens ---
particularly [this apparent depiction of the god of Swift programming](https://www.museodelprado.es/coleccion/obra-de-arte/eolo/e447dadb-b93f-4ce5-84e9-e6ae1d95c6cd).

Rubens, like Vouet,
painted in the Baroque tradition.
The two were contemporaries,
and we can determine the full extent of how they overlap in the history of art
with the help of `DateInterval`:

```swift
import Foundation

let calendar = Calendar.current

// Simon Vouet
// 9 January 1590 – 30 June 1649
let vouet =
    DateInterval(start: calendar.date(from:
        DateComponents(year: 1590, month: 1, day: 9))!,
                 end: calendar.date(from:
                    DateComponents(year: 1649, month: 6, day: 30))!)

// Peter Paul Rubens
// 28 June 1577 – 30 May 1640
let rubens =
    DateInterval(start: calendar.date(from:
                            DateComponents(year: 1577, month: 6, day: 28))!,
                 end: calendar.date(from:
                            DateComponents(year: 1640, month: 5, day: 30))!)

let overlap = rubens.intersection(with: vouet)!

calendar.dateComponents([.year],
                        from: overlap.start,
                        to: overlap.end) // 50 years
```

According to our calculations,
there was a period of 50 years where both painters were living.

We can even take things a step further
and use `DateIntervalFormatter`
to provide a nice representation of that time period:

```swift
let formatter = DateIntervalFormatter()
formatter.timeStyle = .none
formatter.dateTemplate = "%Y"
formatter.string(from: overlap)
// "1590 – 1640"
```

_Beautiful._
You might as well print this code out, frame it, and hang it next to
[_The Judgement of Paris_](https://www.museodelprado.es/en/the-collection/art-work/the-judgement-of-paris/f8b061e1-8248-42ae-81f8-6acb5b1d5a0a).

---

The fact is,
we still don't really know _what_ time is
(or if it even actually exists).
But I'm hopeful that we, as developers,
will find the beauty in Foundation's `Date` APIs,
and in time, learn how to overcome our lack of understanding.

That does it for this week's article.
See you all next time.
