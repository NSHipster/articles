---
title: UIActivityViewController
author: Mattt Thompson
category: Cocoa
excerpt: "The relationship between code and data has long been a curious one."
status:
    swift: 2.0
    reviewed: September 7, 2015
---

The relationship between code and data has long been a curious one.

Certain programming languages, such as [Lisp](http://en.wikipedia.org/wiki/Lisp_programming_language), [Io](http://en.wikipedia.org/wiki/Io_%28programming_language%29), and [Mathematica](http://en.wikipedia.org/wiki/Mathematica) are  [homoiconic](http://en.wikipedia.org/wiki/Homoiconicity), meaning that their code is represented as a data primitive, which itself can be manipulated in code. Most other languages, including Objective-C, however, create a strict boundary between the two, shying away from `eval()` and other potentially dangerous methods of dynamic instructing loading.

This tension between code and data is brought to a whole new level when the data in question is too large or unwieldy to represent as anything but a byte stream. The question of how to encode, decode, and interpret the binary representation of images, documents, and media has been ongoing since the very first operating systems.

The Core Services framework on OS X and Mobile Core Services framework on iOS provide functions that identify and categorize data types by file extension and [MIME type](http://en.wikipedia.org/wiki/Internet_media_type), according to [Universal Type Identifiers](http://en.wikipedia.org/wiki/Uniform_Type_Identifier). UTIs provide an extensible, hierarchical categorization system, which affords the developer great flexibility in handling even the most exotic file types. For example, a Ruby source file (`.rb`) is categorized as Ruby Source Code > Source Code > Text > Content > Data; a QuickTime Movie file (`.mov`) is categorized as Video > Movie > Audiovisual Content > Content > Data.

UTIs have worked reasonably well within the filesystem abstraction of the desktop. However, in a mobile paradigm, where files and directories are hidden from the user, this breaks down quickly. And, what's more, the rise of cloud services and social media has placed greater importance on remote entities over local files. Thus, a tension between UTIs and URLs.

It's clear that we need something else. Could `UIActivityViewController` be the solution we so desperately seek?

* * *

`UIActivityViewController`, introduced in iOS 6, provides a unified services interface for sharing and performing actions on data within an application.

Given a collection of actionable data, a `UIActivityViewController` instance is created as follows:

~~~{swift}
let string: String = ...
let URL: NSURL = ...

let activityViewController = UIActivityViewController(activityItems: [string, URL], applicationActivities: nil)
navigationController?.presentViewController(activityViewController, animated: true) {
    // ...
}
~~~

~~~{objective-c}
NSString *string = ...;
NSURL *URL = ...;

UIActivityViewController *activityViewController =
  [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                    applicationActivities:nil];
[navigationController presentViewController:activityViewController
                                      animated:YES
                                    completion:^{
  // ...
}];
~~~

This would present the following at the bottom of the screen:

![UIActivityViewController]({{ site.asseturl }}/uiactivityviewcontroller.png)

By default, `UIActivityViewController` will show all available services supporting the provided items, but certain activity types can be excluded:

~~~{swift}
activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook]
~~~

~~~{objective-c}
activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook];
~~~

Activity types are divided up into "action" and "share" types:

### UIActivityCategoryAction

- `UIActivityTypePrint`
- `UIActivityTypeCopyToPasteboard`
- `UIActivityTypeAssignToContact`
- `UIActivityTypeSaveToCameraRoll`
- `UIActivityTypeAddToReadingList`
- `UIActivityTypeAirDrop`

### UIActivityCategoryShare

- `UIActivityTypeMessage`
- `UIActivityTypeMail`
- `UIActivityTypePostToFacebook`
- `UIActivityTypePostToTwitter`
- `UIActivityTypePostToFlickr`
- `UIActivityTypePostToVimeo`
- `UIActivityTypePostToTencentWeibo`
- `UIActivityTypePostToWeibo`

