---
title: C Storage Classes
author: Mattt Thompson
category: Objective-C
tags: nshipster
excerpt: "In C, the scope and lifetime of a variable or function within a program is determined by its storage class. Understanding these storage classes allows us to decipher common incantations found throughout Objective-C"
translator: April Peng
excerpt: "在 C 语言中，程序中的变量或函数的生存周期是由它的存储类确定的。了解这些存储类能帮助我们解密整个 Objective-C 中都常见的术语"
---

It's time, once again, to take a few steps back from the world of Objective-C, and look at some underlying C language features. Hold onto your fedoras, ladies & gents, as we dive into C storage classes in this week's edition of NSHipster.

是时候再次从 Objective-C 的世界退回几步，来看看一些底层的 C 语言特性。Hold 住你们的帽子，女士们和先生们，让我们深入到 NSHipster 本周 C 存储类的文章吧。

---

In C, the _scope_ and _lifetime_ of a variable or function within a program is determined by its _storage class_. Each variable has a _lifetime_, or the context in which they store their value. Functions, along with variables, also exist within a particular _scope_, or visibility, which dictates which parts of a program know about and can access them.

在 C 语言中，程序内变量或函数的 _作用域_ 和 _寿命_ 是由其 _存储类_ 确定的。每个变量都具有 _生存周期_，或存储其值的上下文。方法，同变量一样，也存在，或可见于，一个特殊的 _范围里_，这就决定了哪一部分程序知道且能够访问它们。

There are 4 storage classes in C:

C 里有四种存储类：

- `auto`
- `register`
- `static`
- `extern`

At least a few of these will look familiar to anyone who has done a cursory amount of Objective-C programming. Let's go into more detail with each one:

至少它们中的一些会让那些做 Objective-C 编程的人看起来很熟悉。让我们更详细的看看每一个吧：

## `auto`

There's a good chance you've never seen this keyword in the wild. That's because `auto` is the default storage class, and therefore doesn't need to be explicitly used often.

很有可能你从来没见过这个关键字。这是因为 `auto` 是默认存储类，因此通常并不需要显式地使用。

Automatic variables have memory automatically allocated when a program enters a block, and released when the program leaves that block. Access to automatic variables is limited to only the block in which they are declared, as well as any nested blocks.

当运行到程序块时，auto 类型的变量能自动分配内存，并且在该程序块运行完成时释放。访问 auto 变量仅限于在声明它们的 block，以及任何嵌套 block 内。

## `register`

Most Objective-C programmers probably aren't familiar with `register` either, as it's just not widely used in the `NS` world.

大多数 Objective-C 程序员可能也不熟悉 `register`，因为它没有被广泛的使用在 `NS` 世界里。

`register` behaves just like `auto`, except that instead of being allocated onto the stack, they are stored in a [register](http://en.wikipedia.org/wiki/Processor_register).

`register` 行为就像 `auto`，但不同的是它们不是被分配到堆栈中，它们被存储在一个[寄存器](https://zh.wikipedia.org/wiki/%E5%AF%84%E5%AD%98%E5%99%A8)里。

Registers offer faster access than RAM, but because of the complexities of memory management, putting variables in registers does not guarantee a faster program—in fact, it may very well end up slowing down execution by taking up space on the register unnecessarily. As it were, using `register` is actually just a _suggestion_ to the compiler to store the variable in the register; implementations may choose whether or not to honor this.

寄存器能比内存提供更快的访问速度，但由于内存管理的复杂性，把变量放在寄存器中并不能保证程序变得更快。事实上，很可能由于在寄存器上占用了不必要的空间而最终被放缓执行。使用 `寄存器` 实际上只是一个给编译器存储变量的 _建议_，实现时可以选择是否遵从这一点。

`register`'s lack of popularity in Objective-C is instructive: it's probably best not to bother with it, as it's much more likely to cause a headache than speed up your app in any noticeable way.

`寄存器` 在 Objective-C 不够普及其实挺好的：最好还是不要使用它，因为比起其他任何明显的方式上加快应用程序，它更容易引起让人更加头疼的结果。

## `static`

Finally, one that everyone's sure to recognize: `static`.

最后，一说大家都认识的：`static`。

As a keyword, `static` gets used in a lot of different, incompatible ways, so it can be confusing to figure out exactly what it means in every instance. When it comes to storage classes, `static` means one of two things.

作为关键字，`static` 被以很多不同的，不兼容的方式使用，因此要弄清楚每一个实例到底是什么意思可能会造成混淆。当涉及到存储类，`static` 意味着两件事情之一。

1. A `static` variable inside a method or function retains its value between invocations.
2. A `static` variable declared globally can be called by any function or method, so long as those functions appear in the same file as the `static` variable. The same goes for `static` functions.

1. 方法或函数内部的一个 `static` 变量保留其调用之间的值。
2. 全局声明的一个 `static` 变量可以被任何函数或方法被调用，只要这些方法出现在跟 `static` 变量同一个文件中。这同样适用于 `static` 方法。

### 静态单例

A common pattern in Objective-C is the `static` singleton, wherein a statically-declared variable is initialized and returned in either a function or class method. `dispatch once` is used to guarantee that the variable is initialized _exactly_ once in a thread-safe manner:

Objective-C 中一个常见的模式是 `静态` 单例，在这个 case 里，一个静态声明的变量被初始化，并在任何一个函数或类方法中被返回。 `dispatch once` 用于保证变量初始化在一个线程安全的方式下 _只_ 发生一次：

~~~{objective-c}
+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      _sharedInstance = [[self alloc] init];
  });

  return _sharedInstance;
}
~~~

