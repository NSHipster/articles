---
layout: post
title: 单元测试
author: Mattt Thompson
ref: "https://developer.apple.com/library/mac/#documentation/DeveloperTools/Conceptual/UnitTesting/00-About_Unit_Testing/about.html"
framework: Testing
rating: 8.9
translator: Candyan
---

对于开发者来讲，单元测试是一个容易让人激动的话题。它会激发起其热心拥护者的优越感，唤起非从业人员的不足感。[Cargo Cults like TDD](http://ntoll.org/article/tdd-cargo-cult)这篇文章([Cargo Cults](http://zh.wikipedia.org/wiki/%E8%88%B9%E8%B2%A8%E5%B4%87%E6%8B%9C))为他们在单元测试上的名誉打上了共同选择并且道德和工具不分的标签。

这是程序员除了 tabs-versus-spaces 之外，另一个近乎宗教式的辩论。

绝大部分 Objective-C 开发者对于单元测试都不是很在意(_"有 SenTest 这回事，但谁真的回去用哪？"_)。
由于静态类型，易管理的项目规模和先进的编译器[足以为你重写代码](http://clang.llvm.org/doxygen/Rewriter_8h_source.html)，Objective-C 不像 Ruby 这种动态语言对单元测试有那么强的需求(至少在实践中是这样的)。

但这不意味着 Objective-C 的开发者们不会从单元测试中获益。事实上，随着其开源社区的活跃度越来越高，Objective-C 将会变得愈来愈具有协作性，这时自动化测试将变得十分必要。

这周 NSHipster 将探索单元测试框架的世界，并且展示如何使用 Travis CI 来搭建一个自动化构建系统。

---

[单元测试](https://zh.wikipedia.org/wiki/%E5%8D%95%E5%85%83%E6%B5%8B%E8%AF%95)是一个工具。就像其他的工具一样，它的目的是让我们开发的软件更加健壮，可维护性更强。

它需要一个很简单的前提，就是要写一些代码搭建环境来运行一个给定方法，功能，类 或者 特性的特定行为。所有的变量用一个科学的方式隔离开来，以便用逻辑原子性来测试假设。

## OCUnit

[由于在开发 Core Data 1.0 中使用了它](http://www.friday.com/bbum/2005/09/24/unit-testing)，大约在2005年的 WWDC 上，[OCUnit](http://www.sente.ch/software/ocunit/) 被集成进了 Xcode 2.1，这就是众所周知的 SenTestingKit。基于 [Sen:te](http://www.sente.ch) 开发的 OCUnit 实际上是第一个可以用任意语言编写的单元测试库。

所有的单元测试会被添加到 Xcode 工程中的一个单独的测试 Target 中。每个测试文件都定义了一个 `SentestCase` 的子类，并且在其中定义了一系列以 `test` 开头的方法。其用 C 语言 `assert` 风格的宏来判断测试是不是满足某个特定的条件。每个测试都是按照顺序独立运行的，并且在运行之后会把结果记录下来：

~~~{objective-c}
#import <SenTestingKit/SenTestingKit.h>
#import "Person.h"

@interface TestPerson : SenTestCase
@end

@implementation TestPerson
- (void)testFullName {
   Person *person = [[Person alloc] init];
   person.firstName = @"Pablo";
   person.lastName = @"Picasso";
   STAssertEqualObjects([person fullName], @"Pablo Picasso", nil);
}
~~~

SenTestingKit 的断言提供了你所期望的最基本的相等，存在性检测和真值检查：

- `STAssertNil()`
- `STAssertNotNil()`
- `STAssertTrue()`
- `STAssertFalse()`
- `STAssertEqualObjects()`
- `STAssertEquals()`
- `STAssertEqualsWithAccuracy()`
- `STAssertThrows()`
- `STAssertThrowsSpecific()`
- `STAssertThrowsSpecificNamed()`
- `STAssertNoThrow()`
- `STAssertNoThrowSpecific()`
- `STAssertNoThrowSpecificNamed()`
- `STAssertTrueNoThrow()`
- `STAssertFalseNoThrow()`
- `STFail()`


然而，作为有用的测试，它一定会对开发周期造成一些阻碍。当一个项目的开发压力开始增大时，测试是第一个被抛到脑后的。到了一定程度，测试就停摆了（“我们不担心以后怎么样，但现在我们需要产出。”）。

在开发压力很大的情况下，保持测试相关度的唯一机会就是减少开发阻力。所以从本质上来看，我们需要让测试变得更加 _易编写_ 和 _易运行_ 。

## 开源库

所以，有很多开源库尝试通过语法糖和像 [method stubs](https://en.wikipedia.org/wiki/Method_stub), [mock objects](https://en.wikipedia.org/wiki/Mock_object), 和 [promises](http://en.wikipedia.org/wiki/Futures_and_promises) 这些功能来让测试写起来更加让人顺心。

下面的列表是一些对于单元测试十分有用的开源库：

<table>
  <thead>
    <th colspan="3">Mock Objects</th>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/erikdoe/ocmock">OCMock</a></td>
      <td><a href="https://github.com/erikdoe">Erik Doernenburg</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=erikdoe&repo=ocmock&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/jonreid/OCMockito">OCMockito</a></td>
      <td><a href="https://github.com/jonreid">Jon Reid</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=jonreid&repo=OCMockito&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>

  <thead>
    <th colspan="3">Matchers</th>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/specta/expecta">Expecta</a></td>
      <td><a href="https://github.com/petejkim">Peter Jihoon Kim</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=specta&repo=expecta&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/hamcrest/OCHamcrest">OCHamcrest</a></td>
      <td><a href="https://github.com/jonreid">Jon Reid</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=hamcrest&repo=OCHamcrest&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>

  <thead>
    <th colspan="3">BDD / TDD</th>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/specta/specta">Specta</a></td>
      <td><a href="https://github.com/petejkim">Peter Jihoon Kim</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=specta&repo=specta&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/allending/Kiwi">Kiwi</a></td>
      <td><a href="https://github.com/allending">Allen Ding</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=allending&repo=Kiwi&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/pivotal/cedar">Cedar</a></td>
      <td><a href="https://github.com/pivotal">Pivotal Labs</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=pivotal&repo=cedar&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>

  <thead>
    <th colspan="3">Frameworks</th>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/gabriel/gh-unit/">GHUnit</a></td>
      <td><a href="https://github.com/gabriel">Gabriel Handford</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=gabriel&repo=gh-unit&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>
</table>

## 自动化测试

让测试更容易编写是其中一件事，但是让其可以在不影响生产的情况下运行又是另外一回事情了。

### Jenkins

在过去很长一段时间里，在一台专用的 Mac Mini 上安装 [Jenkins](http://jenkins-ci.org) 是自动化构建服务中最先进的一种方式。

当然除了有点儿难以配置之外，[你可以做一些很酷的事情](https://speakerdeck.com/subdigital/ios-build-automation-with-jenkins)，像通过 IM 或者 IRC通知构建状态的变化，通过 [Shenzhen](https://github.com/nomad/shenzhen) 自动分发构建好的应用到 [TestFlight](https://testflightapp.com/dashboard/)(TestFlight 已经被 Apple 收购了 ╮(╯_╰)╭) 或者 [HockeyApp](http://hockeyapp.net) 上，再比如用 [AppleDoc](http://gentlebytes.com/appledoc) 生成文档。

### Travis
直到最近，Objective-C 的自动化单元测试依然是那些能够花的起时间和资金去搭建持续集成服务的项目的专利。但 [Travis CI](https://travis-ci.org) 使持续集成走向大众成为了可能。

Objective-C 的持续集成要比别的语言更困难，因为它需要在一台Mac上完成。由于经济原因，一个云 OS X 环境不像Linux一样有市场。但幸运的是，[SauceLabs](https://saucelabs.com) 建立了这样一个虚拟的 Mac 云，并仁慈的捐出了一些资源来为 Travis-CI 上的开源工程运行测试。

如果要举出一个 Objective-C 自动化测试在野生状态下的例子，可以看看 [AFNetworking 是怎么干的](https://github.com/afnetworking/afnetworking#unit-tests)。

其中 `Test` 子目录包括两个单独的工程，分别对应于 iOS 和 OS X target，以及一个Podfile文件来指定所有测试需要的依赖库。AFNetworking 执行了一个 [Rake](http://rake.rubyforge.org) 任务，其中执行了[`xctool`](https://github.com/facebook/xctool)里面的命令。

而且所有的配置都要定义在 `.travis.yml` 文件中：

#### .travis.yml

~~~
language: objective-c
before_install:
  - brew update
  - brew install xctool --HEAD
  - cd Tests && pod install && cd $TRAVIS_BUILD_DIR
  - mkdir -p "Tests/AFNetworking Tests.xcodeproj/xcshareddata/xcschemes" && cp Tests/Schemes/*.xcscheme "Tests/AFNetworking Tests.xcodeproj/xcshareddata/xcschemes/"
script: rake test
~~~

在 [Travis-CI.org](http://about.travis-ci.org/docs/user/build-configuration/) 上，你可以找到 Travis 配置文件的全部文档。

---

Objective-C 的方向已经受到了 Ruby 社区的直接影响。那些童鞋们对于测试都是很在意的。不过想想 [CocoaPods](http://cocoapods.org)，[RubyMotion](http://www.rubymotion.com) 和 [Nomad](http://nomad-cli.com) 这些工具，Ruby 让 Objective-C 的开发提高了几个档次，那我们还有什么可抱怨的哪。

不过最重要的一点是测试已经来到了 Objective-C 之中了。它并不总是必要的，当然也不是写一个好软件的良方，但它已经证明了自己价值(特别是在开发开源项目时)。因此在无测试变得非常不酷之前，试着用用它吧。
