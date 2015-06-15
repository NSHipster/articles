---
title: Configuration Profiles
author: Mattt Thompson
category: ""
excerpt: "One of the major criticisms of iOS as a platform is how locked down it is. iOS Configuration Profiles offer an interesting mechanism to work around these restrictions."
translator: April Peng
excerpt: "iOS 作为一个平台的主要缺陷是如何锁定它。 iOS 的 Configuration Profiles 提供了一个有趣的机制来解决这些限制。"
---

One of the major criticisms of iOS as a platform is how locked down it is.

iOS 作为一个平台的主要缺陷是如何锁定它。 iOS 的 Configuration Profiles 提供了一个有趣的机制来解决这些限制。

Each app is an island, only able to communicate with other parts of the system under strict terms, and only then with nontrivial effort. There's no way, for example, for an app to open its own settings in Settings.app. There's no way for apps to change their icon at runtime, or to customize the behavior of system-wide functionality, like Notification Center or Siri. Apps can't embed or share views with one another, or communicate locally.

每个应用程序都是一座孤岛，只能在严格的条款下才能与系统的其他部分进行交流，而且用途也很局限。例如，一个应用程序想要在 Settings.app 中打开自己的设置是不行的。也没有办法能让应用程序在运行时改变自己的图标，或自定义系统层面，诸如通知中心或 Siri，的功能的行为。应用程序之间不能互相嵌入、分享视图，或进行本地通信。

So it may come as a surprise how many of these limitations to iOS can be worked around with a bit of XML.

因此，iOS 上有多少限制可以用一点 XML 来解决可能会让你很惊喜。

The feature in question, and topic of this week's article is [iOS Configuration Profiles](https://developer.apple.com/library/ios/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html).

