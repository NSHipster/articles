---
title: Configuration Profiles
author: Mattt Thompson
category: ""
excerpt: "One of the major criticisms of iOS as a platform is how locked down it is. iOS Configuration Profiles offer an interesting mechanism to work around these restrictions."
status:
    swift: n/a
---

One of the major criticisms of iOS as a platform is how locked down it is.

Each app is an island, only able to communicate with other parts of the system under strict terms, and only then with nontrivial effort. There's no way, for example, for an app to open its own settings in Settings.app. There's no way for apps to change their icon at runtime, or to customize the behavior of system-wide functionality, like Notification Center or Siri. Apps can't embed or share views with one another, or communicate locally.

So it may come as a surprise how many of these limitations to iOS can be worked around with a bit of XML.

The feature in question, and topic of this week's article is [iOS Configuration Profiles](https://developer.apple.com/library/ios/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html).

***

Unless you've worked in the enterprise or on wide-scale educational software, there's a good chance that you haven't heard much about configuration profiles.

__Configuration Profiles are not to be confused with Provisioning Profiles.__

A _provisioning profile_ is used to determine that an app is authorized by the developer to run on a particular device. A _configuration profile_ can be used to apply a variety of settings to a device.

Both configuration & provisioning profiles are displayed in similar fashion under `Settings.app > General > Profiles`, which doesn't help with the potential confusion.

Each configuration file includes a number of payloads, each of which can specify configuration, including:

- Whitelisting & Authenticating AirPlay & AirPrint destinations
- Setting up VPN, HTTP Proxies, WiFi & Cellular Network
- Configuring Email (SMTP, Exchange), Calendar (CalDAV), and Contacts (CardDAV, LDAP, AD)
- Restricting access to Apps, Device Features, Web Content, and Media Playback
- Managing Certificates and SSO Credentials
- Installing Web Clips, Apps, and Custom Fonts

There are several ways to deploy configuration profiles:

- Attaching to an email
- Linking to one on a webpage
- Using over-the air configuration
- Using Apple Configurator

> In addition to deploying configuration profiles, the [Apple Configurator](https://itunes.apple.com/us/app/apple-configurator/id434433123?mt=12) can generate profiles, as an alternative to hand-writing XML yourself.

![iOS Configurator - Generate]({{ site.asseturl }}/ios-configurator-generate.png)

## Use Cases

It's easy to recognize how invaluable the aforementioned features would be to anyone attempting to deploy iOS devices within a large business or school.

But how can this be used to bring new functionality to conventional apps? Admittedly, the use of configuration profiles is relatively uncharted territory for many developers, but there could be entire categories of app functionality yet to be realized.

Here are a few ideas to chew on:

### Distributing Development Builds

If you're ever used a development distribution service like [HockeyApp](http://hockeyapp.net) or [TestFlight](http://testflightapp.com), you've installed a configuration profile—perhaps without knowing it!

Using a configuration profile, these services can automatically get information like device UDID, model name, and even add a new web clip on the home screen to download available apps.

Although Apple Legal gets twitchy at even the slightest intimation of third-party app stores, perhaps there are ways for configuration profiles to enable new forms of collaboration. It's unclear what the effect of [Apple's acquisition of Burstly](http://www.theverge.com/apps/2014/2/21/5434060/apple-buys-maker-of-the-ios-testing-platform-testflight) (TestFlight's parent company) will be in the long term, but for now, this could be a great opportunity for some further exploration of this space.

### Installing Custom Fonts

A recent addition to configuration profiles is the ability to embed font payloads, allowing for new typefaces to be installed across the system (for example, to be used in Pages or Keynote).

Just as EOF / WOFF / SVG fonts allow typefaces to be distributed over the web, type foundries could similarly offer TTF / OTF files to iOS devices using an app with a configuration profile. Since configuration profiles can be installed from a web page, an app could embed and run an HTTP process to locally serve a webpage with a profile and payload.

### Enhancing Security

Security has quickly become a killer feature for apps, as discussed in our article about [Multipeer Connectivity](http://nshipster.com/multipeer-connectivity/).

Perhaps configuration profiles, with the ability to embed certificates and single sign-on credentials, could add another level of security to communication apps.

### Expanding the Scope of In-App Purchases

Imagine if IAP could be used to unlock functionality in the real world.

A clever combination of IAP and auto-expiring configuration profiles could be used to allow access to secure WiFi networks, printers, or AirPlay devices. Add in IAP subscriptions and captive WiFi network messages, and it could make for a compelling business model.

* * *

To its credit, tight restrictions have helped ensure a consistent and secure user experience on iOS from its inception, and Apple should be lauded for engineering the platform in such a way that an entire ecosystem of 3rd party software is able to operate without compromising that experience.

Of course, as developers, we're always going to want more functionality open to us.  iOS Configuration Profiles are a lesser-known feature that open a wide range of possibilities, that we have only begun to understand.
