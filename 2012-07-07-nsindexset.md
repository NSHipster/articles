---
layout: post
title: NSIndexSet

ref: "https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSSet_Class/Reference/Reference.html"
framework: Foundation
rating: 7.8
---

`NSIndexSet` (以及它的可修改子类, `NSMutableIndexSet`) 是一个排好序的，无重复元素的整数集合。它看上去有点像 支持离散整数的 `NSRange` .它能用于快速查找特定范围的值的索引，也能用于快速计算交集, 同时，Foundation collection class 提供了很多好用的方法，方便你使用 `NSIndexSet`.

Foundataion framework 里面到处可以看到 `NSIndexSet` 的影子。 任何从已排序容器(比如 array, 或者 table view 的 data source)里面获取多个元素的方法都会用到 `NSIndexSet` 做为参数。

如果你仔细看过，你可能会发现你的数据模型可以用`NSIndexSet` 来表示。比如， AFNetworking 用一个 index set 来代表各个 HTTP 返回码: 用户定义一个 "可接受" 码集合( 默认在 2XX 范围之内的码)，放进一个 `NSIndexSet`, 然后AFNetworking 用 containsIndex: 来检查返回码是否是用户期待的值。

下面还有一些其它关于 index sets 可能的用途:

- 如果你想提供一套用户选项，里面全部是开关选项，那么你可以考虑用一个 NSIndexSet, 然后把每个打开的开关选项作为一个 enum typedef值放进去。 (不过开关项用bit操作貌似更方便，只是bit操作受整数位数的限制，适合在开关数量很少的情况下使用。--译者)
- 想做像某宝那样多条件筛选宝贝？你可以深入研究一下 `NSPredicate`. 另外一种可供参考的 解决方案是为每个条件创建一个 `NSIndexSet` 实例，该实例包含所有满足该条件的宝贝的索引值。 然后根据用户筛选条件对这些 `NSIndexSet` 实例取并集或者交集。
总的来说， `NSIndexSet` 是一个很实用的类。 它没有其它容器类华丽，但是它有它特定的实用场合。 至少， Foundation 自己用它用的非常多。