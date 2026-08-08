---
name: run-marketing-creative
description: Coordinate an end-to-end marketing creative workflow from brand selection and interactive copy development through copy approval, image direction, image generation, and immutable versioned output. Use when a user wants both marketing copy and matching campaign images in one guided process.
---

# Run Marketing Creative

Coordinate the specialized marketing skills without duplicating their domain workflows.

## Operating rules

1. Use Traditional Chinese for interaction and deliverables unless the user requests another language.
2. Ask one necessary question at a time. When choices are useful, provide numbered options and mark the recommendation.
3. Treat copy approval and visual-direction approval as separate gates.
4. Do not start image generation before the copy is explicitly approved.
5. Do not create files until all artifacts for the intended snapshot are approved and the exact write operation is confirmed.

## Coordinate the workflow

1. Resolve the Git root with `git rev-parse --show-toplevel` and stop if it is unavailable.
2. Establish lowercase kebab-case `brand-id` and `campaign-id` values.
3. Locate `<git-root>/marketing/brands/<brand-id>/profile.md`.
4. If the profile is missing or needs revision, use `$manage-marketing-brand` and wait for its completion before continuing.
5. Use `$develop-marketing-copy` to establish the brief, explore directions, draft, revise, and obtain explicit copy approval.
6. Preserve the approved copy handoff exactly.
7. Use `$create-marketing-image` to discuss visual directions, approve a generation specification, generate variants, review them, and obtain explicit image approval.
8. If either specialized skill is unavailable, stop and identify the missing skill rather than recreating its workflow.

## Create an approved snapshot

1. Use `<git-root>/marketing/outputs/<brand-id>/<YYYY-MM-DD>-<campaign-id>/vNN/`.
2. Use the user's local date when creating the campaign directory and retain that directory for later versions.
3. Select the next unused version beginning with `v01`; never overwrite, rename, or delete an existing version.
4. For `v02` and later, create a complete snapshot by copying the previous approved snapshot and replacing only newly approved artifacts.
5. Include `manifest.yaml`, `creative-brief.md`, `copy/`, `image-prompts/`, and `images/`.
6. Name copy files `copy/<channel>.md`.
7. Name prompt files `image-prompts/<channel>-<format>.md`.
8. Name image variants `images/<channel>-<format>-NN.<original-extension>` with zero-padded variant numbers.
9. Preserve the image generator's original file format and prefer PNG when a format choice is available.
10. Show the exact files, copy-forward operations, and risks, then obtain explicit confirmation before writing.

## Manifest contract

Use this shape and add only fields needed by the actual campaign:

```yaml
brand_id: example-brand
campaign_id: summer-sale
campaign_date: YYYY-MM-DD
version: v01
previous_version: null
status: approved
created_at: YYYY-MM-DDTHH:MM:SSZ
source_profile: marketing/brands/example-brand/profile.md
channels:
  - instagram
artifacts:
  creative_brief: creative-brief.md
  copy:
    - copy/instagram.md
  image_prompts:
    - image-prompts/instagram-square.md
  images:
    - images/instagram-square-01.png
```

## Completion report

1. Report the selected brand, campaign, approvals, saved version, artifact paths, image formats, and unresolved risks.
2. Distinguish generated artifacts from planned or unavailable artifacts.
