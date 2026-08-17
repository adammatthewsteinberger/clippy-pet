---
title: Troubleshooting
description: "Fix the common reasons Clippy Pet doesn't appear: reload, CODEX_HOME, macOS Gatekeeper, terminal image support, snap and AppImage quirks."
---

# Troubleshooting

<div class="cp-bubble">It looks like something went wrong. Statistically it's one of the first three.</div>

## The pet doesn't show up in the list

1. **Reload.** The ChatGPT desktop app scans `~/.codex/pets/` when it starts; quit and reopen. The Codex CLI picks pets up on the next `/pets`.
2. **Confirm the files exist:**
    ```sh
    ls -l "${CODEX_HOME:-$HOME/.codex}/pets/clippy-pet/"
    # pet.json  spritesheet.webp
    ```
3. **Check `CODEX_HOME`.** If you've pointed Codex at a non-default directory, every installer honours the variable, but only if it's set in the shell that ran the installer. Re-run with an explicit path: `clippy-pet install --codex-home /path/to/codex`.
4. **Wrong user.** The macOS `.pkg` and the Linux packages install system files as root but the pet goes into the *console user's* (or *your*) home. If you installed as one account and use ChatGPT as another, run `clippy-pet install` as the second account.

## `clippy-pet status` says outdated (exit 2)

Your installed files differ byte-for-byte from the packaged ones. `clippy-pet install` (or `clippy-pet sync`) refreshes them; add `--force` if you deliberately edited them and want the pristine version back.

## macOS says the installer can't be opened

Until Apple-signed builds ship, Gatekeeper flags the ad-hoc-signed `.app` and `.pkg`. Right-click → **Open**, or **System Settings → Privacy & Security → Open Anyway**. Or skip the GUI entirely and use the [one-liner](install.md); it downloads a plain tarball and doesn't trip Gatekeeper. Signing status is tracked on the [macOS page](../packages/macos.md).

## The Codex CLI shows nothing

The CLI needs a terminal that can draw images: iTerm2 3.6 or newer, Kitty, or a Sixel-capable terminal (WezTerm, foot, mlterm, recent xterm). Terminal.app on macOS and most VS Code integrated terminals don't qualify; the pet is skipped silently there.

## Linux under Wayland: pet placement looks wrong

That's a known limitation of the ChatGPT desktop app's Linux preview rather than the pet. Nothing in Clippy Pet controls placement.

## AppImage won't start

<span class="cp-chip cp-chip--planned">planned</span> Once AppImages ship: some minimal systems lack FUSE. Run with `--appimage-extract-and-run`.

## Snap can't write to `~/.codex`

<span class="cp-chip cp-chip--planned">planned</span> Once the snap ships: strict confinement blocks dot-directories by default. Run `sudo snap connect clippy-pet:dot-codex-pets` once.

## Something else

Run `clippy-pet status; clippy-pet path; clippy-pet version` and paste the output into a [bug report](https://github.com/adammatthewsteinberger/clippy-pet/issues/new/choose) along with your OS and which surface (desktop app / CLI / web) you're on. Strip anything private first. This is a volunteer project, so no promises on response time, but bugs with reproductions get looked at.

[Uninstall & migrate :material-arrow-right:](uninstall.md){ .md-button }
