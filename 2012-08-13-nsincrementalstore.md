---
layout: post
title: NSIncrementalStore

ref: "https://developer.apple.com/library/mac/#documentation/CoreData/Reference/NSIncrementalStore_Class/Reference/NSIncrementalStore.html"
framework: Foundation
rating: 9.5
published: true
description: Even for a blog dedicated to obscure APIs, <tt>NSIncrementalStore</tt> sets a new standard. It was introduced in iOS 5, with no more fanfare than the requisite entry in the SDK changelog. Ironically, it is arguably the most important thing to come out of iOS 5, which will completely change the way we build apps from here on out.
---

Even for a blog dedicated to obscure APIs, `NSIncrementalStore` brings a new meaning to the word "obscure". 

尽管这个博客就是专门讲一些晦涩接口，但是`NSIncrementalStore`又刷新了我们对与“晦涩”这个词的理解。

It was introduced in iOS 5, with no more fanfare than the requisite entry in the SDK changelog.

这个接口在iOS 5中被发布，相对于其他大家一定会用到的条目，它并没有在更新日志里有更着重的声明。

Its [programming guide](https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/IncrementalStorePG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010706) weighs in at a paltry 82 words, making it the shortest by an order of magnitude.

它的[编程指南](https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/IncrementalStorePG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010706)仅仅只有82个字，是所有编程指南里字数最少的了吧。

If it weren't for an offhand remark during [WWDC 2011 Session 303](https://deimos.apple.com/WebObjects/Core.woa/BrowsePrivately/adc.apple.com.8266478284.08266478290.8365294535?i=2068798830), it may have gone completely unnoticed.

