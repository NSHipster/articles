---
layout: post
title: AddressBookUI

ref: "http://developer.apple.com/library/ios/#documentation/AddressBookUI/Reference/AddressBookUI_Framework/_index.html"
framework: AddressBookUI
rating: 6.2
published: true
translator: Henry Lee
description: "Address Book UI is an iOS framework for displaying, selecting, editing, and creating contacts in a user's Address Book. Similar to the Message UI framework, Address Book UI contains a number of controllers that can be presented modally, to provide common system functionality in a uniform interface."
description: "地址簿UI是用来在用户地址簿展示、选择、编辑和创建联系人的iOS框架。与消息UI框架想死，地址簿UI包含了一些可以用dismissViewControllerAnimated:completion:方法来展示的试图控制器，它通过一些统一的接口提供常用的系统功能。"

---

[Address Book UI](http://developer.apple.com/library/ios/#documentation/AddressBookUI/Reference/AddressBookUI_Framework/_index.html) is an iOS framework for displaying, selecting, editing, and creating contacts in a user's Address Book. Similar to the [Message UI](http://developer.apple.com/library/ios/#documentation/MessageUI/Reference/MessageUI_Framework_Reference/_index.html) framework, Address Book UI contains a number of controllers that can be presented modally, to provide common system functionality in a uniform interface.

[地址簿UI](http://developer.apple.com/library/ios/#documentation/AddressBookUI/Reference/AddressBookUI_Framework/_index.html)是用来在用户地址簿展示、选择、编辑和创建联系人的iOS框架。与[消息UI](http://developer.apple.com/library/ios/#documentation/MessageUI/Reference/MessageUI_Framework_Reference/_index.html)框架类似，地址簿UI包含了一些可以用dismissViewControllerAnimated:completion:方法来展示的试图控制器，它通过一些统一的接口提供常用的系统功能。

To use the framework, add both `AddressBook.framework` and `AddressBookUI.framework` to your project, under the "Link Binary With Libraries" build phase.

要用到这个框架，你需要添加`AddressBook.framework`和`AddressBookUI.framework`到你工程中build phase的"Link Binary With Libraries"之下。

At first glance, it would seem that there's nothing really remarkable about the Address Book UI framework.

初看你可能觉得地址簿UI没有什么特别的地方。

> Actually, in iOS 6, there are some _fascinating_ inter-process shenanigans going on behind the scenes with 	 like `MFMailComposeViewController` and `ABNewPersonViewController`. Ole Begemann has an [excellent write-up on Remote View Controllers in iOS 6](http://oleb.net/blog/2012/10/remote-view-controllers-in-ios-6/) that's definitely worth a read.

> 其实，在iOS 6里，`MFMailComposeViewController`和`ABNewPersonViewController`有一些_非常棒_的内部处理小伎俩在起着作用，Ole Begemann就有一篇[很棒的、非常值得读的关于远程视图控制器的文章](http://oleb.net/blog/2012/10/remote-view-controllers-in-ios-6/)。


However, tucked away from the rest of the controllers and protocols, there's a single Address Book UI function that's astoundingly useful:

抛开剩下的视图控制器和协议，仍有一个地址簿UI的功能还惊人地有用。

`ABCreateStringWithAddressDictionary()` - Returns a localized, formatted address string from components.



The first argument for the function is a dictionary containing the address components, keyed by string constants:

- `kABPersonAddressStreetKey`
- `kABPersonAddressCityKey`
- `kABPersonAddressStateKey`
- `kABPersonAddressZIPKey`
- `kABPersonAddressCountryKey`
- `kABPersonAddressCountryCodeKey`

`kABPersonAddressCountryCodeKey` is an especially important attribute, as it determines which locale used to format the address string. If you are unsure of the country code, or one isn't provided with your particular data set, `NSLocale` may be able to help you out: 

~~~{objective-c}
[mutableAddressComponents setValue:[[[NSLocale alloc] initWithIdentifier:@"en_US"] objectForKey:NSLocaleCountryCode] forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
~~~

The second argument is a boolean flag, `addCountryName`. When `YES`, the name of the country corresponding to the specified country code will be automatically appended to the address. This should only used when the country code is known.

Nowhere else in all of the other frameworks is this functionality provided. It's not part of [`NSLocale`](http://nshipster.com/nslocale/), or even Map Kit or Core Location. For all of the care and attention to detail that Apple puts into localization, it's surprising that such an important task is relegated to the corners of an obscure, somewhat-unrelated framework.

> Unfortunately, Address Book UI is not available in Mac OS X, and it would appear that there's no equivalent function provided on this platform.

For you see, address formats vary greatly across different regions. For example, addresses in the United States take the form:

    Street Address
    City State ZIP
    Country

Whereas addresses in Japan follow a different convention:

    Postal Code
    Prefecture Municipality
    Street Address
    Country

This is at least as jarring a difference in localization as [swapping periods for commas the radix point](http://en.wikipedia.org/wiki/Decimal_mark#Hindu.E2.80.93Arabic_numeral_system), so make sure to use this function anytime you're displaying an address from its components.

> One great way to take advantage of localized address book formatting would be to check out [FormatterKit](https://github.com/mattt/FormatterKit), which added `TTTAddressFormatter` in its 1.1 release.
