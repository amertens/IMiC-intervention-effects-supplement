# IMiC Intervention Effects — Online Supplement

Source for the **interactive online supplementary appendix** to:

> Dailey-Chwalibóg, Mertens et al. (2025). *Nutritional interventions' impacts on human milk: three trial analyses from low-resource settings.* International Milk Composition (IMiC) Consortium.

The rendered appendix is a Bookdown gitbook published at:
<https://amertens.github.io/IMiC-intervention-effects-supplement/>

It provides full analytical outputs (interactive forest and volcano plots, searchable estimate tables with CSV download, longitudinal trajectories, MILQ-anchored deficiency analyses, BMI-stratified subgroup analyses, and pathway enrichment results) that complement the static main article.

## Outstanding TODOs (revision round 1)

- **Zenodo / Code-Ocean DOI archive.** Science's revision checklist requires GitHub-hosted code to be permanently archived with a DOI. Tag a release of this repo, hook it to Zenodo, then embed the DOI in this README, in `index.Rmd`, and in the main paper's reference list.
- **Figure cross-references.** If the manuscript revision promotes Fig. S2 to a main-text figure (per Reviewer 2), every "Figure S#" cross-reference inside the chapter Rmds will need to be retargeted to the post-revision figure list.

## Section map

The chapter Rmd files are numbered to match the manuscript's `Online Appendix N` references — in particular, the manuscript citations *"Online Appendix 3"* (BMI subgroup) and *"Online Appendix 4"* (microbiome individual taxa) resolve directly to §3 and §4 of the rendered book.

| # | Section | Source Rmd |
|---|---|---|
| – | Overview (with outcome dictionary, methods recap, citation info) | `index.Rmd` |
| 1 | Baseline characteristics by study and intervention arm | `01_baseline_characteristics.Rmd` |
| 2 | Human milk component distributions (Figure S2) | `02_milk_distributions.Rmd` |
| 3 | Subgroup analyses stratified by maternal BMI | `03_subgroup_bmi.Rmd` |
| 4 | Microbiome and exploratory high-dimensional outcomes (Figure S6) | `04_exploratory_outcomes.Rmd` |
| 5 | Adjusted intervention effects on individual milk components | `05_intervention_effects.Rmd` |
| 6 | Reductions in HM nutrient deficiency relative to MILQ standards (Figure S3) | `06_milq_deficiency.Rmd` |
| 7 | Trajectory analyses of HM component change across lactation | `07_trajectory_plots.Rmd` |
| 8 | Sensitivity analyses and additional outputs (unadjusted, unscaled, fat-adjusted TGs [Figure S5], SuperLearner, PCA, pathway enrichment [Tables S2/S3/S5/S6], infant growth [Figure S1]) | `08_sensitivity_supplementary.Rmd` |
| – | Reproducibility / sessionInfo | `99_session_info.Rmd` |

## Display conventions

- **Forest plots** and **volcano plots** are rendered as `plotly` widgets in HTML — hover any point to read the component name, study, visit, ATE, 95% CI, and FDR-adjusted q-value. Plotly's mode bar (top-right) provides zoom, pan, and PNG export.
- Each plot is paired with a **searchable `DT::datatable`** that exposes the same underlying data with column filters, free-text search, sortable columns, and CSV/Excel/copy download buttons.
- Where a chapter's upstream input file is missing in the current build, the chapter prints an **inline notice** identifying the missing file rather than failing. This makes broken artefacts visible to readers and lets the book continue to render for everyone else.
- Static-image figures (saved upstream as pre-built ggplots) are rendered at larger figure dimensions and a 14pt base font in the source chapters, in response to Reviewer 2's note that some labels were too small.

## Data inputs

Each chapter consumes one of three types of upstream artefact:

| Path | Contents | Produced by |
|---|---|---|
| `data/merged_analysis_datasets.RDS` | Harmonised dyad-level dataset (one row per mother × visit) with every HM component, infant anthropometry, and baseline covariate | Upstream analysis repo (data-cleaning step) |
| `results/...RDS` and `results/subsetted results/*.csv` | Cleaned TMLE estimate tables (ATE, 95% CI, p, FDR q) by outcome group | Upstream analysis repo (TMLE step) |
| `figure-data/*.RDS` | Pre-rendered ggplot / plotly / data.frame objects backing specific manuscript figures (S1–S7 etc.) | Upstream analysis repo (figure-prep step) |
| `metadata/milk_component.Rdata` | Canonical mapping of biomarker name → outcome class (macro / micro / B-vit / HMO / protein / metabolomics) | Maintained alongside this repo |

Paths consumed by each chapter are referenced via `here::here(...)` in the source Rmd. The full TMLE / SuperLearner / enrichment pipelines that produce these inputs live in the upstream analysis repository:

<https://github.com/amertens/imic_intervention_effects>

## Porting analysis outputs from the upstream pipeline

The supplement does not contain the underlying RDS / CSV result files (the `data/`, `results/`, and `figures/` directories are gitignored to keep the source repo small). To populate them from the upstream analysis repo, run:

```r
# from the supplement repo root
options(imic.upstream = "C:/path/to/imic_intervention_effects")  # optional override
source("port_results.R")
```

`port_results.R` copies every file the bookdown chapters consume into the supplement at the path each chapter expects. The script reports which files were copied, which were skipped (missing upstream), and lists the few outputs the supplement still needs that aren't yet produced by the upstream pipeline (currently the four `pathway_enrichment_*` RDS files for §8.6).

## Reproducing the supplement

```r
# from the repo root, in an R session
install.packages(c("bookdown","knitr","rmarkdown",
                   "tidyverse","here","DT","plotly","table1"))

# Place the required upstream artefacts in data/, results/, figure-data/, figures/
# (see the "Data inputs" table above; port_results.R automates this).

library(bookdown)
bookdown::render_book("index.Rmd")          # full build
# bookdown::render_book("index.Rmd", "bookdown::gitbook")  # explicit format

# Optional: preview locally
bookdown::serve_book(".")
```

The book is published to GitHub Pages from the `docs/` output directory; the deploy is handled by a GitHub Actions workflow (`.github/workflows/`) when present, or by pushing the rendered `docs/` to the `gh-pages` branch.

The final page of the rendered book prints `sessionInfo()` so that the exact R and package versions used to produce any given build are part of the public record.

## Repository layout

```
.
├── index.Rmd                  Overview / chapter map / outcome dictionary / TODOs
├── 01_..._08_*.Rmd            Section sources (one per book section)
├── 99_session_info.Rmd        Reproducibility appendix
├── _bookdown.yml              Bookdown TOC + output dir
├── _output.yml                Per-format output options (gitbook, pdf, epub)
├── functions.R                Shared helpers: forest_plot, volcano_plot, clean_tab, safe_readRDS …
├── port_results.R             Copy upstream analysis outputs into expected paths
├── metadata/                  milk_component.Rdata — biomarker → outcome-class map
├── figure-data/               Pre-rendered figure objects (RDS) — gitignored copy of upstream figures/figure-data
├── docs/                      Rendered HTML output (GitHub Pages source)
├── book.bib, packages.bib     Bibliography
├── style.css                  Site styling
└── IMiC-intervention-effects-supplement.Rproj
```

## Citation

This supplement is released alongside the main manuscript. When citing analytical outputs from the supplement, please cite the main manuscript and include the appendix URL (and Zenodo DOI once available).

## Issues

Please report issues, broken figures, or unclear chapter content via the GitHub issues tracker of this repository.
