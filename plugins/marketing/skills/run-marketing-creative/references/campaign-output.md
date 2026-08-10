# Campaign Output Contract

Read this reference only immediately before saving current approved campaign output.

## Modes

1. `copy-only`: Used by `$develop-marketing-copy` independently. Require the approved brief and copy; omit unavailable image artifacts.
2. `image-complete`: Used by `$create-marketing-image` independently. Require the approved brief, copy, prompts, and generated-image references.
3. `coordinated-complete`: Used by `$run-marketing-creative`. Require the approved brief, copy, prompts, and generated-image references; never save an intermediate copy-only package.

## Locations

1. Save the Git-tracked campaign package under `<git-root>/marketing/campaigns/<brand-id>/<campaign-id>/`.
2. Save generated images outside that package under `<git-root>/marketing/generated/<brand-id>/<campaign-id>/`.
3. For `brand-neutral`, use the normal locations and preserve `source_profile: null` in `approved-copy.yaml`.
4. Require lowercase kebab-case for `brand-id` and `campaign-id` and reject path separators or traversal segments.
5. Ensure `<git-root>/marketing/generated/.gitignore` matches the plugin-root-relative template at `assets/templates/generated-images.gitignore`. Include creating or correcting this file in the exact write operation shown for approval.
6. Before writing an image, verify with `git check-ignore` that its destination is ignored. Stop if the check fails or the destination would be tracked.

## Safe updates

1. Resolve every destination and confirm that the campaign package remains inside `<git-root>/marketing/campaigns/` and generated images remain inside `<git-root>/marketing/generated/`.
2. Before presenting a write operation and again immediately before applying it, run `git status --short -- <campaign-package> <generated-ignore-file>`. If either target has staged, unstaged, untracked, or conflicted changes, stop and report the paths; do not modify, stage, stash, revert, or merge them without a new explicit decision for those exact changes.
3. Show every file that will be created or modified, the operation on each file, and the risks before requesting confirmation.
4. Validate the approved content, manifest shape, paths, and mode completeness before modifying the campaign package.
5. Give each generated image a new unique `generation-id`. Stop on a filename collision; never overwrite, rename, or delete an existing generated image.
6. Write approved campaign artifacts only after confirmation and write `manifest.yaml` last. Treat the package as saved only after rereading the manifest, confirming `status: approved`, and verifying every indexed artifact.
7. If any write or validation fails, stop and report the completed operations and affected paths. Do not retry automatically, delete residual files, or claim that the campaign package was saved successfully.

## Artifact contract

1. Every campaign package contains `manifest.yaml`, `approved-copy.yaml`, `creative-brief.md`, and `copy/`.
2. In every mode, derive `approved-copy.yaml` from the approved-copy handoff as specified by `marketing-handoffs.md`, changing only `campaign_output` to `saved` and the project-relative package path.
3. When resuming from a campaign package, validate `approved-copy.yaml` against `marketing-handoffs.md` before treating its copy as approved; reject a missing, incomplete, modified, or mismatched handoff.
4. Write copy to `copy/<channel>.md`.
5. A complete image package also contains `approved-image.yaml` and `image-prompts/`; generated images are referenced from the ignored generated-image location and are never copied into the campaign package.
6. Derive `approved-image.yaml` from the approved-image handoff as specified by `marketing-handoffs.md`, changing its top-level `campaign_output` to `saved` and the project-relative package path, and each variant's `artifact_reference` to the matching final project-relative generated-image path after a byte-identical save; preserve every other value.
7. When resuming a complete image package, validate `approved-image.yaml` against `marketing-handoffs.md`, require its nested `copy_handoff` to match `approved-copy.yaml` except for the permitted `campaign_output` metadata difference, and require variant `artifact_reference` values to match `manifest.yaml` `generated_images.path` values one-to-one.
8. Write prompts to `image-prompts/<channel>-<format>.md`.
9. Write each generated image byte-for-byte without re-encoding or transformation as `<channel>-<format>-<generation-id>.<original-extension>`. The ID must be unique, lowercase, and filesystem-safe.
10. Preserve each image's original format and prefer PNG when the generator offers a format choice.
11. Keep only the currently approved generated-image references in `manifest.yaml` and mark each `availability: local-only`. Before using or reporting an image as available, confirm that its local file exists; otherwise report it as unavailable. Older generated files may remain locally for manual cleanup but are not active campaign artifacts.

## Manifest contract

Keep `manifest.yaml` as a minimal index of the current approved artifacts, using this shape:

```yaml
status: approved
artifacts:
  approved_copy: approved-copy.yaml
  approved_image: approved-image.yaml
  creative_brief: creative-brief.md
  copy: copy/instagram.md
  image_prompts:
    - image-prompts/instagram-square.md
  generated_images:
    - path: marketing/generated/example-brand/summer-sale/instagram-square-<generation-id>.png
      availability: local-only
```

For `copy-only`, omit `approved_image`, `image_prompts`, and `generated_images`.
