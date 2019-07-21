---
title: WKWebView
author: Mattt
category: Cocoa
excerpt: iOS has a complicated relationship with the web.
  And it goes back to the very inception of the platform over a decade ago.
revisions:
  "2014-08-24": Original publication
  "2018-07-25": Updated for iOS 12 and macOS Mojave
status:
  swift: 4.2
  reviewed: July 25, 2018
---

iOS has a complicated relationship with the web.
And it goes back to the very inception of the platform over a decade ago.

Although the design of the first iPhone seems like a foregone conclusion today,
the iconic touchscreen device we know and love today
was just one option on the table at the time.
Early prototypes explored the use of a physical keyboard
and a touchscreen + stylus combo,
with screen dimensions going up to 5×7".
Even the iPod click wheel was a serious contender for a time.

But perhaps the most significant early decision to be made involved software,
not hardware.

How should the iPhone run software?
Apps, like on macOS?
Or as web pages, using Safari?
That choice to fork macOS and build iPhoneOS had widespread implications
and remains a contentious decision to this day.

Consider this infamous line from Steve Jobs' WWDC 2007 keynote:

> The full Safari engine is inside of iPhone.
> And so, you can write amazing Web 2.0 and Ajax apps
> that look exactly and behave exactly like apps on the iPhone.
> And these apps can integrate perfectly with iPhone services.
> They can make a call, they can send an email,
> they can look up a location on Google Maps.

The web had long been a second-class citizen on iOS,
which is ironic since the iPhone is largely responsible
for the mobile web as it exists today.
`UIWebView` was massive and clunky and leaked memory like a sieve.
It lagged behind Mobile Safari,
unable to take advantage of its faster JavaScript and rendering engines.

However, all of this changed with the introduction of `WKWebView`
and the rest of the `WebKit` framework.

---

`WKWebView` is the centerpiece of the modern WebKit API
introduced in iOS 8 & macOS Yosemite.
It replaces `UIWebView` in UIKit and `WebView` in AppKit,
offering a consistent API across the two platforms.

Boasting responsive 60fps scrolling,
built-in gestures,
streamlined communication between app and webpage,
and the same JavaScript engine as Safari,
`WKWebView` was one of the most significant announcements at WWDC 2014.

What was once a single class and protocol with `UIWebView` & `UIWebViewDelegate`
has been factored out into 14 classes and 3 protocols in the WebKit framework.
Don't be alarmed by the huge jump in complexity, though ---
this new architecture is much cleaner,
and allows for a ton of new features.

## Migrating from UIWebView / WebView to WKWebView

`WKWebView` has been the preferred API since iOS 8.
But if your app _still_ hasn't made the switch,
be advised that
**`UIWebView` and `WebView` are formally deprecated
in iOS 12 and macOS Mojave**,
and you should update to `WKWebView` as soon as possible.

To help make that transition,
here's a comparison of the APIs of `UIWebView` and `WKWebView`:

| UIWebView                              | WKWebView                                           |
| -------------------------------------- | --------------------------------------------------- |
| `var scrollView: UIScrollView { get }` | `var scrollView: UIScrollView { get }`              |
|                                        | `var configuration: WKWebViewConfiguration { get }` |
| `var delegate: UIWebViewDelegate?`     | `var UIDelegate: WKUIDelegate?`                     |
|                                        | `var navigationDelegate: WKNavigationDelegate?`     |
|                                        | `var backForwardList: WKBackForwardList { get }`    |

### Loading

| UIWebView                                                                                                     | WKWebView                                                        |
| ------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `func loadRequest(request: URLRequest)`                                                                       | `func load(_ request: URLRequest) -> WKNavigation?`              |
| `func loadHTMLString(string: String, baseURL: URL?)`                                                          | `func loadHTMLString(_: String, baseURL: URL?) -> WKNavigation?` |
| `func loadData(_ data: Data, mimeType: String, characterEncodingName: String, baseURL: URL) -> WKNavigation?` |                                                                  |
|                                                                                                               | `var estimatedProgress: Double { get }`                          |
|                                                                                                               | `var hasOnlySecureContent: Bool { get }`                         |
| `func reload()`                                                                                               | `func reload() -> WKNavigation?`                                 |
|                                                                                                               | `func reloadFromOrigin(Any?) -> WKNavigation?`                   |
| `func stopLoading()`                                                                                          | `func stopLoading()`                                             |
| `var request: URLRequest? { get }`                                                                            |                                                                  |
|                                                                                                               | `var URL: URL? { get }`                                          |
|                                                                                                               | `var title: String? { get }`                                     |

