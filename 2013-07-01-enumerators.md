---
title: "NSFastEnumeration / NSEnumerator"
author: Mattt Thompson
translator: Chester Liu
category: Cocoa
excerpt: "遍历体现了计算能力的有趣之处。封装只执行一次的逻辑是一回事，把这个封装好的逻辑应用到集合当中的所有元素完全是另一回事了——这也正是计算机程序强大功能的一个体现。"
status:
    swift: n/a
---

遍历体现了计算能力的有趣之处。封装只执行一次的逻辑是一回事，把这个封装好的逻辑应用到集合当中的所有元素完全是另一回事了——这也正是计算机程序强大功能的一个体现。

每种编程范式都有自己遍历集合的方法：

- **过程式** 在一个循环内进行指针自增
- **面向对象** 对集合内的所有对象都施加一个函数或者 block
- **函数式** 递归地处理数据结构

作为本博客的主旨，Objective-C 语言扮演了一种神奇的桥接角色，在传统的 C 语言过程式编程和以 Smalltalk 为先驱的面向对象式编程之间架起了一座桥梁。从很多角度看来，遍历这部分的实现，是检验这座桥靠不靠谱的重要标准。

这篇文章将会涉及到 Objective-C & Cocoa 当中所有不同的遍历集合的方式。具体的方法有哪些呢？且听我慢慢道来。

---

## C 循环（`for/while`）

`for` 和 `while` 循环是遍历集合的“经典”方法。任何学过大学计算机基础的人都可以写出下面的代码：

~~~{objective-c}
for (NSUInteger i = 0; i < [array count]; i++) {
  id object = array[i];
  NSLog(@"%@", object)
}
~~~

