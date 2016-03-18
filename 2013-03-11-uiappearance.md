---
title: UIAppearance
author: Mattt Thompson
translator: Chester Liu
category: Cocoa
tags: nshipster
excerpt: "UIAppearance allows the appearance of views and controls to be consistently defined across the entire application."
excerpt: "UIAppearance 允许我们对视图和控件的样式在整个应用范围内进行统一的定义。"

status:
    swift: 2.0
    reviewed: September 8, 2015
---

Style vs. Substance.
Message vs. Medium.
Rhetoric vs. Dialectic.

美观还是实际？直接还是间接？感情还是理智？

Is beauty merely skin deep, or is it somehow informed by deeper truths?
What does it mean for something to possess good design?
Are aesthetic judgments relative, or absolute?

美，究竟是肤浅的一个概念，还是深层事实的一种表层体现？当我们说一个东西具有好的设计的时候，我们到底在谈论什么？审美的标准是相对的还是绝对的？

These are deep questions that have been pondered by philosophers, artists, and makers alike for millennia.

这些深刻的问题，哲学家，艺术家和手工艺者们已经深思了近千年。

And while we all continue our search for beauty and understanding in the universe, the app marketplace has been rather clear on this subject:

在我们继续追寻美的意义和对于宇宙更深的理解的同时，应用市场对于这个话题的反映倒很明确：

**Users will pay a premium for good-looking software.**

**用户愿意为好看的软件花大价钱。**

When someone purchases an iPhone, they are buying into Apple's philosophy that things that work well should look good, too. The same goes for when we choose to develop for iOS—a sloppy UI reflects poorly on the underlying code.

当一个人买了一台 iPhone 的时候，他同时也是“买”了苹果的哲学——所有好用的东西也应该是好看的。同样的道理也适用于开发领域，粗糙的界面会让人们感觉代码也不会好到哪里去。

It used to be that even trivial UI customization on iOS required AppStore-approval-process-taunting ju-ju like method swizzling. Fortunately, with iOS 5, developers were given an easier way: `UIAppearance`.

在以前的 iOS 开发中，一些很细小的界面定制工作也需要用到一些会影响到 AppStore 审核的办法，例如 method swizzling。幸运的是，在 iOS 5 上，出现一种新的解决办法：`UIAppearance`。

---

`UIAppearance` allows the appearance of views and controls to be consistently defined across the entire application.

`UIAppearance` 允许我们对视图和控件的样式在整个应用范围内进行统一的定义。

In order to have this work within the existing structure of UIKit, Apple devised a rather clever solution: `UIAppearance` is a protocol that returns a proxy that will forward any configuration to instances of a particular class. Why a proxy instead of a property or method on `UIView` directly? Because there are non-`UIView` objects like `UIBarButtonItem` that render their own composite views.
Appearance can be customized for all instances, or scoped to particular view hierarchies:

为了让这个机制融入已有的 UIKit 体系，苹果设计了一个很聪明的办法：`UIAppearance` 是一个协议，它返回一个 proxy，这个 proxy 会把所有的配置都转发给某个特定类的实例们。为什么使用 proxy 而不是在直接在 `UIView` 里添加一个属性或者方法呢？因为有一些不是 `UIView`
的对象也会渲染自己的组合视图，例如 `UIBarButtonItem`。`UIAppearance` 可以定制一个类所有的实例，也可以限定在具体的视图结构中（译者注：下面文档来自苹果官方文档，不再做翻译）：

> - `+appearance`: Returns the appearance proxy for the receiver.
> - `+appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass,...`: Returns the appearance proxy for the receiver in a given containment hierarchy.
>
> To customize the appearance of all instances of a class, you use `appearance()` to get the appearance proxy for the class. For example, to modify the tint color for all instances of UINavigationBar:

```swift
UINavigationBar.appearance().tintColor = myColor
```
```objective-c
[[UINavigationBar appearance] setTintColor:myColor];
```

