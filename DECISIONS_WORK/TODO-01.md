# TODO-01 Decisions

## 2026-02-03 16:30 CST
Decision: Use continuous cluster probabilities from `Cluster` and `Prop` without a hard pure/admixed threshold.
Rationale: Avoids arbitrary cutoffs and preserves the full admixture signal for downstream adjacency/permutation analyses.
Options considered: Define a binary pure/admixed cutoff; create multiple threshold tiers; use continuous probabilities.
Implications: Analyses will use continuous metrics (e.g., max cluster probability, 1 - max probability, entropy) rather than categorical labels, with optional sensitivity checks later.
Notes: This supports TODO #1 and informs how we build summaries used in later steps.
Links: TODO #1 in `TODO.md`.
---
