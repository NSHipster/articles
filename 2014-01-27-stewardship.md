---
title: Stewardship
author: Mattt Thompson
category: ""
tags: nshipster
excerpt: "Stewardship is an old word. It evokes the ethic of public service and duty. To be a steward is to embody the responsibilities that come with ownership. It is an act that justifies authority through continued accountability; both the greatest challenge and reward of creating and maintaining a project."
status:
    swift: n/a
---

Open Source communities function within what economists describe as a [Gift Economy](http://en.wikipedia.org/wiki/Gift_economy). Rather than paying one another for goods or services through barter or currency, everyone shares freely with one another, and gains [social currency](http://en.wikipedia.org/wiki/Whuffie) based on their generosity. It's similar to how friends tend to take turns inviting one another over for dinner or a party.

With the negligible cost of distributing software over the Internet, developers are able to participate with millions of others around the world. And as a result, we have been able to collaboratively build amazing software.

In terms of open source participation, releasing code is only one aspect—and arguably not even the most important one. Developing an open source project requires equal parts engineering, product design, communication, and community management. But the true deciding factor for whether an open source project succeeds is stewardship.

Stewardship is an old word. It evokes the ethic of public service and duty. To be a steward is to embody the responsibilities that come with ownership. It is an act that justifies authority through continued accountability; both the greatest challenge and reward of creating and maintaining a project.

## Creating

It's not enough to dump a pile of source code somewhere and declare it "open source". To do so misses the point entirely. The first step of stewardship is to clearly explain the goal and value proposition of the project, and establish clear expectations going forward.

### README

A README is the most important part of any open source project. It describes why someone would want to use the code, and how they may start to do so.
All good READMEs have the following:

- A short, one or two sentence introduction that clearly explains what the project is in simple, understandable language.
- A section describing the basic usage of the primary tasks of the project. For example, a UI component would provide sample code of how to create, configure, and add itself to a view.
- A list of requirements and instructions on how to install the code into one's own project.
- Links to documentation and resources for additional information.
- Contact information for the author or current maintainer.
- A quick statement about the licensing terms of the project.

### LICENSE

All open source code should be released under an appropriate license. Unless you have a really good reason not to, choose from any of the licenses approved by the [Open Source Initiative](http://opensource.org), like [MIT](http://opensource.org/licenses/MIT), [Apache 2.0](http://opensource.org/licenses/Apache-2.0), or [GPL](http://opensource.org/licenses/GPL-3.0).

If you're unsure which license to choose, there are [several](http://choosealicense.com) [resources](http://www.tldrlegal.com) online that you can use to learn more. Most open source Objective-C projects are released under an MIT license, which is known to be compatible with the terms of distribution for the App Store.

### Screenshot

For projects with any kind of user interface, such as a custom control, view, or animation, posting a screenshot should be considered a requirement.

Buying anything "sight unseen" is a bad idea, and the same goes for consumers of open source. Although there are no monetary costs involved, evaluating a project requires a nontrivial investment in time and energy. A screenshot helps potential consumers decide if your code is worth checking out.

### Demo

Actions speak louder than words. And no matter how comprehensive a README file is, any open source project can be improved with a working example.

There's just something about seeing the code in a real context that allows developers to grok what's going on. It's also nice to have a starting point for tinkering around.

At the very least, an example can be used to bootstrap the process of fixing bugs or developing new features, both for you and for anyone who wants to contribute. It's also a great place to incorporate any testing infrastructure for the project.

### Distribution

One of the great developments in the Objective-C open source community—and in many ways, what has allowed it to flourish as it has recently—is [CocoaPods](http://cocoapods.org).

CocoaPods is the de facto dependency manager for integrating third party code in iOS and OS X projects. At this point, it's pretty much expected that any library worth using is distributed with a `.podspec`:

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

Once the `.podspec` has been submitted to the CocoaPods specs repository, a consumer would be able to add it to their own project with a Podfile:

#### Podfile

~~~{ruby}
platform :ios, '7.0'
pod 'NSHipsterKit', '~> 1.0'
~~~

## Maintaining

Once the initial thrill of releasing a library has passed, the real work begins. The thing to remember is that a flurry of stars, watchers, and tweets may be exciting, but they don't amount to anything of real importance. Only when users start to come with their questions, issues, and pull requests does code become software.

### Versioning

Versioning is a contract that library authors make to consumers in how software will be changed over time.

The prevailing convention is [Semantic Versioning](http://semver.org), in which a release has a major, minor, and patch version, with each level signifying particular usage implications.

- A patch, or bugfix, release changes only implementation, keeping the public API and thus all documentation intact. Consumers should be able to update between patch versions without any change to their own code.
- A minor, or point, release changes the public API in non-breaking ways, such as adding a new feature. Again, developers should expect to have consumer code between minor versions work pretty much as expected.
- A major release is anything that changes the public API in a backwards-incompatible way. Updating between major versions effectively means migrating consumer code to a new library.

> A comprehensive set of guidelines for semantic versioning can be found at [http://semver.org](http://semver.org)

By following a few basic rules for versioning, developers are able to set clear expectations for how changes will affect shipping code.

Deviating from these conventions as an author is disrespectful to anyone using the software, so take this responsibility seriously.

### Answering Questions

One of our greatest flaws as humans is our relative inability to comprehend not knowing  or understanding something that we ourselves do. This makes it extremely difficult to diagnose (and at times empathize with) misunderstandings that someone else might be having.

There's also a slight sadistic tendency for developers to lord knowledge over anyone who doesn't know as much as they do. We had to figure it out for ourselves (uphill both ways, in the snow) so why shouldn't they have to as well?

We must learn how to do better than this. RTFM is a lame answer to any question. It's also a dead-end to a potential learning experience for yourself.

Rather than disdaining questions, take them as an opportunity to understand what you can do better. Each question is a data point for what could be clarified or improved within your own software and documentation. And one thing to consider: for each person who asks a question, there are dozens of others who don't and get frustrated and give up. Answering one question on a mailing list or developer forum helps many more people than just the asker.

## Transitioning

The fate of any successful enterprise is to outgrow its original creators. While this may be a troubling or unwelcome notion, it is nevertheless something that any responsible creator should keep in mind.

If anything, the reminder that all of this is fleeting gives reason to find enjoyment in even the minutia of a preoccupation.

### Recruiting & Delegating

As a project grows, natural leaders will emerge. If you see someone consistently answering questions in issues or sending pull requests with bug fixes, ask if they would like some more responsibility.

Co-maintainers don't come pre-baked; individuals must grow into that role. And that role is something that must be defined over time by everyone involved. Avoid drama and hard feelings by communicating honestly and often with collaborators.

### Sunsetting

All software has a lifecycle. At some point, all things must come to an end. Libraries outgrow their usefulness, or are supplanted by another piece of software, or simply fall out of favor.
In any case, there will come a time when the lights need to be turned off, and it is the responsibility of the maintainer to wrap things up.

- Announce the ending of the project, offering suggestions for how to migrate to another solution.
- Keep the project around, but make a commit that removes source files from the master branch. (Git will keep everything safe in history)
- Thank everyone involved for their help and contributions.

The alternative is to become a liability, an attractive nuisance... a mockery of what once was a respectable code base.

* * *

Creating is one of the most fulfilling experiences in life, and it's something that's only improved by sharing with others. As software developers, we have a unique opportunity to be unbounded by physical limitations to help one another.

On the occasion that you do have the opportunity to participate in the community, be sure to make the most of it—you'll be happy you did.
