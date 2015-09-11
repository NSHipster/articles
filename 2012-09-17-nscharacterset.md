---
title: NSCharacterSet
author: Mattt Thompson
category: Cocoa
excerpt: "Foundation boasts one of the best, most complete implementations of strings around. But a string implementation is only as good as the programmer who wields it. So this week, we're going to explore some common uses--and misuses--of an important part of the Foundation string ecosystem: NSCharacterSet."
status:
    swift: 2.0
    reviewed: September 9, 2015
---

As mentioned [previously](http://nshipster.com/cfstringtransform/), Foundation boasts one of the best, most complete implementations of strings around.

But a string implementation is only as good as the programmer who wields it. So this week, we're going to explore some common uses--and misuses--of an important part of the Foundation string ecosystem: `NSCharacterSet`.

---

> If you're fuzzy on what character encodings are (or even if you have a pretty good working knowledge), you should take this opportunity to read / re-read / skim and read later Joel Spolsky's classic essay ["The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets (No Excuses!)"](http://www.joelonsoftware.com/articles/Unicode.html). Having that fresh in your mind will give you a much better appreciation of everything we're about to cover.

`NSCharacterSet` and its mutable counterpart, `NSMutableCharacterSet`, provide an object-oriented way of representing sets of Unicode characters. It's most often used with `NSString` & `NSScanner` to filter, remove, or split on different kinds of characters. To give you an idea of what those kinds of characters can be, take a look at the class methods provided by `NSCharacterSet`:

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

Contrary to what its name might suggest, `NSCharacterSet` has _nothing_ to do with `NSSet`.

However, `NSCharacterSet` _does_ have quite a bit in common with `NSIndexSet`, conceptually if not also in its underlying implementation. `NSIndexSet`, covered [previously](http://nshipster.com/nsindexset/), represents a sorted collection of unique unsigned integers. Unicode characters are likewise unique unsigned integers that roughly correspond to some orthographic representation. Thus, a character set like `NSCharacterSet +lowercaseCharacterSet` is analogous to the `NSIndexSet` of the integers 97 to 122.

Now that we're comfortable with the basic concepts of `NSCharacterSet`, let's see some of those patterns and anti-patterns:

## Stripping Whitespace

`NSString -stringByTrimmingCharactersInSet:` is a method you should know by heart. It's most often passed `NSCharacterSet +whitespaceCharacterSet` or `+whitespaceAndNewlineCharacterSet` in order to remove the leading and trailing whitespace of string input.

It's important to note that this method _only_ strips the _first_ and _last_ contiguous sequences of characters in the specified set. That is to say, if you want to remove excess whitespace between words, you need to go a step further.

## Squashing Whitespace

So let's say you do want to get rid of excessive inter-word spacing for that string you just stripped of whitespace. Here's a really easy way to do that:

~~~{swift}
var string = "  Lorem    ipsum dolar   sit  amet. "

let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).filter { !$0.isEmpty }

string = components.joinWithSeparator(" ")
~~~

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

~~~
Mon-Thurs:  8:00 - 18:00
Fri:        7:00 - 17:00
Sat-Sun:    10:00 - 15:00
~~~

You might `enumerateLinesUsingBlock:` and parse with an `NSScanner` like so:

~~~{swift}
let skippedCharacters = NSMutableCharacterSet.punctuationCharacterSet()
skippedCharacters.formUnionWithCharacterSet(NSCharacterSet.whitespaceCharacterSet())

hours.enumerateLines { (line, _) in
    let scanner = NSScanner(string: line)
    scanner.charactersToBeSkipped = skippedCharacters

    var startDay, endDay: NSString?
    var startHour: Int = 0
    var startMinute: Int = 0
    var endHour: Int = 0
    var endMinute: Int = 0

    scanner.scanCharactersFromSet(NSCharacterSet.letterCharacterSet(), intoString: &startDay)
    scanner.scanCharactersFromSet(NSCharacterSet.letterCharacterSet(), intoString: &endDay)

    scanner.scanInteger(&startHour)
    scanner.scanInteger(&startMinute)
    scanner.scanInteger(&endHour)
    scanner.scanInteger(&endMinute)
}
~~~

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
