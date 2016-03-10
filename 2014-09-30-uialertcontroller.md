---
title: UIAlertController
author: Mattt Thompson
category: Cocoa
excerpt: "Did you know that `UIAlertView` and `UIActionSheet` (as well as their respective delegate protocols) are deprecated in iOS 8? It's true."
status:
    swift: 1.0
---

Did you know that `UIAlertView` and `UIActionSheet` (as well as their respective delegate protocols) are deprecated in iOS 8?

It's true. ⌘-click on `UIAlertView` or `UIActionSheet` in your code, and check out the top-level comment:

> `UIAlertView` is deprecated. Use `UIAlertController` with a `preferredStyle` of `UIAlertControllerStyleAlert` instead.

Wondering why Xcode didn't alert you to this change? Just read down to the next line:

```swift
@availability(iOS, introduced=2.0)
```

Although these classes are technically deprecated, this is not communicated in the `@availability` attribute. This should be of little surprise, though; `UIAlertView` has always played it fast and loose.

From its very inception, `UIAlertView` has been laden with vulgar concessions, sacrificing formality and correctness for the whims of an eager developer audience. Its `delegate` protocol conformance was commented out of its initializer (`delegate:(id /* <UIAlertViewDelegate> */)delegate`). And what protocol methods that did exist triggered when a `buttonAtIndex:` "clicked" rather than "tapped". This, and trailing variable-length arguments for `otherButtonTitles`, awkward management of button indexes, a `-show` method with no regard for the view hierarchy... the list goes on.

`UIActionSheet` was nearly as bad, though developers can't be bothered to remember what the heck that control is called half the time, much less complain about its awkward parts.

As such, the introduction of `UIAlertController` should be met like an army liberating a city from occupation. Not only does it improve on the miserable APIs of its predecessors, but it carves a path forward to deal with the UIKit interface singularity brought on by the latest class of devices.

This week's article takes a look at `UIAlertController`, showing first how to port existing alert behavior, and then how this behavior can be extended.

* * *

`UIAlertController` replaces both `UIAlertView` and `UIActionSheet`, thereby unifying the concept of alerts across the system, whether presented modally or in a popover.

Unlike the classes it replaces, `UIAlertController` is a subclass of `UIViewController`. As such, alerts now benefit from the configurable functionality provided with view controller presentation.

`UIAlertController` is initialized with a `title`, `message`, and whether it prefers to be displayed as an alert or action sheet. Alert views are presented modally in the center of their presenting view controllers, whereas action sheets are anchored to the bottom. Alerts can have both buttons and text fields, while action sheets only support buttons.

Rather than specifying all of an alert's buttons in an initializer, instances of a new class, `UIAlertAction`, are added after the fact. Refactoring the API in this way allows for greater control over the number, type, and order of buttons. It also does away with the delegate pattern favored by `UIAlertView` & `UIActionSheet` in favor of much more convenient completion handlers.

## Comparing the Old and New Ways to Alerts

### A Standard Alert

![A Standard Alert]({{ site.asseturl }}/uialertcontroller-alert-defautl-style.png)

#### The Old Way: UIAlertView

```swift
let alertView = UIAlertView(title: "Default Style", message: "A standard alert.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
alertView.alertViewStyle = .Default
alertView.show()

// MARK: UIAlertViewDelegate

func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    switch buttonIndex {
        // ...
    }
}
```

#### The New Way: UIAlertController

```swift
let alertController = UIAlertController(title: "Default Style", message: "A standard alert.", preferredStyle: .Alert)

let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
    // ...
}
alertController.addAction(cancelAction)

let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
    // ...
}
alertController.addAction(OKAction)

self.presentViewController(alertController, animated: true) {
    // ...
}
```

### A Standard Action Sheet

![A Standard Action Sheet]({{ site.asseturl }}/uialertcontroller-action-sheet-automatic-style.png)

#### UIActionSheet

```swift
let actionSheet = UIActionSheet(title: "Takes the appearance of the bottom bar if specified; otherwise, same as UIActionSheetStyleDefault.", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Destroy", otherButtonTitles: "OK")
actionSheet.actionSheetStyle = .Default
actionSheet.showInView(self.view)

// MARK: UIActionSheetDelegate

func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    switch buttonIndex {
        ...
    }
}
```

#### UIAlertController

```swift
let alertController = UIAlertController(title: nil, message: "Takes the appearance of the bottom bar if specified; otherwise, same as UIActionSheetStyleDefault.", preferredStyle: .ActionSheet)

let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
    // ...
}
alertController.addAction(cancelAction)

let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
    // ...
}
alertController.addAction(OKAction)

let destroyAction = UIAlertAction(title: "Destroy", style: .Destructive) { (action) in
    println(action)
}
alertController.addAction(destroyAction)

self.presentViewController(alertController, animated: true) {
    // ...
}
```

