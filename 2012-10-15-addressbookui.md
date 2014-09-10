---
layout: post
title: AddressBookUI
category: Cocoa
author: Mattt Thompson
translator: Henry Lee
excerpt: "Address Book UI是用来在用户地址簿展示、选择、编辑和创建联系人的iOS框架。与Message UI框架相似，Address Book UI包含了一些可以用dismissViewControllerAnimated:completion:方法来展示的试图控制器，它通过一些统一的接口提供常用的系统功能。"

---

[Address Book UI](http://developer.apple.com/library/ios/#documentation/AddressBookUI/Reference/AddressBookUI_Framework/_index.html)是用来在用户地址簿展示、选择、编辑和创建联系人的iOS框架。与[Message UI](http://developer.apple.com/library/ios/#documentation/MessageUI/Reference/MessageUI_Framework_Reference/_index.html)框架相似，Address Book UI包含了一些可以用dismissViewControllerAnimated:completion:方法来展示的试图控制器，它通过一些统一的接口提供常用的系统功能。

要用到这个框架，你需要添加`AddressBook.framework`和`AddressBookUI.framework`两个框架到你工程中build phase的"Link Binary With Libraries"之下。

乍一看你可能觉得Address Book UI没有什么特别的地方。

> 其实，在iOS 6里，`MFMailComposeViewController`和`ABNewPersonViewController`有一些_非常棒_的内部处理小伎俩在起着作用，Ole Begemann就有一篇[很棒的、非常值得读的关于远程视图控制器的文章](http://oleb.net/blog/2012/10/remote-view-controllers-in-ios-6/)。

抛开剩下的View Controller和协议，Address Book UI还有一个功能十分惊人地有用。

`ABCreateStringWithAddressDictionary()`函数返回一个已经本地化、结构化的地址字符串组。

关于这个函数第一个要讨论的问题是包含这些组成结构的字典，这个字典是由以下的常量作为键值的。

- `kABPersonAddressStreetKey`
- `kABPersonAddressCityKey`
- `kABPersonAddressStateKey`
- `kABPersonAddressZIPKey`
- `kABPersonAddressCountryKey`
- `kABPersonAddressCountryCodeKey`

`kABPersonAddressCountryCodeKey` 是一个尤其重要的属性，它决定了用来格式化地址字符串的语言。如果你对国家代码不是很确定或者没有确定的国家代码数据集，你可以通过`NSLocale`像这样来确定：

~~~{objective-c}
[mutableAddressComponents setValue:[[[NSLocale alloc] initWithIdentifier:@"en_US"] objectForKey:NSLocaleCountryCode] forKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
~~~

在其他任何框架里你都找不到实用性这么好的功能，这不需要用到[`NSLocale`](http://nshipster.com/nslocale/)，甚至也不需要Map Kit和Core Location来定位。苹果尽了如此多的努力来提高很多本地化的细节，而你会很惊奇这么一个重要的功能被放在了一个模糊不清、感觉上不怎么相关的一个框架里。

> 不过，电话簿UI在OS X里不提供，似乎这个平台也没有其他相同功能的内容。


你看，地址格式会因为地区的不同相差很大，例如，美国的地址是下面这个格式的：


    Street Address
    City State ZIP
    Country

而日本的地址的表示则有不同的习惯：

    Postal Code
    Prefecture Municipality
    Street Address
    Country


这个和不同地区有不同的[全角半角逗号](http://en.wikipedia.org/wiki/Decimal_mark#Hindu.E2.80.93Arabic_numeral_system)一样烦人，所以，你还是在展示结构化的地址的时候尽量多地用这些函数把。

> 还有一个很棒的利用已经本地化的地址簿的方式就是[FormatterKit](https://github.com/mattt/FormatterKit)，他在它的1.1版中添加了`TTTAddressFormatter`。

