---
title: Benchmarking
author: Mattt Thompson
category: Objective-C
excerpt: "Abstractions are necessary for doing meaningful work, but they come at a cost. By benchmarking, a programmer can uncover the hidden performance characteristics of their code, and use this information to optimize accordingly."
status:
    swift: t.b.c.
---

Abstractions are necessary for doing meaningful work, but they come at a cost. To work at a high level is to turn a blind eye to nonessential details in order to reason with larger logical chunks. Determining what information is important within a particular context, however, is challenging, and is at the heart of performance engineering.

By benchmarking, a programmer can uncover the hidden performance characteristics of their code, and use this information to optimize accordingly. It is an essential tool for any developer interested in making their apps faster (which is to say every self-respecting developer).

* * *

The etymology of the word "benchmark" can be traced back to 19<sup>th</sup> century land surveying. In its original sense, a benchmark was a cut made into stone to secure a "bench", or kind of bracket, used to mount measuring equipment. Its figurative meaning of "a standard by which something is measured" was later repurposed to all walks of epistemology.

In programming, there is a minor semantic distinction between a _benchmark_ and the act of _benchmarking_:

A _benchmark_ is a program made specifically to measure and compare broad performance characteristics of hardware and software configurations. By contrast, _benchmarking_, is a general term for when code is used to measure the performance of a system.

## Benchmarking Performance in Objective-C

Benchmarks should be treated like any other epistemological discipline, with a firm grasp of the Scientific Method as well as statistics.

The Scientific Method outlines a series of steps to logically deduce answers for questions:

1. Ask a Question
2. Construct a Hypothesis
3. Predict the Outcome
4. Test the Hypothesis
5. Analyze the Results

In the case of programming, there are generally two kinds of questions to be asked:

