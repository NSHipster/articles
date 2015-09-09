---
title: NSCalendar Additions
author: Nate Cook
category: "Cocoa"
excerpt: "`NSCalendar` has been quietly building a powerful set of methods for accessing and manipulating dates. From new ways of accessing individual date components and flexibly comparing dates to powerful date interpolation and enumeration methods, there's far too much to ignore. Make some room in your calendar and read on for more."
status:
    swift: 1.2
---

*Dates.* More than any other data type, the gulf between the initial banality of dates and their true, multifaceted complexity looms terrifyingly large. Combining sub-second precision, overlapping units, geopolitical time zone boundaries, localization differences in both language and grammar, and Daylight Saving shifts and leap year adjustments that literally add and remove whole chunks of time from measured existence, there's a lot to process.

To embark on any date-heavy task, then, requires a solid understanding of the tools already at your fingertips. Better to use a `Foundation` method than to write the *n*-thousandth version of `dateIsTomorrow`. Are you using `NSDateComponents`? Did you specify all the right calendar units? Will your code still work correctly on February 28, 2100?

But here's the thing: the APIs you're already using have been holding out on you. Unless you're digging through release notes and API diffs, you wouldn't know that over the last few releases of OS X, `NSCalendar` has quietly built a powerful set of methods for accessing and manipulating dates, and that the latest release brought them all to iOS.

```swift
let calendar = NSCalendar.currentCalendar()
```
```objective-c
NSCalendar *calendar = [NSCalendar currentCalendar];
```

From new ways of accessing individual date components and flexibly comparing dates to powerful date interpolation and enumeration methods, there's far too much to ignore. Make some room in your calendar and read on for more.


## Convenient Component Access

Oh, `NSDateComponents`. So practical and flexible, yet so cumbersome when I just. Want to know. What the hour is. `NSCalendar` to the rescue!

```swift
let hour = calendar.component(.CalendarUnitHour, fromDate: NSDate())
```
```objective-c
NSInteger hour = [calendar component:NSCalendarUnitHour fromDate:[NSDate date]];
```
That's much better. `NSCalendar`, what else can you do?

> - `getEra(_:year:month:day:fromDate:)`: Returns the era, year, month, and day of the given date by reference. Pass `nil`/`NULL` for any parameters you don't need.
> - `getEra(_:yearForWeekOfYear:weekOfYear:weekday:fromDate:)`: Returns the era, year (for week of year), week of year, and weekday of the given date by reference. Pass `nil`/`NULL` for any parameters you don't need.
> - `getHour(_:minute:second:nanosecond:fromDate:)`: Returns time information for the given date by reference. `nil`/`NULL`, you get the idea.

And just kidding, `NSDateComponents`, I take it all back. There are a couple methods for you, too:

> - `componentsInTimeZone(_:fromDate:)`: Returns an `NSDateComponents` instance with components of the given date shifted to the given time zone.
> - `components(_:fromDateComponents:toDateComponents:options:)`: Returns the difference between two `NSDateComponents` instances. The method will use base values for any components that are not set, so provide at the least the year for each parameter. The options parameter is unused; pass `nil`/`0`.


## Date Comparison

While direct `NSDate` comparison has always been a simple matter, more meaningful comparisons can get surprisingly complex. Do two `NSDate` instances fall on the same day? In the same hour? In the same week? 

Fret no more, `NSCalendar` has you covered with an extensive set of comparison methods:

> - `isDateInToday(_:)`: Returns `true` if the given date is today.
> - `isDateInTomorrow(_:)`: Returns `true` if the given date is tomorrow.
> - `isDateInYesterday(_:)`: Returns `true` if the given date is a part of yesterday.
> - `isDateInWeekend(_:)`: Returns `true` if the given date is part of a weekend, as defined by the calendar.
> - `isDate(_:inSameDayAsDate:)`: Returns `true` if the two `NSDate` instances are on the same day—delving into date components is unnecessary.
> - `isDate(_:equalToDate:toUnitGranularity:)`: Returns `true` if the dates are identical down to the given unit of granularity. That is, two date instances in the same week would return true if used with `calendar.isDate(tuesday, equalToDate: thursday, toUnitGranularity: .CalendarUnitWeekOfYear)`, even if they fall in different months.
> - `compareDate(_:toDate:toUnitGranularity:)`: Returns an `NSComparisonResult`, treating as equal any dates that are identical down to the given unit of granularity.
> - `date(_:matchesComponents:)`: Returns `true` if a date matches the specific components given.


