---
title: Message-ID and Mail.app Deep Linking on iOS and macOS
author: Mattt
category: Miscellaneous
excerpt: >-
  Privacy enhancements to privacy in recent versions of iOS
  have afforded users much greater control of how 
  their information is shared.
  However, these improvements have come at a slight cost
  to certain onboarding flows.
  Rather than attempting to work around Apple's privacy protections
  with techniques like device fingerprinting,
  we can instead rely on a longtime system integration with email.
status:
  swift: 5.1
---

[Last week](/device-identifiers/),
we concluded our discussion of device identifiers
with a brief foray into the ways apps use
[device fingerprinting](/device-identifiers/#fingerprinting-in-todays-ios)
to work around Apple's provided APIs
to track users without their consent or awareness.
In response,
a few readers got in touch to explain why
their use of fingerprinting
to bridge between Safari and their native app was justified.

At WWDC 2018.
Apple [announced](https://developer.apple.com/videos/play/wwdc2017/702/) that
starting in iOS 11 apps would no longer have access to a shared cookie store.
Previously,
if a user was logged into a website in Safari on iOS
and installed the native app,
the app could retrieve the session cookie from an `SFSafariViewController`
to log the user in automatically.
The change was implemented as a countermeasure against
user tracking by advertisers and other third parties,
but came at the expense of certain onboarding flows used at the time.

While
[iCloud Keychain](https://support.apple.com/en-us/HT204085),
[Shared Web Credentials](https://developer.apple.com/documentation/security/shared_web_credentials),
[Password Autofill](https://developer.apple.com/documentation/security/password_autofill),
[Universal Links](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content), and
[Sign in with Apple](https://developer.apple.com/documentation/signinwithapplejs/)
have gone a long way to
minimize friction for account creation and authentication,
there are still a few use cases that aren't entirely covered by these new features.

In this week's article,
we'll endeavor to answer one such use case, specifically:\\
**How to do seamless "passwordless" authentication via email on iOS.**

<hr/>

## Mail and Calendar Integrations on Apple Platforms

When you view an email on macOS and iOS,
Mail underlines
[detected dates and times](/nsdatadetector/).
You can interact with them to create a new calendar event.
If you open such an event in Calendar,
you'll see a "Show in Mail" link in its extended details.
Clicking on this link takes you back to the original email message.

This functionality goes all the way back to the launch of the iPhone;
its inclusion in that year's
[Mac OS X release (Leopard)](https://daringfireball.net/2007/12/message_urls_leopard_mail)
would mark the first of many mobile features
that would make their way to the desktop.

If you were to copy this "magic" URL to the pasteboard
and view in a text editor,
you'd see something like this:

```swift
"message:%3C1572873882024.NSHIPSTER%40mail.example.com%3E"
```

Veteran iOS developers will immediately recognize this to use a
[custom URL scheme](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app).
And the web-savvy among them could percent-decode the host
and recognize it to be something akin to an email address, but not.

_So if not an email address, what are we looking at here?_\\
It's a different email field known as a <dfn>Message-ID</dfn>.

## Message-ID

[RFC 5322 §3.6.4](https://tools.ietf.org/html/rfc5322#section-3.6.4) <!-- (which updates RFC 2392) -->
prescribes that every email message <span class="small-caps">SHOULD</span>
have a "Message-ID:" field
containing a single unique message identifier.
The syntax for this identifier is essentially an email address
with enclosing angle brackets (`<>`).

Although the specification contains no normative guidance
for what makes for a good Message-ID,
there's a
[draft IETF document](https://tools.ietf.org/html/draft-ietf-usefor-message-id-01)
from 1998 that holds up quite well.

Let's take a look at how to do this in Swift:

### Generating a Random Message ID

The first technique described in the aforementioned document
involves generating a random Message ID with a 64-bit nonce,
which is prepended by a timestamp to further reduce the chance of collision.
We can do this rather easily
using the random number generator APIs built-in to Swift 5
and the
[`String(_:radix:uppercase:)` initializer](https://developer.apple.com/documentation/swift/string/2997127-init):

```swift
import Foundation

let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
let nonce = String(UInt64.random(in: 0..<UInt64.max), radix: 36, uppercase: true)
let domain = "mail.example.com"

let MessageID = "<\(timestamp).\(nonce)@\(domain)>"
//"<1572873882024.NSHIPSTER@mail.example.com>"
```

We could then save the generated Message-ID with the associated record
in order to link to it later.
However,
in many cases,
a simpler alternative would be to make the Message ID deterministic,
computable from its existing state.

### Generating a Deterministic Message ID

Consider a record structure that conforms to
[`Identifiable` protocol](/identifiable/)
and whose associated `ID` type is a
[UUID](/uuid-udid-unique-identifier/).
You could generate a Message ID like so:

```swift
import Foundation

func messageID<Value>(for value: Value, domain: String) -> String
    where Value: Identifiable, Value.ID == UUID
{
    return "<\(value.id.uuidString)@\(domain)>"
}
```

{% info %}

For lack of a persistent identifier
(or any other distinguishing features),
you might instead use a digest of the message body itself
to generate a Message ID.
Here's an example implementation that uses the new
[CryptoKit framework](https://developer.apple.com/documentation/cryptokit):

```swift
import Foundation
import CryptoKit

let body = #"""
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
nisi ut aliquip ex ea commodo consequat.
"""#

let digest = Data(SHA256.hash(data: body.data(using: .utf8)!))
                .map { String($0, radix: 16, uppercase: true) }
                .joined()

let domain = "ADF"
"<\(digest)@\(domain)>"
// "<F52380112175FCE8ECF2731C193EB8A7CC8642E53C68D292CD88531D42F145@mail.example.com>"
```

{% endinfo %}

## Mobile Deep Linking

The stock Mail client on both iOS and macOS
will attempt to open URLs with the custom `message:` scheme
by launching to the foreground
and attempting to open the message
with the encoded Message-ID field.

### Generating a Mail Deep Link with Message ID

With a Message-ID in hand,
the final task is to create a deep link that you can use to
open Mail to the associated message.
The only trick here is to
[percent-encode](https://en.wikipedia.org/wiki/Percent-encoding)
the Message ID in the URL.
You could do this with the
[`addingPercentEncoding(withAllowedCharacters:)` method](/character-set/),
but we prefer to delegate this all to [`URLComponents`](/nsurl/) instead ---
which has the further advantage of being able to
construct the URL full without a
[format string](/expressiblebystringinterpolation/).

```swift
import Foundation

var components = URLComponents()
components.scheme = "message"
components.host = MessageID
components.string!
// "message://%3C1572873882024.NSHIPSTER%40mail.example.com%3E"
```

{% info %}

As far as we can tell,
the presence or absence of a double slash after the custom `message:` scheme
doesn't have any impact on Mail deep links resolution.

{% endinfo %}

### Opening a Mail Deep Link

If you open a `message:` URL on iOS
and the linked message is readily accessible from the <span class="small-caps">INBOX</span>
of one of your accounts,
Mail will launch immediately to that message.
If the message isn't found,
the app will launch and asynchronously load the message in the background,
opening it once it's available.

{% error %}

<figure>

<picture>
    <source srcset="{% asset message-id-mcmailerrordomain-error-1030--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset message-id-mcmailerrordomain-error-1030--light.png @path %}" alt="Mail error alert on macOS" loading="lazy" width="355">
</picture>

<figcaption hidden>

> **The operation couldn’t be completed. (<code>MCMailErrorDomain error 1030.</code>)**
> Mail was unable to open the URL “<var>message://%3C1572873882024.NSHIPSTER%40mail.example.com%3E</var>”.

</figcaption>

</figure>

By contrast,
attempting to open a Mail deep link on macOS to a message that isn't yet loaded
causes an alert modal to display.
For this reason,
we recommend using Mail deep links on iOS only.

{% enderror %}

As an example,
[Flight School](https://flight.school/)
does this with passwordless authentication system.
To access electronic copies of your books,
you enter the email address you used to purchase them.
Upon form submission,
users on iOS will see a deep link to open the Mail app
to the email containing the "magic sign-in link" ✨.

Other systems might use Message-ID
to streamline passwordless authentication for their native app or website
by way of
[Universal Links](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content),
or incorporate it as part of a
<abbr title="Two-Factor Authentication">2FA</abbr> strategy
(since [<abbr title="short message service">SMS</abbr> is no longer considered to be secure for this purpose](https://pages.nist.gov/800-63-3/sp800-63b.html#ooba)).

{% info %}

If you're using Rails for your web application,
[ActiveMailer interceptors](https://guides.rubyonrails.org/action_mailer_basics.html#intercepting-and-observing-emails)
provide a convenient way to inject `Message-ID` fields
for passwordless authentication flows.

{% endinfo %}

<hr/>

Unlike so many private integrations on Apple platforms,
which remain the exclusive territory of first-party apps,
the secret sauce of "Show in Mail" is something we can all get in on.
Although undocumented,
the feature is unlikely to be removed anytime soon
due to its deep system integration and roots in fundamental web standards.

At a time when everyone from
[browser vendors](https://amp.dev) and
[social media companies](https://facebook.com) to
[governments](https://en.wikipedia.org/wiki/Internet_censorship) --- and even
Apple itself, at times ---
seek to dismantle the open web and control what we can see and do,
it's comforting to know that email,
[nearly 50 years on](http://openmap.bbn.com/~tomlinso/ray/mistakes.html),
remains resolute in its capacity to keep the Internet free and decentralized.

{% asset "articles/message-id.css" %}
