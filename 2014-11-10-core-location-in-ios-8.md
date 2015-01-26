---
layout: post
title: Core Location in iOS 8
author: Mike Lazer-Walker
category: Cocoa
translator: April Peng
excerpt: "自从 iPhone 存在以来，位置服务就一直处于非常重要的位置。iOS 8 给 Core Location 带来了三个主要更新：更分化的权限，室内定位以及访问监控。"
---

自从 iPhone 存在以来，位置服务就一直处于非常重要的位置。Maps.app 是第一代 iPhone 里杀手锏的功能之一。Core Location API 也在 iPhone OS SDK 最初的公开版本里就存在了。每一次发布 iOS，Apple 都会给这个库逐步添加新功能，比如后台运行的位置服务，坐标化，以及室内定位（ iBeacons ）。

iOS 8 仍然继续坚定的延续着这个进程。跟其他最新的更新类似，Core Location 被改动了不少，不管是允许开发者做之前并不被允许的开发，还是帮助维护用户隐私。更特别的是，iOS 8 给 Core Location 带来了三个主要的改进：更分化的权限，室内定位以及访问监控。

## 权限

一个 app 总有各种各样的理由需要得到你的位置信息。一个能够提示你每个转弯在哪里的 GPS 应用就需要持续获得你的位置信息，才可以在转弯的时候提示你。一个餐厅推荐的 app 也需要得到你的位置信息（即便它并没有打开的情况下），才可以在你到你朋友点赞的餐厅附近的时候能收到推送消息。一个 Twitter 应用在发推的时候也可能需要你的位置，但在你不使用的时候不应该监控你的位置。

在 iOS 8 之前，位置服务的权限是二元的：你要么赋予一个应用得到使用位置服务的权限，要么不给。你可以在 Settings.app 查看哪些 app 可以在后台取得你的位置信息，但除了完全不让这个 app 使用位置服务之外，你不能做任何的事来阻止它获取位置信息。

iOS 8 修改了这个问题，它把位置服务权限拆分成了 2 个不同的授权。

- “使用期间” 的授权会只允许应用在 - 就跟你猜测的一样 - 使用期间取得你的位置信息。

- “始终” 的授权则跟之前版本的 iOS 那样，会给应用后台权限。

这是对用户隐私的一个重大改进，但对于我们开发者来说则意味着多一些的工作。

### 取得权限

在早前的 iOS 版本中，获取位置服务权限是隐式的。比如 `CLLocationManager`，如果应用程序还没有被许可或者之前被拒绝了的话，下面的代码会触发系统弹出提示框向用户获取位置服务的授权：

```swift
import Foundation
import CoreLocation

let manager = CLLocationManager()
if CLLocationManager.locationServicesEnabled() {
    manager.startUpdatingLocation()
}
```

> 把事情简化一下，假定我们声明了一个 `manager` 实例作为所有例子的成员变量，它的 delegate 是它的 owner。

让 `CLLocationManager` 取得最新的位置的这个操作会让系统弹出是否允许位置服务的提示。

在 iOS 8，取得权限和使用位置服务已经分成两个动作了。分别用两个不同的方法取得权限：`requestWhenInUseAuthorization` 和 `requestAlwaysAuthorization`。前者只能让应用在使用的时候有权获取位置数据；后者会得到跟之前 iOS 一样的后台位置服务。

```swift
if CLLocationManager.authorizationStatus() == .NotDetermined {
    manager.requestAlwaysAuthorization()
}
```

或者

```swift
if CLLocationManager.authorizationStatus() == .NotDetermined {
    manager.requestWhenInUseAuthorization()
}
```

因为这是异步的，应用不能立即开始使用位置服务。取而代之的是，应用必须实现 `locationManager:didChangeAuthorizationStatus` 的 delegate 方法，这个方法会在用户改变权限状态的时候调用。

如果用户之前已经授权了位置服务，那么在每次位置管理器被初始化，并且 delegate 被设置了相应的权限状态的情况下这个代理方法仍然会被调用。这使得一个单一的代码路径使用定位服务更为方便。

```swift
func locationManager(manager: CLLocationManager!,
                     didChangeAuthorizationStatus status: CLAuthorizationStatus)
{
    if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
        manager.startUpdatingLocation()
        // ...
    }
}
```

### 描述字符串

