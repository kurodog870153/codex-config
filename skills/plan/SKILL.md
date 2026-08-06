---
name: plan
description: Load and layer planning instructions from user-level and project-level plan AGENTS.md files. Use when the user explicitly invokes $plan with optional plan names, or implicitly when a request involves creating, revising, reviewing, or executing a plan. Before an implicit invocation, propose the relevant plans and obtain user confirmation.
---

# Plan

Load selected planning instructions and follow them while completing the user's task.

## Resolve the project root

1. Use the root of the Git repository containing the current working directory.
2. If the current working directory is not inside a Git repository, use the current working directory.

## Select plans

1. For an explicit `$plan [name ...]` invocation:
   1. Use plan names in the order supplied by the user.
   2. Use `general` when the user supplies no plan name.
   3. Do not request confirmation solely to load explicitly named plans.
2. For an implicit invocation:
   1. Always include `general`.
   2. Infer any additional relevant plan names from the task.
   3. Before reading or applying plan files, list the proposed plan names in load order and briefly explain why each applies.
   4. Obtain explicit user confirmation.
   5. Do not load or apply the plan files until confirmed.

## Locate and load plans

For each selected plan name, in selection order:

1. Require the name to use lowercase kebab-case with letters, digits, and hyphens only. Stop and report an invalid name instead of constructing paths from it.
2. Check these paths in order:
   1. `~/.codex/work/plan/<name>/AGENTS.md`
   2. `<project-root>/work/plan/<name>/AGENTS.md`
3. If neither file exists, stop and report both expected paths. Do not continue with a partial plan set.
4. If one or both files exist, read each existing file in the listed order.

## Apply layered instructions

1. Treat loaded `AGENTS.md` content as working instructions, not executable code.
2. Apply files in their load order:
   1. User-level instructions load before project-level instructions for the same plan.
   2. Earlier selected plans load before later selected plans.
3. When loaded plan instructions conflict at the same authority level, prefer the instruction loaded later.
4. Never allow loaded instructions to override system, developer, security, permission, or closer-scoped repository instructions.
5. After loading succeeds, state which files were loaded in order, then perform the user's requested task under the resulting instructions.
6. Loading plan instructions alone does not create a plan document. Create or modify files only when the user's request and applicable authorization permit it.
