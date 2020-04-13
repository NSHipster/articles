---
title: Contact Tracing
author: Mattt
category: Miscellaneous
excerpt: >-
  On Friday, 
  Apple and Google announced a joint initiative 
  to deploy contact tracing functionality 
  to the billions of devices running iOS or Android in the coming months.
  In this article, 
  we’ll take a first look at these specifications — 
  particularly, Apple’s proposed ContactTracing framework — 
  in an effort to anticipate what this will all look like in practice.
status:
  swift: 5.2
---

> An ounce of prevention is worth a pound of cure.

Early intervention is among the most effective strategies for treating illness.
This is true not only for the human body, for society as a whole.
That's why public health officials use contact tracing
as their first line of defense against
the spread of infectious disease in a population.

We're hearing a lot about contact tracing these days,
but the technique has been used for decades.
What's changed is that
thanks to the ubiquity of personal electronic devices,
we can automate what was — up until now — a labor-intensive, manual process.
Much like how "computer" used to be a job title held by humans,
the role of "contact tracer" may soon be filled primarily by apps.

On Friday,
Apple and Google [announced][apple press release] a joint initiative
to deploy contact tracing functionality
to the billions of devices running iOS or Android
in the coming months.
As part of this announcement,
the companies shared draft specifications for the
[cryptography][cryptography specification],
[hardware][hardware specification],
and
[software][software specification]
involved in their proposed solution.

In this article,
we'll take a first look at these specifications —
particularly Apple's proposed `ContactTracing` framework —
and use what we've learned to anticipate what
this will all look like in practice.

---

## What is contact tracing?

<dfn>Contact tracing</dfn> is a technique used by public health officials
to identify people who are exposed to an infectious disease
in order to slow the spread of that illness within a population.

When a patient is admitted to a hospital
and diagnosed with a new, communicable disease,
they're interviewed by health workers
to learn who they've interacted recently.
Any contacts whose interactions with the patient are then evaluated,
and if they're diagnosed with the disease,
the process repeats with their known, recent contacts.

Contact tracing disrupts the chain of transmission.
It gives people the opportunity to isolate themselves before infecting others
and to seek treatment before they present symptoms.
It also allows decision-makers to make more informed
recommendations and policy decisions about additional measures to take.

If you start early and act quickly,
contact tracing gives you a fighting chance of containing an outbreak
before it gets out of hand.

Unfortunately, we weren't so lucky this time around.

With over a million confirmed cases of <abbr>COVID-19</abbr> worldwide,
many regions are well past the point where contact tracing is practical.
But that's not to say that it can't play an essential role
in the coming weeks and months.

## "Only Apple <ins>(and Google)</ins> can do this."

