---
title: Pick it in ChatGPT & Codex
description: How to select Clippy Pet in the ChatGPT desktop app, the Codex CLI, and ChatGPT on the web (with the v1 upload build).
---

# Pick it in ChatGPT & Codex

<div class="cp-bubble">It looks like the files are installed but nothing is waving at you yet. Pets have to be selected once per surface.</div>

Pets are a feature of OpenAI's ChatGPT and Codex products; Clippy Pet is a third-party pet that follows their published contract. Where you pick it depends on where you work.

=== ":material-monitor: ChatGPT desktop app"

    The ChatGPT desktop app (macOS, Windows, and the Linux preview) hosts Codex and reads custom pets from `~/.codex/pets/`.

    1. Install Clippy Pet ([one-liner](install.md) or a native installer).
    2. Open **Settings → Pets**.
    3. Choose **Clippy Pet**.
    4. If it isn't listed, quit and reopen the app (it scans the pets directory on launch).

    Custom pets are per-user: each account on the machine runs the installer once, which is why the macOS `.pkg` seeds the console user's home and the Linux packages ask you to run `clippy-pet install` after installing.

=== ":material-console: Codex CLI"

    1. Install Clippy Pet.
    2. In the Codex CLI, type `/pets` and pick `clippy-pet`, or set it in `~/.codex/config.toml`:

        ```toml
        [tui]
        pet = "clippy-pet"
        ```

    3. Use a terminal that can draw images: **iTerm2 3.6+**, **Kitty**, or anything with **Sixel** support (WezTerm, foot, mlterm, recent xterm). Terminals without image support skip the pet rather than breaking.

=== ":material-web: ChatGPT on the web"

    Web pets are uploaded rather than installed, and the uploader currently accepts the older **v1** sheet layout (1536×1872, nine rows, ≤ 20 MiB), not the v2 sheet the desktop app uses.

    1. Download **`spritesheet-v1.webp`** from the [latest release](https://github.com/adammatthewsteinberger/clippy-pet/releases/latest) (or build it: `python3 scripts/build-v1-spritesheet.py`).
    2. Open ChatGPT → **Settings → Personalization → Pet** and upload it.

    The v1 build is a lossless crop of the v2 atlas: the same nine animation rows minus the two look-direction rows, so the web pet has every animation but doesn't track your pointer. Details in [the pet contract](../how-it-works/contract.md#v1-versus-v2).

!!! note "Product names move fast"

    Surfaces and menu paths above reflect OpenAI's products as of August 2026 (the ChatGPT desktop app with Codex inside, the Codex CLI, ChatGPT on the web). If a menu has moved, [open an issue](https://github.com/adammatthewsteinberger/clippy-pet/issues/new/choose) and we'll update this page; the pet files themselves don't change.

## What you should see

Idle breathing while you type; a wave when it appears; running animations when Codex is working; **failed** when a run errors; **waiting** while it's blocked on you; **review** while it reads a diff. Eyes track the pointer through sixteen directions on the desktop app. The [animation gallery](../meet/animations.md) shows each state.

[Troubleshooting :material-arrow-right:](troubleshooting.md){ .md-button }
