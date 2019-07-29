---
title: Network Link Conditioner
author: Mattt
category: Xcode
tag: popular
excerpt: >-
  App developers often forget to test how their apps perform
  under less-than-ideal networking environments.
  Learn how you can use the Network Link conditioner 
  to simulate a spotty Internet connection on your device.
revisions:
  "2018-07-18": Updated for Xcode 10
  "2019-07-29": Added note about installation problems in macOS 10.14
status:
  swift: n/a
---

Product design is about empathy.
Knowing what a user wants,
what they like,
what they dislike,
what causes them frustration,
and learning to understand and embody those motivations ---
this is what it takes to make something insanely great.

And so we invest in reaching beyond our own operational model of the world.
We tailor our experience to
[different locales](/nslocalizedstring/).
We consider the usability implications of
[screen readers or other assistive technologies](/uiaccessibility/).
We [continuously evaluate](/unit-testing/)
our implementation against these expectations.

There is, however,
one critical factor that app developers often miss:
**network condition**,
or more specifically,
the latency and bandwidth of an Internet connection.

For something so essential to user experience,
it's unfortunate that most developers take an ad-hoc approach
to field-testing their apps under different conditions
(if at all).

This week on NSHipster,
we'll be talking about the
[Network Link Conditioner](https://developer.apple.com/download/more/?q=Additional%20Tools),
a utility that allows macOS and iOS devices
to accurately and consistently simulate adverse networking environments.

## Installation

Network Link Conditioner can be found
in the "Additional Tools for Xcode" package.
You can download this from the
[Downloads for Apple Developers](https://developer.apple.com/download/more/?q=Additional%20Tools)
page.

Search for "Additional Tools"
and select the appropriate release of the package.

<picture>
    <source srcset="{% asset network-link-conditioner-dmg--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset network-link-conditioner-dmg--light.png @path %}" alt="Additional Tools - Hardware" loading=lazy>
</picture>

Once the download has finished,
open the DMG,
navigate to the "Hardware" directory,
and double-click "Network Link Condition.prefPane".

<picture>
    <source srcset="{% asset network-link-conditioner-install--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset network-link-conditioner-install--light.png @path %}" alt="Install Network Link Conditioner" loading=lazy>
</picture>

Click on the Network Link Conditioner preference pane
at the bottom of System Preferences.

<picture>
    {% comment %}<source srcset="{% network-link-conditioner-preference-pane--dark.png @path %}" media="(prefers-color-scheme: dark)">{% endcomment %}
    <img src="{% asset network-link-conditioner-preference-pane--light.png @path %}" alt="Network Link Conditioner" loading=lazy>
</picture>

{% error %}

When you first install Network Link Conditioner on macOS 10.14,
everything works as expected.
But if you close and reopen System Preferences,
the preference pane no longer appears,
and attempting to reinstall results in the following error message:

<figure>

<picture>
    <source srcset="{% asset network-link-conditioner-installation-error--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset network-link-conditioner-installation-error--light.png @path %}" alt="Network Link Conditioner installation error message" loading=lazy>
</picture>

<figcaption hidden>

> **You can’t install the “Network Link Conditioner” preferences.**<br/>
> “Network Link Conditioner” preferences is installed with macOS and can’t be replaced.

</figcaption>
</figure>

As a workaround,
you can move the preference pane
from your user `PreferencePanes` directory to the system-level directory
by entering the following command in `Terminal.app`
(you'll be prompted for your password):

```terminal
$ sudo mv ~/Library/PreferencePanes/Network\ Link\ Conditioner.prefPane /Library/PreferencePanes/
```

Once you've done this,
Network Link Conditioner will appear
the next time you open System Preferences.

{% enderror %}

## Controlling Bandwidth, Latency, and Packet Loss

Enabling the Network Link Conditioner
changes the network environment system-wide
according to the selected configuration,
limiting uplink or download
[bandwidth](https://en.wikipedia.org/wiki/Bandwidth_%28computing%29),
[latency](https://en.wikipedia.org/wiki/Latency_%28engineering%29%23Communication_latency), and rate of
[packet loss](https://en.wikipedia.org/wiki/Packet_loss).

You can choose from one of the following presets:

- 100% Loss
- 3G
- DSL
- EDGE
- High Latency DNS
- LTE
- Very Bad Network
- WiFi
- WiFi 802.11ac

...or create your own according to your particular requirements.

![Preset]({% asset network-link-conditioner-preset.png @path %})

---

Now try running your app with the Network Link Conditioner enabled:

How does network latency affect your app startup? <br/>
What effect does bandwidth have on table view scroll performance? <br/>
Does your app work at all with 100% packet loss?

## Enabling Network Link Conditioner on iOS Devices

Although the preference pane works well for developing on the simulator,
it's also important to test on a real device.
Fortunately,
the Network Link Conditioner is available for iOS as well.

To use the Network Link Conditioner on iOS,
set up your device for development:

1.  Connect your iOS device to your Mac
2.  In Xcode, navigate to Window > Organizer
3.  Select your device in the sidebar
4.  Click "Use for Development"

![iOS Devices]({% asset network-link-conditioner-ios.png @path %})

Now you'll have access to the Developer section of the Settings app.
You can enable and configure the Network Link Conditioner
on your iOS device under Settings > Developer > Networking.
(Just remember to turn it off after you're done testing!).
