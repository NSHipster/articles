---
layout: post
title: NSFormatter
framework: "Foundation"
rating: 8.0
description: "Conversion is the tireless errand of software development. Most programming tasks boil down to some variation of transforming data into something more useful."
---

Conversion is the tireless errand of software development. Most programming tasks boil down to some variation of transforming data into something more useful.

In the case of user-facing software, converting data into human-readable form is an essential task, and a complex one at that. A user's preferred language, locale, calendar, or currency can all factor into how information should be displayed, as can other constraints, such as a label's dimensions.

All of this is to say that sending `-description` to an object just isn't going to cut it in most circumstances. Even `+stringWithFormat:` is going to ultimately disappoint. No, the real tool for this job is `NSFormatter`. 

* * *

`NSFormatter` is an abstract class for transforming data into a textual representation. It can also interpret valid textual representations back into data.

Its origins trace back to `NSCell`, which is used to display information and accept user input in tables, form fields, and other views in AppKit. Much of the API design of NSFormatter reflects this.

Foundation provides two concrete subclasses for `NSFormatter`: `NSNumberFormatter` and `NSDateFormatter`. As some of the oldest members of the Foundation framework, these classes are astonishingly well-suited to their respective domains, in that way only decade-old software can.

## NSNumberFormatter

`NSNumberFormatter` handles every aspect of number formatting imaginable, from mathematical and scientific notation, to currencies and percentages. Nearly everything about the formatter can be customized, whether it's the currency symbol, grouping separator, number of significant digits, rounding behavior, fractions, character for infinity, string representation for `0`, or maximum / minimum values. It can even write out numbers in several languages!

### Number Styles

When using an `NSNumberFormatter`, the first order of business is to determine what kind of information you're displaying. Is it a price? Is this a whole number, or should decimal values be shown?

`NSNumberFormatter` can be configured for any one of the following formats, with `-setNumberStyle:`:

To illustrate the differences between each style, here is how the number `12345.6789` would be displayed for each: 

> - `NSNumberFormatterNoStyle`: 12346
> - `NSNumberFormatterDecimalStyle`: 12345.6789
> - `NSNumberFormatterCurrencyStyle`: $12345.68
> - `NSNumberFormatterPercentStyle`: 1234567%
> - `NSNumberFormatterScientificStyle`: 1.23456789E4
> - `NSNumberFormatterSpellOutStyle`: twelve thousand three hundred forty-five point six seven eight nine

### Locale Awareness

By default, `NSNumberFormatter` will format according to the current locale settings, for things like currency symbol ($, £, €, etc.) and whether to use "," or "." as the decimal separator.

~~~{objective-c}
NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

for (NSString *identifier in @[@"en_US", @"fr_FR"]) {
    numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:identifier];
    NSLog(@"%@: %@", identifier, [numberFormatter stringFromNumber:@(1234.5678)]);
}
~~~

    en_US: $1,234.57
    fr_FR: 1 234,57 €

> All of those settings can be overridden on an individual basis, but for most apps, the best strategy would be deferring to the locale's default settings.

### Rounding & Significant Digits

In order to prevent numbers from getting annoyingly pedantic (_"thirty-two point three three, repeating, of course..."_), make sure to get a handle on `NSNumberFormatter`'s rounding behavior.

The easiest way to do this, would be to `setUsesSignificantDigits:` to `YES`, and then set minimum and maximum number of significant digits appropriately. For example, a number formatter used for approximate distances in directions, would do well with significant digits to the tenths place for miles or kilometers, but only the ones place for feet or meters.

For anything more advanced, an `NSDecimalNumberHandler` object can be passed as the `roundingBehavior` property of a number formatter.

## NSDateFormatter

`NSDateFormatter` is the be all and end all of getting textual representations of both dates and times.

### Date & Time Styles

The most important properties for an `NSDateFormatter` object is its `dateStyle` and `timeStyle`. Like `NSNumberFormatter -numberStyle`, these styles provide common preset configurations for common formats. In this case, the various formats are distinguished by their specificity (more specific = longer).

Both properties share a single set of `enum` values: 

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
            <td><tt>NSDateFormatterNoStyle</tt></td>
            <td>Specifies no style.</td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td><tt>NSDateFormatterShortStyle</tt></td>
            <td>Specifies a short style, typically numeric only.</td>
            <td>11/23/37</td>
            <td>3:30pm</td>
        </tr>
        <tr>
            <td><tt>NSDateFormatterMediumStyle</tt></td>
            <td>Specifies a medium style, typically with abbreviated text.</td>
            <td>Nov 23, 1937</td>
            <td>3:30:32pm</td>
        </tr>
        <tr>
            <td><tt>NSDateFormatterLongStyle</tt></td>
            <td>Specifies a long style, typically with full text.</td>
            <td>November 23, 1937</td>
            <td>3:30:32pm</td>
        </tr>
        <tr>
            <td><tt>NSDateFormatterFullStyle</tt></td>
            <td>Specifies a full style with complete details.</td>
            <td>Tuesday, April 12, 1952 AD</td>
            <td>3:30:42pm PST</td>
        </tr>
    </tbody>
</table>

`dateStyle` and `timeStyle` are set independently. For example to display just the time, an `NSDateFormatter` would be configured with a `dateStyle` of `NSDateFormatterNoStyle`:

~~~{objective-c}
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
[formatter setDateStyle:NSDateFormatterNoStyle];
[formatter setTimeStyle:NSDateFormatterMediumStyle];

NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
// 12:11:19pm
~~~

Whereas setting both to `NSDateFormatterLongStyle` yields the following:

~~~{objective-c}
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
[formatter setDateStyle:NSDateFormatterLongStyle];
[formatter setTimeStyle:NSDateFormatterLongStyle];

NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
// Monday, November 11, 2013 12:11:19pm PST
```

As you might expect, each aspect of the date format can alternatively be configured individually, a la carte. For any aspiring time wizards `NSDateFormatter` has a bevy of different knobs and switches to play with.

### Relative Formatting

As of iOS 4 / OS X 10.6, `NSDateFormatter` supports relative date formatting for certain locales with the `doesRelativeDateFormatting` property. Setting this to `YES` would format the date of `[NSDate date]` to "Today".

## Re-Using Formatter Instances

Perhaps the most critical detail to keep in mind when using formatters is that they are _extremely_ expensive to create. Even just an `alloc init` of an `NSNumberFormatter` in a tight loop is enough to bring an app to its knees.

Therefore, it's strongly recommended that formatters be created once, and re-used as much as possible.

If it's just a single method using a particular formatter, a static instance is a good strategy:

~~~{objective-c}
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

> `dispatch_once` guarantees that the specified block is called only the first time it's encountered.

If the formatter is used across several methods in the same class, that static instance can be refactored into a singleton method:

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

* * *

If your app deals in numbers or dates, `NSFormatter` is indespensable. Actually, if your app doesn't... then what _does_ it do, exactly?

Presenting useful information to users is as much about content as presentation. Invest in learning all of the secrets of `NSNumberFormatter` and `NSDateFormatter` to get everything exactly how you want them.

And if you find yourself with formatting logic scattered across your app, consider creating your own `NSFormatter` subclass to consolidate all of that business logic in one place. 

> [FormatterKit](https://github.com/mattt/FormatterKit) has great examples of `NSFormatter` subclasses for addresses, arrays, colors, locations, ordinal numbers, time intervals, and units of information.
