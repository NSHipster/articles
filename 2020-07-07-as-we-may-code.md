---
title: As We May Code
author: Mattt
category: Miscellaneous
excerpt: >-
  What if, instead of lowering source code down for the purpose of execution, 
  we raised it for the purpose of understanding?
---

Chris Lattner often describes [LLVM] as a process of <dfn>lowering</dfn>.

{% asset swift-compilation-diagram.png alt="Swift Compiler Architecture Diagram"%}

You start at the highest level of abstraction,
source code written in a programming language like Swift or Objective-C.
That code is parsed into an abstract syntax tree,
(<abbr title="Abstract Syntax Tree">AST</abbr>),
which is progressively transformed into
lower-level, intermediate representations
until it finally becomes executable binary.

What if,
instead of lowering source code down for the purpose of execution,
<!-- *bong rip* -->
we _raised_ source code for the purpose of understanding?

<aside class="parenthetical">

It's a weird premise, I know. Bear with me.

</aside>

You could say that we already do this to some degree with
[syntax highlighting](/swiftsyntax/#highlighting-swift-code) \\
(<span class="nohighlight">`func f()`</span> → <code class="highlight"><span class="kd">func</span> <span class="nf">f</span><span class="p">()</span></code>),
[structured editing](/swiftsyntax/), and
[documentation generation](/swift-documentation/).
But how far could we take it?

* * *

In this article,
I'd like to share an idea that I've been kicking around for a while.
It's something that's come into greater focus with
my recent work on [`swift-doc`][swift-doc],
but first started to form during tenure in Apple Developer Publications,
back in 2015.

The idea is this: \\
**What if we took the lessons of the [semantic web]
and applied them to source code?**

Specifically:

- **Representation**:
  Software components should be represented by
  a common, language-agnostic data format.
- **Addressability**:
  Packages, modules, and their constituent APIs
  should each have a unique URL identifier.
- **Decentralization**:
  Information should be distributed across a federated network of data sources,
  which can cross-reference one another by URL.

I grew up with the Internet,
and got to see it, first-hand,
go from an obscure technology to _the_ dominant cultural force.
So much of what I see in software development today
reminds me of what I remember about the web from 20 years ago.
And if you'll forgive the extended wind-up,
I think there's a lot we can learn by looking at that evolution.

<aside class="parenthetical">

As I wrote in my article about [cross-pollination](/cross-pollination),
great ideas often arise from unlikely connections.

</aside>

{% warning %}

If you're already familiar with semantic web
or aren't all that interested in a history lesson
feel free to [skip ahead to the technical details](#skip).

{% endwarning %}

* * *

## <small>Web 1.0</small> The Web of Documents

Tim Berners-Lee launched the World Wide Web
from a NeXT workstation 27 years ago.
His vision for a
globally-distributed, decentralized network of inter-connected documents
gave rise to the Internet as we know it today.
But it was also part of an intellectual tradition dating back to the 1940s,
which includes
Vannevar Bush's _[Memex]_,
Ted Nelson's _[Xanadu]_, and
Doug Engelbart's _[Mother of All Demos]_.

{% info %}

Dr. Bush coined the term <dfn>memex</dfn> in an essay titled
["As We May Think"][As We May Think],
published in the July 1945 issue of _The Atlantic_.

{% endinfo %}

In those early days,
the knowledge being shared was primarily academic.
As the userbase grew over time,
so too did the breadth and diversity of the information available.
And, for a time,
that's what the Internet was:
[fan sites](http://www.automaticbeyondbelief.org) for Sunbeam toasters,
[recipes](http://www.varasanos.com/PizzaRecipe.htm) for Neapolitan-style pizza, and
[the official website](https://www.spacejam.com) for the 1996 film _Space Jam_.

But the web of documents had limits.

If you wanted to
shop for appliances,
see the menu of a pizza shop, or
get local showtimes for a movie,
you _might_ be able to do that on the early Internet.
But you really had to work at it.

Back then,
you'd start by going to a directory like [Yahoo!] or [DMOZ],
navigate to the relevant topic,
and click around until you found a promising lead.
Most of the time, you wouldn't find what you were looking for;
instead, you'd disconnect your modem to free up your landline
and consult the [yellow pages].

{% info %}

As it were,
the difficulty of finding information on the web
gave us the term [<dfn>Sherlocked</dfn>][sherlocked].
Apple's v3 release of the eponymous system software
was widely seen to have killed Karelia Software's
[Watson](https://en.wikipedia.org/wiki/Karelia_Watson):
a similar (paid) application for Mac OS X
that offered a uniform interface to information like stocks, movies, and flights.

{% endinfo %}

This started to change in the early '00s.

## <small>Web 2.0</small> The Social Web

With [Perl CGI][CGI] and [PHP],
you could now easily generate web pages on-the-fly.
This enabled eCommerce and the first commercial uses of the Internet.

After the ensuing [dot-com bubble],
you had technologies like [Java applets] and [Flash]
bring a new level of interactivity to web sites.
Eventually, folks figured out how to use
[an obscure API from Internet Explorer 5][XMLHttpRequest]
to replicate this interactivity on normal webpages —
a technique dubbed [AJAX].
Interacting with a page and seeing results live, without reloading a page?
This was _huge_.
Without that,
social media might not have taken off as it did.

Anyway,
the server-side APIs powering those AJAX interactions on the client,
they were the secret sauce that let the Internet evolve into what it is today.

Remember <dfn>"[mashups]"</dfn>?

Thanks to all of these (often unsecured) AJAX endpoints,
developers could synthesize information across multiple sources
in ways that nobody had ever thought to do.
You could get someone's location from [Fire Eagle],
search for photos taken nearby on [Flickr],
and use [MOO] to print and deliver prints of them on-demand.

<aside class="parenthetical">

Mashups felt like punk rock.
I have a lot of fond memories from this time.

</aside>

By the end of the decade,
the rise of social networks and the early promise of mashups
started to coalesce into the modern Internet.

## <small>Web 3.0</small> The Web of Data

The term "Web 3.0" didn't catch on like its predecessor,
but there's a clear delineation between
the technologies and culture of the web between the early and late '00s.

It's hard to overstate how much the iPhone's launch in 2007
totally changed the trajectory of the Internet.
But many other events played an important role in
shaping the web as we know it today:

- Google acquiring the company behind [Freebase],
  giving it a knowledge graph to augment its website index.
- Facebook launching [Open Graph],
  which meant everything could now be "Liked"
  (and everyone could be targeted for advertisements).
- Yahoo releasing [SearchMonkey] and
  [<abbr title="Build your Own Search Service">BOSS</abbr>][BOSS],
  two ambitious (albeit flawed) attempts
  to carve out a niche from Google's monopoly on search.
- Wolfram launching [Wolfram|Alpha],
  which far exceeded what many of us thought was possible
  for a question answering system.

The Internet always had a lot of information on it;
the difference now is that
the information is accessible to machines as well as humans.

Today,
you can ask Google
[_"Who was the first person to land on the moon?"_][google query]
and get an info box saying, _"Commander Neil Armstrong"_.
You can post a link in Messages
and see it represented by
[a rich visual summary](/ios-13/#generate-rich-representations-of-urls)
instead of a plain text URL.
You can ask Siri,
_"What is the [airspeed velocity][@AirspeedSwift] of an unladen swallow?"_ and hear back
<del>_"I can't get the answer to that on HomePod"_</del>
<ins>_About 25 miles per hour_</ins>.

<aside class="parenthetical">
We're just kidding about that last one.
Siri has gotten a lot better in recent years.
</aside>

Think about what we take for granted about the Internet now,
and try to imagine doing that on the web when it looked
[like this](https://www.spacejam.com).
It's hard to think that any of this would be possible without the semantic web.

* * *

## <small>GitHub.com, Present Day</small> The Spider and The Octocat

READMEs on GitHub.com today remind me of
personal home pages on [Geocities] back in the Web 1.0 days.

{% info %}
Compare the "build passing" SVG badges found at the top of READMEs in 2020
to the 80×15px "XHTML 1.1 ✓" badges found at the bottom of websites in 2000.

{% asset as-we-may-code-badges.png width=800 %}

{% endinfo %}

Even with the [standard coat of paint](https://primer.style/css/),
you see an enormous degree of variance across projects and communities.
Some are sparse; others are replete with adornment.

And yet,
no matter what a project’s README looks like,
onboarding onto a new tool or library entails, well _reading_.

<aside class="parenthetical">

I mean, it’s right there in capital letters: "READ ME"

</aside>

GitHub offers some structured informational cues:
language breakdown, license, some metadata about commit activity.
You can search within the repo using text terms.
And thanks to [semantic] / [tree-sitter],
you can even click through to find declarations in some languages.

_But where's a list of methods?_
_Where are the platform requirements?_ \\
You have to read the README to find out!
(Better hope it's up-to-date 😭)

The modest capabilities of browsing and searching code today
more closely resemble [AltaVista] circa 2000 than Google circa 2020.
Theres so much more that we could be doing.

* * *

<a name="skip"></a>

## <small>RDF Vocabularies</small> The Owl and The Turtle

At the center of the semantic web is something called
<abbr title="Resource Description Framework">[RDF]</abbr>,
the Resource Description Framework.
It's a collection of standards for representing and exchanging data.
The atomic data entity in <abbr>RDF</abbr>
is called a <dfn>triple</dfn>, which comprises:

  - a subject _("the sky")_
  - a predicate _("has the color")_
  - an object _("blue"_)

You can organize triples according to a
<dfn>vocabulary</dfn>, or <dfn>ontology</dfn>,
which defines rules about how things are described.
RDF vocabularies are represented by the
Web Ontology Language
(<abbr title="Web Ontology Language">[OWL]</abbr>).

The ideas behind RDF are simple enough.
Often, the hardest part is navigating
its confusing, acronym-laden technology stack.
The important thing to keep in mind is that
information can be represented in several different ways
without changing the meaning of that information.

Here's a quick run-down:

[RDF/XML]
: An XML representation format for <abbr>RDF</abbr> graphs.

[JSON-LD]
: A JSON representation format for <abbr>RDF</abbr> graphs.

[N-Triples]
: A plain text representation format for <abbr>RDF</abbr> graphs
  where each line encodes a subject–predicate–object triple.

[Turtle]
: A human-friendly, plain text representation format for <abbr>RDF</abbr> graphs.
  A superset of N-Triples,
  and the syntax used in <abbr>SPARQL</abbr> queries.

[SPARQL]
: A query language for <abbr>RDF</abbr> graphs.

### Defining a Vocabulary

Let's start to define a vocabulary for the Swift programming language.
To start,
we'll define the concept of a
`Symbol` along with two subclasses, `Structure` and `Function`.
We'll also define a `name` property that holds a token (a string)
that applies to any `Symbol`.
Finally,
we'll define a `returns` property that applies to a `Function`
and holds a reference to another `Symbol`.

```turtle
@prefix : <http://www.swift.org/#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

:Symbol rdf:type owl:Class .

:name rdf:type owl:FunctionalProperty ;
      rdfs:domain :Symbol ;
      rdfs:range xsd:token .

:Structure rdfs:subClassOf :Symbol .
:Function rdfs:subClassOf :Symbol .

:returns rdf:type owl:FunctionalProperty ;
         rdfs:domain :Function ;
         rdfs:range :Symbol .
```

```xml
<?xml version="1.0" encoding="utf-8" ?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
         xmlns:owl="http://www.w3.org/2002/07/owl#">

  <owl:Class rdf:about="http://www.swift.org/#Symbol"></owl:Class>

  <owl:FunctionalProperty rdf:about="http://www.swift.org/#name">
    <rdfs:domain rdf:resource="http://www.swift.org/#Symbol"/>
    <rdfs:range rdf:resource="http://www.w3.org/2001/XMLSchema#token"/>
  </owl:FunctionalProperty>

  <rdf:Description rdf:about="http://www.swift.org/#Structure">
    <rdfs:subClassOf rdf:resource="http://www.swift.org/#Symbol"/>
  </rdf:Description>

  <rdf:Description rdf:about="http://www.swift.org/#Function">
    <rdfs:subClassOf rdf:resource="http://www.swift.org/#Symbol"/>
  </rdf:Description>

  <owl:FunctionalProperty rdf:about="http://www.swift.org/#returns">
    <rdfs:domain rdf:resource="http://www.swift.org/#Function"/>
    <rdfs:range rdf:resource="http://www.swift.org/#Symbol"/>
  </owl:FunctionalProperty>
</rdf:RDF>
```

### Parsing Code Declarations

Now consider the following Swift code:

```swift
struct Widget { <#...#> }

func foo() -> Widget {<#...#>}
func bar() -> Widget {<#...#>}
```

We can use [SwiftSyntax] to parse the code into an AST
and [SwiftSemantics] to convert those AST nodes
into a more convenient representation.

```swift
import SwiftSyntax
import SwiftSemantics

var collector = DeclarationCollector()
let tree = try SyntaxParser.parse(source: source)
collector.walk(tree)

collector.functions.first?.name // "foo()"
collector.functions.first?.returns // "Widget"
```

Combining this syntactic reading with information from compiler,
we can express facts about the code in the form of RDF triples.

```json-ld
{
    "@context": {
        "name": {
            "@id": "http://www.swift.org/#name",
            "@type": "http://www.w3.org/2001/XMLSchema#token"
        },
        "returns": "http://www.swift.org/#returns"
    },
    "symbols": [
        {
            "@id": "E83C6A28-1E68-406E-8162-D389A04DFB27",
            "@type": "http://www.swift.org/#Structure",
            "name": "Widget"
        },
        {
            "@id": "4EAE3E8C-FD96-4664-B7F7-D64D8B75ECEB",
            "@type": "http://www.swift.org/#Function",
            "name": "foo()"
        },
        {
            "@id": "2D1F49FE-86DE-4715-BD59-FA70392E41BE",
            "@type": "http://www.swift.org/#Function",
            "name": "bar()"
        }
    ]
}
```

```ntriples
_:E83C6A28-1E68-406E-8162-D389A04DFB27 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.swift.org/#Structure> .
_:E83C6A28-1E68-406E-8162-D389A04DFB27 <http://www.swift.org/#name> "Widget"^^<http://www.w3.org/2001/XMLSchema#token> .
_:4EAE3E8C-FD96-4664-B7F7-D64D8B75ECEB <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.swift.org/#Function> .
_:4EAE3E8C-FD96-4664-B7F7-D64D8B75ECEB <http://www.swift.org/#name> "foo()"^^<http://www.w3.org/2001/XMLSchema#token> .
_:4EAE3E8C-FD96-4664-B7F7-D64D8B75ECEB <http://www.swift.org/#returns> _:E83C6A28-1E68-406E-8162-D389A04DFB27 .
_:2D1F49FE-86DE-4715-BD59-FA70392E41BE <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.swift.org/#Function> .
_:2D1F49FE-86DE-4715-BD59-FA70392E41BE <http://www.swift.org/#name> "bar()"^^<http://www.w3.org/2001/XMLSchema#token> .
_:2D1F49FE-86DE-4715-BD59-FA70392E41BE <http://www.swift.org/#returns> _:E83C6A28-1E68-406E-8162-D389A04DFB27 .
```

```turtle
@prefix swift: <http://www.swift.org/#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

_:Widget rdf:type :Structure ;
         swift:name "Widget"^^xsd:token .

_:foo rdf:type :Function ;
      swift:name "foo()"^^xsd:token ;
      swift:returns _:Widget .

_:bar rdf:type :Function ;
      swift:name "bar()"^^xsd:token ;
      swift:returns _:Widget .
```

Encoding our knowledge into a standard format
lets anyone access that information — however they like.
And because these facts are encoded within an ontology,
they can be validated for coherence and consistency.
It's totally language agnostic.

### Querying the Results

With an RDF graph of facts,
we can query it using [SPARQL].
Or,
we could load the information into
a graph database like [Neo4j] or
a relational database like [PostgreSQL]
and perform the query in Cypher or SQL, respectively.

```sparql
PREFIX
    swift: <http://www.swift.org/#>
SELECT ?function ?name
WHERE {
    ?function a swift:Function ;
              swift:returns ?type ;
              swift:name ?name .
    ?type swift:name "Widget" .
}
ORDER BY ?function
```

```cypher
MATCH (function:Function)-[:RETURNS]->(symbol:Symbol {name: 'Widget'})
RETURN function
```

```sql
CREATE TABLE symbols (
    id UUID PRIMARY KEY,
    name TEXT,
);

CREATE TABLE functions (
    returns_id UUID REFERENCES symbols(id),
) INHERITS (symbols);

--

SELECT f.id, f.name
FROM functions f
    INNER JOIN symbols s USING (returns_id);
WHERE s.name = 'Widget'
ORDER BY name
```

Whichever route we take,
we get the same results:

| id                                   | name   |
|--------------------------------------|--------|
| 4EAE3E8C-FD96-4664-B7F7-D64D8B75ECEB | foo()  |
| 2D1F49FE-86DE-4715-BD59-FA70392E41BE | bar()  |

{% info %}

The semantic web suffers from an admittedly weak software ecosystem.
While there are dozens of excellent clients for SQL databases,
you'd be hard-pressed to find much for SPARQL.
So I was quite pleased to come across 
[this kernel](https://github.com/paulovn/sparql-kernel)
by Paulo Villegas
that adds SPARQL support to
[Jupyter notebooks](https://jupyter.org).

{% endinfo %}


### Answering Questions About Your Code

_"What can you do with a knowledge graph?"_
That's kind of like asking, _"What can you do with Swift?"_
The answer — _"Pretty much anything"_ — is as true as it is unhelpful.

Perhaps a better framing would be to consider the kinds of questions that
a knowledge graph of code symbols can help answer:

- Which methods in Foundation produce a `Date` value?
- Which public types in my project _don't_ conform to `Codable`?
- Which methods does `Array` inherit default implementations from `RandomAccessCollection`?
- Which APIs have documentation that includes example code?
- What are the most important APIs in `MapKit`?
- Are there any unused APIs in my project?
- What's the oldest version of iOS that my app could target
  based on my current API usage?
- What APIs were added to [Alamofire] between versions 4.0 and 4.2?
- What APIs in our app are affected by a CVE issued for a 3rd-party dependency?

The possibilities get even more interesting as you layer additional contexts
by linking Swift APIs to different domains and other programming languages:

- How is this Swift API exposed in Objective-C?
- Who are the developers maintaining the packages
  that are pulled in as external dependencies for this project?
- What's the closest functional equivalent to this Swift package
  that's written in Rust?

{% info %}

My pitch for a
[Swift Package Registry Service](https://forums.swift.org/t/swift-package-registry-service/37219/2)
proposes the use of [JSON-LD] and the
[Schema.org `SoftwareSourceCode`](https://schema.org/SoftwareSourceCode) vocabulary
as a standard representation for package metadata,
which could be easily combined with and cross-referenced against
semantic representations of code.

{% endinfo %}

## <small>Future Applications</small> The Promise of What Lies Ahead

> Any fact becomes important when it's connected to another.
>
> <cite>Umberto Eco, _Foucault's Pendulum_</cite>

Operating on code symbolically is more powerful
than treating it as text.
Once you've experienced proper refactoring tools,
you'll never want to go back to global find-and-replace.

The leap from symbolic to semantic understanding of code
promises to be just as powerful.
What follows are a few examples of potential applications of
the knowledge graph we've described.

### Flexible Search Queries

GitHub's [advanced search](https://github.com/search/advanced)
provides an interface to filter results on various
[facets](https://www.elastic.co/guide/en/app-search/current/facets-guide.html),
but they're limited to metadata about the projects.
You can search for Swift code written by
[`@kateinoigakukun`](https://github.com/kateinoigakukun) in 2020,
but you can't, for example,
filter for code compatible with Swift 5.1.
You can search code for the string "record",
but you can't disambiguate between type and function definitions
(`class Record` vs. `func record()`).

As we showed earlier,
the kinds of queries we can perform across a knowledge graph
are fundamentally different from what's possible with
a conventional faceted, full-text search index.

For example,
here's a SPARQL query to find the urls of repositories
created by `@kateinoigakukun` and updated this year
that contain Swift functions named `record`:

```sparql
PREFIX
    swift: <http://www.swift.org/#>
    skos: <http://www.w3.org/2004/02/skos/core/#>
    sdo: <http://schema.org/#>
SELECT ?url
WHERE {
    ?function a swift:Function ;
              swift:name "record" ;
              skos:member ?repository .
    ?repository a sdo:SoftwareSourceCode ;
                sdo:contributor ?contributor;
                sdo:url ?url ;
                sdo:dateModified ?date .
    ?contributor a sdo:Person ;
                 sdo:username "kateinoigakukun" .
    FILTER (?date >= "2020-01-01")
}
ORDER BY ?url
```

{% info %}

Looking for a more grounded example of semantic code search?
Check out [Hoogle](https://hoogle.haskell.org):
a Haskell API search engine
that lets you search for functions by approximate type signature.
For instance, you can search for
[`Ord a => [a] -> [a]`](https://hoogle.haskell.org/?hoogle=Ord%20a%20%3D%3E%20%5Ba%5D%20-%3E%20%5Ba%5D),
(roughly, `([T]) -> [T] where T: Comparable` in Swift)
to find various `sort` methods available in the ecosystem.

{% endinfo %}

### Linked Documentation

When faced with
[missing or incomplete documentation](https://nooverviewavailable.com),
developers are left to search Google for
blog posts, tutorials, conference videos, and sample code
to fill in the gaps.
Often, this means sifting through pages of irrelevant results —
to say nothing of outdated and incorrect information.

A knowledge graph can improve search for documentation
much the same as it can for code,
but we can go even further.
Similar to how academic papers contain citations,
example code can be annotated to include references to
the canonical APIs it interacts with.
Strong connections between references and its source material
make for easy retrieval later on.

Imagine if,
when you option-click on an API in Xcode
to get its documentation,
you also saw a list of sample code and WWDC session videos?
Or what if we could generate sample code automatically from test cases?
Wouldn't that be nice?

All of that information is out there,
just waiting for us to connect the dots.

### Automatic µDependencies

John D. Cook once
[observed](https://www.johndcook.com/blog/2011/02/03/lego-blocks-and-organ-transplants/),
code reuse is more like an organ transplant
than snapping LEGO blocks together.
Fred Brooks similarly analogized software developers to surgeons in
[_The Mythical Man-Month_](https://en.wikipedia.org/wiki/The_Mythical_Man-Month).

But that's not to say that things can't get better —
it'd be hard to argue that they haven't.

Web applications were once described in similar, organic terms,
but that came to an end with the advent of
[containerization](https://en.wikipedia.org/wiki/OS-level_virtualization).
Now you can orchestrate entire multi-cloud deployments automatically
via declarative configuration files.

Before <abbr title="Comprehensive Perl Archive Network">[CPAN]</abbr>,
the state of the art for dependency management
was copy-pasting chunks of code
[you found on a web page](https://en.wikipedia.org/wiki/Matt%27s_Script_Archive).
But today, package managers are essential infrastructure for projects.

* * *

What if,
instead of organizing code into self-contained, modular chunks ourselves,
we let software do it for us?
Call it
<abbr title="Functions as a Dependency">FaaD</abbr> (Functions as a Dependency).

Say you want an implementation of
[_k_-means clustering](https://en.wikipedia.org/wiki/K-means_clustering).
You might search around for "k-means" or "clustering" on GitHub
and find a package named "SwiftyClusterAlgorithms" (😒),
only to discover that it includes a bunch of functionality that you don't need —
and to add insult to injury,
some of those extra bits happen to generate compiler warnings.
Super annoying.

<aside class="parenthetical">

For the record,
[<abbr title="Density-Based Spatial Clustering of Applications with Noise">DBSCAN</abbr>](https://github.com/NSHipster/DBSCAN)
is way better than _k_-means for most distributions.

</aside>

Today, there's no automatic way to pick and choose what you need.
([Swift `import` syntax](/import/) (`import func kMeans`) is a lie)
But there's no inherent reason why the compiler couldn't do this for you.

Or to go even further:
If everything compiles down to [web assembly](https://swiftwasm.org),
there's no inherent requirement for that implementation of _k_-means —
it could be written in Rust or JavaScript,
and you'd be none the wiser.

At a certain point,
you start to question the inherent necessity of software packaging
as we know it today.
Take it far enough,
and you may wonder how much code we'll write ourselves in the future.

### Code Generation

A few months ago,
Microsoft hosted its [Build](https://mybuild.microsoft.com) conference.
And among the videos presented was an interview with
[Sam Altman](https://en.wikipedia.org/wiki/Sam_Altman),
CEO of [OpenAI](https://openai.com/).
A few minutes in,
the interview cut to a video of Sam using
a fine-tuned version of
[GPT-2](https://openai.com/blog/gpt-2-1-5b-release/)
to
[write Python code from docstrings](https://www.pscp.tv/Microsoft/1OyKAYWPRrWKb?t=27m1s).

```python
def is_palindrome(s):
    """Check whether a string is a palindrome"""
    return s == s[::-1] # ← Generated by AI model from docstring!
```

And that's using a model that treats code as text.
Imagine how far you could go with _a priori_ knowledge of programming languages!
Unlike English, the rules of code are, well, codified.
You can check to see if code compiles —
and if it does compile,
you can run it to see the results.

{% info %}

And that's GPT-2.
[GPT-3](https://www.gwern.net/GPT-3) is even more impressive.
For your consideration,
here's what the model generated
when prompted to write a parody of the
[Navy Seal copypasta meme](https://knowyourmeme.com/memes/navy-seal-copypasta)
relating to
[mathematical platonism](https://en.wikipedia.org/wiki/Philosophy_of_mathematics#Platonism):

> What in set theory did you just write about me,
> you ignorant little inductivist?
> I’ll have you know I am a professor at the University of Chicago
> and I have been involved in numerous secret raids on the office of Quine,
> and I have over 300 confirmed set theoreticians. [...]

{% endinfo %}

At this point,
you should feel either very worried or very excited. \\
If you don't, then you're not paying attention.

## <small>Taking Ideas Seriously</small> The Shoemaker's Children

> The use of <abbr>FORTRAN</abbr>,
> like the earlier symbolic programming,
> was very slow to be taken up by the professionals.
> And this is typical of almost all professional groups.
> Doctors clearly do not follow the advice they give to others,
> and they also have a high proportion of drug addicts.
> Lawyers often do not leave decent wills when they die.
> Almost all professionals are slow to use their own expertise for their own work.
> The situation is nicely summarized by the old saying,
> “The shoe maker’s children go without shoes”.
> Consider how in the future, when you are a great expert,
> you will avoid this typical error!
>
> <cite>Richard W. Hamming, [_"The Art of Doing Science and Engineering"_](https://press.stripe.com/#the-art-of-doing-science-and-engineering)</cite>

Today,
lawyers delegate many paralegal tasks like document discovery to computers
and
doctors routinely use machine learning models to help diagnose patients.

So why aren't we —
_ostensibly the people writing software_ —
doing more with AI in our day-to-day?
Why are things like
[TabNine](https://www.tabnine.com) and
[Kite](https://kite.com)
so often seen as curiosities instead of game-changers?

If you take seriously the idea that
<abbr title="artificial intelligence">AI</abbr>
will fundamentally change the nature of many occupations in the coming decade,
what reason do you have to believe that you'll be immune from that
because you work in software?
Looking at the code you've been paid to write over the past few years,
how much of that can you honestly say is truly novel?

We're really not as clever as we think we are.

* * *

## <small>Postscript</small> Reflection and Metaprogramming

Today marks 8 years since I started NSHipster.

You might've noticed that I don't write here as much as I once did.
And on the occasions that I do publish an article,
it's more likely to include obscure
[historical facts](/swift-log/) and
[cultural references](/timeinterval-date-dateinterval/)
than to the [obscure APIs](/cfbag/) promised by this blog's tagline.

A few weeks out now from [WWDC](/wwdc-2020),
I _should_ be writing about
[`DCAppAttestService`](https://developer.apple.com/documentation/devicecheck/dcappattestservice),
[`SKTestSession`](https://developer.apple.com/documentation/storekittest/sktestsession),
SwiftUI [`Namespace`](https://developer.apple.com/documentation/swiftui/namespace)
and
[`UTType`](https://developer.apple.com/documentation/uniformtypeidentifiers/uttype).
But here we are,
at the end of an article about the semantic web, of all things...

* * *

The truth is,
I've come around to thinking that
programming isn't the most important thing
for programmers to pay attention to right now.

* * *

Anyway,
I'd like to take this opportunity to extend my sincere gratitude
to everyone who reads the words I write.
Thank you.
It may be a while before I get back into a regular cadence,
so apologies in advance.

Until next time,
_May your code continue to compile and inspire._


[Stack Overflow]: https://stackoverflow.com
[As We May Think]: https://www.theatlantic.com/magazine/archive/1945/07/as-we-may-think/303881/
[swift-doc]: https://github.com/SwiftDocOrg/swift-doc/
[HeaderDoc]: https://en.wikipedia.org/wiki/HeaderDoc
[WWDC 2001 701]: https://www.youtube.com/watch?v=szgH8p2tkl0
[no overview available]: https://nooverviewavailable.com
[Memex]: https://en.wikipedia.org/wiki/Memex
[Xanadu]: https://en.wikipedia.org/wiki/Project_Xanadu
[Mother of all Demos]: https://en.wikipedia.org/wiki/The_Mother_of_All_Demos
[SearchMonkey]: https://en.wikipedia.org/wiki/Yahoo!_SearchMonkey
[BOSS]: https://en.wikipedia.org/wiki/Yahoo!_Search_BOSS
[Freebase]: https://en.wikipedia.org/wiki/Freebase_(database)
[Open Graph]: https://ogp.me
[Siri]: https://en.wikipedia.org/wiki/Siri
[Geocities]: https://en.wikipedia.org/wiki/Yahoo!_GeoCities
[sherlocked]: https://en.wikipedia.org/wiki/Sherlock_(software)#Sherlocked_as_a_term
[Wolfram|Alpha]: https://www.wolframalpha.com
[google query]: https://www.google.com/search?q=Who+was+the+first+person+to+land+on+the+moon%3F
[@AirspeedSwift]: https://twitter.com/AirspeedSwift

[RDF]: https://en.wikipedia.org/wiki/Resource_Description_Framework
[Triple]: https://en.wikipedia.org/wiki/Semantic_triple
[RDF/XML]: https://en.wikipedia.org/wiki/RDF/XML
[N-Triples]: https://en.wikipedia.org/wiki/N-Triples
[Turtle]: https://en.wikipedia.org/wiki/Turtle_(syntax)
[JSON-LD]: https://en.wikipedia.org/wiki/JSON-LD
[SPARQL]: https://en.wikipedia.org/wiki/SPARQL
[OWL]: https://en.wikipedia.org/wiki/Web_Ontology_Language

[semantic]: https://github.com/github/semantic
[tree-sitter]: https://github.com/tree-sitter
[LLVM]: http://llvm.org/
[strength reduction]: https://en.wikipedia.org/wiki/Strength_reduction
[constant folding]: https://en.wikipedia.org/wiki/Constant_folding

[Moore's Law]: https://en.wikipedia.org/wiki/Moore%27s_law
[semantic web]: https://en.wikipedia.org/wiki/Semantic_Web
[CGI]: https://en.wikipedia.org/wiki/Common_Gateway_Interface
[CPAN]: https://www.cpan.org/
[Yahoo!]: https://en.wikipedia.org/wiki/Yahoo!_Directory
[DMOZ]: https://en.wikipedia.org/wiki/DMOZ
[yellow pages]: https://en.wikipedia.org/wiki/Yellow_pages
[PHP]: https://en.wikipedia.org/wiki/PHP
[dot-com bubble]: https://en.wikipedia.org/wiki/Dot-com_bubble
[JavaScript]: https://en.wikipedia.org/wiki/JavaScript
[Flash]: https://en.wikipedia.org/wiki/Adobe_Flash
[Java applets]: https://en.wikipedia.org/wiki/Java_applet
[XMLHttpRequest]: https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest
[AJAX]: https://en.wikipedia.org/wiki/Ajax_(programming)
[mashups]: https://en.wikipedia.org/wiki/Mashup_(web_application_hybrid)
[Flickr]: https://www.flickr.com
[Fire Eagle]: https://en.wikipedia.org/wiki/Fire_Eagle
[MOO]: https://www.moo.com/us/
[Tripod]: https://en.wikipedia.org/wiki/Tripod_(web_hosting)
[AltaVista]: https://en.wikipedia.org/wiki/AltaVista

[SwiftSyntax]: https://github.com/apple/swift-syntax
[SwiftSemantics]: https://github.com/SwiftDocOrg/SwiftSemantics
[Neo4j]: https://neo4j.com
[PostgreSQL]: https://postgres.app
[Alamofire]: https://github.com/Alamofire/Alamofire

{% asset articles/as-we-may-code.css %}
