---
title: "NSTemporaryDirectory /<br/>NSItemReplacementDirectory /<br/>mktemp(3)"
author: Mattt Thompson
category: Cocoa
excerpt: "Volumes have been written about persisting data, but when it comes to short-lived, temporary files, there is very little to go on for Objective-C. (Or if there has, perhaps it was poetically ephemeral itself)."
status:
    swift: t.b.c.
---

Volumes have been written about persisting data, but when it comes to short-lived, temporary files, there is very little to go on for Objective-C. (Or if there has, perhaps it was poetically ephemeral itself).

* * *

Temporary files are used to write a buffer to disk, to either be atomically moved to a permanent location, or processed in some manner and then discarded. Creating a temporary file involves finding the appropriate part of the filesystem, generating a unique name, and moving or deleting the file after you're finished using it.

## Finding an Enclosing Directory

The first step to creating temporary files or directories is to find a reasonable, out-of-the-way place to write to—somewhere that won't be backed up by Time Machine or synced to iCloud or the like.

On Unix systems, the `/tmp` directory was the de facto scratch space, but with the sandboxed containers of iOS and OS X apps today, a hard-coded path just won't cut it.

`NSTemporaryDirectory` is a Foundation function that returns the directory designated for writing short-lived files on the targeted platform.

### A Wild Goose Chase

In recent years, Apple has pushed to extricate filesystem path operations from `NSString` APIs, recommending that users switch to using `NSURL` and `NSURL`-based APIs for classes like `NSFileManager`. Unfortunately, the migration has not been entirely smooth.

Consider the documentation for `NSTemporaryDirectory`:

> See the `NSFileManager` method `URLForDirectory:inDomain:appropriateForURL:create:error:` for the preferred means of finding the correct temporary directory.

Alright, fair enough. Let's see what's going on with `NSFileManager -URLForDirectory:inDomain:appropriateForURL:create:error:`:

> You can also use this method to create a new temporary directory for storing things like autosave files; to do so, specify `NSItemReplacementDirectory` for the directory parameter, `NSUserDomainMask` for the `domain` parameter, and a valid parent directory for the `url` parameter. After locating (or creating) the desired directory, this method returns the URL for that directory.

Huh? Even after reading through that a few times, it's still unclear how to use this, or what the expected behavior. A quick search through the mailing lists [reaffirms](http://lists.apple.com/archives/cocoa-dev/2012/Apr/msg00117.html) this [confusion](http://lists.apple.com/archives/cocoa-dev/2012/Feb/msg00186.html).

_Actually_, this method appears to be intended for moving _existing_ temporary files to a permanent location on disk with `-replaceItemAtURL:withItemAtURL:backupItemName:options:resultingItemURL:error:`. Not exactly what we're looking for.

So much for the `NSString` filesystem API migration. Let's stick to something that works:

~~~{objective-c}
[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
~~~

## Generating a Unique Directory or File Name

With a place to call home (temporarily), the next step is to figure out what to name our temporary file. We don't really care what temporary files are named—the only real concern is that they're unique, so as to not interfere with, or be interfered by, any other temporary files.

The best way to generate a unique identifier is to use the `globallyUniqueString` method on `NSProcessInfo`

~~~{objective-c}
NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
~~~

This will return a string in the format: `5BD255F4-CA55-4B82-A555-0F4BC5CA2AD6-479-0000018E14D059CC`

> Other sources advise the direct invocation of the `mktemp(3)` system command in order to mitigate potential conflicts. However,  using `NSProcessInfo -globallyUniqueString` to generate unique names is extremely unlikely to result in a collision.

Alternatively, `NSUUID` ([discussed previously](http://nshipster.com/uuid-udid-unique-identifier)) also produces workable results, assuming that you're not doing anything _too_ crazy.

~~~{objective-c}
[[NSUUID UUID] UUIDString]
~~~

This produces a string in the format: `22361D15-E17B-4C48-AEA6-C73BBEA17011`

## Creating a Temporary File Path

Using the aforementioned technique for generating unique identifiers, we can create unique temporary file paths:

~~~{objective-c}
NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"file.txt"];
NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
~~~

## Creating a Temporary Directory

In situations where many temporary files might be created by a process, it may be a good idea to create a temporary sub-directory, which could then be removed for easy cleanup.

Creating a temporary directory is no different than any other invocation of `NSFileManager -createDirectoryAtURL:withIntermediateDirectories:attributes:error:`:

~~~{objective-c}
NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
[[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
~~~

And, of course, temporary file paths relative to this directory can be created with `URLByAppendingPathComponent:`:

~~~{objective-c}
NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
~~~

## Writing to a Temporary File

Files don't exist on the file system until a particular file path is either touched or written to.

### NSData -writeToURL:options:error

There are several ways in which data is written to disk in Foundation. The most straightforward of which is `NSData -writeToURL:options:error`:

~~~{objective-c}
NSData *data = ...;
NSError *error = nil;
[data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
~~~

### NSOutputStream

For more advanced APIs, it is not uncommon to pass an `NSOutputStream` instance to direct the flow of data. Again, creating an output stream to a temporary file path is no different than any other kind of file path:

~~~{objective-c}
NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:[fileURL absoluteString] append:NO];
~~~

### Cleaning Up

The final step is what makes a temporary file _actually temporary_: clean up.

Although files in a system-designated temporary directory make no guarantees about how long they'll exist before being deleted automatically by the operating system (up to a few days, according to scattered reports), it's still good practice to take care of it yourself once you're finished.

Do that with `NSFileManager -removeItemAtURL:`, which works for both a temporary file and a temporary directory:

~~~{objective-c}
NSError *error = nil;
[[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
~~~

* * *

"This too shall pass" is a mantra that acknowledges that all things are indeed temporary. Within the context of the application lifecycle, some things are more temporary than others, and it is in that knowledge that we act appropriately, seeking to find the right place, make a unique impact, and leave without a trace.

Perhaps we can learn something from this cycle in our own, brief and glorious lifecycle.
