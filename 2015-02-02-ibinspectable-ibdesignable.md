---
title: "IBInspectable / IBDesignable"
category: Xcode
author: Nate Cook
excerpt: "Replacing an interface that requires us to memorize and type with one we can see and manipulate can be a enormous improvement. With `IBInspectable` and `IBDesignable`, Xcode 6 makes just such a substitution, building new interactions on top of old technologies."
translator: April Peng
excerpt: "在替换一个界面的时候如果我们能够看见和控制那将比需要我们记住并且输入什么进步了很多。Xcode 6 提供了这样一个替代，用 `IBInspectable` 和 `IBDesignable`，在旧技术上建立新的互动。"
---

Show, don't tell. Seeing is believing. A picture is worth a thousand <del>emails</del> words. 

展示，而不是描述。眼见为实。一图胜千<del>邮件</del>言。

Whatever the cliché, replacing an interface that requires us to memorize and type with one we can see and manipulate can be a enormous improvement. Xcode 6 makes just such a substitution, building new interactions on top of old technologies. With `IBInspectable` and `IBDesignable`, it's possible to build a custom interface for configuring your custom controls and have them rendered in real-time while designing your project.

无论陈词滥调多少次，在替换一个界面的时候如果我们能够看见和控制那将比需要我们记住并且输入什么进步了很多。 Xcode 6 提供了这样一个替代，在旧技术上建立新的互动。在设计项目的时候建立一个自定义的界面使你可以配置自定义控制并将它们实时显示出来，用 `IBInspectable` 和 `IBDesignable`，这将成为可能。


## IBInspectable

`IBInspectable` properties provide new access to an old feature: user-defined runtime attributes. Currently accessible from the identity inspector, these attributes have been available since before Interface Builder was integrated into Xcode. They provide a powerful mechanism for configuring any key-value coded property of an instance in a NIB, XIB, or storyboard:

`IBInspectable` 属性提供了访问旧功能的新方式：用户自定义的运行时属性。从目前的身份检查器（identity inspector）中访问，这些属性在 Interface Builder 被整合到 Xcode 之前就可用了。他们提供了一个强有力的机制来配置一个 NIB，XIB，或者 storyboard 实例中的任何键 - 值编码属性：

