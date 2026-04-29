# MuchAdo Skill Convention

This convention builds a Copilot skill for MuchAdo from the Docusaurus documentation in `docs`.

## Output

The convention writes the skill to `static/skills/muchado` so the static site publishes it with the rest of the generated assets.

The generated structure is:

```text
static/skills/muchado/
  SKILL.md
  references/
    analyzers.md
    command-batches.md
    commands.md
    ...
```

`docs/README.md` becomes the main `SKILL.md` documentation. The other Markdown files in `docs` are copied into `references`.

## Behavior

The convention is idempotent. Each run:

* replaces Docusaurus front matter in `docs/README.md` with skill metadata
* rewrites main documentation links such as `./commands.md` to `references/commands.md`
* copies all other Markdown files from `docs` into `references`
* removes stale generated Markdown files from `references` when the source file no longer exists
* writes UTF-8 files without a byte order mark

## Settings

This convention does not currently support settings.

## Requirements

The convention runs with PowerShell 7 from the root of the target repository. The target repository must contain `docs/README.md`.
