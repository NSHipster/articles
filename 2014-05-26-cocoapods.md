---
layout: post
title: CocoaPods
translator: "Xingruo Liu"
ref: "http://cocoapods.org"
framework: "Open Source"
rating: 9.9
description: "只要设计和施工得当，基础设施可以帮助社会成倍的发展。 就Objective-C而言, CocoaPods提供了一个急需的疏导和管理开源软件的工具。"
---

文明是建立在道路，桥梁，运河，下水道，管线，电线和光纤这些基础设施之上的。只要设计和施工得当，它们可以帮助社会成倍的发展。

唯一的问题就是可扩展性。

不管是在一个新的区域容纳上百万家庭还是整合大量的开发者到新的语言环境中去，挑战都是相同的。

在Objective-C的情况下，[CocoaPods](http://cocoapods.org)提供了一个绝佳的整合合作开发的工具，并且在快速发展的开发社区中起到了一个集结点的作用。

本周的NSHipster，我们将通过讨论CocoaPods的过去，现在以及将来，一起庆祝0.33版本（[具有里程碑意义](http://blog.cocoapods.org/CocoaPods-0.33/)）的发布。

接下来的对CocoaPods起源的历史回顾比较冗长，如果你只在乎技术细节，[点此直接跳过](#使用CocoaPods)。

## 回望

在Objective-C在它存在的前20年左右几乎鲜为人知。NeXT和后来的OS X作为一个边缘平台，只拥有一个相对较小的用户和开发者社区。像所有的社区一样，本地用户小组，邮件列表和网站该有的都有，但是开源合作开发缺很少见。诚然，开源在那时也只处于起步阶段，但是Objective-C却从未有过类似于CPAN (the Comprehensive Perl Archive Network)的组织。所有人除了能从Redwood和Cupertino拿到SDK（或者在论坛搜寻一下可用的代码）以外，剩下的问题只能靠自己解决。

### Objective-C和iPhone

这种情况一直持续到了2008年的夏天，当iPhone OS开始对第三方开发者开放的时候。几乎一夜之间，Objective-C从无人问津变的炙手可热。上百万开发者的涌入，给这门语言注入了新鲜的血液。

就在此时，GitHub 也刚刚发布，并且开始通过新的分布式合作开发方式改变我们对开源的认知。

一大批开源项目开始涌现，例如ASIHTTPRequest和Facebook的Three20。这些早期的库和框架主要是用来填补iPhone OS 2.0和3.0开发中遇到空白，并且在后续的OS迭代中慢慢被遗弃或取代，但是它们突破了每个开发者“单打独斗”的局面。

在这波新的开发者中，那些来自Ruby背景的对 Objective-C 起来了很大的影响。Ruby作为Perl的精神继承者，有一个类似于CPAN的包管理器：[RubyGems](https://rubygems.org)

为什么受Ruby的影响这么大？我的理论是：Ruby是在[Rails](http://rubyonrails.org) 2005年发布1.0版本的时候开始流行起来。假设创业公司的平均寿命在1.5到2.5年之间，那么此时第一批厌倦Rails的开发者正好可以跳上移动开发的大船上。

就在Objective-C开源开发渐入佳境之时，代码分发的痛点开始显现：

缺乏框架，iOS的代码虽然可以被打包成静态库，但是配置和同步分发却成了一个艰巨的任务。

另外一个思路是用Git Submodules把源码直接放入项目。但是链接框架和配置生成环境的繁琐也使得这种方法也没有好到哪里去，尤其是当[ARC和 non-ARC](http://en.wikipedia.org/wiki/Automatic_Reference_Counting)的代码需要分开的时候。

### 进入CocoaPods时代

CocoaPods是由[Eloy Durán](https://twitter.com/alloy)于2011年8月12日创建。

在Bundler和RubyGems的启发下，CocoaPods被设计成即能处理库之间的依赖关系，又能自动下载并且配置好所需要的库。试想一下[开发只有松散文档编制的Xcode项目](https://github.com/CocoaPods/xcodeproj)的难度，CocoaPods的存在简直就是奇迹。

另一个早先的决定就是利用[central Git repository](https://github.com/cocoapods/specs)作为所有库的总数据库。虽然这带来了一些运筹上的顾虑，好在GitHub能够提供一个稳健的平台，帮助团队在后续的迭代中，开发出更好的工具链。

时至今日，CocoaPods已经壮大拥有14个核心开发人员和多达[5000个开源项目](https://github.com/CocoaPods/Specs/tree/master/Specs)。绝大部分项目都是来自于Objective-C开源社区，我们应该感谢每一个参与其中的开发者。

---

## 使用CocoaPods

制作和使用CocoaPods库都十分简单，往往几分钟就能配置完毕。

想获取最新的官方教程，请[前往此处](http://guides.cocoapods.org)。

### 安装CocoaPods

CocoaPods可以方便地通过RubyGems安装，打开Terminal，然后键入以下命令：

~~~{bash}
$ sudo gem install cocoapods
~~~

就这么简单，现在你应该可以开始使用pod命令了。

> 如果你使用Ruby版本管理器，如[rbenv](https://github.com/sstephenson/rbenv)，你可能需要运行以下指令来重新链接shim的二进制文件（例如：$ rbenv rehash）。

### 管理相关性

一个相关性管理器可以将一系列的软件需求转化为具体的标签，然后下载并且整合进入相关的项目。

申明需求可以自动化整个项目配置，这也是软件开发的[最佳实践之一](http://12factor.net/dependencies)，无论是在任何语言中。**甚至你不使用第三方库，CocoaPods仍然是一个管理代码相关性的绝佳工具。**

#### Podfile

`Podfile`这个文件是用来用来申明项目代码相关性的，正如[Bundler](http://bundler.io)的`Gemfile`，或者[npm](https://www.npmjs.org)的`package.json`

`cd`进入`.xcodeproj`文件所在的目录，通过以下命令来创建一个Podfile

~~~{bash}
$ pod init
~~~

#### 以下是一个Podfile的示例：

~~~{ruby}
platform :ios, '7.0'

target "AppName" do

end
~~~

你可以申明需要不同版本的库，大部分情况下，申明到minor或者patch版本就足够了

~~~{ruby}
pod 'X', '~> 1.1'
~~~

CocoaPods遵循[语意化版本规范](http://semver.org)。

对于那些不在CocoaPods公共Git仓库中的库，你可以用任何一个Git, Mercurial或者SVN仓库取代，并且还可以指定具体的commit, branch或者tag。

~~~{ruby}
pod 'Y', :git => 'https://github.com/NSHipster/Y.git', :commit => 'b4dc0ffee'
~~~

一旦所有的相关性都申明完毕，你可以使用以下指令来安装所需要的库：

~~~{bash}
$ pod install
~~~

安装过程中，CocoPods会使用递归来分析所有的需求，并且建立一个代码相关性的图，最后将Podfile序列化为`Podfile.lock`

比如，如果两个库都需要使用[AFNetworking](http://afnetworking.com)，CocoaPods会确定一个同时能被这两库使用的版本，然后将同一个安装版本链接到两个不同的库中。

CocoaPods会创建一个新的包含之前安装好的静态库Xcode项目，然后将它们链接成一个新的libPods.a target。你原有的项目将会依赖这个新的静态库。一个xcworkspace文件会被创建，从此之后，你应该只打开这个xcworkspace文件来进行开发。

反复使用pod install命令，只会让CocoaPods重复以上步骤，重新安装这些库。所以，当你需要升级它们时，请使用以下命令：

~~~{bash}
$ pod update
~~~

### 试着使用CocoaPod

`try`是一个及其实用但又鲜为人知的CocoaPods命令，通过它你能够在安装一个库之前，先试用一下。

你只需要在`try`后面加上任意一个CocoaPods公共库的名称，就能试用它了！

~~~{bash}
$ pod try Ono
~~~

## 建立自己的CocoaPod

作为Objective-C软件分发实际上的标准，CocoaPods几乎是所有开源项目的标配，如果你想让你的项目被大家很方便地使用。

诚然，这会提高一点点你分享项目的门槛，但是，好处是显然易见的。你花几分钟创建一个`.podspec`文件可以节省下其他开发者无数的时间。

### 规范

`.podspec`文件作为CocoaPods的一个独立单元，包含了名称，版本，许可证，和源码文件等所有信息。

> [官方指南](http://guides.cocoapods.org/using/the-podfile)中有许多信息和范例

#### 以下是NSHipsterKit.podspec

~~~{ruby}
Pod::Spec.new do |s|
  s.name     = 'NSHipsterKit'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = "A pretty obscure library.
                You've probably never heard of it."
  s.homepage = 'http://nshipster.com'
  s.authors  = { 'Mattt Thompson' =>
                 'mattt@nshipster.com' }
  s.social_media_url = "https://twitter.com/mattt"
  s.source   = { :git => 'https://github.com/nshipster/NSHipsterKit.git', :tag => '1.0.0' }
  s.source_files = 'NSHipsterKit'
end
~~~

一旦把这个`.podspec`发布到公共数据库中，任何想使用它的开发者，只需要在Podfile中加入如下声明即可：

#### Podfile

~~~{ruby}
pod 'NSHipsterKit', '~> 1.0'
~~~

`.podspec`文件也可以作为管理内部代码的利器：

~~~{ruby}
pod 'Z', :path => 'path/to/directory/with/podspec'
~~~

### 发布CocoaPod

CocoaPods 0.33中加入了[Trunk](http://guides.cocoapods.org/making/getting-setup-with-trunk)服务。

虽然一开始使用GitHub Pull Requests来整理所有公共pods效果很好。但是，随着Pod数量的增加，这个工作对于spec维护人员[Keith Smiley](https://twitter.com/SmileyKeith)来说变得十分繁杂。甚至一些没有通过`$ pod lint`的spec也被提交上来，造成repo无法build。

CocoaPods Trunk服务的引入，解决了很多类似的问题。CocoaPods作为一个集中式的服务，使得分析和统计平台数据变得十分方便。

要想使用Trunk服务，首先你需要注册自己的电脑。这很简单，只要你指明你的邮箱地址（spec文件中的）和名称即可。

~~~{bash}
$ pod trunk register mattt@nshipster.com "Mattt Thompson"
~~~

至此，你就可以通过以下命令来方便地发布和升级你的Pod！

~~~{bash}
$ pod trunk push NAME.podspec
~~~

> 已经发布Pod的作者可以通过[几个简单的步骤](http://blog.cocoapods.org/Claim-Your-Pods/)来声明所有权。

***

## 展望

CocoaPods例证了一个社区的凝聚力。在短短的几年内，Objective-C社区让我们所有人都引以为傲。

CocoaPods仅仅是众多Objective-C基础设施的一部分，还有诸如[Travis CI](http://blog.travis-ci.com/introducing-mac-ios-rubymotion-testing/), [CocoaDocs](http://cocoadocs.org)和[Nomad](http://nomad-cli.com)这些非常好的生产力工具。

虽然整个社区的未来不会一帆风顺，不管怎样，让我们怀着信念，尽可能的提供建设性的意见。我们更应该互相帮助，乐于分享，共同努力推动整个社区的进步！

CocoaPods已经是Objective-C不可或缺的一部分，它只会越来越强大！
