---
title: macOS Dynamic Desktop
author: Mattt
category: ""
excerpt: >
  Dark Mode is one of the most popular additions to macOS ---
  especially among us developer types.
  If you triangulate between that and Night Shift, 
  introduced a couple of years prior,
  you get the Dynamic Desktop feature, new in Mojave.
status:
  swift: 4.2
---

Dark Mode is one of the most popular additions to macOS ---
especially among us developer types,
who tend towards light-on-dark color themes in text editors
and appreciate this new visual consistency across the system.

A couple of years back, there was similar fanfare for Night Shift,
which helped to reduce eye strain
from hacking late into the night (or early in the morning, as it were).

If you triangulate from those two macOS features,
you get Dynamic Desktops, also new in Mojave.
Now when you go to "System Preferences > Desktop & Screen Saver",
you have the option to select a "Dynamic" desktop picture
that changes throughout the day, based on your location.

{% asset desktop-and-screen-saver-preference-pane.png %}

The result is subtle and delightful.
Having a background that tracks the passage of time
makes the desktop feel alive;
in tune with the natural world.
(If nothing else,
it makes for a lovely visual effect when switching dark mode on and off)

_But how does it work, exactly?_<br/>
That's the question for this week's NSHipster article.

The answer involves a deep dive into image formats,
a little bit of reverse-engineering
and even some spherical trigonometry.

---

The first step to understanding how Dynamic Desktop works
is to get hold of a dynamic image.

If you're running macOS Mojave
open Finder,
select "Go > Go to Folder..." (<kbd>⇧</kbd><kbd>⌘</kbd><kbd>G</kbd>),
and enter "/Library/Desktop Pictures/".

{% asset go-to-library-desktop-pictures.png %}

In this directory,
you should find a file named "Mojave.heic".
Double-click it to open it in Preview.

{% asset mojave-heic.png %}

In Preview,
the sidebar shows a list of thumbnails numbered 1 through 16,
each showing a different view of the desert scene.

{% asset mojave-dynamic-desktop-images.png %}

If we select "Tools > Show Inspector" (<kbd>⌘</kbd><kbd>I</kbd>),
we get some general information about what we're looking at:

{% asset mojave-heic-preview-info.png %}

Unfortunately, that's about all Preview gives us
(at least at the time of writing).
If we click on the next panel over, "More Info Inspector",
we don't learn a whole lot more about our subject:

|              |            |
| ------------ | ---------- |
| Color Model  | RGB        |
| Depth:       | 8          |
| Pixel Height | 2,880      |
| Pixel Width  | 5,120      |
| Profile Name | Display P3 |

{% info %}

