---
layout: post
title: NSSortDescriptor
author: Mattt Thompson
translator: "Zihan Xu"
category: Foundation
---

排序：它是CS（计算机科学）入门课程考试和初级编程面试白板考题的主流考题。不管怎么样，你上一次真正需要知道如何实现快速排序是什么时侯？

当制作应用时，你只需要假设排序是快速的，而它的功用的衡量标准是你完成所需要任务的容易程度。从这个角度考虑，Foundation的`NSSortDescriptor`大概是你能找到的最有用，最优雅的实现了。

* * *

`NSSortDescriptor`由下述参数组成	：

- `键`：对于一个给定的集合，对应值的键位将对集合中的每个对象进行排序。
- `升序`：指定一个集合是否按照升序（`YES`）还是降序（`NO`）进行排序的布尔值。

另外`NSSortDescriptor`还有一个涉及到排序的值之间的比较的第三个可选参数。默认情况下，这是一个简单的相等性检查，但它的行为可以通过传递一个`选择器`（`SEL`）或者`比较器`（`NSComparator`）而发生改变。

> 任何时候当你在为面向用户的字符串排序时，一定要加入`localizedStandardCompare:`选择器，它将根据当前语言环境的语言规则进行排序（语言环境可能会根据大小写，变音符号等等的顺序而发生改变）。

有的集合（比如`NSArray`和`NSSet`）有以`sortDescriptors`作为参数，可以返回排过序的数组的方法。排序描述符按顺序应用，所以如果两个元素碰巧被捆绑在同一个特定的排序标准，束缚将被后续的任意描述符所打破。

为了更直观的描述，假设我们有一个`Person`对象，它具有`NSString *`类型的`姓`和`名`属性，和`NSUInteger`类型的`年龄`属性。

~~~{objective-c}
@interface Person : NSObject
@property NSString *firstName;
@property NSString *lastName;
@property NSNumber *age;
@end

@implementation Person

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
~~~

给定以下数据集：

<table>
  <thead>
    <tr>
      <th><tt>index</tt></th>
      <th>0</th>
      <th>1</th>
      <th>2</th>
      <th>3</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><tt>firstName</tt></td>
      <td>Alice</td>
      <td>Bob</td>
      <td>Charlie</td>
      <td>Quentin</td>
    </tr>
    <tr>
      <td><tt>lastName</tt></td>
      <td>Smith</td>
      <td>Jones</td>
      <td>Smith</td>
      <td>Alberts</td>
    </tr>
    <tr>
      <td><tt>age</tt></td>
      <td>24</td>
      <td>27</td>
      <td>33</td>
      <td>31</td>
    </tr>
  </tbody>
</table>

以下是几种使用`NSSortDescriptor`的不同组合来将它们排序的方法：

~~~{objective-c}
NSArray *firstNames = @[ @"Alice", @"Bob", @"Charlie", @"Quentin" ];
NSArray *lastNames = @[ @"Smith", @"Jones", @"Smith", @"Alberts" ];
NSArray *ages = @[ @24, @27, @33, @31 ];

NSMutableArray *people = [NSMutableArray array];
[firstNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    Person *person = [[Person alloc] init];
    person.firstName = [firstNames objectAtIndex:idx];
    person.lastName = [lastNames objectAtIndex:idx];
    person.age = [ages objectAtIndex:idx];
    [people addObject:person];
}];

NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName"
  ascending:YES
  selector:@selector(localizedStandardCompare:)];
NSSortDescriptor *lastNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName"
  ascending:YES
  selector:@selector(localizedStandardCompare:)];
NSSortDescriptor *ageSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"age"
  ascending:NO];

NSLog(@"By age: %@", [people sortedArrayUsingDescriptors:@[ageSortDescriptor]]);
// "Charlie Smith", "Quentin Alberts", "Bob Jones", "Alice Smith"


NSLog(@"By first name: %@", [people sortedArrayUsingDescriptors:@[firstNameSortDescriptor]]);
// "Alice Smith", "Bob Jones", "Charlie Smith", "Quentin Alberts"


NSLog(@"By last name, first name: %@", [people sortedArrayUsingDescriptors:@[lastNameSortDescriptor, firstNameSortDescriptor]]);
// "Quentin Alberts", "Bob Jones", "Alice Smith", "Charlie Smith"
~~~

* * *

`NSSortDescriptor`在Foundation和其他系统框架中随处可见，它在Core Data中发挥着极其重要的作用。如果你自己的类需要定义排序顺序，请按照惯例合理设置`sortDescriptors`参数。

因为，在现实中，你应该以商业逻辑来思考它，而不是用数学公式或者映射化简函数来考量它。在这一方面，`NSSortDescriptor`是一个大灌篮，以至于每当你走出Objective-C和Cocoa的世界时都会思念它。
