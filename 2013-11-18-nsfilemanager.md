---
title: NSFileManager
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "File systems are a complex topic, with decades of history, vestigial complexities, and idiosyncrasies, and is well outside the scope of a single article. And since most applications don't often interact with the file system much beyond simple file operations, one can get away with only knowing the basics."
status:
    swift: t.b.c.
---

`NSFileManager` is Foundation's high-level API for working with file systems. It abstracts Unix and Finder internals, providing a convenient way to create, read, move, copy, and delete files & directories on local or networked drives, as well as iCloud ubiquitous containers.

File systems are a complex topic, with decades of history, vestigial complexities, and idiosyncrasies, and is well outside the scope of a single article. And since most applications don't often interact with the file system much beyond simple file operations, one can get away with only knowing the basics.

What follows are some code samples for your copy-pasting pleasure. Use them as a foundation for understanding how to adjust parameters to your particular use case:

## Common Tasks

> Throughout the code samples is the magical incantation `NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)`. This may be tied with KVO as one of the worst APIs in Cocoa. Just know that this returns an array containing the user documents directory as the first object. Thank goodness for the inclusion of `NSArray -firstObject`.

### Determining If A File Exists

~~~{objective-c}
NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *filePath = [documentsPath stringByAppendingPathComponent:@"file.txt"];
BOOL fileExists = [fileManager fileExistsAtPath:filePath];
~~~

### Listing All Files In A Directory

~~~{objective-c}
NSFileManager *fileManager = [NSFileManager defaultManager];
NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                               includingPropertiesForKeys:@[]
                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    error:nil];

NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'png'"];
for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate]) {
    // Enumerate each .png file in directory
}
~~~

## Recursively Enumerating Files In A Directory

~~~{objective-c}
NSFileManager *fileManager = [NSFileManager defaultManager];
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
~~~

### Creating a Directory

~~~{objective-c}
NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *imagesPath = [documentsPath stringByAppendingPathComponent:@"images"];
if (![fileManager fileExistsAtPath:imagesPath]) {
    [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil];
}
~~~

### Deleting a File

~~~{objective-c}
NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"];
NSError *error = nil;

if (![fileManager removeItemAtPath:filePath error:&error]) {
    NSLog(@"[Error] %@ (%@)", error, filePath);
}
~~~

### Determining the Creation Date of a File

~~~{objective-c}
NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *filePath = [documentsPath stringByAppendingPathComponent:@"Document.pages"];

NSDate *creationDate = nil;
if ([fileManager fileExistsAtPath:filePath]) {
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
    creationDate = attributes[NSFileCreationDate];
}
~~~

There are a number of file attributes that are made accessible through `NSFileManager`, which can be fetched with `-attributesOfItemAtPath:error:`, and other methods:

#### File Attribute Keys

> - `NSFileAppendOnly`: The key in a file attribute dictionary whose value indicates whether the file is read-only.
> - `NSFileBusy`: The key in a file attribute dictionary whose value indicates whether the file is busy.
> - `NSFileCreationDate`: The key in a file attribute dictionary whose value indicates the file's creation date.
> - `NSFileOwnerAccountName`: The key in a file attribute dictionary whose value indicates the name of the file's owner.
> - `NSFileGroupOwnerAccountName`: The key in a file attribute dictionary whose value indicates the group name of the file's owner.
> - `NSFileDeviceIdentifier`: The key in a file attribute dictionary whose value indicates the identifier for the device on which the file resides.
> - `NSFileExtensionHidden`: The key in a file attribute dictionary whose value indicates whether the file's extension is hidden.
> - `NSFileGroupOwnerAccountID`: The key in a file attribute dictionary whose value indicates the file's group ID.
> - `NSFileHFSCreatorCode`: The key in a file attribute dictionary whose value indicates the file's HFS creator code.
> - `NSFileHFSTypeCode`: The key in a file attribute dictionary whose value indicates the file's HFS type code.
> - `NSFileImmutable`: The key in a file attribute dictionary whose value indicates whether the file is mutable.
> - `NSFileModificationDate`: The key in a file attribute dictionary whose value indicates the file's last modified date.
> - `NSFileOwnerAccountID`: The key in a file attribute dictionary whose value indicates the file's owner's account ID.
> - `NSFilePosixPermissions`: The key in a file attribute dictionary whose value indicates the file's Posix permissions.
> - `NSFileReferenceCount`: The key in a file attribute dictionary whose value indicates the file's reference count.
> - `NSFileSize`: The key in a file attribute dictionary whose value indicates the file's size in bytes.
> - `NSFileSystemFileNumber`: The key in a file attribute dictionary whose value indicates the file's filesystem file number.
> - `NSFileType`: The key in a file attribute dictionary whose value indicates the file's type.


