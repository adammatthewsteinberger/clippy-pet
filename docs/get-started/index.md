---
title: Get started
description: Install Clippy Pet in one line, pick it in the ChatGPT desktop app or Codex CLI, and fix the three things that usually go wrong.
---

# Get started

<div class="cp-bubble">It looks like you're installing a pet. Would you like help with that? (This time the answer is actually useful.)</div>

Getting a paperclip takes three steps and about thirty seconds:

1. **[Install](install.md)**: one command on any Unix-like system, or a double-click installer on macOS and Linux.
2. **[Pick it](select.md)**: choose Clippy Pet in the ChatGPT desktop app, the Codex CLI, or upload the web build to ChatGPT.
3. **Enjoy**: it idles, waves, and follows your pointer. When your run fails, it looks appropriately concerned.

If step 2 doesn't show the pet, [troubleshooting](troubleshooting.md) covers reloads, `CODEX_HOME`, Gatekeeper, and terminal image support. If you ever want it gone, [uninstall](uninstall.md) is one command and leaves nothing behind.

## What "install" means here

Clippy Pet is data, not a program. Installing means placing exactly two files in your Codex configuration directory:

```text
${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/
├── pet.json          # 236 bytes: id, name, description, spriteVersionNumber: 2
└── spritesheet.webp  # 1.5 MB: 1536×2288 transparent atlas, 8 columns × 11 rows
```

Every installer on this site (the one-liner, the `.dmg`, the `.deb`, the Homebrew formula when it lands) does that and only that. The `clippy-pet` command-line tool that ships with the packages exists to copy those files into the right place, tell you whether they're current, and remove them again.

[Install now :material-arrow-right:](install.md){ .md-button .md-button--primary }
