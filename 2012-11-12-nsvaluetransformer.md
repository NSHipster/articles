---
layout: post
title: NSValueTransformer
category: Cocoa
author: Mattt Thompson
excerpt: "在 Foundation 框架的所有类中，NSValueTransformer 也许是从 OS X 平台迁移到 iOS 平台表现最差的那个。但是，经过一些雕琢和使用场景的改变，也许它能在你的应用中发挥重大作用。"
---

在 Foundation 框架的所有类中，NSValueTransformer 也许是从 OS X 平台迁移到 iOS 平台表现最差的那个。

为什么？嗯，有两个原因：

第一个也是最明显的一个原因是 `NSValueTransformer` 主要被用于 AppKit 框架的 Cocoa binding 中。它可以自动地把一个属性的值转换为另一个属性的值，而不需要中间的粘合代码，比如判断一个布尔值，或者检查一个对象是否为 `nil`。而 iOS 却没有 Cocoa binding 特性。

第二个原因和 iOS 没有多大关系，而是和 Objective-C 运行时有关。自从有了 block，在对象之间传递行为变得简单多了——比起用 `NSValueTransformer` 或 `NSInvocation` 简单太多了。所以，即使 iOS 明天就可以使用 Cocoa binding，那也无法确定 `NSValueTransformer` 现在还是否会发挥那样至关重要的作用。

但是，你猜怎么着？`NSValueTransformer` 已经成熟很多了。经过一些雕琢和使用场景的改变，也许它能在你的应用中发挥重大作用。

---

`NSValueTransformer` 是一个抽象类，它用于把一个值转换为另一个值。它指定了可以处理哪类输入，并且合适时甚至支持反向的转换。

下面是一个常见的实现代码：

~~~{objective-c}
@interface ClassNameTransformer: NSValueTransformer {}
@end

#pragma mark -

@implementation ClassNameTransformer
+ (Class)transformedValueClass {
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    return (value == nil) ? nil : NSStringFromClass([value class]);
}
@end
~~~

我们通常不会直接初始化 `NSValueTransformer`。而是，与 `NSPersistentStore` 和 `NSURLProtocol` 类似，需要注册相应的实现类，由管理者角色的对象负责初始化它们——这里有点不同的是，你需要把_对象_注册为一个带有指定名字的单例。

~~~{objective-c}
NSString * const ClassNameTransformerName = @"ClassNameTransformer";

// Set the value transformer
[NSValueTransformer setValueTransformer:[[ClassNameTransformer alloc] init] forName:ClassNameTransformerName];

// Get the value transformer
NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:ClassNameTransformerName];
~~~

通常，我们会在 `NSValueTransformer` 实现类的 `+initialize` 方法中注册单例对象，这样在需要用它的时候就不用再做别的什么事情了。

到这里你可能发现了 `NSValueTransformer` 的一个大毛病：它太难用了！创建一个类，实现一大把的方法，声明一个常量，_并且_还要在 `+initialize` 方法中注册它？我看还是别用算了。

在这个使用 block 的年代，我们想要——不对，需要——一种一行（坨）代码就能搞定的实现方式。

[一点儿元编程](https://github.com/mattt/TransformerKit/blob/master/TransformerKit/NSValueTransformer%2BTransformerKit.m#L36)就可以轻松搞定这件事情。注意啦：

~~~{objective-c}
NSString * const TKCapitalizedStringTransformerName = @"TKCapitalizedStringTransformerName";

[NSValueTransformer registerValueTransformerWithName:TKCapitalizedStringTransformerName
           transformedValueClass:[NSString class]
returningTransformedValueWithBlock:^id(id value) {
  return [value capitalizedString];
}];
~~~

我并不是为了迎合读者你，但是在写本篇文章时，我特别想看看怎么能够提升使用 `NSValueTransformer` 的体验。最终的结果就是 [TransformerKit](https://github.com/mattt/TransformerKit)。

整个库的基础是一个使用了一些 Objective-C 运行时技巧的 `NSValueTransformer` category。同时包含了一些方便的例子，比如字符串大小写转换（例如，`CamelCase`、`llamaCase`、`snake_case` 和 `train-case`）。

现在有了这身漂亮的行头，我们要开始好好想想它可能会在哪里发挥用处：

- `NSValueTransformers` 可以很好地用于表示一个转换链。比如，一个应用可能需要把用户输入经过一系列的转换（比如，去掉首尾空格，去掉注音字符，然后让首字母大写）后才能把结果发送到主干系统中。
- 与 block 不同的是，`NSValueTransformer` 封装了反向转换。比如说，你想要把 REST API 中的键值与模型对象的属性一一对应；你可以创建一个可以逆向转换的 `NSValueTransformer` 类，初始化时把 `snake_case` 转换为 `llamaCase`，发送数据到服务器端时把 `llamaCase` 转换为 `snake_case`。
- 另外一个优于 block 的地方是：`NSValueTransformer` 子类可以暴露出新的属性来配置转换行为。增加成员变量还可以简单清楚地记录结果，或者保存一些转换过程中需要用到的东西。
- 不要忘了，我们还可以用在 Core Data 中使用 `NSValueTransformer`，可以用它从二进制字段中编码及解码出组合数据。这些年似乎不再流行这么做了，但是，对于那些模型化得不是很好的信息，把简单的数据用这种方式序列化是非常有效的。但是不要这样把图片存到数据库中——那八成不会是个好主意。

以及还有很多其他的用处，就不再一一列举了。

---

`NSValueTransformer` 并没有 AppKit 框架的印记，它保留了 Foundation 框架与计算基本概念的纯洁联系：接受输入，返回输出。

尽管它还不是很成熟，但一点新鲜的改造可以让 `NSValueTransformer` 回到 NS-嬉皮士界（NSHipsterdom）的最高宗旨：那些我们尚不知道有用的解决方案其实一直在那等待着我们发现。
