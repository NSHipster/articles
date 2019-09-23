---
title: CharacterSet
author: Mattt
category: Cocoa
excerpt: >-
  `CharacterSet` isn't a set and it doesn't contain `Character` values.
  Before we use it to trim, filter, and search through text,
  we should take a closer look to see what's actually going on.
revisions:
  "2012-09-17": Original publication
  "2018-12-12": Updated for Swift 4.2
status:
  swift: 4.2
  reviewed: December 12, 2018
---

In Japan,
there's a comedy tradition known as
[Manzai (漫才)](https://en.wikipedia.org/wiki/Manzai).
It's kind of a cross between stand up and vaudeville,
with a straight man and a funny man
delivering rapid-fire jokes that revolve around miscommunication and wordplay.

As it were, we've been working on a new routine
as a way to introduce the subject for this week's article, `CharacterSet`,
and wanted to see what you thought:

{::nomarkdown}

<div class="conversation">

<ruby class="boke">
Is <code>CharacterSet</code> a <code>Set&lt;Character&gt;</code>?
<rt lang="ja">
キャラクターセットではないキャラクターセット？
</rt>
</ruby>

<ruby class="tsukkomi">
Of course not!
<rt lang="ja">
もちろん違います！
</rt>
</ruby>

<ruby class="boke">
What about <code>NSCharacterSet</code>?
<rt lang="ja">
何エンエスキャラクタセットは？
</rt>
</ruby>

<ruby class="tsukkomi">
That's an old reference.
<rt lang="ja">
それは古いリファレンスです。
</rt>
</ruby>

<ruby class="boke">
Then what do you call a collection of characters?
<rt lang="ja">
何と呼ばれる文字の集合ですか？
</rt>
</ruby>

<ruby class="tsukkomi">
That would be a <code>String</code>!
<rt lang="ja">
それは文字列でしょ！
</rt>
</ruby>

<ruby class="boke">
(╯° 益 °)╯ 彡 ┻━┻
<rt lang="ja">
無駄無駄無駄無駄無駄無駄無駄
</rt>
</ruby>

</div>
{:/}

_(Yeah, we might need to workshop this one a bit more.)_

All kidding aside,
`CharacterSet` is indeed ripe for miscommunication and wordplay (so to speak):
it doesn't store `Character` values,
and it's not a `Set` in the literal sense.

So what is `CharacterSet` and how can we use it?
Let's find out! (行きましょう！)

---

`CharacterSet` (and its reference type counterpart, `NSCharacterSet`)
is a Foundation type used to trim, filter, and search for
characters in text.

In Swift,
a `Character` is an extended grapheme cluster
(really just a `String` with a length of 1)
that comprises one or more scalar values.
`CharacterSet` stores those underlying `Unicode.Scalar` values,
rather than `Character` values, as the name might imply.

The "set" part of `CharacterSet`
refers not to `Set` from the Swift standard library,
but instead to the `SetAlgebra` protocol,
which bestows the type with the same interface:
`contains(_:)`, `insert(_:)`, `union(_:)`, `intersection(_:)`, and so on.

## Predefined Character Sets

`CharacterSet` defines constants
for sets of characters that you're likely to work with,
such as letters, numbers, punctuation, and whitespace.
Most of them are self-explanatory and,
with only a few exceptions,
correspond to one or more
[Unicode General Categories](https://unicode.org/reports/tr44/#General_Category_Values).

| Type Property                     | Unicode General Categories & Code Points |
| --------------------------------- | ---------------------------------------- |
| `alphanumerics`                   | L\*, M\*, N\*                            |
| `letters`                         | L\*, M\*                                 |
| `capitalizedLetters`<sup>\*</sup> | Lt                                       |
| `lowercaseLetters`                | Ll                                       |
| `uppercaseLetters`                | Lu, Lt                                   |
| `nonBaseCharacters`               | M\*                                      |
| `decimalDigits`                   | Nd                                       |
| `punctuationCharacters`           | P\*                                      |
| `symbols`                         | S\*                                      |
| `whitespaces`                     | Zs, U+0009                               |
| `newlines`                        | U+000A – U+000D, U+0085, U+2028, U+2029  |
| `whitespacesAndNewlines`          | Z\*, U+000A – U+000D, U+0085             |
| `controlCharacters`               | Cc, Cf                                   |
| `illegalCharacters`               | Cn                                       |

{% info %}
A common mistake is to use `capitalizedLetters`
when what you actually want is `uppercaseLetters`.
Unicode actually defines three cases:
lowercase, uppercase, and <dfn>titlecase</dfn>.
You can see this in the Latin script used for
Czech as well as Serbo-Croatian and other South Slavic languages,
in which digraphs like "dž" are considered single letters,
and have separate forms for
lowercase (dž), uppercase (DŽ), and titlecase (ǅ).
The `capitalizedLetters` character set contains only
a few dozen of those titlecase digraphs.
{% endinfo %}

The remaining predefined character set, `decomposables`,
is derived from the
[decomposition type and mapping](https://unicode.org/reports/tr44/#Character_Decomposition_Mappings)
of characters.

### Trimming Leading and Trailing Whitespace

Perhaps the most common use for `CharacterSet`
is to remove leading and trailing whitespace from text.

```swift
"""

    😴

""".trimmingCharacters(in: .whitespacesAndNewlines) // "😴"
```

You can use this, for example,
when sanitizing user input or preprocessing text.

## Predefined URL Component Character Sets

In addition to the aforementioned constants,
`CharacterSet` provides predefined values
that correspond to the characters allowed in various
[components of a URL](https://nshipster.com/nsurl/):

- `urlUserAllowed`
- `urlPasswordAllowed`
- `urlHostAllowed`
- `urlPathAllowed`
- `urlQueryAllowed`
- `urlFragmentAllowed`

### Escaping Special Characters in URLs

Only certain characters are allowed in certain parts of a URL
without first being escaped.
For example, spaces must be percent-encoded as `%20` (or `+`)
when part of a query string like
`https://nshipster.com/search/?q=character%20set`.

`URLComponents` takes care of percent-encoding components automatically,
but you can replicate this functionality yourself
using the `addingPercentEncoding(withAllowedCharacters:)` method
and passing the appropriate character set:

```swift
let query = "character set"
query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
// "character%20set"
```

{% warning %}
[Internationalized domain names](https://en.wikipedia.org/wiki/Internationalized_domain_name)
encode non-ASCII characters using
[Punycode](https://en.wikipedia.org/wiki/Punycode)
instead of percent-encoding
(for example,
[NSHipster.中国](https://nshipster.cn) would be
[NSHipster.xn--fiqy6j](https://nshipster.cn))
Punycode encoding / decoding isn't currently provided by Apple SDKs.
{% endwarning %}

## Building Your Own

In addition to these predefined character sets,
you can create your own.
Build them up character by character,
inserting multiple characters at a time by passing a string,
or by mixing and matching any of the predefined sets.

### Validating User Input

You might create a `CharacterSet` to validate some user input to, for example,
allow only lowercase and uppercase letters, digits, and certain punctuation.

```swift
var allowed = CharacterSet()
allowed.formUnion(.lowercaseLetters)
allowed.formUnion(.uppercaseLetters)
allowed.formUnion(.decimalDigits)
allowed.insert(charactersIn: "!@#$%&")

func validate(_ input: String) -> Bool {
    return input.unicodeScalars.allSatisfy { allowed.contains($0) }
}
```

Depending on your use case,
you might find it easier to think in terms of what shouldn't be allowed,
in which case you can compute the inverse character set
using the `inverted` property:

```swift
let disallowed = allowed.inverted
func validate(_ input: String) -> Bool {
    return input.rangeOfCharacter(from: disallowed) == nil
}
```

### Caching Character Sets

If a `CharacterSet` is created as the result of an expensive operation,
you may consider caching its `bitmapRepresentation`
for later reuse.

For example,
if you wanted to create `CharacterSet` for Emoji,
you might do so by enumerating over the Unicode code space (U+0000 – U+1F0000)
and inserting the scalar values for any characters with
[Emoji properties](https://www.unicode.org/reports/tr51/#Emoji_Properties)
using the `properties` property added in Swift 5 by
[SE-0221 "Character Properties"](https://github.com/apple/swift-evolution/blob/master/proposals/0221-character-properties.md):

```swift
import Foundation

var emoji = CharacterSet()

for codePoint in 0x0000...0x1F0000 {
    guard let scalarValue = Unicode.Scalar(codePoint) else {
        continue
    }

    // Implemented in Swift 5 (SE-0221)
    // https://github.com/apple/swift-evolution/blob/master/proposals/0221-character-properties.md
    if scalarValue.properties.isEmoji {
        emoji.insert(scalarValue)
    }
}
```

The resulting `bitmapRepresentation` is a 16KB `Data` object.

```swift
emoji.bitmapRepresentation // 16385 bytes
```

You could store that in a file somewhere in your app bundle,
or embed its [Base64 encoding](https://en.wikipedia.org/wiki/Base64)
as a string literal directly in the source code itself.

```swift
extension CharacterSet {
    static var emoji: CharacterSet {
        let base64Encoded = """
        AAAAAAgE/wMAAAAAAAAAAAAAAAAA...
        """
        let data = Data(base64Encoded: base64Encoded)!

        return CharacterSet(bitmapRepresentation: data)
    }
}

CharacterSet.emoji.contains("👺") // true
```

{% info %}
Because the Unicode code space is a closed range,
`CharacterSet` can express the membership of a given scalar value
using a single bit in a [bit map](https://en.wikipedia.org/wiki/Bit_array),
rather than using a
[universal hashing function](https://en.wikipedia.org/wiki/Universal_hashing)
like a conventional `Set`.
On top of that, `CharacterSet` does some clever optimizations, like
allocating on a per-[plane](https://www.unicode.org/glossary/#plane) basis
and representing sets of contiguous scalar values as ranges, if possible.
{% endinfo %}

---

Much like our attempt at a Manzai routine at the top of the article,
some of the meaning behind `CharacterSet` is lost in translation.

`NSCharacterSet` was designed for `NSString`
at a time when characters were equivalent to 16-bit UCS-2 code units
and text rarely had occasion to leave the Basic Multilingual Plane.
But with Swift's modern,
Unicode-compliant implementations of `String` and `Character`,
the definition of terms has drifted slightly;
along with its `NS` prefix,
`CharacterSet` lost some essential understanding along the way.

Nevertheless,
`CharacterSet` remains a performant, specialized container type
for working with collections of scalar values.

<ruby>
FIN
<rt lang="ja">
おしまい。
</rt>
</ruby>

{% asset articles/characterset.css %}
