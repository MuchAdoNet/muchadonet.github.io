# MuchAdo Skill Convention

This convention builds a Copilot skill for MuchAdo from the Docusaurus documentation published alongside the convention.

## Source Data

The convention resolves its Markdown source from `docs` relative to the convention script location, not from the target repository root. This lets the convention generate the same skill content when it is applied to other repositories.

## Output

The convention writes the skill to `skills/muchado` in the target repository.

The generated structure is:

```text
skills/muchado/
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

The convention runs with PowerShell 7 from the root of the target repository.
