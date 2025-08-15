---
title: "@isolated(any)"
author: Matt Massicotte
category: Swift
excerpt: >-
  There are cases where just a little more visibility and control over how to
  schedule asynchronous work can make all the difference.
status:
  swift: 6.0
---

Ahh, `@isolated(any)`.
It's an attribute of contradictions.
You might see it a lot, but it's ok to ignore it.
You don't need to use it, but I think it should be used more.
It must always take an argument, but that argument cannot vary.

Confusing? Definitely.
But we'll get to it all.

---

To understand why `@isolated(any)` was introduced,
we need to take a look at async functions.

```swift
let respondToEmergency: () async -> Void
```

This is about as simple a function type as we can get.
But, things start to get a little more interesting
when we look at how a function like this is used.
A variable with this type must always be invoked with `await`.

```swift
await respondToEmergency()
```

This, of course, makes sense.
All async functions must be called with `await`.
But! Consider this:

```swift
let sendAmbulance: @MainActor () -> Void = {
    print("🚑 WEE-OOO WEE-OOO!")
}

let respondToEmergency: () async -> Void = sendAmbulance

await respondToEmergency()
```

The explicit types are there to help make what's going on clear.
We first define a **synchronous** function that _**must**_ run on the `MainActor`.
And then we assign that to a plain old,
non-`MainActor` async function.
We've changed so much that you might find it surprising this even compiles.

Remember what `await` actually does. It allows the current task to suspend. That doesn't just let the task wait for future work to complete. It also is an opportunity to change isolation. This makes async functions very flexible!

Just like a dispatcher doesn't sit there doing nothing while waiting for the ambulance to arrive, a suspended task doesn't block its thread. When the dispatcher puts you on hold to coordinate with the ambulance team, that's the isolation switch - they're transferring your request to a different department that specializes in that type of work.

## But change to where, exactly?

Ok, so we know that async functions, because they must always be `await`ed, gain a lot of flexibility. We are close, but have to go just a little further to find the motivation for this attribute.

```swift
func dispatchResponder(_ responder: () async -> Void) async {
    await responder()
}

await dispatchResponder {
    // no explicit isolation => nonisolated
    print("🚒 HONK HOOOOONK!")
    await airSupport()
    print("🚁 SOI SOI SOI SOI SOI!")
}

await dispatchResponder { @MainActor in
    print("🚑 WEE-OOO WEE-OOO!")
}
```

We now have a function that accepts **other** functions as arguments. It's possible to pass in lots of different kinds of functions to `dispatchResponder`. They could be async functions themselves, or even be synchronous. And they can be isolated to any actor. All thanks to the power of `await`.

Except there's a little problem now.
Have a look at `dispatchResponder` on its own:

```swift
func dispatchResponder(_ responder: () async -> Void) async {
    await responder()
}
```

The type of `responder` fully describes everything about this function,
**except** for one thing.
We have no way to know its isolation.
That information is only available at callsites.
The isolation is still present,
so the right thing happens at runtime.
It's just not possible to inspect it statically or even programmatically.
If you've encountered type erasure before,
this should seem familiar.
The flexibility of `async` has come with a price -
a loss of information.

This is where `@isolated(any)` comes in.

## Using `@isolated(any)`

We can change the definition of `dispatchResponder` to fix this.

```swift
func dispatchResponder(_ responder: @isolated(any) () async -> Void) async {
    print("responder isolation:", responder.isolation)

    await responder()
}
```

When you apply `@isolated(any)` to a function type, it does two things. Most importantly, it gives you access to a special `isolation` property. You can use this property to inspect the isolation of the function. The isolation could be an actor. Or it could be non-isolated. This is expressible in the type system with `(any Actor)?`.

Functions with properties felt really strange to me at first.
But, after thinking for a minute,
it became quite natural.
Why not?
It's just a type like any other.
In fact, we can simulate how this all works with another feature:
[`callAsFunction`](/callable).

```swift
struct IsolatedAnyFunction<T> {
    let isolation: (any Actor)?
    let body: () async -> T

    func callAsFunction() async -> T {
        await body()
    }
}

let value = IsolatedAnyFunction(isolation: MainActor.shared, body: {
    // isolated work goes here
})

await value()
```

This analogy is certainly not **perfect**,
but it's close enough that it might help.

There is one other subtle change that `@isolated(any)` makes to a function
that you should be aware of.
Its whole purpose is to capture the isolation of a function.
Since that could be anything,
callsites need an opportunity to switch.
And that means an `@isolated(any)` function must be called with an `await` —
even if it isn't itself explicitly async.

```swift
func dispatchResponder(_ responder: @isolated(any) () -> Void) async {
    await responder() // note the function is synchronous
}
```

This makes synchronous functions marked with `@isolated(any)` a little strange.
They still must be called with `await`,
yet they aren't allowed to suspend internally?

As it turns out, there are some valid (if rare) situations
where such an arrangement can make sense.
But adding this kind of constraint to your API
should at least merit some extra documentation.

## How @isolated(any) Affects Callers

All of the task creation APIs —
`Task` initializers and `TaskGroup` —
make use of `@isolated(any)`.
These are used a lot
and are usually encountered very early on when learning about concurrency.
So, it's completely natural to run into this attribute and think:

