---
title: Model Context Protocol (MCP)
author: Mattt
category: Miscellaneous
excerpt: >-
  Language Server Protocol (LSP)
  revolutionized how programming languages integrate with developer tools.
  Model Context Protocol (MCP)
  aims to do the same for a new generation of AI tools.
status:
  swift: 6.0
---

Language Server Protocol (LSP)
revolutionized how programming languages integrate with developer tools.
Model Context Protocol (MCP)
aims to do the same for a new generation of AI tools.

But before we lay our scene of two protocols (both alike in dignity),
let's take a moment to motivate the problem a bit more.

## Tool Use & Agents

Today’s frontier models are extraordinary. 
But they’re limited in two key ways:

1. They don’t know anything outside their training data
2. They can’t do anything outside of predicting the next token

To their credit, LLMs _(kinda, sorta)_ understand these limitations, 
and have been trained to ask for what they need. 
We (humans) have settled on a practice called <dfn>tool use</dfn> 
that lets AI do just that.

Here's an example:

<!-- 
- When a user sends a message, 
  they may include a list of tools made available to the model.
- When the AI assistant responds, 
  it may ask to call one or more of those tools.
- The client asks the user to approve or deny this to request.
- If approved, the client execute the tool, 
  and returns the result in a follow up message to the model.
- The AI assistant generates a response based on this information. 
-->

{::nomarkdown}
<dl>
<dt class="user">User</dt>
<dd class="user">Write a limerick about today's weather in Portland, Oregon.</dd>

<dt class="client">Client, to Assistant →</dt>
<dd class="client">
  Also, there's this "Get Weather" tool available if you need it.
  It takes a set of coordinates and returns the current temperature and conditions.
</dd>

<dt class="assistant">Assistant</dt>
<dd class="assistant">
  <code>&lt;thinking&gt;</code>
  <em>To write an accurate poem, I should get the weather.
  From my training, <wbr/>I know Portland's coordinates to be 
  45.5155° N, 122.6789° W</em>
  <code>&lt;/thinking&gt;</code>
</dd>
<dd class="assistant">
  Tool call:
  <code>{tool: "Get Weather", latitude: 45.5155, longitude: -122.6789}</code>
</dd>

<dt class="client">← Client, to User</dt>
<dd class="client">Is it alright to make that tool call?</dd>

<dt class="user">User</dt>
<dd class="user"><span class="big">👍</span></dd>

<dt class="client">Client, to Assistant →</dt>
<dd class="client">
  Tool result:
  <code>{temperature: 12, conditions: 'cloudy', humidity: 85%}</code>
</dd>

<dt class="assistant">Assistant</dt>
<dd class="assistant">Here's your limerick about Portland's weather:</dd>
<dd>
<blockquote>
  There once was a city called Portland <br/>
  Where clouds made the skies quite importland <br/>
  At twelve degrees C <br/>
  It's as gray as can be <br/>
  With a dampness that's truly absorbland! <br/>
</blockquote>
</dd>
</dl>
{:/}

Pretty clever, right? <br/>
But then again, <em>so what?</em>

On its face, this is a very slow, expensive way to do something 
better-served by a quick Google search — 
or sticking your head out a window, for that matter.

But here's the thing: <br/>
**Tool use gives rise to agency**
<span aria-label="emergence" role="text">
  (✨𝓮𝓶𝓮𝓻𝓰𝓮𝓷𝓬𝓮✨)
</span>

As the saying goes, 
<q>Quantity has a quality all its own</q>.
Give a language model a dozen... a hundred... a thousand tools —
hell, give it _a tool for making more tools_.
How confident are you that you could find a problem 
that couldn't be solved by such a system?

We're only just starting to see what's possible.

---

But back to more practical matters: <br/>
Let's talk about where we are today with Model Context Protocol.

---

## The New M × N Problem

We've [written previously](https://nshipster.com/language-server-protocol) 
about Language Server Protocol, 
and the <dfn>M × N problem</dfn>.
LSP's challenge was connecting `M` editors with `N` programming languages
MCP faces a similar challenge, of connecting `M` clients with `N` resources.
Without MCP, 
each AI application must implement custom integrations 
for every data source it wants to access.

<!-- ![Diagram of M x N grid](...) -->