## Date Interpolation

Next up is a set of methods that allows you to find the next date(s) based on a starting point. You can find the next (or previous) date based on an `NSDateComponents` instance, an individual date component, or a specific hour, minute, and second. Each of these methods takes an `NSCalendarOptions` bitmask parameter that provides fine-grained control over how the next date is selected, particularly in cases where an exact match isn't found at first.

### `NSCalendarOptions`

The easiest option of `NSCalendarOptions` is `.SearchBackwards`, which reverses the direction of each search, for all methods. Backward searches are constructed to return dates similar to forward searches. For example, searching backwards for the previous date with an `hour` of 11 would give you 11:00, not 11:59, even though 11:59 would technically come "before" 11:00 in a backwards search. Indeed, backward searching is intuitive until you think about it and then unintuitive until you think about it a lot more. That `.SearchBackwards` is the easy part should give you some idea of what's ahead.

The remainder of the options in `NSCalendarOptions` help deal with "missing" time instances. Time can be missing most obviously if one searches in the short window when time leaps an hour forward during a Daylight Saving adjustment, but this behavior can also come into play when searching for dates that don't quite add up, such as the 31st of February or April.

When encountering missing time, if `NSCalendarOptions.MatchStrictly` is provided, the methods will continue searching to find an `exact` match for all components given, even if that means skipping past higher order components. Without strict matching invoked, one of `.MatchNextTime`, `.MatchNextTimePreservingSmallerUnits`, and `.MatchPreviousTimePreservingSmallerUnits` must be provided. These options determine how a missing instance of time will be adjusted to compensate for the components in your request. 

In this case, an example will be worth a thousand words:

```swift
// begin with Valentine's Day, 2015 at 9:00am
let valentines = cal.dateWithEra(1, year: 2015, month: 2, day: 14, hour: 9, minute: 0, second: 0, nanosecond: 0)!

// to find the last day of the month, we'll set up a date components instance with 
// `day` set to 31:
let components = NSDateComponents()
components.day = 31
```
```objective-c
NSDate *valentines = [calendar dateWithEra:1 year:2015 month:2 day:14 hour:9 minute:0 second:0 nanosecond:0];
    
NSDateComponents *components = [[NSDateComponents alloc] init];
components.day = 31;
```

Using strict matching will find the next day that matches `31`, skipping into March to do so:

```swift
calendar.nextDateAfterDate(valentines, matchingComponents: components, options: .MatchStrictly)
// Mar 31, 2015, 12:00 AM
```
```objective-c
NSDate *date = [calendar nextDateAfterDate:valentines matchingComponents:components options:NSCalendarMatchStrictly];
// Mar 31, 2015, 12:00 AM
```

Without strict matching, `nextDateAfterDate` will stop when it hits the end of February before finding a match—recall that the highest unit specified was the day, so the search will only continue *within* the next highest unit, the month. At that point, the option you've provided will determine the returned date. For example, using `.MatchNextTime` will pick the next possible day:

```swift
calendar.nextDateAfterDate(valentines, matchingComponents: components, options: .MatchNextTime)
// Mar 1, 2015, 12:00 AM
```
```objective-c
date = [calendar nextDateAfterDate:valentines matchingComponents:components options:NSCalendarMatchNextTime];
// Mar 1, 2015, 12:00 AM
```

Similarly, using `.MatchNextTimePreservingSmallerUnits` will pick the next day, but will also preserve all the units smaller than the given `NSCalendarUnitDay`:

```swift
calendar.nextDateAfterDate(valentines, matchingComponents: components, options: .MatchNextTimePreservingSmallerUnits)
// Mar 1, 2015, 9:00 AM
```
```objective-c
date = [calendar nextDateAfterDate:valentines matchingComponents:components options:NSCalendarMatchNextTimePreservingSmallerUnits];
// Mar 1, 2015, 9:00 AM
```

And finally, using `.MatchPreviousTimePreservingSmallerUnits` will resolve the missing date by going the *other* direction, choosing the first possible previous day, again preserving the smaller units:

