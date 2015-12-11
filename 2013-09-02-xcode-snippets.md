---
title: Xcode Snippets
author: Mattt Thompson
category: Xcode
excerpt: "iOS development all but requires the use of Xcode. And if we're resigned to use an IDE in our development workflow, we might as well make the most of it, right? So this week on NSHipster, we're going to talk about one of the more powerful yet underused features of Xcode: Code Snippets"
status:
    swift: n/a
---

iOS development all but requires the use of Xcode. To its credit, Xcode has improved pretty consistently over the last couple of years. Sure, [it still has its... quirks](http://www.textfromxcode.com), but hey—things could be [much, much worse](http://www.eclipse.org).

Working in an IDE may not be as cool as working in your favorite [decades-old editor](http://en.wikipedia.org/wiki/Vim_(text_editor)) (or [that other one](http://en.wikipedia.org/wiki/Emacs)), but you know what is cool? [Autocompletion](http://www.textfromxcode.com/post/24542673087). Not to mention [Build & Analyze](http://clang-analyzer.llvm.org/xcode.html), [Breakpoints](https://developer.apple.com/library/ios/recipes/xcode_help-source_editor/Creating,Disabling,andDeletingBreakpoints/Creating,Disabling,andDeletingBreakpoints.html), and [Instruments](https://developer.apple.com/library/ios/DOCUMENTATION/DeveloperTools/Conceptual/InstrumentsUserGuide/InstrumentsQuickStart/InstrumentsQuickStart.html).

This is all to say: if we're resigned to use an IDE in our development workflow, we might as well make the most of it, right? So this week on NSHipster, we're going to talk about one of the more powerful yet underused features of Xcode: **Code Snippets**.

---

From `@interface` declarations to `if (!self) return nil;` incantations, there is a lot of avoidable typing in Objective-C. Xcode snippets allow these common patterns and boilerplate code to be extracted for quick reuse.

## Using Xcode Snippets

To see the available code snippets, show the Utilities panel, to the right of your editor. On the bottom half the Utilities panel, there will be a horizontal divider with 4 icons.

![Utilities Divider]({{ site.asseturl }}/xcode-snippet-utilities-divider.png)

Click the `{ }` icon to show the Code Snippets Library.

![Utilities Panel]({{ site.asseturl }}/xcode-snippet-utilties-panel.png)

There are two ways to insert a snippet into your code:

You can drag and drop from the code snippets library into your editor:

![Drag-and-Drop]({{ site.asseturl }}/xcode-snippet-drag-and-drop.gif)

...or for snippets that include a text completion shortcut, you can start typing that:

![Text Completion Shortcut]({{ site.asseturl }}/xcode-snippet-text-completion-shortcut.gif)

To get a sense of what you can do with snippets, here's an overview of the ones built-in to Xcode:

- C `typedef` declarations for `enum`, `struct` `union`, and blocks
- C control flow statements like `if`, `if`...`else`, and `switch`
- C loops, such as `for`, `while`, and `do`...`while`
- C inline block variable declaration
- Objective-C declarations for `@interface` (including for class extensions and categories), `@implementation`, `@protocol`
- Objective-C boilerplate for KVO, including the relatively obscure `keyPathsForValuesAffecting<Key>`, used for [registering dependent keys](https://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Conceptual/KeyValueObserving/Articles/KVODependentKeys.html)
- Objective-C boilerplate for Core Data fetches, property accessors, and property validation
- Objective-C idioms for enumerating [`NSIndexSet`](http://nshipster.com/nsindexset/)
- Objective-C incantation for `init`, `initWithCoder:` and `initWithFrame:` method implementations
- Objective-C `@try` / `@catch` / `@finally` and `@autorelease` blocks
- GCD idioms for `dispatch_once` and `dispatch_after`

## Creating Xcode Snippets

Of course, what really makes snippets such a powerful feature is the ability to create your own.

The process of creating a snippet is actually pretty unintuitive and difficult to explain. It uses an obscure OS X system feature that allows users to create a "Text Clipping" by dragging and dropping selected text. Much easier to just show it in action:

![Text Completion Shortcut]({{ site.asseturl }}/xcode-snippet-create.gif)

After being added to the code snippet library, a user-defined snippet can be edited by double-clicking its listing:

![Text Completion Shortcut]({{ site.asseturl }}/xcode-snippet-editor.png)

Each snippet has the following fields:

- **Title** - The name of the snippet (appears in text completion and in snippet library listing)
- **Summary** - A brief description of what it does (appears only in snippet library listing)
- **Platform** - Limits the snippet visibility for text completion to the specified platform. OS X, iOS, or both ("All")
- **Language** - Limits the snippet visibility for text completion to the specified language. Most commonly C, Objective-C, C++, or Objective-C++.
- **Completion Shortcut** - The text completion shortcut. For commonly-used snippets, this should be relatively short. Xcode does not warn about conflicting / overlapping shortcuts, so make sure yours doesn't overlap with an existing one.
- **Completion Scopes** - Limits the snippet visibility for text completion to the specified scopes. For example, an `if` / `else` statement should only be auto-completed from within a method or function implementation. Any combination of the following:
    - All
    - Class Implementation
    - Class Interface Methods
    - Class Interface Variables
    - Code Expression
    - Function or Method
    - Preprocessor Directive
    - String or Comment
    - Top Level

> Each Xcode snippet has a file representation in `~/Library/Developer/Xcode/UserData/CodeSnippets/`

### Placeholder Tokens

Something you may have noticed in using other Xcode snippets are placeholder tokens:

![Placeholder Token]({{ site.asseturl }}/xcode-snippet-token.png)

In Xcode, placeholder tokens are delimited by `<#` and `#>`, with the placeholder text in the middle. Go ahead—try typing that into Xcode, and watch as the text between the octothorp tags magically transforms right in front of your eyes.

Include placeholder tags to add a dash of dynamism in your own snippets!

### Third-Party Xcode Snippets

A list of generally useful code snippets can be found [in this GitHub project](https://github.com/mattt/Xcode-Snippets) (pull requests welcome!). If nothing else, this also serves as an example of what's possible.

---

Programming isn't about being an expert typist, so don't make it any more difficult for yourself than it needs to be. If you find yourself groaning while typing some inane, rote-memorized code idiom, take a minute to create a snippet for it instead!
