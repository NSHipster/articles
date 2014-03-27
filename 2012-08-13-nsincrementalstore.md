---
layout: post
title: NSIncrementalStore

ref: "https://developer.apple.com/library/mac/#documentation/CoreData/Reference/NSIncrementalStore_Class/Reference/NSIncrementalStore.html"
framework: Foundation
rating: 9.5
published: true
description: 即使这个博客就是专门讲一些晦涩接口，但是`NSIncrementalStore`又刷新了我们对与“晦涩”这个词的理解。这个接口在iOS 5中被发布，相对于其他大家一定会用到的条目，它并没有在更新日志里有更着重的声明。但是讽刺的是，它有可能是iOS 5的API里最重要的一个，它将从现在开始改变我们创建应用的方式。
---


即使这个博客就是专门讲一些晦涩接口，但是`NSIncrementalStore`又刷新了我们对与“晦涩”这个词的理解。

这个接口在iOS 5中被发布，相对于其他大家一定会用到的条目，它并没有在更新日志里有更着重的声明。

它的[编程指南](https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/IncrementalStorePG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010706)仅仅只有82个字，可能是所有编程指南里字数最少的了吧。

要不是因为在[WWDC 2011 Session 303](https://deimos.apple.com/WebObjects/Core.woa/BrowsePrivately/adc.apple.com.8266478284.08266478290.8365294535?i=2068798830)被随口提到了，可能它早就被完完全全遗忘了。

但是，`NSIncrementalStore`依旧可能是iOS 5放出的最重要的接口之一。

## 终究来说，它立足于Core Data

`NSIncrementalStore`依旧是一个继承于`NSPersistentStore`的抽象类，根据文档它的设计是为了“创建一个能加载和保存不断增长数据的持久化储存，让管理大的需要共享的数据集变得可能”。基于其实所有的我们常用的数据库适配器，都可以从大规模可分享的数据储存中加载数据，上面这个定义其实不怎么样，但是我们现在要介绍的确实是一个该死的奇迹。

如果你不是很精通Core Data，这里是一些背景知识：

[Core Data](http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/CoreData/cdProgrammingGuide.html)是苹果关于对象关系映射的一个框架，至少有一半以上的苹果iOS和Mac商店上的应用、和成千上万的第三方应用使用了Core Data。Core Data很复杂，那是因为它专门用来解决复杂问题，从用的最多的场景到边界情况都涵盖了。

这其实都是在说，Core Data是你绝对应该在你应用里使用的一个框架。

Core Data的持久化储存是可以与[Active Record](http://ar.rubyonrails.org)之类的其他对象关系映射的数据库适配器相比较的。Core Data通过[managed object contexts](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObjectContext_Class/NSManagedObjectContext.html)来响应请求，通过处理[取出请求](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSFetchRequest_Class/NSFetchRequest.html)来读写持久层的数据。对于大多数应用来说，这个持久层应该是一个本地的SQLite数据库。

而有了`NSIncrementalStore`，开发者便有了一个有理由地、被准许的方式去创建一个储存，而且不用管在后端的储存是怎样的实现，而且创建起来还很简单，只需要实现一些必须的方法就好了：

## 实现一个NSIncrementalStore的子类

### `+type` 和 `+initialize`

`NSPersistentStore`实例并不是直接被创建，相反地，它们像`NSURLProtocol`或者`NSValueTransformer`按照工厂模式创建，在这个工厂模式中，它们用`NSPersistentStoreCoordinator`注册他们的类，然后他们才在`-addPersistentStoreWithType:configuration:URL:options:error:`被调用的时候，根据需要创建持久化储存实例。

一个类最开始被加载的时候调用`+initialize`方法，所以一般在这个方法内注册`NSPersistentStoreCoordinator`。

~~~{objective-c}
+ (void)initialize {
  [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
  return NSStringFromClass(self);
}
~~~

### `-loadMetadata:`

`loadMetadata:`是可增长储存配置自己的方法，而且有一个大概怎么把所有事情配置好的模板。特别地，你需要给每个储存配置UUID和储存类型，以下是配置的例子：

~~~{objective-c}
NSMutableDictionary *mutableMetadata = [NSMutableDictionary dictionary];
[mutableMetadata setValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:NSStoreUUIDKey];
[mutableMetadata setValue:[[self class] type] forKey:NSStoreTypeKey];
[self setMetadata:mutableMetadata];
~~~

### `-executeRequest:withContext:error:`

Here's where things get interesting, from an implementation standpoint. (And where it all goes to hell, from an API design standpoint) 

从实现的角度，事情开始有意思起来了（但是从接口设计角度来说，那就糟透了）。

`executeRequest:withContext:error:`方法须要传进去三个参数，分别是`NSPersistentStoreRequest`、`NSManagedObjectContext`和一个`NSError`指针。

`NSPersistentStoreRequest`的角色有些类似抽象子类，因为这个请求的可能无非是`NSFetchRequestType`或者`NSSaveRequestType`。如果是前者的_获取_请求，请求参数其实是`NSFetchRequest`类的一个实例，而它是`NSPersistentStoreRequest`的子类。同样的，如果是_保存_请求，它将是`NSSaveChangesRequest`的一个实例（本文最开始以为没有这个类还被误导了）。

这个方法会根据不同的请求参数返回各种具体的、完全不同的返回值(如果是`NSFetchRequest`的话，那就是查询结果`resultType`)。唯一能解释清楚的方法就是，串讲完所有可能性：

#### 请求类型: `NSFetchRequestType`

- 返回类型: `NSManagedObjectResultType`、`NSManagedObjectIDResultType`或者`NSDictionaryResultType`

> **返回**: 封装在`NSArray`内的符合请求的结果

- 返回类型: `NSCountResultType`
  
> **返回**: 返回一个用<del><tt>NSNumber</tt></del><ins><tt>NSArray</tt>封装的<tt>NSNumber</tt>来表示符合请求的数量</ins>

#### 请求类型: `NSSaveRequestType`
  
> **返回**: 空的`NSArray`

所以，在一个方法内就能对同一个对象做所有读_并且_写的操作，起码所有复杂的操作都在同一地方，对吧？

### `-newValuesForObjectWithID:withContext:error:`

这个方法会在一个对象断层或者它的值已经被managed object context刷新了的时候被调用。

它返回一个`NSIncrementalStoreNode`节点，它包含一个ID和一个特定的managed object现在的值。这个节点对象还应该包含所有属性，包括managed object的所有多对一关系的ID。这个节点还有一个`version`属性用来决定一个对象的当前状态，但是这可能不是对所有的储存实现都可用。

如果根据`objectID`查找不到响应的对象，那这个方法将会返回`nil`。

### `-newValueForRelationship:forObjectWithID: withContext:error:`

这个方法将在对应关系需要刷新的时候调用，不管是从一个断层或者被managed object context刷新。

不像之前的那个，这个方法的返回值将只是单个关系的现有值，可能的返回类型会根据自然的关系不同而不同：

- **对一**: `NSManagedObjectID`
- **对多**: `NSSet`或者`NSOrderedSet`
- **不存在**: `nil`

### `-obtainPermanentIDsForObjects:error:`

最后，这个方法`executeRequest:withContext:error:`是在当永久ID将被分配给新插入对象的保存请求之前被调用的。就像你可能期望的那样，永久ID的数组要与传进对象的数组相对应。

这一般会对应着对持久层的写入，例如SQL里的一个`INSERT`操作。比如说如果对象对应的行是一个自增的`id`列，那你应该这样生成一个`objectID`：

~~~{objective-c}
[self newObjectIDForEntity:entity referenceObject:[NSNumber numberWithUnsignedInteger:rowID]];
~~~

## 玩转你自己的Core Data后端

通过串讲了一遍`NSIncrementalStore`子类里的所有可以重写的方法，你应该发现你的脑海里跑来跑去的想法可能全都是你怎么能实现一个SQL或者NoSQL储存或者两者结合的一些全新的东西。

而让`NSIncrementalStore`这么让人兴奋的是你_完全能_先搭建一个你最喜欢技术的储存，然后只需要多一点点的配置就可以把它放入现有的Core Data栈中。

所以想象一下，不是SQL或者NoSQL，我们直接写一个连接到线上服务的Core Data储存，比如说接下来要介绍的[AFIncrementalStore](https://github.com/AFNetworking/AFIncrementalStore)。

## AFIncrementalStore: 客户端-服务器应用的终极神圣目标?

[`AFIncrementalStore`](https://github.com/AFNetworking/AFIncrementalStore) 是NSIncrementalStore的子类，运用了[AFNetworking](https://github.com/afnetworking/afnetworking)来自动通过属性和关系来请求所需要的资源。

这意味着你在写应用的时候可以直接与线上网络服务通讯，而_不需要在写的时候暴露底层API的任何细节_。当产生任何获取请求或者有关系断层的时候，一个异步的网络请求将会自动从线上网络服务获取数据。

因为储存已经把所有接口的实现给抽象了出来，你可以从开始就写一个很丰富的获取请求和对象关系。不管接口多么的糟糕、多么的不完整，你可以独立地改变所有客户端业务逻辑的对应关系。

可能最幸福的部分其实是，不用从`NSManagedObjectContext`继承或者为其添加难看的category，所有上面提到的，可能只需要**少于300行的代码**就可以实现。


尽管`NSIncrementalStore`其实在iOS 5就已经有了，但是我们在意识到它的潜力之前，还有很长一段路走。未来是异常光明的，所以你最好戴上你的飞行眼镜，拿上一杯冰拿铁然后开始写一些伟大的代码吧！

> 基于充分披露的精神，`NSIncrementalStore`是通过Drew Crawford写的[这篇帖子](http://sealedabstract.com/code/nsincrementalstore-the-future-of-web-services-in-ios-mac-os-x/)我才真正理解到的。我在iOS 5最开始出来的时候知道有它的存在，但是像所有其他人一样，我没怎么关心。

> 另外，`AFIncrementalStore`是我的一个项目，也是为数不多的能提供`NSIncrementalStore`继承写法的例子之一。我并不是特意想用NSHipster来作为一个我推广自己代码的平台，但我只是觉得它确实是一个很能体现`NSIncrementalStore`特点的例子。

