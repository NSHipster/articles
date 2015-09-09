---
title: Inter-Process Communication
author: Mattt Thompson
category: ""
tags: cfhipsterref
excerpt: "In many ways, the story of Apple has been about fusing together technologies through happy accidents of history to create something better than before: OS X as a hybrid of MacOS & NeXTSTEP. Objective-C as the combination of Smalltalk's OOP paradigm and C. iCloud as the byproduct of MobileMe and actual clouds (presumably)."
status:
    swift: t.b.c.
---

<img src="http://nshipster.s3.amazonaws.com/cfhipsterref-illustration-postman.png" width="151" height="300" alt="IPC Postman, illustrated by Conor Heelan" style="float: right; margin-left: 2em; margin-bottom: 2em"/>

In many ways, the story of Apple has been about fusing together technologies through happy accidents of history to create something better than before: OS X as a hybrid of MacOS & NeXTSTEP. Objective-C as the combination of Smalltalk's OOP paradigm and C. iCloud as the byproduct of MobileMe and _actual_ clouds (presumably).

While this is true for many aspects of Apple's technology stack, inter-process communication is a flagrant counter-example.

Rather than taking the best of what was available at each juncture, solutions just kinda piled up. As a result, a handful of overlapping, mutually-incompatible IPC technologies are scattered across various abstraction layers. Whereas all of these are available on OS X, only Grand Central Dispatch and Pasteboard (albeit to a lesser extent) can be used on iOS.[^1]

- Mach Ports
- Distributed Notifications
- Distributed Objects
- AppleEvents & AppleScript
- Pasteboard
- XPC

Ranging from low-level kernel abstractions to high-level, object-oriented APIs, they each have particular performance and security characteristics. But fundamentally, they're all mechanisms for transmitting and receiving data from beyond a context boundary.

## Mach Ports

All inter-process communication ultimately relies on functionality provided by Mach kernel APIs.

Mach ports are light-weight and powerful, but poorly documented

Sending a message over a given Mach port comes down to a single `mach_msg_send` call, but it takes a bit of configuration in order to build the message to be sent:

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

Things are a little easier on the receiving end, since the message only needs to be declared, not initialized:

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

Fortunately, higher-level APIs for Mach ports are provided by Core Foundation and Foundation. `CFMachPort` / `NSMachPort` are wrappers on top of the kernel APIs that can be used as a runloop source, while `CFMessagePort` / `NSMessagePort` facilitate synchronous communication between two ports.

`CFMessagePort` is actually quite nice for simple one-to-one communication. In just a few lines of code, a local named port can be attached as a runloop source to have a callback run each time a message is received:

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

Sending data is straightforward as well. Just specify the remote port, the message payload, and timeouts for sending and receiving. `CFMessagePortSendRequest` takes care of the rest:

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

##  Distributed Notifications

There are many ways for objects to communicate with one another in Cocoa:

There is, of course, sending a message directly. There are also the target-action, delegate, and callbacks, which are all loosely-coupled, one-to-one design patterns. KVO allows for multiple objects to subscribe to events, but it strongly couples those objects together. Notifications, on the other hand, allow messages to be broadcast globally, and intercepted by any object that knows what to listen for.

Each application manages its own `NSNotificationCenter` instance for infra-application pub-sub. But there is also a lesser-known Core Foundation API, `CFNotificationCenterGetDistributedCenter` that allows notifications to be communicated system-wide as well.

To listen for notifications, add an observer to the distributed notification center by specifying the notification name to listen for, and a function pointer to execute each time a notification is received:

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

Sending a distributed notification is even simpler; just post the identifier, object, and user info:

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

Of all of the ways to link up two applications, distributed notifications are by far the easiest. It wouldn't be a great idea to use them to send large payloads, but for simple tasks like synchronizing preferences or triggering a data fetch, distributed notifications are perfect.

##  Distributed Objects

Distributed Objects (DO) is a remote messaging feature of Cocoa that had its heyday back in the mid-90's with NeXT. And though its not widely used any more, the dream of totally frictionless IPC is still unrealized in our modern technology stack.

Vending an object with DO is just a matter of setting up an `NSConnection` and registering it with a particular name:

~~~{objective-c}
@protocol Protocol;

id <Protocol> vendedObject;

NSConnection *connection = [[NSConnection alloc] init];
[connection setRootObject:vendedObject];
[connection registerName:@"server"];
~~~

