---
layout: post
title: UISplitViewController
author: Natasha Murashev
category: Cocoa
excerpt: "The introduction of iPhone 6+ brought on a new importance for UISplitViewController. With just a few little tweaks, an app can now become Universal, with Apple handling most of the UI logic for all the different screen sizes."
---

The introduction of iPhone 6+ brought on a new importance for `UISplitViewController`. With just a few little tweaks, an app can now become Universal, with Apple handling most of the UI logic for all the different screen sizes.

Check out the `UISplitViewController` doing its magic on iPhone 6+:

<video src="https://s3.amazonaws.com/uisplitviewcontroller/SplitViewDemo.mov" width="640" controls/>

> Note that the view does not split when the iPhone 6+ is in _Zoomed_ Display mode! (You can change between Standard and Zoomed Display Mode by going to Settings.app → Display & Brightness → View)

<video src="https://s3.amazonaws.com/uisplitviewcontroller/SplitViewZoomedDemo.mov" width="640" controls/>

Again, Apple handles the logic for figuring out exactly when to show the split views.

## The Storyboard Layout

Here is an overview of what a storyboard layout looks like with a split view controller:

![UISplitViewController Storyboard Layout](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-storyboard-layout.png)

Let's get into more detail:

### Master / Detail

The first step to using a `UISplitViewController` is dragging it onto the storyboard. Next, specify which view controller is the **Master** and which one is the **Detail**.

![UISplitViewController Master-Detail Storyboard ](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-master-detail-storyboard.png)

Do this by selecting the appropriate Relationship Segue:

![UISplitViewController Relationship Segue](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-relationship-segue.png)

The Master view controller is usually the navigation controller containing the list view (a `UITableView` in most cases). The Detail view controller is the Navigation Controller for the view corresponding to what shows up when the user taps on the list item.

### Show Detail

There is one last part to making the split view controller work: specifying the "Show Detail" segue:

![UISplitViewController Show Detail Segue](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-show-detail-segue.png)

In the example below, when the user taps on a cell in the `SelectColorTableViewController`, they'll be shown a navigation controller with the `ColorViewController` at its root.

### Double Navigation Controllers‽

At this point, you might be wondering why both the Master and the Detail view controllers have to be navigation controllers—especially since there is a "Show Detail" segue from a table view (which is part of the navigation stack) to the Detail view controller. What if the Detail View Controller didn't start with a Navigation Controller?

![UISplitViewController No Detail Navigation Controller](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-no-detail-navigation-controller.png)

By all accounts, the app would still work just fine. On an iPhone 6+, the only difference is the lack of a navigation toolbar when the phone is in landscape mode:

![](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-no-navigation-bar.png)

It's not a big deal, unless you do want your navigation bar to show a title. This ends up being a deal-breaker on an iPad.

<video src="https://s3.amazonaws.com/uisplitviewcontroller/iPadSplitViewNoNavBar.mov" width="640" controls/>

Notice that when the iPad app is first opened up, there is no indication that this is a split view controller at all! To trigger the Master view controller, the user has to magically know to swipe left to right.

Even when the navigation controller is in place, the UI is not that much better at first glance (although seeing a title is definitely an improvement):

![UISplitViewController iPad Navigation Bar No Button](http://nshipster.s3.amazonaws.com/uisplitviewcontroller-ipad-navigation-bar-no-button.png)

### displayModeButtonItem

The simplest way to fix this issue would be to somehow indicate that there is more to the app than what's currently on-screen. Luckily, the UISplitViewController has a **displayModeButtonItem**, which can be added to the navigation bar:

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    // ...

    navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
    navigationItem.leftItemsSupplementBackButton = true
}
```

Build and Run on the iPad again, and now the user gets a nice indication of how to get at the rest of the app:

<video src="https://s3.amazonaws.com/uisplitviewcontroller/iPadNavBarWithButton.mov" width="640" controls/>

`UISplitViewController`'s `displayModeButtonItem` adds a bit of extra-cool usability to the iPhone 6+ in Landscape mode, too:

<video src="https://s3.amazonaws.com/uisplitviewcontroller/iPhone6PluseDisplayModeButton.mov" width="640" controls/>

By using the `displayModeButtonItem`, you're once again letting Apple figure out what's appropriate for which screen sizes / rotations. Instead of sweating the small (and big) stuff yourself, you can sit back and relax.

## Collapse Detail View Controller

There is one more optimization we can do for the iPhone 6+ via [`UISplitViewControllerDelegate`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UISplitViewControllerDelegate_protocol/index.html).

When the user first launches the app, we can make the Master view controller fully displayed until the user selects a list item:

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

<video src="https://s3.amazonaws.com/uisplitviewcontroller/iPhone6PlusPrimaryVCRotation.mp4" width="640" controls/>

* * *

Be sure to check out the [`UISplitViewControllerDelegate`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UISplitViewControllerDelegate_protocol/index.html) documentation to learn about all the other fancy things you can do with the `UISplitViewController`.

Given the new different device sizes we now have to work with as iOS developers, the UISplitViewController will soon have to become our new best friend!

> You can get the complete source code for the project used in this post [on Github](https://github.com/NatashaTheRobot/UISplitViewControllerDemo).
