---
layout: post
title: "NS_ENUM & NS_OPTIONS"
category: Cocoa
excerpt: "一个专业的Objective-C工程师应该在面向对象和面向过程范式间优雅地切换，同时能够掌握二者的优势。"
author: Mattt Thompson
translator: Croath Liu
---

一切皆为对象。

其实有很多种方式你可以在面向过程和面向对象间互相转化，但本文的目的是：有时候抛弃C层面的东西也是很好的。

是的——对于这种Smalltalk一样杂交而成的语言中的非面向对象部分而言，C语言是很有魅力的一部分。它速度快、久经考验，是现代计算最核心的部分。而且当面向对象范式处于过于庞大的设计而显得臃肿不堪的时候，C就变成了你的“安全出口”。

静态函数比硬要塞入类中的方法要好。
枚举比字符串常量要好。
按位掩码比字符串常量组成的数组要好。
过程化指令比runtime hack要好。

一个专业的Objective-C工程师应该在面向对象和面向过程范式间优雅地切换，同时能够掌握二者的优势。

而关于这一点，本周的话题围绕的是这两个简单而方便的宏定义： `NS_ENUM` 和 `NS_OPTIONS`。

---

`NS_ENUM` 和 `NS_OPTIONS` 都不算太古老的宏，在iOS 6 / OS X Mountain Lion才开始有，他们都是代替 `enum` 的更好的办法。

> 如果你想在更早的iOS或OS X系统中使用这两个宏，简单定义一下就好了：

~~~{objective-c}
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif
~~~

`enum`，或者其他枚举类型（例如每周的星期几，或TableViewCell的类型等），都是通过C的方法去为预设值定义常量。在一个 `enum` 定义中，没有被赋予特别值的常量都会自动被赋为从0开始的连续值。

有几种合法的方式来定义 `enum`。容易产生困惑的地方是它们每种方法之间略有不同，但不必须想太多，任选一种即可。

例如：

~~~{objective-c}
enum {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
};
~~~

...定义整型值，但不定义类型。

另一种方法:

~~~{objective-c}
typedef enum {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
} UITableViewCellStyle;
~~~

...定义适合特性参数的 `UITableViewCellStyle` 类型。

然而，之前苹果自己的代码中都用这种方法来定义 `enum` ：

~~~{objective-c}
typedef enum {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
};

typedef NSInteger UITableViewCellStyle;
~~~

...这种方法给出了 `UITableViewCellStyle` 确定的大小，但并没有告诉编译器这个类型和之前的 `enum` 有什么关系。

让我感动的是苹果终于给了这个“宏统一”的 `NS_ENUM`。

## `NS_ENUM`

从现在开始 `UITableViewCellStyle` 的定义已经变成这个样子了：

~~~{objective-c}
typedef NS_ENUM(NSInteger, UITableViewCellStyle) {
    UITableViewCellStyleDefault,
    UITableViewCellStyleValue1,
    UITableViewCellStyleValue2,
    UITableViewCellStyleSubtitle
};
~~~

`NS_ENUM` 的第一个参数是用于存储的新类型的类型。在64位环境下，`UITableViewCellStyle` 和 `NSInteger` 一样有8bytes长。你要保证你给出的所有值能被该类型容纳，否则就会产生错误。第二个参数是新类型的名字。大括号里面和以前一样，是你要定义的各种值。

这种实现方法提取了之前各种不同实现的优点，甚至有提示编辑器在进行 `switch` 判断时检查类型匹配的功能。

## `NS_OPTIONS`

`enum` 也可以被定义为[按位掩码（bitmask）][1]。用简单的`OR` (`|`)和`AND` (`&`)数学运算即可实现对一个整型值的编码。每一个值不是自动被赋予从0开始依次累加1的值，而是手动被赋予一个带有一个bit偏移量的值：类似`1 << 0`、 `1 << 1`、 `1 << 2`等。如果你能够心算出每个数字的二进制表示法，例如：`10110` 代表 22，每一位都可以被认为是一个单独的布尔值。例如在UIKit中， `UIViewAutoresizing` 就是一个可以表示任何flexible top、bottom、 left 或 right margins、width、height组合的位掩码。

位掩码用 `NS_OPTIONS` 宏，而不是 `NS_ENUM`。

语法和 `NS_ENUM` 完全相同，但这个宏提示编译器值是如何通过位掩码 `|` 组合在一起的。同样的，注意值的区间不要超过所使用类型的最大容纳范围。

---

`NS_ENUM` 和 `NS_OPTIONS` 都是Objective-C开发中的提升开发体验的新特性，也再次展示了这门语言在对象化和过程化之间健康和谐的辩证关系。记住这一点，它就好像在你成长的道路中认识到的：我们身边的万物都是运作在矛盾且共存的严谨逻辑关系中。

[1]: http://en.wikipedia.org/wiki/Mask_(computing)
