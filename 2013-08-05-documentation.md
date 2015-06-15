---
title: Documentation
author: Mattt Thompson
category: Objective-C
translator: April Peng
excerpt: "Cocoa 开发者间流传着一句格言，Objective-C 的冗长使得其代码就是有效的自我说明。有了 longMethodNamesWithNamedParameters: 以及参数的显式类型，Objective-C 的方法不会给人留下太多的想象空间。"
---

Cocoa 开发者间流传着一句格言，Objective-C 的冗长使得其代码就是有效的自我说明。有了 longMethodNamesWithNamedParameters: 以及参数的显式类型，Objective-C 的方法不会给人留下太多的想象空间。

但即使是自我说明的代码也可以通过说明文档加以改进，而且只需少量的努力就可以给别人产生显著的好处。

**听着** - 我知道程序员不喜欢被告知该怎么做，“你应该” 和 “你不该” 的规范性论证有[长号的修辞影响](http://www.youtube.com/watch?v=ss2hULhXf04)，所以我就切入正题：

你喜欢苹果的文档吗？难道你不希望[为自己的库](http://cocoadocs.org/docsets/AFNetworking/1.3.1/Classes/AFHTTPClient.html)也编写同样的文档吗？只需几个简单的步骤，你的代码就可以得到它该有的文档。

---

每一个现代编程语言都有注释：由一个特殊的字符序列标记的非可执行的自然语言，如 `//`，`/**/`，`＃` 和 `--`。使用特殊格式注释的文档，提供了代码的辅助解释和上下文，可以用编译工具提取和解析。

在 Objective-C，可选的文档工具是 [`appledoc`](https://github.com/tomaz/appledoc)。使用类似 [Javadoc](http://en.wikipedia.org/wiki/Javadoc) 的语法，`appledoc` 能够从 `.h` 文件生成 HTML 和 Xcode 兼容的 `.docset` 文档，外观和[苹果官方文档](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSArray_Class/NSArray.html) [几乎相同](http://cocoadocs.org/docsets/AFNetworking/1.3.1/Classes/AFHTTPClient.html) .

> [Doxygen](http://www.stack.nl/~dimitri/doxygen/)，主要用于 C++，是 Objective-C 的另一种可行选择，但一般在 iOS / OS X 的开发者社区不很受待见。

下面是一些文档化很好的 Objective-C 项目的例子：

- [`AFHTTPSessionManager.h`](https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFHTTPSessionManager.h)
- [`MRBrew.h`](https://github.com/marcransome/MRBrew/blob/master/MRBrew/MRBrew.h)
- [`GRMustache.h`](https://github.com/groue/GRMustache/blob/master/src/classes/GRMustache.h)
- [`TTTAddressFormatter.h`](https://github.com/mattt/FormatterKit/blob/master/FormatterKit/TTTAddressFormatter.h)

## 编写 Objective-C 文档的规范

Objective-C 的文档是由 `/** */` 标记的注释块（注意额外的初始星号），先于任何 `@interface` 或 `@protocol`，以及任何方法或 `@property` 声明。

对于类，类别和协议，文档应说明该特定组件的用途，提供应该如何使用的建议和指导。将它构造的像一个新闻报道：先从顶层“一篇微博大小的”概述，然后在必要的地方更详细的做进一步探讨。关注一个类为何应该（或不应该）被继承，或标准协议（比如 `NSCopying`）的任何行为警告都应始终做好记录。

每个方法都应该以一个简要的开始来说明其功能，接着是任何警告或其他详细信息。方法文档中还含有 Javadoc 风格的 `@` 标签来标识诸如参数和返回值这样的常有字段：

- `@param [参数] [说明]`：描述此参数应该传递什么样的值
- `@return [说明]`：描述方法的返回值
- `@see [selector]`：提供相关方法的“另见”引用
- `@warning [说明]`：标识出异常或潜在的危险行为

属性往往被描述在一个简单的句子里，并且应该包括它的默认值。

相关的属性和方法应该由一个 `@name` 声明来分组，类似于一个[`#pragma mark`](http://nshipster.com/pragma/) 的功能，并且可以与三重斜线（`///`）的注释类型一起使用。

在编写你自己的文档前试着阅读一些其他的文档，这样才能得到正确的基调和风格的认知。当对术语或冗长的描述有质疑的时候，你可以遵循从苹果的官方文档能找到的最接近的文档模式。

> 为了帮助加快项目文档编写的过程，你可能要看看 [VVDocumenter-Xcode](https://github.com/onevcat/VVDocumenter-Xcode) 项目，该项目会根据自己的签名为方法[自动添加 `@param` 和 `@return`标签](https://raw.github.com/onevcat/VVDocumenter-Xcode/master/ScreenShot.gif)。

---

只需按照这些简单的指导，你就可以给自己的项目添加精美的，内容丰富的文档。一旦你找到了它的窍门，你会发现文档很快就生成了。

> 谢谢 [@orta](https://github.com/orta) 对这周话题的建议, 他正在进行的 [CocoaDocs](http://cocoadocs.org) 项目可以为那些在 [CocoaPods](http://cocoapods.org) 发布的项目自动生成文档。
