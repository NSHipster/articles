---
layout: post
title: NSCharacterSet
translator: Ricky Tan
ref: "http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/nscharacterset_Class/Reference/Reference.html"
framework: Foundation
rating: 8.5
published: true
description: "基础类库（Foundation）拥有最好的、功能也最全的string类的实现。但是仅当程序员熟练掌握它时，一个string的实现才是真的好。所以本周，我们将浏览一些基础类库的string生态系统中经常用到且用错的重要组成部分：NSCharacterSet。"
---

正如[之前](http://nshipster.com/cfstringtransform/)提前过的，基础类库（Foundation）拥有最好的、功能也最全的string类的实现。

但是仅当程序员熟练掌握它时，一个string的实现才是真的好。所以本周，我们将浏览一些基础类库的string生态系统中经常用到且用错的重要组成部分：`NSCharacterSet`。

---

> 如果你对什么是字符编码搞不清楚的话（即使你有很好的专业知识），那么你应该抓住这次机会反复阅读Joel Spolsky的这篇经典的文章["The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!)"](http://www.joelonsoftware.com/articles/Unicode.html)。在头脑中保持新鲜感将对你理解我们将要探讨的话题非常有帮助。

`NSCharacterSet` ，以及它的可变版本`NSMutableCharacterSet`，用面向对象的方式来表示一组Unicode字符。它经常与`NSString`及`NSScanner`组合起来使用，在不同的字符上做过滤、删除或者分割操作。为了给你提供这些字符是哪些字符的直观印象，请看看`NSCharacterSet` 提供的类方法：

- `alphanumericCharacterSet`
- `capitalizedLetterCharacterSet`
- `controlCharacterSet`
- `decimalDigitCharacterSet`
- `decomposableCharacterSet`
- `illegalCharacterSet`
- `letterCharacterSet`
- `lowercaseLetterCharacterSet`
- `newlineCharacterSet`
- `nonBaseCharacterSet`
- `punctuationCharacterSet`
- `symbolCharacterSet`
- `uppercaseLetterCharacterSet`
- `whitespaceAndNewlineCharacterSet`
- `whitespaceCharacterSet`

与它的名字所表述的相反，`NSCharacterSet` 跟 `NSSet` 一点关系都_没有_。

但是， `NSCharacterSet` 跟 `NSIndexSet` 还_有点_相似的，至少在概念上而不是底层实现上。`NSIndexSet`，[之前](http://nshipster.com/nsindexset/)提到过，表示一个有序的不重复的无符号整数的集合。Unicode字符跟无符号整数类似，大致对应一些拼写表示。所以，一个 `NSCharacterSet +lowercaseCharacterSet` 字符集与一个包含97到122范围的 `NSIndexSet` 是等价的。

现在我们对理解 `NSCharacterSet` 的基本概念已经有了少许自信，让我们来看一些它的模式与反模式吧：

## 去掉空格

`NSString -stringByTrimmingCharactersInSet:` 是个你需要牢牢记住的方法。它经常会传入 `NSCharacterSet +whitespaceCharacterSet` 或 `+whitespaceAndNewlineCharacterSet` 来删除输入字符串的头尾的空白符号。

It's important to note that this method _only_ strips the _first_ and _last_ contiguous sequences of characters in the specified set. That is to say, if you want to remove excess whitespace between words, you need to go a step further.

## Squashing Whitespace

So let's say you do want to get rid of excessive inter-word spacing for that string you just stripped of whitespace. Here's a really easy way to do that:

~~~{objective-c}
NSString *string = @"Lorem    ipsum dolar   sit  amet.";
string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

NSArray *components = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];

string = [components componentsJoinedByString:@" "];
~~~

First, trim the string of leading and trailing whitespace. Next, use `NSString -componentsSeparatedByCharactersInSet:` to split on the remaining whitespace to create an `NSArray`. Next, filter out the blank string components with an `NSPredicate`. Finally, use `NSArray -componentsJoinedByString:` to re-join the components with a single space. Note that this only works for languages like English that delimit words with whitespace.

And now for the anti-patterns. Take a gander at [the answers to this question on StackOverflow](http://stackoverflow.com/questions/758212/how-can-i-strip-all-the-whitespaces-from-a-string-in-objective-c).

At the time of writing, the correct answer ranks second by number of votes, with 58 up and 2 down. The top answer edges it out with 84 up and 24 down.

Now, it's not uncommon for the top-voted / accepted answer to not be the correct one, but this question may set records for number of completely distinct answers (10), and number of unique, completely incorrect answers (9).

Without further ado, here are the 9 _incorrect_ answers:

- "Use `stringByTrimmingCharactersInSet`" - _Only strips the leading and trailing whitespace, as you know._
- "Replace ' ' with ''" - _This removes **all** of the spaces. Swing and a miss._ 
- "Use a regular expression" - _Kinda works, except it doesn't handle leading and trailing whitespace. A regular expression is overkill anyway._
- "Use Regexp Lite" - _No seriously, regular expressions are completely unnecessary. And it's definitely not worth the external dependency._
- "Use OgreKit" - _Ditto any other third-party regexp library._
- "Split the string into components, iterate over them to find components with non-zero length, and then re-combine" - _So close, but `componentsSeparatedByCharactersInSet:` already makes the iteration unnecessary._
- "Replace two-space strings with single-space strings in a while loop" - _Wrong and oh-so computationally wasteful_.
- "Manually iterate over each `unichar` in the string and use `NSCharacterSet -characterIsMember:`" - _Shows a surprising level of sophistication for missing the method that does this in the standard library._
- "Find and remove all of the tabs" - _Thanks all the same, but who said anything about tabs?_

I don't mean to rag on any of the answerers personally--this is all to point out how many ways there are to approach these kinds of tasks, and how many of those ways are totally wrong.

## String Tokenization

**Do not use `NSCharacterSet` to tokenize strings.**  
**Use `CFStringTokenizer` instead.**

You can be forgiven for using `componentsSeparatedByCharactersInSet:` to clean up user input, but do this for anything more complex, and you'll be in a world of pain.

Why? Well, remember that bit about languages not always having whitespace word boundaries? As it turns out, those languages are rather widely used. Just Chinese and Japanese--#1 and #9 in terms of number of speakers, respectively--alone account for 16% of the world population, or well over a billion people.

...and even for languages that do have whitespace word boundaries, tokenization has some obscure edge cases, particularly with compound words and punctuation.

This is all to say: use `CFStringTokenizer` (or `enumerateSubstringsInRange:options:usingBlock:`) if you ever intend to split a string by words in any meaningful way.

## Parse Data From Strings

`NSScanner` is a class that helps to parse data out of arbitrary or semi-structured strings. When you create a scanner for a string, you can specify a set of characters to skip, thus preventing any of those characters from somehow being included in the values parsed from the string.

For example, let's say you have a string that parses opening hours in the following form:

    Mon-Thurs:  8:00 - 18:00
    Fri:        7:00 - 17:00
    Sat-Sun:    10:00 - 15:00

You might `enumerateLinesUsingBlock:` and parse with an `NSScanner` like so:

~~~{objective-c}
NSMutableCharacterSet *skippedCharacters = [NSMutableCharacterSet punctuationCharacterSet];
[skippedCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];

[hours enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
  NSScanner *scanner = [NSScanner scannerWithString:line];
  [scanner setCharactersToBeSkipped:skippedCharacters];

  NSString *startDay, *endDay;
  NSUInteger startHour, startMinute, endHour, endMinute;

  [scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&startDay];
  [scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&endDay];

  [scanner scanInteger:&startHour];
  [scanner scanInteger:&startMinute];
  [scanner scanInteger:&endHour];
  [scanner scanInteger:&endMinute];
}];
~~~

We first construct an `NSMutableCharacterSet` from the union of whitespace and punctuation characters. Telling `NSScanner` to skip these characters greatly reduces the logic necessary to parse values from the string. 

`scanCharactersFromSet:` with the letters character set captures the start and (optional) end day of the week for each entry. `scanInteger` similarly captures the next contiguous integer value.

`NSCharacterSet` and `NSScanner` allow you to code quickly and confidently. They're really a great combination, those two.

---

`NSCharacterSet` is but one piece to the Foundation string ecosystem, and perhaps the most misused and misunderstood of them all. By keeping these patterns and anti-patterns in mind, however, not only will you be able to do useful things like manage whitespace and scan information from strings, but--more importantly--you'll be able to avoid all of the wrong ways to do it.

And if not being wrong isn't the most important thing about being an NSHipster, then I don't want to be right!

> Ed. Speaking of (not) being wrong, the original version of this article contained errors in both code samples. These have since been corrected.