Each activity type supports a number of different data types. For example, a Tweet might be composed of an `NSString`, along with an attached image and/or URL.

### Supported Data Types by Activity Type

<table>
    <thead>
        <tr>
            <th>Activity Type</th>
            <th>String</th>
            <th>Attributed String</th>
            <th>URL</th>
            <th>Data</th>
            <th>Image</th>
            <th>Asset</th>
            <th>Other</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Post To Facebook</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>Post To Twitter</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>Post To Weibo</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <td>Message</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓*</td>
            <td>✓*</td>
            <td></td>
            <td>✓*</td>
            <td><tt>sms://</tt> <tt>NSURL</tt></td>
        </tr>
        <tr>
            <td>Mail</td>
            <td>✓+</td>
            <td>✓+</td>
            <td>✓+</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>Print</td>
            <td></td>
            <td></td>
            <td></td>
            <td>✓+</td>
            <td>✓+</td>
            <td></td>
            <td><tt>UIPrintPageRenderer</tt>, <tt>UIPrintFormatter</tt>, &amp; <tt>UIPrintInfo</tt></td>
        </tr>
        <tr>
            <td>Copy To Pasteboard</td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td></td>
            <td><tt>UIColor</tt>, <tt>NSDictionary</tt></td>
        </tr>
        <tr>
            <td>Assign To Contact</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td>✓</td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>Save To Camera Roll</td>
            <td></td>
            <td></td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>Add To Reading List</td>
            <td></td>
            <td></td>
            <td>✓</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>Post To Flickr</td>
            <td></td>
            <td></td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <td>Post To Vimeo</td>
            <td></td>
            <td></td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <td>Post To Tencent Weibo</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <td>AirDrop</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
    </tbody>
</table>

## `<UIActivityItemSource>` & `UIActivityItemProvider`

Similar to how a [pasteboard item](https://developer.apple.com/library/mac/documentation/cocoa/reference/NSPasteboardItem_Class/Reference/Reference.html) can be used to provide data only when necessary, in order to avoid excessive memory allocation or processing time, activity items can be of a custom type.

Any object conforming to `<UIActivityItemSource>`, including the built-in `UIActivityItemProvider` class, can be used to dynamically provide different kinds of data depending on the activity type.

### `<UIActivityItemSource>`

#### Getting the Data Items

- `activityViewControllerPlaceholderItem:`
- `activityViewController:itemForActivityType:`

#### Providing Information About the Data Items

- `activityViewController:subjectForActivityType:`
- `activityViewController:dataTypeIdentifierForActivityType:`
- `activityViewController:thumbnailImageForActivityType:suggestedSize:`

One example of how this could be used is to customize a message, depending on whether it's to be shared on Facebook or Twitter.

~~~{swift}
func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
    if activityType == UIActivityTypePostToFacebook {
        return NSLocalizedString("Like this!", comment: "comment")
    } else if activityType == UIActivityTypePostToTwitter {
        return NSLocalizedString("Retweet this!", comment: "comment")
    } else {
        return nil
    }
}
~~~

~~~{objective-c}
- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return NSLocalizedString(@"Like this!");
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return NSLocalizedString(@"Retweet this!");
    } else {
        return nil;
    }
}
~~~

## Creating a Custom UIActivity

In addition to the aforementioned system-provided activities, its possible to create your own activity.

As an example, let's create a custom activity type that takes an image URL and applies a mustache to it using [mustache.me](http://mustache.me).

<table>
    <tr>
        <td><img alt="Jony Ive Before" src="{{ site.asseturl }}/jony-ive-unstache.png"/></td>
        <td><img alt="Jony Ive After" src="{{ site.asseturl }}/jony-ive-mustache.png"/></td>
    </tr>
    <tr>
        <td>Before</td>
        <td>After</td>
    </tr>
</table>