### History

| UIWebView                        | WKWebView                                                                    |
| -------------------------------- | ---------------------------------------------------------------------------- |
|                                  | `func goToBackForwardListItem(item: WKBackForwardListItem) -> WKNavigation?` |
| `func goBack()`                  | `func goBack() -> WKNavigation?`                                             |
| `func goForward()`               | `func goForward() -> WKNavigation?`                                          |
| `var canGoBack: Bool { get }`    | `var canGoBack: Bool { get }`                                                |
| `var canGoForward: Bool { get }` | `var canGoForward: Bool { get }`                                             |
| `var loading: Bool { get }`      | `var loading: Bool { get }`                                                  |

### Javascript Evaluation

| UIWebView                                                               | WKWebView                                                                                                   |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `func stringByEvaluatingJavaScriptFromString(script: String) -> String` |                                                                                                             |
|                                                                         | `func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((AnyObject?, NSError?) -> Void)?)` |

### Miscellaneous

| UIWebView                                     | WKWebView                                       |
| --------------------------------------------- | ----------------------------------------------- |
| `var keyboardDisplayRequiresUserAction: Bool` |                                                 |
| `var scalesPageToFit: Bool`                   |                                                 |
|                                               | `var allowsBackForwardNavigationGestures: Bool` |

### Pagination

`WKWebView` currently lacks equivalent APIs for paginating content.

- `var paginationMode: UIWebPaginationMode`
- `var paginationBreakingMode: UIWebPaginationBreakingMode`
- `var pageLength: CGFloat`
- `var gapBetweenPages: CGFloat`
- `var pageCount: Int { get }`

### Refactored into `WKWebViewConfiguration`

The following properties on `UIWebView`
have been factored into a separate configuration object,
which is passed into the initializer for `WKWebView`:

- `var allowsInlineMediaPlayback: Bool`
- `var allowsAirPlayForMediaPlayback: Bool`
- `var mediaTypesRequiringUserActionForPlayback: WKAudiovisualMediaTypes`
- `var suppressesIncrementalRendering: Bool`

---

## JavaScript ↔︎ Swift Communication

One of the major improvements over `UIWebView`
is how interaction and data can be passed back and forth
between an app and its web content.

### Injecting Behavior with User Scripts

`WKUserScript` allows JavaScript behavior to be injected
at the start or end of document load.
This powerful feature allows for web content to be manipulated
in a safe and consistent way across page requests.

As a simple example,
here's how a user script can be injected
to change the background color of a web page:

```swift
let source = """
    document.body.style.background = "#777";
"""

let userScript = WKUserScript(source: source,
                              injectionTime: .atDocumentEnd,
                              forMainFrameOnly: true)

let userContentController = WKUserContentController()
userContentController.addUserScript(userScript)

let configuration = WKWebViewConfiguration()
configuration.userContentController = userContentController
self.webView = WKWebView(frame: self.view.bounds,
                         configuration: configuration)
```

When you create a `WKUserScript` object,
you provide JavaScript code to execute,
specify whether it should be injected
at the start or end of loading the document,
and whether the behavior should be used for all frames or just the main frame.
The user script is then added to a `WKUserContentController`,
which is set on the `WKWebViewConfiguration` object
passed into the initializer for `WKWebView`.

