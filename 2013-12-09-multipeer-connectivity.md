---
title: Multipeer Connectivity
author: Mattt Thompson
category: Cocoa
tags: popular
excerpt: "As consumer web technologies and enterprises race towards cloud infrastructure, there is a curious and significant counter-movement towards connected devices. The Multipeer Connectivity APIs, introduced in iOS 7, therefore may well be the most significant for the platform."
status:
    swift: t.b.c.
---

As consumer web technologies and enterprises race towards cloud infrastructure, there is a curious and significant counter-movement towards connected devices.

In this age of mobile computing, the possibilities of collaboration, whether in work or play, have never been greater. In this age of privacy concerns and mass surveillance, the need for secure, ad hoc communications has never been more prescient. In this age of connected devices, the promise of mastery over the everyday objects of our lives has never been closer at hand.

The Multipeer Connectivity APIs, introduced in iOS 7, therefore may well be the most significant for the platform. It allows developers to completely reimagine how mobile apps are built, and to redefine what is possible. And we're not just talking about successors to the lame bump-to-send-contact-information genre, either: multi-peer connectivity has implications on everything from collaborative editing and file sharing to multiplayer gaming and sensor aggregation.

* * *

Multipeer Connectivity is a framework that enables nearby devices to communicate over infrastructure Wi-Fi networks, peer-to-peer Wi-Fi, and Bluetooth personal area networks. Connected peers are able securely transmit messages, streams, or file resources to other devices without going through an intermediary web service.

## Advertising & Discovering

The first step in communication is to make peers aware of one another. This is accomplished by advertising and discovering services.

Advertising makes a service known to other peers, while discovery is the inverse process of the client being made aware of services advertised by other peers. In many cases, clients both discover and advertise for the same service, which can lead to some initial confusion—especially to anyone rooted in the client-server paradigm.

Each service is identified by a type, which is a short text string of ASCII letters, numbers, and dashes, up to 15 characters in length. By convention, a service name should begin with the app name, followed by a dash and a unique descriptor for that service (think of it as simplified `com.apple.*`-esque reverse-DNS notation):

~~~{objective-c}
static NSString * const XXServiceType = @"xx-service";
~~~

Peers are uniquely identified by an `MCPeerID` object, which are initialized with a display name. This could be a user-specified nickname, or simply the current device name:

~~~{objective-c}
MCPeerID *localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
~~~

> Peers can be also be advertised or discovered manually using `NSNetService` or the Bonjour C APIs, but this is a rather advanced and specific concern. Additional information about manual peer management can be found in the `MCSession` documentation.

### Advertising

Services are advertised by the `MCNearbyServiceAdvertiser`, which is initialized with a local peer, service type, and any optional information to be communicated to peers that discover the service.

> Discovery information is sent as Bonjour `TXT` records encoded according to [RFC 6763](http://tools.ietf.org/html/rfc6763).

~~~{objective-c}
MCNearbyServiceAdvertiser *advertiser =
    [[MCNearbyServiceAdvertiser alloc] initWithPeer:localPeerID
                                      discoveryInfo:nil
                                        serviceType:XXServiceType];
advertiser.delegate = self;
[advertiser startAdvertisingPeer];
~~~

Events are handled by the advertiser's `delegate`, conforming to the `MCNearbyServiceAdvertiserDelegate` protocol.

As an example implementation, consider a client that allows the user to choose whether to accept or reject incoming connection requests, with the option to reject and block any subsequent requests from that peer:

~~~{objective-c}
#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    if ([self.mutableBlockedPeers containsObject:peerID]) {
        invitationHandler(NO, nil);
        return;
    }

    [[UIActionSheet actionSheetWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Received Invitation from %@", @"Received Invitation from {Peer}"), peerID.displayName]
                       cancelButtonTitle:NSLocalizedString(@"Reject", nil)
                  destructiveButtonTitle:NSLocalizedString(@"Block", nil)
                       otherButtonTitles:@[NSLocalizedString(@"Accept", nil)]
                                   block:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
    {
        BOOL acceptedInvitation = (buttonIndex == [actionSheet firstOtherButtonIndex]);

        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            [self.mutableBlockedPeers addObject:peerID];
        }

        MCSession *session = [[MCSession alloc] initWithPeer:localPeerID
                                            securityIdentity:nil
                                        encryptionPreference:MCEncryptionNone];
        session.delegate = self;

        invitationHandler(acceptedInvitation, (acceptedInvitation ? session : nil));
    }] showInView:self.view];
}
~~~

