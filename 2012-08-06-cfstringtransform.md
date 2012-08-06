---
layout: post
title: CFStringTransform

ref: "https://developer.apple.com/library/mac/#documentation/CoreFOundation/Reference/CFMutableStringRef/Reference/reference.html"
framework: Core Foundation
rating: 9.1

description: `NSString` is the crown jewel of Foundation. But as powerful as `NSString` / `NSMutableString` are, we would be remiss without mentioning their [toll-free bridged](http://developer.apple.com/library/ios/#documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html) cousin, `CFMutableString`. Or more specifically, `CFStringTransform`.
---

There are two indicators that can tell you everything you need to know about how nice a language is to use:

1. API Consistency
2. Quality of String Implementation

`NSString` is the crown jewel of Foundation. In an age where other languages _still_ struggle to handle Unicode correctly, `NSString` not only can handle anything you throw at it, but it can parse that input into linguistic tags. It's unfairly good.

But as powerful as `NSString` / `NSMutableString` are, we would be remiss without mentioning their [toll-free bridged](http://developer.apple.com/library/ios/#documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html) cousin, `CFMutableString`. Or more specifically, `CFStringTransform`.

As denoted by the `CF` prefix, `CFStringTransform` is part of Core Foundation, which is a C, rather than Objective-C API. The function returns a `Boolean` for whether or not the transform was successful, and takes the following parameters:

- `string`: The string to be transformed. Since this argument is a `CFMutableStringRef`, an `NSMutableString` can be used with toll-free bridging.
- `range`: The range of the string over which the transformation should be applied.
- `transform`: The transformation to apply. This argument takes one of the string constants described below.
- `reverse`: Whether to run the transformation in reverse, where applicable. For instance, `kCFStringTransformToXMLHex` can be run in reverse to unescape XML entities.

`CFStringTransform` covers a lot of ground with its `transform` argument. Here's a rundown of what it's capable of:

## Strip Accents and Diacritics

Since the Énġlišh långuãge lẳcks iñterêßţing diaçrïtičş, it can be useful to normalize extended Latin characters into ASCII-friendly representations to make them easier to index and search on. You can get rid of the squiggly bits using the `kCFStringTransformStripCombiningMarks` transformation.

## Name Unicode Characters

`kCFStringTransformToUnicodeName` allows you to determine the Unicode standard name for special characters, including Emoji. For instance, "🐑💨✨" becomes "{SHEEP} {DASH SYMBOL} {SPARKLES}".

## Transcribe Between Orthographies

With the exception of English with its complicated spelling inconsistencies, writing systems are used in languages to encode speech sounds into a phonetic, written representation. European languages generally use the Latin alphabet with a few added diacritics, Russian uses Cyrillic, Japanese uses Hiragana & Katakana, and Thai, Korean, and Arabic each have their own scripts.

Although each language has a particular inventory of sounds that other languages may not have, the overlap across all of the major writing systems is remarkably high--enough so that one can rather effectively [transcribe](http://en.wikipedia.org/wiki/Transcription_(linguistics)) from one to another (not to be confused with [translation](http://en.wikipedia.org/wiki/Translation)).

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

## Normalize User-Generated Content

One of the most practical applications for all of this is to normalize unpredictable user input in useful ways. Even if your application doesn't specifically deal with languages, you should be able to intelligently process anything the user types into your app.

Let's say you want to build a searchable index of movies on the device, which includes titles from around the world. You could:

- First, apply the `kCFStringTransformToLatin` transform to transliterate all non-English text into a phonetic Latin alphabetic representation.

> Hello! こんにちは! สวัสดี! مرحبا! 您好! → Hello! kon'nichiha! s̄wạs̄dī! mrḥbạ! nín hǎo!

- Next, apply the `kCFStringTransformStripCombiningMarks` transform to remove any diacritics or accents.

> Hello! kon'nichiha! s̄wạs̄dī! mrḥbạ! nín hǎo! → Hello! kon'nichiha! swasdi! mrhba! nin hao!

- Finally, downcase the text and use [`CFStringTokenizer`](https://developer.apple.com/library/mac/#documentation/CoreFoundation/Reference/CFStringTokenizerRef/Reference/reference.html) to split the text into tokens, and index the movie on them.

> (hello, kon'nichiha, swasdi, mrhba, nin, hao)

If you do the same to search text entered by the user, you now have an easy way to search for names of titles, regardless of either the language of the search string or the movie title. Mathematical!

`CFStringTransform` can be an insanely powerful way to bend language to your will. And it's but one of many powerful features that await you if you're brave enough to explore outside of Objective-C's warm OO embrace.
