---
title: Bug Reporting
author: Mattt
category: ""
excerpt: If you've ever been told to "file a Radar"
  and wondered what that meant, this week's article has just the fix.
hiddenlang: ""
status:
  swift: n/a
---

"File a radar."
It's a familiar refrain for those of us developing on Apple platforms.

It's what you hear when you complain about
a wandering UIKit component.<br/>
It's the response you get when you share
some hilariously outdated documentation.<br/>
It's that voice inside your head
when you reopen Xcode for the twelfth time today.

If you've ever been told to "file a Radar" and wondered what that meant,
this week's article has just the fix.

---

Radar is Apple's bug tracking software.
Any employee working in an engineering capacity
interacts with it on a daily basis.

Radar is used to track features and bugs alike,
in software, hardware, and everything else:
documentation, localization, web properties ---
heck, even the responses you get from Siri.

When an Apple engineer hears the word "Radar",
one of the first things that come to mind
is Anika the Antbear,
the iconic purple mascot of Radar.app.
But more important than the app or even the database itself,
Radar is a workflow that guides problems from report to verification
across the entire organization.

When a Radar is created,
it's assigned a unique, permanent ID.
Radar IDs are auto-incrementing integers,
so you can get a general sense of when a bug was filed
from the number alone.
(At the time of writing,
new Radars have 8-digit IDs starting with 4.)

{% note do %}