> To customize the appearances for instances of a class when contained within an instance of a container class, or instances in a hierarchy, you use `appearanceWhenContainedInInstancesOfClasses(_:)` to get the appearance proxy for the class (the older, variadic `appearanceWhenContainedIn` method has been deprecated):

```swift
UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self])
				.tintColor = myNavBarColor
UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self, UIPopoverController.self])
				.tintColor = myNavBarColor
UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UIToolbar.self])
				.tintColor = myNavBarColor
UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UIToolbar.self, UIPopoverController.self])
				.tintColor = myNavBarColor
```
```objective-c
[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]]
       setTintColor:myNavBarColor];
[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], [UIPopoverController class]]]
        setTintColor:myPopoverNavBarColor];
[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class]]]
        setTintColor:myToolbarColor];
[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIToolbar class], [UIPopoverController class]]]
        setTintColor:myPopoverToolbarColor];
```

## Determining Which Properties Work With `UIAppearance`

## 判断 `UIAppearance` 可以应用于哪些属性

One major downside to `UIAppearance`'s proxy approach is that it's difficult to know which selectors are compatible.

`UIAppearance` 使用 proxy 的办法带来的一个主要问题是，很难知道 selector 是不是真正可以用的。

<del>Because <tt>+appearance</tt> returns an <tt>id</tt>, Xcode can't provide any code-completion information. This is a major source of confusion and frustration with this feature.</del>

<del>因为 <tt>+appearance</tt> 返回的是 <tt>id</tt>, Xcode 不能提供任何代码补全信息，这个造成困惑和问题的主要原因</del>

<ins>As of iOS 7, UIAppearance now returns <a href="http://nshipster.com/instancetype/"><tt>instancetype</tt></a>, which allows for code completion to work as expected. Huzzah!</ins>

<ins>在 iOS 7 上, UIAppearance 现在返回的是 <a href="http://nshipster.com/instancetype/"><tt>instancetype</tt></a>，使得代码补全可以正常工作了。 万岁！</ins>

