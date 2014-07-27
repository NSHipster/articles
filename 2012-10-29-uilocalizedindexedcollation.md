---
layout: post
title: UILocalizedIndexedCollation

ref: "http://developer.apple.com/library/ios/#documentation/iPhone/Reference/UILocalizedIndexedCollation_Class/UILocalizedIndexedCollation.html"
category: UIKit
rating: 7.1
published: true
translator: "Tony Li"
description: 当 UITableView 有一百来行时，它就变得有些笨重了。如果用户为了找到他们想要的东西，像玩水果忍者的猫那样疯狂地滑动屏幕时，你可能会想要重新考虑一下用户界面的展现方式。
---

当 UITableView 有一百来行时，它就变得有些笨重了。如果用户为了找到他们想要的东西，像[玩水果忍者的猫](http://www.youtube.com/watch?v=CdEBgZ5Y46U)那样疯狂地滑动屏幕时，你可能会想要重新考虑一下用户界面的展现方式。

那么，你可以做些什么呢？

首先，你可以按层级的方式组织你的数据，基于层级的[分支数](http://en.wikipedia.org/wiki/Branching_factor)，这种方式可以很明显地减少每个节目上的行数。

同时，你也可以在列表上方加个 `UISearchBar`，允许用户根据关键字过滤，从而找到他们想要的东西（或者，也许更重要的是，看他们想要找的东西在不在列表里）。

还有第三种在 iOS 应用中并没有被很好利用的办法：**区域索引标题（section index titles）**。它们是在列表右边纵向排列的字母，你可以在电话本联系人界面和音乐曲库界面中看到它们。

![Section Index Titles Example](http://nshipster.s3.amazonaws.com/uilocalizedindexedcollation-example.png)

当用户在那个列表里向下移动手指时，列表会在对应的区域间跳动。这会使得冗长的列表视图变得超级好用。

可以通过实现下列 `UITableViewDataSource` 中的方法来显示区域索引标题：

- `-sectionIndexTitlesForTableView:` —— 返回一个区域索引标题的数组，用于在列表右边显示，例如字母序列 A...Z 和 #。区域索引标题很短，通常不能多于两个 Unicode 字符。

- `-tableView:sectionForSectionIndexTitle:atIndex:` —— 返回当用户触摸到某个索引标题时列表应该跳至的区域的索引。

NSHipster 的老读者可能已经猜到了，我们肯定不想自己去生成这个字母列表。对于不同的地区来说，字母的顺序，甚至「字母」，的意义都会大不相同。

`UILocalizedIndexedCollation` 来拯救我们了。

---

`UILocalizedIndexedCollation` 是一个帮助我们组织列表数据的类，它能够根据地区来生成与之对应区域索引标题。不需要直接创建它的对象，我们可以通过 `UILocalizedIndexedCollation +currentCollation` 获得一个对应当前地区的单例对象。

`UILocalizedIndexedCollation` 的首要任务就是决定对于当前地区区域索引标题应该是什么，我们可以通过 `sectionIndexTitles` 属性来获得它们。

下表可以帮助你更好的了解不同地区之间区域索引标题的差别。

> 如果你自己想要看这些的话，你需要把对应的地区加入到你的项目本地化列表中。

<table>
  <thead>
    <tr>
      <th>Locale</th>
      <th>Section Index Titles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>en_US</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, #</tt></td>
    </tr>
    <tr>
      <td>ja_JP</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, あ, か, さ, た, な, は, ま, や, ら, わ, #</tt></td>
    </tr>
    <tr>
      <td>sv_SE</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, Å, Ä, Ö, #</tt></td>
    </tr>
    <tr>
      <td>ko_KO</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, ㄱ, ㄴ, ㄷ, ㄹ, ㅁ, ㅂ, ㅅ, ㅇ, ㅈ, ㅊ, ㅋ, ㅌ, ㅍ, ㅎ, #</tt></td>
    </tr>
    <tr>
      <td>ar_SA</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, آ, ب, ت, ث, ج, ح, خ, د, ذ, ر, ز, س, ش, ص, ض, ط, ظ, ع, غ, ف, ق, ك, ل, م, ن, ه, و, ي, #</tt></td>
    </tr>
  </tbody>
</table>

你难道不为不用自己做这些事情而高兴吗？

有了你面前的这些区域标题，下一步就是判断每个模型对象分别对应哪个区域了。这可以通过实现 `-sectionForObject:collationStringSelector:` 做到。这个方法返回 `NSInteger` 类型的索引，它对应了模型对象的指定方法的返回值。方法名称可以为 `localizedName`、`title` 甚至 `description` 等。

显而易见，列表数据源中会有一个数组，它对应了列表中有多少区域，数组元素表示区域中的每一行。由于整理工作是由 `UILocalizedIndexedCollation` 来做的，因此理所当然地，也应该由它来为每个区域中的行进行排序。和 `-sectionForObject:collationStringSelector:` 的实现方式类似，`– sortedArrayFromArray:collationStringSelector:` 可以为我们基于模型对象的本地化标题来排列模型对象。

最后，数据源应该实现 `-tableView:sectionForSectionIndexTitle:atIndex:` 方法，这样当我们触摸到区域索引标题时，能够让列表调至对应的区域。`UILocalizedIndexedCollation -sectionForSectionIndexTitleAtIndex:` 可以轻松帮我们做到。

都说完了，下边是列表数据源的一个常见实现：

~~~{objective-c}
- (void)setObjects:(NSArray *)objects {
    SEL selector = @selector(localizedTitle);
    NSInteger index, sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];

    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
      [mutableSections addObject:[NSMutableArray array]];
    }

    for (id object in objects) {
      NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:selector];
      [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }

    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
      NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
      [mutableSections replaceObjectAtIndex:idx withObject:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:objectsForSection collationStringSelector:selector]];
    }

    self.sections = mutableSections;

    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}
~~~

## UITableViewIndexSearch

有一个特殊的区域索引标题需要提一下：`UITableViewIndexSearch`。列表中一般同时会有搜索框和区域索引。为了方便同时也保持视觉上的一致性，通常第一个区域索引处会放个搜索图标，当你触摸这个图标时，列表会滑至顶部的搜索框区域。

为了在列表右边可以看到搜索图标，你需要把 `UITableViewIndexSearch` 这个 `NSString` 常量插入到 `-sectionIndexTitlesForTableView:` 返回值的前边，并且调整 `-tableView:sectionForSectionIndexTitle:atIndex:` 使得它返回正确的区域索引。

---

请所有的 NSHipsters 记住：如果你看到了一个超长的列表，那就一把火把它烧掉！

……其实是说，要用层级、搜索框以及区域索引标题来改变展现方式。当你要实现区域索引标题时，可以用 `UILocalizedIndexedCollation` 来帮你。

我们都这样做了之后，那就能够摆脱因滑动超长列表而带来的压力，从而可以花更多的时间享受更美好的事情，比如看些宠物玩 iPad 的视频。
