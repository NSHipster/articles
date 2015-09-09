---
title: NSFormatter
author: Mattt Thompson
category: Cocoa
tags: nshipster, popular
excerpt: "Conversion is the tireless errand of software development. Most programming tasks boil down to some variation of transforming data into something more useful."
revisions:
    "2014-06-30": Converted examples to Swift; added iOS 8 & OS X Yosemite formatter classes.
    "2015-02-17": Converted remaining examples to Swift; reintroduced Objective-C examples; added Objective-C examples for new formatter classes.
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Conversion is the tireless errand of software development. Most programming tasks boil down to some variation of transforming data into something more useful.

In the case of user-facing software, converting data into human-readable form is an essential task, and a complex one at that. A user's preferred language, locale, calendar, or currency can all factor into how information should be displayed, as can other constraints, such as a label's dimensions.

All of this is to say that sending `-description` to an object just isn't going to cut it in most circumstances. Even `+stringWithFormat:` is going to ultimately disappoint. No, the real tool for this job is `NSFormatter`.

* * *

`NSFormatter` is an abstract class for transforming data into a textual representation. It can also interpret valid textual representations back into data.

Its origins trace back to `NSCell`, which is used to display information and accept user input in tables, form fields, and other views in AppKit. Much of the API design of `NSFormatter` reflects this.

Foundation provides a number of concrete subclasses for `NSFormatter` (in addition to a single `NSFormatter` subclass provided in the MapKit framework):

| Class                        | Availability                   |
|------------------------------|--------------------------------|
| `NSNumberFormatter`          | iOS 2.0 / OS X Cheetah         |
| `NSDateFormatter`            | iOS 2.0 / OS X Cheetah         |
| `NSByteCountFormatter`       | iOS 6.0 / OS X Mountain Lion   |
| `NSDateComponentsFormatter`  | iOS 8.0 / OS X Yosemite        |
| `NSDateIntervalFormatter`    | iOS 8.0 / OS X Yosemite        |
| `NSEnergyFormatter`          | iOS 8.0 / OS X Yosemite        |
| `NSMassFormatter`            | iOS 8.0 / OS X Yosemite        |
| `NSLengthFormatter`          | iOS 8.0 / OS X Yosemite        |
| `MKDistanceFormatter`        | iOS 7.0 / OS X Mavericks       |

As some of the oldest members of the Foundation framework, `NSNumberFormatter` and `NSDateFormatter` are astonishingly well-suited to their respective domains, in that way only decade-old software can. This tradition of excellence is carried by the most recent incarnations as well.

> iOS 8 & OS X Yosemite more than _doubled_ the number of system-provided formatter classes, which is pretty remarkable.

## NSNumberFormatter

`NSNumberFormatter` handles every aspect of number formatting imaginable, from mathematical and scientific notation, to currencies and percentages. Nearly everything about the formatter can be customized, whether it's the currency symbol, grouping separator, number of significant digits, rounding behavior, fractions, character for infinity, string representation for `0`, or maximum / minimum values. It can even write out numbers in several languages!

### Number Styles

When using an `NSNumberFormatter`, the first order of business is to determine what kind of information you're displaying. Is it a price? Is this a whole number, or should decimal values be shown?

`NSNumberFormatter` can be configured for any one of the following formats, with the `numberStyle` property.

To illustrate the differences between each style, here is how the number `12345.6789` would be displayed for each:

#### `NSNumberFormatterStyle`

| Formatter Style    | Output                                                              |
|--------------------|---------------------------------------------------------------------|
| `NoStyle`          | 12346                                                               |
| `DecimalStyle`     | 12345.6789                                                          |
| `CurrencyStyle`    | $12345.68                                                           |
| `PercentStyle`     | 1234567%                                                            |
| `ScientificStyle`  | 1.23456789E4                                                        |
| `SpellOutStyle`    | twelve thousand three hundred forty-five point six seven eight nine |

### Locale Awareness

By default, `NSNumberFormatter` will format according to the current locale settings, which determines things like currency symbol ($, £, €, etc.) and whether to use "," or "." as the decimal separator.

~~~{swift}
let formatter = NSNumberFormatter()
formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle

