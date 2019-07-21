---
title: XcodeKit and Xcode Source Editor Extensions
author: Zoë Smith
category: Xcode
excerpt: >-
  When we last wrote about extending Xcode, 
  we were living in a golden age, and didn't even know it.
  Plugins allowed us to tweak pretty much everything about Xcode;
  Source Editor Extensions? Not so much.
status:
  swift: 5.0
---

When we last [wrote about extending Xcode](/xcode-plugins/) in 2014,
we were living in a golden age, and didn't even know it.

Back then,
Xcode was a supposedly impenetrable castle that we'd leaned a couple of ladders against.
Like a surprisingly considerate horde,
we scaled the walls and got to work on some much-needed upkeep.
Those were heady days of
in-process code injection, an informally sanctioned and thriving ecosystem of third-party plugins ---
all backed up by an in-app package manager.
For a while, Apple tolerated it all.
But with the introduction of [System Integrity Protection](https://support.apple.com/en-us/HT204899) in 2016,
the ladders were abruptly kicked away.
(Pour one out for [Alcatraz](https://github.com/alcatraz/Alcatraz) why don't we,
with a chaser for [XcodeColors](https://github.com/robbiehanson/XcodeColors).
Miss you buddy.)

Plugins allowed us to tweak pretty much everything about Xcode:
window layout, syntactic and semantic highlighting, changing UI elements,
boilerplate generation, project analysis, bindings for something called Vim (?).
Looking back at NSHipster's favorites, some are now thankfully included as a standard feature:
inserting documentation comments,
`switch` statement autocompletion
or --- astonishingly --- line breaks in the issue navigator.
Most of the inventive functionality that plugins added, though, has just plain gone.

{% info %}
While you _can_ re-sign Xcode to load compatible plugins today,
you can't use this copy to distribute on the App Store.
And besides, the plugin party is now well over.
{% endinfo %}

Xcode 8 proposed a solution for the missing plugins in the form of [Source Editor Extensions](https://developer.apple.com/videos/play/wwdc2016/414/).
Like other macOS extensions, they can be sold via the App Store or distributed independently.
But some bad, if old, news:
unlike plugins, these new extensions are seriously limited in scope.
They allow
**pure text manipulation, instigated by the user from a menu command, on one source file at a time** —
none of the fun stuff, in other words.

Source Editor Extensions have remained unchanged since introduction.
We'll discuss signs that _might_ point to interesting future developments.
But if IDEs with an open attitude are more your thing,
there's not much to see here yet.

Let's start, though, by looking at the official situation today:

## Source Editor Extensions

By now, Apple platform developers will be familiar with extension architecture:
separate binaries, sandboxed and running in their own process,
but not distributable without a containing app.

Compared to using a tool like Homebrew, installation is undoubtedly a pain:

{% asset "xcode-source-editor-extension-installation-flow.png" alt="Flow diagram for extension installation process" %}

After finding, downloading and launching the containing app,
the extension shows up in the Extensions pane of System Preferences.
You can then activate it,
restart Xcode
and it should manifest itself as a menu item.  
(App Store reviewers _love_ this process.)

That's the finished result.
To understand how you get to that point,
let's create a simple extension of our own.
This [sample project](https://github.com/zoejessica/marked)
transforms `TODO`, `FIXME` and `MARK` code marks to be uppercased with a trailing colon,
so Xcode can recognize them and add them to the quick navigation bar.
(It's just one of the rules more fully implemented by the [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) extension.)

## Creating a Source Editor Extension

Create a new Cocoa app as the containing app,
and add a new target using the Xcode Source Editor Extension template.

{% asset "xcode-source-editor-add-extension-target" alt="Screenshot of adding Source Editor Extension target to Xcode project" %}

{% info %}
In [Apple's terminology](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionOverview.html#//apple_ref/doc/uid/TP40014214-CH2-SW2),
the <dfn>host</dfn> app is
the application that _calls_ your extension to do some useful work:
in this case,
the host is Xcode.
The <dfn>containing</dfn> app is
the new application that _you_ create to wrap extensions
which can't stand by themselves.
{% endinfo %}

The target contains ready-made `XCSourceEditorExtension` and `XCSourceEditorCommand` subclasses,
with a configured property list.

Both of those superclasses are part of the [XcodeKit framework](https://developer.apple.com/documentation/xcodekit)
(hence the `XC` prefix),
which provides extensions the ability to modify the text and selections of a source file.

### Display Names

User-facing strings for an extension are sprinkled around the extension's `Info.plist` or defined at runtime:

| Display text                                   | Property                                     | Definition |
| ---------------------------------------------- | -------------------------------------------- | ---------- |
| Extension name, as shown in System Preferences | `Bundle Display Name`                        | Info.plist |
| Top level menu item for extension              | `Bundle Name`                                | Info.plist |
| Individual menu command                        | `XCSourceEditorCommandName`                  | Info.plist |
|                                                | `XCSourceEditorCommandDefinitionKey.nameKey` | Runtime    |

### Menu Items

The only way a user can interact with an extension is by selecting one of its menu items.
These show up at the bottom of the Editor menu when viewing a source code file.
Xcode's one affordance to users is that keybindings can be assigned to extension commands,
just as for other menu items.

Each command gets a stringly-typed identifier, display text, and a class to handle it,
which are each defined in the extension target's `Info.plist`.
Alternatively,
we can override these at runtime
by providing a `commandDefinitions` property on the `XCSourceEditorExtension` subclass.
The commands can all be funneled to a single `XCSourceEditorCommand` subclass
or split up to be handled by multiple classes --- whichever you prefer.

In our extension, we just define a single "Format Marks" menu item:

```swift
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        let namespace = Bundle(for: type(of: self)).bundleIdentifier!
        let marker = MarkerCommand.className()
        return [[.identifierKey: namespace + marker,
                 .classNameKey: marker,
                 .nameKey: NSLocalizedString("Format Marks",
                 comment: "format marks menu item")]]
    }
```

{% warning %}
There is no way to dynamically _disable_ individual menu commands,
for example, if an extension wanted to offer different functionality according to the type of source file.
The extension is kept running for Xcode's lifetime,
and menu items are determined at launch.
Nor is there a way to suggest default key bindings.
{% endwarning %}

When the user chooses one of the menu commands defined by the extension,
the handling class is called with
[`perform(with:completionHandler:)`](https://developer.apple.com/documentation/xcodekit/xcsourceeditorcommand/2097278-perform).
The extension finally gets access to something useful,
namely the contents of the current source code file.

### Inputs and Outputs

The passed `XCSourceEditorCommandInvocation` argument holds a reference to the `XCSourceTextBuffer`,
which gives us access to:

- `completeBuffer`, containing the entire text of the file as a single `String`
- another view on the same text, separated into `lines` of code
- an array of current `selections` in terms of lines and columns, supporting multiple cursors
- various indentation settings
- the type of source file

{% error %}
Despite all of that sandboxing, Apple has carelessly left open a serious attack vector,
whereby an unscrupulous extension developer could easily inflict their chosen tab/space fetish on unsuspecting users.
🙀, indeed.
{% enderror %}

With text and selections in hand, we get to do the meaty work of the extension.
Then XcodeKit provides two ways to write back to the same source file,
by mutating either the `completeBuffer` or the more performant `lines` property.
Mutating one changes the other,
and Xcode applies those changes once the completion handler is called.
Modifying the `selections` property updates the user's selection in the same way.

In our example,
we first loop over the `lines` of code.
For each line,
we use a [regular expression](/swift-regular-expressions/)
to determine if it has a code mark that needs reformatting.
If so, we note the index number and the replacement line.
Finally we mutate the `lines` property to update the source file,
and call the completion handler to signal that we're done:

```swift
func perform(with invocation: XCSourceEditorCommandInvocation,
             completionHandler: @escaping (Error?) -> Void ) -> Void
{
    replaceLines(in: invocation.buffer.lines, by: formattingMarks)
    completionHandler(nil)
}

func replaceLines(in lines: NSMutableArray,
                  by replacing: @escaping (String) -> String?)
{
    guard let strings = lines as? [String] else {
        return
    }

    let newStrings: [(Int, String)] = strings.enumerated().compactMap {
        let (index, line) = $0
        guard let replacementLine = replacing(line) else {
            return nil
        }
        return (index, replacementLine)
    }

    newStrings.forEach {
        let (index, newString) = $0
        lines[index] = newString
    }
}

func formattingMarks(in string: String) -> String? {
  /* Regex magic transforms:
     "// fixme here be 🐉"
     to
     "// FIXME: here be 🐉"
  */
}
```

{% info %}
It's worth remembering that extensions can deal with all sorts of text, not just Swift or Objective-C.
Even files that ordinarily open with specialized viewers in Xcode can instead be viewed as Source Code,
which makes extension commands available.
So if we need a transformation of Metal, Markdown, GPX, string dictionaries and the like,
this is possible via an extension.
The buffer's `contentUTI` property reports back specific file types,
which can be interrogated for conformance to more abstract types with [`UTTypeConformsTo`](https://developer.apple.com/documentation/coreservices/1444079-uttypeconformsto).
{% endinfo %}

## Development Tips

### Debugging

Debugging the extension target launches it in a separate Xcode instance, with a dark status bar and icon:

{% asset "xcode-source-editor-dark-xcode-dock.png" alt="Screenshot showing macOS dock with blue and grey Xcode icons" %}

Sometimes attaching to the debugger fails silently,
and it's a [good idea](https://ericasadun.com/2016/07/21/explorations-into-the-xcode-source-editor-extensions-underbelly-part-1/)
to set a log or audible breakpoint to track this:

```swift
func extensionDidFinishLaunching() {
    os_log("Extension ready", type: .debug)
}
```

#### Extension Scheme Setup

[Two suggestions from Daniel Jalkut](https://academy.realm.io/posts/jalkut-extending-xcode-8/#hot-tips-1532) to make life easier.  
Firstly add Xcode as the default executable in the Extension scheme's Run/Info pane:

{% asset "xcode-source-editor-extension-target-default-executable.png" alt="Screenshot showing Xcode set as default executable in extension scheme" %}

Secondly, add a path to a file or project containing some good code to test against,
in the Run/Arguments panel of the extension's scheme, under Arguments Passed On Launch:

{% asset "xcode-source-editor-extension-target-launch-arguments.png" alt="Screenshot showing path to sample code under argument passed on launch in extension scheme" %}

#### Testing XcodeKit

Make sure the test target knows how to find the XcodeKit framework,
if you need to write tests against it.
Add `${DEVELOPER_FRAMEWORKS_DIR}` as both a Runpath and a Framework Search Path in Build Settings:

{% asset "xcode-source-editor-test-target-build-settings.png" alt="Screenshot showing Developer Frameworks Directory added to Runpath and Framework Search Paths in test target's build settings" %}

### Using `pluginkit`

During development, Xcode can become confused as to which extensions it sees.
It can be useful to get an overview of installed extensions using the `pluginkit` tool.
This allows us to query the private PluginKit framework that manages all system extensions.

Here we're matching by the `NSExtensionPointIdentifier` for Source Editor extensions:

```terminal
$ pluginkit -m -p com.apple.dt.Xcode.extension.source-editor

+    com.apple.dt.XCDocumenter.XCDocumenterExtension(1.0)
+    com.apple.dt.XcodeBuiltInExtensions(10.2)
     com.Swiftify.Xcode.Extension(4.6.1)
+    com.charcoaldesign.SwiftFormat-for-Xcode.SourceEditorExtension(0.40.3)
!    com.hotbeverage.accesscontrolkitty.extension(1.0.1)
```

The leading flags in the output can give you some clues as to what might be happening:

- `+` [seems to indicate](https://openradar.appspot.com/radar?id=4976827063861248)
  a specifically enabled extension
- `-` indicates a disabled extension
- `!` indicates some form of conflict

For extra verbose output that lists any duplicates:

```terminal
$ pluginkit -m -p com.apple.dt.Xcode.extension.source-editor -A -D -vvv
```

If you spot an extension that might be causing an issue, you can try manually removing it:

```terminal
$ pluginkit -r path/to/extension
```

Finally, when multiple copies of Xcode are on the same machine, extensions can stop working completely.
In this case, Apple Developer Relations suggests re-registering your main copy of Xcode with Launch Services
(it's easiest to temporarily add `lsregister`'s location to `PATH` first):

```terminal
$ PATH=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support:"$PATH"
$ lsregister -f /Applications/Xcode.app
```

{% info %}
What are those two `com.apple.dt...` plugins in the output above?
Well, it seems like the Developer Tools team are using Source Editor extensions inside Xcode itself.
Looking at the [strings in the binaries](https://github.com/keith/Xcode.app-strings/tree/master/Xcode.app/Contents/PlugIns)
we get confirmation of information found elsewhere:

`XcodeBuiltInExtensions` handles comment toggling, and
`XCDocumenterExtension` inserts documentation comments
(and turns out to be the former Alcatraz plugin
[VVDocumenter](https://github.com/onevcat/VVDocumenter-Xcode),
slurped into Xcode).
Some sort of internal privileging must then happen as they get more appropriate menu locations,
but the basic mechanism looks the same.
{% endinfo %}

## Features and Caveats

### Transforming Source Code

Given how limited XcodeKit's text API is, what sorts of things are people making?
And can it entice tool creators away from the command line?
(Hint: 😬)

- Linting and style extensions ([reformatting based on rules](https://github.com/nicklockwood/SwiftFormat), wrapping comments, alignment, whitespace adjustment, code organization, [profanity removal](https://itunes.apple.com/us/app/dirtywords-for-xcode/id1447526628?mt=12))
- Coding helpers (insert and remove caveman [debugging statements](https://github.com/twostraws/Sharpshooter/) at function calls; [moving import statements](https://github.com/markohlebar/Import) up to the top of the file from any location)
- Translators, from one language to another ([JSON](https://github.com/quicktype/quicktype-xcode) or [Objective-C to Swift](https://swiftify.com))
- Boilerplate generators ([init statements](https://github.com/Atimca/SwiftInitGenerator), [extraction of a protocol from a class](https://itunes.apple.com/us/app/protocol-for-xcode/id1212245111?mt=12), [coding keys](https://github.com/wleii/TrickerX))
- Extracting code to put in a different context ([a playground](https://github.com/insidegui/PlayAlways); [a gist](https://github.com/Bunn/Xgist))

All the tools mentioned above are clearly transforming source code in various ways.
They'll need some information about the structure of that code to do useful work.
Could they be using SourceKit directly?
Well, where the extension is on the App Store, we know that they're not.
**The extension must be sandboxed just to be loaded by Xcode**,
whereas calls to SourceKit needs to be un-sandboxed,
which of course won't fly in the App Store.
We _could_ distribute independently and use an un-sandboxed [XPC service](/inter-process-communication/) embedded in the extension.
Or more likely, we can write our own single-purpose code to get the job done.
The power of Xcode's compiler is tantalizingly out of reach here.
An opportunity, though, if writing a mini-parser sounds like fun
(🙋🏼,
and check out [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)'s beautiful lexer implementation for Swift).

### Context-free Source Code

Once we have some way to analyze source code,
how sophisticated an extension can we then write?
Let's remember that the current API gives us access to a file of text,
but not any of its _context_ within a project.

As an example,
say we want to implement an extension that quickly modifies the access level of Swift code to make it part of a framework's API.
So an `internal` class's `internal` properties and functions get changed to `public`,
but `private` or `fileprivate` implementation details are left alone.

We can get most of the way there,
lexing and parsing the file to figure out where to make appropriate changes,
taking into account Swift's rules about access inheritance.
But what happens if one of these transformed methods turns out to have a parameter with an `internal` type?
If that type is declared in a different file, there's no way for our extension to know,
and making the method `public` will cause a build error:
“Method cannot be declared public because its parameter uses an internal type”.

In this example, we're missing type declarations in other files.
But complex refactorings can need information about how an entire codebase fits together.
Metadata could also be useful,
for example,
what version of Swift the project uses, or a file path to save per-project configuration.

This is a frustrating trade-off for safety.
While it's feasible to transform the purely _syntactic_ parts of isolated code,
once any _semantics_ come into play we quickly bump up against that missing context.

### Output

You can only output transformed text back _to the same source file_ using the extension API.
If you were hoping to generate extensive boilerplate and insert project files automatically,
this isn't supported and would be fragile to manage via the containing app.
Anonymous source file in/out sure is secure, but it isn't powerful.

### Heavyweight Architecture; Lightweight Results

Most extensions' containing apps are hollow shells
with installation instructions and some global preferences.
Why?
Well, a Cocoa app _can_ do anything,
but the extension doesn't give us a lot to work with:

- As creators, we must deal with
  sandboxed communications to the containing app, the limited API and entitlements.
  Add complete sandboxing when distributing through the App Store.
- As users we contend with
  that convoluted installation experience,
  and managing preferences for each extension separately in the containing apps.

It's all, effectively, for the privilege of a menu item.
And the upshot is apparent from a prominent example in the Mac App Store,
[Swiftify](https://itunes.apple.com/us/story/id1437719440):
they suggest no fewer than [four superior ways](https://support.swiftify.com/hc/en-us/articles/360000109571-How-would-this-work-with-the-h-and-m-files-Do-you-have-to-convert-code-piece-by-piece-) to access their service,
over using their own native extension.

## The Handwavy Bit

To further belabor the Xcode-as-castle metaphor,
Apple has opened the gate just very slightly,
but also positioned a large gentleman behind it,
deterring all but the most innocuous of guests.

Extensions might have temporarily pacified the horde,
but they are no panacea.
After nearly three years without expanding the API,
it's no wonder that the App Store is not our destination of choice to augment Xcode.
And Apple's "best software for most" credo doesn't mean they always get the IDE experience right
_cough image literals autocompletion cough_,
or make us optimistic that Xcode will become truly extensible in the style of [VSCode](https://code.visualstudio.com).

But let's swirl some tea leaves and see where Apple _could_ take us
if they so wished:

- Imagine a world where Xcode is using [SwiftSyntax](/swiftsyntax/) directly to represent the syntax of a file
  (a [stated goal of the project](https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20170206/004066.html)).
  Let's imagine that XcodeKit exposes `Syntax` nodes in some way through the extension API.
  We would be working with _exactly_ the same representation as Xcode —
  no hand-written parsers needed.
  [Tools are already being written](https://github.com/apple/swift-syntax#some-example-users) against this library —
  it would be so neat to get them directly in Xcode.
- Let's imagine we have specific [read](https://openradar.appspot.com/26823522)/[write access](http://www.openradar.me/35194855) to the current project directory and metadata.
  Perhaps this leverages the robust entitlements system, with approval through App Review.
  That sounds good to create extensive boilerplate.
- Let's expand our vision:
  there's a way to access fuller semantic information about our code,
  maybe driven via the [LSP protocol](/language-server-protocol/).
  Given a better way to output changes too,
  we could use that information for complex, custom refactorings.
- Imagine invoking extensions [automatically](http://openradar.appspot.com/27045243),
  for example as part of the build.
- Imagine API calls that add custom UI or [Touch Bar items](http://www.openradar.me/29660390), according to context.
- Imagine a thriving, vibrant section of the [Mac App Store](https://itunes.apple.com/us/story/id1380861178) for developer extensions.

---

_Whew_.
That magic tea is strong stuff.
In _that_ world, extensions look a lot more
fun, powerful, and worth the architectural hassles.
Of course,
this is [rank speculation](https://forums.swift.org/t/new-lsp-language-service-supporting-swift-and-c-family-languages-for-any-editor-and-platform/17024/37?u=zoe),
and yet...
The open-source projects Apple is committed to working on will --- eventually ---
change the internal architecture of Xcode,
and surely stranger things are happening.

For now, though, if any of this potential excites you,
please write or tweet about it,
[submit enhancement requests](/bug-reporting/),
get involved on the
[relevant](https://forums.swift.org/c/development/sourcekit-lsp)
[forums](https://forums.swift.org/search?q=swiftsyntax)
or contribute directly.
We're still hoping the Xcode team renders this article comprehensively obsolete,
sooner rather than later 🤞.
