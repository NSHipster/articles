---
title: Bundles and Packages
author: Mattt
category: Cocoa
excerpt: >-
  "In this season of giving,
  let's stop to consider one of the greatest gifts given to us
  by modern computer systems:
  the gift of abstraction."
status:
  swift: "4.2"
---

In this season of giving,
let's stop to consider one of the greatest gifts given to us
by modern computer systems:
_the gift of abstraction_.

Consider that billions of people around the world
use computers and mobile devices on a daily basis.
They do this without having to know anything about
the millions of CPU transistors and SSD sectors and LCD pixels
that come together to make that happen.
All of this is thanks to abstractions
like files and directories and apps and documents.

This week on NSHipster,
we'll be talking about two important abstractions on Apple platforms:
<dfn>bundles</dfn> and <dfn>packages</dfn>.
🎁

{% comment %}
_"Now I have an article hook. Ho ho ho."_
{% endcomment %}

---

Despite being distinct concepts,
the terms "bundle" and "package" are frequently used interchangeably.
Part of this is certainly due to their similar names,
but perhaps the main source of confusion is that
many bundles just so happen to be packages (and vice versa).

So before we go any further,
let's define our terminology:

- A <dfn>bundle</dfn> is a directory with a known structure
  that contains executable code and the resources that code uses.

- A <dfn>package</dfn> is a directory
  that looks like a file when viewed in Finder.

The following diagram illustrates the relationship between bundles and packages,
as well as things like apps, frameworks, plugins, and documents
that fall into either or both categories:

{% asset packages-and-bundles-diagram.svg %}

{% info %}
If you're still fuzzy on these distinctions,
here's an analogy that might help you keep things straight:

Think of a _package_ as a _box_ (📦)
whose contents are sealed away and are considered to exist as a single entity.

Contrast that with _bundles_,
which are more like _backpacks_ (🎒) ---
each with special pockets and compartments for carrying whatever you need,
and coming in different configurations depending on whether
it's for taking to school, work, or the gym.

If something's _both a bundle and a package_,
it's like a piece of _luggage_ (🧳):
sealed like a box
and organized into compartments like a backpack.
{% endinfo %}

## Bundles

Bundles are primarily for **improving developer experience**
by providing structure for organizing code and resources.
This structure not only allows for predictable loading of code and resources,
but allows for system-wide features like localization.

Bundles fall into one of the following three categories,
each with their own particular structure and requirements:

- **App Bundles**, which contain an executable that can be launched,
  an `Info.plist` file describing the executable,
  app icons, launch images,
  and other assets and resources used by the executable, including
  interface files, strings files, and data files.
- **Framework Bundles**, which contain
  code and resources used by the dynamic shared library.
- **Loadable Bundles** like _plug-ins_, which contain
  executable code and resources that extend the functionality of an app.

### Accessing Bundle Contents

In apps, playgrounds, and most other contexts
the bundle you're interested in is accessible through
the type property `Bundle.main`.
And most of the time,
you'll use `url(forResource:withExtension:)`
(or one of its variants)
to get the location of a particular resource.

For example,
if your app bundle includes a file named `Photo.jpg`,
you can get a URL to access it like so:

```swift
Bundle.main.url(forResource: "Photo", withExtension: "jpg")
```

{% info %}
Or if you're using the Asset Catalog,
you can simply drag & drop from the Media Library
(<kbd>⇧</kbd><kbd>⌘</kbd><kbd>M</kbd>)
to your editor to create an image literal.
{% endinfo %}

For everything else,
`Bundle` provides a number of instance methods and properties
that give the location of standard bundle items,
with variants returning either a `URL` or a `String` paths:

| URL                            | Path                            | Description                                      |
| ------------------------------ | ------------------------------- | ------------------------------------------------ |
| `executableURL`                | `executablePath`                | The executable                                   |
| `url(forAuxiliaryExecutable:)` | `path(forAuxiliaryExecutable:)` | The auxiliary executables                        |
| `resourceURL`                  | `resourcePath`                  | The subdirectory containing resources            |
| `sharedFrameworksURL`          | `sharedFrameworksPath`          | The subdirectory containing shared frameworks    |
| `privateFrameworksURL`         | `privateFrameworksPath`         | The subdirectory containing private frameworks   |
| `builtInPlugInsURL`            | `builtInPlugInsPath`            | The subdirectory containing plug-ins             |
| `sharedSupportURL`             | `sharedSupportPath`             | The subdirectory containing shared support files |
| `appStoreReceiptURL`           |                                 | The App Store receipt                            |

### Getting App Information

All app bundles are required to have an `Info.plist` file
that contains information about the app.

Some metadata is accessible directly through instance properties on bundles,
including `bundleURL` and `bundleIdentifier`.

```swift
import Foundation

let bundle = Bundle.main

bundle.bundleURL        // "/path/to/Example.app"
bundle.bundleIdentifier // "com.nshipster.example"
```

You can get any other information
by subscript access to the `infoDictionary` property.
(Or if that information is presented to the user,
use the `localizedInfoDictionary` property instead).

