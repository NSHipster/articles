---
title: Regular Expressions in Swift
author: Mattt
category: Swift
excerpt: >-
  Regular expressions are a powerful tool for working with text,
  but it's often a mystery how to get use them in Swift.
status:
  swift: 5.0
---

Like everyone else in the Pacific Northwest,
we got snowed-in over the weekend.
To pass the time,
we decided to break out our stash of board games:
Carcassonne, Machi Koro, Power Grid, Pandemic;
we had plenty of excellent choices available.
But cooped up in our home for the afternoon,
we decided on a classic:
_[Cluedo](https://en.wikipedia.org/wiki/Cluedo)_.

Me, I'm an avid fan of Cluedo ---
and _yes_, that's what I'm going to call it.
Because despite being born and raised in the United States,
where the game is sold and marketed exclusively under the name "Clue",
I _insist_ on referring to it by its proper name.
(Otherwise, how would we refer to the [1985 film adaptation](https://en.wikipedia.org/wiki/Clue_%28film%29)?)

Alas,
my relentless pedantry often causes me to miss out on invitations to play.
If someone were to ask:

```swift
var invitation = "Hey, would you like to play Clue?"
invitation.contains("Cluedo") // false
```

...I'd have no idea what they were talking about.
If only they'd bothered to phrase it properly,
there'd be no question about their intention:

```swift
invitation = "Fancy a game of Cluedo™?"
invitation.contains("Cluedo") // true
```

Of course,
a <dfn>regular expression</dfn>
would allow me to relax my exacting standards.
I could listen for `/Clue(do)?™?/`
and never miss another invitation.

But who can be bothered to figure out regexes in Swift, anyway?

Well,
sharpen your pencils,
gather your detective notes,
and warm up your 6-sided dice,
because this week on NSHipster,
we crack the case of the cumbersome class known as `NSRegularExpression`.

---

Who killed regular expressions in Swift? <br/>
I have a suggestion:

> _It was `NSRegularExpression`, in the API, with the cumbersome usability._

In any other language,
regular expressions are something you can sling around in one-liners.

- _Need to substitute one word for another?_
  **Boom**: regular expression.
- _Need to extract a value from a templated string?_
  **Boom**: regular expression.
- _Need to parse XML?_
  **Boom**: <del>regular expression</del>
  <ins>actually, you should really use an XML parser in this case</ins>

But in Swift,
you have to go through the trouble of
initializing an `NSRegularExpression` object
and converting back and forth from `String` ranges to `NSRange` values.
It's a total drag.

Here's the good news:

1. You don't need `NSRegularExpression` to use regular expressions in Swift.
2. Recent additions in Swift 4 and 5 make it much, _much_ nicer
   to use `NSRegularExpression` when you need to.

Let's interrogate each of these points, in order:

---

## Regular Expressions without NSRegularExpression

You may be surprised to learn that you can --- in fact ---
use regular expressions in a Swift one-liner:
you just have to bypass `NSRegularExpression` entirely.

### Matching Strings Against Patterns

When you import the Foundation framework,
the Swift `String` type automatically gets access to
`NSString` instance methods and initializers.
Among these is `range(of:options:range:locale:)`,
which finds and returns the first range of the specified string.

Normally,
this performs a by-the-books substring search operation.
_Meh._

But, if you pass the `.regularExpression` option,
the string argument is matched as a pattern.
_Eureka!_

Let's take advantage of this lesser-known feature
to dial our _Cluedo sense_ to the _"American"_ setting.

```swift
import Foundation

let invitation = "Fancy a game of Cluedo™?"
invitation.range(of: #"\bClue(do)?™?\b"#,
                 options: .regularExpression) != nil // true
```

If the pattern matches the specified string,
the method returns a `Range<String.Index>` object.
Therefore, checking for a non-`nil` value
tells us whether or not a match occurred.

The method itself provides default arguments to the
`options`, `range`, and `locale` parameters;
by default, it localized, unqualified search
over the entire string
according to the current locale.

Within a regular expression,
the `?` operator matches the preceding character or group zero or one times.
We use it in our pattern
to make the "-do" in _"Cluedo"_ optional
(accommodating both the American and _correct_ spelling),
and allow a trademark symbol (™)
for anyone wishing to be prim and proper about it.

The `\b` metacharacters match if the current position is a word boundary,
which occurs between word (`\w`) and non-word (`\W`) characters.
Anchoring our pattern to match on word boundaries
prevents false positives like "Pseudo-Cluedo".

{% info %}
The [raw string literals](https://github.com/apple/swift-evolution/blob/master/proposals/0200-raw-string-escaping.md)
introduced in Swift 5
are a _perfect_ fit for declaring regular expression patterns,
which frequently contain backslashes (such as for the `\b` metacharacter)
that would otherwise need to be escaped.
{% endinfo %}

That solves our problem of missing out on invitations.
The next question is how to respond in kind.

### Searching and Retrieving Matches

Rather than merely checking for a non-`nil` value,
we can actually use the return value
to see the string that got matched.

```swift
import Foundation

func respond(to invitation: String) {
  if let range = invitation.range(of: #"\bClue(do)?™?\b"#,
                                  options: .regularExpression) {
    switch invitation[range] {
    case "Cluedo":
        print("I'd be delighted to play!")
    case "Clue":
        print("Did you mean Cluedo? If so, then yes!")
    default:
        fatalError("(Wait... did I mess up my regular expression?)")
    }
  } else {
    print("Still waiting for an invitation to play Cluedo.")
  }
}
```

Conveniently,
the range returned by the `range(of:...)` method
can be plugged into a subscript to get a `Substring`
for the matching range.

### Finding and Replacing Matches

Once we've established that the game is on,
the next step is to read the instructions.
_(Despite its relative simplicity,
players often forget important rules in Cluedo,
such as needing to be in a room in order to suggest it.)_

Naturally, we play the original, British edition.
But as a favor to the _American_ players,
I'll go to the trouble of localizing the rules _on-the-fly_.
For example, the victim's name in the original version is "Dr. Black",
but in America, it's "Mr. Boddy".

We automate this process
using the `replacingOccurrences(of:with:options:)` method ---
again passing the `.regularExpression` option.

```swift
import Foundation

let instructions = """
The object is to solve by means of elimination and deduction
the problem of the mysterious murder of Dr. Black.
"""

instructions.replacingOccurrences(
    of: #"(Dr.|Doctor) Black"#,
    with: "Mr. Boddy",
    options: .regularExpression
)
```

## Regular Expressions with NSRegularExpression

There are limits to what we can accomplish with
the `range(of:options:range:locale:)` and
`replacingOccurrences(of:with:options:)` methods.

Specifically,
you'll need to use `NSRegularExpression`
if you want to match a pattern more than once in a string
or extract values from capture groups.

### Enumerating Matches with Positional Capture Groups

A regular expression can match its pattern
one or more times on a string.
Within each match,
there may be one or more <dfn>capture groups</dfn>,
which are designated by enclosing by parentheses in the regex pattern.

For example,
let's say you wanted to use regular expressions
to determine how many players you need to play Cluedo:

```swift
import Foundation

let description = """
Cluedo is a game of skill for 2-6 players.
"""

let pattern = #"(\d+)[ \p{Pd}](\d+) players"#
let regex = try NSRegularExpression(pattern: pattern, options: [])
```

This pattern includes two capture groups for
one or more digits,
as denoted by the `+` operator and `\d` metacharacter, respectively.

Between them, we match on a set containing a space
and any character in the
[Unicode General Category](https://en.wikipedia.org/wiki/Unicode_character_property#General_Category)
`Pd` (Punctuation, dash).
This allows us to match on
hyphen / minus (`-`), en dash (`–`), em dash (`—`),
or whatever other exotic typographical marks we might encounter.

{% info %}
The en dash is the correct punctuation
for denoting a span or range of numbers.
{% endinfo %}

We can use the `enumerateMatches(in:options:range)` method
to try each match until we find one that
has three ranges (the entire match and the two capture groups),
whose captured values can be used to initialize a valid range.
In the midst of all of this,
we use the new(-ish)
`NSRange(_: in:)` and `Range(_:in:)` initializers
to convert between `String` and `NSString` index ranges.
Once we find such a match,
we set the third closure parameter (a pointer to a Boolean value)
to `true` as a way to tell the enumeration to stop.

```swift
var playerRange: ClosedRange<Int>?

let nsrange = NSRange(description.startIndex..<description.endIndex,
                      in: description)
regex.enumerateMatches(in: description,
                       options: [],
                       range: nsrange) { (match, _, stop) in
    guard let match = match else { return }

    if match.numberOfRanges == 3,
       let firstCaptureRange = Range(match.range(at: 1),
                                     in: description),
       let secondCaptureRange = Range(match.range(at: 2),
                                      in: description),
       let lowerBound = Int(description[firstCaptureRange]),
       let upperBound = Int(description[secondCaptureRange]),
       lowerBound > 0 && lowerBound < upperBound
    {
        playerRange = lowerBound...upperBound
        stop.pointee = true
    }
}

print(playerRange!)
// Prints "2...6"
```

Each capture group can be accessed by position
by calling the `range(at:)` method on the match object.

_\*Sigh\*_.
What? No, we like the solution we came up with ---
longwinded as it may be.
It's just...
gosh, wouldn't it be nice if we could play Cluedo solo?

### Matching Multi-Line Patterns with Named Capture Groups

The only thing making Cluedo a strictly multiplayer affair
is that you need some way to test a theory
without revealing the answer to yourself.

If we wanted to write a program to check that
without spoiling anything for us,
one of the first steps would be to parse a suggestion
into its component parts:
**suspect**,
**location**, and
**weapon**.

```swift
let suggestion = """
I suspect it was Professor Plum, \
in the Dining Room,              \
with the Candlestick.
"""
```

When writing a complex regular expression,
it helps to know exactly _which_ features your platform supports.
In the case of Swift,
`NSRegularExpression` is a wrapper around the
[ICU regular expression engine](http://userguide.icu-project.org/strings/regexp),
which lets us do some really nice things:

```swift
let pattern = #"""
(?xi)
(?<suspect>
    ((Miss|Ms.) \h Scarlett?) |
    ((Colonel | Col.) \h Mustard) |
    ((Reverend | Mr.) \h Green) |
    (Mrs. \h Peacock) |
    ((Professor | Prof.) \h Plum) |
    ((Mrs. \h White) | ((Doctor | Dr.) \h Orchid))
),?(?-x: in the )
(?<location>
    Kitchen        | Ballroom | Conservatory |
    Dining \h Room      |       Library      |
    Lounge         | Hall     | Study
),?(?-x: with the )
(?<weapon>
      Candlestick
    | Knife
    | (Lead(en)?\h)? Pipe
    | Revolver
    | Rope
    | Wrench
)
"""#

let regex = try NSRegularExpression(pattern: pattern, options: [])
```

First off,
declaring the pattern with a multi-line raw string literal
is a huge win in terms of readability.
That, in combination with the `x` and `i` flags within those groups,
allows us to use whitespace to organize our expression
into something more understandable.

Another nicety is how
this pattern uses <dfn>named capture groups</dfn>
(designated by `(?<name>)`) instead of the
standard, positional capture groups from the previous example.
Doing so allows us to access groups by name
by calling the `range(withName:)` method on the match object.

Beyond the more outlandish maneuvers,
we have affordances for regional variations, including
the spelling of "Miss Scarlet(t)",
the title of "Mr. / Rev. Green",
and the replacement of Mrs. White with Dr. Orchid
in standard editions after 2016.

```swift
let nsrange = NSRange(suggestion.startIndex..<suggestion.endIndex,
                      in: suggestion)
if let match = regex.firstMatch(in: suggestion,
                                options: [],
                                range: nsrange)
{
    for component in ["suspect", "location", "weapon"] {
        let nsrange = match.range(withName: component)
        if nsrange.location != NSNotFound,
            let range = Range(nsrange, in: suggestion)
        {
            print("\(component): \(suggestion[range])")
        }
    }
}
// Prints:
// "suspect: Professor Plum"
// "location: Dining Room"
// "weapon: Candlestick"
```

---

Regular expressions are a powerful tool for working with text,
but it's often a mystery how to get use them in Swift.
We hope this article has helped clue you into finding a solution.