- **What are the _absolute_ performance characteristics of this code?** Is the procedure bound by _computation_ or _memory_? What is the [limiting behavior](http://en.wikipedia.org/wiki/Big_O_notation) across different sample sizes?
- **What are the _relative_ performance characteristics of this code, as compared to its alternatives?** Which is faster, methodA or methodB?

Because the underlying factors of everything from the operating system down to the metal itself are extremely variable, performance should be measured across a large number of trials. For most applications, something on the order of 10<sup>5</sup> to 10<sup>8</sup> samples should be acceptable.

### First Pass: CACurrentMediaTime

For this example, let's take a look at the performance characteristics of adding an object to a mutable array.

To establish a benchmark, we specify a `count` of objects to add, and the number of `iterations` to run this process.

```objective-c
static size_t const count = 1000;
static size_t const iterations = 10000;
```

Since we're not testing the stack allocation of objects, we declare the object to be added to the array once, outside of the benchmark.

```objective-c
id object = @"🐷";
```

Benchmarking is as simple as taking the time before running, and comparing it against the time after. `CACurrentMediaTime()` is a convenient way to measure time in seconds derived from `mach_absolute_time`.

> Unlike `NSDate` or `CFAbsoluteTimeGetCurrent()` offsets, `mach_absolute_time()` and `CACurrentMediaTime()` are based on the internal host clock, a precise, monatomic measure, and not subject to changes in the external time reference, such as those caused by time zones, daylight savings, or leap seconds

`for` loops are used to increment `count` and `iterations`. Each iteration is enclosed by an `@autoreleasepool`, to keep the memory footprint low.

Putting it all together, here's a simple way to benchmark code in Objective-C:

```objective-c
CFTimeInterval startTime = CACurrentMediaTime();
{
    for (size_t i = 0; i < iterations; i++) {
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (size_t j = 0; j < count; j++) {
                [mutableArray addObject:object];
            }
        }
    }
}
CFTimeInterval endTime = CACurrentMediaTime();
NSLog(@"Total Runtime: %g s", endTime - startTime);
```

> The extra code block between `startTime` and `endTime` in the example below is unnecessary, but helps improve legibility and acts as a sanity check for variable scope

At this point, your NSHipster sense is probably tingling—as if to say, "Surely, there must be a better, more obscure way to do this!"

It's good to trust your instincts.

Allow me to introduce you to `dispatch_benchmark`.

### Second Pass: dispatch_benchmark

`dispatch_benchmark` is part of [`libdispatch`](http://libdispatch.macosforge.org), a.k.a Grand Central Dispatch. Curiously, though, this function is not publicly declared, so you'll have to do that yourself:

```objective-c
extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));
```

In addition to not having a public function definition, `dispatch_benchmark` also lacks public documentation in Xcode. Fortunately, it does have a man page:

#### man `dispatch_benchmark(3)`

> The `dispatch_benchmark` function executes the given `block` multiple times according to the `count` variable and then returns the average number of nanoseconds per execution. This function is for debugging and performance analysis work. For the best results, pass a high count value to `dispatch_benchmark`.
>
> Please look for inflection points with various data sets and keep the following facts in mind:
>
> - Code bound by computational bandwidth may be inferred by proportional
changes in performance as concurrency is increased.
> - Code bound by memory bandwidth may be inferred by negligible changes in
performance as concurrency is increased.
> - Code bound by critical sections may be inferred by retrograde changes in
performance as concurrency is increased.
>     - Intentional: locks, mutexes, and condition variables.
>     - Accidental: unrelated and frequently modified data on the same cache-line.

If you happened to skim all of that, be encouraged to read through that again—those are remarkably well-written docs. In addition to satisfying the prime directive of documentation of describing how to use the function, it also lays out rather comprehensive and insightful guidelines on how to best make use of the function.

Here's what the previous example looks like if we were to use `dispatch_benchmark` instead:

```objective-c
uint64_t t = dispatch_benchmark(iterations, ^{
    @autoreleasepool {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (size_t i = 0; i < count; i++) {
            [mutableArray addObject:object];
        }
    }
});
NSLog(@"[[NSMutableArray array] addObject:] Avg. Runtime: %llu ns", t);
```

Ahhh, much better. Nanoseconds are a suitably precise time unit, and `dispatch_benchmark` has a much nicer syntax than manually looping and calling `CACurrentMediaTime()`.

### NSMutableArray array vs. arrayWithCapacity:... FIGHT!

Now that we've settled on the preferred way to run an absolute benchmark in Objective-C, let's do a comparative test.

For this example, let's consider the age-old question of "What difference does passing a capacity parameter into collection initialization make?", or more succinctly, "to `-arrayWithCapacity:` or not to `-arrayWithCapacity:` (that is the question)".

Let's find out:

```objective-c
uint64_t t_0 = dispatch_benchmark(iterations, ^{
    @autoreleasepool {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (size_t i = 0; i < count; i++) {
            [mutableArray addObject:object];
        }
    }
});
NSLog(@"[[NSMutableArray array] addObject:] Avg. Runtime: %llu ns", t_0);

uint64_t t_1 = dispatch_benchmark(iterations, ^{
    @autoreleasepool {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:count];
        for (size_t i = 0; i < count; i++) {
            [mutableArray addObject:object];
        }
    }
});
NSLog(@"[[NSMutableArray arrayWithCapacity] addObject:] Avg. Runtime: %llu ns", t_1);
```

#### Results

Testing on an iPhone Simulator running iOS 7.1, the results are as follows:

```
[[NSMutableArray array] addObject:]: Avg. Runtime 26119 ns
[[NSMutableArray arrayWithCapacity] addObject:] Avg. Runtime: 24158 ns
```

Across a large number of samples, there is a roughly 7% performance difference between mutable arrays with and without a capacity.

Although the results are indisputable (our benchmark works beautifully), the real trick is in figuring out how to interpret these results. It would be incorrect to use this benchmark alone to conclude that passing a capacity is always a good idea. Rather, this first benchmark tells us what questions to ask next:

- **What does this cost mean in absolute terms?** In the spirit of avoiding [premature optimization](http://c2.com/cgi/wiki?PrematureOptimization), is the difference in performance negligible in the grand scheme of things?
- **What difference does changing the count of objects make?** Since initial capacity is used, presumably, to prevent resizing the array as it grows, how expensive is this operation for larger values of `n`?
- **What impact does an initial capacity have on the performance characteristics of other collection classes, like `NSMutableSet` or `NSMutableDictionary`?** The public deserves an answer!

## Common-Sense Benchmarking Guidelines

- **Know what question you're trying to answer.** Although we should always endeavor to replace magical thinking with understanding, we must protect against misappropriating scientific methodologies to support incomplete reasoning. Take time to understand what your results mean in terms of the bigger picture, before jumping to any conclusions.
- **Do not ship benchmarking code in apps.** Never mind the fact that `dispatch_benchmark` may or may not warrant an app rejection, benchmarked code has no place in a shipping product. Benchmarking should be done in separate one-off projects or an isolated test case.
- **Use Instruments to gain additional insights.** Knowing the absolute runtime of a series of computations is valuable, but may not offer much insight into how to make that number smaller. Use Instruments to spec the call stack and memory footprint of the code in question, in order to get a better sense of what's actually going on.
- **Benchmark on the device.** Just like any performance measurement, it should ultimately be done on the actual device. In most cases, general performance characteristics will be consistent between the simulator and device, but it's always worth verifying.
- **Don't prematurely optimize.** _This cannot be stressed enough._ One of the most pervasive tendencies for developers is to fixate on what they perceive to be "slow code", before there's any real evidence to support that. Even for veteran developers, it's very easy to incorrectly predict where bottlenecks will be in an application. Don't waste your time chasing shadows. Let Instruments show you where your app is spending most of its time.

* * *

Richard Feynman once likened experiments in particle physics to "[finding] out what a watch is made out of and how the mechanism works [by] smashing two watches together and seeing what kinds of gear wheels fly out". Benchmarking code can feel like this at times.

With so many implementation details of our computational universe hidden to us through layers of abstraction, sometimes the best we can do to try to understand what's at play is to magnify code by a few orders of magnitude and see what we get.

Through a disciplined application of science and statistics in benchmarking, a developer is able to create well-reasoned conclusions about the performance characteristics of their code. Apply these principles and practices in your own project to come to your own conclusions and optimize accordingly.
