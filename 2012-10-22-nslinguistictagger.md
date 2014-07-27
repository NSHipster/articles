---
layout: post
title: NSLinguisticTagger
category: Cocoa
description: "NSLinguisticTagger在语言学功能上来讲是一把名副其实的瑞士军刀，它可以讲自然语言的字符串标记为单词、确定词性和词根、划分出人名地名和组织名称、告诉你字符串使用的语言和语系。"
author: Mattt Thompson
translator: Croath Liu
---

`NSLinguisticTagger` 在语言学功能上来讲是一把名副其实的瑞士军刀，它可以讲自然语言的字符串[标记](http://en.wikipedia.org/wiki/Tokenization)为单词、确定词性和[词根](http://en.wikipedia.org/wiki/Word_stem)、划分出人名地名和组织名称、告诉你字符串使用的语言和[语系](http://en.wikipedia.org/wiki/Writing_system)。

对于我们大多数人来说，这其中蕴含着意义远超过我们所知道的，但或许也只是我们没有合适的机会使用而已。但是，几乎所有使用某种方式来处理自然语言的应用如果能够用上 `NSLinguisticTagger` ，或许就会润色不少，没准会催生一批新特性呢。

---

`NSLinguisticTagger` 和Siri同时出现于iOS 5上，所以可以推测这可能是苹果在私人助理方向开发时候的副产品。

回想一下我们经常问Siri的一个问题：

> 旧金山的天气怎么样？（What is the weather in San Francisco?）

电脑不可能通过逐字翻译"理解"问题的含义，不过我们耍一点儿小花招就可以合理地理解这个问题的_含义_：

~~~{objective-c}
NSString *question = @"What is the weather in San Francisco?";
NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
tagger.string = question;
[tagger enumerateTagsInRange:NSMakeRange(0, [question length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
    NSString *token = [question substringWithRange:tokenRange];
    NSLog(@"%@: %@", token, tag);
}];
~~~

输出如下：

> What: _Pronoun（代词）_
> is: _Verb（动词）_
> the: _Determiner（限定词）_
> weather: _Noun（名词）_
> in: _Preposition（介词）_
> San Francisco: _PlaceName（地名）_

如果我们过滤名词、动词、地名，就会得到结果：`[is, weather, San Francisco]`。

仅以来这个结果，或者配合[潜在语义映射（Latent Semantic Mapping）](http://developer.apple.com/library/mac/#documentation/LatentSemanticMapping/Reference/LatentSemanticMapping_header_reference/Reference/reference.html)库，我们就可以推断出合理解释，然后就可以通过调用相关API去获取旧金山此时此刻的天气状况了。

## 特征标记方案

我们可以通过给 `NSLinguisticTagger` 设置下列scheme来标记不同类型的信息：

- `NSLinguisticTagSchemeTokenType`：将短语在大粒度上分成词语、标点符号、空格等。
- `NSLinguisticTagSchemeLexicalClass`：将短语根据类型分为话语部分、标点空格等。
- `NSLinguisticTagSchemeNameType`：将短语根据是否为命名实体分类。
- `NSLinguisticTagSchemeNameTypeOrLexicalClass`：遵守 `NSLinguisticTagSchemeNameType` 对名字的规则和 `NSLinguisticTagSchemeLexicalClass` 对所有其它部分的原则。

这里有一个不同短语类型和每一个分词方案之间关系的表：（`NSLinguisticTagSchemeNameTypeOrLexicalClass`表示`NSLinguisticTagSchemeNameType` 和 `NSLinguisticTagSchemeLexicalClass`的组合关系）：

<table>
  <thead>
    <tr>
      <th><tt>NSLinguisticTagSchemeTokenType</tt></th>
      <th><tt>NSLinguisticTagSchemeLexicalClass</tt></th>
      <th><tt>NSLinguisticTagSchemeNameType</tt></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <ul>
          <li><tt>NSLinguisticTagWord</tt></li>
          <li><tt>NSLinguisticTagPunctuation</tt></li>
          <li><tt>NSLinguisticTagWhitespace</tt></li>
          <li><tt>NSLinguisticTagOther</tt></li>
        </ul>
      </td>
      <td>
        <ul>
          <li><tt>NSLinguisticTagNoun</tt></li>
          <li><tt>NSLinguisticTagVerb</tt></li>
          <li><tt>NSLinguisticTagAdjective</tt></li>
          <li><tt>NSLinguisticTagAdverb</tt></li>
          <li><tt>NSLinguisticTagPronoun</tt></li>
          <li><tt>NSLinguisticTagDeterminer</tt></li>
          <li><tt>NSLinguisticTagParticle</tt></li>
          <li><tt>NSLinguisticTagPreposition</tt></li>
          <li><tt>NSLinguisticTagNumber</tt></li>
          <li><tt>NSLinguisticTagConjunction</tt></li>
          <li><tt>NSLinguisticTagInterjection</tt></li>
          <li><tt>NSLinguisticTagClassifier</tt></li>
          <li><tt>NSLinguisticTagIdiom</tt></li>
          <li><tt>NSLinguisticTagOtherWord</tt></li>
          <li><tt>NSLinguisticTagSentenceTerminator</tt></li>
          <li><tt>NSLinguisticTagOpenQuote</tt></li>
          <li><tt>NSLinguisticTagCloseQuote</tt></li>
          <li><tt>NSLinguisticTagOpenParenthesis</tt></li>
          <li><tt>NSLinguisticTagCloseParenthesis</tt></li>
          <li><tt>NSLinguisticTagWordJoiner</tt></li>
          <li><tt>NSLinguisticTagDash</tt></li>
          <li><tt>NSLinguisticTagOtherPunctuation</tt></li>
          <li><tt>NSLinguisticTagParagraphBreak</tt></li>
          <li><tt>NSLinguisticTagOtherWhitespace</tt></li>
        </ul>
      </td>
      <td>
        <ul>
          <li><tt>NSLinguisticTagPersonalName</tt></li>
          <li><tt>NSLinguisticTagPlaceName</tt></li>
          <li><tt>NSLinguisticTagOrganizationName</tt></li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

用 `NSLinguisticTagSchemeTokenType` 来进行基本的分词（tokenization）就可以分辨出词语空格和标点符号了。至于话语信息或者区分话语的不同部分应该用 `NSLinguisticTagSchemeLexicalClass`。

继续说其它scheme：

- `NSLinguisticTagSchemeLemma`： 在词根可知时可分析出词根。
- `NSLinguisticTagSchemeLanguage`：根据短语的语言来标记。标记出的值会以标准语言所写形式给出，例如`"en"`、`"fr"`、`"de"`等，和用 `NSOrthography` 类的效果相同。_注意此类分词根据的是词语在整个句子或段落中的表意，而不是只根据该词本身来判断_。
- `NSLinguisticTagSchemeScript`：类似上述也是标记不同语言，但会以如下的缩略形式给出：`"Latn"`、`"Cyrl"`、`"Jpan"`、`"Hans"`、`"Hant"`等。

回头看上面给出的样例代码，首先用一个你想要用到的scheme组成的数组来初始化一个 `NSLinguisticTagger`，然后在判断输入字符串的标记之后枚举出每一个tag。

## 标记选项

除可用的标记scheme之外，还有一些可以传给 `NSLinguisticTagger` 的附加选项（用按位或`|`）来改变细微的分词行为：

- `NSLinguisticTaggerOmitWords`
- `NSLinguisticTaggerOmitPunctuation`
- `NSLinguisticTaggerOmitWhitespace`
- `NSLinguisticTaggerOmitOther`

这些选项的每一个都可以细化标记所代表的广义类别。例如：`NSLinguisticTagSchemeLexicalClass` 配合 `NSLinguisticTaggerOmitPunctuation` 就可以在不同种类的标点符号中再细化。推荐用带block的迭代器或predicate来实现。

最后一个选项是针对 `NSLinguisticTagSchemeNameType` 的：

- `NSLinguisticTaggerJoinNames`

默认一个名字中的每个短语都被分成不同的实例。很多情况下需要将类似“San Francisco”这样的名字当作一个短语而不是两个短语来看待。传入这个属性即可实现这个功能。

---

不幸的是在移动设备的UI设计中，自然语言处理并没有并没有被充分的利用。如果能够有效的利用，用户就可以用说话来代替手上的触摸动作来完成相同的事，而且会花费更少的时间。

当然要做到这点并不容易，但如果我们花费一点点时间能让应用在视觉上更赞，就可以给用户与设备和应用的交互体验上带来很大的颠覆。等到那时，再加上 `NSLinguisticTagger`，使用移动应用将从未如此简单。
