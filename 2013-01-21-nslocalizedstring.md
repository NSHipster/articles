---
title: NSLocalizedString
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Strings are perhaps the most versatile data type in computing. They're passed around as symbols, used to encode numeric values, associate values to keys, represent resource paths, store linguistic content, and format information. Having a strong handle on user-facing strings is essential to making a great user experience."
translator: April Peng
excerpt: "字符串也许是计算最通用的数据类型。他们以符号的方式传来传去，用来为数值编码，键值关联，代表资源路径，存储语言内容和格式的信息。对面向用户的字符串具有强有力的控制是营造良好的用户体验必不可少的能力。"
---

Strings are perhaps the most versatile data type in computing. They're passed around as symbols, used to encode numeric values, associate values to keys, represent resource paths, store linguistic content, and format information. Having a strong handle on user-facing strings is essential to making a great user experience.

字符串也许是计算最通用的数据类型。他们以符号的方式传来传去，用来为数值编码，键值关联，代表资源路径，存储语言内容和格式的信息。对面向用户的字符串具有强有力的控制是营造良好的用户体验必不可少的能力。

In Foundation, there is a convenient macro for denoting strings as user-facing: `NSLocalizedString`.

在 Foundation 中，有一个方便的宏表示作为面向用户的字符串：`NSLocalizedString`。

`NSLocalizedString` provides string localization in "compile-once / run everywhere" fashion, replacing all localized strings with their respective translation according to the string tables of the user settings. But even if you're not going to localize your app to any other markets, `NSLocalizedString` does wonders with respect to copy writing & editing.

`NSLocalizedString` 提供本地化字符串的 “一次编译 / 随处运行” 的方式，根据用户设置的字符串表把所有本地化字符串替换成对应的翻译。但是，即使你不打算把你的应用程序本地化到任何其他市场，`NSLocalizedString` 在拷贝与编辑上仍然有神器的作用。

