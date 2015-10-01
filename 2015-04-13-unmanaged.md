---
title: Unmanaged
author: Nate Cook
category: Swift
tags: swift
translator: Croath Liu
excerpt: "通过 Swift 标准库就可以看出，Swift 在安全性和可靠性方面和与 Objective-C 互通性之间方面有着明显的界线。像 `Int`、`String` 和 `Array` 这些类型在使用过程中都会表现出直接且无歧义的行为，但如果什么都不考虑就创建 `UnsafeMutablePointer` 或 `Unmanaged` 等类型的实例，那恐怕就要踩到坑里了。"
hiddenlang: ""
---

API 对于开发者来说不只是把功能点接口暴露出来而已，同时也传达给我们一些其他的信息，比如说接口如何以及为什么要使用某些值。因为要传达这些信息，给东西起适当的名字这件事才变成了计算机科学中最难的部分之一，而这也成为好的 API 和不好的 API 的重要区别。

通过 Swift 标准库就可以看出，Swift 在安全性和可靠性方面和与 Objective-C 互通性之间方面有着明显的界线。像 `Int`、`String` 和 `Array` 这些类型在使用过程中都会表现出直接且无歧义的行为，但如果什么都不考虑就创建 `UnsafeMutablePointer` 或 `Unmanaged` 等类型的实例，那恐怕就要踩到坑里了。

这次我们关注 `Unmanaged` 这个关键字。`Unmanaged` 表示对不清晰的内存管理对象的封装，以及用烫手山芋的方式来管理他们。但开始之前，我们先回顾一下历史。

## 自动引用计数（Automatic Reference Counting）

在石器时代（我是说 2011 年），在 Objective-C 中还要手动进行引用计数。每一个 retain 操作的引用都要与一个相应的 release 操作构成一个平衡的组合，才能避免应用在场景切换的过程中产生僵尸引用和内存泄漏......好脏。对于工程师来说需要小心地计算每一个对象的引用计数实在是太累了，而且对于新入行者门槛也过高了。

