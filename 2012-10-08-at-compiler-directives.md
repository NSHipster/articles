---
layout: post
title: "@"
translator: "Zihan Xu"
ref: ""
framework: Objective-C
rating: 8.7
published: true
description: "所以如果我们要对这难以捉摸的Objective-C品种观“码”，我们要看些什么？方括号，长的荒唐的方法名，和<tt>@</tt>指令。\"at\"符号编译器指令对于理解Objective-C的格式以及其前身和相关机制非常重要。它是使得Objective-C如此强大，具有表现力，并能一路编译到C的含糖胶。"
---

观鸟人将那些某一特定事物的说不清楚的特性称为["Jizz"][1]（我发誓这不是我编造出来的）。

这一表达可以被我们拿来描述资深人士如何只看一眼就从[Go](http://golang.org)中区分[Rust](http://www.rust-lang.org)，或者从[Elixir](http://elixir-lang.org)中区分[Ruby](http://www.ruby-lang.org)。

但有些东西就像是竖着的酸痛的大拇指：

Perl，它的短小的带有特殊字符的变量名，读起来就像是[Q\*bert的脏话](http://imgur.com/WyG2D)。

Lisp,它使用括号之多由那个[古老的笑话](http://discuss.fogcreek.com/joelonsoftware3/default.asp?cmd=show&ixPost=94232&ixReplies=38)最能体现，据说俄罗斯在80年代为了证明他们成功窃取了一些SDI导弹拦截代码的源代码而展示了如下页面：

                    )))
                  ) )
                ))) ) ))
               )))))
              )))
            ))
          )))) ))
        )))) ))
      )))
    )

所以如果我们要对这难以捉摸的Objective-C品种观“码”，我们要看些什么？对了，以下就是：

- 方括号
- 长的荒唐的方法名
- `@`指令

`@`或者"at"符号编译器指令对于理解Objective-C的格式以及其起源和底层机制非常重要。它是使得Objective-C如此强大，具有表现力，并仍能一路编译成底层 C 语言的关键。

它的用途多种多样，用它本身来描述`@`的含义的唯一转确的说法就是“和Objective-C有关的简写符号”。它们涵盖了广泛的实用性却也由晦涩难懂的用法，从主要的用途如`@interface`和`@implementation`到你的整个职业生涯或许都不会遇到的如`@defs`和`@compatibility_alias`。

但对于有抱负想成为一个NSHipster的人来说，十分熟悉`@`指令就如同一个音乐爱好者按时间顺序循环披头士的全部歌曲的能力（更重要的是，对它们中的每一首都有及其强烈的看法）。

## Interface & Implementation

`@interface`和`@implementation`是你学习Objective-C时最先学的东西：

- `@interface`...`@end`
- `@implementation`...`@end`

你之后才会学习到类别（Category）和类扩展（Class Extension）。

类别通过增加新的类和实例方法来扩展现有类的行为。作为惯例，类别被定义在它们自己的`.{h,m}`文件里，比如：

#### MyObject+CategoryName.h

~~~{objective-c}
@interface MyObject (CategoryName)
  - (void)foo;
  - (BOOL)barWithBaz:(NSInteger)baz;
@end
~~~

#### MyObject+CategoryName.m

~~~{objective-c}
@implementation MyObject (CategoryName)
  - (void)foo {
    // ...
  }

  - (BOOL)barWithBaz:(NSInteger)baz {
    return YES;
  }
@end
~~~

类别对于在标准框架类上添加便利函数非常有用（只是不要过分使用你的工具函数）。

> 小贴士：你可以创建一个定义类似`+appNameDarkGrayColor`类方法的`NSColor`／`UIColor`调色板类别，而不是胡乱使用随机的，任意的颜色值。之后你可以通过创建方法的别名如`+appNameTextColor`的方式增加一个语义层，新的方法返回`+appNameDarkGrayColor`。

扩展看上去很像类别，但是省略了类别名称。这些通常在`@implementation`前定义来指定私有接口，甚至会覆盖interface中定义的属性：

~~~{objective-c}
@interface MyObject ()
@property (readwrite, nonatomic, strong) NSString *name;
- (void)doSomething;
@end

@implementation MyObject
@synthesize name = _name;

// ...

@end
~~~

### 属性

属性指令也是你会很早学会的知识：

- `@property`
- `@synthesize`
- `@dynamic`

关于属性值得注意的一点是，从Xcode 4.4开始，我们再也不需要明确的合成属性了。在`@interface`中被声明的属性在implementation中被自动的合成（与前面有下划线的ivar名称一起，比如`@synthesize propertyName = _propertyName`）。

### 正向类声明

有的时候，`@interface`声明会在属性中引用外部类或者作为参数类型。而不是给每个类添加`#import`语句，在头文件使用前置声明，并且在implementation中引入它们是很好的做法。