本周文章讨论的功能和主题是 [iOS Configuration Profiles](https://developer.apple.com/library/ios/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html).

***

Unless you've worked in the enterprise or on wide-scale educational software, there's a good chance that you haven't heard much about configuration profiles.

除非你在企业或大型的教育软件工作过，那么你很可能没有听说过配置文件。

__Configuration Profiles are not to be confused with Provisioning Profiles.__

__不要把 Configuration Profiles 与 Provisioning Profiles 混淆.__

A _provisioning profile_ is used to determine that an app is authorized by the developer to run on a particular device. A _configuration profile_ can be used to apply a variety of settings to a device.

一个 _provisioning profile_ 用于确定一个应用程序被允许到一个特定的设备上运行。一个 _configuration profile_ 可用于对设备进行多种设置。

Both configuration & provisioning profiles are displayed in similar fashion under `Settings.app > General > Profiles`, which doesn't help with the potential confusion.

这两个配置文件都以类似的方式显示在 `Settings.app > General > Profiles`，这不利于与理清潜在可能的混淆。

Each configuration file includes a number of payloads, each of which can specify configuration, including:

每个配置文件包括多个设置，其中每个可指定的配置，包括：

- Whitelisting & Authenticating AirPlay & AirPrint destinations
- Setting up VPN, HTTP Proxies, WiFi & Cellular Network
- Configuring Email (SMTP, Exchange), Calendar (CalDAV), and Contacts (CardDAV, LDAP, AD)
- Restricting access to Apps, Device Features, Web Content, and Media Playback
- Managing Certificates and SSO Credentials
- Installing Web Clips, Apps, and Custom Fonts

- 白名单、AirPlay 的身份验证和 AirPrint 的目标
- 建立 VPN，HTTP 代理服务器，无线网络和蜂窝网络
- 配置电子邮件（SMTP，Exchange），日历（CalDAV），和联系人（CardDAV，LDAP，AD）
- 限制访问应用程序，设备功能，Web内容和媒体回放
- 管理证书和 SSO 凭据
- 安装网页剪辑，应用程序和自定义字体

There are several ways to deploy configuration profiles:

有几种方法来部署配置文件：

- Attaching to an email
- Linking to one on a webpage
- Using over-the air configuration
- Using Apple Configurator

- 附加到电子邮件
- 链接到一个网页
- 使用无线配置
- 使用 Apple Configurator

> In addition to deploying configuration profiles, the [Apple Configurator](https://itunes.apple.com/us/app/apple-configurator/id434433123?mt=12) can generate profiles, as an alternative to hand-writing XML yourself.

> 除了部署配置文件，在 [Apple Configurator](https://itunes.apple.com/us/app/apple-configurator/id434433123?mt=12) 还可以生成配置文件，以替代你自己手写 XML。

![iOS Configurator - Generate](http://nshipster.s3.amazonaws.com/ios-configurator-generate.png)

## 用例

It's easy to recognize how invaluable the aforementioned features would be to anyone attempting to deploy iOS devices within a large business or school.

你将很容易发现，对于那些任何试图在一个大型企业或学校部署 iOS 设备的人来说，上述功能将是如何的宝贵。

But how can this be used to bring new functionality to conventional apps? Admittedly, the use of configuration profiles is relatively uncharted territory for many developers, but there could be entire categories of app functionality yet to be realized.

不过，这能给传统的应用程序使用带来什么新的功能？诚然，对大多数开发人员来说，配置文件的使用领域还相对未知，但有可能是整个尚未发现的类别的应用程序。

Here are a few ideas to chew on:

这里有一些可以拿来琢磨的想法：

### Distributing Development Builds

### 发版本

If you're ever used a development distribution service like [HockeyApp](http://hockeyapp.net) or [TestFlight](http://testflightapp.com), you've installed a configuration profile—perhaps without knowing it!

如果你曾经使用过类似 [HockeyApp](http://hockeyapp.net) 或 [TestFlight](http://testflightapp.com) 的版本发布服务，你已经安装了一个配置文件，或许你都还不知道！

Using a configuration profile, these services can automatically get information like device UDID, model name, and even add a new web clip on the home screen to download available apps.

使用配置文件，这些服务可以自动得到诸如设备的 UDID，型号名称信息，甚至在主屏幕上添加一个新的网页剪辑来下载可用的应用程序。

Although Apple Legal gets twitchy at even the slightest intimation of third-party app stores, perhaps there are ways for configuration profiles to enable new forms of collaboration. It's unclear what the effect of [Apple's acquisition of Burstly](http://www.theverge.com/apps/2014/2/21/5434060/apple-buys-maker-of-the-ios-testing-platform-testflight) (TestFlight's parent company) will be in the long term, but for now, this could be a great opportunity for some further exploration of this space.

虽然现有的苹果的规定使得要得到在第三方应用程序商店发布的哪怕是一丁点暗示都很难，但或许是有别的办法来配置概要文件，来形成新的合作形式。目前还不清楚[苹果收购 Burstly](http://www.theverge.com/apps/2014/2/21/5434060/apple-buys-maker-of-the-ios-testing-platform-testflight) （TestFlight 的母公司）将在未来有什么样的影响，但就目前而言，这可能是对这个空间进一步探索的一个很好的机会。

### Installing Custom Fonts

### 安装自定义字体

A recent addition to configuration profiles is the ability to embed font payloads, allowing for new typefaces to be installed across the system (for example, to be used in Pages or Keynote).

配置概要文件最近的更新是加入了字体的配置选项，允许在整个系统安装新的字体（例如，在 Pages 或 Keynote 被使用）。

Just as EOF / WOFF / SVG fonts allow typefaces to be distributed over the web, type foundries could similarly offer TTF / OTF files to iOS devices using an app with a configuration profile. Since configuration profiles can be installed from a web page, an app could embed and run an HTTP process to locally serve a webpage with a profile and payload.

正如 EOF/ WOFF/ SVG 字体允许字体在网页被发布一样，可以类似的使用一个配置文件的应用程序给 iOS 设备提供 TTF / OTF 文件。由于配置概要文件可以从网页被安装，应用程序可以嵌入并运行一个 HTTP 请求在本地服务的网页配置文件。

### Enhancing Security

### 增强安全性

Security has quickly become a killer feature for apps, as discussed in our article about [Multipeer Connectivity](http://nshipster.com/multipeer-connectivity/).

安全已迅速成为应用程序的一个杀手级功能，如我们文章中对 [Multipeer Connectivity](http://nshipster.com/multipeer-connectivity/) 的讨论。

Perhaps configuration profiles, with the ability to embed certificates and single sign-on credentials, could add another level of security to communication apps.

以嵌入证书和单一的能力登录凭据，也许配置概要文件可以增加通信类应用程序的安全级别。

### Expanding the Scope of In-App Purchases

### 扩大应用内购买的范围

Imagine if IAP could be used to unlock functionality in the real world.

试想一下，如果 IAP 可用于在现实世界中解锁功能。

A clever combination of IAP and auto-expiring configuration profiles could be used to allow access to secure WiFi networks, printers, or AirPlay devices. Add in IAP subscriptions and captive WiFi network messages, and it could make for a compelling business model.

把 IAP 和自动过期的配置巧妙地结合就可以用来允许访问加密的 WiFi 网络，打印机，或 AirPlay 设备。在 IAP 和 WiFi 网络消息加入配置功能，可以引入一个全新的的商业模式。

* * *

To its credit, tight restrictions have helped ensure a consistent and secure user experience on iOS from its inception, and Apple should be lauded for engineering the platform in such a way that an entire ecosystem of 3rd party software is able to operate without compromising that experience.

值得称道的是，严格限制有助于确保从成立之初就在 iOS 上建立起的一致的安全用户体验，把平台建立在这样一种方式下，使得整个第三方软件的生态系统能够不危及体验去操作，苹果应该为此得到称赞。

Of course, as developers, we're always going to want more functionality open to us.  iOS Configuration Profiles are a lesser-known feature that open a wide range of possibilities, that we have only begun to understand.

当然，作为开发者，我们总是会想得到更多的许可和空间。 iOS Configuration Profiles 是一个我们才刚刚开始了解，还鲜为人知的功能，它可能可以为我们打开更多的可能性**。**
