---
title: Network Link Conditioner
author: Mattt Thompson
category: Xcode
tag: popular
excerpt: "Product design is about empathy. Knowing what a user wants, what they like, what they dislike, what causes them frustration, and learning to understand and embody those motivations in design decisions—this is what it takes to make something insanely great."
translator: April Peng
excerpt: "产品设计是一种感同身受。知道用户想要什么，他们喜欢什么，他们不喜欢什么，是什么原因会让他们沮丧，学习去理解并且把那些动机决实现于设计 - 这就是把一些疯狂的事情做得漂亮要去做的事情。"
---

Product design is about empathy. Knowing what a user wants, what they like, what they dislike, what causes them frustration, and learning to understand and embody those motivations in design decisions—this is what it takes to make something insanely great.

产品设计是一种感同身受。知道用户想要什么，他们喜欢什么，他们不喜欢什么，什么原因会让他们沮丧，学习去理解并且把那些动机决实现于设计 - 这就是把一些疯狂的事情做得漂亮需要去做的事情。

And so we invest in reaching beyond our own operational model of the world. We tailor our experience for [different locales](http://nshipster.com/nslocalizedstring/). We consider the usability implications of [screen readers or other assistive technologiess](http://nshipster.com/uiaccessibility/). We [continuously evaluate](http://nshipster.com/unit-testing/) our implementation against these expectations.

因此，我们在自己的工作领域之外的世界范围内去投资。我们在[不同地区](http://nshipster.com/nslocalizedstring/)调整我们的经验。我们考虑[屏幕阅读器或其他辅助技术](http://nshipster.com/uiaccessibility/)的可用性影响。我们[持续评估](http://nshipster.com/unit-testing/)我们对这些期望的实现。

There is, though, one critical factor that app developers often miss the first time around, and that is **network condition**, or more specifically the latency and bandwidth of an Internet connection. For something so essential to a user's experience with a product, it's unfortunate that most developers take an ad-hoc approach to field testing different kinds of environments, if at all.

尽管还有一个应用程序开发人员开始常常错过的关键因素，那就是**网络状况**，或更具体的说是互联网连接的延迟和带宽。对于一款产品来说，对用户体验如此重要的东西，基本上大多数开发者采取 ad-hoc 的方式来测试不同环境是非常不幸的。

This week on NSHipster, we'll be talking about the [Network Link Conditioner](https://developer.apple.com/downloads/index.action?q=Network%20Link%20Conditioner), a utility that allows Mac and iOS devices to accurately and consistently simulate adverse networking environments.

本周的 NSHipster，让我来聊聊 [Network Link Conditioner](https://developer.apple.com/downloads/index.action?q=Network%20Link%20Conditioner)，一个 Mac 和 iOS 的实用工具，用来精确和持续模拟不良的网络环境。

## Installation

## 安装

Network Link Conditioner can be found in the "Hardware IO Tools for Xcode" package. This can be downloaded from the [Apple Developer Downloads](https://developer.apple.com/downloads/index.action?q=Network%20Link%20Conditioner) page.

Network Link Conditioner 可以在 “Xcode 的硬件 IO 工具” 包中找到。这可以从[苹果开发者下载](https://developer.apple.com/downloads/index.action?q=Network%20Link%20Conditioner)页面下载。

![Download](http://nshipster.s3.amazonaws.com/network-link-conditioner-download.png)

Search for "Network Link Conditioner", and select the appropriate release of the "Hardware IO Tools for Xcode" package.

搜索 “Network Link Conditioner”，然后选择正确版本的 “Xcode 的硬件 IO 工具” 包。

![Package](http://nshipster.s3.amazonaws.com/network-link-conditioner-dmg.png)

Once the download has finished, open the DMG and double-click "Network Link Condition.prefPane" to install.

下载完成后，打开 DMG，然后双击 “Network Link Condition.prefPane” 来进行安装。

![System Preferences](http://nshipster.s3.amazonaws.com/network-link-conditioner-install.png)

From now on, you can enable the Network Link Conditioner from its preference pane at the bottom of System Preferences.

现在起，你可以在系统设置的底部启用 Network Link Conditioner。

![Network Link Conditioner](http://nshipster.s3.amazonaws.com/network-link-conditioner-system-preference.png)

When enabled, the Network Link Conditioner can change the network environment of the iPhone Simulator according to one of the built-in presets:

启用后，Network Link Conditioner 可以根据内置的某个预设来改变 iPhone 模拟器的网络环境根：

- EDGE
- 3G
- DSL
- WiFi
- High Latency DNS
- Very Bad Network
- 100% Loss

Each preset can set a limit for uplink or downlink [bandwidth](http://en.wikipedia.org/wiki/Bandwidth_%28computing%29), [latency](http://en.wikipedia.org/wiki/Latency_%28engineering%29%23Communication_latency), and rate of [packet loss](http://en.wikipedia.org/wiki/Packet_loss) (when any value is set to 0, that value is unchanged from your computer's network environment).

每个预置可以设置上行或下行的[带宽](http://en.wikipedia.org/wiki/Bandwidth_%28computing%29)极限，[延迟](http://en.wikipedia.org/wiki/Latency_％28engineering％29％23Communication_latency)，和[丢包](http://en.wikipedia.org/wiki/Packet_loss)概率（当任何值被设置为 0 时，该值将会同你的计算机的网络环境保持一致）。

![Preset](http://nshipster.s3.amazonaws.com/network-link-conditioner-preset.png)

You can also create your own preset, if you wish to simulate a particular combination of factors simultaneously.

如果你想同时模拟多种因素的特定组合，你也可以创建自己的预设。

Try running your app in the simulator with the Network Link Conditioner enabled under various presets and see what happens. How does network latency affect your app startup? What effect does bandwidth have on table view scroll performance? Does your app work at all with 100% packet loss?

尝试在 Network Link Conditioner 的各种预设启用的情况下运行你的应用程序，看看会发生什么。网络延迟会怎样影响你的应用程序的启动？带宽对 table 视图的滚动性能有什么影响？你的应用程序在 100％ 丢包的情况下依然工作吗？

> If your app uses [Reachability](https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html) to detect network availability, you may experience some unexpected results while using the Network Link Conditioner. As such, any reachability behavior under Airplane mode or WWan / WiFi distinctions is something that should be tested separately from network conditioning.

> 如果你的应用程序使用 [Reachability](https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html) 检测网络的可用性，同时使用 Network Link Conditioner 会让你遇到一些意想不到的结果。因此，飞行模式或 WWAN / WiFi 模式下的任何可用性行为都应该独立于网络条件进行测试。

## Enabling Network Link Conditioner on iOS Devices

## 在 iOS 设备上启用 Network Link Conditioner

While the preference pane works well for developing on the simulator, it's also important to test on actual devices. Fortunately, as of iOS 6, the Network Link Conditioner is available on the devices themselves.

虽然偏好设置面板在模拟器上工作的很好，但在实际设备上测试也是非常重要的。幸运的是，在 iOS 6 上， Network Link Conditioner 在设备上已经有现成的了。

To enable it, you need to set up your device for development:

要启用它，你需要为开发设置一下你的设备：

1. Connect your iPhone or iPad to your Mac
2. In Xcode, go to Window > Organizer (⇧⌘2)
3. Select your device in the sidebar
4. Click "Use for Development"

1. 把你的 iPhone 或 iPad 连接到 Mac
2. 在 Xcode 中，选择 Window > Organizer（⇧⌘2）
3. 在侧边栏中选择你的设备
4. 单击 “Use for Development”

![iOS Devices](http://nshipster.s3.amazonaws.com/network-link-conditioner-ios.png)

Now you'll have access to the Developer section of the Settings app, where you'll find the Network Link Conditioner (just don't forget to turn it off after you're done testing!).

现在，你可以在设置应用程序里看到开发者分区了，你可以在那里找到 Network Link Conditioner（只是别忘了在完成测试后把它关掉！）。
