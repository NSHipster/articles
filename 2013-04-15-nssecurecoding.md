---
title: NSSecureCoding
author: Mattt Thompson
category: Cocoa
translator: April Peng
excerpt: "本周的简短文章：你需要了解的关于 NSSecureCoding 的一切。"
---

本周的简短文章：你需要了解的关于 `NSSecureCoding` 的一切。

---

`NSSecureCoding` 是在 iOS 6 / OS X Mountain Lion SDKs 里推出的协议。除了少数在 WWDC 中有提到，`NSSecureCoding` 却依然相对模糊，大多数开发者都可能听说过它，但也许永远没有走近看看它到底做什么。

`NSSecureCoding` 通过加入类方法 `supportsSecureCoding` 来扩展了 `NSCoding` 协议：

如果一个类符合 `NSSecureCoding` 协议并在 `+ supportsSecureCoding` 返回 `YES`，就声明了它可以处理本身实例的编码解码方式，以防止替换攻击。

具体来说，符合 `NSSecureCoding` 协议并重写了 `-initWithCoder` 的类应该使用 `-decodeObjectOfClass:forKey:` 而不是 `-decodeObjectForKey:`。

为什么这很重要？回想一下，`NSCoding` 是基础类库中将对象归档到文件系统上，或复制到另一个地址空间的一种方式。如果用 `-decodeObjectForKey:` 用于把对象解码成实际的对象，就不能保证创建的对象是预期的结果。如果该表示已损坏 - 具体地说，在改变目标类（并且因此指定初始化方法）的时候 - 应用程序将会面临构造未知对象的风险。无论是恶意或偶然的编码错误，这都可能会导致严重的问题。

这不是一个苹果跟另一个苹果的比较，而有点类似于[最近在 Rails 中发现的 YAML 漏洞](http://tenderlovemaking.com/2013/02/06/yaml-f7u12.html)。

对于一个 [XPC service](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html) 来说，它的目的是为安全考虑的，因此数据的完整性显得尤为重要。很可能 XPC 会对后续的 iOS 和 OS X 版本增加影响，所以最好把这一切都铭记在心。

总之，`NSSecureCoding` 通过建立关系给补上这个漏洞做了最佳实践。现在，要对一个对象进行解码，需要该类提前被声明。

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

...一个符合 `NSSecureCoding` 协议的类应该使用:

~~~{swift}
let object = decoder.decodeObjectOfClass(SomeClass.self, forKey: "key") as SomeClass
~~~

~~~{objective-c}
id obj = [decoder decodeObjectOfClass:[MyClass class]
                               forKey:@"myKey"];
~~~

有时候，一点点 API 的变化，会使得所有事情都千差万别。

---

所以，现在你知道什么是 `NSSecureCoding` 了。也许不是今天，也许也不是明天，但总有一天，你可能需要实现 `NSSecureCoding`。而当那一天到来的时候，你会做好准备。

保重，各位。
