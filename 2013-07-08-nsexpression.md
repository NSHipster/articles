---
layout: post
title: NSExpression
author: Mattt Thompson
translator: Zihan Xu
category: Foundation
---

每当涉及查询或者整理信息时，Cocoa总是其他标准库羡慕的对象。通过使用`NSPredicate`，[`NSSortDescriptor`](http://nshipster.com/nssortdescriptor/)，以及偶尔使用`NSFetchRequest`，即使是最复杂的数据任务也可以被简化成为几行_极其容易读懂_的代码。

现在，NSHipster们无疑已经熟悉`NSPredicate` 了（如果你还不熟悉，下周一定要过来看看），不过如果我们更进一步看看`NSPredicate`，我们会发现`NSPredicate`其实是由更小的部分而组成：两个`NSExpression`（一个左手值和一个右手值），和一个运算符相比较（比如`<`，`IN`，`LIKE`等等）。

大多数开发者通过`+predicateWithFormat:`来使用`NSPredicate`，`NSExpression`是一个相对难懂的类。真可惜啊，因为`NSExpression`本身的功能非常强大。

所以，亲爱的读者，请允许我来表达我对`NSExpression`深深的尊重和着迷：

## 评估数学

关于`NSExpression`你所要知道的第一件事就是它的主要目的是减少表达。如果你思考一下评估`NSPredicate`的过程，你会发现它有两个表达和一个比较符号，所以我们需要将两个表达简化为运算符可以处理的表达--非常像编译一行代码的过程。

这就是我们要学习的`NSExpression`的第一招： **做数学题**。

~~~{objective-c}
NSExpression *expression = [NSExpression expressionWithFormat:@"4 + 5 - 2**3"];
id value = [expression expressionValueWithObject:nil context:nil]; // => 1
~~~

这并不是[Wolfram Alpha](http://www.wolframalpha.com/input/?i=finn+the+human+like+curve)，但是如果加入评估数学表达式对于你的应用很有用的话，那么...你就可以使用NSExpression。

## 函数

我们仅仅触及了`NSExpression`的表面。觉得一台电脑仅仅做小学数学不怎么厉害？那高中的统计学怎么样？

~~~{objective-c}
NSArray *numbers = @[@1, @2, @3, @4, @4, @5, @9, @11];
NSExpression *expression = [NSExpression expressionForFunction:@"stddev:" arguments:@[[NSExpression expressionForConstantValue:numbers]]];
id value = [expression expressionValueWithObject:nil context:nil]; // => 3.21859...
~~~

> `NSExpression` 函数以给定数目的子表达式作为参数。比如，在上述例子中，要得到集合的标准差，数列中的数字要被`+expressionForConstantValue:`封装。虽然只是一个小小的不便（它最终却能使得`NSExpression`变得极其灵活），却足以使第一次尝试它的人绊倒。

如果你觉得 [键值编码简单集合运算符](http://nshipster.com/kvc-collection-operators/) （`@avg`，`@sum`等等）不够用，也许`NSExpression`的自带的统计，算术和位运算功能能激起你的兴趣。

> **要注意的是**：[根据Apple的`NSExpression`文档中的表格](http://developer.apple.com/library/ios/#documentation/cocoa/reference/foundation/Classes/NSExpression_Class/Reference/NSExpression.html)，很明显，Mac OS X & iOS的功能可用性之间没有重叠。看起来最近的iOS版本的确支持如`stddev`之类的函数，但这些变化并没有显示在头文件或者文档里。如果你注意到任何变化，请以[pull request的形式](https://github.com/NSHipster/articles/pulls)告诉我，不胜感激。

### 统计

- `average:`
- `sum:`
- `count:`
- `min:`
- `max:`
- `median:`
- `mode:`
- `stddev:`

### 基本运算

这些函数需要用两个`NSExpression`对象来表达数字。

- `add:to:`
- `from:subtract:`
- `multiply:by:`
- `divide:by:`
- `modulus:by:`
- `abs:`

### 高级运算

- `sqrt:`
- `log:`
- `ln:`
- `raise:toPower:`
- `exp:`

### 边界函数

- `ceiling:` - _（不小于数组中的值的最小积分值）_
- `trunc:` - _（最接近但不大于数组中的值的积分值）_

### 与`math.h`函数类似的函数

`ceiling`非常容易和`ceil(3)`混淆。`ceiling`作用于数字数组，而`ceil(3)`作用于一个`double`值（且它并没对应的内置`NSExpression`函数）。`floor:`在这里的作用和`floor(3)`一样。

- `floor:`

### 随机函数

两个变量--一个带参数，一个不带参数。不带参数时，`random`返回`rand(3)`的等值，而`random:`则从`NSExpression`的数字数组中取任意元素。

- `random`
- `random:`

### 二进制运算

- `bitwiseAnd:with:`
- `bitwiseOr:with:`
- `bitwiseXor:with:`
- `leftshift:by:`
- `rightshift:by:`
- `onesComplement:`

### 日期函数

- `now`

### 字符串函数

- `lowercase:`
- `uppercase:`

### 空操作

- `noindex:`

## 自定义函数

除了这些内置的函数，你也可以在`NSExpression`中调用自定义函数。[由Dave DeLong所撰写的这篇文章](http://funwithobjc.tumblr.com/post/2922267976/using-custom-functions-with-nsexpression) 详述了这个过程。

首先，在类别中定义一个对应的函数：

~~~{objective-c}
@interface NSNumber (Factorial)
- (NSNumber *)factorial;
@end

@implementation NSNumber (Factorial)
- (NSNumber *)factorial {
    return @(tgamma([self doubleValue] + 1));
}
@end
~~~

然后，这样使用函数（`+expressionWithFormat:` 中的`FUNCTION()`宏是构造`-expressionForFunction:`等等的过程的简写。）:

~~~{objective-c}
NSExpression *expression = [NSExpression expressionWithFormat:@"FUNCTION(4.2, 'factorial')"];
id value = [expression expressionValueWithObject:nil context:nil]; // 32.578...
~~~

这样的优势在于， 通过直接调用`-factorial`，我们可以调用`NSPredicate`查询中的函数。比如，我们可以定义一个`location:withinRadius:`方法来轻松的查询用户当前位置附近的管理对象。

正如Dave在他的文章中所提到的那样，这些用例十分边缘化，但它们肯定可以成为你的保留节目中有趣的技巧。.

---

下一周，我们将在刚刚学过的`NSExpression`的基础上继续探索`NSPredicate`和其它一切容易被忽视的内容。敬请期待！