- `@class`

编译时间更短，循环引用的机会更少；如果你还没有习惯这样做，那你就应该这么做了。

### 实例变量可见性

类提供状态以及通过属性和方法提供变化的接口而不是直接展示实例变量，这是一个通用的惯例。

尽管ARC通过内存管理使得使用实例变量更加安全，但上述的自动属性合成删除了实例变量被声明的地方。

不管怎么说，在实例变量_被_直接操作的情况下，有以下可见性指令：

- `@public`：实例变量可使用符号`person->age = 32"`被直接读取。
- `@package`：实例变量是公开的，除非它被指定在框架外（仅适用64位架构）
- `@protected`：实例变量仅可由其类和其衍生类访问
- `@private`：实例变量仅可由其类访问

~~~{objective-c}
@interface Person : NSObject {
  @public
  NSString name;
  int age;

  @private
  int salary;
}
~~~

## 协议

当一个Objective-C程序员意识到她可以定义自己的协议时，这就是她的编程进化的转折点。

协议的美好之处在于，它们可以允许程序员设计可在类的层次结构之外采用的合同。这是美国梦的中心，平等的口号：无论你是谁，你从哪里来：只要足够努力任何人都可以获得成功。

…至少这很理想化，不是吗？

- `@protocol`...`@end`：定义了一组将在服从该协议的类中实现的方法，就好像它们被加入到那个类的接口中一样。

没有连接协议的负担，结构的稳定性和表现力简直棒极了。

### 要求选项

你可以通过指定方法为必须和可选来更深入的定制一个协议。可选的方法在接口上存根，以便能被Xcode自动完成但如果方法没有被实现又不生成警告。协议方法默认是必须的。

`@required`和`@optional`的语法遵循能见宏：

~~~{objective-c}
@protocol CustomControlDelegate
  - (void)control:(CustomControl *)control didSucceedWithResult:(id)result;
@optional
  - (void)control:(CustomControl *)control didFailWithError:(NSError *)error;
@end
~~~

## 处理异常

Objective-C主要通过`NSError`来沟通意想不到的异常状态。而其他语言使用异常处理，Objective-C则将异常以及程序员错误降级为真正的异常的行为。

`@`指令用于`try/catch/finally`块的传统惯例上：

~~~{objective-c}
@try{
  // 试图执行下列语句
  [self getValue:&value error:&error];

  // 如果有异常或者被显式抛出...
  if (error) {
    @throw exception;
  }
} @catch(NSException *e) {
  // …在这里处理异常
}  @finally {
  // 总是在@try或@catch block的尾部执行这个
  [self cleanup];
}
~~~

## 常量

常量是一些特定固定值的简短表示。常量或多或少直接影响着程序员的心情。用这个来衡量，Objective-C长久以来都是程序员的痛苦。

### 对象常量

