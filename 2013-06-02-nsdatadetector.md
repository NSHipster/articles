---
title: NSDataDetector
author: Mattt
category: Cocoa
tags: nshipster
excerpt: >-
  Until humanity embraces RDF for our daily interactions, 
  computers will have to work overtime 
  to figure out what the heck we're all talking about.
revisions:
  "2013-06-02": First Publication
  "2018-08-29": Updated for Swift 4.2
status:
  swift: 4.2
  reviewed: August 29, 2018
---

Text is nothing without context.

What gives weight to our words
is their relation to one another,
to ourselves,
and to our location space-time.

Consider
<dfn>endophoric</dfn> expressions
whose meaning depends on the surrounding text,
or <dfn>deictic</dfn> expressions,
whose meaning is dependent on who the speaker is,
where they are, and when they said it.
Now consider how difficult it would be
for a computer to make sense of an utterance like
_"I'll be home in 5 minutes"_?
(And that's to say nothing of the challenges of
ambiguity and variation
in representations of dates, addresses, and other information.)

For better or worse,
that's how we communicate.
And until humanity embraces
[RDF](https://www.w3.org/RDF/)
for our daily interactions,
computers will have to work overtime
to figure out what the heck we're all talking about.

---

There's immense value in transforming natural language
into structured data that's compatible with our
calendars, address books, maps, and reminders.
Manual data entry, however, amounts to drudgery,
and is the last thing you want to force on users.

On other platforms,
you might delegate this task to a web service
or hack something together that works well enough.
Fortunately for us Cocoa developers,
Foundation us covered with `NSDataDetector`.

You can use `NSDataDetector` to extract
dates, links, phone numbers, addresses, and transit information
from natural language text.

First, create a detector,
by specifying the result types that you're interested in.
Then call the `enumerateMatches(in:options:range:using:)` method,
passing the text to be processed.
The provided closure is executed once for each result.

```swift
let string = "123 Main St. / (555) 555-1234"

let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .address]
let detector = try NSDataDetector(types: types.rawValue)
detector.enumerateMatches(in: string,
                          options: [],
                          range: range) { (result, _, _) in
    print(result)
}
```

```objc
NSString *string = @"123 Main St. / (555) 555-1234";

NSError *error = nil;
NSDataDetector *detector =
    [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress |
                                          NSTextCheckingTypePhoneNumber
                                    error:&error];

[detector enumerateMatchesInString:string
                           options:kNilOptions
                             range:NSMakeRange(0, [string length])
                        usingBlock:
^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
  NSLog(@"%@", result);
}];
```

As you might expect,
running this code produces two results:
the address "123 Main St."
and the phone number "(555) 555-1234".

> When initializing `NSDataDetector`,
> specify only the types you're interested in
> because any unused types will only slow you down.

## Discerning Information from Results

`NSDataDetector` produces `NSTextCheckingResult` objects.

On the one hand,
this makes sense
because `NSDataDetector` is actually a subclass of `NSRegularExpression`.
On the other hand,
there's not much overlap between a pattern match and detected data
other than the range and type.
So what you get is an API that's polluted
and offers no strong guarantees about what information is present
under which circumstances.

> To make matters worse,
> `NSTextCheckingResult` is also used by `NSSpellServer`.
> _Gross._

To get information about data detector results,
you need to first check its `resultType`;
depending on that,
you might access information directly through properties,
(in the case of links, phone numbers, and dates),
or indirectly by keyed values on the `components` property
(for addresses and transit information).

Here's a rundown of the various
`NSDataDetector` result types
and their associated properties:

<table>
  <thead>
    <tr>
      <th>Type</th>
      <th>Properties</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>.link</tt></td>
      <td>
        <ul>
          <li><tt>.url</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>.phoneNumber</tt></td>
      <td>
        <ul>
          <li><tt>.phoneNumber</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>.date</tt></td>
      <td>
        <ul>
          <li><tt>.date</tt></li>
          <li><tt>.duration</tt></li>
          <li><tt>.timeZone</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>.address</tt></td>
      <td>
        <ul>
          <li><tt>.components</tt></li>
          <ul>
            <li><tt>.name</tt></li>
            <li><tt>.jobTitle</tt></li>
            <li><tt>.organization</tt></li>
            <li><tt>.street</tt></li>
            <li><tt>.city</tt></li>
            <li><tt>.state</tt></li>
            <li><tt>.zip</tt></li>
            <li><tt>.country</tt></li>
            <li><tt>.phone</tt></li>
          </ul>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>.transitInformation</tt></td>
      <td>
        <ul>
          <li><tt>.components</tt></li>
          <ul>
            <li><tt>.airline</tt></li>
            <li><tt>.flight</tt></li>
          </ul>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

## Data Detector Data Points

Let's put `NSDataDetector` through its paces.
That way, we'll not only have a complete example of how to use it
to its full capacity
but see what it's actually capable of.

The following text contains one of each of the type of data
that `NSDataDetector` should be able to detect:

```swift
let string = """
   My flight (AA10) is scheduled for tomorrow night from 9 PM PST to 5 AM EST.
   I'll be staying at The Plaza Hotel, 768 5th Ave, New York, NY 10019.
   You can reach me at 555-555-1234 or me@example.com
"""
```

We can have `NSDataDetector` check for everything
by passing `NSTextCheckingAllTypes` to its initializer.
The rest is a matter of switching over each `resultType`
and extracting their respective details:

```swift
let detector = try NSDataDetector(types: NSTextCheckingAllTypes)
let range = NSRange(string.startIndex..<string.endIndex, in: string)
detector.enumerateMatches(in: string,
                          options: [],
                          range: range) { (match, flags, _) in
    guard let match = match else {
        return
    }

    switch match.resultType {
    case .date:
        let date = match.date
        let timeZone = match.timeZone
        let duration = match.duration
        print(date, timeZone, duration)
    case .address:
        if let components = match.components {
            let name = components[.name]
            let jobTitle = components[.jobTitle]
            let organization = components[.organization]
            let street = components[.street]
            let locality = components[.city]
            let region = components[.state]
            let postalCode = components[.zip]
            let country = components[.country]
            let phoneNumber = components[.phone]
            print(name, jobTitle, organization, street, locality, region, postalCode, country, phoneNumber)
        }
    case .link:
        let url = match.url
        print(url)
    case .phoneNumber:
        let phoneNumber = match.phoneNumber
        print(phoneNumber)
    case .transitInformation:
        if let components = match.components {
            let airline = components[.airline]
            let flight = components[.flight]
            print(airline, flight)
        }
    default:
        return
    }
}
```

When we run this code,
we see that `NSDataDetector` is able to identify each of the types.

| Type                | Output                                                                     |
| ------------------- | -------------------------------------------------------------------------- |
| Date                | "2018-08-31 04:00:00 +0000", "America/Los_Angeles", 18000.0                |
| Address             | `nil`, `nil`, `nil` "768 5th Ave", "New York", "NY", "10019", `nil`, `nil` |
| Link                | "mailto:me@example.com"                                                    |
| Phone Number        | "555-555-1234"                                                             |
| Transit Information | `nil`, "10"                                                                |

Impressively,
the date result correctly calculates the 6-hour duration of the flight,
accommodating for the time zone change.
However, some information is missing,
like the name of The Plaza Hotel in the address,
and the airline in the transit information.

> Even after trying a handful of different representations
> ("American Airlines 10", "AA 10", "AA #10", "American Airlines (AA) #10")
> and airlines
> ("Delta 1226", "DL 1226")
> I still wasn't able to find an example that populated the `airline` property.
> If anyone knows what's up, [@ us](https://twitter.com/NSHipster/).

## Detect (Rough) Edges

Useful as `NSDataDetector` is,
it's not a particularly _nice_ API to use.

With all of the charms of its parent class,
[`NSRegularExpression`](https://nshipster.com/nsregularexpression/),
the same, cumbersome initialization pattern of
[NSLinguisticTagger](https://nshipster.com/nltagger/),
and an
[incomplete Swift interface](https://developer.apple.com/documentation/foundation/nstextcheckingtypes),
`NSDataDetector` has an interface that only a mother could love.

But that's only the API itself.

In a broader context,
you might be surprised to learn that a nearly identical API can be found
in the `dataDetectorTypes` properties of `UITextView` and `WKWebView`.
_Nearly_ identical.

`UIDataDetectorTypes` and `WKDataDetectorTypes` are distinct from
and incompatible with `NSTextCheckingTypes`,
which is inconvenient but not super conspicuous.
But what's utterly inexplicable is that these APIs
can detect [shipment tracking numbers](https://developer.apple.com/documentation/uikit/uidatadetectortypes/1648142-shipmenttrackingnumber)
and [lookup suggestions](https://developer.apple.com/documentation/uikit/uidatadetectortypes/1648141-lookupsuggestion),
neither of which are supported by `NSDataDetector`.
It's hard to imagine why shipment tracking numbers wouldn't be supported,
which leads one to believe that it's an oversight.

---

Humans have an innate ability to derive meaning from language.
We can stitch together linguistic, situational and cultural information
into a coherent interpretation at a subconscious level.
Ironically, it's difficult to put this process into words ---
or code as the case may be.
Computers aren't hard-wired for understanding like we are.

Despite its shortcomings,
`NSDataDetector` can prove invaluable for certain use cases.
Until something better comes along,
take advantage of it in your app
to unlock the structured information hiding in plain sight.
