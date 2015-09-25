---
title: PHImageManager
author: Mattt Thompson
category: Cocoa
excerpt: "Yesterday's article described various techniques for resizing images using APIs from the UIKit, Core Graphics, Core Image, and Image I/O frameworks. However, that article failed to mention some rather extraordinary functionality baked into the new Photos framework which takes care of all of this for you."
status:
    swift: 2.0
    reviewed: September 15, 2015
---

[Yesterday's article](http://nshipster.com/image-resizing/) described various techniques for resizing images using APIs from the UIKit, Core Graphics, Core Image, and Image I/O frameworks. However, that article failed to mention some rather extraordinary functionality baked into the new Photos framework which takes care of all of this for you.

For anyone developing apps that manage photos or videos, meet your new best friend: `PHImageManager`.

* * *

New in iOS 8, the Photos framework is something of a triumph for the platform. Photography is one of the key verticals for the iPhone: in addition to being the [most popular cameras in the world](https://www.flickr.com/cameras), photo & video apps are regularly featured on the App Store. This framework goes a long way to empower apps to do even more, with a shared set of tools and primitives.

A great example of this is `PHImageManager`, which acts as a centralized coordinator for image assets. Previously, each app was responsible for creating and caching their own image thumbnails. In addition to requiring extra work on the part of developers, redundant image caches could potentially add up to _gigabytes_ of data across the system. But with `PHImageManager`, apps don't have to worry about resizing or caching logistics, and can instead focus on building out features.

## Requesting Asset Images

`PHImageManager` provides several APIs for asynchronously fetching image and video data for assets. For a given asset, a `PHImageManager` can request an image at a particular size and content mode, with a high degree of configurability in terms of quality and delivery options.

But first, here's a simple example of how a table view might asynchronously load cell images with asset thumbnails:

~~~{swift}
import Photos

var assets: [PHAsset]

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

    let manager = PHImageManager.defaultManager()

    if cell.tag != 0 {
        manager.cancelImageRequest(PHImageRequestID(cell.tag))
    }

    let asset = assets[indexPath.row]

    if let creationDate = asset.creationDate {
        cell.textLabel?.text = NSDateFormatter.localizedStringFromDate(creationDate,
            dateStyle: .MediumStyle,
            timeStyle: .MediumStyle
        )
    } else {
        cell.textLabel?.text = nil
    }

    cell.tag = Int(manager.requestImageForAsset(asset,
        targetSize: CGSize(width: 100.0, height: 100.0),
        contentMode: .AspectFill,
        options: nil) { (result, _) in
            cell.imageView?.image = result
    })

    return cell
}
~~~

~~~{objective-c}
@import Photos;

@property (nonatomic, strong) NSArray<PHAsset *> *assets;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];

    PHImageManager *manager = [PHImageManager defaultManager];

    if (cell.tag) {
        [manager cancelImageRequest:(PHImageRequestID)cell.tag];
    }

    PHAsset *asset = self.assets[indexPath.row];

    if (asset.creationDate) {
        cell.textLabel.text = [NSDateFormatter localizedStringFromDate:asset.creationDate
                                                             dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterMediumStyle];
    } else {
        cell.textLabel.text = nil;
    }

    cell.tag = [manager requestImageForAsset:asset
                                  targetSize:CGSizeMake(100.0, 100.0)
                                 contentMode:PHImageContentModeAspectFill
                                     options:nil
                               resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                   cell.imageView.image = result;
                               }];

    return cell;
}
~~~

API usage is pretty straightforward: the `defaultManager` asynchronously requests an image for the asset corresponding to the cell at a particular index path, and the cell image view is set whenever the result comes back. The only tricky part is handling cell reuse—(1) before assigning the resulting image to the cell's image view, we call `cellForRowAtIndexPath` to be sure we're working with the right cell, and (2) we use the cell's `tag` to keep track of image requests, in order to cancel any pending requests when a cell is reused.

## Batch Pre-Caching Asset Images

If there's reasonable assurance that most of a set of assets will be viewed at some point, it may make sense to pre-cache those images. `PHCachingImageManager` is a subclass of `PHImageManager` designed to do just that.

For example, here's how the results of a `PHAsset` fetch operation can be pre-cached in order to optimize image availability:

~~~{swift}
let cachingImageManager = PHCachingImageManager()

