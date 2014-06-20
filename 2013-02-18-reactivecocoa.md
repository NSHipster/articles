---
layout: post
title: ReactiveCocoa
ref: "https://github.com/ReactiveCocoa/ReactiveCocoa"
framework: "Open Source"
rating: 9.5
description: "打破了苹果API排他性的盾牌，本期NSHipster将介绍一个为Objective-C勇敢构建新纪元的开源项目：ReactiveCocoa"
translator: "Croath Liu"
---

编程语言是有生命的。语言在自由无方向迅速发展的生命周期中不断被推动、被挑战、被变得不规范化、或被蒙上了神秘面纱。科技在不停的改变中、在开发团队和开源社区不断来了又走中得以不断发展；隐晦的神秘力量凭借新兴项目的巨人肩膀被磨练得力量日益突出，很快就会在长期的蛰伏后觉醒，大力开辟出一片新天地。

Objective-C在几十年间的非凡发展史可以分为四个阶段：

**第1阶段**，NeXT接手了Objective-C用以支持[NeXTSTEP](http://en.wikipedia.org/wiki/NeXTSTEP)和[世界上第一个web server](http://en.wikipedia.org/wiki/Web_server#History)。

**第2阶段**，苹果并购了NeXT，（在与Java的长期拉锯战之后），Objective-C处于苹果技术栈的核心地位。

**第3阶段**，随着iOS系统的发布，Objective-C上升到了空前重要的地位，成为移动计算领域最重要的语言。

**Objective-C的第4阶段，也就是现如今**，伴随着大批从Ruby、Python、Javascript社区转型的iOS工程师的涌入，Objective-C开始在开源领域大放异彩。Objective-C第一次直接被苹果以外的其他人打磨和引导。

打破了苹果API排他性的盾牌，本期NSHipster将介绍一个为Objective-C勇敢构建新纪元的开源项目：[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)。

---

> 为了对ReactiveCocoa有全方位了解，请查看其项目的[README](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/README.md)、[Framework Overview](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md)和[Design Guidelines](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/DesignGuidelines.md)。

[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)是一个将函数响应式编程范例带入Objective-C的开源库。由[Josh Abernathy](https://github.com/joshaber)和[Justin Spahr-Summers](https://github.com/jspahrsummers)在对[GitHub for Mac](http://mac.github.com)的开发过程中建立。上周，ReactiveCocoa发布了其[1.0 release](https://github.com/ReactiveCocoa/ReactiveCocoa/tree/v1.0.0)，达到了第一个重要里程碑。

[函数响应式编程(Functional Reactive Programming a.k.a FRP)](http://en.wikipedia.org/wiki/Functional_reactive_programming)是思考软件将输入转化为输出在时间上的持续过程的一种方式。[Josh Abernathy这样解释它](http://blog.maybeapps.com/post/42894317939/input-and-output)：

> 程序接收输入产生输出。输出就是对输入做了一些事的结果。输入，转换，输出，完成。
>
> 输入是应用动作的全部来源。点击、键盘事件、定时器事件、GPS时间、网络请求响应都算是输入。这些事件被传递到应用中，应用将他们以某种方式混合，产生了结果：就是输出。
>
> 输出通常会改变应用的UI。开关状态变化、列表有了新的元素都是UI变化。也有可能让磁盘上某个文件产生变化，或者产生一个API请求，这都是应用的输出。
>
> 但不像传统的输入输出设计，应用的输入输出可以产生很多次。应用打开后，不只是一个简单的 输入→工作→输出 就构成了一个生命周期。应用经常有大量的输入并基于这些输入产生输出。

为了举例说明传统范式即Objective-C的命令响应式编程和函数响应式范式的区别，来思考一下下面这个判断注册项是否合法的常用样例：

### 传统范式

~~~{objective-c}
- (BOOL)isFormValid {
    return [self.usernameField.text length] > 0 &&
            [self.emailField.text length] > 0 &&
            [self.passwordField.text length] > 0 &&
            [self.passwordField.text isEqual:self.passwordVerificationField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    self.createButton.enabled = [self isFormValid];

    return YES;
}
~~~

传统范式的样例中，逻辑被放在了很多方法里，零碎地摆放在view controller里，通过到处散布到delegate里的`self.createButton.enabled = [self isFormValid];`方法在页面的生命周期中被调用。

比较一下用ReactiveCocoa写的同样功能的代码：

### ReactiveCocoa

~~~{objective-c}
RACSignal *formValid = [RACSignal
  combineLatest:@[
    self.username.rac_textSignal,
    self.emailField.rac_textSignal,
    self.passwordField.rac_textSignal,
    self.passwordVerificationField.rac_textSignal
  ]
  reduce:^(NSString *username, NSString *email, NSString *password, NSString *passwordVerification) {
    return @([username length] > 0 && [email length] > 0 && [password length] > 8 && [password isEqual:passwordVerification]);
  }];

RAC(self.createButton.enabled) = formValid;
~~~

所有对于判断表单输入是否合法的逻辑都被整合为一串逻辑了。每次不论哪个输入框被修改了，用户的输入都会被reduce成一个布尔值，然后就可以自动来控制注册按钮的可用状态了。

## 概述

ReactiveCocoa由两大主要部分组成：[signals](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md#signals) (`RACSignal`) 和 [sequences](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md#sequences) (`RACSequence`)。

signal 和 sequence 都是[streams](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/FrameworkOverview.md#streams)，他们共享很多相同的方法。ReactiveCocoa在功能上做了语义丰富、一致性强的一致性设计：signal是_push_驱动的stream，sequence是_pull_驱动的stream。

### `RACSignal`

> - **异步控制或事件驱动的数据源**：Cocoa编程中大多数时候会关注用户事件或应用状态改变产生的响应。
> - **链式以来操作**：网络请求是最常见的依赖性样例，前一个对server的请求完成后，下一个请求才能构建。
> - **并行独立动作**：独立的数据集要并行处理，随后还要把他们合并成一个最终结果。这在Cocoa中很常见，特别是涉及到同步动作时。

> Signal会触发它们的subscriber三种不同类型的事件：
>
> * **下一个**事件从stream中提供一个新值。不像Cocoa集合，它是完全可用的，甚至一个signal可以包含 `nil`。
> * **错误**事件会在一个signal结束之前被标示出来这里有一个错误。这种事件可能包含一个 `NSError` 对象来标示什么发生了错误。错误必须被特殊处理——错误不会被包含在stream的值里面。
> * **完成**事件标示signal成功结束，不会再有新的值会被加入到stream当中。完成事件也必须被单独控制——它不会出现在stream的值里面。
>
> 一个signal的生命由很多`下一个(next)`事件和一个`错误(error)`或`完成(completed)`事件组成（后两者不同时出现）。

### `RACSequence`

> - **简化集合转换**：你会痛苦地发现 `Foundation` 库中没有类似 `map` 和 `filter`、`fold/reduce` 等高级函数。

> Sequence是一种集合，很像 `NSArray`。但和数组不同的是，一个sequence里的值默认是_延迟_加载的（只有需要的时候才加载），这样的话如果sequence只有一部分被用到，那么这种机制就会提高性能。像Cocoa的集合类型一样，sequence不接受 `nil` 值。
>
> `RACSequence` 允许任意Cocoa集合在统一且显式地进行操作。

~~~{objective-c}
RACSequence *normalizedLongWords = [[words.rac_sequence
    filter:^ BOOL (NSString *word) {
        return [word length] >= 10;
    }]
    map:^(NSString *word) {
        return [word lowercaseString];
    }];
~~~

## Cocoa中的先例

Capturing and responding to changes has a long tradition in Cocoa, and ReactiveCocoa is a conceptual and functional extension of that. It is instructive to contrast RAC with those Cocoa technologies:

### RAC 与 KVO

[Key-Value Observing](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html)是Cocoa所有魔法的核心，它被广泛应用在ReactiveCocoa对于属性变化的影响动作中。然而KVO用起来即不简单也不开心：它的API有很多过度设计的参数，以及缺乏方便的block方式调用。

### RAC 与 Bindings

[Bindings](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaBindings/CocoaBindings.html)也是黑魔法。

虽然对Mac OS X控制的要点就是Bindings，但是它的意义在近年来越来越没那么重要了，因为焦点已经移动到了iOS和UIKit这些Bindings不支持的东西身上。Bindings替代了大量的模版胶水代码，允许在Interface Builder中完成编码，但严格上说还是比较有局限性的，并且_无法_debug。RAC提供了一种简洁易懂、扩展性强的以代码为基础的API来运行在iOS上，目标就是取代所有在OS X能用Bindings实现的神奇功能。

---

Objective-C在C的核心上吸收了Smalltalk的思想建立而成，但哲学理念上已经超越了它原本来源的血统。

`@protocol` 是对C++多重继承的拒绝，顺应抽象数据的类型范式是对Java `Interface`的吸收。Objective-C 2.0引入了`@property / @synthesize`则灵感来自C#的 `get; set;` 方法对getter和setter的速记（就语法上来说，这也是NeXTSETP强硬路线坚持者经常辩论的一点）。Block给这门语言带来了函数式编程的好处，可以使用Grand Central Dispatch——来自Fortran / C / C++ standard [OpenMP](http://en.wikipedia.org/wiki/OpenMP)思想而成的基于队列的并发API。下标和对象字面量都是像Ruby、Javascript这样的脚本语言的标准特性，如今也由一个Clang插件被带入了Objective-C的世界里。

ReactiveCocoa则给Objective-C带来了函数响应式编程的健康药剂。它本身也是受C#的[Rx library](http://msdn.microsoft.com/en-us/data/gg577609.aspx)、[Clojure](http://en.wikipedia.org/wiki/Clojure)和[Elm][2]的影响发展而成。

好的点子会传染。ReactiveCocoa就是一种警示，提醒人们好的点子也可以从看似不太可能的地方传播过来，这样的新鲜思想对解决类似的问题也会有完全不同的方法呢。

[1]: http://en.wikipedia.org/wiki/State_(computer_science)#Program_state
[2]: http://en.wikipedia.org/wiki/Elm_(programming_language)
