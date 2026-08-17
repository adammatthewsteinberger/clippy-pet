---
title: The paperclip story
description: A short, sourced history of the Office Assistant paperclip, from Office 97 to the nostalgia comeback, and why an unofficial pet exists in 2026.
---

# The paperclip story

<div class="cp-bubble">It looks like you're writing a letter. Would you like help? (Every history of this character has to start there. Rules.)</div>

!!! warning "Unofficial. Really."

    This page describes Microsoft's historical Office Assistant for context. Clippy Pet is not made, endorsed, or sponsored by Microsoft. "Clippy", "Clippit", "Office", and "Microsoft" may be trademarks of Microsoft Corporation. The artwork in this project is original, and the [notice](../project/license.md) travels with every artifact.

## 1996: an animated paperclip walks into Office 97

Microsoft Office 97 shipped in November 1996 with the **Office Assistant**, an animated character that watched what you typed and offered help. The default character was a paperclip with expressive eyes and eyebrows, officially named **Clippit** and universally called **Clippy**. It was designed by illustrator **Kevan J. Atteberry**, one of several characters (a cat, a dog, a robot, a bouncing dot, Einstein-esque genius…) users could choose.[^wiki]

The technology behind it descended from Microsoft Bob and from Stanford research by Clifford Nass and Byron Reeves on people treating computers as social actors: the idea being that a character with a face would make help feel friendlier.[^wiki] The most famous line it ever produced was, of course:

> It looks like you're writing a letter. Would you like help?

## 2001–2007: turned off, then removed

By Office XP (2001), the Assistant was **off by default**, and Microsoft's own marketing leaned into the joke, with a "Clippy is unemployed" campaign voiced by comedian Gilbert Gottfried.[^wiki] Office 2007 removed the Office Assistant entirely.[^wiki] For a decade the paperclip lived on mainly as the canonical example of a well-meaning interface that interrupted too much.

## 2021 onward: the comeback nobody planned

Then it turned. In November 2021 Microsoft's Windows 11 emoji refresh redrew the 📎 paperclip emoji as Clippy.[^wiki] Clippy stickers appeared in Microsoft Teams. In 2025 the Copilot app's animated character "Mico" gained an Easter egg that transforms into a Clippy lookalike after enough clicks, and press coverage in August 2025 noted a wave of people swapping their profile pictures to Clippy as a small protest gesture about how AI assistants behave.[^recent] A character designed to be helpful, retired for being annoying, came back as shorthand for *an assistant with a personality that stays out of your way until you ask*.

Which is exactly the brief for a coding-tool pet.

## 2026: why an unofficial pet

OpenAI's ChatGPT desktop app and Codex CLI grew a **pets** feature: small animated companions that idle while you work, run while the agent runs, and wince when a build fails. The pets are data (a manifest and a spritesheet) placed in a directory, which means anyone can make one.

A paperclip felt right for three reasons:

1. **The metaphor fits.** An AI coding agent is the help-that-watches-you-type idea, thirty years later and actually useful. Putting a paperclip next to it is affectionate and a little self-aware.
2. **The silhouette works small.** Two eyes and a wire loop read at 64 pixels where most characters turn to mush. See [design notes](design.md).
3. **It's fun to do properly.** Nine animations, sixteen look directions, a validator, and blind QA on the eye directions is more rigour than a paperclip strictly deserves. That's rather the point.

What this project deliberately isn't: a Microsoft product, an OpenAI product, a claim on the name, or an attempt to trade on either. It's an MIT-licensed spritesheet, a shell script, and a disclaimer.

[^wiki]: Wikipedia, [Office Assistant](https://en.wikipedia.org/wiki/Office_Assistant), consulted August 2026, and sources cited there.
[^recent]: Coverage of Microsoft's 2025 Copilot "Mico" character and its Clippy Easter egg, and of the August 2025 profile-picture protest, from mainstream technology press in October and August 2025 respectively; the Wikipedia article above keeps an up-to-date list of citations.

[Design notes :material-arrow-right:](design.md){ .md-button }
