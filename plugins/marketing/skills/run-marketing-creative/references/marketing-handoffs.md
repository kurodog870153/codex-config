# Marketing Handoff Contract

Read this reference only immediately before producing or accepting a marketing handoff.

## Common rules

1. Use `status: approved` only after explicit approval. Reject draft, incomplete, or modified handoffs.
2. Preserve approved copy values verbatim across handoffs. Never infer a missing value.
3. Record unknown non-blocking values under `unresolved`. Stop before downstream work when any unresolved item is blocking.
4. Use `source_profile: null` only for `brand-neutral`. Otherwise require `marketing/brands/<brand-id>/profile.md`, confirm that it exists under the Git root, and reject a missing or mismatched path.
5. In deferred-save mode, use `campaign_output.status: pending` and `campaign_output.path: null`; do not create or modify campaign files.
6. For any successful independent or coordinated save, derive each persisted handoff by changing only its top-level `campaign_output` to `status: saved` and the project-relative campaign-package path. For an approved-image handoff, also replace each variant's `artifact_reference` with its matching final project-relative generated-image path after a byte-identical save; keep the original in-memory handoff and its nested `copy_handoff` unchanged.
7. Any change to approved copy invalidates every visual-direction and image approval derived from it.
8. Each campaign and handoff covers one channel. Require every prompt and variant channel to equal the approved-copy `channel`; reject cross-channel handoffs.

## Approved-copy handoff

```yaml
handoff_type: approved-copy
status: approved
brand_id: example-brand
campaign_id: summer-sale
source_profile: marketing/brands/example-brand/profile.md
channel: instagram
brief:
  offer: Example offer
  audience: Example audience
  objective: Example objective
  desired_action: Example action
  success_criteria: Example criteria
copy:
  headline: Approved headline
  body: Approved body
  cta: Approved CTA
  required_text: []
constraints:
  character_limits: []
  forbidden_changes: []
approval:
  approved_at: YYYY-MM-DDTHH:MM:SSZ
campaign_output:
  status: pending
  path: null
unresolved: []
```

Require every top-level field. Keep `copy` values exact, and list rather than omit empty constraints.

## Approved-image handoff

```yaml
handoff_type: approved-image
status: approved
copy_handoff: <unchanged approved-copy handoff>
visual_direction: Approved direction
prompts:
  - channel: instagram
    format: square
    prompt: Approved generation prompt
variants:
  - channel: instagram
    format: square
    artifact_reference: <generated artifact or file path>
    actual_format: png
    dimensions: 1080x1080
    alt_text: Concise approved description
    validation:
      checked_at: YYYY-MM-DDTHH:MM:SSZ
      artifact_access: { status: passed, reason: null }
      dimensions_and_ratio: { status: passed, reason: null }
      copy_accuracy: { status: not-applicable, reason: No text is rendered }
      brand_compliance: { status: passed, reason: null }
      legibility_and_contrast: { status: passed, reason: null }
      safe_layout_and_integrity: { status: passed, reason: null }
      unsupported_implications: { status: passed, reason: null }
approval:
  approved_at: YYYY-MM-DDTHH:MM:SSZ
campaign_output:
  status: pending
  path: null
unresolved: []
```

Require every top-level field and at least one prompt and approved variant. Preserve the nested approved-copy handoff unchanged. Require an alt text and complete validation record for every variant. For each check, allow only `{ status: passed, reason: null }` or `{ status: not-applicable, reason: <non-empty reason> }`; reject failed, uncertain, or unperformed checks.