for identifier in ["en_US", "fr_FR", "ja_JP"] {
    formatter.locale = NSLocale(localeIdentifier: identifier)
    print("\(identifier) \(formatter.stringFromNumber(1234.5678))")
}
~~~

~~~{objective-c}
NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

for (NSString *identifier in @[@"en_US", @"fr_FR", @"ja_JP"]) {
    numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:identifier];
    NSLog(@"%@: %@", identifier, [numberFormatter stringFromNumber:@(1234.5678)]);
}
~~~

| Locale  | Formatted Number    |
|---------|---------------------|
| `en_US` | $1,234.57           |
| `fr_FR` | 1 234,57 €           |
| `ja_JP` | ￥1,235              |

> All of those settings can be overridden on an individual basis, but for most apps, the best strategy would be deferring to the locale's default settings.

### Rounding & Significant Digits

In order to prevent numbers from getting annoyingly pedantic (_"thirty-two point three three, repeating, of course..."_), make sure to get a handle on `NSNumberFormatter`'s rounding behavior.

The easiest way to do this, would be to set the `usesSignificantDigits` property to `false`, and then set minimum and maximum number of significant digits appropriately. For example, a number formatter used for approximate distances in directions, would do well with significant digits to the tenths place for miles or kilometers, but only the ones place for feet or meters.

> For anything more advanced, an `NSDecimalNumberHandler` object can be passed as the `roundingBehavior` property of a number formatter.

## NSDateFormatter

`NSDateFormatter` is the be all and end all of getting textual representations of both dates and times.

### Date & Time Styles

The most important properties for an `NSDateFormatter` object are its `dateStyle` and `timeStyle`. Like `NSNumberFormatter numberStyle`, these styles provide common preset configurations for common formats. In this case, the various formats are distinguished by their specificity (more specific = longer).

Both properties share a single set of `enum` values:

#### `NSDateFormatterStyle`

<table>
    <thead>
        <tr>
            <th>Style</th>
            <th>Description</th>
            <th colspan="2">Examples</th>
        </tr>
        <tr>
            <th colspan="2"></th>
            <th>Date</th>
            <th>Time</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><tt>NoStyle</tt></td>
            <td>Specifies no style.</td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td><tt>ShortStyle</tt></td>
            <td>Specifies a short style, typically numeric only.</td>
            <td>11/23/37</td>
            <td>3:30pm</td>
        </tr>
        <tr>
            <td><tt>MediumStyle</tt></td>
            <td>Specifies a medium style, typically with abbreviated text.</td>
            <td>Nov 23, 1937</td>
            <td>3:30:32pm</td>
        </tr>
        <tr>
            <td><tt>LongStyle</tt></td>
            <td>Specifies a long style, typically with full text.</td>
            <td>November 23, 1937</td>
            <td>3:30:32pm</td>
        </tr>
        <tr>
            <td><tt>FullStyle</tt></td>
            <td>Specifies a full style with complete details.</td>
            <td>Tuesday, April 12, 1952 AD</td>
            <td>3:30:42pm PST</td>
        </tr>
    </tbody>
</table>

`dateStyle` and `timeStyle` are set independently. For example, to display just the time, an `NSDateFormatter` would be configured with a `dateStyle` of `NoStyle`:

~~~{swift}
let formatter = NSDateFormatter()
formatter.dateStyle = .NoStyle
formatter.timeStyle = .MediumStyle

let string = formatter.stringFromDate(NSDate())
// 10:42:21am
~~~

~~~{objective-c}
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
[formatter setDateStyle:NSDateFormatterNoStyle];
[formatter setTimeStyle:NSDateFormatterMediumStyle];

NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
// 12:11:19pm
~~~

Whereas setting both to `LongStyle` yields the following:

~~~{swift}
let formatter = NSDateFormatter()
formatter.dateStyle = .LongStyle
formatter.timeStyle = .LongStyle

let string = formatter.stringFromDate(NSDate())
// Monday June 30, 2014 10:42:21am PST
~~~

~~~{objective-c}
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
[formatter setDateStyle:NSDateFormatterLongStyle];
[formatter setTimeStyle:NSDateFormatterLongStyle];

NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
// Monday, November 11, 2013 12:11:19pm PST
~~~

