---
name: execute
description: Load and layer hierarchical task-execution instructions from user-level and project-level execute AGENTS.md files. Use when the user explicitly invokes $execute with optional execution-rule names, or implicitly when a request involves executing a specific TASK-* from a task document. Before an implicit invocation, propose the relevant execution-rule hierarchy and obtain user confirmation.
---

# Execute

Load selected task-execution instructions and follow them while handling the user's requested task execution.

## Load hierarchical work instructions

1. Read `../shared/work/hierarchical-instructions.md`, relative to this skill directory.
2. Apply it with this configuration:
   1. `command`: `execute`
   2. `work-directory`: `execute`
   3. `instruction-singular`: `execution rule`
   4. `instruction-plural`: `execution rules`
   5. `implicit-source`: the user's request

## Execute the requested task

1. Loading task-execution instructions alone does not execute or authorize a task.
2. Require the user to specify both of the following before performing task-document eligibility checks:
   1. One task document, using the default path `./outputs/tasks/<requirement-id>.md` or another project-relative path explicitly specified and confirmed by the user when permitted by the applicable loaded instructions.
   2. One `TASK-*` identifier from that document.
3. If the Plan document, task document, or execution directory uses a non-default path, require the user to explicitly specify and confirm the requirement ID and all three actual project-relative paths before eligibility checks. Do not infer one path from another; locate the execution index and records below the specified execution directory according to the loaded instructions.
4. Do not select a task document or `TASK-*` on the user's behalf.
5. After the execution target is complete, perform only the read-only eligibility checks permitted by the loaded instructions.
6. Obtain every required authorization defined by the loaded instructions before changing task state, modifying files, running side-effecting commands, or performing external operations.
