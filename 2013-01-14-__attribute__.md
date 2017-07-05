---
title: "__attribute__"
author: Mattt Thompson
translator: Chester Liu
category: Objective-C
tags: nshipster
excerpt: "本站点文章经常中出现的一个主题是，强调和编译器保持良好关系的重要性。和其他手艺一样，程序员的效率也取决于如何对待他们的工具。照顾好你的工具，它们也会照顾好你。"
status:
    swift: n/a
---

本站点文章经常中出现的一个主题是，强调和编译器保持良好关系的重要性。和其他手艺一样，程序员的效率也取决于如何对待他们的工具。照顾好你的工具，它们也会照顾好你。

`__attribute__` 是一个用于在声明时指定一些特性的编译器指令，它可以让我们进行更多的错误检查和高级优化工作。

使用这个关键字的语法是 `__attribute__` 后面跟两组括号（两个括号可以让它很容易在宏里面使用，特别是有多个属性的时候）。在括号里面是用逗号分隔的属性列表。`__attribute__` 指令可以放在函数，变量和类型声明之后。

~~~{objective-c}
// Return the square of a number
int square(int n) __attribute__((const));

// Declare the availability of a particular API
void f(void)
  __attribute__((availability(macosx,introduced=10.4,deprecated=10.6)));

// Send printf-like message to stderr and exit
extern void die(const char *format, ...)
  __attribute__((noreturn, format(printf, 1, 2)));
~~~

