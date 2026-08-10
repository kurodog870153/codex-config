---
name: develop-marketing-copy
description: Develop marketing copy through an interactive discussion, direction review, drafting, revision, and explicit approval. Use when a user wants to brainstorm, write, refine, localize, or revise campaign copy without immediately generating a final answer or image.
---

# Develop Marketing Copy

Develop copy collaboratively. Do not jump from an incomplete brief to final copy.

## Operating rules

1. Use Traditional Chinese for interaction and deliverables unless the user requests another language.
2. Ask one necessary question at a time. When choices are useful, provide numbered options and mark the recommendation.
3. Separate exploration, draft, and approved states. Never describe unapproved text as final.
4. Do not create or modify files until the user explicitly approves the exact write operation.
5. Preserve approved wording. If a later constraint requires a wording change, explain the conflict and request approval.
6. Do not invent or strengthen prices, availability, performance, statistics, comparisons, testimonials, endorsements, certifications, guarantees, or legal or medical claims. Use only facts supplied by the user or supported by approved profile evidence with its source and approval or validity information; treat unsupported claims as blocking unresolved items.

## Resolve project and brand context

1. Resolve the Git root with `git rev-parse --show-toplevel`.
2. Stop and explain if the current directory is not inside a Git repository.
3. Require `brand-id` and `campaign-id` to use lowercase kebab-case. Reserve `brand-neutral` for profile-free work and never treat it as a profile-backed brand.
4. If the user names a brand other than `brand-neutral`, read `<git-root>/marketing/brands/<brand-id>/profile.md` when it exists.
5. If the named profile is missing, ask whether to use `$manage-marketing-brand` or switch to `brand-neutral`; never continue under a named brand without its profile.
6. If no brand is named, list discovered profiles when possible and ask the user to select one or choose brand-neutral mode. In brand-neutral mode, use `brand-id: brand-neutral`, do not load a profile, and record `source_profile: null` in the approved-copy handoff.
7. Treat the current task brief as the most specific context. When it conflicts with a required or forbidden brand rule, identify the conflict and obtain an explicit decision.

## Develop the copy

1. Establish the product or offer, audience, objective, channel, desired action, constraints, and success criteria.
2. Summarize the agreed brief before ideation.
3. Propose a small set of distinct directions with a rationale for each. Do not write full production copy yet.
4. Ask the user to select, combine, or revise a direction.
5. Draft copy for the selected direction and label it as a draft.
6. Revise through feedback while tracking unresolved decisions.
7. Present an approval candidate with its channel, headline, body, CTA, required text, and character constraints.
8. Ask for explicit approval. If later edits are requested, return the copy to draft state and obtain renewed approval before updating the current campaign package.

## Save approved output

1. Save only after explicit approval.
2. When invoked by `$run-marketing-creative` in deferred-save mode, do not create or modify campaign files; return the approved handoff so the coordinating skill can save the complete copy-and-image campaign package.
3. When used independently, read `../run-marketing-creative/references/campaign-output.md`, relative to this skill directory, and apply its `copy-only` mode.
4. Before writing, show the exact destination, files, updates, and risks, then obtain confirmation.

## Handoff

1. Immediately before returning approved copy, read `../run-marketing-creative/references/marketing-handoffs.md`, relative to this skill directory, and create an `approved-copy` handoff.
2. In deferred-save mode, keep the handoff's campaign-output status pending and do not create or modify campaign files.
3. When image creation is requested, pass this handoff unchanged to `$create-marketing-image`.
