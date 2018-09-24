---
title: NLLanguageRecognizer
author: Mattt
category: Cocoa
tags: language
excerpt: >
  Machine learning has been at the heart of
  natural language processing in Apple platforms for many years,
  but it's only recently that external developers have been able to
  harness it directly.
status:
  swift: 4.2
---

One of my favorite activities,
when I travel,
is to listen to people as they pass
and try to guess what language they're speaking.
I'd like to think that I've gotten pretty good at it over the years
(though I rarely get to know if I guessed right).

If I'm lucky,
I'll recognize a word or phrase as a cognate of a language I'm familiar with,
and narrow things down from there.
Otherwise, I try to build up a phonetic inventory,
listening for what kinds of sounds are present.
For instance,
is the speaker mostly using
voiced alveolar trills [`⟨r⟩`](https://en.wikipedia.org/wiki/Dental,_alveolar_and_postalveolar_trills),
flaps [`⟨ɾ⟩`](https://en.wikipedia.org/wiki/Flap_consonant),
or postalveolar approximants [`⟨ɹ⟩`](https://en.wikipedia.org/wiki/Alveolar_and_postalveolar_approximants)?
Are the vowels mostly open / close; front / back?
Any unusual sounds, like [`⟨ʇ⟩`](https://en.wikipedia.org/wiki/Dental_clicks)?

...or at least that's what I think I do.
To be honest, all of this happens unconsciously and automatically --
for all of us, and for all manner of language recognition tasks.
And have only the faintest idea of how we get from input to output.

Computers operate in a similar manner.
After many hours of training,
machine learning models can predict the language of text
with accuracy far exceeding previous attempts
from a formalized top-down approach.

Machine learning has been at the heart of
natural language processing in Apple platforms for many years,
but it's only recently that external developers have been able to
harness it directly.

---

New in iOS 12 and macOS 10.14,
the [Natural Language framework](https://developer.apple.com/documentation/naturallanguage)
refines existing linguistic APIs
and exposes new functionality to developers.

[`NLTagger`](https://developer.apple.com/documentation/naturallanguage/nltagger)
is [`NSLinguisticTagger`](https://nshipster.com/nslinguistictagger/)
with a new attitude.
[`NLTokenizer`](https://developer.apple.com/documentation/naturallanguage/nltokenizer)
is a replacement for
[`enumerateSubstrings(in:options:using:)`](https://developer.apple.com/documentation/foundation/nsstring/1416774-enumeratesubstrings)
(neé [`CFStringTokenizer`](https://developer.apple.com/documentation/corefoundation/cfstringtokenizer-rf8)).
[`NLLanguageRecognizer`](https://developer.apple.com/documentation/naturallanguage/nllanguagerecognizer)
offers an extension of the functionality previously exposted through the
`dominantLanguage` in `NSLinguisticTagger`,
with the ability to provide hints and get additional predictions.

## Recognizing the Language of Natural Language Text

Here's how to use `NLLanguageRecognizer`
to guess the dominant language of natural language text:

```swift
import NaturalLanguage

let string = """
私はガラスを食べられます。それは私を傷つけません。
"""

let recognizer = NLLanguageRecognizer()
recognizer.processString(string)
recognizer.dominantLanguage // ja
```

First, create an instance of `NLLanguageRecognizer`
and call the method `processString(_:)`
passing a string.
From there, the `dominantLanguage` property
returns an `NLLanguage` object
containing the BCP-47 language tag of the predicted language
(for example `"ja"` for 日本語 / Japanese).

### Getting Multiple Language Hypotheses

If you studied linguistics in college
or joined the Latin club in high school,
you may be familiar with some fun examples of
_polylingual homonymy_ between dialectic Latin and modern Italian.

For example, consider the readings of the following sentence:

> CANE NERO MAGNA BELLA PERSICA!

| Language | Translation                           |
| -------- | ------------------------------------- |
| Latin    | Sing, o Nero, the great Persian wars! |
| Italian  | The black dog eats a nice peach!      |

To the chagrin of [Max Fisher](<https://en.wikipedia.org/wiki/Rushmore_(film)>),
Latin isn't one of the languages supported by `NLLanguageRecognizer`,
so any examples of confusable languages
won't be nearly as entertaining.

With some experimentation,
you'll find that it's quite difficult to get `NLLanguageRecognizer`
to guess incorrectly, or even with low precision.
Beyond giving it a single cognate shared across members of a language family,
it's often able to get past 2σ to 95% certainty
with a handful of words.

After some trial and error,
we were finally able to get `NLLanguageRecognizer` to guess incorrectly
for a string of non-trivial length
by passing the
[Article I of the Universal Declaration of Human Rights in Norsk, Bokmål](https://www.ohchr.org/EN/UDHR/Pages/Language.aspx?LangID=nrr):

```swift
let string = """
Alle mennesker er født frie og med samme menneskeverd og menneskerettigheter.
De er utstyrt med fornuft og samvittighet og bør handle mot hverandre i brorskapets ånd.
"""

let languageRecognizer = NLLanguageRecognizer()
languageRecognizer.processString(string)
recognizer.dominantLanguage // da (!)
```

{% info do %}

The [Universal Declaration of Human Rights](http://www.un.org/en/universal-declaration-human-rights/),
is the among the most widely-translated documents in the world,
with translations in over 500 different languages.
For this reason, it's often used for natural language tasks.

{% endinfo %}

Danish and Norwegian Bokmål are very similar languages to begin with,
so it's unsurprising that `NLLanguageRecognizer` guessed incorrectly.
(For comparison, here's the [equivalent text in Danish](https://www.ohchr.org/EN/UDHR/Pages/Language.aspx?LangID=dns))

We can use the `languageHypotheses(withMaximum:)` method
to get a sense of how confident the `dominantLanguage` guess was:

```swift
languageRecognizer.languageHypotheses(withMaximum: 2)
```

| Language                | Confidence |
| ----------------------- | ---------- |
| Danish (`da`)           | 56%        |
| Norwegian Bokmål (`nb`) | 43%        |

At the time of writing,
the [`languageHints`](https://developer.apple.com/documentation/naturallanguage/nllanguagerecognizer/3017455-languagehints)
property is undocumented,
so it's unclear how exactly it should be used.
However, passing a weighted dictionary of probabilities
seems to have the desired effect of bolstering the hypotheses with known priors:

```swift
languageRecognizer.languageHints = [.danish: 0.25, .norwegian: 0.75]
```

| Language                | Confidence (with Hints) |
| ----------------------- | ----------------------- |
| Danish (`da`)           | 30%                     |
| Norwegian Bokmål (`nb`) | 70%                     |

<br/>

So what can you do once you know the language of a string?

Here are a couple of use cases for your consideration:

## Checking Misspelled Words

Combine `NLLanguageRecognizer` with
[`UITextChecker`](https://nshipster.com/uitextchecker/)
to check the spelling of words in any string:

Start by creating an `NLLanguageRecognizer`
and initializing it with a string by calling the `processString(_:)` method:

```swift
let string = """
Wenn ist das Nunstück git und Slotermeyer?
Ja! Beiherhund das Oder die Flipperwaldt gersput!
"""

let languageRecognizer = NLLanguageRecognizer()
languageRecognizer.processString(string)
let dominantLanguage = languageRecognizer.dominantLanguage! // de
```

Then, pass the `rawValue` of the `NLLanguage` object
returned by the `dominantLanguage` property
to the `language` parameter of
`rangeOfMisspelledWord(in:range:startingAt:wrap:language:)`:

```swift
let textChecker = UITextChecker()

let nsString = NSString(string: string)
let stringRange = NSRange(location: 0, length: nsString.length)
var offset = 0

repeat {
    let wordRange =
            textChecker.rangeOfMisspelledWord(in: string,
                                              range: stringRange,
                                              startingAt: offset,
                                              wrap: false,
                                              language: dominantLanguage.rawValue)
    guard wordRange.location != NSNotFound else {
        break
    }

    print(nsString.substring(with: wordRange))

    offset = wordRange.upperBound
} while true
```

When passed the [The Funniest Joke in the World](https://en.wikipedia.org/wiki/The_Funniest_Joke_in_the_World),
the following words are called out for being misspelled:

- Nunstück
- Slotermeyer
- Beiherhund
- Flipperwaldt
- gersput

## Synthesizing Speech

You can use `NLLanguageRecognizer` in concert with
[`AVSpeechSynthesizer`](https://nshipster.com/avspeechsynthesizer/)
to hear any natural language text read aloud:

```swift
let string = """
Je m'baladais sur l'avenue le cœur ouvert à l'inconnu
    J'avais envie de dire bonjour à n'importe qui.
N'importe qui et ce fut toi, je t'ai dit n'importe quoi
    Il suffisait de te parler, pour t'apprivoiser.
"""

let languageRecognizer = NLLanguageRecognizer()
languageRecognizer.processString(string)
let language = languageRecognizer.dominantLanguage!.rawValue // fr

let speechSynthesizer = AVSpeechSynthesizer()
let utterance = AVSpeechUtterance(string: string)
utterance.voice = AVSpeechSynthesisVoice(language: language)
speechSynthesizer.speak(utterance)
```

It doesn't have the lyrical finesse of
[Joe Dassin](https://itunes.apple.com/us/album/les-champs-%C3%A9lys%C3%A9es/311331439?i=311331447),
but _ainsi va la vie_.

---

In order to be understood,
we first must seek to understand.
And the first step to understanding natural language
is to determine its language.

`NLLanguageRecognizer` offers a powerful new interface to functionality
that's been responsible for intelligent features throughout iOS and macOS.
See how you might take advantage of it in your app
to gain new understanding of your users.
