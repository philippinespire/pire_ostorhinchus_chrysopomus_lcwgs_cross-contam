# TODO-01 Decisions

## 2026-02-03 21:26 CST
Decision: Merge K1 into K2 (store combined value in K2 and remove K1).
Rationale: K1 and K2 represent the same genetic group, so downstream summaries should use K2, K3, and K4 only.
Options considered: Keep K1 and K2 separate; merge K1 into K2; relabel both as a new combined cluster.
Implications: `admixture_summary.csv` and downstream metrics will include K2–K4 only, with K2 = K1 + K2.
Notes: Subsequent scripts should not reference K1.
Links: TODO #1 in `TODO.md`.
---

## 2026-02-03 16:30 CST
Decision: Use continuous cluster probabilities from `Cluster` and `Prop` without a hard pure/admixed threshold.
Rationale: Avoids arbitrary cutoffs and preserves the full admixture signal for downstream adjacency/permutation analyses.
Options considered: Define a binary pure/admixed cutoff; create multiple threshold tiers; use continuous probabilities.
Implications: Analyses will use continuous metrics (e.g., max cluster probability, 1 - max probability, entropy) rather than categorical labels, with optional sensitivity checks later.
Notes: This supports TODO #1 and informs how we build summaries used in later steps.
Links: TODO #1 in `TODO.md`.
---
