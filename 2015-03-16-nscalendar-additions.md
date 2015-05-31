---
title: NSCalendar Additions
author: Nate Cook
translator: GWesley
category: "Cocoa"
excerpt: " `NSCalendar` 已经悄悄的构建了大量的方法方便大家获取和操作日期。 从全新的日期组件存取与日期比较方法，到强大的日期插值与枚举方法，有太多的东西被我们忽视了。接下来让我们抽点时间来了解一下吧。"
---

*日期.* 一个很普通的时间和它的实现间往往有着巨大的差异，里面隐藏的多方面的复杂性远超其它数据类型。其中包括亚秒级的精度，重叠单元，不同地理位置的时区边界，语言和语法上的本地化差异，以及为了夏令时的转换和闰年调整，而在标准时间中添加删除整块的时间等等，里面有太多的东西需要进行处理。

在开始进行任何重度日期相关的任务前，我们有必要深入了解一下我们手中已有的工具。相比写上上千个版本的 `dateIsTomorrow`，我觉得更好的办法是使用 `Foundation` 方法。你有在用 `NSDateComponents` 吗？你有指定正确的日历单元吗？你的代码在 2100 年 2 月 28 号还能正常工作么？

但事实上：大家一直都在使用那些已经非常熟悉了的 APIs 。除非你跑去考察版本说明和 API 变动表，不然你肯定不会知道最近发布的几个 OS X 版本里，`NSCalendar` 已经添加了一系列功能十分强大的方法去操作计算日期，最近的一次发布让我们可以在 iOS 中使用这些方法。

```swift
let calendar = NSCalendar.currentCalendar()
```
```objective-c
NSCalendar *calendar = [NSCalendar currentCalendar];
```

从全新的日期组件存取与日期比较方法，到强大的日期插值与枚举方法，有太多的东西被我们忽视了。接下来让我们抽点时间来了解一下吧。

## 便利的日期组件存取

哇, `NSDateComponents` 真是既实用又灵活，但当我只是想知道现在是多少小时的时候，它用起来感觉又太麻烦了。不要慌， `NSCalendar` 来救你了！

```swift
let hour = calendar.component(.CalendarUnitHour, fromDate: NSDate())
```
```objective-c
NSInteger hour = [calendar component:NSCalendarUnitHour fromDate:[NSDate date]];
```
这样就好多了。`NSCalendar`，你还有哪些本事？

> - `getEra(_:year:month:day:fromDate:)`：根据传入的日期引用返回纪元，年，月，日。不需要的参数可以传入 `nil`/`NULL`。 
> - `getEra(_:yearForWeekOfYear:weekOfYear:weekday:fromDate:)`: 根据传入的日期引用返回纪元，年，当年第几周，星期几。不需要的参数可以传入 `nil`/`NULL`。
> - `getHour(_:minute:second:nanosecond:fromDate:)`: 根据传入的日期引用返回时间信息，然后 `nil`/`NULL` 巴拉巴拉, 你懂的。

`NSDateComponents`，刚才我是逗你玩呢，我收回前面吐槽你话。下面还有不少属于你的方法：

> - `componentsInTimeZone(_:fromDate:)`: 根据传入的的日期和时区返回一个 `NSDateComponents` 实例。
> - `components(_:fromDateComponents:toDateComponents:options:)`: 返回两个 `NSDateComponents` 实例间的差异。如果有未赋值的组件，该方法会使用默认值，所以我们传入的实例至少得设置了年属性。options参数暂时没有用，传 `nil`/`0` 就行。

## 日期比较

虽然直接比较 `NSDate` 是件挺简单的事，但一些更有意义的比较可能变得惊人的复杂。两个 `NSDate` 实例是同一天？同一小时？亦或是同一周？

现在没必要发愁了，`NSCalendar` 提供了大量的比较方法：

> - `isDateInToday(_:)`: 如果传入的日期是当天返回 `true` 。
> - `isDateInTomorrow(_:)`: 如果传入的日期是明天返回 `true` 。
> - `isDateInYesterday(_:)`: 如果传入的日期是昨天返回 `true` 。
> - `isDateInWeekend(_:)`: 如果传入的日期是周末返回 `true` 。
> - `isDate(_:inSameDayAsDate:)`: 如果两个 `NSDate` 实例在同一天返回 `true` - 没必要再去获取日期部件进行比较了。
> - `isDate(_:equalToDate:toUnitGranularity:)`: 如果传入的日期在同一指定单位内返回 `true` 。这意味着，两个在同一周的日期实例调用 `calendar.isDate(tuesday, equalToDate: thursday, toUnitGranularity: .CalendarUnitWeekOfYear)` 方法时会返回 `true` ，就算他们不在同一个月也是如此。
> - `compareDate(_:toDate:toUnitGranularity:)`: 返回一个`NSComparisonResult`，当做和任何指定区间内的日期相等。
> - `date(_:matchesComponents:)`: 如果日期匹配指定的部件返回 `true` 。


