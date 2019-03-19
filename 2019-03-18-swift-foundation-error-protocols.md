---
title: LocalizedError, RecoverableError, CustomNSError
author: Mattt
category: Cocoa
excerpt: >-
  We're all familiar with the `Error` type, 
  but have you met these related Swift Foundation error protocols?
status:
  swift: 5.0
---

Swift 2 introduced error handling by way of the
`throws`, `do`, `try` and `catch` keywords.
It was designed to work hand-in-hand with
Cocoa [error handling conventions](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ErrorHandlingCocoa/ErrorHandling/ErrorHandling.html#//apple_ref/doc/uid/TP40001806-CH201-SW1),
such that any type conforming to the `ErrorProtocol` protocol
(since renamed to `Error`)
was implicitly bridged to `NSError` and
Objective-C methods with an `NSError**` parameter,
were imported by Swift as throwing methods.

```objc
- (NSURL *)replaceItemAtURL:(NSURL *)url
                    options:(NSFileVersionReplacingOptions)options
                      error:(NSError * _Nullable *)error;
```

```swift
func replaceItem(at url: URL,
                 options: NSFileVersion.ReplacingOptions = []) throws -> URL
```

For the most part,
these changes offered a dramatic improvement over the status quo
(namely, _no error handling conventions in Swift at all_).
However, there were still a few gaps to fill
to make Swift errors fully interoperable with Objective-C types.
as described by Swift Evolution proposal
[SE-0112: "Improved NSError Bridging"](https://github.com/apple/swift-evolution/blob/master/proposals/0112-nserror-bridging.md).

Not long after these refinements landed in Swift 3,
the practice of declaring errors in enumerations
had become idiomatic.

Yet for how familiar we've all become with
`Error` (née `ErrorProtocol`),
surprisingly few of us are on a first-name basis with
the other error protocols to come out of SE-0112.
Like, when was the last time you came across `LocalizedError` in the wild?
How about `RecoverableError`?
`CustomNSError` _qu'est-ce que c'est_?

At the risk of sounding cliché,
you might say that these protocols are indeed pretty obscure,
and there's a good chance you haven't heard of them:

<dl>
<dt>`LocalizedError`</dt>
<dd>
A specialized error that provides
localized messages describing the error and why it occurred.
</dd>

<dt>`RecoverableError`</dt>
<dd>
A specialized error that may be recoverable
by presenting several potential recovery options to the user.
</dd>

<dt>`CustomNSError`</dt>
<dd>
A specialized error that provides a
domain, error code, and user-info dictionary.
</dd>
</dl>

If you haven't heard of any of these until now,
you may be wondering when when you'd ever use them.
Well, as the adage goes,
_"There's no time like the present"_.

This week on NSHipster,
we'll take a quick look at each of these Swift Foundation error protocols
and demonstrate how they can make your code ---
if not _less_ error-prone ---
than more enjoyable in its folly.

---

## Communicating Errors to the User

> Too many cooks spoil the broth.

Consider the following `Broth` type
with a nested `Error` enumeration
and an initializer that takes a number of cooks
and throws an error if that number is inadvisably large:

```swift
struct Broth {
  enum Error {
    case tooManyCooks(Int)
  }

  init(numberOfCooks: Int) throws {
    precondition(numberOfCooks > 0)
    guard numberOfCooks < <#redacted#> else {
      throw Error.tooManyCooks(numberOfCooks)
    }

    // ... proceed to make broth
  }
}
```

If an iOS app were to communicate an error
resulting from broth spoiled by multitudinous cooks,
it might do so
with by presenting a `UIAlertController`
in a `catch` statement like this:

```swift
import UIKit

class ViewController: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    do {
      self.broth = try Broth(numberOfCooks: 100)
    } catch let error as Broth.Error {
      let title: String
      let message: String

      switch error {
      case .tooManyCooks(let numberOfCooks):
        title = "Too Many Cooks (\(numberOfCooks))"
        message = """
        It's difficult to reconcile many opinions.

        Reduce the number of decision makers.
        """
      }

      let alertController =
        UIAlertController(title: title,
                  message: message,
                  preferredStyle: .alert)
      alertController.addAction(
        UIAlertAction(title: "OK",
                style: .default)
      )

      self.present(alertController, animated: true, completion: nil)
    } catch {
        // handle other errors...
    }
  }
}
```

Such an implementation, however,
is at odds with well-understood boundaries between models and controllers.
Not only does it create bloat in the controller,
and it doesn't scale to handling multiple errors
or handling errors in multiple contexts.

To reconcile these anti-patterns,
let's turn to our first Swift Foundation error protocol.

### Adopting the LocalizedError Protocol

The `LocalizedError` protocol inherits the base `Error` protocol
and adds four instance property requirements.

```swift
protocol LocalizedError : Error {
    var errorDescription: String? { get }
    var failureReason: String? { get }
    var recoverySuggestion: String? { get }
    var helpAnchor: String? { get }
}
```

These properties map 1:1 with familiar `NSError` `userInfo` keys.

| Requirement          | User Info Key                           |
| -------------------- | --------------------------------------- |
| `errorDescription`   | `NSLocalizedDescriptionKey`             |
| `failureReason`      | `NSLocalizedFailureReasonErrorKey`      |
| `recoverySuggestion` | `NSLocalizedRecoverySuggestionErrorKey` |
| `helpAnchor`         | `NSHelpAnchorErrorKey`                  |

Let's take another pass at our nested `Broth.Error` type
and see how we might refactor error communication from the controller
to instead be concerns of `LocalizedError` conformance.

```swift
import Foundation

extension Broth.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .tooManyCooks(let numberOfCooks):
            return "Too Many Cooks (\(numberOfCooks))"
        }
    }

    var failureReason: String? {
        switch self {
        case .tooManyCooks:
            return "It's difficult to reconcile many opinions."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .tooManyCooks:
            return "Reduce the number of decision makers."
        }
    }
}
```

{% info %}
Thanks to default protocol implementations,
you don't have to satisfy every requirement to adopt `LocalizedError`.
In this example, we omit the `helpAnchor` property
(which is pretty much irrelevant on iOS anyway).
{% endinfo %}

Using `switch` statements may be overkill
for a single-case enumeration such as this,
but it demonstrates a pattern that can be extended
for more complex error types.
Note also how pattern matching is used
to bind the `numberOfCooks` constant to the associated value
only when it's necessary.

Now we can

```swift
import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        do {
            try makeBroth(numberOfCooks: 100)
        } catch let error as LocalizedError {
            let title = error.errorDescription
            let message = [
                error.failureReason,
                error.recoverySuggestion
            ].compactMap { $0 }
             .joined(separator: "\n\n")

            let alertController =
                UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
            alertController.addAction(
                UIAlertAction(title: "OK",
                              style: .default)
            )

            self.present(alertController, animated: true, completion: nil)
        } catch {
            // handle other errors...
        }
    }
}
```

{% asset swift-foundation-error-uikit-alert-modal.png alt="iOS alert modal" %}

{% info %}
You could further DRY up your code
by creating a convenience initializer for `UIAlertController`.

```swift
extension UIAlertController {
  convenience init<Error>(_ error: Error,
                          preferredStyle: UIAlertController.Style)
    where Error: LocalizedError
  {
    let title = error.errorDescription
    let message = [
        error.failureReason,
        error.recoverySuggestion
    ].compactMap { $0 }
     .joined(separator: "\n\n")

    self.init(title: title,
                message: message,
                preferredStyle: .alert)
  }
}
```

{% endinfo %}

---

If that seems like a lot of work just to communicate an error to the user...
you might be onto something.

Although UIKit borrowed many great conventions and idioms from AppKit,
error handling wasn't one of them.
By taking a closer look at what was lost in translation,
we'll finally have the necessary context to understand
the two remaining error protocols to be discussed.

---

## Communicating Errors on macOS

> If at first you don't succeed, try, try again.

Communicating errors to users is significantly easier on macOS than on iOS.
For example,
you might construct and pass an `NSError` object
to the `presentError(_:)` method,
called on an `NSWindow`.

```swift
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet weak var window: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    do {
      _ = try something()
    } catch {
      window.presentError(error)
    }
  }

  func something() throws -> Never {
    let userInfo: [String: Any] = [
      NSLocalizedDescriptionKey:
        NSLocalizedString("The operation couldn’t be completed.",
                          comment: "localizedErrorDescription"),
      NSLocalizedRecoverySuggestionErrorKey:
        NSLocalizedString("If at first you don't succeed...",
                          comment: "localizedErrorRecoverSuggestion")
    ]

    throw NSError(domain: "com.nshipster.error", code: 1, userInfo: userInfo)
  }
}
```

Doing so presents a modal alert dialog
that fits right in with the rest of the system.

{% asset swift-foundation-error-appkit-default-modal.png alt="Default macOS error modal" %}

But macOS error handling isn't merely a matter of convenient APIs;
it also has built-in mechanisms for allowing
users to select one of several options
to attempt to resolve the reported issue.

### Recovering from Errors

To turn a conventional `NSError` into
one that supports recovery,
you specify values for the `userInfo` keys
`NSLocalizedRecoveryOptionsErrorKey` and `NSRecoveryAttempterErrorKey`.
A great way to do that
is to override the `application(_:willPresentError:)` delegate method
and intercept and modify an error before it's presented to the user.

```swift
extension AppDelegate {
  func application(_ application: NSApplication,
           willPresentError error: Error) -> Error
  {
    var userInfo: [String: Any] = (error as NSError).userInfo
    userInfo[NSLocalizedRecoveryOptionsErrorKey] =  [
      NSLocalizedString("Try, try again",
                        comment: "tryAgain")
      NSLocalizedString("Give up too easily",
                        comment: "giveUp")
    ]
    userInfo[NSRecoveryAttempterErrorKey] = self

    return NSError(domain: (error as NSError).domain,
                   code: (error as NSError).code,
                   userInfo: userInfo)
  }
}
```

For `NSLocalizedRecoveryOptionsErrorKey`,
specify an array of one or more localized strings
for each recovery option available the user.

For `NSRecoveryAttempterErrorKey`,
set an object that implements the
`attemptRecovery(fromError:optionIndex:)` method.

```swift
extension AppDelegate {
  // MARK: NSErrorRecoveryAttempting
  override func attemptRecovery(fromError error: Error,
                  optionIndex recoveryOptionIndex: Int) -> Bool
  {
    do {
      switch recoveryOptionIndex {
      case 0: // Try, try again
        try something()
      case 1:
        fallthrough
      default:
        break
      }
    } catch {
      window.presentError(error)
    }

    return true
  }
}
```

With just a few lines of code,
you're able to facilitate a remarkably complex interaction,
whereby a user is alerted to an error and prompted to resolve it
according to a set of available options.

{% asset swift-foundation-error-appkit-fixed-modal.png alt="Recoverable macOS error modal" %}

Cool as that is,
it carries some pretty gross baggage.
First,
the `attemptRecovery` requirement is part of an
<dfn>informal protocol</dfn>,
which is effectively a handshake agreement
that things will work as advertised.
Second,
the use of option indexes instead of actual objects
makes for code that's as fragile as it is cumbersome to write.

Fortunately,
we can significantly improve on this
by taking advantage of Swift's superior type system
and (at long last) the second subject of this article.

### Modernizing Error Recovery with RecoverableError

The `RecoverableError` protocol,
like `LocalizedError` is a refinement on the base `Error` protocol
with the following requirements:

```swift
protocol RecoverableError : Error {
    var recoveryOptions: [String] { get }

    func attemptRecovery(optionIndex recoveryOptionIndex: Int, resultHandler handler: @escaping (Bool) -> Void)
    func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool
}
```

Also like `LocalizedError`,
these requirements map onto error `userInfo` keys
(albeit not as directly).

| Requirement                                                             | User Info Key                               |
| ----------------------------------------------------------------------- | ------------------------------------------- |
| `recoveryOptions`                                                       | `NSLocalizedRecoveryOptionsErrorKey`        |
| `attemptRecovery(optionIndex:_:)` <br/> `attemptRecovery(optionIndex:)` | `NSRecoveryAttempterErrorKey` <sup>\*</sup> |

The `recoveryOptions` property requirement
is equivalent to the `NSLocalizedRecoveryOptionsErrorKey`:
an array of strings that describe the available options.

The `attemptRecovery` functions
formalize the previously informal delegate protocol;
`func attemptRecovery(optionIndex:)`
is for "application" granularity,
whereas
`attemptRecovery(optionIndex:resultHandler:)`
is for "document" granularity.

### Supplementing RecoverableError with Additional Types

On its own,
the `RecoverableError` protocol improves only slightly on
the traditional, `NSError`-based methodology
by formalizing the requirements for recovery.

Rather than implementing conforming types individually,
we can generalize the functionality
with some clever use of generics.

First,
define an `ErrorRecoveryDelegate` protocol
that re-casts the `attemptRecovery` methods from before
to use an associated, `RecoveryOption` type.

```swift
protocol ErrorRecoveryDelegate: class {
    associatedtype RecoveryOption: CustomStringConvertible,
                                   CaseIterable

    func attemptRecovery(from error: Error,
                         with option: RecoveryOption) -> Bool
}
```

Requiring that `RecoveryOption` conforms to `CaseIterable`,
allows us to vend options directly to API consumers
independently of their presentation to the user.

From here,
we can define a generic `DelegatingRecoverableError` type
that wraps an `Error` type
and associates it with the aforementioned `Delegate`,
which is responsible for providing recovery options
and attempting recovery with the one selected.

```swift
struct DelegatingRecoverableError<Delegate, Error>: RecoverableError
  where Delegate: ErrorRecoveryDelegate,
        Error: Swift.Error
{
  let error: Error
  weak var delegate: Delegate? = nil

  init(recoveringFrom error: Error, with delegate: Delegate?) {
    self.error = error
    self.delegate = delegate
  }

  var recoveryOptions: [String] {
    return Delegate.RecoveryOption.allCases.map { "\($0)" }
  }

  func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
    let recoveryOptions = Delegate.RecoveryOption.allCases
    let index = recoveryOptions.index(recoveryOptions.startIndex,
                                      offsetBy: recoveryOptionIndex)
    let option = Delegate.RecoveryOption.allCases[index]

    return self.delegate?.attemptRecovery(from: self.error,
                                          with: option) ?? false
  }
}
```

Now we can refactor the previous example of our macOS app
to have `AppDelegate` conform to `ErrorRecoveryDelegate`
and define a nested `RecoveryOption` enumeration
with all of the options we wish to support.

```swift
extension AppDelegate: ErrorRecoveryDelegate {
  enum RecoveryOption: String, CaseIterable, CustomStringConvertible {
    case tryAgain
    case giveUp

    var description: String {
      switch self {
      case .tryAgain:
        return NSLocalizedString("Try, try again",
                     comment: self.rawValue)
      case .giveUp:
        return NSLocalizedString("Give up too easily",
                     comment: self.rawValue)
      }
    }
  }

  func attemptRecovery(from error: Error,
             with option: RecoveryOption) -> Bool
  {
    do {
      if option == .tryAgain {
        try something()
      }
    } catch {
      window.presentError(error)
    }

    return true
  }

  func application(_ application: NSApplication, willPresentError error: Error) -> Error {
    return DelegatingRecoverableError(recoveringFrom: error, with: self)
  }
}
```

The result?

{% asset swift-foundation-error-appkit-unrefined-modal.png alt="Recoverable macOS error modal with Unintelligible title" %}

_...wait, that's not right._

What's missing?
To find out,
let's look at our third and final protocol in our discussion.

## Improving Interoperability with Cocoa Error Handling System

The `CustomNSError` protocol
is like an inverted `NSError`:
it allows a type conforming to `Error`
to act like it was instead an `NSError` subclass.

```swift
protocol CustomNSError: Error {
    static var errorDomain: String { get }
    var errorCode: Int { get }
    var errorUserInfo: [String : Any] { get }
}
```

The protocol requirements correspond to the
`domain`, `code`, and `userInfo` properties of an `NSError`, respectively.

Now, back to our modal from before:
normally, the title is taken from `userInfo` via `NSLocalizedDescriptionKey`.
Types conforming to `LocalizedError` can provide this too
through their equivalent `errorDescription` property.
And while we _could_ extend `DelegatingRecoverableError`
to adopt `LocalizedError`,
it's actually much less work to add conformance for `CustomNSError`:

```swift
extension DelegatingRecoverableError: CustomNSError {
  var errorUserInfo: [String: Any] {
    return (self.error as NSError).userInfo
  }
}
```

With this one additional step,
we can now enjoy the fruits of our burden.

{% asset swift-foundation-error-appkit-fixed-modal.png alt="Recoverable macOS error modal" %}

{% info %}

For extra credit,
you can provide an implementation for the static `errorDomain` requirement
through a conditional extension on `DelegatingRecoverableError`
whose constrained `Error` type is itself `CustomNSError` (or an `NSError`).

```swift
extension DelegatingRecoverableError where Error: CustomNSError {
  static var errorDomain: String {
    return Error.errorDomain
  }
}
```

{% endinfo %}

---

In programming,
it's often not what you know,
but what you know _about_.
Now that you're aware of the existence of
`LocalizedError`, `RecoverableError`, `CustomNSError`,
you'll be sure to identify situations in which they might
improve error handling in your app.

Useful AF, amiright?
Then again,
_"Familiarity breeds contempt"_;
so often,
what initially endears one to ourselves
is what ultimately causes us to revile it.

Such is the error of our ways.
