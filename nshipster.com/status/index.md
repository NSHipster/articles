---
title: Status
---

{% assign sorted = site.posts | sort: 'title' %}

# Status

At every WWDC, the introduction of new APIs deprecates the old and familiar. New frameworks mean better approaches to the same problems we've been tackling, but old habits die hard. The Swift language, in particular, is still evolving, rendering incorrect information and code samples that might have been published only a few months ago. We do our best to keep articles up to date, and note below the Swift version as well as the last review date for articles that have been checked for correctness since publication.

"**t.b.c.**" indicates that an article has not yet been translated to Swift, "*n/a*" notes that a Swift translation would not be useful or appropriate.



| Article | Swift Version | Last Review |
|---------|:-------------:|:-----------:|{% for post in sorted %}
| [{{ post.title | replace:'_','\\_' }}]({{ post.url }}) | {% if post.status.swift == "n/a" %}*n/a*{% else %}**{{ post.status.swift }}**{% endif %} | {{ post.status.reviewed }} |{% endfor %}


