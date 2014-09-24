# NSHipster

[NSHipster](http://nshipster.com) is a journal of the overlooked bits in Swift, Objective-C and Cocoa. Updated weekly.

**What This Repository Is For**

- Accessing source material
- Correcting typos and providing minor copy editing
- Correcting technical mistakes in content
- Translating existing articles into different languages
- Requesting new articles (please search for any existing requests before opening a new one)
- Running locally to experiment with [Jekyll](https://github.com/jekyll/jekyll), et al.

**What This Repository Is _Not_ For**

- Submitting new articles (please do not go through the trouble of writing an article without being solicited)
- Using content against the terms of its [Creative Commons BY-NC License](http://creativecommons.org/licenses/by-nc/3.0/)
- Creating a mirror of NSHipster on a separate domain

## Running Locally

NSHipster runs on [Jekyll](https://github.com/jekyll/jekyll), a blog-aware, static site generator in Ruby.

You can run the site locally with:

``` shell
$ cd path/to/nshipster.com
$ gem install bundler
$ bundle install
$ git submodule init
$ git submodule update
$ bundle exec jekyll serve --config _config.en.yml
```

### Compass

In addition to the site content, CSS is generated using [Sass](http://sass-lang.com).

To run Sass locally, do:

``` shell
$ cd path/to/nshipster.com/assets
$ sass watch .
```

## Contact

Follow NSHipster on Twitter ([@NSHipster](https://twitter.com/NSHipster))

## License

All code is published under the [MIT License](http://opensource.org/licenses/MIT).

All content is released under the [Creative Commons BY-NC License](http://creativecommons.org/licenses/by-nc/4.0/).

NSHipster® and the NSHipster Logo are registered trademarks of NSHipster, LLC.

