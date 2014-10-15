---
layout: post
title: "XCTestCase /<br/>XCTestExpectation /<br/> measureBlock()"
author: Mattt Thompson
category: Xcode
excerpt: "This week, we'll take a look at `XCTest`, the testing framework built into Xcode, as well as the exciting new additions in Xcode 6: `XCTestExpectation` and performance tests."
---

Although iOS 8 and Swift has garnered the lion's share of attention of the WWDC 2014 announcements, the additions and improvements to testing in Xcode 6 may end up making some of the most profound impact in the long-term.

This week, we'll take a look at `XCTest`, the testing framework built into Xcode, as well as the exciting new additions in Xcode 6: `XCTestExpectation` and performance tests.

* * *

Most Xcode project templates now support testing out-of-the-box. For example, when a new iOS app is created in Xcode with `⇧⌘N`, the resulting project file will be configured with two top-level groups (in addition to the "Products" group): "AppName" & "AppNameTests". The project's auto-generated scheme enables the shortcut `⌘R` to build and run the executable target, and `⌘U` to build and run the test target.

Within the test target is a single file, named "AppNameTests", which contains an example `XCTestCase` class, complete with boilerplate `setUp` & `tearDown` methods, as well as an example functional and performance test cases.

## XCTestCase

Xcode unit tests are contained within an `XCTestCase` subclass. By convention, each `XCTestCase` subclass encapsulates a particular set of concerns, such as a feature, use case, or flow of an application.

> Dividing up tests logically across a manageable number of test cases makes a huge difference as codebases grow and evolve.

### setUp & tearDown

`setUp` is called before each test in an `XCTestCase` is run, and when that test finishes running, `tearDown` is called:

~~~{swift}
class Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
~~~

These methods are useful for creating objects common to all of the tests for a test case:

~~~{swift}
var calendar: NSCalendar?
var locale: NSLocale?

override func setUp() {
    super.setUp()

    self.calendar = NSCalendar(identifier: NSGregorianCalendar)
    self.locale = NSLocale(localeIdentifier: "en_US")
}
~~~

> Since `XCTestCase` is not intended to be initialized directly from within a test case definition, shared properties initialized in `setUp` are declared as optional `var`s.

### Functional Testing

Each method in a test case with a name that begins with "test" is recognized as a test, and will evaluate any assertions within that function to determine whether it passed or failed.

For example, the function `testOnePlusOneEqualsTwo` will pass if `1 + 1` is equal to `2`:

~~~{swift}
func testOnePlusOneEqualsTwo() {
    XCTAssertEqual(1 + 1, 2, "one plus one should equal two")
}
~~~

### All of the XCTest Assertions You _Really_ Need To Know

