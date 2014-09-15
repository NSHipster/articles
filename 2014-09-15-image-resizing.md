---
layout: post
title: Image Resizing Techniques
category: ""
excerpt: "Since time immemorial, iOS developers have been perplexed by a singular question: 'How do you resize an image?'. This article endeavors to provide a clear answer to this eternal question."
---

Since time immemorial, iOS developers have been perplexed by a singular question: "How do you resize an image?". It is a question of beguiling clarity, spurred on by a mutual mistrust of developer and platform. A thousand code samples litter web search results, each claiming to be the One True Solution, and all the others false prophets.

It's embarrassing, really.

This week's article endeavors to provide a clear explanation of the various approaches to image resizing on iOS (and OS X, making the appropriate `UIImage` → `NSImage` conversions), using empirical evidence to offer insights into the performance characteristics of each approach, rather than simply prescribing any one way for all situations.

**Before reading any further, please note the following:**

When setting a `UIImage` on a `UIImageView`, manual resizing is unnecessary for the vast majority of use cases. Instead, one can simply set the `contentMode` property to either `.ScaleAspectFit` to ensure that the entire image is visible within the frame of the image view, or `.ScaleAspectFill` to have the entire image view filled by the image, cropping as necessary from the center.

~~~{swift}
imageView.contentMode = .ScaleAspectFit
imageView.image = image
~~~

* * *

## Determining Scaled Size

Before doing any image resizing, one must first determine the target size to scale to.

### Scaling by Factor

The simplest way to scale an image is by a constant factor. Generally, this involves dividing by a whole number to reduce the original size (rather than multiplying by a whole number to magnify).

A new `CGSize` can be computed by scaling the width and height components individually:

~~~{swift}
let size = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0)
~~~

...or by applying a `CGAffineTransform`:

~~~{swift}
let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
~~~

### Scaling by Aspect Ratio

It's often useful to scale the original size in such a way that fits within a rectangle without changing the original aspect ratio. `AVMakeRectWithAspectRatioInsideRect` is a useful function found in the AVFoundation framework that takes care of that calculation for you:

~~~{swift}
import AVFoundation
let size = AVMakeRectWithAspectRatioInsideRect(image.size, imageView.bounds)
~~~

## Resizing Images

There are a number of different approaches to resizing an image, each with different capabilities and performance characteristics.

### `UIGraphicsBeginImageContextWithOptions` & `UIImage -drawInRect:`

The highest-level APIs for image resizing can be found in the UIKit framework. Given a `UIImage`, a temporary graphics context can be used to render a scaled version, using `UIGraphicsBeginImageContextWithOptions()` and `UIGraphicsGetImageFromCurrentImageContext()`:

~~~{swift}
let image = UIImage(contentsOfFile: self.URL.absoluteString!)

let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
let hasAlpha = false
let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
image.drawInRect(CGRect(origin: CGPointZero, size: size))

let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
~~~

`UIGraphicsBeginImageContextWithOptions()` creates a temporary rendering context into which the original is drawn. The first argument, `size`, is the target size of the scaled image. The second argument, `isOpaque` is used to determine whether an alpha channel is rendered. Setting this to `false` for images without transparency (i.e. an alpha channel) may result in an image with a pink hue. The third argument `scale` is the display scale factor. When set to `0.0`, the scale factor of the main screen is used, which for Retina displays is `2.0` or higher (`3.0` on the iPhone 6 Plus).

### `CGBitmapContextCreate` & `CGContextDrawImage`

Core Graphics / Quartz 2D offers a lower-level set of APIs that allow for more advanced configuration. Given a `CGImage`, a temporary bitmap context is used to render the scaled image, using `CGBitmapContextCreate()` and `CGBitmapContextCreateImage()`:

~~~{swift}
let image = UIImage(contentsOfFile: self.URL.absoluteString!).CGImage

let width = CGImageGetWidth(image) / 2.0
let height = CGImageGetHeight(image) / 2.0
let bitsPerComponent = CGImageGetBitsPerComponent(image)
let bytesPerRow = CGImageGetBytesPerRow(image)
let colorSpace = CGImageGetColorSpace(image)
let bitmapInfo = CGImageGetBitmapInfo(image)

let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)

CGContextSetInterpolationQuality(context, kCGInterpolationHigh)

CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), image)

let scaledImage = UIImage(CGImage: CGBitmapContextCreateImage(context))
~~~

`CGBitmapContextCreate` takes several arguments to construct a context with desired dimensions and amount of memory for each channel within a given colorspace. In the example, these values are fetched from the `CGImage`. Next, `CGContextSetInterpolationQuality` allows for the context to interpolate pixels at various levels of fidelity. In this case, `kCGInterpolationHigh` is passed for best results. `CGContextDrawImage` allows for the image to be drawn at a given size and position, allowing for the image to be cropped on a particular edge or to fit a set of image features, such as faces. Finally, `CGBitmapContextCreateImage` creates a `CGImage` from the context.

### `CGImageSourceCreateThumbnailAtIndex`

Image I/O is a powerful, yet lesser-known framework for working with images. Independent of Core Graphics, it can read and write between between many different formats, access photo metadata, and perform common image processing operations. The framework offers the fastest image encoders and decoders on the platform, with advanced caching mechanisms and even the ability to load images incrementally.

`CGImageSourceCreateThumbnailAtIndex` offers a concise API with different options than found in equivalent Core Graphics calls:

~~~{swift}
import ImageIO