First, we define a [reverse-DNS identifier](http://en.wikipedia.org/wiki/Reverse_domain_name_notation) for the activity type: 

~~~{swift}
let HIPMustachifyActivityType = "com.nshipster.activity.Mustachify"
~~~

~~~{objective-c}
static NSString * const HIPMustachifyActivityType = @"com.nshipster.activity.Mustachify";
~~~

Then specify the category as `UIActivityCategoryAction` and provide a localized title & iOS version appropriate image:

~~~{swift}
// MARK: - UIActivity

override class func activityCategory() -> UIActivityCategory {
    return .Action
}

override func activityType() -> String? {
    return HIPMustachifyActivityType
}

override func activityTitle() -> String? {
    return NSLocalizedString("Mustachify", comment: "comment")
}

override func activityImage() -> UIImage? {
    if #available(iOS 7.0, *) {
        return UIImage(named: "MustachifyUIActivity7")
    } else {
        return UIImage(named: "MustachifyUIActivity")
    }
}
~~~

~~~{objective-c}
#pragma mark - UIActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    return HIPMustachifyActivityType;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Mustachify", nil);
}

- (UIImage *)activityImage {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [UIImage imageNamed:@"MustachifyUIActivity7"];
    } else {
        return [UIImage imageNamed:@"MustachifyUIActivity"];
    }
}
~~~

Next, we create a helper function, `HIPMatchingURLsInActivityItems`, which returns an array of any image URLs of the supported type.

~~~{swift}
func HIPMatchingURLsInActivityItems(activityItems: [AnyObject]) -> [AnyObject] {
    return activityItems.filter {
        if let url = $0 as? NSURL where !url.fileURL {
            return url.pathExtension?.caseInsensitiveCompare("jpg") == .OrderedSame
                || url.pathExtension?.caseInsensitiveCompare("png") == .OrderedSame
        }

        return false
    }
}
~~~

~~~{objective-c}
static NSArray * HIPMatchingURLsInActivityItems(NSArray *activityItems) {
    return [activityItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:
    ^BOOL(id item, __unused NSDictionary *bindings) {
        if ([item isKindOfClass:[NSURL class]] &&
            ![(NSURL *)item isFileURL]) {
            return [[(NSURL *)item pathExtension] caseInsensitiveCompare:@"jpg"] == NSOrderedSame ||
            [[(NSURL *)item pathExtension] caseInsensitiveCompare:@"png"] == NSOrderedSame;
        }

        return NO;
    }]];
}
~~~

This function is then used in `-canPerformWithActivityItems:` and `prepareWithActivityItems:` to get the mustachio'd image URL of the first PNG or JPEG, if any.

~~~{swift}
override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
    return HIPMatchingURLsInActivityItems(activityItems).count > 0
}

override func prepareWithActivityItems(activityItems: [AnyObject]) {
    let HIPMustachifyMeURLFormatString = "http://mustachify.me/%d?src=%@"

    if let firstMatch = HIPMatchingURLsInActivityItems(activityItems).first, mustacheType = self.mustacheType {
        imageURL = NSURL(string: String(format: HIPMustachifyMeURLFormatString, [mustacheType, firstMatch]))
    }

    // ...
}
~~~

~~~{objective-c}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return [HIPMatchingURLsInActivityItems(activityItems) count] > 0;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    static NSString * const HIPMustachifyMeURLFormatString = @"http://mustachify.me/%d?src=%@";

    self.imageURL = [NSURL URLWithString:[NSString stringWithFormat:HIPMustachifyMeURLFormatString, self.mustacheType, [HIPMatchingURLsInActivityItems(activityItems) firstObject]]];
}
~~~

Our webservice provides a variety of mustache options, which are defined in an enumeration:

~~~{swift}
enum HIPMustacheType: Int {
    case English, Horseshoe, Imperial, Chevron, Natural, Handlebar
}
~~~

