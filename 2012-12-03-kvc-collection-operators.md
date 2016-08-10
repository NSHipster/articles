---
layout: post
title: "KVC Collection Operators"
category: Cocoa
excerpt: "Ruby爱好者总爱嘲笑Objective-C臃肿的语法。尽管新的Object Literals语法让我们瘦了几斤，但那些红头发的恶霸们还总是用他们的单行map和花哨的#to_proc符号嘲讽我们。幸运的是，我们有键-值编码这个王牌。"
author: Mattt Thompson
translator: Candyan
---

Ruby爱好者总爱嘲笑Objective-C臃肿的语法。

尽管新的[Object Literals](http://nshipster.com/at-compiler-directives/)特性让我们的语法瘦了几斤，但那些红头发的恶霸们还总是用他们的单行`map`和花哨的[`Symbol#to_proc`](http://pragdave.pragprog.com/pragdave/2005/11/symbolto_proc.html)来嘲讽我们。

实际上，一门语言是否优雅归结起来就是其怎么样能更好的避免循环。`for`，`while`语句是一种拖累；即使是[快速枚举](http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocFastEnumeration.html)也一样。无论你怎么样使他们看起来更加的友好，循环依然是一个在自然语言中用非常简单方式描述所做事情的代码块

"给我这个列表里面所有员工的平均薪酬"，等等。。。

~~~{objective-c}
double totalSalary = 0.0;
for (Employee *employee in employees) {
  totalSalary += [employee.salary doubleValue];
}
double averageSalary = totalSalary / [employees count];
~~~

╮(╯_╰)╭

幸运的是，[键-值编码](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html)给我们了一种更加简洁的，几乎像Ruby一样的方式来做这件事：

~~~{objective-c}
[employees valueForKeyPath:@"@avg.salary"];
~~~

[KVC集合运算符](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/Articles/CollectionOperators.html#//apple_ref/doc/uid/20002176-BAJEAIEE)允许在`valueForKeyPath:`方法中使用key path符号在一个集合中执行方法。无论什么时候你在key path中看见了`@`，它都代表了一个特定的集合方法，其结果可以被返回或者链接，就像其他的key path一样。

集合运算符会根据其返回值的不同分为以下三种类型：

- **简单的集合运算符** 返回的是strings, number, 或者 dates
- **对象运算符** 返回的是一个数组
- **数组和集合运算符** 返回的是一个数组或者集合

要理解其工作原理，最好方式就是去action里面看看。想象一个`Product`类和一个由以下数据所组成的`products`数组：

~~~{objective-c}
@interface Product : NSObject
@property NSString *name;
@property double price;
@property NSDate *launchedOn;
@end
~~~

> 键-值 编码会在必要的时候把基本数据类型的数据自动装箱和拆箱到`NSNumber`或者`NSValue`中来确保一切工作正常。

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Price</th>
      <th>Launch Date</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>iPhone 5</td>
      <td>$199</td>
      <td>September 21, 2012</td>
    </tr>
    <tr>
      <td>iPad Mini</td>
      <td>$329</td>
      <td>November 2, 2012</td>
    </tr>
    <tr>
      <td>MacBook Pro</td>
      <td>$1699</td>
      <td>June 11, 2012</td>
    </tr>
    <tr>
      <td>iMac</td>
      <td>$1299</td>
      <td>November 2, 2012</td>
    </tr>
  </tbody>
</table>

### 简单集合操作符

- `@count`: 返回一个值为集合中对象总数的`NSNumber`对象。
- `@sum`: 首先把集合中的每个对象都转换为`double`类型，然后计算其总，最后返回一个值为这个总和的`NSNumber`对象。
- `@avg`: 把集合中的每个对象都转换为`double`类型，返回一个值为平均值的`NSNumber`对象。
- `@max`: 使用`compare:`方法来确定最大值。所以为了让其正常工作，集合中所有的对象都必须支持和另一个对象的比较。
- `@min`: 和`@max`一样，但是返回的是集合中的最小值。

_例如_：

~~~{objective-c}
[products valueForKeyPath:@"@count"]; // 4
[products valueForKeyPath:@"@sum.price"]; // 3526.00
[products valueForKeyPath:@"@avg.price"]; // 881.50
[products valueForKeyPath:@"@max.price"]; // 1699.00
[products valueForKeyPath:@"@min.launchedOn"]; // June 11, 2012
~~~

>Pro提示：你可以简单的通过把self作为操作符后面的key path来获取一个由`NSNumber`组成的数组或者集合的总值，例如`[@[@(1), @(2), @(3)] valueForKeyPath:@"@max.self"]` (/感谢 [@davandermobile](http://twitter.com/davandermobile), 来自 [Objective Sea](http://objectivesea.tumblr.com/post/34552840247/max-value-nsset-kvc))

### 对象操作符

想象下，我们有一个`inventory`数组，代表了当地苹果商店的当前库存(iPad Mini不足，并且没有新的iMac，因为还没有发货)：

~~~{objective-c}
NSArray *inventory = @[iPhone5, iPhone5, iPhone5, iPadMini, macBookPro, macBookPro];
~~~

- `@unionOfObjects` / `@distinctUnionOfObjects`: 返回一个由操作符右边的key path所指定的对象属性组成的数组。其中`@distinctUnionOfObjects` 会对数组去重, 而且 `@unionOfObjects` 不会.

_例如_：

~~~{objective-c}
[inventory valueForKeyPath:@"@unionOfObjects.name"]; // "iPhone 5", "iPhone 5", "iPhone 5", "iPad Mini", "MacBook Pro", "MacBook Pro"
[inventory valueForKeyPath:@"@distinctUnionOfObjects.name"]; // "iPhone 5", "iPad Mini", "MacBook Pro"
~~~

### 数组和集合操作符

数则和集合操作符跟对象操作符很相似，只不过它是在` NSArray`和`NSSet`所组成的集合中工作的。如果我们做一些例如：比较几个商店中的库存（和我们上一节类似的`appleStore库存`和买iPhone 5和iPad Mini的`versizonStore库存`）这样的工作，这个就会很有用。

- `@distinctUnionOfArrays` / `@unionOfArrays`: 返回了一个数组，其中包含这个集合中每个数组对于这个操作符右面指定的key path进行操作之后的值。正如你期望的，`distinct`版本会移除重复的值。

- `@distinctUnionOfSets`: 和`@distinctUnionOfArrays`差不多, 但是它期望的是一个包含着`NSSet`对象的`NSSet`，并且会返回一个`NSSet`对象。因为集合不能包含重复的值，所以它只有`distinct`操作。

_例如_：

~~~{objective-c}
[@[appleStoreInventory, verizonStoreInventory] valueForKeyPath:@"@distinctUnionOfArrays.name"]; // "iPhone 5", "iPad Mini", "MacBook Pro"
~~~

---

## 这可能是一个可怕的想法

令人好奇的是，[苹果的KVC集合操作符文档](http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/KeyValueCoding/Articles/CollectionOperators.html)冒出了下面这个提示：

> **注意**: 目前还不能自定义集合操作符。

这个提示是有意义的，因为大多数人在第一次看到集合运算符时都在想这个。

然而，事实证明，在我们的小伙伴`objc/runtime`的帮助下，这个实际上 _是_ 有可以能的实现的。

[Guy English](https://twitter.com/gte)有一篇[很神奇的文章](http://kickingbear.com/blog/archives/9)，在文章中，他[swizzles `valueForKeyPath:`](https://gist.github.com/4196641#file_kb_collection_extensions.m)来解析自定义的[DSL](http://en.wikipedia.org/wiki/Domain-specific_language)，其扩展了一些有趣的效果：

~~~{objective-c}
NSArray *names = [allEmployees valueForKeyPath: @"[collect].{daysOff<10}.name"];
~~~

这段代码可以得到只有休了不足10天假期的人的名字（无疑是要提醒他们去休个假吧！）

或者，来看个可笑的极端情况：

~~~{objective-c}
NSArray *albumCovers = [records valueForKeyPath:@"[collect].{artist like 'Bon Iver'}.<NSUnarchiveFromDataTransformerName>.albumCoverImageData"];
~~~

Ruby小伙伴们羡慕吧。只用一行就在艺人记录中过滤出来了名字叫"Bon Iver"的艺人，并且用匹配到的专辑的专辑封面的图像数据初始化了一个`NSImage`对象。

这是一个好的想法吗？可能不是。（`NSPredicate`更加合适，并且其使得逻辑更加简单，易懂）

这个很酷吗？当然啦！这个聪明的例子展示了Objective-C DSL和元编程未来可能的发展方向。

---

KVC集合运算符是一个想节省几行代码并在这一过程中看起来很酷的人必须要了解的。当像Ruby这样的脚本语言自夸它的单行能力是多么的灵活时，我们也许应该花一点儿时间来庆祝Objective-C中的约束和集合操作符。毕竟，Ruby非常非常慢，我说的对吗？&lt;/troll&gt;
