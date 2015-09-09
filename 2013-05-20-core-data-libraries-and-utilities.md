---
title: "Core Data Libraries & Utilities"
author: Mattt Thompson
category: Open Source
excerpt: "We were a bit hard on Core Data last week, so for this issue of NSHipster, we bring you a guided tour of the best open source libraries for working with Core Data. Read on to see how you might make the most from your Core Data experience."
status:
    swift: n/a
    reviewed: August 12, 2015
---

So let's say that, having determined your particular needs and compared all of the alternatives, you've chosen [Core Data](http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/CoreData/cdProgrammingGuide.html) for your next app.

Nothing wrong with that! Core Data is a great choice for apps that model, persist, and query large object graphs.

Sure it's complicated, cumbersome, and yes, at times, a real [pain in the ass](http://nshipster.com/nscoding#figure-2)—but gosh darn it, some of the best and most popular apps ever built use Core Data. And if it's good enough for them, it's probably good enough for you, too.

...but that's not to say that Core Data can't be improved.

And while there have been many libraries attempting to replace Core Data, there are many more that attempt to make it better. These libraries range from the much-needed dose of syntactic sugar to comprehensive, full-stack frameworks.

This week on NSHipster: a guided tour of the best open source libraries for working with Core Data. Read on to see how you might make the most from your Core Data experience.

---

