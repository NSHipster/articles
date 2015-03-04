---
title: UISplitViewController
author: Natasha Murashev
category: Cocoa
excerpt: "The introduction of iPhone 6+ brought on a new importance for UISplitViewController. With just a few little tweaks, an app can now become Universal, with Apple handling most of the UI logic for all the different screen sizes."
translator: April Peng
excerpt: "iPhone 6+ 的推出让 UISplitViewController 变得更为重要。现在只需一些小的调整，一个应用程序就可以兼容 iPhone 和 iPad，所有不同屏幕尺寸的大部分 UI 逻辑则将由苹果来处理。"
---

The introduction of iPhone 6+ brought on a new importance for `UISplitViewController`. With just a few little tweaks, an app can now become Universal, with Apple handling most of the UI logic for all the different screen sizes.

iPhone 6+ 的推出让 `UISplitViewController` 变得更为重要。现在只需一些小的调整，一个应用程序就可以兼容 iPhone 和 iPad，所有不同屏幕尺寸的大部分 UI 逻辑则将由苹果来处理

Check out the `UISplitViewController` doing its magic on iPhone 6+:

看看 `UISplitViewController` 怎样在 iPhone 6+ 上施展魔力的：

<video preload="none" src="http://nshipster.s3.amazonaws.com/SplitViewDemo.mov" poster="http://nshipster.s3.amazonaws.com/SplitViewDemo.jpg" width="640" controls/>

> Note that the view does not split when the iPhone 6+ is in _Zoomed_ Display mode! (You can change between Standard and Zoomed Display Mode by going to Settings.app → Display & Brightness → View)

>注意，当 iPhone 6+ 是 _Zoomed_ 显示模式视图时不会分屏！（你可以在 Settings.app → Display & Brightness → View 里切换 Standard 或 Zoomed 显示模式）

<video preload="none" src="http://nshipster.s3.amazonaws.com/SplitViewZoomedDemo.mov" poster="http://nshipster.s3.amazonaws.com/SplitViewZoomedDemo.jpg" width="640" controls/>

Again, Apple handles the logic for figuring out exactly when to show the split views.

同样，究竟在什么时候显示拆分视图的逻辑苹果都会处理。

## The Storyboard Layout

## Storyboard 布局

Here is an overview of what a storyboard layout looks like with a split view controller:

这是一个 Storyboard 的布局概览，看起来有一个拆分视图控制器：

![UISplitViewController Storyboard Layout](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-storyboard-layout.png)

Let's get into more detail:

让我们来看看更多的细节：

### Master / Detail

The first step to using a `UISplitViewController` is dragging it onto the storyboard. Next, specify which view controller is the **Master** and which one is the **Detail**.

使用 `UISplitViewController` 的第一步是把它拖到 storyboard 里。接下来，指定哪个视图控制器是 **Master** 哪一个是 **Detail**。

![UISplitViewController Master-Detail Storyboard ](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-master-detail-storyboard.png)

Do this by selecting the appropriate Relationship Segue:

通过选择适当的 Relationship Segue 来做：

![UISplitViewController Relationship Segue](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-relationship-segue.png)

The master view controller is usually the navigation controller containing the list view (a `UITableView` in most cases). The detail view controller is the Navigation Controller for the view corresponding to what shows up when the user taps on the list item.

主视图控制器通常是包含列表视图（在大多数情况下是一个 `UITableView`）的导航控制器。详细信息视图控制器则是显示用户点击列表某项时对应的导航控制器视图。

### 显示详细内容

There is one last part to making the split view controller work: specifying the "Show Detail" segue:

还有最后一个部分让拆分视图控制器真正工作：指定 "Show Detail" segue：

![UISplitViewController Show Detail Segue](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-show-detail-segue.png)

In the example below, when the user taps on a cell in the `SelectColorTableViewController`, they'll be shown a navigation controller with the `ColorViewController` at its root.

在下面的例子中，当用户点击了 `SelectColorTableViewController` 里的一个单元格，会显示一个基于 `ColorViewController` 的导航控制器的。

### 双重导航控制器？

At this point, you might be wondering why both the Master and the Detail view controllers have to be navigation controllers—especially since there is a "Show Detail" segue from a table view (which is part of the navigation stack) to the Detail view controller. What if the Detail View Controller didn't start with a Navigation Controller?

在这一点上，你可能想知道为什么主视图控制器和详细信息视图控制器都必须是导航控制器，特别是当有一个 "Show Detail" segue 从表格视图（这是导航堆栈的一部分）连接到详细信息视图控制器。如果详细视图控制器一开始不带导航控制器呢？

![UISplitViewController No Detail Navigation Controller](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-no-detail-navigation-controller.png)

By all accounts, the app would still work just fine. On an iPhone 6+, the only difference is the lack of a navigation toolbar when the phone is in landscape mode:

大体来看，应用程序仍然会工作得很好。在 iPhone 6+ 上，唯一的区别是当手机在横向模式下会没有导航工具栏：

![](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-no-navigation-bar.png)

It's not a big deal, unless you do want your navigation bar to show a title. This ends up being a deal-breaker on an iPad.

