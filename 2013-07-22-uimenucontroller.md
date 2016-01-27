---
title: UIMenuController
author: Mattt Thompson
translator: Chester Liu
category: Cocoa
tags: nshipster
excerpt: "Mobile usability today is truly quite remarkable—especially considering how far it's come in just the last decade. What was once a clumsy technology relegated to the tech elite has now become the primary mode of computation for a significant portion of the general population."
excerpt: "移动可用性在当今是一个十分引入注目的领域，特别是考虑到在过去短短的十年时间中它所经历的巨大变革。曾经只有科技精英才能把玩的复杂技术，如今已经飞入寻常百姓家，成为了大部分人使用计算设备的主要形式。"
status:
    swift: 2.0
    reviewed: September 8, 2015
---

Mobile usability today is truly quite remarkable—especially considering how far it's come in just the last decade. What was once a clumsy technology relegated to the tech elite has now become the primary mode of computation for a significant portion of the general population.

移动可用性在当今是一个十分引入注目的领域，特别是考虑到在过去短短的十年时间中它所经历的巨大变革。曾经只有科技精英才能把玩的复杂技术，如今已经飞入寻常百姓家，成为了大部分人使用计算设备的主要形式。

Yet despite its advances, one can't help but feel occasionally... trapped.

尽管移动可用性得到了长足的发展，有些时候，我们还是不经意的会感觉...受到了某些限制。

All too often, there will be information on the screen that you _just can't access_. Whether its flight information stuck in a table view cell or an unlinked URL, users are forced to solve problems creatively for lack of a provided solution.

总有些时候，屏幕上出现了一些信息，但是你_就是不能使用_。不管是 table view cell 里的航班信息，还是一个没有被链接的 URL，用户在这种时候只能被迫去发挥想象力，因为没有现成的方案供他们使用。

In the past, we've mentioned [localization](http://nshipster.com/nslocalizedstring) and [accessibility](http://nshipster.com/uiaccessibility) as two factors that distinguish great apps from the rest of the pack. This week, we'll add another item to that list: **Edit Actions**.

过去的文章中，我们提到过[国际化（localization）](http://nshipster.com/nslocalizedstring)和[辅助功能（accessibility）
](http://nshipster.com/uiaccessibility)支持是把高品质应用和其他应用所区分开的两个特性，这周我们再往这个名单里添加一项：**编辑操作**。

### Copy, Cut, Paste, Delete, Select

### 复制，剪切，粘贴，删除，选择

iOS 3's killer feature was undoubtedly push notifications, but the ability to copy-paste is probably a close second. For how much we use it everyday, it's difficult to imagine how we got along without it. And yet, it remains a relatively obscure feature for 3rd-party apps.

iOS 3 的杀手特性毫无疑问是推送通知，然而支持复制-粘贴的重要性可能并不比它要差。复制-粘贴作为一个我们几乎每天都要使用的功能，很难相信离开了它是怎样一种场景。但是，在第三方应用中，这个特性的支持仍然显得有些不清晰。

This may be due to how cumbersome it is to implement. Let's look at a simple implementation, and then dive into some specifics about the APIs. First the label itself:

一个可能的原因是，它的实现很繁琐。让我们先看一个简单的实现，然后在深入研究 API 的细节。首先，是 label 本身：

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

有了这些之后，在视图控制器中使用它：

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

总结一下，为了能够支持复制一个 label 中的文字，需要完成下面几步：

- `UILabel` must be subclassed to implement `canBecomeFirstResponder` & `canPerformAction:withSender:`
- Each performable action must implement a corresponding method that interacts with `UIPasteboard`
- When instantiated by a controller, the label must have `userInteractionEnabled` set to `YES` (it is not recommended that this be hard-coded into the subclass implementation)
- A `UIGestureRecognizer` must be added to the label (else, `UIResponder` methods like `touchesBegan:withEvent:` are implemented manually in the subclass)
- In the method implementation corresponding to the gesture recognizer action, `UIMenuController` must be positioned and made visible
- Finally, the label must become first responder

- 必须要继承 `UILabel`，并且在子类中实现 `canBecomeFirstResponder` 和 `canPerformAction:withSender:` 方法
- 每个可以执行的操作，都要实现一个对应的方法，并且在方法中和 `UIPasteboard` 进行交互
- 当在控制器中被初始化时，label 必须把 `userInteractionEnabled` 属性设置为 `YES`（不推荐把这个操作硬编码到子类的实现中）
- label 中必须添加一个 `UIGestureRecognizer`（或者手动在子类中实现 `UIResponder` 的方法，例如 `touchesBegan:withEvent:`）
- 在响应手势识别事件的函数实现中，`UIMenuController` 需要被指定位置，并且设为可见
- 最后，label 必须要成为第一响应者（first responder）

If you're wondering why, _oh why_, this isn't just built into `UILabel`, well... join the club.

如果你在纳闷儿为什么，_天啊为什么_，为什么这个没有内建到 `UILabel` 中，嗯...纳闷儿的并不只有你一个人。

## `UIMenuController`

## `UIMenuController`

`UIMenuController` is responsible for presenting edit action menu items. Each app has its own singleton instance, `sharedMenuController`. By default, a menu controller will show commands for any methods in the `UIResponderStandardEditActions` informal protocol that the responder returns `YES` for in `canPerformAction:withSender:`.

`UIMenuController` 负责展示编辑动作的菜单项。每个应用都持有自己的一个单例对象 `sharedMenuController`。默认情况下，菜单控制器会展示 `UIResponderStandardEditActions` 这个非正式协议（译者注：即不需要对应实现的协议）的方法当中，那些在 `canPerformAction:withSender:` 返回 `YES` 的方法。

### `UIResponderStandardEditActions`

### `UIResponderStandardEditActions`

#### Handling Copy, Cut, Delete, and Paste Commands

#### 处理复制，剪切，删除和粘贴命令

> Each command travels from the first responder up the responder chain until it is handled; it is ignored if no responder handles it. If a responder doesn't handle the command in the current context, it should pass it to the next responder.

> 每个命令都会沿着响应链从第一响应者开始向上传递，如果没有人处理这个命令它就会被忽略。如果某个响应者没有响应它，它会被传递给下一个响应者。

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
