---
title: NSDataAsset
author: Mattt
category: Cocoa
excerpt: >
  There are many ways to speed up a network request:
  compressing and streaming,
  caching and prefetching,
  reducing and inlining,
  connection pooling and multiplexing,
  deferring and backgrounding.
  And yet there's one optimization strategy
  that both predates and outperforms them all:
  _not making the request in the first place_.
status:
  swift: 4.2
---

On the web,
speed isn't a luxury;
it's a matter of survival.

User studies in recent years
suggest that _any_ perceivable latency in page load time ---
that is, greater than 400 milliseconds
(literally in the blink of an eye) ---
can negatively impact conversion and engagement rates.
For every additional second that a webpage takes to load,
one should expect 10% of users to swipe back or close the tab.

For large internet companies like Google, Amazon, and Netflix,
an extra second here and there
can mean _billions_ of dollars in annual revenue.
So it's no surprise those very same companies
have committed so much engineering effort into making the web fast.

There are many techniques for speeding up a network request:
compressing and streaming,
caching and prefetching,
connection pooling and multiplexing,
deferring and backgrounding.
And yet there's one optimization strategy
that both predates and outperforms them all:
_not making the request in the first place_.

Apps, by virtue of being downloaded ahead of time,
have a unique advantage over conventional web pages in this respect.
This week on NSHipster,
we'll show how to leverage the Asset Catalog in an unconventional way
to improve the first launch experience for your app.

---

Asset Catalogs allow you to organize resources
according to the characteristics of the current device.
For a given image,
you can provide different files depending on the
device (iPhone, iPad, Apple Watch, Apple TV, Mac),
screen resolution (`@2x` / `@3x`), or
color gamut (sRGB / P3).
For other kinds of assets,
you might offer variations depending on the available memory
or version of Metal.
Just request an asset by name,
and the most appropriate one is provided automatically.

