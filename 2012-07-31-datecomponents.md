---
title: DateComponents
author: Mattt
category: Cocoa
excerpt: >-
  `DateComponents` is a useful, but ambiguous type.
  Taken in one context,
  date components can be used to represent a specific calendar date.
  But in another context,
  the same object might instead be used as a duration of time.
revisions:
  "2012-07-31": Original Publication
  "2018-10-10": Expanded details
status:
  swift: 4.2
  reviewed: October 10, 2018
---

There are as many mnemonic devices for making sense of time
as the day is long.
["Spring ahead, Fall back"](https://en.wikipedia.org/wiki/Daylight_saving_time).
[That knuckle trick for remembering the lengths of months.](https://en.wikipedia.org/wiki/Knuckle_mnemonic)
Musical theater aficionados can tell you in quick measure
[the length of a year in minutes](https://en.wikipedia.org/wiki/Seasons_of_Love).
Mathematicians, though, have the best ones of all:
Did you know that the fifth hyperfactorial (5⁵ × 4⁴ × 3³ × 2² × 1¹)
is equal to 86400000, or exactly 1 (civil) day in milliseconds?
Or that ten factorial (10! = 10 × 9 × 8… = 3628800) seconds
is equal to 6 weeks?

Amazing, right?
But I want you to forget all of those,
at least for the purposes of programming.

As we discussed in
[our article about `Date`, et al.](/timeinterval-date-dateinterval),
the only unit of time with a constant duration is the second
(and its subdivisions).
When you want to express the duration of, 1 day,
don't write `60 * 60 * 24`.
Instead, write `DateComponents(day: 1)`.

"What is `DateComponents`", you ask?
It's a relatively recent addition to Foundation
for representing a date or duration of time,
and it's the subject of this article.

---

`DateComponents` is a useful, but ambiguous type.

Taken in one context,
date components can be used to represent a specific calendar date.
But in another context,
the same object might instead be used as a duration of time.
For example, a date components object with
`year` set to `2018`,
`month` set to `10`, and
`day` set to `10`
could represent a period of 2018 years, 10 months, and 10 days
or the tenth day of the tenth month in the year 2018:

```swift
import Foundation

let calendar = Calendar.current
let dateComponents = DateComponents(calendar: calendar,
                                    year: 2018,
                                    month: 10,
                                    day: 10)

// DateComponents as a date specifier
let date = calendar.date(from: dateComponents)! // 2018-10-10

// DateComponents as a duration of time
let anotherDate = calendar.date(byAdding: dateComponents, to: date)! // 4037-08-20
```

Let's explore both of these contexts individually,
starting with date components as a representation of a calendar date:

---

## Date Components as a Representation of a Calendar Date

### Extracting Components from a Date

`DateComponents` objects can be created for a particular date
using the `Calendar` method `components(_:from:)`:

```swift
let date = Date() // 2018-10-10T10:00:00+00:00
let calendar = Calendar.current
let components = calendar.dateComponents([.year, .month, .day], from: date)
// {{ page.updated_on | date: '(year: %Y, month: %-M, day: %-d)' }}
```

Each property in `DateComponents`
has a corresponding entry in the
[`Calendar.Component` enumeration](https://developer.apple.com/documentation/foundation/calendar/component).

{% info %}
For best results,
specify only the date components / calendar units that you're interested in.
{% endinfo %}

For reference,
here's what the `dateComponents(_:from:)` method produces
when you specify all of the available calendar units:

```swift
import Foundation

let date = Date() // 2018-10-10T10:00:00+00:00
let calendar = Calendar.current
let dateComponents = calendar.dateComponents(
    [.calendar, .timeZone,
     .era, .quarter,
     .year, .month, .day,
     .hour, .minute, .second, .nanosecond,
     .weekday, .weekdayOrdinal,
     .weekOfMonth, .weekOfYear, .yearForWeekOfYear],
    from: date)
```

| Component           | Value               |
| ------------------- | ------------------- |
| `calendar`          | gregorian           |
| `timeZone`          | America/Los_Angeles |
| `era`               | 1                   |
| `quarter`           | 0                   |
| `year`              | 2018                |
| `month`             | 10                  |
| `day`               | 3                   |
| `hour`              | 10                  |
| `minute`            | 0                   |
| `second`            | 0                   |
| `nanosecond`        | 123456789           |
| `weekday`           | 4                   |
| `weekdayOrdinal`    | 2                   |
| `weekOfMonth`       | 2                   |
| `weekOfYear`        | 41                  |
| `yearForWeekOfYear` | 2018                |
| `isLeapMonth`       | false               |

One of the advantages of learning Foundation APIs
is that you gain a deeper understanding of the domains that it models.
Unless you're a horologist or ISO 8601 enthusiast,
there are probably a few of these components that you're less familiar with,
so let's take a look at some of the more obscure ones:

### Era and Year

The Gregorian calendar has two [eras](https://en.wikipedia.org/wiki/Calendar_era):
BC and AD (alternatively, C.E. and B.C.E).
Their respective integer date component values are `0` and `1`.
No matter what the era is, the `year` component is always a positive number.

### Quarter

In academia and business,
calendar years are often divided up into
[quarter](https://en.wikipedia.org/wiki/Calendar_year#Quarters)
(Q1, Q2, Q3, Q4).

{% error %}

In iOS 12 and macOS Mojave,
the `dateComponents(_:from:)` method
doesn't populate the `quarter` property
for the returned value, even with the unit is specified.  
See [rdar://35247464](http://www.openradar.me/35247464).

As a workaround,
you can use `DateFormatter` to generate a string
using the date format `"Q"`
and parse its integer value:

```swift
let formatter = DateFormatter()
formatter.dateFormat = "Q"
Int(formatter.string(from: Date())) // 4
```

{% enderror %}

### Weekday, Weekday Ordinal, and Week of Month

Weekdays are given integer values starting with
1 for Sunday
and ending with 7 for Saturday.

But the first weekday varies across different locales.
The first weekday in the calendar depends on your current locale.
The United States, China, and other countries begin their weeks on Sunday.
Most countries in Europe, as well as India, Australia, and elsewhere
typically designate Monday as their first weekday.
Certain locales in the Middle East and North Africa
use Saturday as the start of their week.

The locale also affects the values returned for
the `weekdayOrdinal` and `weekOfMonth` components.
In the `en-US` locale,
the date components returned for October 7th, 2018
would have `weekdayOrdinal` equal to 1
(meaning "the first Sunday of the month")
and a `weekOfMonth` value of 2
(meaning "the second week of the month").

### Week of Year and Year for Week of Year

These two are probably the most confusing of all the date components.
Part of that has to do with the ridiculous API name `yearForWeekOfYear`,
but it mostly comes down to the lack of general awareness for
[ISO week dates](https://en.wikipedia.org/wiki/ISO_week_date).

The `weekOfYear` component
returns the ISO week number for the date in question.
For example, October 10th, 2018 occurs on the 41st ISO week.

The `yearForWeekOfYear` component
is helpful for weeks that span two calendar years.
For example, New Years Eve this year --- December 31st, 2018 ---
falls on a Monday.
Because occurs in the first week of 2019,
its `weekOfYear` value is `1`,
its `yearForWeekOfYear` value is `2019`,
and its `year` value is `2018`

{% warning %}

In contrast to the `year` date component,
`yearForWeekOfYear` has a negative value
for years before the common era.
For example,
a date in the year 47 BC
has a `yearForWeekOfYear` equal to `-46`
(the off-by-one value is a consequence of how the year 0 is handled).

{% endwarning %}

### Creating a Date from Date Components

In addition to extracting components from a date,
we can go the opposite direction to create a date from components
using the `Calendar` method `date(from:)`.

Use it the next time you need to initialize a static date
as a more performant and reliable way
than parsing a timestamp with a date formatter.

```swift
var date: Date?

// Bad
let timestamp = "2018-10-03"
let formatter = ISO8601DateFormatter()
formatter.formatOptions =
    [.withFullDate, .withDashSeparatorInDate]
date = formatter.date(from: timestamp)

// Good
let calendar = Calendar.current
let dateComponents =
    DateComponents(calendar: calendar,
                   year: 2018, month: 10, day: 3)
date = calendar.date(from: dateComponents)
```

When date components are used to represent a date,
there's still some ambiguity.
Date components can be (and often are) under-specified,
such that the values of components like `era` or `hour` are inferred
from additional context.
When you use the `date(from:)` method,
what you're really doing is telling `Calendar`
to search for the next date that satisfies the criteria you specified.

Sometimes this isn't possible,
like if date components have contradictory values
(such as `weekOfYear = 1` and `weekOfMonth = 3`),
or a value in excess of what a calendar allows
(such as an `hour = 127`).
In these cases, `date(from:)` returns `nil`.

{% info %}
Ranges for some units can also vary between calendars;
for example, a `month` value of `13` is valid in the Coptic calendar,
but invalid in the Gregorian calendar.
{% endinfo %}

### Getting the Range of a Calendar Unit

A common task when working with dates
is to get the start of day, week, month, or year.
Although it's possible to do this with `DateComponents`
creating a new date with a subset of date component values,
a better way would be to use the `Calendar` method `dateInterval(of:for:)`:

```swift
let date = Date() // 2018-10-10T10:00:00+00:00
let calendar = Calendar.current

var beginningOfMonth: Date?

// OK
let dateComponents =
    calendar.dateComponents([.year, .month], from: date)
beginningOfMonth = calendar.date(from: dateComponents)

// Better
beginningOfMonth =
    calendar.dateInterval(of: .month, for: date)?.start
```

---

## Date Components as a Representation of a Duration of Time

## Calculating the Distance Between Two Dates

Picking up from the previous example ---
you can use the `Calendar` method `dateComponents(_:from:to:)`
to calculate the time between two dates
in terms of your desired units.

How long is the month of October in hours?

```swift
let date = Date() // 2018-10-10T10:00:00+00:00
let calendar = Calendar.current

let monthInterval =
    calendar.dateInterval(of: .month, for: date)!

calendar.dateComponents([.hour],
                        from: monthInterval.start,
                        to: monthInterval.end)
        .hour // 744
```

## Adding Components to Dates

Another frequent programming task
is to calculate a date from an offset
like "tomorrow" or "next week".

If you're adding a single calendar component value,
you can use the `Calendar` method `date(byAdding:value:to:)`:

```swift
let date = Date() // 2018-10-10T10:00:00+00:00
let calendar = Calendar.current

var tomorrow: Date?

// Bad
tomorrow = date.addingTimeInterval(60 * 60 * 24)

// Good
tomorrow = calendar.date(byAdding: .day,
                         value: 1,
                         to: date)
```

For more than one calendar component value,
use the `date(byAdding:to:)` method instead,
passing a `DateComponents` object.

```swift
let date = Date()
let calendar = Calendar.current

// Adding a year
calendar.date(byAdding: .year, value: 1, to: date)

// Adding a year and a day
let dateComponents = DateComponents(year: 1, day: 1)
calendar.date(byAdding: dateComponents, to: date)
```

If you _really_ want to be pedantic when time traveling, though,
the method you're looking for is
`nextDate(after:matching:matchingPolicy:repeatedTimePolicy:direction:)`.
For example,
if you wanted to find the date corresponding to the next time
with the same time components (hour, minute, second, nanosecond)
and wanted to be specific about how to handle phenomena like
2:59AM occurring twice on November 4th, 2018,
here's how you might do that:

```swift
let dateComponents =
    calendar.dateComponents([.hour,
                             .minute,
                             .second,
                             .nanosecond],
                            from: date)

tomorrow = calendar.nextDate(after: date,
                             matching: dateComponents,
                             matchingPolicy: .nextTime,
                             repeatedTimePolicy: .first,
                             direction: .forward)
```

{% info %}

If this seems like a lot of work,
remember that time is complicated and requires precision.
There's a great explanation of the matching and repeated time policies
[buried in the official documentation](https://developer.apple.com/documentation/foundation/nscalendar/1413938-enumeratedates),
so be sure to check that out.

{% endinfo %}

---

So there you have it!
Now you know how to do calendar arithmetic correctly
using `Calendar` and `DateComponents`.

To help you remember, we humbly offer the following mnemonic:

> Are you multiplying seconds? Don't! / <br/>
> Instead, use `(NS)DateComponents`\*

<small>\* `NS` prefix added to make the meter work. Thanks, Swift 3.</small>
