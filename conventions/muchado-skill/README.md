# MuchAdo Skill Convention

This convention builds a Copilot skill for MuchAdo from the Docusaurus documentation published alongside the convention.

## Output

The convention writes the skill to `skill` in the target repository.

The generated structure is:

```text
skill/
  SKILL.md
  references/
    analyzers.md
    command-batches.md
    commands.md
    ...
```

`docs/README.md` becomes the main `SKILL.md` documentation. The other Markdown files in `docs` are copied into `references`.

## Behavior

* replaces Docusaurus front matter in `docs/README.md` with skill metadata
* rewrites main documentation links such as `./commands.md` to `references/commands.md`
* copies all other Markdown files from `docs` into `references`
* removes stale generated Markdown files from `references` when the source file no longer exists
* writes UTF-8 files without a byte order mark
