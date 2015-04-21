---
title: UIApplicationDelegate launchOptions
author: Mattt Thompson
category: Cocoa
translator: Croath Liu
excerpt: "AppDelegate 是 iOS 各种功能的集散中心。"
---

AppDelegate 是 iOS 各种功能的集散中心。

应用生命周期管理？URL 路由？通知？Core Data 咒语？各种三方 SDK 的初始化？一些似乎放在哪里都不合适的零散功能？统统丢进 `AppDelegate.m` 里吧！

对于很多开发者来说 `launchOptions` 参数就是类似于 Java 的 `main` 函数中 `String[] args` 的作用 —— 在构建应用时候一般是被忽略的。在其平淡的外表下，`launchOptions` 其实隐藏 iOS 应用启动时携带的大量核心信息。

NSHipster 本周披露的知识点是关于我们平时关心最少的、但又是 UIKit 中最重要的东西：`launchOptions`。

* * *

每个应用都使用 `UIApplicationDelegate -application:didFinishLaunchingWithOptions:`（更精确地说以后或许也包含 `-application:willFinishLaunchingWithOptions:`） 启动。应用调用这个方法来告诉 delegate 进程已经启动完毕，已经准备好运行了。

在 [Springboard](http://en.wikipedia.org/wiki/SpringBoard) 中点击图标应用就开始启动了，但也有其他一些启动的方法。比如说注册了自定义 URL scheme 的应用可以以类似于 `twitter://` 的方式从一个 URL 启动。应用可以通过推送通知或地理位置变更启动。

查明应用为什么以及是如何启动的，就是 `launchOptions` 参数的职责所在。就像 `userInfo` 字典一样，在 `-application:didFinishLaunchingWithOptions:` 的 `launchOptions` 中也包含很多特别命名的键。

> 这些键中的许多在应用启动时发出的 `UIApplicationDidFinishLaunchingNotification` 的通知中也可用，详细内容请查阅文档。

`launchOptions` 包含的键太多了，按照应用启动原因分组理解起来更容易一点：

## 从 URL 打开

其他应用通过传递 URL 可以打开一个应用：

~~~{objective-c}
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"app://..."]];
~~~

例如：`http://` 开头的 URL 会在 Safari 中打开，`mailto://` 开头的 URL 会在邮件中打开，`tel://` 开头的 URL 会在电话中打开。

这些情况下 `UIApplicationLaunchOptionsURLKey` 键就会很常用了。

> - `UIApplicationLaunchOptionsURLKey`: 标示应用是通过 URL 大家的。其对应的值代表应用被打开时使用的 `NSURL` 对象。

应用也可以通过 URL 和附加系统信息打开。当应用从 AirDrop 的 `UIDocumentInteractionController` 中打开时，`launchOptions` 会包含下列这键：

> - `UIApplicationLaunchOptionsSourceApplicationKey`：请求打开应用的应用 id。对应的值是请求打开应用的 bundle ID 的 `NSString` 对象
> - `UIApplicationLaunchOptionsAnnotationKey`：标示通过 URL 打开应用时携带了自定义数据。对应的值是包含自定义数据的属性列表对象

~~~{objective-c}
NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Document" withExtension:@"pdf"];
if (fileURL) {
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    documentInteractionController.annotation = @{@"foo": @"bar"};
    [documentInteractionController setDelegate:self];
    [documentInteractionController presentPreviewAnimated:YES];
}
~~~

## 响应通知

不要和 [`NSNotification`](http://nshipster.com/nsnotification-and-nsnotificationcenter/) 混淆了，应用可以通过本地（local）或远程（remote）通知打开。

### Remote Notification

自 iOS 3 开始引入的 remote（或者叫 push）notification 是在移动平台上的重要特性。

在 `application:didFinishLaunchingWithOptions:` 中调用 `registerForRemoteNotificationTypes:` 来注册推送通知。

~~~{objective-c}
[application registerForRemoteNotificationTypes:
	UIRemoteNotificationTypeBadge |
    UIRemoteNotificationTypeSound |
	UIRemoteNotificationTypeAlert];
~~~

如果调用成功则会回调 `-application:didRegisterForRemoteNotificationsWithDeviceToken:`，之后该设备就能随时收到推送通知了。

如果应用在打开时收到了推送通知，delegate 会调用 `application:didReceiveRemoteNotification:`。但是如果是通过在通知中心中滑动通知打开的应用，则会调用 `application:didFinishLaunchingWithOptions:` 并携带 `UIApplicationLaunchOptionsRemoteNotificationKey` 启动参数：

> - `UIApplicationLaunchOptionsRemoteNotificationKey`：标示推送通知目前处于可用状态。对应的值是包含通知内容的 `NSDictionary`。
>> - `alert`：一个字符串或包含两个键 `body` 和 `show-view` 的字典。
>> - `badge`：标示从通知发出者那应该获取数据的数量。这个数字会显示在应用图标上。没有 badge 信息则表示应该从图片上移除数字显示。
>> - `sound`：通知接收时播放音频的文件名。如果值为 "default" 那么则播放默认音频。

因为通知可以通过两种方式控制，通常的做法是在 `application:didFinishLaunchingWithOptions:` 中手动调用 `application:didReceiveRemoteNotification:`：

~~~{objective-c}
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ...

    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
}
~~~

### 本地通知

[本地通知](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1) 是在 iOS 4 中加入的功能，这个功能至今都被误解了。

应用可以制定计划在未来某个时间点触发 `UILocalNotification`。如果应用处于打开状态，那么将回调 `-application:didReceiveLocalNotification:` 方法。如果应用处于非活跃状态，通知将会被发送到通知中心。

