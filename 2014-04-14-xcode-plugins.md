---
title: Xcode Plugins
author: Mattt Thompson
category: Xcode
tags: popular
excerpt: "This week on NSHipster: a roundup of some of the most useful and exciting plugins for Xcode—ready for you to try out yourself today!"
status:
    swift: n/a
---

Apple is nothing if not consistent. From [Pentalobular screws](http://en.wikipedia.org/wiki/Pentalobe_screw) to [Sandboxing](https://developer.apple.com/app-sandboxing/), customers are simply expected to relinquish a fair amount of control when they choose to buy a Mac or iPhone. Whether these design decisions are made to ensure a good user experience, or this control is exercised as an end in itself is debatable, but the reality is that in both hardware and software, Apple prefers an ivory tower to a bazaar.

No better example of this can be found with Xcode: the very software that software developers use to build software for the walled ecosystems of iOS & OS X software, _is itself a closed ecosystem_.

Indeed, significant progress has been made in recent years to break open the developer workflow, from alternative IDEs like [AppCode](http://www.jetbrains.com/objc/?utm_source=nshipster) to build tools like [CocoaPods](http://cocoapods.org), [xctool](http://nshipster.com/xctool/) and [nomad](http://nomad-cli.com). However, the notion that Xcode itself could be customized and extended by mere mortals is extremely recent, and just now starting to pick up steam.

Xcode has had a plugin architecture going back to when Interface Builder was its own separate app. However, this system was relatively obscure, undocumented, and not widely used by third parties. Despite this, developers like [Delisa Mason](https://twitter.com/kattrali) and [Marin Usalj](https://twitter.com/_supermarin) have done incredible work creating a stable and vibrant ecosystem of third-party Xcode extensions.

**Simply install [Alcatraz](http://alcatraz.io), and pull down all of the plugins (and color schemes and templates) that you desire.**

This week on NSHipster: a roundup of some of the most useful and exciting plugins for Xcode—ready for you to try out yourself today!

> And since these question come up every time there's an article with pictures:
> 1. The color scheme is [Tomorrow Night](https://github.com/ChrisKempson/Tomorrow-Theme)
> 2. The app used to make animated GIFs is [LICEcap](http://www.cockos.com/licecap/)

* * *

## Making Xcode More Like `X`

Just as New York became a melting pot of cultures from immigrants arriving at
[Ellis Island](http://en.wikipedia.org/wiki/Ellis_Island), Xcode has welcomed the tired, poor, huddled masses of developers from every platform and language imaginable. Like those first wave Americans, who settled into their respective ethnic neighborhoods to re-establish their traditions in a new land, so too have new iOS developers brought over their preferred workflows and keybindings.

Perhaps you would appreciate a taste of home in the land of Cupertino.

### Vim

Finding it _too easy_ to quit Xcode? Try [XVim](https://github.com/JugglerShu/XVim), an experimental plugin that adds all of your favorite Vim keybindings.

### SublimeText

![SCXcodeMiniMap](http://nshipster.s3.amazonaws.com/scxcodeminimap.png)

Do you miss having a code minimap along the right gutter of your editor to put things into perspective? Install  [SCXcodeMiniMap](https://github.com/stefanceriu/SCXcodeMiniMap) and never again miss the tree nodes for the forest.

### Atom

![Show in GitHub](http://nshipster.s3.amazonaws.com/showingithub.png)

Looking to be more in tune with GitHub? Add the [Show in GitHub / BitBucket](https://github.com/larsxschneider/ShowInGitHub) plugin to open to the selected lines of a file online.

## Fixing Xcode

Rather than waiting with crossed fingers and clenched teeth each June, as Apple engineers unveil the next version of Xcode, developers now have the ability to tailor the de facto editor to their particular needs (and most importantly, fix what's broken).

### Add Line Breaks to Issue Navigator

![BBUFullIssueNavigator](http://nshipster.s3.amazonaws.com/bbufullissuenavigator.png)

An annoyance going back to Xcode 4 has been the truncation of items in the Issues Navigator. Never again be frustrated by surprise ellipses when compiler warnings were just starting to get interesting, with  [BBUFullIssueNavigator](https://github.com/neonichu/BBUFullIssueNavigator).

### Dismiss Debugging Console When Typing

![BBUDebuggerTuckAway](http://nshipster.s3.amazonaws.com/bbudebuggertuckaway.gif)

Another annoyance going back to Xcode 4 is how the debugging console seems to always get in the way. No more, with [BBUDebuggerTuckAway](https://github.com/neonichu/BBUDebuggerTuckAway). As soon as you start typing in the editor, the debugging window will get out of your way.

### Add ANSI Color Support to Debugging Console

![XcodeColors](http://nshipster.s3.amazonaws.com/xcodecolors.png)

`ncurses` enthusiasts will no doubt be excited by the [XcodeColors](https://github.com/robbiehanson/XcodeColors) plugin, which adds support for ANSI colors to appear in the debugging console.

### Hide `@property` Methods in Source Navigator

Finding that `@property` synthesizers are creating a low signal-to-noise ratio in the Source Navigator? Let [Xprop](https://github.com/shpakovski/Xprop) excise the cruft, and let the functions and methods shine through.

### Blow Away DerivedData Folder

[Xcode texting you again?](http://www.textfromxcode.com) `rm -rf`-ing the heck out of "Library/Developer/Xcode/DerivedData" does the trick every time, 90% of the time. Add a convenient button to your Xcode window to do this for you, with the [DerivedData Exterminator](https://github.com/kattrali/deriveddata-exterminator).

## Turbocharging Xcode

Not being the most verbose language in existence, Objective-C can use all the help it can get when it comes to autocompletion. Xcode does a lot of heavy lifting when it comes to class and method completion, but these plugins extend it even further:

### Autocomplete `switch` Statements

![SCXcodeSwitchExpander](http://nshipster.s3.amazonaws.com/scxcodeswitchexpander.gif)

Fact: `switch` statements and [`NS_ENUM`](http://nshipster.com/ns_enum-ns_options/) go together like <a href="http://www.thaitable.com/thai/recipe/mango-on-sticky-rice" rel="nofollow">mango and sweet sticky rice</a>. The only way it could be improved would be with [SCXcodeSwitchExpander](https://github.com/stefanceriu/SCXcodeSwitchExpander) with automagically fills out a `case` statement for each value in the enumeration.

### Autocomplete Documentation

![VVDocumenter](http://nshipster.s3.amazonaws.com/vvdocumenter.gif)

[Documentation](http://nshipster.com/documentation/) adds a great deal of value to a code base, but it's a tough habit to cultivate. The [VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode) plugin does a great deal to reduce the amount of work necessary to add [appledoc](http://gentlebytes.com/appledoc/)-compatible header documentation. Install it and wrap your code in a loving lexical embrace.

## Formatting Xcode

["Code organization is a matter of hygiene"](http://nshipster.com/pragma/), so you owe it to yourself and your team to keep whitespace consistent in your code base. Make it easier on yourself by automating the process with these plugins.

### Code Formatting with ClangFormat

[ClangFormat-Xcode](https://github.com/travisjeffery/ClangFormat-Xcode) is a convenient wrapper around the [ClangFormat](http://clang.llvm.org/docs/ClangFormat.html) tool, which automatically formats whitespace according to a specified set of style guidelines. Eliminate begrudging formatting commits forever with this plugin.

### Statement Alignment

![XAlign](http://nshipster.s3.amazonaws.com/xalign.gif)

Fancy yourself a code designer, automated formatters be damned? [XAlign](https://github.com/qfish/XAlign) automatically aligns assignments _just so_, to appease your most egregious OCD tendencies.

## Extending Xcode

In a similar vein to what [Bret Victor writes about Learnable Programming](http://worrydream.com/LearnableProgramming/), these plugins push the boundaries of what we should expect from our editors, adding context and understanding to code without obscuring the meaning.

### Inspect `NSColor` / `UIColor` Instances

![ColorSense](http://nshipster.s3.amazonaws.com/colorsense.png)

Telling what a color is from its RGB values alone is a hard-won skill, so faced with an `NSColor` or `UIColor` value, we have little recourse to know what it'll look like until the code is built and run. Enter [ColorSense for Xcode](https://github.com/omz/ColorSense-for-Xcode)

Quoth the README:

> When you put the caret on one of your colors, it automatically shows the actual color as an overlay, and you can even adjust it on-the-fly with the standard OS X color picker.

### Autocomplete Images from Project Bundle

![KSImageNamed](http://nshipster.s3.amazonaws.com/ksimagenamed.gif)

Similar to the ColorSense plugin, [KSImageNamed](https://github.com/ksuther/KSImageNamed-Xcode) will preview and autocomplete images in `[UIImage imageNamed:]` declarations.

### Semantics Highlighting

![Polychromatic](http://nshipster.s3.amazonaws.com/polychromatic.png)

Any editor worth its salt is expected to have some form of syntax highlighting. But [this recent post by Evan Brooks](https://medium.com/p/3a6db2743a1e) presents the idea of _semantic_ highlighting in editors. The idea is that each variable within a scope would be assigned a particular color, which would be consistent across references. This way, one could easily tell the difference between two instance variables in the same method.

[Polychromatic](https://github.com/kolinkrewinkel/Polychromatic) is a fascinating initial implementation of this for Xcode, and worth a look. The one downside is that this plugin requires the use of special desaturated color schemes—something that may be addressed in a future release, should this idea of semantic highlighting start to pick up mind share.

### Localization

![Lin](http://nshipster.s3.amazonaws.com/lin-1.png)

![Lin](http://nshipster.s3.amazonaws.com/lin-2.png)

It's no secret that NSHipster has [a soft spot for localization](http://nshipster.com/nslocalizedstring/). For this reason, this publication is emphatic in its recommendation of [Lin](https://github.com/questbeat/Lin-Xcode5), a clever Xcode plugin that brings the localization editor to your code.


* * *

Xcode's plugin architecture is based on a number of private frameworks specific to Xcode, including DVTKit & IDEKit. A [complete list](https://github.com/luisobo/Xcode5-RuntimeHeaders) can be derived by running [`class-dump`](http://stevenygard.com/projects/class-dump/) on the Xcode app bundle.

> Using private frameworks would be, of course, verboten on the AppStore, but since plugins aren't distributed through these channels, developers are welcome to use whatever they want, however they want to.

To get started on your own plugin, download the [Xcode5 Plugin Template](https://github.com/kattrali/Xcode5-Plugin-Template), using the other available plugins and class-dump'd headers as a guide for what can be done, and how to do it.