let options = PHFetchOptions()
options.predicate = NSPredicate(format: "favorite == YES")
options.sortDescriptors = [
    NSSortDescriptor(key: "creationDate", ascending: true)
]

let results = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
var assets: [PHAsset] = []
results.enumerateObjectsUsingBlock { (object, _, _) in
    if let asset = object as? PHAsset {
        assets.append(asset)
    }
}

cachingImageManager.startCachingImagesForAssets(assets,
    targetSize: PHImageManagerMaximumSize,
    contentMode: .AspectFit,
    options: nil
)
~~~

~~~{objective-c}
PHCachingImageManager *cachingImageManager = [[PHCachingImageManager alloc] init];

PHFetchOptions *options = [[PHFetchOptions alloc] init];
options.predicate = [NSPredicate predicateWithFormat:@"favorite == YES"];
options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES]];

PHFetchResult *results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage
                                                  options:nil];

NSMutableArray<PHAsset *> *assets = [[NSMutableArray alloc] init];
[results enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([object isKindOfClass:[PHAsset class]]) {
        [assets addObject:object];
    }
}];

[cachingImageManager startCachingImagesForAssets:assets
                                      targetSize:PHImageManagerMaximumSize
                                     contentMode:PHImageContentModeAspectFit
                                         options:nil];
~~~

Alternatively, Swift `willSet` / `didSet` hooks offer a convenient way to automatically start pre-caching assets as they are loaded:

~~~{swift}
let cachingImageManager = PHCachingImageManager()
var assets: [PHAsset] = [] {
    willSet {
        cachingImageManager.stopCachingImagesForAllAssets()
    }

    didSet {
        cachingImageManager.startCachingImagesForAssets(self.assets,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .AspectFit,
            options: nil
        )
    }
}
~~~

## PHImageRequestOptions

In the previous examples, the `options` parameter of `requestImageForAsset()` & `startCachingImagesForAssets()` have been set to `nil`. Passing an instance of `PHImageRequestOptions` allows for fine-grained control over what gets loaded and how.

`PHImageRequestOptions` has the following properties:

> - `deliveryMode` _`PHImageRequestOptionsDeliveryMode`_: (_Described Below_)
> - `networkAccessAllowed` _`Bool`_: Will download the image from iCloud, if necessary.
> - `normalizedCropRect` _`CGRect`_: Specify a crop rectangle in unit coordinates of the original image.
> - `progressHandler`: Provide caller a way to be told how much progress has been made prior to delivering the data when it comes from iCloud. Defaults to nil, shall be set by caller
> - `resizeMode` _`PHImageRequestOptionsResizeMode`_: `.None`, `.Fast`, or `.Exact`. Does not apply when size is `PHImageManagerMaximumSize`.
> - `synchronous` _`Bool`_: Return only a single result, blocking until available (or failure). Defaults to NO
> - `version` _`PHImageRequestOptionsVersion`_: `.Current`, `.Unadjusted`, or `.Original`

Several of these properties take a specific `enum` type, which are all pretty self explanatory, save for `PHImageRequestOptionsDeliveryMode`, which encapsulates some pretty complex behavior:

### PHImageRequestOptionsDeliveryMode

> - `.Opportunistic`: Photos automatically provides one or more results in order to balance image quality and responsiveness. Photos may call the resultHandler block method more than once, such as to provide a low-quality image suitable for displaying temporarily while it prepares a high-quality image. If the image manager has already cached the requested image, Photos calls your result handler only once. This option is not available if the synchronous property is `false`.
> - `.HighQualityFormat`: Photos provides only the highest-quality image available, regardless of how much time it takes to load. If the synchronous property is `true` or if using the `requestImageDataForAsset:options:resultHandler:` method, this behavior is the default and only option.
> - `.FastFormat`: Photos provides only a fast-loading image, possibly sacrificing image quality. If a high-quality image cannot be loaded quickly, the result handler provides a low-quality image. Check the `PHImageResultIsDegradedKey` key in the `info` dictionary to determine the quality of image provided to the result handler.

## Cropping Asset To Detected Faces Using 2-Phase Image Request

Using `PHImageManager` and `PHImageRequestOptions` to their full capacity allows for rather sophisticated functionality. One could, for example, use successive image requests to crop full-quality assets to any faces detected in the image.