```swift
calendar.nextDateAfterDate(valentines, matchingComponents: components, options: .MatchPreviousTimePreservingSmallerUnits)
// Feb 28, 2015, 9:00 AM
```
```objective-c
date = [calendar nextDateAfterDate:valentines matchingComponents:components options:NSCalendarMatchPreviousTimePreservingSmallerUnits];
// Feb 28, 2015, 9:00 AM
```

Besides the `NDateComponents` version shown here, it's worth noting that `nextDateAfterDate` has two other variations:

```swift
// matching a particular calendar unit
cal.nextDateAfterDate(valentines, matchingUnit: .CalendarUnitDay, value: 31, options: .MatchStrictly)
// March 31, 2015, 12:00 AM

// matching an hour, minute, and second
cal.nextDateAfterDate(valentines, matchingHour: 15, minute: 30, second: 0, options: .MatchNextTime)
// Feb 14, 2015, 3:30 PM
```
```objective-c
// matching a particular calendar unit
date = [calendar nextDateAfterDate:valentines matchingUnit:NSCalendarUnitDay value:31 options:NSCalendarMatchStrictly];
// March 31, 2015, 12:00 AM
    
// matching an hour, minute, and second
date = [calendar nextDateAfterDate:valentines matchingHour:15 minute:30 second:0 options:NSCalendarMatchNextTime];
// Feb 14, 2015, 3:30 PM
```

### Enumerating Interpolated Dates

Rather than using `nextDateAfterDate` iteratively, `NSCalendar` provides an API for enumerating dates with the same semantics. `enumerateDatesStartingAfterDate(_:matchingComponents:options:usingBlock:)` computes the dates that match the given set of components and options, calling the provided closure with each date in turn. The closure can set the `stop` parameter to `true`, thereby stopping the enumeration. 

Putting this new `NSCalendarOptions` knowledge to use, here's one way to list the last fifty leap days:

```swift
let leapYearComponents = NSDateComponents()
leapYearComponents.month = 2
leapYearComponents.day = 29

var dateCount = 0
cal.enumerateDatesStartingAfterDate(NSDate(), matchingComponents: leapYearComponents, options: .MatchStrictly | .SearchBackwards) 
{ (date: NSDate!, exactMatch: Bool, stop: UnsafeMutablePointer<ObjCBool>) in
    println(date)

    if ++dateCount == 50 {
        // .memory gets at the value of an UnsafeMutablePointer
        stop.memory = true
    }
}
// 2012-02-29 05:00:00 +0000
// 2008-02-29 05:00:00 +0000
// 2004-02-29 05:00:00 +0000
// 2000-02-29 05:00:00 +0000
// ...
```
```objective-c
NSDateComponents *leapYearComponents = [[NSDateComponents alloc] init];
leapYearComponents.month = 2;
leapYearComponents.day = 29;
    
__block int dateCount = 0;
[calendar enumerateDatesStartingAfterDate:[NSDate date]
                      matchingComponents:leapYearComponents
                                 options:NSCalendarMatchStrictly | NSCalendarSearchBackwards
                              usingBlock:^(NSDate *date, BOOL exactMatch, BOOL *stop) {
    NSLog(@"%@", date);
    if (++dateCount == 50) {
        *stop = YES;
    }
}];
// 2012-02-29 05:00:00 +0000
// 2008-02-29 05:00:00 +0000
// 2004-02-29 05:00:00 +0000
// 2000-02-29 05:00:00 +0000
// ...
```

### Working for the Weekend

If you're always looking forward to the weekend, look no further than our final two `NSCalendar` methods:

> - `nextWeekendStartDate(_:interval:options:afterDate)`: Returns the starting date and length of the next weekend by reference via the first two parameters. This method will return false if the current calendar or locale doesn't support weekends. The only relevant option here is `.SearchBackwards`. (See below for an example.)
> - `rangeOfWeekendStartDate(_:interval:containingDate)`: Returns the starting date and length of the weekend *containing* the given date by reference via the first two parameters. This method returns false if the given date is not in fact on a weekend or if the current calendar or locale doesn't support weekends.


## Localized Calendar Symbols

As if all that new functionality wasn't enough, `NSCalendar` also provides access to a full set of properly localized calendar symbols, making possible quick access to the names of months, days of the week, and more. Each group of symbols is further enumerated along two axes: (1) the length of the symbol and (2) its use as a standalone noun or as part of a date. 

