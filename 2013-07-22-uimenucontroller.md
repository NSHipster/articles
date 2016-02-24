---
title: UIMenuController
author: Mattt Thompson
translator: Chester Liu
category: Cocoa
tags: nshipster
excerpt: "移动可用性在当今是一个十分引入注目的领域，特别是考虑到在过去短短的十年时间中它所经历的巨大变革。曾经只有科技精英才能把玩的复杂技术，如今已经飞入寻常百姓家，成为了大部分人使用计算设备的主要形式。"
status:
    swift: 2.0
    reviewed: September 8, 2015
---

移动可用性在当今是一个十分引入注目的领域，特别是考虑到在过去短短的十年时间中它所经历的巨大变革。曾经只有科技精英才能把玩的复杂技术，如今已经飞入寻常百姓家，成为了大部分人使用计算设备的主要形式。

尽管移动可用性得到了长足的发展，有些时候，我们还是不经意的会感觉...受到了某些限制。

总有些时候，屏幕上出现了一些信息，但是你_就是不能使用_。不管是被限制在一个小小的 table view cell 里的航班信息，或是一个不能点击的 URL，用户在这种时候只能被迫去发挥想象力，因为没有现成的办法供他们使用。

过去的文章中，我们提到过[本地化（localization）](http://nshipster.cn/nslocalizedstring)和[辅助功能（accessibility）
](http://nshipster.com/uiaccessibility)支持是把高品质应用和其他应用所区分开的两个特性，这周我们再往这个名单里添加一项：**编辑操作**。

### 复制，剪切，粘贴，删除，选择

iOS 3 的杀手特性毫无疑问是推送通知，然而支持复制-粘贴的重要性可能并不比它要差。复制-粘贴作为一个我们几乎每天都要使用的功能，很难相信离开了它是怎样一种场景。但是，在第三方应用中，这个特性的支持仍然显得有些不清晰。

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

总结一下，为了能够支持复制一个 label 中的文字，需要完成下面几步：

- 必须要继承 `UILabel`，并且在子类中实现 `canBecomeFirstResponder` 和 `canPerformAction:withSender:` 方法
- 每个可以执行的操作，都要实现一个对应的方法，并且在方法中和 `UIPasteboard` 进行交互
- 当在控制器中被初始化时，label 必须把 `userInteractionEnabled` 属性设置为 `YES`（不推荐把这个操作硬编码到子类的实现中）
- label 中必须添加一个 `UIGestureRecognizer`（或者手动在子类中实现 `UIResponder` 的方法，例如 `touchesBegan:withEvent:`）
- 在响应手势识别事件的函数实现中，需要指定 `UIMenuController` 显示的位置，并且设为可见
- 最后，label 必须要成为第一响应者（first responder）

如果你在纳闷儿为什么，_天啊为什么_，为什么这个没有内建到 `UILabel` 中，嗯...纳闷儿的并不只有你一个人。

## `UIMenuController`

`UIMenuController` 负责展示编辑动作的菜单项。每个应用都持有自己的一个单例对象 `sharedMenuController`。默认情况下，菜单控制器会展示 `UIResponderStandardEditActions` 这个非正式协议（译者注：即不需要对应实现的协议）的方法当中，那些在 `canPerformAction:withSender:` 返回 `YES` 的方法。

### `UIResponderStandardEditActions`

#### 处理复制，剪切，删除和粘贴命令

> 每个命令都会沿着响应链从第一响应者开始向上传递，如果没有人处理这个命令它就会被忽略。如果某个响应者没有响应它，它会被传递给下一个响应者。(译者注：下面具体的操作细节不做翻译）

> `copy:` This method is invoked when the user taps the Copy command of the editing menu. A subclass of UIResponder typically implements this method. Using the methods of the UIPasteboard class, it should convert the selection into an appropriate object (if necessary) and write that object to a pasteboard.

> `cut:` This method is invoked when the user taps the Cut command of the editing menu. A subclass of UIResponder typically implements this method. Using the methods of the UIPasteboard class, it should convert the selection into an appropriate object (if necessary) and write that object to a pasteboard. It should also remove the selected object from the user interface and, if applicable, from the application's data model.

> `delete:` This method is invoked when the user taps the Delete command of the editing menu. A subclass of UIResponder typically implements this method by removing the selected object from the user interface and, if applicable, from the application's data model. It should not write any data to the pasteboard.

> `paste:` This method is invoked when the user taps the Paste command of the editing menu. A subclass of UIResponder typically implements this method. Using the methods of the UIPasteboard class, it should read the data in the pasteboard, convert the data into an appropriate internal representation (if necessary), and display it in the user interface.

#### 处理选择命令

> `select:` This method is invoked when the user taps the Select command of the editing menu. This command is used for targeted selection of items in the receiving view that can be broken up into chunks. This could be, for example, words in a text view. Another example might be a view that puts lists of visible objects in multiple groups; the select: command could be implemented to select all the items in the same group as the currently selected item.

> `selectAll:` This method is invoked when the user taps the Select All command of the editing menu.

除了这些基本从操作命令之外，还有一些富文本编辑有关的命令（`toggleBoldface:`，`toggleItalics:`， 和 `toggleUnderline:`）以及书写方向改变有关的命令（`makeTextWritingDirectionLeftToLeft:` 和 `makeTextWritingDirectionLeftToRight:`)。这些命令除了在编写文本编辑器时有所应用之外，适用的情况并不常见，这里我们就不再赘述了。

## `UIMenuItem`

在 iOS 3.2 上，开发者可以向菜单控制器中添加自定义的命令。之前没有提到的类似“定义”或者拼写检查建议这些大家很熟悉的命令，就是利用了这一特性。

`UIMenuController` 有一个 `menuItems` 属性，是一个包含 `UIMenuItem` 对象的 `NSArray`。每一个 `UIMenuItem` 对象都有一个 `title` 和 `action`。为了让这个菜单项命令能在菜单控制器中显示，响应者必须实现对应的方法选择器。

---

就像有经验的工程师会把软件设计的尽可能灵活和可伸缩，以应对可能出现的未知的使用需求一样，任何对得起他们工资的应用开发者也懂得考虑到用户的各种需求。

当你开发应用的时候，用心考虑下面的几个原则：

- 对于每个控件，思考一下如果它是在桌面端使用，你会期望右击操作（控制操作）会出现什么样的结果
- 当把信息展示给用户的时候，考虑一下它应不应该是可复制的
- 对于格式化过的，或者由多个部分组成的信息，考虑一下采用多种复制的命令是不是更合适一些
- 实现 `copy:` 的时候，确保只把真正有价值的信息复制到剪切板
- 对于可编辑的控件，保证你的 `paste:` 实现能够处理各种有效或者无效输入

如果移动计算在绝大部分人的生活中都占了非常大的比例，我们有必要尽我们最大的努力去提升移动设备的使用效率。经过你细致考虑并采用的 `UIMenuController`，不会成为没有人注意到的无用功。
