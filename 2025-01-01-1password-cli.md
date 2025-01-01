---
title: op run
author: Mattt
category: Miscellaneous
excerpt: >-
  `.env` files can create friction in development workflows — 
  especially as teams and projects grow over time.
  If you're feeling this pain,
  the 1Password CLI (`op`) might be just what you need.
status:
  swift: 6.0
---

`.env` files.
If you've worked on a web application,
you've probably seen one.

While they certainly get the job done,
`.env` files have shortcomings that can create friction in development workflows.

We've touched on `.env` files in past articles about
[xcconfig](https://nshipster.com/xcconfig/) files and 
[secret management on iOS](https://nshipster.com/secrets/).
But this week on NSHipster we're taking a deeper look,
exploring how the lesser-known
[1Password CLI](https://developer.1password.com/docs/cli/get-started/) (`op`)
can solve some problems many of us face managing secrets day-to-day.

---

## The Problem of Configuration

Around 2011, Adam Wiggins published
["The Twelve-Factor App"](https://12factor.net),
a methodology for building modern web applications
that has since become canon in our industry.

The third of those twelve factors,
["Config"](https://12factor.net/config),
prescribes storing configuration in environment variables:

> "Apps sometimes store config as constants in the code.
> This is a violation of twelve-factor,
> which requires **strict separation of config from code**.
> Config varies substantially across deploys, code does not."

This core insight — that configuration should be separate from code —
led to the widespread adoption of `.env` files.

{% info %}

The convention of `.env` files also came out of Heroku at that time,
by way of David Dollar's [Foreman](https://github.com/ddollar/foreman) tool.
Brandon Keepers' standalone [dotenv](https://github.com/bkeepers/dotenv) Ruby gem
came a couple years later.
Both projects have inspired myriad ports to other languages.

{% endinfo %}

A typical `.env` file looks something like this:

```
DATABASE_URL=postgres://localhost:5432/myapp_development
REDIS_URL=redis://localhost:6379/0
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=wJa...
STRIPE_SECRET_KEY=sk_test_...
```

You add this file to `.gitignore` to keep it out of version control,
and load these variables into your environment at runtime with a tool or library.

Simple enough. 
So what's the problem?

### .env Files in Practice

Despite their apparent simplicity,
`.env` files introduce several points of friction in development workflows:

First, there's the perennial issue of onboarding:
How does a new team member get what they need to run the app locally?
The common solution is to have a `.env.sample` / `.env.example` file in version control,
but this creates a maintenance burden to keep it in sync with the actual requirements.
And in any case,
developers still need to go on a scavenger hunt to fill it out 
before they can be productive.

Then there's the multi-environment problem:
As soon as you need different configurations for development, staging, and production,
you end up with a proliferation of files:
`.env.development`, `.env.test`, `.env.staging`...
Each requiring its own `.sample` / `.example` counterpart.

But perhaps most pernicious is the challenge of managing changes to configuration over time.
Because `.env` files aren't in version control,
changes aren't, you know... _tracked anywhere_ 🥲

## Enter the 1Password CLI (`op`)

You may already use [1Password](https://1password.com) 
to manage your passwords and other secrets.
But what you might not know is that 1Password also has a CLI
that can integrate directly with your development workflow.

`op` lets you manage 1Password from the command-line.
You can do all the 
<abbr title="Create-Read-Update-Delete">CRUD</abbr>
operations you'd expect for items in your vault.
But its killer features is the `op run` subcommand,
which can dynamically inject secrets from your 1Password vault
into your application's environment.

Instead of storing sensitive values directly in your `.env` file,
you reference them using special `op://` URLs:

```shell
# .env
IRC_USERNAME=op://development/chatroom/username
IRC_PASSWORD=op://development/chatroom/password
```

<span></span> <!-- Empty span prevents adjacent code blocks from being combined -->

```swift
import Foundation

guard let username = ProcessInfo.processInfo.environment["IRC_USERNAME"],
     let password = ProcessInfo.processInfo.environment["IRC_PASSWORD"] else {
   fatalError("Missing required environment variables")
}

// For testing only - never print credentials in production code
print(password)
```

Run this on its own, 
and you'll fail in proper 12 Factor fashion:

```terminal
$ swift run
❗️ "Missing required environment variables"
```

But by prepending `op run`
we read in that `.env` file,
resolve each vault item reference,
and injects those values into the evironment:

```terminal
$ op run -- swift run
hunter2
```

{% warning %}

The double dash (`--`) after `op run` is important!
It tells the shell to pass all subsequent arguments to the command being run,
rather than interpreting them as options to `op run` itself.

{% endwarning %}

You're even prompted to authorize with Touch ID the first time you invoke `op run`.

{::nomarkdown }
<figure>
<picture>
    <source srcset="{% asset 1password-authorize--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset 1password-authorize--light.png @path %}" alt="1Password Create Vault dialog" loading="lazy" style="width: 400px;">
</picture>
</figure>
{:/}

---

Ready to give this a test drive?
Here's how to get started:

## A Step-By-Step Guide to Using the 1Password CLI in .env Files

### Step 1: Install and Configure the 1Password CLI

On macOS, you can install the CLI with [homebrew](https://brew.sh/):

```terminal
$ brew install 1password-cli
```

Then, in the 1Password app, 
open Settings (<kbd>⌘</kbd><kbd>,</kbd>),
go to the Developer section,
and check the box labeled "Integrate with 1Password CLI".

{::nomarkdown }
<figure id="enable-cli-settings">
<picture>
    <source srcset="{% asset 1password-settings--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset 1password-settings--light.png @path %}" alt="1Password Settings" loading="lazy" style="width: 100%;  margin: 0 !important;">
</picture>
</figure>
{:/}

Running any `op` subcommand should prompt you to connect to the app.

If you get off the happy path,
consult [the official docs](https://developer.1password.com/docs/cli/get-started/)
to get back on track.

### Step 2: Create a Shared Vault

Create a new vault in 1Password specifically for development secrets.
Give it a clear name like "Development" and a useful description.

{::nomarkdown }
<figure id="create-vault-dialog">
<picture>
    <source srcset="{% asset 1password-create-vault--dark.png @path %}" media="(prefers-color-scheme: dark)">
    <img src="{% asset 1password-create-vault--light.png @path %}" alt="1Password Create Vault dialog" loading="lazy" style="width: 100%;  margin: 0 !important;">
</picture>
</figure>
{:/}

### Step 3: Migrate Existing Secrets

For each entry in your `.env` file,
create a corresponding item in 1Password.
Choose the appropriate item type:

{::nomarkdown }
<div style="display: flex; align-items: center; margin-bottom: 1rem;">
  <div style="margin-right: 1rem;">
    <img src="{% asset 1password-api-credential.png @path %}" alt="" width="64"/>
  </div>
  <div>
    <strong>API Credential</strong>
    <div>For third-party service API keys</div>
    <div class="fields">
        Fields:
        <span class="field">username</span>,
        <span class="field">credential</span>
    </div>
  </div>
</div>

<div style="display: flex; align-items: center; margin-bottom: 1rem;">
  <div style="margin-right: 1rem;">
    <img src="{% asset 1password-password.png @path %}" alt="" width="64"/>
  </div>
  <div>
    <strong>Password</strong>
    <div>For first-party secrets, like encryption keys</div>
    <div class="fields">
        Fields:
        <span class="field">username</span>,
        <span class="field">password</span>
    </div>
  </div>
</div>

<div style="display: flex; align-items: center; margin-bottom: 1rem;">
  <div style="margin-right: 1rem;">
    <img src="{% asset 1password-database.png @path %}" alt="" width="64"/>
  </div>
  <div>
    <strong>Database</strong>
    <div>For hosted PostgreSQL databases and the like</div>
    <div class="fields">
        Fields:
        <span class="field">type</span>,
        <span class="field">server</span>,
        <span class="field">port</span>,
        <span class="field">database</span>,
        <span class="field">username</span>,
        <span class="field">password</span>
    </div>
  </div>
</div>
{:/}

### Step 4: Update Your .env File

Replace raw values in your `.env` file
with `op://` references using the following format:

```
op://<#vault#>/<#item#>/<#field#>
```

Each reference consists of three components:
- The vault name (e.g., "development")
- The item name or UUID
- The field name from the item

For example, here's how you might reference credentials for various services:

```shell
# Reference by item name (case-insensitive)
AWS_ACCESS_KEY_ID=op://development/AWS/username
AWS_SECRET_ACCESS_KEY=op://development/WorkOS/credential

# Reference by item UUID
STRIPE_SECRET_KEY=op://development/abc123xyz789defghijklmnop/password

# Using different field names based on item type
DATABASE_HOST=op://development/db/server
DATABASE_USER=op://development/db/username
DATABASE_PASSWORD=op://development/db/password
DATABASE_NAME=op://development/db/database
```

{::nomarkdown}
<div style="display: flex; align-items: flex-start; gap: 1.5em; margin-bottom: 1em; padding-top: 0.5em;">
  <div style="flex: 1;">
  <p>
    You can locate the UUID for any item in 1Password by 
    clicking the "More actions" button (<kbd title="actions menu">⋮</kbd>, <em>whatever you want to call that</em>) 
    and selecting "Copy item UUID".
  </p>
  <p>
    Both item name and UUID references work,
but using UUIDs can be more reliable in automation contexts
since they're guaranteed to be unique and won't change if you rename the item.
  </p>
  </div>
  <picture>
    <source srcset="{% asset 1password-copy-uuid--dark.png @path %}" media="(prefers-color-scheme: dark)">
      <img src="{% asset 1password-copy-uuid--light.png @path %}" alt="1Password Copy Item UUID" loading="lazy" style="width: 150px; margin: 0 !important;">
  </picture>
</div>
{:/}

Once you've replaced all sensitive values with `op://` references,
you can safely commit your `.env` file to version control.
The references themselves don't contain any sensitive information –
they're just pointers to your 1Password vault.

{% info %}

You might find that `.env` files are excluded by your global Git configuration.
To override this, add the following to your repository's `.gitignore`:

```shell
# Override global .gitignore to allow .env containing op:// references
!.env
```

The exclamation point (`!`) [negates a previous pattern](https://git-scm.com/docs/gitignore#_pattern_format),
allowing you to explicitly include a file that would otherwise be ignored.

{% endinfo %}

### Step 5. Update Your Development Script

Whatever command you normally run to kick off your development server,
you'll need to prepend `op run --` to that.

For example, if you follow the 
["Scripts to Rule Them All"](https://github.com/github/scripts-to-rule-them-all) pattern,
you'd update `script/start` like so:

```diff
#!/bin/sh

- swift run
+ op run -- swift run
```

{% info %}

`op run` does a neat trick by creating a 
[pseudoterminal (PTY)](https://en.wikipedia.org/wiki/Pseudoterminal) pair
to redact secrets if printed out directly to `stdout`:

```terminal
$ op run -- env
LANG=en_US.UTF-8
IRC_USERNAME=<concealed by 1Password>
IRC_PASSWORD=<concealed by 1Password>
```

This behavior can be turned off with the `--no-masking` option.

{% endinfo %}

### Advantages Over Traditional .env Files

`op run` solves many of the problems inherent to `.env` files:

- **No More Cold Start Woes**:
  New team members get access to all required configuration
  simply by joining the appropriate 1Password vault.

- **Automatic Updates**:
  When credentials change,
  they're automatically updated for everyone on the team.
  No more out-of-sync configuration.

- **Proper Secret Management**:
  1Password provides features
  like access controls, versioning, and integration with
  [Have I Been Pwned](https://haveibeenpwned.com/).

## Potential Gotchas

Like any technical solution,
there are some trade-offs to consider:

- **Performance**:
  `op run` adds a small overhead to command startup time
  (typically less than a second).
  <sup><a href="https://1password.community/discussion/145854/op-read-is-pretty-slow-700ms-per-invocation">1</a></sup>

- **stdout/stderr Handling**:
  As mentioned above,
  `op run` modifies `stdout`/`stderr` to implement secret masking,
  which can interfere with some terminal applications.
  <sup><a href="https://1password.community/discussion/145938/op-run-changes-stdout-and-stderr-to-not-be-ttys-when-masking">2</a></sup>

- **Dev Container Support**:
  If you use [VSCode Dev Containers](https://containers.dev/overview),
  you may encounter some friction with the 1Password CLI.
  <sup><a href="https://1password.community/discussion/147554/feature-request-first-class-support-for-dev-containers-and-op-cli">3</a></sup>

## Driving Technical Change

The implementation is often the easy part.
The real challenge can be getting your team on board with the change.

First, state the problem you're trying to solve.
Change for change's sake is rarely helpful.

Next, figure out who you need to get buy-in from.
Talk to them.
Articulate specific pain point that everyone recognizes,
like the frustration of onboarding new team members
or the time wasted debugging configuration-related issues.
<aside class="parenthetical">
Feel free to link them to this article 😉
</aside>

Once you've gotten the green light,
move slowly but deliberately.
Start small by migrating a single credential,
or maybe all of the credentials in a smaller project.
Build up confidence that this approach is a good fit —
both technically and socially.

---

Managing development secrets is one of those problems
that seems trivial at first but can become a significant source of friction
as your team and application grow.

The 1Password CLI offers a more sophisticated approach
that integrates with tools developers already use and trust.

While it may not be the right solution for every team,
it's worth considering if you're feeling the pain of traditional `.env` files.

{% asset articles/1password-cli.css @inline %}
