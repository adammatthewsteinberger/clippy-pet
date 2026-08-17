---
date: 2026-08-17
authors: [adam]
categories: [Essays]
slug: why-a-paperclip-why-now
description: On building a deliberately old-fashioned character to a modern spec, and why the most-mocked assistant of the 1990s is the right mascot for an AI coding agent.
---

# Why a paperclip, why now

There's a version of this project that's a joke, and a version that's a craft exercise, and the honest answer is that it's both, in that order.

<!-- more -->

## The joke

In 1996 Microsoft shipped an animated paperclip that watched what you typed and offered help. It was retired in 2001 for being annoying and removed entirely in 2007. Then, over the last five years, it came back as an emoji, a sticker, an Easter egg, and a profile picture people put up to make a point about assistants that don't know when to stop.

In 2026 an AI coding agent watches what you type and offers help. Putting a paperclip next to it is affectionate and a little self-aware, and I don't think you need to explain that joke to anyone who was alive for both halves of it. Codex and the ChatGPT desktop app grew a "pets" feature (small animated companions that idle, run, and wince at build failures) and the pets are just files. Someone was going to make the paperclip. I wanted it to be made properly.

So I opened up my Research Assistant in Claude Code and got to work fast! My goal was to create a resurrection of Clippy from the 90s and bring it into the 21st century. ChatGPT offered the platform, I built the code.

## The craft exercise

"Properly" turned into a longer list than a paperclip strictly deserves:

- Nine animation states drawn to loop cleanly at whatever rate the host picks.
- Sixteen look directions, because a v2 pet's eyes follow your pointer, and a pupil two pixels off at 292.5° reads as "shifty".
- A silhouette that reads at 64 pixels on both light and dark backgrounds, which is why almost all the expression is in the eyes.
- A validator that checks the atlas cell by cell.
- Blind QA on the look directions: shuffle the frames, hide the labels, classify. Thirteen of sixteen came back clean; three shallow diagonals got warnings, and the warnings are published rather than tuned away.

That last part matters to me more than the paperclip does. I've spent a lot of time thinking about how engineers earn attention, and the conclusion I keep coming back to is that honesty outperforms polish over any timescale that matters. A QA page that shows only green ticks isn't evidence. A package matrix that lists commands which don't work yet isn't documentation. So this site has status chips that say *planned* on most of the package managers, and a receipts page that quotes the warnings verbatim.

The plan, the journey, the vibes. It's all part of the story that continues to warm the hearts of Clippy fans world wide.

## Why "unofficial" is on every page

Because it's true, and because saying it clearly is cheaper than implying otherwise. Microsoft's paperclip is theirs; the names may be trademarks; the artwork here is original and the notice ships in every tarball, package, and installer. OpenAI's pets format is theirs; this project follows it as a third party. Nobody endorsed anything. I'd rather tell you than sell you.

## What I hope happens

Someone installs it in one line and smiles when the paperclip winces at their failing test. Someone else forks the pipeline and hatches a pet that isn't a paperclip at all. A packager somewhere lands the row for their distro. And the three warning frames get a better eyebrow from someone with a steadier hand than mine.

Regardless of how this repository is used long term, I hope and pray that today is the day that Clippy lives on as the next Digital AI Assistant to break the internet. And more importantly, that Clippy remains tightly bound to the ever evolving mythos of human imagination that is the world wide web.

[Install it](../../get-started/install.md) · [Make your own](../../make/index.md) · [Show and tell](../../community/show-and-tell.md)
