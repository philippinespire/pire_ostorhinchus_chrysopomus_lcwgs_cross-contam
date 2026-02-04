# TODO 1 Results

Outputs from admixture summarization using continuous metrics.
- [admixture_long.csv](admixture_long.csv): long-format admixture table with one row per sample and cluster.
- [admixture_metrics.csv](admixture_metrics.csv): per-sample metrics including `max_prop`, `admixedness`, entropy, and effective clusters.
- [admixture_summary.csv](admixture_summary.csv): wide-format K2–K4 probabilities joined to summary metrics (K1 merged into K2).
- [admixture_qc.csv](admixture_qc.csv): QC checks for cluster counts and probability sums.

Admixedness Indices
- [Generation of Indices](https://chatgpt.com/share/6983496c-227c-800f-b8bc-267996942f75)
- For downstream analyses, the metric used is Amax​=1−max(p1​,p2​,p3​,p4​)
