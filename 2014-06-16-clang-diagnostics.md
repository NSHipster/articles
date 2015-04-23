---
title: Clang Diagnostics
author: Mattt Thompson
category: Objective-C
excerpt: "Diagnostics combine logic with analytics to arrive at a conclusion. It's science and engineering at their purest. It's human reasoning at its most potent. For us developers, our medium of code informs the production of subsequent code, creating a positive feedback loop that has catapulted the development of technology exponentially over the last half century. For us Objective-C developers specifically, the most effective diagnostics come from Clang."
translator: April Peng
excerpt: "诊断结合了逻辑与分析来得出一个结论。这是最纯粹的科学和工程学，也是人类最有力的推理。对于我们开发者来说，我们通过代码通知后续代码的生产，创建了一个在过去半个世纪里呈几何级数发展的技术的正反馈循环。尤其对于我们的 Objective-C 开发者来说，最有效的诊断来自 Clang。"
---

Diagnostics combine logic with analytics to arrive at a conclusion. It's science and engineering at their purest. It's human reasoning at its most potent.

诊断结合了逻辑与分析来得出一个结论。这是最纯粹的科学和工程学，也是人类最有力的推理。

Within the medical profession, a diagnosis is made through instinct backed by lab samples. For industrial manufacturing, one diagnoses a product fault through an equal application of statistics and gumption.

在医学界，诊断是通过实验室样本做后盾的本能来判断。而对于工业制造，则是通过在统计和方向都等同应用来诊断产品故障。

For us developers, our medium of code informs the production of subsequent code, creating a positive feedback loop that has catapulted the development of technology exponentially over the last half century. For us Objective-C developers specifically, the most effective diagnostics come from Clang.

对于我们开发者来说，我们通过代码通知后续代码的生产，创建了一个在过去半个世纪里呈几何级数发展的技术的正反馈循环。尤其对于我们的 Objective-C 开发者来说，最有效的诊断来自 Clang。

Clang is the C / Objective-C front-end to the LLVM compiler. It has a deep understanding of the syntax and semantics of Objective-C, and is much of the reason that Objective-C is such a capable language today.

Clang 是 C / Objective-C 的前端的 LLVM 编译器。它对 Objective-C 的语义和语法有着深刻的理解，而且更重要的原因是现在 Objective-C 已经是这样一个有能力的语言了。

That amazing readout you get when you "Build & Analyze" (`⌘⇧B`) is a function of the softer, more contemplative side of Clang: its code diagnostics.

当你在 XCode 中运行 "Build & Analyze" (`⌘⇧B`) 后得到的惊人结果是 Clang 的更细腻，更深沉一面的功能：它的代码诊断。

In our article about [`#pragma`](http://nshipster.com/pragma/), we quipped:

在我们关于 [`#pragma`](http://nshipster.com/pragma/) 文章中，我们打趣的说：

> Pro tip: Try setting the `-Weverything` flag and checking the "Treat Warnings as Errors" box your build settings. This turns on Hard Mode in Xcode.

> 资深提示：尝试设置 `-Weverything` 标志，并在你的编译设置中勾选上 "Treat Warnings as Errors"。这将在 Xcode 中开启困难模式。

Now, we stand by this advice, and encourage other developers to step up their game and treat build warnings more seriously. However, there are some situations in which you and Clang reach an impasse. For example, consider the following `switch` statement:

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

When certain flags are enabled, Clang will complain that the "default label in switch which covers all enumeration values". However, if we _know_ that, zooming out into a larger context, `style` is (for better or worse) derived from an external representation (e.g. JSON resource) that allows for unconstrained `NSInteger` values, the `default` case is a necessary safeguard. The only way to insist on this inevitability is to use `#pragma` to ignore a warning flag temporarily:

当启用这些标志后，Clang 会警告说 "default label in switch which covers all enumeration values"。然而，放大到一个更大的背景下，如果我们 _知道_ `style` 是（不管怎样）从外部来源的描述（如JSON资源），允许无约束的 `NSInteger` 值，则 `default` 情况是必要的保障。坚持这个必然性的唯一方法就是使用 `#pragma` 暂时忽略警告标志：

> `push` & `pop` are used to save and restore the compiler state, similar to Core Graphics or OpenGL contexts.

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

> Again, and this cannot be stressed enough, Clang is right at least 99% of the time. Actually fixing an analyzer warning is _strongly_ preferred to ignoring it. Use `#pragma clang diagnostic ignored` as a method of last resort.

> 而且，怎么强调都不为过，Clang 至少在 99％ 的情况下都是对的。事实上修正一个分析警告 _最好的_ 办法就是忽略它。使用 `#pragma clang diagnostic ignored` 作为最后的方法。

This week, as a public service, we've compiled a (mostly) comprehensive list of Clang warning strings and their associated flags, which can be found here:

本周，作为公共服务，我们已经编制了一份（基本上）全面的 Clang 警告综合列表，可以在这里找到：

**[F\*\*\*ingClangWarnings.com](http://fuckingclangwarnings.com)**

You can also find the compiler and analyzer flags for any warning you might encounter by `^`-Clicking the corresponding entry in the Xcode Issue Navigator and selecting "Reveal in Log". (If this option is disabled, try building the project again).

你可以在 Xcode Issue Navigator 里选择 "Reveal in Log" 并 `^`-点击 相应的条目，这样你还可以找到你可能会遇到的任何编译器和分析器的警告。（如果这个选项被禁用，请尝试重新构建项目）

* * *

Corrections? Additions? Open a [Pull Request](https://github.com/mattt/fuckingclangwarnings.com/pulls) to submit your change. Any help would be greatly appreciated.

更正？补充？建立一个 [Pull Request](https://github.com/mattt/fuckingclangwarnings.com/pulls) 来提交更改。任何帮助都将不胜感激。
