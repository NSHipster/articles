---
title: "NSRegularExpression"
author: Nate Cook
category: Cocoa
excerpt: "Some find regular expressions impenetrably incomprehensible, thick with symbols and adornments, more akin to a practical joke than part of a reasonable code base. Others rely on their brevity and their power, wondering how anyone could possibly get along without such a versatile tool in their arsenal. Happily, on one thing we can all agree: In `NSRegularExpression`, Cocoa has the most long-winded and byzantine regular expression interface you're ever likely to come across."
status:
    swift: 3.0
hiddenlang: "ruby,swift"
---

> "Some people, when confronted with a problem, think 'I know, I'll use `NSRegularExpression`.' Now they have three problems."

Regular expressions fill a controversial role in the programming world. Some find them impenetrably incomprehensible, thick with symbols and adornments, more akin to a practical joke than part of a reasonable code base. Others rely on their brevity and their power, wondering how anyone could possibly get along without such a versatile tool in their arsenal.

Happily, on one thing we can all agree. In `NSRegularExpression`, Cocoa has the most long-winded and byzantine regular expression interface you're ever likely to come across. Don't believe me? Let's try extracting the links from this snippet of HTML, first using Ruby:

```ruby
htmlSource = "Questions? Corrections? <a href=\"https://twitter.com/NSHipster\">@NSHipster</a> or <a href=\"https://github.com/NSHipster/articles\">on GitHub</a>."
linkRegex = /<a\s+[^>]*href="([^"]*)"[^>]*>/i
links = htmlSource.scan(linkRegex)
puts(links)
# https://twitter.com/NSHipster
# https://github.com/NSHipster/articles
```

Two or three lines, depending on how you count—not bad. Now we'll try the same thing in Swift using `NSRegularExpression`:

```swift
let htmlSource = "Questions? Corrections? <a href=\"https://twitter.com/NSHipster\">@NSHipster</a> or <a href=\"https://github.com/NSHipster/articles\">on GitHub</a>."

let linkRegexPattern = "<a\\s+[^>]*href=\"([^\"]*)\"[^>]*>"
let linkRegex = try! NSRegularExpression(pattern: linkRegexPattern,
                                         options: .caseInsensitive)
let matches = linkRegex.matches(in: htmlSource,
                                range: NSMakeRange(0, htmlSource.utf16.count))

let links = matches.map { result -> String in
    let hrefRange = result.rangeAt(1)
    let start = String.UTF16Index(hrefRange.location)
    let end = String.UTF16Index(hrefRange.location + hrefRange.length)

    return String(htmlSource.utf16[start..<end])!
}
print(links)
// ["https://twitter.com/NSHipster", "https://github.com/NSHipster/articles"]
```

The prosecution rests.

This article won't get into the ins and outs of regular expressions themselves (you may need to learn about wildcards, backreferences, lookaheads and the rest elsewhere), but read on to learn about `NSRegularExpression`, `NSTextCheckingResult`, and a particularly sticky point when bringing it all together in Swift.

---

## `NSString` Methods