不久前，Objective-C只有`NSString`常量。但随着[Apple的LLVM 4.0编译器](http://clang.llvm.org/docs/ObjectiveCLiterals.html)的发布，让我们欣喜的是`NSNumber`，`NSArray`和`NSDictionary`常量被添加了。

- `@""`：返回一个由引号内Unicode内容初始化的`NSString`对象。
- `@42`，`@3.14`，`@YES`，`@'Z'`：返回一个由相关类构造初始化的`NSNumber`对象，比如`@42` → `[NSNumber numberWithInteger:42]`，或者`@YES` → `[NSNumber numberWithBool:YES]`。支持使用后缀进一步指定类型，如`@42U` → `[NSNumber numberWithUnsignedInt:42U]`。
- `@[]`：返回一个由冒号分隔的对象列表作为内容的`NSArray`对象。比如，`@[@"A", @NO, @2.718]` → `[NSArray arrayWithObjects:@"A", @NO, @2.718, nil]` （注意在数组常量中结束标记`nil`是不需要的）。
- `@{}`：返回一个由特定键－值对初始化作为内容的`NSDictionary`对象，格式： `@{@"someKey" : @"theValue"}`。
- `@()`：动态评估封装的表达，并返回基于其值的合适的对象常量（比如，`const char*`返回`NSString`，`int`返回`NSNumber`，等等。）。这也是使用数字常量和`枚举`值的指定方式。

### Objective-C 常量

选择器和协议可以作为方法参数。`@selector()`和`@protocol()`作为伪常量指令返回一个指向特定选择器（`SEL`）或协议（`Protocol *`）的指针。

- `@selector()`：返回一个指向有特定名称的选择器的`SEL`指针。用于类似`-performSelector:withObject:`的方法。
- `@protocol()`：返回一个指向有特定名称的协议的`Protocol *`指针。用于类似`-conformsToProtocol:`的方法。

### C 常量

常量也能以别的方式工作，如将 Objective-C 对象转换成 C 值。这些指令能让我们揭开 Objective-C 的神秘面纱，让我们开始了解究竟发生了什么。

你知不知道所有的Objective-C的类和对象都只是被美化了的`struct`？又或者一个对象的整个身份的关键在于那个`struct`的一个`isa`字段？

对于大多数人来说，至少大多数时间，学习这方面只是仅仅是学术练习。但对于任何在低层最优化冒险的人来说，这仅仅是根本的出发点。

- `@encode()`：返回一个类型的[类型编码](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html)。这个类型值可以用于`NSCoder -encodeValueOfObjCType:at`中的第一个参数编码。
- `@defs()`：返回一个Objective-C类的布局。比如，定义一个与`NSObject`有相同布局的struct，你只需要这样：

~~~{objective-c}
struct {
  @defs(NSObject)
}
~~~

> 编者注：正如读者[@secboffin](http://twitter.com/secboffin) & [@ameaijou](http://twitter.com/ameaijou)所指出的，`@defs`已经无法在现在的Objective-C runtime中使用。

## 优化

有一些`@`编译器指令专门用来为常用的优化提供快捷。

- `@autoreleasepool{}`：如果你的代码中包含创建大量临时对象的紧密的循环，你可以通过`@autorelease`更加积极的释放这些寿命短暂，局部范围内的对象来达到优化。`@autoreleasepool`替换并且改进了旧的又慢又不能在ARC中使用的`NSAutoreleasePool`。
- `@synchronized(){}`：这个指令为在一特定的环境中（通常是`self`）确保安全执行某一特定块提供了一个便捷的方法。这种情况的死锁很昂贵，所以，对于针对特定级别的线程安全的类来说，建议使用专用的`NSLock`属性或者使用如`OSAtomicCompareAndSwap32(3)`的底层的死锁函数。

## 兼容性

如果之前的指令对你来说都不新鲜了，那么有很大可能你并不知道这一个：

- `@compatibility_alias`：允许现有类有不同的名称作为别名。

比如[PSTCollectionView](https://github.com/steipete/PSTCollectionView)使用了`@compatibility_alias`来显著提高对[UICollectionView](http://nshipster.com/uicollectionview/)向后兼容的直接替换的使用体验：

~~~{objective-c}
// 允许代码使用UICollectionView如同它可以在iOS SDK 5使用一样。
// http://developer.apple.com/legacy/mac/library/#documentation/DeveloperTools/gcc-3.3/gcc/compatibility_005falias.html
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@compatibility_alias UICollectionViewController PSTCollectionViewController;
@compatibility_alias UICollectionView PSTCollectionView;
@compatibility_alias UICollectionReusableView PSTCollectionReusableView;
@compatibility_alias UICollectionViewCell PSTCollectionViewCell;
@compatibility_alias UICollectionViewLayout PSTCollectionViewLayout;
@compatibility_alias UICollectionViewFlowLayout PSTCollectionViewFlowLayout;
@compatibility_alias UICollectionViewLayoutAttributes     PSTCollectionViewLayoutAttributes;
@protocol UICollectionViewDataSource <PSTCollectionViewDataSource> @end
@protocol UICollectionViewDelegate <PSTCollectionViewDelegate> @end
#endif
~~~

只要聪明的使用这些宏的组合，开发者可以通过引入`PSTCollectionView`来开发`UICollectionView`－－而不需要担心最终项目的部署目标。作为快速替换，同样的代码在iOS6中工作起来几乎和在iOS 4.3中一样。

---

回顾：

**接口与实现**

- `@interface`...`@end`
- `@implementation`...`@end`
- `@class`

**实例变量可视性**

- `@public`
- `@package`
- `@protected`
- `@private`

**属性**

- `@property`
- `@synthesize`
- `@dynamic`

**协议**

- `@protocol`
- `@required`
- `@optional`

**异常处理**

- `@try`
- `@catch`
- `@finally`
- `@throw`

**对象常量**

- `@""`
- `@42`, `@3.14`, `@YES`, `@'Z'`
- `@[]`
- `@{}`
- `@()`

**Objective-C 常量**

- `@selector()`
- `@protocol()`

**C 常量**

- `@encode()`
- `@defs()`

**优化**

- `@autoreleasepool{}`
- `@synchronized{}`

**兼容**

- `@compatibility_alias`

这就是`@`不同面孔下的详尽的描述。它是一个多功能的，电力十足的字符，它体现了这门语言的潜在的设计和机制。

> 这应该是一个完整的清单了，但是我们总有可能忽视一些新的或者长期被遗忘的用途。如果你知道有哪些`@`指令不在清单里，一定要让[@NSHipster](https://twitter.com/nshipster)知道啊。

[1]: http://en.wikipedia.org/wiki/Jizz_(birding)
