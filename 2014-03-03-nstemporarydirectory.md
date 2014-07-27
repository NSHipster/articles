---
layout: post
title: "NSTemporaryDirectory /<br/>NSItemReplacementDirectory /<br/>mktemp(3)"
category: Cocoa
description: "外存被用于写入可持续化保存的数据，但当数据生命周期很短时，用Objective-C操作临时文件的资料却很少（可能有，不过这些资料本身也是“临时”的）。"
author: Mattt Thompson
translator: "Croath Liu"
---

外存被用于写入可持续化保存的数据，但当数据生命周期很短时，用Objective-C操作临时文件的资料却很少（可能有，不过这些资料本身也是“临时”的）。

* * *

临时文件的作用是在硬盘上简历buffer，既不会被原子化地转移到固定位置，也不会被某种合理的方式处理和销毁。需要找到文件系统上适当的位置、生成一个唯一的名字、再用完之后移动或删除文件的构思，才能去建立临时文件。

## 寻找依赖目录

建立临时文件（或目录）的第一步就是找到适当的不碍事的地方去写这些文件，而且这个地方也不会被Time Machine或iCloud之类的东西同步。

实际上，在Unix系统中， `/tmp` 目录是最佳选择了。但现如今的iOS和Max OS X应用都有了自己的沙箱容器，所以最好还是不要用hard-code的路径了。

`NSTemporaryDirectory` 是Foundation框架中的函数，这个函数会返回一个中相关系统上为写入临时文件而设计的目录。

### 一场徒劳

近些年Apple把文件系统从那些调用 `NSString` 的地址的API中解放出来了，开发者改为用 `NSURL` 以及其上的API操作 `NSFileManager` 等类去解决这些问题。但这个解放并不是完全顺利的。

先看一看 `NSTemporaryDirectory` 的文档：

> 请查看 `NSFileManager` 的 `URLForDirectory:inDomain:appropriateForURL:create:error:` 方法来作为寻找临时目录的首选方法。

好吧，那看看`NSFileManager -URLForDirectory:inDomain:appropriateForURL:create:error:`方法里有什么：

> 你可以用这个方法去建立临时文件目录去存储类似自动保存的文件等。依此方法建立临时目录时用  `NSItemReplacementDirectory` 作为 `directory` 参数、 `NSUserDomainMask` 作为 `domain `参数、用一个合法的父级目录作为 `url` 参数传入。建立完成后，这个方法会返回该目录的URL。

这啥？读了好几遍我也没清楚怎么用。在邮件列表里找到[别人也](http://lists.apple.com/archives/cocoa-dev/2012/Apr/msg00117.html)遇到了同样的[疑惑](http://lists.apple.com/archives/cocoa-dev/2012/Feb/msg00186.html)。

_实际上_，这个方法似乎是为配合 `-replaceItemAtURL:withItemAtURL:backupItemName:options:resultingItemURL:error:` 方法移动_现有_临时文件到硬盘上的固定位置而设计的，并不是我们要找的东西。

这些关于 `NSString` 文件系统的变革整合太多太多了，我们还是直接看一些有用的东西吧：

~~~{objective-c}
[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
~~~

## 生成唯一的目录名或文件名

找到了被（暂时）称作主目录的地方，下一步就是想办法去给临时文件命名。命名时除了文件名要唯一之外就没有什么好担心的事情了，这样做是为了不干预、也不被其他同名文件干扰。

生成唯一标示符的最佳办法是用 `NSProcessInfo` 的 `globallyUniqueString` 方法。

~~~{objective-c}
NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
~~~

这个方法会返回这种格式的字符串： `5BD255F4-CA55-4B82-A555-0F4BC5CA2AD6-479-0000018E14D059CC`

> 也有其他人建议直接调用系统的 `mktemp(3)` 命令去防止重名冲突。但是用 `NSProcessInfo -globallyUniqueString` 方法显然不像能产生冲突的样子。

还有个办法， `NSUUID` ([我们之前讨论过了](http://nshipster.com/uuid-udid-unique-identifier))也可以生成出可用的结果，但我不觉得你会做出_如此疯狂_的事情来。

~~~{objective-c}
[[NSUUID UUID] UUIDString]
~~~

这个方法会返回这种格式的字符串： `22361D15-E17B-4C48-AEA6-C73BBEA17011`

## 建立临时文件地址

用上述方法可以生成唯一标示符了，于是就能生成唯一名字的临时文件地址了：

~~~{objective-c}
NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"file.txt"];
NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
~~~

## 建立临时目录

当一个程序需要生成很多临时文件时，建立子目录是一个好办法，可以帮助你简单快速地删除文件。

建立临时目录也是同样的方法调用 `NSFileManager -createDirectoryAtURL:withIntermediateDirectories:attributes:error:` ：

~~~{objective-c}
NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
[[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
~~~

该目录的临时文件的地址要用 `URLByAppendingPathComponent:` 方法接上文件名：

~~~{objective-c}
NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
~~~

## 向临时文件中写入内容

除非向文件中写入了内容或更新闻的时间戳，否则文件不会被建立。

### NSData -writeToURL:options:error

Foundation库中有很多向硬盘写数据的方法，最直接的方法应该就是 `NSData -writeToURL:options:error` 了：

~~~{objective-c}
NSData *data = ...;
NSError *error = nil;
[data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
~~~

### NSOutputStream

更高级的API中比较常见的就是直接向数据流传入一个  `NSOutputStream`  实例。同样的，通过建立输出流来向临时文件地址写入和其他写入方法没什么两样：

~~~{objective-c}
NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:[fileURL absoluteString] append:NO];
~~~

### 清除

最后一步就是让临时文件真正达到它_临时_的意义：清除。

虽然临时文件系统设计上没有说明临时文件在被系统自动删除前可以存在多久（至少最近没听到有人说过），但是你自己去管理好它是个很好的习惯。

用 `NSFileManager -removeItemAtURL:` 方法去删除临时文件或目录：

~~~{objective-c}
NSError *error = nil;
[[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
~~~

* * *

“一切都会过去的！”这句谚语的意思就是所有的一切都是临时性的。在应用生命周期的上下文里，一些东西比其他的令具有临时性，所以我们应该为它们找到一个合理合适的地方去存放、保证唯一性、用过后不留痕迹。

或许我们可以从这个小小的应用生命周期中，学到一些关于我们短暂而灿烂的生命的意义。
