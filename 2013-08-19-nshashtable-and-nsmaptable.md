---
title: "NSHashTable & NSMapTable"
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "NSSet and NSDictionary, along with NSArray are the workhorse collection classes of Foundation. Unlike other standard libraries, implementation details are hidden from developers, allowing them to write simple code and trust that it will be (reasonably) performant."
status:
    swift: 2.0
    reviewed: September 11, 2015
---

`NSSet` and `NSDictionary`, along with `NSArray` are the workhorse collection classes of Foundation. Unlike [ other standard libraries](http://en.wikipedia.org/wiki/Java_collections_framework), implementation details are [hidden](http://ridiculousfish.com/blog/posts/array.html) from developers, allowing them to write simple code and trust that it will be (reasonably) performant.

However, even the best abstractions break down; their underlying assumptions overturned. In these cases, developers either venture further down the abstraction, or, if available use a more general-purpose solution.

For `NSSet` and `NSDictionary`, the breaking assumption was in the memory behavior when storing objects in the collection. For `NSSet`, objects are a strongly referenced, as are `NSDictionary` values. Keys, on the other hand, are copied by `NSDictionary`. If a developer wanted to store a weak value, or use a non-`<NSCopying>`-conforming object as a key, they could be clever and use [`NSValue +valueWithNonretainedObject`](http://nshipster.com/nsvalue/). Or, as of iOS 6 (and as far back as OS X Leopard), they could use `NSHashTable` or `NSMapTable`, the more general-case counterparts to `NSSet` or `NSDictionary`, respectively.

So without further ado, here's everything you need to know about two of the more obscure members of Foundation's collection classes:

## `NSHashTable`

`NSHashTable` is a general-purpose analogue of `NSSet`. Contrasted with the behavior of `NSSet` / `NSMutableSet`, `NSHashTable` has the following characteristics:

- `NSSet` / `NSMutableSet` holds `strong` references to members, which are tested for hashing and equality using the methods `hash` and `isEqual:`.
- `NSHashTable` is mutable, without an immutable counterpart.
- `NSHashTable` can hold `weak` references to its members.
- `NSHashTable` can `copy` members on input.
- `NSHashTable` can contain arbitrary pointers, and use pointer identity for equality and hashing checks.

### Usage

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

`NSHashTable` objects are initialized with an option for any of the following behaviors. Deprecated enum values are due to `NSHashTable` being ported from Garbage-Collected OS X to ARC-ified iOS. Other values are aliased to options defined by [NSPointerFunctions](http://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Reference/Foundation/Classes/NSPointerFunctions_Class/Introduction/Introduction.html), which will be covered next week on NSHipster.

> - `NSHashTableStrongMemory`: Equal to `NSPointerFunctionsStrongMemory`. This is the default behavior, equivalent to `NSSet` member storage.
> - `NSHashTableWeakMemory`: Equal to `NSPointerFunctionsWeakMemory`. Uses weak read and write barriers. Using `NSPointerFunctionsWeakMemory`, object references will turn to `NULL` on last release.
> - `NSHashTableZeroingWeakMemory`: This option has been deprecated. Instead use the `NSHashTableWeakMemory` option.
> - `NSHashTableCopyIn`: Use the memory acquire function to allocate and copy items on input (see [`NSPointerFunction -acquireFunction`](http://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Reference/Foundation/Classes/NSPointerFunctions_Class/Introduction/Introduction.html#//apple_ref/occ/instp/NSPointerFunctions/acquireFunction)). Equal to `NSPointerFunctionsCopyIn`.
> - `NSHashTableObjectPointerPersonality`: Use shifted pointer for the hash value and direct comparison to determine equality; use the description method for a description. Equal to `NSPointerFunctionsObjectPointerPersonality`.

## `NSMapTable`

`NSMapTable` is a general-purpose analogue of `NSDictionary`. Contrasted with the behavior of `NSDictionary` / `NSMutableDictionary`, `NSMapTable` has the following characteristics:

- `NSDictionary` / `NSMutableDictionary` copies keys, and holds strong references to values.
- `NSMapTable` is mutable, without an immutable counterpart.
- `NSMapTable` can hold keys and values with `weak` references, in such a way that entries are removed when either the key or value is deallocated.
- `NSMapTable` can `copy` its values on input.
- `NSMapTable` can contain arbitrary pointers, and use pointer identity for equality and hashing checks.

> *Note:* `NSMapTable`'s focus on strong and weak references means that Swift's prevalent value types are a no go—reference types only, please.

### Usage

Instances where one might use `NSMapTable` include non-copyable keys and storing weak references to keyed delegates or another kind of weak object.

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

`NSMapTable` objects are initialized with options specifying behavior for both keys and values, using the following enum values:

> - `NSMapTableStrongMemory`: Specifies a strong reference from the map table to its contents.
> - `NSMapTableWeakMemory`: Uses weak read and write barriers appropriate for ARC or GC. Using `NSPointerFunctionsWeakMemory`, object references will turn to `NULL` on last release. Equal to `NSMapTableZeroingWeakMemory`.
> - `NSHashTableZeroingWeakMemory`: This option has been superseded by the `NSMapTableWeakMemory` option.
> - `NSMapTableCopyIn`: Use the memory acquire function to allocate and copy items on input (see acquireFunction (see [`NSPointerFunction -acquireFunction`](http://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Reference/Foundation/Classes/NSPointerFunctions_Class/Introduction/Introduction.html#//apple_ref/occ/instp/NSPointerFunctions/acquireFunction)). Equal to NSPointerFunctionsCopyIn.
> - `NSMapTableObjectPointerPersonality`: Use shifted pointer hash and direct equality, object description.
Equal to `NSPointerFunctionsObjectPointerPersonality`.

### Subscripting

`NSMapTable` doesn't implement [object subscripting](http://nshipster.com/object-subscripting/), but it can be trivially added in a category. `NSDictionary`'s `NSCopying` requirement for keys belongs to `NSDictionary` alone:

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

As always, it's important to remember that programming is not about being clever: always approach a problem from the highest viable level of abstraction. `NSSet` and `NSDictionary` are _great_ classes. For 99% of problems, they are undoubtedly the correct tool for the job. If, however, your problem has any of the particular memory management constraints described above, then `NSHashTable` & `NSMapTable` may be worth a look.