~~~{objective-c}
typedef NS_ENUM(NSInteger, HIPMustacheType) {
    HIPMustacheTypeEnglish,
    HIPMustacheTypeHorseshoe,
    HIPMustacheTypeImperial,
    HIPMustacheTypeChevron,
    HIPMustacheTypeNatural,
    HIPMustacheTypeHandlebar,
};
~~~

Finally, we provide a `UIViewController` to display the image. For this example, a simple `UIWebView` controller suffices.

~~~{swift}
class HIPMustachifyWebViewController: UIViewController, UIWebViewDelegate {
    var webView: UIWebView { get }
}
~~~

~~~{objective-c}
@interface HIPMustachifyWebViewController : UIViewController <UIWebViewDelegate>
@property (readonly, nonatomic, strong) UIWebView *webView;
@end
~~~

~~~{swift}
func activityViewController() -> UIViewController {
    let webViewController = HIPMustachifyWebViewController()

    let request = NSURLRequest(URL: imageURL)
    webViewController.webView.loadRequest(request)

    return webViewController
}
~~~

~~~{objective-c}
- (UIViewController *)activityViewController {
    HIPMustachifyWebViewController *webViewController = [[HIPMustachifyWebViewController alloc] init];

    NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
    [webViewController.webView loadRequest:request];

    return webViewController;
}
~~~

To use our brand new mustache activity, we simply pass it in the `UIActivityViewController initializer`:

~~~{swift}
let mustacheActivity = HIPMustachifyActivity()
let activityViewController = UIActivityViewController(activityItems: [imageURL], applicationActivities: [mustacheActivity])
~~~

~~~{objective-c}
HIPMustachifyActivity *mustacheActivity = [[HIPMustachifyActivity alloc] init];
UIActivityViewController *activityViewController =
  [[UIActivityViewController alloc] initWithActivityItems:@[imageURL]
                                    applicationActivities:@[mustacheActivity]];
~~~

## Invoking Actions Manually

Now is a good time to be reminded that while `UIActivityViewController` allows users to perform actions of their choosing, sharing can still be invoked manually, when the occasion arises.

So for completeness, here's how one might go about performing some of these actions manually:

### Open URL

~~~{swift}
if let URL = NSURL(string: "http://nshipster.com") {
    UIApplication.sharedApplication().openURL(URL)
}
~~~

~~~{objective-c}
NSURL *URL = [NSURL URLWithString:@"http://nshipster.com"];
[[UIApplication sharedApplication] openURL:URL];
~~~

System-supported URL schemes include: `mailto:`, `tel:`, `sms:`, and `maps:`.

### Add to Safari Reading List

~~~{swift}
import SafariServices

if let URL = NSURL(string: "http://nshipster.com/uiactivityviewcontroller") {
    let _ = try? SSReadingList.defaultReadingList()?.addReadingListItemWithURL(URL,
        title: "NSHipster",
        previewText: "..."
    )
}
~~~

~~~{objective-c}
@import SafariServices;

NSURL *URL = [NSURL URLWithString:@"http://nshipster.com/uiactivityviewcontroller"];
[[SSReadingList defaultReadingList] addReadingListItemWithURL:URL
                                                        title:@"NSHipster"
                                                  previewText:@"..."
                                                        error:nil];
~~~

### Add to Saved Photos

~~~{swift}
let image: UIImage = ...
let completionTarget: AnyObject = self
let completionSelector: Selector = "didWriteToSavedPhotosAlbum"
let contextInfo: UnsafeMutablePointer<Void> = nil

UIImageWriteToSavedPhotosAlbum(image, completionTarget, completionSelector, contextInfo)
~~~

~~~{objective-c}
UIImage *image = ...;
id completionTarget = self;
SEL completionSelector = @selector(didWriteToSavedPhotosAlbum);
void *contextInfo = NULL;
UIImageWriteToSavedPhotosAlbum(image, completionTarget, completionSelector, contextInfo);
~~~

### Send SMS

~~~{swift}
import MessageUI

