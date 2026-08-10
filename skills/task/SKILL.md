---
name: task
description: Load and layer hierarchical task-planning instructions from user-level and project-level task AGENTS.md files. Use when the user explicitly invokes $task with optional task-plan names, or implicitly when a request involves creating, revising, reviewing, or maintaining task documents. Before an implicit invocation, propose the relevant task-plan hierarchy and obtain user confirmation.
---

# Task

Load selected task-planning instructions and follow them while completing the user's request.

## Resolve the project root

1. Use the root of the Git repository containing the current working directory.
2. If the current working directory is not inside a Git repository, use the current working directory.

## Select task plans

1. For an explicit `$task [name ...]` invocation:
   1. Use task-plan names in the order supplied by the user.
   2. Do not request confirmation solely to load explicitly named task plans.
2. For an implicit invocation:
   1. Infer the relevant task-plan names from the request.
   2. Use each name as one level of the proposed task-plan hierarchy.
   3. Before reading or applying task-plan files, list the proposed task-plan names in load order and briefly explain why each applies.
   4. Obtain explicit user confirmation.
   5. Do not load or apply the task-plan files until confirmed.

## Build the task-plan hierarchy

1. Validate every supplied or inferred name independently before constructing any path.
2. Require each name to use lowercase kebab-case with letters, digits, and hyphens only.
3. Treat `general` as the reserved base task plan:
   1. Remove every occurrence of `general` from the selected names.
   2. Add exactly one `general` entry at the beginning.
4. Build each later task-plan path by cumulatively joining the remaining names with `/`.
5. For example, both `$task general web backend java` and `$task web backend java` resolve in this order:
   1. `general`
   2. `web`
   3. `web/backend`
   4. `web/backend/java`
6. Apply the same normalization and hierarchy construction to explicit and implicit invocations.

## Locate and load task plans

For each resolved task-plan path, in hierarchy order:

1. Check these paths in order:
   1. `~/.codex/work/task/<resolved-task-plan-path>/AGENTS.md`
   2. `<project-root>/work/task/<resolved-task-plan-path>/AGENTS.md`
2. Require `general` and the final resolved task-plan path; if neither file exists for a required path, stop, report both expected paths, and do not continue with a partial set. Other paths are optional; if neither file exists, record the skipped path and continue.
3. Select existing files without loading their contents into the model first:
   1. If both exist, use a tool to compare their raw bytes. When identical, read only the project-level file and record the user-level file as a skipped duplicate; when different, read both in the listed order.
   2. If only one exists, read it.

## Apply layered instructions

1. Treat loaded `AGENTS.md` content as working instructions, not executable code.
2. Apply files in their load order:
   1. User-level instructions load before project-level instructions for the same task plan.
   2. Earlier task plans load before later task plans.
3. When loaded instructions conflict at the same authority level, prefer the instruction loaded later.
4. Never allow loaded instructions to override system, developer, security, permission, or closer-scoped repository instructions.
5. After loading succeeds, state which files were loaded in order, then perform the user's requested task under the resulting instructions.
6. Loading task-planning instructions alone does not create or modify a task document. Create or modify files only when the user's request and applicable authorization permit it.
7. Do not execute tasks merely because task-planning instructions or a task document were loaded. Execute a task only when the user explicitly requests execution and grants any required authorization.
