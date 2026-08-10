---
name: create-marketing-image
description: Create marketing images from approved copy through visual-direction discussion, layout confirmation, prompt preparation, image generation, review, and approved campaign saving. Use when a user has approved marketing copy and wants campaign artwork, social images, ads, or other channel-specific visuals.
---

# Create Marketing Image

Create visuals from approved copy without silently changing the message.

## Operating rules

1. Use Traditional Chinese for interaction and deliverables unless the user requests another language.
2. Ask one necessary question at a time. When choices are useful, provide numbered options and mark the recommendation.
3. Require approved copy before image generation. If the copy is not approved, direct the user to `$develop-marketing-copy`.
4. Preserve approved wording, CTA, spelling, and required statements.
5. If approved text does not fit the proposed layout, do not shorten it in this skill. Return to `$develop-marketing-copy` for revision and renewed approval, then resume only with the updated approved handoff. If that skill is unavailable, stop and report the fit constraint.
6. Do not generate an image or write files until the user approves the visual direction and the exact operation.
7. Do not visually imply unsupported outcomes, endorsements, certifications, product attributes, comparisons, or before-and-after results. Use only the approved copy handoff and approved profile evidence; treat anything unsupported as a blocking unresolved item before proposing or generating a visual.

## Resolve context

1. Resolve the Git root with `git rev-parse --show-toplevel` and stop if it is unavailable.
2. Validate `brand-id` and `campaign-id` as lowercase kebab-case. Treat `brand-neutral` as the reserved profile-free brand ID.
3. For `brand-neutral`, skip profile lookup and preserve `source_profile: null` in the approved-copy handoff. Otherwise, require and read `<git-root>/marketing/brands/<brand-id>/profile.md`; stop if it is missing or if the approved-copy handoff or saved `approved-copy.yaml` names another profile.
4. Read the approved copy and creative brief from the supplied handoff or approved campaign package.
5. When accepting a handoff, read `../run-marketing-creative/references/marketing-handoffs.md`, relative to this skill directory, and validate it as `approved-copy`. Stop if it is unapproved, incomplete, modified, or has blocking unresolved items.
6. Confirm the channel, dimensions or aspect ratio, placement, visual style, required assets, accessibility needs, and number of variants.
7. Identify conflicts between the requested visual and brand rules before proposing a direction.

## Create the image

1. Propose a small set of distinct visual directions without generating images.
2. Ask the user to select or revise a direction.
3. Present the final image specification and generation prompt for approval.
4. Use the available image generation skill or tool after approval. Follow `$imagegen` when it is available.
5. If image generation is unavailable or fails, return the approved prompt, dimensions, layout, copy placement, and asset requirements; do not claim that an image was created.
6. Preserve the generator's original format and prefer PNG when the tool offers a choice.
7. Immediately after generation, read `../run-marketing-creative/references/image-quality-checks.md`, relative to this skill directory, and validate every variant before presenting it for approval.
8. Do not present a failed or unverified variant as approvable. If no variant passes, stop and report the failed checks before asking whether to revise the direction or prompt.
9. Present each passing variant with its validation record and alt text, then obtain explicit approval before saving or returning it in an `approved-image` handoff.

## Save approved output

1. Save only approved artifacts.
2. When invoked by `$run-marketing-creative` in deferred-save mode, do not create or modify campaign files; return an `approved-image` handoff conforming to the contract already loaded while accepting the approved-copy handoff, so the coordinating skill can save the complete campaign package.
3. When used independently, read `../run-marketing-creative/references/campaign-output.md`, relative to this skill directory, and apply its `image-complete` mode.
4. Before writing or copying, show the exact destination, files, operations, and risks, then obtain confirmation.

## Completion report

1. Report the approved copy source, visual direction, generated variants, saved campaign package, actual formats, and any unresolved limitations.
2. In deferred-save mode, report campaign output as pending and distinguish returned artifacts from persisted files.
3. Never report a generation or save operation that was not actually completed.
