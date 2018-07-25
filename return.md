---
layout: post
date: 2018-07-09
title: Returning to Our Regularly Scheduled Programming
author: Mattt
category: ""
excerpt: 
    NSHipster returns to weekly publication,
    with new articles every Monday,
    updates every Wednesday,
    and new trivia questions every Friday.
status:
    swift: n/a
---

When the iPhone SDK first came out,
there was a disconnect between how futuristic the iPhone was
and how, well... _not_ Objective-C was.

For many new developers,
Objective-C was seen as an ugly, obscure language ---
something you merely put up with
in exchange for the privilege of developing on this amazing new platform.
That was certainly the case for me when I wrote my first app.
But over time,
I learned to appreciate the beauty of the language and its frameworks.

I started NSHipster in July 2012
as a way to share my newfound passion.
At the time,
the term "hipster" was tossed around frequently as a casual pejorative
for people who ironically enjoyed obscure or bad things.
What better term for someone excited about Objective-C, right?
Rather than being ashamed or annoyed by the language we used in our day-to-day,
it felt good to turn it around and say
"Oh, this? It's an obscure API. You've probably never heard of it."

---

Today marks six years since I first launched NSHipster
(which is a big milestone for all of you out there counting in
[base-6](https://www.seximal.net)).
To mark the occasion,
I'm very excited to announce my return as the managing editor of NSHipster.

I'm extremely thankful to [Nate Cook](https://nshipster.com/authors/nate-cook/)
for his stewardship of NSHipster.
During my tenure at Apple from 2015 to 2018,
I was unable to contribute to the site;
it's entirely thanks to him that NSHipster exists today.
His contributions to Swift are extraordinary and immeasurable,
and we all benefit immensely as a community from his work.

## What to Expect

**NSHipster is a celebration of small details
that come from big ideas.**
It stands at that fabled intersection of liberal arts and technology,
where we can collectively geek out about
thoughtful abstractions and clever optimizations.

Our focus will continue to be Objective-C and Swift,
and Apple platforms like macOS and iOS.
And we'll also look at any other languages or technologies
that can help us make insanely great software.

But most importantly,
we'll be returning to a regular publishing schedule.

Here's what that will look like:

### New Articles Every Monday

Every Monday,
I want you to be able to visit the site
(or refresh your feed reader)
and learn something new.
It could be topical and directly applicable to what you're working on right now.
It might be something you hadn't heard of before, and decide to research further.
Or maybe its a different way of thinking about a problem.

We'll start this week with an article
that ostensibly falls into any of those three categories:
[Swift GYB](https://nshipster.com/swift-gyb/)

> This time around,
> I'd like to open things up more for external contributors.
> If you have a topic that you'd like to write about on NSHipster,
> please submit a quick, 3–5 sentence, pitch to
> [mattt@nshipster.com](mailto:mattt@nshipster.com).

### Updated Articles Every Wednesday

With nearly 150 articles dating as far back as 2012,
there's a lot of material on NSHipster that needs to be revisited.
Out of date, sample code (mostly Swift),
changes in behavior that impact the documentation,
entirely new APIs that need to be addressed...

We'll have updates every Wednesday
until we run out of outdated material (😂).

### Trivia Questions Every Friday

The annual NSHipster pub quizzes at WWDC
was one of our favorite events of the year.
Hundreds of developers came out and formed small teams
(with hilarious team names)
to answer trivia questions about APIs, language features, and Apple lore.
For example, here's one of the tougher question
from the [last quiz we did](https://nshipster.com/nshipster-quiz-8/):

---

**Question**: After Chris Lattner,
who was the second contributor to Swift?

{::nomarkdown}

<details>
<summary><strong>Answer</strong></summary>
<p><a href="https://github.com/apple/swift/commit/023c9cc431e1b67c83ab9c8763b01dd4d8de972e">Doug Gregor</a></p>
</details>
{:/}

---

We're excited to make these kinds of trivia questions a regular feature
and share them with everyone.
[Follow us on Twitter](https://twitter.com/nshipster)
to take our weekly NSHipster quiz.

## What's Different Right Now

You might have noticed a few changes since your last visit.

Here's a recap of what we've been working on for today's announcement:

### Upgraded Site Infrastructure

A lot's changed about the internet since NSHipster first launched.
The web is significantly faster and more secure,
thanks to new standards like HTTP/2
and the widespread adoption of SSL.

In the weeks leading up to today's relaunch,
I quietly got to work upgrading NSHipster's tech stack:

- Both [NSHipster.com](https://nshipster.com)
  and [NSHipster.cn](https://nshipster.cn)
  are now hosted by [Netlify](https://www.netlify.com),
  which has been an absolute joy to use.
  Everything is served from a global CDN
  (using HTTP/2 if your browser supports it)
  to ensure that the site loads fast, no matter where you are.
- NSHipster is now served exclusively using HTTPS
  thanks to [Let's Encrypt](https://letsencrypt.org).
- Server responses now include fancy new security headers like
  [Content-Security-Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP) and
  [Strict-Transport-Security](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security).
- All of the image assets were re-optimized with the latest version of
  [ImageOptim](https://imageoptim.com/mac),
  which reduced file size by ~30% across the board.
- Critical CSS is now inlined to optimize the site's
  [Critical Rendering Path](https://developers.google.com/web/fundamentals/performance/critical-rendering-path/).
- The site now offers [JSON Feed](https://jsonfeed.org) syndication for articles.
- And most important of all,
  the site now
  [supports the iPhone X notch](https://webkit.org/blog/7929/designing-websites-for-iphone-x/).

If you notice anything amiss,
like a missing image
or a page that isn't rendering as you expected,
please [let us know](https://github.com/nshipster/nshipster.com)!

### Removed Site Search

In the process of upgrading the site's infrastructure,
I ended up removing the search widget provided by
[Swiftype](https://swiftype.com).
I'm looking into a couple alternatives,
but don't currently have any specific plans for bringing site search back.

### Retired Content

Technology evolves quickly.
And while I've tried to write mostly evergreen content on NSHipster,
there are some articles that have become obsolete.
For example, our article about [BackRow](https://nshipster.com/backrow/)
is irrelevant now that the tvOS is available.

These articles will live on in perpetuity at their original URLs,
but they'll include a deprecation notice at the top
and won't be displayed in the main site navigation.

## More Things to Look Forward To

But that's not all ---
in addition to new weekly articles,
we have a lot of exciting things in the works:

### CFHipsterRef Update and Print Edition

[CFHipsterRef](https://gum.co/cfhipsterref)
was released
on the eve of Swift's announcement at WWDC 2014.
Although this new language
gets most of our attention these days
(what, with its cool name and fast bird logo),
Objective-C and low-level technologies
are still just as important as ever.

Coming this fall,
we'll be releasing a second edition CFHipsterRef
with new and updated content.
This will be a free update to everyone who ordered the first edition.
(I also look forward to finally making good on a promise I made
to release a print edition of the book)

### New Books

I can't say too much yet,
but I'm planning to have a something out by the end of the year.
Stay tuned!

> In the meantime,
> check out [Flight School](https://flight.school).
> It's a new, ongoing book series I'm working on
> that's all about Swift.
> Each book offers an in-depth look at essential topics
> for intermediate and advanced developers.
>
> The first two books,
> [Guide to Swift Codable](https://gumroad.com/l/codable)
> and [Guide to Swift Numbers](https://gumroad.com/l/swift-numbers),
> are both available for download,
> with more on the way soon.

### More Tools and Experiments

NSHipster is more than writing blog posts and books.
It's also an opportunity to make fun and useful things
for the community.

One such project is
[ASCIIwwdc](https://asciiwwdc.com),
a site that offers searchable transcripts of WWDC sessions
going back to 2010.
It was recently updated with all of the sessions from 2017
and most from 2018,
so if you haven't gotten around to watching this year's talks,
you might find this to be a nice way to get up to speed quickly.

Another example is
[SwiftDoc](https://swiftdoc.org).
Nate created this around the time that he took the reigns of NSHipster,
and it's been an invaluable tool for understanding
the complex type relationships in the Swift standard library.
I've updated the site for Swift 4.2,
and look forward to keeping it in sync going forward.

Look out for more of these in the future!

### Conferences and Meetups Near You

This fall,
I'll have the honor of presenting at
some of the best developer conferences of the year,
in New York City, Logroño, Madrid, and Paris:

- [try! Swift NYC](https://www.tryswift.co/events/2018/nyc/) • New York City, USA • September 4th & 5th
- [NSSpain](https://2018.nsspain.com) • Logroño, Spain • September 12th – 14th
- NSCoders Night • Madrid, Spain • September 11th
- [FrenchKit](https://frenchkit.fr) • Paris, France • September 20th & 21st

If you plan on attending any of these
or will be in any of these cities when I'm there,
[please get in touch](https://twitter.com/mattt) (my DMs are open).

---

Thank you to everyone who's supported NSHipster over the past 6 years.
We couldn't be more excited about what's to come.

Until next time:
May your code continue to compile and inspire.
