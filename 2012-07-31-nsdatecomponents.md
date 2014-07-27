---
layout: post
title: NSDateComponents
category: Foundation
author: Mattt Thompson
translator: Candyan
---

`NSDateComponents` 类在Foundation的日期和时间API中扮演着重要的角色。其本身并没有什么令人印象深刻的特征，仅仅是一个日期信息的容器（信息包括：月，年，月中的某天，年中的某周，或者是否是闰月)。然而，值得一提的是，在其结合 `NSCalendar`和`NSDateComponents` 类之后，日历格式的转换变得十分方便。

日期代表了时间中的某个特定时刻，而日期组件的表示则依赖于其所使用的日历系统。很多时候，这个表示形式会和我们大多数人使用的[Gregorian Calendar](http://en.wikipedia.org/wiki/Gregorian_calendar)有着很大的不同。例如[Islamic Calendar](http://en.wikipedia.org/wiki/Islamic_calendar)一年有354或者355天，而[Buddhist calendar](http://en.wikipedia.org/wiki/Buddhist_calendar)一年会有354，355，384或者385天。

## 从日期中提取日期组件

`NSDateComponents`类能够被手动初始化，但是在大多数时候，会使用`NSCalendar -components:fromDate:`来提取某个日期的日期组件。

~~~{objective-c}
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *date = [NSDate date];
[calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:date];
~~~

其中`components`参数是一个用来获取日期组件值的[掩码](http://zh.wikipedia.org/zh-cn/%E6%8E%A9%E7%A0%81)([bitmask](http://en.wikipedia.org/wiki/Bitmask))，有下面这些值可以选择：

- `NSEraCalendarUnit`
- `NSYearCalendarUnit`
- `NSMonthCalendarUnit`
- `NSDayCalendarUnit`
- `NSHourCalendarUnit`
- `NSMinuteCalendarUnit`
- `NSSecondCalendarUnit`
- `NSWeekCalendarUnit`
- `NSWeekdayCalendarUnit`
- `NSWeekdayOrdinalCalendarUnit`
- `NSQuarterCalendarUnit`
- `NSWeekOfMonthCalendarUnit`
- `NSWeekOfYearCalendarUnit`
- `NSYearForWeekOfYearCalendarUnit`
- `NSCalendarCalendarUnit`
- `NSTimeZoneCalendarUnit`

> 由于其计算所有可能值的开销很大，所以随后的计算只使用指定的值(用`|`来分割两个不同的值，使用位运算“或”操作)。

## 计算相对日期

`NSDateComponents`对象可以用来计算相对日期。使用 `NSCalendar -dateByAddingComponents:toDate:options:`方法来确定昨天，下周或者5小时30分钟之后的日期。

~~~{objective-c}
NSCalendar *calendar = [NSCalendar currentCalendar];
NSDate *date = [NSDate date];

NSDateComponents *components = [[NSDateComponents alloc] init];
[components setWeek:1];
[components setHour:12];

NSLog(@"1 week and twelve hours from now: %@", [calendar dateByAddingComponents:components toDate:date options:0]);
~~~

## 用Components来创建日期

`NSDateComponents`类最强大的特性也许就是能够通过组件反向创建`NSDate`对象。`NSCalendar -dateFromComponents:`就是用来实现这个目的的：

~~~{objective-c}
NSCalendar *calendar = [NSCalendar currentCalendar];

NSDateComponents *components = [[NSDateComponents alloc] init];
[components setYear:1987];
[components setMonth:3];
[components setDay:17];
[components setHour:14];
[components setMinute:20];
[components setSecond:0];

NSLog(@"Awesome time: %@", [calendar dateFromComponents:components]);
~~~

特别有意思的地方在于，这个方法除了正常的月/日/年方式之外，也可以用某些信息来确定一个日期。只要提供的信息能够唯一确定一个日期，你就会得到一个结果。例如：指定2013年的第316天，那么就会返回一个2013年12月11日0点0分0秒的`NSDate`对象（如果没有指定时间，时间组件的默认值是0）。

> 请注意：如果传入了一些前后矛盾的组件，那么就会返回一个丢失了信息的结果或者`nil`。

* * *

`NSDateComponents`及它跟`NSCalendar`的关系突显具有像Foundation一样严格的工程框架的明显优势。你也许不会每天做日历相关的计算，但当有这样的需要时，知道怎么使用`NSDateComponents`会让你从无数挫折中解脱出来。