想在 iOS 8 中使用定位，另一个改变是必须的。在这之前，应用可以选择性的在 `Info.plist` 中包含 'NSLocationUsageDescription' 的关键字。这个值是一个纯文本的字符串，向用户说明了应用预期要使用位置服务。现在这个值被拆分成了两个不同的关键字（`NSLocationWhenInUseUsageDescription` 和 `NSLocationAlwaysUsageDescription`），而且是必填的；如果你不添加对应的关键字就去调用 `requestWhenInUseAuthorization` 或 `requestAlwaysAuthorization`，那么将不会有任何的弹出提示给用户。

![Core Location Always Authorization](http://nshipster.s3.amazonaws.com/core-location-always-authorization.png)

![Core Location When In Use Authorization](http://nshipster.s3.amazonaws.com/core-location-when-in-use-authorization.png)

### 获取多个权限

另一个值得注意的细节是授权的弹出框会只显示一次。在 `CLLocationManager.authorizationStatus()` 返回除 `NotDetermined` 之外的值之后，不管调用 `requestWhenInUseAuthorization()` 或 `requestAlwaysAuthorization()` 都不会有一个 `UIAlertController` 显示出来了。在用户最初的选择之后，唯一改变授权的方式是到 Settings.app 或者到隐私设置，又或者是应用自己的设置页面。

旧的授权机制各种不方便的情况下，现在让应用在它的生存周期内询问不论是“使用期间”还是“始终”的权限的机制明显复杂多了，更不方便了。为了缓解这一点，Apple 引入了一个字符串常量，`UIApplicationOpenSettingsURLString`，它存储了一个 URL 用来打开当前应用在 Settings.app 对应的页面。

下面的例子显示了如何在应用里弹出两种类型的权限获取窗口，如果你的应用打算获取始终的权限的话，可以参考一下。

```swift
switch CLLocationManager.authorizationStatus() {
    case .Authorized:
        // ...
    case .NotDetermined:
        manager.requestWhenAlwaysAuthorization()
    case .AuthorizedWhenInUse, .Restricted, .Denied:
        let alertController = UIAlertController(
            title: "Background Location Access Disabled",
            message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'Always'.",
            preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)

        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)

        self.presentViewController(alertController, animated: true, completion: nil)
}
```

![Core Location Settings Alert](http://nshipster.s3.amazonaws.com/core-location-settings-alert.png)

![Core Location Settings Location Never](http://nshipster.s3.amazonaws.com/core-location-settings-1.png)

![Core Location Settings Location Always](http://nshipster.s3.amazonaws.com/core-location-settings-2.png)

### 向后兼容

所有这些新的 API 都只支持 iOS 8。对于要支持 iOS 7 或之前 iOS 版本的应用，则必须维护两部分代码，一个是为 iOS 8 获取权限的，同时还需要维护之前的获取位置更新的方法。一个简单的实现会看上去像下面这样：

```swift
func triggerLocationServices() {
    if CLLocationManager.locationServicesEnabled() {
        if self.manager.respondsToSelector("requestWhenInUseAuthorization") {
            manager.requestWhenInUseAuthorization()
        } else {
            startUpdatingLocation()
        }
    }
}

func startUpdatingLocation() {
    manager.startUpdatingLocation()
}

// MARK: - CLLocationManagerDelegate

func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .AuthorizedWhenInUse || status == .Authorized {
        startUpdatingLocation()
    }
}
```

### 建立用户的信任

现在在 iOS 8 上有一个共同的变化趋势是：它们更容易得到用户的信任。

显式的请求的授权，鼓励应用程序在用户试图做一些事情之前不请求授权。这包括了用使用说明来很清晰的解释为什么你需要的访问位置信息，以及应用程序将如何使用它。“使用期间” 和 “始终” 的区别授权，使用户感到轻松，因为应用只得到了需要的数据。

当然，这些新的 API 并不能阻止应用做跟之前一样的事。所有应用 “需要” 针对支持 iOS 8 的事只是添加对 `useAlwaysAuthorization` 的调用，以及添加一个全局适用的字符串。但随着这些新的变化， Apple 正在传达一个重要的信息，那就是你应该尊重你的用户。一旦用户习惯了像这样尊重用户隐私的应用程序，不难想象的是，不负责任地使用定位服务 的应用会在 App Store 得到更多负面的评分。

## 室内定位追踪

如果一个人仔细阅读了 `CoreLocation.framework` 的 API 改动文件，会发现最令人费解的改动之一是引进了 `CLFloor`，一个新的只有相当简单的接口对象：

```swift
class CLFloor : NSObject {
    var level: Int { get }
}
```

```objective-c
@interface CLFLoor : NSObject
@property(readonly, nonatomic) NSInteger level
@end
```

就是这样。仅一个属性，一个整形值来表示当前位置处于建筑物的第几层楼。

> 欧洲人肯定会很高兴的发现一楼是用 '1' 表示的, 而不是 '0'。

由 `CLLocationManager` 返回的 `CLLocation` 对象可能包括一个 `floor` 属性，但如果你是写一个使用定位服务的示例应用程序，你会发现 `CLLocation` 对象的 `floor` 属性总是 `nil`。

这是因为该API的变化只是 iOS8 中引入的室内定位跟踪这个大功能的冰山一角。对于大型空间的应用开发，例如艺术博物馆或百货公司这种， Apple 现在已经有结合了无线，GPS，蜂窝，和 室内定位数据的内置 Core Location API 支持 <abbr title="Indoor Positioning Systems">IPS</abbr> 。

也就是说，这个新功能的信息令人吃惊的来之不易。该项目目前被很好的严格限制访问了，仅允许已通过从 [Apple Maps Connect](https://mapsconnect.apple.com) 申请的程序。关于该项目的的有限信息是在[今年的WWDC(Session 708: Taking Core Location Indoors)](http://asciiwwdc.com/2014/sessions/708)被初露头角的，但大部分的后台细节都被隐藏在被关上的门之后了。对于大多数的我们来说，别无选择的，只能打消没有用的好奇心。

## CLVisit

很多应用程序，使用位置监控的原因是确定用户是否在某个确定的地方。概念上讲，你在想的是诸如“地方”或“访问”的名词术语，而不是原始的 GPS 坐标。

然而，除非你可以得益于使用区域监视（被限制在一个相对小的数量的区域）或室内定位（ iBeacon ）测距（这要求把室内定位硬件真正安装在一个空间内），否则用 Core Location 的后台监控工具并不是非常适合。开发一个登记应用或像 [Moves](https://moves-app.com) 这样的全面的日志应用，位置监控和花费很多时间做特定处理一般意味着消耗大量的电量。

在 iOS 8  里， Apple 曾试图通过引进 `CLVisit` 来解决这个问题， 这是一种新型的后台位置的监控。一个 `CLVisit` 表示该用户已经处于某个位置的时间长度，包括一个坐标和开始/结束的时间戳。

理论上讲，使用访问监控并不比任何其他后台定位跟踪做更多的事。简单地调用 `manager.startMonitoringVisits()` 将启用后台访问跟踪，假设用户同意授权你的应用程序“始终”的使用权限。一旦启动，你的应用程序将在有位置更新的时候在后台被唤醒，不像基本的定位监控，如果系统有个访问更新的队列（通常可以使更新延迟），你的 delegate 方法将被调用多次，每个单一的访问调用一次，而不是一个包含 CLLocation 对象的数组调用 `locationManager:didReceiveUpdates:`。调用 `manager.stopMonitoringVisits()` 会停止跟踪。

###  处理访问

每个 `CLVisit` 对象包含了一些基本属性：平均坐标，水平精度和到达日期和离开时间。

每次一个访问被追踪到，`CLLocationManagerDelegate` 可能会被告知两次：一次是在用户刚抵达一个新的地方的时候，以及当用户离开的时候。你可以通过检查 `departureDate` 属性来分辨它们; `NSDate.distantFuture()` 的离开时间意味着用户还在那儿。

```swift
func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
    if visit.departureDate.isEqualToDate(NSDate.distantFuture()) {
        // User has arrived, but not left, the location
    } else {
        // The visit is complete
    }
}
```

### 实现须知

至少到 iOS 8.1，CLVisit 还不是那么精确。开始和结束时间一般有一两分钟的误差，是否访问某个地方的线路边际有点模糊。在咖啡店的角落躲一分钟可能不会触发访问，但在等一个特别长的红绿灯的时候却有可能触发。很可能 Apple 将在操作系统的后续升级的时候提升访问检测的质量，但现在如果你的应用程序对访问检测的精度要求很高的话，你最好不要依赖 `CLVisit`。
