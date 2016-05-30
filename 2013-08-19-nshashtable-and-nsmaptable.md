---
title: "NSHashTable & NSMapTable"
author: Mattt Thompson
translator: Chester Liu
category: Cocoa
tags: nshipster
excerpt: "NSSet 和 NSDictionary，连同 NSArray 是 Foundation 框架中最常用的几个集合类型。和其它标准库不同的是，它们的实现细节没有对开发者公开，使得开发者只能编写简单的代码，相信框架（在合理的程度上）是高效的。"
status:
    swift: 2.0
    reviewed: September 11, 2015
---

`NSSet` 和 `NSDictionary`，连同 `NSArray` 是 Foundation 框架中最常用的几个集合类型。和[其它标准库](http://en.wikipedia.org/wiki/Java_collections_framework)不同的是，它们的实现细节[没有](http://ridiculousfish.com/blog/posts/array.html)对开发者公开，使得开发者只能编写简单的代码，相信框架（在合理的程度上）是高效的。

然而，再好的抽象也有不好用的时候。当对他们底层的实现假设不符合预期的时候，开发者要么继续在抽象层次上进行探索，要么在可能的情况下，使用更加通用的解决方案。

对于 `NSSet` 和 `NSDictionary` 来说，不符合预期的部分通常在于它们存储对象时在内存中的表现。对于 `NSSet`，对象在存储时会被强引用，`NSDictionary` 中值的存储也是一样。对键来说，在 `NSDictionary` 中会被拷贝。如果开发者想存储弱引用的值，或者使用一个没有遵守 `<NSCopying>` 的对象作为键，他可以选择聪明的办法，使用 [`NSValue +valueWithNonretainedObject`](http://nshipster.cn/nsvalue/)。或者，在 iOS 6（以及 OS X Leopard）上，他可以使用 `NSHashTable` 或 `NSMapTable`，分别对应着 `NSSet` 和 `NSDictionary`，是它们更加通用的版本。

废话不多说，对这两个 Foundation 框架中最不知名的集合类型，下面是你所需要知道的一切：

## `NSHashTable`

`NSHashTable` 是 `NSSet` 的通用版本，和 `NSSet` / `NSMutableSet` 不同的是，`NSHashTable` 具有下面这些特性：

- `NSSet` / `NSMutableSet` 持有成员的强引用，通过  `hash` 和 `isEqual:` 方法来检测成员的散列值和相等性。
- `NSHashTable` 是可变的，没有不可变的对应版本。
- `NSHashTable` 可以持有成员的弱引用。
- `NSHashTable` 可以在加入成员时进行 `copy` 操作。
- `NSHashTable` 可以存储任意的指针，通过指针来进行相等性和散列检查。

### 用法

~~~{swift}
let hashTable = NSHashTable(options: .CopyIn)
hashTable.addObject("foo")
hashTable.addObject("bar")
hashTable.addObject(42)
hashTable.removeObject("bar")
print("Members: \(hashTable.allObjects)")
~~~
~~~{objective-c}
NSHashTable *hashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsCopyIn];
[hashTable addObject:@"foo"];
[hashTable addObject:@"bar"];
[hashTable addObject:@42];
[hashTable removeObject:@"bar"];
NSLog(@"Members: %@", [hashTable allObjects]);
~~~

`NSHashTable` 对象在初始化时可以选择下面任意一个选项来产生不同的行为。在 `NSHashTable` 从具有垃圾回收机制的 OS X 环境被移植到 ARC 化的 iOS 环境的过程中，有一些选项枚举值被废弃了。其余的选项值对应着 [NSPointerFunctions](http://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Reference/Foundation/Classes/NSPointerFunctions_Class/Introduction/Introduction.html) 的选项，这部分内容会在下周的 NSHipster 中进行讲解。（译者注：下面具体的内容来自官方文档，不再做翻译，NSMapTable 部分做相同处理）

> - `NSHashTableStrongMemory`: Equal to `NSPointerFunctionsStrongMemory`. This is the default behavior, equivalent to `NSSet` member storage.
> - `NSHashTableWeakMemory`: Equal to `NSPointerFunctionsWeakMemory`. Uses weak read and write barriers. Using `NSPointerFunctionsWeakMemory`, object references will turn to `NULL` on last release.
> - `NSHashTableZeroingWeakMemory`: This option has been deprecated. Instead use the `NSHashTableWeakMemory` option.
> - `NSHashTableCopyIn`: Use the memory acquire function to allocate and copy items on input (see [`NSPointerFunction -acquireFunction`](http://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Reference/Foundation/Classes/NSPointerFunctions_Class/Introduction/Introduction.html#//apple_ref/occ/instp/NSPointerFunctions/acquireFunction)). Equal to `NSPointerFunctionsCopyIn`.
> - `NSHashTableObjectPointerPersonality`: Use shifted pointer for the hash value and direct comparison to determine equality; use the description method for a description. Equal to `NSPointerFunctionsObjectPointerPersonality`.

## `NSMapTable`

`NSMapTable` 是 `NSDictionary` 的通用版本。和 `NSDictionary` / `NSMutableDictionary` 不同的是，`NSMapTable` 具有下面这些特性：

- `NSDictionary` / `NSMutableDictionary` 对键进行拷贝，对值持有强引用。
- `NSMapTable` 是可变的，没有不可变的对应版本。
- `NSMapTable` 可以持有键和值的弱引用，当键或者值当中的一个被释放时，整个这一项就会被移除掉。
- `NSMapTable` 可以在加入成员时进行 `copy` 操作。
- `NSMapTable` 可以存储任意的指针，通过指针来进行相等性和散列检查。

> *注意：* `NSMapTable` 专注于强引用和弱引用，意外着 Swift 中流行的值类型是不适用的，只能用于引用类型。

### 用法

下面的例子展示了如何使用 `NSMapTable` 来包含不可拷贝的键，以及存储键对应的 delegate 或其他值的弱引用。

~~~{swift}
let delegate: AnyObject = ...
let mapTable = NSMapTable(keyOptions: .StrongMemory, valueOptions: .WeakMemory)

mapTable.setObject(delegate, forKey: "foo")
print("Keys: \(mapTable.keyEnumerator().allObjects)")
~~~
~~~{objective-c}
id delegate = ...;
NSMapTable *mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                             valueOptions:NSMapTableWeakMemory];
[mapTable setObject:delegate forKey:@"foo"];
NSLog(@"Keys: %@", [[mapTable keyEnumerator] allObjects]);
~~~

`NSMapTable` 对象在初始化时需要使用下面这些选项来指定键和值的具体行为：

> - `NSMapTableStrongMemory`: Specifies a strong reference from the map table to its contents.
> - `NSMapTableWeakMemory`: Uses weak read and write barriers appropriate for ARC or GC. Using `NSPointerFunctionsWeakMemory`, object references will turn to `NULL` on last release. Equal to `NSMapTableZeroingWeakMemory`.
> - `NSHashTableZeroingWeakMemory`: This option has been superseded by the `NSMapTableWeakMemory` option.
> - `NSMapTableCopyIn`: Use the memory acquire function to allocate and copy items on input (see acquireFunction (see [`NSPointerFunction -acquireFunction`](http://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Reference/Foundation/Classes/NSPointerFunctions_Class/Introduction/Introduction.html#//apple_ref/occ/instp/NSPointerFunctions/acquireFunction)). Equal to NSPointerFunctionsCopyIn.
> - `NSMapTableObjectPointerPersonality`: Use shifted pointer hash and direct equality, object description.
Equal to `NSPointerFunctionsObjectPointerPersonality`.

### 使用下标

`NSMapTable` 没有实现[对象下标索引](http://nshipster.cn/object-subscripting/)，不过通过 category 来添加这个特性并不是很麻烦。`NSDictionary` 对于键要遵守 `NSCopying` 的要求，只适用于 `NSDictionary` 本身：

~~~{swift}
extension NSMapTable {
    subscript(key: AnyObject) -> AnyObject? {
        get {
            return objectForKey(key)
        }

        set {
            if newValue != nil {
                setObject(newValue, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }
}
~~~

~~~{objective-c}
@implementation NSMapTable (NSHipsterSubscripting)

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key
{
    if (obj != nil) {
        [self setObject:obj forKey:key];
    } else {
        [self removeObjectForKey:key];
    }
}

@end
~~~

---

和往常一样，记住一点，编程并不是要做到多么聪明：永远先从最高的抽象层次去尝试解决问题。`NSSet` 和 `NSDictionary` 都是 _非常好_  的工具。在 99% 的情况下，它们毋庸置疑是正确的选择。如果你碰到的问题包含上面提到的具体的内存管理需求，那么 `NSHashTable` 和 `NSMapTable` 值得你一看。
