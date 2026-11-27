---
title: Bug Reporting
author: Mattt
category: Miscellaneous
excerpt: >-
  If you've ever been told to "file a Radar"
  and wondered what that meant,
  this week's article has just the fix.
revisions:
  "2018-07-16": Original publication
  "2026-10-09": Rewritten for Feedback Assistant
status:
  swift: n/a
  reviewed: October 9, 2026
---

"File a radar."
It's a familiar refrain for those of us developing on Apple platforms.

It's what you hear when you complain about
a wandering UIKit component.<br/>
It's the response you get when you share
some hilariously outdated documentation.<br/>
It's that voice inside your head
when you reopen Xcode for the twelfth time today.

These days, you're just as likely to hear
"Did you file feedback?" or "What's the FB number?"
It all means the same thing.

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
When this article was first published in 2018,
new Radars had 8-digit IDs starting with 4.
Today they have nine digits.

{% info do %}

Radar.app uses the `rdar://` custom URL scheme.
If an Apple employee clicks a [rdar://xxxxxxxx](rdar://30000000) link,
it opens directly to that Radar.
For the rest of us, it does nothing at all.
You'll still see these links in Apple's open source projects,
like the [Swift changelog](https://github.com/swiftlang/swift/blob/main/CHANGELOG.md),
as breadcrumbs for engineers on the inside.

{% endinfo %}

## Reporting Bugs as External Developers

Unfortunately for all of us not working at Apple,
we can't access Radar directly.
Instead, we file bugs through a system that feeds into it:
[Feedback Assistant](https://developer.apple.com/feedback-assistant/).

Old-timers may remember Apple Bug Reporter (bugreport.apple.com),
the web app external developers used to file Radars for years.
At WWDC 2019,
Apple retired Bug Reporter
and folded developer bug reports into Feedback Assistant,
which until then had been the place
for beta testers to report problems.

Feedback Assistant is available
on the web at [feedbackassistant.apple.com](https://feedbackassistant.apple.com)
and as an app on Mac, iPhone, and iPad.
The Mac app ships with every version of macOS;
find it with Spotlight
or in `/System/Library/CoreServices/Applications`.
On iPhone and iPad,
the app appears on the Home Screen when you're running a beta.
On either platform, you can also launch it with the `applefeedback://` URL scheme.

Prefer the app when you can.
It automatically collects a sysdiagnose
and runs diagnostics specific to the area you're reporting on.
From an iPhone or iPad,
it can even collect diagnostics from a paired
Apple Watch, Apple TV, or HomePod.
On the website, you'll have to gather and upload any logs yourself.

When you create new feedback,
Feedback Assistant first asks what it's about.
Developers have three starting points:

Developer Technologies & SDKs
: For bugs in a framework or API.
  Choose the technology (for example, Core Bluetooth)
  and the OS where the problem occurs.

Developer Tools & Resources
: For problems with Xcode, App Store Connect,
  or other developer tools and services.

A specific OS (iOS & iPadOS, macOS, tvOS, watchOS, HomePod)
: For problems in general use of the system,
  like a bug in Messages.

Despite the name,
Feedback Assistant isn't only for bugs.
If you want an API that doesn't exist yet,
choose "Suggestion" as the type of issue.
Apple engineers call these "enhancement requests",
and they count.

### FB Numbers

When you submit feedback,
it's assigned a Feedback Assistant ID:
`FB` followed by a number, like `FB18158843`.
This is the number to quote any time you talk to Apple
about your problem.

Behind the scenes,
your report is tracked in Radar with an ID of its own.
You'll sometimes see both in Apple's release notes,
which list the Radar ID in parentheses,
followed by the FB number when a developer reported the issue:

> Fixed: Unable to set Icon Composer icon as alternate iOS icon
> (153305178) (FB18025356)
> <cite>[Xcode 26 Release Notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-26-release-notes)</cite>

Finding your FB number in a list like this
is about as close to a thank-you note as you'll get.

## Attachments

A bug report tells an engineer what you saw.
Attachments let them see it for themselves.

**Sysdiagnose.**
A sysdiagnose is an archive of diagnostic information
from across the operating system,
including logs and recent crash reports.
Apple wants one with every report,
"even if you think one is not needed."
The Feedback Assistant app attaches one for you.
To capture one yourself on a Mac,
press <kbd>Control</kbd>-<kbd>Option</kbd>-<kbd>Command</kbd>-<kbd>Shift</kbd>-<kbd>.</kbd>
or run `sudo sysdiagnose`;
after a few minutes, the archive appears in `/private/var/tmp`.
Instructions for other devices are on Apple's
[Profiles and Logs](https://developer.apple.com/feedback-assistant/profiles-and-logs/) page.
Logs roll over,
so capture a sysdiagnose as soon as possible after the problem occurs
and note the time in your report.
For crashes, reproduce outside of Xcode,
or the debugger will catch the crash
before the system can write a crash report.

**Profiles.**
For dozens of technologies,
from APNs and App Intents to Wallet and Wi-Fi,
Apple provides debug profiles that turn on extra logging.
They're on the same
[Profiles and Logs](https://developer.apple.com/feedback-assistant/profiles-and-logs/) page,
each with its own instructions.
Usually an engineer will ask you to install one,
but if your bug involves one of the listed technologies,
installing the profile _before_ you reproduce the problem
saves a round trip.

**Sample projects.**
If the problem appears in your app,
the most useful thing you can do
is reproduce it in a small, self-contained project.
More often than you'd expect,
this is where you discover that the bug was yours all along ---
which is its own kind of victory.
If the problem survives,
attach the project.
An engineer who can build and run your sample
can start fixing the bug right away.
(Attach a sysdiagnose, too;
it helps get your report to the right engineer.)

**Everything else.**
For anything visual, attach a screenshot or screen recording.
For crashes, kernel panics, hardware problems,
or printing issues on a Mac,
Apple requires a
[System Information report](https://support.apple.com/guide/mac-help/get-system-information-about-your-mac-syspr35536/mac).

## What About Swift?

Not every bug goes through Feedback Assistant.
Swift is developed in the open,
and the Swift project tracks bugs with GitHub Issues:
[swiftlang/swift](https://github.com/swiftlang/swift/issues)
for the compiler and standard library,
[swiftlang/swift-package-manager](https://github.com/swiftlang/swift-package-manager/issues)
for SwiftPM,
[swiftlang/sourcekit-lsp](https://github.com/swiftlang/sourcekit-lsp/issues)
for SourceKit-LSP,
and [swiftlang/swift-foundation](https://github.com/swiftlang/swift-foundation/issues)
for the open source Swift implementation of Foundation.

The Swift project's
[contributing guide](https://www.swift.org/contributing/#reporting-bugs)
draws the line:
if a bug can be reproduced only within an Xcode project or a playground,
or if it's covered by an Apple NDA,
file it with Feedback Assistant instead.
Likewise, a bug in Foundation as it ships on Apple platforms
belongs in Feedback Assistant.

Otherwise, the advice is familiar:
a concise description,
a reduced test case,
and the compiler version and platform.
Unlike with Radar,
you can search existing issues before you file,
and even open a pull request with the fix.
Other open source projects work the same way;
WebKit bugs go to [bugs.webkit.org](https://bugs.webkit.org).

## Third-Party Tools

The fundamental problem with Radar as an external developer
is lack of transparency.
There's no way to see what anyone else has reported.
All too often,
you'll invest a good deal of time writing up a detailed summary
and creating a reproducible test case
only to have the bug unceremoniously closed as a duplicate
of a report you'll never see.

So developers did what developers do.
[Open Radar](https://openradar.appspot.com), created by
[Tim Burks](https://github.com/timburks) in 2008,
is a public database of bugs reported to Apple,
and for years it was the de facto way
for us to coordinate our bug reports.
[Brisk](https://github.com/br1sk/brisk/),
created by [Keith Smiley](https://github.com/keith),
was a native Mac app for filing Radars
that could cross-post them to Open Radar.

Brisk worked by talking to Bug Reporter's web "APIs",
so it went the way of Bug Reporter.
Open Radar, on the other hand, is still online as of this writing,
with developers posting FB numbers where Radar IDs used to be.
It's a community-run service,
so don't count on it as the only place your report lives.
But if your bug can be disclosed publicly,
posting it there (or in a GitHub issue, or on your blog)
gives other developers something to find
and an FB number to cite in their own reports.

## Advice for Writing a _Good_ Bug Report

So now that you know how to file a bug report,
let's talk about how to write a good one.

### One Problem, One Bug Report

You won't be doing anyone any favors
by reporting multiple bugs in the same report.
Each additional concern makes it
both more difficult to understand
and less actionable for the assigned engineer.
Apple may even send it back
and ask you to resubmit each issue separately.
Instead, file one report per problem
and reference related reports by FB number.

### Choose a Title Strategically

Before an issue can be resolved by an engineer,
it needs to find its way to them.
The best way to ensure things get to the right person
is to surface the most important information in the title.

- For problems about an API,
  put the fully-qualified symbol name in the title
  (for example, `URLSession.data(for:delegate:)`).
- For problems related to documentation,
  include the navigation breadcrumbs
  (for example,
  "Foundation > URLSession > data(for:delegate:)").
- For problems with a particular app,
  include the app name, version, and build number
  from its "About" window.
- For anything platform- or version-specific, say so.
  Apple's own example:
  _"Calendar events on iOS 15.2 beta are missing after creating a quick event"_
  is better than _"Calendar events are missing"_.

### Steps, Expected, Actual

The body of your report should let someone
who has never heard of your app
reproduce the problem on the first try.
Write numbered steps,
then say what you expected to happen
and what actually happened.

```text
1. Open the attached sample project and run it on an iPhone simulator.
2. Tap "Load".
3. Rotate the simulator to landscape.

Expected: The list keeps its scroll position.
Actual: The list scrolls back to the top.
```

Then consider anything else that might affect the outcome.
Are you signed in to iCloud?
Is an accessibility setting turned on?
Did it start with a particular beta?
Details that seem irrelevant to you
are often exactly what an engineer needs.

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
Practice [empathy](/empathy/).

## After You File

External developers often liken filing a bug report
to sending a message into a black hole.
Feedback Assistant has made it a little less dark.
Each report shows a status,
such as "Open", "Potential Fix Identified",
or "Investigation Complete – Works as Designed",
along with a count of **Recent Similar Reports**:
none, fewer than 10, or more than 10 grouped with yours in the past year.
It's not much,
but it's more than Bug Reporter ever told us.
If Apple needs more information,
you'll get an email asking you to check your report.
Respond promptly.

Your FB number is your ticket to every other conversation with Apple.
When you ask about a problem on the
[Apple Developer Forums](https://developer.apple.com/forums/),
include it:
Apple engineers can look it up directly,
and other developers can cite it in their own reports.
(Just know that mentioning a problem on the forums,
even in a thread an Apple engineer replies to,
isn't the same as filing a bug.)
When you request
[code-level support](https://developer.apple.com/support/technical/)
from Developer Technical Support,
include your FB number along with the details from your report;
for beta software, Apple asks that you file feedback first.
And when you write a workaround in your own code,
leave the FB number in a comment,
so your future self knows when it's safe to remove.

## How to Signal Boost Bug Reports

With so many reports coming in,
the odds of the right person seeing yours
in a timely manner can seem impossibly small.
Fortunately, there are a few things you can do to help your chances.

### Duplicating Existing Reports

In Apple's bug triage workflow,
each problem is (ideally) tracked by a single Radar.
Reports that describe the same underlying problem
are grouped together,
and duplicates are closed in favor of the original.

That's no reason to stay quiet.
Apple asks developers to submit feedback for every issue,
"even if you think an issue is obvious
and are sure others have reported it",
because the number of reports tells them how many people are affected.
Filing a duplicate is how you say
_"I have this problem, too"_ and _"Please fix this first"_.
If you know the FB number of an existing report,
mention it and ask to have yours marked as a duplicate;
you'll be notified when the original is closed.

Part of me can't help projecting a certain courage onto those doomed bug reports,
who sacrifice themselves in the name of software quality.
_Semper fidelis_, buggos.

### Filing Early

Apple says that reporting issues during the beta cycle
increases the likelihood that they'll be addressed by the public release.
A report filed against beta 1
has a much better chance than one filed in September.

### Writing About It

Apple engineers are developers like you or me,
and many of them pay attention to what we're writing about.
In addition to being helpful to fellow developers,
a blog post or forum thread that includes your FB number
may be just the thing that convinces
that one engineer to take another look.

---

Speaking from my personal experience working at Apple,
Radar is far and away the best bug tracking system I've ever used.
So it can be frustrating to be on the outside looking in,
knowing full well what we're missing out on as external developers.

In contrast to open source software,
which empowers anyone to fix whatever bugs they might encounter,
the majority of Apple software is proprietary;
there's often very little that we can do.
Our only option is to file a bug report and hope for the best.

But things have gotten better.
Feedback Assistant collects the diagnostics we used to gather by hand,
statuses tell us more than they used to,
and the parts of the stack that moved into the open,
like Swift and Foundation,
take bug reports (and fixes) from anyone.

The only way things continue to improve is if we communicate.

So the next time you find something amiss, remember:
"file a radar".
Or, as they say these days,
"file feedback".
