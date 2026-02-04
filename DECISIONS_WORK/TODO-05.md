# TODO-05 Decisions

## 2026-02-03 18:10 CST
Decision: Use plate-neighbor adjacency metrics (mean/median absolute `admixedness` differences and dominant-cluster mismatch rate) with within-plate permutation baselines.
Rationale: Plate adjacency is spatial, so neighbor-based metrics directly test whether admixedness or cluster assignments are locally non-random without hard thresholds.
Options considered: Global plate clustering statistics; threshold-based adjacency; continuous adjacency with permutations.
Implications: Outputs include per-plate metrics and empirical p-values, plus diagnostics for missing or duplicate wells.
Notes: Adjacency uses 4-neighbor (up/down/left/right) wells on each plate.
Links: `PLANS/TODO-05.md`.
---
