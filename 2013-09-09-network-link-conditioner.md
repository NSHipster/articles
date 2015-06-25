---
title: Network Link Conditioner
author: Mattt Thompson
category: Xcode
tag: popular
excerpt: "Product design is about empathy. Knowing what a user wants, what they like, what they dislike, what causes them frustration, and learning to understand and embody those motivations in design decisions—this is what it takes to make something insanely great."
---

Product design is about empathy. Knowing what a user wants, what they like, what they dislike, what causes them frustration, and learning to understand and embody those motivations in design decisions—this is what it takes to make something insanely great.

And so we invest in reaching beyond our own operational model of the world. We tailor our experience for [different locales](http://nshipster.com/nslocalizedstring/). We consider the usability implications of [screen readers or other assistive technologiess](http://nshipster.com/uiaccessibility/). We [continuously evaluate](http://nshipster.com/unit-testing/) our implementation against these expectations.

There is, though, one critical factor that app developers often miss the first time around, and that is **network condition**, or more specifically the latency and bandwidth of an Internet connection. For something so essential to a user's experience with a product, it's unfortunate that most developers take an ad-hoc approach to field testing different kinds of environments, if at all.

This week on NSHipster, we'll be talking about the [Network Link Conditioner](https://developer.apple.com/downloads/index.action?q=Hardware%20IO%20Tools), a utility that allows Mac and iOS devices to accurately and consistently simulate adverse networking environments.

## Installation

Network Link Conditioner can be found in the "Hardware IO Tools for Xcode" package. This can be downloaded from the [Apple Developer Downloads](https://developer.apple.com/downloads/index.action?q=Hardware%20IO%20Tools) page.

![Download](http://nshipster.s3.amazonaws.com/network-link-conditioner-download.png)

Search for "Network Link Conditioner", and select the appropriate release of the "Hardware IO Tools for Xcode" package.

![Package](http://nshipster.s3.amazonaws.com/network-link-conditioner-dmg.png)

Once the download has finished, open the DMG and double-click "Network Link Condition.prefPane" to install.

![System Preferences](http://nshipster.s3.amazonaws.com/network-link-conditioner-install.png)

From now on, you can enable the Network Link Conditioner from its preference pane at the bottom of System Preferences.

![Network Link Conditioner](http://nshipster.s3.amazonaws.com/network-link-conditioner-system-preference.png)

When enabled, the Network Link Conditioner can change the network environment of the iPhone Simulator according to one of the built-in presets:

- EDGE
- 3G
- DSL
- WiFi
- High Latency DNS
- Very Bad Network
- 100% Loss

Each preset can set a limit for uplink or downlink [bandwidth](http://en.wikipedia.org/wiki/Bandwidth_%28computing%29), [latency](http://en.wikipedia.org/wiki/Latency_%28engineering%29%23Communication_latency), and rate of [packet loss](http://en.wikipedia.org/wiki/Packet_loss) (when any value is set to 0, that value is unchanged from your computer's network environment).

![Preset](http://nshipster.s3.amazonaws.com/network-link-conditioner-preset.png)

You can also create your own preset, if you wish to simulate a particular combination of factors simultaneously.

Try running your app in the simulator with the Network Link Conditioner enabled under various presets and see what happens. How does network latency affect your app startup? What effect does bandwidth have on table view scroll performance? Does your app work at all with 100% packet loss?

> If your app uses [Reachability](https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html) to detect network availability, you may experience some unexpected results while using the Network Link Conditioner. As such, any reachability behavior under Airplane mode or WWan / WiFi distinctions is something that should be tested separately from network conditioning.

## Enabling Network Link Conditioner on iOS Devices

While the preference pane works well for developing on the simulator, it's also important to test on actual devices. Fortunately, as of iOS 6, the Network Link Conditioner is available on the devices themselves.

To enable it, you need to set up your device for development:

1. Connect your iPhone or iPad to your Mac
2. In Xcode, go to Window > Organizer (⇧⌘2)
3. Select your device in the sidebar
4. Click "Use for Development"

![iOS Devices](http://nshipster.s3.amazonaws.com/network-link-conditioner-ios.png)

Now you'll have access to the Developer section of the Settings app, where you'll find the Network Link Conditioner (just don't forget to turn it off after you're done testing!).
