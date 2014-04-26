---
layout: post 
title: "namespacing"
framework: "Objective-C"
description: 
translator: "Sheldon Huang"
---
>为什么Objecive-C中的很多类名都是NS开头的呢？

我保证在你第一次给别人介绍Objective-C的时候肯定会听到这句话。

就像父母要向孩子解释什么是死亡或者圣诞老人是不存在的问题一样，父母总是寄希望时间会让孩子自己找到答案。

>你既然这么问了，实际上NS代表了NeXTSTEP （好吧，其实是代表NeXTSTEP/Sun，我们只是做个简单的介绍），它被用于...

你越解释，你会发现对方越失望，接下来，他们不在只是随便问问了，他们开始问一些你更难解释的问题--在Objective-C中[@](http://nshipster.com/at-compiler-directives/)是什么？

* * *

命名一直是Objective-C的硬伤，和那些优雅的语言相比，Objective-C缺乏标识符容器这点引来了很多不切实际的批评家。

他们总是说：Objective-C不像其他流行语言一样提供模块化机制来避免类名和方法名的冲突。

相反地，Objective-C 依靠前缀来确保APP中的方法名不会影响其他有相同名字的代码。

插入一个关于类型系统的题外话之后我们会继续进入关于命名的讨论。

##C和Objective-C中的类型

我曾在这个博客上多次提过Objective-C是直接建立在C语言之上的，一个重要的原因是Objective-C和C语言共用一个类型系统，他们都要求标识符是全局唯一的。

你可以自己定义一个和@interface同名的静态变量，编译之后你会得到一个错误：

~~~{objective-c}
@interface XXObject : NSObject
@end

static char * XXObject;//将“XXObject”重新定义为不同的符号

~~~

也就是说，Objective-C的runtime在C语言的类型系统上又创建了一个抽象层，它甚至可以允许下面这段代码被编译:

~~~{objective-c}

@protocol Foo
@end

@interface Foo : NSObject <Foo 
    id Foo
}

@property id Foo;
+ (id)Foo;
- (id)Foo;
@end

@interface Foo (Foo)
@end

@implementation Foo
@synthesize Foo;

+ (id)Fo 
    id Foo = @"Fo
    return Foo
}
@end

~~~

2. 通过Objective-C的环境，程序能区别所有相同名字的类，协议，类别，实例变量，实例方法和类方法。

>一个变量能重新调整一个已经存在的方法也是得益与C语言的类型系统（这个有点像一个变量能够隐藏它的隐藏功能）

##前缀

在Objective-C应用中的所有类名都必须是全局唯一的。由于很多不同的框架中会有一些相似的功能，所以在名字上也可能会有重复（users， views， requests / responses 等等），所以[苹果官方文档](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html)规定类名需要有2-3个字母作为前缀。

###类前缀

[苹果官方建议](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/Conventions/Conventions.html)两个字母作为前缀的类名是为官方的库和框架准备的，而对于作为第三方开发者的我们，官方建议使用3个或者更多的字母作为前缀去命名我们的类。

一个资深的Mac或iOS开发者可能会记得下面大部分的缩写标识符：

|Prefix|Frameworks|
|---|:---|
|AB |AddressBook / AddressBookUI|
|AC   |Accounts|
|AD   |iAd|
|AL   |AssetsLibrary|
|AU   |AudioUnit|
|AV   |AVFoundation|
|CA   |CoreAnimation|
|CB   |CoreBluetooth|
|CF   |CoreFoundation / CFNetwork|
|CG   |CoreGraphics / QuartzCore / ImageIO|
|CI   |CoreImage|
|CL   |CoreLocation|
|CM  |CoreMedia / CoreMotion|
|CV   |CoreVideo|
|EA   |ExternalAccessory|
|EK   |EventKit / EventKitUI|
|GC   |GameController|
|GLK   |GLKit|
|JS   |JavaScriptCore|
|MA   |MediaAccessibility|
|MC   |MultipeerConnectivity|
|MF   |MessageUI|
|MIDI  |CoreMIDI|
|MK  |MapKit|
|MP   |MediaPlayer|
|NK   |NewsstandKit|
|NS   |Foundation, AppKit, CoreData|
|PK   |PassKit|
|QL   |QuickLook|
|SC |SystemConfiguration|
|Se   |Security|
|SK   |StoreKit / SpriteKit|
|SL   |Social|
|SS   |Safari Services|
|TW   |Twitter|
|UI   |UIKit|
|UT   |MobileCoreServices|

####第三方类前缀
* * *

