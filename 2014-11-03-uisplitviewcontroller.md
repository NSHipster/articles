---
title: UISplitViewController
author: Natasha Murashev
category: Cocoa
excerpt: >
  Although user interface idioms have made way
  for the broader concept of size classes,
  `UISplitViewController` remains a workhorse API for writing   Universal apps.
revisions:
  "2014-11-03": Original publication
  "2018-09-26": Updated for iOS 12 and Swift 4.2
status:
  swift: 4.2
  reviewed: September 26, 2018
---

In the beginning, there was the iPhone.
And it was good.

Some years later, the iPad was introduced.
And with some adaptations, an iOS app could be made Universal
to accommodate both the iPhone and iPad in a single bundle.

For a while,
the split between the two was the _split_ itself ---
namely `UISplitViewController`.
Given a classic master-detail view controller paradigm,
an iPhone would display each on separate screens,
whereas an iPad would display both side-by-side.

But over time, the iPhone grew in size
and the distinction between phone and tablet began to blur.
Starting with the iPhone 6+,
apps running in landscape mode on the phone
had enough screen real estate to act like they were on a tablet.

Although user interface idioms have made way
for the broader concept of size classes,
`UISplitViewController` remains a workhorse API for writing Universal apps.
This week, let's take a closer look at how we can use it
to adapt our UI to a variety of screen sizes.

---

Let's start with an example of `UISplitViewController`
working its magic on a large iPhone:

<video preload="none" poster="{% asset split-view-demo.jpg @path %}" width="640" controls>
    <source src="{% asset split-view-demo.mov @path %}" type="video/quicktime"/>
</video>

However, the view doesn't split when the iPhone is in _Zoomed_ Display mode.

<video preload="none" poster="{% asset split-view-zoomed-demo.jpg @path %}" width="640" controls>
    <source src="{% asset split-view-zoomed-demo.mov @path %}" type="video/quicktime"/>
</video>

{% info do %}

You can change between Standard and Zoomed Display Mode in Settings
by going to General → Accessibility → Zoom,
enabling the Zoom option
and selecting Full Screen Zoom for Zoom Region.

{% endinfo %}

This is one instance of how split views automatically determine when to show split views.

## Split View Controller, from Start to Finish

The best way to understand how to use `UISplitViewController` works
is to show a complete example.
The source code for the example project in this post
[can be found here](https://github.com/NSHipster/UISplitViewControllerDemo).

### The Storyboard Layout

Here's an overview of what a storyboard layout looks like with a split view controller:

{% asset uisplitviewcontroller-storyboard-layout.png alt="UISplitViewController Storyboard Layout" %}

In order to _master_ this concept,
let's dive into more _detail_.

### Master / Detail

The first step to using a `UISplitViewController`
is dragging it onto the storyboard.
The next step is to specify which view controller is the <dfn>master</dfn>
and which one is the <dfn>detail</dfn>.

{% asset uisplitviewcontroller-master-detail-storyboard.png alt="UISplitViewController Master-Detail Storyboard" %}

You can do this by selecting the appropriate Relationship Segue:

{% asset uisplitviewcontroller-relationship-segue.png alt="UISplitViewController Relationship Segue" %}

The master view controller is typically the navigation controller
that contains the list view (a `UITableView` in most cases);
the detail view controller is the navigation controller
that contains the view that shows up when the user taps on the list item.

### Show Detail

There's one last part to making the split view controller work:
specifying the "Show Detail" segue.

{% asset uisplitviewcontroller-show-detail-segue.png alt="UISplitViewController Show Detail Segue" %}

In the example below,
when the user taps on a cell in the `ColorsViewController`,
they're shown a navigation controller with the `ColorViewController` at its root.

### Double Navigation Controllers‽

At this point,
you might be wondering:
_Why do the master and detail view controllers
have to be navigation controllers ---
especially when there's already a "Show Detail" segue?_.

Well, let's see what happens
when the detail view controller
doesn't have a navigation controller at its root:

{% asset uisplitviewcontroller-no-detail-navigation-controller.png alt="UISplitViewController No Detail Navigation Controller" %}

By all accounts,
the app would still work just fine.
On a large iPhone,
the only difference is the lack of a navigation bar
when the phone is in landscape mode:

{% asset uisplitviewcontroller-no-navigation-bar.png alt="UISplitViewController No Navigation Bar" %})

