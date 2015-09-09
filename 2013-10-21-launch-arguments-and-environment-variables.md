---
title: "Launch Arguments &<br/>Environment Variables"
author: Mattt Thompson
category: Xcode
excerpt: "There are a number of options that can be passed into a target's scheme to enable useful debugging behavior, but like a fast food secret menu, they're obscure and widely unknown."
status:
    swift: n/a
---

Walk into any American fast food establishment, and you'll be greeted with a colorful, back-lit display of specials, set menus, and other a la carte items. But as those in-the-know are quick to point out, larger chains often have a _secret_ menu, passed down by oral tradition between line cook workers and patrons over the generations.

At McDonald's, one can order a "Poor Man’s Big Mac", which transforms a double cheeseburger alchemy-like into the chain's signature sandwich on the cheap.

At Chipotle, there is an unwritten rule that they'll make anything within the scope of available ingredients. Since Mexican food is a testament to culinary combinatorics, an off-book order for a Quesadilla or Nachos is well within their wheelhouse.

In life, it's all about knowing what to ask for.

Which brings us to Xcode Launch Arguments & Environment Variables. There are a number of options that can be passed into a target's scheme to enable useful debugging behavior, but like a fast food secret menu, they're obscure and widely unknown.

So this week on NSHipster, we'll take a look at the hidden world of Xcode runtime configuration, so that you, dear reader, may also saunter up to the great lunch counter of Objective-C and order to your heart's content.

* * *

To enable launch arguments and set environment variables for your app, select your target from the Xcode toolbar and select "Edit Scheme..."