The `.heic` file extension corresponds to image containers
encoded using the <abbr title="High-Efficiency Image File Format">HEIF</abbr>,
or High-Efficiency Image File Format
(which is itself based on <abbr title="High-Efficiency Video Compression">HEVC</abbr>,
or High-Efficiency Video Compression ---
also known as H.265 video).
For more information, check out
[WWDC 2017 Session 503 "Introducing HEIF and HEVC"](https://developer.apple.com/videos/play/wwdc2017/503/)

{% endinfo %}

If we want to learn more,
we'll need to roll up our sleeves
and get our hands dirty with some low-level APIs.

## Digging Deeper with CoreGraphics

Let's start our investigation by creating a new Xcode Playground.
For simplicity, we can hard-code a URL to the "Mojave.heic" file on our system.

```swift
import Foundation
import CoreGraphics

// macOS 10.14 Mojave Required
let url = URL(fileURLWithPath: "/Library/Desktop Pictures/Mojave.heic")
```

Next, create a `CGImageSource`,
copy its metadata,
and enumerate over each of its tags:

```swift
let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
let metadata = CGImageSourceCopyMetadataAtIndex(source, 0, nil)!
let tags = CGImageMetadataCopyTags(metadata) as! [CGImageMetadataTag]
for tag in tags {
    guard let name = CGImageMetadataTagCopyName(tag),
        let value = CGImageMetadataTagCopyValue(tag)
    else {
        continue
    }

    print(name, value)
}
```

When we run this code, we get two results:
`hasXMP`, which has a value of `"True"`,
and `solar`, which has a decidedly less understandable value:

```
YnBsaXN0MDDRAQJSc2mvEBADDBAUGBwgJCgsMDQ4PEFF1AQFBgcICQoLUWlRelFh
UW8QACNAcO7vOubr3yO/1e+pmkOtXBAB1AQFBgcNDg8LEAEjQFRxqCKOFiAjwCR6
waUkDgHUBAUGBxESEwsQAiNAVZV4BI4c+CPAEP2uFrMcrdQEBQYHFRYXCxADI0BW
tALKmrjwIz/2ObLnx6l21AQFBgcZGhsLEAQjQFfTrJlEjnwjQByrLle1Q0rUBAUG
Bx0eHwsQBSNAWPrrmI0ISCNAKiwhpSRpc9QEBQYHISIjCxAGI0BgJff9KDpyI0BE
NTOsilht1AQFBgclJicLEAcjQGbHdYIVQKojQEq3fAg86lXUBAUGBykqKwsQCCNA
bTGmpC2YRiNAQ2WFOZGjntQEBQYHLS4vCxAJI0BwXfII2B+SI0AmLcjfuC7g1AQF
BgcxMjMLEAojQHCnF6YrsxcjQBS9AVBLTq3UBAUGBzU2NwsQCyNAcTcSnimmjCPA
GP5E0ASXJtQEBQYHOTo7CxAMI0BxgSADjxK2I8AoalieOTyE1AQFBgc9Pj9AEA0j
QHNWsnnMcWIjwEO+oq1pXr8QANQEBQYHQkNEQBAOI0ABZpkFpAcAI8BKYGg/VvMf
1AQFBgdGR0hAEA8jQErBKblRzPgjwEMGElBIUO0ACAALAA4AIQAqACwALgAwADIA
NAA9AEYASABRAFMAXABlAG4AcAB5AIIAiwCNAJYAnwCoAKoAswC8AMUAxwDQANkA
4gDkAO0A9gD/AQEBCgETARwBHgEnATABOQE7AUQBTQFWAVgBYQFqAXMBdQF+AYcB
kAGSAZsBpAGtAa8BuAHBAcMBzAHOAdcB4AHpAesB9AAAAAAAAAIBAAAAAAAAAEkA
AAAAAAAAAAAAAAAAAAH9
```

### Shining Light on Solar

Most of us would look at that wall of text
and quietly close the lid of our MacBook Pro.
But, as some of you surely noticed,
this text looks an awful lot like it's
[Base64-encoded](https://en.wikipedia.org/wiki/Base64).

Let's test out our hypothesis in code:

```swift
if name == "solar" {
    let data = Data(base64Encoded: value)!
    print(String(data: data, encoding: .ascii))
}
```

<samp>
bplist00Ò\u{01}\u{02}\u{03}...
</samp>

What's that?
`bplist`, followed by a bunch of garbled nonsense?

By golly, that's the
[file signature](https://en.wikipedia.org/wiki/File_format#Magic_number)
for a [binary property list](https://en.wikipedia.org/wiki/Property_list).

Let's see if `PropertyListSerialization` can make any sense of it...

```swift
if name == "solar" {
    let data = Data(base64Encoded: value)!
    let propertyList = try PropertyListSerialization
                            .propertyList(from: data,
                                          options: [],
                                          format: nil)
    print(propertyList)
}
```

```
(
    ap = {
        d = 15;
        l = 0;
    };
    si = (
        {
            a = "-0.3427528387535028";
            i = 0;
            z = "270.9334057827345";
        },
        ...
        {
            a = "-38.04743388682423";
            i = 15;
            z = "53.50908581251309";
        }
    )
)
```

_Now we're talking!_

We have two top-level keys:

The `ap` key corresponds to
a dictionary containing integers for the `d` and `l` keys.

The `si` key corresponds to
an array of dictionaries with integer and floating-point values.
Of the nested dictionary keys,
`i` is the easiest to understand:
incrementing from 0 to 15,
they're the index of the image in the sequence.
It'd be hard to guess `a` and `z` without any additional information,
but they turn out to represent the altitude (`a`) and azimuth (`z`)
of the sun in the corresponding pictures.

### Calculating Solar Position

At the time of writing,
those of us in the northern hemisphere
are settling into the season of autumn
and its shorter, colder days,
whereas those of us in the southern hemisphere
are gearing up for hotter and longer days.
The changing of the seasons reminds us that
the duration of a solar day depends where you are on the planet
and where the planet is in its orbit around the sun.

The good news is that astronomers can tell you ---
with perfect accuracy ---
where the sun is in the sky for any location or time.
The bad news is that
the necessary calculations are
[complicated](https://en.wikipedia.org/wiki/Position_of_the_Sun)
to say the least.

Honestly, we don't really understand it ourselves,
and are pretty much just porting whatever code we manage to find online.
After some trial and error,
we were able to arrive at
[something that seems to work](https://github.com/NSHipster/DynamicDesktop/blob/master/SolarPosition.playground)
(PRs welcome!):

```swift
import Foundation
import CoreLocation

// Apple Park, Cupertino, CA
let location = CLLocation(latitude: 37.3327, longitude: -122.0053)
let time = Date()

let position = solarPosition(for: location, at: time)
let formattedDate = DateFormatter.localizedString(from: time,
                                                    dateStyle: .medium,
                                                    timeStyle: .short)
print("Solar Position on \(formattedDate)")
print("\(position.azimuth)° Az / \(position.elevation)° El")
```

<samp>
Solar Position on Oct 1, 2018 at 12:00
180.73470025840783° Az / 49.27482549913847° El
</samp>

At noon on October 1, 2018,
the sun shines on Apple Park from the south,
about halfway between the horizon and directly overhead.

If track the position of the sun over an entire day,
we get a sinusoidal shape reminiscent of the Apple Watch "Solar" face.

{% asset solar-position-watch-faces.jpg %}

### Extending Our Understanding of XMP

Alright, enough astronomy for the moment.
Let's ground ourselves in something much more banal:
_de facto_ XML metadata standards.

Remember the `hasXMP` metadata key from before?
Yeah, _that_.

<abbr title="Extensible Metadata Platform">XMP</abbr>,
or Extensible Metadata Platform,
is a standard format for tagging files with metadata.
What does XMP look like?
Brace yourself:

```swift
let xmpData = CGImageMetadataCreateXMPData(metadata, nil)
let xmp = String(data: xmpData as! Data, encoding: .utf8)!
print(xmp)
```

```xml
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="XMP Core 5.4.0">
   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
      <rdf:Description rdf:about=""
            xmlns:apple_desktop="http://ns.apple.com/namespace/1.0/">
         <apple_desktop:solar>
            <!-- (Base64-Encoded Metadata) -->
        </apple_desktop:solar>
      </rdf:Description>
   </rdf:RDF>
</x:xmpmeta>
```

_Yuck._

But it's a good thing that we checked.
We'll need to honor that `apple_desktop` namespace
to make our own Dynamic Desktop images work correctly.

Speaking of, let's get started on that.

## Creating Our Own Dynamic Desktop

Let's create a data model to represent a Dynamic Desktop:

```swift
struct DynamicDesktop {
    let images: [Image]

    struct Image {
        let cgImage: CGImage
        let metadata: Metadata

        struct Metadata: Codable {
            let index: Int
            let altitude: Double
            let azimuth: Double

            private enum CodingKeys: String, CodingKey {
                case index = "i"
                case altitude = "a"
                case azimuth = "z"
            }
        }
    }
}
```

Each Dynamic Desktop comprises an ordered sequence of images,
each of which has image data, stored in a `CGImage` object,
and metadata, as discussed before.
We adopt `Codable` in the `Metadata` declaration
in order for the compiler to automatically synthesize conformance.
We'll take advantage of that when it comes time
to generate the Base64-encoded binary property list.

### Writing to an Image Destination

First, create a `CGImageDestination`
with a specified output URL.
The file type is `heic` and the source count
is equal to the number of images to be included.

```swift
guard let imageDestination = CGImageDestinationCreateWithURL(
                                outputURL as CFURL,
                                AVFileType.heic as CFString,
                                dynamicDesktop.images.count,
                                nil
                             )
else {
    fatalError("Error creating image destination")
}
```

Next, enumerate over each image in the dynamic desktop object.
By using the `enumerated()` method,
we also get the current `index` for each loop
so that we can set the image metadata on the first image:

```swift
for (index, image) in dynamicDesktop.images.enumerated() {
    if index == 0 {
        let imageMetadata = CGImageMetadataCreateMutable()
        guard let tag = CGImageMetadataTagCreate(
                            "http://ns.apple.com/namespace/1.0/" as CFString,
                            "apple_desktop" as CFString,
                            "solar" as CFString,
                            .string,
                            try! dynamicDesktop.base64EncodedMetadata() as CFString
                        ),
            CGImageMetadataSetTagWithPath(
                imageMetadata, nil, "xmp:solar" as CFString, tag
            )
        else {
            fatalError("Error creating image metadata")
        }

        CGImageDestinationAddImageAndMetadata(imageDestination,
                                              image.cgImage,
                                              imageMetadata,
                                              nil)
    } else {
        CGImageDestinationAddImage(imageDestination,
                                   image.cgImage,
                                   nil)
    }
}
```

Aside from the unrefined nature of Core Graphics APIs,
the code is pretty straightforward.
The only part that requires further explanation is the call to
`CGImageMetadataTagCreate(_:_:_:_:_:)`.

Because of a mismatch between how image and container metadata are structured
and how they're represented in code,
we have to implement `Encodable` for `DynamicDesktop` ourselves:

```swift
extension DynamicDesktop: Encodable {
    private enum CodingKeys: String, CodingKey {
        case ap, si
    }

    private enum NestedCodingKeys: String, CodingKey {
        case d, l
    }

    func encode(to encoder: Encoder) throws {
        var keyedContainer =
            encoder.container(keyedBy: CodingKeys.self)

        var nestedKeyedContainer =
            keyedContainer.nestedContainer(keyedBy: NestedCodingKeys.self,
                                           forKey: .ap)

        // FIXME: Not sure what `l` and `d` keys indicate
        try nestedKeyedContainer.encode(0, forKey: .l)
        try nestedKeyedContainer.encode(self.images.count, forKey: .d)

        var unkeyedContainer =
            keyedContainer.nestedUnkeyedContainer(forKey: .si)
        for image in self.images {
            try unkeyedContainer.encode(image.metadata)
        }
    }
}
```

With that in place,
we can implement the aforementioned `base64EncodedMetadata()` method like so:

```swift
extension DynamicDesktop {
    func base64EncodedMetadata() throws -> String {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary

        let binaryPropertyListData = try encoder.encode(self)
        return binaryPropertyListData.base64EncodedString()
    }
}
```

Once the for-in loop is exhausted,
and all images and metadata are written,
we call `CGImageDestinationFinalize(_:)` to finalize the image source
and write the image to disk.

```swift
guard CGImageDestinationFinalize(imageDestination) else {
    fatalError("Error finalizing image")
}
```

If everything worked as expected,
you should now be the proud owner of a brand new Dynamic Desktop.
Nice!

---

We love the Dynamic Desktop feature in Mojave,
and are excited to see the same proliferation of them
that we saw when wallpapers hit the mainstream with Windows 95.

If you're so inclined,
here are a few ideas for where to go from here:

### Automatically Generating a Dynamic Desktop from Photos

It's mind-blowing to think that something as transcendent as
the movement of celestial bodies
can be reduced to a system of equations with two inputs:
time and place.

In the example before,
this information is hard-coded,
but you could ostensibly extract that information
from images automatically.

By default,
the camera on most phones captures
[Exif metadata](https://en.wikipedia.org/wiki/Exif)
each time a photo is snapped.
This metadata can include the time which the photo was taken
and the GPS coordinates of the device at the time.

By reading time and location information directly from image metadata,
you can automatically determine solar position
and simplify the process of generating a Dynamic Desktop
from a series of photos.

### Shooting a Time Lapse on Your iPhone

Want to put your new iPhone XS to good use?
(Or more accurately,
"Want to use your old iPhone for something productive
while you procrastinate selling it?")

Mount your phone against a window,
plug it into a charger,
set the Camera to Timelapse mode,
and hit the "Record" button.
By extracting key frames from the resulting video,
you can make your very own _bespoke_ Dynamic Desktop.

You might also want to check out
[Skyflow](https://itunes.apple.com/us/app/skyflow-time-lapse-shooting/id937208291?mt=8)
or similar apps that more easily allow you to
take still photos at predefined intervals.

### Generating Landscapes from GIS Data

If you can't stand to be away from your phone for an entire day (sad)
or don't have anything remarkable to look (also sad),
you could always create your own reality (sounds sadder than it is).

Using an app like
[Terragen](https://planetside.co.uk),
you can render photo-realistic 3D landscapes,
with fine-tuned control over the earth, sun, and sky.

You can make it even easier for yourself by
downloading an elevation map from the U.S. Geological Survey's
[National Map website](https://viewer.nationalmap.gov/basic/)
and using that as a template for your 3D rendering project.

### Downloading Pre-Made Dynamic Desktops

Or if you have actual work to do
and can't be bothered to spend your time making pretty pictures,
you can always just pay someone else to do it for you.

We're personally fans of the the
[24 Hour Wallpaper](https://www.jetsoncreative.com/24hourwallpaper/) app.
If you have any other recommendations,
[@ us on Twitter!](https://twitter.com/NSHipster/).