但是用过 C 风格循环的人也都知道，这个方法容易导致 [差一错误](https://zh.wikipedia.org/wiki/%E5%B7%AE%E4%B8%80%E9%94%99%E8%AF%AF)——特别是使用非标准形式时。

幸运的是，Smalltalk 使用一种叫做 [列表生成式](http://en.wikipedia.org/wiki/List_comprehension) 的方法改善了这个问题，也就是大家今天所熟知的 `for/in` 循环。

## 列表生成式 （`for/in`）

通过使用高层抽象，表明我们想遍历一个集合当中的所有元素，这种方法不仅减少了错误的发生，同时也减少了代码量：

~~~{objective-c}
for (id object in array) {
    NSLog(@"%@", object);
}
~~~

在 Cocoa 当中，生成式方法可以用在任何实现了 `NSFastEnumeration` 协议的类上，包括 `NSArray`, `NSSet`, 和 `NSDictionary`。

### `<NSFastEnumeration>`

`NSFastEnumeration` 只包含一个方法：

~~~{objective-c}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
~~~

> - `state`: 遍历中需要使用的上下文信息，确保在遍历过程中集合不被修改。
> - `stackbuf`: 一个 C 数组，内容是将要被调用者遍历的对象们.
> - `len`: stackbuf 中最多能返回的元素数量.

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

> - `state`: 遍历器使用的一个状态信息，通常在遍历开始时这个值被设置成 0
> - `itemsPtr`: 一个 C 对象数组
> - `mutationsPtr`: 用于检测集合是否被修改的状态信息
> - `extra`: 一个 C 数组，可以用来保存返回值

每个优雅的抽象背后，都是些注定要隐藏起来的实现。`itemPtr`？，`mutationsPtr`？`extra`？开玩笑吗，都是些什么东西？

> 读者如果好奇的话，[Mike Ash 有一篇非常精彩的博客](http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html) ，在文章中他深入到了内部细节当中，提供了 `NSFastEnumeration` 若干参考实现。

对于 `NSFastEnumeration` 你需要了解的是它 _很快_ 。哪怕没有很明显的超过，也至少和你自己使用 `for` 循环是一样快的。高速背后的秘密是 `-countByEnumeratingWithState:objects:count:` 这个函数，它会缓存集合成员，并按需加载。和单线程的 `for` 循环实现不同的是，对象的加载是可以并发的，以最大程度利用系统资源。

苹果推荐在可能的情况下使用 `NSFastEnumeration` `for/in` 风格进行集合的遍历。老实说，单纯看它的用法是如此简单，性能表现也很好，这并不是个很难做出的选择。说真的，使用它吧。

## `NSEnumerator`

当然在 `NSFastEnumeration` 出现之前（大约是 OS X Leopard / iOS 2.0 时期），还有一位值得尊敬的先烈 `NSEnumerator`。

在外行人看来，`NSEnumerator` 是一个实现了下面两个方法的抽象类：

~~~{objective-c}
- (id)nextObject
- (NSArray *)allObjects
~~~

`nextObject` 返回集合类型中的下一个元素，如果没有就返回 `nil`。`allObjects` 返回所有剩余的元素（如果有的话）。`NSEnumerator` 只能向一个方向遍历，而且只能进行单增。

要想遍历一个集合当中的所有元素，需要这样使用 `NSEnumerator`：

~~~{objective-c}
id object = nil;
NSEnumerator *enumerator = ...;
while ((object = [enumerator nextObject])) {
    NSLog(@"%@", object);
}
~~~

...另外，为了跟上现在孩子们的脚步，`NSEnumerator` 本身也实现了 `<NSFastEnumeration>` 协议：

~~~{objective-c}
for (id object in enumerator) {
    NSLog(@"%@", object);
}
~~~

如果你想给自己的非集合支持的自定义类添加快速遍历功能的话，使用 `NSEnumerator` 可能是更加方便而且易用的方法，相比深入 `NSFastEnumeration` 的实现细节而言。

关于 `NSEnumeration` 几个有趣的小知识：

- 使用一行代码实现数组反转（忽略"点"语法的过度使用）`array.reverseObjectEnumerator.allObjects`。
- 在 [`NSEnumeratorLinq`](https://github.com/k06a/NSEnumeratorLinq) 的帮助下进行 LINQ 风格的操作，这个库使用了链式的 `NSEnumerator` 子类。
- 使用 [`TTTRandomizedEnumerator`](https://github.com/mattt/TTTRandomizedEnumerator) 可以方便地随机取出集合当中的元素，又是一个第三方库，它支持使用随机顺序进行元素遍历。

## 使用 Blocks 进行遍历

最后，随着 OS X Snow Leopard / iOS 4 中 blocks 语法的引入，一种新的基于 block 的遍历集合的方法也被加入进来：

~~~{objective-c}
[array enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
    NSLog(@"%@", object);
}];
~~~

诸如 `NSArray`, `NSSet`, `NSDictionary`，和 `NSIndexSet` 这些集合类型都包含了一系列类似的 block 遍历方法。

这种方法的一个优势是当前对象的索引 （`idx`）会跟随对象传递进来。`BOOL` 指针可以用于提前返回，相当于传统 C 循环当中的 `break` 语句。

除非你真的需要在遍历时使用数字索引，使用 `for/in` `NSFastEnumeration` 几乎总是更快的选择。

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
> - `NSEnumerationConcurrent`: 指示 Block 遍历应当是并发的。遍历的顺序是不确定而且未定义的；这个标志位是一个提示，可能在某些情况下会被实现方忽略；Block 中的代码必须在并发调用的情况下是安全的。

> - `NSEnumerationReverse`: 指示遍历应该是反向进行的，这个选项在 `NSArray` 和 `NSIndexSet` 中可用；在 `NSDictionary` 和 `NSSet` 中，以及和 `NSEnumerationConcurrent` 同时使用的情况下，行为是未定义的。

再重申一次，快速遍历几乎可以肯定要比 block 遍历快很多，不过如果你被迫要使用 blocks 的话这些选项可能会有用。

---

到现在，你已经了解到了 Objective-C 和 Cocoa 当中所以常见的遍历方法。

很有趣的一点是，当我们仔细研究这些方法时，我们能学习到抽象的重要性。高层的抽象不仅仅写起来方便，理解起来更容易，而且还往往比使用“困难的方法”要快。

高层命令会表明自己要达到的目的，例如“把这个集合当中的所有元素都遍历一遍”，它们把实现完全交给编译器进行高层优化，这一点通过传统的循环当中进行指针运算是完全做不到的。上下文是很强大的工具，根据上下文来设计 API 和功能，最终是为了实现抽象所承诺达到的目的：更容易地解决更大规模的问题。
