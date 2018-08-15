---
title: guard & defer
author: Mattt & Nate Cook
authors:
    - Nate Cook
    - Mattt
category: Swift
excerpt: >
    Swift 2.0 introduced two new control statements
    that aimed to simplify and streamline the programs we write.
    While the former by its nature makes our code more linear,
    the latter does the opposite by delaying execution of its contents.
revisions:
    "2015-10-05": First Publication
    "2018-08-01": Updated for Swift 4.2
status:
    swift: 4.2
    reviewed: August 1, 2018
---

> "We should do (as wise programmers aware of our limitations)
> our utmost best to … make the correspondence between the program
> (spread out in text space) and the process
> (spread out in time) as trivial as possible."

> —[Edsger W. Dijkstra](https://en.wikipedia.org/wiki/Edsger_W._Dijkstra),
> ["Go To Considered Harmful"](https://homepages.cwi.nl/~storm/teaching/reader/Dijkstra68.pdf)

It's a shame that his essay
is most remembered for popularizing the "\_\_\_\_ Consider Harmful" meme
among programmers and their ill-considered online diatribes.
Because (as usual) Dijkstra was making an excellent point:
**the structure of code should reflect its behavior**.

Swift 2.0 introduced two new control statements
that aimed to simplify and streamline the programs we write:
`guard` and `defer`.
While the former by its nature makes our code more linear,
the latter does the opposite by delaying execution of its contents.

How should we approach these new control statements?
How can `guard` and `defer` help us clarify
the correspondence between the program and the process?

Let's defer `defer` and first take on `guard`.

---

## guard

`guard` is a conditional statement
requires an expression to evaluate to `true`
for execution to continue.
If the expression is `false`,
the mandatory `else` clause is executed instead.

```swift
func sayHello(numberOfTimes: Int) {
    guard numberOfTimes > 0 else {
        return
    }

    for _ in 1...numberOfTimes {
        print("Hello!")
    }
}
```

The `else` clause in a `guard` statement
must exit the current scope by using
`return` to leave a function,
`continue` or `break` to get out of a loop,
or a function that returns [`Never`](https://nshipster.com/never)
like `fatalError(_:file:line:)`.

`guard` statements are most useful when combined with optional bindings.
Any new optional bindings created in a `guard` statement's condition
are available for the rest of the function or block.

Compare how optional binding works with a `guard-let` statement
to an `if-let` statement:

```swift
var name: String?

if let name = name {
    // name is nonoptional inside (name is String)
}
// name is optional outside (name is String?)


guard let name = name else {
    return
}

// name is nonoptional from now on (name is String)
```

If the multiple optional bindings syntax introduced in
[Swift 1.2](/swift-1.2/)
heralded a renovation of the
[pyramid of doom](http://www.scottlogic.com/blog/2014/12/08/swift-optional-pyramids-of-doom.html),
`guard` statements tear it down altogether.

```swift
for imageName in imageNamesList {
    guard let image = UIImage(named: imageName)
        else { continue }

    // do something with image
}
```

### Guarding Against Excessive Indentation and Errors

Let's take a before-and-after look at how `guard` can
improve our code and help prevent errors.

As an example,
we'll implement a `readBedtimeStory()` function:

```swift
enum StoryError: Error {
    case missing
    case illegible
    case tooScary
}

func readBedtimeStory() throws {
    if let url = Bundle.main.url(forResource: "book",
                               withExtension: "txt")
    {
        if let data = try? Data(contentsOf: url),
            let story = String(data: data, encoding: .utf8)
        {
            if story.contains("👹") {
                throw StoryError.tooScary
            } else {
                print("Once upon a time... \(story)")
            }
        } else {
            throw StoryError.illegible
        }
    } else {
        throw StoryError.missing
    }
}
```

To read a bedtime story,
we need to be able to find the book,
the storybook must be decipherable,
and the story can't be too scary
(_no monsters at the end of this book, please and thank you!_).

But note how far apart the `throw` statements are from the checks themselves.
To find out what happens when you can't find `book.txt`,
you need to read all the way to the bottom of the method.

Like a good book,
code should tell a story:
with an easy-to-follow plot,
and clear a beginning, middle, and end.
(Just try not to write too much code in the "post-modern" genre).

Strategic use of `guard` statements
allow us to organize our code to read more linearly.

```swift
func readBedtimeStory() throws {
    guard let url = Bundle.main.url(forResource: "book",
                                  withExtension: "txt")
    else {
        throw StoryError.missing
    }

    guard let data = try? Data(contentsOf: url),
        let story = String(data: data, encoding: .utf8)
    else {
        throw StoryError.illegible
    }

    if story.contains("👹") {
        throw StoryError.tooScary
    }

    print("Once upon a time... \(story)")
}
```

_Much better!_
Each error case is handled as soon as it's checked,
so we can follow the flow of execution straight down the left-hand side.

### Don't Not Guard Against Double Negatives

One habit to guard against
as you embrace this new control flow mechanism is overuse ---
particularly when the evaluated condition is already negated.

For example,
if you want to return early if a string is empty,
don't write:

```swift
// Huh?
guard !string.isEmpty else {
    return
}
```

Keep it simple.
Go with the (control) flow.
Avoid the double negative.

```swift
// Aha!
if string.isEmpty {
    return
}
```

## defer

Between `guard` and the new `throw` statement for error handling,
Swift encourages a style of early return
(an NSHipster favorite) rather than nested `if` statements.
Returning early poses a distinct challenge, however,
when resources that have been initialized
(and may still be in use)
must be cleaned up before returning.

The `defer` keyword provides a safe and easy way to handle this challenge
by declaring a block that will be executed
only when execution leaves the current scope.

Consider the following function that wraps a system call to `gethostname(2)`
to return the current [hostname](https://en.wikipedia.org/wiki/Hostname)
of the system:

```swift
import Darwin

func currentHostName() -> String {
    let capacity = Int(NI_MAXHOST)
    let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: capacity)

    guard gethostname(buffer, capacity) == 0 else {
        buffer.deallocate()
        return "localhost"
    }

    let hostname = String(cString: buffer)
    buffer.deallocate()

    return hostname
}
```

Here, we allocate an `UnsafeMutablePointer<Int8>` early on
but we need to remember to deallocate it
both in the failure condition _and_ once we're finished with the buffer.

Error prone? _Yes._
Frustratingly repetitive? _Check._

By using a `defer` statement,
we can remove the potential for programmer error and simplify our code:

```swift
func currentHostName() -> String {
    let capacity = Int(NI_MAXHOST)
    let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: capacity)
    defer { buffer.deallocate() }

    guard gethostname(buffer, capacity) == 0 else {
        return "localhost"
    }

    return String(cString: buffer)
}
```

Even though `defer` comes immediately after the call to `allocate(capacity)`,
its execution is delayed until the end of the current scope.
Thanks to `defer`, `buffer` will be properly deallocated
regardless of where the function returns.

Consider using `defer` whenever an API requires calls to be balanced,
such as `allocate(capacity:)` / `deallocate()`,
`wait()` / `signal()`, or
`open()` / `close()`.
This way, you not only eliminate a potential source of programmer error,
but make Dijkstra proud.
_"Goed gedaan!" he'd say, in his native Dutch_.

### Deferring Frequently

If you use multiple `defer` statements in the same scope,
they're executed in reverse order of appearance ---
like a stack.
This reverse order is a vital detail,
ensuring everything that was in scope when a deferred block was created
will still be in scope when the block is executed.

For example,
running the following code prints the output below:

```swift
func procrastinate() {
    defer { print("wash the dishes") }
    defer { print("take out the recycling") }
    defer { print("clean the refrigerator") }

    print("play videogames")
}
```

<samp>
play videogames<br/>
clean the refrigerator<br/>
take out the recycling<br/>
wash the dishes<br/>
</samp>

> What happens if you nest `defer` statements, like this?

```swift
defer { defer { print("clean the gutter") } }
```

> Your first thought might be that it pushes the statement
> to the very bottom of the stack.
> But that's not what happens.
> Think it through,
> and then test your hypothesis in a Playground.

### Deferring Judgement

If a variable is referenced in the body of a `defer` statement,
its final value is evaluated.
That is to say:
`defer` blocks don't capture the current value of a variable.

If you run this next code sample,
you'll get the output that follows:

```swift
func flipFlop() {
    var position = "It's pronounced /ɡɪf/"
    defer { print(position) }

    position = "It's pronounced /dʒɪf/"
    defer { print(position) }
}
```

<samp>
It's pronounced /dʒɪf/ <br/>
It's pronounced /dʒɪf/
</samp>

### Deferring Demurely

Another thing to keep in mind
is that `defer` blocks can't break out of their scope.
So if you try to call a method that can throw,
the error can't be passed to the surrounding context.

```swift
func burnAfterReading(file url: URL) throws {
    defer { try FileManager.default.removeItem(at: url) }
    // 🛑 Errors not handled

    let string = try String(contentsOf: url)
}
```

Instead,
you can either ignore the error by using `try?`
or simply move the statement out of the `defer` block
and at the end of the function to execute conventionally.

### (Any Other) Defer Considered Harmful

As handy as the `defer` statement is,
be aware of how its capabilities can lead to confusing,
untraceable code.
It may be tempting to use `defer` in cases
where a function needs to return a value that should also be modified,
as in this typical implementation of the postfix `++` operator:

```swift
postfix func ++(inout x: Int) -> Int {
    let current = x
    x += 1
    return current
}
```

In this case, `defer` offers a clever alternative.
Why create a temporary variable when we can just defer the increment?

```swift
postfix func ++(inout x: Int) -> Int {
    defer { x += 1 }
    return x
}
```

Clever indeed, yet this inversion of the function's flow harms readability.
Using `defer` to explicitly alter a program's flow,
rather than to clean up allocated resources,
will lead to a twisted and tangled execution process.

---

"As wise programmers aware of our limitations,"
we must weigh the benefits of each language feature against its costs.

A new statement like `guard` leads to a more linear, more readable program;
apply it as widely as possible.

Likewise, `defer` solves a significant challenge
but forces us to keep track of its declaration as it scrolls out of sight;
reserve it for its minimum intended purpose to prevent confusion and obscurity.
