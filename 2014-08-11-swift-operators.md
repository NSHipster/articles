---
title: Swift Operators
author: Mattt Thompson
category: Swift
tags: swift
excerpt: "Operators in Swift are among the most interesting and indeed controversial features of this new language."
translator: Candyan
---

没有了语句，程序将会变成神马样子哪？一个包含了类，命名空间，条件语句，循环语句和的命名空间含义的大杂烩。

语句代表了一个程序可以做的事情。他们是可执行的执行力。

如果我们把一个语句拆开——例如 `1 + 2` ——分解成不同的组成部分，我们就会发现运算符和操作数这两部分：

|          1          |          +          |          2          |
|:-------------------:|:-------------------:|:-------------------:|
|       左操作数       |        运算符        |       右操作数       |

虽然这个表达式是线性的，但编译器会用树形表示或者 AST：

![1 + 2 AST]({{ site.asseturl }}/swift-operators-one-plus-two.svg)

复合语句，像 `1 + 2 + 3`

|       (1 + 2)       |          +          |          3          |
|:-------------------:|:-------------------:|:-------------------:|
|       左操作数       |        运算符        |       右操作数       |


![1 + 2 + 3 AST]({{ site.asseturl }}/swift-operators-one-plus-two-plus-three.svg)

或者，更复杂的语句，`1 + 2 * 3 % 4`，编译器会用运算符优先级来把表达式解析为单一语句：


|          1          |          +          |       ((2 * 3) % 4)       |
|:-------------------:|:-------------------:|:-------------------------:|
|       左操作数       |        运算符        |          右操作数          |


![1 + 2 * 3 % 4 AST]({{ site.asseturl }}/swift-operators-one-plus-two-times-three-mod-four.svg)

