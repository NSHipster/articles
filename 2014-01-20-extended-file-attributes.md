---
title: Extended File Attributes
author: Mattt Thompson
category: Objective-C
excerpt: "Amidst revelations of widespread spying by the NSA, the concept of metadata has taken an unexpected role in the national conversation about government surveillance. What is it? And how much does it reveal about us and our daily habits? These are questions that the American people are asking, and they deserve an answer."
status:
    swift: t.b.c.
---

Amidst revelations of widespread spying by the NSA, the concept of metadata has taken an unexpected role in the national conversation about government surveillance. What is it? And how much does it reveal about us and our daily habits? These are questions that the American people are asking, and they deserve an answer.

Acting with a sense of civic and patriotic duty rivaled only by Uncle Sam walloping Communism with a bald eagle, NSHipster aims to shed as much light on metadata as Edward Snowden with an industrial lantern.

* * *

For every file on a UNIX filesystem, there is associated metadata. Indeed, having a path, permissions, and timestamp attributes is what makes a file a file, rather than just a blob of data.

However, on OS X and iOS, additional metadata can be stored in [**extended file attributes**](http://en.wikipedia.org/wiki/Extended_file_attributes). Introduced in OS X Tiger, they are perfect for associating small, application-specific data with a file. EAs are stored in the attributes B*-Tree of the HFS+ filesystem, and have a maximum size of 128KB as of OS X Lion & iOS 5.

What kind of information, you ask? Invoke the `ls` command in the terminal and pass the `@` option to see what information hides in plain sight.

~~~
$ ls -l@
-rw-r--r--@ 1 mattt  staff  12292 Oct 19 05:59 .DS_Store
	com.apple.FinderInfo	   32
-rw-r--r--@ 1 mattt  staff   5147 Dec  3 05:01 NSFixie.h
	com.apple.TextEncoding	   15
-rw-r--r--@ 1 mattt  staff   5147 Dec  3 05:04 NSFixie.m
-rw-r--r--@ 1 mattt  staff   1438 Dec 18 14:31 Podfile
	com.macromates.selectionRange	     4
	com.macromates.visibleIndex	     1
~~~

- Finder stores 32 bytes of information in `.DS_Store`, though for reasons that aren't entirely clear.
- Xcode takes 15 bytes to denote the TextEncoding to use for a particular file.
- TextMate uses extended attributes to preserve the cursor position between launches.

The extended attributes API, declared in `<sys/xattr.h>`, has functions for getting, setting, listing, and removing attributes:

~~~{objective-c}
ssize_t getxattr(const char *path, const char *name, void *value, size_t size, u_int32_t position, int options);
int setxattr(const char *path, const char *name, void *value, size_t size, u_int32_t position, int options);
ssize_t listxattr(const char *path, char *namebuf, size_t size, int options);
int removexattr(const char *path, const char *name, int options);
~~~

To show these in action, consider the use of extended attributes to associate an [HTTP Etag](http://en.wikipedia.org/wiki/HTTP_ETag) with a file:

~~~{objective-c}
NSHTTPURLResponse *response = ...;
NSURL *fileURL = ...;

const char *filePath = [fileURL fileSystemRepresentation];
const char *name = "com.Example.Etag";
const char *value = [[response allHeaderFields][@"Etag"] UTF8String];
int result = setxattr(filePath, name, value, strlen(value), 0, 0);
~~~

As another example, previous to iOS 5.0.1, EAs were the designated way to denote that a particular file should not be synchronized with iCloud (as of iOS 5.1, `NSURL -setResourceValue:forKey:error:` is used, which sets the `com.apple.metadata:com_apple_backup_excludeItem` EA instead):

~~~{objective-c}
#include <sys/xattr.h>

if (!&NSURLIsExcludedFromBackupKey) {
    // iOS <= 5.0.1
    const char *filePath = [[URL path] fileSystemRepresentation];
    const char *name = "com.apple.MobileBackup";
    u_int8_t value = 1;
    int result = setxattr(filePath, name, &value, sizeof(value), 0, 0);
} else {
    // iOS >= 5.1
    NSError *error = nil;
    [URL setResourceValue:@YES
                   forKey:NSURLIsExcludedFromBackupKey
                    error:&error];
}
~~~

Lest extended attributes veer dangerously close to "being a hammer that makes everything look like a nail", let it be made clear: **extended attributes should not be used for critical data**. Not all volume formats support extended attributes, so copying between, say, HFS+ and FAT32 may result in a loss of information. Also consider that nothing is stopping any application from deleting or overwriting extended attributes at any time.

For things like author, file history, window or cursor position, and networking metadata, extended attributes are a great choice. If you've been struggling to synchronize file state, it may be exactly the solution you've been looking for. Just be mindful about EAs' limitations and understand why they would or would not be appropriate for a particular use case.

* * *

Between domestic wiretapping, the botched launch of [healthcare.gov](https://www.healthcare.gov), various stories of retailers leaking customer information, and untold volumes of snark on social networks, our culture has taken a profound shift in its relationship to computers. The average person is more technically savvy, but also harbors a newfound suspicion and mistrust of technology.

Knowing the relationship between data, metadata, and the entities that interact with both offer the best chance at understanding and adapting to whatever the future holds. As programmers, we are the arbiters of digital reality for ourselves and others; it is our responsibility to act in good faith and good conscience. Taking this responsibility seriously is more important than ever before. However this manifests itself in your occupation, take care in what you do.