不像推送通知，`UIApplication` 的 delegate 提供了统一控制本地通知的方法。如果应用是通过本地通知启动的，`-application:didReceiveLocalNotification:` 将会在 `-application:didFinishLaunchingWithOptions:` 之后被自动调用（意思就是不需要像推送通知一样在 `-application:didFinishLaunchingWithOptions:` 中手动调用了）。

本地通知会在启动参数中携带和推送通知有类似结构的 `UIApplicationLaunchOptionsLocalNotificationKey`：

- `UIApplicationLaunchOptionsLocalNotificationKey`: 标示本地通知目前处于可用状态。对应的值是包含通知内容的 `NSDictionary`。

如果应用在运行中时收到本地通知需要显示提示框、其他情况不显示提示框，可以手动从 `UILocalNotification` 获取相关信息进行操作：

~~~{objective-c}
// .h
@import AVFoundation;

@interface AppDelegate ()
@property (readwrite, nonatomic, assign) SystemSoundID localNotificationSound;
@end

// .m
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:notification.alertAction
                                       message:notification.alertBody
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                             otherButtonTitles:nil];

        if (!self.localNotificationSound) {
            NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"Sosumi"
                                                      withExtension:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_localNotificationSound);
        }
        AudioServicesPlaySystemSound(self.localNotificationSound);

        [alertView show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if (self.localNotificationSound) {
        AudioServicesDisposeSystemSoundID(self.localNotificationSound);
    }
}
~~~

## 地理位置事件

听说你在开发一个 LBS 签到照片的应用？哈哈，看起来你的动作好像落后时代四年多了。

但不要害怕！有了 iOS 的位置监控，你的应用可以通过地理位置触发的事件启动了：

> - `UIApplicationLaunchOptionsLocationKey`：标示应用是响应地理位置事件启动的。对应的值是包含 Boolean 值的 `NSNumber` 对象。可以把这个键作为信号来创建 `CLLocationManager` 对象并开始进行定位。位置数据会传给 location manager 的 delegate（并不需要这个键）。

以下是检测位置变化来判断启动行为的例子：

~~~{objective-c}
// .h
@import CoreLocation;

@interface AppDelegate () <CLLocationManagerDelegate>
@property (readwrite, nonatomic, strong) CLLocationManager *locationManager;
@end

// .m
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ...

    if (![CLLocationManager locationServicesEnabled]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Services Disabled", nil)
                                    message:NSLocalizedString(@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled.", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    } else {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }

    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        [self.locationManager startUpdatingLocation];
    }
}
~~~

## 报刊杂志（Newsstand）

_所有的报刊杂志开发者都会为此欢呼的！_

_`欢呼声.aiff`_

够了...

有新的可用下载时，报刊杂志应用可以启动。

这样注册即可：

~~~{objective-c}
[application registerForRemoteNotificationTypes:
	UIRemoteNotificationTypeNewsstandContentAvailability];
~~~

然后在启动参数中找到这个键：

> - `UIApplicationLaunchOptionsNewsstandDownloadsKey`：标示应用有新的可用杂志资源下载。对应的值是包含 `NKAssetDownload` id 的字符串数组。虽然你可以通过这些 id 进行检查，但还是应该通过 `NKLibrary` 对象的 downloadingAssets 属性来持有这些 `NKAssetDownload` 对象（可用用于展示下载进度或错误）以便显示在报刊杂志书架中。

详细情况不再赘述。

## 蓝牙

iOS 7 开始支持外围蓝牙设备重唤醒应用。

应用启动后通过特定的 id 实例化一个 `CBCentralManager` 或 `CBPeripheralManager` 用于连接蓝牙设备，之后应用就可以通过蓝牙系统的相关动作来被重新唤醒了。取决于发出通知的是一个中心设备还是外围设备，`launchOptions` 会传入以下两个键中的一个：

> - `UIApplicationLaunchOptionsBluetoothCentralsKey`: Indicates that the app previously had one or more `CBCentralManager` objects and was relaunched by the Bluetooth system to continue actions associated with those objects. The value of this key is an `NSArray` object containing one or more `NSString` objects. Each string in the array represents the restoration identifier for a central manager object.
> - `UIApplicationLaunchOptionsBluetoothPeripheralsKey`:  Indicates that the app previously had one or more `CBPeripheralManager` objects and was relaunched by the Bluetooth system to continue actions associated with those objects. The value of this key is an `NSArray` object containing one or more `NSString` objects. Each string in the array represents the restoration identifier for a peripheral manager object.

~~~{objective-c}
// .h
@import CoreBluetooth;

@interface AppDelegate () <CBCentralManagerDelegate>
@property (readwrite, nonatomic, strong) CBCentralManager *centralManager;
@end

// .m
self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionRestoreIdentifierKey:(launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey] ?: [[NSUUID UUID] UUIDString])}];

if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
    static NSString * const UID = @"7C13BAA0-A5D4-4624-9397-15BF67161B1C"; // generated with `$ uuidgen`
    NSArray *services = @[[CBUUID UUIDWithString:UID]];
    NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [self.centralManager scanForPeripheralsWithServices:services options:scanOptions];
}
~~~

* * *

Keeping track of all of the various ways and means of application launching can be exhausting. So it's fortunate that any given app will probably only have to handle one or two of these possibilities.

Knowing what's possible is often what it takes to launch an app from concept to implementation, so bear in mind all of your options when the next great idea springs to mind.
