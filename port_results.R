## port_results.R
##
## Copy the upstream analysis outputs the online resource (this bookdown)
## consumes into this repo at the paths expected by each chapter. Run this once,
## or whenever the upstream analysis has been re-run.
##
## Usage (from the supplement repo root):
##   source("port_results.R")
##
## You can override the source/dest directories by setting
##   options(imic.upstream = "C:/path/to/upstream/analysis/repo")
##   options(imic.dest     = ".")
## before sourcing.

## Default: the analysis repo checked out next to this one.
upstream <- getOption("imic.upstream", file.path("..", "imic_intervention_effects"))
dest <- getOption("imic.dest", ".")

if (!dir.exists(upstream)) {
  stop("Upstream analysis repo not found at: ", upstream)
}

## Mapping of upstream -> destination (relative to dest).
## Add an entry whenever a chapter starts consuming a new artefact.
files <- list(
  ## ---- dyad-level dataset --------------------------------------------------
  ## INDIVIDUAL-LEVEL (one row per mother x visit): stays local, never committed
  ## (data/ is gitignored); Sections 1 and 2 read it for the baseline tables and
  ## boxplots, which publish only summaries.
  list("data/merged_analysis_datasets.RDS",
       "data/merged_analysis_datasets.RDS"),

  ## ---- adjusted intervention-effect estimate tables (CSV, ch 6) -----------
  list("results/subsetted results/primary_macro.csv",
       "results/subsetted results/primary_macro.csv"),
  list("results/subsetted results/primary_macro_arm_strat.csv",
       "results/subsetted results/primary_macro_arm_strat.csv"),
  list("results/subsetted results/primary_micro.csv",
       "results/subsetted results/primary_micro.csv"),
  list("results/subsetted results/primary_micro_arm_strat.csv",
       "results/subsetted results/primary_micro_arm_strat.csv"),
  list("results/subsetted results/primary_bvit.csv",
       "results/subsetted results/primary_bvit.csv"),
  list("results/subsetted results/primary_bvit_arm_strat.csv",
       "results/subsetted results/primary_bvit_arm_strat.csv"),
  list("results/subsetted results/secondary_hmo.csv",
       "results/subsetted results/secondary_hmo.csv"),
  list("results/subsetted results/secondary_hmo_arm_strat.csv",
       "results/subsetted results/secondary_hmo_arm_strat.csv"),
  list("results/subsetted results/secondary_bioactives.csv",
       "results/subsetted results/secondary_bioactives.csv"),
  list("results/subsetted results/secondary_bioactives_arm_strat.csv",
       "results/subsetted results/secondary_bioactives_arm_strat.csv"),
  list("results/subsetted results/tertiary_targeted_metabolomics.csv",
       "results/subsetted results/tertiary_targeted_metabolomics.csv"),
  list("results/subsetted results/tertiary_targeted_metabolomics_arm_strat.csv",
       "results/subsetted results/tertiary_targeted_metabolomics_arm_strat.csv"),

  ## ---- Table S1: native-unit descriptive concentrations + ATEs (ch 8.2) ---
  list("results/tables/table_s1_primary_secondary_native_units.csv",
       "results/tables/table_s1_primary_secondary_native_units.csv"),

  ## ---- machine-readable data files (published under data-files/) ---------
  ## The supplementary materials externalise four oversized tables (S1, S3, S6,
  ## S7) and name the CSV for each, telling readers to find it in the online
  ## resource -- i.e. here -- plus a fifth file with the native-unit estimates
  ## for every targeted metabolite. index.Rmd publishes data-files/ into docs/
  ## (Machine-readable data files section), so they must be ported under that
  ## folder, not just left in results/. Written upstream by
  ## src/pipeline/rebuild-submission-tables.R.
  list("results/tables/table_s1_primary_secondary_native_units.csv",
       "data-files/table_s1_primary_secondary_native_units.csv"),
  list("results/tables/table_s1_primary_secondary_native_units_wide.csv",
       "data-files/table_s1_primary_secondary_native_units_wide.csv"),
  list("results/tables/targeted_metabolites_native_units.csv",
       "data-files/targeted_metabolites_native_units.csv"),
  list("results/tables/table_s3_tertiary_msea_full.csv",
       "data-files/table_s3_tertiary_msea_full.csv"),
  list("results/tables/table_s6_mummichog_full.csv",
       "data-files/table_s6_mummichog_full.csv"),
  list("results/tables/table_s7_proteomics_go_full.csv",
       "data-files/table_s7_proteomics_go_full.csv"),

  ## ---- trajectory (ch 10) --------------------------------------------------
  list("results/adjusted_intervention_effects_traj_results_clean.RDS",
       "results/adjusted_intervention_effects_traj_results_clean.RDS"),
  list("results/adjusted_combined_arms_intervention_effects_traj_results_clean.RDS",
       "results/adjusted_combined_arms_intervention_effects_traj_results_clean.RDS"),

  ## ---- exploratory high-dim (ch 7) ---------------------------------------
  list("results/microbiome_diversity_intervention_effects_results.RDS",
       "results/microbiome_diversity_intervention_effects_results.RDS"),
  list("results/microbiome_diversity_intervention_effects_results_arm_strat.RDS",
       "results/microbiome_diversity_intervention_effects_results_arm_strat.RDS"),
  list("results/microbiome_intervention_effects_results.RDS",
       "results/microbiome_intervention_effects_results.RDS"),
  list("results/adjusted_combined_arms_intervention_effects_proteomics_results_clean.RDS",
       "results/adjusted_combined_arms_intervention_effects_proteomics_results_clean.RDS"),
  list("results/adjusted_combined_arms_intervention_effects_untargeted_results_clean.RDS",
       "results/adjusted_combined_arms_intervention_effects_untargeted_results_clean.RDS"),

  ## ---- sensitivity (ch 11) -------------------------------------------------
  list("results/unadjusted_intervention_effects_results_clean.RDS",
       "results/unadjusted_intervention_effects_results_clean.RDS"),
  list("results/adjusted_combined_arms_intervention_effects_unscaled_results_clean.RDS",
       "results/adjusted_combined_arms_intervention_effects_unscaled_results_clean.RDS"),
  list("results/pca_intervention_effects_results_arm_strat.RDS",
       "results/pca_intervention_effects_results_arm_strat.RDS"),

  ## ---- chapter figure-data objects + metadata ----------------------------
  ## Consumed directly by chapters 2/3/7/8 (significance-dependent figure
  ## objects). NOTE: the MILQ figure object is intentionally NOT listed here —
  ## the MILQ deficiency analysis already used per-(study x visit) correction
  ## and must remain unchanged by this revision.
  list("metadata/milk_component.Rdata",
       "metadata/milk_component.Rdata"),
  list("figure-data/SL_vim_plot_data.RDS",
       "figure-data/SL_vim_plot_data.RDS"),
  list("figure-data/pca_intervention_effects_results.RDS",
       "figure-data/pca_intervention_effects_results.RDS"),
  list("figure-data/figureS1_growth_plot_data.RDS",
       "figure-data/figureS1_growth_plot_data.RDS"),
  list("figure-data/subgroup_results.RDS",
       "figure-data/subgroup_results.RDS")
)

