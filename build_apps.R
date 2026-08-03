## build_apps.R — bundle data for the shinylive apps and export them (webR) to
## docs/apps/, sharing one runtime. Run after port_results.R.
##
##   "C:/Program Files/R/R-4.4.2/bin/Rscript.exe" build_apps.R
##
## The exported apps under docs/apps/ are what GitHub Pages serves; the per-app
## data/ folders are derived from results/ and are gitignored (regenerated here).

if (!requireNamespace("shinylive", quietly = TRUE))
  stop("Install the 'shinylive' package first: install.packages('shinylive')")

apps_root <- "shiny-apps"
dest      <- "docs/apps"
dir.create(dest, recursive = TRUE, showWarnings = FALSE)

copy_data <- function(app, files, from) {
  d <- file.path(apps_root, app, "data")
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
  ok <- 0
  for (f in files) {
    src <- file.path(from, f)
    if (file.exists(src)) { file.copy(src, file.path(d, f), overwrite = TRUE); ok <- ok + 1 }
    else cat(sprintf("[warn] missing data file: %s\n", src))
  }
  cat(sprintf("[data] %s: %d files staged\n", app, ok))
}

## ---- Effect Explorer: 12 subsetted result CSVs ----------------------------
prefixes <- c("primary_macro","primary_micro","primary_bvit",
              "secondary_hmo","secondary_bioactives","tertiary_targeted_metabolomics")
copy_data("effect-explorer",
          c(paste0(prefixes, ".csv"), paste0(prefixes, "_arm_strat.csv")),
          from = "results/subsetted results")

shinylive::export(file.path(apps_root, "effect-explorer"), dest, subdir = "effect-explorer")
cat("[export] effect-explorer -> docs/apps/effect-explorer\n")

## ---- Pathway Explorer: 8 enrichment CSVs (from results/metaboanalyst) ------
pe_data <- file.path(apps_root, "pathway-explorer", "data")
dir.create(pe_data, recursive = TRUE, showWarnings = FALSE)
pe_src <- c("primary_combined/primary_combined_supplementary_table.csv",
            "primary_stratified/primary_stratified_supplementary_table.csv",
            "tertiary_msea/tertiary_msea_combined.csv",
            "tertiary_msea/tertiary_msea_stratified.csv",
            "triglyceride_fa/triglyceride_fa_composition_stratified.csv",
            "untargeted_msea/untargeted_msea_combined.csv",
            "mummichog_s5/milk_mummichog_tableS5.csv",
            "proteomics_go/proteomics_go_tableS6.csv")
pe_ok <- 0
for (rel in pe_src) {
  src <- file.path("results/metaboanalyst", rel)
  if (file.exists(src)) { file.copy(src, file.path(pe_data, basename(rel)), overwrite = TRUE); pe_ok <- pe_ok + 1 }
  else cat(sprintf("[warn] missing enrichment file: %s\n", src))
}
cat(sprintf("[data] pathway-explorer: %d files staged\n", pe_ok))
shinylive::export(file.path(apps_root, "pathway-explorer"), dest, subdir = "pathway-explorer")
cat("[export] pathway-explorer -> docs/apps/pathway-explorer\n")

dir_mb <- function(d) round(sum(file.info(list.files(d, recursive = TRUE, full.names = TRUE))$size, na.rm = TRUE)/1e6, 1)
cat(sprintf("[size] docs/apps total: %.1f MB\n", dir_mb(dest)))