> For more information about Localization (l10n) and Internationalization (i18n) [see the NSHipster article about NSLocale](http://nshipster.com/nslocale/).

>有关本地化（l10n）和国际化（i18n）的更多信息[请查看 NSHipster 有关 NSLocale 的文章](http://nshipster.cn/nslocale/)。

---

`NSLocalizedString` is a Foundation macro that returns a localized version of a string. It has two arguments: `key`, which uniquely identifies the string to be localized, and `comment`, a string that is used to provide sufficient context for accurate translation.

`NSLocalizedString` 是一个 Foundation 的宏定义，返回一个字符串的本地化版本。它有两个参数：`key`：进行本地化的唯一字符串标识，和 `comment`：用于提供用来准确翻译的足够的上下文的字符串。

In practice, the `key` is often just the base translation string to be used, while `comment` is usually `nil`, unless there is an ambiguous context:

在实践中，`key` 往往只是用来翻译的基准字符串，而 `comment` 通常是 `nil`，除非有一个模糊的上下文：

~~~{objective-c}
textField.placeholder = NSLocalizedString(@"Username", nil);
~~~

`NSLocalizedString` can also be used as a format string in `NSString +stringWithFormat:`. In these cases, it's important to use the `comment` argument to provide enough context to be properly translated.

`NSLocalizedString` 也可以在 `NSString +stringWithFormat:` 中用来作为格式化字符串。在这种情况下，使用 `comment` 参数来提供达到正确翻译足够的上下文是很重要的。

~~~{objective-c}
self.title = [NSString stringWithFormat:NSLocalizedString(@"%@'s Profile", @"{User First Name}'s Profile"), user.name];

label.text = [NSString stringWithFormat:NSLocalizedString(@"Showing %lu of %lu items", @"Showing {number} of {total number} items"), [page count], [items count]];
~~~

## `NSLocalizedString` & Co.

There are four varieties of `NSLocalizedString`, with increasing levels of control (and obscurity):

随着控制（和模糊）程度的增加，有四个种类的 `NSLocalizedString`：

~~~{objective-c}
NSString * NSLocalizedString(
  NSString *key,
  NSString *comment
)

NSString * NSLocalizedStringFromTable(
  NSString *key,
  NSString *tableName,
  NSString *comment
)

NSString * NSLocalizedStringFromTableInBundle(
  NSString *key,
  NSString *tableName,
  NSBundle *bundle,
  NSString *comment
)

NSString * NSLocalizedStringWithDefaultValue(
  NSString *key,
  NSString *tableName,
  NSBundle *bundle,
  NSString *value,
  NSString *comment
)
~~~

99% of the time, `NSLocalizedString` will suffice. If you're working in a library or shared component, `NSLocalizedStringFromTable` should be used instead.

99％ 的情况下，`NSLocalizedString` 就足够了。如果你实现的是一个库或共享组件，应该使用 `NSLocalizedStringFromTable`。

## Localizable.strings

At runtime, `NSLocalizedString` determines the preferred language, and finds a corresponding `Localizable.strings` file in the app bundle. For example, if the user prefers French, the file `fr.lproj/Localizable.strings` will be consulted.

在运行时，`NSLocalizedString` 会确定首选的语言，并在应用程序包中找到相应的 `Localizable.strings` 文件。例如，如果用户首选法语，文件 `fr.lproj/Localizable.strings` 将来用作参考。

Here's what that looks like:

就是下面这个样子：

~~~
/* No comment provided by engineer. */
"Username"="nom d'utilisateur";
/* {User First Name}'s Profile */
"%@'s Profile"="profil de %1$@";
~~~

`Localizable.strings` files are initially generated with `genstrings`.

`Localizable.strings` 文件最初将由 `genstrings` 产生。

>  The `genstrings` utility generates a .strings file(s) from the C or Objective-C (.c or .m) source code file(s) given as the argument(s).  A .strings file is used for localizing an application for different languages, as described under "Internationalization" in the Cocoa Developer Documentation.

> `genstrings` 程序用给定的参数从 C 或 Objective-C（.c 或 .m）的源代码文件生成一个 .strings 文件。一个 .strings 文件用于为应用程序的不同语言作本地化，正如 Cocoa 开发者文档下的 “Internationalization” 描述的那样。

`genstrings` goes through each of the selected source files, and for each use of `NSLocalizedString`, appends the key and comment into a target file. It's up to the developer to then create a copy of that file for each targeted locale and have a localizer translate it.

`genstrings` 会浏览每个所选的源文件，以及每个使用 `NSLocalizedString` 的源文件，把键和注释追加到目标文件。这取决于开发人员是否为每个语言创建该文件的副本，并进行本地化翻译。

## 不要模板化

After reading that part about localized format strings, you may be tempted to take a clever, DRY approach by creating reusable grammar templates like `@"{Noun} {Verb} {Noun}"`, and localizing each word individually...

在阅读了有关本地化的格式字符串的一部分之后，你可能会采取通过聪明的，DRY 的方式创建可重复使用的诸如 `@"{Noun} {Verb} {Noun}"` 这样的语法模板，并分别为每一个字做翻译...

**DON'T.** This cannot be stressed enough: _don't subdivide localized strings_. Context will be lost, grammatical constructions will be awkward and unidiomatic, verbs will be incorrectly conjugated, and you'll have missed the point entirely—taking great effort to make something worse than if you hadn't bothered in the first place.

**不要这样做** 这件事怎么强调也不过分：_不要细分本地化字符串_。上下文可能会丢失，语法结构将变得非常凌乱和不合常规，动词会被错误地改变格式，你将完全搞错重点 —— 在一些事情上花大力气比你在一开始就没有尽力更糟。

Numbers, dates, and similar values are almost always safe replacements. Nouns are subject to pluralization and verb conjugation, but usually safe as direct or indirect objects.

数字，日期，以及类似的几乎总是可以安全替代的值。名词受到多元化和动词变形的影响，但通常作为直接或间接的对象安全的替换。

For additional guidelines, see [Apple's Internationalization and Localization guide](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/Introduction/Introduction.html#//apple_ref/doc/uid/10000171i).

有关其他准则，请参阅[苹果的国际化和本地化指南](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/Introduction/Introduction.html#//apple_ref/doc/uid/10000171i).

---

`NSLocalizedString` is a remarkably reliable indicator of code quality. Those who care enough to take a few extra seconds to internationalize are very likely to be just as thoughtful when it comes to design and implementation.

`NSLocalizedString` 是代码质量的一个非常可靠的指标。那些愿意多花一些时间到国际化的人在涉及到设计和实现的时候也很可能会一样的周到。

**Always wrap user-facing strings with `NSLocalizedString`.**

**始终把面向用户的字符串用 `NSLocalizedString` 包起来。**

Even if you don't plan to localize your app into any other languages, there is _immense_ utility in being able to easily review all of the strings that a user will see. And if localization is in the cards, it's significantly easier to `NSLocalize` your strings as you go along the first time, then try to find all of them after-the-fact.

即使你不打算把你的应用程序本地化成其他语言，能够轻松地查看所有用户将看到字符串也是 _非常_ 有用的。如果本地化在你的计划中，把你的字符串在一开始就 `NSLocalize` 也将使这变得非常容易，你只需在必要的时候将它们都找出来就可以了。