> For sake of simplicity, this example contrives a block-based initializer for `UIActionSheet`, which allows for the `invitationHandler` to be passed directly into the action sheet responder in order to avoid the messy business of creating and managing a custom delegate object. This method can be implemented in a category, or adapted from [any of the implementations available on CocoaPods](http://cocoapods.org/?q=uiactionsheet%20blocks)

### Creating a Session

As in the example above, sessions are created by advertisers, and passed to peers when accepting an invitation to connect. An `MCSession` object is initialized with the local peer identifier, as well as `securityIdentity` and `encryptionPreference` parameters.

~~~{objective-c}
MCSession *session = [[MCSession alloc] initWithPeer:localPeerID
                                    securityIdentity:nil
                                encryptionPreference:MCEncryptionNone];
session.delegate = self;
~~~

`securityIdentity` is an optional parameter that allows peers to securely identify peers by X.509 certificates. When specified, the first object should be an `SecIdentityRef` identifying the client, followed by one or more `SecCertificateRef` objects than can be used to verify the local peer’s identity.

The `encryptionPreference` parameter specifies whether to encrypt communication between peers. Three possible values are provided by the `MCEncryptionPreference` enum:

- `MCEncryptionOptional`: The session prefers to use encryption, but will accept unencrypted connections.
- `MCEncryptionRequired`: The session requires encryption.
- `MCEncryptionNone`: The session should not be encrypted.

> Enabling encryption can significantly reduce transfer rates, so unless your application specifically deals with user-sensitive information, `MCEncryptionNone` is recommended.

The `MCSessionDelegate` protocol will be covered in the section on sending and receiving information.

### Discovering

Clients can discover advertised services using `MCNearbyServiceBrowser`, which is initialized with the local peer identifier and the service type, much like for `MCNearbyServiceAdvertiser`.

~~~{objective-c}
MCNearbyServiceBrowser *browser = [[MCNearbyServiceBrowser alloc] initWithPeer:localPeerID serviceType:XXServiceType];
browser.delegate = self;
~~~

There may be many peers advertising a particular service, so as a convenience to the user (and the developer), the `MCBrowserViewController` offers a built-in, standard way to present and connect to advertising peers:

~~~{objective-c}
MCBrowserViewController *browserViewController =
    [[MCBrowserViewController alloc] initWithBrowser:browser
                                             session:session];
browserViewController.delegate = self;
[self presentViewController:browserViewController
                   animated:YES
                 completion:
^{
    [browser startBrowsingForPeers];
}];
~~~

When a browser has finished connecting to peers, it calls `-browserViewControllerDidFinish:` on its delegate, to notify the presenting view controller that it should update its UI to accommodate the newly-connected clients.

## Sending & Receiving Information

Once peers are connected to one another, information can be sent between them. The Multipeer Connectivity framework distinguishes between three different forms of data transfer:

- **Messages** are information with well-defined boundaries, such as short text or small serialized objects.
- **Streams** are open channels of information used to continuously transfer data like audio, video, or real-time sensor events.
- **Resources** are files like images, movies, or documents.

### Messages

Messages are sent with `-sendData:toPeers:withMode:error:`:

~~~{objective-c}
NSString *message = @"Hello, World!";
NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
NSError *error = nil;
if (![self.session sendData:data
                    toPeers:peers
                   withMode:MCSessionSendDataReliable
                      error:&error]) {
    NSLog(@"[Error] %@", error);
}
~~~

* * *

Messages are received through the `MCSessionDelegate` method `-sessionDidReceiveData:fromPeer:`. Here's how one would decode the message sent in the previous code example:

~~~{objective-c}
#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    NSString *message =
        [[NSString alloc] initWithData:data
                              encoding:NSUTF8StringEncoding];
    NSLog(@"%@", message);
}
~~~