let messageComposeViewController = MFMessageComposeViewController()
messageComposeViewController.messageComposeDelegate = self
messageComposeViewController.recipients = ["mattt@nshipster•com"]
messageComposeViewController.body = "Lorem ipsum dolor sit amet"
navigationController?.presentViewController(messageComposeViewController, animated: true) {
    // ...
}
~~~

~~~{objective-c}
@import MessageUI;

MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
messageComposeViewController.messageComposeDelegate = self;
messageComposeViewController.recipients = @[@"mattt@nshipster•com"];
messageComposeViewController.body = @"Lorem ipsum dolor sit amet";
[navigationController presentViewController:messageComposeViewController animated:YES completion:^{
    // ...
}];
~~~

### Send Email

~~~{swift}
import MessageUI

let mailComposeViewController = MFMailComposeViewController()
mailComposeViewController.mailComposeDelegate = self
mailComposeViewController.setToRecipients(["mattt@nshipster•com"])
mailComposeViewController.setSubject("Hello")
mailComposeViewController.setMessageBody("Lorem ipsum dolor sit amet", isHTML: false)
navigationController?.presentViewController(mailComposeViewController, animated: true) {
    // ...
}
~~~

~~~{objective-c}
@import MessageUI;

MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
mailComposeViewController.mailComposeDelegate = self;
[mailComposeViewController setToRecipients:@[@"mattt@nshipster•com"]];
[mailComposeViewController setSubject:@"Hello"];
[mailComposeViewController setMessageBody:@"Lorem ipsum dolor sit amet"
                                   isHTML:NO];
[navigationController presentViewController:mailComposeViewController animated:YES completion:^{
    // ...
}];
~~~

### Post Tweet

~~~{swift}
import Social

let tweetComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
tweetComposeViewController.setInitialText("Lorem ipsum dolor sit amet.")
navigationController?.presentViewController(tweetComposeViewController, animated: true) {
    // ...
}
~~~

~~~{objective-c}
@import Social;

SLComposeViewController *tweetComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
[tweetComposeViewController setInitialText:@"Lorem ipsum dolor sit amet."];
[self.navigationController presentViewController:tweetComposeViewController
                                        animated:YES
                                      completion:^{
                                          // ...
                                      }];
~~~

## IntentKit

While all of this is impressive and useful, there is a particular lacking in the activities paradigm in iOS, when compared to the rich [Intents Model](http://developer.android.com/guide/components/intents-filters.html) found on Android.

On Android, apps can register for different intents, to indicate that they can be used for Maps, or as a Browser, and be selected as the default app for related activities, like getting directions, or bookmarking a URL.

While iOS lacks the extensible infrastructure to support this, a 3rd-party library called [IntentKit](https://github.com/intentkit/IntentKit), by [@lazerwalker](https://github.com/lazerwalker) (of [f*ingblocksyntax.com](http://goshdarnblocksyntax.com) fame), is an interesting example of how we might narrow the gap ourselves.

![IntentKit](https://raw.github.com/intentkit/IntentKit/master/example.gif)

Normally, a developer would have to do a lot of work to first, determine whether a particular app is installed, and how to construct a URL to support a particular activity.

IntentKit consolidates the logic of connecting to the most popular Web, Maps, Mail, Twitter, Facebook, and Google+ clients, in a UI similar to `UIActivityViewController`.

Anyone looking to take their sharing experience to the next level should definitely give this a look.

* * *

There is a strong argument to be made that the longterm viability of iOS as a platform depends on sharing mechanisms like `UIActivityViewController`. As the saying goes, "Information wants to be free". And anything that stands in the way of federation will ultimately lose to something that does not.

The future prospects of public [remote view controller](http://oleb.net/blog/2012/10/remote-view-controllers-in-ios-6/) APIs gives me hope for the future of sharing on iOS. For now, though, we could certainly do much worse than `UIActivityViewController`.
