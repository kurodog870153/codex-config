---
name: manage-marketing-brand
description: Create and update project-local marketing brand profiles through an interactive, reviewable workflow using the plugin's reusable template. Use when a user needs to add, configure, inspect, or revise brand voice, audience, copy constraints, visual guidance, channel rules, or brand asset references for marketing skills.
---

# Manage Marketing Brand

Manage mutable brand data outside the plugin while keeping the reusable skills unchanged.

## Operating rules

1. Use Traditional Chinese for interaction and profile content unless the user requests another language.
2. Ask one necessary question at a time. When choices are useful, provide numbered options and mark the recommendation.
3. Never request, read into the profile, display, or store passwords, API keys, access tokens, private keys, or other secrets.
4. Do not create or update files until the user reviews the proposed content, exact paths, commands or operations, validation, and risks, then explicitly confirms.
5. Never delete, replace, or modify files in a brand's `assets/` directory unless the user separately requests and authorizes that exact action.
6. Record a factual marketing claim as approved evidence only when the user supplies its source and approval or validity information. Otherwise preserve it as unanswered and never promote it into an approved proof point.

## Resolve locations

1. Resolve the Git root with `git rev-parse --show-toplevel`.
2. Stop and explain if the current directory is not inside a Git repository.
3. Require `brand-id` to use lowercase kebab-case and reject the reserved `brand-neutral` ID.
4. Read the reusable template at `../../assets/templates/brand-profile.md`, relative to this skill directory.
5. Store the project profile at `<git-root>/marketing/brands/<brand-id>/profile.md`.
6. Reserve `<git-root>/marketing/brands/<brand-id>/assets/` for project-owned logos, product images, fonts, and visual references.
7. Before presenting a profile write and again immediately before applying it, run `git status --short -- <profile-path>`. If the target has staged, unstaged, untracked, or conflicted changes, stop and report the path; do not modify, stage, stash, revert, or merge it without a new explicit decision for those exact changes.

## Create a profile

1. Confirm that the target profile does not exist.
2. Gather the template fields interactively and distinguish required facts from optional guidance.
3. Preserve unknown values as clearly marked unanswered fields rather than inventing brand facts.
4. Present the completed profile and target paths for review.
5. After explicit approval, create the profile and empty asset directory without modifying unrelated files.
6. Validate the path, required headings, `brand-id`, and absence of obvious secret fields.

## Update a profile

1. Read the existing profile and preserve all unrelated content.
2. Gather the requested change interactively.
3. Present a concise diff and identify conflicts or information loss.
4. Obtain explicit approval for that exact diff.
5. Apply only the approved changes without touching brand assets.
6. Validate the resulting profile and report the changed path.

## Handoff

1. Return the `brand-id`, profile path, asset directory, configured channels, required copy rules, forbidden copy rules, and visual constraints.
2. Tell the calling marketing skill which fields remain unanswered.
3. Never claim that a profile was written or updated unless the operation actually completed.