if let imageSource = CGImageSourceCreateWithURL(self.URL, nil) {
    let options = [
        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) / 2.0,
        kCGImageSourceCreateThumbnailFromImageIfAbsent: true
    ]

    let scaledImage = UIImage(CGImage: CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options))
}
~~~

Given a `CGImageSource` and set of options, `CGImageSourceCreateThumbnailAtIndex` creates a thumbnail image. Resizing is accomplished by the `kCGImageSourceThumbnailMaxPixelSize`. Specifying the maximum dimension divided by a constant factor scales the image while maintaining the original aspect ratio. By specifying either `kCGImageSourceCreateThumbnailFromImageIfAbsent` or `kCGImageSourceCreateThumbnailFromImageAlways`, Image I/O will automatically cache the scaled result for subsequent calls.

### Lanczos Resampling with Core Image

Core Image provides a built-in [Lanczos resampling](http://en.wikipedia.org/wiki/Lanczos_resampling) functionality with the `CILanczosScaleTransform` filter. Although arguably a higher-level API than UIKit, the pervasive use of key-value coding in Core Image makes it unwieldy.

That said, at least the pattern is consistent. The process of creating a transform filter, configuring it, and rendering an output image is just like any other Core Image workflow:

~~~{swift}
let image = CIImage(contentsOfURL: self.URL)

let filter = CIFilter(name: "CILanczosScaleTransform")
filter.setValue(image, forKey: "inputImage")
filter.setValue(0.5, forKey: "inputScale")
filter.setValue(1.0, forKey: "inputAspectRatio")
let outputImage = filter.valueForKey("outputImage") as CIImage

let context = CIContext(options: nil)
let scaledImage = UIImage(CGImage: self.context.createCGImage(outputImage, fromRect: outputImage.extent()))
~~~

`CILanczosScaleTransform` accepts an `inputImage`, `inputScale`, and `inputAspectRatio`, all of which are pretty self-explanatory. A `CIContext` is used to create a `UIImage` by way of a `CGImageRef` intermediary representation, since `UIImage(CIImage:)` doesn't often work as expected.

---

## Performance Benchmarks

So how do these various approaches stack up to one another?

Here are the results of a set of [performance benchmarks](http://nshipster.com/benchmarking/) done on an iPod Touch (5th Generation) running iOS 8.0 GM, using [`XCTestCase.measureBlock()`](http://nshipster.com/xctestcase/):

### JPEG

Scaling a large, high-resolution (12000 ⨉ 12000 px 20 MB JPEG) source image from [NASA Visible Earth](http://visibleearth.nasa.gov/view.php?id=78314) to 1/10<sup>th</sup> the size:

| Operation                          | Time _(sec)_ | σ    |
|------------------------------------|--------------|------|
| `UIKit`                            | 0.002        | 22%  |
| `Core Graphics` <sup>1</sup>       | 0.006        | 9%   |
| `Image I/O`   <sup>2</sup>         | 0.001        | 121% |
| `Core Image` <sup>3, 4</sup>       | 0.011        | 7%   |

### PNG

Scaling a reasonably large (1024 ⨉ 1024 px 1MB PNG) rendering of the [Postgres.app](http://postgresapp.com) Icon to 1/10<sup>th</sup> the size:

| Operation                          | Time _(sec)_ | σ    |
|------------------------------------|--------------|------|
| `UIKit`                            | 0.001        | 25%  |
| `Core Graphics` <sup>5</sup>       | 0.005        | 12%  |
| `Image I/O` <sup>6</sup>           | 0.001        | 82%  |
| `Core Image` <sup>7</sup>          | 0.234        | 43%  |

<sup>1, 5</sup> Results were consistent across different values of `CGInterpolationQuality`, with negligible differences in performance benchmarks.

<sup>2</sup> The high standard deviation reflects the cost of creating the cached thumbnail, which was comparable to the performance of the equivalent Core Graphics function.

<sup>3</sup> Creating a `CIContext` is an extremely expensive operation, and accounts for most of the time spent in the benchmark. Using a cached instance reduced average runtime down to metrics comparable with `UIGraphicsBeginImageContextWithOptions`.

<sup>4, 7</sup> Setting `kCIContextUseSoftwareRenderer` to `true` on the options passed on `CIContext` creation yielded results an order of magnitude slower than base results.

## Conclusions

- **UIKit**, **Core Graphics**, and **Image I/O** all perform well for scaling operations on most images.
- **Core Image** is outperformed for image scaling operations. In fact, it is specifically recommended in the [Performance Best Practices section of the Core Image Programming Guide](https://developer.apple.com/library/mac/documentation/graphicsimaging/Conceptual/CoreImaging/ci_performance/ci_performance.html#//apple_ref/doc/uid/TP30001185-CH10-SW1) to use Core Graphics or Image I/O functions to crop or downsample images beforehand.
- For general image scaling without any additional functionality, **`UIGraphicsBeginImageContextWithOptions`** is probably the best option.
- If image quality is a consideration, consider using **`CGBitmapContextCreate`** in combination with **`CGContextSetInterpolationQuality`**.
- When scaling images with the intent purpose of displaying thumbnails, **`CGImageSourceCreateThumbnailAtIndex`** offers a compelling solution for both rendering and caching.

* * *

### NSMutableHipster

This is a good opportunity to remind readers that NSHipster articles are [published on GitHub](https://github.com/NSHipster/articles). If you have any corrections or additional insights to offer, please [open an issue or submit a pull request](https://github.com/nshipster/articles/issues).