## 日期插值

接下来讲一些根据起始点寻找下一个日期的方法。你可以基于一个 `NSDateComponents` 实例，一个指定的日期组件，或者特定的时分秒，去找到下一个（或上一个）日期。所有这些方法都需要一个 `NSCalendarOptions` 位参数去提供更加精细的控制，特别是一开始我们没能找到准确的匹配的时候，它可以帮我们确定如何选定下一个日期。

### `NSCalendarOptions`

最简单的 `NSCalendarOptions` 选项是 `.SearchBackwards`，使用它我们可以在所有方法中进行反向搜索。反向搜索和正向搜索得到的结果是类似的。举个例子，反向搜索 11 之前的一个 `小时` 会给你返回 11：00， 而不是 11：59， 虽然在反向搜索中 11：59 严格意义上来讲是比 11：00 “早”。确实，反向搜索咋一看是符合直觉的，但想多了很可能会把你绕进去。既然`.SearchBackwards` 是已经是最简单的选项，你大概能才猜到后面都是些什么鬼。

接下来的 `NSCalendarOptions` 选项能够帮助我们处理那些 “消失” 的时间。举个最直观的例子来说，当你进行一个短时窗搜索时碰到夏令时调整，时间提前了一个小时。或者搜索时遇到类似 2 月 或者 4 月 31 号，它都能帮我们跳过这些缺失的时间。

当遇到缺失的时间时，如果我们设置了 `NSCalendarOptions.MatchStrictly`，相关方法会根据传入的组件寻找一个 `精确` 的匹配。如果没有设置的话，那么必须提供`.MatchNextTime`, `.MatchNextTimePreservingSmallerUnits`, 和 `.MatchPreviousTimePreservingSmallerUnits` 中的任一项。这些选项决定了如何处理我们请求时遇到的时间缺失问题。

这种情况，往往一例胜千言：

```swift
// 2015 年情人节，早上 9 点
let valentines = cal.dateWithEra(1, year: 2015, month: 2, day: 14, hour: 9, minute: 0, second: 0, nanosecond: 0)!

// 为了找到月的最后一天， 我设置一个日期组件然后把 `day` 设成 31：
let components = NSDateComponents()
components.day = 31
```
```objective-c
NSDate *valentines = [calendar dateWithEra:1 year:2015 month:2 day:14 hour:9 minute:0 second:0 nanosecond:0];
    
NSDateComponents *components = [[NSDateComponents alloc] init];
components.day = 31;
```

使用精确匹配会在三月找到下个 `31` 号，如下：

```swift
calendar.nextDateAfterDate(valentines, matchingComponents: components, options: .MatchStrictly)
// Mar 31, 2015, 12:00 AM
```
```objective-c
NSDate *date = [calendar nextDateAfterDate:valentines matchingComponents:components options:NSCalendarMatchStrictly];
// Mar 31, 2015, 12:00 AM
```

不使用精确匹配的话，`nextDateAfterDate` 方法会在找到匹配的指定天数前就在二月底停了下来，然后在下个月继续寻找。 可见，你所提供的选项决定了最终返回的具体日期。举例来说，使用`.MatchNextTime` 选项找到下一个合适的日子：

```swift
calendar.nextDateAfterDate(valentines, matchingComponents: components, options: .MatchNextTime)
// Mar 1, 2015, 12:00 AM
```
```objective-c
date = [calendar nextDateAfterDate:valentines matchingComponents:components options:NSCalendarMatchNextTime];
// Mar 1, 2015, 12:00 AM
```

类似的，当使用 `.MatchNextTimePreservingSmallerUnits` 选项时会找到下一天，但是所有比指定单元 `NSCalendarUnitDay` 要小的单元会被保留下来：

```swift
calendar.nextDateAfterDate(valentines, matchingComponents: components, options: .MatchNextTimePreservingSmallerUnits)
// Mar 1, 2015, 9:00 AM
```
```objective-c
date = [calendar nextDateAfterDate:valentines matchingComponents:components options:NSCalendarMatchNextTimePreservingSmallerUnits];
// Mar 1, 2015, 9:00 AM
```

