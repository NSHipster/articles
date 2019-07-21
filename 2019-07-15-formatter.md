---
title: Formatter
author: Mattt
category: Cocoa
tags: nshipster, popular
excerpt: >-
  Conversion is a tireless errand in software development.
  Most programs boil down to some variation of 
  transforming data into something more useful.
revisions:
  "2014-06-30": Converted examples to Swift; added iOS 8 & OS X Yosemite formatter classes.
  "2015-02-17": Converted remaining examples to Swift; reintroduced Objective-C examples; added Objective-C examples for new formatter classes.
  "2019-07-15": Updated for iOS 13 & macOS 10.15
status:
  swift: 5.1
  reviewed: July 15, 2019
---

Conversion is a tireless errand in software development.
Most programs boil down to some variation of
transforming data into something more useful.

In the case of user-facing software,
making data human-readable is an essential task ---
and a complex one at that.
A user's preferred language, calendar, and currency
can all factor into how information should be displayed,
as can other constraints, such as a label's dimensions.

All of this is to say:
calling `description` on an object just doesn't cut it
under most circumstances.
Indeed,
the real tool for this job is <dfn>`Formatter`</dfn>:
an ancient, abstract class deep in the heart of the Foundation framework
that's responsible for transforming data into textual representations.

---

`Formatter`'s origins trace back to `NSCell`,
which is used to display information and accept user input in
tables, form fields, and other views in AppKit.
Much of the API design of `(NS)Formatter` reflects this.

Back then,
formatters came in two flavors: dates and numbers.
But these days,
there are formatters for everything from
physical quantities and time intervals to personal names and postal addresses.
And as if that weren't enough to keep straight,
a good portion of these have been
<dfn>soft-deprecated</dfn>,
or otherwise superseded by more capable APIs (that are also formatters).

