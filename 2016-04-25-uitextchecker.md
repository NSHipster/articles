---
title: UITextChecker
author: Croath Liu
category: Cocoa
excerpt: "Make no mistake, a tiny keyboard on a slab of glass doesn't always lend itself to perfect typing. Whether for accuracy or hilarity, anyone typing on an iOS device notices when autocorrect steps in to help out. You might not know, however, that UIKit includes a class to help you with your user's typing inside your app."
status:
    swift: 2.2
---

Make no mistake, a tiny keyboard on a slab of glass doesn't always lend itself to perfect typing. Whether for accuracy or hilarity, anyone typing on an iOS device notices when autocorrect steps in to help out. You might not know, however, that UIKit includes a class to help you with your user's typing inside your app.

毫无疑问，玻璃板上的一个小键盘并不总适合完美的打字。 无论是准确性还是愉悦程度，在 iOS 设备上打过字的都看到过自动更正提示。 你可能不知道，UIKit 包括一个类，可以在应用程序内帮助你的用户的打字。

First introduced in iOS 3.2 (or should we call it iPhone OS 3.2, given the early date?), `UITextChecker` does exactly what it says: it checks text. Read on to learn how you can use this class for spell checking and text completion.

`UITextChecker` 首先在 iOS 3.2 中引入（或者我们应该把它叫做 iPhone OS 3.2？），完全按照它的描述工作着：检查文本。 下面将介绍如何使用此类进行拼写检查和文本自动完成。

---

## Spell Checking

## 文本检查

What happens if you mistype a word in iOS? Type "hipstar" into a text field and iOS will offer to autocorrect to "hipster" most of the time. 

如果你不小心在 iOS 中打错了字，会发生什么？ 比如，在文本框中输入 “hipstar”，iOS 基本上会提供自动更正为 “hipster” 的提示。

![Autocorrecting 'hipstar']({{ site.asseturl }}/uitextchecker-hipstar.png)

We can find the same suggested substitution using `UITextChecker`:

我们可以使用 `UITextChecker` 找到相同的替换建议：

```swift
import UIKit

let str = "hipstar"
let textChecker = UITextChecker()
let misspelledRange = textChecker.rangeOfMisspelledWordInString(
        str, range: NSRange(0..<str.utf16.count), 
        startingAt: 0, wrap: false, language: "en_US")

if misspelledRange.location != NSNotFound,
    let guesses = textChecker.guessesForWordRange(
        misspelledRange, inString: str, language: "en_US") as? [String] 
{
    print("First guess: \(guesses.first)")
    // First guess: hipster
} else {
    print("Not found")
}
```
```objective-c
NSString *str = @"hipstar";
UITextChecker *textChecker = [[UITextChecker alloc] init];
NSRange misspelledRange = [textChecker 
                           rangeOfMisspelledWordInString:str 
                           range:NSMakeRange(0, [str length]) 
                           startingAt:0 
                           wrap:NO 
                           language:@"en_US"];
                             
NSArray *guesses = [NSArray array];
if (misspelledRange.location != NSNotFound) {
    guesses = [textChecker guessesForWordRange:misspelledRange 
                                      inString:str 
                                      language:@"en_US"];
    NSLog(@"First guess: %@", [guesses firstObject]);
    // First guess: hipster
} else {
    NSLog(@"Not found");
}
```

The returned array of strings _might_ look like this one:

返回的字符串数组_可能_如下所示：

```swift
["hipster", "hip star", "hip-star", "hips tar", "hips-tar"]
```

Or it might not---`UITextChecker` produces context- and device-specific guesses. According to the documentation, `guessesForWordRange(_:inString:language:)` "returns an array of strings, in the order in which they should be presented, representing guesses for words that might have been intended in place of the misspelled word at the given range in the given string."

也可能不是 --- `UITextChecker` 会依据上下文和特定的情况给出猜测。根据文档，`guessesForWordRange(_:inString:language:)` "返回一个字符串数组，并以它们应该出现的顺序排序，表示给定字符串中的给定范围内可以替换的拼写错误的猜测 “。

So no guarantee of idempotence or correctness, which makes sense for a method with `guesses...` in the name. How can NSHipsters trust a method that changes its return value? We'll find the answer if we dig further.

所以并不能保证正确性，这对于一个以 `guesses...` 开头的方法来说还是挺合理的。 NSHipster 们要如何信任一个其返回值随时改变的方法呢？ 如果我们进一步挖掘，我们会找到答案。

