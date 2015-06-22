---
title: Search Kit
author: Mattt Thompson
translator: Ricky Tan
category: Cocoa
excerpt: "Search Kit is a C framework for searching and indexing content in human languages. It supports matching on phrase or partial word, including logical & wildcard operators, and can rank results by relevance. Search Kit also provides document summarization, which is useful for generating representative excerpts. And best of all: it's thread-safe."
excerpt: "Search Kit 是一个用人类语言来搜索和建立内容索引的 C 框架。它支持词组或部分单词匹配，包括逻辑操作和通配符，且能通过相关性对结果进行排序。Search Kit 也提供了文档总结功能，在生成有代表性的摘要时很有用。最重要的是：它是线程安全的。"
---

NSHipsters love irony, right? How about this for irony:

NSHipsters 喜欢讽刺，对吧？看看这个讽刺如何：

There's this framework called [Search Kit](https://developer.apple.com/library/mac/#documentation/UserExperience/Reference/SearchKit/Reference/reference.html), which despite being insanely powerful and useful for finding information, is something that almost no one has ever heard of.

有一个叫做 [Search Kit](https://developer.apple.com/library/mac/#documentation/UserExperience/Reference/SearchKit/Reference/reference.html) 的框架，尽管它在查找信息方面好用且强大到爆，却几乎没人听说过。

It's true! I'd reckon there's a better chance that more of you have implemented your own search functionality from scratch than have ever even heard of Search Kit. (Heck, most people haven't even heard of [Core Services](https://developer.apple.com/library/mac/#documentation/Carbon/Reference/CoreServicesReferenceCollection/_index.html), its parent framework)

这是真的！比起听说过 Search Kit，我猜你们大部分人更可能从零开始实现你自己的搜索功能。（真是哔了狗了，大部分人甚至都没听说过 [Core Services](https://developer.apple.com/library/mac/#documentation/Carbon/Reference/CoreServicesReferenceCollection/_index.html)，它的父框架）

If only everyone knew that they could harness the same killer search functionality that Apple uses for their own applications...

但愿每个人都知道他们本可以在他们自己的应用中使用苹果公司使用的杀手锏级搜索功能……

---

Search Kit is a C framework for searching and indexing content in human languages. It supports matching on phrase or partial word, including logical (`AND`, `OR`) and wildcard (`*`) operators, and can rank results by relevance. Search Kit also provides document summarization, which is useful for generating representative excerpts. And best of all: it's thread-safe.

Search Kit 是一个用人类语言来搜索和建立内容索引的 C 框架。它支持词组或部分单词匹配，包括逻辑操作和通配符，且能通过相关性对结果进行排序。Search Kit 也提供了文档总结功能，在生成有代表性的摘要时很有用。最重要的是：它是线程安全的。

All of the whiz-bang search-as-you-type features in OS X—from Mail.app and Xcode to System Preferences and Spotlight—use Search Kit under the hood.

取得极大成功的即打即搜的特性底层都是 Search Kit，从 OS X 的邮件，Xcode 到系统偏好和 Spotlight。

But to understand how Search Kit does its magic, it's important to explain some of the basics of Information Retrieval and Natural Language Processing.

但是想要理解 Search Kit 为何如此神奇，那还得解释一下一些信息检索和自然语言处理的基础概念。

> Be sure to check out [Apple's Search Kit Programming Guide](https://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_intro/searchKit_intro.html) for an authoritative explanation of the what's, why's, and how's of this great framework.

> 一定要去看看 [苹果 Search Kit 编程指南](https://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_intro/searchKit_intro.html) 以得到这个屌爆的框架是什么，为什么和怎么会的一个权威解释。

## Search 101

Quoth Apple:

引用自苹果：

> You have an information need. But before you can ask a question, you need someone or something to ask. That is, you need to establish who or what you will accept as an authority for an answer. So before you ask a question you need to define the target of your question.

> 你有一条需要的信息。但是在你开始问问题之前，你需要一个可以问的东西。那就是，你需要确立一个你能接受的人或物作为答案的权威认证。所以在你问问题之前你需要定义你问题的目标。


Finding the answer in a reasonable amount of time requires effort from the start. This is what that process looks like in general terms:

在合理时间内找到答案需要从一开始就作出努力。笼统地说，即这个过程看起来是怎样的：

### Extract

### 抽取

First, content must be extracted from a [corpus](http://en.wikipedia.org/wiki/Text_corpus). For a text document, this could involve removing any styling, formatting, or other meta-information. For a data record, such as an `NSManagedObject`, this means taking all of the salient fields and combining it into a representation.

首先，内容必须从 [语料库](https://zh.wikipedia.org/wiki/%E8%AF%AD%E6%96%99%E5%BA%93) 中抽取出来。对一个文本文档而言，这会涉及到移除样式，格式或其他元信息。对一个数据记录而言，比如 `NSManagedObject`，这意味着将所有主要的字段合并为一种表示形式。

Once extracted, the content is [tokenized](http://en.wikipedia.org/wiki/Tokenization) for further processing.

一旦抽取完毕，内容将被 [符号化](http://en.wikipedia.org/wiki/Tokenization) 为后续过程作准备。

### Filter

### 过滤

In order to get the most relevant matches, it's important to filter out common, or "stop" words like articles, pronouns, and helping verbs, that don't really contribute to overall meaning.

为了得到最相关的匹配，过滤掉常见的，对整体意思表达没有帮助的“停止”词汇是十分重要的，如冠词，代词和助动词。

### Reduce

### 简化

Along the same lines, words that mean basically the same thing should be reduced down into a common form. Morpheme clusters, such as grammatical conjugations like "computer", "computers", "computed", and "computing", for example, can all be simplified to be just "compute", using a [stemmer](http://en.wikipedia.org/wiki/Stemming). Synonyms, likewise, can be lumped into a common entry using a thesaurus lookup.

在同一行中，表达同一事物的词语应当简化为一个共同的形式。词素组，如语法上的动词变化，举个例子像 "computer"，"computers"，"computed"，"computing" 都可以用 [词干提取](https://zh.wikipedia.org/wiki/%E8%AF%8D%E5%B9%B2%E6%8F%90%E5%8F%96) 简化为 "compute"。同样地，同义词可以用同义词表归并为统一的条目。

### Index

### 索引

The end result of extracting, filtering, and reducing content into an array of normalized tokens is to form an [inverted index](http://en.wikipedia.org/wiki/Inverted_index), such that each token points to its origin in the index.

抽取、过滤、简化过的内容变为一个正则化的符号数组，其最终结果是生成一个 [倒排索引](https://zh.wikipedia.org/wiki/%E5%80%92%E6%8E%92%E7%B4%A2%E5%BC%95)，如此一来每个符号指向它在索引中的来源位置。

After repeating this process for each document or record in the corpus until, each token can point to many different articles. In the process of searching, a query is mapped onto one or many of these tokens, retrieving the union of the articles associated with each token.

对全集中的每一份文档或记录重复这一过程之后，每个符号可以指向许多不同的文章。在搜索过程中，一个查询映射到一个或多个符号，检索出符号对应的文章的并集。

## Using Search Kit

## 使用 Search Kit

### Creating an Index

### 创建索引

`SKIndexRef` is the central data type in Search Kit, containing all of the information needed to process and fulfill searches, and add information from new documents. Indexes can be persistent / file-based or ephemeral / in-memory. Indexes can either be created from scratch, or loaded from an existing file or data object—and once an index is finished being used, like many other C APIs, the index is closed.

`SKIndexRef` 是 Search Kit 的核心数据类型，它包含所有所需要的信息，用来处理及实现搜索，以及为新文档添加信息。索引可以是持久的 / 基于文件，或暂时的 / 内存中。索引既可以从头开始创建，也可以从已有的文件或数据对象加载，一旦索引用完了，就像许多其它 C 接口一样，索引就关闭了。

### Adding Documents to an Index

### 向索引中添加文档

`SKDocumentRef` is the data type associated with entries in the index. When a search is performed, documents (along with their context and relevance) are the results.

`SKDocumentRef` 是与索引中的条目相对应的数据类型。当一次搜索执行完毕，文档（包括它们的内容和相关度）就是结果。

Each `SKDocumentRef` is associated with a URI.

每个 `SKDocumentRef` 都关联着一个 URI。


For documents on the file system, the URI is simply the location of the file on disk:

对于文件系统上的文档，URI 就是文件在磁盘上的路径：

~~~{objective-c}
NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/document"];
SKDocumentRef document = SKDocumentCreateWithURL((__bridge CFURLRef)fileURL);
~~~

For Core Data managed objects, the `NSManagedObjectID -URIRepresentation` can be used:

对于 Core Data 管理的对象，可以用 `NSManagedObjectID -URIRepresentation`：

~~~{objective-c}
NSURL *objectURL = [objectID URIRepresentation];
SKDocumentRef document = SKDocumentCreateWithURL((__bridge CFURLRef)objectURL);
~~~

> For any other kinds of data, it would be up to the developer to define a URI representation.

> 对于任何其它数据，由开发者自己定义 URI 表示。


When adding the contents of a `SKDocumentRef` to an `SKIndexRef`, the text can either be specified manually:

当向 `SKIndexRef` 添加 `SKDocumentRef` 的内容时，文本既可以手动指定：

~~~{objective-c}
NSString *string = @"Lorem ipsum dolar sit amet"
SKIndexAddDocumentWithText(index, document, (__bridge CFStringRef)string, true);
~~~

...or collected automatically from a file:

...也可以从文件自动采集：

~~~{objective-c}
NSString *mimeTypeHint = @"text/rtf"
SKIndexAddDocument(index, document, (__bridge CFStringRef)mimeTypeHint, true);
~~~

To change the way a file-based document's contents are processed, properties can be defined when creating the index:

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

### Searching

### 搜索

`SKSearchRef` is the data type constructed to perform a search on an `SKIndexRef`. It contains a reference to the index, a query string, and a set of options:



~~~{objective-c}
NSString *query = @"kind of blue";
SKSearchOptions options = kSKSearchOptionDefault;
SKSearchRef search = SKSearchCreate(index, (CFStringRef)query, options);
~~~

`SKSearchOptions` is a bitmask with the following possible values:

> - `kSKSearchOptionDefault`: Default search options include:
>   - Relevance scores will be computed
>   - Spaces in a query are interpreted as Boolean AND operators.
>   - Do not use similarity searching.

These options can be specified individually as well:

> - `kSKSearchOptionNoRelevanceScores`: This option saves time during a search by suppressing the computation of relevance scores.
> - `kSKSearchOptionSpaceMeansOR`: This option alters query behavior so that spaces are interpreted as Boolean OR operators.
> - `kSKSearchOptionFindSimilar`: This option alters query behavior so that Search Kit returns references to documents that are similar to an example text string. When this option is specified, Search Kit ignores all query operators.

Putting this all together is `SKIndexCopyDocumentURLsForDocumentIDs`, which performs the search and fills arrays with the results. Iterating through the range of found matches provides access to the document URL and relevance score (if calculated):

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

> For more examples of Search Kit in action, be sure to check out [Indragie Karunaratne's](https://github.com/indragiek) project, [SNRSearchIndex](https://github.com/indragiek/SNRSearchIndex).

---

And so this article becomes yet another document in the corpus we call the Internet. By pointing to Search Kit, and explaining even the briefest of its features, this—the strings of tokens you read at this very moment—are (perhaps) making it easier for others to find Search Kit.

...and it's a good thing, too, because Search Kit is a wonderful and all-too-obscure framework, which anyone building a content-based system would do well to investigate.
