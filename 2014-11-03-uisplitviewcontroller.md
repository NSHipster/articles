---
title: UISplitViewController
author: Natasha Murashev
category: Cocoa
translator: April Peng
excerpt: "iPhone 6+ 的推出让 UISplitViewController 变得更为重要。现在只需一些小的调整，一个应用程序就可以兼容 iPhone 和 iPad，所有不同屏幕尺寸的大部分 UI 逻辑则将由苹果来处理。"
---

iPhone 6+ 的推出让 `UISplitViewController` 变得更为重要。现在只需一些小的调整，一个应用程序就可以兼容 iPhone 和 iPad，所有不同屏幕尺寸的大部分 UI 逻辑则将由苹果来处理

看看 `UISplitViewController` 怎样在 iPhone 6+ 上施展魔力的：

<video preload="none" src="{{ site.asseturl }}/SplitViewDemo.mov" poster="{{ site.asseturl }}/SplitViewDemo.jpg" width="640" controls/>

>注意，当 iPhone 6+ 是 _缩放_ 显示模式视图时不会分屏！（你可以在 Settings.app → Display & Brightness → View 里切换 Standard 或 Zoomed 显示模式）

<video preload="none" src="{{ site.asseturl }}/SplitViewZoomedDemo.mov" poster="{{ site.asseturl }}/SplitViewZoomedDemo.jpg" width="640" controls/>

同样，究竟在什么时候显示拆分视图的逻辑苹果都会处理。

## Storyboard 布局

这是一个带有 split view controller 的 Storyboard 的布局概览，它看起来是这样的：

![UISplitViewController Storyboard Layout]({{ site.asseturl }}/uisplitviewcontroller-storyboard-layout.png)

让我们来看看更多的细节：

### Master / Detail

使用 `UISplitViewController` 的第一步是把它拖到 storyboard 里。接下来，指定哪个视图控制器是 **Master** 哪一个是 **Detail**。

![UISplitViewController Master-Detail Storyboard ]({{ site.asseturl }}/uisplitviewcontroller-master-detail-storyboard.png)

通过选择适当的 Relationship Segue 来做：

![UISplitViewController Relationship Segue]({{ site.asseturl }}/uisplitviewcontroller-relationship-segue.png)

主视图控制器通常是包含列表视图（在大多数情况下是一个 `UITableView`）的导航控制器。详细信息视图控制器则是显示用户点击列表某项时对应的导航控制器视图。

### 显示详细内容

还有最后一个部分让拆分视图控制器真正工作：指定 "Show Detail" segue：

![UISplitViewController Show Detail Segue]({{ site.asseturl }}/uisplitviewcontroller-show-detail-segue.png)

在下面的例子中，当用户点击了 `SelectColorTableViewController` 里的一个单元格，它们会被展示在一个以 `colorviewcontroll` 为根的导航控制器中。

### 双重导航控制器？

在这一点上，你可能想知道为什么主视图控制器和详细信息视图控制器都必须是导航控制器，特别是当有一个 "Show Detail" segue 从表格视图（这是导航堆栈的一部分）连接到详细信息视图控制器。如果详细视图控制器一开始不带导航控制器呢？

![UISplitViewController No Detail Navigation Controller]({{ site.asseturl }}/uisplitviewcontroller-no-detail-navigation-controller.png)

大体来看，应用程序仍然会工作得很好。在 iPhone 6+ 上，唯一的区别是当手机在横向模式下会没有导航工具栏：

![]({{ site.asseturl }}/uisplitviewcontroller-no-navigation-bar.png)

这不是什么大不了的事，除非你想让你的导航栏显示一个标题。但在 iPad 上这最终会是致命的弱点。

<video preload="none" src="{{ site.asseturl }}/iPadSplitViewNoNavBar.mov" poster="{{ site.asseturl }}/iPadSplitViewNoNavBar.jpg" width="540" controls/>

请注意，当 iPad 应用程序第一次打开的时候，没有任何迹象表明这是一个拆分视图控制器！触发主视图控制器，用户必须奇迹般的知道要去向右滑动。

即使有导航控制器，在刚开始的时候用户界面也没有好太多（虽然能看到一个标题绝对是一个改进）：

![UISplitViewController iPad Navigation Bar No Button]({{ site.asseturl }}/uisplitviewcontroller-ipad-navigation-bar-no-button.png)

### `displayModeButtonItem`

要解决这个问题，最简单的方法是在某种程度上表明应用程序的当前屏幕上有更多的内容。幸运的是，UISplitViewController 有一个 **displayModeButtonItem**，可以被添加到导航栏：

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    // ...

    navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
    navigationItem.leftItemsSupplementBackButton = true
}
```

编译并重新在 iPad 上运行，现在用户就看到很好的指示，显示如何显示应用程序的其余部分：

<video preload="none" src="{{ site.asseturl }}/iPadNavBarWithButton.mov" poster="{{ site.asseturl }}/iPadNavBarWithButton.jpg" width="540" controls/>

`UISplitViewController` 的 `displayModeButtonItem` 在 iPhone 6+ 的横向模式下也增加了一些额外的炫酷功能：

<video preload="none" src="{{ site.asseturl }}/iPhone6PluseDisplayModeButton.mov" poster="{{ site.asseturl }}/iPhone6PluseDisplayModeButton.jpg" width="640" controls/>

通过使用 `displayModeButtonItem`，你再次让苹果来决定在不同屏幕尺寸、旋转下怎样做最合适。而不是自己辛苦的做这些小事，就可以高枕无忧了。

## 收起详细视图控制器

通过 [`UISplitViewControllerDelegate`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UISplitViewControllerDelegate_protocol/index.html)，我们还可以为 iPhone 6+ 做一个优化。

当用户第一次启动应用程序的时候，在用户选择一个列表项前，都可以让主视图控制器完全显示：

```swift
import UIKit

class SelectColorTableViewController: UITableViewController, UISplitViewControllerDelegate {
    private var collapseDetailViewController = true

    // MARK: UITableViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        splitViewController?.delegate = self
    }

    // ...

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseDetailViewController = false
    }

    // MARK: - UISplitViewControllerDelegate

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return collapseDetailViewController
    }
}
```

当用户第一次在 iPhone 6+ 上以纵向模式打开应用程序的时候，`SelectColorViewController` 被显示为主视图控制器。一旦用户选择一种颜色，或该应用进入后台，`SelectColorViewController` 被再次折叠，并显示 `ColorViewController`：

<video preload="none" src="http://nshipster.s3.amazonaws.com/iPhone6PlusPrimaryVCRotation.mov" poster="http://nshipster.s3.amazonaws.com/iPhone6PlusPrimaryVCRotation.jpg" width="640" controls/>

* * *

一定要查看一下 [`UISplitViewControllerDelegate`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UISplitViewControllerDelegate_protocol/index.html) 的文档来了解所有其他你可以用 `UISplitViewController` 来实现的花哨东西。

鉴于现在作为 iOS 开发者，我们不得不处理新的不同的设备尺寸，UISplitViewController 很快就会成为我们新的好朋友！

> 你可以[在 GitHub](https://github.com/NatashaTheRobot/UISplitViewControllerDemo) 上得到这篇文章所用项目的完整源代码。

