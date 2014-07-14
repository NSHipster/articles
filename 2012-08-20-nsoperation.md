---
layout: post
title: NSOperation
ref: "https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html"
category: Cocoa
rating: 9.0
excerpt: "Everyone knows that the secret to making an app snappy and responsive is to offload computation asynchronously to the background."
---

Everyone knows that the secret to making an app snappy and responsive is to offload computation to be done asynchronously in the background.

The modern Objective-C developer has two options in this respect: [Grand Central Dispatch](http://en.wikipedia.org/wiki/Grand_Central_Dispatch) or [`NSOperation`](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html). Since GCD has gone pretty mainstream, let's focus on the latter, object-oriented approach.

`NSOperation` represents a single unit of computation. It's an abstract class that gives subclasses a useful, thread-safe way to model aspects like state, priority, dependencies, and cancellation. Or, if subclassing isn't your cup of tea, there's always `NSBlockOperation`, a concrete subclass that wraps block in operations.

Examples of tasks that lend themselves well to `NSOperation` include [network requests](https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking/AFURLConnectionOperation.h), image resizing, linguistic processing, or any other repeatable, structured, long-running task that returns processed data.

But simply wrapping computation into an object doesn't do much without a little oversight. That's where `NSOperationQueue` comes in.

`NSOperationQueue` regulates the concurrent execution of operations. It acts as a priority queue, such that operations are executed in a roughly First-In-First-Out manner, with higher-priority (`NSOperation -queuePriority`) ones getting to jump ahead of lower-priority ones. `NSOperationQueue` also executes operations concurrently, with the option to limit the maximum number to be executed simultaneously (`maxConcurrentOperationCount`).

To kick off an `NSOperation`, you can either call `-start`, or add it to an `NSOperationQueue`, which will automatically start the operation when it reaches the front of the queue.

Let's go through the different parts of `NSOperation`, describing how they're used and how to implement them in subclasses:

## State

`NSOperation` encodes a rather elegant state machine to describe the execution of an operation:

> `isReady` → `isExecuting` → `isFinished`

In lieu of an explicit `state` property, state is determined implicitly by KVO notifications on those keypaths. That is, when an operation is ready to be executed, it sends a KVO notification for the `isReady` keypath, whose corresponding property would then return `YES`.

Each property must be mutually exclusive from one-another in order to encode a consistent state:

- `isReady`: Returns `YES` to indicate that the operation is ready to execute, or `NO` if there are still unfinished initialization steps on which it is dependent.
- `isExecuting`: Returns `YES` if the operation is currently working on its task, or `NO` otherwise.
- `isFinished` Returns `YES` if the operation's task finished execution successfully, or if the operation was cancelled. An `NSOperationQueue` does not dequeue an operation until `isFinished` changes to `YES`, so it is critical to implement this correctly so as to avoid deadlock.

## Cancellation

It may be useful to cancel operations early to prevent needless work from being performed. Reasons for cancellation may include explicit user action, or a failure in a dependent operation.

Similar to execution state, `NSOperation` communicates changes in cancellation state through KVO on the `isCancelled` keypath. When an operation responds to the `-cancel` command, it should clean up any internal details and arrive in an appropriate final state as quickly as possible. Specifically, the values for both `isCancelled` and `isFinished` need to become `YES`, and the value of `isExecuting` to `NO`.

One thing to definitely watch out for are the spelling peculiarities around the word "cancel". Although spelling varies across dialects, when it comes to `NSOperation`:

- `cancel`: use one L for the method (verb)
- `isCancelled`: use two L's for the property (adjective)

## Priority

All operations may not be equally important. Setting the `queuePriority` property will promote or defer an operation in an `NSOperationQueue` according to the following ranking:

- `NSOperationQueuePriorityVeryHigh`
- `NSOperationQueuePriorityHigh`
- `NSOperationQueuePriorityNormal`
- `NSOperationQueuePriorityLow`
- `NSOperationQueuePriorityVeryLow`

Additionally, operations may specify a `threadPriority` value, which is a value between `0.0` and `1.0`, with `1.0` representing the highest priority. Whereas `queuePriority` determine the order in which operations are started, `threadPriority` specifies the allocation of computation once an operation has been started. But as with most threading details, if you don't know what it does, you probably didn't need to know about it anyway.

## Dependencies

Depending on the complexity of your application, it may make sense to divide up large tasks into a series of composable sub-tasks. You can do that using `NSOperation` dependencies.

For example, to describe the process of downloading and resizing an image from a server, you would probably want to divide up the networking into one operation, and resizing into another (perhaps to reuse the networking operation to download other resources, or reuse the resizing operation for images already on-disk). However, an image can't be resized until its  downloaded. Therefore, we say that the networking operation is a _dependency_ of the resizing operation, and must be finished before the resizing operation can be started. Expressed in code:

~~~{objective-c}
[resizingOperation addDependency:networkingOperation];
[operationQueue addOperation:networkingOperation];
[operationQueue addOperation:resizingOperation];
~~~

An operation will not be started until all of its dependencies return `YES` to `isFinished`. It's important to remember to add all of the operations involved in a dependency graph to the operation queue, lest there be a gap somewhere along the way.

Also, make sure not to accidentally create a dependency cycle, such that A depends on B, and B depends on A, for example. This will create deadlock and sadness.

## `completionBlock`

One useful feature that was added in the blocks renaissance of iOS 4 and Snow Leopard was the `completionBlock` property.

When an `NSOperation` finishes, it will execute its `completionBlock` exactly once. This provides a really nice way to customize the behavior of an operation when used in a model, or view controller. For example, you could set a completion block on a network operation block to do something with the response data from the server once its finished loading.

---

`NSOperation` remains an essential tool in the modern Objective-C programmers bag of tricks. Whereas GCD is ideal for in-line asynchronous processing, `NSOperation` provides a more comprehensive, object-oriented model of computation, which is ideal for encapsulating all of the data around structured, repeatable tasks in an application. Add it to your next project and bring delight not only to your user, but yourself as well!