如果不是因为在[WWDC 2011 Session 303](https://deimos.apple.com/WebObjects/Core.woa/BrowsePrivately/adc.apple.com.8266478284.08266478290.8365294535?i=2068798830)被随口提到了，可能它早就被完完全全遗忘了。

And yet, `NSIncrementalStore` is arguably the most important thing to come out of iOS 5.
但是，`NSIncrementalStore`依旧可能是iOS 5放出的最重要的接口之一。

## At Last, A Foothold Into Core Data
## 最后，其实是Core Data的立足点

`NSIncrementalStore` is an abstract subclass of `NSPersistentStore` designed to "create persistent stores which load and save data incrementally, allowing for the management of large and/or shared datasets". And while that may not sound like much, consider that nearly all of the database adapters we rely on load incrementally from large, shared data stores. What we have here is a goddamned miracle.

`NSIncrementalStore`依旧是一个继承于`NSPersistentStore`的抽象类，根据文档它的设计是为了“创建一个能加载和保存不断增长数据的持久化储存”

For those of you not as well-versed in Core Data, here's some background: 
如果你不是很精通Core Data，这里是一些背景知识可以：


[Core Data](http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/CoreData/cdProgrammingGuide.html) is Apple's framework for object relational mapping. It's used in at least half of all of the first-party apps on Mac and iOS, as well as thousands of other third-party apps. Core Data is complex, but that's because it solves complex problems, covering a decades-worth of one-offs and edge cases.

[Core Data](http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/CoreData/cdProgrammingGuide.html)是苹果关于对象关系映射的一个框架，至少有一半以上的苹果iOS和Mac商店上的应用、和成千上万的第三方应用用了Core Data。Core Data很复杂，那是因为它专门用来解决复杂问题，既涵盖了一些长时间的一次性事物也包括了很多便捷情况。

This is all to say that Core Data is something you should probably use in your application.
这其实都是在说，Core Data是你应该用在你应用里的一个框架。

Persistent stores in Core Data are comparable to database adapters in other ORMs, such as [Active Record](http://ar.rubyonrails.org). They respond to changes within [managed object contexts](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObjectContext_Class/NSManagedObjectContext.html) and handle [fetch requests](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSFetchRequest_Class/NSFetchRequest.html) by reading and writing data to some persistence layer. For most applications, that persistent layer has been a local SQLite database.
Core Data的持久化储存是可以与其他对象关系映射的数据库适配器相比较的，例如[Active Record](http://ar.rubyonrails.org)。Core Data通过[managed object contexts](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObjectContext_Class/NSManagedObjectContext.html)来响应请求，通过处理[取出请求](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSFetchRequest_Class/NSFetchRequest.html)来读写持久层的数据。对于大多数应用来说，这个持久层应该是一个本地的SQLite数据库。


With `NSIncrementalStore`, developers now have a sanctioned, reasonable means to create a store that connects to whatever underlying backend you like--and rather simply, too. All it takes is to implement a few required methods:

而有了`NSIncrementalStore`，开发者便有了一个有理由地、被准许的方式去创建一个不管在后端连接什么的储存，而且创建起来还很简单，只需要实现一些必须的方法就好了。

## Implementing an NSIncrementalStore Subclass

## 实现一个NSIncrementalStore的子类

### `+type` and `+initialize`

### `+type` 和 `+initialize`

`NSPersistentStore` instances are not created directly. Instead, they follow a factory pattern similar to `NSURLProtocol` or `NSValueTransformer`, in that they register their classes with the `NSPersistentStoreCoordinator`, which then constructs persistent store instances as necessary when `-addPersistentStoreWithType:configuration:URL:options:error:` is called. The registered persistent store classes are identified by a unique "store type" string (`NSStringFromClass` is sufficient, but you could be pedantic by specifying a string that follows the convention of ending in `-Type`, like `NSSQLiteStoreType`).

`NSPersistentStore`实例并不是直接被创建，相反地，它们像`NSURLProtocol`或者`NSValueTransformer`按照工厂模式创建，在这个工厂模式中，它们用`NSPersistentStoreCoordinator`注册他们的类，然后他们才在`-addPersistentStoreWithType:configuration:URL:options:error:`被调用的时候，根据需要创建持久化储存实例。

`+initialize` is automatically called the first time a class is loaded, so this is a good place to register with `NSPersistentStoreCoordinator`:
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

### `-loadMetadata:`

`loadMetadata:` is where the incremental store has a chance to configure itself. There is, however, a bit of Kabuki theater boilerplate that's necessary to get everything set up. Specifically, you need to set a UUID for the store, as well as the store type. Here's what that looks like:

`loadMetadata:`是增长储存配置自己的方法，而且有一个大概怎么把所有事情配置好的模板。特别地，你需要给每个储存配置UUID和储存类型，以下是那些配置的例子：

~~~{objective-c}
NSMutableDictionary *mutableMetadata = [NSMutableDictionary dictionary];
[mutableMetadata setValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:NSStoreUUIDKey];
[mutableMetadata setValue:[[self class] type] forKey:NSStoreTypeKey];
[self setMetadata:mutableMetadata];
~~~

### `-executeRequest:withContext:error:`

### `-executeRequest:withContext:error:`

Here's where things get interesting, from an implementation standpoint. (And where it all goes to hell, from an API design standpoint) 

从实现的角度来说，现在事情开始有意思起来了。（但是从接口设计角度来说，那就糟透了）

`executeRequest:withContext:error:` passes an `NSPersistentStoreRequest`, an `NSManagedObjectContext` and an `NSError` pointer.

`executeRequest:withContext:error:`方法传进三个参数，分别是`NSPersistentStoreRequest`、`NSManagedObjectContext`和一个`NSError`指针。

`NSPersistentStoreRequest`'s role here is as a sort of abstract subclass. The request parameter will either be of type `NSFetchRequestType` or an `NSSaveRequestType`. If it has a _fetch_ request type, the request parameter will actually be an instance of `NSFetchRequest`, which is a subclass of `NSPersistentStoreRequest`. Likewise, if it has a _save_ request type, it will be an instance of `NSSaveChangesRequest` (this article was originally mistaken by stating that there was no such a class).

`NSPersistentStoreRequest`的角色有些类似抽象子类，因为这个请求的可能无非是`NSFetchRequestType`或者`NSSaveRequestType`。如果是前者的_获取_请求，请求参数其实是`NSFetchRequest`类的一个实例，而它是`NSPersistentStoreRequest`的子类。同样的，如果是_保存_请求，它将是`NSSaveChangesRequest`的一个实例（本文最开始以为没有这个类还被误导了）。

This method requires very specific and very different return values depending on the request parameter (and the `resultType`, if it's an `NSFetchRequest`). The only way to explain it is to run through all of the possibilities:

这个方法会根据不同的请求参数返回各种具体的、完全不同的返回值(如果是`NSFetchRequest`的话，那就是查询结果`resultType`)。唯一能解释清楚的方法就是，解释清楚所有可能性：

#### 请求类型: `NSFetchRequestType`

- 返回类型: `NSManagedObjectResultType`、`NSManagedObjectIDResultType`或者`NSDictionaryResultType`

> **返回**: 封装在`NSArray`内的符合请求的结果

- 返回类型: `NSCountResultType`
  
> **返回**: <del><tt>NSNumber</tt></del><ins><tt>NSArray</tt> 返回一个 <tt>NSNumber</tt> 来表示符合请求的数量</ins>

#### 请求类型: `NSSaveRequestType`
  
> **返回**: 空`NSArray`

So, one method to do all read _and_ write operations with a persistence backend. At least all of the heavy lifting goes to the same place, right?

所以，一个方法就能对同一个做所有读_和_写的操作，起码所有复杂的操作都在同一地方，对吧？

### `-newValuesForObjectWithID:withContext:error:`

### `-newValuesForObjectWithID:withContext:error:`

This method is called when an object faults, or has its values refreshed by the managed object context. 

这个方法会在一个对象断层，或者它的值已经被managed object context刷新了。

It returns an `NSIncrementalStoreNode`, which is a container for the ID and current values for a particular managed object. The node should include all of the attributes, as well as the managed object IDs of any to-one relationships. There is also a `version` property of the node that can be used to determine the current state of an object, but this may not be applicable to all storage implementations.

它返回一个`NSIncrementalStoreNode`，它包含一个ID和一个特定managed object的现在的值。这个node对象还应该包含所有属性，包括managed object所有多对一关系的ID。

If an object with the specified `objectID` cannot be found, this method should return `nil`.

如果根据`objectID`查找不到响应的对象，那这个方法将会返回`nil`。

### `-newValueForRelationship:forObjectWithID: withContext:error:`

### `-newValueForRelationship:forObjectWithID: withContext:error:`

This one is called when a relationship needs to be refreshed, either from a fault or by the managed object context. 

这个方法将在对应关系需要刷新的时候调用，不管是从一个断层或者被managed object context刷新。

Unlike the previous method, the return value will be just the current value for a single relationship. The expected return type depends on the nature of the relationship:

不像之前的那个，这个方法的返回值将只是单个关系的现有值，可能的返回类型会根据自然的关系不同而不同：

- **对一**: `NSManagedObjectID`
- **对多**: `NSSet`或者`NSOrderedSet`
- **不存在**: `nil`

- **to-one**: `NSManagedObjectID`
- **to-many**: `NSSet` or `NSOrderedSet`
- **non-existent**: `nil`

### `-obtainPermanentIDsForObjects:error:`

### `-obtainPermanentIDsForObjects:error:`

Finally, this method is called before `executeRequest:withContext:error:` with a save request, where permanent IDs should be assigned to newly-inserted objects. As you might expect, the array of permanent IDs should match up with the array of objects passed into this method.

最后，这个方法是在`executeRequest:withContext:error:`当永久ID将被分配给新插入对象的保存请求之前被调用的。就想你可能期望的那样，永久ID的数组要与传进对象的数组相对应。

This usually corresponds with a write to the persistence layer, such as an `INSERT` statement in SQL. If, for example, the row corresponding to the object had an auto-incrementing `id` column, you could generate an objectID with:

这对应着写入持久层，例如SQL里的一个`INSERT`操作。比如说如果对象对应的行是一个自增的`id`列，那你应该这样生成一个`objectID`：

~~~{objective-c}
[self newObjectIDForEntity:entity referenceObject:[NSNumber numberWithUnsignedInteger:rowID]];
~~~

## Roll Your Own Core Data Backend

## 玩转你自己的Core Data后端

Going through all of the necessary methods to override in an `NSIncrementalStore` subclass, you may have found your mind racing with ideas about how you might implement a SQL or NoSQL store, or maybe something new altogether.

通过串讲了一遍`NSIncrementalStore`子类里的所有可以重写的方法，你应该发现你的脑海里跑来跑去的想法全都是你怎么能实现一个SQL或者NoSQL储存或者两者结合的一些全新的东西。

What makes `NSIncrementalStore` so exciting is that you _can_ build a store on your favorite technology, and drop that into any existing Core Data stack with little to no additional configuration.

而让`NSIncrementalStore`这么让人兴奋的是你_能_先搭建一个你最喜欢技术的储存，然后只需要一点点多一些的配置就可以把它放入现有的Core Data栈中。

So imagine if, instead SQL or NoSQL, we wrote a Core Data store that connected to a webservice. Allow me to introduce [AFIncrementalStore](https://github.com/AFNetworking/AFIncrementalStore).

所以想象一下，不是SQL或者NoSQL，我们直接写一个连接到线上服务的Core Data储存，比如说接下来要介绍的[AFIncrementalStore](https://github.com/AFNetworking/AFIncrementalStore)。

## AFIncrementalStore: The Holy Grail of Client-Server Applications?
## AFIncrementalStore: 客户端-服务器应用的最终神圣目标?

[`AFIncrementalStore`](https://github.com/AFNetworking/AFIncrementalStore) is an NSIncrementalStore subclass that uses [AFNetworking](https://github.com/afnetworking/afnetworking) to automatically request resources as properties and relationships are needed.

[`AFIncrementalStore`](https://github.com/AFNetworking/AFIncrementalStore) 是NSIncrementalStore的子类，在集成后还用了[AFNetworking](https://github.com/afnetworking/afnetworking)来自动通过属性和关系来请求所需要的资源。

What this means is that you can now write apps that communicate with a webservice _without exposing any of the details about the underlying API_. Any time a fetch request is made or an attribute or relationship faults, an asynchronous network request will fetch that information from the webservice.

这以为这你在写应用的时候可以直接与线上网络服务通讯，而_不需要在写的时候暴露底层API的任何细节_。当产生任何获取请求或者有关系断层的时候，一个异步的网络请求将会自动从线上网络服务获取数据。

Since the store abstracts all of the implementation details of the API away, you can write expressive fetch requests and object relationships from the start. No matter how bad or incomplete an API may be, you can change all of that mapping independently of the business logic of the client.

因为储存已经把所有接口的实现给抽象了出来，你可以从开始就写一个很丰富的获取请求和对象关系。不管接口多么的遭、多么的不完整，你可以独立地改变所有客户端商业逻辑的对应关系。

Perhaps the best part is that all of this is possible in **just under 300 LOC**. No need to subclass `NSManagedObject` or add obtrusive categories on `NSManagedObjectContext`--it just works.

可能最幸福的部分其实是，不用从`NSManagedObjectContext`继承或者为其添加难看的category，所有上面提到的可能只需要**少于300行的代码**就可以实现。

Even though `NSIncrementalStore` has been around since iOS 5, we're still a long way from even beginning to realize its full potential. The future is insanely bright, so you best don your aviators, grab an iced latte and start coding something amazing.

尽管`NSIncrementalStore`其实在iOS 5就已经有了，但是我们在意识到它的潜力之前，还有很长一段路走。未来是异常光明的，所以你最好戴上你的飞行眼镜，拿上一杯冰拿铁然后开始写一些伟大的代码吧！

> In the spirit of full disclosure, `NSIncrementalStore` was brought to my attention by [this blog post by Drew Crawford](http://sealedabstract.com/code/nsincrementalstore-the-future-of-web-services-in-ios-mac-os-x/). I caught wind of it around the time iOS 5 originally came out, but like everyone else, I paid it no mind.

> 在基于充分披露的精神下，`NSIncrementalStore`是通过Drew Crawford写的[这篇帖子](http://sealedabstract.com/code/nsincrementalstore-the-future-of-web-services-in-ios-mac-os-x/)我才真正理解到的。我在iOS 5最开始出来的时候知道有它的存在，但是像所有其他人一样，我没怎么关系。

> Also, `AFIncrementalStore` is a project of mine, which is offered as one of only a few examples of an `NSIncrementalStore` subclass available. I don't mean to use NSHipster as a platform to promote my own code, but I thought this to be a particularly salient example.

> 另外，`AFIncrementalStore`是我的一个项目，也是为数不多的能提供`NSIncrementalStore`继承方法的例子之一。我并不是想用NSHipster来作为一个我推广自己代码的平台，但我只是觉得它确实是一个很能体现`NSIncrementalStore`特点的例子。

