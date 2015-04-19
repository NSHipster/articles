---
title: UIApplicationDelegate launchOptions
author: Mattt Thompson
category: Cocoa
translator: Croath Liu
excerpt: "AppDelegate is the dumping ground for functionality in iOS."
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

An app can also be launched through URLs with additional system information. When an app is launched from an `UIDocumentInteractionController` or via AirDrop, the following keys are set in `launchOptions`:

> - `UIApplicationLaunchOptionsSourceApplicationKey`: Identifies the app that requested the launch of your app. The value of this key is an `NSString` object that represents the bundle ID of the app that made the request
> - `UIApplicationLaunchOptionsAnnotationKey`: Indicates that custom data was provided by the app that requested the opening of the URL. The value of this key is a property-list object containing the custom data.

~~~{objective-c}
NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Document" withExtension:@"pdf"];
if (fileURL) {
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    documentInteractionController.annotation = @{@"foo": @"bar"};
    [documentInteractionController setDelegate:self];
    [documentInteractionController presentPreviewAnimated:YES];
}
~~~

## Responding to Notification

Not to be confused with [`NSNotification`](http://nshipster.com/nsnotification-and-nsnotificationcenter/), apps can be sent remote or local notifications.

### Remote Notification

Introduced in iOS 3, remote, or "push" notifications are one of the defining features of the mobile platform.

To register for remote notifications, `registerForRemoteNotificationTypes:` is called in `application:didFinishLaunchingWithOptions:`.

~~~{objective-c}
[application registerForRemoteNotificationTypes:
	UIRemoteNotificationTypeBadge |
    UIRemoteNotificationTypeSound |
	UIRemoteNotificationTypeAlert];
~~~

...which, if successful, calls  `-application:didRegisterForRemoteNotificationsWithDeviceToken:`. Once the device has been successfully registered, it can receive push notifications at any time.

If an app receives a notification while in the foreground, its delegate will call `application:didReceiveRemoteNotification:`. However, if the app is launched, perhaps by swiping the alert in notification center, `application:didFinishLaunchingWithOptions:` is called with the  `UIApplicationLaunchOptionsRemoteNotificationKey` launch option:

> - `UIApplicationLaunchOptionsRemoteNotificationKey`: Indicates that a remote notification is available for the app to process. The value of this key is an `NSDictionary` containing the payload of the remote notification.
>> - `alert`: Either a string for the alert message or a dictionary with two keys: `body` and `show-view`.
>> - `badge`: A number indicating the quantity of data items to download from the provider. This number is to be displayed on the app icon. The absence of a badge property indicates that any number currently badging the icon should be removed.
>> - `sound`: The name of a sound file in the app bundle to play as an alert sound. If “default” is specified, the default sound should be played.

Since this introduces two separate code paths for notification handling, a common approach is to have `application:didFinishLaunchingWithOptions:` manually call `application:didReceiveRemoteNotification:`:

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

### Local Notification

[Local notifications](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1) were added in iOS 4, and to this day, are still surprisingly misunderstood.

Apps can schedule `UILocalNotification`s to trigger at some future time or interval. If the app is active in the foreground at that time, the app calls `-application:didReceiveLocalNotification:` on its delegate. However, if the app is not active, the notification will be posted to Notification Center.

Unlike remote notifications, `UIApplication` delegate provides a unified code path for handling local notifications. If an app is launched through a local notification, it calls `-application:didFinishLaunchingWithOptions:` followed by `-application:didReceiveLocalNotification:` (that is, there is no need to call it from `-application:didFinishLaunchingWithOptions:` like remote notifications).

A local notification populates the launch options on `UIApplicationLaunchOptionsLocalNotificationKey`, which contains a payload with the same structure as a remote notification:

- `UIApplicationLaunchOptionsLocalNotificationKey`: Indicates that a local notification is available for the app to process. The value of this key is an `NSDictionary` containing the payload of the local notification.

In the case where it is desirable to show an alert for a local notification delivered when the app is active in the foreground, and otherwise wouldn't provide a visual indication, here's how one might use the information from `UILocalNotification` to do it manually:

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

## Location Event

Building the next great geomobilelocalsocial check-in photo app? Well, you're about 4 years late to the party.

But fear not! With iOS region monitoring, your app can be launched on location events:

> - `UIApplicationLaunchOptionsLocationKey`: Indicates that the app was launched in response to an incoming location event. The value of this key is an `NSNumber` object containing a Boolean value. You should use the presence of this key as a signal to create a `CLLocationManager` object and start location services again. Location data is delivered only to the location manager delegate and not using this key.

Here's an example of how an app might go about monitoring for significant location change to determine launch behavior:

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

## Newsstand

_All of the Newsstand developers in the house: say "Yeah!"_

_`crickets.aiff`_

Well alright, then.

Newsstand can launch when newly-downloaded assets are available.

This is how you register:

~~~{objective-c}
[application registerForRemoteNotificationTypes:
	UIRemoteNotificationTypeNewsstandContentAvailability];
~~~

And this is the key to look out for in `launchOptions`:

> - `UIApplicationLaunchOptionsNewsstandDownloadsKey`: Indicates that newly downloaded Newsstand assets are available for your app. The value of this key is an array of string identifiers that identify the `NKAssetDownload` objects corresponding to the assets. Although you can use the identifiers for cross-checking purposes, you should obtain the definitive array of `NKAssetDownload` objects (representing asset downloads in progress or in error) through the downloadingAssets property of the `NKLibrary` object representing the Newsstand app’s library.

Not too much more to say about that.

## Bluetooth

iOS 7 introduced functionality that allows apps to be relaunched by Bluetooth peripherals.

If an app launches, instantiates a `CBCentralManager` or `CBPeripheralManager` with a particular identifier, and connects to other Bluetooth peripherals, the app can be re-launched by certain actions from the Bluetooth system. Depending on whether it was a central or peripheral manager that was notified, one of the following keys will be passed into `launchOptions`:

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
