---
title: "Temporary Files"
author: Mattt
category: Cocoa
excerpt: >-
  Volumes have been written about persisting data, 
  but when it comes to short-lived, temporary files, 
  there is very little to go on for Cocoa. 
  (Or if there has, perhaps it was poetically ephemeral itself).
revisions:
  "2014-03-03": First Publication
  "2018-10-23": Updated for Swift 4.2
status:
  swift: 4.2
---

Volumes have been written about persisting data,
but when it comes to short-lived, temporary files,
there is very little to go on for Cocoa.
(Or if there has, perhaps it was poetically ephemeral itself).

---

Temporary files are used to write data to disk
before either moving it to a permanent location
or discarding it.
For example, when a movie editor app exports a project,
it may write each frame to a temporary file until it reaches the end
and moves the completed file to the `~/Movies` directory.
Using a temporary file for these kinds of situations
ensures that tasks are completed <dfn>atomically</dfn>
(either you get a finished product or nothing at all; nothing half-way),
and without creating excessive <dfn>memory pressure</dfn> on the system
(on most computers, disk space is plentiful whereas memory is limited).

There are four distinct steps to working with a temporary file:

- Creating a temporary directory in the filesystem
- Creating a temporary file in that directory with a unique filename
- Writing data to the temporary file
- Moving or deleting the temporary file once you're finished with it

## Creating a Temporary Directory

The first step to creating a temporary file
is to find a reasonable, out-of-the-way location to which you can write ---
somewhere inconspicuous that get in the way of the user
or accidentally get picked up by a system process like
Spotlight indexing, Time Machine backups, or iCloud sync.

On Unix systems, the `/tmp` directory is the de facto scratch space.
However, today's macOS and iOS apps run in a container
and don't have access to system directories;
a hard-coded path like that isn't going to cut it.

Instead, let's ask `FileManager` to point us in the right direction
using the `uri(for:in:appropriateFor:create:)` method:

```swift
let temporaryDirectoryURL =
    try FileManager.default.url(for: .itemReplacementDirectory,
                                in: .userDomainMask,
                                appropriateFor: URL(fileURLWithPath: "/"),
                                create: true)
```

```objc
NSFileManager *fileManager = [NSFileManager defaultManager];
NSError *error = nil;
NSURL *temporaryDirectoryURL =
    [fileManager URLForDirectory:NSItemReplacementDirectory
                        inDomain:NSUserDomainMask
               appropriateForURL:[NSURL fileURLWithPath:@"/"]
                          create:YES
                           error:&error];
```

The parameters of this method are frequently misunderstood,
so let's go through each to understand what this method actually does:

- We pass the item replacement search path (`.itemReplacementDirectory`)
  to say that we're interested in a temporary directory.
- We pass the user domain mask (`.userDomainMask`)
  to get a directory that's accessible to the user.
- For the `appropriateForURL` parameter,
  the only part of the file URL that's considered is the volume;
  therefore, we can pass `URL(fileURLWithPath: "/")`
  to specify the current volume.
- Finally, we pass `true` to the `create` parameter
  to save us the additional step of creating it ourselves.

The resulting directory will have a path that looks something like this:
<samp>file:///var/folders/l3/kyksr35977d8nfl1mhw6l_c00000gn/T/TemporaryItems/(A%20Document%20Being%20Saved%20By%20NSHipster%208)/</samp>

{% warning %}

A previous version of this article
recommended the use of `NSTemporaryDirectory()`.
That guidance was incorrect.
We recommend that you use `FileManager` APIs as described above.

{% endwarning %}

## Creating a Temporary File

With a place to call home (at least temporarily),
the next step is to figure out what to call our temporary file.
We're not picky about what to it's named ---
just so long as it's unique,
and doesn't interfere with any other temporary files in the directory.

The best way to generate a unique identifier
is the `ProcessInfo` property `globallyUniqueString`:

```swift
ProcessInfo().globallyUniqueString
```

```objc
[[NSProcessInfo processInfo] globallyUniqueString];
```

The resulting filename will look something like this:
<samp>42BC63F7-E79E-4E41-8E0D-B72B049E9254-25121-000144AB9F08C9C1</samp>

