---
title: Image Resizing Techniques
author: Mattt Thompson
category: ""
excerpt: "Since time immemorial, iOS developers have been perplexed by a singular question: 'How do you resize an image?'. This article endeavors to provide a clear answer to this eternal question."
status:
    swift: 2.0
    reviewed: September 30, 2015
revisions:
    "2014-09-15": Original publication.
    "2015-09-30": Revised for Swift 2.0, `vImage` method added.
---

Since time immemorial, iOS developers have been perplexed by a singular question: "How do you resize an image?". It is a question of beguiling clarity, spurred on by a mutual mistrust of developer and platform. A thousand code samples litter web search results, each claiming to be the One True Solution, and all the others false prophets.

It's embarrassing, really.

This week's article endeavors to provide a clear explanation of the various approaches to image resizing on iOS (and OS X, making the appropriate `UIImage` → `NSImage` conversions), using empirical evidence to offer insights into the performance characteristics of each approach, rather than simply prescribing any one way for all situations.

**Before reading any further, please note the following:**

When setting a `UIImage` on a `UIImageView`, manual resizing is unnecessary for the vast majority of use cases. Instead, one can simply set the `contentMode` property to either `.ScaleAspectFit` to ensure that the entire image is visible within the frame of the image view, or `.ScaleAspectFill` to have the entire image view filled by the image, cropping as necessary from the center.

```swift
imageView.contentMode = .ScaleAspectFit
imageView.image = image
```

* * *

## Determining Scaled Size

Before doing any image resizing, one must first determine the target size to scale to.

### Scaling by Factor

The simplest way to scale an image is by a constant factor. Generally, this involves dividing by a whole number to reduce the original size (rather than multiplying by a whole number to magnify).

A new `CGSize` can be computed by scaling the width and height components individually:

```swift
let size = CGSize(width: image.size.width / 2, height: image.size.height / 2)
```

...or by applying a `CGAffineTransform`:

```swift
let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
```

### Scaling by Aspect Ratio

It's often useful to scale the original size in such a way that fits within a rectangle without changing the original aspect ratio. `AVMakeRectWithAspectRatioInsideRect` is a useful function found in the AVFoundation framework that takes care of that calculation for you:

```swift
import AVFoundation
let rect = AVMakeRectWithAspectRatioInsideRect(image.size, imageView.bounds)
```

## Resizing Images

There are a number of different approaches to resizing an image, each with different capabilities and performance characteristics.

### `UIGraphicsBeginImageContextWithOptions` & `UIImage -drawInRect:`

The highest-level APIs for image resizing can be found in the UIKit framework. Given a `UIImage`, a temporary graphics context can be used to render a scaled version, using `UIGraphicsBeginImageContextWithOptions()` and `UIGraphicsGetImageFromCurrentImageContext()`:

```swift
let image = UIImage(contentsOfFile: self.URL.absoluteString!)

let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
let hasAlpha = false
let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
image.drawInRect(CGRect(origin: CGPointZero, size: size))

let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
UIGraphicsEndImageContext()
```

`UIGraphicsBeginImageContextWithOptions()` creates a temporary rendering context into which the original is drawn. The first argument, `size`, is the target size of the scaled image. The second argument, `isOpaque` is used to determine whether an alpha channel is rendered. Setting this to `false` for images without transparency (i.e. an alpha channel) may result in an image with a pink hue. The third argument `scale` is the display scale factor. When set to `0.0`, the scale factor of the main screen is used, which for Retina displays is `2.0` or higher (`3.0` on the iPhone 6 Plus).

### `CGBitmapContextCreate` & `CGContextDrawImage`

Core Graphics / Quartz 2D offers a lower-level set of APIs that allow for more advanced configuration. Given a `CGImage`, a temporary bitmap context is used to render the scaled image, using `CGBitmapContextCreate()` and `CGBitmapContextCreateImage()`:

```swift
let cgImage = UIImage(contentsOfFile: self.URL.absoluteString!).CGImage

let width = CGImageGetWidth(cgImage) / 2
let height = CGImageGetHeight(cgImage) / 2
let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
let bytesPerRow = CGImageGetBytesPerRow(cgImage)
let colorSpace = CGImageGetColorSpace(cgImage)
let bitmapInfo = CGImageGetBitmapInfo(cgImage)

let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)

CGContextSetInterpolationQuality(context, kCGInterpolationHigh)

CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), cgImage)

let scaledImage = CGBitmapContextCreateImage(context).flatMap { UIImage(CGImage: $0 }
```

