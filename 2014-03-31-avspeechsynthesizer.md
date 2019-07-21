---
title: AVSpeechSynthesizer
author: Mattt
category: Cocoa
excerpt: Though we're a long way off from Hal or Her,
  we shouldn't forget about the billions of people out there for us to talk to.
revisions:
  "2014-03-31": Original publication
  "2018-08-08": Updated for iOS 12 and macOS Mojave
status:
  swift: 4.2
  reviewed: August 8, 2018
---

Though we're a long way off from
[_Hal_](https://www.youtube.com/watch?v=ARJ8cAGm6JE) or
[_Her_](https://www.youtube.com/watch?v=WzV6mXIOVl4),
we shouldn't forget about the billions of people out there for us to talk to.

Of the thousands of languages in existence,
an individual is fortunate to gain a command of just a few within their lifetime.
And yet,
over several millennia of human co-existence,
civilization has managed to make things work (more or less)
through an ad-hoc network of
interpreters, translators, scholars,
and children raised in the mixed linguistic traditions of their parents.
We've seen that mutual understanding fosters peace
and that conversely,
mutual unintelligibility destabilizes human relations.

It's fitting that the development of computational linguistics
should coincide with the emergence of the international community we have today.
Working towards mutual understanding,
intergovernmental organizations like the United Nations and European Union
have produced a substantial corpus of
[parallel texts](http://en.wikipedia.org/wiki/Parallel_text),
which form the foundation of modern language translation technologies.

Computer-assisted communication
between speakers of different languages consists of three tasks:
**transcribing** the spoken words into text,
**translating** the text into the target language,
and **synthesizing** speech for the translated text.

This article focuses on how iOS handles the last of these: speech synthesis.

---

Introduced in iOS 7 and available in macOS 10.14 Mojave,
`AVSpeechSynthesizer` produces speech from text.

To use it,
create an `AVSpeechUtterance` object with the text to be spoken
and pass it to the `speakUtterance(_:)` method:

```swift
import AVFoundation

let string = "Hello, World!"
let utterance = AVSpeechUtterance(string: string)

let synthesizer = AVSpeechSynthesizer()
synthesizer.speakUtterance(utterance)
```

```objc
NSString *string = @"Hello, World!";
AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];

AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
[synthesizer speakUtterance:utterance];
```

You can use the adjust the volume, pitch, and rate of speech
by configuring the corresponding properties on the `AVSpeechUtterance` object.

When speaking,
a synthesizer can be paused on the next word boundary,
which makes for a less jarring user experience than stopping mid-vowel.

```swift
synthesizer.pauseSpeakingAtBoundary(.word)
```

```objc
[synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryWord];
```

## Supported Languages

Mac OS 9 users will no doubt have fond memories of the old system voices ---
especially the novelty ones, like
Bubbles, Cellos, Pipe Organ, and Bad News.

In the spirit of quality over quantity,
each language is provided a voice for each major locale region.
So instead of asking for "Fred" or "Markus",
`AVSpeechSynthesisVoice` asks for `en-US` or `de-DE`.

VoiceOver supports over 30 different languages.
For an up-to-date list of what's available,
call `AVSpeechSynthesisVoice` class method `speechVoices()`
or check [this support article](https://support.apple.com/en-us/HT206175).

By default,
`AVSpeechSynthesizer` will speak using a voice
based on the user's current language preferences.
To avoid sounding like a
[stereotypical American in Paris](https://www.youtube.com/watch?v=v-3RZl3YyJw),
set an explicit language by selecting a `AVSpeechSynthesisVoice`.

```swift
let string = "Bonjour!"
let utterance = AVSpeechUtterance(string: string)
utterance.voice = AVSpeechSynthesisVoice(language: "fr")
```

```objc
NSString *string = @"Bonjour!";
AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"fr-FR"];
```

Many APIs in foundation and other system frameworks
use ISO 681 codes to identify languages.
`AVSpeechSynthesisVoice`, however, takes an
[IETF Language Tag](http://en.wikipedia.org/wiki/IETF_language_tag),
as specified [BCP 47 Document Series](http://tools.ietf.org/html/bcp47).
If an utterance string and voice aren't in the same language,
speech synthesis fails.

> Not all languages are preloaded on the device,
> and may have to be downloaded in the background
> before speech can be synthesized.

{% comment %}

> [This gist](https://gist.github.com/mattt/9892187)
> shows how to detect an ISO 681 language code from an arbitrary string,
> and convert that to an IETF language tag.
> {% endcomment %}

## Customizing Pronunciation

A few years after it first debuted on iOS,
`AVUtterance` added functionality to control
the pronunciation of particular words,
which is especially helpful for proper names.

To take advantage of it,
construct an utterance using `init(attributedString:)`
instead of `init(string:)`.
The initializer scans through the attributed string
for any values associated with the `AVSpeechSynthesisIPANotationAttribute`,
and adjusts pronunciation accordingly.

```swift
import AVFoundation

let text = "It's pronounced 'tomato'"

let mutableAttributedString = NSMutableAttributedString(string: text)
let range = NSString(string: text).range(of: "tomato")
let pronunciationKey = NSAttributedString.Key(rawValue: AVSpeechSynthesisIPANotationAttribute)

// en-US pronunciation is /tə.ˈme͡ɪ.do͡ʊ/
mutableAttributedString.setAttributes([pronunciationKey: "tə.ˈme͡ɪ.do͡ʊ"], range: range)

let utterance = AVSpeechUtterance(attributedString: mutableAttributedString)

// en-GB pronunciation is /tə.ˈmɑ.to͡ʊ/... but too bad!
utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")

let synthesizer = AVSpeechSynthesizer()
synthesizer.speak(utterance)
```

Beautiful. 🍅

Of course, [this property is undocumented](https://developer.apple.com/documentation/avfoundation/avspeechsynthesisipanotationattribute)
at the time of writing,
so you wouldn't know that the IPA you get from Wikipedia
won't work correctly unless you watched
[this session from WWDC 2018](https://developer.apple.com/videos/play/wwdc2018/236/).

To get IPA notation that `AVSpeechUtterance` can understand,
you can open the Settings app,
navigate to General > Accessibility > Speech > Pronunciations,
and... say it yourself!

{% asset speech-pronunciation-replacement alt="Speech Pronunciation Replacement" %}

## Hooking Into Speech Events

One of the coolest features of `AVSpeechSynthesizer`
is how it lets developers hook into speech events.
An object conforming to `AVSpeechSynthesizerDelegate` can be called
when a speech synthesizer
starts or finishes,
pauses or continues,
and as each range of the utterance is spoken.

For example, an app ---
in addition to synthesizing a voice utterance ---
could show that utterance in a label,
and highlight the word currently being spoken:

```swift
var utteranceLabel: UILabel!

// MARK: AVSpeechSynthesizerDelegate

override func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
  willSpeakRangeOfSpeechString characterRange: NSRange,
                                    utterance: AVSpeechUtterance)
{
    self.utterranceLabel.attributedText =
        attributedString(from: utterance.speechString,
                         highlighting: characterRange)
}
```

```objc
#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
willSpeakRangeOfSpeechString:(NSRange)characterRange
                utterance:(AVSpeechUtterance *)utterance
{
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:utterance.speechString];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor redColor] range:characterRange];
    self.utteranceLabel.attributedText = mutableAttributedString;
}
```

{% asset avspeechsynthesizer-example.gif alt="AVSpeechSynthesizer Example" width=320 %}

Check out [this Playground](https://github.com/NSHipster/AVSpeechSynthesizer-Example)
for an example of live text-highlighting for all of the supported languages.

---

Anyone who travels to an unfamiliar place
returns with a profound understanding of what it means to communicate.
It's totally different from how one is taught a language in High School:
instead of genders and cases,
it's about emotions
and patience
and clinging onto every shred of understanding.
One is astounded by the extent to which two humans
can communicate with hand gestures and facial expressions.
One is also humbled by how frustrating it can be when pantomiming breaks down.

In our modern age, we have the opportunity to go out in a world
augmented by a collective computational infrastructure.
Armed with `AVSpeechSynthesizer`
and myriad other linguistic technologies on our devices,
we've never been more capable of breaking down the forces
that most divide our species.

If that isn't universe-denting,
then I don't know what is.
