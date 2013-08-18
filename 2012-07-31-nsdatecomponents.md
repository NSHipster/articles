---
layout: post
title: NSDateComponents

ref: "https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDateComponents_Class/Reference/Reference.html"
framework: Foundation
rating: 6.9
---

`NSDateComponents` serves an important role in the date and time APIs in Foundation. By itself, it's just a container for information about a date, such as its month, year, day of month, week of year, or whether that month is a leap month. Combined with `NSCalendar`, `NSDateComponents` becomes a remarkably convenient interchange format for calendar calculations.

Whereas dates represent a particular moment in time, date components depend on which calendar system is being used to represent them, which may differ wildly from what we're used to with the [Gregorian Calendar](http://en.wikipedia.org/wiki/Gregorian_calendar). For example, the [Islamic Calendar](http://en.wikipedia.org/wiki/Islamic_calendar) has 354 or 355 days in a year, whereas the [Buddhist calendar](http://en.wikipedia.org/wiki/Buddhist_calendar) may have 354, 355, 384, or 385 days, depending on the year.

The most common use of `NSDateComponents` is to determine information about a given date, which may be used to group events by day or week, for instance. To do this, get the calendar for the current locale, and then use `NSCalendar -components:fromDate:`.

~~~{objective-c}
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *date = [NSDate date];
[calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:date];
~~~

The `components` parameter is a [bitmask](http://en.wikipedia.org/wiki/Bitmask) of the date component values to retrieve:

- `NSEraCalendarUnit`
- `NSYearCalendarUnit`
- `NSMonthCalendarUnit`
- `NSDayCalendarUnit`
- `NSHourCalendarUnit`
- `NSMinuteCalendarUnit`
- `NSSecondCalendarUnit`
- `NSWeekCalendarUnit`
- `NSWeekdayCalendarUnit`
- `NSWeekdayOrdinalCalendarUnit`
- `NSQuarterCalendarUnit`
- `NSWeekOfMonthCalendarUnit`
- `NSWeekOfYearCalendarUnit`
- `NSYearForWeekOfYearCalendarUnit`
- `NSCalendarCalendarUnit`
- `NSTimeZoneCalendarUnit`

Since it would be expensive to compute all of the possible values, specify only the ones you'll use in subsequent calculations (joining with `|`, the bitwise `OR` operator).

Another way you may use `NSDateComponents` would be to make relative date calculations, such as determining the date yesterday, next week, or 5 hours and 30 minutes from now. Use `NSCalendar -dateByAddingComponents:toDate:options:`:

~~~{objective-c}
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *date = [NSDate date];

NSDateComponents *components = [[NSDateComponents alloc] init];
[components setWeek:1];
[components setHour:12];

NSLog(@"1 week and twelve hours from now: %@", [calendar dateByAddingComponents:components toDate:date options:0]);
~~~

One last example of how you can use `NSDateComponents` would be to use them to create an `NSDate` object from components. `NSCalendar -dateFromComponents:` is the method you'll use here:

~~~{objective-c}
NSCalendar *calendar = [NSCalendar currentCalendar];
    
NSDateComponents *components = [[NSDateComponents alloc] init];
[components setYear:1987];
[components setMonth:3];
[components setDay:17];
[components setHour:14];
[components setMinute:20];
[components setSecond:0];

NSLog(@"Awesome time: %@", [calendar dateFromComponents:components]);
~~~

What's particularly interesting about this approach is that a date can be determined by information other than the normal month/day/year approach. If you pass enough information to uniquely determine the date, such as the year (e.g. 2012), and day of the the year (e.g. 213 of 365) you would get 7/31/2012 at midnight (because no time was specified, it defaults to 0). Note that passing inconsistent components will either result in some information being discarded, or `nil` being returned. 

`NSDateComponents` and its relationship to `NSCalendar` highlight the distinct advantage having a pedantically-engineered framework like Foundation at your disposal. You may not be doing calendar calculations every day, but when it comes time, knowing how to use `NSDateComponents` will save you eons of frustration.
