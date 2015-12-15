---
title: NSDataDetector
author: Mattt Thompson
category: Cocoa
tags: nshipster
excerpt: "Until humanity embraces RDF for all of their daily interactions, a large chunk of artificial intelligence is going to go into figuring out what the heck we're all talking about. Fortunately for Cocoa developers, there's NSDataDetector."
translator: April Peng
excerpt: "当人类在他们所有的日常交往中都使用 RDF 后，人工智能的一大任务就是要去搞清楚到底我们都在谈论什么。幸运的是，对于 Cocoa 开发者来说，我们有 NSDataDetector。"
---

Machines speak in binary, while humans speak in riddles, half-truths, and omissions.

机器只用二进制说话，而人类的语言却充满了谜语，真假，和省略。

And until humanity embraces [RDF](http://en.wikipedia.org/wiki/Resource_Description_Framework) for all of their daily interactions, a large chunk of artificial intelligence is going to go into figuring out what the heck we're all talking about.

当人类在他们所有的日常交往中都使用 [RDF](http://en.wikipedia.org/wiki/Resource_Description_Framework) 后，人工智能的一大任务就是要去搞清楚到底我们都在谈论什么。

Because in the basic interactions of our daily lives—meeting people, making plans, finding information online—there is immense value in automatically converting from implicit human language to explicit structured data, so that it can be easily added to our calendars, address books, maps, and reminders.

因为在我们的日常生活中，跟人碰面，制定计划，上网查找信息，这些基本交互都包含把隐晦的人类语言自动转换成明确的结构化数据的巨大价值，因此我们才可以很容易地把这些信息加入到我们的日历，地址簿，地图和提醒中去。

Fortunately for Cocoa developers, there's an easy solution: `NSDataDetector`.

幸运的是，对于 Cocoa 开发者来说，有一个简单的解决方案：`NSDataDetector`。

---

`NSDataDetector` is a subclass of [`NSRegularExpression`](https://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSRegularExpression_Class/Reference/Reference.html), but instead of matching on an ICU pattern, it detects semi-structured information: dates, addresses, links, phone numbers and transit information.

`NSDataDetector` 是 [`NSRegularExpression`](https://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSRegularExpression_Class/Reference/Reference.html) 的子类，而不只是一个 ICU 的模式匹配，它可以检测半结构化的信息：日期，地址，链接，电话号码和交通信息。

It does all of this with frightening accuracy. `NSDataDetector` will match flight numbers, address snippets, oddly formatted digits, and even relative deictic expressions like "next Saturday at 5".

它以惊人的准确度完成这一切。`NSDataDetector` 可以匹配航班号，地址段，奇怪的格式化了的数字，甚至是相对的指示语，如 “下周六五点”。

You can think of it as a regexp matcher with incredibly complicated expressions that can extract information from natural language (though its actual implementation details may be somewhat more complicated than that).

你可以把它看成是一个有着复杂的令人难以置信的正则表达式匹配，可以从自然语言提取信息（尽管实际的实现细节可能比这个复杂得多）。

`NSDataDetector` objects are initialized with a bitmask of types of information to check, and then passed strings to match on. Like `NSRegularExpression`, each match found in a string is represented by a `NSTextCheckingResult`, which has details like character range and match type. However, `NSDataDetector`-specific types may also contain metadata such as address or date components.

`NSDataDetector` 对象用一个需要检查的信息的位掩码类型来初始化，然后传入一个需要匹配的字符串。像 `NSRegularExpression` 一样，在一个字符串中找到的每个匹配是用 `NSTextCheckingResult` 来表示的，它有诸如字符范围和匹配类型的详细信息。然而，`NSDataDetector` 的特定类型也可以包含元数据，如地址或日期组件。

~~~{swift}
let string = "123 Main St. / (555) 555-5555"
let types: NSTextCheckingType = .Address | .PhoneNumber
var error: NSError?
let detector = NSDataDetector(types: types.rawValue, error: &error)
detector.enumerateMatchesInString(string, options: nil, range: NSMakeRange(0, (string as NSString).length)) { (result, flags, _) in
    println(result)
}
~~~

~~~{objective-c}
NSError *error = nil;
NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress
                                                        | NSTextCheckingTypePhoneNumber
                                                           error:&error];

NSString *string = @"123 Main St. / (555) 555-5555";
[detector enumerateMatchesInString:string
                           options:kNilOptions
                             range:NSMakeRange(0, [string length])
                        usingBlock:
^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
  NSLog(@"Match: %@", result);
}];
~~~

> When initializing `NSDataDetector`, be sure to specify only the types you're interested in. With each additional type to be checked comes a nontrivial performance cost.

> 当初始化 `NSDataDetector` 的时候，确保只指定你感兴趣的类型。每当增加一个需要检查的类型，随着而来的是不小的性能损失为代价。

## Data Detector Match Types

## 数据检测器匹配类型

Because of how much `NSTextCheckingResult` is used for, it's not immediately clear which properties are specific to `NSDataDetector`. For your reference, here is a table of the different `NSTextCheckingTypes` for `NSDataDetector` matches, and their associated properties:

因为 `NSTextCheckingResult` 有众多用途，并不能立即清楚其属性是否是特定于 `NSDataDetector`。为了供您参考，下面是 `NSDataDetector` 的各种 `NSTextCheckingTypes` 匹配，及其相关属性表：

<table>
  <thead>
    <tr>
      <th>类型</th>
      <th>属性</th>
    </tr>
  </thead>
  <tbody>

    <tr>
      <td><tt>NSTextCheckingTypeDate</tt></td>
      <td>
        <ul>
          <li><tt>date</tt></li>
          <li><tt>duration</tt></li>
          <li><tt>timeZone</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>NSTextCheckingTypeAddress</tt></td>
      <td>
        <ul>
          <li><tt>addressComponents</tt><sup>*</sup></li>
          <ul>
            <li><tt>NSTextCheckingNameKey</tt></li>
            <li><tt>NSTextCheckingJobTitleKey</tt></li>
            <li><tt>NSTextCheckingOrganizationKey</tt></li>
            <li><tt>NSTextCheckingStreetKey</tt></li>
            <li><tt>NSTextCheckingCityKey</tt></li>
            <li><tt>NSTextCheckingStateKey</tt></li>
            <li><tt>NSTextCheckingZIPKey</tt></li>
            <li><tt>NSTextCheckingCountryKey</tt></li>
            <li><tt>NSTextCheckingPhoneKey</tt></li>
          </ul>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>NSTextCheckingTypeLink</tt></td>
      <td>
        <ul>
          <li><tt>url</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>NSTextCheckingTypePhoneNumber</tt></td>
      <td>
        <ul>
          <li><tt>phoneNumber</tt></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><tt>NSTextCheckingTypeTransitInformation</tt></td>
      <td>
        <ul>
          <li><tt>components</tt><sup>*</sup></li>
          <ul>
            <li><tt>NSTextCheckingAirlineKey</tt></li>
            <li><tt>NSTextCheckingFlightKey</tt></li>
          </ul>
        </ul>
      </td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td colspan="2"><sup>*</sup> <tt>NSDictionary</tt> properties have values at defined keys.
  </tfoot>
</table>

## Data Detection on iOS

## 在 iOS 做数据检测

Somewhat confusingly, iOS also defines `UIDataDetectorTypes`. A bitmask of these values can be set as the `dataDetectorTypes` of a `UITextView` to have detected data automatically linked in the displayed text.

有点混乱的是，iOS 也定义了 `UIDataDetectorTypes`。这些位掩码的值可以设置成一个 `UITextView` 的 `dataDetectorTypes`，来自动检测显示的文本。

`UIDataDetectorTypes` is distinct from `NSTextCheckingTypes` in that equivalent enum constants (e.g. `UIDataDetectorTypePhoneNumber` and `NSTextCheckingTypePhoneNumber`) do not have the same integer value, and not all values in one are found in the other. Converting from `UIDataDetectorTypes` to `NSTextCheckingTypes` can be accomplished with a function:

`UIDataDetectorTypes` 和 `NSTextCheckingTypes` 相同的那些枚举常量其实是不同的（如 `UIDataDetectorTypePhoneNumber` 和 `NSTextCheckingTypePhoneNumber`），他们的整数值并不一样，而且一个中的所有值也并不能在另外一个里面都能找到。可以用以下方法把 `UIDataDetectorTypes` 转换为 `NSTextCheckingTypes`：

~~~{swift}
func NSTextCheckingTypesFromUIDataDetectorTypes (dataDetectorType: UIDataDetectorTypes) -> NSTextCheckingType {
    var textCheckingType: NSTextCheckingType = nil
    
    if dataDetectorType & .Address != nil {
        textCheckingType |= .Address
    }
    
    if dataDetectorType & .CalendarEvent != nil {
        textCheckingType |= .Date
    }
    
    if dataDetectorType & .Link != nil {
        textCheckingType |= .Link
    }
    
    if dataDetectorType & .PhoneNumber != nil {
        textCheckingType |= .PhoneNumber
    }
    
    return textCheckingType
}
~~~
~~~{objective-c}
static inline NSTextCheckingType NSTextCheckingTypesFromUIDataDetectorTypes(UIDataDetectorTypes dataDetectorType) {
    NSTextCheckingType textCheckingType = 0;
    if (dataDetectorType & UIDataDetectorTypeAddress) {
        textCheckingType |= NSTextCheckingTypeAddress;
    }

    if (dataDetectorType & UIDataDetectorTypeCalendarEvent) {
        textCheckingType |= NSTextCheckingTypeDate;
    }

    if (dataDetectorType & UIDataDetectorTypeLink) {
        textCheckingType |= NSTextCheckingTypeLink;
    }

    if (dataDetectorType & UIDataDetectorTypePhoneNumber) {
        textCheckingType |= NSTextCheckingTypePhoneNumber;
    }

    return textCheckingType;
}
~~~

---

Do I detect some disbelief of how easy it is to translate between natural language and structured data? This should not be surprising, given how [insanely](http://nshipster.com/cfstringtransform/) [great](http://nshipster.com/nslinguistictagger/) Cocoa's linguistic APIs are.

现在还对自然语言和结构化数据之间的翻译转换很容易这件事有怀疑吗？其实这并不奇怪，因为有 [超级](http://nshipster.com/cfstringtransform/) [棒](http://nshipster.com/nslinguistictagger/) 的 Cocoa 语言 API。

Don't make your users re-enter information by hand just because of a programming oversight. Take advantage of `NSDataDetector` in your app to unlock the structured information already hiding in plain sight.

不要让你的用户因为一个程序的疏忽而重新输入信息。在你的应用程序里充分利用 `NSDataDetector` 解锁那些已经隐藏在众目睽睽下的结构化信息吧。