> For your convenience, the following table is provided. Contained within are the most significant open source libraries and utilities for working with Core Data. This list is by no means comprehensive, so if you think something is missing or out of place, please tweet [@NSHipster](https://twitter.com/NSHipster)—or better yet, [submit a pull request](https://github.com/NSHipster/articles).

<table>
  <thead>
    <tr>
      <th colspan="3">Wrappers</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/magicalpanda/MagicalRecord">Magical Record</a></td>
      <td><a href="https://github.com/casademora">Saul Mora</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=magicalpanda&repo=MagicalRecord&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/supermarin/ObjectiveRecord">Objective-Record</a></td>
      <td><a href="https://github.com/supermarin">Marin Usalj</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=supermarin&repo=ObjectiveRecord&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/soffes/SSDataKit">SSDataKit</a></td>
      <td><a href="https://github.com/soffes">Sam Soffes</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=soffes&repo=SSDataKit&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/martydill/ios-queryable">ios-queryable</a></td>
      <td><a href="https://github.com/martydill">Marty Dill</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=martydill&repo=ios-queryable&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/apparentsoft/ReactiveCoreData">ReactiveCoreData</a></td>
      <td><a href="https://github.com/apparentsoft">Jacob Gorban</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=apparentsoft&repo=ReactiveCoreData&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>

  <thead>
    <tr>
      <th colspan="3">Adapters</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/RestKit/RestKit">RestKit</a></td>
      <td><a href="https://github.com/blakewatters">Blake Watters</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=RestKit&repo=RestKit&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/AFNetworking/AFIncrementalStore">AFIncrementalStore</a></td>
      <td><a href="https://github.com/mattt">Mattt Thompson</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=AFNetworking&repo=AFIncrementalStore&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/mutualmobile/MMRecord">MMRecord</a></td>
      <td><a href="https://github.com/cnstoll">Conrad Stoll</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=mutualmobile&repo=MMRecord&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/OliverLetterer/SLRESTfulCoreData">SLRESTfulCoreData</a></td>
      <td><a href="https://github.com/OliverLetterer">Oliver Letterer</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=OliverLetterer&repo=SLRESTfulCoreData&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/gonzalezreal/Overcoat">Overcoat</a></td>
      <td><a href="https://github.com/gonzalezreal">Guillermo Gonzalez</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=gonzalezreal&repo=Overcoat&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/Mantle/Mantle">Mantle</a></td>
      <td><a href="https://github.com/Mantle">Mantle</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=Mantle&repo=Mantle&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>

  <thead>
    <tr>
      <th colspan="3">Synchronizers</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/nothirst/TICoreDataSync">TICoreDataSync</a></td>
      <td><a href="https://github.com/timisted">Tim Isted</a>, <a href="https://github.com/MrRooni">Michael Fey</a>, <a href="https://github.com/kevinhoctor">Kevin Hoctor</a>, <a href="https://github.com/chbeer">Christian Beer</a>, <a href="https://github.com/tonyarnold">Tony Arnold</a>, and <a href="https://github.com/dannygreg">Danny Greg</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=nothirst&repo=TICoreDataSync&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/lhunath/UbiquityStoreManager">UbiquityStoreManager</a></td>
      <td><a href="https://github.com/lhunath">Maarten Billemont</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=lhunath&repo=UbiquityStoreManager&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>


  <thead>
    <tr>
      <th colspan="3">Utilities</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/rentzsch/mogenerator">mogenerator</a></td>
      <td><a href="https://github.com/rentzsch">Jonathan 'Wolf' Rentzsch</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=rentzsch&repo=mogenerator&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>
</table>

## Wrappers

Wrapper libraries provide some much needed syntactic sugar and convenience methods to Core Data's verbose and complicated APIs.

For example, to insert a new managed object into a managed object context, it's a class method on, not `NSManagedObject` or `NSManagedObjectContext` as one might reasonably expect, but `NSEntityDescription`. `NSEntityDescription +insertNewObjectForEntityForName:inManagedObjectContext:`. What?

There are a number of open source libraries that collectively identify and correct for the roughest patches of the Core Data APIs. Managing a main and private context outside of `AppDelegate`, convenience method for manipulating and querying managed objects, and so on.

#### [SSDataKit](https://github.com/soffes/SSDataKit)

> There is a lot of boilerplate code required to write a Core Data application. This is annoying. In pretty much everything I've written since Core Data came to iOS, I have used the following class.

### Inspired by [Active Record](http://api.rubyonrails.org/classes/ActiveRecord/Base.html)

It should be no surprise that programmers, having learned how to do things a certain way, will bring those ideas and conventions to other technologies. For the large influx of Ruby developers coming over to iOS, that familiar paradigm was [Active Record](http://api.rubyonrails.org/classes/ActiveRecord/Base.html).

Contrary to popular belief, Core Data is _not_ an [Object-Relational Mapper](http://en.wikipedia.org/wiki/Object-relational_mapping), but rather an object graph and persistence framework, capable of much more than the [Active Record pattern](http://en.wikipedia.org/wiki/Active_record_pattern) alone is capable of. Using Core Data as an ORM necessarily limits the capabilities of Core Data and muddies its conceptual purity. But for many developers longing for the familiarity of an ORM, this trade-off is a deal at twice the price!

#### [Magical Record](https://github.com/magicalpanda/MagicalRecord)

> MagicalRecord was inspired by the ease of Ruby on Rails' Active Record fetching. The goals of this code are to clean up Core Data related code, allow for clear, simple, one-line fetches, and still allow the modification of the `NSFetchRequest` when request optimizations are needed.

#### [ObjectiveRecord](https://github.com/supermarin/ObjectiveRecord)

> This is a lightweight ActiveRecord way of managing Core Data objects.
> The syntax is borrowed from Ruby on Rails.
> And yeah, no AppDelegate code.
> It's fully tested with [Kiwi](https://github.com/kiwi-bdd/Kiwi).

### Inspired by [LINQ](http://en.wikipedia.org/wiki/Language_Integrated_Query)

Here's a fun game: the next time you meet a developer coming over from the .NET world, set a timer to see how long it takes them to start raving about [LINQ](http://en.wikipedia.org/wiki/Language_Integrated_Query). Seriously, people _love_ LINQ.

For the uninitiated, LINQ is like [SQL](http://en.wikipedia.org/wiki/SQL), but integrated as a language feature. Think `NSPredicate`, [`NSSortDescriptor`](http://nshipster.com/nssortdescriptor/), and [`Key-Value Coding`](http://nshipster.com/kvc-collection-operators/) with a much nicer syntax:

~~~
from c in SomeCollection
  where c.SomeProperty < 10
  select new {c.SomeProperty, c.OtherProperty};
~~~

#### [ios-queryable](https://github.com/martydill/ios-queryable)

> ios-queryable supports LINQ-style query composition and deferred execution, and implements a subset of IEnumerable's methods, including `where`, `take`, `skip`, `orderBy`, `first/firstOrDefault`, `single/singleOrDefault`, `count`, `any`, and `all`.

### Inspired by [ReactiveCocoa](https://github.com/ReactiveCocoa)

ReactiveCocoa, which itself [brings the functional reactive paradigm to Objective-C](http://nshipster.com/reactivecocoa/), is now being used to bring some functional sanity and order to Core Data. This is still uncharted territory, but the initial results are indeed promising.

#### [ReactiveCoreData](https://github.com/apparentsoft/ReactiveCoreData)

> ReactiveCoreData (RCD) is an attempt to bring Core Data into the ReactiveCocoa (RAC) world.

## Adapters

Most iOS apps communicate with a webservice in some capacity. For apps using Core Data, it's common for records to be fetched, updated, and deleted from a REST or RPC-style webservice. Maintaining consistency between a local cache and the server is a deceptively tricky enterprise.

Keeping objects up-to-date, removing duplicate records, mapping entities to API endpoints, reconciling conflicts, managing network reachability... these are just some of the challenges a developer faces when creating a robust client-server application.

Fortunately, there are a wealth of open-source libraries that can help alleviate some of this pain.

#### [RestKit](https://github.com/RestKit/RestKit)

> RestKit is a modern Objective-C framework for implementing RESTful web services clients on iOS and OS X. It provides a powerful [object mapping](https://github.com/RestKit/RestKit/wiki/Object-mapping) engine that seamlessly integrates with [Core Data](http://developer.apple.com/library/mac/#documentation/cocoa/Conceptual/CoreData/cdProgrammingGuide.html) and a simple set of networking primitives for mapping HTTP requests and responses built on top of [AFNetworking](https://github.com/AFNetworking/AFNetworking). It has an elegant, carefully designed set of APIs that make accessing and modeling RESTful resources feel almost magical.

#### [AFIncrementalStore](https://github.com/AFNetworking/AFIncrementalStore)

> AFIncrementalStore is an NSIncrementalStore subclass that uses AFNetworking to automatically request resources as properties and relationships are needed.

#### [MMRecord](https://github.com/mutualmobile/MMRecord)

> MMRecord is a block-based seamless web service integration library for iOS and OS X. It leverages the Core Data model configuration to automatically create and populate a complete object graph from an API response. It works with any networking library, is simple to setup, and includes many popular features that make working with web services even easier.

#### [SLRESTfulCoreData](https://github.com/OliverLetterer/SLRESTfulCoreData)

> `SLRESTfulCoreData` builds on top of [AFNetworking](https://github.com/AFNetworking/AFNetworking) and [SLCoreDataStack](https://github.com/OliverLetterer/SLCoreDataStack) and let's you map your JSON REST API to your CoreData model in minutes.

#### [Overcoat](https://github.com/gonzalezreal/Overcoat)

> Overcoat is an [AFNetworking](https://github.com/AFNetworking/AFNetworking) extension that makes it super simple for developers to use Mantle model objects with a REST client.

#### [Mantle](https://github.com/github/Mantle)

> Mantle makes it easy to write a simple model layer for your Cocoa or Cocoa Touch application.

## Synchronizers

Whereas adapters synchronize information through an existing, general purpose interface such as REST, synchronizers use a more direct protocol, offering better integration and performance at the expense of portability and generality.

### [TICoreDataSync](https://github.com/nothirst/TICoreDataSync)

> Automatic synchronization for Core Data Apps, between any combination of OS X and iOS: Mac to iPhone to iPad to iPod touch and back again

#### [UbiquityStoreManager](https://github.com/lhunath/UbiquityStoreManager)

> UbiquityStoreManager is a controller that implements iCloud integration with Core Data for you.

## Utilities

We would be remiss to survey the open source Core Data ecosystem without mentioning Mogenerator. Among one of the surviving projects from the pre-iPhone era, Mogenerator has become indispensable to developers over the years. Although much has changed about Core Data over the years, the one constant has been Apple's characteristic lack of comprehensive tooling. Fortunately, Mr. Wolf Rentzsch has us covered.

#### [Mogenerator](https://github.com/rentzsch/mogenerator)

> `mogenerator` is a command-line tool that, given an `.xcdatamodel` file, will generate *two classes per entity*. The first class, `_MyEntity`, is intended solely for machine consumption and will be continuously overwritten to stay in sync with your data model. The second class, `MyEntity`, subclasses `_MyEntity`, won't ever be overwritten and is a great place to put your custom logic.

---

Remember: there is no silver bullet. There is no one-size-fits-all solution. Just as Core Data may only be advisable in particular circumstances, so too are the aforementioned Core Data libraries.

Dividing the ecosystem up into broad categories is informative if only to help identify the relative strengths and trade-offs of each library. Only you can determine (yes, sometimes through trial and error) which solution is the best for you.

