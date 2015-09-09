---
title: NSIncrementalStore
author: Mattt Thompson
category: Cocoa
excerpt: Even for a blog dedicated to obscure APIs, `NSIncrementalStore` sets a new standard. It was introduced in iOS 5, with no more fanfare than the requisite entry in the SDK changelog. Ironically, it is arguably the most important thing to come out of iOS 5, which will completely change the way we build apps from here on out.
status:
    swift: 1.1
    reviewed: September 8, 2015
---

Even for a blog dedicated to obscure APIs, `NSIncrementalStore` brings a new meaning to the word "obscure".

It was introduced in iOS 5, with no more fanfare than the requisite entry in the SDK changelog.

Its [programming guide](https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/IncrementalStorePG/Introduction/Introduction.html#//apple_ref/doc/uid/TP40010706) weighs in at a paltry 82 words, making it the shortest by an order of magnitude.

If it weren't for an offhand remark during [WWDC 2011 Session 303](https://deimos.apple.com/WebObjects/Core.woa/BrowsePrivately/adc.apple.com.8266478284.08266478290.8365294535?i=2068798830), it may have gone completely unnoticed.

And yet, `NSIncrementalStore` is arguably the most important thing to come out of iOS 5.

## At Last, A Foothold Into Core Data

`NSIncrementalStore` is an abstract subclass of `NSPersistentStore` designed to "create persistent stores which load and save data incrementally, allowing for the management of large and/or shared datasets". And while that may not sound like much, consider that nearly all of the database adapters we rely on load incrementally from large, shared data stores. What we have here is a goddamned miracle.

For those of you not as well-versed in Core Data, here's some background:

[Core Data](http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/CoreData/cdProgrammingGuide.html) is Apple's framework for object relational mapping. It's used in at least half of all of the first-party apps on Mac and iOS, as well as thousands of other third-party apps. Core Data is complex, but that's because it solves complex problems, covering a decades-worth of one-offs and edge cases.

This is all to say that Core Data is something you should probably use in your application.

Persistent stores in Core Data are comparable to database adapters in other ORMs, such as [Active Record](http://ar.rubyonrails.org). They respond to changes within [managed object contexts](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSManagedObjectContext_Class/NSManagedObjectContext.html) and handle [fetch requests](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Classes/NSFetchRequest_Class/NSFetchRequest.html) by reading and writing data to some persistence layer. For most applications, that persistent layer has been a local SQLite database.

With `NSIncrementalStore`, developers now have a sanctioned, reasonable means to create a store that connects to whatever underlying backend you like--and rather simply, too. All it takes is to implement a few required methods:

## Implementing an NSIncrementalStore Subclass

### `+type` and `+initialize`

`NSPersistentStore` instances are not created directly. Instead, they follow a factory pattern similar to `NSURLProtocol` or `NSValueTransformer`, in that they register their classes with the `NSPersistentStoreCoordinator`, which then constructs persistent store instances as necessary when `-addPersistentStoreWithType:configuration:URL:options:error:` is called. The registered persistent store classes are identified by a unique "store type" string (`NSStringFromClass` is sufficient, but you could be pedantic by specifying a string that follows the convention of ending in `-Type`, like `NSSQLiteStoreType`).

`+initialize` is automatically called the first time a class is loaded, so this is a good place to register with `NSPersistentStoreCoordinator`:

~~~{swift}
class CustomIncrementalStore: NSIncrementalStore {
    override class func initialize() {
        NSPersistentStoreCoordinator.registerStoreClass(self, forStoreType:self.type)
    }

    class var type: String {
        return NSStringFromClass(self)
    }
}
~~~


~~~{objective-c}
+ (void)initialize {
  [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
  return NSStringFromClass(self);
}
~~~

### `-loadMetadata:`

`loadMetadata:` is where the incremental store has a chance to configure itself. There is, however, a bit of Kabuki theater boilerplate that's necessary to get everything set up. Specifically, you need to set a UUID for the store, as well as the store type. Here's what that looks like:

~~~{swift}
override func loadMetadata(error: NSErrorPointer) -> Bool {
    self.metadata = [
        NSStoreUUIDKey: NSProcessInfo().globallyUniqueString,
        NSStoreTypeKey: self.dynamicType.type
    ]

    return true
}
~~~

~~~{objective-c}
NSMutableDictionary *mutableMetadata = [NSMutableDictionary dictionary];
[mutableMetadata setValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:NSStoreUUIDKey];
[mutableMetadata setValue:[[self class] type] forKey:NSStoreTypeKey];
[self setMetadata:mutableMetadata];
~~~

### `-executeRequest:withContext:error:`

Here's where things get interesting, from an implementation standpoint. (And where it all goes to hell, from an API design standpoint)

`executeRequest:withContext:error:` passes an `NSPersistentStoreRequest`, an `NSManagedObjectContext` and an `NSError` pointer.

`NSPersistentStoreRequest`'s role here is as a sort of abstract subclass. The request parameter will either be of type `NSFetchRequestType` or an `NSSaveRequestType`. If it has a _fetch_ request type, the request parameter will actually be an instance of `NSFetchRequest`, which is a subclass of `NSPersistentStoreRequest`. Likewise, if it has a _save_ request type, it will be an instance of `NSSaveChangesRequest` (this article was originally mistaken by stating that there was no such a class).

This method requires very specific and very different return values depending on the request parameter (and the `resultType`, if it's an `NSFetchRequest`). The only way to explain it is to run through all of the possibilities:

#### Request Type: `NSFetchRequestType`

- Result Type: `NSManagedObjectResultType`, `NSManagedObjectIDResultType`, or `NSDictionaryResultType`

> **Return**: `NSArray` of objects matching request

- Result Type: `NSCountResultType`

> **Return**: <del><tt>NSNumber</tt></del><ins><tt>NSArray</tt> containing one <tt>NSNumber</tt> of count of objects matching request</ins>

#### Request Type: `NSSaveRequestType`

> **Return**: Empty `NSArray`

So, one method to do all read _and_ write operations with a persistence backend. At least all of the heavy lifting goes to the same place, right?

### `-newValuesForObjectWithID:withContext:error:`

This method is called when an object faults, or has its values refreshed by the managed object context.

It returns an `NSIncrementalStoreNode`, which is a container for the ID and current values for a particular managed object. The node should include all of the attributes, as well as the managed object IDs of any to-one relationships. There is also a `version` property of the node that can be used to determine the current state of an object, but this may not be applicable to all storage implementations.

If an object with the specified `objectID` cannot be found, this method should return `nil`.

### `-newValueForRelationship:forObjectWithID: withContext:error:`

This one is called when a relationship needs to be refreshed, either from a fault or by the managed object context.

Unlike the previous method, the return value will be just the current value for a single relationship. The expected return type depends on the nature of the relationship:

- **to-one**: `NSManagedObjectID`
- **to-many**: `NSSet` or `NSOrderedSet`
- **non-existent**: `nil`

### `-obtainPermanentIDsForObjects:error:`

Finally, this method is called before `executeRequest:withContext:error:` with a save request, where permanent IDs should be assigned to newly-inserted objects. As you might expect, the array of permanent IDs should match up with the array of objects passed into this method.

This usually corresponds with a write to the persistence layer, such as an `INSERT` statement in SQL. If, for example, the row corresponding to the object had an auto-incrementing `id` column, you could generate an objectID with:

~~~{swift}
self.newObjectIDForEntity(entity, referenceObject: rowID)
~~~

~~~{objective-c}
[self newObjectIDForEntity:entity referenceObject:[NSNumber numberWithUnsignedInteger:rowID]];
~~~

## Roll Your Own Core Data Backend

Going through all of the necessary methods to override in an `NSIncrementalStore` subclass, you may have found your mind racing with ideas about how you might implement a SQL or NoSQL store, or maybe something new altogether.

What makes `NSIncrementalStore` so exciting is that you _can_ build a store on your favorite technology, and drop that into any existing Core Data stack with little to no additional configuration.

So imagine if, instead SQL or NoSQL, we wrote a Core Data store that connected to a webservice. Allow me to introduce [AFIncrementalStore](https://github.com/AFNetworking/AFIncrementalStore).

## AFIncrementalStore

[`AFIncrementalStore`](https://github.com/AFNetworking/AFIncrementalStore) is an NSIncrementalStore subclass that uses [AFNetworking](https://github.com/afnetworking/afnetworking) to automatically request resources as properties and relationships are needed.

What this means is that you can now write apps that communicate with a webservice _without exposing any of the details about the underlying API_. Any time a fetch request is made or an attribute or relationship faults, an asynchronous network request will fetch that information from the webservice.

Since the store abstracts all of the implementation details of the API away, you can write expressive fetch requests and object relationships from the start. No matter how bad or incomplete an API may be, you can change all of that mapping independently of the business logic of the client.

* * *

Even though `NSIncrementalStore` has been around since iOS 5, we're still a long way from even beginning to realize its full potential. The future is insanely bright, so you best don your aviators, grab an iced latte and start coding something amazing.