## Finalized milk-Mummichog feature annotation (Section 9). It lives at results/
## top level upstream; relocate it under mummichog_s5/ beside the Table S6 grid.
files[[length(files) + 1]] <- list("results/milk_mummichog_annotation_finalized.csv",
                                   "results/metaboanalyst/mummichog_s5/milk_mummichog_annotation_finalized.csv")

## UniProt-native proteome GO enrichment, FDR-significant terms (Section 9). At
## results/ top level upstream, so copy_tree("results/metaboanalyst") below does
## not pick it up; relocate it under proteomics_go/.
files[[length(files) + 1]] <- list("results/proteomics_go_uniprot_fdrsig.csv",
                                   "results/metaboanalyst/proteomics_go/proteomics_go_uniprot_fdrsig.csv")

## ---- cross-compartment blood results (Section 10) ----------------------------
## Only the tables Section 10 renders. The per-feature tables (tens of thousands
## of rows) are not published.
blood_csvs <- c(
  "results/blood_compartment_all_FDRsig_ATE.csv",              # FDR-significant counts; m/z 286.202
  "results/fdr_sig_putative_annotation.csv",                   # blood feature annotations
  "results/cross_compartment_arrow_contrast_summary.csv",      # concordance
  "results/cross_compartment_threshold_free_panel.csv",
  "results/cross_compartment_matching_sensitivity.csv",
  "results/cross_compartment_proteome_overlap_adjusted.csv",   # milk vs maternal-blood proteome
  "results/carnitine_annotation_support.csv",                  # m/z 286.202 annotation evidence
  "results/targeted_carnitine_crossvalidation.csv",
  "results/compartment_tracking/trenton_linked_crosscompartment.csv",  # Fig. 6D features
  "results/blood_mummichog_pathways_adjusted.csv",             # pathway direction
  "results/fat_synthesis_timepoint_table.csv",
  "results/signed_pathway_direction.csv",
  "results/signed_pathway_direction_milk.csv",
  "results/blood_chemical_class_enrichment_directional.csv"   # Table S9, all rows
)
for (f in blood_csvs) files[[length(files) + 1]] <- list(f, f)

