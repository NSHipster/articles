---
title: NSSecureCoding
author: Mattt Thompson
category: Cocoa
excerpt: "A short post for this week: everything you need to know about NSSecureCoding."
translator: April Peng
excerpt: "本周的简短文章：你需要了解的关于 NSSecureCoding 的一切。"
---

A short post for this week: everything you need to know about `NSSecureCoding`.

本周的简短文章：你需要了解的关于 `NSSecureCoding` 的一切。

---

`NSSecureCoding` is a protocol introduced in the iOS 6 / OS X Mountain Lion SDKs. Aside from a few mentions at WWDC, `NSSecureCoding` remains relatively obscure—most developers have perhaps heard of it, but perhaps never went so far as to look up what it does.

`NSSecureCoding` 是在 iOS 6 / OS X Mountain Lion SDKs 里推出的协议。除了少数在 WWDC 中有提到，`NSSecureCoding` 却依然相对模糊，大多数开发者都可能听说过它，但也许永远没有走近看看它到底做什么。

`NSSecureCoding` extends the `NSCoding` protocol by adding the class method `supportsSecureCoding`:

`NSSecureCoding` 通过加入类方法 `supportsSecureCoding` 来扩展了 `NSCoding` 协议：

By conforming to `NSSecureCoding` and returning `YES` for `+supportsSecureCoding`, a class declares that it handles encoding and decoding of instances of itself in a way that guards against substitution attacks.

如果一个类符合 `NSSecureCoding` 协议并在 `+ supportsSecureCoding` 返回 `YES`，就声明了它可以处理本身实例的编码解码方式，以防止替换攻击。

Specifically, classes that override `-initWithCoder` and conform to `NSSecureCoding` should use `-decodeObjectOfClass:forKey:` rather than `-decodeObjectForKey:`.

具体来说，符合 `NSSecureCoding` 协议并重写了 `-initWithCoder` 的类应该使用 `-decodeObjectOfClass:forKey:` 而不是 `-decodeObjectForKey:`。

Why is this important? Recall that `NSCoding` is Foundation's way of marshaling objects to be either archived on a file system, or copied to another address space. When `-decodeObjectForKey:` is used to decode representations of objects into actual objects, there is no guarantee that the result of creating the object will be what was expected. If that representation is corrupted—specifically, in changing the target class (and thus designated initializer)—the application runs the risk of constructing unknown objects. Whether by malicious intent or an incidental coding error, this can cause serious problems.

为什么这很重要？回想一下，`NSCoding` 是 Foundation 为整理文件系统上的归档对象，或整理复制到另一个地址空间的对象一种方式。如果用 `-decodeObjectForKey:` 用于把对象解码成实际的对象，就不能保证创建的对象是预期的结果。如果该表示已损坏 - 具体地说，在改变目标类（并且因此指定初始化方法）的时候 - 应用程序将会面临构造未知对象的风险。无论是恶意或偶然的编码错误，这都可能会导致严重的问题。

It's not an apples-to-apples comparison, but it's somewhat similar to [recent YAML exploit found in Rails](http://tenderlovemaking.com/2013/02/06/yaml-f7u12.html).

这不是一个苹果跟另一个苹果的比较，而有点类似于[最近在 Rails 中发现的 YAML 漏洞](http://tenderlovemaking.com/2013/02/06/yaml-f7u12.html)。

For an [XPC service](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html), which is designed with security in mind, data integrity of this nature is especially important. It's a safe bet that XPC will only wax influence in subsequent iOS and OS X releases, so it's good to keep this all in mind.

对于一个 [XPC service](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html) 来说，它的目的是为安全考虑的，因此数据的完整性显得尤为重要。很可能 XPC 会对后续的 iOS 和 OS X 版本增加影响，所以最好把这一切都铭记在心。

Anyway, `NSSecureCoding` patches this vulnerability by establishing a contract for best practices. Now, decoding an object requires the class to be known ahead of time.

总之，`NSSecureCoding` 通过建立关系给补上这个漏洞做了最佳实践。现在，要对一个对象进行解码，需要该类提前被声明。

Whereas a standard, secure implementation of `-initWithCoder:` might have a check like:

而一个标准的，安全的 `-initWithCoder:` 实现可能需要一个检查，比如：

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

...一个符合 `NSSecureCoding` 协议的类应该使用:

~~~{swift}
let object = decoder.decodeObjectOfClass(SomeClass.self, forKey: "key") as SomeClass
~~~

~~~{objective-c}
id obj = [decoder decodeObjectOfClass:[MyClass class]
                               forKey:@"myKey"];
~~~

Sometimes, a little API change makes all of the difference.

有时候，一点点 API 的变化，会使得所有事情都千差万别。

---

So now you know what's up with `NSSecureCoding`. Perhaps not today, perhaps not tomorrow, but someday—you will probably need to implement `NSSecureCoding`. And when that day comes... you'll be ready.

所以，现在你知道什么是 `NSSecureCoding` 了。也许不是今天，也许也不是明天，但总有一天，你可能需要实现 `NSSecureCoding`。而当那一天到来的时候，你会做好准备。

Stay safe, everyone.

保重，各位。