就像[你小学学过的](http://zh.wikipedia.org/wiki/%E9%81%8B%E7%AE%97%E6%AC%A1%E5%BA%8F)运算符优先级规则一样，它为复合语句提供了一套标准的运算次序。

```
1 + 2 * 3 % 4
1 + ((2 * 3) % 4)
1 + (6 % 4)
1 + 2
```

然而，看下这个语句 `5 - 2 + 3`。加法和减法有着相同的运算优先级，如果先计算减法后计算加法的话 `(5 - 2) + 3` 的结果是6，先计算加法后计算减法的话 `5 - (2 + 3)` 的结果是0。在代码中，算数运算符是遵循左结合律的，这就意味着（`(5 - 2) + 3`）会先求左边部分的值。

运算符可能是一元的也有可能是三元的。前置运算符 `!`会对操作数的逻辑值做非运算，而后置运算符 `++`会对操作数加一。三元运算符 `?:` 通过求 `?` 左边语句的值来决定是执行 `:` 左边的语句（语句的值是 `true`）还是 `:` 右边的语句（语句的值是 `false`），其用这种方式来折叠 `if-else` 表达式。

## Swift 运算符

Swift 提供了一组对于 C 或者 Objective-C 开发者来说十分熟悉的运算符，并且补充了一些新的（特别需要注意的是，区间运算符和空值合并(nil coalescing)运算符）：

### 前置运算符

- `++`: 自增
- `--`: 自减
- `+`: 一元正号
- `-`: 一元负号
- `!`: 非
- `~`: 按位取反

### 中间运算符

<table>
    <tr>
        <th colspan="2">幂运算 <tt>{优先级 160}</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>&lt;&lt;</tt></td><td>左移</td></tr>
        <tr><td><tt>&gt;&gt;</tt></td><td>右移</td></tr>
    </tbody>


    <tr>
        <th colspan="2">乘法 <tt>{ 左结合性 优先级 150 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>*</tt></td><td>乘法</td></tr>
        <tr><td><tt>/</tt></td><td>除法</td></tr>
        <tr><td><tt>%</tt></td><td>模运算</td></tr>
        <tr><td><tt>&amp;*</tt></td><td>乘法，忽略溢出</td></tr>
        <tr><td><tt>&amp;/</tt></td><td>除法, 忽略溢出</td></tr>
        <tr><td><tt>&amp;%</tt></td><td>模运算, 忽略溢出</td></tr>
        <tr><td><tt>&amp;</tt></td><td>按位与</td></tr>
    </tbody>

    <tr>
        <th colspan="2">加法 <tt>{ 左结合性 优先级 140 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>+</tt></td><td>加法</td></tr>
        <tr><td><tt>-</tt></td><td>减法</td></tr>
        <tr><td><tt>&amp;+</tt></td><td>带溢出的加法</td></tr>
        <tr><td><tt>&amp;-</tt></td><td>带溢出的减法</td></tr>
        <tr><td><tt>|</tt></td><td>按位或</td></tr>
        <tr><td><tt>^</tt></td><td>按位异或</td></tr>
    </tbody>

    <tr>
        <th colspan="2">区间 <tt>{ 优先级 135 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>..&lt;</tt></td><td>半开区间</td></tr>
        <tr><td><tt>...</tt></td><td>封闭区间</td></tr>
    </tbody>

    <tr>
        <th colspan="2">转换 <tt>{ 优先级 132 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>is</tt></td><td>类型检查</td></tr>
        <tr><td><tt>as</tt></td><td>类型转换</td></tr>
    </tbody>

    <tr>
        <th colspan="2">比较 <tt>{ 优先级 130 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>&lt;</tt></td><td>小于</td></tr>
        <tr><td><tt>&lt;=</tt></td><td>小于等于</td></tr>
        <tr><td><tt>></tt></td><td>大于</td></tr>
        <tr><td><tt>>=</tt></td><td>大于等于</td></tr>
        <tr><td><tt>==</tt></td><td>等于</td></tr>
        <tr><td><tt>!=</tt></td><td>不等于</td></tr>
        <tr><td><tt>===</tt></td><td>恒等</td></tr>
        <tr><td><tt>!==</tt></td><td>不恒等</td></tr>
        <tr><td><tt>~=</tt></td><td>模式匹配</td></tr>
    </tbody>

    <tr>
        <th colspan="2">合取 <tt>{ 左结合性 优先级 120 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>&amp;&amp;</tt></td><td>逻辑与</td></tr>
    </tbody>

    <tr>
        <th colspan="2">析取 <tt>{ 左结合性 优先级 110 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>||</tt></td><td>逻辑或</td></tr>
    </tbody>

    <tr>
        <th colspan="2">空值合并 <tt>{ 右结合性 优先级 110 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>??</tt></td><td>空值合并</td></tr>
    </tbody>

    <tr>
        <th colspan="2">三元条件运算符 <tt>{ 右结合性 优先级 100 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>?:</tt></td><td>三元条件运算符</td></tr>
    </tbody>

    <tr>
        <th colspan="2">赋值 <tt>{ 右结合性 优先级 90 }</tt></th>
    </tr>
    <tbody>
        <tr><td><tt>=</tt></td><td>赋值</td></tr>
        <tr><td><tt>*=</tt></td><td>相乘并且赋值</td></tr>
        <tr><td><tt>/=</tt></td><td>相除并且赋值</td></tr>
        <tr><td><tt>%=</tt></td><td>取模后赋值</td></tr>
        <tr><td><tt>+=</tt></td><td>相加并且赋值</td></tr>
        <tr><td><tt>-=</tt></td><td>相减并且赋值</td></tr>
        <tr><td><tt>&lt;&lt;=</tt></td><td>左移后赋值</td></tr>
        <tr><td><tt>>>=</tt></td><td>右移后赋值</td></tr>
        <tr><td><tt>&amp;=</tt></td><td>按位与后赋值</td></tr>
        <tr><td><tt>^=</tt></td><td>按位异或后赋值</td></tr>
        <tr><td><tt>|=</tt></td><td>按位或后赋值</td></tr>
        <tr><td><tt>&amp;&amp;=</tt></td><td>逻辑与后赋值</td></tr>
        <tr><td><tt>||=</tt></td><td>逻辑或后赋值</td></tr>
    </tbody>
</table>

### 后置运算符


- `++`: 自增
- `--`: 自减

### 成员方法

除了上述的这些标准运算符之外，还有一些_实际上_被语言定义的操作符：

- `.`: 访问成员
- `?`: 可选
- `!`: Forced-Value
- `[]`: 下标
- `[]=`: 下表赋值

## 重载

Swfit 是可以重载运算符的，其能够让现有的运算符像 `+` 在其它的类型中起作用。

为了重载一个运算符，需要为运算符号简单的定义一个新的函数，并且要有适当的参数个数。

例如，重载 `*` 来让一个字符串重复某个特定的次数：

```swift
func * (left: String, right: Int) -> String {
    if right <= 0 {
        return ""
    }

    var result = left
    for _ in 1..<right {
        result += left
    }

    return result
}

"a" * 6 
// "aaaaaa"
```
然而，这是一个有争议的语言特性。

任何一个 C++ 开发者都会急于用这会造成不确定性破坏的恐怖故事来款待你。

来看看下面这个语句：

```swift
[1, 2] + [3, 4] // [1, 2, 3, 4]
```

默认情况下，`+` 运算符对于两个数组的行为是把右边的数组附加到左边的数组里面去。

然而，被重载了之后：

```swift
func +(left: [Double], right: [Double]) -> [Double] {
    var sum = [Double](count: left.count, repeatedValue: 0.0)
    for (i, _) in enumerate(left) {
        sum[i] = left[i] + right[i]
    }

    return sum
}
```

其结果就变成了两个数组的每个元素两两相加并且转换成 `Double` 之后所组成的数组：

```swift
[1, 2] + [3, 4] // [4.0, 6.0]
```

如果用下面这段代码重载这个运算符，让它可以用于 `Int` 类型：

```swift
func +(left: [Int], right: [Int]) -> [Int] {
    var sum = [Int](count: left.count, repeatedValue: 0)
    for (i, _) in enumerate(left) {
        sum[i] = left[i] + right[i]
    }

    return sum
}
```

那么，这个结果将会变成一个两两相加之后所组成的 `Int` 数组。

```swift
[1, 2] + [3, 4] // [4, 6]
```

运算符重载的问题就在这儿了：**语意不清**

经过了多年的基本算术运算符限制和编程语言，重载运算符已经变得司空见惯了：

- 计算整数的和: `1 + 2 // 3`
- 计算浮点数的和: `1.0 + 2.0 // 3.0`
- 字符串连接: `"a" + "b" // "ab"`
- 数组连接: `["foo"] + ["bar"] // ["foo", "bar"]`


`+` 只对数字起作用是理所当然的。想想这个问题：_为啥应该在两个字符串相加的时候要把他们连接到一起_？ `1 + 2` 的结果不是 `12` （[除了在 Javascript 中](https://www.destroyallsoftware.com/talks/wat)）。这是很直观的，熟悉的。

> PHP 使用 `.` 来连接字符串（从客观的角度来看，这个想法很可怕）。

Objective-C 允许连续的字符串与空白字符相连。

在 Swift 的首次发布即将到来之际，其在解决运算符的语义歧义的问题上依然还有一些工作要做。Swift最近有些变化，诸如给 `nil` 增加合并操作符 (`??`)，鼓励对于 `BooleanType` 不用可选类型（optionals）（ `Bool?` 这种情况看起来十分令人不解），需要我们集团扪心自问_这是不是真的有意义_和适当的文件检索。

> 正如前面的例子所示，我特别关心数组运算符的语义。我的建议是：数组应该用 `<<` 运算符来代替 `+` 和 `-` 运算符：

```swift
func <<<T> (inout left: [T], right: [T]) -> [T] {
    left.extend(right)
    return left
}

func <<<T> (inout left: [T], right: T) -> [T] {
    left.append(right)
    return left
}
```

## 自定义运算符

另一个更有争议的但又令人兴奋的特性是可以自定义操作符。

`**` 是在很多编程语言中都可以找到的一个算术运算符，但是在 Swift 是没有的。它让右操作数作为左操作数的指数来进行幂运算（ `^` 符号已经被用来执行一个[按位异或](http://en.wikipedia.org/wiki/Bitwise_operation#XOR)运算了，通常它被用做上标。

要把这个运算符添加到 Swift 中，首先要定义一个运算符：

```swift
infix operator ** { associativity left precedence 160 }
```
- `infix` 指定了它是一个二元操作符，有左右两个操作数参数
- `operator` 是一个保留字，其必须写在 `prefix`, `infix`, 或者 `postfix` 之后
- `**` 是运算符本身
- `associativity left` 的意思是操作是从左侧开始分组的
- `precedence 160` 意味着它的运算优先级跟指数运算符 `<<` 和 `>>` （左右位移）一样。

```swift
func ** (left: Double, right: Double) -> Double {
    return pow(left, right)
}

2 ** 3 
// 8
```

如果合适的话，当创建一个自定义运算符时，还要确保创建了相应的赋值操作符：

```swift
infix operator **= { associativity right precedence 90 }
func **= (inout left: Double, right: Double) {
    left = left ** right
}
```

> 要注意 `left` 是 `inout` 的，这样做完全没有问题，因为赋值操作改变了原来的值。

### 用协议和方法来自定义运算符

事实上，运算符本身的函数定义应该非常简单明了。但对于一些更加复杂的功能，一些额外的设置也是很有必要的。

例如一个用正则表达式来判断右边部分是不是可以匹配到左边部分的自定义运算符 `=~`：

```swift
protocol RegularExpressionMatchable {
    func match(pattern: String, options: NSRegularExpressionOptions) -> Bool
}

extension String: RegularExpressionMatchable {
    func match(pattern: String, options: NSRegularExpressionOptions = nil) -> Bool {
        let regex = NSRegularExpression(pattern: pattern, options: options, error: nil)
        return regex.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, self.utf16Count)) != 0
    }
}

infix operator =~ { associativity left precedence 130 }
func =~<T: RegularExpressionMatchable> (left: T, right: String) -> Bool {
    return left.match(right, options: nil)
}
```

- 首先，声明一个包含了一个正则表达式方法的 `RegularExpressionMatchable` `protocol`。
- 然后，声明一个 `String` 继承了 `RegularExpressionMatchable` 这个 `protocol` 的 `extension`，并使用 `NSRegularExpression` 来实现 `match` 方法。
- 最后，对于符合`RegularExpressionMatchable`的泛型声明并实现一个 `=~` 运算符。

通过这样做，使用者可以选择使用 `match` 方法来代替这个运算符。它也有一个额外的好处就是在选择调用的方法时更加的灵活。

> 事实上，还有一个[更聪明的方法](https://gist.github.com/mattt/2099ee21bbfbebaa94a3)可以做到。下周我们会更加深入的讨论这个。

所有这些都是想说明：**自定义运算符仅仅应该为已经存在方法提供一个方便的使用方式。**

### 数学符号的使用

自定义运算符可以是一个 ASCII 字符 /, =, -, +, !, *, %, <, >, &, |, ^, or ~ 或者 数学符号字符集中的任意一个 Unicode 字符。

这就让用一个单一的前置运算符 `√` (`⌥v`) 来求一个数的平方根成为了可能： 

```swift
prefix operator √ {}
prefix func √ (number: Double) -> Double {
    return sqrt(number)
}

√4 
// 2
```

或者想想看 `±` 运算符，它无论是作为 `infix ` 还是 `prefix ` 都会返回一个由两个数的和和两个数的差所组成的元组。

```swift
infix operator ± { associativity left precedence 140 }
func ± (left: Double, right: Double) -> (Double, Double) {
    return (left + right, left - right)
}

prefix operator ± {}
prefix func ± (value: Double) -> (Double, Double) {
    return 0 ± value
}

2 ± 3
// (5, -1)

±4
// (4, -4)
```

> 想要了解更多 Swift 中数学符号的使用，请查看 [Euler](https://github.com/mattt/Euler)

自定义运算符是很难归类的，因此很难使用。**在使用带有异国情调的自定义运算符时，要克制**。毕竟，代码是不应该被复制粘贴的。

* * *

Swift 的运算符是这门新语言中最有趣也是最有争议的特性。

当你在你的代码上要重载或者定义一个新的运算符时，请确保遵循了下面这些指导建议：

## Swift 运算符指南

1. 如果这个运算符的意义不是因而易见，无可争议的，那么就不要创建它。寻找其中任何潜在的冲突，来确保语义的一致性。
2. 自定义运算符应该只提供一个方便的调用方式。复杂的功能应该总是在一个方法中实现的，而且最好指定一个通用的自定义协议。
3. 请注意自定义运算符的结合性和优先级。找个跟这个运算符最接近的类，然后使用适当的优先级的值。
4. 如果自定义的运算符是有意义的，那么就一定要给它实现一个快速赋值运算符（例如 `+=` 跟 `+`）
