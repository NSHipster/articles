---
title: "IBInspectable / IBDesignable"
category: Xcode
author: Nate Cook
translator: April Peng
excerpt: "比起一个需要我们记住并且输入什么的界面来说，如果替换成我们能够看见并可控制的界面的话将会是巨大的进步。Xcode 6 提供了这样一个替代，用 `IBInspectable` 和 `IBDesignable`，在旧技术上建立新的互动。"
---

展示，而不是描述。眼见为实。一图胜千<del>邮件</del>言。

无论陈词滥调多少次，比起一个需要我们记住并且输入什么的界面来说，如果替换成我们能够看见并可控制的界面的话将会是巨大的进步。 Xcode 6 提供了这样一个替代，在旧技术上建立新的互动。在设计项目的时候建立一个自定义的界面使你可以配置自定义控制并将它们实时显示出来，用 `IBInspectable` 和 `IBDesignable`，这将成为可能。


## IBInspectable

`IBInspectable` 属性提供了访问旧功能的新方式：用户自定义的运行时属性。从目前的身份检查器（identity inspector）中访问，这些属性在 Interface Builder 被整合到 Xcode 之前就可用了。他们提供了一个强有力的机制来配置一个 NIB，XIB，或者 storyboard 实例中的任何键值编码（key-value coded）属性：

![User-Defined Runtime Attributes]({{ site.asseturl }}/IBInspectable-runtime-attributes.png)

虽然功能强大，运行时属性可能会使工作很繁琐。一个属性的关键字路径，类型和属性值需要在每个实例设置，没有任何自动完成或输入提示，这就需要前往文档或自定义子类的源代码仔细检查设置。 `IBInspectable` 属性彻底的解决了这个问题：在 Xcode 6，你现在可以指定任何属性作为可检查项并为你的自定义类建立了一个用户界面。

例如，在一个 `UIView` 子类里，这些属性用它们的值来更新背景层：

````swift
@IBInspectable var cornerRadius: CGFloat = 0 {
   didSet {
       layer.cornerRadius = cornerRadius
       layer.masksToBounds = cornerRadius > 0
   }
}
@IBInspectable var borderWidth: CGFloat = 0 {
   didSet {
       layer.borderWidth = borderWidth
   }
}
@IBInspectable var borderColor: UIColor? {
   didSet {
       layer.borderColor = borderColor?.CGColor
   }
}
````

标有 `@IBInspectable`（或是 Objective-C 中的 `IBInspectable`），他们就可以很容易在 Interface Builder 的观察面板（inspector panel）里编辑。需要注意的是 Xcode 在这里做了更多的事，属性名称是从 camel- 转换为 title- 模式 并且相关的名称组合在一起：

![IBInspectable Attribute Inspector]({{ site.asseturl }}/IBInspectable-inspectable.png)

因为可检查属性仅仅是用户定义的运行时属性顶部的接口，所以支持相同的类型列表：布尔，字符串和数字（即，`NSNumber` 或任何数值类型），以及 `CGPoint`、`CGSize`、`CGRect`、`UIColor` 和 `NSRange`，额外增加了 `UIImage`。

> 那些已经熟悉运行时属性的人将注意到在上面的例子中有一些问题。`UIColor` 是里面唯一支持色彩的类型，而不是原生支持视图 `CALayer` 的 `CGColor`。`borderColor` 会计算 `UIColor` 属性（通过运行时属性设置）并映射到该层需要的 `CGColor`。


### 让现有的类型可观察

内置的 Cocoa 类型如果在 Interface Builder 中的属性检查器中没有列出也可以通过扩展来使属性可视。如果你喜欢圆角，你一定会喜欢这个 `UIView` 扩展：

````swift
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
````

变！你创建的任何 `UIView` 都将有一个可配置的边界半径。


## IBDesignable

如果这还不够，`IBDesignable` 自定义视图也在 Xcode 6 中亮相了。当应用到 `UIView` 或 `NSView` 子类中的时候，`@ IBDesignable` 让 Interface Builder 知道它应该在画布上直接渲染视图。你会看到你的自定义视图在每次更改后不必编译并运行你的应用程序就会显示。

标记一个自定义视图为 `IBDesignable`，只需在类名前加上 `@IBDesignable` 的前缀（或是 Objective-C 里的 `IB_DESIGNABLE` 宏）。你的初始化、布置和绘制方法将被用来在画布上渲染你的自定义视图：

````swift
@IBDesignable
class MyCustomView: UIView {
    ...
}
````

![IBDesignable Live Preview]({{ site.asseturl }}/IBInspectable-designable.png)

从这个功能上节约的时间是不能被低估的。加上 `IBInspectable` 属性，一个设计师或开发人员可以轻松地调整自定义控件的呈现，以得到她想要的确切的结果。任何改变，无论是从代码或属性检查器中，都将立即呈现在画布上。

此外，任何问题都是可避开编译和运行整个程序来调试的。调试的方法很简单，只需在你的代码中设置一个断点，在 Interface Builder 中选择视图，并选择 **Editor** ➔ **Debug Selected Views**。

由于在 Interface Builder 中呈现自定义视图不会有应用程序的完整上下文，你可能需要生成模拟数据以便显示，例如一个默认用户头像图片或仿制的天气数据。有两种方法可以为这个特殊的上下文添加代码：

> - `prepareForInterfaceBuilder()`：此方法与你代码的其余部分一起编译，但只有当视图正在准备在 Interface Builder 显示时执行。

> - `TARGET_INTERFACE_BUILDER`：`#if TARGET_INTERFACE_BUILDER` 预处理宏在 Objective-C 或 Swift 下都是工作的，它会视情况编译正确代码：

> ````swift
#if !TARGET_INTERFACE_BUILDER
    // this code will run in the app itself
#else
    // this code will execute only in IB
#endif
````


## IBCalculatorConstructorSet

把自定义 `IBDesignable` 视图和视图里的 `IBInspectable` 属性结合在一起，你能干点啥？作为一个例子，让我们更新老式经典 [Apple folklore](http://www.folklore.org/StoryView.py?story=Calculator_Construction_Set.txt)：在“Steve Jobs Roll Your Own Calculator Construction Set”，Xcode 6 的风格：

![Calculator Construction Set]({{ site.asseturl }}/IBInspectable-CCS.gif)

* * *
<br>

现在你差不多已经眼见为实了，那让我们来看看更多的图片吧。*你*用这些强大的新工具创造了什么？把你的 `IBInspectable` 或 `IBDesignable` 创作加上话题 `＃IBInspectable` [po 成一张图片](http://twitter.com/share?hashtags=IBInspectable)，我们都可以看看还可以学到些什么。
