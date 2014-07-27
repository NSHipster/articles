---
layout: post
title: 对象下标索引
translator: "Zihan Xu"
category: Objective-C
rating: 8.7
---

Xcode 4.4悄然为Objective-C引入了语法革命。然而，像所有的革命一样，我们要费些努力才能找出它的起因和煽动者：Xcode 4.4附带有苹果LLVM编译器4.0，其中纳入了在Clang的前端版本3.1生效的改变。

> 对于外行来说，[Clang](http://clang.llvm.org/index.html)是开源C语言家族对于[LLVM](http://www.llvm.org)编译器的前端。Clang负责可以追溯到几年前的所有重要的语言特点，比如“构建与分析”，ARC，块，以及当通过GCC编译时近3倍的性能提升。

Clang 3.1为Objective-c增加了三个功能，它们的美学和装饰效果可以和Objective-C 2.0引入的变化相媲美：__`NSNumber`字面__，__集合字面__，和__对象的下标索引__。

在一个单一的Xcode发布中，Objective-C从这样：

~~~{objective-c}
NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:42] forKey:@"foo"];
id value = [dictionary objectForKey:@"foo"];
~~~

…变成了这样：

~~~{objective-c}
NSDictionary *dictionary = @{@"foo": @42};
id value = dictionary[@"foo"];
~~~

简洁是清晰的精髓。

较短的代码意味着打字更少，但这也意味着你要了解的更多。即使一点点语法就足以改变一个预言，并且解锁一个新的设计模式。

集合字面成为配置property list更好的选择。<br/>
单元素数组参数变的更加容易接受<br/>
需要封装数值的API变的更加好用。<br/>

然而，在这些语言性能被增加了一年以后，对象下标索引相对来说仍然没有被充分利用。不过，在读完文章以后，你也许可以帮助改变这种情况。

---

C数组的元素在内存中连续分布，并且由第一个元素的地址来引用。为得到某一特定索引的数值，你可以通过用数组元素的大小乘以所需的索引来移位。这个指针算法可以由`[]`操作符来提供。

随着时间的推移，脚本语言在这个熟悉的惯例下有了更多的发挥空间，扩大作用以获得或设置数组中的数值，以及hash值和对象。

随着Clang 3.1的出现，一些都圆满了：最初作为C运算符出现，并由脚本语言应用的内容，现在已经回到了Objective-C。而像上述的昔日的脚本语言一样，Objective-C中的`[]`下标运算符已经被以同样方式重载以处理整数索引的和对象键控的存储单元。

~~~{objective-c}
dictionary[@"foo"] = @42;
array[0] = @"bar"
~~~

>如果Objective-C是C的超集，对象下标索引如何重载`[]`C运算符？现代的Objective-C运行禁止对象的指针运算，使得这个语法转换成为可能。

这一切真正变得有趣的地方是当你用下标支持来延伸自己的类的时候：

### 自定义索引下标

为你的类增加自定义索引下标，你只需要声明和实现下列方法：

~~~{objective-c}
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
~~~

### 自定义键位下标

同样的，你也可以通过声明和实现以下方法增加自定义键位下标到你的类：

~~~{objective-c}
- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
~~~

## 用DSL来进行自定义下标索引

描述这一切的重点在于鼓励你用非常规的方式来思考这一语言特性。目前，类中的大多数自定义下标索引被用来方便的访问私有集合类。但没有什么能够阻止你这样做：

~~~{objective-c}
routes[@"GET /users/:id"] = ^(NSNumber *userID){
  // ...
}
~~~

...or this:

~~~{objective-c}
id piece = chessBoard[@"E1"];
~~~

...or this:

~~~{objective-c}
NSArray *results = managedObjectContext[@"Product WHERE stock > 20"];
~~~

考虑到下标的灵活性和简洁，它完全可以用来生成[DSL](http://en.wikipedia.org/wiki/Domain-specific_language)。当在你自己的类中定义自定义下标索引时，它们是如何被实现的并没有限制。你可以使用这个语法来提供定义应用路线，搜索查询，复合属性存取器或者仅仅是旧的KVO的缩写。

---

当然，这是很危险的想法。下标索引不是你的新自行车，也不是一个巨大的锤子。_它甚至不是一个巨大的螺丝刀！_如果一定要用一件事物来描述对象下标索引，那就是麻烦。龙来了。

当然，它的确为改变语法惯例以有用的使用它们开发了新的有趣的机会。
