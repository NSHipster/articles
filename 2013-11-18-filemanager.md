---
title: FileManager
author: Mattt
category: Cocoa
tags: nshipster
excerpt: >-
  `FileManager` offers a convenient way to create, read, move, copy, and delete
  both files and directories,
  whether they're on local or networked drives or iCloud ubiquitous containers.
revisions:
  "2013-11-18": First Publication
  "2018-10-29": Updated for Swift 4.2
status:
  swift: 4.2
  reviewed: October 29, 2018
---

One of the most rewarding experiences you can have as a developer
is to teach young people how to program.
If you ever grow jaded by how fundamentally broken all software is,
there's nothing like watching a concept like recursion
_click_ for the first time
to offset your world-weariness.

My favorite way to introduce the concept of programming
is to set out all the ingredients for a peanut butter and jelly sandwich
and ask the class give me instructions for assembly
as if I were a robot 🤖.
The punchline is that the computer
takes every instruction as _literally_ as possible,
often with unexpected results.
Ask the robot to "put peanut butter on the bread",
and you may end up with an unopened jar of Jif
flattening a sleeve of Wonder Bread.
Forget to specify which part of the bread to put the jelly on?
Don't be surprised if it ends up on the outer crust.
And so on.
_Kids love it._

The lesson of breaking down a complex process into discrete steps
is a great encapsulation of programming.
And the malicious compliance from lack of specificity
echoes the analogy of "programming as wish making"
from [our article about `numericCast(_:)`](/numericcast).

