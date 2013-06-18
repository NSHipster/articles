# NSHipster

[NSHipster](http://nshipster.com) is a journal of the overlooked bits in Objective-C and Cocoa. Updated weekly.

**What This Repository Is For**

- Accessing source material
- Correcting typos and providing minor copy editing
- Correcting technical mistakes in content
- Translating existing articles into different languages
- Requesting new articles (please search for any existing requests before opening a new one)
- Running locally to experiment with [Jekyll](https://github.com/mojombo/jekyll), et al.

**What This Repository Is _Not_ For**

- Submitting new articles (please do not go through the trouble of writing an article without being solicited)
- Using content against the terms of its [Creative Commons BY-NC License](http://creativecommons.org/licenses/by-nc/3.0/)
- Creating a mirror of NSHipster on a separate domain

## Running Locally

NSHipster runs on [Jekyll](https://github.com/mojombo/jekyll), a blog-aware, static site generator in Ruby. You can run the site locally with:

``` shell
$ cd path/to/nshipster.com
$ gem install bundler
$ bundle install
$ bundle exec jekyll server
```

### Compass

In addition to the site content, CSS is generated using [Compass](http://compass-style.org),  an open-source CSS Authoring Framework. To run Compass locally, do:

``` shell
$ cd path/to/nshipster.com
$ gem install compass
$ compass watch .
```

## Credits

Site content, design, and concept were created by [Mattt Thompson](http://mattt.me/) ([@mattt](https://twitter.com/mattt))

Illustrations were created by [Conor Heelan](http://www.conorheelan.com)

## Contact

Follow NSHipster on Twitter ([@NSHipster](https://twitter.com/NSHipster))

## License

NSHipster is released under a [Creative Commons BY-NC License](http://creativecommons.org/licenses/by-nc/3.0/). See `LICENSE.md` for more information.