In order to find out what methods work with `UIAppearance`, you have to [look at the headers](http://stackoverflow.com/questions/9424112/what-properties-can-i-set-via-an-uiappearance-proxy):

要想知道哪些方法可以应用于 `UIAppearance`，你得[去头文件中找](http://stackoverflow.com/questions/9424112/what-properties-can-i-set-via-an-uiappearance-proxy)：

```
$ cd /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/
  Developer/SDKs/iPhoneOS*.sdk/System/Library/Frameworks/UIKit.framework/Headers
$ grep -H UI_APPEARANCE_SELECTOR ./* | sed 's/ __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0) UI_APPEARANCE_SELECTOR;//'
```

`UIAppearance` looks for the `UI_APPEARANCE_SELECTOR` macro in method signatures. Any method with this annotation can be used with the `appearance` proxy.

`UIAppearance` 会在方法签名中查找 `UI_APPEARANCE_SELECTOR` 宏。任何有这个注解的方法都可以被 `appearance` proxy 使用。

For your convenience, [here is the list of properties as of iOS 7.0](https://gist.github.com/mattt/5135521).

[这里是 iOS 7.0 上所有的属性列表](https://gist.github.com/mattt/5135521)，方便你参考使用。

## Implementing `<UIAppearance>` in Custom UIView Subclasses

## 在自定义的 UIView 子类中实现 `<UIAppearance>`

Much like how [`NSLocalizedString`](http://nshipster.com/nslocalizedstring/) and [`#pragma`](http://nshipster.com/pragma/) are marks of quality in Objective-C code, having custom UI classes conform to `UIAppearance` is not only a best-practice, but it demonstrates a certain level of care being put into its implementation.

就像 [`NSLocalizedString`](http://nshipster.cn/nslocalizedstring/)  和 [`#pragma`](http://nshipster.cn/pragma/)是高质量的 Objective-C 代码的标志一样，让自定义的界面类支持 `UIAppearance`，不仅仅是一种最佳实践，同时也展示了开发者在代码实现上花费了一定程度的心血。

[Peter Steinberger](https://twitter.com/steipete) has [this great article](http://petersteinberger.com/blog/2013/uiappearance-for-custom-views/), which describes some of the caveats about implementing `UIAppearance` in custom views. It's a must-read for anyone who aspires to greatness in their open source UI components.

[Peter Steinberger](https://twitter.com/steipete) 撰写了 [这篇优秀的博文](http://petersteinberger.com/blog/2013/uiappearance-for-custom-views/)，其中描述了在自定义视图中实现 `UIAppearance` 时需要注意的一些地方。对于在开源 UI 控件中追求极致实现的人来说，这篇文章是必读的。

## Alternatives

## 替代品

Another major shortcoming of `UIAppearance` is that style rules are _imperative_, rather than _declarative_. That is, styling is applied at runtime in code, rather than being interpreted from a list of style rules.

`UIAppearance` 另一个主要的不足之处在于，样式的规则是 _命令式_ 的，而不是 _描述式_ 的。也就是说，样式是在应用执行时在代码中进行应用，而不是从一个规则列表中获取。

Yes, if there's one idea to steal from web development, it's the separation of content and presentation. Say what you will about CSS, but stylesheets are _amazing_.

是的，如果我们可以 Web 开发中偷过来一个主意的话，那一定就是内容和表现分离了。不管你对 CSS 有什么看法，样式表实在是 _美妙之极_ 。

Stylesheet enthusiasts on iOS now have some options. [Pixate](http://www.pixate.com) is a commercial framework that uses CSS to style applications. [NUI](https://github.com/tombenner/nui), an open-source project by [Tom Benner](https://github.com/tombenner), does much the same with a CSS/SCSS-like language. Another open source project along the same lines is [UISS](https://github.com/robertwijas/UISS) by [Robert Wijas](https://github.com/robertwijas), which allows `UIAppearance` rules to be read from JSON.

到目前为止，样式表的狂热爱好者在 iOS 上有几个可选的替代品。[Pixate](http://www.pixate.com) 是一个商业框架，支持使用 CSS 来定制应用样式。[NUI](https://github.com/tombenner/nui)，一个由 [Tom Benner](https://github.com/tombenner) 发起的开源项目，使用类似 CSS/SCSS 的语言，做的差不多是同样的事情。和它同一战线的另一个开源项目是 [UISS](https://github.com/robertwijas/UISS)，由 [Robert Wijas](https://github.com/robertwijas) 发起，允许我们从 JSON 中读取 `UIAppearance` 规则。


---

Cocoa developers have a long history of obsessing about visual aesthetics, and have often gone to extreme ends to achieve their desired effects. Recall the [Delicious Generation](http://en.wikipedia.org/wiki/Delicious_Generation) of Mac developers, and applications like [Disco](http://discoapp.com), which went so far as to [emit virtual smoke when burning a disc](http://www.youtube.com/watch?v=8Dwi47XOqwI).

Cocoa 开发者痴迷于视觉审美的历史可以追溯到很久之前，他们经常会通过很极致的方法来实现想要的效果。回忆一下 Mac 开发者的 [美味时代](http://en.wikipedia.org/wiki/Delicious_Generation)，以及诸如 [Disco](http://discoapp.com) 这样的 App，它[在烧录光盘时会释放出虚拟的烟雾效果](http://www.youtube.com/watch?v=8Dwi47XOqwI)。

This spirit of dedication to making things look good is alive and well in iOS. As a community and as an ecosystem, we have relentlessly pushed the envelope in terms of what users should expect from their apps. And though this makes our jobs more challenging, it makes the experience of developing for iOS all the more enjoyable.

这种决心让东西看起来好看的精神，在 iOS 平台上同样蔚然成风。作为社区和生态系统的一员，在用户对于应用的期望上，我们不懈地努力，去挑战极限。在这个过程中，我们的工作变得更加具有挑战性，也使得开发 iOS 的体验更加像是一种享受。

Settle for nothing less than the whole package.
Make your apps beautiful from interface to implementation.

不要止步于金玉其外败絮其中（反之亦然）。让你的应用从界面到实现都变得优美。

