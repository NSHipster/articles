---
title: macOS Character Viewer
author: Mattt
category: ""
excerpt: >-
  Ever see a character and wonder what it was?
  Ever want to insert a character but couldn't figure out how to type it?
  You can find the answer to these questions and many more 
  at the bottom of the Edit menu in macOS.
status:
  swift: 4.2
---

Emoji is a conspiracy by the Unicode® Consortium
to make Americans care about internationalization.

For a time,
many developers operated under the assumption that
user-input would be _primarily_ Latin-1-compatible;
or if not, then Extended Latin, certainly.
Or at least they could feel reasonably assured that
everything would fall within the Basic Multilingual Plane ---
fitting comfortably into a single UTF-16 code unit.

But nowadays, with Emoji emerging as
the _lingua franca_ of these troubled times,
text is presumed international until proven otherwise.
Everyone should be ready for when the
<abbr title="💩">U+1F4A9</abbr>
hits the fan.

So whatever you think about those
colorful harbingers of societal collapse,
at _least_ they managed to break us of
our ASCII-only information diets.

This week on NSHipster,
we'll be looking at a relatively obscure part of macOS
that will prove essential for developers in today's linguistic landscape:
<dfn>Character Viewer</dfn>

---

From any macOS app,
you can select the Edit menu
and find an item at the very bottom called "Emoji & Symbols"
(tellingly renamed from "Special Characters" in OS X Mavericks).

By default,
this opens a panel that looks something like this:

{% asset character-viewer-collapsed.png %}

You may have discovered this on your own
and have found this to be a convenient alternative to
searching for Emoji online.

_But this isn't even its final form!_
Click the icon on the top right
to see its _true_ power:

{% asset character-viewer-expanded.png %}

Go ahead and memorize the global shortcut if you haven't already:
<kbd>⌃</kbd><kbd>⌘</kbd><kbd>Space</kbd>.
If you do any serious work with text,
you'll be using Character Viewer frequently.

Let's take a quick tour of Character Viewer
and see what it can do for us:

## A Quick Tour of Character Viewer

The sidebar on the left provides quick access to
your favorite and frequently-used characters,
as well as a customizable list of named categories
like Emoji, Latin, Punctuation, and Bullets/Stars.

The center column displays a grid of characters.
Some categories, including Emoji,
provide special views
that make it easier to browse through the characters in that collection.

Selecting a character populates the inspector pane on the right
with a larger, isolated rendering of the character,
the character name, code point, and UTF-8 encoding.
The inspector may also show alternate glyph renderings
provided by other fonts
as well as related characters, as applicable.

### Copying Character Information

You can control-click a character and
choose "Copy Character Info" from the shortcut menu
to copy the information found in the inspector.
For example:

<samp>
😂<br/>
face with tears of joy<br/>
Unicode: U+1F602, UTF-8: F0 9F 98 82
</samp>

Let's take a look at what all of this means
and how to use it in Swift code:

#### Character Literal

The first line of the copied character information is the character itself.

Swift source code fully supports Unicode,
so you can copy-paste any character into a string literal
and have it work as expected:

```swift
"😂" // 😂
```