This example could easily be extended to perform more significant modifications,
such as [changing all occurrences of the phrase "the cloud" to "my butt"](https://github.com/panicsteve/cloud-to-butt).

### Message Handlers

Communication from web to app has improved significantly as well,
with the introduction of message handlers.

Like how `console.log` prints out information to the
[Safari Web Inspector](https://developer.apple.com/safari/tools/),
information from a web page can be passed back to the app by invoking:

```javascript
window.webkit.messageHandlers.<#name#>.postMessage()
```

> What's really great about this API is that JavaScript objects are
> _automatically serialized_ into native Objective-C or Swift objects.

The name of the handler is configured in `add(_:name)`,
which registers a handler conforming to the `WKScriptMessageHandler` protocol:

```swift
class NotificationScriptMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage)
    {
        print(message.body)
    }
}

let userContentController = WKUserContentController()
let handler = NotificationScriptMessageHandler()
userContentController.add(handler, name: "notification")
```

Now, when a notification comes into the app
(such as to notify the creation of a new object on the page)
that information can be passed with:

```javascript
window.webkit.messageHandlers.notification.postMessage({ body: "..." });
```

> Add User Scripts to create hooks for webpage events
> that use Message Handlers to communicate status back to the app.

The same approach can be used to scrape information
from the page for display
or analysis within the app.

For example,
if you wanted to build a browser specifically for NSHipster.com,
it could have a button that listed related articles in a popover:

```javascript
// document.location.href == "https://nshipster.com/wkwebview"
const showRelatedArticles = () => {
  let related = [];
  const elements = document.querySelectorAll("#related a");
  for (const a of elements) {
    related.push({ href: a.href, title: a.title });
  }

  window.webkit.messageHandlers.related.postMessage({ articles: related });
};
```

```swift
let js = "showRelatedArticles();"
self.webView?.evaluateJavaScript(js) { (_, error) in
    print(error)
}

// Get results in a previously-registered message handler
```

## Content Blocking Rules

Though depending on your use case,
you may be able to skip the hassle of round-trip communication with JavaScript.

As of iOS 11 and macOS High Sierra,
you can specify declarative content blocking rules for a `WKWebView`,
just like a
[Safari Content Blocker app extension](https://developer.apple.com/library/archive/documentation/Extensions/Conceptual/ContentBlockingRules/CreatingRules/CreatingRules.html).

For example,
if you wanted to [Make Medium Readable Again](https://makemediumreadable.com)
in your web view,
you could define the following rules in JSON:

```swift
let json = """
[
    {
        "trigger": {
            "if-domain": "*.medium.com"
        },
        "action": {
            "type": "css-display-none",
            "selector": ".overlay"
        }
    }
]
"""
```

Pass these rules to
`compileContentRuleList(forIdentifier:encodedContentRuleList:completionHandler:)`
and configure a web view with the resulting content rule list
in the completion handler:

```swift
WKContentRuleListStore.default()
    .compileContentRuleList(forIdentifier: "ContentBlockingRules",
                            encodedContentRuleList: json)
{ (contentRuleList, error) in
    guard let contentRuleList = contentRuleList,
        error == nil else {
        return
    }

    let configuration = WKWebViewConfiguration()
    configuration.userContentController.add(contentRuleList)

    self.webView = WKWebView(frame: self.view.bounds,
                        configuration: configuration)
}
```

By declaring rules declaratively,
WebKit can compile these operations
into bytecode that can run much more efficiently
than if you injected JavaScript to do the same thing.

In addition to hiding page elements,
you can use content blocking rules to
prevent page resources from loading (like images or scripts),
strip cookies from requests to the server,
and force a page to load securely over HTTPS.

## Snapshots

Starting in iOS 11 and macOS High Sierra,
the WebKit framework provides built-in APIs for taking screenshots of web pages.

To take a picture of your web view's visible viewport
after everything is finished loading,
implement the `webView(_:didFinish:)` delegate method
to call the `takeSnapshot(with:completionHandler:)` method like so:

```swift
func webView(_ webView: WKWebView,
            didFinish navigation: WKNavigation!)
{
    var snapshotConfiguration = WKSnapshotConfiguration()
    snapshotConfiguration.snapshotWidth = 1440

    webView.takeSnapshot(with: snapshotConfiguration) { (image, error) in
        guard let image = image,
            error == nil else {
            return
        }

        // ...
    }
}
```

Previously,
taking screenshots of a web page meant
messing around with view layers and graphics contexts.
So a clean, single method option is a welcome addition to the API.

---

`WKWebView` truly makes the web feel like a first-class citizen.
Even if you consider yourself native purist,
you may be surprised at the power and flexibility afforded by WebKit.

In fact, many of the apps you use every day rely on WebKit
to render especially tricky content.
The fact that you probably haven't noticed should be an indicator
that web views are consistent with app development best practices.
