---
title: UIActivityViewController
author: Mattt
category: Cocoa
excerpt: >-
  iOS provides a unified interface for users to
  share and perform actions on strings, images, URLs,
  and other items within an app.
revisions:
  "2014-03-31": Original publication
  "2018-12-05": Updated for iOS 12 and Swift 4.2
status:
  swift: 4.2
  reviewed: December 5, 2018
---

On iOS,
`UIActivityViewController` provides a unified interface for users to
share and perform actions on strings, images, URLs,
and other items within an app.

You create a `UIActivityViewController`
by passing in the items you want to share
and any custom activities you want to support
(we'll show how to do that later on).
You then present that view controller as you would any other modal or popover.

```swift
let string = "Hello, world!"
let url = URL(string: "https://nshipster.com")!
let image = UIImage(named: "mustache.jpg")
let pdf = Bundle.main.url(forResource: "Q4 Projections",
                            withExtension: "pdf")

let activityViewController =
    UIActivityViewController(activityItems: [string, url, image, pdf],
                             applicationActivities: nil)

present(activityViewController, animated: true) {
    <#...#>
}
```

When you run this code
the following is presented on the screen:

{% asset uiactivityviewcontroller.png alt="UIActivityViewController" %}

By default,
`UIActivityViewController` shows all the activities available
for the items provided,
but you can exclude certain activity types
via the `excludedActivityTypes` property.

```swift
activityViewController.excludedActivityTypes = [.postToFacebook]
```

Activity types are divided up into "action" and "share" types:

- **Action** (`UIActivityCategoryAction`) activity items
  take an action on selected content,
  such as copying text to the pasteboard
  or printing an image.
- **Share** (`UIActivityCategoryShare`) activity items
  share the selected content,
  such as composing a message containing a URL
  or posting an image to Twitter.

Each activity type supports certain kinds of items.
For example,
you can post a String, URL, and / or image to Twitter,
but you can't assign a string to be the photo for a contact.

The following tables show the available activity types for each category
and their supported items:

### UIActivityCategoryAction

<table style="table-layout: auto; text-align: center;">
    <thead>
        <tr>
            <th colspan="2" rowspan="2"></th>
            <th>{% asset uiactivity-icon-string.svg %}</th>
            <th>{% asset uiactivity-icon-url.svg %}</th>
            <th>{% asset uiactivity-icon-image.svg %}</th>
            <th>{% asset uiactivity-icon-file.svg %}</th>
        </tr>
        <tr>
            <th>String</th>
            <th>URL</th>
            <th>Image</th>
            <th>Files</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>{% asset uiactivity-airDrop.png width=32 height=32 %}</th>
            <th><code>airDrop</code></th>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
        </tr>
        <tr>
            <th>{% asset uiactivity-addToReadingList.png width=32 height=32 %}</th>
            <th><code>addToReadingList</code></th>
            <td></td>
            <td>✓</td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <th>{% asset uiactivity-assignToContact.png width=32 height=32 %}</th>
            <th><code>assignToContact</code></th>
            <td></td>
            <td></td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <th>{% asset uiactivity-copyToPasteboard.png width=32 height=32 %}</th>
            <th><code>copyToPasteboard</code></th>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
        </tr>
        <tr>
            <th>{% asset uiactivity-print.png width=32 height=32 %}</th>
            <th><code>print</code></th>
            <td></td>
            <td></td>
            <td>✓</td>
            <td>✓</td>
        </tr>
        <tr>
            <th>{% asset uiactivity-saveToCameraRoll.png width=32 height=32 %}</th>
            <th><code>saveToCameraRoll</code></th>
            <td></td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
    </tbody>
</table>

### UIActivityCategoryShare

<table style="table-layout: auto; text-align: center;">
    <thead>
        <tr>
            <th colspan="2" rowspan="2"></th>
            <th>{% asset uiactivity-icon-string.svg %}</th>
            <th>{% asset uiactivity-icon-url.svg %}</th>
            <th>{% asset uiactivity-icon-image.svg %}</th>
            <th>{% asset uiactivity-icon-file.svg %}</th>
        </tr>
        <tr>
            <th>String</th>
            <th>URL</th>
            <th>Image</th>
            <th>Files</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>{% asset uiactivity-mail.png width=32 height=32 %}</th>
            <th><code>mail</code></th>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
        </tr>
        <tr>
            <th>{% asset uiactivity-message.png width=32 height=32 %}</th>
            <th><code>message</code></th>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
        </tr>
        <tr>
            <th>{% asset uiactivity-postToFacebook.png width=32 height=32 %}</th>
            <th><code>postToFacebook</code></th>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <th>{% asset uiactivity-postToFlickr.png width=32 height=32 %}</th>
            <th><code>postToFlickr</code></th>
            <td></td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <th>{% asset uiactivity-postToTencentWeibo.png width=32 height=32 %}</th>
            <th><code>postToTencentWeibo</code></th>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <th>{% asset uiactivity-postToTwitter.png width=32 height=32 %}</th>
            <th><code>postToTwitter</code></th>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <th>{% asset uiactivity-postToVimeo.png width=32 height=32 %}</th>
            <th><code>postToVimeo</code></th>
            <td></td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
        <tr>
            <th>{% asset uiactivity-postToWeibo.png width=32 height=32 %}</th>
            <th><code>postToWeibo</code></th>
            <td>✓</td>
            <td>✓</td>
            <td>✓</td>
            <td></td>
        </tr>
    </tbody>
</table>

{% info %}
`UIActivityViewController` allows users to choose how they share content.
However, as a developer,
you can access this functionality directly.
Here are the corresponding APIs for each of the system-provided activity types:

| Activity Type                                                                                                                  | Corresponding API                                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| `addToReadingList`                                                                                                             | [`SSReadingList`](https://developer.apple.com/documentation/safariservices/ssreadinglist/1621226-additem)                             |
| `assignToContact`                                                                                                              | [`CNContact`](https://developer.apple.com/documentation/contacts/cncontact)                                                           |
| `copyToPasteboard`                                                                                                             | [`UIPasteboard`](https://developer.apple.com/documentation/uikit/uipasteboard/1829417-setitems)                                       |
| `print`                                                                                                                        | [`UIPrintInteractionController`](https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/1618174-printtoprinter) |
| `saveToCameraRoll`                                                                                                             | [`UIImageWriteToSavedPhotosAlbum`](https://developer.apple.com/documentation/uikit/1619125-uiimagewritetosavedphotosalbum)            |
| `mail`                                                                                                                         | [`MFMailComposeViewController`](https://developer.apple.com/documentation/messageui/mfmailcomposeviewcontroller)                      |
| `message`                                                                                                                      | [`MFMessageComposeViewController`](https://developer.apple.com/documentation/messageui/mfmessagecomposeviewcontroller)                |
| `postToFacebook` <br/> `postToFlickr` <br/> `postToTencentWeibo` <br/> `postToTwitter` <br/> `postToVimeo` <br/> `postToWeibo` | [`SLComposeViewController`](https://developer.apple.com/documentation/social/slcomposeviewcontroller)                                 |

{% endinfo %}

## Creating a Custom UIActivity

In addition to the system-provided activities,
you can create your own activities.

As an example,
let's create a custom activity
that takes an image and applies a mustache to it via a web application.

<table style="text-align: center;">
    <tr>
        <td><img alt="Jony Ive Before" src="{% asset jony-ive-unstache.png @path %}"/></td>
        <td><img alt="Jony Ive After" src="{% asset jony-ive-mustache.png @path %}"/></td>
    </tr>
    <tr>
        <td>Before</td>
        <td>After</td>
    </tr>
</table>

### Defining a Custom Activity Type

First,
define a new activity type constant
in an extension to `UIActivity.ActivityType`,
initialized with a
[reverse-DNS identifier](https://en.wikipedia.org/wiki/Reverse_domain_name_notation).

```swift
extension UIActivity.ActivityType {
    static let mustachify =
        UIActivity.ActivityType("com.nshipster.mustachify")
}
```

### Creating a UIActivity Subclass

Next,
create a subclass of `UIActivity`
and override the default implementations of the
`activityCategory` type property
and `activityType`, `activityTitle`, and `activityImage` instance properties.

```swift
class MustachifyActivity: UIActivity {
    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return .mustachify
    }

    override var activityTitle: String? {
        return NSLocalizedString("Mustachify", comment: "activity title")
    }

    override var activityImage: UIImage? {
        return UIImage(named: "mustachify-icon")
    }

    <#...#>
}
```

### Determining Which Items are Actionable

Activities are responsible for determining
whether they can act on a given array of items
by overriding the `canPerform(withActivityItems:)` method.

Our custom activity can work if any of the items is an image,
which we identify with some fancy pattern matching on a for-in loop:

```swift
override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
    for case is UIImage in activityItems {
        return true
    }

    return false
}
```

### Preparing for Action

Once an activity has determined that it can work with the specified items,
it uses the `prepare(withActivityItems:)` method
to get ready to perform the activity.

In the case of our custom activity,
we take the PNG representation of the first image in the array of items
and store that in an instance variable:

```swift
var sourceImageData: Data?

override func prepare(withActivityItems activityItems: [Any]) {
    for case let image as UIImage in activityItems {
        self.sourceImageData = image.pngData()
        return
    }
}
```

### Performing the Activity

The `perform()` method is usually the most important part of your activity.
Because processing can take some time,
this is an asynchronous method.
However, for lack of a completion handler,
you signal that work is done by calling the `activityDidFinish(_:)` method.

But if an activity provides a view controller
(as ours will, to show the result),
UIKit presents that view controller instead of calling `perform()`,
so the work has to happen there.

Our custom activity delegates the mustachification process to a web app
using a data task sent from the shared `URLSession`.
The `mustachify(completion:)` method calls its completion handler
on the main queue with the resulting image,
or with `nil` if an error occurred in the request
or we can't create an image from the provided data.

```swift
func mustachify(completion: @escaping (UIImage?) -> Void) {
    let url = URL(string: "https://mustachify.app/")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = self.sourceImageData

    URLSession.shared.dataTask(with: request) { (data, _, error) in
        var image: UIImage?
        if error == nil, let data = data {
            image = UIImage(data: data)
        }

        DispatchQueue.main.async {
            completion(image)
        }
    }.resume()
}
```

### Showing the Results

The final step is to provide a view controller
to be presented with the result of our activity.

We override the `activityViewController` property
to return a navigation controller
containing a simple view controller that displays the image:

```swift
override var activityViewController: UIViewController? {
    let viewController = MustachifyViewController(activity: self)
    return UINavigationController(rootViewController: viewController)
}
```

When its view loads,
the view controller asks the activity to mustachify the image
and shows the result in an image view.
The "Done" button stays disabled until the image arrives.
When the user taps it,
it calls `activityDidFinish(_:)` with `true`
to indicate that the activity finished successfully,
and UIKit dismisses it.
If the image couldn't be mustachified,
it calls `activityDidFinish(_:)` with `false` to indicate failure.

```swift
class MustachifyViewController: UIViewController {
    let activity: MustachifyActivity
    let imageView = UIImageView()

    init(activity: MustachifyActivity) {
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.imageView.frame = self.view.bounds
        self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.imageView.contentMode = .scaleAspectFit
        self.view.addSubview(self.imageView)

        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .done,
                            target: self,
                            action: #selector(done))
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        self.activity.mustachify { image in
            if let image = image {
                self.imageView.image = image
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.activity.activityDidFinish(false)
            }
        }
    }

    @objc func done() {
        self.activity.activityDidFinish(true)
    }
}
```

### Providing a Custom Activity to Users

We can use our brand new mustache activity
by passing it to the `applicationActivities` parameter
in the `UIActivityViewController` initializer:

```swift
let activityViewController =
    UIActivityViewController(activityItems: [image],
                             applicationActivities: [MustachifyActivity()])

present(activityViewController, animated: true) {
    <#...#>
}
```

{% asset uiactivityviewcontroller-custom-action.png %}

---

There is a strong argument to be made that
the long-term viability of iOS as a platform
depends on sharing mechanisms like `UIActivityViewController`.

As the saying goes, _"Information wants to be free."_
Anything that stands in the way of federation is doomed to fail.
