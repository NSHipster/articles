---
title: Inter-Process Communication
author: Mattt Thompson
category: ""
translator: Daniel Hu
tags: cfhipsterref
excerpt: "In many ways, the story of Apple has been about fusing together technologies through happy accidents of history to create something better than before: OS X as a hybrid of MacOS & NeXTSTEP. Objective-C as the combination of Smalltalk's OOP paradigm and C. iCloud as the byproduct of MobileMe and actual clouds (presumably)."
status:
    swift: t.b.c.
---

<img src="{{ site.asseturl }}/cfhipsterref-illustration-postman.png" width="151" height="300" alt="IPC Postman, illustrated by Conor Heelan" style="float: right; margin-left: 2em; margin-bottom: 2em"/>

由于历史的机缘巧合，苹果通过技术的结合创造出了很多优秀的产品： OS X 是 MacOS 和 NeXTSTEP 的结合，Objective-C 是 Smalltalk 的面向对象语法和 C 的结合，iCloud 是 MobileMe 和 _actual_ clonds 的结合。

尽管苹果通过这种完美的结合丰富了自己的技术栈，但进程间通信却是一个典型的反面例子。

苹果并没有直接采用最好的可行方案，而是有点堆砌解决方案的意思。这造成了苹果采用的多种进程间通信方案之间无法兼容，分散的堆砌在抽象层。尽管 OS X 支持了所有的进程间通信方案，但在 iOS 上仅支持 Grand Central Dispatch 和 剪贴板。

- Mach Ports
- Distributed Notifications
- Distributed Objects
- AppleEvents & AppleScript
- Pasteboard
- XPC

上面的方案从抽象的底层内核接口过度到高级的面向对象的接口，这些方案都有自己的性能和安全特性。无一例外的是这几种进程间通信技术背后的原理都是全局的上下文来发送接收数据。

## Mach Ports

所有的进程间通信方案最终都是基于操作系统提供的很底层的内核接口 Mach ports。

虽然 Mach ports 是操作系统提供的轻量级功能强大的内核接口，但苦于该接口的文档有限。

向端口发送消息只需要调用方法 'mach_msg_send' 即可，在发送消息前还需要做如下配置来生成待发送的消息：

~~~{objective-c}
natural_t data;
mach_port_t port;

struct {
    mach_msg_header_t header;
    mach_msg_body_t body;
    mach_msg_type_descriptor_t type;
} message;

message.header = (mach_msg_header_t) {
    .msgh_remote_port = port,
    .msgh_local_port = MACH_PORT_NULL,
    .msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0),
    .msgh_size = sizeof(message)
};

message.body = (mach_msg_body_t) {
    .msgh_descriptor_count = 1
};

message.type = (mach_msg_type_descriptor_t) {
    .pad1 = data,
    .pad2 = sizeof(data)
};

mach_msg_return_t error = mach_msg_send(&message.header);

if (error == MACH_MSG_SUCCESS) {
    // ...
}
~~~

接受消息就更简单了，接受方只需要声明好待接受的消息甚至都不用初始化就可以了：

~~~{objective-c}
mach_port_t port;

struct {
    mach_msg_header_t header;
    mach_msg_body_t body;
    mach_msg_type_descriptor_t type;
    mach_msg_trailer_t trailer;
} message;

mach_msg_return_t error = mach_msg_receive(&message.header);

if (error == MACH_MSG_SUCCESS) {
    natural_t data = message.type.pad1;
    // ...
}
~~~

幸运的是 Core Foundation 和 Foundation 两个框架对 Mach ports 进行了封装，提供了更高级的接口。
`CFMachPort` / `NSMachPort` 是对内核接口的封装可用于 NSRunLoop 来监听来自端口的消息，同时 `CFMessagePort` / `NSMessagePort` 可用于两个端口间的异步通信。

`CFMessagePort` 是一个很好的端对端通信方案。只需要简单的几行代码就可以为一个端口设置一个回调方法并让该端口作为 NSRunLoop 的消息源，当 NSRunLoop 接受到来自该端口的消息时便会执行为该端口设置的回调：

