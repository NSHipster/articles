---
title: CFStringTransform
author: Mattt Thompson
category: Cocoa
tags: nshipster, popular
excerpt: "NSString is the crown jewel of Foundation. But as powerful as it is, one would be remiss not to mention its toll-free bridged cousin, CFMutableString—or more specifically, CFStringTransform."
status:
    swift: 1.2
---

There are two indicators that tell you everything you need to know about how nice a language is to use:

1. API Consistency
2. Quality of String Implementation

`NSString` is the crown jewel of Foundation. In an age where other languages _still_ struggle to handle Unicode correctly, `NSString` is especially impressive. Not content to _just work_ with whatever is thrown at it, `NSString` can parse strings into linguistic tags, determine the dominant language of the content, and convert between every string encoding imaginable. It's unfairly good.

But as powerful as `NSString` / `NSMutableString` are, one would be remiss not to mention their [toll-free bridged](http://developer.apple.com/library/ios/#documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html) cousin, `CFMutableString`—or more specifically, `CFStringTransform`.

As denoted by the `CF` prefix, `CFStringTransform` is part of Core Foundation. The function takes the following arguments, and returns a `Boolean` for whether or not the transform was successful:

- `string`: The string to be transformed. Since this argument is a `CFMutableStringRef`, an `NSMutableString` can be passed using toll-free bridging cast.
- `range`: The range of the string over which the transformation should be applied. This argument is a `CFRange`, rather than an `NSRange` value.
- `transform`: The transformation to apply. This argument takes an [ICU transform string](http://userguide.icu-project.org/transforms/general), including any one of the string constants described below.
- `reverse`: Whether to run the transformation in reverse, where applicable.

`CFStringTransform` covers a lot of ground with its `transform` argument. Here's a rundown of what it can do:

## Strip Accents and Diacritics

Énġlišh långuãge lẳcks iñterêßţing diaçrïtičş. As such, it can be useful to normalize extended Latin characters into ASCII-friendly representations. Rid any string of its squiggly bits using the `kCFStringTransformStripCombiningMarks` transformation.

## Name Unicode Characters

`kCFStringTransformToUnicodeName` allows you to determine the Unicode standard name for special characters, including Emoji. For instance, "🐑💨✨" is transformed into "{SHEEP} {DASH SYMBOL} {SPARKLES}", and "🐷" becomes "{PIG FACE}".

## Transliterate Between Orthographies

With the notable exception of English (and its delightful spelling inconsistencies), writing systems generally encode speech sounds into a consistent written representation. European languages generally use the Latin alphabet (with a few added diacritics), Russian uses Cyrillic, Japanese uses Hiragana & Katakana, and Thai, Korean, & Arabic each have their own scripts.

Although each language has a particular inventory of sounds, some of which other languages may lack, the overlap across all of the major writing systems is remarkably high—enough so that one can rather effectively [transliterate](http://en.wikipedia.org/wiki/Transliteration) (not to be confused with [translation](http://en.wikipedia.org/wiki/Translation)) from one script to another.

`CFStringTransform` can transliterate back and forth between Latin and Arabic, Cyrillic, Greek, Korean (Hangul), Hebrew, Japanese (Hiragana & Katakana), Mandarin Chinese, and Thai.

<table>
  <thead>
    <tr>
      <th>Transformation</th>
      <th>Input</th>
      <th>Output</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>kCFStringTransformLatinArabic</tt></td>
      <td>mrḥbạ</td>
      <td>مرحبا</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformLatinCyrillic</tt></td>
      <td>privet</td>
      <td>привет</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformLatinGreek</tt></td>
      <td>geiá sou</td>
      <td>γειά σου</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformLatinHangul</tt></td>
      <td>annyeonghaseyo</td>
      <td>안녕하세요</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformLatinHebrew</tt></td>
      <td>şlwm</td>
      <td>שלום</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformLatinHiragana</tt></td>
      <td>hiragana</td>
      <td>ひらがな</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformLatinKatakana</tt></td>
      <td>katakana</td>
      <td>カタカナ</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformLatinThai</tt></td>
      <td>s̄wạs̄dī</td>
      <td>สวัสดี</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformHiraganaKatakana</tt></td>
      <td>にほんご</td>
      <td>ニホンゴ</td>
    </tr>
    <tr>
      <td><tt>kCFStringTransformMandarinLatin</tt></td>
      <td>中文</td>
      <td>zhōng wén</td>
    </tr>
  </tbody>
</table>

> And that's only using the constants defined in Core Foundation! By passing an [ICU transform](http://userguide.icu-project.org/transforms/general#TOC-ICU-Transliterators) directly, `CFStringTransform` can transliterate between Latin and Arabic, Armenian, Bopomofo, Cyrillic, Georgian, Greek, Han, Hangul, Hebrew, Hiragana, Indic ( Devanagari, Gujarati, Gurmukhi, Kannada, Malayalam, Oriya, Tamil, & Telegu), Jamo, Katakana, Syriac, Thaana, & Thai.

## Normalize User-Generated Content

One of the more practical applications for string transformation is to normalize unpredictable user input. Even if your application doesn't specifically deal with other languages, you should be able to intelligently process anything the user types into your app.

For example, let's say you want to build a searchable index of movies on the device, which includes greetings from around the world:

~~~{swift}
var mutableString = NSMutableString(string: "Hello! こんにちは! สวัสดี! مرحبا! 您好!") as CFMutableStringRef
~~~

- First, apply the `kCFStringTransformToLatin` transform to transliterate all non-English text into a Latin alphabetic representation.

~~~{swift}
CFStringTransform(mutableString, nil, kCFStringTransformToLatin, Boolean(0))
~~~

> Hello! こんにちは! สวัสดี! مرحبا! 您好! →
> Hello! kon'nichiha! s̄wạs̄dī! mrḥbạ! nín hǎo!

- Next, apply the `kCFStringTransformStripCombiningMarks` transform to remove any diacritics or accents.

~~~{swift}
CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, Boolean(0))
~~~

> Hello! kon'nichiha! s̄wạs̄dī! mrḥbạ! nín hǎo! →
> Hello! kon'nichiha! swasdi! mrhba! nin hao!

- Finally, downcase the text with `CFStringLowercase`, and split the text into tokens with [`CFStringTokenizer`](https://developer.apple.com/library/mac/#documentation/CoreFoundation/Reference/CFStringTokenizerRef/Reference/reference.html) to use as an index for the text.

~~~{swift}
let tokenizer = CFStringTokenizerCreate(nil, mutableString, CFRangeMake(0, CFStringGetLength(mutableString)), 0, CFLocaleCopyCurrent())

var mutableTokens: [String] = []
var type: CFStringTokenizerTokenType
do {
    type = CFStringTokenizerAdvanceToNextToken(tokenizer)
    let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
    let token = CFStringCreateWithSubstring(nil, mutableString, range) as NSString
    mutableTokens.append(token)
} while type != .None
~~~

> (hello, kon'nichiha, swasdi, mrhba, nin, hao)

By applying the same set of transformations on search text entered by the user, you have a universal way to search regardless of either the language of the search string or content!

> For anyone wanting to be especially clever, all of the necessary transformations can actually be done in a single pass, by specifying the ICU transform `"Any-Latin; Latin-ASCII; Any-Lower"`.

* * *

`CFStringTransform` can be an insanely powerful way to bend language to your will. And it's but one of many powerful features that await you if you're brave enough to explore outside of Objective-C's warm OO embrace.