This creates the same kind of fragmented ecosystem that plagued development tools before LSP:
- Some AI applications offer deep integration with specific data sources but limited support for others
- Different applications implement similar integrations in incompatible ways
- Improvements to one integration rarely benefit the broader ecosystem

Like LSP, 
MCP transforms this M × N problem into an <dfn>M + N</dfn> problem through standardization.
Rather than each AI application implementing custom integrations, 
it only needs to support the MCP standard. 
In doing so, 
it gains access to all MCP-compatible data sources and tools 🌈

<!-- ![Diagram of M + N](...) -->

## How Model Context Protocol Works

MCP follows a client-server architecture similar to LSP:

- The *client* is typically an AI application or development environment <br/>
  For example, 
  [Claude Desktop](https://claude.ai/download),
  [Zed](https://zed.dev), and 
  [Cursor](https://www.cursor.com).
- The *server* is a program that provides access to data and/or tools

Requests and responses are encoded according to the
[JSON-RPC](https://www.jsonrpc.org/) 2.0 specification.
Communication between client and server happens over 
Stdio (`stdin`/`stdout`) or HTTP with Server-Sent Events 
[transports](https://modelcontextprotocol.io/docs/concepts/architecture#transport-layer).

Like LSP, MCP has clients and servers negotiate a set of capabilities.
When a client connects to a server, it sends an 
[`initialize` message](https://spec.modelcontextprotocol.io/specification/2024-11-05/basic/lifecycle/#initialization),
with information about what protocol version it supports.
The server responds in kind.

From there, the client can ask the server about what features it has.
MCP describes three different kinds of features that a server can provide:

- **Prompts**: 
  Templates that shape how language models respond. 
  They're the difference between getting generic text and precise, useful results. 
  A good prompt is like a well-designed API - 
  it defines the contract between you and the model.
- **Resources**:
  Reference materials that ground models in reality. 
  By providing structured data alongside your query, 
  you transform a model from a creative writer into 
  an informed assistant with domain-specific knowledge.
  _(Think: databases, file systems, documents)_
- **Tools**: 
  Functions that extend what models can do. 
  They allow AI to calculate, retrieve information, 
  or interact with external systems when simple text generation isn't enough. 
  Tools bridge the gap between language understanding and practical capability.

{% info %}

The distinction between these is admittedly fuzzy.
After all, all they ultimately do is fill a context window with tokens.
You could, for example, implement everything as a tool.

<aside class="parenthetical">
In practice, that's what clients tend to support best
</aside>

{% endinfo %}

Our previous example handwaved the existence of a "Get Weather" tool.
MCP gives our client a standard way to consult various connected services.

To get a list of available tools on an MCP, 
the client would send a `tools/list` request to the server:

```json
{
  "jsonrpc": "2.0", 
  "id": 1, 
  "method": "tools/list", 
  "params": {}
}
```

In our example, the server would respond:

```json
{
  "jsonrpc":"2.0",
  "id": 1,
  "result": {
    "tools": [
      {
          "name": "get_weather",
          "description": "Returns current weather conditions for the specified coordinates.",
          "inputSchema": {
              "type": "object", 
              "properties": {
                  "latitude": { "type": "number" },
                  "longitude": { "type": "number" }
              },
              "required": ["latitude", "longitude"]
          }
      }
    ]
  }
}
```

The client can share this list of tools with the language model
in a system prompt or a user message.
When the model responds wanting to invoke the `get_weather` tool,
the client asks the user to confirm tool use.
If the human-in-the-loop says 🆗,
the client sends a `tools/call` request:

```json
{
  "jsonrpc": "2.0", 
  "id": 2,
  "method": "tools/call", 
  "params": { 
    "name": "get_weather",
    "arguments": {
      "latitude": 45.5155,
      "longitude": -122.6789
    }
  }
}
```

In response, the server sends:

```json
{
  "jsonrpc":"2.0",
  "id": 2,
  "content": [
    {
      "type": "text",
      "text": "{\"temperature\": 12, \"conditions\": \"cloudy\", \"humidity\": 85}"
      "annotations": {
        "audience": ["assistant"]
      }
    }
  ]
}
```

The client then passes that result to the AI assistant,
the assistant generates a response with this information,
and the client passes that along to the user.

---

That's pretty much all there is to it.
There are plenty of details to get bogged down with.
But that's what LLMs are for.
Now is the time for vibes coding. <br/>
MCP is [punk rock](https://www.itsnicethat.com/features/toby-mott-oh-so-pretty-punk-in-print-phaidon-111016).

{% asset model-context-protocol-now-form-a-band.webp %}

## How do I start?

MCP is an emerging standard from Anthropic.
So it's no surprise that [Claude Desktop](https://claude.ai/download)
is most capable of showing off what it can do.

Once you have Claude Desktop installed,
you can peruse the 
[myriad example servers](https://modelcontextprotocol.io/examples) available.

Or, if you want to skip straight to la <em lang="fr">crème de la crème</em>,
then have a taste of what we've been cooking up with MCP lately:

### iMCP

Fun fact! The word _"paradise"_ derives from an old word for _"walled garden"_.
<aside class="parenthetical">
The English word "paradise" comes from Old French "paradis", 
which derives from Latin "paradisus", 
which was borrowed from Greek <span title="paradeisos">"παράδεισος"</span>, 
which itself was adopted from Old Persian <span title="paridaida">"𐎱𐎼𐎭𐎹𐎭𐎠𐎶"</span>
</aside>

Ironic how Apple has a way of making your digital life a living hell sometimes.

For many of us who exist in Apple's walled garden, 
we’re often frustrated by the product design and software quality 
that gets between us and our data.
Spotlight search is stuck in the ‘00s. 
Apple Intelligence [didn’t live up to the hype](https://nshipster.com/ollama). 
Siri seems doomed to suck forever.

That was our motivation for building [iMCP](https://iMCP.app).

{::nomarkdown }
<picture id="imcp-logo">
    <source srcset="{% asset model-context-protocol-imcp--dark.svg @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset model-context-protocol-imcp--light.svg @path %}" alt="iMCP" onclick="window.location.href='https://iMCP.app';">
</picture>
{:/}

iMCP is a macOS app for connecting your digital life with AI. 
It works with Claude Desktop and a growing list of clients that support MCP.
It gives MCP access to your calendars, contacts, even messages —
[no small feat](https://github.com/loopwork-ai/iMCP?tab=readme-ov-file#imessage-database-access)!

[Download it today](https://iMCP.app/download)
and get a taste of some _real_ Apple intelligence.

### mcp-swift-sdk

In the process of building iMCP,
we built a [Swift SDK](https://github.com/loopwork-ai/mcp-swift-sdk)
for Model Context Protocol servers and clients.

If you're inspired to build your own MCP app
and like working in Swift more than Python or TypeScript,
definitely give this a try!

### hype

If, however, you have accepted Python into your heart as I have,
then I'd recommend checking out another project I've been working on:
[hype](https://github.com/loopwork-ai/hype).

My goal with hype is to eliminate every barrier between writing Python code
and calling it in a way that's useful.
Add the `@hype.up` decorator to a function
to instantly generate an HTTP API, a CLI, a GUI, or an MCP.

```python
# example.py
import hype
from pydantic import Field

@hype.up
def divide(
    x: int,
    y: int = Field(gt=0),
) -> int:
    """
    Divides one number by another.
    :param x: The numerator
    :param y: The denominator
    :return: The quotient
    """
    return x // y
```

Start up an MCP server with the `hype` command:

```console
$ hype mcp example.py
```

### emcee

But really, the best code is code you don't have to write.
If you already have a web application with an
[OpenAPI specification](https://www.openapis.org),
you can use another tool we built —
[emcee](https://emcee.sh) —
to instantly spin up an MCP server to it.

<img src="{% asset model-context-protocol-emcee.png @path %}" alt="emcee" onclick="window.location.href='https://emcee.sh';">

We think emcee is a convenient way to connect to services 
that don't have an existing MCP server implementation — 
_especially for services you're building yourself_. 
Got a web app with an OpenAPI spec? 
You might be surprised how far you can get without a dashboard or client library.

---

In case it's not abundantly clear,
we here at NSHipster dot com are pretty bought into the promise of
Model Context Protocol.
And we're excited to see where everything goes in the coming months.

If you're building in this space, 
I'd love to [hear from you](mailto:mattt@nshipster.com)
✌️

{% asset articles/model-context-protocol.css @inline %}