`CGBitmapContextCreate` takes several arguments to construct a context with desired dimensions and amount of memory for each channel within a given colorspace. In the example, these values are fetched from the `CGImage`. Next, `CGContextSetInterpolationQuality` allows for the context to interpolate pixels at various levels of fidelity. In this case, `kCGInterpolationHigh` is passed for best results. `CGContextDrawImage` allows for the image to be drawn at a given size and position, allowing for the image to be cropped on a particular edge or to fit a set of image features, such as faces. Finally, `CGBitmapContextCreateImage` creates a `CGImage` from the context.

### `CGImageSourceCreateThumbnailAtIndex`

Image I/O is a powerful, yet lesser-known framework for working with images. Independent of Core Graphics, it can read and write between many different formats, access photo metadata, and perform common image processing operations. The framework offers the fastest image encoders and decoders on the platform, with advanced caching mechanisms and even the ability to load images incrementally.

`CGImageSourceCreateThumbnailAtIndex` offers a concise API with different options than found in equivalent Core Graphics calls:

```swift
import ImageIO

if let imageSource = CGImageSourceCreateWithURL(self.URL, nil) {
    let options: [NSString: NSObject] = [
        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height) / 2.0,
        kCGImageSourceCreateThumbnailFromImageAlways: true
    ]
    
    let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options).flatMap { UIImage(CGImage: $0) }
}
```

Given a `CGImageSource` and set of options, `CGImageSourceCreateThumbnailAtIndex` creates a thumbnail image. Resizing is accomplished by the `kCGImageSourceThumbnailMaxPixelSize`. Specifying the maximum dimension divided by a constant factor scales the image while maintaining the original aspect ratio. By specifying either `kCGImageSourceCreateThumbnailFromImageIfAbsent` or `kCGImageSourceCreateThumbnailFromImageAlways`, Image I/O will automatically cache the scaled result for subsequent calls.

### Lanczos Resampling with Core Image