Understanding this second attribute is extremely important for localization, since some languages, Slavic languages in particular, use different noun cases for different contexts. For example, a calendar would need to use one of the `standaloneMonthSymbols` variants for its headers, not the `monthSymbols` that are used for formatting specific dates.

For your perusal, here's a table of all the symbols that are available in `NSCalendar`—note the different values for standalone symbols in the Russian column:

| &nbsp; | en_US | ru_RU |
|--------|-------|-------|
| `monthSymbols` | January, February, March… | января, февраля, марта… |
| `shortMonthSymbols` | Jan, Feb, Mar… | янв., февр., марта… |
| `veryShortMonthSymbols` | J, F, M, A… | Я, Ф, М, А… |
| `standaloneMonthSymbols` | January, February, March… | Январь, Февраль, Март… |
| `shortStandaloneMonthSymbols` | Jan, Feb, Mar… | Янв., Февр., Март… |
| `veryShortStandaloneMonthSymbols` | J, F, M, A… | Я, Ф, М, А… |
| `weekdaySymbols` | Sunday, Monday, Tuesday, Wednesday… | воскресенье, понедельник, вторник, среда… |
| `shortWeekdaySymbols` | Sun, Mon, Tue, Wed… | вс, пн, вт, ср… |
| `veryShortWeekdaySymbols` | S, M, T, W… | вс, пн, вт, ср… |
| `standaloneWeekdaySymbols` | Sunday, Monday, Tuesday, Wednesday… | Воскресенье, Понедельник, Вторник, Среда… |
| `shortStandaloneWeekdaySymbols` | Sun, Mon, Tue, Wed… | Вс, Пн, Вт, Ср… |
| `veryShortStandaloneWeekdaySymbols` | S, M, T, W… | В, П, В, С… |
| `AMSymbol` | AM | AM |
| `PMSymbol` | PM | PM |
| `quarterSymbols` | 1st quarter, 2nd quarter, 3rd quarter, 4th quarter | 1-й квартал, 2-й квартал, 3-й квартал, 4-й квартал |
| `shortQuarterSymbols` | Q1, Q2, Q3, Q4 | 1-й кв., 2-й кв., 3-й кв., 4-й кв. |
| `standaloneQuarterSymbols` | 1st quarter, 2nd quarter, 3rd quarter, 4th quarter | 1-й квартал, 2-й квартал, 3-й квартал, 4-й квартал |
| `shortStandaloneQuarterSymbols` | Q1, Q2, Q3, Q4 | 1-й кв., 2-й кв., 3-й кв., 4-й кв. |
| `eraSymbols` | BC, AD | до н. э., н. э. |
| `longEraSymbols` | Before Christ, Anno Domini | до н.э., н.э. |

> *Note:* These same collections are also available via `NSDateFormatter`.

## Your Weekly Swiftification

It's becoming something of a feature here at NSHipster to close with a slightly Swift-ified version of the discussed API. Even in this brand-new set of `NSCalendar` APIs, there are some sharp edges to be rounded off, replacing `UnsafeMutablePointer` parameters with more idiomatic tuple return values. 

With a useful set of `NSCalendar` extensions ([gist here](https://gist.github.com/natecook1000/43976a66fa04e3fdb3c7)), the component accessing and weekend finding methods can be used without in-out variables. For example, getting individual date components from a date is much simpler:

```swift
// built-in
var hour = 0
var minute = 0
calendar.getHour(&hour, minute: &minute, second: nil, nanosecond: nil, fromDate: NSDate())

// swiftified
let (hour, minute, _, _) = calendar.getTimeFromDate(NSDate())
```

As is fetching the range of the next weekend:

```swift
// built-in
var startDate: NSDate?
var interval: NSTimeInterval = 0
let success = cal.nextWeekendStartDate(&startDate, interval: &interval, options: nil, afterDate: NSDate())
if success, let startDate = startDate {
    println("start: \(startDate), interval: \(interval)")
}

// swiftified
if let nextWeekend = cal.nextWeekendAfterDate(NSDate()) {
    println("start: \(nextWeekend.startDate), interval: \(nextWeekend.interval)")
}
```

* * *

So take *that*, complicated calendrical math. With these new additions to `NSCalendar`, you'll have your problems sorted out in no time.