Another application would then create a connection registered for that same registered name, and immediately get an atomic proxy that functioned as if it were that original object:

~~~{objective-c}
id proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"server" host:nil];
[proxy setProtocolForProxy:@protocol(Protocol)];
~~~

Any time a distributed object proxy is messaged, a Remote Procedure Call (RPC) would be made over the `NSConnection` to evaluate the message against the vended object and return the result back to the proxy.

Distributed Objects are simple, transparent, and robust. And they would have been a flagpole feature of Cocoa had any of it worked as advertised.

In reality, Distributed Objects can't be used like local objects, if only because any message sent to a proxy could result in an exception being thrown. Unlike other languages, Objective-C doesn't use exceptions for control flow. As a result, wrapping everything in a `@try/@catch` is a poor fit to the conventions of Cocoa.

DO is awkward for other reasons, too. The divide between objects and primitives is especially pronounced when attempting to marshal values across a connection. Also, connections are totally unencrypted, and the lack of extensibility for the underlying communication channels makes it a deal-breaker for most serious usage.

All that's really left are traces of the annotations used by Distributed Objects to specify the proxying behavior of properties and method parameters:

- `in`: Argument is used as input, but not referenced later
- `out`: Argument is used to return a value by reference
- `inout`: Argument is used as input and returned by reference
- `const`: Argument is constant
- `oneway`: Return without blocking for result
- `bycopy`: Return a copy of the object
- `byref`: Return a proxy of the object

##  AppleEvents & AppleScript

AppleEvents are the most enduring legacies of the classic Macintosh operating system. Introduced in System 7, AppleEvents allowed apps to be controlled locally using AppleScript, or remotely using a feature called Program Linking. To this day, AppleScript, using the Cocoa Scripting Bridge, remains the most direct way to programmatically interact with OS X applications.

That said, it's easily one of the weirdest technologies to work with.

AppleScript uses a natural language syntax, intended to be more accessible to non-programmers. And while it does succeed in communicating intent in a human-understandable way, it's a nightmare to write.

To get a better sense of the nature of the beast, here's how to tell Safari to open a URL in the active tab in the frontmost window:

~~~{Applescript}
tell application "Safari"
  set the URL of the front document to "http://nshipster.com"
end tell
~~~

In many ways, AppleScript's natural language syntax is more of a liability than an asset. English, much like any other spoken language, has a great deal of redundancy and ambiguity built into normal constructions. While this is perfectly acceptable for humans, computers have a tough time resolving all of this.

Even for a seasoned Objective-C developer, it's nearly impossible to write AppleScript without constantly referencing documentation or sample code.

Fortunately, the Scripting Bridge provides a proper programming interface for Cocoa applications.

###  Cocoa Scripting Bridge

In order to interact with an application through the Scripting Bridge, a programming interface must first be generated:

~~~
$ sdef /Applications/Safari.app | sdp -fh --basename Safari
~~~

`sdef` generates scripting definition files for an application. These files can then be piped into `sdp` to be converted into another format—in this case, a C header. The resulting `.h` file can then be added and `#import`-ed into a project to get a first-class object interface to that application.

Here's the same example as before, expressed using the Cocoa Scripting Bridge:

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

It's a bit more verbose than AppleScript, but this is much easier to integrate into an existing codebase. It's also a lot clearer to understand how this same code could be adapted to slightly different behavior (though that could just be the effect of being more familiar with Objective-C).

Alas, AppleScript's star appears to be falling, as recent releases of OS X and iWork applications have greatly curtailed their scriptability. At this point, it's unlikely that adding support in your own applications will be worth it.

##  Pasteboard

Pasteboard is the most visible inter-process communication mechanism on OS X and iOS. Whenever a user copies or pastes a piece of text, an image, or a document between applications, an exchange of data from one process to another over mach ports is being mediated by the `com.apple.pboard` service.

On OS X there's `NSPasteboard`, and on iOS there's `UIPasteboard`. They're pretty much the same, although like most counterparts, iOS provides a cleaner, more modern set of APIs that are slightly less capable than what's found on OS X.

Programmatically writing to the Pasteboard is nearly as simple as invoking `Edit > Copy` in a GUI application:

~~~{objective-c}
NSImage *image;

NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
[pasteboard clearContents];
[pasteboard writeObjects:@[image]];
~~~

The reciprocal paste action is a bit more involved, requiring an iteration over the Pasteboard contents:

~~~{objective-c}
NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