As you might expect, each aspect of the date format can alternatively be configured individually, a la carte. For any aspiring time wizards `NSDateFormatter` has a bevy of different knobs and switches to play with.

### Relative Formatting

As of iOS 4 / OS X Snow Leopard, `NSDateFormatter` supports relative date formatting for certain locales with the `doesRelativeDateFormatting` property. Setting this to `true` would format the date of `NSDate()` to "Today".

## NSByteCounterFormatter

For apps that work with files, data in memory, or information downloaded from a network, `NSByteCounterFormatter` is a must-have. All of the great information unit formatting behavior seen in Finder and other OS X apps is available with `NSByteCounterFormatter`, without any additional configuration.

`NSByteCounterFormatter` takes a raw number of bytes and formats it into more meaningful units. For example, rather than bombarding a user with a ridiculous quantity, like "8475891734 bytes", a formatter can make a more useful approximation of "8.48 GB":

~~~{swift}
let formatter = NSByteCountFormatter()
let byteCount = 8475891734
let string = formatter.stringFromByteCount(Int64(byteCount))
// 8.48 GB
~~~
~~~{objective-c}
NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
long long byteCount = 8475891734;
NSLog(@"%@", [formatter stringFromByteCount:byteCount]);
// 8.48 GB
~~~

By default, specifying a `0` byte count will yield a localized string like "Zero KB". For a more consistent format, set `allowsNonnumericFormatting` to `false`:

~~~{swift}
let formatter = NSByteCountFormatter()
let byteCount = 0

formatter.stringFromByteCount(Int64(byteCount))
// Zero KB

formatter.allowsNonnumericFormatting = false
formatter.stringFromByteCount(Int64(byteCount))
// 0 bytes
~~~
~~~{objective-c}
NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
long long byteCount = 0;

NSLog(@"%@", [formatter stringFromByteCount:byteCount]);
// Zero KB

formatter.allowsNonnumericFormatting = NO;
NSLog(@"%@", [formatter stringFromByteCount:byteCount]);
// 0 bytes
~~~

### Count Style

