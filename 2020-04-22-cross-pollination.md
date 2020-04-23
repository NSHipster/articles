---
title: Cross-Pollination
author: Mattt
category: Miscellaneous
excerpt: >-
  A brief essay about the flowering of ideas,
  written for the occasion of Earth Day.
---

April is the month when apple trees start to bloom
up here in the Pacific Northwest.
All across Oregon's Willamette Valley,
from Portland stretching south to Eugene,
long-barren branches sprout white, 5-petaled blossoms tinged with pink.
Any other year,
our family would be taking weekend trips
southwest to Sherwood or east towards Hood River
to visit their orchards.

Like the Fuji and Gala varieties that predominate in this region,
most apple cultivars are <dfn>self-unfruitful</dfn> —
which is to say that they require cross-pollination
to produce a good crop consistently.

<aside class="parenthetical">

There are a few cultivars that are partially self-fruitful
and may produce a good crop without the help of another variety.
But even they would typically benefit from cross-pollination.

</aside>

<!-- diagram -->

When fertilized by the pollen of Fuji apple blossoms
(or those of Braeburn, Honey Crisp, or McIntosh varieties),
a Gala apple tree can yield 20 kilograms of fruit each season.
Those Gala trees, in return, endow their pollen on the Fuji apple trees
so that they too may blossom and bear one or two bushels of fruit, each.

## The Dance of the Honey Bee

Appletree pollen is sticky.
In contrast with the windborne pollen of Alder, Birch, and Ash trees
(whose allergenic quality gave the Willamette its name,
meaning _"valley of sickness"_ in the indigenous Kalapuya dialect),
appletrees rely on insects to transfer pollen —
particularly the <dfn>honey bee</dfn>.

Honey bees eat the pollen of flowers and convert their nectar into honey.
Some of the pollen sticks to their furry bodies,
which is inadvertently spread as they move from plant to plant.

When a scout bee encounters a food source,
she flies back to the hive
and communicates the location of that food source to male worker bees
by performing what's called a <dfn>waggle dance</dfn>.
Performed in darkness on the vertical honeycomb surface in the hive,
she's able to convey the precise location of new food sources to them
by flying a coffee bean-shaped pattern oriented in the direction of the sun.
It's an incredible feat,
made all the more remarkable by the fact that bees are not, individually,
very intelligent.
Bees have brains on the order of 1 million neurons,
compared to the 100 billion neurons of a human brain.

If you move a food source closer and farther away from a hive,
you can see how the dance changes to convey this new information.
But move it _just_ past some critical point,
and the dance becomes something entirely different:
instead of the waggle dance,
the bee performs a <dfn>round dance</dfn>
with a totally different cadence and flight path.

<!-- diagram -->

For many years,
the dance language of the bumblebee eluded all those who studied it.
That is until 
a mathematician named Barbara Shipman 
made the connection between a bee's dance language
and the six-dimensional geometry of flag manifolds,
of all things.
What was the unique insight that allowed her to see what others couldn't?
She grew up in a family of beekeepers
and cultivated an interest in mathematics and biology
that carried throughout her studies.

The leap from furry, buzzing insects to abstract geometry is inconceivable
unless you're accustomed to looking at the world in that particular way.

## The Rose that Grows From the Dunghill

When Apple first announced the Swift programming language in 2014,
it generated a flurry of excitement as we all tried to understand it.
One of the most powerful tools at our disposal for understanding is _analogy_:

`<# New Thing #>` is like `<# Familiar Thing #>` crossed with `<# Another Thing #>`.

So in those early days,
there was a lot of discussion within the community
attempting to compare and contrast Swift with
[Haskell][haskell] or [Go][go] or [Python][python] or [Scheme][scheme] or [Dylan][dylan].

<aside class="parenthetical">

Indeed, Apple originally pitched Swift as "Objective-C without the C".

</aside>

