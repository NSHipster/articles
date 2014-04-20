---
layout: post
title: "NSHipster Quiz #1"
translator: Ricky Tan
ref: "http://www.uikonf.com/2013/03/25/nshipster-quiz-night.html"
framework: Trivia
rating: 10.0
description: "Test your knowledge of general programming knowledge, Cocoa APIs, and Apple trivia in this first-ever NSHipster Quiz. How NSHip are you?"
---

4月9日，首届 [NSHipster Pub Quiz](http://www.uikonf.com/2013/04/11/nshipster-pub-quiz.html) 在柏林举行。考虑到你们传统酒吧竞猜与“难倒专家”的结合，比赛中问到了一些你们知道且关心的东西：电脑、编程、苹果公司的琐事之类的事情。此次活动由 [UIKonf](http://www.uikonf.com) 主办，并由它的组织成员 [Chris Eidhof](http://twitter.com/chriseidhof)，[Matt Patterson](http://twitter.com/fidothe) 和 [Peter Bihr](http://twitter.com/peterbihr) 最终实施。再次感谢 Chris，Matt 和 Peter，以及到场的各位，让活动如此精彩。

总共50多人出席，组成了12支左右的队伍，每队最多6人，取了诸如“NSBeep”，“alloc] win_it]” 和 “- Bug Fixes / - Performance Improvements”之类的队名。当晚，[CodeKollectiv](http://codekollektiv.com) 队拿下30分，取得了冠军。

以下是在家独自玩的游戏规则：

- 一共四轮，每轮10个问题
- 答案分开写在答题纸上
- 每个正确答案得1分
- 为让游戏更加有趣，最多跟5个朋友一起玩
- 不能上网或打开 Xcode

* * *

第一轮：常识
--------------------------

0. `NS`表示什么？
1. 当乔布斯发布 iPhone 时，他给星巴克打了个恶作剧电话。他订了多少拿铁？
  a. 3000
  b. 4000
  c. 6000
2. NSOperation 有4个被用作 keypath 的属性用来表示状态。它们是什么？
3. 在答题纸上画出带有 `UITableViewCellStyleValue2` 风格的 `UITableViewCell`。
4. UIKit 中哪个协议有 `–tableView:heightForRowAtIndexPath:` 方法？
5. `BOOL`的存储类型是什么？_(即 `typedef` 定义)_
6. Unix 的新纪元是哪年？提示：NSDate 中有个初始化函数指代了它。
7. 当前 Xcode 是多少版？
8. NSHipster 上的第一篇文章是什么？
9. 第一代 iPhone 的主屏上有多少个应用？

第二轮：接口
-------------

你将给定类名，以及属性或者方法的描述。你需要告诉我该类的方法或属性的名字。

1. `UIView`：“一个标志位，决定视图在边界变化时如何布局子视图”
2. `UIAccessibility`：“在可访问性元素上执行一个动作的结果的简要的本地化的描述”
3. `UIColor`：“返回一个颜色对象，RGB 值分别为0.0，1.0，1.0，透明值为 1.0”
4. `UIAlertView`：“当用户点击警告视图的按钮时，发送给代理对象”
5. `UIButton`：“一个布尔值决定当用户点击时是否发光”
6. `UITableView`：“用指定动画效果重新加载某些行”
7. `UITableViewDataSource`：“通知数据源返回指定节的行数”
8. `UIWebView`：“设置主页内容及基准地址”
9. `UIGestureRecognizer`：“当相关视图中有一个或多个手指接触按下时通知消息接收者”
10. `UIDictationPhrase`：“口语短语最可能的文本解释”


第三轮：图片
----------------------

- 1. 这是什么？

![Question 1](http://nshipster-quiz-1.s3.amazonaws.com/question-1.jpg)

- 2. 这是什么？

![Question 2](http://nshipster-quiz-1.s3.amazonaws.com/question-2.jpg)

- 3. 这是什么？

![Question 3](http://nshipster-quiz-1.s3.amazonaws.com/question-3.jpg)

- 4. 这是什么？

![Question 4](http://nshipster-quiz-1.s3.amazonaws.com/question-4.jpg)

- 5. 这他妈是什么？

![Question 5](http://nshipster-quiz-1.s3.amazonaws.com/question-5.jpg)

- 6. 这是谁？

![Question 6](http://nshipster-quiz-1.s3.amazonaws.com/question-6.jpg)

- 7. 这是谁？

![Question 7](http://nshipster-quiz-1.s3.amazonaws.com/question-7.jpg)

- 8. 这是谁？

![Question 8](http://nshipster-quiz-1.s3.amazonaws.com/question-8.jpg)

- 9. 这是谁？

![Question 9](http://nshipster-quiz-1.s3.amazonaws.com/question-9.jpg)

- 10. 这张照片中，比尔·盖茨和乔布斯在2007的D5会议中接受左边超出边界的一男一女的采访。他们是谁？（每人1分）

![Question 10](http://nshipster-quiz-1.s3.amazonaws.com/question-10.jpg)


第四轮：说出框架名！
-----------------------------

每个问题中列出了同一个框架中的三个类的名字，名字都去除了命名空间前缀。指出它们所属的框架！

1. Color List, Matrix, Sound
2. Composition, URL Asset, Capture Session
3. Enclosure, Author, Feed
4. Geocoder, Location, Region
5. Merge Policy, Mapping Model, Incremental Store
6. Analysis, Summary, Search
7. Record, Person, MultiValue
8. View, View Controller, Skybox Effect
9. Central Manager, Descriptor, Peripheral Delegate
10. Filter, Face Feature, Vector


* * *

# 答案

第一轮：常识
--------------------------

1. [NeXTSTEP](http://en.wikipedia.org/wiki/NeXTSTEP)
2. [4000](http://www.macrumors.com/2013/03/04/steve-jobs-4000-latte-prank-order-lives-on-at-san-francisco-starbucks/)
3. [`isReady`, `isExecuting`, `isFinished`, `isCancelled`](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html%23//apple_ref/doc/uid/TP40004591-RH2-DontLinkElementID_1)
4. [    textLabel detailTextLabel   ](http://developer.apple.com/library/ios/DOCUMENTATION/UserExperience/Conceptual/TableView_iPhone/Art/tvcellstyle_value2.jpg)
5. [`UITableViewDelegate`](http://developer.apple.com/library/ios/documentation/uikit/reference/UITableViewDelegate_Protocol/Reference/Reference.html#//apple_ref/doc/uid/TP40006942-CH3-SW25)
6. [`signed char`](http://nshipster.com/bool/)
7. [Midnight UTC, 1 January 1970](http://en.wikipedia.org/wiki/Unix_epoch)
8. [4.6.2 (4H1003)](http://en.wikipedia.org/wiki/Xcode)
9. [NSIndexSet](http://nshipster.com/nsindexset/)
10. [16](http://en.wikipedia.org/wiki/IPhone_%281st_generation%29)

第二轮：接口
-------------

1. `@contentMode`
2. `@accessibilityHint`
3. `+cyanColor`
4. `-alertView:clickedButtonAtIndex:`
5. `@showsTouchWhenHighlighted`
6. `-reloadRowsAtIndexPaths:withRowAnimation:`
7. `-tableView:numberOfRowsInSection:`
8. `-loadHTMLString:baseURL:`
9. `-touchesBegan:withEvent:`
10. `@text`

第三轮：图片
----------------------

1. [Apple I](http://en.wikipedia.org/wiki/Apple_I)
2. [Apple eMac](http://en.wikipedia.org/wiki/EMac)
3. [Apple Bandai Pippin](http://en.wikipedia.org/wiki/Apple_Bandai_Pippin)
4. [Apple QuickTake](http://en.wikipedia.org/wiki/Apple_QuickTake)
5. [New Proposed Apple Campus / "Mothership"](http://www.cultofmac.com/108782/apples-magnificent-mothership-campus-gets-new-renders-and-more-details-report/)
6. [Sir Jonathan "Jony" Ive](http://en.wikipedia.org/wiki/Jonathan_Ive)
7. [Scott Forstall](http://en.wikipedia.org/wiki/Scott_Forstall)
8. [Bob Mansfield](http://en.wikipedia.org/wiki/Bob_Mansfield)
9. [Susan Kare](http://en.wikipedia.org/wiki/Susan_kare)
10. [Kara Swisher & Walt Mossberg ](http://allthingsd.com/20071224/best-of-2007-video-d5-interview-with-bill-gates-and-steve-jobs/)

第四轮：说出框架名！
-----------------------------

1. [App Kit](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/ApplicationKit/ObjC_classic/_index.html)
2. [AV Foundation](https://developer.apple.com/library/mac/#documentation/AVFoundation/Reference/AVFoundationFramework/_index.html)
3. [Publication Subscription](http://developer.apple.com/library/mac/#documentation/InternetWeb/Reference/PubSubReference/_index.html#//apple_ref/doc/uid/TP40004649)
4. [Core Location](http://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CoreLocation_Framework/_index.html)
5. [Core Data](http://developer.apple.com/library/ios/#documentation/cocoa/Reference/CoreData_ObjC/_index.html)
6. [Search Kit](https://developer.apple.com/library/mac/#documentation/UserExperience/Reference/SearchKit/Reference/reference.html)
7. [Address Book](http://developer.apple.com/library/ios/#documentation/AddressBook/Reference/AddressBook_iPhoneOS_Framework/_index.html)
8. [GLKit](http://developer.apple.com/library/mac/#documentation/GLkit/Reference/GLKit_Collection/_index.html)
9. [Core Bluetooth](http://developer.apple.com/library/ios/#documentation/CoreBluetooth/Reference/CoreBluetooth_Framework/_index.html)
10. [Core Image](https://developer.apple.com/library/mac/#documentation/graphicsimaging/Conceptual/CoreImaging/ci_intro/ci_intro.html)

* * *

你感觉如何？在 Twitter 上发布你的得分，看看超过你的小伙伴们多少吧！
