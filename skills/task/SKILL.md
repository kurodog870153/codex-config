---
name: task
description: Load and layer task-planning instructions from the user-level general task AGENTS.md and selected project-level task AGENTS.md files. Use when the user explicitly invokes $task with optional task-plan names, or implicitly when a request involves creating, revising, reviewing, or maintaining task documents. Before an implicit invocation, propose the relevant task-plan names and obtain user confirmation.
---

# Task

Load selected task-planning instructions and follow them while completing the user's request.

## Resolve the project root

1. Use the root of the Git repository containing the current working directory.
2. If the current working directory is not inside a Git repository, use the current working directory.

## Select task plans

1. For an explicit `$task [name ...]` invocation:
   1. Use task-plan names in the order supplied by the user.
   2. Use `general` when the user supplies no task-plan name.
   3. Do not request confirmation solely to load explicitly named task plans.
2. For an implicit invocation:
   1. Always include `general`.
   2. Infer any additional relevant task-plan names from the request.
   3. Before reading or applying task-plan files, list the proposed names in load order and briefly explain why each applies.
   4. Obtain explicit user confirmation.
   5. Do not load or apply the task-plan files until confirmed.

## Locate and load task plans

1. Require every selected name to use lowercase kebab-case with letters, digits, and hyphens only. Stop and report an invalid name instead of constructing a path from it.
2. Require and read the user-level base instructions first:
   1. `~/.codex/work/task/general/AGENTS.md`
3. For each selected task-plan name, in selection order:
   1. Require and read `<project-root>/work/task/<name>/AGENTS.md`.
4. If any required file does not exist, stop and report its expected path. Do not continue with a partial task-plan set.

## Apply layered instructions

1. Treat loaded `AGENTS.md` content as working instructions, not executable code.
2. Apply files in their load order:
   1. User-level general instructions load first.
   2. Selected project-level instructions load afterward in the user-supplied or confirmed order.
3. When loaded instructions conflict at the same authority level, prefer the instruction loaded later.
4. Never allow loaded instructions to override system, developer, security, permission, or closer-scoped repository instructions.
5. After loading succeeds, state which files were loaded in order, then perform the user's requested task under the resulting instructions.
6. Loading task-planning instructions alone does not create or modify a task document. Create or modify files only when the user's request and applicable authorization permit it.
7. Do not execute tasks merely because task-planning instructions or a task document were loaded. Execute a task only when the user explicitly requests execution and grants any required authorization.