Last year,
we saw something similar with at [WWDC 2019](/wwdc-2019/).
Anyone familiar with [React][react] or [Elm][elm]
immediately recognized the influences on
[SwiftUI][swiftui] and [Combine][combine]
(even if Apple hadn't come out and acknowledged it explicitly).

For some,
the connection between React and Elm with JavaScript
is an inconvenient truth.
I've seen numerous developers profess their disdain for the language
in ways that echo the old rivalry between iOS and Android
(or the even older rivalry between [Mac and PC][get a mac]).

And yet,
there are countless examples of good ideas from _"them"_
being criticized and mocked until they're incorporated into an Apple product:

- <kbd title="alt">⌥</kbd><kbd title="tab">⇥</kbd> app switching on Windows
  (<kbd title="command">⌘</kbd><kbd title="tab">⇥</kbd> on macOS)
- Dark mode in Android 
  ([added in iOS 13](/dark-mode/))
- Generics in Java and other languages
  (a core feature in Swift, 
  [later added to Objective-C][objective-c lightweight generics])
- [JSX][jsx]-style <abbr title="domain-specific languages">DSL</abbr>s
  declarative UI 
  ([function builders][function builders] in SwiftUI)

All of which begs the question:

_Why did we consider these good ideas heretical until Apple did it?_

## Us vs. Them

Another flavor of this arises from the dichotomy between "Native" and "Hybrid".

<aside class="parenthetical">

Often the "other" isn't even distinguished beyond a negative definition —
"Non-native".

</aside>

Whenever a company writes some blog post about React Native,
what inevitably follows is chorus of developers who either
praise the decision as courageous (if switching away)
or call it idiotic (if adopting it).

As developers,
we tend to align ourselves with enlightenment ideals like objectivity.
We say that we make decisions based in the indisputable reality of fact.
We consider ourselves reasonable and our decisions well-reasoned.

But to what extent is this actually true?
Do our thoughts lead us to our preferences,
or do we use thoughts to rationalize them after the fact?

* * *

In the 1960s and 70s,
the social psychologist Henri Tajfel and his colleagues
ran a [series of experiments][minimal groups] 
that demonstrated how little it takes
for people to engage in intergroup discrimination.

In one experiment,
a group of boys were shown pictures with clusters of dots
and instructed to guess how many there were
as a test of their visual judgment.
The researchers split the group between
those who overestimated or underestimated the number.
Except, they only pretended to do this —
the boys were, in fact, randomly assigned to one of the two groups.
They were then given the task of allocating a fixed amount of real money
to other boys in the study.

The results surprised even the researchers:

Overwhelmingly, the boys chose outcomes where their assigned group
(under- or over-estimators) received more money than their counterparts —
_even when that meant getting less overall_.

Successful replication of these results in follow-up studies since then
presents compelling evidence of this peculiarity in human nature.
That a willingness to engage in "us vs. them" discrimination
can arise from completely artificial distinctions,
irrespective of any rationale of self-interest.

* * *

_How else could you explain the intense tribalism
around how we talk to computers?_

## The Dream of Purity

When a developer proudly declares something to be
"Pure Swift" or "100% JavaScript free",
what are they really saying?
What's presented as an objective statement of fact
often feels more like an oath of allegiance.

If you see the existence of competing technologies
as a fight between good and evil,
perhaps there are more important battles to fight.
If you can't evaluate solutions as a series of trade-offs,
what chance do you have at accomplishing anything at all?

Yes,
there are real differences between technologies
and reasonable people disagree about
which one is best-suited to solve a particular problem.
But don't mistake this for a moral contest.

> Purity is an ideal;
> a vision of the condition which needs yet to be created,
> or such as needs to be diligently protected against the genuine or imagined odds.
> Without such a vision, neither the concept of purity makes sense,
> nor the distinction between purity and impurity can be sensibly drawn.
>
> – Zygmunt Bauman

* * *

It's of no practical consequence that
the grounds on which Apple Park sits today
were fruit orchards a hundred years ago.
But it's poetic.
Long before it was "Silicon Valley",
the stretch of land between the San Andreas and Hayward faults
was called "the Valley of Heart's Delight"
for all of its fruit trees and flowering plants.

Dwelling on this,
you might reflect on how humans are like apple trees.
That we need a variety of different influences to reach our potential.
(Even self-starters benefit from a unique perspective).

You might then consider what we share in common with
the bees that pollinate apple trees.
Like them,
our success comes not from our individual intelligence,
but in our ability to share information.

Whether we're like bees or like apples,
we come away learning the same lesson:
We can achieve remarkable results by working together.

[haskell]: https://en.wikipedia.org/wiki/Haskell_(programming_language)
[go]: https://en.wikipedia.org/wiki/Go_(programming_language)
[python]: https://en.wikipedia.org/wiki/Python_(programming_language)
[scheme]: https://en.wikipedia.org/wiki/Scheme_(programming_language)
[dylan]: https://en.wikipedia.org/wiki/Dylan_(programming_language)
[react]: https://en.wikipedia.org/wiki/React_(web_framework)
[elm]: https://en.wikipedia.org/wiki/Elm_(programming_language)
[swiftui]: https://developer.apple.com/xcode/swiftui/
[combine]: https://developer.apple.com/documentation/combine
[get a mac]: https://en.wikipedia.org/wiki/Get_a_Mac
[function builders]: https://forums.swift.org/t/function-builders/25167
[objective-c lightweight generics]: https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/using_imported_lightweight_generics_in_swift
[jsx]: https://reactjs.org/docs/introducing-jsx.html
[minimal groups]: https://en.wikipedia.org/wiki/Minimal_group_paradigm