if ([pasteboard canReadObjectForClasses:@[[NSImage class]] options:nil]) {
    NSArray *contents = [pasteboard readObjectsForClasses:@[[NSImage class]] options: nil];
    NSImage *image = [contents firstObject];
}
~~~

What makes Pasteboard especially compelling as a mechanism for transferring data is the notion of simultaneously providing multiple representations of content copied onto a pasteboard. For example, a selection of text may be copied as both rich text (RTF) and plain text (TXT), allowing, for example, a WYSIWYG editor to preserve style information by grabbing the rich text representation, and a code editor to use just the plain text representation.

These representations can even be provided on an on-demand basis by conforming to the `NSPasteboardItemDataProvider` protocol. This allows derivative representations, such as plain text from rich text, to be generated only as necessary.

Each representation is identified by a Unique Type Identifier (UTI), a concept discussed in greater detail in the next chapter.

##  XPC

XPC is the state-of-the-art for inter-process communication in the SDKs. Its architectural goals are to avoid long-running process, to adapt to the available resources, and to lazily initialize wherever possible. The motivation to incorporate XPC into an application is not to do things that are otherwise impossible, but to provide better privilege separation and fault isolation for inter-process communication.

It's a replacement for `NSTask`, and a whole lot more.

Introduced in 2011, XPC has provided the infrastructure for the App Sandbox on OS X, Remote View Controllers on iOS, and App Extensions on both. It is also widely used by system frameworks and first-party applications:

~~~{bash}
$ find /Applications -name \*.xpc
~~~

By surveying the inventory of XPC services in the wild, one can get a much better understanding of opportunities to use XPC in their own application. Common themes in applications emerge, like services for image and video conversion, system calls, webservice integration, and 3rd party authentication.

XPC takes responsibility for both inter-process communication and service lifecycle management. Everything from registering a service, getting it running, and communicating with other services is handled by `launchd`. An XPC service can be launched on demand, or restarted if they crash, or terminated if they idle. As such, services should be designed to be completely stateless, so as to allow for sudden termination at any point of execution.

As part of the new security model adopted by iOS and backported in OS X, XPC services are run with the most restricted environment possible by default: no file system access, no network access, and no root privilege escalation. Any capabilities must be whitelisted by a set of entitlements.

XPC can be accessed through either the `libxpc` C API, or the `NSXPCConnection` Objective-C API.

XPC services either reside within an application bundle or are advertised to run in the background using launchd.

Services call `xpc_main` with an event handler to receive new XPC connections:

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

Each XPC connection is one-to-one, meaning that the service operates on distinct connections, with each call to `xpc_connection_create` creating a new peer.  :

~~~{objective-c}
xpc_connection_t c = xpc_connection_create("com.example.service", NULL);
xpc_connection_set_event_handler(c, ^(xpc_object_t event) {
    // ...
});
xpc_connection_resume(c);
~~~

When a message is sent over an XPC connection, it is automatically dispatched onto a queue managed by the runtime. As soon as the connection is opened on the remote end, messages are dequeued and sent.

Each message is a dictionary, with string keys and strongly-typed values:

~~~{objective-c}
xpc_dictionary_t message = xpc_dictionary_create(NULL, NULL, 0);
xpc_dictionary_set_uint64(message, "foo", 1);
xpc_connection_send_message(c, message);
xpc_release(message)
~~~

XPC objects operate on the following primitive types:

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

XPC offers a convenient way to convert from the `dispatch_data_t` data type, which simplifies the workflow from GCD to XPC:

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

###  Registering Services

XPC can also be registered as launchd jobs, configured to automatically start on matching IOKit events, BSD notifications or CFDistributedNotifications. These criteria are specified in a service's `launchd.plist` file:

.launchd.plist

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

A recent addition to `launchd` property lists is the `ProcessType` key, which describe at a high level the intended purpose of the launch agent. Based on the prescribed contention behavior, the operating system will automatically throttle CPU and I/O bandwidth accordingly.

#### Process Types and Contention Behavior

| Process Type | Contention Behavior                               |
|--------------|---------------------------------------------------|
| Standard     | Default value                                     |
| Adaptive     | Contend with apps when doing work on their behalf |
| Background   | Never contend with apps                           |
| Interactive  | Always contend with apps                          |

To register a service to run approximately every 5 minutes (allowing a grace period for system resources to become more available before scheduling at a more aggressive priority), a set of criteria is passed into `xpc_activity_register`:

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
