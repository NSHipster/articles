---
title: NSOperation
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "In life, there's always work to be done. Every day brings with it a steady stream of tasks and chores to fill the working hours of our existence. Productivity is, as in life as it is in programming, a matter of scheduling and prioritizing and multi-tasking work in order to keep up appearances."
status:
    swift: 2.0
    reviewed: September 15, 2015
---

In life, there's always work to be done. Every day brings with it a steady stream of tasks and chores to fill the working hours of our existence.

Yet, no matter how burdened one's personal ToDo list becomes, it pales in comparison to the workload of an iOS app, of which millions of computations are expected, all while managing to draw a frame every 16 milliseconds.

Productivity is, as in life as it is in programming, a matter of scheduling and prioritizing and multi-tasking work in order to keep up appearances.

The secret to making apps snappy is to offload as much unnecessary work to the background as possible, and in this respect, the modern Cocoa developer has two options: [Grand Central Dispatch](http://en.wikipedia.org/wiki/Grand_Central_Dispatch) and [`NSOperation`](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html). This article will primarily focus on the latter, though it's important to note that the two are quite complementary (more on that later).

* * *

`NSOperation` represents a single unit of work. It's an abstract class that offers  a useful, thread-safe structure for modeling state, priority, dependencies, and management.

> For situations where it doesn't make sense to build out a custom `NSOperation` subclass, Foundation provides the concrete implementations [`NSBlockOperation`](https://developer.apple.com/library/ios/documentation/cocoa/reference/NSBlockOperation_class/Reference/Reference.html) and [`NSInvocationOperation`](https://developer.apple.com/library/mac/documentation/cocoa/reference/NSInvocationOperation_Class/Reference/Reference.html).

Examples of tasks that lend themselves well to `NSOperation` include [network requests](https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFURLConnectionOperation.h), image resizing, text processing, or any other repeatable, structured, long-running task that produces associated state or data.

But simply wrapping computation into an object doesn't do much without a little oversight. That's where `NSOperationQueue` comes in:

## NSOperationQueue

`NSOperationQueue` regulates the concurrent execution of operations. It acts as a priority queue, such that operations are executed in a roughly [First-In-First-Out](http://en.wikipedia.org/wiki/FIFO) manner, with higher-priority (`NSOperation.queuePriority`) ones getting to jump ahead of lower-priority ones. `NSOperationQueue` can also limit the maximum number of concurrent operations to be executed at any given moment, using the `maxConcurrentOperationCount` property.

> NSOperationQueue itself is backed by a Grand Central Dispatch queue, though that's a private implementation detail.

To kick off an `NSOperation`, either call `start`, or add it to an `NSOperationQueue`, to have it start once it reaches the front of the queue. **Since so much of the benefit of `NSOperation` is derived from `NSOperationQueue`, it's almost always preferable to add an operation to a queue rather than invoke `start` directly.**

## State

`NSOperation` encodes a rather elegant state machine to describe the execution of an operation:

> `ready` → `executing` → `finished`

In lieu of an explicit `state` property, state is determined implicitly by KVO notifications on those keypaths. When an operation is ready to be executed, it sends a KVO notification for the `ready` keypath, whose corresponding property would then return `true`.

Each property must be mutually exclusive from one another in order to encode a consistent state:

- `ready`: Returns `true` to indicate that the operation is ready to execute, or `false` if there are still unfinished initialization steps on which it is dependent.
- `executing`: Returns `true` if the operation is currently working on its task, or `false` otherwise.
- `finished` Returns `true` if the operation's task finished execution successfully, or if the operation was cancelled. An `NSOperationQueue` does not dequeue an operation until `finished` changes to `true`, so it is _critical_ to implement this correctly in subclasses to avoid deadlock.

## Cancellation

It is often useful to cancel operations early to prevent needless work from being performed, whether due to a failure in a dependent operation or explicit cancellation by the user.

Similar to execution state, `NSOperation` communicates cancellation through KVO on the `cancelled` keypath. When an operation is cancelled, it should clean up any internal details and arrive in an appropriate final state as quickly as possible. Specifically, the values for both `cancelled` and `finished` need to become `true`, and `executing` needs to become `false`.

One thing to watch out for are the spelling peculiarities of the word "cancel". Although spelling varies across dialects, when it comes to `NSOperation`:

- `cancel`: use one L for the function _(verb)_
- `cancelled`: use two L's for the property _(adjective)_

## Priority

All operations may not be equally important. Setting the `queuePriority` property will promote or defer an operation in an `NSOperationQueue` according to the following rankings:

### NSOperationQueuePriority

~~~{swift}
public enum NSOperationQueuePriority : Int {
    case VeryLow
    case Low
    case Normal
    case High
    case VeryHigh
}
~~~
~~~{objective-c}
typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
    NSOperationQueuePriorityVeryLow = -8L,
    NSOperationQueuePriorityLow = -4L,
    NSOperationQueuePriorityNormal = 0,
    NSOperationQueuePriorityHigh = 4,
    NSOperationQueuePriorityVeryHigh = 8
};
~~~

## Quality of Service

Quality of Service is a new concept in iOS 8 & OS X Yosemite that creates consistent, high-level semantics for scheduling system resources. APIs were introduced for both [XPC](https://developer.apple.com/library/mac/documentation/macosx/conceptual/bpsystemstartup/chapters/CreatingXPCServices.html) and `NSOperation` that use this abstraction.

For `NSOperation`, the `threadPriority` property has been deprecated in favor of this new `qualityOfService` property. (And good riddance—`threadPriority` was too unwieldy to be anything but a liability to most developers.)

Service levels establish the system-wide priority of an operation in terms of how much CPU, network, and disk resources are allocated. A higher quality of service means that more resources will be provided to perform an operation's work more quickly.

> QoS appears to use the [XNU kernel task policy feature introduced in OS X Mavericks](http://www.opensource.apple.com/source/xnu/xnu-1456.1.26/osfmk/mach/task_policy.h) under the hood.

The following enumerated values are used to denote the nature and urgency of an operation. Applications are encouraged to select the most appropriate value for operations in order to ensure a great user experience:

### NSQualityOfService

~~~{swift}
@available(iOS 8.0, OSX 10.10, *)
public enum NSQualityOfService : Int {    
    case UserInteractive
    case UserInitiated
    case Utility
    case Background
    case Default
}
~~~
~~~{objective-c}
typedef NS_ENUM(NSInteger, NSQualityOfService) {
    NSQualityOfServiceUserInteractive = 0x21,    
    NSQualityOfServiceUserInitiated = 0x19,    
    NSQualityOfServiceUtility = 0x11,    
    NSQualityOfServiceBackground = 0x09,
    NSQualityOfServiceDefault = -1
} NS_ENUM_AVAILABLE(10_10, 8_0);
~~~

- `.UserInteractive`:UserInteractive QoS is used for work directly involved in providing an interactive UI such as processing events or drawing to the screen.
- `.UserInitiated`: UserInitiated QoS is used for performing work that has been explicitly requested by the user and for which results must be immediately presented in order to allow for further user interaction.  For example, loading an email after a user has selected it in a message list.
- `.Utility`: Utility QoS is used for performing work which the user is unlikely to be immediately waiting for the results.  This work may have been requested by the user or initiated automatically, does not prevent the user from further interaction, often operates at user-visible timescales and may have its progress indicated to the user by a non-modal progress indicator.  This work will run in an energy-efficient manner, in deference to higher QoS work when resources are constrained.  For example, periodic content updates or bulk file operations such as media import.
- `.Background`: Background QoS is used for work that is not user initiated or visible.  In general, a user is unaware that this work is even happening and it will run in the most efficient manner while giving the most deference to higher QoS work.  For example, pre-fetching content, search indexing, backups, and syncing of data with external systems.
- `.Default`: Default QoS indicates the absence of QoS information.  Whenever possible QoS information will be inferred from other sources.  If such inference is not possible, a QoS between UserInitiated and Utility will be used.

~~~{swift}
let backgroundOperation = NSOperation()
backgroundOperation.queuePriority = .Low
backgroundOperation.qualityOfService = .Background

let operationQueue = NSOperationQueue.mainQueue()
operationQueue.addOperation(backgroundOperation)
~~~
~~~{objective-c}
NSOperation *backgroundOperation = [[NSOperation alloc] init];
backgroundOperation.queuePriority = NSOperationQueuePriorityLow;
backgroundOperation.qualityOfService = NSOperationQualityOfServiceBackground;

[[NSOperationQueue mainQueue] addOperation:backgroundOperation];
~~~

## Asynchronous Operations

Another change in iOS 8 / OS X Yosemite is the deprecation of the `concurrent` property in favor of the new `asynchronous` property.

Originally, the `concurrent` property was used to distinguish between operations that performed all of their work in a single `main` method, and those that managed their own state while executing asynchronously. This property was also used to determine whether `NSOperationQueue` would execute a method in a separate thread. After `NSOperationQueue` was changed to run on an internal dispatch queue rather than manage threads directly, this aspect of the property was ignored. The new `asynchronous` property clears away the semantic cobwebs of `concurrent`, and is now the sole determination of whether an `NSOperation` should execute synchronously in `main`, or asynchronously.

## Dependencies

Depending on the complexity of an application, it may make sense to divide up large tasks into a series of composable sub-tasks. This can be done with `NSOperation` dependencies.

For example, to describe the process of downloading and resizing an image from a server, one might divide up networking into one operation, and resizing into another (perhaps to reuse the networking operation to download other resources, or also use the resizing operation for images already cached in memory). However, since an image can't be resized until it's downloaded, then the networking operation is a _dependency_ of the resizing operation, and must be finished before the resizing operation can be started.

Expressed in code:

~~~{swift}
let networkingOperation: NSOperation = ...
let resizingOperation: NSOperation = ...
resizingOperation.addDependency(networkingOperation)

let operationQueue = NSOperationQueue.mainQueue()
operationQueue.addOperations([networkingOperation, resizingOperation], waitUntilFinished: false)
~~~

~~~{objective-c}
NSOperation *networkingOperation = ...
NSOperation *resizingOperation = ...
[resizingOperation addDependency:networkingOperation];

NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
[operationQueue addOperation:networkingOperation];
[operationQueue addOperation:resizingOperation];
~~~

An operation will not be started until all of its dependencies return `true` for `finished`.

Make sure not to accidentally create a dependency cycle, such that A depends on B, and B depends on A, for example. This will create deadlock and sadness.

## `completionBlock`

When an `NSOperation` finishes, it will execute its `completionBlock` exactly once. This provides a really nice way to customize the behavior of an operation when used in a model or view controller.

~~~{swift}
let operation = NSOperation()
operation.completionBlock = {
    print("Completed")
}

NSOperationQueue.mainQueue().addOperation(operation)
~~~

~~~{objective-c}
NSOperation *operation = ...;
operation.completionBlock = ^{
    NSLog("Completed");
};

[[NSOperationQueue mainQueue] addOperation:operation];
~~~

For example, you could set a completion block on a network operation to do something with the response data from the server once it's finished loading.

* * *

`NSOperation` remains an essential tool in an iOS or OS X developer's bag of tricks. Whereas GCD is ideal for in-line asynchronous processing, `NSOperation` provides a more comprehensive, object-oriented model of computation for encapsulating all of the data around structured, repeatable tasks in an application.

Developers should use the highest level of abstraction possible for any given problem, and for scheduling consistent, repeated work, that abstraction is `NSOperation`. Other times, it makes more sense to sprinkle in some GCD (including within an `NSOperation` subclass implementation).

## When to Use Grand Central Dispatch

Dispatch queues, groups, semaphores, sources, and barriers comprise an essential set of concurrency primitives, on top of which all of the system frameworks are built.

For one-off computation, or simply speeding up an existing method, it will often be more convenient to use a lightweight GCD `dispatch` than employ `NSOperation`.

## When to Use NSOperation

`NSOperation` can be scheduled with a set of dependencies at a particular queue priority and quality of service. Unlike a block scheduled on a GCD queue, an `NSOperation` can be cancelled and have its operational state queried. And by subclassing, `NSOperation` can associate the result of its work on itself for future reference.

---

Just remember: **NSOperation and Grand Central Dispatch are not mutually exclusive**. Creative and effective use of both are key to developing robust and performant iOS or OS X applications.
