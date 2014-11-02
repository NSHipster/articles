---
layout: post
title: "Benchmarking"
category: Objective-C
tag: popular
author: Mattt Thompson
translator: Croath Liu
excerpt: "对于完成有意义的工作来说抽象很重要，但却会带来副作用。利用benchmarking，工程师可以揭开他们代码中运行效率的面纱，然后利用获得的信息来优化。"
---

对于完成有意义的工作来说抽象很重要，但却会带来副作用。为了工作起来更顺手我们需要洞察一些细枝末节来确定一些批量处理的具体逻辑。找到一个特定上下文的有用信息是非常重要的，是具有挑战性的，是高效编程的核心。

利用benchmarking，工程师可以揭开他们代码中运行效率的面纱，然后利用获得的信息来优化。这对于每一位想让app运行更快的工程师（或者说每一个自重的工程师）来说都是必备工具。

* * *

“benchmark”这个词可以追溯到19世纪。它的本意是，一个 benchmark 就是一个一种把石头切割成平板的切刀或用来测量的支架。后来这个词的“测量东西的标准”的比喻义被应用到各种领域了。

在编程中， _benchmark_ 和 _benchmarking_ 略微有语义上的区别：

_benchmark_ 是程序明确地要测量并比较硬件以及软件上的运行效率。相对来说 _benchmarking_ 表示的则是测量效率的一段代码。

## Objective-C 中使用 Benchmarking 测量效率

Benchmark应该和其他认知论有一样的规律可遵循，像统计量那样的科学方法一样有通用的理解。

科学方法涵盖了一系列的逻辑步骤来推演问题：

1. 提出问题
2. 构造假说
3. 预期结果
4. 验证假说
5. 分析结果

当应用到编程时，一般来说会提出两类问题：