![Edit Scheme...](http://nshipster.s3.amazonaws.com/launch-arguments-edit-scheme.png)

On the left side of the panel, select "Run [AppName].app", and select the "Arguments" segment on the right side. There will be two drop-downs, for "Arguments Passed on Launch" and "Environment Variables".

![Edit Scheme Panel](http://nshipster.s3.amazonaws.com/launch-arguments-edit-scheme-panel.png)

For the purposes of debugging an app target, launch arguments and environment variables can be thought to be equivalent—both change the runtime behavior by defining certain values. In practice, the main difference between the two is that launch arguments begin with a dash (`-`) and don't have a separate field for argument values.

## Arguments Passed on Launch

Any argument passed on launch will override the current value in `NSUserDefaults` for the duration of execution. While this can be used for domain-specific testing and debugging, the two most widely applicable use cases are for localization and Core Data.

### Localization

Getting localization right is a challenging and time-consuming task in and of itself. Fortunately, there are a few launch arguments that make the process _much_ nicer.

> For more information about localization, check out our article about [`NSLocalizedString`](http://nshipster.com/nslocalizedstring/).

#### NSDoubleLocalizedStrings

To simulate German's UI-breaking _götterdämmere Weltanschauung_ of long-compound-words-unbroken-by-breakable-whitespace, there's `NSDoubleLocalizedStrings`.

According to [IBM's Globalization Guidelines](http://www-01.ibm.com/software/globalization/guidelines/a3.html), we can expect translations from English to many European languages to be double or even triple the physical space of the source:

<table>
<thead>
<tr>
<th>Number of Characters in Text</th>
<th>Additional Physical Space Required</th>
</tr>
<tbody>
<tr><td>≤ 10</td><td>100% to 200%</td></tr>
<tr><td>11 – 20</td><td>80% to 100%</td></tr>
<tr><td>21 – 30</td><td>60% to 80%</td></tr>
<tr><td>31 – 50</td><td>40% to 60%</td></tr>
<tr><td>51 – 70</td><td>31% to 40%</td></tr>
<tr><td>70</td><td>30%</td></tr>
</tbody>
</table>

While you're waiting for the first batch of translations to come back, or are merely curious to see how badly your UI breaks under linguistic pressure, specify the following launch argument:

~~~
-NSDoubleLocalizedStrings YES
~~~

![NSDoubleLocalizedStrings - Before & After](http://nshipster.s3.amazonaws.com/launch-arguments-nsdoublelocalizedstrings.png)

#### NSShowNonLocalizedStrings

Project managers screaming at you to get localization finished? Now you can configure your app to scream at you as well!

If you pass the `NSShowNonLocalizedStrings` launch argument, any unlocalized string will SCREAM AT YOU IN CAPITAL LETTERS. HOW DELIGHTFUL!

~~~
-NSShowNonLocalizedStrings YES
~~~

#### AppleLanguages

Perhaps the most useful launch argument of all, however, is `AppleLanguages`.

Normally, one would have to manually go through Settings > General > International > Language and wait for the Simulator or Device to restart. But the same can be accomplished much more simply with the following launch argument:

~~~
-AppleLanguages (es)
~~~

> The value for `AppleLanguages` can either be the name of the language ("Spanish"), or its language code (`es`), but since localization files are keyed by their ISO 639 code, using the code is preferable to the actual name of the language.

### Core Data

Of all of the system frameworks, Core Data may be the most in need of debugging. Managed objects passing across contexts and threads, and notifications firing with dazzlingly fervor, there's too much going on to keep track of yourself. Call in reinforcements with these essential launch arguments:

#### SQL Debug

Most Core Data stacks use SQLite as a persistent store, so if your app is anything like the majority, you'll appreciate being able to watch SQL statements and statistics fly by as Core Data works its magic.

Set the following launch argument:

~~~
-com.apple.CoreData.SQLDebug 3
~~~

...and let the spice flow.

~~~
CoreData: sql: pragma cache_size=1000
CoreData: sql: SELECT Z_VERSION, Z_UUID, Z_PLIST FROM Z_METADATA
CoreData: sql: SELECT 0, t0.Z_PK, t0.Z_OPT, t0.ZAUTHOR, t0.ZTITLE, t0.ZCOPYRIGHT FROM ZBOOK t0 ORDER BY t0.ZAUTHOR, t0.ZTITLE
CoreData: annotation: sql connection fetch time: 0.0001s
CoreData: annotation: total fetch execution time: 0.0010s for 20 rows.
~~~

`com.apple.CoreData.SQLDebug` takes a value between `1` and `3`; the higher the value, the more verbose the output. Adjust according to taste.

#### Syntax Colored Logging

Want your debug statements to be _even spicier_? Toss `com.apple.CoreData.SyntaxColoredLogging` into the mix and brace yourself for an explosion of color:

~~~
-com.apple.CoreData.SyntaxColoredLogging YES
~~~

#### Migration Debug

In any other persistence layer, migrations are a blessing. Yet, for some reason, Core Data manages to make them into something out of a nightmare. When things go wrong and you have no one to blame except your own ignorant self, unworthy of such an intuitive and well-designed <del>ORM</del> <ins>graph persistence framework</ins>, then here's an argument you'll want to pass at launch:

~~~
-com.apple.CoreData.MigrationDebug
~~~

* * *

## Environment Variables

Whereas launch arguments are specific to the executable, environment variables have a wider scope, more along the lines of a global variable (but without all of the knee-jerk derision from programmers).

Configure your environment with the following settings to shape the memory management policies to aide in debugging.

> Unless otherwise specified, environment variables are passed `YES` or `NO` to enable or disable a particular feature.

### Zombies!

Over-played in popular media, under-played in Objective-C, everyone can agree that it pays to know about zombies.

Setting `NSZombie`-related environment variables allows you to control the _BRAAAAINS!_ of your app. To be more specific, when objects are deallocated, they become "zombified", able to communicate any messages that are passed after they have been freed. This can be useful for tracing any errant `EXC_BAD_ACCESS` exceptions you get during execution.

<table>
<thead>
<tr>
<th>Name</th><th>Effect</th></tr>
</thead>
<tbody>
<tr><td><tt>NSZombieEnabled</tt></td></td><td>If set to <tt>YES</tt>, deallocated objects are 'zombified'; this allows you to quickly debug problems where you send a message to an object that has already been freed.</td></tr>
<tr><td><tt>NSDeallocateZombies</tt></td><td>If set to <tt>YES</tt>, the memory for 'zombified' objects is actually freed.</td></tr>
</tbody>
</table>

### Memory Allocator

The memory allocator includes several debugging hooks that can be enabled by environment variables. As explained in Apple's [Memory Usage Performance Guidelines](https://developer.apple.com/library/mac/documentation/performance/Conceptual/ManagingMemory/Articles/MallocDebug.html):

> Guard Malloc is a special version of the malloc library that replaces the standard library during debugging. Guard Malloc uses several techniques to try and crash your application at the specific point where a memory error occurs. For example, it places separate memory allocations on different virtual memory pages and then deletes the entire page when the memory is freed. Subsequent attempts to access the deallocated memory cause an immediate memory exception rather than a blind access into memory that might now hold other data. When the crash occurs, you can then go and inspect the point of failure in the debugger to identify the problem.

Here are some of the most useful ones:

<table>
<thead>
<tr><th>Name</th><th>Effect</th></tr>
</thead>
<tbody>
<tr><td><tt>MallocScribble</tt></td><td>Fill allocated memory with 0xAA and scribble deallocated memory with <tt>0x55</tt>.</td></tr>
<tr><td><tt>MallocGuardEdges</tt></td><td>Add guard pages before and after large allocations.</td></tr>
<tr><td><tt>MallocStackLogging</tt></td><td>Record backtraces for each memory block to assist memory debugging tools; if the block is allocated and then immediately freed, both entries are removed from the log, which helps reduce the size of the log.</td></tr>
<tr><td><tt>MallocStackLoggingNoCompact</tt></td><td>Same as <tt>MallocStackLogging</tt> but keeps all log entries.</td></tr>
</tbody>
</table>

### I/O Buffering

Although unlikely, you may come across a situation where you want logging to `stdout` to be unbuffered (ensuring that the output has been written before continuing). You can set that with the `NSUnbufferedIO` environment variable:

<table>
<thead>
<tr><th>Name</th><th>Effect</th></tr>
</thead>
<tbody>
<tr><td><tt>NSUnbufferedIO</tt></td><td>If set to YES, Foundation will use unbuffered I/O for <tt>stdout</tt> (<tt>stderr</tt> is unbuffered by default).</td></tr>
</tbody>
</table>

* * *

Just as secret menus are bound by the implications of Gödel's Incompleteness Theorem, it is impossible to document all of the secret incantations to get special treatment in Xcode. However, perhaps you can find a few more (and learn a _ton_ about runtime internals) by perusing Apple's [Technical Note TN2239: iOS Debugging Magic][TN2239] and [Technical Note TN2124: OS X Debugging Magic][TN2124].

Hopefully, though, the secret knowledge you've been exposed to in this article will sustain you in your app endeavors. Use them wisely, and pass them onto your coworkers like an urban legend or juicy rumor.


[TN2239]: https://developer.apple.com/library/ios/technotes/tn2239/_index.html
[TN2124]: https://developer.apple.com/library/mac/technotes/tn2124/_index.html
