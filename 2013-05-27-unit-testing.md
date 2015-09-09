---
title: Unit Testing
author: Mattt Thompson
category: Objective-C
excerpt: "Unit Testing is an emotional topic for developers. It inspires a sense of superiority to its most zealous adherents, and evokes a feeling of inadequacy to non-practitioners. Cargo Cults like TDD stake their reputation on unit testing to the point of co-opting and conflating utility with morality."
status:
    swift: n/a
---

Unit Testing is an emotional topic for developers. It inspires a sense of superiority to its most zealous adherents, and evokes a feeling of inadequacy to non-practitioners. [Cargo Cults like TDD](http://ntoll.org/article/tdd-cargo-cult) stake their reputation on unit testing to the point of co-opting and conflating utility with morality.

It's as close to a religious matter as programmers get, aside from the tabs-versus-spaces debate.

Objective-C developers have, for the most part, remained relatively apathetic to Unit Testing (_"There's that SenTest thing, but who uses that, really?"_). Between static typing, typically manageable project sizes, and a compiler advanced enough to [rewrite code for you](http://clang.llvm.org/doxygen/Rewriter_8h_source.html), unit testing isn't as much of a necessity as it is for more dynamic languages like Ruby (at least in practice).

But that's not to say that Objective-C developers wouldn't benefit from unit testing. In fact, as Objective-C continues to become more collaborative, with growing participation in the open source community, automated testing will become a necessity.

This week NSHipster will explore the world of unit testing frameworks, and how to set up an automated build system with Travis CI.

---

[Unit Testing](https://en.wikipedia.org/wiki/Unit_testing) is a tool, just like any other tool. Its purpose is to make us better at our jobs, which is to produce robust, maintainable software.

It's a simple enough premise: write code to construct environments that exercise the particular behavior of a given method, function, class, or feature. Variables are isolated in a scientific manner, so as to test assumptions with logical atomicity.

## OCUnit

[OCUnit](http://www.sente.ch/software/ocunit/), a.k.a. SenTestingKit, was integrated into Xcode 2.1 circa WWDC 2005, [as a result of its use in the development of Core Data 1.0](http://www.friday.com/bbum/2005/09/24/unit-testing). Developed by [Sen:te](http://www.sente.ch), OCUnit is actually one of the first unit testing libraries written for any language.

Unit Tests were added into a separate testing target in the Xcode Project. Each test file defines an `SenTestCase` subclass, which implements a series of methods beginning with the word `test`. C `assert`-style macros are used to fail tests if the specified condition is not met. Each test is run in sequence, independently of one another, with the results logged afterwards:

~~~{objective-c}
#import <SenTestingKit/SenTestingKit.h>
#import "Person.h"

@interface TestPerson : SenTestCase
@end

@implementation TestPerson
- (void)testFullName {
   Person *person = [[Person alloc] init];
   person.firstName = @"Pablo";
   person.lastName = @"Picasso";
   STAssertEqualObjects([person fullName], @"Pablo Picasso", nil);
}
~~~

The SenTestingKit assertions are about what you'd expect, offering bread-and-butter equality, existence, and truth checks:

- `STAssertNil()`
- `STAssertNotNil()`
- `STAssertTrue()`
- `STAssertFalse()`
- `STAssertEqualObjects()`
- `STAssertEquals()`
- `STAssertEqualsWithAccuracy()`
- `STAssertThrows()`
- `STAssertThrowsSpecific()`
- `STAssertThrowsSpecificNamed()`
- `STAssertNoThrow()`
- `STAssertNoThrowSpecific()`
- `STAssertNoThrowSpecificNamed()`
- `STAssertTrueNoThrow()`
- `STAssertFalseNoThrow()`
- `STFail()`

And yet, as useful as tests are, they necessarily introduce friction into a development cycle. When project pressures begin to weigh, tests are the first thing to be thrown overboard. At some point, the tests stop passing ("we can worry about that later—now we have to ship!")

The only chance testing has to remain relevant in high-pressure situations is to reduce that friction in development. Essentially, tests need to become both _easier to write_ and _easier to run_.

## Open Source Libraries

There are a myriad of open source libraries that attempt to make testing more palatable by way of syntactic sugar and features like [method stubs](https://en.wikipedia.org/wiki/Method_stub), [mock objects](https://en.wikipedia.org/wiki/Mock_object), and [promises](http://en.wikipedia.org/wiki/Futures_and_promises).

Here's a list of some of the most useful open source libraries for unit testing:

<table>
  <thead>
    <th colspan="3">Mock Objects</th>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/erikdoe/ocmock">OCMock</a></td>
      <td><a href="https://github.com/erikdoe">Erik Doernenburg</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=erikdoe&repo=ocmock&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/jonreid/OCMockito">OCMockito</a></td>
      <td><a href="https://github.com/jonreid">Jon Reid</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=jonreid&repo=OCMockito&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>

  <thead>
    <th colspan="3">Matchers</th>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/specta/expecta">Expecta</a></td>
      <td><a href="https://github.com/petejkim">Peter Jihoon Kim</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=specta&repo=expecta&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/hamcrest/OCHamcrest">OCHamcrest</a></td>
      <td><a href="https://github.com/jonreid">Jon Reid</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=hamcrest&repo=OCHamcrest&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>

  <thead>
    <th colspan="3">BDD / TDD</th>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/specta/specta">Specta</a></td>
      <td><a href="https://github.com/petejkim">Peter Jihoon Kim</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=specta&repo=specta&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/kiwi-bdd/Kiwi">Kiwi</a></td>
      <td><a href="https://github.com/allending">Allen Ding</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=kiwi-bdd&repo=Kiwi&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
    <tr>
      <td><a href="https://github.com/pivotal/cedar">Cedar</a></td>
      <td><a href="https://github.com/pivotal">Pivotal Labs</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=pivotal&repo=cedar&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>

  <thead>
    <th colspan="3">Frameworks</th>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/gh-unit/gh-unit/">GHUnit</a></td>
      <td><a href="https://github.com/gabriel">Gabriel Handford</a></td>
      <td><iframe src="http://ghbtns.com/github-btn.html?user=gh-unit&repo=gh-unit&type=watch&count=true" allowtransparency="true" frameborder="0" scrolling="0" width="106" height="20"></iframe></td>
    </tr>
  </tbody>
</table>

## Automated Testing

Making tests easier to write is one thing, but getting them to run without affecting productivity is quite another.


### Jenkins

For a long time, installing [Jenkins](http://jenkins-ci.org) on a dedicated Mac Mini was the state-of-the-art for automated build servers.

Aside from the fact that it's _kinda the worst thing ever to set-up_, [you can do a lot of cool things](https://speakerdeck.com/subdigital/ios-build-automation-with-jenkins) like notifying build status over IM or IRC, automatically distributing builds to [TestFlight](https://testflightapp.com/dashboard/) or [HockeyApp](http://hockeyapp.net) with [Shenzhen](https://github.com/nomad/shenzhen), and generating documentation with [AppleDoc](http://gentlebytes.com/appledoc/).

### Travis

Until recently, automated unit testing for Objective-C was the privilege of projects that could dedicate the time and money to setup a CI server. [Travis CI](https://travis-ci.org) made CI available to the masses.

CI for Objective-C is more difficult than for other languages, because it needs to be done on a Mac. For economic reasons, there just isn't a market for cloud-based OS X environments like there is for Linux. Fortunately, [SauceLabs](https://saucelabs.com) has built such a virtualized Mac cloud, and is graciously donating some of it to run tests for open source Objective-C projects on Travis-CI.

For an example of automated Objective-C unit testing in the wild, check out [how AFNetworking does it](https://github.com/afnetworking/afnetworking#unit-tests).

The `Tests` subdirectory contains separate projects for iOS and OS X targets, as well as a Podfile, which specifies all of the testing library dependencies. AFNetworking executes a [Rake](http://rake.rubyforge.org) task, which shells out to [`xctool`](https://github.com/facebook/xctool).

All of the configuration for setup is defined in `.travis.yml`:

#### .travis.yml

~~~
language: objective-c
before_install:
  - brew update
  - brew install xctool --HEAD
  - cd Tests && pod install && cd $TRAVIS_BUILD_DIR
  - mkdir -p "Tests/AFNetworking Tests.xcodeproj/xcshareddata/xcschemes" && cp Tests/Schemes/*.xcscheme "Tests/AFNetworking Tests.xcodeproj/xcshareddata/xcschemes/"
script: rake test
~~~

Full documentation for the Travis configuration file [can be found on Travis-CI.org](http://about.travis-ci.org/docs/user/build-configuration/).

---

Once again, the direction of Objective-C has been directly influenced by the Ruby community. Those guys and gals are _serious_ about testing. It's not like we should complain, though: between [CocoaPods](http://cocoapods.org), [RubyMotion](http://www.rubymotion.com), and [Nomad](http://nomad-cli.com), Ruby has made Objective-C development better by several orders of magnitude.

The bottom line is that testing has come to Objective-C. It's not always necessary, and it's certainly not a silver bullet for writing great software, but it's proven itself invaluable (especially for open source development). So give it a try now, before _not_ testing becomes _seriously uncool_.