copy_one <- function(src_rel, dst_rel) {
  src <- file.path(upstream, src_rel)
  dst <- file.path(dest, dst_rel)
  if (!file.exists(src)) {
    cat(sprintf("[skip ] %s\n   (missing upstream)\n", src_rel))
    return(invisible(FALSE))
  }
  if (!dir.exists(dirname(dst))) dir.create(dirname(dst), recursive = TRUE)
  ok <- file.copy(src, dst, overwrite = TRUE, copy.date = TRUE)
  cat(sprintf("%s %s -> %s\n", if (ok) "[copy ]" else "[FAIL ]", src_rel, dst_rel))
  invisible(ok)
}

## Recursive directory copy (used for the metaboanalyst results tree and the
## upstream figure trees, which hold many files under a stable folder name).
copy_tree <- function(src_rel, dst_rel = src_rel, pattern = NULL) {
  src <- file.path(upstream, src_rel)
  dst <- file.path(dest, dst_rel)
  if (!dir.exists(src)) {
    cat(sprintf("[skip ] tree %s (missing upstream)\n", src_rel))
    return(invisible(FALSE))
  }
  fs <- list.files(src, pattern = pattern, recursive = TRUE, full.names = FALSE)
  for (f in fs) {
    s <- file.path(src, f)
    d <- file.path(dst, f)
    if (!dir.exists(dirname(d))) dir.create(dirname(d), recursive = TRUE)
    file.copy(s, d, overwrite = TRUE, copy.date = TRUE)
  }
  cat(sprintf("[tree ] %s -> %s (%d files)\n", src_rel, dst_rel, length(fs)))
  invisible(TRUE)
}

cat(sprintf("\nPorting analysis outputs\n  from: %s\n  to:   %s\n\n", upstream, dest))
res <- vapply(files, function(f) copy_one(f[[1]], f[[2]]), logical(1))
cat(sprintf("\nCopied %d of %d files.\n", sum(res), length(res)))

## ---- enrichment CSV outputs (Section 9 and the pathway-explorer app) ----
copy_tree("results/metaboanalyst", "results/metaboanalyst", pattern = "\\.csv$")

