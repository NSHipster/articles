---
title: TextOutputStream
author: Mattt
category: Swift
excerpt: >-
  `print` is among the most-used functions in the Swift standard library.
  Indeed, it's the first function a programmer learns 
  when writing "Hello, world!".
  So it's surprising how few of us are familiar with its other forms.
status:
  swift: 4.2
---

`print` is among the most-used functions in the Swift standard library.
Indeed, it's the first function a programmer learns
when writing "Hello, world!".
So it's surprising how few of us are familiar with its other forms.

For instance,
did you know that the actual signature of `print` is
[`print(_:separator:terminator:)`](https://developer.apple.com/documentation/swift/1541053-print)?
Or that it had a variant
[`print(_:separator:terminator:to:)`](https://developer.apple.com/documentation/swift/1641736-print)?

_Shocking, I know._

It's like learning that your best friend _"Chaz"_
goes by his middle name
and that his full legal name is _actually_
"R. Buckminster Charles Lagrand Jr." ---
oh, and also, they've had an identical twin the whole time.

Once you've taken a moment to collect yourself,
read on to find out the whole truth about a function
that you may have previously thought to need no further introduction.

---

Let's start by taking a closer look at that function declaration from before:

```swift
func print<Target>(_ items: Any...,
                   separator: String = default,
                   terminator: String = default,
                   to output: inout Target)
    where Target : TextOutputStream
```

This overload of `print`
takes a variable-length list of arguments,
followed by `separator` and `terminator` parameters ---
both of which have default values.

- `separator` is the string used to join
  the representation of each element in `items`
  into a single string.
  By default, this is a space (`" "`).
- `terminator` is the string appended to the end of the printed representation.
  By default, this is a newline (`"\n"`).

The last parameter, `output`
takes a mutable instance of a generic `Target` type
that conforms to the `TextOutputStream` protocol.

An instance of a type adopting to `TextOutputStream`
can be passed to the `print(_:to:)` function
to capture and redirect strings from standard output.

## Implementing a Custom Text Output Stream Type

Due to the mercurial nature of Unicode,
you can't know what characters lurk within a string
just by looking at it.
Between
[combining marks](http://www.unicode.org/faq/char_combmark.html),
[format characters](http://unicode.org/glossary/#format_character),
[unsupported characters](https://unicode.org/faq/unsup_char.html),
[variation sequences](https://unicode.org/faq/vs.html),
[ligatures, digraphs, and other presentational forms](http://www.unicode.org/faq/ligature_digraph.html),
a single extended grapheme cluster can contain much more than meets the eye.

So as an example,
let's create a custom type that conforms to `TextOutputStream`.
Instead of writing a string to standard output verbatim,
we'll have it inspect each constituent <dfn>code point</dfn>.

Conforming to the `TextOutputStream` protocol is simply a matter of
fulfilling the `write(_:)` method requirement.

```swift
protocol TextOutputStream {
    mutating func write(_ string: String)
}
```

In our implementation,
we iterate over each `Unicode.Scalar` value in the passed string;
the `enumerated()` collection method
provides the current offset on each loop.
At the top of the method,
a `guard` statement bails out early if the string is empty or a newline
(this reduces the amount of noise in the console).

```swift
struct UnicodeLogger: TextOutputStream {
    mutating func write(_ string: String) {
        guard !string.isEmpty && string != "\n" else {
            return
        }

        for (index, unicodeScalar) in
            string.unicodeScalars.lazy.enumerated()
        {
            let name = unicodeScalar.name ?? ""
            let codePoint = String(format: "U+%04X", unicodeScalar.value)
            print("\(index): \(unicodeScalar) \(codePoint)\t\(name)")
        }
    }
}
```

To use our new `UnicodeLogger` type,
initialize it and assign it to a variable (with `var`)
so that it can be passed as an `inout` argument.
Anytime we want to get an X-ray of a string
instead of merely printing its surface representation,
we can tack on an additional parameter to our `print` statement.

Doing so allows us to reveal a secret about the emoji character 👨‍👩‍👧‍👧:
it's actually a
[sequence](https://unicode.org/emoji/charts/emoji-zwj-sequences.html)
of four individual emoji
joined by <abbr title="zero width joiner">ZWJ</abbr> characters ---
_seven code points in total!_

```swift
print("👨‍👩‍👧‍👧")
// Prints: "👨‍👩‍👧‍👧"

var logger = UnicodeLogger()
print("👨‍👩‍👧‍👧", to: &logger)
// Prints:
// 0: 👨 U+1F468    MAN
// 1:    U+200D     ZERO WIDTH JOINER
// 2: 👩 U+1F469    WOMAN
// 3:    U+200D     ZERO WIDTH JOINER
// 4: 👧 U+1F467    GIRL
// 5:    U+200D     ZERO WIDTH JOINER
// 6: 👧 U+1F467    GIRL
```

{% info %}

In Swift 5.0,
you can access the name of a scalar value by
through its Unicode `properties` property.
In the meantime, we can use
[a string transform](https://nshipster.com/cfstringtransform/)
to pull the name for us
(we just need to strip some cruft at either end).

```swift
import Foundation

extension Unicode.Scalar {
    var name: String? {
        guard var escapedName =
                "\(self)".applyingTransform(.toUnicodeName,
                                            reverse: false)
        else {
            return nil
        }

        escapedName.removeFirst(3) // remove "\\N{"
        escapedName.removeLast(1) // remove "}"

        return escapedName
    }
}
```

For more information, see
[SE-0211: "Add Unicode Properties to Unicode.Scalar"](https://github.com/apple/swift-evolution/blob/master/proposals/0211-unicode-scalar-properties.md).

{% endinfo %}

## Ideas for Using Custom Text Output Streams

Now that we know about an obscure part of the Swift standard library,
what can we do with it?

As it turns out,
there are plenty of potential use cases for `TextOutputStream`.
To get a better sense of what they are,
consider the following examples:

### Logging to Standard Error

By default,
Swift `print` statements are directed to
[<dfn>standard output (`stdout`)</dfn>](https://en.wikipedia.org/wiki/Standard_streams#Standard_output).
If you wanted to instead direct to
<dfn>standard error (`stderr`)</dfn>,
you could create a new text output stream type
and use it in the following way:

```swift
import func Darwin.fputs
import var Darwin.stderr

struct StderrOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}

var standardError = StderrOutputStream()
print("Error!", to: &standardError)
```

### Writing Output to a File

The previous example of writing to `stderr`
can be generalized to write to any stream or file
by instead creating an output stream to a `FileHandle`
(for which standard error is accessible through a type property).

```swift
import Foundation

struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}
```

Following this approach,
you can customize `print` to write to a file instead of a stream.

```swift
let url = URL(fileURLWithPath: "<#/path/to/file.txt#>")
let fileHandle = try FileHandle(forWritingTo: url)
var output = FileHandlerOutputStream(fileHandle)

print("\(Date())", to: &output)
```

### Escaping Streamed Output

As a final example,
let's imagine a situation in which you find yourself
frequently copy-pasting console output into a form on some website.
Unfortunately,
the website has the unhelpful behavior of
trying to parse `<` and `>` as if they were HTML.

Rather than taking an extra step to escape the text
each time you post to the site,
you could create a `TextOutputStream`
that takes care of that for you automatically
(in this case, we use an XML-escaping function
that we found buried deep in Core Foundation).

```swift
import Foundation

struct XMLEscapingLogger: TextOutputStream {
    mutating func write(_ string: String) {
        guard !string.isEmpty && string != "\n",
            let xmlEscaped = CFXMLCreateStringByEscapingEntities(nil, string as NSString, nil)
        else {
            return
        }

        print(xmlEscaped)
    }
}

var logger = XMLEscapingLogger()
print("<3", to: &logger)
// Prints "&lt;3"
```

---

Printing is a familiar and convenient way
for developers to understand the behavior of their code.
It complements more comprehensive techniques
like logging frameworks and debuggers,
and --- in the case of Swift ---
proves to be quite capable in its own right.

Have any other cool ideas for using `TextOutputStream` that you'd like to share?
Let us know [on Twitter](https://twitter.com/nshipster)!
