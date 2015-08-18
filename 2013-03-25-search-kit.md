---
title: Search Kit
author: Mattt Thompson
translator: Ricky Tan
category: Cocoa
excerpt: "Search Kit 是一个用人类语言来搜索和建立内容索引的 C 框架。它支持词组或部分单词匹配，包括逻辑操作和通配符，且能通过相关性对结果进行排序。Search Kit 也提供了文档总结功能，在生成有代表性的摘要时很有用。最重要的是：它是线程安全的。"
---

NSHipsters 喜欢讽刺，对吧？看看这个讽刺如何：

有一个叫做 [Search Kit](https://developer.apple.com/library/mac/#documentation/UserExperience/Reference/SearchKit/Reference/reference.html) 的框架，尽管它在查找信息方面好用且强大到爆，却几乎没人听说过。

这是真的！比起听说过 Search Kit，我猜你们大部分人更可能从零开始实现你自己的搜索功能。（真是够了，大部分人甚至都没听说过 [Core Services](https://developer.apple.com/library/mac/#documentation/Carbon/Reference/CoreServicesReferenceCollection/_index.html)，它的父框架）

但愿每个人都知道他们本可以在他们自己的应用中使用苹果公司使用的杀手锏级搜索功能……

---

Search Kit 是一个用人类语言来搜索和建立内容索引的 C 框架。它支持词组或部分单词匹配，包括逻辑操作和通配符，且能通过相关性对结果进行排序。Search Kit 也提供了文档总结功能，在生成有代表性的摘要时很有用。最重要的是：它是线程安全的。

取得极大成功的即打即搜的特性底层都是 Search Kit，从 OS X 的邮件，Xcode 到系统偏好和 Spotlight。

但是想要理解 Search Kit 为何如此神奇，那还得解释一下一些信息检索和自然语言处理的基础概念。

> 一定要去看看 [苹果 Search Kit 编程指南](https://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_intro/searchKit_intro.html) 以得到这个屌爆的框架是什么，为什么和怎么会的一个权威解释。

## Search 101

引用自苹果：

> 你有一条需要的信息。但是在你开始问问题之前，你需要一个可以问的东西。那就是，你需要确立一个你能接受的人或物作为答案的权威认证。所以在你问问题之前你需要定义你问题的目标。

在合理时间内找到答案需要从一开始就作出努力。笼统地说，即这个过程看起来是怎样的：

### 抽取

首先，内容必须从 [语料库](https://zh.wikipedia.org/wiki/%E8%AF%AD%E6%96%99%E5%BA%93) 中抽取出来。对一个文本文档而言，这会涉及到移除样式，格式或其他元信息。对一个数据记录而言，比如 `NSManagedObject`，这意味着将所有主要的字段合并为一种表示形式。

一旦抽取完毕，内容将被 [符号化](http://en.wikipedia.org/wiki/Tokenization) 为后续过程作准备。

### 过滤

为了得到最相关的匹配，过滤掉常见的，对整体意思表达没有帮助的“停止”词汇是十分重要的，如冠词，代词和助动词。

### 简化

在同一行中，表达同一事物的词语应当简化为一个共同的形式。词素组，如语法上的动词变化，举个例子像 "computer"，"computers"，"computed"，"computing" 都可以用 [词干提取](https://zh.wikipedia.org/wiki/%E8%AF%8D%E5%B9%B2%E6%8F%90%E5%8F%96) 简化为 "compute"。同样地，同义词可以用同义词表归并为统一的条目。

### 索引

抽取、过滤、简化过的内容变为一个正则化的符号数组，其最终结果是生成一个 [倒排索引](https://zh.wikipedia.org/wiki/%E5%80%92%E6%8E%92%E7%B4%A2%E5%BC%95)，如此一来每个符号指向它在索引中的来源位置。

对语料库中的每一份文档或记录重复这一过程之后，每个符号可以指向许多不同的文章。在搜索过程中，一个查询映射到一个或多个符号，检索出符号对应的文章的并集。

## 使用 Search Kit

### 创建索引

`SKIndexRef` 是 Search Kit 的核心数据类型，它包含所有所需要的信息，用来处理及实现搜索，以及为新文档添加信息。索引可以是持久的 / 基于文件，或暂时的 / 内存中。索引既可以从头开始创建，也可以从已有的文件或数据对象加载，一旦索引用完了，就像许多其它 C 接口一样，索引就关闭了。

### 向索引中添加文档

`SKDocumentRef` 是与索引中的条目相对应的数据类型。当一次搜索执行完毕，文档（包括它们的内容和相关度）就是结果。

每个 `SKDocumentRef` 都关联着一个 URI。

对于文件系统上的文档，URI 就是文件在磁盘上的路径：

~~~{objective-c}
NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/document"];
SKDocumentRef document = SKDocumentCreateWithURL((__bridge CFURLRef)fileURL);
~~~

对于 Core Data 管理的对象，可以用 `NSManagedObjectID -URIRepresentation`：

~~~{objective-c}
NSURL *objectURL = [objectID URIRepresentation];
SKDocumentRef document = SKDocumentCreateWithURL((__bridge CFURLRef)objectURL);
~~~

> 对于任何其它数据，由开发者自己定义 URI 表示。

当向 `SKIndexRef` 添加 `SKDocumentRef` 的内容时，文本既可以手动指定：

~~~{objective-c}
NSString *string = @"Lorem ipsum dolar sit amet"
SKIndexAddDocumentWithText(index, document, (__bridge CFStringRef)string, true);
~~~

...也可以从文件自动采集：

~~~{objective-c}
NSString *mimeTypeHint = @"text/rtf"
SKIndexAddDocument(index, document, (__bridge CFStringRef)mimeTypeHint, true);
~~~

为了改变基于文件的文档内容的处理方式，在创建索引时可以定义一些属性：

~~~{objective-c}
NSSet *stopwords = [NSSet setWithObjects:@"all", @"and", @"its", @"it's", @"the", nil];

NSDictionary *properties = @{
  @"kSKStartTermChars": @"", // additional starting-characters for terms
  @"kSKTermChars": @"-_@.'", // additional characters within terms
  @"kSKEndTermChars": @"",   // additional ending-characters for terms
  @"kSKMinTermLength": @(3),
  @"kSKStopWords":stopwords
};

SKIndexRef index = SKIndexCreateWithURL((CFURLRef)url, NULL, kSKIndexInverted, (CFDictionaryRef)properties);
~~~

### 搜索

`SKSearchRef` 是在 `SKIndexRef` 上执行搜索时构建的数据类型。它包含索引的引用，查询字符串，和一些选项：

~~~{objective-c}
NSString *query = @"kind of blue";
SKSearchOptions options = kSKSearchOptionDefault;
SKSearchRef search = SKSearchCreate(index, (CFStringRef)query, options);
~~~

`SKSearchOptions` 是有以下可能值的位掩码：

> - `kSKSearchOptionDefault`：默认搜索选项包括：
>   - 计算相关度的值
>   - 查询中的空格解释为逻辑**与**操作
>   - 不使用相似搜索

这些选项也可以单独指定：

> - `kSKSearchOptionNoRelevanceScores`：这个选项不计算相关度值可以节省搜索时间。
> - `kSKSearchOptionSpaceMeansOR`：这个选项将查询语句中的空格改为逻辑**或**操作。
> - `kSKSearchOptionFindSimilar`：这个选项使 Search Kit 返回与示例文本相似的文档引用。当这个选项指定时，Search Kit 忽略所有查询操作符。

将所有这些放到一起的是 `SKIndexCopyDocumentURLsForDocumentIDs`，它执行搜索然后用结果填充数组。在匹配的范围中遍历可以访问文档的 URL 和相关度值（如果计算了的话）：

~~~{objective-c}
NSUInteger limit = ...; // Maximum number of results
NSTimeInterval time = ...; // Maximum time to get results, in seconds
SKDocumentID documentIDs[limit];
CFURLRef urls[limit];
float scores[limit];
CFIndex count;
Boolean hasResult = SKSearchFindMatches(search, limit, documentIDs, scores, time, &count);

SKIndexCopyDocumentURLsForDocumentIDs(index, foundCount, documentIDs, urls);

NSMutableArray *mutableResults = [NSMutableArray array];
[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)] enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    CFURLRef url = urls[idx];
    float relevance = scores[idx];

    NSLog(@"- %@: %f", url, relevance);

    if (objectID) {
      [mutableResults addObject:(NSURL *)url];
    }

    CFRelease(url);
}];
~~~

> 更多 Search Kit 实例请查看 [Indragie Karunaratne's](https://github.com/indragiek) 项目，[SNRSearchIndex](https://github.com/indragiek/SNRSearchIndex)。


---

本文也成了互联网上语料库的另一个文档了。通过指向 Search Kit，并解释哪怕它最简单的特性，本文———— 你当前正在读的字符串符号 ———— （也许）让他人更容易地找到 Search Kit。

...当然了这也是一件好事，因为 Search Kit 是个了不起的又晦涩的框架，那些在建立基于内容的系统的人都将好好调研一下。
