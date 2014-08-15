---
layout: post
title: NSFileManager
translator: "Lin Xiangyu"
category: Cocoa
rating: 7.9
description: "文件系统是一个复杂的主题，它有数十年的历史，一些遗留下的复杂性和一些特别的地方，已经不是一篇文章就可以描述的了。现在大多数的应用除了简单的文件操作之外不会经常与文件系统交互，所以有时候简单了解它的基础就行了。"
---


`NSFileManager` 是处理文件系统的 Foundation 框架的高级API。它抽象了 Unix 和 Finder 的内部构成，和 iCloud ubiquitous containers 一样， 提供了创建，读取，移动，拷贝以及删除本地或者网络驱动器上的文件或者目录的方法。

文件系统是一个复杂的主题，它有数十年的历史，一些遗留下的复杂性和一些特别的地方，已经不是一篇文章就可以描述的了。现在大多数的应用除了简单的文件操作之外不会经常与文件系统交互，所以有时候简单了解它的基础就行了。

你可以复制粘贴下面的代码试试看，用他们作为你的代码基础，修改这些参数来达到你期望的效果。

## 常用操作

 纵观苹果提供的样例代码，尽是这样的黑魔法： `NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)` ， 它或许绑定了KVO，也是Cocoa最糟糕的API之一。你只需要知道它返回了一个包含用户文档目录作为第一个元素的数组就行了。真要感谢 `NSArray -firstObject`。

## 确定文件是否存在

~~~{objective-c}

NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *filePath = [documentsPath stringByAppendingPathComponent:@"file.txt"];
BOOL fileExists = [fileManager fileExistsAtPath:filePath];

~~~

## 列出文件里面的所有目录

~~~{objective-c}

NSFileManager *fileManager = [NSFileManager defaultManager];
NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                               includingPropertiesForKeys:@[]
                                                  options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    error:nil];

NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'png'"];
for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate]) {
    // 在目录中枚举 .png 文件
}

~~~


### 在目录中递归地遍历文件


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

### 创建一个目录

~~~{objective-c}

NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *imagesPath = [documentsPath stringByAppendingPathComponent:@"images"];
if (![fileManager fileExistsAtPath:imagesPath]) {
    [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil];
}］

~~~
### 删除一个目录
~~~{objective-c}


NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
NSString *filePath = [documentsPath stringByAppendingPathComponent:@"image.png"];
NSError *error = nil;

if (![fileManager removeItemAtPath:filePath error:&error]) {
    NSLog(@"[Error] %@ (%@)", error, filePath);
}
~~~
### 删除文件的创建日期

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

通过NSFileManager的 `-attributesOfItemAtPath:error:` 和其它方法可以访问很多文件的属性

#### 文件属性的键

> - `NSFileAppendOnly`: 文件是否只读
> - `NSFileBusy`: 文件是否繁忙
> - `NSFileCreationDate`: 文件创建日期
> - `NSFileOwnerAccountName`:  文件所有者的名字
> - `NSFileGroupOwnerAccountName`: 文件所有组的名字
> - `NSFileDeviceIdentifier`: 文件所在驱动器的标示符
> - `NSFileExtensionHidden`:  文件后缀是否隐藏
> - `NSFileGroupOwnerAccountID`:  文件所有组的group ID
> - `NSFileHFSCreatorCode`: 文件的HFS创建者的代码
> - `NSFileHFSTypeCode`: 文件的HFS类型代码
> - `NSFileImmutable`: 文件是否可以改变
> - `NSFileModificationDate`:  文件修改日期
> - `NSFileOwnerAccountID`: 文件所有者的ID
> - `NSFilePosixPermissions`: 文件的Posix权限
> - `NSFileReferenceCount`: 文件的链接数量
> - `NSFileSize`: 文件的字节
> - `NSFileSystemFileNumber`:  文件在文件系统的文件数量
> - `NSFileType`: 文件类型
> - `NSDirectoryEnumerationSkipsSubdirectoryDescendants`: 浅层的枚举，不会枚举子目录
> - `NSDirectoryEnumerationSkipsPackageDescendants`: 不会扫描pakages的内容
> - `NSDirectoryEnumerationSkipsHiddenFile`: 不会扫描隐藏文件



## NSFileManagerDelegate

NSFileManager 可以设置一个  `<NSFileManagerDelegate>` protocol 来确认是否要进行特定的文件操作。它允许进行一些业务逻辑，比如保护一些文件删除，在 Controller 中删除一些元素

`NSFileManagerDelegate`里面有四个方法，每个按照path变化

- `-fileManager:shouldMoveItemAtURL:toURL:`
- `-fileManager:shouldCopyItemAtURL:toURL:`
- `-fileManager:shouldRemoveItemAtURL:`
- `-fileManager:shouldLinkItemAtURL:toURL:`

如果你想用 `alloc init` 初始化你自己的 `NSFileManager` 来取代shared实例，那就要用它了，就像文档说的

> 如果你使用一个delegate 来接受移动，拷贝，涉案出，以及链接的操作，你需要创建一个独一无二的实例，将delegate绑定到你的实例中，用这个fielmanager开始你的操作

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


文档也可与放到iCloud里面。如果你猜可以直截了当的进行操作，恭喜你猜对了。

这里有一个其它用到 `alloc init` 的地方，因为 `URLForUbiquityContainerIdentifier: and setUbiquitous:itemAtURL:destinationURL:error:` 是代码块调用，所以整个操作需要在后台队列分发

### 将文件放到iCloud里面

~~~{objective-c}


dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *fileURL = [NSURL fileURLWithPath:[documentsPath stringByAppendingPathComponent:@"Document.pages"]];

    //这里的 identifier 应该设置为 entitlements 的第一个元素；当你使用这段代码的时候需要把 identifier 设置为你自己的真实 identifier
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


> 你可以在苹果的 `iCloud File Management` 文档里面找到更多信息

* * *


关于文件系统需要知道很多东西，但大多数是理论测验层面的。别误会，这些理论测验并没有错！但理论并不能教你代码该怎么写。NSFileManager可以让你不用学习它们大多数的内容就能完成工作。