- **这段代码的 _绝对_ 效率是多少？**达到了计算力和内存的上限了吗？应用不同样本大小时的[瓶颈操作](http://en.wikipedia.org/wiki/Big_O_notation)是什么？
- **这段代码的 _相对_ 效率是多少？**方法 A 和 方法 B 哪个更快？

因为从操作系统本身的一切基本因素都是可变性非常强的，性能应该通过大量的试验来测量。对于大多数应用来说，样本数量在 10<sup>5</sup> 到 10<sup>8</sup> 直接是合理的。

### 第一发：CFAbsoluteTimeGetCurrent

这里例子中，我们看一看向可变数组中添加元素的效率。

为了建立 benchmark，我们指定一个 `count` 表示有多少个元素需要添加，`iterations` 表示这个测试要运行多少次。

```objective-c
static size_t const count = 1000;
static size_t const iterations = 10000;
```

因为我们不需要测试申请内存的时间，所以我们在 benchmark 外部只声明一次要添加进数组的元素。

```objective-c
id object = @"🐷";
```

做这个 benchmarking 很简单：代码运行前记录一次时间，运行后记录一次，然后比较时间差。你可以很方便地使用 包装了 `mach_absolute_time` 的 `CACurrentMediaTime()` 方法来以秒为单位测量时间。

> 和 `NSDate` 或 `CFAbsoluteTimeGetCurrent()` 偏移量不同的是，`mach_absolute_time()` 和  `CACurrentMediaTime()` 是基于内建时钟的，能够更精确更原子化地测量，并且不会因为外部时间变化而变化（例如时区变化、夏时制、秒突变等）

`for` 循环用来让 `count` 和 `iterations` 递增。每个循环体都被 `@autoreleasepool` 包裹，用来降低内存占用。

那么具体的步骤如下：

```objective-c
CFTimeInterval startTime = CACurrentMediaTime();
{
    for (size_t i = 0; i < iterations; i++) {
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (size_t j = 0; j < count; j++) {
                [mutableArray addObject:object];
            }
        }
    }
}
CFTimeInterval endTime = CACurrentMediaTime();
NSLog(@"Total Runtime: %g s", endTime - startTime);
```

> 这个例子中 `startTime` 和 `endTime` 之间的 block 代码是不必要的，只是为了提高可读性，让代码看起来更清晰明了：很容易能分隔开变量会发生大规模突变的代码

看到这里，你的 NSHipster 第六感肯定嗅到了什么 “肯定有更好更高端的方法吧！”

相信的你直觉是件好事。

下面，请允许我向你介绍 `dispatch_benchmark`。

### 第二发：dispatch_benchmark

`dispatch_benchmark` 是 [`libdispatch` (Grand Central Dispatch)](http://libdispatch.macosforge.org) 的一部分。但严肃地说，这个方法并没有被公开声明，所以你必须要自己声明：

```objective-c
extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));
```

因为没有公开的函数定义， `dispatch_benchmark` 在 Xcode 中也没有公开的文档。但幸运的是有 man 页面：

> 译者按：下面这段 man 不翻译了，你应该自己看懂所有的 man，完整的 man 内容看[这里](http://opensource.apple.com/source/libdispatch/libdispatch-339.90.1/man/dispatch_benchmark.3)

#### man `dispatch_benchmark(3)`

> The `dispatch_benchmark` function executes the given `block` multiple times according to the `count` variable and then returns the average number of nanoseconds per execution. This function is for debugging and performance analysis work. For the best results, pass a high count value to `dispatch_benchmark`.
>
> Please look for inflection points with various data sets and keep the following facts in mind:
>
> - Code bound by computational bandwidth may be inferred by proportional
changes in performance as concurrency is increased.
> - Code bound by memory bandwidth may be inferred by negligible changes in
performance as concurrency is increased.
> - Code bound by critical sections may be inferred by retrograde changes in
performance as concurrency is increased.
>     - Intentional: locks, mutexes, and condition variables.
>     - Accidental: unrelated and frequently modified data on the same cache-line.

如果你略过了这些文档，那么就请一定再读一遍——这些文档非常有用。为了更好地说明这个函数的用法，文档还写了非常有指导意义的指南。

之前那个例子如果我们用 `dispatch_benchmark` 来写会长成这个样子：

```objective-c
uint64_t t = dispatch_benchmark(iterations, ^{
    @autoreleasepool {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (size_t i = 0; i < count; i++) {
            [mutableArray addObject:object];
        }
    }
});
NSLog(@"[[NSMutableArray array] addObject:] Avg. Runtime: %llu ns", t);
```

看到了吧，好多了吧。相比之前的秒计时，毫微秒更加精确，`dispatch_benchmark` 也比手动写循环的 `CFAbsoluteTimeGetCurrent()` 语法结构上看起来更好。

### NSMutableArray array 对决 arrayWithCapacity:！

现在我们已经知道了用 Objective-C 直接运行一个 benchmark 的方法，那么来做一个比较速度的测试吧。

这个例子中我们依旧来考虑这个问题：“传入 capacity 参数和直接初始化有什么区别？”，或者更直接一点：“用 `-arrayWithCapacity:` 还是不用（，这是个问题）”。

一起来看看：

```objective-c
uint64_t t_0 = dispatch_benchmark(iterations, ^{
    @autoreleasepool {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (size_t i = 0; i < count; i++) {
            [mutableArray addObject:object];
        }
    }
});
NSLog(@"[[NSMutableArray array] addObject:] Avg. Runtime: %llu ns", t_0);

uint64_t t_1 = dispatch_benchmark(iterations, ^{
    @autoreleasepool {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:count];
        for (size_t i = 0; i < count; i++) {
            [mutableArray addObject:object];
        }
    }
});
NSLog(@"[[NSMutableArray arrayWithCapacity] addObject:] Avg. Runtime: %llu ns", t_1);
```

#### 结果

测试运行在 搭载 iOS 7.1 的 iPhone 模拟器，结果如下：

```
[[NSMutableArray array] addObject:]: Avg. Runtime 26119 ns
[[NSMutableArray arrayWithCapacity] addObject:] Avg. Runtime: 24158 ns
```

经过大规模样本的测试，用 capacity 与否造成了 7% 的效率差异。

虽然结果没什么有争议的地方（我们的 benchmark 完美地工作了），真正重要的是解释这个结果产生的原因。错误的想法是：通过 benchmark 我们得出结论，用 capacity 参数来初始化是最佳选择。正确想法应该是：这个 benchmark 的结果提示我们应该继续提出问题：

- **这些效率消耗意味着什么呢？** 为了避免出现[不当优化](http://c2.com/cgi/wiki?PrematureOptimization)，想想这点效率差别在大规模系统中是否可以忽略不计呢？
- **如果改变数组元素的个数，会有什么不同的结论吗？** 因为用了 capacity 参数，可以推测的是我们避免了数组元素的增加，但是去计算大规模数据的 `n` 值消耗有多大呢？
- **其他集合类型，比如说 `NSMutableSet` 或 `NSMutableDictionary` 的 capacity 参数初始化效率又是怎么样的呢？** 民众需要真相！

## Benchmarking 常识指南

- **知道你要解答的是什么问题。** 虽然我们始终致力于用思考去代替神奇的思维，但我们必须保护自己免受科学方法的淹没，也不应该支持不完整的推理。得出结论之前，花一些时间去理解在大背景下你的结果到底意味着什么。
- **不要在你 app 的提交代码中加入 benchmarking。** 注意，`dispatch_benchmark` 可能会导致 app 被 App Store 拒绝，benchmark 代码不应该被加到终极提交的产品中。Benchmarking 应该被分离到单独的项目分支或独立的测试用例中。
- **使用 Instruments 来获得更有用的结果。** 知道了一系列计算过程的运行绝对时间确实有价值，但可能不足以为减少内存使用提供完善的参考。使用 Instruments 来分析有疑问代码的栈调用和内存用量，你会对这段代码到底发生了什么有更好地理解。
- **在真实设备上 benchmark。** 像其他任何效率测量工具一样，测量终究要在真正的机器上跑一跑。大多数情况下模拟器和真实设备的效率测量结果是一致的，但以防万一还是值得这么做的。
- **不要过早优化。** _这句话怎么强调也不过分。_ 工程师的普遍倾向是在发现真正的原因之前过分关注他们认为的“慢代码”。即使是老手也很容易把应用的瓶颈预测错误。不要浪费时间在追赶影子上。让 Instruments 告诉你你的应用到底哪里花费了最多的时间。

* * *

Richard Feynman 曾经把物理学中的颗粒化实验比作“[找出]手表是怎么做出来的，以及机器是如何[通过]把一堆手表组合在一起并且剔掉无用的齿轮就运行起来了”。Benchmarking 代码的感觉就像这个。

拥有了这些计算世界隐藏起来的抽象层的具体实现细节，有时我们可以能尽所能来理解在大数量级代码层次上到底什么在其核心作用，以及我们能够得到什么。

通过科学和基准统计的严谨程序，开发人员能够在其代码的性能特爹方面得出理由充分的结论。将这些这些原则和惯例套用在自己的项目中来得出适合你自己的结论，并据此优化。
