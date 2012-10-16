---
layout: post
title: AddressBookUI

ref: "http://developer.apple.com/library/ios/#documentation/AddressBookUI/Reference/AddressBookUI_Framework/_index.html"
framework: AddressBookUI
rating: 6.2
published: true
description: "Address Book UI is an iOS framework for displaying, selecting, editing, and creating contacts in a user's Address Book. Similar to the Message UI framework, Address Book UI contains a number of controllers that can be presented modally, to provide common system functionality in a uniform interface."
---

[Address Book UI](http://developer.apple.com/library/ios/#documentation/AddressBookUI/Reference/AddressBookUI_Framework/_index.html) is an iOS framework for displaying, selecting, editing, and creating contacts in a user's Address Book. Similar to the [Message UI](http://developer.apple.com/library/ios/#documentation/MessageUI/Reference/MessageUI_Framework_Reference/_index.html) framework, Address Book UI contains a number of controllers that can be presented modally, to provide common system functionality in a uniform interface.

To use the framework, add both `AddressBook.framework` and `AddressBookUI.framework` to your project, under the "Link Binary With Libraries" build phase.

At first glance, it would seem that there's nothing really remarkable about the Address Book UI framework.

> Actually, in iOS 6, there are some _fascinating_ inter-process shenanigans going on behind the scenes with modal controllers like `MFMailComposeViewController` and `ABNewPersonViewController`. Ole Begemann has an [excellent write-up on Remote View Controllers in iOS 6](http://oleb.net/blog/2012/10/remote-view-controllers-in-ios-6/) that's definitely worth a read.

However, tucked away from the rest of the controllers and protocols, there's a single Address Book UI function that's astoundingly useful:

`ABCreateStringWithAddressDictionary()` - Returns a localized, formatted address string from components.

The first argument for the function is a dictionary containing the address components, keyed by string constants:

- `kABPersonAddressStreetKey`
- `kABPersonAddressCityKey`
- `kABPersonAddressStateKey`
- `kABPersonAddressZIPKey`
- `kABPersonAddressCountryKey`
- `kABPersonAddressCountryCodeKey`

`kABPersonAddressCountryCodeKey` is an especially important attribute, as it determines which locale used to format the address string. If you are unsure of the country code, or one isn't provided with your particular data set, `NSLocale` may be able to help you out: 

    [mutableAddressComponents setValue:[[[NSLocale alloc] initWithIdentifier:@"en_US"] objectForKey:NSLocaleCountryCode] forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];

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
