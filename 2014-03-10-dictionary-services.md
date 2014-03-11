---
layout: post
title: "UIReferenceLibraryViewController /<br/>DCSDictionaryRef/<br/>/usr/share/dict/words"
framework: ""
rating: 6.5
description: "虽然字典的地位很大程度上已经被基于网络的“一键释义”功能所替代，但是字典和词汇表在拼写检查、语法检查、自动纠错、自动摘要、语义分析等领域，仍然在幕后扮演着重要角色。"
---

本周的主题是字典。我们讨论的不是日常开发中经常遇到的`NSDictionary` 或 `CFDictionaryRef`，而是已经离你远去了的、学生时代常用的字典。

> 不过如果认真讨论一下，为什么字典会被称作“字典”呢？为什么我们不能像Ruby语言等直接叫它哈希（`Hash`）？字典到底是什么？不断通过Hash函数加密内容来解释语义？哈哈，字典其实没那么糟糕吧。我认为用“组合起来的数组”来描述他再适合不过了。

虽然字典的地位很大程度上已经被基于网络的“一键释义”功能所替代，但是字典和词汇表在拼写检查、语法检查、自动纠错、自动摘要、语义分析等领域，仍然在幕后扮演着重要角色。所以为了方便下面的讨论，我们先回顾一下字典在Unix、Mac OS X和iOS系统上的展现形式和被赋予的意义。

* * *

## Unix

几乎所有Unix的发行版都包含一些用换行分割的词表文件。在Mac OS X上，你可以在`/usr/share/dict`找到他们：

~~~
$ ls /usr/share/dict
    README
    connectives
    propernames
    web2
    web2a
    words@ -> web2
~~~

连接到`words`的`web2`词表，虽然内容不是很详尽，但还是相当占了相当大的空间的：

~~~
$ wc /usr/share/dict/words
    235886  235886 2493109
~~~

如果你把它的头部打出来你就会发现其实这里面的内容相当有趣。我异常兴奋地发现了一堆以"a"开头的词：

~~~
$ head /usr/share/dict/words
    A
    a
    aa
    aal
    aalii
    aam
    Aani
    aardvark
    aardwolf
    Aaron
~~~

这些系统提供的巨大词表文件让`grep`纵横交错的文字难题、生成易于记忆的密码、种子数据库都变得简单。但从用户的视角来看，`/usr/share/dict`只是一个缺乏整体意义的单词表，所以对日常的使用没什么太大意义。

Mac OS X在这个基础上构建了系统词典。OS X在对扩展壮大Unix的功能性方面从未让人失望，于是它不遗余力地发布了很多基于bundles和plist文件的字典。

* * *

## OS X

Mac OS X模仿`/usr/share/dict`的结构，创造了`/Library/Dictionaries`目录。
我们现在就看一下OS X在共享性的系统字典方面比Unix有所超越的地方————它同样认同非英语字典的存在：

~~~
$ ls /Library/Dictionaries/

    Apple Dictionary.dictionary/
    Diccionario General de la Lengua Española Vox.dictionary/
    Duden Dictionary Data Set I.dictionary/
    Dutch.dictionary/
    Italian.dictionary/
    Korean - English.dictionary/
    Korean.dictionary/
    Multidictionnaire de la langue française.dictionary/
    New Oxford American Dictionary.dictionary/
    Oxford American Writer's Thesaurus.dictionary/
    Oxford Dictionary of English.dictionary/
    Oxford Thesaurus of English.dictionary/
    Sanseido Super Daijirin.dictionary/
    Sanseido The WISDOM English-Japanese Japanese-English Dictionary.dictionary/
    Simplified Chinese - English.dictionary/
    The Standard Dictionary of Contemporary Chinese.dictionary/
~~~

Mac OS X为我们带来了包括英文字典在内的汉语、法语、德语、意大利语、日语、韩语专业字典，甚至包含一个专门讲解Apple术语的字典！

让我们研究的更深一点，看看这些`.dictionary`的bundle文件里面到底有什么：

~~~
$ ls "/Library/Dictionaries/New Oxford American Dictionary.dictionary/Contents"

    Body.data
    DefaultStyle.css
    EntryID.data
    EntryID.index
    Images/
    Info.plist
    KeyText.data
    KeyText.index
    Resources/
    _CodeSignature/
    version.plist
~~~

通过对字典文件结构的观察，确实可以发现一些有趣的细节。观察新牛津字典（New Oxford American Dictionary），可以发现如下内容：

