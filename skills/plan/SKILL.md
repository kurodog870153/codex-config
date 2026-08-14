---
name: plan
description: Load and layer hierarchical planning instructions from user-level and project-level plan AGENTS.md files. Use when the user explicitly invokes $plan with optional plan names, or implicitly when a request involves creating, revising, reviewing, or executing a plan. Before an implicit invocation, propose the relevant plan hierarchy and obtain user confirmation.
---

# Plan

Load selected planning instructions and follow them while completing the user's task.

## Load hierarchical work instructions

1. Read `../shared/work/hierarchical-instructions.md`, relative to this skill directory.
2. Apply it with this configuration:
   1. `command`: `plan`
   2. `work-directory`: `plan`
   3. `instruction-singular`: `plan`
   4. `instruction-plural`: `plans`
   5. `implicit-source`: the user's task

## Complete the request

1. Perform the user's requested task under the loaded instructions.
2. Loading plan instructions alone does not create a plan document. Create or modify files only when the user's request and applicable authorization permit it.
