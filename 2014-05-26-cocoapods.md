---
title: CocoaPods
author: Mattt Thompson
category: Open Source
tags: cfhipsterref
excerpt: "When well thought-out and implemented, infrastructure is a multiplying force that drives growth and development. In the case of Objective-C, CocoaPods has provided a much-needed tool for channeling and organizing open source participation."
status:
    swift: n/a
---

<img src="http://nshipster.s3.amazonaws.com/cfhipsterref-illustration-egg-merchant.png" width="139" height="300" alt="Egg Merchant, illustrated by Conor Heelan" style="float: right; margin-left: 2em; margin-bottom: 2em"/>

Civilization is built on infrastructure: roads, bridges, canals, sewers, pipes, wires, fiber. When well thought-out and implemented, infrastructure is a multiplying force that drives growth and development. But when such formative structures are absent or ad hoc, it feels as if progress is made _in spite of_ the situation.

It all has to do with solving the problem of scale.

No matter what the medium, whether it's accommodating millions of families into a region, or integrating a large influx of developers into a language ecosystem, the challenges are the same.

In the case of Objective-C, [CocoaPods](http://cocoapods.org) provided a much-needed tool for channeling and organizing open source participation, and served as a rallying point for the community at a time of rapid growth and evolution.

This week on NSHipster, we'll celebrate the launch of CocoaPods 0.33, [an important milestone for the project](http://blog.cocoapods.org/CocoaPods-0.33/), by taking a look back at where we came from, discussing where we are now, and thinking about what's to come.

> The following historical look at the origins of CocoaPods is, admittedly, a bit wordy for this publication. So if you're looking for technical details, feel free to [skip directly to that](#using-cocoapods).

---

## A Look Back

For the first twenty or so years of its existence, Objective-C was not a widely known language. NeXT and later OS X were marginal platforms, with a comparatively small user base and developer community. Like any community, there were local user groups and mailing lists and websites, but open source collaboration was not a widespread phenomenon. Granted, Open Source was only just starting to pick up steam at that time, but there was no contemporary Objective-C equivalent to, for example, CPAN, the Comprehensive Perl Archive Network. Everyone took SDKs from Redwood City and Cupertino as far as they could, (maybe sprinkling in some code salvaged from a forum thread), but ultimately rolling their own solutions to pretty much everything else.

### Objective-C and the iPhone

This went on until the summer of 2008, when iPhone OS was first opened up to third party developers. Almost overnight, Objective-C went from being an obscure C++/C# also-ran to the one of the most sought-after programmer qualifications. Millions of developers flocked from all walks of code, bringing an influx of new ideas and influences to the language.

Around this same time, GitHub had just launched, and was starting to change the way we thought about open source by enabling a new distributed, collaborative workflow.

In those early years of iPhone OS, we started to see the first massively adopted open source projects, like ASIHTTPRequest and Facebook's Three20. These first libraries and frameworks were built to fill in the gaps of app development on iPhone OS 2.0 and 3.0, and although largely made obsolete by subsequent OS releases or other projects, they demonstrated a significant break from the tradition of "every developer for themselves".

Of this new wave of developers, those coming from a Ruby background had a significant influence on the code and culture of Objective-C. Ruby, a spiritual successor to Perl, had its own package manager similar to CPAN: [RubyGems](https://rubygems.org).

> Why so much influence from Ruby? Here's my pet theory: Ruby started gaining popular traction because of [Rails](http://rubyonrails.org), which hit 1.0 at the end of 2005. Given that the average duration of a startup gig seems to be about 1½ – 2½ years, the timing works out such that those first and second waves of bored Rails developers itching to jump ship would find a place in the emerging app space.

As open source contributions in Objective-C began to get some traction, the pain points of code distribution were starting to become pretty obvious:

Lacking frameworks, code for iOS could be packaged as a static library, but getting that set up and keeping code and static distributions in sync was an arduous process.

Another approach was to use Git submodules, and include the source directly in the project. But getting everything working, with linked frameworks and build flags configured, was not great either—especially at a time when the body of code was split between [ARC and non-ARC](http://en.wikipedia.org/wiki/Automatic_Reference_Counting).

### Enter CocoaPods

CocoaPods was created by [Eloy Durán](https://twitter.com/alloy) on August 12, 2011.

Taking inspiration from Bundler and RubyGems, CocoaPods was designed to resolve a list of dependencies, download the required sources, and configure the existing project in such a way to be able to use them. Considering the challenges of [working with a sparsely documented Xcode project format](https://github.com/CocoaPods/xcodeproj) and build system, it's kind of a miracle that this exists at all.

Another notable decision made early on was to use a [central Git repository](https://github.com/cocoapods/specs) as the database for all of the available libraries. Although there were certain logistical considerations with this approach, bootstrapping on GitHub provided a stable infrastructure, that allowed the team to iterate on building out the tool chain.

Since its initial proof-of-concept, the project has grown to include [14 core team members](http://cocoapods.org/about) along with over 100 additional contributors. At the time of writing, there are nearly [5000 open source projects](https://github.com/CocoaPods/Specs/tree/master/Specs) available for anyone to add to their project.

A significant portion of these prolific contributions from the open source community for Objective-C has been directly enabled and encouraged by increased ownership around tooling. Everyone involved should be commended for their hard work and dedication.

> To break the 4th wall for a moment: Seriously, _thank you_, ladies and gentlemen of CocoaPods. You've done an amazing job. Keep up the good work!

---

## Using CocoaPods

CocoaPods is easy to get started with both as a consumer and a library author. It should only take a few minutes to get set up.

> For the most up-to-date information on how to use CocoaPods, check out the [official guides](http://guides.cocoapods.org).

### Installing CocoaPods

CocoaPods is installed through RubyGems, the Ruby package manager, which comes with a standard OS X install.

To install, open Terminal.app and enter the following command:

~~~{bash}
$ sudo gem install cocoapods
~~~

Now you should have the `pod` command available in the terminal.

> If you're using a Ruby versioning manager, like [rbenv](https://github.com/sstephenson/rbenv), you may need to run a command to re-link a binary shim to the library (e.g. `$ rbenv rehash`).

### Managing Dependencies

A dependency manager resolves a list of software requirements into a list of specific tags to download and integrate into a project.

Declaring requirements in such a way allows for project setup to be automated, which is [general best practice for software development practice](http://12factor.net/dependencies), no matter what the language. **Even if you don't include third-party libraries, CocoaPods is still an invaluable tool for managing code dependencies across projects.**

#### Podfile

A `Podfile` is where the dependencies of a project are listed. It is equivalent to `Gemfile` for Ruby projects using [Bundler](http://bundler.io), or `package.json` for JavaScript projects using [npm](https://www.npmjs.org).

To create a Podfile, `cd` into the directory of your `.xcodeproj` file and enter the command:

~~~{bash}
$ pod init
~~~

#### Podfile

~~~{ruby}
platform :ios, '7.0'

target "AppName" do

end
~~~

Dependencies can have varying levels of specificity. For most libraries, pegging to a minor or patch version is the safest and easiest way to include them in your project.

~~~{ruby}
pod 'X', '~> 1.1'
~~~

> CocoaPods follows [Semantic Versioning](http://semver.org) conventions.

To include a library not included in the public specs database, a Git, Mercurial, or SVN repository can be used instead, for which a `commit`, `branch`, or `tag` can be specified.

~~~{ruby}
pod 'Y', :git => 'https://github.com/NSHipster/Y.git', :commit => 'b4dc0ffee'
~~~

Once all of the dependencies have been specified, they can be installed with:

~~~{bash}
$ pod install
~~~

When this is run, CocoaPods will recursively analyze the dependencies of each project, resolving them into a dependency graph, and serializing into a `Podfile.lock` file.

> For example, if two libraries require [AFNetworking](http://afnetworking.com), CocoaPods will determine a version that satisfies both requirements, and links them with a common installation of it.

CocoaPods will create a new Xcode project that creates static library targets for each dependency, and then links them all together into a `libPods.a` target. This static library becomes a dependency for your original application target. An `xcworkspace` file is created, and should be used from that point onward. This allows the original `xcodeproj` file to remain unchanged.

Subsequent invocations of `pod install` will add new pods or remove old pods according to the locked dependency graph. To update the individual dependencies of a project to the latest version, do the following:

~~~{bash}
$ pod update
~~~

### Trying Out a CocoaPod

One great, but lesser-known, feature of CocoaPods is the `try` command, which allows you to test-drive a library before you add it to your project.

Invoking `$ pod try` with the name of a project in the public specs database opens up any example projects for the library:

~~~{bash}
$ pod try Ono
~~~

![Ono.xcworkspace](http://nshipster.s3.amazonaws.com/cocoapods-try-ono.png)

## Creating a CocoaPod

Being the de facto standard for Objective-C software distribution, CocoaPods is pretty much a requirement for open source projects with the intention of being used by others

Yes, it raises the barrier to entry for sharing your work, but the effort is minimal, and more than justifies itself. Taking a couple minutes to create a `.podspec` file saves every user at least that much time attempting to integrate it into their own projects.

Remember: **_raising_ the bar for contribution within a software ecosystem _lowers_ the bar for participation**.

### Specification

A `.podspec` file is the atomic unit of a CocoaPods dependency. It specifies the name, version, license, and source files for a library, along with other metadata.

> The [official guide to the Podfile](http://guides.cocoapods.org/using/the-podfile) has some great information and examples.

#### NSHipsterKit.podspec

~~~{ruby}
Pod::Spec.new do |s|
  s.name     = 'NSHipsterKit'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = "A pretty obscure library.
                You've probably never heard of it."
  s.homepage = 'http://nshipster.com'
  s.authors  = { 'Mattt Thompson' =>
                 'mattt@nshipster.com' }
  s.social_media_url = "https://twitter.com/mattt"
  s.source   = { :git => 'https://github.com/nshipster/NSHipsterKit.git', :tag => '1.0.0' }
  s.source_files = 'NSHipsterKit'
end
~~~

Once published to the public specs database, anyone could add it to their project, specifying their Podfile thusly:

#### Podfile

~~~{ruby}
pod 'NSHipsterKit', '~> 1.0'
~~~

A `.podspec` file can be useful for organizing internal or private dependencies as well:

~~~{ruby}
pod 'Z', :path => 'path/to/directory/with/podspec'
~~~

### Publishing a CocoaPod

New in CocoaPods 0.33 is [the new Trunk service](http://guides.cocoapods.org/making/getting-setup-with-trunk).

Although it worked brilliantly at first, the process of using Pull Requests on GitHub for managing new pods became something of a chore, both for library authors and spec organizers like [Keith Smiley](https://twitter.com/SmileyKeith). Sometimes podspecs would be submitted without passing `$ pod lint`, causing the specs repo build to break. Other times, rogue commits from people other than the original library author would break things unexpectedly.

The CocoaPods Trunk service solves a lot of this, making the process nicer for everyone involved. Being a centralized service, it also has the added benefit of being able to get analytics for library usage, and other metrics.

To get started, you must first register your machine with the Trunk service. This is easy enough, just specify your email address (the one you use for committing library code) along with your name.

~~~{bash}
$ pod trunk register mattt@nshipster.com "Mattt Thompson"
~~~

Now, all it takes to publish your code to CocoaPods is a single command. The same command works for creating a new library or adding a new version to an existing one:

~~~{bash}
$ pod trunk push NAME.podspec
~~~

> Authors of existing CocoaPods can claim their libraries [with a few simple steps](http://blog.cocoapods.org/Claim-Your-Pods/).

***

## A Look Forward

CocoaPods exemplifies the compounding effect of infrastructure on a community. In a few short years, the Objective-C community has turned into something that we can feel proud to be part of.

CocoaPods is just one example of the great work being done on Objective-C infrastructure. Other community tools, like [Travis CI](http://blog.travis-ci.com/introducing-mac-ios-rubymotion-testing/), [CocoaDocs](http://cocoadocs.org), and [Nomad](http://nomad-cli.com) have dramatically improved the everyday experience iOS and OS X development for the community.

It can be tempting to be snarky, contrarian, or grumpy about the direction of a community. No matter what, though, let us all try our best to enter into dialogue in good faith, offering constructive criticism where we can. We should help each other to be good [stewards](http://nshipster.com/stewardship/) of what we share, and strive towards [empathy](http://nshipster.com/empathy/) in all our interactions.

CocoaPods is a good thing for Objective-C. And it's only getting better.