如果这个让你想起了 ISO C 当中的 [`#pragma`](http://nshipster.cn/pragma)，并不是只有你一个人会这样想。

事实上，当 `__attribute__` 首次被引入 GCC 时就受到了一些人的反对，他们建议使用 `#pragma` 来完成同样的事情。

然而有两个原因导致最后 `__attribute__` 还是被添加进来了：

> 1. 从宏中生成 `#pragma` 是不可能的（在 C99 引入 `_Pragma` 操作符之前）。
> 2. 同样的 `#pragma` 语句在另外的编译器中的含义不能完全确定。

引用 [GCC 函数属性有关文档](http://gcc.gnu.org/onlinedocs/gcc/Function-Attributes.html) 的说法：

> 这两个理由几乎能覆盖所有提议使用 `#pragma` 的申请。在任何地方使用 `#pragma` 基本都是错误的。

确实如此，如果你看一下现代 Objective-C——在苹果框架的头文件以及精心设计的开源项目中—— 使用 `__attribute__` 的地方非常多。（相反，如今 `#pragma` 值得注意的地方只是用于修饰：`#pragma mark`）

话不多说，让我们看一下最重要的几个属性：

---

GCC
---

### `format`

> `format` 属性用于指定一个函数接收类似 `printf`， `scanf`， `strftime` 和 `strfmon` 风格的参数，应该按照参数对格式化字符串进行类型检查。

~~~{objective-c}
extern int
my_printf (void *my_object, const char *my_format, ...)
  __attribute__((format(printf, 2, 3)));
~~~

Objective-C 程序员还可以使用 `__NSString__` 来应用跟 `NSString +stringWithFormat:` 和 `NSLog()` 一样的格式化字符串规则。

### `nonnull`

> `nonnull` 属性表明一些函数参数应该是非空的指针。

~~~{objective-c}
extern void *
my_memcpy (void *dest, const void *src, size_t len)
  __attribute__((nonnull (1, 2)));
~~~

使用 `nonnull` 把对于值的预期进行了显式的硬编码，可以帮助我们找到所有调用函数时可能潜伏的 `NULL` 指针 bug。记住一点，编译期错误 ≫ 运行时错误。

### `noreturn`

> 少数的几个标准库函数，例如 `abort` 和 `exit`，是不能返回的。GCC 了解这一点。`noreturn` 这个属性用于声明其他不能返回的函数。

举个例子，AFNetworking [在网络请求线程的入口方法出使用了 `noreturn` 属性](https://github.com/AFNetworking/AFNetworking/blob/1.1.0/AFNetworking/AFURLConnectionOperation.m#L157)。这个方法用于产生专门用于网络请求的 `NSThread`，确保这个线程在应用整个生命周期内都能一直运行。

### `pure` / `const`

> `pure` 属性表明这个函数除了返回值以外没有任何副作用，也就是说它们的返回值只依赖于传入的参数和/或全局变量。这种函数可以通过常见的子表达式消除和循环优化技术进行优化，就像算术操作符一样。

> `const` 属性表明这个函数除了参数之外不会对值进行检查，除了返回值之外也没有其他副作用。注意，一个有指针类型的参数同时检查指针指向的数据的函数，一定不要声明为 `const`。同样的，一个调用在内部非 `const` 函数的函数通常也不能是 `const`。`const` 函数返回 `void` 类型是没有意义的。

~~~{objective-c}
int square(int n) __attribute__((const));
~~~

`pure` 和 `const` 都是为了支持高效的性能优化而营造出函数式编程范例的属性。`const` 可以被看做是更加严格的 `pure`，因为它不依赖于全局变量或者指针。

举个例子，因为被声明为 `const` 的函数结果除了传入参数之外不依赖于任何东西，这个函数的结果就可以被缓存起来，当之后用同样的参数调用的时候可以直接把缓存返回（就像我们知道一个数字的平方是另一个常数，所以我们只需要计算一次就可以了）。

### `unused`

> 当一个函数增加了这个属性声明的时候，意味着它可能不会被使用，GCC 不会对这个函数产生警告。

使用 `__unused` 关键字可以达到同样的效果，可以在方法实现中声明没有被使用的参数。通过了解这个上下文，编译器可以进行相应的优化。你更可能会在 delegate 的方法实现里使用 `__unused`，因为 protocols 为了支持更多可能的用例经常会提供必要的参数之外的上下文。

LLVM
----

和其他 GCC 特性一样，Clang 支持了 `__attribute__`， 还加入了一小部分扩展特性。

要检查能否使用特定的属性，可以用 `__has_attribute` 这个指令。

### `availability`

> Clang 引入了可用性属性，可以放在声明之后，表明这个声明在操作系统版本层次上的生命周期。考虑下面这个虚构的函数 f 的声明：

~~~{objective-c}
void f(void) __attribute__((availability(macosx,introduced=10.4,deprecated=10.6,obsoleted=10.7)));
~~~

> `availability` 属性指出 `f` 在 OS X Tiger 中被引入，在 OS X Snow Leopard 中被废弃，在 OS X Lion 中被淘汰。

> Clang 使用这些信息来判断使用 `f` 是不是安全的：举个例子，如果 Clang 需要为 OS X Leopard 编译代码，调用 f() 没有问题。如果 Clang 为 OS X Snow Leopard 编译代码，调用仍然会成功，不过 Clang 会发出警告，表明这个函数已经废弃了。最后，如果 Clang 为 OS X Lion 平台编译代码，调用会失败，因为 `f()` 已经不可用了。

> `availability` 属性是用一个逗号分隔的列表，列表的第一项是平台名称，然后是指出声明的生命周期当中重要的里程碑时间（如果有的话）的语句，最后是额外的信息。

- `introduced`: 声明被引入的第一个版本。
- `deprecated`: 声明被废弃的第一个版本，意味着用户应当从这个 API 迁移到另外的方法。
- `obsoleted`: 声明被废弃的第一个版本，意味着它被彻底删除不能使用了。
- `unavailable`: 声明在这个平台上从来就是不可用的
- `message`: 额外的文本信息，Clang 在对于废弃和淘汰声明给出警告或者错误的时候会提供这些信息，可以用于指导用户进行 API 替换。

> 在同一个声明上可以添加多个可用性属性，它们可能是针对不同平台的。只有当前和目标平台对应的平台可用性属性会发挥作用，其他的属性会被忽略掉。如果没有和当前目标苹果对应的可用性属性，整个可用性属性会被忽略。

支持的平台：

- `ios`: 苹果 iOS 操作系统。最低的部署目标通过 `-mios-version-min=*version*` 或者 `-miphoneos-version-min=*version*` 命令行参数指定。
- `macosx`: 苹果 OS X 操作系统。最低的部署目标通过 `-mmacosx-version-min=*version*` 命令行参数指定。

### `overloadable`

> Clang 在 C 语言中提供了 C++ 函数重载支持，通过 `overloadable` 这个属性实现。例如我们要提供多个不同重载版本的 `tgsin` 函数，它会调用合适的标准库函数，分别提供对 `float`，`double` 和 `long double` 精度的值计算 `sine` 值。

~~~{objective-c}
#include <math.h>
float __attribute__((overloadable)) tgsin(float x) { return sinf(x); }
double __attribute__((overloadable)) tgsin(double x) { return sin(x); }
long double __attribute__((overloadable)) tgsin(long double x) { return sinl(x); }
~~~

注意 `overloadable`只能用于函数。你可以通过使用 `id` 和 `void *` 这种泛型的返回值和参数类型，在一定程度上实现方法声明的重载。

---

对于编译器优化来说，上下文至关重要。通过给编译器对代码的解析添加约束，生成的代码更有可能达到最高的效率。对你的编译器做些让步，结果总是好的。

同时 `__attribute__` 也不仅仅是为了编译器而添加的：下一个看到这段代码的人也会感激额外的这部分工作的。因此多付出一些吧，为了和你共事的同事，为了下一个接手代码的人，也为了两年之后（已经彻底忘了这段代码是什么意思）的你。

因为最终，你收获的与你付出的总是相等的（译者注：原文 the love you take is equal to the love you make，源自 Beatles 的作品 The End）。
