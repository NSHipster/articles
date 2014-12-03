---
layout: post
title: WatchKit
author: Mattt Thompson
category: ""
translator: Bob Liu
excerpt: "看过WatchKit之后，会有许多东西从UIKit里冒出来。这些主观、固执己见的东西不太好整理成文档。但是对于正在学习的人来说，可能是有趣或是有用的。"
---

[ᴡᴀᴛᴄʜ](http://www.apple.com/watch/)令每个人们兴奋. 对于开发者来说更甚。

什么是开始的学习最好方式? 除了 [Apple's WatchKit developer resources](https://developer.apple.com/watchkit/)。

- 观看 "Getting Started" 视频—就像是身处Moscone（一个会展中心）.
- 阅读[Human Interface Guidelines](https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/WatchHumanInterfaceGuidelines/index.html)—考虑到它是你设计你程序的先决条件。
- 精读介绍此框架方方面面的[WatchKit Programming Guide](https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/WatchKitProgrammingGuide/index.html) 和[WKInterfaceCatalog](https://developer.apple.com/library/prerelease/ios/samplecode/WKInterfaceCatalog/Introduction/Intro.html)。
- 当你最后准备给你的app增加对iwatch的拓展,查阅下[Lister Sample App](https://developer.apple.com/library/prerelease/ios/samplecode/Lister/Introduction/Intro.html) (使用 Objective-C & Swift!)，看是如何在一起适配的。

苹果开发的出版物，开发者的传道和WatchKit的开发团队对于WatchKit的开始是十分出色的。官方的资源是极好的。

即便如此,在阅读全部之后之后,由于与UIKit相关联，一些东西映入眼帘。他们主观、固执己见的东西不太好整理成文档，但是对于正在学习的人来说，可能是有趣或是有用的。

所以这周给大家介绍一个从iOS开发者的视角对于WatchKit的初步印象。

* * *

当平台的制约成为限制开发者的角色的时候，WatchKit倾听了最为早期的iOS开发。相比OS X & AppKit之前参差不齐的十年，iPhoneOS& UIKit像一阵清风。Apps也是小巧的、简单的、短小的。

在经历了7年时间和许多重大版本的发布，从iPhones和iPads的全部尺寸和形状到TV和CarPlay，iOS已经成长到包含无数设备型号和配置了。这仍然是一个令开发者惊异的体验（大部分是这样的），但是感觉魔力也失去了前进的方向。

> **参照物**: 回忆是不好的。 记得以前那些日子，没有ARC，没有GCD，没有Interface Builder对已iOS的支持，更加没有Swift。那段时间必不可少的开源库Three20和asi-http-request。那时候对于tableview的滑动展现的工艺水平是在cell的contentView `drawRect:` 函数里面手动的填上文字和图片。生活是孤独、贫穷、艰险、粗野和短暂的。

不管你从哪里来，WatchKit的简单将会令人愉悦和庆幸。

## 和UIKit相比较

考虑到可以共享的历史和分享的目的，WatchKit具有和UIKit惊人的相似，这一点也不令人吃惊。手表不同于手机和平板电脑，他们放在桌面上并不相同。一些概念是可以共享的，但是每一个概念都会有自己唯一的目的和限制，以形成他们自己的软件面貌。

为了对比, 这张表格怎么依据UIKit / Cocoa的概念去理解WatchKit。

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

> 作为前缀[namespace prefix](http://nshipster.com/namespacing/)，`WKInterface` 别出心裁，但是 `WK` 就其本身而言是伴随新的[WebKit](http://nshipster.com/wkwebkit/)框架最近才发布的。尽管手表平台可以有网页嵌套还有很长一段路要走，但把他们区别开来的决定还是非常明智的。

尽管有许多的重叠，但是也会有很多不同。理解这其中的区别既可以为如何将WatchKit做好提供资源信息，还可以教给我们苹果是如何思考API和时间可持续进步的。

### WKInterfaceController

 `WKInterfaceController` 在场景中管理元素, 然而 `UIViewController` 管理一个页面和他的子页面。 Interface objects不是Views, 但是他们去扮演相似的角色。

 为`WKInterfaceController`设计的初始化程序是 `initWithContext:`, 他接收 `context` 为参数:

```swift
override init(context: AnyObject?) {
    super.init(context: context)

    // ...
}
```
 
什么是 `context`? 它是你想要的任何事情: 一个日期, 一个字符串, 一个数据模型, 或者什么也不是。
`context`的开放性一开始可能会让你迷惑，但是实际上它是对于UIKit长期存在问题的一种非常聪明的解决方式-即view controllers之间很难传递信息。没有一个标准统一的用法，`UIViewController` 被压栈，退栈，展出，开发者经常遇见艰难的的选择，自定义初始器（不完全被Storyboards兼容），属性设定（容易创建控制伴随不完整的状态），自定义代理（如果全部做对，过于正式），或是用通知（仅仅。。。不）。许多应用使用Core Data，并在App代理里面存入其引用`managedObjectContext`的模型。

但是，我走题了。

总的来说, `WKInterfaceController` 的API不是那么有迹可循，而且没有比他的生命周期的方法更好说明的方法:

```swift
// MARK: - WKInterfaceController

override func willActivate() {
    // ...
}

override func didDeactivate() {
    // ...
}
```

那正是要点: 2个方法。 No loading / unloading, no will / did appear / disappear, no `animated:YES`。 Watch apps 必然非常的简单。 iOS设备驱动应用和watch的通信都是耗时和耗电的,所有的交互控制器场景的开始都是使用初始器和 `willActivate` 就全部完成了。 在执行`didDeactivate`之后,Watch将会忽略交互元素的更新状态。

Watch应用不是分层就是基于页面的。这就是熟悉的Xcode的工程模板，例如："Master-Detail Application", "Page-Based Application", 和"Tabbed Application"，除了相互排除的设计选项。

分层的应用包含含蓄的导航栈, `WKInterfaceController` 可以管理 `
-pushControllerWithName:context:` 和 `-popController` 。需要注意一点是如何获取的字符串-在Storyboard里所指定的控制器的名称-而不是控制器实例本身。

另一方面，基于页面的应用类似于横向或者纵向的 `UIScrollView`，一些预先加载的场景管理都是用控制器来管理的。判断哪个使用场景最适合使用分层还是基于页面的交互将会十分有趣。没有使用过真是的设备，仅凭直觉也没有太多的上下文去了解取舍。

最后一点，有一个有趣的例子使用的苹果的Swift简单代码，使用了内置结构体作为Storyboard的常量：


```swift
class WatchListsInterfaceController: WKInterfaceController, ListsControllerDelegate {
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

`WKInterfaceObject` 好像`UIView`的翻译 , 包括属性 `alpha`, `hidden`, `horizontal` & `vertical` alignment, 和 `width` & height.

最显著的不同是没有了`frame`. 取而代之的是手动的指定坐标点或者设置自动布局去限制，WatchKit interface objects 在网隔里根据边缘和各自的顺序布局，就好像过去和CSS的框架工作，好像[Bootstrap](http://getbootstrap.com) (或者你是一名 Rubyists还记得[Shoes](http://shoesrb.com)吗?).

另一些不同于Cocoa Touch是对象-动作方法对每个控制器的类型来说使用的是固定格式的特性，而不是动态的传递`sender` 和 `UIEvent`。

| Object       |   Action Method                                            |
|--------------|------------------------------------------------------------|
| Button       |   `- (IBAction)doButtonAction`                             |
| Switch       |   `- (IBAction)doSwitchAction:(BOOL)on`                    |
| Slider       |   `- (IBAction)doSliderAction:(float)value`                |
| Table        |   `- (IBAction)doTableRowTapAction:(NSInteger)rowIndex`    |
| Menu Item    |   `- (IBAction)doMenuItemAction`                           |


为了更小, 关闭了控制器的状态集合, 这种方法更加的吸引人—比起输入`UIControlEventTouchUpInside`更加优秀。

### WKInterfaceButton

`WKInterfaceButton`是一个interface object对象，它可以被点击来触发动作。它的内容可以是单一的内容标签或者是一组。

最新的部分-有能力包含的组-非常的_大_。这样避免了任何人对 `UIButton`的抱怨，增加子view和位置以及正确的交互的实现难度，将使得人们放弃，并且去使用 `UITapGestureRecognizer`。

### WKInterfaceTable

所有从iOS中转来的概念，列表可能是变化最大的。`UITableView`是iPhone程序的支柱。因此，他们形成了相当复杂去处理大量的应用数据需求，他们需要用各种方式去展现。相比之下`WKInterfaceTable`似乎另一番景象。

WatchKit 列表没有 sections 或者 headers, 或 footers, 或 editing, 或 searching, 或 data sources, 或 delegates. 行在`WKInterfaceController -willActivate`之前被填充, 每行都有他自己对应的控制器(一个 `NSObject` 的子类和 `IBOutlet`s)。 `WKInterfaceController`可以对列表的交互进行反馈，通过`table:didSelectrowAtIndex:`的代理方法，或者是用之前提供的对象-动作的方法`。

它可能看起来不是十分相似，但是这种方法十分适合watch，并且相比iOS是否的更加的直接。

### WKInterfaceLabel

相比之下，`WKInterface`可能是从iOS中变化最小的。支持`NSAttributedString`，自定义字体以及字体的尺寸,他几乎和你所能知道的一切一样的。

### WKInterfaceDate & WKInterfaceTimer

我们不会忘记对于手表时间是非常重要的概念。因此，WatchKit介绍了两个新的interface objects，他们在Cocoa或者Cocoa Touch并先例：`WKInterfaceDate`和`WKInterfaceTimer`。

`WKInterfaceDate`是一个特殊的标签，它用来展示目前的日期或者是时间。 `WKInterfaceTimer` 相似,除了它可以到指定日期并且倒计时。

以上两个类就像其他的WatchKit里面的类一样，确保了app的质量。考虑到这些任务对于手表的重要性，以及菜鸟程序员在运用`NSDateFormatter`和`NSTimer`时的情形，我们终于想象一下这些现象都消除了。

### WKInterfaceSlider & WKInterfaceSwitch

滑动条和开关应该在手表上回归。没有了触摸手势的福利，交互回归到基础。_Tap, Tap_, `On` / `Off`. _Tap, Tap_, `+` / `-`。

`WKInterfaceSlider` 和 `WKInterfaceSwitch`便显出高水准和易自定义性。

* * *

当然，以上文字只是对WatchKit浅显的思考。就像文章一开始我写到的，[Apple's official resources for WatchKit](https://developer.apple.com/watchkit/)包括了任何你想到的事情。

