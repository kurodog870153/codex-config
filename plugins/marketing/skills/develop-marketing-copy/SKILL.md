---
name: develop-marketing-copy
description: Develop marketing copy through an interactive discussion, direction review, drafting, revision, and explicit approval. Use when a user wants to brainstorm, write, refine, localize, or version campaign copy without immediately generating a final answer or image.
---

# Develop Marketing Copy

Develop copy collaboratively. Do not jump from an incomplete brief to final copy.

## Operating rules

1. Use Traditional Chinese for interaction and deliverables unless the user requests another language.
2. Ask one necessary question at a time. When choices are useful, provide numbered options and mark the recommendation.
3. Separate exploration, draft, and approved states. Never describe unapproved text as final.
4. Do not create or modify files until the user explicitly approves the exact write operation.
5. Preserve approved wording. If a later constraint requires a wording change, explain the conflict and request approval.

## Resolve project and brand context

1. Resolve the Git root with `git rev-parse --show-toplevel`.
2. Stop and explain if the current directory is not inside a Git repository.
3. Require `brand-id` and `campaign-id` to use lowercase kebab-case.
4. If the user names a brand, read `<git-root>/marketing/brands/<brand-id>/profile.md` when it exists.
5. If the named profile is missing, ask whether to use `$manage-marketing-brand` or continue without a profile.
6. If no brand is named, list discovered profiles when possible and ask the user to select one or choose brand-neutral mode.
7. Treat the current task brief as the most specific context. When it conflicts with a required or forbidden brand rule, identify the conflict and obtain an explicit decision.

## Develop the copy

1. Establish the product or offer, audience, objective, channel, desired action, constraints, and success criteria.
2. Summarize the agreed brief before ideation.
3. Propose a small set of distinct directions with a rationale for each. Do not write full production copy yet.
4. Ask the user to select, combine, or revise a direction.
5. Draft copy for the selected direction and label it as a draft.
6. Revise through feedback while tracking unresolved decisions.
7. Present an approval candidate with its channel, headline, body, CTA, required text, and character constraints.
8. Ask for explicit approval. Treat later edits as a new approved version rather than overwriting an earlier saved version.

## Save approved output

1. Save only after explicit approval.
2. Use `<git-root>/marketing/outputs/<brand-id>/<YYYY-MM-DD>-<campaign-id>/vNN/`.
3. Use the user's local date for a new campaign directory and retain that directory for later versions.
4. Select the next unused zero-padded version, beginning with `v01`.
5. Never overwrite or delete an existing version.
6. For `v02` and later, create a complete snapshot by carrying forward unchanged approved artifacts and replacing only approved changes.
7. Write `creative-brief.md`, `copy/<channel>.md`, and `manifest.yaml`. Omit unavailable image artifacts in a copy-only snapshot.
8. Record the brand, campaign, version, creation timestamp, previous version, channels, source profile, approval status, and artifact paths in `manifest.yaml`.
9. Before writing, show the exact destination, files, copy-forward operation, and risks, then obtain confirmation.

## Handoff

1. Return the approved copy with the brand, campaign, channel, CTA, mandatory text, forbidden changes, and version path.
2. When image creation is requested, pass this handoff unchanged to `$create-marketing-image`.
