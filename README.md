# IMiC intervention effects on human milk: online resource

Source of the online resource for Dailey-Chwalibóg, Mertens *et al.* (2026), *Nutritional interventions' impacts on human milk: three trials in low-resource settings*, from the International Milk Composition (IMiC) Consortium. The site is a bookdown gitbook published at <https://amertens.github.io/IMiC-intervention-effects-supplement/>.

## Sections

| Section | Contents | Source |
|---|---|---|
| Overview | Contents, estimates and plot conventions, data files, citation | `index.Rmd` |
| 1 | Baseline characteristics by trial and arm | `01_baseline_characteristics.Rmd` |
| 2 | All milk components analyzed; their distributions | `02_milk_distributions.Rmd` |
| 3 | Effects by maternal BMI | `03_subgroup_bmi.Rmd` |
| 4 | Microbiome, untargeted proteome, and untargeted metabolome | `04_exploratory_outcomes.Rmd` |
| 5 | Component metadata; effects on each targeted component; effect explorer app | `05_intervention_effects.Rmd` |
| 6 | Effects on nutrient deficiency (MILQ reference) | `06_milq_deficiency.Rmd` |
| 7 | Effects on change between visits | `07_trajectory_plots.Rmd` |
| 8 | Unadjusted and native-unit effects (Table S1), treatment-arm prediction, principal-component scores, infant growth | `08_sensitivity_supplementary.Rmd` |
| 9 | Enrichment analyses (Tables S3, S6, and S7 in full); pathway explorer app | `09_pathway_enrichment.Rmd` |
| 10 | Maternal and infant blood in MISAME-III | `10_cross_compartment_blood.Rmd` |
| – | R session | `99_session_info.Rmd` |

The article cites Sections 1–5 by number, so those numbers must not change. The site does not reproduce the article's figures; it holds the tables behind them, the interactive views, and results the article does not print.

## Building the site

```r
# from the repository root
source("port_results.R")                                # copy the analysis outputs (see below)
bookdown::render_book(".", "bookdown::gitbook")        # render the book into docs/
source("build_apps.R")                                  # export the two shinylive apps into docs/apps/
```

`port_results.R` copies the files the chapters read from the analysis repository, by default `../imic_intervention_effects`; set `options(imic.upstream = "path/to/analysis/repo")` to use another location. The analysis code is at <https://github.com/amertens/IMiC-intervention-effects-public>. GitHub Pages serves `docs/` from `main`; do not edit `docs/` by hand.

A chapter whose input file is missing prints a note naming the file instead of its output.

## Data

The repository and the site hold aggregate results only. `data/` and `results/` are gitignored. The one individual-level input, `data/merged_analysis_datasets.RDS` (the harmonized dyad-level dataset, used for the Section 1 tables and the Section 2 boxplots), stays local. `.gitignore` also blocks the saved figure objects that once embedded per-sample data.

Tracked inputs: `data-files/` (the CSV files the supplementary materials point to, published to `docs/data-files/`), `figure-data/` (aggregate estimate tables), and `metadata/milk_component.Rdata` (the map of components to outcome classes).

## Repository layout

```
index.Rmd, 01_*.Rmd ... 10_*.Rmd, 99_session_info.Rmd   chapters
_bookdown.yml, _output.yml, style.css, *.bib             book settings
functions.R                                              shared helpers
port_results.R                                           copy inputs from the analysis repository
build_apps.R, shiny-apps/                                effect and pathway explorer apps
data-files/, figure-data/, metadata/                     tracked aggregate inputs
docs/                                                    rendered site (GitHub Pages)
```

## Citation

Cite the article, and cite the online resource by the DOI of its archive, [10.5281/zenodo.22104233](https://doi.org/10.5281/zenodo.22104233), which also holds the analysis code.