- 二进制编码的 `KeyText.data`、`KeyText.index`和`Content.data`文件
- 用于绘制的CSS文件
- 从A-Frame到Zither共1207张图片
- 用于切换到[US English Diacritical Pronunciation](http://en.wikipedia.org/wiki/Pronunciation_respelling_for_English)和[IPA](http://en.wikipedia.org/wiki/International_Phonetic_Alphabet) (International Phonetic Alphabet)的链接
- Manifest和签名文件

Normally, proprietary binary encoding would be the end of the road in terms of what one could reasonably do with data, but luckily, Core Services provides APIs to read this information.

#### Getting Definition of Word

To get the definition of a word on Mac OS X, one can use the `DCSCopyTextDefinition` function, found in the Core Services framework:

~~~{objective-c}
#import <CoreServices/CoreServices.h>

NSString *word = @"apple";
NSString *definition = (__bridge_transfer NSString *)DCSCopyTextDefinition(NULL, (__bridge CFStringRef)word, CFRangeMake(0, [word length]));
NSLog(@"%@", definition);
~~~

Wait, where did all of those great dictionaries go?

Well, they all disappeared into that first `NULL` argument. One might expect to provide a `DCSCopyTextDefinition` type here, as prescribed by the function definition. However, there are no public functions to construct or copy such a type, making `NULL` the only available option. The documentation is as clear as it is stern:

> This parameter is reserved for future use, so pass `NULL`. Dictionary Services searches in all active dictionaries.

"Dictionary Services searches in **all active dictionaries**", you say? Sounds like a loophole!

#### Setting Active Dictionaries

Now, there's nothing programmers love to hate to love more than the practice of exploiting loopholes to side-step Apple platform restrictions. Behold: an entirely error-prone approach to getting, say, thesaurus results instead of the first definition available in the standard dictionary:

~~~{objective-c}
NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
NSMutableDictionary *dictionaryPreferences = [[userDefaults persistentDomainForName:@"com.apple.DictionaryServices"] mutableCopy];
NSArray *activeDictionaries = [dictionaryPreferences objectForKey:@"DCSActiveDictionaries"];
dictionaryPreferences[@"DCSActiveDictionaries"] = @[@"/Library/Dictionaries/Oxford American Writer's Thesaurus.dictionary"];
[userDefaults setPersistentDomain:dictionaryPreferences forName:@"com.apple.DictionaryServices"];
{
    NSString *word = @"apple";
    NSString *definition = (__bridge_transfer NSString *)DCSCopyTextDefinition(NULL, (__bridge CFStringRef)word, CFRangeMake(0, [word length]));
    NSLog(@"%@", definition);
}
dictionaryPreferences[@"DCSActiveDictionaries"] = activeDictionaries;
[userDefaults setPersistentDomain:dictionaryPreferences forName:@"com.apple.DictionaryServices"];
~~~

"But this is Mac OS X, a platform whose manifest destiny cannot be contained by meager sandboxing attempts from Cupertino!", you cry. "Isn't there a more civilized approach? Like, say, private APIs?"

Why yes, yes there are.

### Private APIs

Not publicly exposed, but still available through Core Services are a number of functions that cut closer to the dictionary services functionality that we crave:

~~~{objective-c}
extern CFArrayRef DCSCopyAvailableDictionaries();
extern CFStringRef DCSDictionaryGetName(DCSDictionaryRef dictionary);
extern CFStringRef DCSDictionaryGetShortName(DCSDictionaryRef dictionary);
extern DCSDictionaryRef DCSDictionaryCreate(CFURLRef url);
extern CFStringRef DCSDictionaryGetName(DCSDictionaryRef dictionary);
extern CFArrayRef DCSCopyRecordsForSearchString(DCSDictionaryRef dictionary, CFStringRef string, void *, void *);

extern CFDictionaryRef DCSCopyDefinitionMarkup(DCSDictionaryRef dictionary, CFStringRef record);
extern CFStringRef DCSRecordCopyData(CFTypeRef record);
extern CFStringRef DCSRecordCopyDataURL(CFTypeRef record);
extern CFStringRef DCSRecordGetAnchor(CFTypeRef record);
extern CFStringRef DCSRecordGetAssociatedObj(CFTypeRef record);
extern CFStringRef DCSRecordGetHeadword(CFTypeRef record);
extern CFStringRef DCSRecordGetRawHeadword(CFTypeRef record);
extern CFStringRef DCSRecordGetString(CFTypeRef record);
extern CFStringRef DCSRecordGetTitle(CFTypeRef record);
extern DCSDictionaryRef DCSRecordGetSubDictionary(CFTypeRef record);
~~~

Private as they are, these functions aren't about to start documenting themselves, so let's take a look at how they're used:

#### Getting Available Dictionaries

~~~{objective-c}
NSMapTable *availableDictionariesKeyedByName =
    [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn
                          valueOptions:NSPointerFunctionsObjectPointerPersonality];

for (id dictionary in (__bridge_transfer NSArray *)DCSCopyAvailableDictionaries()) {
    NSString *name = (__bridge NSString *)DCSDictionaryGetName((__bridge DCSDictionaryRef)dictionary);
    [availableDictionariesKeyedByName setObject:dictionary forKey:name];
}
~~~

#### Getting Definition for Word

With instances of the elusive `DCSDictionaryRef` type available at our disposal, we can now see what all of the fuss is about with that first argument in `DCSCopyTextDefinition`:

~~~{objective-c}
NSString *word = @"apple";

for (NSString *name in availableDictionariesKeyedByName) {
    id dictionary = [availableDictionariesKeyedByName objectForKey:name];

    CFRange termRange = DCSGetTermRangeInString((__bridge DCSDictionaryRef)dictionary, (__bridge CFStringRef)word, 0);
    if (termRange.location == kCFNotFound) {
        continue;
    }

    NSString *term = [word substringWithRange:NSMakeRange(termRange.location, termRange.length)];

    NSArray *records = (__bridge_transfer NSArray *)DCSCopyRecordsForSearchString((__bridge DCSDictionaryRef)dictionary, (__bridge CFStringRef)term, NULL, NULL);
    if (records) {
        for (id record in records) {
            NSString *headword = (__bridge NSString *)DCSRecordGetHeadword((__bridge CFTypeRef)record);
            if (headword) {
                NSString *definition = (__bridge_transfer NSString*)DCSCopyTextDefinition((__bridge DCSDictionaryRef)dictionary, (__bridge CFStringRef)headword, CFRangeMake(0, [headword length]));
                NSLog(@"%@: %@", name, definition);

                NSString *HTML = (__bridge_transfer NSString*)DCSRecordCopyData((__bridge DCSDictionaryRef)dictionary, (__bridge CFStringRef)headword, CFRangeMake(0, [headword length]));
                NSLog(@"%@: %@", name, definition);
            }
        }
    }
}
~~~

Most surprising from this experimentation is the ability to access the raw HTML for entries, which  combined with a dictionary's bundled CSS, produces the result seen in Dictionary.app.

> For any fellow linguistics nerds or markup curious folks out there, here's [the HTML of the entry for the word "apple"]((https://gist.github.com/mattt/9453538)).

In the process of writing this article, I _accidentally_ created [an Objective-C wrapper](https://github.com/mattt/DictionaryKit) around this forbidden fruit (so forbidden by our favorite fruit company, so don't try submitting this to the App Store).

* * *

## iOS

iOS development is a decidedly more by-the-books affair, so attempting to reverse-engineer the platform would be little more than an academic exercise. Fortunately, a good chunk of functionality is available (as of iOS 5) through the obscure UIKit class `UIReferenceLibraryViewController`.

`UIReferenceLibraryViewController` is similar to an `MFMessageComposeViewController`, in that provides a minimally-configurable view controller around system functionality, intended to be presented modally.

Simply initialize with the desired term:

~~~{objective-c}
UIReferenceLibraryViewController *referenceLibraryViewController =
    [[UIReferenceLibraryViewController alloc] initWithTerm:@"apple"];
[viewController presentViewController:referenceLibraryViewController
                             animated:YES
                           completion:nil];
~~~

This is the same behavior that one might encounter by tapping the "Define" `UIMenuItem` on a highlighted word in a `UITextView`.

`UIReferenceLibraryViewController` also provides the class method `dictionaryHasDefinitionForTerm:`. A developer would do well to call this before presenting a dictionary view controller that will inevitably have nothing to display.

~~~{objective-c}
[UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:@"apple"];
~~~

> In both cases, it appears that `UIReferenceLibraryViewController` will do its best to normalize the search term, so stripping whitespace or changing to lowercase should not be necessary.

* * *

From Unix word lists to their evolved `.dictionary` bundles on OS X (and presumably iOS), words are as essential to application programming as mathematical constants and the "Sosumi" alert noise. Consider how the aforementioned APIs can be integrated into your own app, or used to create a kind of app you hadn't previously considered. There are a [wealth](http://nshipster.com/nslocalizedstring/) [of](http://nshipster.com/nslinguistictagger/) [linguistic](http://nshipster.com/search-kit/) [technologies](http://nshipster.com/uilocalizedindexedcollation/) baked into Apple's platforms, so take advantage of them.
