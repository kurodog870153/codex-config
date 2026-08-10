---
name: run-marketing-creative
description: Coordinate an end-to-end marketing creative workflow from brand selection and interactive copy development through copy approval, image direction, image generation, and a current approved campaign package with Git-ignored generated images. Use when a user wants both marketing copy and matching campaign images in one guided process.
---

# Run Marketing Creative

Coordinate the specialized marketing skills without duplicating their domain workflows.

## Operating rules

1. Use Traditional Chinese for interaction and deliverables unless the user requests another language.
2. Ask one necessary question at a time. When choices are useful, provide numbered options and mark the recommendation.
3. Treat copy approval and visual-direction approval as separate gates.
4. Do not start image generation before the copy is explicitly approved.
5. Do not create or modify campaign files until all intended artifacts are approved and the exact write operation is confirmed. Treat brand-profile writes as separate operations governed by `$manage-marketing-brand`.
6. In this coordinated workflow, defer all campaign-output writes until both the copy and images are approved; the specialized skills must return handoffs without saving campaign files.

## Coordinate the workflow

1. Resolve the Git root with `git rev-parse --show-toplevel` and stop if it is unavailable.
2. Establish lowercase kebab-case `brand-id` and `campaign-id` values. Reserve `brand-neutral` for profile-free work.
3. For `brand-neutral`, skip profile lookup and management and preserve `source_profile: null` in every handoff and the saved `approved-copy.yaml`. Otherwise, locate `<git-root>/marketing/brands/<brand-id>/profile.md`.
4. If a required profile is missing or needs revision, use `$manage-marketing-brand` as a separate operation. Wait for its completion, report the result, and obtain confirmation before resuming this workflow.
5. Use `$develop-marketing-copy` in deferred-save mode to establish the brief, explore directions, draft, revise, obtain explicit copy approval, and return an approved handoff without writing campaign files.
6. Before accepting the first specialized handoff, read `references/marketing-handoffs.md`, relative to this skill directory, and use it to validate both handoff types.
7. Validate the result as `approved-copy`, report the handoff and unresolved items, then obtain explicit confirmation before starting the image stage.
8. Preserve the approved copy handoff exactly. Any new or revised copy approval invalidates all prior visual-direction and image approvals.
9. Use `$create-marketing-image` in deferred-save mode to discuss visual directions, approve a generation specification, generate variants, review them, obtain explicit image approval, and return an approved handoff without writing campaign files.
10. Validate the result as `approved-image`, report the handoff and unresolved items, then obtain explicit confirmation before saving the current campaign package.
11. If either specialized skill attempts an intermediate campaign write, stop before the write and restate that the coordinated workflow owns the final campaign package.
12. If either specialized skill is unavailable, stop and identify the missing skill rather than recreating its workflow.

## Save approved campaign output

1. Immediately before saving, read `references/campaign-output.md`, relative to this skill directory, and apply its `coordinated-complete` mode.
2. Show the exact files, updates, and risks, then obtain explicit confirmation before writing.

## Completion report

1. Report the selected brand, campaign, approvals, saved campaign path, artifact paths, image formats, and unresolved risks.
2. Distinguish generated artifacts from planned or unavailable artifacts.
