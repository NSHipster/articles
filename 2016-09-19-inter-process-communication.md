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

~~~{objective-c}
id proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"server" host:nil];
[proxy setProtocolForProxy:@protocol(Protocol)];
~~~

- `in`: Argument is used as input, but not referenced later
- `out`: Argument is used to return a value by reference
- `inout`: Argument is used as input and returned by reference
- `const`: Argument is constant
- `oneway`: Return without blocking for result
- `bycopy`: Return a copy of the object
- `byref`: Return a proxy of the object

## AppleEvents & AppleScript

AppleEvents 是经典的麦金塔操作系统中最重要的遗产。AppleEvents 在 System 7 中被引入，其允许在本地使用 AppleScript 或者远程使用叫 Program Linking 的特性来控制应用。到现在，使用 Cocoa Scripting Bridge 的 AppleScript 仍然是 OS X 上与应用交互最直接的方式。

AppleEvents 和 AppleScript 很容易成为最奇怪的技术之一。

AppleScript 使用更自然的语法，这对于没有非编程人员更容易接受。尽管 AppleScript 在易阅读方面取得了成功，但其书写起来却十分痛苦。

为了更好的理解其语法很自然的表达方式，下面给出一个在窗口活跃界面中使用 Safari 打开 URL 的例子：

~~~{Applescript}
tell application "Safari"
  set the URL of the front document to "http://nshipster.com"
end tell
~~~

AppleScript 自然的语法很多时候却成为了一种负担。英语和其他人类语言一样，通常在表达中会存在很多冗余。语言中的冗余对于人类来讲很容易接受，但对于计算机来说却是很困难的一件事。

幸好 Scripting Bridge 为 Cocoa 应用程序提供了较好的编程接口。

### Cocoa Scripting Bridge

为了使用 Scripting Bridge 和应用程序交互，首先需要生成一个编程接口：

~~~
$ sdef /Applications/Safari.app | sdp -fh --basename Safari
~~~

`sdef` 为应用生成了脚本定义。这些脚本文件通过管道(译注：管道是类 Unix 系统中的一种进程间通信的方式)发送到 `sdp` 然后被转换为 C 头文件。转换后的头文件被添加导入到项目中，这样项目就获得了与该脚本对应的应用的交互接口。

下面用 Cocoa Scripting Bridge 重写了上面的例子：

~~~{objective-c}
#import "Safari.h"

SafariApplication *safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];

for (SafariWindow *window in safari.windows) {
    if (window.visible) {
        window.currentTab.URL = [NSURL URLWithString:@"http://nshipster.com"];
        break;
    }
}
~~~

这比 AppleScript 稍微复杂些，但却更容易集成到现有的代码中。

## Pasteboard

剪贴板是 OS X 和 iOS 上最直观的进程间通信方式。用户在 mach 端口上进行的两个应用间的文本，图片，文档的复制粘贴操作是通过 `com.apple.pboard` 服务进程完成的。

在 OS X 上使用 `NSPasteboard` 来完成复制粘贴操作，而 iOS 上使用 `UIPasteboard`。这两个类基本一样，但是如同两个平台上的其他类，iOS 相对 OS X 来说总是提供更简洁更现代化的接口。

编程实现复制粘贴功能和在应用程序用户界面中点击 `编辑 > 拷贝` 一样简单：

~~~{objective-c}
NSImage *image;

NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
[pasteboard clearContents];
[pasteboard writeObjects:@[image]];
~~~

相比复制，粘贴要复杂些，其需要遍历整个粘贴板上的内容：

~~~{objective-c}
NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

if ([pasteboard canReadObjectForClasses:@[[NSImage class]] options:nil]) {
    NSArray *contents = [pasteboard readObjectsForClasses:@[[NSImage class]] options: nil];
    NSImage *image = [contents firstObject];
}
~~~

粘贴板作为传输数据的方式最吸引人的地方在于其对拷贝的数据的多种呈现方式。例如，对文本的拷贝可以同时当做富文本 (RTF) 和纯文本 (TXT)，即允许 WYSIWYG 编辑器呈现出富文本的样式，同事允许代码编辑器以纯文本的方式呈现出来。

这些呈现形式可以通过遵循 `NSPasteboardItemDataProvider` 协议来实现。遵循该协议后允许衍生出来的数据呈现形式，比如允许富文本在必要的时候可以转换为纯文本。

每种呈现形式都由唯一类型标识符 Unique Type Identifier (UTI) 表示，这个概念将在下一章中进行讨论。

## XPC

SDKs 中的 XPC 是进程间通信的中最先进的。其架构目的是为了避免进程长时间运行，自适应可用的系统资源，延迟对象的初始化。把 XPC 集成到应用中可以为进程间通信提供很好的错误隔离。

XPC 可以做为 `NSTask` 的替换方案。

XPC 在2011年引入系统中为 OS X 带来了沙盒机制，为 iOS 带来了远程视图控制机制和应用扩展。其已被广泛应用在了系统框架和系统应用中：

~~~{bash}
$ find /Applications -name \*.xpc
~~~

通过对集成了 XPC 服务应用的统计，你可以对何时在自己的应用中集成 XPC 有更好的理解。例如应用中常用的图片视频转换服务，系统函数调用，web 服务和第三方的验证服务这些情况下都可以集成 XPC.

