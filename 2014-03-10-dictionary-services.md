---
layout: post
title: "UIReferenceLibraryViewController /<br/>DCSDictionaryRef/<br/>/usr/share/dict/words"
category: ""
description: "虽然字典的地位很大程度上已经被基于网络的“一键释义”功能所替代，但是字典和词汇表在拼写检查、语法检查、自动纠错、自动摘要、语义分析等领域，仍然在幕后扮演着重要角色。"
translator: "Croath Liu"
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

通常情况下拥有对二进制文件读权限才可以获得相关的数据，但幸运的是Core Services为我们提供了相关的API。

#### 获取单词的释义

在Mac OS X获取一个单词的释义，需要用到Core Services framework的`DCSCopyTextDefinition`函数：

~~~{objective-c}
#import <CoreServices/CoreServices.h>

NSString *word = @"apple";
NSString *definition = (__bridge_transfer NSString *)DCSCopyTextDefinition(NULL, (__bridge CFStringRef)word, CFRangeMake(0, [word length]));
NSLog(@"%@", definition);
~~~

先别急用，我们来看看这些牛逼的字典到底是怎么被获取数据的。

看起来这些字典好像都进到了第一个`NULL`参数里。按照这个函数的定义来收，你可能想在这里放一个`DCSCopyTextDefinition`类型的数据，但是没有public的函数让你使用这个类型，所以让它成为`NULL`是唯一的解决办法了，就如文档里面所说：

> 此参数为预留参数，可能在以后会被用到，目前暂时传递`NULL`即可。字典服务会在所有可用状态（active）的字典中搜索相关信息。

"在**所有可用状态的字典**中搜索相关信息"？听起来像一个漏洞啊！

#### 将字典设为可用（Active）状态

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

看到这里你可能会愤怒地说："但这是Mac OS X啊，一般应用是不能通过沙箱从Cupertino获取manifest权限的，就没有更方便的方法么？比如说私有API？"

答案是：当然有。

### 私有API

这些API没有公开暴露出来，但是为了满足我们对字典的渴望，这些API仍然能够通过调用Core Services的一些函数来实现：

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

这些API都是私有的，所以当然也不会有文档来解释他们的用途和使用方法，所以先来看一下到底怎么用这些API吧：

#### 获取可用字典

~~~{objective-c}
NSMapTable *availableDictionariesKeyedByName =
    [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn
                          valueOptions:NSPointerFunctionsObjectPointerPersonality];

for (id dictionary in (__bridge_transfer NSArray *)DCSCopyAvailableDictionaries()) {
    NSString *name = (__bridge NSString *)DCSDictionaryGetName((__bridge DCSDictionaryRef)dictionary);
    [availableDictionariesKeyedByName setObject:dictionary forKey:name];
}
~~~

#### 获取单词释义

在上述处理中获取了很多难以琢磨的`DCSDictionaryRef`类型的实例，现在用这些实例我们来看看能对第一个参数`DCSCopyTextDefinition`做些什么事：

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

这种方法最有趣的地方是你要从HTML格式的内容中来获取有用的信息，这些HTML还包含了CSS文件，他们都是用来在系统的字典应用(Dictionary.app)来显示内容用的。

> 如果你是个好奇宝宝，或者是对语言学有偏爱的怪咖，可以看看[单词"apple"的HTML信息](https://gist.github.com/mattt/9453538)。

写这篇文章的时候，我顺便也就写了一个[Objective-C wrapper](https://github.com/mattt/DictionaryKit)，这个库通过私有API从我们喜爱的水果公司来取禁果（所以不要把这个库放到你需要提交到App Store的应用中使用）。

* * *

## iOS

iOS开发毫无疑问是一件照本宣科的事，所以尝试逆向工程会比技术尝试更有用一点。幸运的是并不需要这样做了，因为有一批关于UIKit的`UIReferenceLibraryViewController`在iOS5之后API已经开放。

`UIReferenceLibraryViewController`和`MFMessageComposeViewController`很相似，提供了最小化配置的系统层view controller，可以直接被present显示。

用需要查找term来进行初始化：

~~~{objective-c}
UIReferenceLibraryViewController *referenceLibraryViewController =
    [[UIReferenceLibraryViewController alloc] initWithTerm:@"apple"];
[viewController presentViewController:referenceLibraryViewController
                             animated:YES
                           completion:nil];
~~~

这种行为和用户点击`UITextView`中高亮词汇弹出的"定义"的`UIMenuItem`的效果差不多。

`UIReferenceLibraryViewController`也提供了一个类方法`dictionaryHasDefinitionForTerm:`，开发者可以在dictionary view controller出现之前调用这个方法，就可以在不必需的时候不显示那个view controller了。

~~~{objective-c}
[UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:@"apple"];
~~~

> 在这两种情况下，`UIReferenceLibraryViewController`会以非常好的形式去格式化搜索结果，所以并不需要开发者手动去掉空格或者调整大小写来优化搜索。

* * *

无论是Unix的词汇表还是基于其发展而来的OS X（或iOS）的`.dictionary` bundles，它与数学常量以及Apple的"Sosumi"提醒一样，对于编程来说都是至关重要的。你可以思考一下如何将上述API引入你的app，或者用它们来创建你以前从未尝试过的应用。这里有很多Apple系统内部关于语言学的链接供你参考：a [wealth](http://nshipster.com/nslocalizedstring/) [of](http://nshipster.com/nslinguistictagger/) [linguistic](http://nshipster.com/search-kit/) [technologies](http://nshipster.com/uilocalizedindexedcollation/)。