## New Functionality

`UIAlertController` is not just a cleanup of pre-existing APIs, it's a generalization of them. Previously, one was constrained to whatever presets were provided (swizzling in additional functionality at their own risk). With `UIAlertController`, it's possible to do a lot more out-of-the-box:

### Alert with Destructive Button

![Alert with Destructive Button]({{ site.asseturl }}/uialertcontroller-alert-cancel-destroy.png)

The type of an action is specified by `UIAlertActionStyle`, which has three values:

> - `.Default`: Apply the default style to the action’s button.
> - `.Cancel`: Apply a style that indicates the action cancels the operation and leaves things unchanged.
> - `.Destructive`: Apply a style that indicates the action might change or delete data.

So, to add a destructive action to a modal alert, just add a `UIAlertAction` with style `.Destructive`:

```swift
let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .Alert)

let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
    println(action)
}
alertController.addAction(cancelAction)

let destroyAction = UIAlertAction(title: "Destroy", style: .Destructive) { (action) in
    println(action)
}
alertController.addAction(destroyAction)

self.presentViewController(alertController, animated: true) {
    // ...
}
```

### Alert with >2 Buttons

![Alert with More Than 2 Buttons]({{ site.asseturl }}/uialertcontroller-alert-one-two-three-cancel.png)

With one or two actions, buttons in an alert are stacked horizontally. Any more than that, though, and it takes on a display characteristic closer to an action sheet:

```swift
let oneAction = UIAlertAction(title: "One", style: .Default) { (_) in }
let twoAction = UIAlertAction(title: "Two", style: .Default) { (_) in }
let threeAction = UIAlertAction(title: "Three", style: .Default) { (_) in }
let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }

alertController.addAction(oneAction)
alertController.addAction(twoAction)
alertController.addAction(threeAction)
alertController.addAction(cancelAction)
```

### Creating a Login Form

![Creating a Login Form]({{ site.asseturl }}/uialertcontroller-alert-username-password-login-forgot-password-cancel.png)

iOS 5 added the `alertViewStyle` property to `UIAlertView`, which exposed much sought-after private APIs that allowed login and password fields to be displayed in an alert, as seen in several built-in system apps.

In iOS 8, `UIAlertController` can add text fields with the `addTextFieldWithConfigurationHandler` method:

```swift
let loginAction = UIAlertAction(title: "Login", style: .Default) { (_) in
    let loginTextField = alertController.textFields![0] as UITextField
    let passwordTextField = alertController.textFields![1] as UITextField

    login(loginTextField.text, passwordTextField.text)
}
loginAction.enabled = false

let forgotPasswordAction = UIAlertAction(title: "Forgot Password", style: .Destructive) { (_) in }
let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }

alertController.addTextFieldWithConfigurationHandler { (textField) in
    textField.placeholder = "Login"

    NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
        loginAction.enabled = textField.text != ""
    }
}

alertController.addTextFieldWithConfigurationHandler { (textField) in
    textField.placeholder = "Password"
    textField.secureTextEntry = true
}

alertController.addAction(loginAction)
alertController.addAction(forgotPasswordAction)
alertController.addAction(cancelAction)
```

### Creating a Sign Up Form

![Creating a Sign Up Form]({{ site.asseturl }}/uialertcontroller-alert-sign-up.png)

`UIAlertController` goes even further to allow any number of text fields, each with the ability to be configured and customized as necessary. This makes it possible to create a fully-functional signup form in a single modal alert:

```swift
alertController.addTextFieldWithConfigurationHandler { (textField) in
    textField.placeholder = "Email"
    textField.keyboardType = .EmailAddress
}

alertController.addTextFieldWithConfigurationHandler { (textField) in
    textField.placeholder = "Password"
    textField.secureTextEntry = true
}

alertController.addTextFieldWithConfigurationHandler { (textField) in
    textField.placeholder = "Password Confirmation"
    textField.secureTextEntry = true
}
```

Though, it must be said, _caveat implementor_. Just because you _can_ implement a signup form in an alert doesn't mean you _should_. Suck it up and use a view controller, like you're supposed to.

## Caveats

Attempting to add a text field to an alert controller with style `.ActionSheet` will throw the following exception:

> Terminating app due to uncaught exception `NSInternalInconsistencyException`, reason: 'Text fields can only be added to an alert controller of style `UIAlertControllerStyleAlert`'

Likewise, attempting to add more than one `.Cancel` action to either an alert or action sheet will raise:

> Terminating app due to uncaught exception `NSInternalInconsistencyException`, reason: '`UIAlertController` can only have one action with a style of `UIAlertActionStyleCancel`'
