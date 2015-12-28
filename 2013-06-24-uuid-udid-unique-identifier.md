---
title: "NSUUID /<br/>CFUUIDRef /<br/>UIDevice -uniqueIdentifier /<br/>-identifierForVendor"
author: Mattt Thompson
category: Cocoa
excerpt: "Until recently, it was trivial to uniquely identify devices between application launches, and even across applications: a simple call to UIDevice -uniqueIdentifier, and you were all set."
translator: April Peng
excerpt: "直到最近之前，应用程序，甚至是跨应用程序启动的时候，获得设备的唯一标识一直都是小菜一碟，简单的请求 UIDevice -uniqueIdentifier 就完事了。"
---

Let's say you're making privacy software that also prevents piracy. I mean, it's an obvious idea—[someone's going to do it](http://www.fakeblock.com). You're just trying to be _that_ person.

比方说，你正在做一个有版权的软件，就需要防止盗版。我的意思是，这再明显不过了 - [好的想法总是会有人想去做](http://www.fakeblock.com)。而你只是想成为真正做到的 _那个_ 人。

Until recently, it was trivial to uniquely identify devices between application launches, and even across applications: a simple call to `UIDevice -uniqueIdentifier`, and you were all set.

直到最近之前，应用程序，甚至是跨应用程序启动的时候，获得设备的唯一标识一直都是小菜一碟，简单的请求 UIDevice -uniqueIdentifier 就完事了。

However, `UIDevice -uniqueIdentifier` was deprecated in iOS 5 with the following notes:

然而，`UIDevice -uniqueIdentifier` 在 iOS 5 就被废弃了，以下是注释：

> Use the `identifierForVendor` property of [`UIDevice`] or the `advertisingIdentifier` property of the `ASIdentifierManager` class instead, as appropriate, or use the `UUID` method of the `NSUUID` class to create a `UUID` and write it to the user defaults database.

> 可酌情使用 [`UIDevice`] 的 `identifierForVendor` 属性 或 `ASIdentifierManager` 类的 `advertisingIdentifier` 代替，或使用 `NSUUID` 类的 `UUID` 方法来创建一个 `UUID` 并写入到用户的默认数据库。

[As of May 1st](https://developer.apple.com/news/?id=3212013a), Apple began enforcing this deprecation on all new app submissions, even for apps targeting earlier versions of iOS. Any use of `uniqueIdentifier` is grounds for immediate rejection of new binaries.

[从 5 月 1 日起](https://developer.apple.com/news/?id=3212013a)，苹果公司开始强制所有新提交的应用程序不能再使用这个废弃的 API，即使是针对早期版本 iOS 的应用程序也一样。任何使用 `uniqueIdentifier` 的二进制文件都将立即被拒。

Just as privacy and piracy have phonetic and conceptual similarities, device identifiers, whether UUID / GUID, UDID, or otherwise can be rather confusing:

就像版权和盗版有语音和概念上的相似性一样，设备标识符，无论是 UUID / GUID，UDID，或其他方式都是相当容易混淆的：

- **UUID _(Universally Unique Identifier)_**: A sequence of 128 bits that can guarantee uniqueness across space and time, defined by [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).
- **GUID _(Globally Unique Identifier)_**: Microsoft's implementation of the UUID specification; often used interchangeably with UUID.
- **UDID _(Unique Device Identifier)_**: A sequence of 40 hexadecimal characters that uniquely identify an iOS device (the device's [Social Security Number](https://en.wikipedia.org/wiki/Social_Security_number), if you will). This value can be [retrieved through iTunes](http://whatsmyudid.com), or found using `UIDevice -uniqueIdentifier`. Derived from hardware details like [MAC address](http://en.wikipedia.org/wiki/MAC_address).

- **UUID _（通用唯一标识符）_**：一个 128 位的序列，可以保证跨时间和空间的唯一性，由 [RFC4122](http://www.ietf.org/rfc/rfc4122.txt) 定义。
- **GUID _（全局唯一标识符）_**：微软实现的 UUID 规范；经常与 UUID 互换使用。
- **UDID _（设备唯一标识符）_**：40 个十六进制字符，用来唯一标识 iOS 设备（可当做该设备的[社会安全码](https://zh.wikipedia.org/wiki/%E7%A4%BE%E6%9C%83%E5%AE%89%E5%85%A8%E8%99%9F%E7%A2%BC)）。这个值可以[从 iTunes 得到](http://whatsmyudid.com)，或使用 `UIDevice -uniqueIdentifier` 得到类似 [MAC 地址](http://en.wikipedia.org/wiki/MAC_address) 这样的硬件详细信息。

Incidentally, all of the suggested replacements for `UIDevice -uniqueIdentifier` listed in its deprecation notes return UUID, whether created automatically with `UIDevice -identifierForVendor` & `ASIdentifierManager -advertisingIdentifier` or manually with `NSUUID` (or `CFUUIDCreate`).

顺便说一句，所有在说明中列出的可以替代 `UIDevice -uniqueIdentifier` 的建议都会返回 UUID，不论是自动从 `UIDevice -identifierForVendor` 和 `ASIdentifierManager -advertisingIdentifier` 创建或从 `NSUUID` （或 `CFUUIDCreate`） 手动创建。

## Vendor Identifier

## 供应商标识

> The value of this property is the same for apps that come from the same vendor running on the same device. A different value is returned for apps on the same device that come from different vendors, and for apps on different devices regardless of vendor.

> 对于同一设备上运行的相同运营商的应用程序来说，此属性返回的值都是相同的。同一台设备在不同运营商连接的情况下会返回给应用程序不同的值。而对于不同的设备来说，不管什么运营商，返回给应用程序的值都不一样。

> The value in this property remains the same while the app (or another app from the same vendor) is installed on the iOS device. The value changes when the user deletes all of that vendor’s apps from the device and subsequently reinstalls one or more of them. Therefore, if your app stores the value of this property anywhere, you should gracefully handle situations where the identifier changes.

> 只要应用程序（或同一运营商的另一个应用程序）安装在 iOS 设备上后，此属性的值都将保持不变。而当用户从设备删除所有该供应商的应用程序，并随后重新安装其中一个或多个应用程序时，该值将会改变。因此，如果你的应用程序在任何地方存储了这一属性的值，你需要正确处理标识符变化的这种情况。

In many ways, this is what should have been used the whole time. App developers now have a way to identify devices uniquely—even across other apps by the same developer—without being entrusted with something as sensitive as the device's UDID.

在很多情况下，这才应该是其正确使用方法。应用程序开发者现在仍然找办法来确认设备的唯一标识，即使是从出自同样开发者的其他应用程序，而不把这种任务交给设备的 UDID。

For most applications, doing a find-and-replace of `uniqueIdentifier` to `identifierForVendor` is enough.

对于大多数应用来说，查找 `uniqueIdentifier` 并将其替换为 `identifierForVendor` 就足够了。

However, for advertising networks, which require a consistent identifier across applications from many developers, a different approach is required:

但是，对于广告网络来说，需要把来自多个开发人员的不同的应用程序制定一个一致的识别符，必需需要一个不同的方法：

## Advertising Identifier

## 广告标识

> iOS 6 introduces the Advertising Identifier, a non-permanent, non-personal, device identifier, that advertising networks will use to give you more control over advertisers’ ability to use tracking methods. If you choose to limit ad tracking, advertising networks using the Advertising Identifier may no longer gather information to serve you targeted ads. In the future all advertising networks will be required to use the Advertising Identifier. However, until advertising networks transition to using the Advertising Identifier you may still receive targeted ads from other networks.

> iOS 6 引入的广告标识，是一个非永久性的，非个人的设备标识符。广告网络将使用它来使你可以更好地通过跟踪方法控制广告投放。如果用户设置了限制广告追踪，使用广告标识的广告网络可能就不能再通过收集信息来提供针对性的广告了。在未来，所有的广告网络都将被要求使用广告标识符。然而，在广告网络过渡到使用广告标识之前，你可能还会收到来自其他网络的针对性的广告。

As the sole component of the [Ad Support framework](http://developer.apple.com/library/ios/#documentation/DeviceInformation/Reference/AdSupport_Framework/_index.html#//apple_ref/doc/uid/TP40012658), `ASIdentifierManager`'s modus operandi is clear: provide a way for ad networks to track users between different applications in a way that doesn't compromise privacy.

作为 [Ad Support framework](http://developer.apple.com/library/ios/#documentation/DeviceInformation/Reference/AdSupport_Framework/_index.html#//apple_ref/doc/uid/TP40012658) 仅有的组件, `ASIdentifierManager` 的作案手法很明确：提供一种方法让广告网络通过不同的应用程序跟踪用户行为，但又不触犯隐私。

Users can opt out of ad targeting in a Settings screen added in iOS 6.1, found at **Settings > General > About > Advertising**:

用户可以在 iOS 6.1 新加的设置页面来选择限制广告跟踪，位置在 **设置 > 通用 > 关于本机 > 广告** (在 iOS 9.2 上，这个设置的位置已经修改： 设置 > 隐私 > 广告 [译者注])：

![Limit Ad Tracking](http://nshipster.s3.amazonaws.com/ad-support-limit-ad-tracking.png)

## NSUUID & CFUUIDRef

`NSUUID` was added to Foundation in iOS 6 as a way to easily create UUIDs. How easy?

在 iOS 6 中被加到 Foundation 的 `NSUUID` 可以用来轻松地创建的 UUID。有多容易呢？

~~~{swift}
let UUID = NSUUID.UUID().UUIDString
~~~

~~~{objective-c}
NSString *UUID = [[NSUUID UUID] UUIDString];
~~~

If your app targets iOS 5 or earlier, however, you have to settle for Core Foundation functions on `CFUUIDRef`:

不过，如果你的应用针对 iOS 5 或更早的版本，你必须设置 Core Foundation 的 `CFUUIDRef`：

~~~{swift}
let UUID = CFUUIDCreateString(nil, CFUUIDCreate(nil))
~~~

~~~{objective-c}
CFUUIDRef uuid = CFUUIDCreate(NULL);
NSString *UUID = CFUUIDCreateString(NULL, uuid);
~~~

For apps building against a base SDK without the vendor or advertising identifier APIs, a similar effect can be achieved—as recommended in the deprecation notes—by using [`NSUserDefaults`](http://developer.apple.com/library/ios/#documentation/cocoa/reference/foundation/Classes/NSUserDefaults_Class/Reference/Reference.html):

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

This way, a UUID will be generated once when the app is launched for the first time, and then stored in `NSUserDefaults` to be retrieved on each subsequent app launch. Unlike advertising or vendor identifiers, these identifiers would not be shared across other apps, but for most intents and purposes, this is works just fine.

以此方式，一个 UUID 会在应用程序启动的第一时间被生成，然后存储在 `NSUserDefaults` 以便随后每次应用程序的启动所调用。不同于广告或运营商标识的是，这些标识不会同其他应用程序共享，但对于大多数的意图和目的来说，这已经足够达到目的了。

---

Of course, UUIDs have many other uses: primary identifiers for records in distributed systems, names for temporary files, or even a bulk color generator (chunk the hexadecimal representation into 5 groups of 6!). But on iOS, it's all about tracking, about finding what was lost in a sea of network traffic and possibilities. Knowing where you stand on uniqueness is the first step to understanding all of this.

当然，UUID 还有许多其他用途：用于记录在分布式系统的主标识符，临时文件的名称，或甚至是一个散色生成器（把十六进制串成每组 6 个，一共 5 组的表示方式！）。但在 iOS 上，它主要还是用于跟踪，用于发现在网络和可能性的汪洋中遗失了什么。理解你有多独特是了解一切的第一步。