It's not a big deal unless want your navigation bar to show a title.
But this is a deal-breaker on an iPad:

<video preload="none" poster="{% asset ipad-split-view-no-navigation-bar.jpg @path %}" width="540" controls>
    <source src="{% asset ipad-split-view-no-navigation-bar.mov @path %}" type="video/quicktime"/>
</video>

Notice that when the iPad app first launches,
there's no indication that there's a split view controller at all!
To trigger the master view controller,
the user has to magically know to swipe left-to-right.

### Adding a Display Mode Button

To resolve this issue,
we're looking for some way to indicate that there's more to the app
than what's currently on-screen.
Luckily, `UISplitViewController` has a `displayModeButtonItem` navigation item,
which can be added to the navigation bar
to give us the visual indicator we seek:

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    <#...#>

    navigationItem.leftBarButtonItem =
        splitViewController?.displayModeButtonItem
    navigationItem.leftItemsSupplementBackButton = true
}
```

```objc
- (void)viewDidLoad {
    [super viewDidLoad];

    <#...#>

    self.navigationItem.leftBarButtonItem =
        self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
}
```

_Build and Run_ on the iPad again,
and now you get a nice indication of how access the rest of the app:

<video preload="none" poster="{% asset ipad-navigation-bar-with-button.jpg @path %}" width="540" controls>
    <source src="{% asset ipad-navigation-bar-with-button.mov @path %}" type="video/quicktime"/>
</video>

The `displayModeButtonItem` property lends some nice usability
to apps running on large iPhones in landscape mode, too:

<video preload="none" poster="{% asset iphone-displayModeButtonItem.jpg @path %}" width="640" controls>
    <source src="{% asset iphone-displayModeButtonItem.mov @path %}" type="video/quicktime"/>
</video>

By using `displayModeButtonItem`,
you let iOS figure out what's appropriate
for the current screen size and orientation.
Instead of sweating the small (and big) stuff yourself,
you can sit back and relax. 🍹

## Collapse Detail View Controller

There's one more optimization we can do for the iPhone.
When the user first launches the app,
let's make the master view controller display fully
until the user selects a list item.
We can do that using
[`UISplitViewControllerDelegate`](https://developer.apple.com/documentation/uikit/uisplitviewcontrollerdelegate):

```swift
class ColorsViewController: UITableViewController {
    var collapseDetailViewController: Bool = true

    <#...#>

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        self.collapseDetailViewController = false
    }
}

class SplitViewDelegate: NSObject, UISplitViewControllerDelegate {
    <#...#>

    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool
    {
        guard let navigationController = primaryViewController as? UINavigationController,
            let controller = navigationController.topViewController as? ColorsViewController
        else {
            return true
        }

        return controller.collapseDetailViewController
    }
}
```

```objc
// SelectColorTableViewController.h

@interface SelectColorTableViewController :
            UITableViewController <UISplitViewControllerDelegate>
@end

// SelectColorTableViewController.m

@interface SelectColorTableViewController ()
@property (nonatomic) BOOL shouldCollapseDetailViewController;
@end

@implementation SelectColorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldCollapseDetailViewController = YES;
    self.splitViewController.delegate = self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.shouldCollapseDetailViewController = NO;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
      ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return self.shouldCollapseDetailViewController;
}

@end
```

Now when the app launches on an iPhone in portrait orientation,
`ColorsViewController` is in full view.
Once the user selects a color
(or the app goes into the background),
`ColorsViewController` is collapsed again,
and `ColorViewController` is displayed:

<video preload="none" poster="{% asset iphone-primary-view-controller-rotation.jpg @path %}" width="640" controls>
    <source src="{% asset iphone-primary-view-controller-rotation.mov @path %}" type="video/quicktime"/>
</video>

---

iOS is always adapting to new capabilities from new hardware.
When retina screens were introduced,
developers could no longer assume that 1pt = 1px.
When larger iPhones were introduced,
developers could no longer assume a single screen size.

Today, we're responsible for accommodating several generations
or iPhones and iPads, as well as external displays
and various accessibility features.
This would be a nightmare if it weren't for the powerful and thoughtful APIs
provided in iOS.

`UISplitViewController` may not be the newest API on the block
when it comes to adapting to various interface conditions,
but it remains a useful tool for quickly creating robust apps.
