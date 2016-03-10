---
title: "UIReferenceLibraryViewController /<br/>DCSDictionaryRef/<br/>/usr/share/dict/words"
author: Mattt Thompson
category: Cocoa
tags: cfhipsterref
excerpt: "Though widely usurped of their 'go-to reference' status by the Internet, dictionaries and word lists serve an important role behind the scenes of functionality ranging from spell check, grammar check, and auto-correct to auto-summarization and semantic analysis."
status:
    swift: t.b.c.
---

<img src="{{ site.asseturl }}/cfhipsterref-illustration-librarian.png" width="173" height="300" alt="Librarian, illustrated by Conor Heelan" style="float: right; margin-left: 2em; margin-bottom: 2em"/>

This week's article is about dictionaries. Not the `NSDictionary` / `CFDictionaryRef` we encounter everyday, but those distant lexicographic vestiges of school days past.

> But seriously, why are dictionaries called that, anyway? Why can't we just settle on `Hash`, like those nice Ruby folks? What's that? Semantic overlap with hashing functions and cryptographic digests? Well, dictionary isn't _that_ bad. Anything other than "associative arrays", I reckon.

Though widely usurped of their "go-to reference" status by the Internet, dictionaries and word lists serve an important role behind the scenes of functionality ranging from spell check, grammar check, and auto-correct to auto-summarization and semantic analysis. So, for your reference, here's a look at the ways and means by which computers give meaning to the world through words, in Unix, OS X, and iOS.

* * *

## Unix

Nearly all Unix distributions include a small collection newline-delimited list of words. On OS X, these can be found at `/usr/share/dict`:

~~~bash
$ ls /usr/share/dict
    README
    connectives
    propernames
    web2
    web2a
    words@ -> web2
~~~

Symlinked to `words` is the `web2` word list, which, though not exhaustive, is still a sizable corpus:

~~~bash
$ wc /usr/share/dict/words
    235886  235886 2493109
~~~

Skimming with `head` shows what fun lies herein. Such excitement is rarely so palpable as it is among words beginning with "a":

~~~bash
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

These giant, system-provided text files make it easy to `grep` crossword puzzle clues, generate mnemonic pass phrases, and seed databases, but from a user perspective, `/usr/share/dict`'s monolingualism and lack of associated meaning make it less than useful for everyday use.

OS X builds upon this with its own system dictionaries. Never one to disappoint, the operating system's penchant for extending Unix functionality through strategically placed bundles and plist files is in full force with how dictionaries are distributed.

* * *

## OS X

The OS X analog to `/usr/share/dict` can be found in `/Library/Dictionaries`.
A quick peek into the shared system dictionaries demonstrates one immediate improvement over Unix, by acknowledging the existence of languages other than English:

~~~bash
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

OS X ships with dictionaries in Chinese, English, French, Dutch, Italian, Japanese, Korean, as well as an English thesaurus and a special dictionary for Apple-specific terminology.

Diving deeper into the rabbit hole, we peruse the `.dictionary` bundles to see them for what they really are:

~~~bash
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

A filesystem autopsy reveals some interesting implementation details. In the case of the New Oxford American Dictionary in particular, contents include:

- Binary-encoded `KeyText.data`, `KeyText.index`, & `Content.data`
- CSS for styling entries
- 1207 images, from A-Frame to Zither.
- Preference to switch between [US English Diacritical Pronunciation](http://en.wikipedia.org/wiki/Pronunciation_respelling_for_English) and [IPA](http://en.wikipedia.org/wiki/International_Phonetic_Alphabet) (International Phonetic Alphabet)
- Manifest & signature for dictionary contents

Normally, proprietary binary encoding would be the end of the road in terms of what one could reasonably do with data, but luckily, Core Services provides APIs to read this information.

#### Getting Definition of Word

To get the definition of a word on OS X, one can use the `DCSCopyTextDefinition` function, found in the Core Services framework:

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

"But this is OS X, a platform whose manifest destiny cannot be contained by meager sandboxing attempts from Cupertino!", you cry. "Isn't there a more civilized approach? Like, say, private APIs?"

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

![Entry for "apple" in Dictionary.app]({{ site.asseturl }}/dictionary.png)

> For any fellow linguistics nerds or markup curious folks out there, here's [the HTML of the entry for the word "apple"](https://gist.github.com/mattt/9453538).

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

![Presenting a UIReferenceLibraryViewController]({{ site.asseturl }}/uireferencelibraryviewcontroller-1.png)

This is the same behavior that one might encounter by tapping the "Define" `UIMenuItem` on a highlighted word in a `UITextView`.

> Tapping on "Manage" brings up a view to download additional dictionaries.

![Presenting a UIReferenceLibraryViewController]({{ site.asseturl }}/uireferencelibraryviewcontroller-2.png)

`UIReferenceLibraryViewController` also provides the class method `dictionaryHasDefinitionForTerm:`. A developer would do well to call this before presenting a dictionary view controller that will inevitably have nothing to display.

~~~{objective-c}
[UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:@"apple"];
~~~

> In both cases, it appears that `UIReferenceLibraryViewController` will do its best to normalize the search term, so stripping whitespace or changing to lowercase should not be necessary.

* * *

From Unix word lists to their evolved `.dictionary` bundles on OS X (and presumably iOS), words are as essential to application programming as mathematical constants and the "Sosumi" alert noise. Consider how the aforementioned APIs can be integrated into your own app, or used to create a kind of app you hadn't previously considered. There are a [wealth](http://nshipster.com/nslocalizedstring/) [of](http://nshipster.com/nslinguistictagger/) [linguistic](http://nshipster.com/search-kit/) [technologies](http://nshipster.com/uilocalizedindexedcollation/) baked into Apple's platforms, so take advantage of them.