自动引用计数（ARC）的到来让和手动内存管理相关的一切都失去了必要。在 ARC 下，编译器会在每一个生命周期内按照规则帮你进行 `retain`/`release`/`autorelease` 指令的调用，减少了很多麻烦。[这幅图](https://developer.apple.com/library/mac/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html) 绝对会让你感受到抛弃手动内存管理的益处：

![ARC 出现前后内存管理差异](http://nshipster.s3.amazonaws.com/unmanaged-arc.png)

在现在这个后 ARC 的世界里，所有的 Objective-C 和 从 Objective-C 方法返回的 Core Foundation 类型的内存都被自动管理，只剩下由 C 函数返回的 Core Foundation 类型还没有收编。对于后者而言，对象所有权的管理仍然停留在调用 `CFRetain()` 和 `CFRelease()`、或通过某个 `__bridge` 函数桥接到 Objective-C 对象的方式的层面上。

为了帮助大家理解 C 函数返回对象是否被调用者持有，苹果使用了 *Create 规则* 和 *Get 规则* 命名法：

- **Create 规则** 的意思是，如果一个函数的名字含有 `Create` 或 `Copy` ，函数的返回值被函数的调用者持有。也就是说，调用 `Create` 或 `Copy` 函数的对象应该对返回对象调用 `CFRelease` 进行释放。

- **Get 规则** 则不像 Create 规则一样能从命名规则看出规律。或许可以描述成函数名不含有 `Create` 或 `Copy` 的函数？这种函数遵守 Get 规则，返回对象的持有者不会发生变化。如果想持久化一个返回对象，大多数时候就是你自己手动 retain 它。

> 如果你是一个像我一样系三条皮带都怕裤子掉下来的那种开发者，那就去好好看看文档。即使大多数 API 遵从这种命名规则，以防意外情况，用的时候都应该好好看看文档确认一下。

等等！等等！我们这篇文章是讨论 *Swift* 的，回到正轨！

Swift 仅支持 ARC，所以也没有地方调用 `CFRelease` 或 `__bridge_retained`。那么 Swift 是如何让这种 “在上下文中内存管理” 的哲学融入自己的内存安全体系呢？

事情分两种情况。*注明* 的 API，Swift 能够在上下文中严格遵循注释描述对 CoreFoundation API 进行内存管理，并以同样内存安全的方式桥接到 Objective-C 或 Swift 类型上。对于没有明确注明的 API，Swift 则会通过 `Unmanaged` 类型把工作交给开发者。

## 管理 `Unmanaged`

虽然大多数的 CoreFoundation API 都有注明是否可自动管理，但一些重要的部分还没有得到充分重视。这篇文章编写时，Address Book framework 的 API 似乎是比较重要的尚未注明的部分，有一些函数还要传入或返回 `Unmanaged` 类型的对象。

一个 `Unmanaged<T>` 实例封装有一个 CoreFoundation 类型 `T`，它在相应范围内持有对该 `T` 对象的引用。从一个 `Unmanaged` 实例中获取一个 Swift 值的方法有两种：

> - `takeRetainedValue()`：返回该实例中 Swift 管理的引用，并在调用的同时减少一次引用次数，所以可以按照 Create 规则来对待其返回值。

> - `takeUnretainedValue()`：返回该实例中 Swift 管理的引用而 *不减少* 引用次数，所以可以按照 Get 规则来对待其返回值。

在实践中最好不要直接操作 `Unmanaged` 实例，而是用这两个 `take` 开头的方法从返回值中拿到绑定的对象。

我们来看一个例子。比如说我们这里要创建一个 `ABAddressBook` 来获取用户最好的朋友的名字：

```swift
let bestFriendID = ABRecordID(...)

// Create Rule - retained
let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

if let
    // Get Rule - unretained
    bestFriendRecord: ABRecord = ABAddressBookGetPersonWithRecordID(addressBook, bestFriendID)?.takeUnretainedValue(),
    // Create Rule (Copy) - retained
    name = ABRecordCopyCompositeName(bestFriendRecord)?.takeRetainedValue() as? String
{
    println("\(name): BFF!")
    // Rhonda Shorsheimer: BFF!
}
```

通过使用 Swift 1.2 新增的 optional 绑定，取得对象并将其转化为 Swift 类型简直是小菜一碟。

## 最好的解决问题的方法是避免遇到问题

现在我们已经知道如何对付 `Unmanaged` 了，现在我们还是看看如何避免碰到这种情况吧。如果 `Unmanaged` 引用是从你自己写的 C 函数返回的，那么你最好还是注明一下。这种注释能够帮助编译器理解如何自动管理你所返回对象的内存：就不要用 `Unmanaged<CFString>` 了，直接返回一个在 Swift 中类型安全以及内存管理完善的 `CFString` 类型。

举例说明，我们有一个函数能将两个 `CFString` 对象拼装成一个字符串，并且要告诉 Swift 这个返回字符串的内存是被如何管理的。根据上面提到的命名规则，我们的函数应该叫做 `CreateJoinedString` —— 这个名字表达的意思是调用者将持有返回值。

```c
CFStringRef CreateJoinedString(CFStringRef string1, CFStringRef string2);
```

既然这样，在函数实现中我们用 `CFStringCreateMutableCopy` 创建的 `resultString` 返回时没有与其创建函数平衡的 `CFRelease`：

```c
CFStringRef CreateJoinedString(CFStringRef string1, CFStringRef string2) {
    CFMutableStringRef resultString = CFStringCreateMutableCopy(NULL, 0, string1);
    CFStringAppend(resultString, string2);
    return resultString;
}
```

在 Swift 中像上面一样，我们也要手动管理内存。我们的函数被引用成返回一个 `Unmanaged<CFString>!`：

```swift
// imported declaration:
func CreateJoinedString(string1: CFString!, string2: CFString!) -> Unmanaged<CFString>!

// to call:
let joinedString = CreateJoinedString("First", "Second").takeRetainedValue() as String
```

既然我们的函数遵循了 Create 规则进行命名，那么就可以打开编译器的隐式桥接来消除 `Unmanaged` 歧义。Core Foundation 提供了两个宏：`CF_IMPLICIT_BRIDGING_ENABLED` 和 `CF_IMPLICIT_BRIDGING_DISABLED` —— 用来打开和关闭 Clang 的 `arc_cf_code_audited` 变量：

```c
CF_IMPLICIT_BRIDGING_ENABLED            // get rid of Unmanaged
#pragma clang assume_nonnull begin      // also get rid of !s

CFStringRef CreateJoinedString(CFStringRef string1, CFStringRef string2);

#pragma clang assume_nonnull end
CF_IMPLICIT_BRIDGING_DISABLED
```

现在 Swift 已经能够控制这个函数返回值的内存管理了，我们的代码里也可以不用 `Unmanaged` 了：

```swift
// imported declaration:
func CreateJoinedString(string1: CFString, string2: CFString) -> CFString

// to call:
let joinedString = CreateJoinedString("First", "Second") as String
```

最后一点，如果你的函数 *没有使用* Create/Get 规则来命名，那么明显地，你把这些函数用这个法则重新命名一次。当然在真实情况下这种修改可能并不容易，但是拥有明确性一致性返回的 API 的好处不仅仅是避免 `Unmanaged`。如果不能够重命名，也有另外两种注明方式可以使用：将持有者转移到调用者的函数应该使用 `CF_RETURNS_RETAINED`，反之则使用 `CF_RETURNS_NOT_RETAINED`。比如说，这个命名糟糕的 `MakeJoinedString` 就是用了手动注明的方式来表明其性质：

```c
CF_RETURNS_RETAINED
__nonnull CFStringRef MakeJoinedString(__nonnull CFStringRef string1,
                                       __nonnull CFStringRef string2);
```

* * *

你可能感觉 `Unmanaged` 只是一时的权宜之计 —— 是的确实，因为对 CoreFoundation 中数量庞大的 API 进行标注的工作还在进行中。随着函数的交互形式被修改得越来越清晰，每一代 Xcode 发布都有可能需要你减少对 `takeRetainedValue()` 的调用。在最后一个 `CFUnannotatedFunctionRef` 被改好之前，`Unmanaged` 将会帮助你渡过难关。