最后， 使用 `.MatchPreviousTimePreservingSmallerUnits` 选项会在 *另一个* 方向上解决缺失的时间问题， 和前面一样，保留较小的单元，然后找到匹配的前一天：

```swift
calendar.nextDateAfterDate(valentines, matchingComponents: components, options: .MatchPreviousTimePreservingSmallerUnits)
// Feb 28, 2015, 9:00 AM
```
```objective-c
date = [calendar nextDateAfterDate:valentines matchingComponents:components options:NSCalendarMatchPreviousTimePreservingSmallerUnits];
// Feb 28, 2015, 9:00 AM
```

除了这里的 `NDateComponents` 外，还值得注意的是 `nextDateAfterDate` 方法有两种变化：

```swift
// 匹配指定的日历单元
cal.nextDateAfterDate(valentines, matchingUnit: .CalendarUnitDay, value: 31, options: .MatchStrictly)
// March 31, 2015, 12:00 AM

// 匹配时，分，秒
cal.nextDateAfterDate(valentines, matchingHour: 15, minute: 30, second: 0, options: .MatchNextTime)
// Feb 14, 2015, 3:30 PM
```
```objective-c
// 匹配指定的日历单元
date = [calendar nextDateAfterDate:valentines matchingUnit:NSCalendarUnitDay value:31 options:NSCalendarMatchStrictly];
// March 31, 2015, 12:00 AM
    
// 匹配时，分，秒
date = [calendar nextDateAfterDate:valentines matchingHour:15 minute:30 second:0 options:NSCalendarMatchNextTime];
// Feb 14, 2015, 3:30 PM
```

### 枚举插值日期

`NSCalendar` 提供了一个API去枚举日期， 所以大家没有必要反复的调用`nextDateAfterDate` 方法。`enumerateDatesStartingAfterDate(_:matchingComponents:options:usingBlock:)` 方法根据提供的日期组件和选项，依次获取匹配的日期。可以将 `stop` 属性设为 `true` 去停止枚举。 

来试试这个 `NSCalendarOptions` 的新方法吧，下面展示了一种获取随后50个闰年的方法：

```swift
let leapYearComponents = NSDateComponents()
leapYearComponents.month = 2
leapYearComponents.day = 29

var dateCount = 0
cal.enumerateDatesStartingAfterDate(NSDate(), matchingComponents: leapYearComponents, options: .MatchStrictly | .SearchBackwards) 
{ (date: NSDate!, exactMatch: Bool, stop: UnsafeMutablePointer<ObjCBool>) in
    println(date)

    if ++dateCount == 50 {
        // .memory 用来获取一个 UnsafeMutablePointer 属性的值
        stop.memory = true
    }
}
// 2012-02-29 05:00:00 +0000
// 2008-02-29 05:00:00 +0000
// 2004-02-29 05:00:00 +0000
// 2000-02-29 05:00:00 +0000
// ...
```
```objective-c
NSDateComponents *leapYearComponents = [[NSDateComponents alloc] init];
leapYearComponents.month = 2;
leapYearComponents.day = 29;
    
__block int dateCount = 0;
[calendar enumerateDatesStartingAfterDate:[NSDate date]
                      matchingComponents:leapYearComponents
                                 options:NSCalendarMatchStrictly | NSCalendarSearchBackwards
                              usingBlock:^(NSDate *date, BOOL exactMatch, BOOL *stop) {
    NSLog(@"%@", date);
    if (++dateCount == 50) {
        *stop = YES;
    }
}];
// 2012-02-29 05:00:00 +0000
// 2008-02-29 05:00:00 +0000
// 2004-02-29 05:00:00 +0000
// 2000-02-29 05:00:00 +0000
// ...
```

### 处理周末 

要想找周末的话，记住下面两个 `NSCalendar` 方法就行：

> - `nextWeekendStartDate(_:interval:options:afterDate)`: 根据传入的前两个参数返回下个周末的开始时间个长度。如果当前的地区和日历未提供对周末属性的支持，该方法会返回 `false` 。唯一相关的属性是 `.SearchBackwards`。（例子在下面。）
> - `rangeOfWeekendStartDate(_:interval:containingDate)`: 根据传入的前两个参数返回 *包含* 该日期的周末。如果传入的日期并不在周末或者当前的地区和日历未提供对周末属性的支持，该方法会返回 `false` 。


## 本地化日期符号
 
似乎所有这些新功能还不够丰富似的， `NSCalendar` 还提供了一整套的本地化日期符号，用来快速获取月份名称，星期名称等等。每组符号都列举在两个轴上：(1) 符号的长度  (2) 它是作为标准名称还是日期的一部分。