Radar.app uses the `rdar://` custom URL scheme.
If an Apple employee clicks a [rdar://xxxxxxxx](rdar://30000000) link
with an ID, it'll open directly to that Radar.
Otherwise, clicking this link pops up a dialog box with the message
"There is no application set to open the URL rdar://xxxxxxxx."

{% endnote %}

## Reporting Bugs as External Developers

Unfortunately for all of us not working at Apple,
we can't access Radar directly.
Instead, we have to file bugs through systems
that interface with it indirectly.

### Apple Bug Reporter

[Apple Bug Reporter](https://bugreport.apple.com)
is the primary interface to Radar for external developers.

Bug Reporter was recently updated to a modern web app
that resembles Mail and other apps on
[iCloud.com](https://icloud.com).
For anyone who remembers its predecessor,
I think you'll agree that this is a huge improvement.

{% asset apple-bug-reporter.png %}

Choose the product related to the problem you're reporting
and enter a descriptive title.
If it's a bug,
specify whether the kind of bug
(Performance, Crash/Hang/Data Loss, UI/Usability, etc.)
and how often you can produce it.
Finally,
write a description of the problem,
including a summary,
steps to reproduce,
expected vs. actual results,
and information about the configuration and version of your system.

This information is compiled into a Radar
that is then triaged, assigned, prioritized, and scheduled
by engineers.

### Feedback Assistant

If you're participating in the
[Apple Beta Software Program](https://beta.apple.com/sp/betaprogram/welcome),
and encounter a problem with your prerelease OS,
you can alternatively report it using Feedback Assistant
(find it on macOS and iOS with Spotlight).

{% asset feedback-assistant.png %}

Feedback Assistant offers a more streamlined experience
that's optimized for providing feedback about the platform you're living on.
It automatically captures a sysdiagnose
and other information about your system
in order to diagnose the problem you're encountering more accurately.

Whereas Bug Reporter is your first choice
for problems directly related to your work,
Feedback Assistant is often a more convenient option
for any bumps you encounter in your day-to-day.

## Third-Party Bug Reporting Tools

When developers encounter a problem,
they're motivated to do something about it
rather than merely complain.
This is the reason they file bug reports in the first place.

This is, incidentally, the same motivation
that compels us to create tools to fix problems that we find
in the bug reporting process itself.

Here are some essential tools for bug reporting
from the Apple developer community:

### Open Radar

The fundamental problem with Radar as an external developer
is lack of transparency.
One of the ways this manifests itself is that
there's no way to know what anyone else has reported.
All too often,
you'll invest a good deal of time writing up a detailed summary
and creating a reproducible test case
only to have the bug unceremoniously closed as a duplicate.

[Open Radar](https://openradar.appspot.com), created by
[Tim Burks](https://github.com/timburks),
is a public database of bugs reported to Apple.
Over the many years of its existence,
Open Radar has become the de facto way
for us to coordinate our bug reports.

{% asset open-radar.png %}

When you file a Radar with apple,
you're encouraged to also
[file it with Open Radar](https://openradar.appspot.com/myradars/add)
(unless it's something that shouldn't be disclosed publicly).
Your contribution can help anyone else
who might have the same problem in the future.

### Brisk

Although the recently-overhauled Bug Reporter web app is quite nice to use,
there's no replacement for a native app.

[Brisk](https://github.com/br1sk/brisk/),
created by [Keith Smiley](https://github.com/keith),
is a macOS app for filing Radars through Apple's Bug Reporter.
It's a fully-featured app,
with support for two-factor authentication,
saving radars as drafts,
automatically duping radars by ID,
and even opening `rdar://` URLs.
But its killer feature is the ability to cross-post bug reports to Open Radar.

{% asset brisk-app.png %}

To get started,
[download the latest release](https://github.com/br1sk/brisk/releases/latest)
from GitHub
or install via [Homebrew](https://brew.sh) with the following command:

`$ brew cask install Brisk`

## Advice for Writing a _Good_ Bug Report

So now that you know how to write a bug report
let's talk about how to write a good one.

### One Problem, One Bug Report

You won't be doing anyone any favors
by reporting multiple bugs in the same report.
Each additional concern you raise makes it
both more difficult to understand
and less actionable for the assigned engineer.

Instead, file multiple Radars
and reference any related problems by ID in your summary.

### Choose a Title Strategically

Before an issue can start to be resolved by an engineer,
it needs to find its way to them.
The best way to ensure things get to the right person
is to surface the most important information in the title.

- For problems about an API,
  put the fully-qualified symbol name in the title
  (for example, `URLSession.dataTaskWithRequest(_:)`).
- For problems related to documentation,
  include the full list of navigation breadcrumbs in the title
  (for example,
  "Foundation > URL Loading System > URLSession > dataTaskWithRequest:").
- For problems with a particular app,
  reference the app name, version, and build number,
  which are found in the "About" info box
  (for example, "Xcode 10.0 beta (10L176w)").

### Don't Be Antagonistic

Chances are, you're not at your cheeriest when you're writing a bug report.

It's unacceptable that this doesn't work as expected.
You wasted hours trying to debug this problem.
Apple doesn't care about software quality anymore.

That sucks. We get it.

However, none of that is going to solve your problem any faster.
If anything,
hostility will make an engineer less likely to address your concern.

Remember that there's a person on the other end of your bug report.
Practice [empathy](https://nshipster.com/empathy/).

{% note do %}

Peter Steinberger has more great advice on the subject
[in this blog post](https://pspdfkit.com/blog/2016/writing-good-bug-reports/).

{% endnote %}

## How to Signal Boost Bug Reports

External developers may often liken the experience of filing a Radar
to sending a message into a black hole.
With thousands of new Radars coming in every hour,
the odds of the right person seeing your bug report
in a timely manner seem impossibly small.

Fortunately, there are a few things you can do to help your chances:

### Duplicating Existing Radars

In Apple's bug triage workflow,
each problem is (ideally) tracked by a single Radar.
If multiple Radars seem to report the same underlying problem,
the oldest or most specific one is kept around
while the others are closed as duplicates.
This resolution can be frustrating for external developers,
as this is often the last word they hear about a problem they're having ---
particularly if the original Radar isn't visible to them.

That said, having your bug closed as a duplicate isn't always a bad thing.
You can knowingly file a duplicate of an existing Radar as a way to
say _"I have this problem, too"_ and _"Please fix this first"_.
However annoying this might be for the Apple engineer responsible for triage,
part of me can't help projecting a courage to those doomed bug reports,
who courageously sacrifice themselves in the name of software quality.
_Semper fidelis_, buggos.

### Twitter

Some teams within Apple are quite responsive to feedback on Twitter.
It's hard to stay in-the-loop when you're in The Loop,
so engineers and higher-ups alike often tune in
to channel the _vox populi_.

Due to the chilling nature of Apple's social media policies,
you're unlikely ever to hear anything back.
But rest assured that your Tweets are showing up
on a saved Twitter search somewhere in Cupertino.

### Blogging

Apple engineers are developers like you or me,
and many of them pay attention to what we're writing about.
In addition to being helpful to fellow developers,
a simple write-up may be just the thing that convinces
that one engineer to take another look.

---

Speaking from my personal experience working at Apple,
Radar is far and away the best bug tracking systems I've ever used.
So it can be frustrating to be back on the outside looking in,
knowing full well what we're missing out on as external developers.

In contrast to open source software,
which empowers anyone to fix whatever bugs they might encounter,
the majority of Apple software is proprietary;
there's often very little that we can do.
Our only option is to file a bug report and hope for the best.

Fortunately, things have gotten better.
The new Bug Reporter site is excellent,
and the process itself appears to be moving towards greater transparency:

> Encouraging change on @apple’s bug reporter…
> I’ve been hearing of people now getting notified
> when an original is “awaiting verification”,
> and not just “closed”"
> <cite>Dave DeLong ([@davedelong](https://twitter.com/davedelong))
> [via Twitter](https://twitter.com/davedelong/status/1017853619717079040)</cite>

The only way things continue to improve is if we communicate.

So the next time you find something amiss, remember:
"file a radar".
