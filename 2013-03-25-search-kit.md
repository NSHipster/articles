---
title: Search Kit
author: Mattt Thompson
category: Cocoa
excerpt: "Search Kit is a C framework for searching and indexing content in human languages. It supports matching on phrase or partial word, including logical & wildcard operators, and can rank results by relevance. Search Kit also provides document summarization, which is useful for generating representative excerpts. And best of all: it's thread-safe."
status:
    swift: t.b.c.
---

NSHipsters love irony, right? How about this for irony:

There's this framework called [Search Kit](https://developer.apple.com/library/mac/#documentation/UserExperience/Reference/SearchKit/Reference/reference.html), which despite being insanely powerful and useful for finding information, is something that almost no one has ever heard of.

It's true! I'd reckon there's a better chance that more of you have implemented your own search functionality from scratch than have ever even heard of Search Kit. (Heck, most people haven't even heard of [Core Services](https://developer.apple.com/library/mac/#documentation/Carbon/Reference/CoreServicesReferenceCollection/_index.html), its parent framework)

If only everyone knew that they could harness the same killer search functionality that Apple uses for their own applications...

---

Search Kit is a C framework for searching and indexing content in human languages. It supports matching on phrase or partial word, including logical (`AND`, `OR`) and wildcard (`*`) operators, and can rank results by relevance. Search Kit also provides document summarization, which is useful for generating representative excerpts. And best of all: it's thread-safe.

All of the whiz-bang search-as-you-type features in OS X—from Mail.app and Xcode to System Preferences and Spotlight—use Search Kit under the hood.

But to understand how Search Kit does its magic, it's important to explain some of the basics of Information Retrieval and Natural Language Processing.

> Be sure to check out [Apple's Search Kit Programming Guide](https://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/SearchKitConcepts/searchKit_intro/searchKit_intro.html) for an authoritative explanation of the what's, why's, and how's of this great framework.

## Search 101

Quoth Apple:

> You have an information need. But before you can ask a question, you need someone or something to ask. That is, you need to establish who or what you will accept as an authority for an answer. So before you ask a question you need to define the target of your question.

Finding the answer in a reasonable amount of time requires effort from the start. This is what that process looks like in general terms:

### Extract

First, content must be extracted from a [corpus](http://en.wikipedia.org/wiki/Text_corpus). For a text document, this could involve removing any styling, formatting, or other meta-information. For a data record, such as an `NSManagedObject`, this means taking all of the salient fields and combining it into a representation.

Once extracted, the content is [tokenized](http://en.wikipedia.org/wiki/Tokenization) for further processing.

### Filter

In order to get the most relevant matches, it's important to filter out common, or "stop" words like articles, pronouns, and helping verbs, that don't really contribute to overall meaning.

### Reduce

Along the same lines, words that mean basically the same thing should be reduced down into a common form. Morpheme clusters, such as grammatical conjugations like "computer", "computers", "computed", and "computing", for example, can all be simplified to be just "compute", using a [stemmer](http://en.wikipedia.org/wiki/Stemming). Synonyms, likewise, can be lumped into a common entry using a thesaurus lookup.

### Index

The end result of extracting, filtering, and reducing content into an array of normalized tokens is to form an [inverted index](http://en.wikipedia.org/wiki/Inverted_index), such that each token points to its origin in the index.

After repeating this process for each document or record in the corpus until, each token can point to many different articles. In the process of searching, a query is mapped onto one or many of these tokens, retrieving the union of the articles associated with each token.

## Using Search Kit

### Creating an Index

`SKIndexRef` is the central data type in Search Kit, containing all of the information needed to process and fulfill searches, and add information from new documents. Indexes can be persistent / file-based or ephemeral / in-memory. Indexes can either be created from scratch, or loaded from an existing file or data object—and once an index is finished being used, like many other C APIs, the index is closed.

### Adding Documents to an Index

`SKDocumentRef` is the data type associated with entries in the index. When a search is performed, documents (along with their context and relevance) are the results.

Each `SKDocumentRef` is associated with a URI.


For documents on the file system, the URI is simply the location of the file on disk:

~~~{objective-c}
NSURL *fileURL = [NSURL fileURLWithPath:@"/path/to/document"];
SKDocumentRef document = SKDocumentCreateWithURL((__bridge CFURLRef)fileURL);
~~~

For Core Data managed objects, the `NSManagedObjectID -URIRepresentation` can be used:

~~~{objective-c}
NSURL *objectURL = [objectID URIRepresentation];
SKDocumentRef document = SKDocumentCreateWithURL((__bridge CFURLRef)objectURL);
~~~

> For any other kinds of data, it would be up to the developer to define a URI representation.

When adding the contents of a `SKDocumentRef` to an `SKIndexRef`, the text can either be specified manually:

~~~{objective-c}
NSString *string = @"Lorem ipsum dolar sit amet"
SKIndexAddDocumentWithText(index, document, (__bridge CFStringRef)string, true);
~~~

...or collected automatically from a file:

~~~{objective-c}
NSString *mimeTypeHint = @"text/rtf"
SKIndexAddDocument(index, document, (__bridge CFStringRef)mimeTypeHint, true);
~~~

To change the way a file-based document's contents are processed, properties can be defined when creating the index:

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
