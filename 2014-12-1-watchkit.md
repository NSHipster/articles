---
layout: post
title: WatchKit
author: Mattt Thompson
category: ""
translator: Bob Liu
excerpt: "看过WatchKit之后，会有许多东西从UIKit里冒出来。这些主观、固执己见的东西不太好整理成文档。但是对于正在学习的人来说，可能是有趣或是有用的。"
---

[ᴡᴀᴛᴄʜ](http://www.apple.com/watch/) 令每个人们兴奋。对于开发者来说更甚。

入门学习最好的方法是什么？只有 [Apple's WatchKit developer resources](https://developer。apple.com/watchkit/)。

- 观看 "Getting Started" 视频—就像是身处 Moscone（一个会展中心）。
- 阅读 [Human Interface Guidelines](https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/WatchHumanInterfaceGuidelines/index.html)—考虑到它是你设计你程序的先决条件。
- 精读介绍此框架方方面面的 [WatchKit Programming Guide] (https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/WatchKitProgrammingGuide/index.html) 和[WKInterfaceCatalog](https://developer.apple.com/library/prerelease/ios/samplecode/WKInterfaceCatalog/Introduction/Intro.html)。
- 当你最后准备给你的 app 增加对手表的拓展，查阅下 [Lister Sample App] (https://developer.apple.com/library/prerelease/ios/samplecode/Lister/Introduction/Intro.html) (使用 Objective-C & Swift !)，看是如何在一起适配的。

苹果开发者公共资源、开发布道活动、WatchKit 开发团队给 WatchKit 打好了基础。官方的资源是极好的。

即便如此，在阅读全部之后之后，由于与UIKit相关联，一些东西映入眼帘。他们主观、固执己见的东西不太好整理成文档，但是对于正在学习的人来说，可能是有趣或是有用的。

所以这周给大家介绍一个从 iOS 开发者的视角对于 WatchKit 的初步印象。

* * *

当平台的制约成为限制开发者的角色的时候，WatchKit 倾听了最为早期的 iOS 开发。相比 OS X & AppKit 之前参差不齐的十年，iPhoneOS & UIKit 像一阵清风。Apps 也是小巧的、简单的、短小的。

在经历了7年时间和许多重大版本的发布，从 iPhones 和 iPads 的全部尺寸和形状到 TV 和 CarPlay ，iOS 已经成长到包含无数设备型号和配置了。这仍然是一个令开发者惊异的体验（大部分是这样的），但是感觉魔力也失去了前进的方向。

> **参照物**： 回忆是不好的。 记得以前那些日子，没有 ARC，没有 GCD，没有 Interface Builder 对于 iOS 的支持，更加没有 Swift 。那段时间必不可少的开源库 Three20 和 asi-http-request 。那时候对于 tableview 的滑动展现的工艺水平是在 cell 的 contentView 调用 `drawRect:` 函数，手动的填上文字和图片。生活是孤独、贫穷、艰险、粗野和短暂的。

不管你从哪里来，WatchKit 的简单将会令人愉悦和庆幸。

## 和UIKit相比较

考虑到可共享和分享的目标，WatchKit 具有和 UIKit 惊人的相似，这一点也不令人吃惊。手表不同于手机和平板电脑，他们放在桌面上并不相同。一些概念是可以共用的，但是每一个概念都会有自己独特的目的和限制，以形成他们自己的软件轮廓。

为了对比，这张表格怎么依据 UIKit / Cocoa 的概念去理解WatchKit。

| WatchKit                                 | UIKit                                              |
|------------------------------------------|----------------------------------------------------|
| `WKInterfaceController`                  | `UIViewController`                                 |
| `WKUserNotificationInterfaceController`  | `UIApplicationDelegate` + `UIAlertController`      |
| `WKInterfaceDevice`                      | `UIDevice`                                         |
| `WKInterfaceObject`                      | `UIView`                                           |
| `WKInterfaceButton`                      | `UIButton`                                         |
| `WKInterfaceDate`                        | `UILabel` + `NSDateFormatter`                      |
| `WKInterfaceGroup`                       | `UIScrollView`                                     |
| `WKInterfaceImage`                       | `UIImageView`                                      |
| `WKInterfaceLabel`                       | `UILabel`                                          |
| `WKInterfaceMap`                         | `MKMapView`                                        |
| `WKInterfaceSeparator`                   | `UITableView.separatorColor` / `.separatorStyle`   |
| `WKInterfaceSlider`                      | `UIStepper` + `UISlider`                           |
| `WKInterfaceSwitch`                      | `UISwitch`                                         |
| `WKInterfaceTable`                       | `UITableView`                                      |
| `WKInterfaceTimer`                       | `UILabel` + `NSDateFormatter` + `NSTimer`          |

> 作为前缀 [namespace prefix](http://nshipster.com/namespacing/)，`WKInterface` 别出心裁，但是 `WK` 是伴随新的 [WebKit](http://nshipster.com/wkwebkit/)框架最近才发布的。尽管手表平台可以有网页还有很长一段路要走，但把他们区别开来的决定还是非常明智的。

尽管有许多的重叠，但是也会有很多不同。理解这其中的区别既可以为如何将 WatchKit 做好提供资源信息，还可以教给我们苹果是如何思考 API 和时间可持续进步的。

### WKInterfaceController

 `WKInterfaceController` 在场景中管理元素， 然而 `UIViewController` 管理一个页面和他的子页面。 Interface objects 不是页面组， 但它缺扮演相似的角色。

 为 `WKInterfaceController` 设计的初始化程序是 `initWithContext:`， 它接收 `context` 为参数：

```swift
override init(context: AnyObject?) {
    super.init(context: context)

    // ...
}
```

什么是 `context` ? 它是你想要的任何事情： 一个日期， 一个字符串， 一个数据模型，或者什么也不是。
`context` 的开放性一开始可能会让你迷惑，但是实际上它是对于 UIKit 长期存在问题提出来一种非常聪明的解决方式-即视图与控制器之间很难传递信息。在 `UIViewController` 被压栈，退栈，展出时候，没有一个标准统一的传递数值的方法，开发者经常遇见艰难的的选择，自定义初始器（不完全被Storyboards兼容），属性设定（容易创建控制伴随不完整的状态），自定义代理（如果做到正确，过于正式），或是用通知（额。。。不太好）。许多应用使用 Core Data 传递信息，通过在 App 代理里面存入其引用 `managedObjectContext` 的模型。

但是，我走题了。

总的来说， `WKInterfaceController` 的API不是那么有迹可循，但是没有比他的生命周期的方法更好说明的问题的了：

```swift
// MARK: - WKInterfaceController

override func willActivate() {
    // ...
}

override func didDeactivate() {
    // ...
}
```

那正是想要的点：2个相互对应的方法。 No loading / unloading， no will / did appear / disappear， no `animated:YES` 。手表应用必然非常的简单。iOS 设备驱动应用和手表的通信都是耗时和耗电的，所有的交互控制器场景的初始化都是使用初始器和 `willActivate` 就全部完成了。 在执行`didDeactivate`之后，手表将会忽略页面内交互元素的更新。

手表的应用不是分层（Hierarchical）就是基于页面（Page-Based）。这就是熟悉的Xcode的工程模板，例如："Master-Detail Application" ， "Page-Based Application" ， 和 "Tabbed Application" ，只可惜设计选项的被排除在外。

分层（Hierarchical）的应用里面有个隐藏的导航栈， `WKInterfaceController` 可以管理 `
-pushControllerWithName:context:` 和 `-popController` 方法。需要注意一点是如何获取的字符串-在Storyboard里所指定的控制器的名称-而不是控制器实例本身。

另一方面，基于页面（Page-Based）的应用类似于可横向或者可纵向滚动的 `UIScrollView`，一些预先加载的场景都是用控制器来管理的。判断哪个使用场景最适合使用分层（Hierarchical）还是基于页面（Page-Based）的交互将会十分有趣。没有使用过真实的设备，仅凭猜想也没有太多的线索去了解。

最后一点，有一个有趣的例子使用的苹果的Swift简单代码，使用了内置结构体（inner structs）作为Storyboard的常量：


```swift
class WatchListsInterfaceController: WKInterfaceController， ListsControllerDelegate {
    struct WatchStoryboard {
        static let interfaceControllerName = "WatchListsInterfaceController"

        struct RowTypes {
            static let list = "WatchListsInterfaceControllerListRowType"
            static let noLists = "WatchListsInterfaceControllerNoListsRowType"
        }

        struct Segues {
            static let listSelection = "WatchListsInterfaceControllerListSelectionSegue"
        }
    }

    // ...
}
```

### WKInterfaceObject

`WKInterfaceObject` 好像 `UIView` 的翻译，包括属性 `alpha` ， `hidden` ， `horizontal` & `vertical` ，`alignment` ，和 `width` & `height`。

最显著的不同是没有了 `frame` 。 取而代之的是手动的指定坐标点和设置自动布局适应，WatchKit interface objects 在网隔里根据边缘和各自的顺序布局，就好像过去使用 CSS 的框架工作，好像[Bootstrap](http://getbootstrap.com) (或者你是一名 Rubyists 还记得[Shoes](http://shoesrb.com)吗?)。

另一些不同于 Cocoa Touch 是，`WKInterfaceObject` 使用对象-动作（ Target-Action ） 的方法对每个类型控制器来说只需要调用固定格式的方法，而不是动态的传递 `sender` 和 `UIEvent`。

| Object       |   Action Method                                            |
|--------------|------------------------------------------------------------|
| Button       |   `- (IBAction)doButtonAction`                             |
| Switch       |   `- (IBAction)doSwitchAction:(BOOL)on`                    |
| Slider       |   `- (IBAction)doSliderAction:(float)value`                |
| Table        |   `- (IBAction)doTableRowTapAction:(NSInteger)rowIndex`    |
| Menu Item    |   `- (IBAction)doMenuItemAction`                           |


为了更小， 关闭了控制器的状态集合， 这种方法更加的吸引人—比起输入 `UIControlEventTouchUpInside` 更加优秀。

### WKInterfaceButton

`WKInterfaceButton`是一个接口对象（interface object），它可以被点击来触发动作。它的可以包含是单一的文本标签或者是一组标签。

最新的部分更新的部分-有能力包含一个组-非常的_大_。这样避免了人们之前对 `UIButton` 的抱怨，它们使用起来非常困难，增加子视图和获得其视图位置以及正确的交互，致使人们只好放弃，并且去使用 `UITapGestureRecognizer`。

### WKInterfaceTable

所有从 iOS 中传来的概念中，列表可能是变化最大的。`UITableView` 是 iPhone 程序的支柱。因此，他们形成了相当复杂度去处理大量的应用数据需求，这些数据需要用各种方式去展现。相比之下`WKInterfaceTable`似乎另一番景象。

WatchKit 列表没有 sections 或者 headers， 或 footers， 或 editing， 或 searching， 或 data sources， 或 delegates。 行在`WKInterfaceController -willActivate` 方法之前被填充， 每行都有他自己对应的控制器(一个 `NSObject` 的子类和 一些`IBOutlet`)。 `WKInterfaceController`可以对列表的交互进行反馈，通过 `table:didSelectrowAtIndex:` 的代理方法，或者是用之前提供的对象-动作的方法`。

它可能看起来和之前十分不同，但是这种方法十分适合手表，并且相比 iOS 更加的直接。

### WKInterfaceLabel

相比之下，`WKInterface` 可能是从iOS中变化最小的。支持 `NSAttributedString` ，自定义字体以及字体的尺寸，他几乎和你所能知道的一切一样的。

### WKInterfaceDate & WKInterfaceTimer

我们不会忘记对于手表时间是非常重要的概念。因此，WatchKit介绍了两个新的接口对象（interface object），他们在Cocoa 或者 Cocoa Touch 并先例：`WKInterfaceDate` 和 `WKInterfaceTimer` 。

`WKInterfaceDate` 是一个特殊的标签，它用来展示目前的日期或是时间。`WKInterfaceTimer` 相似，除了它可以到指定日期并且倒计时。

以上两个类就像其他的 WatchKit 里面的类一样，确保了 app 的质量。考虑到这些任务对于手表的重要性，以及菜鸟程序员在运用 `NSDateFormatter` 和 `NSTimer` 时的情形，我们终于想象一下这些现象都消除了。

### WKInterfaceSlider & WKInterfaceSwitch

滑动条和开关应该在手表上回归。没有了触摸手势的福利，交互回归到基础。_Tap， Tap_， `On` / `Off`。 _Tap， Tap_， `+` / `-`。

`WKInterfaceSlider` 和 `WKInterfaceSwitch` 便显出高水准和易自定义性。

* * *

当然，以上文字只是对WatchKit浅显的思考。就像文章一开始我写到的，[Apple's official resources for WatchKit](https://developer.apple.com/watchkit/)包括了任何你想到的事情。