## Learning New Words

## 新词学习

Let's assume that you want your users to be able to type `"hipstar"` exactly. Let your app know that by telling it to learn the word, using the `UITextChecker.learnWord(_:)` class method:

让我们假设你希望你的用户能够准确输入 `"hipstar"`。 那么你需要使用 `UITextChecker.learnWord(_:)` 类方法来告诉你的应用程序来学习这个词：

```swift
UITextChecker.learnWord(str)
```
```objective-c
[UITextChecker learnWord:str];
```

`"hipstar"` is now a recognized word for the whole device and won't show up as misspelled in further checks.

`"hipstar"` 现在变成了整个设备都能认识的词，并且在后续的拼写检查中也不会被显示为拼写错误。

```swift
let misspelledRange = textChecker.rangeOfMisspelledWordInString(str, 
        range: NSRange(0..<str.utf16.count), 
        startingAt: 0, wrap: false, language: "en_US")
// misspelledRange.location == NSNotFound
```
```objective-c
NSRange misspelledRange = [textChecker 
                           rangeOfMisspelledWordInString:str 
                           range:NSMakeRange(0, [str length]) 
                           startingAt:0 
                           wrap:NO 
                           language:@"en_US"];
// misspelledRange.location == NSNotFound
```

As expected, the search above returns `NSNotFound`, for `UITextChecker` has learned the word we created. `UITextChecker` also provides class methods for checking and unlearning words: `UITextChecker.hasLearnedWord(_:)` and `UITextChecker.unlearnWord(_:)`.

正如所料，上面的搜索返回 `NSNotFound`，因为 `UITextChecker` 已经学会了我们创建的词。 `UITextChecker` 还提供类方法来检查和取消学习单词：`UITextChecker.hasLearnedWord(_:)` 和 `UITextChecker.unlearnWord(_:)`。

## Suggesting Completions

## 建议完成

There's one more `UITextChecker` API, this time for finding possible completions for a partial word:

还有另外一个 `UITextChecker` API，可以根据片段找出可能的完整词：

```swift
let partial = "hipst"
let completions = textChecker.completionsForPartialWordRange(
        NSRange(0..<partial.utf16.count), inString: partial, 
        language: "en_US")
// completions == ["hipster", "hipsters"]
```
```objective-c
NSString *partial = @"hipst";
NSArray *completions = [textChecker
                        completionsForPartialWordRange:NSMakeRange(0, [partial length])
                        inString:partial
                        language:@"en_US"];
// completions == ["hipster", "hipsters"]
```

`completionsForPartialWordRange` gives you an array of possible words from a group of initial characters. Although the documentation states that the returned array of strings will be sorted by probability, `UITextChecker` only sorts the completions alphabetically. `UITextChecker`'s OS X-based sibling,  `NSSpellChecker`, does behave as it describes.

`completionsForPartialWordRange` 给出一组根据初始字符的可能单词的数组。虽然文档声明返回的字符串数组是按概率排序的，但 `UITextChecker` 仅按结果的字母顺序排序。 `UITextChecker` 在 OS X 的对应类别是 `NSSpellChecker`。它的行为和它描述的一样。

> You won't see any of the custom words you've taught `UITextChecker` show up as possible completions. Why not? Since vocabulary added via `UITextChecker.learnWord(_:)` is global to the device, this prevents your app's words from showing up in another app's autocorrections.

> 你不会看到任何你教 `UITextChecker` 的自定义单词显示到可能的完成列表里。 为什么呢？ 因为通过 `UITextChecker.learnWord(_:)` 添加的词汇对设备来说是全局的，这会阻止一个应用程序的单词显示在另一个应用程序的自动更正中。

---

Building an app that leans heavily on a textual interface? Use `UITextChecker` to make sure the system isn't flagging your own vocabulary. Writing a keyboard extension? With `UITextChecker` and `UILexicon`, which provides common and user-defined words from the system-wide dictionary and first and last names from the user’s address book, you can support nearly any language without creating your own dictionaries!

如果你正在开发一个大量基于文本界面的应用程序，请使用 `UITextChecker` 来确保系统不会把你自己的词汇标注错误。 如果你正在写一个键盘扩展，可以使用 `UITextChecker` 和 `UILexicon`，它提供了来自系统范围级字典的用户自定义单词以及来自用户地址簿的姓和名，你可以支持几乎任何语言，而无需创建自己的字典！
