---
title: Device Identifiers and Fingerprinting on iOS
author: Mattt
category: Miscellaneous
excerpt: >-
  For every era,
  there's a monster that embodies the anxieties of the age.
status:
  swift: 5.1
---

For every era,
there's a monster that embodies the anxieties of the age.

At the dawn of the [Holocene](https://en.wikipedia.org/wiki/Holocene),
our ancestors traced the contours of shadows cast by the campfire
as they kept watch over the darkness.
Once we learned to read the night sky for navigation,
sailors swapped stories of sea creatures like
[Leviathan](https://en.wikipedia.org/wiki/Leviathan) and
[Siren](https://en.wikipedia.org/wiki/Siren_%28mythology%29)
to describe the dangers of open ocean
(and the perils to be found on unfamiliar shores).

[Frankenstein's monster](https://en.wikipedia.org/wiki/Frankenstein%27s_monster)
was as much the creation of Mary Shelley
as it was a spiritual collaboration with
[Luigi Galvani](https://en.wikipedia.org/wiki/Luigi_Galvani).
And Bram Stoker's
[fictionalized account of the mummy's curse](https://en.wikipedia.org/wiki/The_Jewel_of_Seven_Stars)
was more a response to the
[Egyptomania](https://en.wikipedia.org/wiki/Egyptomania)
and European colonialism
of the nineteenth century
than any personal account of the Middle Kingdom.

More recently,
the ["monster ruins a beach party"](https://en.wikipedia.org/wiki/The_Beach_Girls_and_the_Monster)
trope of the 1960s
arose from concerns of teenager morality.
While the
[Martians](https://en.wikipedia.org/wiki/The_Day_Mars_Invaded_Earth)
who invaded those same drive-in double features
served as a proxy for Cold War fears at the height of the
[Space Race](https://en.wikipedia.org/wiki/Space_Race).

<hr/>

All of which begs the question:
_"What monster best exemplifies our present age?"_

Consider the unnamed monster from the film
_[It Follows](https://en.wikipedia.org/wiki/It_Follows)_:
a formless, supernatural being that relentlessly pursues its victims
anywhere on the planet.

Sounds a bit like the state of
<dfn title="advertising technology">ad tech</dfn>
in 2019, no?

<aside class="parenthetical">
Setting aside its central theme of carnal karma,
which follows the same well-trodden path of horror 
as our aforementioned beach monsters...
</aside>

<hr/>

This week on NSHipster —
in celebration of our favorite holiday
<abbr title="(Halloween)">🎃</abbr> —
we're taking a look at the myriad ways that
you're being tracked on iOS,
both sanctioned and unsanctioned,
historically and presently.
So gather around the campfire,
and allow us to trace the contours of the unseen, formless monsters
that stalk us under cover of [Dark Mode](/dark-mode/).

<hr/>

## The Cynicism of Marketing and Advertising Technology

Contrary to our intuitions about natural selection in the marketplace,
history is littered with examples of
inferior-but-better-marketed products winning out over superior alternatives:
_VHS vs. Betamax_,
_Windows vs. Macintosh_,
etc.
(According to the common wisdom of business folks, at least.)
Regardless,
most companies reach a point where
_“if you build it, they will come”_
ceases to be a politically viable strategy,
and someone authorizes a marketing budget.

Marketers are tasked with growing market share
by identifying and communicating with as many potential customers as possible.
And many ---
either out of a genuine belief or formulated as a post hoc rationalization ---
take the potential benefit of their product
as a license to flouting long-established customs of personal privacy.
So they enlist the help of one or more
advertising firms,
who promise to maximize their allocated budget and
provide some accountability for their spending
by using technology to
<dfn>**target**</dfn>,
<dfn>**deliver**</dfn>, and
<dfn>**analyze**</dfn>
messaging to consumers.

**Each of these tasks is predicated on a consistent identity,
which is why advertisers go to such great lengths to track you.**

- Without knowing who you are,
  marketers have no way to tell if you're a likely or even potential customer.
- Without knowing where you are,
  marketers have no way to reach you
  other than to post ads where they're likely to be seen.
- Without knowing what you do,
  marketers have no way to tell if their ads worked
  or were seen at all.

## Apple-Sanctioned Identifiers

Apple's provided various APIS to facilitate user identification
for various purposes:

### Universal Identifiers (UDID)

In the early days of iOS,
Apple provided a `uniqueIdentifier` property on `UIDevice` ---
affectionately referred to as a
<abbr title="Universal Device Identifier">UDID</abbr>
([not to be confused with a UUID](/uuid-udid-unique-identifier/)).
Although such functionality seems unthinkable today,
that property existed until iOS 5,
until it was
deprecated and replaced by `identifierForVendor` in iOS 6.

### Vendor Identifiers (IDFV)

Starting in iOS 6,
developers can use the
`identifierForVendor` property on `UIDevice`
to generate a unique identifier that's shared across apps and extensions
created by the same vendor
(<abbr title="Identifier for Vendor">IDFV</abbr>).

```swift
import UIKit

let idfv = UIDevice.current.identifierForVendor // BD43813E-CFC5-4EEB-ABE2-94562A6E76CA
```

{% warning %}

According to [the documentation](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor)
`identifierForVendor` return `nil`
"after the device has been restarted but before the user has unlocked the device."
It's unclear when that would be the case,
but something to keep in mind if your app does anything in the background.

{% endwarning %}

### Advertising Identifiers (IDFA)

Along with `identifierForVendor` came the introduction of a new
[AdSupport framework](https://developer.apple.com/documentation/adsupport),
which Apple created to help distinguish
identification necessary for app functionality
from anything in the service of advertising.

The resulting
`advertisingidentifier` property
(affectionately referred to as
<abbr title="Identifier for Advertisers">IDFA</abbr> by its associates)
differs from `identifierForVendor`
by returning the same value for everyone.
The value can change, for example,
if the user [resets their Advertising Identifier](https://support.apple.com/en-us/HT205223)
or erases their device.

```swift
import AdSupport

let idfa = ASIdentifierManager.shared().advertisingIdentifier
```

If advertising tracking is limited,
the property returns a zeroed-out UUID instead.

```swift
idfa.uuidString == "00000000-0000-0000-0000-000000000000" // true if the user has limited ad tracking
```

{% info %}

Curiously,
macOS Mojave introduced a
[`clearAdvertisingIdentifier()` method](https://developer.apple.com/documentation/adsupport/asidentifiermanager/2998811-clearadvertisingidentifier),
which appears to create a _"tragedy of the commons"_ situation,
where a single app could spoil things for everyone else
_(not that this is a bad thing from the user's perspective!)_

{% endinfo %}

{% warning %}

There's also the curious case of the
`isAdvertisingTrackingEnabled` property.
According to
[the documentation](https://developer.apple.com/documentation/adsupport/asidentifiermanager/1614148-isadvertisingtrackingenabled):

> Check the value of this property
> before performing any advertising tracking.
> If the value is false,
> use the advertising identifier only for the following purposes:
> frequency capping,
> attribution,
> conversion events,
> estimating the number of unique users,
> advertising fraud detection,
> and debugging.

This kind of _"honor system"_ approach compliance is confusing.
And it makes you wonder what kind of usage
_wouldn't_ fall within these broad allowances.

If you have any insight into how this is policed,
[drop us a line](https://twitter.com/nshipster) ---
we'd love to hear more.

{% endwarning %}

### DeviceCheck

`identifierForVendor` and `advertisingIdentifier`
provide all the same functionality as the `uniqueIdentifier` property
they replaced in iOS 6,
save for one:
the ability to persist across device resets and app uninstalls.

In iOS 11,
Apple quietly introduced the
[DeviceCheck framework](https://developer.apple.com/documentation/devicecheck),
which allows developers to assign two bits of information
that are persisted by Apple
**until the developer manually removes them**.

Interacting with the DeviceCheck framework should be familiar to
anyone familiar with [APNS](/apns-device-tokens):
after setting things up on App Store Connect and your servers,
the client generates tokens on the device,
which are sent to your servers to set or query two bits of information:

```swift
import DeviceCheck

let device = DCDevice.current
if device.isSupported {
    device.generateToken { data, error in
        if let token = data?.base64EncodedString() {
            <#send token to your server#>
        }
    }
}
```

Based on the device token and other information sent by the client,
the server tells Apple to set each bit value
by sending a JSON payload like this:

```json
{
  "device_token": "QTk4QkFDNEItNTBDMy00Qjc5LThBRUEtMDQ5RTQzRjNGQzU0Cg==",
  "transaction_id": "D98BA630-E225-4A2F-AFEC-BE3A3D591708",
  "timestamp": 1572531720,
  "bit0": true,
  "bit1": false
}
```

To retrieve those two bits at a later point in time,
the server sends a payload without `bit0` and `bit1` fields:

```json
{
  "device_token": "QTk4QkFDNEItNTBDMy00Qjc5LThBRUEtMDQ5RTQzRjNGQzU0Cg==",
  "transaction_id": "D98BA630-E225-4A2F-AFEC-BE3A3D591708",
  "timestamp": 1572532500
}
```

If everything worked,
Apple's servers would respond with a `200` status code
and the following JSON payload:

```json
{
   "bit0" : true
   "bit1" : false,
   "last_update_time" : "2019-10"
}
```

{% error %}

Apple allegedly created the DeviceCheck framework
to meet the needs of Uber
in limiting the abuse of promotional codes.
Although DeviceCheck proports to store _only_ two bits of information
(just enough to, for example,
determine whether a device has ever been used to create an account
and whether the device was ever associated with fraudulent activity),
we have (admittedly vague) concerns that the timestamp, even with truncation,
could be exploited to store more than two bits of information.

{% enderror %}

## Fingerprinting in Today's iOS

Despite these affordances by Apple,
advertisers have continued to work to circumvent user privacy protections
and use any and all information at their disposal
to identify users by other means.

Over the years,
Apple's restricted access to information about
device hardware,
[installed apps](https://developer.apple.com/documentation/uikit/uiapplication/1622952-canopenurl),
[nearby WiFi networks](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_networking_wifi-info).
They've required apps to request permission to
get your current location,
access your camera and microphone,
flip through your contacts, and
find and connect to Bluetooth accessories.
They've taken bold steps to [prevent user tracking in Safari](https://webkit.org/blog/8828/intelligent-tracking-prevention-2-2/).

For lack of this information,
companies have had to get creative,
looking to forge unique identities from the scraps of what's still available.
This process of identification by a combination of external factors
is known as <dfn>[fingerprinting](https://en.wikipedia.org/wiki/Fingerprint_%28computing%29)</dfn>.

The unfortunate reality is that we can be uniquely identified
by vanishingly small amounts of information.
For example,
individuals within a population can be singled out by as few as
four timestamped coordinates
{% cite de_montjoye_2013 %}
or little more than a birthday and a ZIP code
{% cite sweeney_2000 %}.

Every WWDC since 2012 has featured a session about Privacy,
but the only mention of fingerprinting specifically was
[a brief discussion in 2014](https://asciiwwdc.com/2014/sessions/715?q=fingerprinting)
about how to avoid doing it.

By our count,
a determined party could use conventional, unrestricted APIs
to generate a few dozen bits of randomness:

### Locale Information (~36 bits)

Locale information is the greatest source of identifying information
on Apple platforms.
The combination of your
preferred languages, region, calendar, time zone,
and which keyboards you have installed
say a lot about who you are ---
especially if you have less conventional preferences.

```swift
import Foundation

Locale.current.languageCode
log2(Double(Locale.isoLanguageCodes.count)) // 9.217 bits

Locale.current.regionCode
log2(Double(Locale.isoRegionCodes.count)) // 8 bits

Locale.current.calendar.identifier
// ~2^4 (16) Calendars

TimeZone.current.identifier
log2(Double(TimeZone.knownTimeZoneIdentifiers.count)) // 8.775 bits

UserDefaults.standard.object(forKey: "AppleKeyboards")
// ~2^6 (64) iOS keyboards
```

{% info %}

We recently [Tweeted](https://twitter.com/mattt/status/1175817188646612992)
about apps having unrestricted access to emoji keyboard information.
We've since been informed that Apple is investigating the issue.

{% endinfo %}

### Accessibility (~10 bits)

Accessibility preferences also provide a great deal of information,
with each individual setting contributing a single potential bit:

```swift
UIAccessibility.isBoldTextEnabled
UIAccessibility.isShakeToUndoEnabled
UIAccessibility.isReduceMotionEnabled
UIAccessibility.isDarkerSystemColorsEnabled
UIAccessibility.isReduceTransparencyEnabled
UIAccessibility.isAssistiveTouchRunning
```

Of the approximately ~25% of users who take advantage of
[Dynamic Type](https://developer.apple.com/documentation/uikit/uifont/scaling_fonts_automatically)
by configuring a preferred font size,
that selection may also be used to fingerprint you:

```swift
let application = UIApplication.shared
application.preferredContentSizeCategory
```

### Hardware Information (~5 or ~6 bits)

Although most of the juiciest bits have been locked down
in OS updates over the years,
there's just enough to contribute a few more bits for purposes of identification.

On iOS,
you can get the current model and amount of storage of a user's device:

```swift
import UIKit

let device = UIDevice.current
device.name // "iPhone 11 Pro"

let fileManager = FileManager.default
if let path = fileManager.urls(for: .libraryDirectory, in: .systemDomainMask).last?.path,
    let systemSize = try? fileManager.attributesOfFileSystem(forPath: path)[.systemSize] as? Int
{
    Measurement<UnitInformationStorage>(value: Double(systemSize), unit: .bytes)
        .converted(to: .gigabytes)  // ~256GB
}
```

With [14 supported iOS devices](https://support.apple.com/guide/iphone/supported-models-iphe3fa5df43/ios),
most having 3 configurations each,
let's say that this contributes about 32 possibilities, or 5 bits.

You can go a few steps further on macOS,
to further differentiate hardware by its processor count and amount of RAM:

```swift
processInfo.processorCount // 8

Measurement<UnitInformationStorage>(value: Double(processInfo.physicalMemory),
                                    unit: .bytes)
    .converted(to: .gigabytes) // 16GB
```

It's hard to get a sense of
[how many different Mac models are in use](https://everymac.com/systems/by_capability/minimum-macos-supported.html),
but a reasonable estimate would be on the order of 2<sup>6</sup> or 2<sup>7</sup>.

### Cellular Network (~2 bits)

Knowing whether someone's phone is on Verizon or Vodafone
can also be factored into a fingerprint.
You can use the `CTTelephonyNetworkInfo` class from the
[CoreTelephony framework](https://developer.apple.com/documentation/coretelephony)
to lookup the providers for devices with cellular service:

```swift
import CoreTelephony

let networkInfo = CTTelephonyNetworkInfo()
let carriers = networkInfo.serviceSubscriberCellularProviders?.values
carriers?.map { ($0.mobileNetworkCode, $0.mobileCountryCode) }
```

The number of providers varies per country,
but using the 4 major carriers in United States
as a guideline,
we can say carrier information would contribute about 2 bits
(or more if you have multiple SIM cards installed).

## Communication Preferences (2 bits)

More generally,
even knowing whether someone can send texts or email at all
can be factored into a fingerprint.
This information can be gathered without permissions via
the [MessageUI framework](https://developer.apple.com/documentation/messageui).

```swift
import MessageUI

MFMailComposeViewController.canSendMail()
MFMessageComposeViewController.canSendText()
```

## Additional Sources of Identifying Information

If the use of digital fingerprinting seems outlandish,
that's just scratching the surface of how companies and researchers
have figured out how to circumvent your privacy.

### GeoIP and Relative Network Speeds

Although access to geolocation through conventional APIs
requires explicit authorization,
third parties may be able to get a general sense of where you are in the world
based on how you access the Internet.

[Geolocation by source IP address](https://ipinfo.io)
is used extensively for things like region locking and localization.
You could also combine this information with
[ping-time measurements](https://developer.apple.com/library/archive/samplecode/SimplePing/Introduction/Intro.html#//apple_ref/doc/uid/DTS10000716)
to hosts in known locations
to get a more accurate pinpoint on location {% cite weinberg_2018 %}:

```terminal
ping -c 5 99.24.18.13 # San Francisco, USA

--- 99.24.18.13 ping statistics ---
5 packets transmitted, 5 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 11.900/12.184/12.895/0.380 ms

ping -c 5 203.47.10.37 # Adelaide, Australia

--- 203.47.10.37 ping statistics ---
5 packets transmitted, 5 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 202.122/202.433/203.436/0.504 ms
```

### Battery Health

It's unclear whether this is a concern in iOS,
but depending on how precise the results of `UIDevice` battery APIs are,
you may be able to use them to identify a device by its battery health.
{% cite olejnik_2015 %}

```swift
var timestampedBatteryLevels: [(Date, Float)] = []

if UIDevice.current.isBatteryMonitoringEnabled {
    timestampedBatteryLevels.append((Date(), UIDevice.current.batteryLevel))
}
```

{% info %}

For this reason,
battery level APIs were
[removed in Firefox 55](https://developer.mozilla.org/en-US/docs/Web/API/Battery_Status_API).

If this seems outlandish,
consider that Apple recently released a security update for iOS after researchers
demonstrated that small discrepancies in gyroscope calibration settings
could be used to uniquely identify devices.
{% cite zhang_2019 %}

{% endinfo %}

### And so on...

Everything from your heartbeat, to your gait, to your
[butt shape](https://www.wired.co.uk/article/surveillance-technology-biometrics)
seem capable of leaking your identity.
It can all be quite overwhelming.

I mean,
if a motivated individual can find your home address by
[cross-referencing the reflection in your eyes against Google Street view](https://www.theverge.com/2019/10/11/20910551/stalker-attacked-pop-idol-reflection-pupils-selfies-videos-photos-google-street-view-japan),
how can we even stand a chance out there?

<hr/>

Much as we may bemoan the current duopoly of mobile operating systems,
we might take some solace in the fact that
at least one of the players actually cares about user privacy.
Though it's unclear whether that's a fight that can ever be won.

At times,
our fate of being tracked and advertised to
may seem as inevitable as the victims in _It Follows_.

But let's not forget that,
as technologists, as people with a voice,
we're in a position to fight back.

<footer id="bibliography">

<h5>References</h5>

{% bibliography --cited %}

</footer>
