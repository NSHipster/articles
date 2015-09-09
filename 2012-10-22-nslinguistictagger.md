---
title: NSLinguisticTagger
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "NSLinguisticTagger is a veritable Swiss Army Knife of linguistic functionality, with the ability to tokenize natural language strings into words, determine their part-of-speech & stem, extract names of people, places, & organizations, and tell you the languages & respective writing system used in the string."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

`NSLinguisticTagger` is a veritable Swiss Army Knife of linguistic functionality, with the ability to [tokenize](http://en.wikipedia.org/wiki/Tokenization) natural language strings into words, determine their part-of-speech & [stem](http://en.wikipedia.org/wiki/Word_stem), extract names of people, places, & organizations, and tell you the languages & respective [writing system](http://en.wikipedia.org/wiki/Writing_system) used in the string.

For most of us, this is far more power than we know what to do with. But perhaps this is just for lack sufficient opportunity to try. After all, almost every application deals with natural language in one way or another--perhaps `NSLinguisticTagger` could add a new level of polish, or enable brand new features entirely.

---

Introduced with iOS 5, `NSLinguisticTagger` is a contemporary to Siri, raising speculation that it was a byproduct of the personal assistant's development.

Consider a typical question we might ask Siri:

> What is the weather in San Francisco?

Computers are a long ways off from "understanding" this question literally, but with a few simple tricks, we can do a reasonable job understanding the _intention_ of the question:

~~~{swift}
let question = "What is the weather in San Francisco?"
let options: NSLinguisticTaggerOptions = [.OmitWhitespace, .OmitPunctuation, .JoinNames]
let schemes = NSLinguisticTagger.availableTagSchemesForLanguage("en")
let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
tagger.string = question
tagger.enumerateTagsInRange(NSMakeRange(0, (question as NSString).length), scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, options: options) { (tag, tokenRange, _, _) in
    let token = (question as NSString).substringWithRange(tokenRange)
    println("\(token): \(tag)")
}
~~~
~~~{objective-c}
NSString *question = @"What is the weather in San Francisco?";
NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
tagger.string = question;
[tagger enumerateTagsInRange:NSMakeRange(0, [question length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
    NSString *token = [question substringWithRange:tokenRange];
    NSLog(@"%@: %@", token, tag);
}];
~~~

This code would print the following:

> What: _Pronoun_
> is: _Verb_
> the: _Determiner_
> weather: _Noun_
> in: _Preposition_
> San Francisco: _PlaceName_

If we filter on nouns, verbs, and place name, we get `[is, weather, San Francisco]`.

Just based on this alone, or perhaps in conjunction with something like the [Latent Semantic Mapping](http://developer.apple.com/library/mac/#documentation/LatentSemanticMapping/Reference/LatentSemanticMapping_header_reference/Reference/reference.html) framework, we can conclude that a reasonable course of action would be to make an API request to determine the current weather conditions in San Francisco.

## Tagging Schemes

`NSLinguisticTagger` can be configured to tag different kinds of information by specifying any of the following tagging schemes:

- `NSLinguisticTagSchemeTokenType`: Classifies tokens according to their broad type: word, punctuation, whitespace, etc.
- `NSLinguisticTagSchemeLexicalClass`: Classifies tokens according to class: part of speech for words, type of punctuation or whitespace, etc.
- `NSLinguisticTagSchemeNameType`: Classifies tokens as to whether they are part of named entities of various types or not.
- `NSLinguisticTagSchemeNameTypeOrLexicalClass`: Follows `NSLinguisticTagSchemeNameType` for names, and `NSLinguisticTagSchemeLexicalClass` for all other tokens.

Here's a list of the various token types associated with each scheme (`NSLinguisticTagSchemeNameTypeOrLexicalClass`, as the name implies, is the union between `NSLinguisticTagSchemeNameType` & `NSLinguisticTagSchemeLexicalClass`):

<table>
  <thead>
    <tr>
      <th><tt>NSLinguisticTagSchemeTokenType</tt></th>
      <th><tt>NSLinguisticTagSchemeLexicalClass</tt></th>
      <th><tt>NSLinguisticTagSchemeNameType</tt></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <ul>
          <li><tt>NSLinguisticTagWord</tt></li>
          <li><tt>NSLinguisticTagPunctuation</tt></li>
          <li><tt>NSLinguisticTagWhitespace</tt></li>
          <li><tt>NSLinguisticTagOther</tt></li>
        </ul>
      </td>
      <td>
        <ul>
          <li><tt>NSLinguisticTagNoun</tt></li>
          <li><tt>NSLinguisticTagVerb</tt></li>
          <li><tt>NSLinguisticTagAdjective</tt></li>
          <li><tt>NSLinguisticTagAdverb</tt></li>
          <li><tt>NSLinguisticTagPronoun</tt></li>
          <li><tt>NSLinguisticTagDeterminer</tt></li>
          <li><tt>NSLinguisticTagParticle</tt></li>
          <li><tt>NSLinguisticTagPreposition</tt></li>
          <li><tt>NSLinguisticTagNumber</tt></li>
          <li><tt>NSLinguisticTagConjunction</tt></li>
          <li><tt>NSLinguisticTagInterjection</tt></li>
          <li><tt>NSLinguisticTagClassifier</tt></li>
          <li><tt>NSLinguisticTagIdiom</tt></li>
          <li><tt>NSLinguisticTagOtherWord</tt></li>
          <li><tt>NSLinguisticTagSentenceTerminator</tt></li>
          <li><tt>NSLinguisticTagOpenQuote</tt></li>
          <li><tt>NSLinguisticTagCloseQuote</tt></li>
          <li><tt>NSLinguisticTagOpenParenthesis</tt></li>
          <li><tt>NSLinguisticTagCloseParenthesis</tt></li>
          <li><tt>NSLinguisticTagWordJoiner</tt></li>
          <li><tt>NSLinguisticTagDash</tt></li>
          <li><tt>NSLinguisticTagOtherPunctuation</tt></li>
          <li><tt>NSLinguisticTagParagraphBreak</tt></li>
          <li><tt>NSLinguisticTagOtherWhitespace</tt></li>
        </ul>
      </td>
      <td>
        <ul>
          <li><tt>NSLinguisticTagPersonalName</tt></li>
          <li><tt>NSLinguisticTagPlaceName</tt></li>
          <li><tt>NSLinguisticTagOrganizationName</tt></li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

So for basic tokenization, use `NSLinguisticTagSchemeTokenType`, which will allow you to distinguish between words and whitespace or punctuation. For information like part-of-speech, or differentiation between different parts of speech, `NSLinguisticTagSchemeLexicalClass` is your new bicycle.

Continuing with the tagging schemes:

- `NSLinguisticTagSchemeLemma`: This tag scheme supplies a stem forms of the words, if known.
- `NSLinguisticTagSchemeLanguage`: Tags tokens according to their script. The tag values will be standard language abbreviations such as `"en"`, `"fr"`, `"de"`, etc., as used with the `NSOrthography` class. _Note that the tagger generally attempts to determine the language of text at the level of an entire sentence or paragraph, rather than word by word._
- `NSLinguisticTagSchemeScript`: Tags tokens according to their script. The tag values will be standard script abbreviations such as `"Latn"`, `"Cyrl"`, `"Jpan"`, `"Hans"`, `"Hant"`, etc.

As demonstrated in the example above, first you initialize an `NSLinguisticTagger` with an array of all of the different schemes that you wish to use, and then assign or enumerate each of the tags after specifying the tagger's input string.

## Tagging Options

In addition to the available tagging schemes, there are several options you can pass to `NSLinguisticTagger` (combined with bitwise OR `|`) to slightly change its behavior:

- `NSLinguisticTaggerOmitWords`
- `NSLinguisticTaggerOmitPunctuation`
- `NSLinguisticTaggerOmitWhitespace`
- `NSLinguisticTaggerOmitOther`

Each of these options omit the broad categories of tags described. For example, `NSLinguisticTagSchemeLexicalClass`, which distinguishes between many different kinds of punctuation, all of those would be omitted with `NSLinguisticTaggerOmitPunctuation`. This is preferable to manually filtering these tag types in enumeration blocks or with predicates.

The last option is specific to `NSLinguisticTagSchemeNameType`:

- `NSLinguisticTaggerJoinNames`

By default, each token in a name is treated as separate instances. In many circumstances, it makes sense to treat names like "San Francisco" as a single token, rather than two separate tokens. Passing this token makes this so.

---

Finally, NSString provides convenience methods that handle the setup and configuration of NSLinguisticTagger on your behalf. For one-off tokenizing, you can save a lot of boilerplate:

```swift
var tokenRanges: NSArray?
let tags = "Where in the world is Carmen San Diego?".linguisticTagsInRange(
				NSMakeRange(0, (question as NSString).length), 
				scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, 
				options: options, orthography: nil, tokenRanges: &tokenRanges
			)
// tags: ["Pronoun", "Preposition", "Determiner", "Noun", "Verb", "PersonalName"]
```

---

Natural language is woefully under-utilized in user interface design on mobile devices. When implemented effectively, a single utterance from the user can achieve the equivalent of a handful of touch interactions, in a fraction of the time.

Sure, it's not easy, but if we spent a fraction of the time we use to make our visual interfaces pixel-perfect, we could completely re-imagine how users best interact with apps and devices. And with `NSLinguisticTagger`, it's never been easier to get started.
