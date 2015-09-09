---
title: NSLocalizedString
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Strings are perhaps the most versatile data type in computing. They're passed around as symbols, used to encode numeric values, associate values to keys, represent resource paths, store linguistic content, and format information. Having a strong handle on user-facing strings is essential to making a great user experience."
status:
    swift: t.b.c.
---

Strings are perhaps the most versatile data type in computing. They're passed around as symbols, used to encode numeric values, associate values to keys, represent resource paths, store linguistic content, and format information. Having a strong handle on user-facing strings is essential to making a great user experience.

In Foundation, there is a convenient macro for denoting strings as user-facing: `NSLocalizedString`.

`NSLocalizedString` provides string localization in "compile-once / run everywhere" fashion, replacing all localized strings with their respective translation according to the string tables of the user settings. But even if you're not going to localize your app to any other markets, `NSLocalizedString` does wonders with respect to copy writing & editing.

> For more information about Localization (l10n) and Internationalization (i18n) [see the NSHipster article about NSLocale](http://nshipster.com/nslocale/).

---

`NSLocalizedString` is a Foundation macro that returns a localized version of a string. It has two arguments: `key`, which uniquely identifies the string to be localized, and `comment`, a string that is used to provide sufficient context for accurate translation.

In practice, the `key` is often just the base translation string to be used, while `comment` is usually `nil`, unless there is an ambiguous context:

~~~{objective-c}
textField.placeholder = NSLocalizedString(@"Username", nil);
~~~

`NSLocalizedString` can also be used as a format string in `NSString +stringWithFormat:`. In these cases, it's important to use the `comment` argument to provide enough context to be properly translated.

~~~{objective-c}
self.title = [NSString stringWithFormat:NSLocalizedString(@"%@'s Profile", @"{User First Name}'s Profile"), user.name];

label.text = [NSString stringWithFormat:NSLocalizedString(@"Showing %lu of %lu items", @"Showing {number} of {total number} items"), [page count], [items count]];
~~~

## `NSLocalizedString` & Co.

There are four varieties of `NSLocalizedString`, with increasing levels of control (and obscurity):

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

## Localizable.strings

At runtime, `NSLocalizedString` determines the preferred language, and finds a corresponding `Localizable.strings` file in the app bundle. For example, if the user prefers French, the file `fr.lproj/Localizable.strings` will be consulted.

Here's what that looks like:

~~~
/* No comment provided by engineer. */
"Username"="nom d'utilisateur";
/* {User First Name}'s Profile */
"%@'s Profile"="profil de %1$@";
~~~

`Localizable.strings` files are initially generated with `genstrings`.

>  The `genstrings` utility generates a .strings file(s) from the C or Objective-C (.c or .m) source code file(s) given as the argument(s).  A .strings file is used for localizing an application for different languages, as described under "Internationalization" in the Cocoa Developer Documentation.

`genstrings` goes through each of the selected source files, and for each use of `NSLocalizedString`, appends the key and comment into a target file. It's up to the developer to then create a copy of that file for each targeted locale and have a localizer translate it.

## No Madlibs

After reading that part about localized format strings, you may be tempted to take a clever, DRY approach by creating reusable grammar templates like `@"{Noun} {Verb} {Noun}"`, and localizing each word individually...

**DON'T.** This cannot be stressed enough: _don't subdivide localized strings_. Context will be lost, grammatical constructions will be awkward and unidiomatic, verbs will be incorrectly conjugated, and you'll have missed the point entirely—taking great effort to make something worse than if you hadn't bothered in the first place.

Numbers, dates, and similar values are almost always safe replacements. Nouns are subject to pluralization and verb conjugation, but usually safe as direct or indirect objects.

For additional guidelines, see [Apple's Internationalization and Localization guide](https://developer.apple.com/library/ios/documentation/MacOSX/Conceptual/BPInternational/Introduction/Introduction.html#//apple_ref/doc/uid/10000171i).

---

`NSLocalizedString` is a remarkably reliable indicator of code quality. Those who care enough to take a few extra seconds to internationalize are very likely to be just as thoughtful when it comes to design and implementation.

**Always wrap user-facing strings with `NSLocalizedString`.**

Even if you don't plan to localize your app into any other languages, there is _immense_ utility in being able to easily review all of the strings that a user will see. And if localization is in the cards, it's significantly easier to `NSLocalize` your strings as you go along the first time, then try to find all of them after-the-fact.
