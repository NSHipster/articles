---
title: Network Link Conditioner
author: Mattt Thompson
category: Xcode
tag: popular
translator: April Peng
excerpt: "产品设计是一种感同身受。知道用户想要什么，他们喜欢什么，他们不喜欢什么，是什么原因会让他们沮丧，学习去理解并且把那些动机实现于设计 —— 这就是把一些疯狂的事情做得漂亮要去做的事情。"
---

产品设计是一种感同身受。知道用户想要什么，他们喜欢什么，他们不喜欢什么，什么原因会让他们沮丧，学习去理解并且把那些动机实现于设计 —— 这就是把一些疯狂的事情做得漂亮需要去做的事情。

因此，我们在自己的工作领域之外的世界范围内去投资。我们在[不同地区](http://nshipster.com/nslocalizedstring/)调整我们的经验。我们考虑[屏幕阅读器或其他辅助技术](http://nshipster.com/uiaccessibility/)的可用性影响。我们[持续评估](http://nshipster.com/unit-testing/)我们对这些期望的实现。

尽管还有一个应用程序开发人员开始常常错过的关键因素，那就是**网络状况**，或更具体的说是互联网连接的延迟和带宽。对于一款产品来说，对用户体验如此重要的东西，基本上大多数开发者采取 ad-hoc 的方式来测试不同环境是非常不幸的。

本周的 NSHipster，让我来聊聊 [Network Link Conditioner](https://developer.apple.com/downloads/index.action?q=Network%20Link%20Conditioner)，一个 Mac 和 iOS 的实用工具，用来精确和持续模拟不良的网络环境。

## 安装

Network Link Conditioner 可以在 “Xcode 的硬件 IO 工具” 包中找到。这可以从[苹果开发者下载](https://developer.apple.com/downloads/index.action?q=Network%20Link%20Conditioner)页面下载。

![Download](http://nshipster.s3.amazonaws.com/network-link-conditioner-download.png)

搜索 “Network Link Conditioner”，然后选择正确版本的 “Xcode 的硬件 IO 工具” 包。

![Package](http://nshipster.s3.amazonaws.com/network-link-conditioner-dmg.png)

下载完成后，打开 DMG，然后双击 “Network Link Condition.prefPane” 来进行安装。

![System Preferences](http://nshipster.s3.amazonaws.com/network-link-conditioner-install.png)

现在起，你可以在系统设置的底部启用 Network Link Conditioner。

![Network Link Conditioner](http://nshipster.s3.amazonaws.com/network-link-conditioner-system-preference.png)

启用后，Network Link Conditioner 可以根据内置的某个预设来改变 iPhone 模拟器的网络环境根：

- EDGE
- 3G
- DSL
- WiFi
- High Latency DNS
- Very Bad Network
- 100% Loss

每个预置可以设置上行或下行的[带宽](http://en.wikipedia.org/wiki/Bandwidth_%28computing%29)极限，[延迟](http://en.wikipedia.org/wiki/Latency_％28engineering％29％23Communication_latency)，和[丢包](http://en.wikipedia.org/wiki/Packet_loss)概率（当任何值被设置为 0 时，该值将会同你的计算机的网络环境保持一致）。

![Preset](http://nshipster.s3.amazonaws.com/network-link-conditioner-preset.png)

如果你想同时模拟多种因素的特定组合，你也可以创建自己的预设。

尝试在 Network Link Conditioner 的各种预设启用的情况下运行你的应用程序，看看会发生什么。网络延迟会怎样影响你的应用程序的启动？带宽对 table 视图的滚动性能有什么影响？你的应用程序在 100％ 丢包的情况下依然工作吗？

> 如果你的应用程序使用 [Reachability](https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html) 检测网络的可用性，同时使用 Network Link Conditioner 会让你遇到一些意想不到的结果。因此，飞行模式或 WWAN / WiFi 模式下的任何可用性行为都应该独立于网络条件进行测试。

## 在 iOS 设备上启用 Network Link Conditioner

虽然偏好设置面板在模拟器上工作的很好，但在实际设备上测试也是非常重要的。幸运的是，在 iOS 6 上， Network Link Conditioner 在设备上已经有现成的了。

要启用它，你需要为开发设置一下你的设备：

1. 把你的 iPhone 或 iPad 连接到 Mac
2. 在 Xcode 中，选择 Window > Organizer（⇧⌘2）
3. 在侧边栏中选择你的设备
4. 单击 “Use for Development”

![iOS Devices](http://nshipster.s3.amazonaws.com/network-link-conditioner-ios.png)

现在，你可以在设置应用程序里看到开发者分区了，你可以在那里找到 Network Link Conditioner（只是别忘了在完成测试后把它关掉！）。
