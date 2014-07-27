---
layout: post
title: UICollectionView
category: UIKit
description: "从现在起，UICollectionView凭一己之力改变我们将要设计和开发iOS应用的方式。这并不是说，collection views是未知或模糊的。作为一个NSHipster，不仅仅是知道名不见经传的石头，更多是在它们家喻户晓、售罄一空之前就知道有前途。"
author: Mattt Thompson
translator: "JJ Mao"
---

`UICollectionView` 是一种新的 `UITableView` ，并且它极其重要。

这并不是说，collection views是未知或模糊的--任何一个去过有关它WWDC会议的或是在 iOS 6 beta 版上玩过的人都知道怎么回事。

记住，作为一个NSHipster，不仅仅是知道名不见经传的石头，更多是在它们家喻户晓、售罄一空之前就知道有前途。所以呢，在其他人发现之前，这儿有个关于大热门的概要：

---

`UICollectionView` 采用 `UITableView` 的熟知模式，并概括了他们作出任何可能的布局 (一般情况下，这是微不足道的)。

和 `UITableView` 一样，`UICollectionView` 是管理有序items集合的 `UIScrollView` 子类。由 _data source_ 管理的items在特定索引路径上提供有代表性的cell view。


然而，和 `UITableView` 不同的是，`UICollectionView` 不局限于垂直的单列布局。相反，collection view有一个 _layout_  对象，它决定子视图的位置，这类似于某些方面的data source。稍后将作详细介绍。

### Cell 视图

在另一个不同于早期table view的做法中，视图的回收过程有明显改善。

在 `-tableView:cellForRowAtIndexPath:` 中，开发者必须调用熟悉的咒语：
~~~{objective-c}
UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:...];
if (!cell) {
  cell = [[UITableViewCell alloc] initWithStyle:... reuseIdentifier:...];
}
~~~

谢天谢地，`UICollectionView` 不用这样了。如果没有可重用的cells，通过创建一个新的cell，`-dequeueReusableCellWithReuseIdentifier:forIndexPath:`确保返回一个有效对象。只需为特定的重用标识符注册一个 `UICollectionReusableView` 子类，一切都会自动工作。值得庆幸的是，iOS 6中 `UITableView` 也支持这种用法。

### Supplementary 视图

由于collection views没有被归入任何特定结构，"header" 和 "footer"视图的约定不是很适用。所以在它这个地方，collection views拥有可以与每个cell关联的
_supplementary views_。

每个cell可以有多个与之关联的supplementary views--每个命名为"kind"。正因如此，headers和footers仅仅是supplementary views所施展的一成功力。

关键在于supplementary views，即使最复杂的layout也可以被实现而不影响cells的语义完整性。`UITableView` hacks对于[`spacer.gif`](http://en.wikipedia.org/wiki/Spacer_GIF)就像 `UICollectionView` cells对于[semantic HTML](http://en.wikipedia.org/wiki/Semantic_HTML)。

### Decoration 视图

除了cell views和supplementary views，collections还有 _decoration views_。一个decoration view，顾名思义，是一种没有功能性用途的东西... 除了在网络上传播的[摒弃对anti-skeuomorphic狂热分子的仇恨](http://skeu.it)。不过说真的，如果你愿意给你的虚拟藏书应用镶嵌完美质感的木纹架子，这很可能是容易做到的，_对吗_？

有一点要记住的是，decoration views完全是由layout管理的，与cell或supplementary views不一样,它不在collection view data source的管辖范围内。

## Layouts和Layout属性

Layouts是使 `UICollectionView` 如此神奇的核心。把它们看作是CSS对于之前提到的collection cells的semantic HTML。

`UICollectionViewLayout` 是一个抽象的基类，用于定位cell views和它们的supplementary和decoration views。但不是将它直接归入子类，大多数应用喜欢使用或者将 `UICollectionViewFlowLayout` 归入子类。Flow layouts用一些线性概念覆盖了layouts的广义类，不管它是单行或单列或一格。

在你足够安心地了解了flow layouts的所有限制之前，你可以稳妥地从flow layouts开始学习。

每个cell view、supplemental view和decoration view 都有layout属性。想要知道layouts如何灵活，只需看看 `UICollectionViewLayoutAttributes` 对象的特性就知道了：

- `frame`
- `center`
- `size`
- `transform3D`
- `alpha`
- `zIndex`
- `hidden`

属性由你可能想要的那种委托方法指定：

- `-layoutAttributesForItemAtIndexPath:`
- `-layoutAttributesForSupplementaryViewOfKind:atIndexPath:`
- `-layoutAttributesForDecorationViewOfKind:atIndexPath:`

这是最酷的方法：

- `-layoutAttributesForElementsInRect:`

例如，你可以使用它来当items靠近屏幕边缘时淡出。或者，由于所有的layout属性特性是自动支持动画的，你可以用一套正确的3D transforms在短短几行代码里创建一个简陋的[cover flow](http://en.wikipedia.org/wiki/Cover_Flow) layout。

实际上，collection views甚至可以大规模的交换layouts，在不改变底层数据的情况下允许视图在不同模式下无缝交换。

---

自从有了iPad，iOS业界便弥漫着一种徘徊于原先iPhone的UI设计模式和对这种更新的、外形尺寸更大的需求之间的微妙而紧张的气氛。随着iPhone 5和"iPad mini"的传闻，要不是 `UICollectionView` (以及Auto-Layout)，这种紧张气氛可能导致整个iOS平台的衔接断裂。

Apple有无数种不同方式提供类似的功能（或者干脆不提供），但是一旦提供，他们在设计这类功能方面的确能够各个都是全垒打。

data source和layout接口之间简洁明了的逻辑分离；cell、supplementary和decoration视图之间明确的分工；一堆可继承拓展以及可通过UIKit自动实现动画的layout属性...大量的细心与智慧才组成了这些API。

因此，iOS应用的整个前景将会永远改变。有了collection views，我们的审美已经随着iPad应用的视觉和交互的整个重新定义而转变。

大家可能对collection views尚未熟悉，但是现在你可以说在它们还没流行起来之前就知道它们了。

>  为了方便在你的应用里使用这个collection view的新特性，同时也不会让你感觉必须提升iOS 6的使用率才能做到这件事，这儿有一个好消息：

> [Peter Steinberger](https://github.com/steipete) 发布了[PSTCollectionView](https://github.com/steipete/PSTCollectionView), _一个100% API-兼容的 `UICollectionView`替代物，它支持iOS 4.3+_ 。来看看!
