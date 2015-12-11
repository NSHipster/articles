---
title: "NSUUID /<br/>CFUUIDRef /<br/>UIDevice -uniqueIdentifier /<br/>-identifierForVendor"
author: Mattt Thompson
category: Cocoa
excerpt: "Until recently, it was trivial to uniquely identify devices between application launches, and even across applications: a simple call to UIDevice -uniqueIdentifier, and you were all set."
status:
    swift: 1.1
---

Let's say you're making privacy software that also prevents piracy. I mean, it's an obvious idea—[someone's going to do it](http://www.fakeblock.com). You're just trying to be _that_ person.

Until recently, it was trivial to uniquely identify devices between application launches, and even across applications: a simple call to `UIDevice -uniqueIdentifier`, and you were all set.

However, `UIDevice -uniqueIdentifier` was deprecated in iOS 5 with the following notes:

> Use the `identifierForVendor` property of [`UIDevice`] or the `advertisingIdentifier` property of the `ASIdentifierManager` class instead, as appropriate, or use the `UUID` method of the `NSUUID` class to create a `UUID` and write it to the user defaults database.

[As of May 1st](https://developer.apple.com/news/?id=3212013a), Apple began enforcing this deprecation on all new app submissions, even for apps targeting earlier versions of iOS. Any use of `uniqueIdentifier` is grounds for immediate rejection of new binaries.

Just as privacy and piracy have phonetic and conceptual similarities, device identifiers, whether UUID / GUID, UDID, or otherwise can be rather confusing:

- **UUID _(Universally Unique Identifier)_**: A sequence of 128 bits that can guarantee uniqueness across space and time, defined by [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).
- **GUID _(Globally Unique Identifier)_**: Microsoft's implementation of the UUID specification; often used interchangeably with UUID.
- **UDID _(Unique Device Identifier)_**: A sequence of 40 hexadecimal characters that uniquely identify an iOS device (the device's [Social Security Number](https://en.wikipedia.org/wiki/Social_Security_number), if you will). This value can be [retrieved through iTunes](http://whatsmyudid.com), or found using `UIDevice -uniqueIdentifier`. Derived from hardware details like [MAC address](http://en.wikipedia.org/wiki/MAC_address).

Incidentally, all of the suggested replacements for `UIDevice -uniqueIdentifier` listed in its deprecation notes return UUID, whether created automatically with `UIDevice -identifierForVendor` & `ASIdentifierManager -advertisingIdentifier` or manually with `NSUUID` (or `CFUUIDCreate`).

## Vendor Identifier

> The value of this property is the same for apps that come from the same vendor running on the same device. A different value is returned for apps on the same device that come from different vendors, and for apps on different devices regardless of vendor.

> The value in this property remains the same while the app (or another app from the same vendor) is installed on the iOS device. The value changes when the user deletes all of that vendor’s apps from the device and subsequently reinstalls one or more of them. Therefore, if your app stores the value of this property anywhere, you should gracefully handle situations where the identifier changes.

In many ways, this is what should have been used the whole time. App developers now have a way to identify devices uniquely—even across other apps by the same developer—without being entrusted with something as sensitive as the device's UDID.

For most applications, doing a find-and-replace of `uniqueIdentifier` to `identifierForVendor` is enough.

However, for advertising networks, which require a consistent identifier across applications from many developers, a different approach is required:

## Advertising Identifier

> iOS 6 introduces the Advertising Identifier, a non-permanent, non-personal, device identifier, that advertising networks will use to give you more control over advertisers’ ability to use tracking methods. If you choose to limit ad tracking, advertising networks using the Advertising Identifier may no longer gather information to serve you targeted ads. In the future all advertising networks will be required to use the Advertising Identifier. However, until advertising networks transition to using the Advertising Identifier you may still receive targeted ads from other networks.

As the sole component of the [Ad Support framework](http://developer.apple.com/library/ios/#documentation/DeviceInformation/Reference/AdSupport_Framework/_index.html#//apple_ref/doc/uid/TP40012658), `ASIdentifierManager`'s modus operandi is clear: provide a way for ad networks to track users between different applications in a way that doesn't compromise privacy.

Users can opt out of ad targeting in a Settings screen added in iOS 6.1, found at **Settings > General > About > Advertising**:

![Limit Ad Tracking]({{ site.asseturl }}/ad-support-limit-ad-tracking.png)

## NSUUID & CFUUIDRef

`NSUUID` was added to Foundation in iOS 6 as a way to easily create UUIDs. How easy?

~~~{swift}
let UUID = NSUUID.UUID().UUIDString
~~~

~~~{objective-c}
NSString *UUID = [[NSUUID UUID] UUIDString];
~~~

If your app targets iOS 5 or earlier, however, you have to settle for Core Foundation functions on `CFUUIDRef`:

~~~{swift}
let UUID = CFUUIDCreateString(nil, CFUUIDCreate(nil))
~~~

~~~{objective-c}
CFUUIDRef uuid = CFUUIDCreate(NULL);
NSString *UUID = CFUUIDCreateString(NULL, uuid);
~~~

For apps building against a base SDK without the vendor or advertising identifier APIs, a similar effect can be achieved—as recommended in the deprecation notes—by using [`NSUserDefaults`](http://developer.apple.com/library/ios/#documentation/cocoa/reference/foundation/Classes/NSUserDefaults_Class/Reference/Reference.html):

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

---

Of course, UUIDs have many other uses: primary identifiers for records in distributed systems, names for temporary files, or even a bulk color generator (chunk the hexadecimal representation into 5 groups of 6!). But on iOS, it's all about tracking, about finding what was lost in a sea of network traffic and possibilities. Knowing where you stand on uniqueness is the first step to understanding all of this.
