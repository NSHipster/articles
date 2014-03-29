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
> ### 创建标签指南
> If you provide a custom control or view, or if you display a custom icon in a standard control or view, you need to provide a label that:
> 如果你提供一些自定义的控件或者视图，或者你只是在标准控件或者试图上展示了一个自定义的图标，你需要创建一个像这样的标签：
>
- **Very briefly describes the element.** Ideally, the label consists of a single word, such as Add, Play, Delete, Search, Favorites, or Volume.
- **Does not include the type of the control or view.** The type information is contained in the traits attribute of the element and should never be repeated in the label.
- **Begins with a capitalized word.** This helps VoiceOver read the label with the appropriate inflection.
- **Does not end with a period.** The label is not a sentence and therefore should not end with a period.
- **Is localized.** Be sure to make your application available to as wide an audience as possible by localizing all strings, including accessibility attribute strings. In general, VoiceOver speaks in the language that the user specifies in International settings.

- **非常简洁地描述该元素。** 理想情况下，这个标签只需要展示一个词，像添加、播放、删除、搜索、收藏或者音量。
- **不应该包括这个控件或者视图的种类。** 种类的信息已经包含在元素的特质属性里了，不需要在标签里做更多重复。
- **开头大写。** 这能帮助VoiceOver用合适的语调读出这个标签。
- **不需要句号结尾。** 标签文字不是一个句子，所以不必用句号结尾
- **必须是本地化后的文字** 为了让你的应用用得更广，尽可能为广泛的用户本地化所有的字符串，包括辅助功能的文字。一般情况下，VoiceOver用的语言是用户在国际化设置里设置的语言。

>
> ### Guidelines for Creating Hints
> ### 创建提示指南
> The hint attribute describes the results of performing an action on a control or view. You should provide a hint only when the results of an action are not obvious from the element’s label.
> 提示属性描述了当用户对某个控件或者视图做操作后的结果。你只需要在元素标签不能充分描述这个操作的时候提供这个提示。
>
- **Very briefly describes the results.** Even though few controls and views need hints, strive to make the hints you do need to provide as brief as possible. Doing so decreases the amount of time users must spend listening before they can use the element. 
- **结果描述要十分简洁。** 尽管只有很少一部分控件和视图需要提示，你还是得尽可能让你的提示更简洁，这样能让用户在知道怎么对这个元素做操作之前听描述的时间更短。
- **Begins with a verb and omits the subject.** Be sure to use the third-person singular declarative form of a verb, such as “Plays,” and not the imperative, such as “Play.” You want to avoid using the imperative, because using it can make the hint sound like a command.
- **以动词开头并省略宾语** 最好用像“Plays”的第三人称单数的动词，不要用像“Play”一样的祈使语气。你最好避免用祈使句，这会让这个声音听起来有些命令的口吻。
- **Begins with a capitalized word and ends with a period.** Even though a hint is a phrase, not a sentence, ending the hint with a period helps VoiceOver speak it with the appropriate inflection.
- **以大写字母单词开头并以句号结尾。** 尽管提示是一个短语而不是句子，以句号结尾能帮助VoiceOver发音的语调更合适。
- **Does not include the name of the action or gesture.** A hint does not tell users how to perform the action, it tells users what will happen when that action occurs.
- **不要包含动作或者手势的名字。** 提示不需要告诉用户他如何操作，它只需要告诉用户他操作的结果。
- **Does not include the name of the control or view.** The user gets this information from the label attribute, so you should not repeat it in the hint.
- **不要包含控件或者视图的名字** 用户已经在标签属性里知道这些信息了，不必在这里重复这些信息。
- **Is localized**. As with accessibility labels, hints should be available in the user’s preferred language.
- **必须已经本地化了**. 就想之前的辅助功能标签一样，提示语言也必须是用户设置的语言。

## Traits
## 辅助功能特征

If you are using custom controls, or have taken liberties with non-standard use of a standard control, you should make sure to specify the correct accessibility traits.

如果你正在使用的自定义的控件或者随意地没有使用标准用法，你应该确保你指定了正确的辅助功能特征。

Accessibility traits describe a set of traits that characterize how a control behaves or should be treated. Examples include distinctions like:

辅助功能特征描述了一系列控件行为与处理模式的特征。例如以下特征：

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