_"Ugh another thing to understand!"_

It's reasonable because
the components of a function type dictate how it can be used.
They are all essential qualities for API consumers.
They _**are**_ the interface.

- Parameters
- Return value
- Does it throw?
- Is it async?

This is not an exhaustive list,
but what's important is all of these are things callers must care about.
Except for `@isolated(any)`, which is the **opposite**.
It doesn't affect callers at all.

This, I think, is the root of a lot of confusion around `@isolated(any)`.
Unlike other qualities of a function,
this attribute is used to capture information for the API producer.

I'm so close to saying _"you can and should just ignore `@isolated(any)`"_.
But I just cannot quite go that far,
because there is one situation you should be aware of.

## Scheduling

To help understand when you should be thinking about using `@isolated(any)`,
I'm going to quote
[the proposal](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0431-isolated-any-functions.md):

> This allows the API to make more **intelligent scheduling** decisions about the function.

I've highlighted "intelligent scheduling",
because this is the key component of `@isolated(any)`.
The attribute gives you access to the isolation of a function argument.
But what would you use that for?

Did you know that, before Swift 6.0, the ordering of the following code was undefined?

```swift
@MainActor
func threeAlarmFire() {
    Task { print("🚒 Truck A reporting!") }
    Task { print("🚒 Truck B checking in!") }
    Task { print("🚒 Truck C on the case!") }
}
```

Ordering turns out to be a very tricky topic when working with unstructured tasks.
And while it will always require care, Swift 6.0 did improve the situation.
We now have some stronger guarantees about scheduling work on the `MainActor`,
and `@isolated(any)` was needed to make that possible.

{% warning %}

Anytime you use `Task`,
think about _when_ that work will start and _how_ that could matter.

{% endwarning %}

Take a look at this:

```swift
@MainActor
func sendAmbulance() {
    print("🚑 WEE-OOO WEE-OOO!")
}

nonisolated func dispatchResponders() {
    // synchronously enqueued
    Task { @MainActor in
        sendAmbulance()
    }

    // synchronously enqueued
    Task(operation: sendAmbulance)

    // not synchronously enqueued!
    Task {
        await sendAmbulance()
    }
}
```

These are three ways to achieve the same goal.
But, there is a subtle difference in how the last form is scheduled.
`Task` takes an `@isolated(any)` function
so it can look at its isolation
and **synchronously submit it to an actor**.
This is how ordering can be preserved!
But, it cannot do that in the last case.
That closure passed into `Task` isn't actually itself `MainActor` —
it has inherited nonisolated from the enclosing function.

I think it might help to translate this into
<abbr title="Grand Central Dispatch">GCD</abbr>.

```swift
func dispatchResponders() {
    // synchronously enqueued
    DispatchQueue.main.async {
        sendAmbulance()
    }

    // synchronously enqueued
    DispatchQueue.main.async(execute: sendAmbulance)

    // not synchronously enqueued!
    DispatchQueue.global().async {
        DispatchQueue.main.async {
            sendAmbulance()
        }
    }
}
```

Look really closely at that last one!
What we are doing there is introducing a new async closure
that then calls our `MainActor` function.
There are **two** steps.
This doesn't always matter,
but it certainly could.
And if you need to precisely schedule asynchronous work,
`@isolated(any)` can help.

## isolated(all)

All this talk about `@isolated(any)` got me thinking...

It's kinda strange that only _some_ functions get to have this `isolation` property.
It would certainly feel more consistent to me if _all_ functions had it.
In fact, I think we can go further.
I can imagine a future where an explicit `@isolated(any)`
isn't even necessary for async functions.
As far as I can tell, there is no downside.

And a little less syntactic noise would be nice.
Perhaps one day!

## isolated(some)

We do have to talk about that `any`.
It's surprising that this attribute requires an argument,
yet permits only one possible value.
The reason here comes down to future considerations.

The **concrete** actor type that this `isolation` property returns
is always `(any Actor)?`.
This is the most generic type for isolation and matches the `#isolation` macro.
Today, there is no way to constrain a function to only **specific** actor types,
such as `@isolated(MyActor)`.
The `any` keyword here was chosen to mirror how protocols handle this.
But accepting an argument leaves the door open
to more sophisticated features in the future.

And that really fits the spirit of `@isolated(any)`.
Doing a little work now in exchange for flexibility down the road.

Because you'll see it in many foundational concurrency APIs,
it's very natural to feel like you must understand `@isolated(any)`.
I'm 100% behind technical curiosity!
In this case, however, it is not required.
For the most part, you can just ignore this attribute.
You will rarely, if ever, need to use it yourself.

But if you ever find yourself capturing isolated functions
and passing them along to **other** APIs that use `@isolated(any)`,
you should consider adopting it.
It could prove useful.
It's even a source-compatible change
to add or remove this attribute from an async function.

---

So there you have it.

As with many parts of the concurrency system,
there's a surprising depth to `@isolated(any)`.
Thankfully, from a practical perspective,
we can enjoy the ordering guarantees of task creation
that it enables without needing to master it.
And one less thing on this journey is most welcome.

Isolated maybe, but never alone.