这不是什么大不了的事，除非你想让你的导航栏显示一个标题。但在 iPad 上这最终会是致命的弱点。

<video preload="none" src="http://nshipster.s3.amazonaws.com/iPadSplitViewNoNavBar.mov" poster="http://nshipster.s3.amazonaws.com/iPadSplitViewNoNavBar.jpg" width="540" controls/>

Notice that when the iPad app is first opened up, there is no indication that this is a split view controller at all! To trigger the Master view controller, the user has to magically know to swipe left to right.

请注意，当 iPad 应用程序第一次打开的时候，没有任何迹象表明这是一个拆分视图控制器！触发主视图控制器，用户必须奇迹般的知道要去向右滑动。

Even when the navigation controller is in place, the UI is not that much better at first glance (although seeing a title is definitely an improvement):

即使有导航控制器，在刚开始的时候用户界面也没有好太多（虽然能看到一个标题绝对是一个改进）：

![UISplitViewController iPad Navigation Bar No Button](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-ipad-navigation-bar-no-button.png)

### `displayModeButtonItem`

The simplest way to fix this issue would be to somehow indicate that there is more to the app than what's currently on-screen. Luckily, the UISplitViewController has a **displayModeButtonItem**, which can be added to the navigation bar:

要解决这个问题，最简单的方法是在某种程度上表明应用程序的当前屏幕上有更多的内容。幸运的是，UISplitViewController 有一个 **displayModeButtonItem**，可以被添加到导航栏：

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    // ...

    navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
    navigationItem.leftItemsSupplementBackButton = true
}
```

Build and Run on the iPad again, and now the user gets a nice indication of how to get at the rest of the app:

编译并重新在 iPad 上运行，现在用户就看到很好的指示，显示如何显示应用程序的其余部分：

<video preload="none" src="http://nshipster.s3.amazonaws.com/iPadNavBarWithButton.mov" poster="http://nshipster.s3.amazonaws.com/iPadNavBarWithButton.jpg" width="540" controls/>

`UISplitViewController`'s `displayModeButtonItem` adds a bit of extra-cool usability to the iPhone 6+ in landscape mode, too:

`UISplitViewController` 的 `displayModeButtonItem` 在 iPhone 6+ 的横向模式下也增加了一些额外的炫酷功能：

<video preload="none" src="http://nshipster.s3.amazonaws.com/iPhone6PluseDisplayModeButton.mov" poster="http://nshipster.s3.amazonaws.com/iPhone6PluseDisplayModeButton.jpg" width="640" controls/>

By using the `displayModeButtonItem`, you're once again letting Apple figure out what's appropriate for which screen sizes / rotations. Instead of sweating the small (and big) stuff yourself, you can sit back and relax.

通过使用 `displayModeButtonItem`，你再次让苹果来搞定什么是适合其屏幕的尺寸/旋转。而不是自己辛苦的做这些小事，就可以高枕无忧了。

## 收起详细视图控制器

There is one more optimization we can do for the iPhone 6+ via [`UISplitViewControllerDelegate`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UISplitViewControllerDelegate_protocol/index.html).

我们还可以为 iPhone 6+ 做一个优化，通过 [`UISplitViewControllerDelegate`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UISplitViewControllerDelegate_protocol/index.html)。

When the user first launches the app, we can make the master view controller fully displayed until the user selects a list item:

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

When the user first opens up the app on iPhone 6+ in portrait orientation, `SelectColorViewController` gets displayed as the primary view controller. Once the user selects a color or the app goes into the background, the `SelectColorViewController` gets collapsed again, and the `ColorViewController` is displayed:

当用户第一次在 iPhone 6+ 上以纵向模式打开应用程序的时候，`SelectColorViewController` 被显示为主视图控制器。一旦用户选择一种颜色，或该应用进入后台，`SelectColorViewController` 被再次折叠，并显示 `ColorViewController`：

<video preload="none" src="http://nshipster.s3.amazonaws.com/iPhone6PlusPrimaryVCRotation.mov" poster="http://nshipster.s3.amazonaws.com/iPhone6PlusPrimaryVCRotation.jpg" width="640" controls/>

* * *

Be sure to check out the [`UISplitViewControllerDelegate`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UISplitViewControllerDelegate_protocol/index.html) documentation to learn about all the other fancy things you can do with the `UISplitViewController`.

一定要查看一下 [`UISplitViewControllerDelegate`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UISplitViewControllerDelegate_protocol/index.html) 的文档来了解所有其他你可以用 `UISplitViewController` 来实现的花哨东西。

Given the new different device sizes we now have to work with as iOS developers, the UISplitViewController will soon be our new best friend!

鉴于现在作为 iOS 开发者，我们不得不处理新的不同的设备尺寸，UISplitViewController 很快就会成为我们新的好朋友！

> You can get the complete source code for the project used in this post [on GitHub](https://github.com/NatashaTheRobot/UISplitViewControllerDemo).

> 你可以[在 GitHub](https://github.com/NatashaTheRobot/UISplitViewControllerDemo) 上得到这篇文章所用项目的完整源代码。

