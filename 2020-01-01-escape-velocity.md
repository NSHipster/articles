---
title: Escape Velocity
author: Mattt
category: Miscellaneous
published: false
excerpt: >-
  Swift is great for apps and not much else right now.
---

As someone born between 1981 and 1996,
I fall into the widely accepted definition of a "Millenial",
the generation so named for coming of age around the year 2000.

I remember staying up to watch the ball drop in 1999,
tuned into MTV's _New Year's Eve Live_.
As the East Coast collectively counted down the seconds to midnight,
the broadcast from Times Square had 
Gwen Stefani performing a cover of R.E.M.'s 
[_"It's the End of the World As We Know It."_](https://music.apple.com/us/album/its-the-end-of-the-world-as-we-know-it-and-i-feel-fine/1440850529?i=1440850619),
in an _ironic-maybe-not-ironic_ nod to the very real fears
many of us had about <abbr>Y2K</abbr> at the time.

Every year since,
I've taken New Year's Eve as an occasion for solemn contemplation.
Being another <code>mod 10</code> year
and following the year that was 2019,
I can't help thinking a lot about the end of the world
and wondering how I feel about it.
This week, I'd like to invite you, dear reader,
to crack open a can of [Surge][surge],
queue up some 
[Robbie Williams](https://music.apple.com/gb/album/millennium/1440864572?i=1440864990) 
on your Sony Walkman™,
and hear me out as I talk through some things.

<aside class="parenthetical">

I've, uh, had a lot on my mind.

</aside>

* * *

Swift was announced on June 2nd, 2014,
and (if the official repository is to be believed)
development started on 
[July 17, 2010](https://github.com/apple/swift/commit/18844bc65229786b96b89a9fc7739c0fc897905e).

Apple has a proven track record of destructive innovation, 
of _"out with the old"_,
of _"get on board or get out of the way"_.
So when the announcement came,
each of us had a choice to make: 
Either full-throated support or irrelevance.
Many of us at the time were all too eager to jump in head-first
and discounted criticism as a form of apostacy, of heresy, of being a buzz-kill.
For anyone who missed this the first time around,
you can see pretty much the same dynamic playing out now with SwiftUI.

Every decision has an opportunity cost,
and I know a lot of people who came to regret going all in so early, 
myself included.
Even when I was actually being paid by Apple to make Swift better,
I struggled to justify the trajectory of my career so far.
I knew I wanted to get out and do something else,
but I'd dug myself in deep and needed to build up enough speed to get out.

* * *

When Swift was open-sourced at the end of 2015,
[the Swift.org website](https://web.archive.org/web/20151203210715/https://swift.org/)
included the following as part of its welcome message:

> Now that Swift is open source, 
> you can help make the best general purpose programming language available everywhere.
> <cite hidden>Swift.org, archived December 3, 2015 by <a href="https://archive.org">The Internet Archive</a></cite>

Five years after its public release 
and a decade since it first started,
it's hard to deny that Swift has struggled to gain widespread adoption
outside of the Apple ecosystem.
And current trends don't provide much assurance that this will ever change.

<aside class="parenthetical">

Perhaps tellingly,
this was [changed](https://web.archive.org/web/20171201012935/https://swift.org/)
sometime in 2017. 
The landing page now reads:
<q>Our goals for Swift are ambitious: 
we want to make programming simple things easy, and difficult things possible.</q>
...which seems quite a bit less ambitious than the original version.

</aside>

In
[Stack Overflow's Developer Survey for 2019](https://insights.stackoverflow.com/survey/2019#most-popular-technologies),
Swift ranks 14<sup>th</sup> under "Most Popular Technologies" 
among respondents who described themselves as professional developers.

On 
[GitHub's ranking of Top languages over time](https://octoverse.github.com/#top-languages-over-time)
Swift isn't ranked among the most popular language on GitHub 
by repository contributors
_(though Swift's influence can be felt through
Objective-C's disappearance after 2015)._

Swift did manage to snag the #10 spot in the latest
[TIOBE Index](https://www.tiobe.com/tiobe-index/) update.
However, this achievement is undercut by the fact that
TIOBE twice named Objective-C its "Programming Language of the Year" 
(in 2010 and 2011),
which peaked at position #3 in March 2015.

{% info %}

If this seems unfair,
consider that Swift is roughly as old as 
[Go][go] (2009), 
[Rust][rust] (2010), 
[Kotlin][kotlin] (2011),
[TypeScript][typescript] (2012), and
[Elixir][elixir] (2012),
each of which have arguably seen greater adoption than Swift
for systems and web application development.

{% endinfo %}

* * *

If Swift and Xcode is all you know, 
it's hard to appreciate how far behind it is to other languages
in terms of tooling.
If I had to describe the experience of, 
for example,
writing [React](https://reactjs.org) 
in [TypeScript](https://www.typescriptlang.org)
with [Visual Studio Code](/vscode/)
and [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi?hl=en):
Imagine [SwiftUI Previews](/swiftui-previews/),
but how you'd expect it to work in Xcode 16.

It's a prime example of 
the [Cathedral and Bazaar models](https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar)
of software development.
And that same disparity can be found in terms of package ecosystem, too.

Apple provides a lot of functionality for its platforms
_([more than they can document, in fact!](https://nooverviewavailable.com/))_,
and for everything else,
the iOS developer community has done an admirable job to fill the gaps.
But try to use Swift for anything other than an iDevice,
and you'll quickly find yourself having to reinvent functionality
far removed from the problem you _actually_ want to solve.

Last year, 
[npm](https://npmjs.com), the largest registry for Node.js packages,
[crossed the 1 million mark](https://snyk.io/blog/npm-passes-the-1-millionth-package-milestone-what-can-we-learn/).
Some other points of comparison:
[Maven Centeral](https://search.maven.org) (Java),
[nuget](https://www.nuget.org/packages) (.NET),
[CPAN](https://www.cpan.org) (Perl)
[PyPI](https://pypistats.org) (Python), and
[RubyGems](https://rubygems.org/stats) (Ruby),
each have a total package count in the low 6 figures.

How many Swift packages are there?
It's hard to know for sure, 
but it's a lot fewer than any of those other languages.

{% info %}

The closest thing Swift has to a mainstream, centralized package registry is
[CocoaPods](/cocoapods/),
which reports over 69K entries.
But that number includes both Objective-C and Swift libraries,
and it's unclear what the breakdown is.

We can use GitHub search to establish some general parameters 
for what the real count is.
As a lower bounds,
searching GitHub for projects with a `Package.swift` files in their root directory
[returns around twenty thousand results](https://github.com/search?utf8=✓&q=path%3A%2F+filename%3APackage.swift&type=Code&ref=advsearch&l=&l=).
As an upper bounds,
searching all Swift projects with more than 1★ (excluding forks),
[the count is closer to fifty thousand](https://github.com/search?l=&p=99&q=stars%3A%3E3+language%3ASwift&ref=advsearch&type=Repositories&utf8=✓)

{% endinfo %}

Granted,
numbers aren't everything,
and massive `node_modules` directories
exist in their own special circle of 
["Dependency Hell"](https://en.wikipedia.org/wiki/Dependency_hell).
But, 
as the saying goes, 
<q>“Quantity has a quality all its own”</q>.
Even if you write off 90% of JavaScript packages as garbage,
you're still more than _twice_ as likely
to find an existing solution to a problem 
from an npm module than any Swift package.
It's hard to overstate the difference of 
reliably having prior art for most programming tasks.

For the time being,
any competitive advantage Swift might claim outside of app development,
whether in terms of performance or client / server code reuse,
is overshadowed by the weakness of its ecosystem.

Swift is great for apps and not much else right now.\\
_But then again, 
what good are apps, anyway?_

* * *

Take a moment to think about the most important problems you're facing right now
as an individual.
Next, think about the biggest problems facing society. 
Now ask yourself: 
_How many of those problems can be solved by apps?_

<aside class="parenthetical">

Conversely,
how many of these problems are **caused** by apps?

</aside>

I don't mean to sound glib,
but the problems most worth solving today
are political and social in nature, not technological ---
and to the extent that technological solutions exist,
they're much more likely to manifest in the form of a website or database 
_(or heck, even an Excel spreadsheet)_
than an app.

Every era may believe themselves to exist on a knife's edge,
at the precipice of total annihilation.
But it's not unreasonable to see the unique peril of our current age.

<!-- Maybe we've been right all along,
and this whole time has been an incredible lucky streak for civilization. -->

When recruiting John Sculley, then CEO of PepsiCo,
to become the new CEO of Apple in the early 1980's,
Steve Jobs famously asked him:

> Do you want to spend the rest of your life selling sugared water, 
> or do you want a chance to change the world?
> <cite hidden>Steve Jobs</cite>

To that end, ask yourself: \\
_Do you really want to spend your life writing apps?_

* * *

Thinking about the smartest developers I knew around the last `mod 10` changeover ---
the folks who were there with me during that iOS renaissance in the early '10s ---
I can’t help but notice that very few of them are still "making apps".

Some of them transitioned into management tracks,
while a few managed to build successful businesses.
I know several people who shifted their focus to tooling
in support of their growing team of engineers.
The coolest among them started making videogames.
Still others jumped ship to the <abbr>.NET</abbr> stack
and seem all the happier for it.

So what comes next?
_I don't know._
Do you?

[surge]: https://en.wikipedia.org/wiki/Surge_(drink)
[go]: https://en.wikipedia.org/wiki/Go_(programming_language)
[rust]: https://en.wikipedia.org/wiki/Rust_(programming_language)
[kotlin]: https://en.wikipedia.org/wiki/Kotlin_(programming_language)
[typescript]: https://en.wikipedia.org/wiki/TypeScript
[elixir]: https://en.wikipedia.org/wiki/Elixir_(programming_language)
