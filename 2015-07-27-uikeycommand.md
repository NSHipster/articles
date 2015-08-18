---
title: UIKeyCommand
author: Nate Cook
category: Cocoa
excerpt: "As part of the push for greater productivity on the iPad, iOS 9 adds *Discoverability*, an overlay showing the currently available key commands inside an app. This small change suddenly makes key commands far more viable on the iPad and, with it, makes `UIKeyCommand` a necessary addition to your app."
translator: April Peng
excerpt: "为了使 iPad 更高效的工作，iOS 9 增加了 *可发现特性*，这是一个叠加层，用于显示一个应用程序内当前可用的键盘命令。在 iPad 上，这个微小的变化使得键盘命令瞬间变得比以往有用多了，并且也使得 `UIKeyCommand` 成为你的应用程序的一个必要的添加"
---

Adding a new feature to a product is always a tradeoff. Will the added utility of a new feature be enough to offset the added complexity? Shortcuts would seem to side-step this issue—after all, they're simply a quicker alternative for features already in your app. But that creates another dilemma: what if a new feature is added and no one knows it's there?

给产品添加新功能始终是一个权衡。新功能添加的工具是否足以抵消增加的复杂性？不过快捷键似乎可以避开这个问题，毕竟，他们只是对应用程序已有的功能更快的替代方案。但是却创造了另一种困境：会不会一个新的功能被加入了却没有人知道它的存在？

When key commands for external keyboards debuted in iOS 7, there was no intrinsic way to learn of their existence. Unlike in OS X, where a user can gradually discover shortcuts for the menu items they use most often, an iOS app had few ways to communicate what key commands are available. Initial tours flash by and fade from memory; help screens are hidden out of sight. Without a way to make shortcuts visible in a timely and relevant manner, users were sure to miss out on useful features that developers had taken the time to implement.

在 iOS 7 里，当外部键盘发送键盘命令时，并没有自带的办法知道他们的存在。不像 OS X，用户可以在他们最常使用的菜单项中逐渐找到快捷方式，一个 iOS 应用程序很少有方法来告诉用户可用的键盘命令。初学教程总是一闪而过留不下任何记忆，帮助屏幕也总是淡出在视线之外。如果没有一种方法能及时且相关的使快捷方式可见，用户们一定会错过开发者花心思实现的非常有用的功能。

No longer. As part of the push for greater productivity on the iPad, iOS 9 adds *Discoverability*, an overlay showing the currently available key commands inside an app. This small change suddenly makes key commands far more viable on the iPad and, with it, makes `UIKeyCommand` a necessary addition to your app.

然而这种情况将不再继续了。为了使 iPad 更高效的工作，iOS 9 增加了 *可发现特性*，这是一个叠加层，用于显示一个应用程序内当前可用的键盘命令。在 iPad 上，这个微小的变化使得键盘命令瞬间变得比以往有用多了，并且也使得 `UIKeyCommand` 成为你的应用程序的一个必要的添加。

---

## `UIKeyCommand`

The `UIKeyCommand` class is in fact quite simple, with only four properties to configure:

`UIKeyCommand` 类其实很简单，只有四个属性来配置：

- `input`: The character of the key you'd like to recognize, or the correct constant for the arrow and escape keys, which do not have characters themselves. The available constants are:

- `input`：你需要识别的关键字，或正确的箭头和退出键，本身并不包含字符。可用常数是：
    - `UIKeyInputUpArrow`
    - `UIKeyInputDownArrow`
    - `UIKeyInputLeftArrow`
    - `UIKeyInputRightArrow`
    - `UIKeyInputEscape`

- `modifierFlags`: One or more `UIKeyModifierFlags`, describing the modifier keys that should be pressed in combination with `input`:
    - `.Command`, `.Alternate`, `.Shift`, `.Control`: The Command, Option, Shift, and Control keys, respectively.
    - `.NumericPad`: Indicates that `input` should come from the numeric keypad rather than the top row of the standard keyboard.
    - `.AlphaShift`: Indicates that the CapsLock key should be *pressed* as part of the combination, rather than just engaged.
	
- `modifierFlags`：一个或多个 `UIKeyModifierFlags`，描述了需要与 `input` 键同时使用的键：
	- `.Command`，`.Alternate`，`.Shift`，`.Control`：分别表示 Command, Option, Shift, 和 Control 键。
	- `.NumericPad`：表示 `input` 应该来自数字键盘，而不是标准键盘的最上面一行。
	- `.AlphaShift`：指示大小写锁定键应该作为组合的一部分被*按下*，而不仅仅是参与。

- `action`: The selector to call when the key command is invoked, called with a `UIKeyCommand` as its only argument. The key event will travel up the responder chain until a matching selector is found.

- `action`：按键命令调用的方法，`UIKeyCommand` 作为其唯一的参数。键盘事件将追溯响应链，直到发现一个匹配的方法。

- `discoverabilityTitle` *(iOS 9 only)*: An optional label to display for the key command in the Discoverability layover. Only key commands with a title set will be listed.

