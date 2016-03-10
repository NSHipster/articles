---
title: Xcode Key Bindings & Gestures
author: Mattt Thompson
category: Xcode
tag: popular
excerpt: "Xcode key bindings and gestures not only shave off seconds of precious work, but make you look more confident, competent, and cromulent in the process."
status:
    swift: n/a
---

The extent to which programming-as-craft is compared to manual disciplines like woodworking is tiresome. It's absolutely the case that one should know and maintain their tools as well as a carpenter or metalsmith, but... I mean, c'mon. One would think that an industry demanding the skills of ninjas and rockstars would mix it up a little: "keep your shurikens polished, sharp, and hidden" or "tune your guitar and condition your hair twice daily".

Here at NSHipster, the advice is simple and only slightly allegorical: "Xcode is your mustache, so keep it trimmed, waxed to a sharp point, and free of bugs."

Anyway, a few weeks ago, we looked at how [Xcode Snippets](http://nshipster.com/xcode-snippets/) can make you more productive by reducing the amount of boilerplate code you have to type out. This week, we're going to pick up on that thread and cover the essential key bindings and gestures.

Xcode key bindings and gestures not only shave off seconds of precious work, but make you look more confident, competent, and cromulent in the process. Learn the following tricks of the trade and join the elite set of Xcode power users.

---

> For your reference, here is a legend of the common modifier key symbols (as well as a symbol for click [shamelessly borrowed from the International Phonetic Alphabet](http://en.wikipedia.org/wiki/Click_consonant)):

<table id="xcode-key-bindings-modifiers">
  <thead>
    <tr>
      <th>Command</th>
      <th>Control</th>
      <th>Option</th>
      <th>Shift</th>
      <th>Click</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>⌘</tt></td>
      <td><tt>⌃</tt></td>
      <td><tt>⌥</tt></td>
      <td><tt>⇧</tt></td>
      <td><tt>ʘ</tt></td>
    </tr>
  </tbody>
</table>

## Open Quickly (`⇧⌘O`)

![Open Quickly]({{ site.asseturl }}/xcode-shortcuts-quick-open.png)

Learn to rely less on the Project Navigator by learning to love Open Quickly. There's a lot to love, too—with support for partial case- and position-insensitive matches, Xcode does a great job of finding what you want with just a minimal amount of input on your part.

---

## Quick Documentation (`⌥ʘ` on Symbol / Three-Finger Tap) <br/> Open Documentation (`⌥ʘʘ` on Symbol)

![Quick Documentation]({{ site.asseturl }}/xcode-shortcuts-quick-documentation.gif)

Quick Documentation is probably the first Xcode shortcut developers should learn. Just alt-click (or three-finger tap) any class, variable, or constant value, and Xcode will give you a quick rundown of what you're looking at. Alt-double-click to bring up the documentation window, opened to the relevant entry.

## Jump to Definition (`⌘ʘ` on Symbol)

Also well-know to an expert Xcoder's workflow is Jump to Definition, which opens the editor window to the relevant `@interface` definition or constant declaration in a `.h` file. This is especially useful for getting a raw look at system frameworks like Foundation, to get an idea of what's _really_ going on behind-the-scenes.

## Jump to Next Counterpart (`^⌘↑` / `^⌘↓` / Three-Finger Vertical Swipe)

![Jump to Next Counterpart]({{ site.asseturl }}/xcode-shortcuts-counterpart.gif)

Last, but certainly not least, there's Jump to Next Counterpart, which is very likely the shortcut used the most on any given day. Quickly switch between a `.h` header and it's corresponding `.m` implementation with a simple three-finger swipe up or down (or `^⌘↑` / `^⌘↓` if you feel so inclined).

---

## Comment Selection / Current Line (`⌘/`)

![Comment Selection]({{ site.asseturl }}/xcode-shortcuts-comment.gif)

Sure, you _could_ be debugging the "right way" by setting breakpoints and being clever with your code paths, but there's quite so refreshingly simple and powerful as phasing code in and out of computational existence with a comment. Add or remove `//` comments to the current line or selection.

## Show Standard Editor (`⌘↵`) <br/> Show Assistant Editor (`⌥⌘↵`) <br/> Show Version Editor (`⌥⇧⌘↵`)

![Editors]({{ site.asseturl }}/xcode-shortcuts-editors.gif)

For how useful the Assistant Editor can be, surprisingly few developers can actually remember the key combo to turn it on and off. But now with `⌘↵` and `⌥⌘↵` fresh in your mind, you'll be helping Xcode help yourself more often.

![Assistant Editor Position]({{ site.asseturl }}/xcode-shortcuts-assistant-editor-position.png)

As an aside, if you're not big on how editors are stacking, a different horizontal or vertical arrangement can be chosen in View > Assistant Editor.

---

![Panels]({{ site.asseturl }}/xcode-shortcuts-panels.gif)

Sandwiching the editors on the left and right flanks, the Navigator and Utilities panels encircle your code in their loving embrace. Learning how to get them to show what's useful and GTFO when needed are critical for inner peace and maximum productivity.

## Show/Hide Navigator Panel (`⌘0`)

## Select Navigator (`⌘1, ..., ⌘8`)

1. Project Navigator
2. Symbol Navigator
3. Find Navigator
4. Issue Navigator
5. Test Navigator
6. Debug Navigator
7. Breakpoint Navigator
8. Log Navigator

## Show/Hide Utilities Panel (`⌥⌘0`)

## Select Utilities Panel (`⌥⌘1, ⌥⌘2, ...`)

### Source File

1. File Inspector
2. Quick Help

### Interface Builder

1. File Inspector
2. Quick Help
3. Identity Inspector
4. Attributes Inspector
5. Size Inspector
6. Connections Inspector

## Show / Hide Debug Area (`⇧⌘Y`) <br/> Activate Console (`⇧⌘C`)

![Show / Hide Debug Area]({{ site.asseturl }}/xcode-shortcuts-debug-area.gif)

Anyone miss the option in Xcode 3 to have a detached debugger window? Yeah, me too.

Knowing how to toggle the debug area and activate the console in a single keystroke may be a shallow consolation, but it does help take the edge off of the pain or loss.

---

## Find (`⌘F`) /<br/>Find & Replace (`⌥⌘F`) /<br/>Find in Project (`⇧⌘F`) /<br/>Find & Replace in Project (`⌥⇧⌘F`)

![Find]({{ site.asseturl }}/xcode-shortcuts-find.gif)

For when Xcode's refactoring capabilities come up short... which is to say: often. On the plus side, Xcode allows reference, definition, and regular expression search in addition to literal text.

## Spelling & Grammar (`⌘:`)

![Spelling & Grammar]({{ site.asseturl }}/xcode-shortcuts-spelling-and-grammar.png)

All-powerful as Clang is, it still can't help your nightmarish grammar and punctuation in your comments. Especially for anyone releasing code into the open-source wilds, do yourself a favor and give it a once-over with a built-in OS X spelling and grammar check.

---

![Xcode Shortcut Preferences]({{ site.asseturl }}/xcode-shortcuts-preferences.png)

But, of course, the fun doesn't stop there! Like any respectable editor, Xcode allows you to customize the key bindings for every menu item and action across the app.

Here are a few non-standard key bindings that you might find useful:

- `^w`: Close Document (replaces Delete to Mark)
- `^⌘/`: Show / Hide Toolbar
- `^⌘F`: _None_ (removes Full Screen (at least until Mavericks))

Got any useful or clever bindings to share? Tweet them to [@NSHipster](https://twitter.com/NSHipster)!
