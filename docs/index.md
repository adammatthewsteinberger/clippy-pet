---
title: Home
description: Clippy Pet is an unofficial animated paperclip pet for the ChatGPT desktop app and Codex CLI. Nine animation states, sixteen look directions, one-line install on every Unix.
hide:
  - navigation
  - toc
---

<div class="cp-hero" markdown>
<div markdown>

# It looks like you're writing code.&nbsp;📎 { .cp-title }

<p class="cp-tagline">Would you like a paperclip to watch? Clippy Pet is an <strong>unofficial</strong>, open-source animated pet for the <strong>ChatGPT desktop app</strong> and the <strong>Codex CLI</strong>. It idles, waves, runs, jumps, fails gracefully, waits patiently, and follows your cursor through sixteen look directions.</p>

```sh
curl -fsSL https://adammatthewsteinberger.github.io/clippy-pet/install.sh | sh
```

<div class="cp-cta" markdown>
[Install it :material-arrow-right:](get-started/install.md){ .md-button .md-button--primary }
[Meet the paperclip](meet/index.md){ .md-button }
[Make your own pet](make/index.md){ .md-button }
</div>

<small>Also: <a href="packages/macos/">macOS .dmg / .pkg</a> · <a href="packages/linux/">.deb / .rpm / .apk / Arch</a> · <a href="packages/managers/">package managers</a>. One command, one directory, zero background processes.</small>

</div>
<div class="cp-gifs" markdown>
![Clippy Pet idle](assets/previews/idle.gif){ loading=lazy }
![Clippy Pet waving](assets/previews/waving.gif){ loading=lazy }
![Clippy Pet running](assets/previews/running.gif){ loading=lazy }
![Clippy Pet jumping](assets/previews/jumping.gif){ loading=lazy }
![Clippy Pet review](assets/previews/review.gif){ loading=lazy }
![Clippy Pet failed](assets/previews/failed.gif){ loading=lazy }
</div>
</div>

<div class="cp-bubble">It looks like you'd like to know what happens when you run that command. Good instinct. It downloads one release tarball, checks its SHA-256 against the published <code>SHA256SUMS</code>, and copies two files (a <code>pet.json</code> and a <code>spritesheet.webp</code>) into <code>~/.codex/pets/clippy-pet/</code>. That's it. <a href="packages/curl/">Read the whole script</a>.</div>

## What you get

<div class="grid cards" markdown>

-   :material-animation-play:{ .lg .middle } **Nine animation states**

    ---

    Idle, waving, jumping, running (right, left, and toward you), failed, waiting, and review, on a transparent 1536×2288 WebP atlas built to the pet v2 contract.

    [:octicons-arrow-right-24: See every animation](meet/animations.md)

-   :material-eye-outline:{ .lg .middle } **Sixteen look directions**

    ---

    22.5° clockwise increments so the eyes track your pointer instead of staring into the middle distance. Every direction was blind-tested and the results are published.

    [:octicons-arrow-right-24: The look directions](meet/look-directions.md)

-   :material-package-variant-closed:{ .lg .middle } **Real installers, honestly labelled**

    ---

    One-line install, `.dmg`/`.pkg`/`.app` for macOS, `.deb`/`.rpm`/`.apk`/Arch for Linux, reproducible tarballs, and a status page that says exactly which package managers are live yet.

    [:octicons-arrow-right-24: Installers & packages](packages/index.md)

-   :material-clipboard-check-outline:{ .lg .middle } **The receipts**

    ---

    A validator, blind direction QA, semantic QA, look-continuity measurements, and chroma-cleanup evidence, all checked in and all reproducible. The numbers are real, including the warnings.

    [:octicons-arrow-right-24: QA evidence](how-it-works/qa.md)

-   :material-source-branch:{ .lg .middle } **Remixable source**

    ---

    Normalized per-state frames and row strips ship in the repo under MIT. Recolor it, re-rig it, or use the pipeline to hatch a pet that isn't a paperclip at all.

    [:octicons-arrow-right-24: Make your own](make/index.md)

-   :material-history:{ .lg .middle } **A little history**

    ---

    Why a paperclip, why 1996 keeps coming back, and why this project is unofficial and says so on every page.

    [:octicons-arrow-right-24: The paperclip story](meet/history.md)

</div>

## Where it shows up

=== "ChatGPT desktop app"

    Install, then open **Settings → Pets** in the ChatGPT desktop app (Codex lives inside it on macOS, Windows, and the Linux preview) and pick **Clippy Pet**. Reload the app if it doesn't appear immediately.

=== "Codex CLI"

    Install, then type `/pets` in the Codex CLI and choose `clippy-pet`. Pets render in terminals with image support (iTerm2 3.6+, Kitty, or Sixel-capable terminals).

=== "ChatGPT on the web"

    Web pets are uploaded, not installed, and the uploader takes the older v1 sheet. Grab `spritesheet-v1.webp` from the [latest release](https://github.com/adammatthewsteinberger/clippy-pet/releases/latest) and upload it under **Settings → Personalization → Pet**.

[Full selection guide :material-arrow-right:](get-started/select.md){ .md-button }

## Honesty corner

Clippy Pet is not made by, endorsed by, or affiliated with Microsoft or OpenAI. "Clippy" and "Clippit" may be Microsoft trademarks; the paperclip artwork here is original and the [notice](project/license.md) travels with every artifact. The whole project is one JSON file and one image, plus a shell script that copies them. Nothing runs in the background, nothing phones home, and this site uses cookie-free analytics only if the maintainer turns them on. If any page says a package manager is "planned", that means it isn't published yet. We'd rather tell you than sell you.

<div class="cp-bubble">It looks like you've read to the bottom of a landing page. Would you like to <a href="get-started/install/">install a paperclip</a>, <a href="https://github.com/adammatthewsteinberger/clippy-pet">star the repo</a>, or <a href="community/show-and-tell/">show us your remix</a>?</div>
