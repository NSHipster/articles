---
title: UIPrintInteractionController
author: Nate Cook
category: Cocoa
excerpt: "With all the different means to comment, mark up, save, and share right at our fingertips, it's easy to overlook the value of a printed sheet of paper."
status:
    swift: 1.0
---

With all the different means to comment, mark up, save, and share right at our fingertips, it's easy to overlook the value of a printed sheet of paper.

UIKit makes it easy to print straight from a user's device with custom designs that you can adapt to both your content and the paper size.  This article will first walk through how to format your content for printing, then detail the different ways to present (or not!) the printing interface.

* * *

> The "printed" images throughout this article are taken from Apple's *Printer Simulator*. (The yellow edges represent the non-printable margins of the paper)
>
> As of Xcode 6, the printer simulator must be downloaded as part of the *[Hardware IO Tools for Xcode](https://developer.apple.com/downloads/index.action?name=hardware%20io%20tools)*.

![Download Hardware I/O Tools from Apple Developer Website ]({{ site.asseturl }}/uiprintinteractioncontroller-hardware-io-tools-download.png)

![PrintSimulator App Info]({{ site.asseturl }}/uiprintinteractioncontroller-printer-simulator-app.png)

![PrintSimulator App Load Paper]({{ site.asseturl }}/uiprintinteractioncontroller-printersimulator-load-paper.pnd.png)

* * *

At the heart of the [UIKit Printing APIs](https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Printing/Printing.html#//apple_ref/doc/uid/TP40010156-CH12-SW3) is `UIPrintInteractionController`. A shared instance of this class manages details of print jobs and configure any UI that will be presented to the user. It also provides three levels of control for the formatting of your content.

## Printing is a Job

Before we look at formatting actual content for printing, let's go through the options for configuring the print job and the print options presented to the user.

### UIPrintInfo

Print job details are set in a `UIPrintInfo` instance. You can use the following properties:

> - `jobName` _`String`_: A name for this print job. The name will be displayed in the Print Center on the device and, for some printers, on the LCD display.
> - `orientation` _`UIPrintInfoOrientation`_: Either `.Portrait` (the default) or `.Landscape`—this is ignored if what you print has an intrinsic orientation, such as a PDF.
> - `duplex` _`UIPrintInfoDuplex`_: `.None`, `.ShortEdge`, or `.LongEdge`. The short- and long-edge settings indicate how double-sided pages could be bound, while `.None` suppresses double-sided printing (though not the UI toggle for duplexing, perplexingly).
> - `outputType` _`UIPrintInfoOutputType`_: Gives UIKit a hint about the type of content you're printing. Can be any of:
>      - `.General` (default): For mixed text and graphics; allows duplexing.
>      - `.Grayscale`: Can be better than `.General` if your content includes black text only.
>      - `.Photo`: For color or black and white images; disables duplexing and favors photo media for the paper type.
>      - `.PhotoGrayscale`: Can be better than `.Photo` for grayscale-only images, depending on the printer.
> - `printerID` _`String?`_: An ID for a particular printer—you can retrieve this only *after* the user has selected a printer through the UI and save it to use as a preset for a future print job.

In addition, `UIPrintInfo` provides a `dictionaryRepresentation` property, which can be saved and used to create a new `UIPrintInfo` instance later.

### `UIPrintInteractionController` Settings

There are a handful of settings on the `UIPrintInteractionController` that you can configure before displaying the printing UI. These include:

> - `printInfo` _`UIPrintInfo`_: The aforementioned print job configuration.
> - `printPaper` _`UIPrintPaper`_: A simple type that describes the physical and printable size of a paper type; except for specialized applications, this will be handled for you by UIKit.
> - `showsNumberOfCopies` _`Bool`_: When `true`, lets the user choose the number of copies.
> - `showsPageRange` _`Bool`_: When `true`, lets the user choose a sub-range from the printed material. This only makes sense with multi-page content—it's turned off by default for images.
> - `showsPaperSelectionForLoadedPapers` _`Bool`_: When this is `true` and the selected printer has multiple paper options, the UI will let the user choose which paper to print on.

## Formatting Your Content

Through four different properties of `UIPrintInteractionController`, you can select the level of control (and complexity) you want for your content.

> 1. `printingItem` _`AnyObject!`_ or `printingItems` _`[AnyObject]!`_: At the most basic level, the controller simply takes content that is already printable (images and PDFs) and sends them to the printer.
> 2. `printFormatter` _`UIPrintFormatter`_: At the next level, you can use a `UIPrintFormatter` subclass to format content inside your application, then hand the formatter off to the `UIPrintInteractionController`. You have some control over the format, and the printing API largely takes care of the rest.
> 3. `printPageRenderer` _`UIPrintPageRenderer`_: At the highest level, you can create a custom subclass of `UIPrintPageRenderer`, combining page formatters and your own drawing routines for headers, footers, and page content.

Since Thanksgiving (my favorite holiday) is around the corner, to illustrate these properties we'll add printing to different screens of a hypothetical app for Thanksgiving recipes.

## Printing With `printItem`(`s`)

You can print pre-existing printable content by setting either the `printItem` or `printItems` property of `UIPrintInteractionController`. Images and PDFs can be given either as image data (in a `NSData`, `UIImage`, or `ALAsset` instance) or via any `NSURL` referencing something that can be loaded into an `NSData` object. To be printable, images must be in [a format that `UIImage` supports](https://developer.apple.com/library/ios/documentation/Uikit/reference/UIImage_Class/index.html#//apple_ref/doc/uid/TP40006890-CH3-SW3).

Let's walk through a very simple case: showing the UI to print an image when the user taps a button. (We'll look at alternate ways of initiating printing below.) The process will be largely the same, no matter what you're printing—configure your print info, set up the print interaction controller, and provide your content before displaying the UI:

```swift
@IBAction func print(sender: UIBarButtonItem) {
    if UIPrintInteractionController.canPrintURL(imageURL) {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = imageURL.lastPathComponent
        printInfo.outputType = .Photo

        let printController = UIPrintInteractionController.sharedPrintController()!
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = false

        printController.printingItem = imageURL

        printController.presentAnimated(true, completionHandler: nil)
    }
}
```

```objective-c
- (IBAction)print:(id)sender {
    if ([UIPrintInteractionController canPrintURL:self.imageURL]) {
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.jobName = self.imageURL.lastPathComponent;
        printInfo.outputType = UIPrintInfoOutputGeneral;

        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        printController.printInfo = printInfo;

        printController.printingItem = self.imageURL;

        [printController presentAnimated:true completionHandler: nil];
    }
}
```

Easy as pie! _(Or, in this case, sautéed Swiss chard.)_

![Print with .printingItem]({{ site.asseturl }}/uiprintinteractioncontroller-image-print.png)

> The `presentAnimated(:completionHandler:)` method is for presenting the printing UI on the **iPhone**. If printing from the **iPad**, use one of the `presentFromBarButtonItem(:animated:completionHandler:)` or
`presentFromRect(:inView:animated:completionHandler:)` methods instead.

## UIPrintFormatter

The `UIPrintFormatter` class has two subclasses that can be used to format text (`UISimpleTextPrintFormatter` and `UIMarkupTextPrintFormatter`) plus another (`UIViewPrintFormatter`) that can format the content of three views: `UITextView`, `UIWebView`, and `MKMapView`. Print formatters have a few properties that allow you to define the printed area of the page in different ways; the final print area for the formatter will be the smallest rectangle that meets the following criteria:

> - `contentInsets` _`UIEdgeInsets`_: A set of insets from the edges of the page for the entire block of content. The left and right insets are applied on every page, but the top inset is *only* applied on the first page. The bottom inset is ignored.
> - `perPageContentInsets` _`UIEdgeInsets`_ (iOS 8 only): A set of insets from the edges of the page for *every page* of formatted content.
> - `maximumContentWidth` and `maximumContentHeight` _`CGFloat`_: If specified, these can further constrain the width and height of the content area.

> Though not clearly documented by Apple, all of these values are based on 72 points per inch.

The two text-based print formatters are initialized with the text they will be formatting. `UISimpleTextPrintFormatter` can handle plain or attributed text, while `UIMarkupTextPrintFormatter` takes and renders HTML text in its `markupText` property. Let's try sending an HTML version of our Swiss chard recipe through the markup formatter:

```swift
let formatter = UIMarkupTextPrintFormatter(markupText: htmlString)
formatter.contentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72) // 1" margins

printController.printFormatter = formatter
```

```objective-c
UIMarkupTextPrintFormatter *formatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:htmlString];
formatter.contentInsets = UIEdgeInsetsMake(72, 72, 72, 72); // 1" margins

printController.printFormatter = formatter;
```

The result? A handsomely rendered HTML page:

![Print with UIMarkupTextPrintFormatter]({{ site.asseturl }}/uiprintinteractioncontroller-html-print.png)

On the other hand, to use a `UIViewPrintFormatter`, you retrieve one from the view you want to print via its `viewPrintFormatter` property. Here's a look at how the formatter does its job for each of the three supported views:

#### 1) UITextView

![Print with UITextView]({{ site.asseturl }}/uiprintinteractioncontroller-textview-print.png)

#### 2) UIWebView

![Print with UIWebView]({{ site.asseturl }}/uiprintinteractioncontroller-webview-print.png)

#### 3) MKMapView

![Print with MKMapView]({{ site.asseturl }}/uiprintinteractioncontroller-mapview-print.png)

## UIPrintPageRenderer

The built-in formatters are fine, but for the *most* control over the printed page, you can implement a subclass of `UIPrintPageRenderer`. In your subclass you can combine the print formatters we saw above with your own custom drawing routines to create terrific layouts for your app's content. Let's look at one more way of printing a recipe, this time using a page renderer to add a header and to draw the images alongside the text of the recipe.

In the initializer, we save the data that we'll need to print, then set the `headerHeight` (the header and footer drawing methods won't even be called unless you set their respective heights) and create a markup text formatter for the text of the recipe.

> Complete Objective-C and Swift source code for the following examples [is available as a gist](https://gist.github.com/mattt/bd5e48ae461848cdbd1e).

```swift
class RecipePrintPageRenderer: UIPrintPageRenderer {
    let authorName: String
    let recipe: Recipe

    init(authorName: String, recipe: Recipe) {
        self.authorName = authorName
        self.recipe = recipe
        super.init()

        self.headerHeight = 0.5 * POINTS_PER_INCH
        self.footerHeight = 0.0 // default

        let formatter = UIMarkupTextPrintFormatter(markupText: recipe.html)
        formatter.perPageContentInsets = UIEdgeInsets(top: POINTS_PER_INCH, left: POINTS_PER_INCH,
            bottom: POINTS_PER_INCH, right: POINTS_PER_INCH * 3.5)
        addPrintFormatter(formatter, startingAtPageAtIndex: 0)
    }

    // ...
}
```

```objective-c
@interface RecipePrintPageRenderer : UIPrintPageRenderer
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) Recipe *recipe;

- (id)initWithAuthorName:(NSString *)authorName
                  recipe:(Recipe *)recipe;
@end

@implementation RecipePrintPageRenderer

- (id)initWithAuthorName:(NSString *)authorName
                  recipe:(Recipe *)recipe
{
    if (self = [super init]) {
        self.authorName = authorName;
        self.recipe = recipe;

        self.headerHeight = 0.5;
        self.footerHeight = 0.0;  // default

        UIMarkupTextPrintFormatter *formatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:recipe.html];
        formatter.perPageContentInsets = UIEdgeInsetsMake(POINTS_PER_INCH, POINTS_PER_INCH, POINTS_PER_INCH, POINTS_PER_INCH * 3.5);
        [self addPrintFormatter:formatter startingAtPageAtIndex:0];
    }

    return self;
}

// ...

@end
```

> When you use one or more print formatters as part of your custom renderer (as we're doing here), UIKit queries them for the number of pages to print. If you're doing truly custom page layout, implement the `numberOfPages()` method to provide the correct value.

Next, we override `drawHeaderForPageAtIndex(:inRect:)` to draw our custom header. Unfortunately, those handy per-page content insets on print formatters are gone here, so we first need to inset the `headerRect` parameter to match my margins, then simply draw into the current graphics context. There's a similar `drawFooterForPageAtIndex(:inRect:)` method for drawing the footer.

```swift
override func drawHeaderForPageAtIndex(pageIndex: Int, var inRect headerRect: CGRect) {
    var headerInsets = UIEdgeInsets(top: CGRectGetMinY(headerRect), left: POINTS_PER_INCH, bottom: CGRectGetMaxY(paperRect) - CGRectGetMaxY(headerRect), right: POINTS_PER_INCH)
    headerRect = UIEdgeInsetsInsetRect(paperRect, headerInsets)

    // author name on left
    authorName.drawAtPointInRect(headerRect, withAttributes: nameAttributes, andAlignment: .LeftCenter)

    // page number on right
    let pageNumberString: NSString = "\(pageIndex + 1)"
    pageNumberString.drawAtPointInRect(headerRect, withAttributes: pageNumberAttributes, andAlignment: .RightCenter)
}
```

```objective-c
- (void)drawHeaderForPageAtIndex:(NSInteger)index
                          inRect:(CGRect)headerRect
{
    UIEdgeInsets headerInsets = UIEdgeInsetsMake(CGRectGetMinY(headerRect), POINTS_PER_INCH, CGRectGetMaxY(self.paperRect) - CGRectGetMaxY(headerRect), POINTS_PER_INCH);
    headerRect = UIEdgeInsetsInsetRect(self.paperRect, headerInsets);

    // author name on left
    [self.authorName drawAtPointInRect:headerRect withAttributes:self.nameAttributes andAlignment:NCStringAlignmentLeftCenter];

    // page number on right
    NSString *pageNumberString = [NSString stringWithFormat:@"%ld", index + 1];
    [pageNumberString drawAtPointInRect:headerRect withAttributes:self.pageNumberAttributes andAlignment:NCStringAlignmentRightCenter];
}
```

Lastly, let's provide an implementation of `drawContentForPageAtIndex(:inRect:)`:

```swift
override func drawContentForPageAtIndex(pageIndex: Int, inRect contentRect: CGRect) {
    if pageIndex == 0 {
        // only use rightmost two inches of contentRect
        let imagesRectWidth = POINTS_PER_INCH * 2
        let imagesRectHeight = paperRect.height - POINTS_PER_INCH - (CGRectGetMaxY(paperRect) - CGRectGetMaxY(contentRect))
        let imagesRect = CGRect(x: CGRectGetMaxX(paperRect) - imagesRectWidth - POINTS_PER_INCH, y: paperRect.origin.y + POINTS_PER_INCH, width: imagesRectWidth, height: imagesRectHeight)

        drawImages(recipe.images, inRect: imagesRect)
    }
}
```
```objective-c
- (void)drawContentForPageAtIndex:(NSInteger)pageIndex
                           inRect:(CGRect)contentRect
{
    if (pageIndex == 0) {
        // only use rightmost two inches of contentRect
        CGFloat imagesRectWidth = POINTS_PER_INCH * 2;
        CGFloat imagesRectHeight = CGRectGetHeight(self.paperRect) - POINTS_PER_INCH - (CGRectGetMaxY(self.paperRect) - CGRectGetMaxY(contentRect));
        CGRect imagesRect = CGRectMake(CGRectGetMaxX(self.paperRect) - imagesRectWidth - POINTS_PER_INCH, CGRectGetMinY(self.paperRect) + POINTS_PER_INCH, imagesRectWidth, imagesRectHeight);

        [self drawImages:self.recipe.images inRect:imagesRect];
    }
}
```

With the implementation of our custom page renderer complete, we can set an instance as the `pageRenderer` property on the print interaction controller and we're ready to print.

```swift
let renderer = RecipePrintPageRenderer(authorName: "Nate Cook", recipe: selectedRecipe)
printController.printPageRenderer = renderer
```

```objective-c
RecipePrintPageRenderer *renderer = [[RecipePrintPageRenderer alloc] initWithAuthorName:@"Nate Cook" recipe:selectedRecipe];
printController.printPageRenderer = renderer;
```

The final result is much nicer than any of the built-in formatters.

> Note that the text of the recipe is being formatted by a `UIMarkupTextPrintFormatter`, while the header and images are drawn via custom code.

![Print with UIPrintPageRenderer subclass]({{ site.asseturl }}/uiprintinteractioncontroller-renderer-print.png)

## Printing via a Share Sheet

With the tools we've learned above, adding printing capability in a share sheet is simple. Instead of using `UIPrintInteractionController` to present the printing UI, we pass off our configured `UIPrintInfo` and printing item(s), formatter, or renderer to a `UIActivityViewController`. If the user selects the *Print* button in the share sheet, the printing UI will be displayed with all our configurations intact.

```swift
@IBAction func openShareSheet() {
    let printInfo = ...
    let formatter = ...

    let activityItems = [printInfo, formatter, textView.attributedText]
    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    presentViewController(activityController, animated: true, completion: nil)
}
```

```objective-c
- (IBAction)openShareSheet:(id)sender {
    UIPrintInfo *printInfo = ...
    UISimpleTextPrintFormatter *formatter = ...

    NSArray *activityItems = @[printInfo, formatter, self.textView.attributedText];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}
```

> While `UIPrintInfo` and subclasses of `UIPrintFormatter` and `UIPrintPageRenderer` can be passed to a `UIActivityViewController` as activities, none of them seem to conform to the `UIActivityItemSource` protocol, so you'll see a (harmless) warning in your console about "Unknown activity items."

## Skipping the Printing UI

New in iOS 8 is a way to print without any presentation of the printing UI. Instead of presenting the UI each time the user presses a print button, you can provide a way for your users to select a printer somewhere in your app with the easy-to-use `UIPrinterPickerController`. It accepts an optional `UIPrinter` instance in its constructor for a pre-selection, uses the same presentation options as explained above, and has a completion handler for when the user has selected her printer:

```swift
let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: savedPrinter)
printerPicker.presentAnimated(true) {
    (printerPicker, userDidSelect, error) in

    if userDidSelect {
        self.savedPrinter = printerPicker.selectedPrinter
    }
}
```

```objective-c
UIPrinterPickerController *printPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:self.savedPrinter];
[printPicker presentAnimated:YES completionHandler:
    ^(UIPrinterPickerController *printerPicker, BOOL userDidSelect, NSError *error) {

    if (userDidSelect) {
        self.savedPrinter = printerPicker.selectedPrinter;
    }
}];
```

Now you can tell your `UIPrintInteractionController` to print directly by calling `printToPrinter(:completionHandler:)` with the saved printer instead of using one of the `present...` methods.

* * *

As one final recommendation, consider the printed page as you would any other way of interacting with your content. In the same way you scrutinize font size and weight or the contrast between elements on screen, make sure to test your print layouts *on paper*—the contrast, size, and margins should all be appropriate to the medium.
