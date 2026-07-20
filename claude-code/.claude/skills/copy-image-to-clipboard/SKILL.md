---
name: copy-image-to-clipboard
description: Copy an image file to the macOS clipboard using the bundled `scripts/pbcopyimg.sh` script. Use when the user says "copy that image to my clipboard", "copy this image to the clipboard", "put that image on my clipboard", or names an image file to copy.
allowed-tools: Bash
---

Copy an image file to the macOS clipboard via the bundled script at
`~/.claude/skills/copy-image-to-clipboard/scripts/pbcopyimg.sh`. Always invoke it by that
full `~/` path — never by a relative path, and never after `cd`-ing into the skill dir.

## 1. Resolve the target image

Determine which image file to copy:

- If the user named a file (path or filename), use that.
- Otherwise, resolve "that image" / "this image" to the most recently produced or
  referenced image in the current conversation — e.g. a screenshot just saved, a file
  the user mentioned, or an image path discussed moments ago.
- If no image can be confidently identified, ask the user for the path. Do not guess.

Expand `~` and relative paths to something the shell can read. Supported extensions are
`png`, `jpg`, `jpeg`, `tif`, `tiff`, `gif`, `pdf` (these are what the script accepts).

## 2. Copy it with the bundled script

Run the bundled script on the resolved file (quote the path). Invoke it by its `~/`
absolute path so it runs correctly regardless of the current working directory and
resolves to the right home on any machine:

```
~/.claude/skills/copy-image-to-clipboard/scripts/pbcopyimg.sh "<image-file>"
```

Run this command **exactly as written** — a single command, from whatever the current
working directory is. Do **not** `cd` into the skill directory first, and do **not** wrap
it in a compound command; the `~/` path already resolves correctly on its own, and an
extra `cd` only causes a second permission prompt.

The script ships with this skill; no shell function or config is
required. On success it prints `copied <abs-path> to clipboard` — report that the image is
on the clipboard. If the file does not exist or the type is unsupported, the script prints
a usage/error message and exits non-zero — relay it to the user.

## Notes

- This relies on macOS (`osascript`). If run elsewhere it will not work.
- Only the clipboard is written; no files are modified.