The simplest way to use regular expressions in Cocoa is to skip `NSRegularExpression` altogether. The `range(of:...)` method on `NSString` (which is bridged to Swift's native `String` type) switches into regular expression mode when given the `.regularExpression` option, so lightweight searches can be written easily:

```swift
let source = "For NSSet and NSDictionary, the breaking..."

// Matches anything that looks like a Cocoa type:
// UIButton, NSCharacterSet, NSURLSession, etc.
let typePattern = "[A-Z]{3,}[A-Za-z0-9]+"

if let typeRange = source.range(of: typePattern,
                                options: .regularExpression) {
    print("First type: \(source[typeRange])")
    // First type: NSSet
}
```

```objc
NSString *source = @"For NSSet and NSDictionary, the breaking...";

// Matches anything that looks like a Cocoa type:
// UIButton, NSCharacterSet, NSURLSession, etc.
NSString *typePattern = @"[A-Z]{3,}[A-Za-z0-9]+";
NSRange typeRange = [source rangeOfString:typePattern
                                  options:NSRegularExpressionSearch];

if (typeRange.location != NSNotFound) {
    NSLog(@"First type: %@", [source substringWithRange:typeRange]);
    // First type: NSSet
}
```

Replacement is also a snap using `replacingOccurrences(of:with:...)` with the same option. Watch how we surround each type name in our text with Markdown-style backticks using this one weird trick:

```swift
let markedUpSource = source.replacingOccurrences(of: typePattern,
    with: "`$0`", options: .regularExpression)
print(markedUpSource)
// "For `NSSet` and `NSDictionary`, the breaking...""
```

```objc
NSString *markedUpSource =
    [source stringByReplacingOccurrencesOfString:typePattern
                                      withString:@"`$0`"
                                         options:NSRegularExpressionSearch
                                           range:NSMakeRange(0, source.length)];
NSLog(@"%@", markedUpSource);
// "For `NSSet` and `NSDictionary`, the breaking...""
```

This approach to regular expressions can even handle subgroup references in the replacement template. Lo, a quick and dirty Pig Latin transformation:

```swift
let ourcesay = source.replacingOccurrences(
    of: "([bcdfghjklmnpqrstvwxyz]*)([a-z]+)",
    with: "$2$1ay",
    options: [.regularExpression, .caseInsensitive])
print(ourcesay)
// "orFay etNSSay anday ictionaryNSDay, ethay eakingbray..."
```

```objc
NSString *ourcesay =
    [source stringByReplacingOccurrencesOfString:@"([bcdfghjklmnpqrstvwxyz]*)([a-z]+)"
                                      withString:@"$2$1ay"
                                         options:NSRegularExpressionSearch | NSCaseInsensitiveSearch
                                           range:NSMakeRange(0, source.length)];
NSLog(@"%@", ourcesay);
// "orFay etNSSay anday ictionaryNSDay, ethay eakingbray..."
```

These two methods will suffice for many places you might want to use regular expressions, but for heavier lifting, we'll need to work with `NSRegularExpression` itself. First, though, let's sort out a minor complication when using this class from Swift.

## `NSRange` and Swift

Swift provides a more comprehensive, more complex interface to a string's characters and substrings than does Foundation's `NSString`. The Swift standard library provides [four different views](https://developer.apple.com/swift/blog/?id=30) into a string's data, giving you quick access to the elements of a string as characters, Unicode scalar values, or UTF-8 or UTF-16 code units.

How does this relate to `NSRegularExpression`? Well, many `NSRegularExpression` methods use `NSRange`s, as do the `NSTextCheckingResult` instances that store a match's data. `NSRange`, in turn, uses integers for its location and length, while none of `String`'s views use integers as an index:

```swift
let range = NSRange(location: 4, length: 5)

// Not one of these will compile:
source[range]
source.characters[range]
source.substring(with: range)
source.substring(with: range.toRange()!)
```

Confusion. Despair.

But don't give up! Everything isn't as disconnected as it seems—the `utf16` view on a Swift `String` is meant specifically for interoperability with Foundation's `NSString` APIs. As long as Foundation has been imported, you can create new indices for a `utf16` view directly from integers:

```swift
let start = String.UTF16Index(range.location)
let end = String.UTF16Index(range.location + range.length)
let substring = String(source.utf16[start..<end])!
// substring is now "NSSet"
```

With that in mind, here are a few additions to `String` that will make straddling the Swift/Objective-C divide a bit easier:

```swift
extension String {
    /// An `NSRange` that represents the full range of the string.
    var nsrange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    /// Returns a substring with the given `NSRange`,
    /// or `nil` if the range can't be converted.
    func substring(with nsrange: NSRange) -> String? {
        guard let range = nsrange.toRange()
            else { return nil }
        let start = UTF16Index(range.lowerBound)
        let end = UTF16Index(range.upperBound)
        return String(utf16[start..<end])
    }

    /// Returns a range equivalent to the given `NSRange`,
    /// or `nil` if the range can't be converted.
    func range(from nsrange: NSRange) -> Range<Index>? {
        guard let range = nsrange.toRange() else { return nil }
        let utf16Start = UTF16Index(range.lowerBound)
        let utf16End = UTF16Index(range.upperBound)

        guard let start = Index(utf16Start, within: self),
            let end = Index(utf16End, within: self)
            else { return nil }

        return start..<end
    }
}
```

We'll put these to use in the next section, where we'll finally see `NSRegularExpression` in action.

## `NSRegularExpression` & `NSTextCheckingResult`

If you're doing more than just searching for the first match or replacing all the matches in your string, you'll need to build an `NSRegularExpression` to do your work. Let's build a miniature text formatter that can handle \*bold\* and \_italic\_ text.

Pass a pattern and, optionally, some options to create a new instance. `miniPattern` looks for an asterisk or an underscore to start a formatted sequence, one or more characters to format, and finally a matching character to end the formatted sequence. The initial character and the string to format are both captured:

```swift
let miniPattern = "([*_])(.+?)\\1"
let miniFormatter = try! NSRegularExpression(pattern: miniPattern, options: .dotMatchesLineSeparators)
// the initializer throws an error if the pattern is invalid
```

```objc
NSString *miniPattern = @"([*_])(.+?)\\1";
NSError *error = nil;
NSRegularExpression *miniFormatter = [NSRegularExpression
                                      regularExpressionWithPattern:miniPattern
                                      options:NSRegularExpressionDotMatchesLineSeparators
                                      error:&error];
```

The initializer throws an error if the pattern is invalid. Once constructed, you can use an `NSRegularExpression` as often as you need with different strings.

```swift
let text = "MiniFormatter handles *bold* and _italic_ text."
let matches = miniFormatter.matches(in: text, options: [], range: text.nsrange)
// matches.count == 2
```

```objc
NSString *text = @"MiniFormatter handles *bold* and _italic_ text.";
NSArray<NSTextCheckingResult *> *matches = [miniFormatter matchesInString:text
                                            options:kNilOptions
                                            range:NSMakeRange(0, text.length)];
// matches.count == 2
```

Calling `matches(in:options:range:)` fetches an array of `NSTextCheckingResult`, the type used as the result for a variety of text handling classes, such as `NSDataDetector` and `NSSpellChecker`. The resulting array has one `NSTextCheckingResult` for each match.

The information we're most interested are the range of the match, stored as `range` in each result, and the ranges of any capture groups in the regular expression. You can use the `numberOfRanges` property and the `rangeAt(_:)`method to find the captured ranges—range 0 is always the full match, with the ranges at indexes 1 up to, but not including, `numberOfRanges` covering each capture group.

Using the `NSRange`-based substring method we declared above, we can use these ranges to extract the capture groups:

```swift
for match in matches {
    let stringToFormat = text.substring(with: match.rangeAt(2))!
    switch text.substring(with: match.rangeAt(1))! {
    case "*":
        print("Make bold: '\(stringToFormat)'")
    case "_":
        print("Make italic: '\(stringToFormat)'")
    default: break
    }
}
// Make bold: 'bold'
// Make italic: 'italic'
```

```objc
for (NSTextCheckingResult *match in matches) {
    NSString *delimiter = [text substringWithRange:[match rangeAtIndex:1]];
    NSString *stringToFormat = [text substringWithRange:[match rangeAtIndex:2]];

    if ([delimiter isEqualToString:@"*"]) {
        NSLog(@"Make bold: '%@'", stringToFormat);
    } else if ([delimiter isEqualToString:@"_"]) {
        NSLog(@"Make italic: '%@'", stringToFormat);
    }
}
// Make bold: 'bold'
// Make italic: 'italic'
```

For basic replacement, head straight to `stringByReplacingMatches(in:options:range:with:)`, the long-winded version of `String.replacingOccurences(of:with:options:)`. In this case, we need to use different replacement templates for different matches (bold vs. italic), so we'll loop through the matches ourselves (moving in reverse order, so we don't mess up the ranges of later matches):

```swift
var formattedText = text
Format:
for match in matches.reversed() {
    let template: String
    switch text.substring(with: match.rangeAt(1)) ?? "" {
    case "*":
        template = "<strong>$2</strong>"
    case "_":
        template = "<em>$2</em>"
    default: break Format
    }
    let matchRange = formattedText.range(from: match.range)!    // see above
    let replacement = miniFormatter.replacementString(for: match,
                            in: formattedText, offset: 0, template: template)
    formattedText.replaceSubrange(matchRange, with: replacement)
}
// 'formattedText' is now:
// "MiniFormatter handles <strong>bold</strong> and <em>italic</em> text."
```

```objc
NSMutableString *formattedText = [NSMutableString stringWithString:text];
for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
    NSString *delimiter = [text substringWithRange:[match rangeAtIndex:1]];
    NSString *template = [delimiter isEqualToString:@"*"]
        ? @"<strong>$2</strong>"
        : @"<em>$2</em>";

    NSString *replacement = [miniFormatter replacementStringForResult:match
                                                             inString:formattedText
                                                               offset:0
                                                             template:template];
    [formattedText replaceCharactersInRange:[match range] withString:replacement];
}
// 'formattedText' is now:
// @"MiniFormatter handles <strong>bold</strong> and <em>italic</em> text."
```

Calling `miniFormatter.replacementString(for:in:...)` generates a replacement string specific to each `NSTextCheckingResult` instance with our customized template.

#### Expression and Matching Options

`NSRegularExpression` is highly configurable—you can pass different sets of options when creating an instance or when calling any method that performs matching.

##### `NSRegularExpression.Options`

Pass one or more of these as `options` when creating a regular expression.

- `.caseInsensitive`: Turns on case insensitive matching. Equivalent to the `i` flag.
- `.allowCommentsAndWhitespace`: Ignores any whitespace and comments between a `#` and the end of a line, so you can format and document your pattern in a vain attempt at making it readable. Equivalent to the `x` flag.
- `.ignoreMetacharacters`: The opposite of the `.regularExpression` option in `String.range(of:options:)`—this essentially turns the regular expression into a plain text search, ignoring any regular expression metacharacters and operators.
- `.dotMatchesLineSeparators`: Allows the `.` metacharacter to match line breaks as well as other characters. Equivalent to the `s` flag.
- `.anchorsMatchLines`: Allows the `^` and `$` metacharacters (beginning and end) to match the beginnings and ends of lines instead of just the beginning and end of the entire input string. Equivalent to the `m` flag.
- `.useUnixLineSeparators`, `.useUnicodeWordBoundaries`: These last two opt into more specific line and word boundary handling: UNIX line separators

##### `NSRegularExpression.MatchingOptions`

Pass one or more of these as `options` to any matching method on an `NSRegularExpression` instance.

- `.anchored`: Only match at the start of the search range.
- `.withTransparentBounds`: Allows the regex to look past the search range for lookahead, lookbehind, and word boundaries (though not for actual matching characters).
- `.withoutAnchoringBounds`: Makes the `^` and `$` metacharacters match only the beginning and end of the string, not the beginning and end of the search range.
- `.reportCompletion`, `.reportProgress`: These only have an effect when passed to the method detailed in the next section. Each option tells `NSRegularExpression` to call the enumeration block additional times, when searching is complete or as progress is being made on long-running matches, respectively.

## Partial Matching

Finally, one of the most powerful features of `NSRegularExpression` is the ability to scan only as far into a string as you need. This is especially valuable on a large string, or when using an pattern that is expensive to run.

Instead of using the `firstMatch(in:...)` or `matches(in:...)` methods, call `enumerateMatches(in:options:range:using:)` with a closure to handle each match. The closure receives three parameters: the match, a set of flags, and a pointer to a Boolean that acts as an out parameter, so you can stop enumerating at any time.

We can use this method to find the first several names in Dostoevsky's [_Brothers Karamazov_](http://www.gutenberg.org/files/28054/28054-0.txt), where names follow a first and patronymic middle name style (e.g., "Ivan Fyodorovitch"):

```swift
let nameRegex = try! NSRegularExpression(pattern: "([A-Z]\\S+)\\s+([A-Z]\\S+(vitch|vna))")

let bookString = ...
var names: Set<String> = []

nameRegex.enumerateMatches(in: bookString, range: bookString.nsrange) {
    (result, _, stopPointer) in
    guard let result = result else { return }
    let name = nameRegex.replacementString(for: result,
                    in: bookString, offset: 0, template: "$1 $2")
    names.insert(name)

    // stop once we've found six unique names
    stopPointer.pointee = ObjCBool(names.count == 6)
}
// names.sorted():
// ["Adelaïda Ivanovna", "Alexey Fyodorovitch", "Dmitri Fyodorovitch",
//  "Fyodor Pavlovitch", "Pyotr Alexandrovitch", "Sofya Ivanovna"]
```

```objc
NSString *namePattern = @"([A-Z]\\S+)\\s+([A-Z]\\S+(vitch|vna))";
NSRegularExpression *nameRegex = [NSRegularExpression
                                  regularExpressionWithPattern:namePattern
                                  options:kNilOptions
                                  error:&error];

NSString *bookString = ...
NSMutableSet *names = [NSMutableSet set];

[nameRegex enumerateMatchesInString:bookString
                            options:kNilOptions
                              range:NSMakeRange(0, [bookString length])
                         usingBlock:
^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
    if (result == nil) return;

    NSString *name = [nameRegex replacementStringForResult:result
                                                   inString:bookString
                                                     offset:0
                                                   template:@"$1 $2"];
    [names addObject:name];

    // stop once we've found six unique names
    *stop = (names.count == 6);
}];
```

With this approach we only need to look at the first 45 matches, instead of nearly 1300 in the entirety of the book. Not bad!

---

Once you get to know it, `NSRegularExpression` can be a truly useful tool. In fact, you may have used it already to find dates, addresses, or phone numbers in user-entered text—[`NSDataDetector`](/nsdatadetector/) is an `NSRegularExpression` subclass with patterns baked in to identify useful info. Indeed, as we've come to expect of text handling throughout Foundation, `NSRegularExpression` is thorough, robust, and has surprising depth beneath its tricky interface.