> - `NSDirectoryEnumerationSkipsSubdirectoryDescendants`: Perform a shallow enumeration; do not descend into directories.
> - `NSDirectoryEnumerationSkipsPackageDescendants`: Do not descend into packages.
> - `NSDirectoryEnumerationSkipsHiddenFiles`: Do not enumerate hidden files.

## NSFileManagerDelegate

`NSFileManager` may optionally set a delegate to verify that it should perform a particular file operation. This allows the business logic of, for instance, which files to protect from deletion, to be factored out of the controller.

There are four kinds of methods in the `<NSFileManagerDelegate>` protocol, each with a variation for working with paths, as well as methods for error handling:

- `-fileManager:shouldMoveItemAtURL:toURL:`
- `-fileManager:shouldCopyItemAtURL:toURL:`
- `-fileManager:shouldRemoveItemAtURL:`
- `-fileManager:shouldLinkItemAtURL:toURL:`

If you were wondering when you might `alloc init` your own `NSFileManager` rather than using the shared instance, this is it. As per the documentation:

> If you use a delegate to receive notifications about the status of move, copy, remove, and link operations, you should create a unique instance of the file manager object, assign your delegate to that object, and use that file manager to initiate your operations.

~~~{objective-c}
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
~~~

#### CustomFileManagerDelegate.m

~~~{objective-c}
#pragma mark - NSFileManagerDelegate

- (BOOL)fileManager:(NSFileManager *)fileManager
shouldRemoveItemAtURL:(NSURL *)URL
{
    return ![[[URL lastPathComponent] pathExtension] isEqualToString:@"pdf"];
}
~~~

## Ubiquitous Storage

Documents can also be moved to iCloud. If you guessed that this would be anything but straight forward, you'd be 100% correct.

This is another occasion when you'd `alloc init` your own `NSFileManager` rather than using the shared instance. Because `URLForUbiquityContainerIdentifier:` and `setUbiquitous:itemAtURL:destinationURL:error:` are blocking calls, this entire operation needs to be dispatched to a background queue.

### Moving an Item to Ubiquitous Storage

~~~{objective-c}
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *fileURL = [NSURL fileURLWithPath:[documentsPath stringByAppendingPathComponent:@"Document.pages"]];

    // Defaults to first listed in entitlements when `nil`; should replace with real identifier
    NSString *identifier = nil;

    NSURL *ubiquitousContainerURL = [fileManager URLForUbiquityContainerIdentifier:identifier];
    NSURL *ubiquitousFileURL = [ubiquitousContainerURL URLByAppendingPathComponent:@"Document.pages"];

    NSError *error = nil;
    BOOL success = [fileManager setUbiquitous:YES
                                    itemAtURL:fileURL
                               destinationURL:ubiquitousFileURL
                                        error:&error];
    if (!success) {
        NSLog(@"[Error] %@ (%@) (%@)", error, fileURL, ubiquitousFileURL);
    }
});
~~~

> You can find more information about ubiquitous document storage in Apple's "iCloud File Management" document.

* * *

There's a lot to know about file systems, but as an app developer, it's mostly an academic exercise. Now don't get me wrong—academic exercises are great! But they don't ship code. `NSFileManager` allows you to ignore most of the subtlety of all of this and get things done.