## ---- attach pval_adj_global (sensitivity) to the subsetted CSVs --------------
## Upstream clean_results.R writes the per-visit pval_adj into the subsetted CSVs
## but drops pval_adj_global (the more conservative correction pooled across all
## studies and visits within an outcome group, retained for sensitivity). Join it
## back on from the upstream clean result frames, keyed on study/visit/contrast/
## biomarker, so each subsetted CSV carries both correction columns.
attach_global_fdr <- function() {
  combined_csvs <- c("primary_macro", "primary_micro", "primary_bvit",
                     "secondary_hmo", "secondary_bioactives",
                     "tertiary_targeted_metabolomics")
  key_tbl <- function(rds_rel) {
    p <- file.path(upstream, rds_rel)
    if (!file.exists(p)) { cat(sprintf("[skip ] global FDR: missing %s\n", rds_rel)); return(NULL) }
    d <- readRDS(p)
    if (!"pval_adj_global" %in% names(d)) {
      cat(sprintf("[skip ] global FDR: %s lacks pval_adj_global\n", basename(rds_rel))); return(NULL)
    }
    d <- d[d$measure == "ATE", , drop = FALSE]
    out <- data.frame(study = as.character(d$study), visit = as.character(d$visit),
                      contrast = as.character(d$contrast),
                      biomarker = tolower(as.character(d$biomarker)),
                      pval_adj_global = d$pval_adj_global, stringsAsFactors = FALSE)
    out[!duplicated(out[, c("study", "visit", "contrast", "biomarker")]), ]
  }
  kc <- key_tbl("results/adjusted_combined_arms_intervention_effects_results_clean.RDS")
  ks <- key_tbl("results/adjusted_intervention_effects_results_clean.RDS")
  one <- function(fname, keytbl) {
    if (is.null(keytbl)) return(invisible(FALSE))
    path <- file.path(dest, "results/subsetted results", paste0(fname, ".csv"))
    if (!file.exists(path)) return(invisible(FALSE))
    df <- utils::read.csv(path, check.names = FALSE)
    if ("pval_adj_global" %in% names(df)) df$pval_adj_global <- NULL
    df$.bm <- tolower(as.character(df$biomarker))
    m <- merge(df, keytbl, by.x = c("study", "visit", "contrast", ".bm"),
               by.y = c("study", "visit", "contrast", "biomarker"),
               all.x = TRUE, sort = FALSE)
    m$.bm <- NULL
    cols <- names(m); cols <- cols[cols != "pval_adj_global"]
    m <- m[, append(cols, "pval_adj_global", after = match("pval_adj", cols))]
    utils::write.csv(m, path, row.names = FALSE)
    cat(sprintf("[+global] %s (%d unmatched)\n", fname, sum(is.na(m$pval_adj_global))))
    invisible(TRUE)
  }
  for (f in combined_csvs)                    one(f, kc)
  for (f in paste0(combined_csvs, "_arm_strat")) one(f, ks)
}
attach_global_fdr()

## ---- one row per estimate in the arm-stratified CSVs --------------------------
## Upstream clean_results.R joins the arm-stratified native-unit results without
## keeping only the ATE rows (its pooled join does), so every estimate appears
## twice: once with its native-unit ATE and once with the arm's mean (MN row) in
## the *_unscaled columns. Keep the row whose native-unit value matches the ATE.
## Once the upstream join is fixed this finds no duplicates and changes nothing.
dedupe_arm_strat <- function() {
  un_rel <- "results/adjusted_intervention_effects_unscaled_results_clean.RDS"
  un_p <- file.path(upstream, un_rel)
  if (!file.exists(un_p)) { cat(sprintf("[skip ] arm-strat dedupe: missing %s\n", un_rel)); return(invisible(FALSE)) }
  un <- as.data.frame(readRDS(un_p))
  un <- un[un$measure == "ATE", , drop = FALSE]
  ate_key <- paste(un$study, un$visit, un$contrast, tolower(un$biomarker))
  ate_est <- stats::setNames(un$est, ate_key)
  for (fname in paste0(c("primary_macro", "primary_micro", "primary_bvit", "secondary_hmo",
                         "secondary_bioactives", "tertiary_targeted_metabolomics"), "_arm_strat")) {
    path <- file.path(dest, "results/subsetted results", paste0(fname, ".csv"))
    if (!file.exists(path)) next
    df <- utils::read.csv(path, check.names = FALSE)
    key <- paste(df$study, df$visit, df$contrast, tolower(df$biomarker))
    target <- ate_est[key]
    is_ate <- !is.na(target) & !is.na(df$est_unscaled) &
      abs(df$est_unscaled - target) <= 1e-8 * pmax(1, abs(target))
    dup <- key %in% key[duplicated(key)]
    ## keep unduplicated rows; among duplicates keep the ATE match, or else the first
    keep <- !dup | is_ate
    lost <- setdiff(unique(key[dup]), unique(key[dup & is_ate]))
    keep[dup & key %in% lost & !duplicated(key)] <- TRUE
    out <- df[keep, , drop = FALSE]
    out <- out[!duplicated(paste(out$study, out$visit, out$contrast, tolower(out$biomarker))), , drop = FALSE]
    if (nrow(out) < nrow(df)) utils::write.csv(out, path, row.names = FALSE)
    cat(sprintf("[dedup] %s: %d -> %d rows\n", fname, nrow(df), nrow(out)))
  }
  invisible(TRUE)
}
dedupe_arm_strat()

## The earlier "pathway_enrichment_*.RDS genuinely missing upstream" footer has
## been removed: the pathway/enrichment chapter (Section 9) is now built from the
## scripted MetaboAnalystR CSV outputs under results/metaboanalyst/ (copied by
## the copy_tree() call above), which supersede those never-produced RDS files.
