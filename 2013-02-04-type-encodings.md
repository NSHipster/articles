---
title: Type Encodings
author: Mattt Thompson
translator: Ricky Tan
category: Objective-C
tags: nshipster
excerpt: "从数字电台和数学命理到象形文字和流浪汉码，找到看似平常的东西中隐藏的意思真是令人着迷。即使它们中隐藏的信息很少用到或者并不特别有趣，但正是那种寻找的快感激发着我们强烈的好奇心。"
---

从 [数字电台](http://en.wikipedia.org/wiki/Numbers_station) 和 [数学命理](http://en.wikipedia.org/wiki/Numerology) 到 [象形文字](http://en.wikipedia.org/wiki/Egyptian_hieroglyphs) 和 [流浪汉码](http://en.wikipedia.org/wiki/Hobo#Hobo_.28sign.29_code)，找到看似平常的东西中隐藏的意思真是令人着迷。即使它们中隐藏的信息很少用到或者并不特别有趣，但正是那种寻找的快感激发着我们强烈的好奇心。

在这种精神下，本周的 NSHipster 我们来看看 [Objective-C Type Encodings](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)。

---

[上一周](http://nshipster.cn/nsvalue/)，在讨论 `NSValue` 时提到了 `+valueWithBytes:objCType:`，它的第二个参数需要用 Objective-C 的编译器指令 `@encode()` 来创建。

`@encode`，[`@`编译器指令](http://nshipster.com/at-compiler-directives/) 之一，返回一个给定类型编码为一种内部表示的字符串（例如，`@encode(int)` → `i`），类似于 ANSI C 的 `typeof` 操作。苹果的 Objective-C 运行时库内部利用类型编码帮助加快消息分发。

这里有一个所有不同的 Objective-C 类型编码的概要：

<table id="type-encodings">
  <caption>Objective-C Type Encodings</caption>
  <thead>
    <tr>
      <th>编码</th>
      <th>意义</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>c</tt></td>
      <td>A <tt>char</tt></td>
    </tr>
    <tr>
      <td><tt>i</tt></td>
      <td>An <tt>int</tt></td></tr>
    <tr>
      <td><tt>s</tt></td>
      <td>A <tt>short</tt></td></tr>
    <tr>
      <td><tt>l</tt></td>
      <td>A <tt>long</tt><tt>l</tt> is treated as a 32-bit quantity on 64-bit programs.</td></tr>
    <tr>
      <td><tt>q</tt></td>
      <td>A <tt>long long</tt></td></tr>
    <tr>
      <td><tt>C</tt></td>
      <td>An <tt>unsigned char</tt></td></tr>
    <tr>
      <td><tt>I</tt></td>
      <td>An <tt>unsigned int</tt></td></tr>
    <tr>
      <td><tt>S</tt></td>
      <td>An <tt>unsigned short</tt></td></tr>
    <tr>
      <td><tt>L</tt></td>
      <td>An <tt>unsigned long</tt></td></tr>
    <tr>
      <td><tt>Q</tt></td>
      <td>An <tt>unsigned long long</tt></td></tr>
    <tr>
      <td><tt>f</tt></td>
      <td>A <tt>float</tt></td></tr>
    <tr>
      <td><tt>d</tt></td>
      <td>A <tt>double</tt></td></tr>
    <tr>
      <td><tt>B</tt></td>
      <td>A C++ <tt>bool</tt> or a C99 <tt>_Bool</tt></td></tr>
    <tr>
      <td><tt>v</tt></td>
      <td>A <tt>void</tt></td></tr>
    <tr>
      <td><tt>*</tt></td>
      <td>A character string (<tt>char *</tt>)</td></tr>
    <tr>
      <td><tt>@</tt></td>
      <td>An object (whether statically typed or typed <tt>id</tt>)</td></tr>
    <tr>
      <td><tt>#</tt></td>
      <td>A class object (<tt>Class</tt>)</td></tr>
    <tr>
      <td><tt>:</tt></td>
      <td>A method selector (<tt>SEL</tt>)</td></tr>
    <tr>
      <td>[<em>array type</em>] </td>
      <td>An array</td></tr>
    <tr>
      <td>{<em>name=type...</em>}</td>
      <td>A structure</td></tr>
    <tr>
      <td>(<em>name</em>=<em>type...</em>)</td>
      <td>A union</td></tr>
    <tr>
      <td><tt>b</tt>num</td>
      <td>A bit field of <em>num</em> bits</td></tr>
    <tr>
      <td><tt>^</tt>type</td>
      <td>A pointer to <em>type</em></td></tr>
    <tr>
      <td><tt>?</tt></td>
      <td>An unknown type (among other things, this code is used for function pointers)</td>
    </tr>
  </tbody>
</table>

当然，用图表很不错，但是用代码实践更好：

~~~{objective-c}
NSLog(@"int        : %s", @encode(int));
NSLog(@"float      : %s", @encode(float));
NSLog(@"float *    : %s", @encode(float*));
NSLog(@"char       : %s", @encode(char));
NSLog(@"char *     : %s", @encode(char *));
NSLog(@"BOOL       : %s", @encode(BOOL));
NSLog(@"void       : %s", @encode(void));
NSLog(@"void *     : %s", @encode(void *));

NSLog(@"NSObject * : %s", @encode(NSObject *));
NSLog(@"NSObject   : %s", @encode(NSObject));
NSLog(@"[NSObject] : %s", @encode(typeof([NSObject class])));
NSLog(@"NSError ** : %s", @encode(typeof(NSError **)));

int intArray[5] = {1, 2, 3, 4, 5};
NSLog(@"int[]      : %s", @encode(typeof(intArray)));

float floatArray[3] = {0.1f, 0.2f, 0.3f};
NSLog(@"float[]    : %s", @encode(typeof(floatArray)));

typedef struct _struct {
    short a;
    long long b;
    unsigned long long c;
} Struct;
NSLog(@"struct     : %s", @encode(typeof(Struct)));
~~~

结果：

|  类型         | 编码               |
|--------------|--------------------|
| `int`        | `i`                |
| `float`      | `f`                |
| `float *`    | `^f`               |
| `char`       | `c`                |
| `char *`     | `*`                |
| `BOOL`       | `c`                |
| `void`       | `v`                |
| `void *`     | `^v`               |
| `NSObject *` | `@`                |
| `NSObject`   | `#`                |
| `[NSObject]` | `{NSObject=#}`     |
| `NSError **` | `^@`               |
| `int[]`      | `[5i]`             |
| `float[]`    | `[3f]`             |
| `struct`     | `{_struct=sqQ}`    |

这里有一些有趣的点：

（我靠，外卖啊！！！！这怎么翻译？？！！！！）

There are some interesting takeaways from this:

- 指针的标准编码是加一个前置的 `^`，而 `char *` 拥有自己的编码 `*`。这在概念上是很好理解的，因为 C 的字符串被认为是一个实体，而不是指针。
- `BOOL` 是 `c`，而不是某些人以为的 `i`。原因是 `char` 比 `int` 小，且在 80 年代 Objective-C 最开始设计的时候，每一个 bit 位都比今天的要值钱（就像美元一样）。`BOOL` 更确切地说是 `signed char` （即使设置了 `-funsigned-char` 参数），以在不同编译器之间保持一致，因为 `char` 可以是 `signed` 或者 `unsigned`。
- 直接传入 `NSObject` 将产生 `#`。但是传入 `[NSObject class]` 产生一个名为 `NSObject` 只有一个类字段的结构体。很明显，那就是 `isa` 字段，所有的 `NSObject` 实例都用它来表示自己的类型。

## 方法编码

如苹果的 ["Objective-C Runtime Programming Guide"](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html) 中所提到的，有一大把内部使用的类型编码无法用 `@encode()` 返回。

以下是协议中声明的方法的类型修饰符：

<table id="method-encodings">
  <caption>Objective-C Method Encodings</caption>
  <thead>
    <tr>
      <th>编码</th>
      <th>意义</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>r</tt></td>
      <td><tt>const</tt></td>
    </tr>
    <tr>
      <td><tt>n</tt></td>
      <td><tt>in</tt></td>
    </tr>
    <tr>
      <td><tt>N</tt></td>
      <td><tt>inout</tt></td>
    </tr>
    <tr>
      <td><tt>o</tt></td>
      <td><tt>out</tt></td>
    </tr>
    <tr>
      <td><tt>O</tt></td>
      <td><tt>bycopy</tt></td>
    </tr>
    <tr>
      <td><tt>R</tt></td>
      <td><tt>byref</tt></td>
    </tr>
    <tr>
      <td><tt>V</tt></td>
      <td><tt>oneway</tt></td>
    </tr>
  </tbody>
</table>

对于那些熟悉 [NSDistantObject](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSDistantObject_Class/Reference/Reference.html) 的人，你无疑会认出这些是 [Distributed Objects](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/DistrObjects/DistrObjects.html#//apple_ref/doc/uid/10000102i) 的残留。

Although DO has fallen out of fashion in the age of iOS, it was an interprocess messaging protocol used between Cocoa applications--even running on different machines on the network. Under these constraints, there were benefits to be had from the additional context.

For example, parameters in distributed object messages were passed as proxies by default. In situations where proxying would be unnecessarily inefficient, the `bycopy` qualifier could be added to make sure a full copy of the object was sent. Also by default, parameters were `inout`, signifying that objects needed to be sent back and forth when sending the message. By specifying a parameter as `in` or `out` instead, the application could avoid the round-trip overhead.

---

So what do we gain from our newfound understanding of Objective-C Type Encodings?
Honestly, not that much (unless you're doing any crazy metaprogramming).

But as we said from the very outset, there is wisdom in the pursuit of deciphering secret messages.

Looking at type encodings reveals details about Objective-C runtime internals, which is a noble pursuit in and of itself. Going further down the rabbit hole, and we come to the secret history of Distributed Objects, and the obscure parameter qualifiers that [still linger around to this day](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSNumberFormatter_Class/Reference/Reference.html%23jumpTo_22).