Another approach would be to send `NSKeyedArchiver`-encoded objects:

~~~{objective-c}
id <NSSecureCoding> object = // ...;
NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
NSError *error = nil;
if (![self.session sendData:data
                    toPeers:peers
                   withMode:MCSessionSendDataReliable
                      error:&error]) {
    NSLog(@"[Error] %@", error);
}
~~~

~~~{objective-c}
#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    unarchiver.requiresSecureCoding = YES;
    id object = [unarchiver decodeObject];
    [unarchiver finishDecoding];
    NSLog(@"%@", object);
}
~~~

> In order to guard against object substitution attacks, it is important to set `requiresSecureCoding` to `YES`, such that an exception is thrown if the root object class does not conform to `<NSSecureCoding>`.  For more information, see the [NSHipster article on [NSSecureCoding](http://nshipster.com/nssecurecoding/).

### Streams

Streams are created with `-startStreamWithName:toPeer:`:

~~~{objective-c}
NSOutputStream *outputStream =
    [session startStreamWithName:name
                          toPeer:peer];

stream.delegate = self;
[stream scheduleInRunLoop:[NSRunLoop mainRunLoop]
                forMode:NSDefaultRunLoopMode];
[stream open];

// ...
~~~

* * *

Streams are received by the `MCSessionDelegate` with `-session:didReceiveStream:withName:fromPeer:`:

~~~{objective-c}
#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID
{
    stream.delegate = self;
    [stream scheduleInRunLoop:[NSRunLoop mainRunLoop]
                      forMode:NSDefaultRunLoopMode];
    [stream open];
}
~~~

Both the input and output streams must be scheduled and opened before they can be used. Once that's done, streams can be read from and written to just like any other bound pair.

### Resources

Resources are sent with `sendResourceAtURL:withName:toPeer:withCompletionHandler:`:

~~~{objective-c}
NSURL *fileURL = [NSURL fileURLWithPath:@"path/to/resource"];
NSProgress *progress =
    [self.session sendResourceAtURL:fileURL
                           withName:[fileURL lastPathComponent]
                             toPeer:peer
                  withCompletionHandler:^(NSError *error)
{
    NSLog(@"[Error] %@", error);
}];
~~~

The returned `NSProgress` object can be [Key-Value Observed](http://nshipster.com/key-value-observing/) to monitor progress of the file transfer, as well as provide a cancellation handler, through the `-cancel` method.

* * *

Receiving resources happens across two methods in `MCSessionDelegate`: `-session:didStartReceivingResourceWithName:fromPeer:withProgress:` & `-session:didFinishReceivingResourceWithName:fromPeer:atURL:withError:`:

~~~{objective-c}
#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
   withProgress:(NSProgress *)progress
{
    // ...
}

- (void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
          atURL:(NSURL *)localURL
      withError:(NSError *)error
{
    NSURL *destinationURL = [NSURL fileURLWithPath:@"/path/to/destination"];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] moveItemAtURL:localURL
                                                 toURL:destinationURL
                                                 error:&error]) {
        NSLog(@"[Error] %@", error);
    }
}
~~~

Again, the `NSProgress` parameter in `-session:didStartReceivingResourceWithName:fromPeer:withProgress:` allows the receiving peer to monitor the file transfer progress. In `-session:didFinishReceivingResourceWithName:fromPeer:atURL:withError:`, it is the responsibility of the delegate to move the file at the temporary `localURL` to a permanent location.

* * *

Multipeer Connectivity is a ground-breaking API, whose value is only just starting to be fully understood. Although full support for features like AirDrop are currently limited to latest-gen devices, you should expect to see this kind of functionality become expected behavior.

As you look forward to the possibilities of the new year ahead, get your head out of the cloud, and start to consider the incredible possibilities around you.