~~~{swift}
let asset: PHAsset

@IBOutlet weak var imageView: UIImageView!
@IBOutlet weak var progressView: UIProgressView!

override func viewDidLoad() {
    super.viewDidLoad()

    let manager = PHImageManager.defaultManager()

    let initialRequestOptions = PHImageRequestOptions()
    initialRequestOptions.synchronous = true
    initialRequestOptions.resizeMode = .Fast
    initialRequestOptions.deliveryMode = .FastFormat

    manager.requestImageForAsset(asset,
        targetSize: CGSize(width: 250.0, height: 250.0),
        contentMode: .AspectFit,
        options: initialRequestOptions) { (initialResult, _) in
            guard let ciImage = initialResult?.CIImage else {
                return
            }

            let finalRequestOptions = PHImageRequestOptions()
            finalRequestOptions.progressHandler = { (progress, _, _, _) in
                self.progressView.progress = Float(progress)
            }

            let detector = CIDetector(
                ofType: CIDetectorTypeFace,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyLow]
            )

            let features = detector.featuresInImage(ciImage)
            if features.count > 0 {
                var rect = CGRectZero
                features.forEach {
                    rect.unionInPlace($0.bounds)
                }

                let transform = CGAffineTransformMakeScale(1.0 / initialResult!.size.width, 1.0 / initialResult!.size.height)
                finalRequestOptions.normalizedCropRect = CGRectApplyAffineTransform(rect, transform)
            }

            manager.requestImageForAsset(self.asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .AspectFit,
                options: finalRequestOptions) { (finalResult, _) in
                    self.imageView.image = finalResult
            }
    }
}
~~~

~~~{objective-c}
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

- (void)viewDidLoad {
    [super viewDidLoad];

    PHImageManager *manager = [PHImageManager defaultManager];

    PHImageRequestOptions *initialRequestOptions = [[PHImageRequestOptions alloc] init];
    initialRequestOptions.synchronous = true;
    initialRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    initialRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;

    void (^resultHandler)(UIImage *, NSDictionary *) = ^(UIImage * _Nullable initialResult, NSDictionary * _Nullable info) {
        if (!initialResult.CIImage) {
            return;
        }

        PHImageRequestOptions *finalRequestOptions = [[PHImageRequestOptions alloc] init];
        finalRequestOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            self.progressView.progress = progress;
        };

        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
        NSArray<CIFeature *> *features = [detector featuresInImage:initialResult.CIImage];
        if (features.count) {
            CGRect rect;
            for (CIFeature *feature in features) {
                CGRectUnion(rect, feature.bounds);
            }

            CGAffineTransform transform = CGAffineTransformMakeScale(1.0 / initialResult.size.width, 1.0 / initialResult.size.height);
            finalRequestOptions.normalizedCropRect = CGRectApplyAffineTransform(rect, transform);
        }

        [manager requestImageForAsset:self.asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeAspectFit
                              options:finalRequestOptions
                        resultHandler:^(UIImage * _Nullable finalResult, NSDictionary * _Nullable info) {
                            self.imageView.image = finalResult;
                        }];
    };
    // typedef void (^ PHAssetImageProgressHandler)(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) NS_AVAILABLE_IOS(8_0);

    [manager requestImageForAsset:self.asset
                       targetSize:PHImageManagerMaximumSize
                      contentMode:PHImageContentModeAspectFit
                          options:initialRequestOptions
                    resultHandler:resultHandler];

}
~~~

The initial request attempts to get the most readily available representation of an asset to pass into a `CIDetector` for facial recognition. If any features were detected, the final request would be cropped to them, by specifying the `normalizedCropRect` on the final `PHImageRequestOptions`.

> `normalizedCropRect` is normalized for `origin` and `size` components within the inclusive range `0.0` to `1.0`. An affine transformation scaling on the inverse of the original frame makes for an easy calculation.

* * *

From its very inception, iOS has been a balancing act between functionality and integrity. And with every release, a combination of thoughtful affordances and powerful APIs have managed to expand the role third-party applications without compromising security or performance.

By unifying functionality for fetching, managing, and manipulating photos, the Photos framework will dramatically raise the standards for existing apps, while simultaneously lowering the bar for developing apps, and is a stunning example of why developers tend to prefer iOS as a platform.