Beyond offering a more convenient API,
Asset Catalogs let apps take advantage of
[app thinning](https://help.apple.com/xcode/mac/current/#/devbbdc5ce4f),
resulting in smaller installations that are optimized for each user's device.

Images are far and away the most common types of assets,
but as of iOS 9 and macOS El Capitan,
resources like JSON, XML and other data file can join in the fun by way of
[`NSDataAsset`](https://developer.apple.com/documentation/uikit/nsdataasset).

## How to Store and Retrieve Data with Asset Catalog

As an example,
let's imagine an iOS app for creating digital color palettes.

To distinguish between different shades of gray,
we might load a list of colors and their corresponding names.
Normally, we might download this from a server on first launch,
but that could cause a bad user experience if
[adverse networking conditions](https://nshipster.com/network-link-conditioner/)
block app functionality.
Since this is a relatively static data set,
why not include the data in the app bundle itself
by way of an Asset Catalog?

### Step 1. Add New Data Set to Asset Catalog

When you create a new app project in Xcode,
it automatically generates an Asset Catalog.
Select `Assets.xcassets` from the project navigator
to open the Asset Catalog editor.
Click the <kbd>+</kbd> icon at the bottom left
and select "New Data Set"

{% asset add-new-data-set.png %}

Doing this creates a new subdirectory of `Assets.xcassets`
with the `.dataset` extension.

{% info do %}

By default,
the Finder treats both of these bundles as directories,
which makes it easy to inspect and modify their contents as needed.

{% endinfo %}

### Step 2. Add a Data File

Open the Finder,
navigate to the data file
and drag-and-drop it
into the empty field for your data set asset in Xcode.

{% asset asset-catalog-any-any-universal.png %}

When you do this,
Xcode copies the file to the the `.dataset` subdirectory
and updates the `contents.json` metadata file
with the filename and
[Universal Type Identifier](https://en.wikipedia.org/wiki/Uniform_Type_Identifier).
of the file.

```json
{
  "info": {
    "version": 1,
    "author": "xcode"
  },
  "data": [
    {
      "idiom": "universal",
      "filename": "colors.json",
      "universal-type-identifier": "public.json"
    }
  ]
}
```

### Step 3. Access Data Using NSDataAsset

Now you can access the file's data
with the following code:

```swift
guard let asset = NSDataAsset(name: "NamedColors") else {
    fatalError("Missing data asset: NamedColors")
}

let data = asset.data
```

In the case of our color app,
we might call this from the `viewDidLoad()` method in a view controller
and use the resulting data to decode an array of model objects
to be displayed in a table view:

```swift
let decoder = JSONDecoder()
self.colors = try! decoder.decode([NamedColor].self, from: asset.data)
```

## Mixing It Up

Data sets don't typically benefit from app thinning features of Asset Catalogs
(most JSON files, for example,
couldn't care less about what version of Metal is supported by the device).

But for our color palette app example,
we might provide different color lists on devices with a wide-gamut display.

To do this,
select the asset in the sidebar of the Asset Catalog editor
and click on the drop-down control labeled Gamut in the Attributes Inspector.

{% asset select-color-gamut.png %}

After providing bespoke data files for each gamut,
the `contents.json` metadata file should look something like this:

```json
{
  "info": {
    "version": 1,
    "author": "xcode"
  },
  "data": [
    {
      "idiom": "universal",
      "filename": "colors-srgb.json",
      "universal-type-identifier": "public.json",
      "display-gamut": "sRGB"
    },
    {
      "idiom": "universal",
      "filename": "colors-p3.json",
      "universal-type-identifier": "public.json",
      "display-gamut": "display-P3"
    }
  ]
}
```

## Keeping It Fresh

Storing and retrieving data from the Asset Catalog is trivial.
What's actually difficult --- and ultimately more important ---
is keeping that data up-to-date.

Refresh data using `curl`, `rsync`, `sftp`,
Dropbox, BitTorrent, or Filecoin.
Kick things off from a shell script
(and call it in an Xcode Build Phase, if you like).
Add it to your `Makefile`, `Rakefile`, `Fastfile`,
or whatever is required of your build system of choice.
Delegate the task to Jenkins or Travis or that bored-looking intern.
Trigger it from a bespoke Slack integration
or create a Siri Shortcut so you can wow your colleagues with a casual
_"Hey Siri, update that data asset before it gets too stale"_.

**However you decide to synchronize your data,
just make sure it's automated and part of your release process.**

Here's an example of a shell script you might run
to download the latest data file using `curl`:

```shell
#!/bin/sh
CURL='/usr/bin/curl'
URL='https://example.com/path/to/data.json'
OUTPUT='./Assets.xcassets/Colors.dataset/data.json'

$CURL -fsSL -o $OUTPUT $URL
```

## Wrapping It Up

Although the Assets Catalog performs lossless compression of image assets,
nothing from the documentation, Xcode Help, or WWDC sessions  
indicate that any such optimization is done for data assets (at least not yet).

For data assets larger than, say, a few hundred kilobytes,
you should consider using compression.
This is especially true for text files like JSON, CSV, and XML,
which typically compress down to 60% — 80% of their original size.

We can add compression to our previous shell script
by piping the output of `curl` to `gzip` before writing to our file:

```shell
#!/bin/sh
CURL='/usr/bin/curl'
GZIP='/usr/bin/gzip'
URL='https://example.com/path/to/data.json'
OUTPUT='./Assets.xcassets/Colors.dataset/data.json.gz'

$CURL -fsSL $URL | $GZIP -c > $OUTPUT
```

If you do adopt compression,
make sure that the `"universal-type-identifier"` field
reflects this:

```json
{
  "info": {
    "version": 1,
    "author": "xcode"
  },
  "data": [
    {
      "idiom": "universal",
      "filename": "colors.json.gz",
      "universal-type-identifier": "org.gnu.gnu-zip-archive"
    }
  ]
}
```

On the client-side,
it's up to you to decompress data from the asset catalog before use.
If you had a `Gzip` module, you might do the following:

```swift
do {
    let data = try Gzip.decompress(data: asset.data)
} catch {
    fatalError(error.localizedDescription)
}
```

Or, if you do this multiple times in your app,
you could create a convenience method in an extension to `NSDataAsset`:

```swift
extension NSDataAsset {
    func decompressedData() throws -> Data {
        return try Gzip.decompress(data: self.data)
    }
}
```

{% info do %}

You might also consider managing large data asset files in version control
using [Git Large File Storage (LFS)](https://git-lfs.github.com).

{% endinfo %}

---

Although it's tempting to assume that all of your users
enjoy fast, ubiquitous network access over WiFi and LTE,
this isn't true for everyone,
and certainly not all the time.

Take a moment to see what networking calls your app makes at launch,
and consider if any of these might benefit from being pre-loaded.
Making a good first impression
could mean the difference between a long-term active use
and deletion after a few seconds.
