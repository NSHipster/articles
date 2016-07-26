---
title: "NSFastEnumeration / NSEnumerator"
author: Mattt Thompson
translator: Chester Liu
category: Cocoa
excerpt: "Enumeration is where computation gets interesting. It's one thing to encode logic that's executed once, but applying it across a collection—that's what makes programming so powerful."
excerpt: "遍历体现了计算能力的有趣之处。封装只执行一次的逻辑是一回事，把这个封装好的逻辑应用到集合当中的所有元素完全是另一回事了——这也正是计算机程序强大功能的一个体现。"
status:
    swift: n/a
---

Enumeration is where computation gets interesting. It's one thing to encode logic that's executed once, but applying it across a collection—that's what makes programming so powerful.

遍历体现了计算能力的有趣之处。封装只执行一次的逻辑是一回事，把这个封装好的逻辑应用到集合当中的所有元素完全是另一回事了——这也正是计算机程序强大功能的一个体现。

Each programming paradigm has its own way to iterate over a collection:

每种编程范式都有自己遍历集合的方法：

- **Procedural** increments a pointer within a loop
- **过程式** 在一个循环内进行指针自增
- **Object Oriented** applies a function or block to each object in a collection
- **面向对象** 对集合内的所有对象都施加一个函数或者 block
- **Functional** works through a data structure recursively
- **函数式** 递归地处理数据结构

Objective-C, to echo one of the central themes of this blog, plays a fascinating role as a bridge between the Procedural traditions of C and the Object Oriented model pioneered in Smalltalk. In many ways, enumeration is where the proverbial rubber hits the road.

作为本博客的主旨，Objective-C 语言扮演了一种神奇的桥接角色，在传统的 C 语言过程式编程和以 Smalltalk 为先驱的面向对象式编程之间架起了一座桥梁。从很多角度看来，遍历这部分的实现，是检验这座桥靠不靠谱的重要标准。

This article will cover all of the different ways collections are enumerated in Objective-C & Cocoa. How do I love thee? Let me count the ways.

这篇文章将会涉及到 Objective-C & Cocoa 当中所有不同的遍历集合的方式。具体的方法有哪些呢？且听我慢慢道来。

---

## C Loops (`for/while`)

## C 循环（`for/while`）

`for` and `while` loops are the "classic" method of iterating over a collection. Anyone who's taken Computer Science 101 has written code like this before:

`for` 和 `while` 循环是遍历集合的“经典”方法。任何学过大学计算机基础的人都可以写出下面的代码：

~~~{objective-c}
for (NSUInteger i = 0; i < [array count]; i++) {
  id object = array[i];
  NSLog(@"%@", object)
}
~~~

