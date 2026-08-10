# Image Quality Checks

Read this reference immediately after image generation and before presenting variants for approval.

## Per-variant checks

1. Confirm that the artifact is accessible and decodes successfully; record its actual format and pixel dimensions.
2. Confirm that dimensions and aspect ratio match the approved specification.
3. When text is rendered in the image, compare every visible word, CTA, spelling, and required statement with the approved-copy handoff.
4. Confirm required assets, colors, typography direction, avoided visuals, and other applicable profile rules.
5. Inspect at actual resolution for legibility, contrast, safe margins, unintended cropping, malformed text, distorted subjects, duplicated elements, and other generation artifacts.
6. Confirm that the image does not imply an unsupported outcome, endorsement, certification, comparison, product attribute, or before-and-after result.
7. Write concise alt text that describes the meaningful content without repeating decorative detail or introducing unsupported claims.

## Result rules

1. Record each check as `passed` or `not-applicable`; include a reason for every `not-applicable` result.
2. Treat an unperformed, uncertain, or failed check as blocking. Do not present that variant as approvable or include it in an `approved-image` handoff.
3. If no variant passes, stop before approval, report the failed checks, and ask whether to revise the direction or prompt.
4. Preserve the validation record and alt text with every passing variant.