- 按钮
- 链接
- 搜索框
- 键盘按钮
- 静态文字
- 图片
- 声音播放
- 已选中
- 标题元素
- 经常更新
- 能换页
- 没有开启
- 无


The `accessibilityTraits` property takes a bitmask of `UIAccessibilityTraits` values, which can be combined in ways specified in the documentation.

`accessibilityTraits`属性用了`UIAccessibilityTraits`为值的位掩码，这样这个属性可以由文档里指定的好几个属性结合而成。

For example, if a custom button control displays an image and plays a sound when tapped, you should define the traits for "Button", "Image", and "Plays Sound". Or, if you were to use a `UISlider` for purely decorative purposes, you should set the "Not Enabled" trait.

例如，如果自定义的按钮上展示了一张图片，在点击的时候播放声音，你需要定义它的特征为“按钮”、“图片”和“播放声音”。或者如果你只是用`UISlider`来装饰页面，你需要将它的特征定义为“没有开启”。

## Frame & Activation Point
## 控件框架与控件激活位置

As a general rule, the cleverness of a custom UI element is directly proportional to how gnarly its implementation is. Overlapping & invisible views, table view hacks, first responder shenanigans: sometimes it's better not to ask how something works.

一般来说，一个自定义的UI元素的精妙程度是基本上和你实现时得粗糙度是正相关的，覆盖和隐藏的视图、列表视图的小技巧，第一响应者的轨迹：有些时候还是不要问这个功能到底是怎么实现的吧。

However, when it comes to accessibility, it's important to set the record straight. 

不过，当你处理辅助功能的话，你将过程弄得更直接一些还是很重要的。

`accessibilityFrame` and `accessibilityActivationPoint` are used to define the accessible portions and locations of UI elements, without changing their outward appearance.

`accessibilityFrame`和`accessibilityActivationPoint`是用来定义辅助功能的区域和UI元素的位置，而不用改变他外在的视图的位置。

As you try out your app in VoiceOver mode, try interacting with all of the elements on each screen. If the selection target is not what you expected, you can use `accessibilityFrame` and `accessibilityActivationPoint` to adjust accordingly.

在你在VoiceOver模式下调试你的应用的时候，尝试一下与各个屏幕下的所有元素交互。如果选择对象不是你期望的时候，你可以就此改变`accessibilityFrame`和`accessibilityActivationPoint`让你的选择更方便。

## Value
## 辅助功能控件的值

Accessibility value corresponds to the content of a user interface element. For a label, the value is its text. For a `UISlider`, it's the current numeric value represented by the control.
控件空能的值指的是一个UI元素的内容。标签的值是文字，`UISlider`的值是控件当时表示的数字。

Want to know a quick way to improve the accessibility of your table views? Try setting the `accessibilityValue` property for cells to be a localized summary of the cell's content. For example, if you had a table view that showed status updates, you might set the `accessibilityLabel` to "Update from #{User Name}", and the `accessibilityValue` to the content of that status update. 

想知道快速在列表视图里提高你的应用可用性么？尝试一下给列表单元格设置`accessibilityValue`的值，让它变成单元格内容本地化后的更改。例如说，如果你有一个展示状态更新的列表视图，你可能可以设置`accessibilityLabel`为“#{用户名}的更新”，而设置`accessibilityValue`为更新内容。

---

Apple has done a great service to humanity in making accessibility a first-class citizen in its hardware and software. You're missing out on some of the best engineering, design, and technical writing that Apple has ever done if you ignore `UIAccessibility`.

让辅助功能成为了苹果软件和硬件上的一等公民这件事，是苹果为人类服务做的一大贡献。你如果忽视了`UIAccessibility`，那你会错过为数不多苹果在工程、设计和技术文档方面做得最好的工作。

Do yourself a favor and read the _excellent_ [Accessibility Programming Guide for iOS](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/iPhoneAccessibility/Introduction/Introduction.html). It only takes an hour or two to get the hang of everything. 

帮自己一个忙，读一下这篇_一级棒_的[iOS辅助功能变成指南](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/iPhoneAccessibility/Introduction/Introduction.html)吧，可能只需要一两个小时你就能掌握全部的东西了吧。

Who knows? You may end up changing someone's life because of it.

谁知道呢，你可能最后因为这个该表了一个人的生活。