The singleton pattern is useful for creating objects that are shared across the entire application, such as an HTTP client or a notification manager, or objects that may be expensive to create, such as formatters.

单例模式对于创建整个应用程序共享的对象是很有用的，诸如 HTTP 客户端或一个通知管理，或创建过程很昂贵的对象，诸如格式化。

## `extern`

Whereas `static` makes functions and variables globally visible within a particular file, `extern` makes them visible globally to _all files_.

当 `static` 使得一个特定的文件中的函数和变量全局可见，`extern` 则使它们对所有文件可见。

Global variables are not a great idea, generally speaking. Having no constraints on how or when state can be mutated is just asking for impossible-to-debug bugs. That said, there are two common and practical uses for `extern` in Objective-C.

一般来说，全局变量并不是一个好主意。由于没有如何及何时改变值的任何限制，常常导致无法调试的错误。在 Objective-C，对 `extern` 有两个常见和实际的用途。

### Global String Constants

### 全局字符串常量

Any time your application uses a string constant with a non-linguistic value in a public interface, it should declare it as an external string constant. This is especially true of keys in `userInfo` dictionaries, `NSNotification` names, and `NSError` domains.

任何时候，如果你的应用程序要在一个公共头文件申明一个非自然语言的字符串常量，都应该将其声明为外部字符串常量。尤其是在声明诸如 `userInfo` 字典，`NSNotification` 名称和 `NSError` 域的时候。

The pattern is to declare an `extern` `NSString * const` in a public header, and define that `NSString * const` in the implementation:

该模式是在公共头文件里申明一个 `extern` 的 `NSString * const`，并在实现文件里定义该 `NSString * const`：

#### AppDelegate.h

~~~{objective-c}
extern NSString * const kAppErrorDomain;
~~~

#### AppDelegate.m

~~~{objective-c}
NSString * const kAppErrorDomain = @"com.example.yourapp.error";
~~~

It doesn't particularly matter what the value of the string is, so long as it's unique. Using a string constant establishes a strict contract, that the constant variable is used instead of the string's literal value itself.

字符串的值并没有特别的需要注意的事情，只要它是唯一的。使用字符串常量建立了严格的约束，用该常数变量来代替字符串的文本值本身。

### Public Functions

### 公共方法

Some APIs may wish to expose helper functions publicly. For auxiliary concerns and state-agnostic procedures, functions are a great way to encapsulate these behaviors—and if they're particularly useful, it may be worth making them available globally.

一些 API 可能会想要公开曝光一些辅助方法。出于仅提供辅助而与具体状态无关的考虑，用方法来封装这些行为是一个很好的方式，而且如果特别有用，还可能值得使其全局可用。

The pattern follows the same as in the previous example:

该模式例子如下：

#### TransactionStateMachine.h

~~~{objective-c}
typedef NS_ENUM(NSUInteger, TransactionState) {
    TransactionOpened,
    TransactionPending,
    TransactionClosed,
};

extern NSString * NSStringFromTransactionState(TransactionState state);
~~~

#### TransactionStateMachine.m

~~~{objective-c}
NSString * NSStringFromTransactionState(TransactionState state) {
  switch (state) {
    case TransactionOpened:
      return @"Opened";
    case TransactionPending:
      return @"Pending";
    case TransactionClosed:
      return @"Closed";
    default:
      return nil;
  }
}
~~~

---

To understand anything is to make sense of its context. What we may see as obvious and self-evident, is all but unknown to someone without our frame of reference. Our inability to truly understand or appreciate the differences in perspective and information between ourselves and others is perhaps our most basic shortcoming.

理解任何事情其实都是去了解其上下文。可能那些我们看到的很明显且不证自明的东西，对所有那些没有我们的参照系的人来说是未知的。我们无法真正了解和欣赏自己和他人的观点及信息的差异或许是我们最根本的缺点。

That is why, in our constructed logical universe of 0's and 1's, we take such care to separate contexts, and structure our assumptions based on these explicit rules. C storage classes are essential to understanding how a program operates. Without them, we are left to develop as one might walk on egg shells. So take heed of these simple rules of engagement and go forth to code with confidence.

这就是为什么，在我们构建的逻辑 0 和 1 的宇宙中，我们如此谨慎的区分上下文，并基于这些明确的规则上构建我们的假设。C 存储类对于理解程序是如何运行是必不可少的。如果没有他们，我们的开发将如履薄冰。因此，需要谨慎对待这些简单的规则，才能饱含信心的编写代码。