One might think that dealing with bytes in code (which is, you know, _a medium of bytes_) would be a piece of cake, but in reality, even determining how many bytes are in a kilobyte remains a contentious and confusing matter. ([Obligatory XKCD link](http://xkcd.com/394/))

In [SI](http://en.wikipedia.org/wiki/International_System_of_Units), the "kilo" prefix multiplies the base quantity by 1000 (i.e. 1km == 1000 m). However, being based on a binary number system, a more convenient convention has been to make a kilobyte equal to 2<sup>10</sup> bytes instead (i.e. 1KB == 1024 bytes). While the 2% difference is negligible at lower quantities, this confusion has significant implications when, for example, determining how much space is available on a 1TB drive (either 1000GB or 1024 GB).

To complicate matters further, this binary prefix was codified into the [Kibibyte](http://en.wikipedia.org/wiki/Kibibyte) standard by the [IEC](http://en.wikipedia.org/wiki/International_Electrotechnical_Commission) in 1998... which is summarily ignored by the [JEDEC](http://en.wikipedia.org/wiki/JEDEC_memory_standards#Unit_prefixes_for_semiconductor_storage_capacity), the trade and engineering standardization organization representing the actual manufacturers of storage media. The result is that one can represent information as either `1kB`, `1KB`, or `1KiB`. ([Another obligatory XKCD link](http://xkcd.com/927/))

Rather than get caught up in all of this, simply use the most appropriate count style for your particular use case:

#### NSByteCountFormatterCountStyle

| `File`    | Specifies display of file byte counts. The actual behavior for this is platform-specific; on OS X Mountain Lion, this uses the binary style, but that may change over time. |
| `Memory`  | Specifies display of memory byte counts. The actual behavior for this is platform-specific; on OS X Mountain Lion, this uses the binary style, but that may change over time. |

In most cases, it is better to use `File` or `Memory`, however decimal or binary byte counts can be explicitly specified with either of the following values:

| `Decimal` | Causes 1000 bytes to be shown as 1 KB. |
| `Binary`  | Causes 1024 bytes to be shown as 1 KB. |

## Date & Time Interval Formatters

`NSDateFormatter` is great for points in time, but when it comes to dealing with date or time ranges, Foundation was without any particularly great options. That is, until the introduction of `NSDateComponentsFormatter` & `NSDateIntervalFormatter`.

## NSDateComponentsFormatter

As the name implies, `NSDateComponentsFormatter` works with `NSDateComponents`, which was covered in [a previous NSHipster article](http://nshipster.com/nsdatecomponents/). An `NSDateComponents` object is a container for representing a combination of discrete calendar quantities, such as "1 day and 2 hours". `NSDateComponentsFormatter` provides localized representations of `NSDateComponents` objects in several different formats:

~~~{swift}
let formatter = NSDateComponentsFormatter()
formatter.unitsStyle = .Full

let components = NSDateComponents()
components.day = 1
components.hour = 2

let string = formatter.stringFromDateComponents(components)
// 1 day, 2 hours
~~~
~~~{objective-c}
NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;

NSDateComponents *components = [[NSDateComponents alloc] init];
components.day = 1;
components.hour = 2;

NSLog(@"%@", [formatter stringFromDateComponents:components]);
// 1 day, 2 hours
~~~

#### `NSDateComponentsFormatterUnitsStyle`

| Unit Style      | Example                                                           |
|-----------------|-------------------------------------------------------------------|
| `Positional`    | "1:10"                                                            |
| `Abbreviated`   | "1h 10m"                                                          |
| `Short`         | "1hr 10min"                                                       |
| `Full`          | "1 hour, 10 minutes"                                              |
| `SpellOut`      | "One hour, ten minutes"                                           |

### NSDateIntervalFormatter

Like `NSDateComponentsFormatter`, `NSDateIntervalFormatter` deals with ranges of time, but specifically for time intervals between a start and end date:

~~~{swift}
let formatter = NSDateIntervalFormatter()
formatter.dateStyle = .NoStyle
formatter.timeStyle = .ShortStyle

let fromDate = NSDate()
let toDate = fromDate.dateByAddingTimeInterval(10000)

let string = formatter.stringFromDate(fromDate, toDate: toDate)
// 5:49 - 8:36 PM
~~~
~~~{objective-c}
NSDateIntervalFormatter *formatter = [[NSDateIntervalFormatter alloc] init];
formatter.dateStyle = NSDateIntervalFormatterNoStyle;
formatter.timeStyle = NSDateIntervalFormatterShortStyle;

NSDate *fromDate = [NSDate date];
NSDate *toDate = [fromDate dateByAddingTimeInterval:10000];

NSLog(@"%@", [formatter stringFromDate:fromDate toDate:toDate]);
// 5:49 - 8:36 PM
~~~

#### `NSDateIntervalFormatterStyle`

| Formatter Style     | Time Output                         | Date Output                   |
|---------------------|-------------------------------------|-------------------------------|
| `NoStyle`           |                                     |                               |
| `ShortStyle`        | 5:51 AM - 7:37 PM                   | 6/30/14 - 7/11/14             |
| `MediumStyle`       | 5:51:49 AM - 7:38:29 PM             | Jun 30, 2014 - Jul 11, 2014   |
| `LongStyle`         | 6:02:54 AM GMT-8 - 7:49:34 PM GMT-8 | June 30, 2014 - July 11, 2014 |
| `FullStyle`         | 6:03:28 PM Pacific Standard Time - 7:50:08 PM Pacific Standard Time | Monday, June 30, 2014 - Friday, July 11, 2014 |

`NSDateIntervalFormatter` and `NSDateComponentsFormatter` are useful for displaying regular and pre-defined ranges of times such as the such as the opening hours of a business, or frequency or duration of calendar events.

> In the case of displaying business hours, such as "Mon – Fri: 8:00 AM – 10:00 PM", use the `weekdaySymbols` of an `NSDateFormatter` to get the localized names of the days of the week.

## Mass, Length, & Energy Formatters

Prior to iOS 8 / OS X Yosemite, working with physical quantities was left as an exercise to the developer. However, with the introduction of HealthKit, this functionality is now provided in the standard library.

### NSMassFormatter

Although the fundamental unit of physical existence, mass is pretty much relegated to tracking the weight of users in HealthKit.

> Yes, mass and weight are different, but this is programming, not science class, so stop being pedantic.

~~~{swift}
let massFormatter = NSMassFormatter()
let kilograms = 60.0
print(massFormatter.stringFromKilograms(kilograms)) // "132 lb"
~~~
~~~{objective-c}
NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
double kilograms = 60;
NSLog(@"%@", [massFormatter stringFromKilograms:kilograms]); // "132 lb"
~~~

### NSLengthFormatter

`NSLengthFormatter` can be thought of as a more useful version of `MKDistanceFormatter`, with more unit options and formatting options.

~~~{swift}
let lengthFormatter = NSLengthFormatter()
let meters = 5_000.0
print(lengthFormatter.stringFromMeters(meters)) // "3.107 mi"
~~~
~~~{objective-c}
NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
double meters = 5000;
NSLog(@"%@", [lengthFormatter stringFromMeters:meters]); // "3.107 mi"
~~~

### NSEnergyFormatter

Rounding out the new `NSFormatter` subclasses added for HealthKit is `NSEnergyFormatter`, which formats energy in Joules, the raw unit of work for exercises, and Calories, which is used when working with nutrition information.

~~~{swift}
let energyFormatter = NSEnergyFormatter()
energyFormatter.forFoodEnergyUse = true

let joules = 10_000.0
print(energyFormatter.stringFromJoules(joules)) // "2.39 Cal"
~~~
~~~{objective-c}
NSEnergyFormatter *energyFormatter = [[NSEnergyFormatter alloc] init];
energyFormatter.forFoodEnergyUse = YES;

double joules = 10000;
NSLog(@"%@", [energyFormatter stringFromJoules:joules]); // "2.39 Cal"
~~~

---

## Re-Using Formatter Instances

Perhaps the most critical detail to keep in mind when using formatters is that they are _extremely_ expensive to create. Even just an `alloc init` of an `NSNumberFormatter` in a tight loop is enough to bring an app to its knees.

Therefore, it's strongly recommended that formatters be created once, and re-used as much as possible.

If it's just a single method using a particular formatter, a static instance is a good strategy:

~~~{swift}
// a nested struct can have a static property, 
// created only the first time it's encountered.
func fooWithNumber(number: NSNumber) {
    struct NumberFormatter {
        static let formatter: NSNumberFormatter = {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .DecimalStyle
            return formatter
        }()
    }
    
    let string = NumberFormatter.formatter.stringFromNumber(number)
    // ...
}
~~~

~~~{objective-c}
// dispatch_once guarantees that the specified block is called 
// only the first time it's encountered.
- (void)fooWithNumber:(NSNumber *)number {
    static NSNumberFormatter *_numberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });

    NSString *string = [_numberFormatter stringFromNumber:number];

    // ...
}
~~~

If the formatter is used across several methods in the same class, that static instance can be refactored into a singleton method in Objective-C or a static type property in Swift:

~~~{swift}
static let numberFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    return formatter
}()
~~~

~~~{objective-c}
+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *_numberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });

    return _numberFormatter;
}
~~~