But let's take the metaphor a step further,
and imagine that instead of commanding a single robot to
([`sudo`](https://xkcd.com/149/))
make a sandwich,
you're writing instructions for a thousand different robots.
Big and small, fast and slow;
some have 4 arms instead of 2,
others hover in the air,
maybe a few read everything in reverse.
Consider what would happen if multiple robots tried to make a sandwich
at the same time.
Or imagine that your instructions
might be read by robots that won't be built for another 40 years,
by which time peanut butter is packaged in capsules
and jelly comes exclusively as a gas.

That's kind of what it's like to interact with a file system.

The only chance we have at making something that works
is to leverage the power of abstraction.
On Apple platforms,
this functionality is provided by the Foundation framework
by way of `FileManager`.

We can't possibly cover everything there is to know
about working with file systems in a single article,
so this week,
let's take a look at the operations you're most likely to perform
when building an app.

---

`FileManager` offers a convenient way to create, read, move, copy, and delete
both files and directories,
whether they're on local or networked drives or iCloud ubiquitous containers.

The common currency for all of these operations are paths and file URLs.

## Paths and File URLs

Objects on the file system can be identified in a few different ways.
For example, each of the following represents
the location of the same text document:

- Path: `/Users/NSHipster/Documents/article.md`
- File URL: `file:///Users/NSHipster/Documents/article.md`
- File Reference URL: `file:///.file/id=1234567.7654321/`

<dfn>Paths</dfn> are slash-delimited (`/`) strings that designate a location
in the directory hierarchy.
<dfn>File URLs</dfn> are URLs with a `file://` scheme in addition to a file path.
<dfn>File Reference URLs</dfn> identify the location of a file
using a unique identifier separate from any directory structure.

Of those,
you'll mostly deal with the first two,
which identify files and directories using a relational path.
That path may be <dfn>absolute</dfn>
and provide the full location of a resource from the root directory,
or it may be <dfn>relative</dfn>
and show how to get to a resource from a given starting point.
Absolute URLs begin with `/`,
whereas relative URLs begin with
`./` (the current directory),
`../` (the parent directory), or
`~` (the current user's home directory).

`FileManager` has methods that accept both paths and URLs ---
often with variations of the same method for both.
In general, the use of URLs is preferred to paths,
as they're more flexible to work with.
(it's also easier to convert from a URL to a path than vice versa).

## Locating Files and Directories

The first step to working with a file or directory
is locating it on the file system.
Standard locations vary across different platforms,
so rather than manually constructing paths like `/System` or `~/Documents`,
you use the `FileManager` method `url(for:in:appropriateFor:create:)`
to locate the appropriate location for what you want.

The first parameter takes one of the values specified by
[`FileManager.SearchPathDirectory`](https://developer.apple.com/documentation/foundation/filemanager/searchpathdirectory).
These determine what kind of standard directory you're looking for,
like "Documents" or "Caches".

The second parameter passes a
[`FileManager.SearchPathDomainMask`](https://developer.apple.com/documentation/foundation/filemanager/searchpathdomainmask) value,
which determines the scope of where you're looking for.
For example,
`.applicationDirectory` might refer to `/Applications` in the local domain
and `~/Applications` in the user domain.

```swift
let documentsDirectoryURL =
    try FileManager.default.url(for: .documentDirectory,
                            in: .userDomainMask,
                            appropriateFor: nil,
                            create: false)
```

```objc
NSString *documentsPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *filePath = [documentsPath stringByAppendingPathComponent:@"file.txt"];
```

{% info %}

Files and directories can have alternate names from what's encoded by the path.

For example, most macOS system directories are localized;
although a user's photos located at `~/Photos`,
the `~/Photos/.localized` file can change how the folder is named in Finder
and Open / Save panels.
An app can also provide locale-specific names for itself
and directories it creates.

Another example of this is when files
are configured to hide their file extension.
(You've probably encountered this at some point,
with some degree of bewilderment).

Long story short, when displaying the name of a file or directory to the user,
don't simply take the last path component.
Instead, call the method `displayName(atPath:)`:

```swift
let directoryURL: URL

// Bad
let filename = directoryURL.pathComponents.last

// Good
let filename = FileManager.default.displayName(atPath: url.path)
```

```objc
NSString *documentsPath;

// Bad
NSString *filename = documentsPath.pathComponents.lastObject;

// Good
NSString *filename = [NSFileManager.defaultManager displayNameAtPath:documentsPath];
```

{% endinfo %}

## Determining Whether a File Exists

You might check to see if a file exists at a location before trying to read it,
or want to avoid overwriting an existing one.
To do this, call the `fileExists(atPath:)` method:

```swift
let fileURL: URL
let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
```

```objc
NSURL *fileURL;
BOOL fileExists = [NSFileManager.defaultManager fileExistsAtPath:[fileURL path]];
```

## Getting Information About a File

The file system stores various pieces of metadata
about each file and directory in the system.
You can access them using the `FileManager` method `attributesOfItem(atPath:)`.
The resulting dictionary contains attributes keyed by `FileAttributeKey` values,
including `.creationDate`:

```swift
let fileURL: URL
let attributes =
    FileManager.default.attributesOfItem(atPath: fileURL.path)
let creationDate = attributes[.creationDate]
```

```objc
NSURL *fileURL;
NSFileManager *fileManager = NSFileManager.defaultManager;

NSError *error = nil;
NSDictionary *attributes = [fileManager attributesOfItemAtPath:[fileURL path]
                                                         error:&error];
NSDate *creationDate = attributes[NSFileCreationDate];
```

{% info %}
File attributes used to be keyed by string constants,
which made them hard to discover through autocompletion or documentation.
Fortunately, it's now easy to
[see everything that's available](https://developer.apple.com/documentation/foundation/fileattributekey).
{% endinfo %}

## Listing Files in a Directory

To list the contents of a directory,
call the `FileManager` method
`contentsOfDirectory(at:includingPropertiesForKeys:options:)`.
If you intend to access any metadata properties,
as described in the previous section
(for example, get the modification date of each file in a directory),
specify those here to ensure that those attributes are cached.
The `options` parameter of this method allows you to skip
hidden files and/or descendants.

```swift
let directoryURL: URL
let contents =
    try FileManager.default.contentsOfDirectory(at: directoryURL,
                                                includingPropertiesForKeys: nil,
                                                options: [.skipsHiddenFiles])
for file in contents {
    // ...
}
```

```objc
NSFileManager *fileManager = NSFileManager.defaultManager;
NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                               includingPropertiesForKeys:@[]
                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    error:nil];

NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'png'"];
for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate]) {
    // Enumerate each .png file in directory
}
```

### Recursively Enumerating Files In A Directory

If you want to go through each subdirectory at a particular location recursively,
you can do so by creating a `FileManager.DirectoryEnumerator` object
with the `enumerator(atPath:)` method:

```swift
let directoryURL: URL

if let enumerator =
    FileManager.default.enumerator(atPath: directoryURL.path)
{
    for case let path as String in enumerator {
        // Skip entries with '_' prefix, for example
        if path.hasPrefix("_") {
            enumerator.skipDescendants()
        }
    }
}
```

```objc
NSFileManager *fileManager = NSFileManager.defaultManager;
NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:bundleURL
                                      includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    errorHandler:^BOOL(NSURL *url, NSError *error)
{
    if (error) {
        NSLog(@"[Error] %@ (%@)", error, url);
        return NO;
    }

    return YES;
}];

NSMutableArray *mutableFileURLs = [NSMutableArray array];
for (NSURL *fileURL in enumerator) {
    NSString *filename;
    [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];

    NSNumber *isDirectory;
    [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];

    // Skip directories with '_' prefix, for example
    if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
        [enumerator skipDescendants];
        continue;
    }

    if (![isDirectory boolValue]) {
        [mutableFileURLs addObject:fileURL];
    }
}
```

## Creating a Directory

To create a directory,
call the method `createDirectory(at:withIntermediateDirectories:attributes:)`.
In Unix parlance, setting the `withIntermediateDirectories` parameter to `true`
is equivalent to passing the `-p` option to `mkdir`.

```swift
try FileManager.default.createDirectory(at: directoryURL,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
```

```objc
NSFileManager *fileManager = NSFileManager.defaultManager;
NSString *documentsPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask,
                                         YES) firstObject];
NSString *imagesPath = [documentsPath stringByAppendingPathComponent:@"images"];
if (![fileManager fileExistsAtPath:imagesPath]) {
    NSError *error = nil;
    [fileManager createDirectoryAtPath:imagesPath
           withIntermediateDirectories:NO
                            attributes:nil
                                 error:&error];
}
```

## Deleting a File or Directory

If you want to delete a file or directory,
call `removeItem(at:)`:

```swift
let fileURL: URL
try FileManager.default.removeItem(at: fileURL)
```

```objc
NSString *documentsPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask,
                                         YES) firstObject];
NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"];
NSError *error = nil;

if (![NSFileManager.defaultManager removeItemAtPath:filePath error:&error]) {
    NSLog(@"[Error] %@ (%@)", error, filePath);
}
```

## FileManagerDelegate

`FileManager` may optionally set a delegate
to verify that it should perform a particular file operation.
This is a convenient way to audit all file operations in your app,
and a good place to factor out and centralize business logic,
such as which files to protect from deletion.

There are four operations covered by the
[`FileManagerDelegate`](https://developer.apple.com/documentation/foundation/filemanagerdelegate) protocol:
moving, copying, removing, and linking items ---
each with variations for working with paths and URLs,
as well as how to proceed after an error occurs:

If you were wondering when you might create your own `FileManager`
rather than using this shared instance,
this is it.

From the documentation:

> You should associate your delegate
> with a unique instance of the `FileManager` class,
> as opposed to the shared instance.

```swift
class CustomFileManagerDelegate: NSObject, FileManagerDelegate {
    func fileManager(_ fileManager: FileManager,
                              shouldRemoveItemAt URL: URL) -> Bool
    {
        // Don't delete PDF files
        return URL.pathExtension != "pdf"
    }
}

// Maintain strong references to fileManager and delegate
let fileManager = FileManager()
let delegate = CustomFileManagerDelegate()

fileManager.delegate = delegate
```

```objc
NSFileManager *fileManager = [[NSFileManager alloc] init];
fileManager.delegate = delegate;

NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                               includingPropertiesForKeys:@[]
                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    error:nil];

for (NSString *filePath in contents) {
    [fileManager removeItemAtPath:filePath error:nil];
}

// CustomFileManagerDelegate.m

#pragma mark - NSFileManagerDelegate

- (BOOL)fileManager:(NSFileManager *)fileManager
shouldRemoveItemAtURL:(NSURL *)URL
{
    return ![[[URL lastPathComponent] pathExtension] isEqualToString:@"pdf"];
}
```

---

When you write an app that interacts with a file system,
you don't know if it's an HDD or SSD
or if it's formatted with APFS or HFS+ or something else entirely.
You don't even know where the disk is:
it could be internal or in a mounted peripheral,
it could be network-attached, or maybe floating around somewhere in the cloud.

The best strategy for ensuring that things work
across each of the various permutations
is to work through `FileManager` and its related Foundation APIs.
