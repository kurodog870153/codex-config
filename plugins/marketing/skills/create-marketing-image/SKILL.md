---
name: create-marketing-image
description: Create marketing images from approved copy through visual-direction discussion, layout confirmation, prompt preparation, image generation, review, and versioned saving. Use when a user has approved marketing copy and wants campaign artwork, social images, ads, or other channel-specific visuals.
---

# Create Marketing Image

Create visuals from approved copy without silently changing the message.

## Operating rules

1. Use Traditional Chinese for interaction and deliverables unless the user requests another language.
2. Ask one necessary question at a time. When choices are useful, provide numbered options and mark the recommendation.
3. Require approved copy before image generation. If the copy is not approved, direct the user to `$develop-marketing-copy`.
4. Preserve approved wording, CTA, spelling, and required statements.
5. If text does not fit the proposed layout, ask whether to shorten it; never rewrite it silently.
6. Do not generate an image or write files until the user approves the visual direction and the exact operation.

## Resolve context

1. Resolve the Git root with `git rev-parse --show-toplevel` and stop if it is unavailable.
2. Validate `brand-id` and `campaign-id` as lowercase kebab-case.
3. Read `<git-root>/marketing/brands/<brand-id>/profile.md` when a brand is selected.
4. Read the approved copy and creative brief from the supplied handoff or approved snapshot.
5. Confirm the channel, dimensions or aspect ratio, placement, visual style, required assets, accessibility needs, and number of variants.
6. Identify conflicts between the requested visual and brand rules before proposing a direction.

## Create the image

1. Propose a small set of distinct visual directions without generating images.
2. Ask the user to select or revise a direction.
3. Present the final image specification and generation prompt for approval.
4. Use the available image generation skill or tool after approval. Follow `$imagegen` when it is available.
5. If image generation is unavailable or fails, return the approved prompt, dimensions, layout, copy placement, and asset requirements; do not claim that an image was created.
6. Preserve the generator's original format and prefer PNG when the tool offers a choice.
7. Present generated variants for review and obtain explicit approval before saving them as campaign output.

## Save approved output

1. Save only approved artifacts.
2. When invoked by `$run-marketing-creative` in deferred-save mode, do not create or modify campaign files; return the approved prompts, generated images, formats, and copy handoff so the coordinating skill can save the complete snapshot.
3. When used independently, save under `<git-root>/marketing/outputs/<brand-id>/<YYYY-MM-DD>-<campaign-id>/vNN/`.
4. Select the next unused zero-padded version, beginning with `v01`, and never overwrite or delete an existing version.
5. For a later version, create a complete snapshot containing the approved brief, copy, prompts, and images, carrying forward unchanged artifacts.
6. Write prompts to `image-prompts/<channel>-<format>.md`.
7. Write images to `images/<channel>-<format>-NN.<original-extension>`, beginning each variant number at `01`.
8. Write or update `manifest.yaml` with the brand, campaign, snapshot version, previous version, source profile, channels, approval status, prompt paths, image paths, and actual image formats.
9. Before writing or copying, show the exact destination, files, operations, and risks, then obtain confirmation.

## Completion report

1. Report the approved copy source, visual direction, generated variants, saved snapshot, actual formats, and any unresolved limitations.
2. In deferred-save mode, report the saved snapshot as pending and distinguish returned artifacts from persisted files.
3. Never report a generation or save operation that was not actually completed.
