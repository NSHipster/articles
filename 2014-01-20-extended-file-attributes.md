---
title: Extended File Attributes
author: Mattt Thompson
category: Objective-C
excerpt: "Amidst revelations of widespread spying by the NSA, the concept of metadata has taken an unexpected role in the national conversation about government surveillance. What is it? And how much does it reveal about us and our daily habits? These are questions that the American people are asking, and they deserve an answer."
translator: April Peng
excerpt: "在 NSA 披露的间谍活动中，元数据的概念在举国讨论的政府监控中担当了意想不到的角色。它是什么？它揭示了多少我们的信息和我们的日常习惯？这些是美国人民都在问的问题，他们需要一个答案。"
---

Amidst revelations of widespread spying by the NSA, the concept of metadata has taken an unexpected role in the national conversation about government surveillance. What is it? And how much does it reveal about us and our daily habits? These are questions that the American people are asking, and they deserve an answer.

在 NSA 披露的间谍活动中，元数据的概念在举国讨论的政府监控中担当了意想不到的角色。它是什么？它揭示了多少我们的信息和我们的日常习惯？这些是美国人民都在问的问题，他们需要一个答案。

Acting with a sense of civic and patriotic duty rivaled only by Uncle Sam walloping Communism with a bald eagle, NSHipster aims to shed as much light on metadata as Edward Snowden with an industrial lantern.

以只有山姆大叔以美国大败共产主义才能媲美的公民和爱国责任感，NSHipster 旨在尽可能多的摆脱像 爱德华·斯诺登 一样照向元数据的灯光。

* * *

For every file on a UNIX filesystem, there is associated metadata. Indeed, having a path, permissions, and timestamp attributes is what makes a file a file, rather than just a blob of data.

在 UNIX 文件系统中的每个文件，都有关联的元数据。事实上，一个路径，权限和时间戳是使一个文件之所以成为文件的属性，而不只是一个数据点。

However, on OS X and iOS, additional metadata can be stored in [**extended file attributes**](http://en.wikipedia.org/wiki/Extended_file_attributes). Introduced in OS X Tiger, they are perfect for associating small, application-specific data with a file. EAs are stored in the attributes B*-Tree of the HFS+ filesystem, and have a maximum size of 128KB as of OS X Lion & iOS 5.

但是，在 OS X 和 iOS，额外的元数据可以存储在[**扩展文件属性**](http://en.wikipedia.org/wiki/Extended_file_attributes)中。这是在 OS X Tiger 中被引入的，把那些少量的，应用程序特定的数据关联到一个文件来说是完美的解决办法。EAs 存储在 HFS+ 文件系统的 B*-Tree 中，并在OS X Lion 和 iOS 5 中有最大 128KB 的容量。

What kind of information, you ask? Invoke the `ls` command in the terminal and pass the `@` option to see what information hides in plain sight.

你问这是什么样的信息？在终端调用 `ls` 命令，并通过 `@` 选项来查看在众目睽睽下隐藏了什么样的信息。

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

- Finder 存储了 32 个字节的信息在 `.DS_Store`，但其原因尚不完全清楚。
- Xcode 中需要 15 个字节为一个特定的文件表示 TextEncoding 。
- TextMate 用扩展属性保留启动时的光标位置。

The extended attributes API, declared in `<sys/xattr.h>`, has functions for getting, setting, listing, and removing attributes:

扩展属性 API 声明在 `<sys/xattr.h>`，有获取，设置，列出和删除属性的功能：

~~~{objective-c}
ssize_t getxattr(const char *path, const char *name, void *value, size_t size, u_int32_t position, int options);
int setxattr(const char *path, const char *name, void *value, size_t size, u_int32_t position, int options);
ssize_t listxattr(const char *path, char *namebuf, size_t size, int options);
int removexattr(const char *path, const char *name, int options);
~~~

To show these in action, consider the use of extended attributes to associate an [HTTP Etag](http://en.wikipedia.org/wiki/HTTP_ETag) with a file:

为了显示这些功能，我们来假设使用扩展属性把一个 [HTTP Etag](http://en.wikipedia.org/wiki/HTTP_ETag) 与一个文件相关联：

~~~{objective-c}
NSHTTPURLResponse *response = ...;
NSURL *fileURL = ...;

const char *filePath = [fileURL fileSystemRepresentation];
const char *name = "com.Example.Etag";
const char *value = [[response allHeaderFields][@"Etag"] UTF8String];
int result = setxattr(filePath, name, value, strlen(value), 0, 0);
~~~

As another example, previous to iOS 5.0.1, EAs were the designated way to denote that a particular file should not be synchronized with iCloud (as of iOS 5.1, `NSURL -setResourceValue:forKey:error:` is used, which sets the `com.apple.metadata:com_apple_backup_excludeItem` EA instead):

举另一个 iOS 5.0.1 的例子，EAs 是设计来表示一个不应该被 iCloud  同步的特定文件（如 iOS 5.1 中，如果使用 `NSURL -setResourceValue:forKey:error:`，它将设置 `com.apple.metadata:com_apple_backup_excludeItem` 的 EA）：

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

为了避免扩展属性变成与 “对一把锤子来说，一切看起来都像钉子” 接近的结果，我们需要清楚的是：**扩展属性不应该被用于关键数据**。并非所有卷格式支持扩展属性，也就是说，HFS+ 和 FAT32 之间的复制可能导致信息丢失。同时也需要清楚，没有什么能阻止任何应用程序在任何时候删除或覆盖扩展属性。

For things like author, file history, window or cursor position, and networking metadata, extended attributes are a great choice. If you've been struggling to synchronize file state, it may be exactly the solution you've been looking for. Just be mindful about EAs' limitations and understand why they would or would not be appropriate for a particular use case.

对于像作者，文件历史记录，窗口或光标位置，或者网络的元数据，扩展属性是一个不错的选择。如果你一直在努力同步文件的状态，这可能正是你一直在寻找的解决方案。只是要留意有关 EAs 的局限和理解他们为什么会或不会适用特定的用例。

* * *

Between domestic wiretapping, the botched launch of [healthcare.gov](https://www.healthcare.gov), various stories of retailers leaking customer information, and untold volumes of snark on social networks, our culture has taken a profound shift in its relationship to computers. The average person is more technically savvy, but also harbors a newfound suspicion and mistrust of technology.

国内的窃听门，拙劣推出的 [healthcare.gov](https://www.healthcare.gov)，零售商泄露客户信息，以及社交网络上的数不清的故事，都不难看出我们的文化已经将它的关系转移到计算机上。现在的人更精通技术，同时也隐藏了新发现的怀疑和技术的不信任。

Knowing the relationship between data, metadata, and the entities that interact with both offer the best chance at understanding and adapting to whatever the future holds. As programmers, we are the arbiters of digital reality for ourselves and others; it is our responsibility to act in good faith and good conscience. Taking this responsibility seriously is more important than ever before. However this manifests itself in your occupation, take care in what you do.

知道了数据，元数据，以及与这两个交互的实体之间的关系，就可以很好地理解和适应未来。作为程序员，我们是自己和他人数字化现实的捍卫者；真诚并凭良心办事是我们的责任。认真对待这一责任比以往任何时候都更加重要。然而，体现在你的职业里的就是，做好你在做的。