If the same formatter is privately implemented across several classes, one could either expose it publicly in one of the classes, or implement the static singleton method in a category on `NSNumberFormatter`.

> Prior to iOS 7 and OS X Mavericks, `NSDateFormatter` & `NSNumberFormatter` were not thread safe. Under these circumstances, the safest way to reuse formatter instances was with a thread dictionary:

~~~{objective-c}
NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
NSDateFormatter *dateFormatter = threadDictionary[@"dateFormatter"];
if (!dateFormatter) {
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    threadDictionary[@"dateFormatter"] = dateFormatter;
}

return dateFormatter;
~~~

## Formatter Context

Another addition to formatters in iOS 8 & OS X Yosemite is the idea of formatter _contexts_. This allows the formatted output to be correctly integrated into the localized string. The most salient application of this is the letter casing of formatted output at different parts of a sentence in western locales, such as English. For example, when appearing at the beginning of a sentence or by itself, the first letter of formatted output would be capitalized, whereas it would be lowercase in the middle of a sentence.

A `context` property is available for `NSDateFormatter`, `NSNumberFormatter`, `NSDateComponentsFormatter`, and `NSByteCountFormatter`, with the following values:

| Formatting Context      | Output          |
|-------------------------|-----------------|
| `Standalone`            | "About 2 hours" |
| `ListItem`              | "About 2 hours" |
| `BeginningOfSentence`   | "About 2 hours" |
| `MiddleOfSentence`      | "about 2 hours" |
| `Dynamic`               | _(Depends)_     |

