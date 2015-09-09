---
title: NSDataDetector
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Until humanity embraces RDF for all of their daily interactions, a large chunk of artificial intelligence is going to go into figuring out what the heck we're all talking about. Fortunately for Cocoa developers, there's NSDataDetector."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Machines speak in binary, while humans speak in riddles, half-truths, and omissions.

And until humanity embraces [RDF](http://en.wikipedia.org/wiki/Resource_Description_Framework) for all of their daily interactions, a large chunk of artificial intelligence is going to go into figuring out what the heck we're all talking about.

Because in the basic interactions of our daily lives—meeting people, making plans, finding information online—there is immense value in automatically converting from implicit human language to explicit structured data, so that it can be easily added to our calendars, address books, maps, and reminders.

Fortunately for Cocoa developers, there's an easy solution: `NSDataDetector`.

---

`NSDataDetector` is a subclass of [`NSRegularExpression`](https://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSRegularExpression_Class/Reference/Reference.html), but instead of matching on an ICU pattern, it detects semi-structured information: dates, addresses, links, phone numbers and transit information.

It does all of this with frightening accuracy. `NSDataDetector` will match flight numbers, address snippets, oddly formatted digits, and even relative deictic expressions like "next Saturday at 5".

You can think of it as a regexp matcher with incredibly complicated expressions that can extract information from natural language (though its actual implementation details may be somewhat more complicated than that).

`NSDataDetector` objects are initialized with a bitmask of types of information to check, and then passed strings to match on. Like `NSRegularExpression`, each match found in a string is represented by a `NSTextCheckingResult`, which has details like character range and match type. However, `NSDataDetector`-specific types may also contain metadata such as address or date components.

~~~{swift}
let string = "123 Main St. / (555) 555-5555"
let types: NSTextCheckingType = [.Address, .PhoneNumber]
let detector = try? NSDataDetector(types: types.rawValue)
detector?.enumerateMatchesInString(string, options: [], range: NSMakeRange(0, (string as NSString).length)) { (result, flags, _) in
    print(result)
}
~~~
~~~{objective-c}
NSError *error = nil;
NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress
                                                        | NSTextCheckingTypePhoneNumber
                                                           error:&error];

NSString *string = @"123 Main St. / (555) 555-5555";
[detector enumerateMatchesInString:string
                           options:kNilOptions
                             range:NSMakeRange(0, [string length])
                        usingBlock:
^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
  NSLog(@"Match: %@", result);
}];
~~~

> When initializing `NSDataDetector`, be sure to specify only the types you're interested in. With each additional type to be checked comes a nontrivial performance cost.

## Data Detector Match Types

Because of how much `NSTextCheckingResult` is used for, it's not immediately clear which properties are specific to `NSDataDetector`. For your reference, here is a table of the different `NSTextCheckingTypes` for `NSDataDetector` matches, and their associated properties:

<table>
  <thead>
    <tr>
      <th>Type</th>
      <th>Properties</th>
    </tr>
  </thead>
  <tbody>

    <tr>
      <td><tt>NSTextCheckingTypeDate</tt></td>
      <td>
        <ul>
          <li><tt>date</tt></li>
          <li><tt>duration</tt></li>
          <li><tt>timeZone</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>NSTextCheckingTypeAddress</tt></td>
      <td>
        <ul>
          <li><tt>addressComponents</tt><sup>*</sup></li>
          <ul>
            <li><tt>NSTextCheckingNameKey</tt></li>
            <li><tt>NSTextCheckingJobTitleKey</tt></li>
            <li><tt>NSTextCheckingOrganizationKey</tt></li>
            <li><tt>NSTextCheckingStreetKey</tt></li>
            <li><tt>NSTextCheckingCityKey</tt></li>
            <li><tt>NSTextCheckingStateKey</tt></li>
            <li><tt>NSTextCheckingZIPKey</tt></li>
            <li><tt>NSTextCheckingCountryKey</tt></li>
            <li><tt>NSTextCheckingPhoneKey</tt></li>
          </ul>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>NSTextCheckingTypeLink</tt></td>
      <td>
        <ul>
          <li><tt>url</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>NSTextCheckingTypePhoneNumber</tt></td>
      <td>
        <ul>
          <li><tt>phoneNumber</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>NSTextCheckingTypeTransitInformation</tt></td>
      <td>
        <ul>
          <li><tt>components</tt><sup>*</sup></li>
          <ul>
            <li><tt>NSTextCheckingAirlineKey</tt></li>
            <li><tt>NSTextCheckingFlightKey</tt></li>
          </ul>
        </ul>
      </td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td colspan="2"><sup>*</sup> <tt>NSDictionary</tt> properties have values at defined keys.
  </tfoot>
</table>

## Data Detection on iOS

Somewhat confusingly, iOS also defines `UIDataDetectorTypes`. A bitmask of these values can be set as the `dataDetectorTypes` of a `UITextView` to have detected data automatically linked in the displayed text.

`UIDataDetectorTypes` is distinct from `NSTextCheckingTypes` in that equivalent enum constants (e.g. `UIDataDetectorTypePhoneNumber` and `NSTextCheckingTypePhoneNumber`) do not have the same integer value, and not all values in one are found in the other. Converting from `UIDataDetectorTypes` to `NSTextCheckingTypes` can be accomplished with a function:

~~~{swift}
func NSTextCheckingTypesFromUIDataDetectorTypes(dataDetectorType: UIDataDetectorTypes) -> NSTextCheckingType {
    var textCheckingType: NSTextCheckingType = []
    
    if dataDetectorType.contains(.Address) {
        textCheckingType.insert(.Address)
    }
    
    if dataDetectorType.contains(.CalendarEvent) {
        textCheckingType.insert(.Date)
    }
    
    if dataDetectorType.contains(.Link) {
        textCheckingType.insert(.Link)
    }
    
    if dataDetectorType.contains(.PhoneNumber) {
        textCheckingType.insert(.PhoneNumber)
    }
    
    return textCheckingType
}
~~~
~~~{objective-c}
static inline NSTextCheckingType NSTextCheckingTypesFromUIDataDetectorTypes(UIDataDetectorTypes dataDetectorType) {
    NSTextCheckingType textCheckingType = 0;
    if (dataDetectorType & UIDataDetectorTypeAddress) {
        textCheckingType |= NSTextCheckingTypeAddress;
    }

    if (dataDetectorType & UIDataDetectorTypeCalendarEvent) {
        textCheckingType |= NSTextCheckingTypeDate;
    }

    if (dataDetectorType & UIDataDetectorTypeLink) {
        textCheckingType |= NSTextCheckingTypeLink;
    }

    if (dataDetectorType & UIDataDetectorTypePhoneNumber) {
        textCheckingType |= NSTextCheckingTypePhoneNumber;
    }

    return textCheckingType;
}
~~~

---

Do I detect some disbelief of how easy it is to translate between natural language and structured data? This should not be surprising, given how [insanely](http://nshipster.com/cfstringtransform/) [great](http://nshipster.com/nslinguistictagger/) Cocoa's linguistic APIs are.

Don't make your users re-enter information by hand just because of a programming oversight. Take advantage of `NSDataDetector` in your app to unlock the structured information already hiding in plain sight.
