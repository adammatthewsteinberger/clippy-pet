---
title: Security
description: How to report a security vulnerability in Clippy Pet privately, and what to expect.
---

<div class="cp-bubble">It looks like you found something serious. Thank you. Please don't put it in a public issue; use the private route below.</div>

--8<-- "SECURITY.md"

## Scope notes

Clippy Pet's attack surface is deliberately tiny: a manifest, an image, a POSIX shell installer, and CI. Things that would count as security issues here include the installer writing outside its documented locations, checksum or signature verification being bypassable, the release workflow being able to publish unsigned artifacts as signed, or a malicious `spritesheetPath`. Things that aren't: the ChatGPT desktop app or Codex CLI's own behaviour (report those to OpenAI), and Gatekeeper warnings on unsigned builds (documented on the [macOS](../packages/macos.md) page).
