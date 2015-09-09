---
title: NSSecureCoding
author: Mattt Thompson
category: Cocoa
excerpt: "A short post for this week: everything you need to know about NSSecureCoding."
status:
    swift: 1.1
---

A short post for this week: everything you need to know about `NSSecureCoding`.

---

`NSSecureCoding` is a protocol introduced in the iOS 6 / OS X Mountain Lion SDKs. Aside from a few mentions at WWDC, `NSSecureCoding` remains relatively obscure—most developers have perhaps heard of it, but perhaps never went so far as to look up what it does.

`NSSecureCoding` extends the `NSCoding` protocol by adding the class method `supportsSecureCoding`:

By conforming to `NSSecureCoding` and returning `YES` for `+supportsSecureCoding`, a class declares that it handles encoding and decoding of instances of itself in a way that guards against substitution attacks.

Specifically, classes that override `-initWithCoder` and conform to `NSSecureCoding` should use `-decodeObjectOfClass:forKey:` rather than `-decodeObjectForKey:`.

Why is this important? Recall that `NSCoding` is Foundation's way of marshaling objects to be either archived on a file system, or copied to another address space. When `-decodeObjectForKey:` is used to decode representations of objects into actual objects, there is no guarantee that the result of creating the object will be what was expected. If that representation is corrupted—specifically, in changing the target class (and thus designated initializer)—the application runs the risk of constructing unknown objects. Whether by malicious intent or an incidental coding error, this can cause serious problems.

It's not an apples-to-apples comparison, but it's somewhat similar to [recent YAML exploit found in Rails](http://tenderlovemaking.com/2013/02/06/yaml-f7u12.html).

For an [XPC service](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html), which is designed with security in mind, data integrity of this nature is especially important. It's a safe bet that XPC will only wax influence in subsequent iOS and OS X releases, so it's good to keep this all in mind.

Anyway, `NSSecureCoding` patches this vulnerability by establishing a contract for best practices. Now, decoding an object requires the class to be known ahead of time.

Whereas a standard, secure implementation of `-initWithCoder:` might have a check like:

~~~{swift}
if let object = decoder.decodeObjectForKey("key") as? SomeClass {
    // ...
}
~~~

~~~{objective-c}
id obj = [decoder decodeObjectForKey:@"myKey"];
if (![obj isKindOfClass:[MyClass class]]) {
  // fail
}
~~~

...an `NSSecureCoding`-conforming class would use:

~~~{swift}
let object = decoder.decodeObjectOfClass(SomeClass.self, forKey: "key") as SomeClass
~~~

~~~{objective-c}
id obj = [decoder decodeObjectOfClass:[MyClass class]
                               forKey:@"myKey"];
~~~

Sometimes, a little API change makes all of the difference.

---

So now you know what's up with `NSSecureCoding`. Perhaps not today, perhaps not tomorrow, but someday—you will probably need to implement `NSSecureCoding`. And when that day comes... you'll be ready.

Stay safe, everyone.