In cases where localizations may change the position of formatted information within a string, the `Dynamic` value will automatically change depending on where it appears in the text.

- - -

## Third Party Formatters

An article on `NSFormatter` would be remiss without mention of some of the third party subclasses that have made themselves mainstays of everyday app development: [ISO8601DateFormatter](http://boredzo.org/iso8601dateformatter/) & [FormatterKit](https://github.com/mattt/FormatterKit)

### ISO8601DateFormatter

Created by [Peter Hosey](https://twitter.com/boredzo), [ISO8601DateFormatter](https://github.com/boredzo/iso-8601-date-formatter) has become the de facto way of dealing with [ISO 8601 timestamps](http://en.wikipedia.org/wiki/ISO_8601), used as the interchange format for dates by webservices ([Yet another obligatory XKCD link](http://xkcd.com/1179/)).

Although Apple provides [official recommendations on parsing internet dates](https://developer.apple.com/library/ios/qa/qa1480/_index.html), the reality of formatting quirks across makes the suggested `NSDateFormatter`-with-`en_US_POSIX`-locale approach untenable for real-world usage. `ISO8601DateFormatter` offers a simple, robust interface for dealing with timestamps:

~~~{swift}
let formatter = ISO8601DateFormatter()
let timestamp = "2014-06-30T08:21:56+08:00"
let date = formatter.dateFromString(timestamp)
~~~

> Although not an `NSFormatter` subclass, [TransformerKit](https://github.com/mattt/TransformerKit) offers an extremely performant alternative for parsing and formatting both ISO 8601 and RFC 2822 timestamps.

### FormatterKit

[FormatterKit](https://github.com/mattt/FormatterKit) has great examples of `NSFormatter` subclasses for use cases not currently covered by built-in classes, such as localized addresses, arrays, colors, locations, and ordinal numbers, and URL requests. It also boasts localization in 23 different languages, making it well-suited to apps serving every major market.

#### TTTAddressFormatter

~~~{swift}
let formatter = TTTAddressFormatter()
formatter.locale = NSLocale(localeIdentifier: "en_GB")

let street = "221b Baker St"
let locality = "Paddington"
let region = "Greater London"
let postalCode = "NW1 6XE"
let country = "United Kingdom"

let string = formatter.stringFromAddressWithStreet(street: street, locality: locality, region: region, postalCode: postalCode, country: country)
// 221b Baker St / Paddington / Greater London / NW1 6XE / United Kingdom
~~~
~~~{objective-c}
TTTAddressFormatter *formatter = [[TTTAddressFormatter alloc] init];
[formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_GB"]];

NSString *street = @"221b Baker St";
NSString *locality = @"Paddington";
NSString *region = @"Greater London";
NSString *postalCode = @"NW1 6XE";
NSString *country = @"United Kingdom";

NSLog(@"%@", [formatter stringFromAddressWithStreet:street locality:locality region:region postalCode:postalCode country:country]);
// 221b Baker St / Paddington / Greater London / NW1 6XE / United Kingdom
~~~

#### TTTArrayFormatter

~~~{swift}
let formatter = TTTArrayFormatter()
formatter.usesAbbreviatedConjunction = true // Use '&' instead of 'and'
formatter.usesSerialDelimiter = true // Omit Oxford Comma

let array = ["Russel", "Spinoza", "Rawls"]
let string = formatter.stringFromArray(array)
// "Russell, Spinoza & Rawls"
~~~
~~~{objective-c}
TTTArrayFormatter *formatter = [[TTTArrayFormatter alloc] init];
formatter.usesAbbreviatedConjunction = YES; // Use '&' instead of 'and'
formatter.usesSerialDelimiter = YES; // Omit Oxford Comma

NSArray *array = @[@"Russel", @"Spinoza", @"Rawls"];
NSLog(@"%@", [formatter stringFromArray:array]);
// "Russell, Spinoza & Rawls"
~~~

#### TTTColorFormatter

~~~{swift}
let formatter = TTTColorFormatter()
let color = UIColor.orangeColor()
let hex = formatter.hexadecimalStringFromColor(color);
// #ffa500
~~~
~~~{objective-c}
TTTColorFormatter *formatter = [[TTTColorFormatter alloc] init];
UIColor *color = [UIColor orangeColor];
NSLog(@"%@", [formatter hexadecimalStringFromColor:color]);
// #ffa500
~~~

#### TTTLocationFormatter

~~~{swift}
let formatter = TTTLocationFormatter()
formatter.numberFormatter.maximumSignificantDigits = 4
formatter.bearingStyle = TTTBearingAbbreviationWordStyle
formatter.unitSystem = TTTImperialSystem

let pittsburgh = CLLocation(latitude: 40.4405556, longitude: -79.9961111)
let austin = CLLocation(latitude: 30.2669444, longitude: -97.7427778)
let string = formatter.stringFromDistanceAndBearingFromLocation(pittsburgh, toLocation: austin)
// "1,218 miles SW"
~~~
~~~{objective-c}
TTTLocationFormatter *formatter = [[TTTLocationFormatter alloc] init];
formatter.numberFormatter.maximumSignificantDigits = 4;
formatter.bearingStyle = TTTBearingAbbreviationWordStyle;
formatter.unitSystem = TTTImperialSystem;

CLLocation *pittsburgh = [[CLLocation alloc] initWithLatitude:40.4405556 longitude:-79.9961111];
CLLocation *austin = [[CLLocation alloc] initWithLatitude:30.2669444 longitude:-97.7427778];
NSLog(@"%@", [formatter stringFromDistanceAndBearingFromLocation:pittsburgh toLocation:austin]);
// "1,218 miles SW"
~~~

#### TTTOrdinalNumberFormatter

~~~{swift}
let formatter = TTTOrdinalNumberFormatter()
formatter.locale = NSLocale(localeIdentifier: "fr_FR")
formatter.grammaticalGender = TTTOrdinalNumberFormatterMaleGender
let string = NSString(format: NSLocalizedString("You came in %@ place", comment: ""), formatter.stringFromNumber(2))
// "Vous êtes arrivé à la 2e place!"
~~~
~~~{objective-c}
TTTOrdinalNumberFormatter *formatter = [[TTTOrdinalNumberFormatter alloc] init];
[formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"fr_FR"]];
[formatter setGrammaticalGender:TTTOrdinalNumberFormatterMaleGender];
NSLog(@"%@", [NSString stringWithFormat:NSLocalizedString(@"You came in %@ place!", nil), [formatter stringFromNumber:@2]]);
// "Vous êtes arrivé à la 2e place!"
~~~

#### TTTURLRequestFormatter

~~~{swift}
let request = NSMutableURLRequest(URL: NSURL(string: "http://nshipster.com")!)
request.HTTPMethod = "GET"
request.addValue("text/html", forHTTPHeaderField: "Accept")

let command = TTTURLRequestFormatter.cURLCommandFromURLRequest(request)
// curl -X GET "https://nshipster.com/" -H "Accept: text/html"
~~~
~~~{objective-c}
NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.example.com/"]];
[request setHTTPMethod:@"GET"];
[request addValue:@"text/html" forHTTPHeaderField:@"Accept"];
NSLog(@"%@", [TTTURLRequestFormatter cURLCommandFromURLRequest:request]);
// curl -X GET "https://nshipster.com/" -H "Accept: text/html"
~~~

* * *

If your app deals in numbers or dates (or time intervals or bytes or distance or length or energy or mass), `NSFormatter` is indispensable. Actually, if your app doesn't… then what _does_ it do, exactly?

Presenting useful information to users is as much about content as presentation. Invest in learning all of the secrets of `NSNumberFormatter`, `NSDateFormatter`, and the rest of the Foundation formatter crew to get everything exactly how you want them.

And if you find yourself with formatting logic scattered across your app, consider creating your own `NSFormatter` subclass to consolidate all of that business logic in one place.
