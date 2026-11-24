---
title: cron & Calendar.RecurrenceRule
author: Mattt
category: Cocoa
excerpt: >-
  American Thanksgiving is the fourth Thursday of November.
  That's easy to say and impossible to write as a cron expression.
  A recurrence rule can say it,
  and as of iOS 18, so can Foundation.
status:
  swift: 6.1
---

I have a bespoke little piece of software
that I vibecoded for myself.
Every Sunday, it walks me through a review of the week,
and on the first Sunday of the month,
a review of the month.

Or that's the idea.
The scheduler behind it takes cron expressions,
and cron can't say "the first Sunday of the month".
So the monthly review starts up every Sunday at 5 PM,
checks the date,
and quits unless it's one of the first seven days of the month.
This past Sunday, November 22, it did just that.

American Thanksgiving is this Thursday:
the fourth Thursday of November,
which is to say, another date that cron can't write down.
It seemed like the right week to find out why.

---

## Eight Days a Week

A cron expression has five fields:
minute, hour, day of month, month, and day of week.
That last one counts from 0 to 7,
with Sunday at both ends.
(If you can never remember which field is which,
there's [crontab.guru](https://crontab.guru/#0_17_1-7_*_0).)

To get the first Sunday of the month,
you might ask for a Sunday that falls in the first seven days:

```
0 17 1-7 * 0
```

Here's what `crontab(5)` has to say about that:

> If both fields are restricted (ie, are not \*),
> the command will be run when either field matches the current time.

_Either._

In fact, that expression doesn't wait for the first Sunday.
In November 2026, it runs on the 1st through the 7th,
and then on the 8th, the 15th, the 22nd, and the 29th:
eleven times, when you asked for one.
(Other months, you might get off with ten.)
It's the only place in a crontab
where filling in another field makes a job run _more_ often.

The standard workaround is to run every Sunday
and check the date in the command itself:

```
0 17 * * 0  [ "$(date +\%d)" -le 7 ] && monthly-review
```

Which is what mine does, more or less.

{% info %}

Some schedulers, like [Quartz](https://en.wikipedia.org/wiki/Quartz_%28scheduler%29)
(no, not _that_ [Quartz](https://en.wikipedia.org/wiki/Quartz_%28graphics_layer%29)),
extend the syntax
so that `FRI#3` means the third Friday of the month.
The cron on your Mac doesn't.
It does have a loophole, though.
A day field that starts with `*` doesn't count as restricted,
so `0 17 1-7 * */7` runs on the first Sunday and only then.
(`*/7` matches 0 and 7, and both are Sunday.)
Other schedulers may not go along with it.

`launchd` is no help either.
A job's `StartCalendarInterval` can set both `Day` and `Weekday`,
and the man page says that the job starts
"if either one matches the current date",
the same as cron.
But when I tried it on macOS 27,
a job with both keys ran whenever the weekday matched
and ignored the day of the month.

{% endinfo %}

## The Fourth Thursday of November

Thanksgiving is the fourth Thursday of November.
But it wasn't always.

<aside class="parenthetical">

How the holiday came to be at all is another story,
and Philip Deloria tells it in
["The Invention of Thanksgiving"](https://www.newyorker.com/magazine/2019/11/25/the-invention-of-thanksgiving).

</aside>

In 1863,
Abraham Lincoln proclaimed a day of thanksgiving
for the last Thursday of November,
and the custom mostly held until 1939.
That year, November had five Thursdays,
and the last one fell on the 30th.
Franklin Roosevelt,
hoping that a longer shopping season would help the economy,
moved the holiday up a week.
Twenty-three states went along with him.
Twenty-two kept the old date.
Three celebrated both.
The mayor of Atlantic City called the new one "Franksgiving".

Roosevelt's rule was the next-to-last Thursday,
and he kept to it for two more years.
Then Congress passed a third rule,
the fourth Thursday,
which he signed into law on December 26, 1941.

Each of those rules takes only a few words to say,
and none of them can be written as a cron expression.
As recurrence rules,
they all start with `FREQ=YEARLY;BYMONTH=11`
and differ only in `BYDAY`:

|         | Lincoln | <abbr title="Franklin D. Roosevelt">FDR</abbr> | Congress |
| ------- | ------- | ------ | -------- |
| `BYDAY` | `-1TH`  | `-2TH` | `4TH`    |
| 1939    | Nov 30  | Nov 23 | Nov 23   |
| 1940    | Nov 28  | Nov 21 | Nov 28   |
| 1941    | Nov 27  | Nov 20 | Nov 27   |

`RRULE` comes from iCalendar,
the format of every `.ics` file you've ever been sent.
It became a standard in 1998 as [RFC 2445](https://datatracker.ietf.org/doc/html/rfc2445),
written by engineers at Lotus and Microsoft
and based on vCalendar,
a mid-'90s creation of the Versit Consortium:
Apple, AT&T, IBM, and Siemens.
([RFC 5545](https://datatracker.ietf.org/doc/html/rfc5545) replaced it in 2009.)

Where cron matches fields against the clock,
a recurrence rule starts with a frequency
and narrows it down with `BY` parts.
`BYDAY=4TH` is the fourth Thursday.
`BYDAY=-1TH` is the last.
And my monthly review is `FREQ=MONTHLY;BYDAY=1SU`.

{% info %}

Canadian Thanksgiving comes earlier,
because it gets cold sooner up there:
the second Monday of October,
or `FREQ=YEARLY;BYMONTH=10;BYDAY=2MO`.

[The last time Thanksgiving came up here](/bless/),
I noted that it falls on the day Americans observe
Columbus Day, or Indigenous Peoples' Day.
As recurrence rules, they're one and the same.

{% endinfo %}

## Calendar.RecurrenceRule

EventKit has had [`EKRecurrenceRule`](https://developer.apple.com/documentation/eventkit/ekrecurrencerule) since iOS 4,
but it exists to be attached to an event in someone's calendar.
As of iOS 18 and macOS 15,
Foundation has a recurrence rule of its own:

```swift
import Foundation

let calendar = Calendar(identifier: .gregorian)

let thanksgiving = Calendar.RecurrenceRule.yearly(
    calendar: calendar,
    months: [11],
    weekdays: [.nth(4, .thursday)]
)

let start = calendar.date(from: DateComponents(year: 2026))!
for date in thanksgiving.recurrences(of: start).prefix(3) {
    print(date.formatted(date: .complete, time: .omitted))
}
// Thursday, November 26, 2026
// Thursday, November 25, 2027
// Thursday, November 23, 2028
```

Change that `4` to `-1` and you get Lincoln's Thanksgiving,
which agrees with ours until 2028,
the next time November has five Thursdays.

The rule holds a calendar,
so it accounts for time zones and daylight saving time.
And `recurrences(of:)` returns a sequence,
so a rule with no end is fine,
as long as you don't ask for all of it.

There's a catch, though:
The documentation says that the calculations
"are implemented according to RFC-5545",
and for some rules, they... aren't?
Take the last weekday of the month:

```swift
let lastWeekday = Calendar.RecurrenceRule.monthly(
    calendar: calendar,
    weekdays: [
        .every(.monday), .every(.tuesday), .every(.wednesday),
        .every(.thursday), .every(.friday),
    ],
    setPositions: [-1]
)

for date in lastWeekday.recurrences(of: start).prefix(3) {
    print(date.formatted(date: .complete, time: .omitted))
}
// Wednesday, January 7, 2026
// Friday, February 6, 2026
// Friday, March 6, 2026
```

None of those is the last weekday of anything.
As of macOS 27,
a monthly rule with a plain weekday, like `.every(.tuesday)`,
gives you the first Tuesday of the month
where the RFC calls for every one of them.
([I filed a bug](https://github.com/swiftlang/swift-foundation/issues/2464).)
Ordinal weekdays, like the ones for Thanksgiving, come out right.
(Before macOS 27, [not if your week starts on Monday](https://github.com/swiftlang/swift-foundation/issues/1387).)

## RRULE

Foundation is missing a couple of other things, too.
`Calendar.RecurrenceRule` has no initializer that takes an `RRULE` string,
so it can't read the rules in that table up there,
and it has no way to describe itself to a person.

[RRULE](https://github.com/mattt/swift-rrule) is a small package I cooked up that covers all three.
It parses RFC 5545 recurrence rules,
describes them in English, German, Spanish, or French,
and works out their dates itself,
tested against every example in the RFC:

```swift
import RRULE

let thanksgiving = try RecurrenceRule.parse("FREQ=YEARLY;BYMONTH=11;BYDAY=4TH")
print(thanksgiving.formatted())
// Annually in November on the fourth Thursday

let lastWeekday = try RecurrenceRule.parse(
    "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1"
)
for date in lastWeekday.recurrences(of: start).prefix(3) {
    print(date.formatted(date: .complete, time: .omitted))
}
// Friday, January 30, 2026
// Friday, February 27, 2026
// Tuesday, March 31, 2026
```

It also converts to and from `Calendar.RecurrenceRule`,
for code that already speaks Foundation.

## Computus

Recurrence rules have their limits, too.
RFC 5545 has an example for U.S. presidential elections,
held on "the first Tuesday after a Monday in November",
and it takes some squinting:

```
FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8
```

And then there's Easter,
which **no** recurrence rule can express.
That's a little awkward for a calendar format,
because Easter is the reason our calendar is the way it is.

Easter is the Sunday after the first full moon
that falls on or after March 21.
Not the full moon in the sky, mind you,
but an _ecclesiastical_ full moon:
the fourteenth day of a lunar month that's reckoned from tables.
The calculation has a name, _computus_,
and according to Donald Knuth,
<q>there are many indications that the sole nontrivial application of arithmetic
in Europe during the Middle Ages was the calculation of Easter date</q>.

By the sixteenth century,
the tables and the sky had come apart.
The Julian calendar has a leap year every four years,
which is slightly too many,
and the equinox had slipped by ten days.
So in 1582, Pope Gregory XIII issued the bull _Inter gravissimas_,
which says what the reform was for:

> ...to restore the vernal equinox to its original place
> from which it has already receded
> by about ten days since the Council of Nicaea...

Ten days were dropped from that October,
so that the 4th was followed by the 15th.
And century years stopped being leap years
unless they're divisible by 400.
The leap year rule you've written a dozen times
is there to keep Easter in its place.

Great Britain and its colonies held out until 1752,
by which time there were eleven days to drop.
The manual page for `cal` in Seventh Edition Unix notes that
"the calendar produced is that for England and her colonies",
and then, in a paragraph of its own:
"Try September 1752."

```terminal
$ cal 9 1752
   September 1752
Su Mo Tu We Th Fr Sa
       1  2 14 15 16
17 18 19 20 21 22 23
24 25 26 27 28 29 30
```

So why can't a recurrence rule find Easter?
Every part of a rule tests a field of the Gregorian calendar:
a month, a day of the month, a weekday, a week of the year.
None of them knows about the moon.
Consider 2009 and 2026.
Both are common years that start on a Thursday,
so their calendars are the same, day for day.
But Easter fell on April 12 in 2009
and on April 5 in 2026.
A rule that runs every year can't tell them apart.

Easter's dates do repeat, eventually:
once every 5,700,000 years.

Not even Apple tries.
The US Holidays calendar in the Calendar app
is a subscription to [a file on iCloud](https://calendars.icloud.com/holidays/us_en-us.ics).
In it, Thanksgiving is a rule,
`FREQ=YEARLY;COUNT=5;BYDAY=4TH;BYMONTH=11`,
and Easter is five separate events,
one for each year through 2029.

For Easter, you still have to write code.
Fortunately, someone did that in 1876,
when "a New York correspondent" sent [this algorithm](https://doi.org/10.1038/013487a0) to the journal _Nature_:

```swift
func easter(in year: Int) -> DateComponents {
    let a = year % 19
    let (b, c) = year.quotientAndRemainder(dividingBy: 100)
    let (d, e) = b.quotientAndRemainder(dividingBy: 4)
    let f = (b + 8) / 25
    let g = (b - f + 1) / 3
    let h = (19 * a + b - d - g + 15) % 30
    let (i, k) = c.quotientAndRemainder(dividingBy: 4)
    let l = (32 + 2 * e + 2 * i - h - k) % 7
    let m = (a + 11 * h + 22 * l) / 451
    let (month, day) = (h + l - 7 * m + 114).quotientAndRemainder(dividingBy: 31)
    return DateComponents(year: year, month: month, day: day + 1)
}

easter(in: 2026) // April 5
```

There is another way out.
In 1928, Parliament passed the Easter Act,
which sets Easter as
"the first Sunday after the second Saturday in April".
That one's easy:

```
FREQ=YEARLY;BYMONTH=4;BYDAY=SU;BYMONTHDAY=9,10,11,12,13,14,15
```

But that caught on about as well as
that one time a state legislature tried to redefine π as 3.
Which is to say, it didn't:
nearly a century later,
the Act still hasn't come into force.

<aside class="parenthetical">

EDIT: The one about π = 3 turns out to be
[an April Fools' joke](https://en.wikipedia.org/wiki/Mark_Boslough) from 1998.
The real one happened [in Indiana, in 1897](https://en.wikipedia.org/wiki/Indiana_pi_bill).
The number was 3.2,
and the House passed it without a dissenting vote.

</aside>

---

Recurrence rules turn up where you don't expect them.
I was surprised and delighted to see
that the ChatGPT app uses them for its scheduled tasks:
underneath, [each schedule is an iCalendar event](https://simonwillison.net/2025/Jan/15/chatgpt-tasks/),
`RRULE` and all.

Defaults matter,
and they carry on long after you'd expect them to.
(We've [said as much before](/apns-device-tokens/):
precedent is a form of inertia.)
Somebody settled on five fields for cron in the 1970s,
and that's still how my software knows when to wake up.
The engineers at Lotus and Microsoft who standardized `RRULE` in 1998
presumably didn't have a chatbot in mind.
And the leap year rule that Pope Gregory signed off on in 1582,
all to keep a feast day where it belonged,
is in every date library you'll ever use.

As for my monthly review:
the scheduler still takes only cron,
so it'll keep checking the date every Sunday.

<aside class="parenthetical">
If you're reading this on the fourth Thursday of November,
Happy Thanksgiving. 🦃
</aside>

[RRULE is open source on GitHub.](https://github.com/mattt/swift-rrule)
Let me know what you think!