Alternatively,
[`UUID`](https://nshipster.com/uuid-udid-unique-identifier)
also produces workably unique identifiers:

```swift
UUID().uuidString
```

```objc
[[NSUUID UUID] UUIDString]
```

A generated UUID string has the following format:
<samp>B49C292E-573D-4F5B-A362-3F2291A786E7</samp>

Now that we have an appropriate directory and a unique filename,
let's put them together to create our temporary file:

```swift
let temporaryDirectoryURL =
    try FileManager.default.url(for: .itemReplacementDirectory,
                                in: .userDomainMask,
                                appropriateFor: URL(fileURLWithPath: "/"),
                                create: true)

let temporaryFilename = ProcessInfo().globallyUniqueString

let temporaryFileURL =
    temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
```

```objc
NSFileManager *fileManager = [NSFileManager defaultManager];

NSError *error = nil;
NSURL *temporaryDirectoryURL =
    [fileManager URLForDirectory:NSItemReplacementDirectory
                        inDomain:NSUserDomainMask
               appropriateForURL:[NSURL fileURLWithPath:@"/"]
                          create:YES
                           error:&error];

NSString *temporaryFilename =
    [[NSProcessInfo processInfo] globallyUniqueString];
NSURL *temporaryFileURL =
    [temporaryDirectoryURL
        URLByAppendingPathComponent:temporaryFilename];
```

## Writing to a Temporary File

The sole act of creating a file URL is of no consequence to the file system;
a file is created only when the file path is written to.
So let's talk about our options for doing that:

### Writing Data to a URL

The simplest way to write data to a file
is to call the `Data` method `write(to:options)`:

```swift
let data: Data
try data.write(to: temporaryFileURL,
               options: .atomicWrite)
```

```objc
NSData *data;
NSError *error = nil;
[data writeToURL:temporaryFileURL
         options:NSDataWritingAtomic
           error:&error];
```

By passing the `atomicWrite` option,
we ensure that either all of the data is written
or the method returns an error.

### Writing Data to a File Handle

If you're doing anything more complicated
than writing a single `Data` object to a file,
consider creating a `FileHandle` instead, like so:

```swift
let fileHandle = try FileHandle(forWritingTo: temporaryFileURL)
defer { fileHandle.closeFile() }

fileHandle.write(data)
```

```objc
NSError *error = nil;
NSFileHandle *fileHandle =
    [NSFileHandle fileHandleForWritingToURL:temporaryFileURL
                                      error:&error];
[fileHandle writeData:data];

[fileHandle closeFile];
```

### Writing Data to an Output Stream

For more advanced APIs,
it's not uncommon to use `OutputStream`
to direct the flow of data.
Creating an output stream to a temporary file
is no different than any other kind of file:

```swift
let outputStream =
    OutputStream(url: temporaryFileURL, append: true)!
defer { outputStream.close() }

data.withUnsafeBytes { bytes in
    outputStream.write(bytes, maxLength: bytes.count)
}
```

```objc
NSOutputStream *outputStream =
    [NSOutputStream outputStreamWithURL:temporaryFileURL
                                 append:YES];

[outputStream write:data.bytes
          maxLength:data.length];

[outputStream close];
```

{% info %}
In Swift,
calling `fileHandle.closeFile()` or
`outputStream.close()`
within a [`defer`](https://nshipster.com/guard-and-defer/) statement
is a convenient way to fulfill the API contract
of closing a file when we're done with it.
(Of course, don't do this if you want to keep the file handle open
longer than the enclosing scope).
{% endinfo %}

## Moving or Deleting the Temporary File

Files in system-designated temporary directories
are periodically deleted by the operating system.
So if you intend to hold onto the file that you've been writing to,
you need to move it somewhere outside the line of fire.

If you already know where the file's going to live,
you can use `FileManager` to move it to its permanent home:

```swift
let fileURL: URL
try FileManager.default.moveItem(at: temporaryFileURL,
                                 to: fileURL)
```

```objc
NSFileManager *fileManager = [NSFileManager defaultManager];

NSURL *fileURL;
NSError *error = nil;
[fileManager moveItemAtURL:temporaryFileURL
                     toURL:fileURL
                     error:&error];
```

{% info %}
Or, if you're not entirely settled on that,
you can use the same approach
to locate a cache directory where the file can lie low for a while:

```swift
let cacheDirectoryURL =
    try FileManager.default.url(for: .cachesDirectory,
                                in: .userDomainMask,
                                appropriateFor: URL(fileURLWithPath: "/"),
                                create: false)
```

```objc
NSFileManager *fileManager = [NSFileManager defaultManager];

NSError *error = nil;
NSURL *cacheDirectoryURL =
        [fileManager URLForDirectory:NSCachesDirectory
                            inDomain:NSUserDomainMask
                    appropriateForURL:[NSURL fileURLWithPath:@"/"]
                                create:NO
                                error:&error];
```

{% endinfo %}

Although the system eventually takes care of files in temporary directories,
it's not a bad idea to be a responsible citizen
and follow the guidance of
_"take only pictures; leave only footprints."_

`FileManager` can help us out here as well,
with the `removeItem(at:)` method:

```swift
try FileManager.default.removeItem(at: temporaryFileURL)
```

```objc
NSFileManager *fileManager = [NSFileManager defaultManager];

NSError *error = nil;
[fileManager removeItemAtURL:temporaryFileURL
                       error:&error];
```

---

_"This too shall pass"_
is a mantra that acknowledges that all things are indeed temporary.

Within the context of the application lifecycle,
some things are more temporary than others,
and it's with that knowledge that we choose to act appropriately:
seeking to find the right place,
make a unique impact,
and leave without a trace.

Perhaps we can learn something from this cycle in our own,
brief and glorious lifecycle.
