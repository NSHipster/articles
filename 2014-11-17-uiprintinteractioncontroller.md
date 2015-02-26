---
title: UIPrintInteractionController
author: Nate Cook
category: Cocoa
translator: April Peng
excerpt: "随着各种不同方式的评论、标记、保存、分享都通过指尖的操作完成，纸质印刷品的价值很容易被人忽视。"
---

随着各种不同方式的评论、标记、保存、分享都通过指尖的操作完成，纸质印刷品的价值很容易被人忽视。

UIKit 可以很容易的把用户设备里存储的定制设计直接打印出来，并且可以兼容内容和纸张大小。本文将首先概述如何格式化你的内容以便打印，然后详细介绍呈现（或不用呈现！）打印界面的不同方式。

* * *

> 这篇文章的“打印”图像都来自苹果的 *打印机模拟器*。（黄色边表示纸张的非打印边距）

> 在 Xcode 6 上，打印机模拟器必须下载，它是*[Xcode 的硬件 IO 工具](https://developer.apple.com/downloads/index.action?name=hardware%20io%20tools)的一部分*。

![从苹果开发者网站下载硬件 I/O 工具](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-hardware-io-tools-download.png)

![PrintSimulator 应用信息](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-printer-simulator-app.png)

![PrintSimulator 应用加载说明](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-printersimulator-load-paper.pnd.png)

* * *

[UIKit 打印 APIs](https://developer.apple.com/library/ios/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Printing/Printing.html#//apple_ref/doc/uid/TP40010156-CH12-SW3) 的核心是 `UIPrintInteractionController`。这个类的一个共享实例管理着打印工作的细节和配置任何将要呈现给用户的 UI。它还为你的内容的格式提供了三个级别的控制。

## 打印一个任务

在我们看看如何格式化打印的实际内容之前，让我们先看一下配置打印任务的选项和呈现给用户的打印选项。

### UIPrintInfo

打印任务细节在 `UIPrintInfo` 实例中设置。可以使用以下属性：

> - `jobName` _`String`_：此打印任务的名称。这个名字将被显示在设备的打印中心，对于有些打印机则显示在液晶屏上。
> - `orientation` _`UIPrintInfoOrientation`_：`.Portrait` （默认值）或 `.Landscape`，如果你打印的内容有一个内置的方向值，如 PDF，这个属性将被忽略。
> - `duplex` _`UIPrintInfoDuplex`_：`.None`、`.ShortEdge` 或 `.LongEd​​ge`。short- 和 long- 的边界设置指示如何绑定双面页面，而 `.None` 不支持双面打印（这里不是 UI 切换为双面打印，令人困惑）。
> - `outputType` _`UIPrintInfoOutputType`_：给 UIKit 提供要打印内容的类型提示。可以是以下任意一个：
>      - `.General`（默认）：文本和图形混合类型；允许双面打印。
>      - `.Grayscale`：如果你的内容只包括黑色文本，那么该类型比 `.General` 更好。
>      - `.Photo`：彩色或黑白图像；禁用双面打印，更适用于图像媒体的纸张类型。
>      - `.PhotoGrayscale`：对于仅灰度的图像，根据打印机的不同，该类型可能比 `.Photo` 更好。
> - `printerID` _`String?`_：一个特定的打印机的 ID，当用户通过 UI 选择过打印机并且保存它作为未来打印预设*之后*，你才能得到这个类型。

此外，`UIPrintInfo` 还提供一个 `dictionaryRepresentation` 属性，它可以被保存并用来创建一个新的 `UIPrintInfo` 实例。

### `UIPrintInteractionController` 设置

`UIPrintInteractionController` 有一些很便捷的设置，可以在显示打印 UI 之前配置设置。包括：

> - `printInfo` _`UIPrintInfo`_：之前所述的打印任务的配置。
> - `printPaper` _`UIPrintPaper`_：纸张类型的物理和打印尺寸的一个简单的类型描述；除了专门的应用程序，这将由 UIKit 处理。
> - `showsNumberOfCopies` _`Bool`_：当值为 `true` 时，让用户选择拷贝的份数。
> - `showsPageRange` _`Bool`_：当值为 `true` 时，让用户从打印源中选择一个子范围。这只在多页内容时有用，它默认关闭了图像。
> - `showsPaperSelectionForLoadedPapers` _`Bool`_：当值为 `true` 并且所选择的打印机有多个纸张选项时，用户界面将让用户选择用于打印的纸张。

## 格式化你的内容

通过 `UIPrintInteractionController` 四个不同的属性，可以选择内容的控制（和复杂性）级别。

> 1. `printingItem` _`AnyObject!`_ 或 `printingItems` _`[AnyObject]!`_：最基本的等级，控制器只需要已经可打印（图像和 PDF 文件）的内容，并将它们发送到打印机。
> 2. `printFormatter` _`UIPrintFormatter`_：更高等级，你可以在应用程序内使用一个 `UIPrintFormatter` 的子类来对内容进行格式化，然后传给 `UIPrintInteractionController`。你已经做了一些格式化，剩下的大部分事情打印 API 会处理。
> 3. `printPageRenderer` _`UIPrintPageRenderer`_：最高级别，你可以创建 `UIPrintPageRenderer` 的一个自定义子类，结合页面格式和自己的绘图程序来绘制页眉、页脚和页面内容。

为了说明这些特性，正好感恩节（我最喜欢的节日）将至，我们将假想一个感恩节食谱的应用程序并增加打印不同页面的功能。

## 用 `printItem`(`s`) 打印

你可以通过设置 `UIPrintInteractionController` 的 `printItem` 或 `printItems` 属性打印预存的可打印内容。图像和 PDF 文件可以通过图象数据（`NSData`，`UIImage` 或 `ALAsset` 实例），或通过任何 `NSURL` 引用的东西被加载到一个 `NSData` 对象来得到。要打印，图像必须是[`UIImage` 支持的格式](https://developer.apple.com/library/ios/documentation/Uikit/reference/UIImage_Class/index.html#//apple_ref/doc/uid/TP40006890-CH3-SW3).

让我们来看一个非常简单的例子：当用户点击一个按钮时显示打印图像的 UI。（我们下面将看到初始化打印的几个方式。）这个过程是大致相同的，不管你是怎么设置的打印信息或设置打印交互控制器和显示 UI 之前提供的内容：

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

易如反掌！ _(或者应景的说，像做煎瑞士甜菜一样简单。)_

![用 .printingItem 打印](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-image-print.png)

> `presentAnimated(:completionHandler:)` 方法是在 **iPhone** 上呈现打印 UI。如果是从 **iPad** 打印，使用 `presentFromBarButtonItem(:animated:completionHandler:)` 或
`presentFromRect(:inView:animated:completionHandler:)` 方法代替。

## UIPrintFormatter

`UIPrintFormatter` 类有两个子类可用于格式化文本（`UISimpleTextPrintFormatter` 和 `UIMarkupTextPrintFormatter`） 另外还有 （`UIViewPrintFormatter`）可以格式化三种试图的内容：`UITextView`、`UIWebView` 和 `MKMapView`。打印格式化器有几个特性，让你以不同方式定义页面的打印区域；格式化器的最终打印区域将是满足以下条件的最小矩形：

> - `contentInsets` _`UIEdgeInsets`_：一个全部内容页面的边缘插图集合。左和右插图被应用在每一页上，但顶部边界则*只*应用在第一页上。底部插图将被忽略。
> - `perPageContentInsets` _`UIEdgeInsets`_（仅 iOS 8）：一个*每一页*格式化内容页面的边缘插图集。
> - `maximumContentWidth` 和 `maximumContentHeight` _`CGFloat`_：如果指定，可以进一步约束内容区域的宽度和高度。

> 虽然 Apple 的文档没有明确说明，但所有这些值都基于每英寸 72 点。

这两个基于文本的打印格式将同需要格式化的文本一起被初始化。`UISimpleTextPrintFormatter` 可以处理普通或属性文本，而 `UIMarkupTextPrintFormatter` 用其 `markupText` 属性呈现 HTML 文本。让我们尝试通过标记格式发送我们 HTML 版本的瑞士甜菜菜谱：

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

结果嘞？一个漂亮的 HTML 页面：

![用 UIMarkupTextPrintFormatter 打印](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-html-print.png)

另一方面，使用 `UIViewPrintFormatter`，你可以从 `viewPrintFormatter` 属性得到一个你想要打印的视图。下面就来看看格式化如何格式它所支持的三个视图的：

#### 1) UITextView

![打印 UITextView](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-textview-print.png)

#### 2) UIWebView

![打印 UIWebView](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-webview-print.png)

#### 3) MKMapView

![打印 MKMapView](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-mapview-print.png)

## UIPrintPageRenderer

内置的格式化都很好，但为了对打印页面实现*最好*的控制，你可以实现 `UIPrintPageRenderer` 的一个子类。在你的子类里，你可以结合我们上面看到的打印格式和你自定义的绘图函数为你的应用程序内容创建出色的布局。让我们来看看打印食谱的另一种方式，这次使用网页渲染器来添加页眉和绘制图像旁边的配方文本。

在初始化中，我们需要把打印的数据保存下来，然后设置 `headerHeight`（除非你设置各自的高度，否则页眉和页脚的绘图方法将不会被调用），并为菜谱的文字创建一个标记文本格式。

> 下面例子的完整 Objective-C 和 Swift 源代码[可以在 gist 下载](https://gist.github.com/mattt/bd5e48ae461848cdbd1e)。

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

> 当你使用一个或多个打印格式作为自定义渲染的一部分（正如我们在这里所做的一样），UIKit 会查询它们的打印页数。如果你正在做真正的自定义页面布局，可以实现 `numberOfPages()` 方法来提供正确的值。

接下来，我们重写 `drawHeaderForPageAtIndex(:inRect:)` 来绘制我们的自定义标题。遗憾的是，打印格式的那些方便的为每个页面内容设置插图的功能在这儿都没有了，所以我们首先需要插入 `headerRect` 参数来适应边距，然后简单地绘制到当前的图形上下文中。还有一个类似的 `drawFooterForPageAtIndex(:inRect:)` 方法来绘制页脚。

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

最后，让我们来实现一个 `drawContentForPageAtIndex(:inRect:)`：

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

当我们的自定义页面的渲染实现完成后，我们可以设置一个实例作为打印交互控制器上的 `pageRenderer` 属性，这样我们就可以准备进行打印了。

```swift
let renderer = RecipePrintPageRenderer(authorName: "Nate Cook", recipe: selectedRecipe)
printController.printPageRenderer = renderer
```

```objective-c
RecipePrintPageRenderer *renderer = [[RecipePrintPageRenderer alloc] initWithAuthorName:@"Nate Cook" recipe:selectedRecipe];
printController.printPageRenderer = renderer;
```

最后的结果比任何内置格式都要好得多。

> 需要注意的是菜谱的文本是由一个 `UIMarkupTextPrintFormatter` 来格式化的，然而页眉和图像则通过自定义代码绘制。

![用 UIPrintPageRenderer 子类打印](http://nshipster.s3.amazonaws.com/uiprintinteractioncontroller-renderer-print.png)

## 通过共享表单打印

有了上面这些我们已经学会了的工具，在共享表单里添加打印功能也很简单。我们把配置的 `UIPrintInfo` 和打印项目及格式来显示或渲染到 `UIActivityViewController` 来显示打印 UI，而不是使用 `UIPrintInteractionController` 来呈现。如果用户在共享表单里选择了*打印*按钮，打印界面将完好的显示我们所有的配置。

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

> 虽然 `UIPrintInfo` 以及 `UIPrintFormatter` 和 `UIPrintPageRenderer` 的子类可以作为活动传递到 `UIActivityViewController`，但他们都不符合 `UIActivityItemSource` 协议，所以你会在控制台看到一个 "Unknown activity items." 的（无害）警告。

## 跳过打印  UI

在新的 iOS 8 里，有一种方式可以在没有任何 UI 展示的情况下打印。不必在用户每次按下打印按钮时呈现 UI，你可以用好用的 `UIPrinterPickerController` 在应用程序中为你的用户在某个地方选择一台打印机提供一种方法。它的构造方法接受可选的 `UIPrinter` 实例作为一个预选，可以使用上面解释过的相同的展示选项，并且当用户选择了打印机后还有一个完成回调：

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

现在，你可以让你的 `UIPrintInteractionController` 调用 `printToPrinter(:completionHandler:)` 来使用已保存的打印机而不是调用某一个 `present...` 方法来直接打印了。

* * *

最后有一个建议，考虑到你可能会在打印页面与你的内容进行某种方式的交互。在你仔细检查字体大小和重量或是屏幕上元素之间的差异的同时，同样需要确保*在纸张上*测试你的打印布局 - 另外，大小和边距都应该最好使用适中的值。
