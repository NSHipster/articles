---
title: Clang Diagnostics
author: Mattt Thompson
category: Objective-C
translator: April Peng
excerpt: "诊断结合了逻辑与分析来得出一个结论。这是最纯粹的科学和工程学，也是人类最有力的推理。对于我们开发者来说，我们通过代码通知后续代码的生产，创建了一个在过去半个世纪里呈几何级数发展的技术的正反馈循环。尤其对于我们的 Objective-C 开发者来说，最有效的诊断来自 Clang。"
---

诊断结合了逻辑与分析来得出一个结论。这是最纯粹的科学和工程学，也是人类最有力的推理。

在医学界，诊断是通过实验室样本做后盾的本能来判断。而对于工业制造，则是通过在统计和方向都等同应用来诊断产品故障。

对于我们开发者来说，我们通过代码通知后续代码的生产，创建了一个在过去半个世纪里呈几何级数发展的技术的正反馈循环。尤其对于我们的 Objective-C 开发者来说，最有效的诊断来自 Clang。

Clang 是 C / Objective-C 的前端的 LLVM 编译器。它对 Objective-C 的语义和语法有着深刻的理解，而且更重要的原因是现在 Objective-C 已经是这样一个有能力的语言了。

当你在 XCode 中运行 "Build & Analyze" (`⌘⇧B`) 后得到的惊人结果是 Clang 的更细腻，更深沉一面的功能：它的代码诊断。

在我们关于 [`#pragma`](http://nshipster.com/pragma/) 文章中，我们打趣的说：

> 资深提示：尝试设置 `-Weverything` 标志，并在你的编译设置中勾选上 "Treat Warnings as Errors"。这将在 Xcode 中开启困难模式。

现在，我们支持这个建议，并鼓励其他开发者更严肃的对待编译警告。然而，也有一些情况下，你和 Clang 会陷入僵局。例如，考虑以下 `switch` 语句：

~~~{objective-c}
switch (style) {
    case UITableViewCellStyleDefault:
    case UITableViewCellStyleValue1:
    case UITableViewCellStyleValue2:
    case UITableViewCellStyleSubtitle:
        // ...
    default:
        return;
}
~~~

当启用这些标志后，Clang 会警告说 "default label in switch which covers all enumeration values"。然而，放大到一个更大的背景下，如果我们 _知道_ `style` 是（不管怎样）从外部来源的描述（如JSON资源），允许无约束的 `NSInteger` 值，则 `default` 情况是必要的保障。坚持这个必然性的唯一方法就是使用 `#pragma` 暂时忽略警告标志：

> `push` & `pop` 用于保存和恢复编译器的状态，类似 Core Graphics 或 OpenGL 上下文。

~~~{objective-c}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcovered-switch-default"
switch (style) {
    case UITableViewCellStyleDefault:
    case UITableViewCellStyleValue1:
    case UITableViewCellStyleValue2:
    case UITableViewCellStyleSubtitle:
        // ...
    default:
        return;
}
#pragma clang diagnostic pop
~~~

> 而且，怎么强调都不为过，Clang 至少在 99％ 的情况下都是对的。事实上修正一个分析警告 _最好的_ 办法就是忽略它。使用 `#pragma clang diagnostic ignored` 作为最后的方法。

本周，作为公共服务，我们已经编制了一份（基本上）全面的 Clang 警告综合列表，可以在这里找到：

**[F\*\*\*ingClangWarnings.com](http://fuckingclangwarnings.com)**

你可以在 Xcode Issue Navigator 里选择 "Reveal in Log" 并 `^`-点击 相应的条目，这样你还可以找到你可能会遇到的任何编译器和分析器的警告。（如果这个选项被禁用，请尝试重新构建项目）

* * *

更正？补充？建立一个 [Pull Request](https://github.com/mattt/fuckingclangwarnings.com/pulls) 来提交更改。任何帮助都将不胜感激。
