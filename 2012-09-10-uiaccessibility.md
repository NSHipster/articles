---
layout: post
title: UIAccessibility
category: Cocoa
author: Mattt Thompson
translator: Henry Lee
excerpt: 辅助功能，如同国际化一样，是一个很难让开发者提起兴致来的话题，但是你也知道，让你对这些东西感兴趣起来就是NSHipster的任务。

---

> 我们想互相帮助，人类理应如此。
> - [Charlie Chaplin](http://en.wikiquote.org/wiki/Charlie_Chaplin)

你知道我最想每个人都从苹果抄袭什么么？它们的肢体障碍者辅助技术。

iPhones和iPad本身已经如此神奇，但是凭借苹果的肢体障碍者辅助功能，它们同时让许多肢体障碍者和他们的家人的生活_完全改变_。我们就可以看看最近的[WWDC 2012开场视频](http://www.youtube.com/watch?v=MbP_pxR5cMk)，视频里一个叫Per Busch的得过盲人，在[Ariadne GPS](http://www.ariadnegps.eu)的帮助下，竟然能在Kassel森林里行走。这其实是一个提醒，告诉你你的工作可能对另一个人的生活产生巨大的影响。

辅助功能，如同国际化一样，是一个很难让开发者提起兴致来的话题，但是你也知道，让你对这些东西感兴趣起来就是NSHipster的任务。让我们现在开始吧：

---

`UIAccessibility`是在`UIKit`里的一个非正式协议，提供关于UI元素的辅助功能信息。这个信息能够通过VoiceOver和其他辅助科技帮助你的肢体障碍者用户与你的应用进行交互。

在UIKit里的所有标准视图和控件都实现了`UIAccessibility`协议，所以你的应用默认是可以被肢体障碍者使用的。于是提高你应用的肢体障碍者可用性其实只需要一些细微的调整，而不必全盘重新实现。

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

## 开启辅助功能

在我们介绍更多之前，为了能理解这些辅助功能的信息是如何传递给用户的，不妨花一些时间来玩一玩VoiceOver。打开设置，点击通用，滑到最下面选择辅助功能。在辅助功能选项里，你能设置一些分类的辅助功能技术：视觉、听觉、学习和肢体活动。

进入VoiceOver然后开启它，接着会有一个提示弹出来，告诉你打开VoiceOver会改变你控制设备的方式。关掉提示以后，VoiceOver就在你的设备上打开了。

不要绝望！——不像你把设备变成另一个语言一样，VoiceOver不会引发这种你不知道如果关掉它的危险。

![VoiceOver Settings](http://nshipster.s3.amazonaws.com/uiaccessibility-voiceover.png)

调至VoiceOver模式的设备可能和你之前习惯的用法有些不一样：

- 轻触一次是选中控件
- 双击激活选中的控件
- 用三只手指来滚动视图

摁下Home键来开始探索吧！

你会首先注意到苹果的原声应用，信息、日历和天气在VoiceOver模式下全都可用，甚至，连相机都是可用的，[VoiceOver还会告诉你人脸在你相机预览的哪个部位](http://svan.ca/blog/2012/blind/)！

可能相反地，试着用一用你从App Store下载的一些应用，你会发现很多（不是全部）在视觉上很震撼的应用，用了很多个性化的控件和交互之后，在VoiceOver模式下则变得完全不可用。

所以现在你应该大概知道了你需要做的工作大概是什么，所以我们来讨论它的实现吧：

## 文字标签和提示

如果你只想在提高你应用肢体障碍者可用性上做一件事情，那你要多注意辅助功能标签和UI元素的提示。

当用户在选择了指定交互元素的时候，辅助功能标签和提示告诉VoiceOver应该如何“说”给用户听。这个信息需要很有帮助，但必须简洁。

- **`accessibilityLabel`** 标识一个UI元素。每一个有辅助功能的视图和控件都_必须_支持这个属性。
- **`accessibilityHint`** 描述与这个UI元素交互的结果。这个提示只需要在之前元素的标签表征不明显的时候支持就好了。

[辅助功能编程指南](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/iPhoneAccessibility/Making_Application_Accessible/Making_Application_Accessible.html)提供了一些在文字标签和提示的指导:

> ### 创建标签指南

> 如果你提供一些自定义的控件或者视图，或者你只是在标准控件或者试图上展示了一个自定义的图标，你需要创建一个像这样的标签：
>
- **非常简洁地描述该元素。** 理想情况下，这个标签只需要展示一个词，像添加、播放、删除、搜索、收藏或者音量。
- **不应该包括这个控件或者视图的种类。** 种类的信息已经包含在元素的特征属性里了，不需要在标签里做更多重复。
- **开头大写。** 这能帮助VoiceOver用合适的语调读出这个标签。
- **不需要句号结尾。** 标签文字不是一个句子，所以不必用句号结尾
- **必须是本地化后的文字。** 为了让你的应用用得更广，尽可能为广泛的用户本地化所有的字符串，包括辅助功能的文字。一般情况下，VoiceOver用的语言是用户在国际化设置里设置的语言。

>
> ### 创建提示指南
> 提示属性描述了当用户对某个控件或者视图做操作后的结果。你只需要在元素标签不能充分描述这个操作的时候提供这个提示。
>
- **结果描述要十分简洁。** 尽管只有很少一部分控件和视图需要提示，你还是得尽可能让你的提示更简洁，这样能让用户在知道怎么对这个元素做操作之前听语音描述的时间更短。
- **以动词开头并省略宾语** 最好用像“Plays”的第三人称单数的动词，不要用像“Play”一样的祈使语气。你最好避免用祈使句，这会让这个声音听起来有些命令的口吻。
- **以大写字母单词开头并以句号结尾。** 尽管提示是一个短语而不是句子，以句号结尾能帮助VoiceOver发音的语调更合适。
- **不要包含动作或者手势的名字。** 提示不需要告诉用户他如何操作，只需要告诉用户他操作的结果。
- **不要包含控件或者视图的名字** 用户已经在标签属性里知道这些信息了，不必在这里重复这些信息。
- **必须已经本地化了。** 就像之前的辅助功能标签一样，提示语言也必须是用户设置的语言。

## 辅助功能特征

如果你正在使用的自定义的控件或者随意地没有用标准用法使用标准控件，你应该确保你指定了正确的辅助功能特征。

辅助功能特征描述了一系列控件行为与处理模式的特征。例如以下特征：

- 按钮
- 链接
- 搜索框
- 键盘按键
- 静态文字
- 图片
- 播放声音
- 已选中
- 标题元素
- 经常更新
- 触发换页
- 没有开启
- 无

`accessibilityTraits`属性用了`UIAccessibilityTraits`为值的位掩码，这样这个属性可以由文档里指定的好几个属性结合而成。

例如，如果自定义的按钮上展示了一张图片，在点击的时候播放声音，你需要定义它的特征为“按钮”、“图片”和“播放声音”。或者如果你只是用`UISlider`来装饰页面，你需要将它的特征定义为“没有开启”。

## 控件框架与控件激活位置

一般来说，一个自定义的UI元素的精妙程度是基本上和你实现时的粗糙度是正相关的，覆盖和隐藏视图、列表视图的小技巧，第一响应者的把戏：有些时候还是不要问这个功能到底是怎么实现的为好吧。

不过，当你处理辅助功能的话，你将过程弄得更直接一些还是很重要的。

`accessibilityFrame`和`accessibilityActivationPoint`是用来定义辅助功能的区域和UI元素的位置，而不用改变他外在的视图的位置。

在你在VoiceOver模式下调试你的应用的时候，尝试一下与各个屏幕下的所有元素交互。如果选择对象不是你期望的时候，你可以相应地改变`accessibilityFrame`和`accessibilityActivationPoint`让你的选择更方便。

## 辅助功能控件的值

辅助功能控件的值是指的一个UI元素的内容。标签的值是文字，`UISlider`的值是控件当时表示的数字。

想知道快速在列表视图里提高你的应用可用性么？尝试一下给列表单元格设置`accessibilityValue`的值，让它变成单元格内容本地化后的更改。例如说，如果你有一个展示状态更新的列表视图，你可能可以设置`accessibilityLabel`为“#{用户名}的更新”，而设置`accessibilityValue`为更新内容。

---

让辅助功能成为苹果软件和硬件上的一等公民这件事，是苹果为人类服务做的一大贡献。你如果忽视了`UIAccessibility`，那你会错过为数不多苹果在工程、设计和技术文档方面做得最好的工作。

帮自己一个忙，读一下这篇_一级棒_的[iOS辅助功能变成指南](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/iPhoneAccessibility/Introduction/Introduction.html)吧，可能只需要一两个小时你就能掌握全部的东西了。

谁知道呢，你可能因为这个最后改变了一个人的生活。
