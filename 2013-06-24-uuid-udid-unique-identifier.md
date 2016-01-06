---
title: "NSUUID /<br/>CFUUIDRef /<br/>UIDevice -uniqueIdentifier /<br/>-identifierForVendor"
author: Mattt Thompson
category: Cocoa
translator: April Peng
excerpt: "直到最近之前，应用程序，甚至是跨应用程序启动的时候，获得设备的唯一标识一直都是小菜一碟，简单的请求 UIDevice -uniqueIdentifier 就完事了。"
---

比方说，你正在做一个有版权的软件，就需要防止盗版。我的意思是，这再明显不过了 - [已经有人在做这件事了](http://www.fakeblock.com)。而你正想成为 _那个_ 人。

直到最近之前，应用程序，甚至是跨应用程序启动的时候，获得设备的唯一标识一直都是小菜一碟，简单的请求 UIDevice -uniqueIdentifier 就完事了。

然而，`UIDevice -uniqueIdentifier` 在 iOS 5 就被废弃了，以下是注释：

> 可酌情使用 [`UIDevice`] 的 `identifierForVendor` 属性 或 `ASIdentifierManager` 类的 `advertisingIdentifier` 代替，或使用 `NSUUID` 类的 `UUID` 方法来创建一个 `UUID` 并写入到用户的默认数据库。

[从 5 月 1 日起](https://developer.apple.com/news/?id=3212013a)，苹果公司开始强制所有新提交的应用程序不能再使用这个废弃的 API，即使是针对早期版本 iOS 的应用程序也一样。任何使用 `uniqueIdentifier` 的二进制文件都将立即被拒。

就像版权和盗版有语音和概念上的相似性一样，设备标识符，无论是 UUID / GUID，UDID，或其他方式都是相当容易混淆的：

- **UUID _（通用唯一标识符）_**：一个 128 位的序列，可以保证跨时间和空间的唯一性，由 [RFC4122](http://www.ietf.org/rfc/rfc4122.txt) 定义。
- **GUID _（全局唯一标识符）_**：微软实现的 UUID 规范；经常与 UUID 互换使用。
- **UDID _（设备唯一标识符）_**：40 个十六进制字符，用来唯一标识 iOS 设备（可当做该设备的[社会安全码](https://zh.wikipedia.org/wiki/%E7%A4%BE%E6%9C%83%E5%AE%89%E5%85%A8%E8%99%9F%E7%A2%BC)）。这个值可以[从 iTunes 得到](http://whatsmyudid.com)，或使用 `UIDevice -uniqueIdentifier` 得到类似 [MAC 地址](http://en.wikipedia.org/wiki/MAC_address) 这样的硬件详细信息。

顺便说一句，所有在说明中列出的可以替代 `UIDevice -uniqueIdentifier` 的建议都会返回 UUID，不论是自动从 `UIDevice -identifierForVendor` 和 `ASIdentifierManager -advertisingIdentifier` 创建或从 `NSUUID` （或 `CFUUIDCreate`） 手动创建。

## 供应商标识

> 对于同一设备上运行的相同运营商的应用程序来说，此属性返回的值都是相同的。同一台设备在不同运营商连接的情况下会返回给应用程序不同的值。而对于不同的设备来说，不管什么运营商，返回给应用程序的值都不一样。

> 只要应用程序（或同一运营商的另一个应用程序）安装在 iOS 设备上后，此属性的值都将保持不变。而当用户从设备删除所有该供应商的应用程序，并随后重新安装其中一个或多个应用程序时，该值将会改变。因此，如果你的应用程序在任何地方存储了这一属性的值，你需要正确处理标识符变化的这种情况。

在很多情况下，这才应该是其正确使用方法。应用程序开发者现在仍然找办法来确认设备的唯一标识，即使是从出自同样开发者的其他应用程序，而不把这种任务交给设备的 UDID。

对于大多数应用来说，查找 `uniqueIdentifier` 并将其替换为 `identifierForVendor` 就足够了。

但是，对于广告网络来说，需要把来自多个开发人员的不同的应用程序制定一个一致的识别符，必需需要一个不同的方法：

## 广告标识

> iOS 6 引入的广告标识，是一个非永久性的，非个人的设备标识符。广告网络将使用它来使你可以更好地通过跟踪方法控制广告投放。如果用户设置了限制广告追踪，使用广告标识的广告网络可能就不能再通过收集信息来提供针对性的广告了。在未来，所有的广告网络都将被要求使用广告标识符。然而，在广告网络过渡到使用广告标识之前，你可能还会收到来自其他网络的针对性的广告。

作为 [Ad Support framework](http://developer.apple.com/library/ios/#documentation/DeviceInformation/Reference/AdSupport_Framework/_index.html#//apple_ref/doc/uid/TP40012658) 仅有的组件, `ASIdentifierManager` 的作案手法很明确：提供一种方法让广告网络通过不同的应用程序跟踪用户行为，但又不触犯隐私。

用户可以在 iOS 6.1 新加的设置页面来选择限制广告跟踪，位置在 **设置 > 通用 > 关于本机 > 广告** (在 iOS 9.2 上，这个设置的位置已经修改： 设置 > 隐私 > 广告 [译者注])：

![Limit Ad Tracking](http://nshipster.s3.amazonaws.com/ad-support-limit-ad-tracking.png)

## NSUUID & CFUUIDRef

在 iOS 6 中被加到 Foundation 的 `NSUUID` 可以用来轻松地创建的 UUID。有多容易呢？

~~~{swift}
let UUID = NSUUID.UUID().UUIDString
~~~

~~~{objective-c}
NSString *UUID = [[NSUUID UUID] UUIDString];
~~~

不过，如果你的应用针对 iOS 5 或更早的版本，你必须设置 Core Foundation 的 `CFUUIDRef`：

~~~{swift}
let UUID = CFUUIDCreateString(nil, CFUUIDCreate(nil))
~~~

~~~{objective-c}
CFUUIDRef uuid = CFUUIDCreate(NULL);
NSString *UUID = CFUUIDCreateString(NULL, uuid);
~~~

对那些基于基础 SDK 而没有使用运营商或广告标识 API 的应用程序来说，使用弃用说明里推荐的方法就可以达到类似的效果，使用 [`NSUserDefaults`](http://developer.apple.com/library/ios/#documentation/cocoa/reference/foundation/Classes/NSUserDefaults_Class/Reference/Reference.html):

~~~{swift}
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {

    let userDefaults = NSUserDefaults.standardUserDefaults()

    if userDefaults.objectForKey("ApplicationUniqueIdentifier") == nil {
        let UUID = NSUUID.UUID().UUIDString
        userDefaults.setObject(UUID, forKey: "ApplicationUniqueIdentifier")
        userDefaults.synchronize()
    }

    return true
}
~~~

~~~{objective-c}
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:kApplicationUUIDKey];
    if (!UUID) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        UUID = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);

        [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:kApplicationUUIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
~~~

以此方式，一个 UUID 会在应用程序启动的第一时间被生成，然后存储在 `NSUserDefaults` 以便随后每次应用程序的启动所调用。不同于广告或运营商标识的是，这些标识不会同其他应用程序共享，但对于大多数的意图和目的来说，这已经足够达到目的了。

---

当然，UUID 还有许多其他用途：用于记录在分布式系统的主标识符，临时文件的名称，或甚至是一个散色生成器（把十六进制串成每组 6 个，一共 5 组的表示方式！）。但在 iOS 上，它主要还是用于跟踪，用于发现在网络和可能性的汪洋中遗失了什么。理解你有多独特是了解一切的第一步。
