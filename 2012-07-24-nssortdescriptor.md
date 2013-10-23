---
layout: post
title: NSSortDescriptor

ref: "https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSSortDescriptor_Class/Reference/Reference.html"
framework: Foundation
rating: 8.4
---

Sorting: it's the mainstay of Computer Science 101 exams and whiteboarding interview questions. But when was the last time you actually needed to know how to implement Quicksort yourself? 

When making apps, sorting is just something you can assume to be fast, and utility is a function of convenience and clarity of intention. And when it comes to that, you'd be hard-pressed to find a better implementation than Foundation's `NSSortDescriptor`.

* * *

`NSSortDescriptor` objects are constructed with the following parameters:

> - `key`: for a given collection, the key for the corresponding value to be sorted on for each object in the collection.
> - `ascending`: a boolean specifying whether the collection should be sorted in ascending (`YES`) or descending (`NO`) order.

There is an optional third parameter that relates to how the sorted values are compared to one another. By default, this is a simple equality check, but this behavior can be changed by passing either a `selector` (`SEL`) or `comparator` (`NSComparator`). 

> Any time you're sorting user-facing strings, be sure to pass the selector `localizedStandardCompare:`, which will sort according to the language rules of the current locale (locales may differ on ordering of case, diacritics, and so forth).

Collection classes like `NSArray` and `NSSet` have methods to return sorted arrays of the objects that take an array of `sortDescriptors`. Sort descriptors are applied in order, so that if two elements happen to be tied for a particular sorting criteria, the tie is broken by any subsequent descriptors.

To put that into more practical terms, consider a `Person` class with properties for `firstName` & `lastName` of type `NSString *`, and `age`, which is an `NSUInteger`. 

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

Given the following dataset:

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

Here are some of the different ways they can be sorted by combinations of `NSSortDescriptor`:

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

`NSSortDescriptor` can be found throughout Foundation and other system frameworks, playing an especially prominent role in Core Data. Anytime your own classes need to define sort ordering, follow the convention of specifying a `sortDescriptors` parameter as appropriate.

Because, in reality, sorting should be thought of in terms of business logic, not mathematical formulas and map-reduce functions. In this respect, `NSSortDescriptor` is a slam dunk, and will have you pining for it anytime you venture out of Objective-C and Cocoa.
