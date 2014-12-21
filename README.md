# NSHipster

[NSHipster](http://nshipster.com) is a journal of the overlooked bits in Swift, Objective-C and Cocoa. Updated weekly.

This repository hosts the source code that generates and deploys [NSHipster.com](http://nshipster.com) and [NSHipster.cn](http://nshipster.cn). For the articles themselves, see [this repository](https://github.com/nshipster/articles).

* * *

## Requirements

- Ruby 2.0.0+
- [Bundler](http://bundler.io)
- [Foreman](https://github.com/ddollar/foreman)
- [s3cmd](http://s3tools.org/s3cmd)

## Running Locally

NSHipster uses [Jekyll](https://github.com/jekyll/jekyll), a blog-aware, static site generator in Ruby. In addition to the site content, CSS is generated using [Sass](http://sass-lang.com) with [Bourbon](http://bourbon.io), [Neat](http://neat.bourbon.io), and [Bitters](http://bitters.bourbon.io).

You can run the site locally with the following commands:

```shell
$ git clone git@github.com:NSHipster/nshipster.com.git
$ cd nshipster.com
$ bundle install
$ git submodule update --init
$ foreman start
```

## Deploying

Websites are hosted statically with Amazon AWS S3 & CloudFront, using [Rake](https://rubygems.org/gems/rake) and [s3cmd](http://s3tools.org/s3cmd) for deployment (a root s3cmd configuration (`./.s3cfg`) file with valid IAM credentials is required).

```shell
rake publish        # Defaults to en / nshipster.com
rake publish[zh]    # zh-Hans / nshipster.cn
```

## Contact

Follow NSHipster on Twitter ([@NSHipster](https://twitter.com/NSHipster))

## License

All code is published under the [MIT License](http://opensource.org/licenses/MIT).

All content is released under the [Creative Commons BY-NC License](http://creativecommons.org/licenses/by-nc/4.0/).

NSHipster® and the NSHipster Logo are registered trademarks of NSHipster, LLC.
