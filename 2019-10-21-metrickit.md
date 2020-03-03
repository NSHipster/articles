---
title: MetricKit
author: Mattt
category: Xcode
excerpt: >-
  At WWDC this year,
  Apple announced a coordinated effort between Xcode 11 and iOS 13
  to bring new insights to developers
  about how their apps are performing in the field.
status:
  swift: 5.1
---

As an undergraduate student,
I had a radio show called
_"Goodbye, Blue Monday"_
(I was really into Vonnegut at the time).
It was nothing glamorous ---
just a weekly, 2-hour slot at the end of the night
before the station switched into automation.

If you happened to be driving through the hills of Pittsburgh, Pennsylvania
late at night with your radio tuned to
[<abbr title="Radio Carnegie Tech">WRCT</abbr> 88.3](http://www.wrct.org),
you'd have heard an eclectic mix of
[Contemporary Classical](https://beta.music.apple.com/us/album/acoustica/410402556),
[Acid Jazz](https://beta.music.apple.com/us/album/a-funk-odyssey/203132910),
[Italian Disco](https://beta.music.apple.com/us/album/ma-quale-idea-single/1415038751), and
[Bebop](https://beta.music.apple.com/us/album/kind-of-blue/268443092).
That, and the stilting, dulcet baritone of
a college kid doing his best impersonation of
[Tony Mowod](http://old.post-gazette.com/magazine/20010404mowod4.asp).

Sitting there in the booth,
waiting for tracks to play out before launching into an
<abbr title="Federal Communications Commission">FCC</abbr>-mandated
<abbr title="Public Service Announcement">PSA</abbr>
or on-the-hour
[station identification](https://en.wikipedia.org/wiki/Station_identification),
I'd wonder:
_Is anyone out there listening?_
_And if they were, did they like it?_
I could've been broadcasting static the whole time and been none the wiser.

The same thoughts come to mind whenever I submit a build to App Store Connect...
but then I'll remember that, unlike radio,
you _can_ actually know these things!
And the latest improvements in Xcode 11 make it easier than ever
to get an idea of how your apps are performing in the field.

We'll cover everything you need to know in this week's NSHipster article.
So as they say on the radio:
_"Don't touch that dial (it's got jam on it)"._

<hr/>

MetricKit is a new framework in iOS 13
for collecting and processing battery and performance metrics.
It was announced at [WWDC this year](/wwdc-2019/)
along with XCTest Metrics and the Xcode Metrics Organizer
as part of a coordinated effort to bring new insights to developers
about how their apps are performing in the field.

{::nomarkdown}

<figure>

<picture>
    <source srcset="{% asset metrickit-diagram--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset metrickit-diagram--light.png @path %}" alt="MetricKit Diagram" loading="lazy" />
</picture>

<figcaption>Diagram from WWDC 2019 Session 417: <a href="https://developer.apple.com/videos/play/wwdc2019/417/">"Improving Battery Life and Performance"</a></figcaption>

</figure>
{:/}

Apple automatically collects metrics from apps installed on the App Store.
You can view them in Xcode 11
by opening the Organizer (<kbd>⌥</kbd><kbd>⌘</kbd><kbd>⇧</kbd><kbd>O</kbd>)
and selecting the new Metrics tab.

MetricKit complement Xcode Organizer Metrics by providing a programmatic way to
receive daily information about how your app is performing in the field.
With this information,
you can collect, aggregate, and analyze on your own in greater detail
than you can through Xcode.

## Understanding App Metrics

Metrics can help uncover issues you might not have seen while testing locally,
and allow you to track changes across different versions of your app.
For this initial release,
Apple has focused on the two metrics that matter most to users:
<dfn>battery usage</dfn> and <dfn>performance</dfn>.

### Battery Usage

<picture id="battery-usage">
    <source srcset="{% asset metrickit-battery-usage--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset metrickit-battery-usage--light.png @path %}" alt="MetricKit Diagram" loading="lazy"/>
</picture>

Battery life depends on a lot of different factors.
Physical aspects like the age of the device and
the number of charge cycles are determinative,
but the way your phone is used matters, too.
Things like CPU usage,
the brightness of the display and the colors on the screen,
and how often radios are used to fetch data or get your current location ---
all of these can have a big impact.
But the main thing to keep in mind is that
users care a lot about battery life.

Aside from how good the camera is,
the amount of time between charges
is _the_ deciding factor when someone buys a new phone these days.
So when their new, expensive phone _doesn't_ make it through the day,
they're going to be pretty unhappy.

Until recently,
Apple's taken most of the heat on battery issues.
But since iOS 12 and its new
[Battery Usage screen](https://support.apple.com/en-us/HT201264) in Settings,
users now have a way to tell when their favorite app is to blame.
Fortunately,
with iOS 13 you now have everything you need to make sure
your app doesn't run afoul of reasonable energy usage.

### Performance

Performance is another key factor in the overall user experience.
Normally, we might look to stats like
processor clock speed or [frame rate](/uitableviewheaderfooterview/)
as a measure of performance.
But instead,
Apple's focusing on less abstract and more actionable metrics:

Hang Rate
: How often is the main / UI thread blocked,
such that the app is unresponsive to user input?

Launch Time
: How long does an app take to become usable after the user taps its icon?

Peak Memory & Memory at Suspension
: How much memory does the app use at its peak
and just before entering the background?

Disk Writes
: How often does the app write to disk,
which --- if you didn't already know --- is a
[comparatively slow operation](https://people.eecs.berkeley.edu/~rcs/research/interactive_latency.html)
_(even with the flash storage on an iPhone!)_

## Using MetricKit

From the perspective of an API consumer,
it's hard to imagine how MetricKit could be easier to incorporate.
All you need is for some part of your app to serve as
a metric subscriber
(an obvious choice is your `AppDelegate`),
and for it to be added to the shared `MXMetricManager`:

```swift
import UIKit
import MetricKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MXMetricManager.shared.add(self)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        MXMetricManager.shared.remove(self)
    }
}

extension AppDelegate: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        <# ... #>
    }
}
```

iOS automatically collects samples while your app is being used,
and once per day (every 24 hours),
it'll send an aggregated report with those metrics.

To verify that your `MXMetricManagerSubscriber`
is having its delegate method called as expected,
select Simulate MetricKit Payloads from the Debug menu
while Xcode is running your app.

{% warning %}

The Simulate MetricKit Payloads menu item
requires the app to be running on an actual device
and is disabled for Simulator builds.

{% endwarning %}

### Annotating Critical Code Sections with Signposts

In addition to the baseline statistics collected for you,
you can use the
[`mxSignpost`](https://developer.apple.com/documentation/metrickit/3214364-mxsignpost) function
to collect metrics around the most important parts of your code.
This [signpost](https://developer.apple.com/documentation/os/3019241-os_signpost)-backed API
captures CPU time, memory, and writes to disk.

For example,
if part of your app did post-processing on audio streams,
you might annotate those regions with metric signposts
to determine the energy and performance impact of that work:

```swift
let audioLogHandle = MXMetricManager.makeLogHandle(category: "Audio")

func processAudioStream() {
    mxSignpost(.begin, log: audioLogHandle, name: "ProcessAudioStream")
    <#...#>
    mxSignpost(.end, log: audioLogHandle, name: "ProcessAudioStream")
}
```

## Creating a Self-Hosted Web Service for Collecting App Metrics

Now that you have this information,
what do you do with it?
How do we fill that `<#...#>` placeholder in our implementation of `didReceive(_:)`?

You _could_ pass that along to some paid analytics or crash reporting service,
_but where's the fun in that_?
Let's build our own web service to collect these for further analysis:

### Storing and Querying Metrics with PostgreSQL

The `MXMetricPayload` objects received by metrics manager subscribers
have a convenient
[`jsonRepresentation()`](https://developer.apple.com/documentation/metrickit/mxmetricpayload/3131907-jsonrepresentation) method
that generates something like this:

{% capture metrics_json %}

```json
{
  "locationActivityMetrics": {
    "cumulativeBestAccuracyForNavigationTime": "20 sec",
    "cumulativeBestAccuracyTime": "30 sec",
    "cumulativeHundredMetersAccuracyTime": "30 sec",
    "cumulativeNearestTenMetersAccuracyTime": "30 sec",
    "cumulativeKilometerAccuracyTime": "20 sec",
    "cumulativeThreeKilometersAccuracyTime": "20 sec"
  },
  "cellularConditionMetrics": {
    "cellConditionTime": {
      "histogramNumBuckets": 3,
      "histogramValue": {
        "0": {
          "bucketCount": 20,
          "bucketStart": "1 bars",
          "bucketEnd": "1 bars"
        },
        "1": {
          "bucketCount": 30,
          "bucketStart": "2 bars",
          "bucketEnd": "2 bars"
        },
        "2": {
          "bucketCount": 50,
          "bucketStart": "3 bars",
          "bucketEnd": "3 bars"
        }
      }
    }
  },
  "metaData": {
    "appBuildVersion": "0",
    "osVersion": "iPhone OS 13.1.3 (17A878)",
    "regionFormat": "US",
    "deviceType": "iPhone9,2"
  },
  "gpuMetrics": {
    "cumulativeGPUTime": "20 sec"
  },
  "memoryMetrics": {
    "peakMemoryUsage": "200,000 kB",
    "averageSuspendedMemory": {
      "averageValue": "100,000 kB",
      "standardDeviation": 0,
      "sampleCount": 500
    }
  },
  "signpostMetrics": [
    {
      "signpostIntervalData": {
        "histogrammedSignpostDurations": {
          "histogramNumBuckets": 3,
          "histogramValue": {
            "0": {
              "bucketCount": 50,
              "bucketStart": "0 ms",
              "bucketEnd": "100 ms"
            },
            "1": {
              "bucketCount": 60,
              "bucketStart": "100 ms",
              "bucketEnd": "400 ms"
            },
            "2": {
              "bucketCount": 30,
              "bucketStart": "400 ms",
              "bucketEnd": "700 ms"
            }
          }
        },
        "signpostCumulativeCPUTime": "30,000 ms",
        "signpostAverageMemory": "100,000 kB",
        "signpostCumulativeLogicalWrites": "600 kB"
      },
      "signpostCategory": "TestSignpostCategory1",
      "signpostName": "TestSignpostName1",
      "totalSignpostCount": 30
    },
    {
      "signpostIntervalData": {
        "histogrammedSignpostDurations": {
          "histogramNumBuckets": 3,
          "histogramValue": {
            "0": {
              "bucketCount": 60,
              "bucketStart": "0 ms",
              "bucketEnd": "200 ms"
            },
            "1": {
              "bucketCount": 70,
              "bucketStart": "201 ms",
              "bucketEnd": "300 ms"
            },
            "2": {
              "bucketCount": 80,
              "bucketStart": "301 ms",
              "bucketEnd": "500 ms"
            }
          }
        },
        "signpostCumulativeCPUTime": "50,000 ms",
        "signpostAverageMemory": "60,000 kB",
        "signpostCumulativeLogicalWrites": "700 kB"
      },
      "signpostCategory": "TestSignpostCategory2",
      "signpostName": "TestSignpostName2",
      "totalSignpostCount": 40
    }
  ],
  "displayMetrics": {
    "averagePixelLuminance": {
      "averageValue": "50 apl",
      "standardDeviation": 0,
      "sampleCount": 500
    }
  },
  "cpuMetrics": {
    "cumulativeCPUTime": "100 sec"
  },
  "networkTransferMetrics": {
    "cumulativeCellularDownload": "80,000 kB",
    "cumulativeWifiDownload": "60,000 kB",
    "cumulativeCellularUpload": "70,000 kB",
    "cumulativeWifiUpload": "50,000 kB"
  },
  "diskIOMetrics": {
    "cumulativeLogicalWrites": "1,300 kB"
  },
  "applicationLaunchMetrics": {
    "histogrammedTimeToFirstDrawKey": {
      "histogramNumBuckets": 3,
      "histogramValue": {
        "0": {
          "bucketCount": 50,
          "bucketStart": "1,000 ms",
          "bucketEnd": "1,010 ms"
        },
        "1": {
          "bucketCount": 60,
          "bucketStart": "2,000 ms",
          "bucketEnd": "2,010 ms"
        },
        "2": {
          "bucketCount": 30,
          "bucketStart": "3,000 ms",
          "bucketEnd": "3,010 ms"
        }
      }
    },
    "histogrammedResumeTime": {
      "histogramNumBuckets": 3,
      "histogramValue": {
        "0": {
          "bucketCount": 60,
          "bucketStart": "200 ms",
          "bucketEnd": "210 ms"
        },
        "1": {
          "bucketCount": 70,
          "bucketStart": "300 ms",
          "bucketEnd": "310 ms"
        },
        "2": {
          "bucketCount": 80,
          "bucketStart": "500 ms",
          "bucketEnd": "510 ms"
        }
      }
    }
  },
  "applicationTimeMetrics": {
    "cumulativeForegroundTime": "700 sec",
    "cumulativeBackgroundTime": "40 sec",
    "cumulativeBackgroundAudioTime": "30 sec",
    "cumulativeBackgroundLocationTime": "30 sec"
  },
  "timeStampEnd": "2019-10-22 06:59:00 +0000",
  "applicationResponsivenessMetrics": {
    "histogrammedAppHangTime": {
      "histogramNumBuckets": 3,
      "histogramValue": {
        "0": {
          "bucketCount": 50,
          "bucketStart": "0 ms",
          "bucketEnd": "100 ms"
        },
        "1": {
          "bucketCount": 60,
          "bucketStart": "100 ms",
          "bucketEnd": "400 ms"
        },
        "2": {
          "bucketCount": 30,
          "bucketStart": "400 ms",
          "bucketEnd": "700 ms"
        }
      }
    }
  },
  "appVersion": "1.0.0",
  "timeStampBegin": "2019-10-21 07:00:00 +0000"
}
```

{% endcapture %}

{::nomarkdown}

<details>
<summary>Expand for JSON Representation:</summary>
{{ metrics_json | markdownify }}
</details>
{:/}

As you can see,
there's a lot baked into this representation.
Defining a schema for all of this information would be a lot of work,
and there's no guarantee that this won't change in the future.
So instead,
let's embrace the NoSQL paradigm
_(albeit responsibly, using [Postgres](https://postgresapp.com))_
by storing payloads in a [`JSONB` column](https://www.postgresql.org/docs/current/datatype-json.html):

```sql
CREATE TABLE IF NOT EXISTS metrics (
    id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    payload JSONB NOT NULL
);
```

_So easy!_

We can extract individual fields from payloads
using [JSON operators](https://www.postgresql.org/docs/current/functions-json.html)
like so:

```sql
SELECT (payload -> 'applicationTimeMetrics'
                ->> 'cumulativeForegroundTime')::INTERVAL
FROM metrics;
--      interval
-- ═══════════════════
--  @ 11 mins 40 secs
-- (1 row)
```

{% info %}

The JSON representation of metrics stores measurements for time and memory
as strings with units (such as `"100 ms"` and `500 kB`).
In Postgres, you can cast time measurements directly to the
[`INTERVAL` type](https://www.postgresql.org/docs/current/datatype-datetime.html#DATATYPE-INTERVAL-INPUT),
however you'll need to create a function to convert to byte counts:

```sql
CREATE OR REPLACE FUNCTION parse_byte_count (TEXT)
RETURNS BIGINT
AS $$
  SELECT
    replace(split_part($1, ' ', 1),',','')::BIGINT *
    CASE split_part($1, ' ', 2)
        WHEN 'kB' THEN 1000
        WHEN 'MB' THEN 1000 * 1000
        WHEN 'GB' THEN 1000 * 1000 * 1000
    END
$$ LANGUAGE 'sql' STRICT IMMUTABLE;
```

{% endinfo %}

#### Advanced: Creating Views

JSON operators in PostgreSQL can be cumbersome to work with ---
especially for more complex queries.
One way to help with that is to create a view
_([materialized](https://www.postgresql.org/docs/current/rules-materializedviews.html) or otherwise)_
to project the most important information to you
in the most convenient representation:

```sql
CREATE VIEW key_performance_indicators AS
SELECT
    id,
    (payload -> 'appVersion') AS app_version,
    (payload -> 'metaData' ->> 'deviceType') AS device_type,
    (payload -> 'metaData' ->> 'regionFormat') AS region,
    (payload -> 'applicationTimeMetrics'
             ->> 'cumulativeForegroundTime'
    )::INTERVAL AS cumulative_foreground_time,
    parse_byte_count(
      payload -> 'memoryMetrics'
             ->> 'peakMemoryUsage'
    ) AS peak_memory_usage_bytes
FROM metrics;
```

With views,
you can perform
[aggregate queries](https://www.postgresql.org/docs/current/functions-aggregate.html)
over all of your metrics JSON payloads
with the convenience of a schema-backed relational database:

```sql
SELECT avg(cumulative_foreground_time)
FROM key_performance_indicators;
--         avg
-- ══════════════════
--  @ 9 mins 41 secs

SELECT app_version, percentile_disc(0.5)
         WITHIN GROUP (ORDER BY peak_memory_usage_bytes)
         AS median
FROM key_performance_indicators
GROUP BY app_version;
--  app_version │  median
-- ═════════════╪═══════════
--  "1.0.1"     │ 192500000
--  "1.0.0"     │ 204800000
```

{% error %}

PostgreSQL doesn't handle camelcase well for table or column names,
so keep that in mind when using functions like
[`jsonb_to_record`](https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-JSON-PROCESSING-TABLE).

{% enderror %}

### Creating a Web Service

In this example,
most of the heavy lifting is delegated to Postgres,
making the server-side implementation rather boring.
For completeness,
here are some reference implementations in
Ruby (Sinatra) and JavaScript (Express):

```ruby
require 'sinatra/base'
require 'pg'
require 'sequel'

class App < Sinatra::Base
  configure do
    DB = Sequel.connect(ENV['DATABASE_URL'])
  end

  post '/collect' do
    DB[:metrics].insert(payload: request.body.read)
    status 204
  end
end
```

```javascript
import express from 'express';
import { Pool } from 'pg';

const db = new Pool(
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production'
);

const app = express();
app.post('/collect', (request, response) => {
  db.query('INSERT INTO metrics (payload) VALUES ($1)', [request.body], (error, results) => {
    if (error) {
      throw error;
    }

    response.status(204);
  })
});

app.listen(process.env.PORT || 5000)
```

### Sending Metrics as JSON

Now that we have everything set up,
the final step is to implement
the required `MXMetricManagerSubscriber` delegate method `didReceive(_:)`
to pass that information along to our web service:

```swift
extension AppDelegate: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            let url = URL(string: "https://example.com/collect")!

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = payload.jsonRepresentation()

            let task = URLSession.shared.dataTask(with: request)
            task.priority = URLSessionTask.lowPriority
            task.resume()
        }
    }
}
```

<hr/>

When you create something and put it out into the world,
you lose your direct connection to it.
That's as true for apps as it is for college radio shows.
Short of user research studies or
[invasive ad-tech](https://techcrunch.com/2019/02/06/iphone-session-replay-screenshots/),
the truth is that
[we rarely have any clue about how people are using our software](https://xkcd.com/1172/).

<!-- Second xkcd reference in as many weeks. Go figure. -->

Metrics offer a convenient way to at least make sure that
things aren't too slow or too draining.
And though they provide but a glimpse in the aggregate
of how our apps are being enjoyed,
it's just enough to help us honor both our creation and our audience
with a great user experience.

{% asset "articles/metrickit.css" %}