{% error %}
There are so many formatters in Apple SDKs
that it's impossible to keep them all working memory.
Apparently, this is as true of computers as it is for humans;
at the time of writing,
[searching for "formatter" on developer.apple.com](https://developer.apple.com/search/?q=formatter&type=Reference)
fails with a timeout!
{% enderror %}

To make sense of everything,
this week's article groups each of the built-in formatters
into one of four categories:

[Numbers and Quantities](#formatting-numbers-and-quantities)
: [`NumberFormatter`](#numberformatter)
: [`MeasurementFormatter`](#measurementformatter)

[Dates, Times, and Durations](#formatting-dates-times-and-durations)
: [`DateFormatter`](#dateformatter)
: [`ISO8601DateFormatter`](#iso8601dateformatter)
: [`DateComponentsFormatter`](#datecomponentsformatter)
: [`DateIntervalFormatter`](#dateintervalformatter)
: [`RelativeDateTimeFormatter`](#relativedatetimeformatter)

[People and Places](#formatting-people-and-places)
: [`PersonNameComponentsFormatter`](#personnamecomponentsformatter)
: [`CNPostalAddressFormatter`](#cnpostaladdressformatter)

[Lists and Items](#formatting-lists-and-items)
: [`ListFormatter`](#listformatter)

---

## Formatting Numbers and Quantities

| Class                  | Example Output  | Availability                 |
| ---------------------- | --------------- | ---------------------------- |
| `NumberFormatter`      | "1,234.56"      | iOS 2.0 <br/> macOS 10.0+    |
| `MeasurementFormatter` | "-9.80665 m/s²" | iOS 10.0+ <br/> macOS 10.12+ |
| `ByteCountFormatter`   | "756 KB"        | iOS 6.0+ <br/> macOS 10.8+   |
| `EnergyFormatter`      | "80 kcal"       | iOS 8.0+ <br/> macOS 10.10+  |
| `MassFormatter`        | "175 lb"        | iOS 8.0+ <br/> macOS 10.10+  |
| `LengthFormatter`      | "5 ft, 11 in"   | iOS 8.0+ <br/> macOS 10.10+  |
| `MKDistanceFormatter`  | "500 miles"     | iOS 7.0+ <br/> macOS 10.9+   |

{% warning %}

`ByteCountFormatter`,
`EnergyFormatter`,
`MassFormatter`,
`LengthFormatter`, and
`MKDistanceFormatter`
are superseded by `MeasurementFormatter`.

| Legacy Formatter      | Measurement Formatter Unit |
| --------------------- | -------------------------- |
| `ByteCountFormatter`  | `UnitInformationStorage`   |
| `EnergyFormatter`     | `UnitEnergy`               |
| `MassFormatter`       | `UnitMass`                 |
| `LengthFormatter`     | `UnitLength`               |
| `MKDistanceFormatter` | `UnitLength`               |

The only occasions in which you might still use
`EnergyFormatter`, `MassFormatter`, or `LengthFormatter`
are when working with the HealthKit framework;
these formatters provide conversion and interoperability
with `HKUnit` quantities.

{% endwarning %}

### NumberFormatter

`NumberFormatter` covers every aspect of number formatting imaginable.
For better or for worse
_(mostly for better)_,
this all-in-one API handles
ordinals and cardinals,
mathematical and scientific notation,
percentages,
and monetary amounts in various flavors.
It can even write out numbers in a few different languages!

So whenever you reach for `NumberFormatter`,
the first order of business is to establish
what _kind_ of number you're working with
and set the `numberStyle` property accordingly.

#### Number Styles

| Number Style         | Example Output           |
| -------------------- | ------------------------ |
| `none`               | 123                      |
| `decimal`            | 123.456                  |
| `percent`            | 12%                      |
| `scientific`         | 1.23456789E4             |
| `spellOut`           | one hundred twenty-three |
| `ordinal`            | 3rd                      |
| `currency`           | \$1234.57                |
| `currencyAccounting` | (\$1234.57)              |
| `currencyISOCode`    | USD1,234.57              |
| `currencyPlural`     | 1,234.57 US dollars      |

{% warning %}

`NumberFormatter` also has a `format` property
that takes a familiar `SPRINTF(3)`-style format string.
[As we've argued in a previous article](/expressiblebystringinterpolation/),
format strings are something to be avoided unless absolutely necessary.

{% endwarning %}

#### Rounding & Significant Digits

To prevent numbers from getting annoyingly pedantic
_("thirty-two point three three --- repeating, of course…")_,
you'll want to get a handle on `NumberFormatter`'s rounding behavior.
Here, you have two options:

- Set `usesSignificantDigits` to `true`
  to format according to the rules of
  [<dfn>significant figures</dfn>](https://en.wikipedia.org/wiki/Significant_figures)

```swift
var formatter = NumberFormatter()
formatter.usesSignificantDigits = true
formatter.minimumSignificantDigits = 1 // default
formatter.maximumSignificantDigits = 6 // default

formatter.string(from: 1234567) // 1234570
formatter.string(from: 1234.567) // 1234.57
formatter.string(from: 100.234567) // 100.235
formatter.string(from: 1.23000) // 1.23
formatter.string(from: 0.0000123) // 0.0000123
```

- Set `usesSignificantDigits` to `false`
  _(or keep as-is, since that's the default)_
  to format according to specific limits on
  how many <dfn>decimal</dfn> and <dfn>fraction</dfn> digits to show
  (the number of digits leading or trailing the decimal point, respectively).

```swift
var formatter = NumberFormatter()
formatter.usesSignificantDigits = false
formatter.minimumIntegerDigits = 0 // default
formatter.maximumIntegerDigits = 42 // default (seriously)
formatter.minimumFractionDigits = 0 // default
formatter.maximumFractionDigits = 0 // default

formatter.string(from: 1234567) // 1234567
formatter.string(from: 1234.567) // 1235
formatter.string(from: 100.234567) // 100
formatter.string(from: 1.23000) // 1
formatter.string(from: 0.0000123) // 0
```

If you need specific rounding behavior,
such as "round to the nearest integer" or "round towards zero",
check out the
`roundingMode`,
`roundingIncrement`, and
`roundingBehavior` properties.

#### Locale Awareness

Nearly everything about the formatter can be customized,
including the
grouping separator,
decimal separator,
negative symbol,
percent symbol,
infinity symbol,
and
how to represent zero values.

Although these settings can be overridden on an individual basis,
it's typically best to defer to the defaults provided by the user's locale.

{% error %}

The advice to defer to user locale defaults has a critical exception:
**money**

Consider the following code
that uses the default `NumberFormatter` settings for
American and Japanese locales
to format the same number:

```swift
let number = 1234.5678 // 🤔

let formatter = NumberFormatter()
formatter.numberStyle = .currency

let 🇺🇸 = Locale(identifier: "en_US")
formatter.locale = 🇺🇸
formatter.string(for: number) // $1,234.57

let 🇯🇵 = Locale(identifier: "ja_JP")
formatter.locale = 🇯🇵
formatter.string(for: number) // ￥ 1,235 😵
```

```objc
NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

for (NSString *identifier in @[@"en_US", @"ja_JP"]) {
    numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:identifier];
    NSLog(@"%@: %@", identifier, [numberFormatter stringFromNumber:@(1234.5678)]);
}
// Prints "$1,234.57" and "￥ 1,235" 😵
```

At the time of writing,
the difference between \$1,234.57 and ￥ 1,235
is roughly equivalent to the price difference between
a new [MacBook Air](https://www.apple.com/shop/buy-mac/macbook-air)
and
a [Lightning - 3.5 mm Adapter](https://www.apple.com/jp/shop/product/MMX62J/A/lightning-35-mmヘッドフォンジャックアダプタ).
Make a mistake like that in your app,
and someone --- developer or user ---
is going to be pretty upset.

Working with money in code is a deep topic,
but the basic guidance is this:
Use `Decimal` values (rather than `Float` or `Double`)
and specify an explicit currency.
For more information,
check out the
[Flight School Guide to Swift Numbers](https://flight.school/books/numbers/)
and its companion Swift library,
[`Money`](https://github.com/flight-school/money).

{% enderror %}

### MeasurementFormatter

`MeasurementFormatter` was introduced in iOS 10 and macOS 10.12
as part of the full complement of APIs for performing
type-safe dimensional calculations:

- `Unit` subclasses represent units of measure,
  such as count and ratio
- `Dimension` subclasses represent dimensional units of measure,
  such as mass and length,
  (which is the case for the overwhelming majority of
  the concrete subclasses provided,
  on account of them being dimensional in nature)
- A `Measurement` is a quantity of a particular `Unit`
- A `UnitConverter` converts quantities of one unit to
  a different, compatible unit

<details>

{::nomarkdown}

<summary>For the curious, here's the complete list of units supported by <code>MeasurementFormatter</code>:</summary>

{:/}

| Measure                       | Unit Subclass                     | Base Unit                           |
| ----------------------------- | --------------------------------- | ----------------------------------- |
| Acceleration                  | `UnitAcceleration`                | meters per second squared (m/s²)    |
| Planar angle and rotation     | `UnitAngle`                       | degrees (°)                         |
| Area                          | `UnitArea`                        | square meters (m²)                  |
| Concentration of mass         | `UnitConcentrationMass`           | milligrams per deciliter (mg/dL)    |
| Dispersion                    | `UnitDispersion`                  | parts per million (ppm)             |
| Duration                      | `UnitDuration`                    | seconds (sec)                       |
| Electric charge               | `UnitElectricCharge`              | coulombs (C)                        |
| Electric current              | `UnitElectricCurrent`             | amperes (A)                         |
| Electric potential difference | `UnitElectricPotentialDifference` | volts (V)                           |
| Electric resistance           | `UnitElectricResistance`          | ohms (Ω)                            |
| Energy                        | `UnitEnergy`                      | joules (J)                          |
| Frequency                     | `UnitFrequency`                   | hertz (Hz)                          |
| Fuel consumption              | `UnitFuelEfficiency`              | liters per 100 kilometers (L/100km) |
| Illuminance                   | `UnitIlluminance`                 | lux (lx)                            |
| Information Storage           | `UnitInformationStorage`          | Byte<sup>\*</sup> (byte)            |
| Length                        | `UnitLength`                      | meters (m)                          |
| Mass                          | `UnitMass`                        | kilograms (kg)                      |
| Power                         | `UnitPower`                       | watts (W)                           |
| Pressure                      | `UnitPressure`                    | newtons per square meter (N/m²)     |
| Speed                         | `UnitSpeed`                       | meters per second (m/s)             |
| Temperature                   | `UnitTemperature`                 | kelvin (K)                          |
| Volume                        | `UnitVolume`                      | liters (L)                          |

<span class="fn"><sup>\*</sup> Follows [ISO/IEC 80000-13 standard](https://en.wikipedia.org/wiki/ISO/IEC_80000); one byte is 8 bits, 1 kilobyte = 1000¹ bytes</span>

</details>

---

`MeasurementFormatter` and its associated APIs are a intuitive ---
just a delight to work with, honestly.
The only potential snag for newcomers to Swift
(or Objective-C old-timers, perhaps)
are the use of generics to constrain `Measurement` values
to a particular `Unit` type.

```swift
import Foundation

// "The swift (Apus apus) can power itself to a speed of 111.6km/h"
let speed = Measurement<UnitSpeed>(value: 111.6,
                                   unit: .kilometersPerHour)

let formatter = MeasurementFormatter()
formatter.string(from: speed) // 69.345 mph
```

#### Configuring the Underlying Number Formatter

By delegating much of its formatting responsibility to
an underlying `NumberFormatter` property,
`MeasurementFormatter` maintains a high degree of configurability
while keeping a small API footprint.

Readers with an engineering background may have noticed that
the localized speed in the previous example
gained an extra significant figure along the way.
As discussed previously,
we can enable `usesSignificantDigits` and set `maximumSignificantDigits`
to prevent incidental changes in precision.

```swift
formatter.numberFormatter.usesSignificantDigits = true
formatter.numberFormatter.maximumSignificantDigits = 4
formatter.string(from: speed) // 69.35 mph
```

#### Changing Which Unit is Displayed

A `MeasurementFormatter`,
by default,
will use the preferred unit for the user's current locale (if one exists)
instead of the one provided by a `Measurement` value.

Readers with a non-American background certainly noticed that
the localized speed in the original example
converted to a bizarre, archaic unit of measure known as "miles per hour".
You can override this default unit localization behavior
by passing the `providedUnit` option.

```swift
formatter.unitOptions = [.providedUnit]
formatter.string(from: speed) // 111.6 km/h
formatter.string(from: speed.converted(to: .milesPerHour)) // 69.35 mph
```

---

## Formatting Dates, Times, and Durations

| Class                       | Example Output    | Availability                 |
| --------------------------- | ----------------- | ---------------------------- |
| `DateFormatter`             | "July 15, 2019"   | iOS 2.0 <br/> macOS 10.0+    |
| `ISO8601DateFormatter`      | "2019-07-15"      | iOS 10.0+ <br/> macOS 10.12+ |
| `DateComponentsFormatter`   | "10 minutes"      | iOS 8.0 <br/> macOS 10.10+   |
| `DateIntervalFormatter`     | "6/3/19 - 6/7/19" | iOS 8.0 <br/> macOS 10.10+   |
| `RelativeDateTimeFormatter` | "3 weeks ago"     | iOS 13.0+ <br/> macOS 10.15  |

### DateFormatter

`DateFormatter` is the <abbr title=" Original Gangster">OG</abbr> class
for representing dates and times.
And it remains your best, first choice
for the majority of date formatting tasks.

For a while,
there was a concern that it would become overburdened with responsibilities
like its sibling `NumberFormatter`.
But fortunately,
recent SDK releases spawned new formatters for new functionality.
We'll talk about those in a little bit.

#### Date and Time Styles

The most important properties for a `DateFormatter` object are its
`dateStyle` and `timeStyle`.
As with `NumberFormatter` and its `numberStyle`,
these date and time styles provide preset configurations
for common formats.

<table>
    <thead>
        <tr>
            <th>Style</th>
            <th colspan="2">Example Output</th>
        </tr>
        <tr>
            <th></th>
            <th>Date</th>
            <th>Time</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><code>none</code></td>
            <td>“”</td>
            <td>“”</td>
        </tr>
        <tr>
            <td><code>short</code></td>
            <td>“11/16/37”</td>
            <td>“3:30 PM”</td>
        </tr>
        <tr>
            <td><code>medium</code></td>
            <td>“Nov 16, 1937”</td>
            <td>“3:30:32 PM”</td>
        </tr>
        <tr>
            <td><code>long</code></td>
            <td>“November 16, 1937”</td>
            <td>“3:30:32 PM”</td>
        </tr>
        <tr>
            <td><code>full</code></td>
            <td>“Tuesday, November 16, 1937 AD</td>
            <td>“3:30:42 PM EST”</td>
        </tr>
    </tbody>
</table>

```swift
let date = Date()

let formatter = DateFormatter()
formatter.dateStyle = .long
formatter.timeStyle = .long

formatter.string(from: date)
// July 15, 2019 at 9:41:00 AM PST

formatter.dateStyle = .short
formatter.timeStyle = .short
formatter.string(from: date)
// "7/16/19, 9:41:00 AM"
```

```objc
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
[formatter setDateStyle:NSDateFormatterLongStyle];
[formatter setTimeStyle:NSDateFormatterLongStyle];

NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
// July 15, 2019 at 9:41:00 AM PST

[formatter setDateStyle:NSDateFormatterShortStyle];
[formatter setTimeStyle:NSDateFormatterShortStyle];

NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
// 7/16/19, 9:41:00 AM
```

`dateStyle` and `timeStyle` are set independently.
So,
to display just the time for a particular date,
for example,
you set `dateStyle` to `none`:

```swift
let formatter = DateFormatter()
formatter.dateStyle = .none
formatter.timeStyle = .medium

let string = formatter.string(from: Date())
// 9:41:00 AM
```

```objc
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
[formatter setDateStyle:NSDateFormatterNoStyle];
[formatter setTimeStyle:NSDateFormatterMediumStyle];

NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
// 9:41:00 AM
```

As you might expect, each aspect of the date format can alternatively be configured individually, a la carte. For any aspiring time wizards `NSDateFormatter` has a bevy of different knobs and switches to play with.

{% warning %}

`DateFormatter` also has a `dateFormat` property
that takes a familiar `STRFTIME(3)`-style format string.
We've already called this out for `NumberFormatter`,
but it's a point that bears repeating:
use presets wherever possible and
only use custom format strings if absolutely necessary.

{% endwarning %}

### ISO8601DateFormatter

When we wrote our first article about `NSFormatter` back in 2013,
we made a point to include discussion of
[Peter Hosey's ISO8601DateFormatter](https://github.com/boredzo/iso-8601-date-formatter)'s
as the essential open-source library
for parsing timestamps from external data sources.

Fortunately,
we no longer need to proffer a third-party solution,
because, as of iOS 10.0 and macOS 10.12,
`ISO8601DateFormatter` is now built-in to Foundation.

```swift
let formatter = ISO8601DateFormatter()
formatter.date(from: "2019-07-15T09:41:00-07:00") // Jul 15, 2019 at 9:41 AM
```

{% info %}

`JSONDecoder` provides built-in support for decoding ISO8601-formatted timestamps
by way of the `.iso8601` date decoding strategy.

```swift
import Foundation

let json = #"""
[{
    "body": "Hello, world!",
    "timestamp": "2019-07-15T09:41:00-07:00"
}]
"""#.data(using: .utf8)!

struct Comment: Decodable {
    let body: String
    let timestamp: Date
}

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601

let comments = try decoder.decode([Comment].self, from: json)
comments.first?.timestamp // Jul 15, 2019 at 9:41 AM
```

{% endinfo %}

### DateIntervalFormatter

`DateIntervalFormatter` is like `DateFormatter`,
but can handle two dates at once ---
specifically, a start and end date.

```swift
let formatter = DateIntervalFormatter()
formatter.dateStyle = .short
formatter.timeStyle = .none

let fromDate = Date()
let toDate = Calendar.current.date(byAdding: .day, value: 7, to: fromDate)!

formatter.string(from: fromDate, to: toDate)
// "7/15/19 – 7/22/19"
```

```objc
NSDateIntervalFormatter *formatter = [[NSDateIntervalFormatter alloc] init];
formatter.dateStyle = NSDateIntervalFormatterShortStyle;
formatter.timeStyle = NSDateIntervalFormatterNoStyle;

NSDate *fromDate = [NSDate date];
NSDate *toDate = [fromDate dateByAddingTimeInterval:86400 * 7];

NSLog(@"%@", [formatter stringFromDate:fromDate toDate:toDate]);
// "7/15/19 – 7/22/19"
```

#### Date Interval Styles

<table>
    <thead>
        <tr>
            <th>Style</th>
            <th colspan="2">Example Output</th>
        </tr>
        <tr>
            <th></th>
            <th>Date</th>
            <th>Time</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><code>none</code></td>
            <td>“”</td>
            <td>“”</td>
        </tr>
        <tr>
            <td><code>short</code></td>
            <td>“6/30/14 - 7/11/14”</td>
            <td>“5:51 AM - 7:37 PM”</td>
        </tr>
        <tr>
            <td><code>medium</code></td>
            <td>“Jun 30, 2014 - Jul 11, 2014”</td>
            <td>“5:51:49 AM - 7:38:29 PM”</td>
        </tr>
        <tr>
            <td><code>long</code></td>
            <td>“June 30, 2014 - July 11, 2014”</td>
            <td>“6:02:54 AM GMT-8 - 7:49:34 PM GMT-8”</td>
        </tr>
        <tr>
            <td><code>full</code></td>
            <td>“Monday, June 30, 2014 - Friday, July 11, 2014</td>
            <td>“6:03:28 PM Pacific Standard Time - 7:50:08 PM Pacific Standard Time”</td>
        </tr>
    </tbody>
</table>

{% info %}
When displaying business hours,
such as "Mon – Fri: 8:00 AM – 10:00 PM",
use the `shortWeekdaySymbols` of the current `Calendar`
to get localized names for the days of the week.

```swift
import Foundation

var calendar = Calendar.current
calendar.locale = Locale(identifier: "en_US")
calendar.shortWeekdaySymbols
// ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

calendar.locale = Locale(identifier: "ja_JP")
calendar.shortWeekdaySymbols
// ["日", "月", "火", "水", "木", "金", "土"]
```

{% endinfo %}

### DateComponentsFormatter

As the name implies,
`DateComponentsFormatter` works with `DateComponents` values
([previously](/datecomponents/)),
which contain a combination of discrete calendar quantities,
such as "1 day and 2 hours".

`DateComponentsFormatter` provides localized representations of date components
in several different, pre-set formats:

```swift
let formatter = DateComponentsFormatter()
formatter.unitsStyle = .full

let components = DateComponents(day: 1, hour: 2)

let string = formatter.string(from: components)
// 1 day, 2 hours
```

```objc
NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;

NSDateComponents *components = [[NSDateComponents alloc] init];
components.day = 1;
components.hour = 2;

NSLog(@"%@", [formatter stringFromDateComponents:components]);
// 1 day, 2 hours
```

#### Date Components Unit Styles

| Style         | Example                 |
| ------------- | ----------------------- |
| `positional`  | "1:10"                  |
| `abbreviated` | "1h 10m"                |
| `short`       | "1hr 10min"             |
| `full`        | "1 hour, 10 minutes"    |
| `spellOut`    | "One hour, ten minutes" |

#### Formatting Context

Some years ago,
formatters introduced the concept of <dfn>formatting context</dfn>,
to handle situations where
the capitalization and punctuation of a localized string may depend on whether
it appears at the beginning or middle of a sentence.
A `context` property is available for `DateComponentsFormatter`,
as well as `DateFormatter`, `NumberFormatter`, and others.

| Formatting Context    | Output               |
| --------------------- | -------------------- |
| `standalone`          | "About 2 hours"      |
| `listItem`            | "About 2 hours"      |
| `beginningOfSentence` | "About 2 hours"      |
| `middleOfSentence`    | "about 2 hours"      |
| `dynamic`             | Depends<sup>\*</sup> |

<span class="fn"><sup>\*</sup>
A `Dynamic` context changes capitalization automatically
depending on where it appears in the text
for locales that may position strings differently
depending on the content.</span>

### RelativeDateTimeFormatter

`RelativeDateTimeFormatter` is a newcomer in iOS 13 ---
and at the time of writing, still undocumented,
so consider this an NSHipster exclusive scoop!

Longtime readers may recall that
`DateFormatter` actually gave this a try circa iOS 4
by way of the `doesRelativeDateFormatting` property.
But that hardly ever worked,
and most of us forgot about it, probably.
Fortunately,
`RelativeDateTimeFormatter` succeeds
where `doesRelativeDateFormatting` fell short,
and offers some great new functionality to make your app
more personable and accessible.

(As far as we can tell,)
`RelativeDatetimeFormatter` takes the most significant date component
and displays it in terms of past or future tense
("1 day ago" / "in 1 day").

```swift
let formatter = RelativeDateTimeFormatter()

formatter.localizedString(from: DateComponents(day: 1, hour: 1)) // "in 1 day"
formatter.localizedString(from: DateComponents(day: -1)) // "1 day ago"
formatter.localizedString(from: DateComponents(hour: 3)) // "in 3 hours"
formatter.localizedString(from: DateComponents(minute: 60)) // "in 60 minutes"
```

For the most part,
this seems to work really well.
However, its handling of `nil`, zero, and net-zero values
leaves something to be desired...

```swift
formatter.localizedString(from: DateComponents(hour: 0)) // "in 0 hours"
formatter.localizedString(from: DateComponents(day: 1, hour: -24)) // "in 1 day"
formatter.localizedString(from: DateComponents()) // ""
```

#### Styles

| Style         | Example                   |
| ------------- | ------------------------- |
| `abbreviated` | "1 mo. ago" <sup>\*</sup> |
| `short`       | "1 mo. ago"               |
| `full`        | "1 month ago"             |
| `spellOut`    | "one month ago"           |

<span class="fn"><sup>\*</sup>May produce output distinct from `short` for non-English locales.</span>

#### Using Named Relative Date Times

By default,
`RelativeDateTimeFormatter` adopts the formulaic convention
we've seen so far.
But you can set the `dateTimeStyle` property to `.named`
to prefer localized <dfn>deictic expressions</dfn> ---
"tomorrow", "yesterday", "next week" ---
whenever one exists.

```swift
import Foundation

let formatter = RelativeDateTimeFormatter()
formatter.localizedString(from: DateComponents(day: -1)) // "1 day ago"

formatter.dateTimeStyle = .named
formatter.localizedString(from: DateComponents(day: -1)) // "yesterday"
```

This just goes to show that
beyond calendrical and temporal relativity,
`RelativeDateTimeFormatter` is a real whiz at linguistic relativity, too!
For example,
English doesn't have a word to describe the day before yesterday,
whereas other languages, like German, do.

```swift
formatter.localizedString(from: DateComponents(day: -2)) // "2 days ago"

formatter.locale = Locale(identifier: "de_DE")
formatter.localizedString(from: DateComponents(day: -2)) // "vorgestern"
```

<em lang="de">Hervorragend!</em>

---

## Formatting People and Places

| Class                           | Example Output                              | Availability                 |
| ------------------------------- | ------------------------------------------- | ---------------------------- |
| `PersonNameComponentsFormatter` | "J. Appleseed"                              | iOS 9.0+ <br/> macOS 10.11+  |
| `CNContactFormatter`            | "Applessed, Johnny"                         | iOS 13.0+ <br/> macOS 10.15+ |
| `CNPostalAddressFormatter`      | "1 Infinite Loop\\n<br/>Cupertino CA 95014" | iOS 13.0+ <br/> macOS 10.15+ |

{% warning %}

`CNContactFormatter`
is superseded by `PersonNameComponentsFormatter`.

Unless you're working with existing `CNContact` objects,
prefer the use of `PersonNameComponentsFormatter` to format personal names.

{% endwarning %}

### PersonNameComponentsFormatter

`PersonNameComponentsFormatter` is a sort of high water mark for Foundation.
It encapsulates one of the [hardest](https://martinfowler.com/bliki/TwoHardThings.html),
most personal problems in computer
in such a way to make it accessible to anyone
without requiring a degree in Ethnography.

The [documentation](https://developer.apple.com/documentation/foundation/personnamecomponentsformatter)
does a wonderful job illustrating the complexities of personal names
(if I might say so myself),
but if you had any doubt of the utility of such an API,
consider the following example:

```swift
let formatter = PersonNameComponentsFormatter()

var nameComponents = PersonNameComponents()
nameComponents.givenName = "Johnny"
nameComponents.familyName = "Appleseed"

formatter.string(from: nameComponents) // "Johnny Appleseed"
```

Simple enough, right?
We all know names are space delimited, first-last... _right?_

```swift
nameComponents.givenName = "约翰尼"
nameComponents.familyName = "苹果籽"

formatter.string(from: nameComponents) // "苹果籽约翰尼"
```

_'nuf said._

### CNPostalAddressFormatter

`CNPostalAddressFormatter` provides a convenient `Formatter`-based API
to functionality dating back to the original AddressBook framework.

The following example formats a constructed `CNMutablePostalAddress`,
but you'll most likely use existing `CNPostalAddress` values
retrieved from the user's address book.

```swift
let address = CNMutablePostalAddress()
address.street = "One Apple Park Way"
address.city = "Cupertino"
address.state = "CA"
address.postalCode = "95014"

let addressFormatter = CNPostalAddressFormatter()
addressFormatter.string(from: address)
/* "One Apple Park Way
    Cupertino CA 95014" */
```

#### Styling Formatted Attributed Strings

When formatting compound values,
it can be hard to figure out where each component went
in the final, resulting string.
This can be a problem when you want to, for example,
call out certain parts in the UI.

Rather than hacking together an ad-hoc,
[regex](/swift-regular-expressions/)-based solution,
`CNPostalAddressFormatter` provides a method that vends an
`NSAttributedString` that lets you identify
the ranges of each component
(`PersonNameComponentsFormatter` does this too).

The `NSAttributedString` API is...
to put it politely,
bad.
It feels bad to use.

So for the sake of anyone hoping to take advantage of this functionality,
please copy-paste and appropriate the following code sample
to your heart's content:

```swift
var attributedString = addressFormatter.attributedString(
                            from: address,
                            withDefaultAttributes: [:]
                       ).mutableCopy() as! NSMutableAttributedString

let stringRange = NSRange(location: 0, length: attributedString.length)
attributedString.enumerateAttributes(in: stringRange, options: []) { (attributes, attributesRange, _) in
    let color: UIColor
    switch attributes[NSAttributedString.Key(CNPostalAddressPropertyAttribute)] as? String {
    case CNPostalAddressStreetKey:
        color = .red
    case CNPostalAddressCityKey:
        color = .orange
    case CNPostalAddressStateKey:
        color = .green
    case CNPostalAddressPostalCodeKey:
        color = .purple
    default:
        return
    }

    attributedString.addAttribute(.foregroundColor,
                                  value: color,
                                  range: attributesRange)
}
```

<figure>
<address style="display: inline-block; padding: 1em; font-style: normal;">
<span style="color: red;">One Apple Park Way</span><br/>
<span style="color: orange;">Cupertino</span> 
<span style="color: green;">CA</span>
<span style="color: purple;">95014</span>
</address>
</figure>

---

## Formatting Lists and Items

| Class           | Example Output                          | Availability                 |
| --------------- | --------------------------------------- | ---------------------------- |
| `ListFormatter` | "macOS, iOS, iPadOS, watchOS, and tvOS" | iOS 13.0+ <br/> macOS 10.15+ |

### ListFormatter

Rounding out our survey of formatters in the Apple SDK,
it's another new addition in iOS 13:
`ListFormatter`.
To be completely honest,
we didn't know where to put this in the article,
so we just kind of stuck it on the end here.
(Though in hindsight,
this is perhaps appropriate given the subject matter).

Once again,
[we don't have any official documentation to work from at the moment](https://developer.apple.com/documentation/foundation/listformatter),
but the comments in the header file give us enough to go on.

> NSListFormatter provides locale-correct formatting of a list of items
> using the appropriate separator and conjunction.
> Note that the list formatter is unaware of
> the context where the joined string will be used,
> e.g., in the beginning of the sentence
> or used as a standalone string in the UI,
> so it will not provide any sort of capitalization customization on the given items,
> but merely join them as-is.
>
> The string joined this way may not be grammatically correct when placed in a sentence,
> and it should only be used in a standalone manner.

_tl;dr_:
This is `joined(by:)` with locale-aware serial and penultimate delimiters.

For simple lists of strings,
you don't even need to bother with instantiating `ListFormatter` ---
just call the `localizedString(byJoining:)` class method.

```swift
import Foundation

let operatingSystems = ["macOS", "iOS", "iPadOS", "watchOS", "tvOS"]
ListFormatter.localizedString(byJoining: operatingSystems)
// "macOS, iOS, iPadOS, watchOS, and tvOS"
```

`ListFormatter` works as you'd expect
for lists comprising zero, one, or two items.

```swift
ListFormatter.localizedString(byJoining: [])
// ""

ListFormatter.localizedString(byJoining: ["Apple"])
// "Apple"

ListFormatter.localizedString(byJoining: ["Jobs", "Woz"])
// "Jobs and Woz"
```

#### Lists of Formatted Values

`ListFormatter` exposes an underlying `itemFormatter` property,
which effectively adds a `map(_:)` before calling `joined(by:)`.
You use `itemFormatter` whenever you'd formatting a list of non-String elements.
For example,
you can set a `NumberFormatter` as the `itemFormatter` for a `ListFormatter`
to turn an array of cardinals (`Int` values)
into a localized list of ordinals.

```swift
let numberFormatter = NumberFormatter()
numberFormatter.numberStyle = .ordinal

let listFormatter = ListFormatter()
listFormatter.itemFormatter = numberFormatter

listFormatter.string(from: [1, 2, 3])
// "1st, 2nd, and 3rd"
```

{% warning %}

If you set a custom locale on your list formatter,
be sure to set that locale for the underlying formatter.
And be mindful of value semantics, too ---
without the re-assignment to `itemFormatter` in the example below,
you'd get a French list of English ordinals instead.

```swift
let 🇫🇷 = Locale(identifier: "fr_FR")
listFormatter.locale = 🇫🇷

numberFormatter.locale = 🇫🇷
listFormatter.itemFormatter = numberFormatter

listFormatter.string(from: [1, 2, 3])
// "1er, 2e et 3e"
```

{% endwarning %}

---

As some of the oldest members of the Foundation framework,
`NSNumberFormatter` and `NSDateFormatter`
are astonishingly well-suited to their respective domains,
in that way only decade-old software can.
This tradition of excellence is carried by the most recent incarnations as well.

If your app deals in numbers or dates
(or time intervals or names or lists measurements of any kind),
then `NSFormatter` is indispensable.

And if your app _doesn't_...
then the question is,
what _does_ it do, exactly?

Invest in learning all of the secrets of Foundation formatters
to get everything exactly how you want them.
And if you find yourself with formatting logic scattered across your app,
consider creating your own `Formatter` subclass
to consolidate all of that business logic in one place.

{% asset articles/formatter.css %}
