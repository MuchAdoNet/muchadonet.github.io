# update-repo-docs

This convention updates repository documentation for MuchAdo from the Docusaurus documentation published alongside the convention.

## Output

The convention writes the Copilot skill to `skills/muchado` in the target repository.

The generated skill structure is:

```text
skills/
  muchado/
    SKILL.md
    references/
      analyzers.md
      command-batches.md
      commands.md
      ...
```

The convention also updates the generated common documentation section in the target repository `README.md`. The generated section is marked with these comments:

```md
<!-- DO NOT EDIT: update-repo-docs convention -->

...

<!-- END DO NOT EDIT -->
```

`docs/README.md` becomes the main `SKILL.md` documentation and the generated `README.md` section. The other Markdown files in `docs` are copied into `references`.

## Behavior

* replaces Docusaurus front matter in `docs/README.md` with skill metadata
* rewrites main skill documentation links such as `./commands.md` to `references/commands.md`
* rewrites generated `README.md` links such as `./commands.md` to `https://muchado.net/commands`
* copies all other Markdown files from `docs` into `references`
* removes stale generated Markdown files from `references` when the source file no longer exists
* writes UTF-8 files without a byte order mark