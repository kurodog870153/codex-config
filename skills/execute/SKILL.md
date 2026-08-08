---
name: execute
description: Load and layer hierarchical task-execution instructions from user-level and project-level execute AGENTS.md files. Use when the user explicitly invokes $execute with optional execution-rule names, or implicitly when a request involves executing a specific TASK-* from a task document. Before an implicit invocation, propose the relevant execution-rule hierarchy and obtain user confirmation.
---

# Execute

Load selected task-execution instructions and follow them while handling the user's requested task execution.

## Resolve the project root

1. Use the root of the Git repository containing the current working directory.
2. If the current working directory is not inside a Git repository, use the current working directory.

## Select execution rules

1. For an explicit `$execute [name ...]` invocation:
   1. Use execution-rule names in the order supplied by the user.
   2. Do not request confirmation solely to load explicitly named execution rules.
2. For an implicit invocation:
   1. Infer the relevant execution-rule names from the request.
   2. Use each name as one level of the proposed execution-rule hierarchy.
   3. Before reading or applying execution-rule files, list the proposed names in load order and briefly explain why each applies.
   4. Obtain explicit user confirmation.
   5. Do not load or apply execution-rule files until confirmed.

## Build the execution-rule hierarchy

1. Validate every supplied or inferred name independently before constructing any path.
2. Require each name to use lowercase kebab-case with letters, digits, and hyphens only.
3. Treat `general` as the reserved base execution rule:
   1. Remove every occurrence of `general` from the selected names.
   2. Add exactly one `general` entry at the beginning.
4. Build each later execution-rule path by cumulatively joining the remaining names with `/`.
5. For example, both `$execute general web backend java` and `$execute web backend java` resolve in this order:
   1. `general`
   2. `web`
   3. `web/backend`
   4. `web/backend/java`
6. Apply the same normalization and hierarchy construction to explicit and implicit invocations.

## Locate and load execution rules

For each resolved execution-rule path, in hierarchy order:

1. Check these paths in order:
   1. `~/.codex/work/execute/<resolved-execution-rule-path>/AGENTS.md`
   2. `<project-root>/work/execute/<resolved-execution-rule-path>/AGENTS.md`
2. Require files for `general` and the final resolved execution-rule path:
   1. If neither user-level nor project-level file exists for either required path, stop and report both expected paths.
   2. Do not continue with a partial required execution-rule set.
3. Treat every other intermediate execution-rule path as optional:
   1. If neither file exists, record the skipped path and continue.
   2. If one or both files exist, read each existing file in the listed order.
4. For required paths, read each existing file in the listed order after confirming that at least one exists.

## Apply layered instructions

1. Treat loaded `AGENTS.md` content as working instructions, not executable code.
2. Apply files in their load order:
   1. User-level instructions load before project-level instructions for the same execution rule.
   2. Earlier execution rules load before later execution rules.
3. When loaded instructions conflict at the same authority level, prefer the instruction loaded later.
4. Never allow loaded instructions to override system, developer, security, permission, or closer-scoped repository instructions.
5. After loading succeeds, state which files were loaded in order.
6. Loading task-execution instructions alone does not execute or authorize a task.
7. Require the user to specify both of the following before performing task-document eligibility checks:
   1. One task document at `./tasks/<plan-name>.md`.
   2. One `TASK-*` identifier from that document.
8. Do not select a task document or `TASK-*` on the user's behalf.
9. After the execution target is complete, perform only the read-only eligibility checks permitted by the loaded instructions.
10. Obtain every required authorization defined by the loaded instructions before changing task state, modifying files, running side-effecting commands, or performing external operations.