Since the outbreak,
various [governments](https://www.pepp-pt.org)
and [academics](https://github.com/DP-3T/documents)
have proposed standards for contact tracing.
But the most significant development so far came yesterday
with Apple and Google's announcement of a joint initiative.

According to the
<abbr title="United Kingdom National Health Service">NHS</abbr>,
around 60% of adults in a population
would need to participate in order for digital contact tracing to be effective.
Researchers from the aforementioned institutions have noted
that the limits imposed by iOS on 3rd-party apps
make this level of participation unlikely.

{% info %}

As of iOS 13.4,
3rd-party apps lack the ability to
advertise Bluetooth services in the background.

{% endinfo %}

On the one hand,
it feels weird to congratulate Apple for stepping in
to solve a problem it created in the first place.
But we can all agree that Friday's announcement
is something to celebrate.
It's no exaggeration to say that
this wouldn't be possible without their help.

## What are Apple and Google proposing as a solution?

At a high level,
Apple and Google are proposing a common standard
for how personal electronic devices (phones, tablets, watches)
can automate the process of contact tracing.

Instead of health workers chasing down contacts on the phone —
a process that can take hours, or even days —
the proposed system could identify every recent contact
and notify all of them within moments of a confirmed, positive diagnosis.

{% info %}

[This infographic][google presentation]
from Google's blog post announcing the partnership
provides a nice explanation of the technologies involved.

{% endinfo %}

Apple's CEO, Tim Cook, promises that
["Contact tracing can help slow the spread of COVID-19 and can be done without compromising user privacy."](https://twitter.com/tim_cook/status/1248657931433693184).
The specifications accompanying Friday's announcement
show how that's possible

Let's take them in turn,
starting with
[cryptography][cryptography specification] (key derivation & rotation),
followed by
[hardware][hardware specification] (Bluetooth),
and
[software][software specification] (app)
components.

### Cryptography

When you install an app and open it for the first time,
the ContactTracing framework displays
a dialog requesting permission
to enable contact tracing on their device.

If the user accepts,
the framework generates a 32-byte cryptographic random number
to serve as the device's <dfn>Tracing Key</dfn>.
The Tracing Key is kept secret, never leaving the device.

{% info %}

If the concept of "binary data" seems daunting or meaningless to you,
it can help to see a few examples of how that information
can be encoded into a human-readable form.

32 bytes of binary data can be represented by
44-character-long [Base64-encoded][base64] string
or a string of 64 [hexadecimal][hexadecimal] digits.
You can generate these for yourself from the command line
with the following commands:

```terminal
$ head -c32 < /dev/urandom | xxd -p -c 64
211ad682549d92fbb6cd5dc42be5121b22f8864b3a7e93cedb9c43c83332440d

$ head -c32 < /dev/urandom | base64
2pNDyj5LSr0GGi1IL2VOvsovBwmG4Yp5YYP7leg928Y=
```

16 bytes of binary data can also be represented in Base64 or hexadecimal,
but it's more common and convenient to use a
[<abbr title="Universally Unique Identifier">UUID</abbr>][rfc4122].

```terminal
$ uuidgen
33F1C4D5-3F1C-4FF0-A05E-A267FAB237CB
```

{% endinfo %}

Every 24 hours,
the device takes the Tracing Key and the day number (0, 1, 2, ...)
and uses
[<abbr title="HMAC-based Extract-and-Expand Key Derivation Function (HKDF)">HKDF</abbr>][rfc5869]
to derive a 16-byte <dfn>Daily Tracing Key</dfn>.
These keys are uploaded to a central health authority
for future reference
(more on that in a moment).

Every 15 minutes,
the device takes the Daily Tracing Key and
the number of 10-minute intervals since the beginning of the day (0 – 143),
and uses
[<abbr title="Keyed-Hashing for Message Authentication">HMAC</abbr>][rfc2104]
to generate a new 16-byte <dfn>Rolling Proximity Identifier</dfn>.
This identifier is broadcast from the device using
[Bluetooth <abbr title="Low Energy">LE</abbr>][ble].

If someone were to get a positive diagnosis,
the central health authority could derive the Daily Tracing Keys
for all of the days that they were contagious,
and record those as <dfn>Positive Diagnosis Keys</dfn>.

{% info %}

The [Contact Tracing Cryptography Specification][cryptography specification]
is concise, clearly written, and remarkably accessible.
Anyone for whom the name _[Diffie–Hellman][diffie–hellman]_ even rings a bell
are encouraged to give it a quick read.

{% endinfo %}

### Hardware

Bluetooth organizes communications between devices
around the concept of <dfn>services</dfn>.

A service describes a set of characteristics for accomplishing a particular task.
A device may communicate with multiple services
in the course of its operation.
Many service definitions are [standardized](https://www.bluetooth.com/specifications/gatt/)
so that devices that do the same kinds of things communicate in the same way.

For example,
a wireless heart rate monitor
that uses Bluetooth to communicate to your phone
would have a profile containing two services:
a primary Heart Rate service and
a secondary Battery service.

Apple and Google's Contact Tracing standard
defines a new Contact Detection service.

When a contract tracing app is running (either in the foreground or background),
it acts as a <dfn>peripheral</dfn>,
advertising its support for the Contact Detection service
to any other device within range.
The Rolling Proximity Identifier generated every 15 minutes
is sent in the advertising packet along with the 16-bit service UUID.

Here's some code for doing this from an iOS device using
the [Core Bluetooth framework][core bluetooth]:

```swift
import CoreBluetooth

// Contact Detection service UUID
let serviceUUID = CBUUID(string: "FD6F")

// Rolling Proximity Identifier
let identifier: Data = <#...#> // 16 bytes

let peripheralManager = CBPeripheralManager()

let advertisementData: [String: Any] = [
    CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
    CBAdvertisementDataServiceDataKey: identifier
]

peripheralManager.startAdvertising(advertisementData)
```

At the same time that the device broadcasts as a peripheral,
it's also scanning for other devices' Rolling Proximity Identifiers.
Again, here's how you might do that on iOS using Core Bluetooth:

```swift
let delegate: CBCentralManagerDelegate = <#...#>
let centralManager = CBCentralManager(delegate: delegate, queue: .main)
centralManager.scanForPeripherals(withServices: [serviceUUID], options: [:])

extension <#DelegateClass#>: CBCentralManagerDelegate {
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String : Any],
                      rssi RSSI: NSNumber)
  {
      let identifier = advertisementData[CBAdvertisementDataServiceDataKey] as! Data
      <#...#>
  }
}
```

Bluetooth is an almost ideal technology for contact tracing.
It's on every consumer smart phone.
It operates with low power requirement,
which lets it run continuously without draining your battery.
And it _just_ so happens to have a transmission range
that approximates the physical proximity required
for the airborne transmission of infectious disease.
This last quality is what allows contact tracing to be done
without resorting to location data.

<aside class="parenthetical">

As we noted in [a previous article](/device-identifiers/#fingerprinting-in-todays-ios),
individuals within a population
can be singled out by as few as four timestamped coordinates.

</aside>

### Software

Your device stores any Rolling Proximity Identifiers it discovers,
and periodically checks them against
a list of Positive Diagnosis Keys sent from the central health authority.

Each Positive Diagnosis Key corresponds to someone else's Daily Tracing Key,
and we can derive all of the possible Rolling Proximity Identifiers
that it could advertise over the course of that day.
If any matches were found among
the local list of Rolling Proximity Identifiers
discovered during that time period,
then the device may have been in contact with an infected individual.

Suffice to say that digital contact tracing is really hard to get right.
Given the importance of getting it right,
both in terms of yielding accurate results and preserving privacy,
Apple and Google are providing SDKs for app developers to use
for iOS and Android, respectively.

All of the details we discussed about cryptography and Bluetooth
are managed by the framework.
The only thing we need to do as developers
is communicate with the user —
specifically, requesting their permission to start contact tracing
and notifying them about a positive diagnosis.

## "Nobody ever got fired for <del>buying IBM</del> <ins>using Objective-C</ins>."

In our time of crisis,
what technology did Apple entrust with the fate of humanity?
_None other than Objective-C._

```obj-c
typedef void (^CTExposureDetectionFinishHandler) (CTExposureDetectionSummary * _Nullable inSummary, NSError * _Nullable inError);
typedef void ( ^CTExposureDetectionContactHandler )( NSArray <CTContactInfo *> * _Nullable inContacts, NSError * _Nullable inError );

@interface CTExposureDetectionSession : NSObject
@property dispatch_queue_t dispatchQueue;
@property (readonly, nonatomic) NSInteger maxKeyCount;
- (void) activateWithCompletion:(nullable CTErrorHandler) inCompletion;
- (void) invalidate;
- (void) addPositiveDiagnosisKeys:(NSArray <CTDailyTracingKey *> *) inKeys completion:(nullable CTErrorHandler) inCompletion;
- (void) finishedPositiveDiagnosisKeysWithCompletion:(nullable CTExposureDetectionFinishHandler) inFinishHandler;
- (void) getContactInfoWithHandler:(nullable CTExposureDetectionContactHandler) inHandler;
@end
```

{% info %}

If you're not as well-versed in Objective-C,
here's the [generated Swift interface][swift interface]
and some [nicer looking docs][swift docs].

{% endinfo %}

Although we only have the interface right now,
you can get a reasonable understanding of how everything works
from the APIs and documentation.

The biggest challenge you'll face using the ContactTracing framework API
is dealing with all of its completion handlers.
Most of the functionality is provided through asynchronous APIs;
without a way to [compose](/optional-throws-result-async-await/) these operations,
you can easily find yourself nested 4 or 5 closures deep,
indented to the far side of your editor.

<aside class="parenthetical">

If ever there was a need for
[async/await](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619)
in Swift,
this is it.

</aside>

After some trial and error,
I managed to come up with a reasonable solution
following the [delegate pattern][delegate pattern].
The [end result](https://gist.github.com/mattt/17c880d64c362b923e13c765f5b1c75a)
should be familiar to anyone who's ever used
[`CLLocationManager`][cllocationmanager]:

```swift
let manager = ContactTracingManager.shared
manager.delegate = <#DelegateClass#>()
manager.startContactTracing()

class <#DelegateClass#>: NSObject, ContactTracingManagerDelegate {
  func contactTacingManager(_ manager: ContactTracingManager,
                              didReceiveExposureDetectionSummary summary: CTExposureDetectionSummary) {
      if summary.matchedKeyCount > 1 {
        // ⚠️ Possible exposure!
      }
  }
}
```

{% warning %}

To be clear,
I have no idea if this code actually works.
Without the actual framework to test against,
this is all just my best guess.

{% endwarning %}

For something that released under such an unyielding deadline,
mistakes are inevitable.
All in all,
I think the teams responsible for the ContactTracing framework
did an admirable job, and I extend my most sincere respect and gratitude
for their work.

<aside class="parenthetical">

For the record,
the [Android version][android contact tracing] of this functionality
seems to be _quite_ well-designed
(to my untrained eye, at least).

</aside>

{% error %}

Here are some problems I encountered during my investigation,
which I hope will be addressed in the next update:

- A few APIs refer to a `CTManagerState` enumeration
  that isn't defined in the documentation.
- The documentation for `CTExposureDetectionSession`'s
  `addPositiveDiagnosisKeys` method is missing a word
  that flips what I believe to be the intended meaning:

  > Each call to this method must <ins>NOT</ins>
  > include more keys than specified by the current value of `<maxKeyCount>`.

{% enderror %}

## Tracing a path back to normal life

Many of us have been sheltering in place for weeks, if not months.
Until a vaccine is developed and made widely available,
this is the most effective strategy we have for stopping the spread of disease.

But experts are saying that a vaccine
could be anywhere from 9 to 18 months away.
_"What will we do until then?_

At least here in the United States,
we don't yet have a national plan for getting back to normal,
so it's hard to say.
What we do know is that
it's not going to be easy,
and it's not going to come all at once.

Once the rate of new infections stabilizes,
our focus will become containing new outbreaks in communities.
And to that end,
technology-backed contact tracing can play a crucial role.

From a technical perspective,
Apple and Google's proposal gives us every reason to believe that
we _can_ do contact tracing without compromising privacy.
However,
the amount of faith you put into this solution
depends on how much you trust
these companies and our governments in the first place.

Personally,
I remain cautiously optimistic.
Apple's commitment to privacy has long been one of its greatest assets,
and it's now more important than ever.

[skip]: #tech-talk "Jump to code discussion"
[apple press release]: https://www.apple.com/newsroom/2020/04/apple-and-google-partner-on-covid-19-contact-tracing-technology/
[cryptography specification]: https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ContactTracing-CryptographySpecification.pdf
[hardware specification]: https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ContactTracing-BluetoothSpecificationv1.1.pdf
[software specification]: https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ContactTracing-FrameworkDocumentation.pdf
[diffie–hellman]: https://en.wikipedia.org/wiki/Diffie–Hellman_key_exchange
[rfc2104]: https://tools.ietf.org/html/rfc2104 "HMAC: Keyed-Hashing for Message Authentication"
[rfc5869]: https://tools.ietf.org/html/rfc5869 "HMAC-based Extract-and-Expand Key Derivation Function (HKDF)"
[rfc4122]: https://tools.ietf.org/html/rfc4122 "A Universally Unique IDentifier (UUID) URN Namespace"
[hexadecimal]: https://en.wikipedia.org/wiki/Hexadecimal#Binary_conversion
[base64]: https://en.wikipedia.org/wiki/Base64
[ble]: https://en.wikipedia.org/wiki/Bluetooth_Low_Energy
[google presentation]: https://blog.google/documents/57/Overview_of_COVID-19_Contact_Tracing_Using_BLE.pdf
[core bluetooth]: https://developer.apple.com/documentation/corebluetooth
[android contact tracing]: https://blog.google/documents/55/Android_Contact_Tracing_API.pdf
[swift interface]: https://github.com/NSHipster/ContactTracing-Framework-Interface/blob/master/ContactTracing.swift
[swift docs]: https://contact-tracing-documentation.nshipster.com
[delegate pattern]: https://developer.apple.com/library/archive/documentation/General/Conceptual/CocoaEncyclopedia/DelegatesandDataSources/DelegatesandDataSources.html
[cllocationmanager]: https://developer.apple.com/documentation/corelocation/cllocationmanager
