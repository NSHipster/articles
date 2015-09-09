---
title: UIMenuController
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Mobile usability today is truly quite remarkable—especially considering how far it's come in just the last decade. What was once a clumsy technology relegated to the tech elite has now become the primary mode of computation for a significant portion of the general population."
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Mobile usability today is truly quite remarkable—especially considering how far it's come in just the last decade. What was once a clumsy technology relegated to the tech elite has now become the primary mode of computation for a significant portion of the general population.

Yet despite its advances, one can't help but feel occasionally... trapped.

All too often, there will be information on the screen that you _just can't access_. Whether its flight information stuck in a table view cell or an unlinked URL, users are forced to solve problems creatively for lack of a provided solution.

In the past, we've mentioned [localization](http://nshipster.com/nslocalizedstring) and [accessibility](http://nshipster.com/uiaccessibility) as two factors that distinguish great apps from the rest of the pack. This week, we'll add another item to that list: **Edit Actions**.

### Copy, Cut, Paste, Delete, Select

iOS 3's killer feature was undoubtedly push notifications, but the ability to copy-paste is probably a close second. For how much we use it everyday, it's difficult to imagine how we got along without it. And yet, it remains a relatively obscure feature for 3rd-party apps.

This may be due to how cumbersome it is to implement. Let's look at a simple implementation, and then dive into some specifics about the APIs. First the label itself:

~~~{swift}
class HipsterLabel : UILabel {
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return (action == "copy:")
    }
    
    // MARK: - UIResponderStandardEditActions

    override func copy(sender: AnyObject?) {
        UIPasteboard.generalPasteboard().string = text
    }    
}
~~~
~~~{objective-c}
// HipsterLabel.h
@interface HipsterLabel : UILabel
@end

// HipsterLabel.m
@implementation HipsterLabel

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    return (action == @selector(copy:));
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(id)sender {
   	[[UIPasteboard generalPasteboard] setString:self.text];
}

@end
~~~

And with that out of the way, the view controller that uses it:

~~~{swift}
override func viewDidLoad() {
	super.viewDidLoad()
	
	let label: HipsterLabel = ...
	label.userInteractionEnabled = true
	view.addSubview(label)

	let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
	label.addGestureRecognizer(gestureRecognizer)
}

// MARK: - UIGestureRecognizer

func handleLongPressGesture(recognizer: UIGestureRecognizer) {
	if let recognizerView = recognizer.view,
		recognizerSuperView = recognizerView.superview
	{
		let menuController = UIMenuController.sharedMenuController()
		menuController.setTargetRect(recognizerView.frame, inView: recognizerSuperView)
		menuController.setMenuVisible(true, animated:true)
		recognizerView.becomeFirstResponder()
	}
}
~~~
~~~{objective-c}
- (void)viewDidLoad {
	HipsterLabel *label = ...;
	label.userInteractionEnabled = YES;
    [self.view addSubview:label];

    UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [label addGestureRecognizer:gestureRecognizer];
}

#pragma mark - UIGestureRecognizer

- (void)handleLongPressGesture:(UIGestureRecognizer *)recognizer  {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [recognizer.view becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
        [menuController setMenuVisible:YES animated:YES];
    }
}
~~~

So, to recap, in order to allow a label's text to be copied, the following must happen:

- `UILabel` must be subclassed to implement `canBecomeFirstResponder` & `canPerformAction:withSender:`
- Each performable action must implement a corresponding method that interacts with `UIPasteboard`
- When instantiated by a controller, the label must have `userInteractionEnabled` set to `YES` (it is not recommended that this be hard-coded into the subclass implementation)
- A `UIGestureRecognizer` must be added to the label (else, `UIResponder` methods like `touchesBegan:withEvent:` are implemented manually in the subclass)
- In the method implementation corresponding to the gesture recognizer action, `UIMenuController` must be positioned and made visible
- Finally, the label must become first responder

If you're wondering why, _oh why_, this isn't just built into `UILabel`, well... join the club.

## `UIMenuController`

`UIMenuController` is responsible for presenting edit action menu items. Each app has its own singleton instance, `sharedMenuController`. By default, a menu controller will show commands for any methods in the `UIResponderStandardEditActions` informal protocol that the responder returns `YES` for in `canPerformAction:withSender:`.

### `UIResponderStandardEditActions`

#### Handling Copy, Cut, Delete, and Paste Commands

> Each command travels from the first responder up the responder chain until it is handled; it is ignored if no responder handles it. If a responder doesn't handle the command in the current context, it should pass it to the next responder.

> `copy:` This method is invoked when the user taps the Copy command of the editing menu. A subclass of UIResponder typically implements this method. Using the methods of the UIPasteboard class, it should convert the selection into an appropriate object (if necessary) and write that object to a pasteboard.

> `cut:` This method is invoked when the user taps the Cut command of the editing menu. A subclass of UIResponder typically implements this method. Using the methods of the UIPasteboard class, it should convert the selection into an appropriate object (if necessary) and write that object to a pasteboard. It should also remove the selected object from the user interface and, if applicable, from the application's data model.

> `delete:` This method is invoked when the user taps the Delete command of the editing menu. A subclass of UIResponder typically implements this method by removing the selected object from the user interface and, if applicable, from the application's data model. It should not write any data to the pasteboard.

> `paste:` This method is invoked when the user taps the Paste command of the editing menu. A subclass of UIResponder typically implements this method. Using the methods of the UIPasteboard class, it should read the data in the pasteboard, convert the data into an appropriate internal representation (if necessary), and display it in the user interface.

#### Handling Selection Commands

> `select:` This method is invoked when the user taps the Select command of the editing menu. This command is used for targeted selection of items in the receiving view that can be broken up into chunks. This could be, for example, words in a text view. Another example might be a view that puts lists of visible objects in multiple groups; the select: command could be implemented to select all the items in the same group as the currently selected item.

> `selectAll:` This method is invoked when the user taps the Select All command of the editing menu.

In addition to these basic editing commands, there are commands that deal with rich text editing (`toggleBoldface:`, `toggleItalics:`, and `toggleUnderline:`) and writing direction changes (`makeTextWritingDirectionLeftToLeft:` & `makeTextWritingDirectionLeftToRight:`). As these are not generally applicable outside of writing an editor, we'll just mention them in passing.

## `UIMenuItem`

With iOS 3.2, developers could now add their own commands to the menu controller. As yet unmentioned, but familiar commands like "Define" or spell check suggestions take advantage of this.

`UIMenuController` has a `menuItems` property, which is an `NSArray` of `UIMenuItem` objects. Each `UIMenuItem` object has a `title` and `action`. In order to have a menu item command display in a menu controller, the responder must implement the corresponding selector.

---

Just as a skilled coder designs software to be flexible and adaptable to unforeseen use cases, any app developer worth their salt understands the need to accommodate users with different needs from themselves.

As you develop your app, take to heart the following guidelines:

- For every control, think about what you would expect a right-click (control-click) to do if used from the desktop.
- Any time information is shown to the user, consider whether it should be copyable.
- With formatted or multi-faceted information, consider whether multiple kinds of copy commands are appropriate.
- When implementing `copy:` make sure to copy only valuable information to the pasteboard.
- For editable controls, ensure that your implementation `paste:` can handle a wide range of valid and invalid input.

If mobile is to become most things to most people, the least we can do is make our best effort to allow users to be more productive. Your thoughtful use of `UIMenuController` will not go unnoticed.