`XCTest` comes with [a number of built-in assertions](https://developer.apple.com/library/prerelease/ios/documentation/DeveloperTools/Conceptual/testing_with_xcode/testing_3_writing_test_classes/testing_3_writing_test_classes.html#//apple_ref/doc/uid/TP40014132-CH4-SW34), but one could narrow them down to just a few essentials:

#### Fundamental Test

To be entirely reductionist, all of the `XCTest` assertions come down to a single, base assertion:

~~~{swift}
XCTAssert(expression, format...)
~~~

If the expression evaluates to `true`, the test passes. Otherwise, the test fails, printing the `format`ted message.

Although a developer could get away with only using `XCTAssert`, the following helper assertions provide some useful semantics to help clarify what exactly is being tested. When possible, use the most specific assertion available, falling back to `XCTAssert` only in cases where it better expresses the intent.

#### Boolean Tests

For `Bool` values, or simple boolean expressions, use `XCTAssertTrue` & `XCTAssertFalse`:

~~~{swift}
XCTAssertTrue(expression, format...)
XCTAssertFalse(expression, format...)
~~~

> `XCTAssert` is equivalent to `XCTAssertTrue`.

#### Equality Tests

When testing whether two values are equal, use `XCTAssert[Not]Equal`:

~~~{swift}
XCTAssertEqual(expression1, expression2, format...)
XCTAssertNotEqual(expression1, expression2, format...)
~~~

> `XCTAssert[Not]EqualObjects` are not necessary in Swift, since there is no distinction between scalars and objects.

When specifically testing whether two `Double`, `Float`, or other floating-point values are equal, use `XCTAssert[Not]EqualWithAccuracy`, to account for any issues with [floating point accuracy](http://en.wikipedia.org/wiki/Floating_point#Representable_numbers.2C_conversion_and_rounding):

~~~{swift}
XCTAssertEqualWithAccuracy(expression1, expression2, accuracy, format...)
XCTAssertNotEqualWithAccuracy(expression1, expression2, accuracy, format...)
~~~

> In addition to the aforementioned equality assertions, there are `XCTAssertGreaterThan[OrEqual]` & `XCTAssertLessThan[OrEqual]`, which supplement `==` with `>`, `>=`, `<`, & `<=` equivalents for comparable values.

#### Nil Tests

Use `XCTAssert[Not]Nil` to assert the existence (or non-existence) of a given value:

~~~{swift}
XCTAssertNil(expression, format...)
XCTAssertNotNil(expression, format...)
~~~

#### Unconditional Failure

Finally, the `XCTFail` assertion will always fail:

~~~{swift}
XCTFail(format...)
~~~

`XCTFail` is most commonly used to denote a placeholder for a test that should be made to pass. It is also useful for handling error cases already accounted by other flow control structures, such as the `else` clause of an `if` statement testing for success.

### Performance Testing

New in Xcode 6 is the ability to [benchmark the performance of code](http://nshipster.com/benchmarking/):

~~~{swift}
func testDateFormatterPerformance() {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .LongStyle
    dateFormatter.timeStyle = .ShortStyle

    let date = NSDate()

    self.measureBlock() {
        let string = dateFormatter.stringFromDate(date)
    }
}
~~~

~~~
Test Case '-[_Tests testDateFormatterPerformance]' started.
<unknown>:0: Test Case '-[_Tests testDateFormatterPerformance]' measured [Time, seconds] average: 0.000, relative standard deviation: 242.006%, values: [0.000441, 0.000014, 0.000011, 0.000010, 0.000010, 0.000010, 0.000010, 0.000010, 0.000010, 0.000010], performanceMetricID:com.apple.XCTPerformanceMetric_WallClockTime, baselineName: "", baselineAverage: , maxPercentRegression: 10.000%, maxPercentRelativeStandardDeviation: 10.000%, maxRegression: 0.100, maxStandardDeviation: 0.100
Test Case '-[_Tests testDateFormatterPerformance]' passed (0.274 seconds).
~~~

Performance tests help establish a baseline of performance for hot code paths. Sprinkle them into your test cases to ensure that significant algorithms and procedures remain performant as time goes on.

## XCTestExpectation

Perhaps the most exciting feature added in Xcode 6 is built-in support for asynchronous testing, with the `XCTestExpectation` class. Now, tests can wait for a specified length of time for certain conditions to be satisfied, without resorting to complicated GCD incantations.

To make a test asynchronous, first create an expectation with `expectationWithDescription`:

~~~{swift}
let expectation = expectationWithDescription("...")
~~~

Then, at the bottom of the method, add the `waitForExpectationsWithTimeout` method, specifying a timeout, and handler to execute if the conditions of a test are not satisfied within that timeframe:

~~~{swift}
waitForExpectationsWithTimeout(10, handler: { error in
    // ...
})
~~~

Now, the only remaining step is to `fulfill` that `expecation` in the relevant callback of the asynchronous method being tested:

~~~{swift}
expectation.fulfill()
~~~

> If the test has more than one expectation, it will not pass unless each expectation executes `fulfill()` within the timeout specified in `waitForExpectationsWithTimeout()`.

Here's an example of how the response of an asynchronous networking request can be tested with the new `XCTestExpectation` APIs:

~~~{swift}
func testAsynchronousURLConnection() {
    let URL = "http://nshipster.com/"
    let expectation = expectationWithDescription("GET \(URL)")

    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithURL(NSURL(string: URL), completionHandler: {(data, response, error) in
        expectation.fulfill()

        XCTAssertNotNil(data, "data should not be nil")
        XCTAssertNil(error, "error should be nil")

        if let HTTPResponse = response as NSHTTPURLResponse! {
            XCTAssertEqual(HTTPResponse.URL.absoluteString, URL, "HTTP response URL should be equal to original URL")
            XCTAssertEqual(HTTPResponse.statusCode, 200, "HTTP response status code should be 200")
            XCTAssertEqual(HTTPResponse.MIMEType as String, "text/html", "HTTP response content type should be text/html")
        } else {
            XCTFail("Response was not NSHTTPURLResponse")
        }
    })

    task.resume()

    waitForExpectationsWithTimeout(task.originalRequest.timeoutInterval, handler: { error in
        task.cancel()
    })
}
~~~

## Mocking in Swift

With first-class support for asynchronous testing, Xcode 6 seems to have fulfilled all of the needs of a modern test-driven developer. Well, perhaps save for one: [mocking](http://en.wikipedia.org/wiki/Mock_object).

Mocking is a useful technique for isolating and controlling behavior in systems that, for reasons of complexity, non-determinism, or performance constraints, do not usually lend themselves to testing. Examples include simulating network requests, intensive database queries, or inducing states that might emerge under a particular race condition.

There are a couple of [open source libraries](http://nshipster.com/unit-testing/#open-source-libraries) for creating mock objects and [stubbing](http://en.wikipedia.org/wiki/Test_stub) method calls, but these libraries largely rely on Objective-C runtime manipulation, something that is not currently possible with Swift.

However, this may not actually be necessary in Swift, due to its less-constrained syntax.

In Swift, classes can be declared within the definition of a function, allowing for mock objects to be extremely self-contained. Just declare a mock inner-class, `override` and necessary methods:

~~~{swift}
func testFetchRequestWithMockedManagedObjectContext() {
    class MockNSManagedObjectContext: NSManagedObjectContext {
        override func executeFetchRequest(request: NSFetchRequest!, error: AutoreleasingUnsafePointer<NSError?>) -> [AnyObject]! {
            return [["name": "Johnny Appleseed", "email": "johnny@apple.com"]]
        }
    }

    let mockContext = MockNSManagedObjectContext()
    let fetchRequest = NSFetchRequest(entityName: "User")
    fetchRequest.predicate = NSPredicate(format: "email ENDSWITH[cd] %@", "@apple.com")
    fetchRequest.resultType = .DictionaryResultType

    var error: NSError?
    let results = mockContext.executeFetchRequest(fetchRequest, error: &error)

    XCTAssertNil(error, "error should be nil")
    XCTAssertEqual(results.count, 1, "fetch request should only return 1 result")

    let result = results[0] as [String: String]
    XCTAssertEqual(result["name"] as String, "Johnny Appleseed", "name should be Johnny Appleseed")
    XCTAssertEqual(result["email"] as String, "johnny@apple.com", "email should be johnny@apple.com")
}
~~~

* * *

With Xcode 6, we've finally arrived: **the built-in testing tools are now good enough to use on their own**. That is to say, there are no particularly compelling reasons to use any additional abstractions in order to provide acceptable test coverage for the vast majority apps and libraries. Except in extreme cases that require extensive stubbing, mocking, or other exotic test constructs, XCTest assertions, expectations, and performance measurements should be sufficient.

But no matter how good the testing tools have become, they're only good as _how you actually use them_.

If you're new to testing on iOS or OS X, start by adding a few assertions to that automatically-generated test case file and hitting `⌘U`. You might be surprised at how easy and—dare I say—enjoyable you'll find the whole experience.