XPC 负责对进程间通信和系统服务的生命周期进行管理。注册服务，开启服务，和其他服务进行通信都是由 `launchd` (译注：可看做 daemon 守护进程)进行管理。XPC 服务可以按需启动或在崩溃后重新启动服务也可以在闲置时关闭该服务。因此，为了允许在执行过程中可以随时终止服务，服务应该被设计为无状态形式。

由于 iOS 和 OS X 采用新的安全策略，默认情况下 XPC 服务是在及其严格的环境中运行：无文件系统访问权限，无网络访问权限，无 root 权限。应用所具有的访问权限都需要加入一个白名单文件中。

可以通过 `libxpc` 的 C 接口或者 `NSXPCConnection` 的 Objective-C 接口使用 XPC 服务。XPC 服务可以在应用的 bundle 或者使用 launchd 在后台中执行。

下面给出设置回调方法然后调用 `xpc_main` 接受 XPC 连接的例子：

~~~{objective-c}
static void connection_handler(xpc_connection_t peer) {
    xpc_connection_set_event_handler(peer, ^(xpc_object_t event) {
        peer_event_handler(peer, event);
    });

    xpc_connection_resume(peer);
}

int main(int argc, const char *argv[]) {
   xpc_main(connection_handler);
   exit(EXIT_FAILURE);
}
~~~

当消息通过 XPC 服务发送后，该消息在运行时被自动分发到操作队列中进行管理。当远端的连接建立后，该消息从消息队列中弹出并发送至远端。

~~~{objective-c}
xpc_connection_t c = xpc_connection_create("com.example.service", NULL);
xpc_connection_set_event_handler(c, ^(xpc_object_t event) {
    // ...
});
xpc_connection_resume(c);
~~~

~~~{objective-c}
xpc_dictionary_t message = xpc_dictionary_create(NULL, NULL, 0);
xpc_dictionary_set_uint64(message, "foo", 1);
xpc_connection_send_message(c, message);
xpc_release(message)
~~~

XPC 对象有以下的操作优先级：

- Data
- Boolean
- Double
- String
- Signed Integer
- Unsigned Integer
- Date
- UUID
- Array
- Dictionary
- Null

XPC 提供很简便的方式来转换 `dispatch_data_t` 类型的数据：

~~~{objective-c}
void *buffer;
size_t length;
dispatch_data_t ddata =
    dispatch_data_create(buffer,
                         length,
                         DISPATCH_TARGET_QUEUE_DEFAULT,
                         DISPATCH_DATA_DESTRUCTOR_MUNMAP);

xpc_object_t xdata = xpc_data_create_with_dispatch_data(ddata);
~~~

~~~{objective-c}
dispatch_queue_t queue;
xpc_connection_send_message_with_reply(c, message, queue,
    ^(xpc_object_t reply)
{
      if (xpc_get_type(event) == XPC_TYPE_DICTIONARY) {
         // ...
      }
});
~~~

### Registering Services

XPC 也可以配置为监听到 IOKit 事件，BSD(译注：一种 Unix 发型版本) 通知或者 CFDistributedNotifications 时自动启动，并注册为 launchd 任务 (译注：开机启动的常驻系统服务)。这些功能可咋系统服务文件 ` launchd.plist` 进行配置：

~~~{xml}
<key>LaunchEvents</key>
<dict>
  <key>com.apple.iokit.matching</key>
  <dict>
      <key>com.example.device-attach</key>
      <dict>
          <key>idProduct</key>
          <integer>2794</integer>
          <key>idVendor</key>
          <integer>725</integer>
          <key>IOProviderClass</key>
          <string>IOUSBDevice</string>
          <key>IOMatchLaunchStream</key>
          <true/>
          <key>ProcessType</key>
          <string>Adaptive</string>
      </dict>
  </dict>
</dict>
~~~

最近 `launchd.plist` 文件中新增了一个描述启动代理目的的键 `ProcessType`。基于设定的键值，操作系统可以自适应的使用的 CPU 和 I/O 宽带。

#### Process Types and Contention Behavior

| Process Type | Contention Behavior                               |
|--------------|---------------------------------------------------|
| Standard     | Default value                                     |
| Adaptive     | Contend with apps when doing work on their behalf |
| Background   | Never contend with apps                           |
| Interactive  | Always contend with apps                          |

为了注册一个每 5 分钟运行一次的服务,需要在 `xpc_activity_register` 进行如下设置：

~~~{objective-c}
xpc_object_t criteria = xpc_dictionary_create(NULL, NULL, 0);
xpc_dictionary_set_int64(criteria, XPC_ACTIVITY_INTERVAL, 5 * 60);
xpc_dictionary_set_int64(criteria, XPC_ACTIVITY_GRACE_PERIOD, 10 * 60);

xpc_activity_register("com.example.app.activity",
                      criteria,
                      ^(xpc_activity_t activity)
{
    // Process Data

    xpc_activity_set_state(activity, XPC_ACTIVITY_STATE_CONTINUE);

    dispatch_async(dispatch_get_main_queue(), ^{
        // Update UI

        xpc_activity_set_state(activity, XPC_ACTIVITY_STATE_DONE);
    });
});
~~~