直到最近，由于[CocoaPods](http://cocoapods.org/)的出现和大量新的iOS开发者的涌现，开源代码的遍布，第三方代码在很大程度上对苹果和其余的Objective-C开发社区来说已经不是问题了。最近苹果官方的命名指南也发生了变化，它将三个字母作为前缀的建议只是做为一个习惯做法。

正因为这样，那些已经存在的第三方库依然使用2个字母作为前缀，你可以参考一些那些[在GitHub上得到很多start的Objective-C的仓库](https://github.com/search?l=Objective-C&q=stars%3A%3E1&s=stars&type=Repositories)。

|Prefix|Frameworks|
|---|:---|
|AF | AFNetworking ("Alamofire")|
|RK | RestKit|
|PU|  GPUImage
|SD | SDWebImage|
|MB | MBProgressHUD|
|FB | Facebook SDK|
|FM | FMDB ("Flying Meat")|
|JK | JSONKit|
|UI|  FlatUI
|NI | Nimbus|
|AC|  Reactive Cocoa

我们已经看到在在这个[第三方库](https://github.com/AshFurrow/AFTabledCollectionView)的前缀已经和我的[AFNetworking](https://github.com/AFNetworking/AFNetworking)一样了，所以最好还是要在你的代码中遵守要三个字母以上的作为类前缀的规定(https://github.com/AshFurrow/AFTabledCollectionView)。

>对于那些针对特殊功能而写的第三方库的作者，可以考虑在下一次主要升级时使用[@compatibility_alias](http://nshipster.com/at-compiler-directives/)来为那些使用者们提供一个天衣无缝的转移路径。

##方法前缀

不仅是类容易造成命名冲突，selectors也很容易造成命名冲突，甚至方法比类会有更多的问题。
考虑一下这个category：

~~~{objective-c}
@interface NSString (PigLatin)
- (NSString *)pigLatinString;
@end

~~~

如果 `-pigLatinString`方法被另一个category实现了（或者以后版本的iOS或者Mac OS X 在NSString类中也添加了同样名字的方法），那么调用这个方法就会得到未定义的行为错误，因为我们不能保证在runtime中哪个方法会先被定义。

我们可以通过在方法名前加前缀来避免这个问题，就像加这个类名一样（在类别名前加前缀也是个好办法）：

~~~{objective-c}
@interface NSString (XXXPigLatin)
- (NSString *)xxx_pigLatinString;
@end

~~~

苹果官方建议[所有category方法都要使用前缀](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html#//apple_ref/doc/uid/TP40011210-CH6-SW4)，这个建议比类名需要加前缀的规定更加广为人知和接受。

很多开发者都在热情地讨论着这个规定的某一方面。然而，无论是通过成本角度还是效益角度来衡量命名冲突风险的可能性都是是不全面的:

category的主要功能是通过语法糖将一些有用的功能包裹进原来的类中。任何一个category方法都可以被选择性实现，你也可以把他当做是self的一个隐型功能方法。

当我在编译器的环境参数中将`OBJC_PRINT_REPLACED_METHODS`这个参数设置为YES，那我们就能在编译的时候检测方法名是否有冲突。实际上，方法名的冲突是很少发生的，而且在发生的时候，他们通常会得到一个`needlessly duplicated across dependencies`的提示。即使发生最坏的情况，程序在运行是出现异常，那么很可能是两个方法名一样，那么他们做的事情也是一样的，所以结果也不会有什么变化。就像Swiss Army Knife写了一个category，他定义了`NSArray`中的` -firstObject`这个方法，那么只要苹果官方没有在`NSArray`中加这个方法的话，那么这个类别方法一直有效的。

在苹果官方的编程指南中有很多严肃又松散的解释。这里没有固定的文档，他们可能一直变化。看到这里，如果你还是悬而未决，那么你只需要把的category方法名加上前缀，如果你还是选择不去做任何改变，那么你就等着自食其果吧。

###Swizzling
* * * 

在Swizzling时，方法名加前缀或者后缀也是非常有必要的，这个我在上周关于[swizzling](http://nshipster.com/method-swizzling/)的文章中提到过。

~~~{objective-c}

@implementation UIViewController (Swizzling)

- (void)xxx_viewDidLoad {
    [self xxx_viewDidLoad];

    // Swizzled implementation
}

~~~

##我们真的需要命名空间么？

在最近关于Objective-C替换、改造和重塑的讨论中，我可以明显地发现命名空间是未来的一个趋势。但是它到底给我们带来了什么呢？

美学？除了IETE成员和军事人员，我想没有人会喜欢CLAs的视觉审美，但是用::，/或者另外的.这些符号真的能让我们觉得更好么？你真的想要以后把`NSArray`叫做`Foundation Array`？（那我这个NSHipster.com这个博客不是也得改名字了?!）

语义学？让我们比较一下其他的语言，看看他们是怎么用命名空间的，那么你就会意识到命名空间不能解决所有不明确的问题。可能在某些额外环境的情况下，那些命名空间会出现更多问题。

你还是不赞同，那么你想象一下Objective-C的命名空间的实现可能会像这个样子，你会觉得怎么样:

~~~{objective-c}

@namespaceX
    @implementation Obje
    @using F: Foundatio
    - (void)fo
      F:Array *array = @[@1,@2, @3
      // 
   
    @en
@end

~~~

虽然Objective-C有繁琐的代码但也有容易理解的明显优点。我们作为开发者去讨论NSString的时候，我们不会把它理解成别的意思，编译器也是一样。当我们在阅读代码时，我们不需要过多地去考虑这些代码是什么作用的。并且最重要的是，NSString这个类名在google这些搜索引擎中[很容易就可以找到， 你不会得到其他结果](http://lmgtfy.com/?q=NSString)。

不管怎样，如果你对这个讨论感兴趣的话，我强烈建议你看一下[Kyle Sluder](http://optshiftk.com/)的[《 this namespace feature proposal 》](http://optshiftk.com/2012/04/draft-proposal-for-namespaces-in-objective-c/)。非常值得一看。