```swift
bundle.infoDictionary["CFBundleName"] // "Example"
bundle.localizedInfoDictionary["CFBundleName"] // "Esempio" (`it_IT` locale)
```

### Getting Localized Strings

One of the most important features that bundles facilitate is localization.
By enforcing a convention for where localized assets are located,
the system can abstract the logic
for determining which version of a file to load
away from the developer.

For example,
bundles are responsible for loading the localized strings used by your app.
You can access them using the `localizedString(forKey:value:table:)` method.

```swift
import Foundation

let bundle = Bundle.main
bundle.localizedString(forKey: "Hello, %@",
                       value: "Hello, ${username}",
                       table: nil)
```

However, it's almost always a better idea to use
`NSLocalizedString` so that utilities like `genstrings`
can automatically extract keys and comments to `.strings` files for translation.

```swift
NSLocalizedString("Hello, %@", comment: "Hello, ${username}")
```

```terminal
$ find . \( -name "*.swift" !           \ # find all Swift files
            ! -path "./Carthage/*"      \ # ignoring dependencies
            ! -path "./Pods/*"          \ # from Carthage and CocoaPods
         \)    |                        \
  tr '\n' '\0' |                        \ # change delimiter to NUL
  xargs -0 genstrings -o .              \ # to handle paths with spaces
```

## Packages

Packages are primarily for **improving user experience**
by encapsulating and consolidating related resources into a single unit.

A directory is considered to be a package by the Finder
if any of the following criteria are met:

- The directory has a special extension like `.app`, `.playground`, or `.plugin`
- The directory has an extension that an app has registered as a document type
- The directory has an extended attribute designating it as a package <sup>\*</sup>

### Accessing the Contents of a Package

In Finder,
you can control-click to show a contextual menu
with actions to perform on a selected item.
If an item is a package,
"Show Package Contents" will appear at the top,
under "Open" and "Open With ▶︎".

{% asset show-package-contents.png %}

Selecting this menu item will open a new Finder window
from the package directory.

You can, of course,
access the contents of a package programmatically, too.
The best option depends on the kind of package:

- If a package has bundle structure,
  it's usually easiest to use
  [`Bundle`](https://developer.apple.com/documentation/foundation/bundle)
  as described in the previous section.
- If a package is a document, you can use
  [`NSDocument`](https://developer.apple.com/documentation/appkit/nsdocument) on macOS
  and [`UIDocument`](https://developer.apple.com/documentation/uikit/uidocument) on iOS.
- Otherwise, you can use
  [`FileWrapper`](https://developer.apple.com/documentation/foundation/filewrapper)
  to navigate directories, files, and symbolic links,
  and [`FileHandler`](https://developer.apple.com/documentation/foundation/filehandle)
  to read and write to file descriptors.

### Determining if a Directory is a Package

Although it's up to the Finder how it wants to represent files and directories,
most of that is delegated to the operating system
and the services responsible for managing
Uniform Type Identifiers (<abbr title="Uniform Type Identifiers">UTI</abbr>).

If you want to determine whether a file extension
is one of the built-in system package types
or used by an installed app as a registered document type,
you can use the Core Services functions
`UTTypeCreatePreferredIdentifierForTag(_:_:_:)` and
`UTTypeConformsTo(_:_:)`:

```swift
import Foundation
import CoreServices

func directoryIsPackage(_ url: URL) -> Bool {
    let filenameExtension: CFString = url.pathExtension as NSString
    guard let uti = UTTypeCreatePreferredIdentifierForTag(
                        kUTTagClassFilenameExtension,
                        filenameExtension, nil
                    )?.takeRetainedValue()
    else {
        return false
    }

    return UTTypeConformsTo(uti, kUTTypePackage)
}

let xcode = URL(fileURLWithPath: "/Applications/Xcode.app")
directoryIsPackage(xcode) // true
```

{% info %}

We couldn't find any documentation describing
how to set the so-called "package bit" for a file,
but based on our reading of
[CarbonCore/Finder.h](https://opensource.apple.com/source/CarbonHeaders/CarbonHeaders-8A428/Finder.h),
we believe this can be done by setting the
`kHasBundle` (`0x2000`) flag
in the `com.apple.FinderInfo` extended attribute
(but we haven't had a chance to try it out yet):

```terminal
$ xattr -wx com.apple.FinderInfo <#?#> /path/to/package
```

{% endinfo %}

---

As we've seen,
it's not just end-users that benefit from abstractions ---
whether it's the safety and expressiveness of
a high-level programming language like Swift
or the convenience of APIs like Foundation,
we as developers leverage abstraction to make great software.

For all that we may (rightfully) complain
about abstractions that are
[leaky](https://en.wikipedia.org/wiki/Leaky_abstraction) or
[inverted](https://en.wikipedia.org/wiki/Abstraction_inversion),
it's important to take a step back
and realize how many useful abstractions we deal with every day,
and how much they allow us to do.