![User-Defined Runtime Attributes](http://nshipster.s3.amazonaws.com/IBInspectable-runtime-attributes.png)

While powerful, runtime attributes can be cumbersome to work with. The key path, type, and value of an attribute need to be set on each instance, without any autocompletion or type hinting, which requires trips to the documentation or a custom subclass's source code to double-check the settings. `IBInspectable` properties solve this problem outright: in Xcode 6 you can now specify any property as inspectable and get a user interface built just for your custom class.

虽然功能强大，运行时属性可能会使工作很繁琐。一个属性的关键字路径，类型和属性值需要在每个实例设置，没有任何自动完成或输入提示，这就需要前往文档或自定义子类的源代码仔细检查设置。 `IBInspectable` 属性彻底的解决了这个问题：在 Xcode 6，你现在可以指定任何属性作为可检查项并为你的自定义类建立了一个用户界面。

For example, these properties in a `UIView` subclass update the backing layer with their values:

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

Marked with `@IBInspectable` (or `IBInspectable` in Objective-C), they are easily editable in Interface Builder's inspector panel. Note that Xcode goes the extra mile here—property names are converted from camel- to title-case and related names are grouped together:

标有 `@IBInspectable`（或是 Objective-C 中的 `IBInspectable`），他们就可以很容易在 Interface Builder 的观察面板（inspector panel）里编辑。需要注意的是 Xcode 在这里做了更多的事，属性名称是从 camel- 转换为 title- 模式 并且相关的名称组合在一起：

![IBInspectable Attribute Inspector](http://nshipster.s3.amazonaws.com/IBInspectable-inspectable.png)

Since inspectable properties are simply an interface on top of user-defined runtime attributes, the same list of types is supported: booleans, strings, and numbers (i.e., `NSNumber` or any of the numeric value types), as well as `CGPoint`, `CGSize`, `CGRect`, `UIColor`, and `NSRange`, adding `UIImage` for good measure.

因为可检查属性仅仅是用户定义的运行时属性顶部的接口，所以支持相同的类型列表：布尔，字符串和数字（即，`NSNumber` 或任何数值类型），以及 `CGPoint`、`CGSize`、`CGRect`、`UIColor` 和 `NSRange`，额外增加了 `UIImage`。

> Those already familiar with runtime attributes will have noticed a bit of trickery in the example above. `UIColor` is the only color type supported, not the `CGColor` native to a view's backing `CALayer`. The `borderColor` computed property maps the `UIColor` (set via runtime attribute) to the layer's required `CGColor`.

> 那些已经熟悉运行时属性的人将注意到在上面的例子中有一些问题。`UIColor` 是里面唯一支持色彩的类型，而不是原生支持视图 `CALayer` 的 `CGColor`。`borderColor` 会计算 `UIColor` 属性（通过运行时属性设置）并映射到该层需要的 `CGColor`。


### Making Existing Types Inspectable

### 让现有的类型可观察

Built-in Cocoa types can also be extended to have inspectable properties beyond the ones already in Interface Builder's attribute inspector. If you like rounded corners, you'll love this `UIView` extension:

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

Presto! A configurable border radius on any `UIView` you create.

变！你创建的任何 `UIView` 都将有一个可配置的边界半径。


## IBDesignable

As if that weren't enough, `IBDesignable` custom views also debut in Xcode 6. When applied to a `UIView` or `NSView` subclass, the `@IBDesignable` designation lets Interface Builder know that it should render the view directly in the canvas. This allows seeing how your custom views will appear without building and running your app after each change.

如果这还不够，`IBDesignable` 自定义视图也在 Xcode 6 中亮相了。当应用到 `UIView` 或 `NSView` 子类中的时候，`@ IBDesignable` 让 Interface Builder 知道它应该在画布上直接渲染视图。你会看到你的自定义视图在每次更改后不必编译并运行你的应用程序就会显示。

To mark a custom view as `IBDesignable`, prefix the class name with `@IBDesignable` (or the `IB_DESIGNABLE` macro in Objective-C). Your initializers, layout, and drawing methods will be used to render your custom view right on the canvas:

标记一个自定义视图为 `IBDesignable`，只需在类名前加上 `@IBDesignable` 的前缀（或是 Objective-C 里的 `IB_DESIGNABLE` 宏）。你的初始化、布置和绘制方法将被用来在画布上渲染你的自定义视图：

````swift
@IBDesignable
class MyCustomView: UIView {
    ...
}
````

![IBDesignable Live Preview](http://nshipster.s3.amazonaws.com/IBInspectable-designable.png)

The time-savings from this feature can't be understated. Combined with `IBInspectable` properties, a designer or developer can easily tweak the rendering of a custom control to get the exact result she wants. Any changes, whether made in code or the attribute inspector, are immediately rendered on the canvas.

从这个功能上节约的时间是不能被低估的。加上 `IBInspectable` 属性，一个设计师或开发人员可以轻松地调整自定义控件的呈现，以得到她想要的确切的结果。任何改变，无论是从代码或属性检查器中，都将立即呈现在画布上。

Moreover, any problems can be debugged without compiling and running the whole project. To kick off a debugging session right in place, simply set a breakpoint in your code, select the view in Interface Builder, and choose **Editor** ➔ **Debug Selected Views**.

此外，任何问题都是可避开编译和运行整个程序来调试的。调试的方法很简单，只需在你的代码中设置一个断点，在 Interface Builder 中选择视图，并选择 **Editor** ➔ **Debug Selected Views**。

Since the custom view won't have the full context of your app when rendered in Interface Builder, you may need to generate mock data for display, such as a default user profile image or generic weather data. There are two ways to add code for this special context:

由于在 Interface Builder 中呈现自定义视图不会有应用程序的完整上下文，你可能需要生成模拟数据以便显示，例如一个默认用户头像图片或仿制的天气数据。有两种方法可以为这个特殊的上下文添加代码：

> - `prepareForInterfaceBuilder()`: This method compiles with the rest of your code but is only executed when your view is being prepared for display in Interface Builder.

> - `prepareForInterfaceBuilder()`：此方法与你代码的其余部分一起编译，但只有当视图正在准备在 Interface Builder 显示时执行。


> - `TARGET_INTERFACE_BUILDER`: The `#if TARGET_INTERFACE_BUILDER` preprocessor macro will work in either Objective-C or Swift to conditionally compile the right code for the situation:

> - `TARGET_INTERFACE_BUILDER`：`#if TARGET_INTERFACE_BUILDER` 预处理宏在 Objective-C 或 Swift 下都是工作的，它会视情况编译正确代码：


> ````swift
#if !TARGET_INTERFACE_BUILDER
    // this code will run in the app itself
#else
    // this code will execute only in IB
#endif
````


## IBCalculatorConstructorSet

What can you create with a combination of `IBInspectable` attributes in your `IBDesignable` custom view? As an example, let's update an old classic from [Apple folklore](http://www.folklore.org/StoryView.py?story=Calculator_Construction_Set.txt): the "Steve Jobs Roll Your Own Calculator Construction Set", Xcode 6-style:

把自定义 `IBDesignable` 视图和视图里的 `IBInspectable` 属性结合在一起，你能干点啥？作为一个例子，让我们更新老式经典 [Apple folklore](http://www.folklore.org/StoryView.py?story=Calculator_Construction_Set.txt)：在“Steve Jobs Roll Your Own Calculator Construction Set”，Xcode 6 的风格：

![Calculator Construction Set](http://nshipster.s3.amazonaws.com/IBInspectable-CCS.gif)

* * *
<br>

That was almost a thousand words—let's see some more pictures. What are *you* creating with these powerful new tools? [Tweet an image](http://twitter.com/share?hashtags=IBInspectable) of your `IBInspectable` or `IBDesignable` creations with the hashtag `#IBInspectable`—we can all learn from seeing what's possible.

这差不多就是千言万语了，让我们来看看更多的图片。*你*用这些强大的新工具创造了什么？把你的 `IBInspectable` 或 `IBDesignable` 创作加上话题 `＃IBInspectable` [po 成一张图片](http://twitter.com/share?hashtags=IBInspectable)，我们都可以看看还可以学到些什么。