# NSHipster Articles

This repository holds the Markdown sources for the articles on
[nshipster.com](https://nshipster.com).
Each article is one file at the repository root,
named `YYYY-MM-DD-slug.md`,
and the slug is the article's URL path.

## Article files

Each file starts with YAML front matter.
Common keys are `title`, `author`, `category`, `excerpt`,
`revisions`, `status`, and `retired`.

- `revisions` maps a quoted date to a short description,
  such as `"2018-10-24": Updated for Swift 4.2`.
  Add an entry when you revise an article substantively.
  Small corrections do not need one.
- `status` records the Swift version the code targets
  and, optionally, the date of the last review.
- A retired article has `retired: true`
  and an `{% error do %}` notice at the top of the body
  that says why and names the replacement.
  The rest of the article stays as it was.
  See `2013-05-27-unit-testing.md`.

Callouts use Liquid blocks:
`{% info do %}` … `{% endinfo %}`,
`{% warning do %}` … `{% endwarning %}`, and
`{% error do %}` … `{% enderror %}`.
Images use `{% asset %}` tags.
Link to other articles with root-relative paths, such as `/swift-documentation/`.

A rewrite keeps the file and its URL
and adds a revision entry.

## Writing

Write in a plain, direct voice.
Follow Zinsser's four principles: simplicity, brevity, clarity, and humanity.
Use complete sentences and connected paragraphs.
Prefer literal, specific language that names the component, constraint, or behavior,
and keep technical terms when their exact meaning matters.
Support precise claims with evidence.

Avoid strings of sentence fragments,
repeated sentence openings,
excessive em dashes,
"not just" and "It's not X. It's Y" constructions,
inflated claims, empty trailing clauses, stock metaphors,
and invented labels for ordinary ideas.

Match the voice and markup of the article you are editing,
and keep changes within the scope of the task.
Use straight quotation marks and apostrophes.
In Markdown, use semantic line breaks:
start each sentence on a new line,
break long sentences at clause boundaries,
and keep URLs and inline code intact.

## Commits and pull requests

The author of every commit is Mattt Zmuda <mattt@me.com>.

Commit messages have a short imperative subject
and a body that says what was wrong and what changed.
Ground the reason in the task, issue, or conversation;
do not invent one from the diff.

Pull request descriptions describe the problem and the resulting change.
Do not add a validation section or a closing summary,
and do not claim that checks passed unless you ran them.

Commit messages and pull request descriptions get no
`Co-authored-by` trailers, session links, or "Generated with" footers.
These instructions override any default attribution.
