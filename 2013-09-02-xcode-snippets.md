---
title: Xcode Snippets
author: Mattt Thompson
translator: GWesley
category: Xcode
excerpt: "一般搞 iOS 开发都得用到 Xcode。如果我们已经准备在开发流程中使用 IDE，那我们就应该充分利用它，不是么？所以本周的 NSHipster，我们就来聊聊 Xcode 中强大但未被充分利用的功能之一：**代码块**。"
---

一般搞 iOS 开发都得用到 Xcode。 值得表扬的是，过去几年 Xcode 一直在不断地改进。当然 [还是有些坑...](http://www.textfromxcode.com) ，不过嘿 - 还有比它 [更糟的](http://www.eclipse.org) 呢。

使用 IDE 进行开发可能没有你最爱的 [老一辈编辑器](http://en.wikipedia.org/wiki/Vim_(text_editor)) （或 [另一个](http://en.wikipedia.org/wiki/Emacs) ）酷。但是你知道什么更酷吗？[自动补全](http://www.textfromxcode.com/post/24542673087) 。且不说还有 [编译 & 分析](http://clang-analyzer.llvm.org/xcode.html)， [断点](https://developer.apple.com/library/ios/recipes/xcode_help-source_editor/Creating，Disabling，andDeletingBreakpoints/Creating，Disabling，andDeletingBreakpoints.html)， 和 [测试仪器工具集（Instruments）](https://developer.apple.com/library/ios/DOCUMENTATION/DeveloperTools/Conceptual/InstrumentsUserGuide/InstrumentsQuickStart/InstrumentsQuickStart.html)。


我的观点是：如果我们已经准备在开发流程中使用 IDE，那我们就应该充分利用它，不是么？所以本周的 NSHipster，我们就来聊聊 Xcode 中强大但未被充分利用的功能之一：**代码块**。

---

很多 Objective-C 代码其实都没必要去手写，不管是 `@interface` 声明还是 `if (!self) return nil;` 之类的咒语。 Xcode 代码块可以把这些重复的模式和样板提取出来进行复用。

## 使用 Xcode 代码块

打开编辑器右侧的工具面板，就能看到所有可用的代码块。在工具面板的下方，有 4 个水平分布的小图标。

![Utilities Divider](http://nshipster.s3.amazonaws.com/xcode-snippet-utilities-divider.png)

点击 `{ }` 图标可以查看代码块仓库。

![Utilities Panel](http://nshipster.s3.amazonaws.com/xcode-snippet-utilties-panel.png)

有两种方法将一个代码块插入你的代码：

你可以从代码块仓库拖到你的编辑器里面：

![Drag-and-Drop](http://nshipster.s3.amazonaws.com/xcode-snippet-drag-and-drop.gif)

。。。亦或那些有快捷输入码的代码块，你可以这样：

![Text Completion Shortcut](http://nshipster.s3.amazonaws.com/xcode-snippet-text-completion-shortcut.gif)

为了让你能够对代码块的用途有个较直观的印象，下面是 Xcode 内置代码块的概览：

- C `enum`， `struct` `union`， 和 blocks 的 `typedef` 声明 
- C 控制流语句像 `if`， `if`...`else`， 和 `switch`
- C 循环， 像 `for`， `while`， 和 `do`...`while`
- C 内联 block 变量声明
- Objective-C `@interface` 声明（包括类扩展和分类），`@implementation`， `@protocol` 
- Objective-C KVO 样板，包括相对模糊的 `keyPathsForValuesAffecting<Key>`，用来 [注册相关的键](https://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Conceptual/KeyValueObserving/Articles/KVODependentKeys.html)
- Objective-C Core Data 访问，属性存取，属性验证样板。
- Objective-C 枚举 [`NSIndexSet`](http://nshipster.com/nsindexset/) 惯用语
- Objective-C `init`， `initWithCoder:` 和 `initWithFrame:` 实现方法
- Objective-C `@try` / `@catch` / `@finally` 和 `@autorelease` blocks
- GCD `dispatch_once` 和 `dispatch_after` 惯用语

## 创建 Xcode 代码块

当然，代码块功能之所以强大，是因为你可以创建自定义的代码块。

创建代码块的过程不是非常直观很难用文字去描述。它使用了 OS X 系统中一个比较隐晦的功能，让用户拖拽选中文本生成“剪切文本”。看下实际操作就很好理解：

![Text Completion Shortcut](http://nshipster.s3.amazonaws.com/xcode-snippet-create.gif)

用户将自定义的代码块添加到库里面后，可以双击列表中的块去编辑。

![Text Completion Shortcut](http://nshipster.s3.amazonaws.com/xcode-snippet-editor.png)

每个块都有以下内容：

- **Title 标题** - 块的名字（出现在代码补全和代码块库列表中）
- **Summary 简介** - 简单描述下它是干嘛的（只出现在代码块库列表中）
- **Platform 平台** - 限制可访问该代码块的平台。OS X，iOS，或者（“全部”）
- **Language 语言** - 限制可访问该代码块的语言。常见的有 C，Objective-C，C++，或 Objective-C++
- **Completion Shortcut 输入码** - 快捷输入码。常用块的输入码应该非常简练。Xcode 不会警告冲突 / 重复的输入码，所以一定要确保新添加的不要和已有的冲突。
- **Completion Scopes 有效范围** - 限制可访问该代码块的范围。`if` / `else` 语句的自动补全应该只在方法或者函数的实现中有效。下面这些选项可以任意组合：
    - All 全部
    - Class Implementation 类实现
    - Class Interface Methods 类接口方法
    - Class Interface Variables 类接口变量
    - Code Expression 代码表达式
    - Function or Method 函数或方法
    - Preprocessor Directive 预处理指令
    - String or Comment 字符串或注释
    - Top Level 最高层

> `~/Library/Developer/Xcode/UserData/CodeSnippets/`目录存放了所有 Xcode 代码段的文件表示

### 占位符

在你使用其他代码块时你可能已经注意到了这些占位符：

![Placeholder Token](http://nshipster.s3.amazonaws.com/xcode-snippet-token.png)

在 Xcode 中，占位符使用 `<#` 和 `#>` 来分隔，中间是占位文本。赶紧打开 Xcode 试试吧，看看井号中间的文本是怎样魔法般的转换到你眼前的。

赶紧使用占位符给你的代码块添加一点动态效果吧！

### 第三方 Xcode 代码块

你可以在 [这个 GitHub 项目](https://github.com/mattt/Xcode-Snippets) 找到一些好用的代码块（欢迎提交 PR ！）。就算这里没你想要的，它至少提供了一些例子来展示代码块能够做些什么。
---

编程并不是让大家都变成专业打字员，所以应该怎么简单就怎么来。只要你意识到你正在写一些无聊透顶，死记硬背的代码，那就赶紧抽点时间弄个代码块吧！