But as anyone who has used C-style loops knows, this method is prone to [off-by-one errors](http://en.wikipedia.org/wiki/Off-by-one_error)—particularly when used in a non-standard way.

但是用过 C 风格循环的人也都知道，这个方法容易导致 [差一错误](https://zh.wikipedia.org/wiki/%E5%B7%AE%E4%B8%80%E9%94%99%E8%AF%AF)——特别是使用非标准形式时。

Fortunately, Smalltalk significantly improved this state of affairs with an idea called [list comprehensions](http://en.wikipedia.org/wiki/List_comprehension), which are commonly known today as `for/in` loops.

幸运的是，Smalltalk 使用一种叫做 [列表生成式](http://en.wikipedia.org/wiki/List_comprehension) 的方法改善了这个问题，也就是大家今天所熟知的 `for/in` 循环。

## List Comprehension (`for/in`)

## 列表生成式 （`for/in`）

By using a higher level of abstraction, declaring the intention of iterating through all elements of a collection, not only are we less prone to error, but there's a lot less to type:

通过使用高层抽象，表明我们想遍历一个集合当中的所有元素，这种方法不仅减少了错误的发生，同时也减少了代码量：

~~~{objective-c}
for (id object in array) {
    NSLog(@"%@", object);
}
~~~

In Cocoa, comprehensions are available to any class that implements the `NSFastEnumeration` protocol, including `NSArray`, `NSSet`, and `NSDictionary`.

在 Cocoa 当中，生成式方法可以用在任何实现了 `NSFastEnumeration` 协议的类上，包括 `NSArray`, `NSSet`, 和 `NSDictionary`。

### `<NSFastEnumeration>`

`NSFastEnumeration` contains a single method:

`NSFastEnumeration` 只包含一个方法：

~~~{objective-c}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
~~~

> - `state`: Context information that is used in the enumeration to, in addition to other possibilities, ensure that the collection has not been mutated.
> - `stackbuf`: A C array of objects over which the sender is to iterate.
> - `len`: The maximum number of objects to return in stackbuf.

One single, _deceptively complicated_ method. There's that `stackbuf` out pointer parameter, and a `state` parameter of type `NSFastEnumerationState *`. Let's take a closer look at that...

一个 _看似很复杂_ 的方法，里面有一个 `stackbuf` 指针出参，一个类型是 `NSFastEnumerationState *` 的 `state` 变量。我们来深入研究一下...

### `NSFastEnumerationState`

~~~{objective-c}
typedef struct {
      unsigned long state;
      id *itemsPtr;
      unsigned long *mutationsPtr;
      unsigned long extra[5];
} NSFastEnumerationState;
~~~

> - `state`: Arbitrary state information used by the iterator. Typically this is set to 0 at the beginning of the iteration.
> - `itemsPtr`: A C array of objects.
> - `mutationsPtr`: Arbitrary state information used to detect whether the collection has been mutated.
> - `extra`: A C array that you can use to hold returned values.

Under every elegant abstraction is an underlying implementation deserving to be hidden from the eyes of God. `itemsPtr`? `mutationsPtr`? `extra`‽ Seriously, what gives?

每个优雅的抽象背后，都是些注定要隐藏起来的实现。`itemPtr`？，`mutationsPtr`？`extra`？开玩笑吗，都是些什么东西？

> For the curious, [Mike Ash has a fantastic blog post](http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html) where he dives into the internals, providing several reference implementations of `NSFastEnumeration`.

> 读者如果好奇的话，[Mike Ash 有一篇非常精彩的博客](http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html) ，在文章中他深入到了内部细节当中，提供了 `NSFastEnumeration` 若干参考实现。

What you should know about `NSFastEnumeration` is that it is _fast_. At least as fast if not significantly faster than rolling your own `for` loop, in fact. The secret behind its speed is how `-countByEnumeratingWithState:objects:count:` buffers collection members, loading them in as necessary. Unlike a single-threaded `for` loop implementation, objects can be loaded concurrently, making better use of available system resources.

对于 `NSFastEnumeration` 你需要了解的是它 _很快_ 。哪怕没有很明显的超过，也至少和你自己使用 `for` 循环是一样快的。高速背后的秘密是 `-countByEnumeratingWithState:objects:count:` 这个函数，它会缓存集合成员，并按需加载。和单线程的 `for` 循环实现不同的是，对象的加载是可以并发的，以最大程度利用系统资源。

Apple recommends that you use `NSFastEnumeration` `for/in`-style enumeration for your collections wherever possible and appropriate. And to be honest, for how easy it is to use and how well it performs, that's a pretty easy sell. Seriously, use it.

苹果推荐在可能的情况下使用 `NSFastEnumeration` `for/in` 风格进行集合的遍历。老实说，单纯看它的用法是如此简单，性能表现也很好，这并不是个很难做出的选择。说真的，使用它吧。

## `NSEnumerator`

But of course, before `NSFastEnumeration` (circa OS X Leopard / iOS 2.0), there was the venerable `NSEnumerator`.

当然在 `NSFastEnumeration` 出现之前（大约是 OS X Leopard / iOS 2.0 时期），还有一位值得尊敬的先烈 `NSEnumerator`。

For the uninitiated, `NSEnumerator` is an abstract class that implements two methods:

在外行人看来，`NSEnumerator` 是一个实现了下面两个方法的抽象类：

~~~{objective-c}
- (id)nextObject
- (NSArray *)allObjects
~~~

`nextObject` returns the next object in the collection, or `nil` if unavailable. `allObjects` returns all of the remaining objects, if any. `NSEnumerator`s can only go forward, and only in single increments.

`nextObject` 返回集合类型中的下一个元素，或者返回 `nil`，在不可用的情况下。`allObjects` 返回所有剩余的元素，如果存在的话。`NSEnumerator` 只能向一个方向遍历，而且只能进行单增。

To enumerate through all elements in a collection, one would use `NSEnumerator` thusly:

要想遍历一个集合当中的所有元素，需要这样使用 `NSEnumerator`：

~~~{objective-c}
id object = nil;
NSEnumerator *enumerator = ...;
while ((object = [enumerator nextObject])) {
    NSLog(@"%@", object);
}
~~~

...or because `NSEnumerator` itself conforms to `<NSFastEnumeration>` in an attempt to stay hip to the way kids do things these days:

...另外，为了跟上现在孩子们的脚步，`NSEnumerator` 本身也实现了 `<NSFastEnumeration>` 协议：

~~~{objective-c}
for (id object in enumerator) {
    NSLog(@"%@", object);
}
~~~

If you're looking for a convenient way to add fast enumeration to your own non-collection-class-backed objects, `NSEnumerator` is likely a much more palatable option than getting your hands messy with `NSFastEnumeration`'s implementation details.

如果你想给自己的非集合支持的自定义类添加快速遍历功能的话，使用 `NSEnumerator` 可能是更加方便而且易用的方法，相比深入 `NSFastEnumeration` 的实现细节而言。

Some quick points of interest about `NSEnumeration`:

关于 `NSEnumeration` 几个有趣的小知识：

- Reverse an array in one line of code with (and excuse the excessive dot syntax) `array.reverseObjectEnumerator.allObjects`.
- 使用一行代码实现数组反转（忽略点语法的过度使用）`array.reverseObjectEnumerator.allObjects`。
- Add LINQ-style operations with [`NSEnumeratorLinq`](https://github.com/k06a/NSEnumeratorLinq), a third-party library using chained `NSEnumerator` subclasses.
- 在 [`NSEnumeratorLinq`](https://github.com/k06a/NSEnumeratorLinq) 的帮助下进行 LINQ 风格的操作，这个库使用了链式的 `NSEnumerator` 子类。
- Shake things up with your collection classes in style with [`TTTRandomizedEnumerator`](https://github.com/mattt/TTTRandomizedEnumerator), another third-party library, which iterates through elements in a random order.
- 使用 [`TTTRandomizedEnumerator`](https://github.com/mattt/TTTRandomizedEnumerator) 可以方便地随机取出集合当中的元素，又是一个第三方库，它支持使用随机顺序进行元素遍历。

## Enumerate With Blocks

## 使用 Blocks 进行遍历

Finally, with the introduction of blocks in OS X Snow Leopard / iOS 4, came a new block-based way to enumerate collections:

最后，随着 OS X Snow Leopard / iOS 4 中 blocks 语法的引入，一种新的基于 block 的遍历集合的方法也被加入进来：

~~~{objective-c}
[array enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
    NSLog(@"%@", object);
}];
~~~

Collection classes like `NSArray`, `NSSet`, `NSDictionary`, and `NSIndexSet` include a similar set of block enumeration methods.

诸如 `NSArray`, `NSSet`, `NSDictionary`，和 `NSIndexSet` 这些集合类型都包含了一系列类似的 block 遍历方法。

One of the advantages of this approach is that the current object index (`idx`) is passed along with the object itself. The `BOOL` pointer allows for early returns, equivalent to a `break` statement in a regular C loop.

这种方法的一个优势是当前对象的索引 （`idx`）会跟随对象传递进来。`BOOL` 指针可以用于提前返回，相当于传统 C 循环当中的 `break` 语句。

Unless you actually need the numerical index while iterating, it's almost always faster to use a `for/in` `NSFastEnumeration` loop instead.

除非你真的需要在遍历时使用数字索引，使用 `for/in` `NSFastEnumeration` 几乎总是更快的选择。

One last thing to be aware of are the expanded method variants with an `options` parameter:

最后一个需要了解的是，这个系列方法还有带有 `options` 参数的扩展版本：

~~~{objective-c}
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts
                         usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
~~~

### `NSEnumerationOptions`

~~~{objective-c}
enum {
   NSEnumerationConcurrent = (1UL << 0),
   NSEnumerationReverse = (1UL << 1),
};
typedef NSUInteger NSEnumerationOptions;
~~~

> - `NSEnumerationConcurrent`: Specifies that the Block enumeration should be concurrent. The order of invocation is nondeterministic and undefined; this flag is a hint and may be ignored by the implementation under some circumstances; the code of the Block must be safe against concurrent invocation.
> - `NSEnumerationReverse`: Specifies that the enumeration should be performed in reverse. This option is available for `NSArray` and `NSIndexSet` classes; its behavior is undefined for `NSDictionary` and `NSSet` classes, or when combined with the `NSEnumerationConcurrent` flag.

Again, fast enumeration is almost certain to be much faster than block enumeration, but these options may be useful if you're resigned to using blocks.

再重申一次，快速遍历几乎可以肯定要比 block 遍历快很多，不过如果你被迫要使用 blocks 的话这些选项可能会有用。

---

So there you have all of the conventional forms of enumeration in Objective-C and Cocoa.

到现在，你已经了解到了 Objective-C 和 Cocoa 当中所以常见的遍历方法。

What's especially interesting is that in looking at these approaches, we learn a lesson about the power of abstraction. Higher levels of abstraction are not just easier to write and comprehend, but can often be much faster than doing it the "hard way".

很有趣的一点是，当我们仔细研究这些方法时，我们能学习到抽象的重要性。高层的抽象不仅仅写起来方便，理解起来更容易，而且还往往比使用“困难的方法”要快。

High-level commands that declare intention, like "iterate through all of the elements of this collection" lend themselves to high-level compiler optimization in a way that just isn't possible with pointer arithmetic in a loop. Context is a powerful thing, and designing APIs and functionality accordingly ultimately fulfill that great promise of abstraction: to solve larger problems more easily.

高层命令会表明自己要达到的目的，例如“把这个集合当中的所有元素都遍历一遍”，它们把实现完全交给编译器进行高层优化，这一点通过传统的循环当中进行指针运算是完全做不到的。上下文是很强大的工具，根据上下文来设计 API 和功能，最终是为了实现抽象所承诺达到的目的：更容易地解决更大规模的问题。