- `discoverabilityTitle` *（仅 iOS 9）*：一个可选的标签，用来在发现层显示快捷键命令。只有设置了标题的键盘命令才会被列出。




## Responding to Key Commands

## 响应键盘命令

Enabling key commands is as simple as providing an array of `UIKeyCommand` instances somewhere in the responder chain. Text inputs are automatically first responders, but perhaps more usefully, a view controller can respond to key commands by implementing `canBecomeFirstResponder()`:

启用键盘命令很简单，只需要在响应链的某处提供一个 `UIKeyCommand` 实例的数组。文字输入是自动的第一响应者，但也许更方便的是在视图控制器通过实现 `canBecomeFirstResponder()` 来响应键盘命令：

```swift
override func canBecomeFirstResponder() -> Bool {
    return true
}
```
```objective-c
- (BOOL)canBecomeFirstResponder {
    return YES;
}
```

Next, provide a list of available key commands via the `keyCommands` property:

接下来，通过 `keyCommands` 属性提供可用的按键命令列表：

```swift
override var keyCommands: [UIKeyCommand]? {
    return [
        UIKeyCommand(input: "1", modifierFlags: .Command, action: "selectTab:", discoverabilityTitle: "Types"),
        UIKeyCommand(input: "2", modifierFlags: .Command, action: "selectTab:", discoverabilityTitle: "Protocols"),
        UIKeyCommand(input: "3", modifierFlags: .Command, action: "selectTab:", discoverabilityTitle: "Functions"),
        UIKeyCommand(input: "4", modifierFlags: .Command, action: "selectTab:", discoverabilityTitle: "Operators"),
            
        UIKeyCommand(input: "f", modifierFlags: [.Command, .Alternate], action: "search:", discoverabilityTitle: "Find…"),
    ]
}

// ...

func selectTab(sender: UIKeyCommand) {
    let selectedTab = sender.input
    // ...
}
```
```objective-c
- (NSArray<UIKeyCommand *>*)keyCommands {
    return @[
        [UIKeyCommand keyCommandWithInput:@"1" modifierFlags:UIKeyModifierCommand action:@selector(selectTab:) discoverabilityTitle:@"Types"],
        [UIKeyCommand keyCommandWithInput:@"2" modifierFlags:UIKeyModifierCommand action:@selector(selectTab:) discoverabilityTitle:@"Protocols"],
        [UIKeyCommand keyCommandWithInput:@"3" modifierFlags:UIKeyModifierCommand action:@selector(selectTab:) discoverabilityTitle:@"Functions"],
        [UIKeyCommand keyCommandWithInput:@"4" modifierFlags:UIKeyModifierCommand action:@selector(selectTab:) discoverabilityTitle:@"Operators"],

        [UIKeyCommand keyCommandWithInput:@"f" 
                            modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate 
                                   action:@selector(search:) 
                     discoverabilityTitle:@"Find…"]
    ];
}

// ...

- (void)selectTab:(UIKeyCommand *)sender {
    NSString *selectedTab = sender.input;
    // ...
}
```

In the Discoverability layover, accessed by holding down the Command key, key commands are listed in the order you specified:

按住 Command 键显示可视层，关键命令将以你指定的顺序列出：

![Discoverability Layover](http://nshipster.s3.amazonaws.com/uikeycommand-discoverability.png)

*Voila!* Secrets, revealed!

*瞧！* 秘密被发现了！


### Context Sensitivity

### 情境敏感性

The `keyCommands` property is accessed whenever a key pressed, making it possible to provide context-sensitive responses depending on the state of your application. While this is similar to the way a menu item and its active/inactive state are configured in OS X, the recommendation for iOS is to omit inactive commands completely—that is, there are no grayed out commands in the Discoverability layover.

只要一个按键被按下， `keyCommands` 属性就会被访问，从而可以提供根据你应用程序的上下文状态敏感的反应。虽然这是类似菜单项的方式，其有效/无效状态被配置在 OS X 里面，iOS 版的建议是完全忽略不活动的命令，也就是说，在发现层不要显示变灰的命令。

Here, a set of commands that are available to logged in users of an app are included only when appropriate:

以下是在一个应用程序里的一套对已登录用户可用的命令：

```swift
let globalKeyCommands = [UIKeyCommand(input:...), ...]
let loggedInUserKeyCommands = [UIKeyCommand(input:...), ...]

override var keyCommands: [UIKeyCommand]? {
    if isLoggedInUser() {
        return globalKeyCommands + loggedInUserKeyCommands
    } else {
        return globalKeyCommands
    }
}
```

---

Although we don't take shortcuts when creating our apps, that doesn't mean our users won't find shortcuts useful. Adding key commands lets control of your app shift from the screen to the keyboard—your users will love the option.

虽然我们在创建我们的应用程序时并没有走捷径，这并不意味着我们的用户觉得快捷方式没用。添加键盘命令可以让你的应用程序从屏幕转变到键盘，你的用户一定会喜欢新的选择。

