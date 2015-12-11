---
title: Configuration Profiles
author: Mattt Thompson
category: ""
translator: April Peng
excerpt: "iOS 作为一个平台的主要缺陷是如何锁定它。 iOS 的 Configuration Profiles 提供了一个有趣的机制来解决这些限制。"
---

iOS 作为一个平台的主要缺陷是如何锁定它。 iOS 的 Configuration Profiles 提供了一个有趣的机制来解决这些限制。

每个应用程序都是一座孤岛，只能在严格的条款下才能与系统的其他部分进行交流，而且用途也很局限。例如，一个应用程序想要在 Settings.app 中打开自己的设置是不行的。也没有办法能让应用程序在运行时改变自己的图标，或自定义系统层面功能的行为，如通知中心或 Siri。应用程序之间不能互相嵌入、分享视图，或进行本地通信。

因此，iOS 上有多少限制可以用一点 XML 来解决可能会让你很惊喜。

本周文章讨论的功能和主题是 [iOS Configuration Profiles](https://developer.apple.com/library/ios/featuredarticles/iPhoneConfigurationProfileRef/Introduction/Introduction.html).

***

除非你在企业或大型的教育软件工作过，那么你很可能没有听说过配置文件。

__不要把 Configuration Profiles 与 Provisioning Profiles 混淆.__

一个 _provisioning profile_ 用于确定一个应用程序被允许到一个特定的设备上运行。一个 _configuration profile_ 可用于对设备进行多种设置。

这两个配置文件都以类似的方式显示在 `Settings.app > General > Profiles`，这不利于与理清潜在可能的混淆。

每个配置文件包括多个设置，其中每个可指定的配置，包括：

- 白名单、AirPlay 的身份验证和 AirPrint 的目标
- 建立 VPN，HTTP 代理服务器，无线网络和蜂窝网络
- 配置电子邮件（SMTP，Exchange），日历（CalDAV），和联系人（CardDAV，LDAP，AD）
- 限制访问应用程序，设备功能，Web内容和媒体回放
- 管理证书和 SSO 凭据
- 安装网页剪辑，应用程序和自定义字体

有几种方法来部署配置文件：

- 附加到电子邮件
- 链接到一个网页
- 使用无线配置
- 使用 Apple Configurator

> 除了部署配置文件，在 [Apple Configurator](https://itunes.apple.com/us/app/apple-configurator/id434433123?mt=12) 还可以生成配置文件，以替代你自己手写 XML。

![iOS Configurator - Generate]({{ site.asseturl }}/ios-configurator-generate.png)

## 用例

你将很容易发现，对于那些任何试图在一个大型企业或学校部署 iOS 设备的人来说，上述功能将是如何的宝贵。

不过，这能给传统的应用程序使用带来什么新的功能？诚然，对大多数开发人员来说，配置文件的使用领域还相对未知，但有可能是整个尚未发现的类别的应用程序。

这里有一些可以拿来琢磨的想法：

### 发版本

如果你曾经使用过类似 [HockeyApp](http://hockeyapp.net) 或 [TestFlight](http://testflightapp.com) 的版本发布服务，你已经安装了一个配置文件，或许你都还不知道！

使用配置文件，这些服务可以自动得到诸如设备的 UDID，型号名称信息，甚至在主屏幕上添加一个新的网页剪辑来下载可用的应用程序。

虽然现有的苹果的规定使得要得到在第三方应用程序商店发布的哪怕是一丁点暗示都很难，但或许是有别的办法来配置概要文件，来形成新的合作形式。目前还不清楚[苹果收购 Burstly](http://www.theverge.com/apps/2014/2/21/5434060/apple-buys-maker-of-the-ios-testing-platform-testflight) （TestFlight 的母公司）将在未来有什么样的影响，但就目前而言，这可能是对这个空间进一步探索的一个很好的机会。

### 安装自定义字体

配置概要文件最近的更新是加入了字体的配置选项，允许在整个系统安装新的字体（例如，在 Pages 或 Keynote 被使用）。

正如 EOF/ WOFF/ SVG 字体允许字体在网页被发布一样，可以类似的使用一个配置文件的应用程序给 iOS 设备提供 TTF / OTF 文件。由于配置概要文件可以从网页被安装，应用程序可以嵌入并运行一个 HTTP 请求在本地服务的网页配置文件。

### 增强安全性

安全已迅速成为应用程序的一个杀手级功能，如我们文章中对 [Multipeer Connectivity](http://nshipster.com/multipeer-connectivity/) 的讨论。

也许配置概要文件的嵌入证书和单点登录认证的能力可以增加通信类应用程序的安全级别。

### 扩大应用内购买的范围

试想一下，如果 IAP 可用于在现实世界中解锁功能。

把 IAP 和自动过期的配置巧妙地结合就可以用来允许访问加密的 WiFi 网络，打印机，或 AirPlay 设备。在 IAP 和 WiFi 网络消息加入配置功能，可以引入一个全新的的商业模式。

* * *

值得称道的是，严格限制有助于确保从成立之初就在 iOS 上建立起的一致的安全用户体验，把平台建立在这样一种方式下，使得整个第三方软件的生态系统能够不危及体验去操作，苹果应该为此得到称赞。

当然，作为开发者，我们总是会想得到更多的许可和空间。 iOS Configuration Profiles 是一个我们才刚刚开始了解，还鲜为人知的功能，它可能可以更多功能开放给我们。