Core Image provides a built-in [Lanczos resampling](http://en.wikipedia.org/wiki/Lanczos_resampling) functionality with the `CILanczosScaleTransform` filter. Although arguably a higher-level API than UIKit, the pervasive use of key-value coding in Core Image makes it unwieldy.

That said, at least the pattern is consistent. The process of creating a transform filter, configuring it, and rendering an output image is just like any other Core Image workflow:

```swift
let image = CIImage(contentsOfURL: self.URL)

let filter = CIFilter(name: "CILanczosScaleTransform")!
filter.setValue(image, forKey: "inputImage")
filter.setValue(0.5, forKey: "inputScale")
filter.setValue(1.0, forKey: "inputAspectRatio")
let outputImage = filter.valueForKey("outputImage") as! CIImage

let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
let scaledImage = UIImage(CGImage: self.context.createCGImage(outputImage, fromRect: outputImage.extent()))
```

`CILanczosScaleTransform` accepts an `inputImage`, `inputScale`, and `inputAspectRatio`, all of which are pretty self-explanatory. A `CIContext` is used to create a `UIImage` by way of a `CGImageRef` intermediary representation, since `UIImage(CIImage:)` doesn't often work as expected.

Creating a `CIContext` is an expensive operation, so a cached context should always be used for repeated resizing. A `CIContext` can be created using either the GPU or the CPU (much slower) for rendering—use the `kCIContextUseSoftwareRenderer` key in the options dictionary to specify which.


### `vImage` in Accelerate

The [Accelerate framework](https://developer.apple.com/library/prerelease/ios/documentation/Accelerate/Reference/AccelerateFWRef/index.html#//apple_ref/doc/uid/TP40009465) includes a suite of `vImage` image-processing functions, with a [set of functions](https://developer.apple.com/library/prerelease/ios/documentation/Performance/Reference/vImage_geometric/index.html#//apple_ref/doc/uid/TP40005490-CH212-145717) that scale an image buffer. These lower-level APIs promise high performance with low power consumption, but at the cost of managing the buffers yourself. The following is a Swift version of a method [suggested by Nyx0uf on GitHub](https://gist.github.com/Nyx0uf/217d97f81f4889f4445a):

```swift
let cgImage = UIImage(contentsOfFile: self.URL.absoluteString!).CGImage

// create a source buffer
var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, 
    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.First.rawValue), 
    version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.RenderingIntentDefault)
var sourceBuffer = vImage_Buffer()
defer {
    sourceBuffer.data.dealloc(Int(sourceBuffer.height) * Int(sourceBuffer.height) * 4)
}

var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
guard error == kvImageNoError else { return nil }
    
// create a destination buffer
let scale = UIScreen.mainScreen().scale
let destWidth = Int(image.size.width * CGFloat(scalingFactor) * scale)
let destHeight = Int(image.size.height * CGFloat(scalingFactor) * scale)
let bytesPerPixel = CGImageGetBitsPerPixel(image.CGImage) / 8
let destBytesPerRow = destWidth * bytesPerPixel
let destData = UnsafeMutablePointer<UInt8>.alloc(destHeight * destBytesPerRow)
defer {
    destData.dealloc(destHeight * destBytesPerRow)
}
var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)

// scale the image
error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
guard error == kvImageNoError else { return nil }
    
// create a CGImage from vImage_Buffer
let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
guard error == kvImageNoError else { return nil }

// create a UIImage
let scaledImage = destCGImage.flatMap { UIImage(CGImage: $0, scale: 0.0, orientation: image.imageOrientation) }
```

The Accelerate APIs used here clearly operate at a lower-level than the other resizing methods. To use this method, you first create a source buffer from your CGImage using a `vImage_CGImageFormat` with `vImageBuffer_InitWithCGImage()`. The destination buffer is allocated at the desired image resolution, then `vImageScale_ARGB8888` does the actual work of resizing the image. Managing your own buffers when operating on images larger than your app's memory limit is left as an exercise for the reader.


---

## Performance Benchmarks

So how do these various approaches stack up to one another?

Here are the results of a set of [performance benchmarks](http://nshipster.com/benchmarking/) done on an iPhone 6 running iOS 8.4, via [this project](https://github.com/natecook1000/Image-Resizing):

### JPEG

Loading, scaling, and displaying a large, high-resolution (12000 ⨉ 12000 px 20 MB JPEG) source image from [NASA Visible Earth](http://visibleearth.nasa.gov/view.php?id=78314) at 1/10<sup>th</sup> the size:

| Operation                          | Time _(sec)_ | σ    |
|------------------------------------|--------------|------|
| `UIKit`                            | 0.612        | 14%  |
| `Core Graphics` <sup>1</sup>       | 0.266        | 3%   |
| `Image I/O`                        | 0.255        | 2%   |
| `Core Image` <sup>2</sup>          | 3.703        | 33%  |
| `vImage` <sup>3</sup>              | --           | --   |

### PNG

Loading, scaling, and displaying a reasonably large (1024 ⨉ 1024 px 1MB PNG) rendering of the [Postgres.app](http://postgresapp.com) Icon at 1/10<sup>th</sup> the size:

| Operation                          | Time _(sec)_ | σ    |
|------------------------------------|--------------|------|
| `UIKit`                            | 0.044        | 30%  |
| `Core Graphics` <sup>4</sup>       | 0.036        | 10%  |
| `Image I/O`                        | 0.038        | 11%  |
| `Core Image` <sup>5</sup>          | 0.053        | 68%  |
| `vImage`                           | 0.050        | 25%  |

<sup>1, 4</sup> Results were consistent across different values of `CGInterpolationQuality`, with negligible differences in performance benchmarks.

<sup>3</sup> The size of the NASA Visible Earth image was larger than could be processed in a single pass on the device.

<sup>2, 5</sup> Setting `kCIContextUseSoftwareRenderer` to `true` on the options passed on `CIContext` creation yielded results an order of magnitude slower than base results.

## Conclusions

- **UIKit**, **Core Graphics**, and **Image I/O** all perform well for scaling operations on most images.
- **Core Image** is outperformed for image scaling operations. In fact, it is specifically recommended in the [Performance Best Practices section of the Core Image Programming Guide](https://developer.apple.com/library/mac/documentation/graphicsimaging/Conceptual/CoreImaging/ci_performance/ci_performance.html#//apple_ref/doc/uid/TP30001185-CH10-SW1) to use Core Graphics or Image I/O functions to crop or downsample images beforehand.
- For general image scaling without any additional functionality, **`UIGraphicsBeginImageContextWithOptions`** is probably the best option.
- If image quality is a consideration, consider using **`CGBitmapContextCreate`** in combination with **`CGContextSetInterpolationQuality`**.
- When scaling images with the intent purpose of displaying thumbnails, **`CGImageSourceCreateThumbnailAtIndex`** offers a compelling solution for both rendering and caching.
- Unless you're already working with `vImage`, the extra work to use the low-level Accelerate framework for resizing doesn't pay off.

