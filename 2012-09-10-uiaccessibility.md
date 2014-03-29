---
layout: post
title: UIAccessibility

ref: "http://developer.apple.com/library/ios/#documentation/uikit/reference/UIAccessibility_Protocol/Introduction/Introduction.html"
framework: UIKit
rating: 10.0
published: true
translator: "Henry Lee"
description: Accessibility, like internationalization, is one of those topics that's difficult to get developers excited about. But as you know, NSHipster is all about getting developers excited about this kind of stuff.
description: 辅助功能，如同国际化一样，是一个很难让开发者提起兴致来的话题，但是你也知道，NSHipster就是关于教你对这些东西感兴趣的。

---

> 我们想互相帮助，人类理应如此。
> - [Charlie Chaplin](http://en.wikiquote.org/wiki/Charlie_Chaplin)

You know what I wish everyone would copy from Apple? Their assistive technologies.

你知道我最想每个人都从苹果抄袭什么么？它们的残疾人辅助技术。

iPhones and iPads--magical as they are--become downright _life-changing_ for individuals with disabilities and their families because of Apple's commitment to accessibility. Look no further than the [WWDC 2012 Introduction Video](http://www.youtube.com/watch?v=MbP_pxR5cMk), which opens with Per Busch, a blind man who walks the woods of Kassel, Germany with the aid of [Ariadne GPS](http://www.ariadnegps.eu). It's a lovely reminder of the kind of impact our work can have on others.

iPhones和iPad虽然已经如此神奇，但是凭借苹果的辅助功能，它们同样让许多残疾人和他们的家人的生活_完全改变_。我们就可以看看最近的[WWDC 2012开场视频](http://www.youtube.com/watch?v=MbP_pxR5cMk)，视频里一个叫Per Busch的得过盲人，在[Ariadne GPS](http://www.ariadnegps.eu)的帮助下，竟然能在Kassel森林里行走。这其实是一个提醒，告诉你你的工作可能对另一个人的生活产生巨大的影响。

Accessibility, like [internationalization](http://nshipster.com/nslocale/), is one of those topics that's difficult to get developers excited about. But as you know, NSHipster is _all about_ getting developers excited about this kind of stuff. Let's get started: 

辅助功能，如同国际化一样，是一个很难让开发者提起兴致来的话题，但是你也知道，NSHipster就是关于教你对这些东西感兴趣的。让我们现在开始吧：

---

`UIAccessibility` is an informal protocol in `UIKit` that provides accessibility information about user interface elements. This information is used by VoiceOver and other assistive technologies to help users with disabilities interact with your application.

`UIAccessibility`是在`UIKit`里不是很正式的一个协议，提供关于用户交互元素的辅助功能信息。这个信息能够通过VoiceOver和其他辅助科技帮助你的残疾人用户与你的应用进行交互。


All of the standard views and controls in UIKit implement `UIAccessibility`, so applications are accessible by default. As a result, the task of improving the accessibility of your application is one of minor adjustments rather than wholesale re-implementation.

在UIKit里的所有标准视图都实现了`UIAccessibility`，所以你的应用默认是可以被残疾人使用的。所以提要你应用的残疾人可用性其实只需要一些细微的调整，而不必全盘重新实现。

Here's a list of all of the properties in `UIAccessibility`: 

这里是`UIAccessibility`所有属性的列表：

- `accessibilityLabel`
- `accessibilityHint`
- `accessibilityValue`
- `accessibilityLanguage`
- `accessibilityTraits`
- `accessibilityFrame`
- `accessibilityActivationPoint`
- `accessibilityElementsHidden`
- `accessibilityViewIsModal`

## Enabling Accessibility
## 开启辅助功能

Before we go any further, take a couple minutes to play with VoiceOver, and understand how accessibility information is conveyed to the user. Open the Settings app, tap General, scroll to the bottom and tap Accessibility. In Accessibility, you'll see settings for assistive technologies grouped by category: Vision, Hearing, Learning, and Physical & Motor.

在我们介绍更多之前，花一些时间来玩一玩VoiceOver，从而来理解这些辅助功能的信息是如何传递给用户的。打开设置应用，点击通用，花到最下面选择辅助工更。在辅助功能选项里，你能设置一些分类的辅助功能技术：视觉、听觉、学习和物理触觉。

Tap VoiceOver, and then tap the VoiceOver switch to turn it on. An alert will pop up telling you that enabling VoiceOver changes the way you control your device. Dismiss the alert, and now VoiceOver is now enabled on your device. 

进入VoiceOver然后打开它，接着会有一个提示弹出来，告诉你打开VoiceOver会改变你控制设备的方式。关掉提示以后，VoiceOver就在你的设备上打开了。

Don't Panic--unlike setting your device to another language, there's no real risk of not being able to figure out how to turn VoiceOver off.

不要绝望——不像你把设备变成另一个语言了一样，不会有你不知道如何把VoiceOver关掉的危险的。

![VoiceOver Settings](http://nshipster.s3.amazonaws.com/uiaccessibility-voiceover.png)

Using the device in VoiceOver mode is a bit different than you're used to:

将设备调至VoiceOver模式可能和你之前习惯的用法有些不一样：

- Tap once to select an item
- Double-Tap to activate the selected item
- Swipe with three fingers to scroll

- 轻触一次选中控件
- 双击激活选择的空间
- 用三只手指来滚动视图

Press the Home button and start exploring!

摁下Home键来开始探索吧！

You'll notice that all of the stock Apple apps--Messages, Calendar, Weather--each is fully-usable in VoiceOver mode. Heck, _even Camera is usable_, with [VoiceOver telling you where faces are in your camera's viewport](http://svan.ca/blog/2012/blind/)!

你会首先注意到苹果的原声应用，信息、日历和天气在VoiceOver模式下全都可用，甚至，连相机都是可用的，[VoiceOver会告诉你人脸在你相机预览的哪个部位](http://svan.ca/blog/2012/blind/)！

By contrast (perhaps), try some of the apps you've downloaded from the App Store. You may be surprised that some (but certainly not all) of the most visually-stunning apps, with all of their custom controls and interactions are completely unusable in this mode.

可能相反地，试着用一用你从App Store下载的一些应用，你会发现很多（不是全部）在视觉上很震撼的应用，用了很多个性化的控件和交互之后，在VoiceOver下变得完全不可用。

So now that you have an idea of what you're working with, let's talk about implementation:

所以现在你应该大概知道了你需要做的工作是设么，所以我们来介绍它的实现吧：

## Label & Hint
## 文字标签和提示

If there was just one thing you could do to improve the accessibility of your app, paying attention to accessibility labels and hints of UI elements would be it.

如果你只想在提高你应用残疾人可用性上做一件事情，那你可以多注意辅助功能标签和UI元素的提示。

Accessibility labels and hints tell VoiceOver what to say when selecting user interface elements. This information should be helpful, but concise. 

当用户在选择了指定交互元素的时候，辅助功能标签和提示告诉VoiceOver应该如何“说”给用户听。这个信息需要很有帮助，但必须简洁。


- **`accessibilityLabel`** identifies a user interface element. Every accessible view and control _must_ supply a label.
- **`accessibilityHint`** describes the results of interacting with a user interface element. A hint should be supplied _only_ if the result of an interaction is not obvious from the element's label.

- **`accessibilityLabel`** 标识一个UI元素。每一个有辅助功能的视图和控件都_必须_支持这个属性。
- **`accessibilityHint`** 描述与这个UI元素交互的结果。这个提示只需要在之前元素的标签表征不明显的时候支持就好了。


The [Accessibility Programming Guide](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/iPhoneAccessibility/Making_Application_Accessible/Making_Application_Accessible.html) provides the following guidelines for labels and hints:

[辅助功能编程指南](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/iPhoneAccessibility/Making_Application_Accessible/Making_Application_Accessible.html)提供了一些在文字标签和提示的指导:

> ### Guidelines for Creating Labels
> If you provide a custom control or view, or if you display a custom icon in a standard control or view, you need to provide a label that:
>
- **Very briefly describes the element.** Ideally, the label consists of a single word, such as Add, Play, Delete, Search, Favorites, or Volume.
- **Does not include the type of the control or view.** The type information is contained in the traits attribute of the element and should never be repeated in the label.
- **Begins with a capitalized word.** This helps VoiceOver read the label with the appropriate inflection.
- **Does not end with a period.** The label is not a sentence and therefore should not end with a period.
- **Is localized.** Be sure to make your application available to as wide an audience as possible by localizing all strings, including accessibility attribute strings. In general, VoiceOver speaks in the language that the user specifies in International settings.
>
> ### Guidelines for Creating Hints
> The hint attribute describes the results of performing an action on a control or view. You should provide a hint only when the results of an action are not obvious from the element’s label.
>
- **Very briefly describes the results.** Even though few controls and views need hints, strive to make the hints you do need to provide as brief as possible. Doing so decreases the amount of time users must spend listening before they can use the element.
- **Begins with a verb and omits the subject.** Be sure to use the third-person singular declarative form of a verb, such as “Plays,” and not the imperative, such as “Play.” You want to avoid using the imperative, because using it can make the hint sound like a command.
- **Begins with a capitalized word and ends with a period.** Even though a hint is a phrase, not a sentence, ending the hint with a period helps VoiceOver speak it with the appropriate inflection.
- **Does not include the name of the action or gesture.** A hint does not tell users how to perform the action, it tells users what will happen when that action occurs.
- **Does not include the name of the control or view.** The user gets this information from the label attribute, so you should not repeat it in the hint.
- **Is localized**. As with accessibility labels, hints should be available in the user’s preferred language.

## Traits

If you are using custom controls, or have taken liberties with non-standard use of a standard control, you should make sure to specify the correct accessibility traits.

Accessibility traits describe a set of traits that characterize how a control behaves or should be treated. Examples include distinctions like:

- Button
- Link
- Search Field
- Keyboard Key
- Static Text
- Image
- Plays Sound
- Selected
- Summary Element
- Updates Frequently
- Causes Page Turn
- Not Enabled
- None

The `accessibilityTraits` property takes a bitmask of `UIAccessibilityTraits` values, which can be combined in ways specified in the documentation.

For example, if a custom button control displays an image and plays a sound when tapped, you should define the traits for "Button", "Image", and "Plays Sound". Or, if you were to use a `UISlider` for purely decorative purposes, you should set the "Not Enabled" trait.

## Frame & Activation Point

As a general rule, the cleverness of a custom UI element is directly proportional to how gnarly its implementation is. Overlapping & invisible views, table view hacks, first responder shenanigans: sometimes it's better not to ask how something works.

However, when it comes to accessibility, it's important to set the record straight. 

`accessibilityFrame` and `accessibilityActivationPoint` are used to define the accessible portions and locations of UI elements, without changing their outward appearance.

As you try out your app in VoiceOver mode, try interacting with all of the elements on each screen. If the selection target is not what you expected, you can use `accessibilityFrame` and `accessibilityActivationPoint` to adjust accordingly.

## Value

Accessibility value corresponds to the content of a user interface element. For a label, the value is its text. For a `UISlider`, it's the current numeric value represented by the control.

Want to know a quick way to improve the accessibility of your table views? Try setting the `accessibilityValue` property for cells to be a localized summary of the cell's content. For example, if you had a table view that showed status updates, you might set the `accessibilityLabel` to "Update from #{User Name}", and the `accessibilityValue` to the content of that status update. 

---

Apple has done a great service to humanity in making accessibility a first-class citizen in its hardware and software. You're missing out on some of the best engineering, design, and technical writing that Apple has ever done if you ignore `UIAccessibility`.

Do yourself a favor and read the _excellent_ [Accessibility Programming Guide for iOS](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/iPhoneAccessibility/Introduction/Introduction.html). It only takes an hour or two to get the hang of everything. 

Who knows? You may end up changing someone's life because of it.