理解这两个属性对本地化来说十分的重要，有些语言，特别是斯拉夫语言，会依据不同的内容使用不同的名词格。举例来说，一个日期要使用某个 `standaloneMonthSymbols` 的变体作为头，而不是使用 `monthSymbols` 去格式化日期。

下面这张表包含了 `NSCalendar` 提供的所有符号，供大家阅览，请注意俄语列中独立符号的不同之处：

| &nbsp; | en_US | ru_RU |
|--------|-------|-------|
| `monthSymbols` | January, February, March… | января, февраля, марта… |
| `shortMonthSymbols` | Jan, Feb, Mar… | янв., февр., марта… |
| `veryShortMonthSymbols` | J, F, M, A… | Я, Ф, М, А… |
| `standaloneMonthSymbols` | January, February, March… | Январь, Февраль, Март… |
| `shortStandaloneMonthSymbols` | Jan, Feb, Mar… | Янв., Февр., Март… |
| `veryShortStandaloneMonthSymbols` | J, F, M, A… | Я, Ф, М, А… |
| `weekdaySymbols` | Sunday, Monday, Tuesday, Wednesday… | воскресенье, понедельник, вторник, среда… |
| `shortWeekdaySymbols` | Sun, Mon, Tue, Wed… | вс, пн, вт, ср… |
| `veryShortWeekdaySymbols` | S, M, T, W… | вс, пн, вт, ср… |
| `standaloneWeekdaySymbols` | Sunday, Monday, Tuesday, Wednesday… | Воскресенье, Понедельник, Вторник, Среда… |
| `shortStandaloneWeekdaySymbols` | Sun, Mon, Tue, Wed… | Вс, Пн, Вт, Ср… |
| `veryShortStandaloneWeekdaySymbols` | S, M, T, W… | В, П, В, С… |
| `AMSymbol` | AM | AM |
| `PMSymbol` | PM | PM |
| `quarterSymbols` | 1st quarter, 2nd quarter, 3rd quarter, 4th quarter | 1-й квартал, 2-й квартал, 3-й квартал, 4-й квартал |
| `shortQuarterSymbols` | Q1, Q2, Q3, Q4 | 1-й кв., 2-й кв., 3-й кв., 4-й кв. |
| `standaloneQuarterSymbols` | 1st quarter, 2nd quarter, 3rd quarter, 4th quarter | 1-й квартал, 2-й квартал, 3-й квартал, 4-й квартал |
| `shortStandaloneQuarterSymbols` | Q1, Q2, Q3, Q4 | 1-й кв., 2-й кв., 3-й кв., 4-й кв. |
| `eraSymbols` | BC, AD | до н. э., н. э. |
| `longEraSymbols` | Before Christ, Anno Domini | до н.э., н.э. |

> *注：* 这些符号在 `NSDateFormatter` 中也可以使用。

## 你的每周Swift化

在 NSHipster 我们讨论 API 的时候会有一些 Swift 的版本，这渐渐变成了我们的特色。 甚至是在讨论这些全新的 `NSCalendar` API的时候，我们需要把前面的方法再打磨一下，将 `UnsafeMutablePointer` 参数替换为更符合语言习惯的元组返回值。

这里给大家介绍一个非常好用的 `NSCalendar` 扩展集（[ 点 我 ](https://gist.github.com/natecook1000/43976a66fa04e3fdb3c7)），有了它我们使用访问日期组件和搜索周末方法时，可以不用把值传进又传出。比如，获取指定的日期组件就变得简单的多：

```swift
// built-in
var hour = 0
var minute = 0
calendar.getHour(&hour, minute: &minute, second: nil, nanosecond: nil, fromDate: NSDate())

// Swift化
let (hour, minute, _, _) = calendar.getTimeFromDate(NSDate())
```

获取下一个周末的日期范围：

```swift
// built-in
var startDate: NSDate?
var interval: NSTimeInterval = 0
let success = cal.nextWeekendStartDate(&startDate, interval: &interval, options: nil, afterDate: NSDate())
if success, let startDate = startDate {
    println("start: \(startDate), interval: \(interval)")
}

// Swift化
if let nextWeekend = cal.nextWeekendAfterDate(NSDate()) {
    println("start: \(nextWeekend.startDate), interval: \(nextWeekend.interval)")
}
```

* * *

这下复杂的日历计算吓不到你们了。有了 `NSCalendar` 提供的这些新功能，你可以很快的解决你碰到的问题。


