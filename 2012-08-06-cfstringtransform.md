---
layout: post
title: CFStringTransform
translator: Ricky Tan
ref: "https://developer.apple.com/library/mac/documentation/CoreFOundation/Reference/CFMutableStringRef/Reference/reference.html#//apple_ref/doc/uid/20001504-CH201-BCIGCACA"
framework: CoreFoundation
rating: 9.1
description: "NSString 是基础类库中的佼佼者。 它虽然很强大，但是不提提它的可自由桥接的表兄弟 CFMutableString，或者更特别地，CFStringTransform，是不负责任的。"
---

关于一种语言好不好用，你只需要衡量以下两种指标：

1. API 的统一性
2. String 类的实现质量

`NSString` 是基础类库中的佼佼者。在那个其他语言 _仍在_ 艰难地正理处理 Unicode的时代，`NSString` 是尤其让人印象深刻的。不仅仅是任何内容扔在它里面就能 _正确工作_ ，`NSString` 还能将字符串解析成语法标签、检测出内容中的首要语言，并且在任意你能想到的字符编码中转换。它好用得离谱。


它虽然很强大，但是不提提它的可自由桥接（[toll-free bridged](http://developer.apple.com/library/ios/#documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html)）的表兄弟 CFMutableString，或者更特别地，CFStringTransform，是不负责任的。

正如它的`CF`前缀所表述的一样，`CFStringTransform` 是 Core Foundation 中的一部分。这个函数传入以下参数，并返回一个 `Boolean` 来表示转换是否成功：

- `string`: 需要转换的字符串。由于这个参数是 `CFMutableStringRef` 类型，一个 `NSMutableString` 类型也可以通过自由桥接的方式传入。
- `range`: 转换操作作用的范围。这个参数是 `CFRange`，而不是 `NSRange`。
- `transform`: 需要应用的变换。这个参数使用了包含下面将提到的字符串常量的 [ICU transform string](http://userguide.icu-project.org/transforms/general)。
- `reverse`: 如有需要，是否返回反转过的变换。

`CFStringTransform` 中的 `transform` 参数涉及的内容很多。这里有个它能做什么的概述：

## 去掉重音和变音符

Énġlišh långuãge lẳcks iñterêßţing diaçrïtičş. 如此类的字符串，把扩展的拉丁字符集正则化为 ASCII 友好型的表示，它非常有用。用 `kCFStringTransformStripCombiningMarks` 变换来去掉任意字符串中弯弯扭扭的符号。

## 为 Unicode 字符命名

`kCFStringTransformToUnicodeName` 让你可以找出特殊字符的 Unicode 标准名，包括 Emoji。例如："🐑💨✨" 被转换成 "{SHEEP} {DASH SYMBOL} {SPARKLES}"，而 "🐷" 变成了 "{PIG FACE}"。

## 不同拼写之间转写

除了英语这个重大例外（和它那令人愉快的拼写不一致），书写系统一般是将语言音调编码成一致的符号表示。欧洲语言一般使用拉丁字母（外加一些变音符），俄罗斯用西里尔字母，日本用平假名和片假名，泰国、韩国和阿拉伯国家也都有自己的字母。

虽然每种语言都有特殊的音调列表，也许有些其他语言会缺失，所有主要书写系统的交集已经足以让你高效的在不同字母之间[转写](https://zh.wikipedia.org/wiki/%E8%BD%AC%E5%86%99)（不要跟[翻译](https://zh.wikipedia.org/wiki/%E7%BF%BB%E8%AF%91)搞混了）。

`CFStringTransform` 可以在拉丁语和阿拉伯语、西里尔语、希腊语、韩语（韩国）、希伯来语、日语（平假名和片假名）、普通话、泰语之间来回转写。

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

> 并且这只是用了核心类库中常量定义！直接传入一个[ICU transform](http://userguide.icu-project.org/transforms/general#TOC-ICU-Transliterators)表达式，`CFStringTransform` 还可以在拉丁语和阿拉伯语、亚美尼亚语、注音、西里尔字母、格鲁吉亚语、希腊语、汉语、韩语、希伯来语、平假名、印度语（梵文，古吉拉特语，旁遮普文，卡纳达语，马拉雅拉姆语，奥里雅语，泰米尔语，特卢固）、朝鲜语、片假名、叙利亚语、塔纳文、泰语之间转写。

## 正则化用户产生的内容

One of the more practical applications for string transformation is to normalize unpredictable user input. Even if your application doesn't specifically deal with other languages, you should be able to intelligently process anything the user types into your app.

For example, let's say you want to build a searchable index of movies on the device, which includes greetings from around the world:

- First, apply the `kCFStringTransformToLatin` transform to transliterate all non-English text into a Latin alphabetic representation.

> Hello! こんにちは! สวัสดี! مرحبا! 您好! →  
> Hello! kon'nichiha! s̄wạs̄dī! mrḥbạ! nín hǎo!

- Next, apply the `kCFStringTransformStripCombiningMarks` transform to remove any diacritics or accents.

> Hello! kon'nichiha! s̄wạs̄dī! mrḥbạ! nín hǎo! →  
> Hello! kon'nichiha! swasdi! mrhba! nin hao!

- Finally, downcase the text with `CFStringLowercase`, and split the text into tokens with [`CFStringTokenizer`](https://developer.apple.com/library/mac/#documentation/CoreFoundation/Reference/CFStringTokenizerRef/Reference/reference.html) to use as an index for the text.

> (hello, kon'nichiha, swasdi, mrhba, nin, hao)

By applying the same set of transformations on search text entered by the user, you have a universal way to search regardless of either the language of the search string or content!

* * *

`CFStringTransform` 会是个近乎疯狂的强大工具来按你的要求处理语言。can be an insanely powerful way to bend language to your will. And it's but one of many powerful features that await you if you're brave enough to explore outside of Objective-C's warm OO embrace.