~~~{objective-c}
static CFDataRef Callback(CFMessagePortRef port,
                          SInt32 messageID,
                          CFDataRef data,
                          void *info)
{
    // ...
}

CFMessagePortRef localPort =
    CFMessagePortCreateLocal(nil,
                             CFSTR("com.example.app.port.server"),
                             Callback,
                             nil,
                             nil);

CFRunLoopSourceRef runLoopSource =
    CFMessagePortCreateRunLoopSource(nil, localPort, 0);

CFRunLoopAddSource(CFRunLoopGetCurrent(),
                   runLoopSource,
                   kCFRunLoopCommonModes);
~~~

发送数据很简单，只需要声明好远程端口，封装好待发送的消息，设置好发送接收的超时时间即可。剩下的工作由 `CFMessagePortSendRequest` 完成：

~~~{objective-c}
CFDataRef data;
SInt32 messageID = 0x1111; // Arbitrary
CFTimeInterval timeout = 10.0;

CFMessagePortRef remotePort =
    CFMessagePortCreateRemote(nil,
                              CFSTR("com.example.app.port.client"));

SInt32 status =
    CFMessagePortSendRequest(remotePort,
                             messageID,
                             data,
                             timeout,
                             timeout,
                             NULL,
                             NULL);
if (status == kCFMessagePortSuccess) {
    // ...
}
~~~

## Distributed Notifications

在 Cocoa 框架中有多种方式可用于对象间通信：

直接发送消息是一种。当然也可以使用 target-action, delegate, 和回调这些低耦合，一对一的通信方案。KVO 允许多个对象监听同一个事件，但这样造成了这些对象间产生了耦合。通知是另一种可以广播并且可以让任何想要监听的对象接收到消息的方式。

每个应用程序都维护了自己的通知中心用于发送接收通知。但这有一个很少被人熟知的 Core Foundation 接口 `CFNotificationCenterGetDistributedCenter`，该接口系统级的进程间通信。

为了监听通知，需要向通知中心添加一个申明了名字和回调函数指针的通知：

~~~{objective-c}
static void Callback(CFNotificationCenterRef center,
                     void *observer,
                     CFStringRef name,
                     const void *object,
                     CFDictionaryRef userInfo)
{
    // ...
}

CFNotificationCenterRef distributedCenter =
    CFNotificationCenterGetDistributedCenter();

CFNotificationSuspensionBehavior behavior =
        CFNotificationSuspensionBehaviorDeliverImmediately;

CFNotificationCenterAddObserver(distributedCenter,
                                NULL,
                                Callback,
                                CFSTR("notification.identifier"),
                                NULL,
                                behavior);
~~~

发送通知同样简单，只需要指定待发送的通知的标识符，附着于该通知的消息和用户信息即可：

~~~{objective-c}
void *object;
CFDictionaryRef userInfo;

CFNotificationCenterRef distributedCenter =
    CFNotificationCenterGetDistributedCenter();

CFNotificationCenterPostNotification(distributedCenter,
                                     CFSTR("notification.identifier"),
                                     object,
                                     userInfo,
                                     true);
~~~

在所有的应用程序间通信的方案中，发送通知是目前为止最简单的方式，其可以很好的胜任一些简单的工作如同步偏好设置或者触发数据的拉取，但不建议使用通知发送大量的数据。

## Distributed Objects 

Distributed Objects (DO) 是 Cocoa 的一种远程消息特性，其在90年代中期的 NeXT 系统中达到鼎盛。这种方式以及被很少使用了，但设计出精巧的进程间通信方案的梦想至今仍未实现。

使用 DO 发送对象只需要对 `NSConnection` 进行一系列设置并注册一个名字即可：

~~~{objective-c}
@protocol Protocol;

id <Protocol> vendedObject;

NSConnection *connection = [[NSConnection alloc] init];
[connection setRootObject:vendedObject];
[connection registerName:@"server"];
~~~



