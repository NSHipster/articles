---
layout: post
title: NSLocalizedString

ref: "https://developer.apple.com/library/mac/#documentation/cocoa/reference/foundation/miscellaneous/foundation_functions/reference/reference.html"
framework: Foundation
rating: 9.5
published: true
description: "Strings are perhaps the most important data type in computing. They're passed around as symbols, used to encode numeric values, associate keys to values, represent resource paths, store linguistic content, and format information. Being able to discern user-facing strings from all of the other purposes is essential to making a great user experience."
---

Strings are perhaps the most important data type in computing. They're passed around as symbols, used to encode numeric values, associate keys to values, represent resource paths, store linguistic content, and format information. Being able to discern user-facing strings from all of the other purposes is essential to making a great user experience.

In Foundation, there is a convenient wrapper function for denoting strings as user-facing: `NSLocalizedString`. `NSLocalizedString` provides string localization in "compile-once / run everywhere" fashion, replacing all localized strings with their respective translation according to the language settings of the target platform.

> For more information about Localization (l10n) and Internationalization (i18n) [see the NSHipster article about NSLocale](http://nshipster.com/nslocale/).

---

`NSLocalizedString` is a Foundation function that returns a localized version of a string. It has two arguments: `key`, which uniquely identifies the string to be localized, and `comment`, a string that is used to provide sufficient context for accurate translation.

In practice, the `key` is often just the base translation string to be used, while `comment` is usually `nil`, unless there is an ambiguous context:

~~~{objective-c}
textField.placeholder = NSLocalizedString(@"Username", nil);
~~~

`NSLocalizedString` can also be used as a format string in `NSString +stringWithFormat:`. In these cases, it's important to use the `comment` argument to provide enough context to be properly translated.

~~~{objective-c}
self.title = [NSString stringWithFormat:NSLocalizedString(@"%@'s Profile", @"{User First Name}'s Profile"), user.name];
~~~

~~~{objective-c}
label.text = [NSString stringWithFormat:NSLocalizedString(@"Showing %lu of %lu items", @"Showing {number} of {total number} items"), [page count], [items count]];
~~~

## `NSLocalizedString` & Co.

There are four varieties of `NSLocalizedString`, with increasing levels of control (and obscurity):

~~~{objective-c}
NSString * NSLocalizedString(
  NSString *key, 
  NSString *comment
)
~~~

~~~{objective-c}
NSString * NSLocalizedStringFromTable(
  NSString *key, 
  NSString *tableName, 
  NSString *comment
)
~~~

~~~{objective-c}
NSString * NSLocalizedStringFromTableInBundle(
  NSString *key, 
  NSString *tableName, 
  NSBundle *bundle,
  NSString *comment
)
~~~

~~~{objective-c}
NSString * NSLocalizedStringWithDefaultValue(
  NSString *key,
  NSString *tableName,
  NSBundle *bundle,
  NSString *value,
  NSString *comment
)
~~~

99% of the time, `NSLocalizedString` will suffice. If you're working in a library or shared component, `NSLocalizedStringFromTable` should be used instead.

## No Madlibs

After reading that part about localized format strings, you may be tempted to take a clever, DRY approach by creating reusable grammar templates like `@"{Noun} {Verb} {Noun}", and localizing each word individually...

**DON'T.** This cannot be stressed enough: _don't subdivide localized strings_. Context will be lost, grammatical constructions will be awkward and unidiomatic, verbs will be incorrectly-conjugated, and you'll have missed the point entirely—taking great effort to make something worse than if you hadn't bothered in the first place.

Numbers, dates, and similar values are almost always safe replacements. Nouns are subject to pluralization and verb conjugation, but usually safe as direct or indirect objects.

For additional guidelines, see [Localizing String Resources from Apple's Internationalization Programming guide](https://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPInternational/Articles/StringsFiles.html#//apple_ref/doc/uid/20000005).

---

`NSLocalizedString` is a remarkably reliable indicator of code quality. Those who care enough to take a few extra seconds to internationalize are very likely to be just as thoughtful when it comes to design and implementation.

**Always wrap user-facing strings in `NSLocalizedString`.**

Even if you don't plan to localize your app into any other languages, there is _immense_ utility in being able to easily review all of the strings that a user will see. And if localization is in the cards, it's significantly easier to `NSLocalize` your strings as you go along the first time, then try to find all of them after-the-fact.
