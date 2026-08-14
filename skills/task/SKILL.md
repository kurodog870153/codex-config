---
name: task
description: Load and layer hierarchical task-planning instructions from user-level and project-level task AGENTS.md files. Use when the user explicitly invokes $task with optional task-plan names, or implicitly when a request involves creating, revising, reviewing, or maintaining task documents. Before an implicit invocation, propose the relevant task-plan hierarchy and obtain user confirmation.
---

# Task

Load selected task-planning instructions and follow them while completing the user's request.

## Load hierarchical work instructions

1. Read `../shared/work/hierarchical-instructions.md`, relative to this skill directory.
2. Apply it with this configuration:
   1. `command`: `task`
   2. `work-directory`: `task`
   3. `instruction-singular`: `task plan`
   4. `instruction-plural`: `task plans`
   5. `implicit-source`: the user's request

## Complete the request

1. Perform the user's requested task under the loaded instructions.
2. Loading task-planning instructions alone does not create or modify a task document. Create or modify files only when the user's request and applicable authorization permit it.
3. Do not execute tasks merely because task-planning instructions or a task document were loaded. Execute a task only when the user explicitly requests execution and grants any required authorization.
