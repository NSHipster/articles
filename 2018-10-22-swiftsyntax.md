---
title: SwiftSyntax
author: Mattt
category: Swift
excerpt: >
  SwiftSyntax is a Swift library
  that lets you parse, analyze, generate, and transform Swift source code.
  It's what swift-format, SwiftLint, and Swift macros are built on.
  Let's take a look at how it works,
  and use it to write a linter, a rewriter, and a syntax highlighter.
revisions:
  "2018-10-22": Original publication
  "2026-10-09": Rewritten for swift-syntax 604 and Swift 6.2
status:
  swift: 6.2
  reviewed: October 9, 2026
---

[SwiftSyntax](https://github.com/swiftlang/swift-syntax) is a Swift library
that lets you parse, analyze, generate, and transform Swift source code.

When we first wrote about it in 2018,
SwiftSyntax was an experimental wrapper around a C++ library called libSyntax.
To get a syntax tree,
you had to write your code to a file,
shell out to `swiftc` with a frontend flag,
and decode the JSON it spat out.
Generating code was even worse.
At the time of writing,
we said it was "still in development and subject to API changes."

_Reader, it was subject to API changes._

Nearly every API from the original version of this article is gone.
libSyntax is gone too.
In its place is a package written entirely in Swift,
with its own parser,
and a release schedule tied to the language itself.
Today, swift-syntax is what [swift-format](/swift-format/) and
[SwiftLint](https://github.com/realm/SwiftLint) use to read your code,
and it's what every Swift macro uses to write it.

So let's take another look.

---

## What Is SwiftSyntax?

SwiftSyntax represents Swift source code as a <dfn>syntax tree</dfn>:
a data structure that captures both the text of a file
and the grammatical relationships between its parts.
[The documentation](https://swiftpackageindex.com/swiftlang/swift-syntax/documentation/swiftsyntax/working-with-swiftsyntax)
describes three design tenets:

- **Immutability**:
  Syntax trees never change.
  "Modifying" a tree produces a new one
  that shares all unchanged structure with the original,
  which also makes them safe to pass between threads.
- **Source fidelity**:
  The tree keeps every byte of the input,
  including whitespace and comments,
  so it can reproduce the original text exactly.
- **Resilience**:
  The parser accepts _any_ input.
  Code that doesn't parse cleanly
  is represented with "missing" and "unexpected" nodes
  instead of being rejected.

That last point matters more than it might seem.
The code in your editor is broken most of the time you're typing it,
and tools that work on source code need to cope with that.

It's also important to understand what SwiftSyntax _doesn't_ do.
It works at the level of syntax only,
so it can tell you that `x` is an identifier,
but not what type `x` has or where it was declared.
For semantic information,
you need the compiler itself,
by way of SourceKit or
[sourcekit-lsp](/language-server-protocol/).
But plenty of useful tools need only syntax:
formatters, linters, code generators,
syntax highlighters, and macros.

### Versions and Modules

Starting with Swift 5.8,
swift-syntax dropped its old `0.50x00.0` version scheme
in favor of major versions that match the language:
`508.0.0` for Swift 5.8,
`509.0.0` for Swift 5.9,
`600.0.0` for Swift 6.0,
and so on.
As of this writing,
the latest release is `604.0.0`,
which corresponds to Swift 6.4.

Add it to your `Package.swift` like any other dependency:

```swift
dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "604.0.0")
],
targets: [
    .executableTarget(
        name: "Spooky",
        dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        ]
    )
]
```

The package is split into more than a dozen library products.
These are the ones you'll reach for first:

- **SwiftSyntax**: the syntax tree types, visitors, and rewriters
- **SwiftParser**: a parser that turns source text into a syntax tree
- **SwiftSyntaxBuilder**: APIs for building syntax trees from string literals and result builders
- **SwiftBasicFormat**: a simple pretty-printer for generated code
- **SwiftIDEUtils**: editor-oriented utilities, including syntax classification
- **SwiftSyntaxMacros**: the protocols you implement to write a macro

## Demystifying the Syntax Tree

Syntax trees can be difficult to understand in the abstract.
So let's parse some code and see what it looks like.

Consider the following single-line Swift program,
which declares a function named `one()` that returns the value `1`.
Pass it to `Parser.parse(source:)`
and print the result's `debugDescription`:

```swift
import SwiftParser
import SwiftSyntax

let source = "func one() -> Int { return 1 }"
let sourceFile = Parser.parse(source: source)

print(sourceFile.debugDescription)
```

That prints the following:

```
SourceFileSyntax
├─statements: CodeBlockItemListSyntax
│ ╰─[0]: CodeBlockItemSyntax
│   ╰─item: FunctionDeclSyntax
│     ├─attributes: AttributeListSyntax
│     ├─modifiers: DeclModifierListSyntax
│     ├─funcKeyword: keyword(SwiftSyntax.Keyword.func)
│     ├─name: identifier("one")
│     ├─signature: FunctionSignatureSyntax
│     │ ├─parameterClause: FunctionParameterClauseSyntax
│     │ │ ├─leftParen: leftParen
│     │ │ ├─parameters: FunctionParameterListSyntax
│     │ │ ╰─rightParen: rightParen
│     │ ╰─returnClause: ReturnClauseSyntax
│     │   ├─arrow: arrow
│     │   ╰─type: IdentifierTypeSyntax
│     │     ╰─name: identifier("Int")
│     ╰─body: CodeBlockSyntax
│       ├─leftBrace: leftBrace
│       ├─statements: CodeBlockItemListSyntax
│       │ ╰─[0]: CodeBlockItemSyntax
│       │   ╰─item: ReturnStmtSyntax
│       │     ├─returnKeyword: keyword(SwiftSyntax.Keyword.return)
│       │     ╰─expression: IntegerLiteralExprSyntax
│       │       ╰─literal: integerLiteral("1")
│       ╰─rightBrace: rightBrace
╰─endOfFileToken: endOfFile
```

That's a lot more pleasant than the JSON we were squinting at in 2018.

At the top level, we have a `SourceFileSyntax`
containing a list of `CodeBlockItemSyntax` elements.
This example has a single item,
a function declaration (`FunctionDeclSyntax`),
which comprises the `func` keyword,
the function's name,
a signature with a parameter clause and return clause,
and a body.
The leaves of the tree are <dfn>tokens</dfn> (`TokenSyntax`):
keywords, identifiers, literals, and punctuation.
Empty collections,
like the function's attributes and modifiers,
still appear in the tree;
optional parts that aren't there,
like a generic parameter clause, don't.

Where did all the spaces go?
SwiftSyntax uses the term <dfn>trivia</dfn>
for anything that isn't syntactically meaningful,
like whitespace and comments.
Each token has leading and trailing trivia attached to it.
Call `debugDescription(includeTrivia: true)` instead,
and you'll see that the `func` keyword carries a single trailing space:

```
funcKeyword: keyword(SwiftSyntax.Keyword.func) trailingTrivia=spaces(1)
```

Because of this,
converting a tree back to a string gives you exactly what you started with.
`sourceFile.description == source` is always `true`,
even for code that doesn't compile.
To check whether the parser had to recover from errors,
look at the tree's `hasError` property.

{% info do %}
For a more interactive way to explore syntax trees,
try [Swift AST Explorer](https://swift-ast-explorer.com),
which shows the SwiftSyntax tree for any code you paste in.
{% endinfo %}

## Walking the Tree

Once you have a syntax tree,
the usual way to look through it is to subclass `SyntaxVisitor`.
Override `visit(_:)` for the kinds of nodes you care about,
and call `walk(_:)` to traverse the tree from the root to its leaves.
Each `visit(_:)` method returns a `SyntaxVisitorContinueKind`
that says whether to descend into the node's children
(`.visitChildren`) or move on (`.skipChildren`).

For example,
here's a tiny linter that flags force unwraps (`!`) and force tries (`try!`):

```swift
import SwiftParser
import SwiftSyntax

final class ForceFinder: SyntaxVisitor {
    let converter: SourceLocationConverter
    var warnings: [String] = []

    init(converter: SourceLocationConverter) {
        self.converter = converter
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: ForceUnwrapExprSyntax) -> SyntaxVisitorContinueKind {
        warn(node, "force unwrap")
        return .visitChildren
    }

    override func visit(_ node: TryExprSyntax) -> SyntaxVisitorContinueKind {
        if node.questionOrExclamationMark?.tokenKind == .exclamationMark {
            warn(node, "force try")
        }
        return .visitChildren
    }

    private func warn(_ node: some SyntaxProtocol, _ message: String) {
        let location = node.startLocation(converter: converter)
        warnings.append("\(location.file):\(location.line):\(location.column): warning: \(message)")
    }
}

let source = """
let url = URL(string: "https://nshipster.com")!
let data = try! Data(contentsOf: url)
"""

let sourceFile = Parser.parse(source: source)
let converter = SourceLocationConverter(fileName: "Example.swift", tree: sourceFile)
let finder = ForceFinder(converter: converter)
finder.walk(sourceFile)

for warning in finder.warnings {
    print(warning)
}
// Example.swift:1:11: warning: force unwrap
// Example.swift:2:12: warning: force try
```

The `viewMode` passed to `SyntaxVisitor.init(viewMode:)`
determines how the visitor treats the missing and unexpected nodes
that the parser creates when it recovers from errors.
`.sourceAccurate` visits only what's actually in the source text.
A `SourceLocationConverter` maps positions in the tree
back to line and column numbers you can show to a human.

Since this is all syntax,
there's no way to tell whether a given force unwrap is a good idea.
The visitor knows that something is being unwrapped;
it doesn't know what, or whether it could ever be `nil`.
That's a limit of any syntax-based linter,
and a big part of why
swift-format's equivalent rules are off by default.

## Rewriting Swift Code

Where `SyntaxVisitor` looks,
`SyntaxRewriter` touches.
Its `visit(_:)` methods return a node,
and whatever you return replaces the original in a new tree.

[The examples in the swift-syntax repository](https://github.com/swiftlang/swift-syntax/tree/main/Examples)
include a rewriter that takes each integer literal in a source file
and increments its value by one.
Sensible enough.
But let's consider a considerably _less_ productive ---
and more seasonally appropriate (🎃) ---
use of source rewriting:

```swift
import SwiftSyntax

final class ZalgoRewriter: SyntaxRewriter {
    override func visit(_ token: TokenSyntax) -> TokenSyntax {
        guard case .stringSegment(let text) = token.tokenKind else {
            return token
        }

        var token = token
        token.tokenKind = .stringSegment(zalgo(text))
        return token
    }
}
```

The `visit(_:)` overload for `TokenSyntax` is called for every token in the tree.
String literals are made up of several tokens,
including the quotation marks themselves,
so we look for `.stringSegment` tokens,
which hold the literal text between them.
Although syntax nodes are immutable,
their properties have setters that work on a copy,
so the body reads like a normal value-type mutation.

What's that
[`zalgo`](https://gist.github.com/mattt/b46ab5027f1ee6ab1a45583a41240033)
function all about?
You're probably better off not knowing...

Anyway, parse your source code,
pass it to the rewriter's `rewrite(_:)` method,
and print the result:

```swift
import SwiftParser

let sourceFile = Parser.parse(source: source)
let possessed = ZalgoRewriter().rewrite(sourceFile)
print(possessed)
```

Every string literal is transformed in the following manner:

```swift
// Before 👋😄
print("Hello, world!")

// After 🦑😵
print("H͞͏̟̂ͩel̵ͬ͆͜ĺ͎̪̣͠ơ̡̼͓̋͝, w͎̽̇ͪ͢ǒ̩͔̲̕͝r̷̡̠͓̉͂l̘̳̆ͯ̊d!")
```

_Spooky, right?_

## Writing Swift Code: The Easy Way

The original version of this article included a section titled
"Writing Swift Code: The Hard Way."
It took twenty-odd lines of
`SyntaxFactory` calls and builder closures
to produce the following:

```swift
struct Example {
}
```

_Oofa doofa._

Here's how you do that today with SwiftSyntaxBuilder:

```swift
import SwiftSyntax
import SwiftSyntaxBuilder

let example: DeclSyntax = "struct Example {}"
```

Syntax nodes conform to `ExpressibleByStringInterpolation`,
so you write the code you want as a string,
and the parser turns it into a tree.
Interpolations let you parameterize it:
interpolate another syntax node to splice it in,
use `\(raw:)` to insert text verbatim,
or use `\(literal:)` to turn a Swift value
into the corresponding literal expression,
with quotes and escaping handled for you.

For larger structures,
SwiftSyntaxBuilder provides result builder initializers
that you can mix with string interpolation freely,
`for` loops and `if` statements included:

```swift
import SwiftSyntax
import SwiftSyntaxBuilder

let monsters = ["ghost", "goblin", "vampire", "werewolf", "zombie"]

let source = try SourceFileSyntax {
    try EnumDeclSyntax("enum Monster: String, CaseIterable") {
        for monster in monsters {
            DeclSyntax("case \(raw: monster)")
        }
    }
}

print(source.formatted())
```

Running that prints:

```swift
enum Monster: String, CaseIterable {
    case ghost
    case goblin
    case vampire
    case werewolf
    case zombie
}
```

The initializer that takes a header string and a member builder
is marked `throws`
because the header could turn out to be something other than an `enum`.
The `formatted()` method comes from SwiftBasicFormat,
which adds the newlines and indentation that generated code otherwise lacks.
(Fittingly, `BasicFormat` is itself a subclass of `SyntaxRewriter`.)

{% warning do %}
Code in string literals is parsed at runtime,
so a typo won't stop your code generator from compiling.
If the parser has to recover from errors,
the resulting node has `hasError` set,
and on Apple platforms a fault is logged with the parser's diagnostics.
{% endwarning %}

So, does this replace [GYB](/swift-gyb/) for everyday code generation?
For anything that goes through a build tool plugin or a macro,
it's a strong contender.

## Highlighting Swift Code

Let's conclude our look at SwiftSyntax
with something that's actually useful:
a syntax highlighter.

A <dfn>syntax highlighter</dfn>, in this sense,
describes any tool that takes source code
and formats it in a way that's more suitable for display in HTML.

Back in 2018,
we [built one](https://github.com/NSHipster/SwiftSyntaxHighlighter)
by subclassing `SyntaxRewriter`
and switching over every kind of token,
with a `default` case that printed whatever we'd forgotten to handle.
It worked, but it was a lot of code,
and it's still pinned to swift-syntax `0.50300.0`.

Today, the SwiftIDEUtils module does the hard part.
The `classifications` property on any syntax node
returns a sequence of consecutive ranges covering the node's full text,
comments and whitespace included,
each tagged with a `SyntaxClassification`
like `.keyword`, `.type`, `.stringLiteral`, or `.lineComment`.
All that's left is to map those to
[the CSS classes used by Rouge and Pygments](https://github.com/rouge-ruby/rouge/blob/main/lib/rouge/token.rb):

```swift
import Foundation
import SwiftIDEUtils
import SwiftParser
import SwiftSyntax

func highlight(_ source: String) -> String {
    let sourceFile = Parser.parse(source: source)
    let bytes = Array(source.utf8)

    var html = ""
    for classified in sourceFile.classifications {
        let range = classified.range
        let slice = bytes[range.lowerBound.utf8Offset..<range.upperBound.utf8Offset]
        let text = String(decoding: slice, as: UTF8.self)
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        if let cssClass = classified.kind.cssClass {
            html += #"<span class="\#(cssClass)">\#(text)</span>"#
        } else {
            html += text
        }
    }

    return #"<pre class="highlight"><code>\#(html)</code></pre>"#
}

extension SyntaxClassification {
    var cssClass: String? {
        switch self {
        case .keyword: "k"
        case .type: "kt"
        case .identifier, .dollarIdentifier: "n"
        case .argumentLabel: "nl"
        case .attribute: "nd"
        case .stringLiteral: "s"
        case .regexLiteral: "sr"
        case .integerLiteral: "mi"
        case .floatLiteral: "mf"
        case .operator: "o"
        case .lineComment: "c1"
        case .blockComment: "cm"
        case .docLineComment, .docBlockComment: "cd"
        case .ifConfigDirective: "cp"
        case .editorPlaceholder, .none: nil
        }
    }
}
```

Classified ranges are expressed as UTF-8 offsets,
so we slice the source's UTF-8 bytes rather than its characters.
And because classifications come from the parser
rather than a pile of regular expressions,
a contextual keyword like `async` is highlighted as a keyword
only where it's actually used as one.

## Standing on the Syntax Tree

Most of the SwiftSyntax code that runs on your machine
wasn't written by you.

**swift-format** is built on swift-syntax from top to bottom.
Its lint rules are `SyntaxVisitor` subclasses
(including `NeverForceUnwrap` and `NeverUseForceTry`,
which are more thorough versions of the visitor we wrote earlier),
its format rules are `SyntaxRewriter` subclasses,
and its pretty-printer works from the syntax tree.
Since Swift 6, it ships with the toolchain,
so you can run it as `swift format`.
[SwiftLint](https://github.com/realm/SwiftLint) uses swift-syntax as well.

**Macros** are where swift-syntax really comes into its own.
A macro is a compiler plugin that receives syntax nodes as input
and returns new syntax nodes as output,
so every macro implementation is a swift-syntax program.
Here's the `#stringify` macro from
[the swift-syntax examples](https://github.com/swiftlang/swift-syntax/tree/main/Examples),
which expands `#stringify(x + y)` to `(x + y, "x + y")`:

```swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}
```

Everything in there should look familiar by now:
a syntax node comes in,
string interpolation builds a new one,
and `\(literal:)` turns the argument's source text into a string literal.
There's a lot more to say about macros,
and we'll save it for another article.
In the meantime,
[the SwiftSyntaxMacros documentation](https://swiftpackageindex.com/swiftlang/swift-syntax/documentation/swiftsyntaxmacros)
is a good place to start.

---

In 2018,
SwiftSyntax was an intriguing preview of what structured editing
could look like for Swift.
Eight years and a few hundred API changes later,
it's an essential part of the toolchain.
If you've been putting off writing that linter,
code generator, or refactoring tool,
the hard part is already done.
