---
title: AVSpeechSynthesizer
author: Mattt Thompson
category: Cocoa
excerpt: "Though we're a long way off from Hal or Her, we should never forget about the billions of other people out there for us to talk to."
status:
    swift: 2.0
    reviewed: September 10, 2015
---

Though we're a long way off from [_Hal_](https://www.youtube.com/watch?v=ARJ8cAGm6JE) or [_Her_](https://www.youtube.com/watch?v=WzV6mXIOVl4), we should never forget about the billions of other people out there for us to talk to.

Of the thousands of languages in existence, an individual is fortunate to gain a command of just two within their lifetime. And yet, over several millennia of human co-existence, civilization has managed to make things work, more or less, through an ad-hoc network of interpreters, translators, scholars, and children raised in the mixed linguistic traditions of their parents. We've seen that mutual understanding fosters peace, and that conversely, mutual unintelligibility destabilizes human relations.

It is fitting that the development of computational linguistics should coincide with the emergence of the international community we have today. Working towards mutual understanding, intergovernmental organizations like the United Nations and European Union have produced a substantial corpora of [parallel texts](http://en.wikipedia.org/wiki/Parallel_text), which form the foundation of modern language translation technologies.

> Another related linguistic development is the [Esperanto](http://en.wikipedia.org/wiki/Esperanto) language, created by L. L. Zamenhof in an effort to promote harmony between people of different countries.

And while automatic text translation has reached an acceptable level for everyday communication, there is still a divide when we venture out into unfamiliar places. There is still much work to be done in order to augment our ability to communicate with one another in person.

* * *

Introduced in iOS 7, `AVSpeechSynthesizer` produces synthesized speech from a given `AVSpeechUtterance`. Each utterance can adjust its rate of speech and pitch, and be configured to use any one of the available `AVSpeechSynthesisVoice`s:

```swift
import AVFoundation

let string = "Hello, World!"
let utterance = AVSpeechUtterance(string: string)
utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

let synthesizer = AVSpeechSynthesizer()
synthesizer.speakUtterance(utterance)
```

~~~{objective-c}
NSString *string = @"Hello, World!";
AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];

AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
[synthesizer speakUtterance:utterance];
~~~

When speaking, a synthesizer can either be paused immediately or on the next word boundary, which makes for a less jarring user experience.

```swift
synthesizer.pauseSpeakingAtBoundary(.Word)
```

~~~{objective-c}
[synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryWord];
~~~

## Supported Languages

Mac OS 9 users will no doubt have fond memories of the old system voices: Bubbles, Cellos, Pipe Organ, and Bad News.

> These can still be installed on OS X. Just look under the "English (United States) - Novelty" voices in the "Dictation & Speech" preference pane.

In the name of quality over quantity, each language is provided a voice for each major locale region. So instead of asking for "Fred" and "Markus", `AVSpeechSynthesisVoice` asks for `en-US` and `de-DE`.

As of iOS 8.1, `[AVSpeechSynthesisVoice speechVoices]` the following languages and locales are supported:

- Arabic (`ar-SA`)
- Chinese (`zh-CN`, `zh-HK`, `zh-TW`)
- Czech (`cs-CZ`)
- Danish (`da-DK`)
- Dutch (`nl-BE`, `nl-NL`)
- English (`en-AU`, `en-GB`, `en-IE`, `en-US`, `en-ZA`)
- Finnish (`fi-FI`)
- French (`fr-CA`, `fr-FR`)
- German (`de-DE`)
- Greek (`el-GR`)
- Hebrew (`he-IL`)
- Hindi (`hi-IN`)
- Hungarian (`hu-HU`)
- Indonesian (`id-ID`)
- Italian (`it-IT`)
- Japanese (`ja-JP`)
- Korean (`ko-KR`)
- Norwegian (`no-NO`)
- Polish (`pl-PL`)
- Portuguese (`pt-BR`, `pt-PT`)
- Romanian (`ro-RO`)
- Russian (`ru-RU`)
- Slovak (`sk-SK`)
- Spanish (`es-ES`, `es-MX`)
- Swedish (`sv-SE`)
- Thai (`th-TH`)
- Turkish (`tr-TR`)

`NSLocale` and `NSLinguisticTagger` both use ISO 681 codes to identify languages. `AVSpeechSynthesisVoice`, however, takes an [IETF Language Tag](http://en.wikipedia.org/wiki/IETF_language_tag), as specified [BCP 47 Document Series](http://tools.ietf.org/html/bcp47). If an utterance string and voice aren't in the same language, speech synthesis will fail.

> [This gist](https://gist.github.com/mattt/9892187) shows how to detect an ISO 681 language code from an arbitrary string, and convert that to an IETF language tag.

## Delegate Methods

What makes `AVSpeechSynthesizer` really amazing for developers is the ability to hook into speech events. An object conforming to `AVSpeechSynthesizerDelegate` can be called when its speech synthesizer either starts or finishes, pauses or continues, and as each range of the utterance is spoken.

For example, an app, in addition to synthesizing a voice utterance, could show that utterance in a label, and highlight the word currently being spoken:

```swift
var utteranceLabel: UILabel!

// MARK: AVSpeechSynthesizerDelegate

func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
    let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
    mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: characterRange)
    utteranceLabel.attributedText = mutableAttributedString
}

func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
    utteranceLabel.attributedText = NSAttributedString(string: utterance.speechString)
}
```

~~~{objective-c}
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

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
 didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    self.utteranceLabel.attributedText = [[NSAttributedString alloc] initWithString:self.utteranceString];
}
~~~

![AVSpeechSynthesizer Example](http://nshipster.s3.amazonaws.com/avspeechsynthesizer-example.gif)

See [this example app](https://github.com/mattt/AVSpeechSynthesizer-Example) for a demonstration of live text-highlighting for all of the supported languages.

* * *

Anyone who travels to an unfamiliar place returns with a profound understanding of what it means to communicate. It's totally different from how one is taught a language in High School: instead of genders and cases, it's about emotions and patience and clinging onto every shred of understanding. One is astounded by the extent to which two humans can communicate with hand gestures and facial expressions. One is also humbled by how frustrating it can be when pantomiming breaks down.

In our modern age, we have the opportunity to go out in a world augmented by a collective computational infrastructure. Armed with `AVSpeechSynthesizer` and the myriad other linguistic technologies on iOS and elsewhere, we have never been more capable of breaking down the forces that most divide our species.

If that isn't universe-denting, then I don't know what is.