All characters found in Character Viewer
are valid string and character literals.
However, not all entries are valid Unicode scalar literals.
For example,
the character 👩🏻‍🦰
is a [named sequence](https://unicode.org/reports/tr34/)
consisting of four individual code points:

- 👩‍ WOMAN (U+1F469)
- 🏻 EMOJI MODIFIER FITZPATRICK TYPE-1-2 (U+1F3FB)
- ␣ ZERO WIDTH JOINER (U+200D)
- 🦰 EMOJI COMPONENT RED HAIR (U+1F9B0)

Attempting to initialize a `Unicode.Scalar` value
from a string literal with this character
results in an error.

```swift
("👩🏻‍🦰" as Unicode.Scalar) // error
```

#### Unicode Code Point

Each Unicode character is assigned a unique name and number,
known as a <dfn>code point</dfn>.
By convention,
Unicode code points are formatted as 4 – 6 hexadecimal digits (0–9, A–F)
with the prefix "U+".

In Swift,
string literals have the `\u{n}` escape sequence
which takes a 1 – 6 hexadecimal number corresponding to a
Unicode <dfn>scalar value</dfn>
(essentially, the numerical value of any code point
that isn't a [surrogate](https://unicode.org/faq/utf_bom.html#utf16-2)).

The character 😂 has a scalar value equal to 1F602₁₆ (128514 in decimal).
You can plug that number into a `\u{}` escape sequence in a string literal
to have it replaced by the character in the resulting string.

```swift
"\u{1F602}" // "😂"
```

Unicode scalar value escape sequences are especially useful
when working with nonprinting control characters
like [directional formatting characters](http://unicode.org/reports/tr9/).

#### UTF-8 Code Units

The pairs of hexadecimal digits labeled "UTF8"
correspond to the code points for the
[UTF-8](https://unicode.org/faq/utf_bom.html#utf8-1)
encoded form of the character.

The UTF-8 code unit is a byte (8 bits),
which is represented by two hexadecimal digits.

In Swift,
you can use the `String(decoding:as:)` initializer
to create a string from an array of `UInt8` values
corresponding to the values copied from Character Viewer.

```swift
String(decoding: [0xF0, 0x9F, 0x98, 0x82], as: UTF8.self) // 😂
```

#### Unicode Character Name

The last piece of information provided by Character Viewer
is the name of the character "face with tears of joy".

The Swift standard library doesn't currently provide a way to
initialize Unicode scalar values or named sequences.
However, you can use the `String` method
[`applyingTransform(_:reverse:)`](https://developer.apple.com/documentation/foundation/nsstring/1407787-applyingtransform)
provided by the Foundation framework
to get a character by name:

```swift
import Foundation

"\\N{FACE WITH TEARS OF JOY}".applyingTransform(.toUnicodeName,
                                                reverse: true)
// "😂"
```

Perhaps more usefully,
you can apply the `.toUnicodeName` transform in the non-reverse direction
to get the Unicode names for each character in a string:

```swift
"🥳✨".applyingTransform(.toUnicodeName, reverse: false)
// \\N{FACE WITH PARTY HORN AND PARTY HAT}\\N{SPARKLES}
```

{% info %}
The `\N` escape sequence corresponds to the
[ICU regular expression metacharacter `\N{UNICODE CHARACTER NAME}`](http://userguide.icu-project.org/strings/regexp#TOC-Regular-Expression-Metacharacters).
{% endinfo %}

## Things to Do with Character Viewer

Now that you're more familiar with Character Viewer,
here are some ideas for things to do with it:

### Add Keyboard Shortcut Characters to Favorites

All developers should take responsibility for writing documentation
about the software they work on
and the processes they use in their organization.

When providing instructions for using a Mac app,
it's often helpful to include the keyboard shortcuts
corresponding to menu items.
The symbols for modifier keys like Shift (<kbd>⇧</kbd>) are difficult to type,
so it's often more convenient to pick them from Character Viewer.
You can make it even easier for yourself by adding them to your Favorites list.

Click on the Action button at the top left corner of the Character Viewer panel
and select the Customize List... menu item.
In the displayed sheet,
scroll to the bottom of the categories listed under Symbols
and check the box next to Technical Symbols.

| ⌃ | Control | UP ARROWHEAD (U+2303) |
| ⌥ | Alt / Option | OPTION KEY (U+2325) |
| ⇧ | Shift | UPWARDS WHITE ARROW (U+21E7) |
| ⌘ | Command | PLACE OF INTEREST SIGN (U+2318) |

Dismiss the sheet and select Technical Symbols in the sidebar,
and you'll notice some familiar keyboard shortcut characters.
Add them to your Favorites list
by selecting each individually and
clicking the Add to Favorites button in the inspector.

{% asset character-viewer-add-to-favorites.png %}

### Demystify Unknown Characters

Ever see a character and wonder what it was?
Simply copy-paste it into the search field of Character Viewer
to get its name and number.

For example,
have you ever wondered about the  character you get by typing
<kbd>⌥</kbd><kbd>⇧</kbd><kbd>K</kbd>?
Like how did Apple get its logo into the Unicode Standard
when that goes against their
[criteria for encoding symbols](http://www.unicode.org/pending/symbol-guidelines.html)?

By copy-pasting into the Character Viewer,
you can learn that, in fact,
the Apple logo _isn't_ an encoded Unicode character.
Rather, it's a glyph associated with the code point U+F8FF
from the [Private-Use Area block](http://www.unicode.org/faq/private_use.html).

{% asset character-viewer-apple-logo.png %}

The next time you have a question about what's in your pasteboard,
consider asking Character Viewer instead of Safari.

### Divest Your Cryptocurrency

Given the current economic outlook for Bitcoin (₿) and other cryptocurrencies,
you may be looking to divest your holdings
in favor of something more stable and valuable
(sorry, too soon?).

Look no further than the Currency Symbols category
for some exciting investment opportunities, including
[French franc (₣)](https://en.wikipedia.org/wiki/French_franc) and
[Italian lira (₤)](https://en.wikipedia.org/wiki/Italian_lira).

{% asset character-viewer-currency-symbols.png %}

### Explore the Unicode Code Table

At the bottom of the Customize List... sheet,
you'll find a section titled Code Tables.
Go ahead and check the box next to Unicode.

{% asset character-viewer-unicode-code-chart.png %}

This is arguably the best interface available to you
for browsing the Unicode Standard.
No web page comes close to matching the speed and convenience of
what's available here in the macOS Character Viewer.

The top panel shows a sortable table of
[Unicode blocks](https://en.wikipedia.org/wiki/Unicode_block),
with their code point offset, name, and category.
Clicking on any of these entries
navigates to the corresponding offset in the bottom panel,
where characters are displayed in a 16-column grid.

_Brilliant._

---

Character Viewer is an indispensable tool for working with text on computers ---
_a hidden gem in macOS if ever there was one._

But even more than that,
Character Viewer offers a look into
our collective linguistic and cultural heritage
as encoded into the Unicode Standard.
Etchings made thousands of years ago, by
Phoenician merchants and
Qin dynasty bureaucrats and
Ancient Egyptian priests and
Lycian school children ---
they're preserved here digitally,
just waiting to be discovered.

_Seriously, how amazing is that?_

So if ever you grow weary of the awfulness of software...
take a scroll through the multitude of scripts and symbols
in the Unicode code table,
and take solace that we managed to get a _few_ things right along the way.
