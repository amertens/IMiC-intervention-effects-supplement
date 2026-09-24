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

upstream <- getOption(
  "imic.upstream",
  "C:/Users/andre/OneDrive/Documents/imic_intervention_effects"
)
dest <- getOption("imic.dest", ".")

if (!dir.exists(upstream)) {
  stop("Upstream analysis repo not found at: ", upstream)
}

## Mapping of upstream -> destination (relative to dest).
## Add an entry whenever a chapter starts consuming a new artefact.
files <- list(
  ## ---- dyad-level dataset --------------------------------------------------
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
  list("results/microbiome_intervention_effects_results_arm_strat.RDS",
       "results/microbiome_intervention_effects_results_arm_strat.RDS"),
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
  list("results/SLvim_lab_plots.RDS",
       "results/SLvim_lab_plots.RDS"),

  ## ---- pre-rendered figure objects (already mostly ported) ---------------
  list("figures/figure-data/volcano_plots.RDS",
       "figures/figure-data/volcano_plots.RDS"),
  list("figures/figure-data/volcano_plots_pooled_arms.RDS",
       "figures/figure-data/volcano_plots_pooled_arms.RDS"),

  ## ---- chapter figure-data objects + metadata ----------------------------
  ## Consumed directly by chapters 2/3/7/8 (significance-dependent figure
  ## objects). NOTE: the MILQ figure object is intentionally NOT listed here —
  ## the MILQ deficiency analysis already used per-(study x visit) correction
  ## and must remain unchanged by this revision.
  list("metadata/milk_component.Rdata",
       "metadata/milk_component.Rdata"),
  list("figure-data/SL_vim_plot_data.RDS",
       "figure-data/SL_vim_plot_data.RDS"),
  list("figure-data/figure_s2_plots.RDS",
       "figure-data/figure_s2_plots.RDS"),
  list("figure-data/figure_s4_trajectory_plots.RDS",
       "figure-data/figure_s4_trajectory_plots.RDS"),
  list("figure-data/figure_sX_forest_plot_fat_adjusted.RDS",
       "figure-data/figure_sX_forest_plot_fat_adjusted.RDS"),
  list("figure-data/figures8_network_plots_primary.RDS",
       "figure-data/figures8_network_plots_primary.RDS"),
  list("figure-data/figures8_network_plots_metabolomics.RDS",
       "figure-data/figures8_network_plots_metabolomics.RDS"),
  list("figure-data/pca_intervention_effects_results.RDS",
       "figure-data/pca_intervention_effects_results.RDS"),
  list("figure-data/figureS1_growth_plot_data.RDS",
       "figure-data/figureS1_growth_plot_data.RDS"),
  list("figure-data/subgroup_results.RDS",
       "figure-data/subgroup_results.RDS")
)

## ---- manuscript figures regenerated upstream 2026-09-23 (colourblind-safe) ---
## Fig. 3 (fig3-primary-volcano-composite.R): the combined-arm composite and its
## arm-stratified counterpart are embedded in §9.2, and the printed Fig. S4 in
## §8.3. The others are the current print versions of Figs. 4-6, S1 and S5, kept
## alongside for reference.
for (f in c("figures/figure3.png", "figures/figure3_stratified_supplement.png",
            "figures/figure4.jpeg", "figures/figure5.png", "figures/figure6.png",
            "figures/figureS4_triglyceride_means.png",
            "figures/figureS1_growth_outcomes.png",
            "figures/figureS5_microbiome_diversity.png"))
  files[[length(files) + 1]] <- list(f, f)

## Direction-split ORA composite figures (§9 primary/tertiary subsections). Named
## appendix_* upstream; kept under their figureS_* names here so the published
## site carries no "appendix" file names. NOT regenerated on 2026-09-23, so they
## still use the pre-Okabe-Ito study colours.
files[[length(files) + 1]] <- list("figures/appendix_primary_ora_by_direction.png",
                                   "figures/figureS_primary_ora_by_direction.png")
files[[length(files) + 1]] <- list("figures/appendix_tertiary_ora_by_direction.png",
                                   "figures/figureS_tertiary_ora_by_direction.png")

## Finalized milk-Mummichog feature-level annotation (§9 mummichog subsection).
## These live at results/ top-level upstream; relocate under mummichog_s5/ here
## so §9.8 loads them alongside the Table S6 pathway grid. (The direction-split
## primary/tertiary ORA CSVs already live under results/metaboanalyst/ upstream
## and are picked up by the copy_tree("results/metaboanalyst") call below.)
files[[length(files) + 1]] <- list("results/milk_mummichog_annotation_finalized.csv",
                                   "results/metaboanalyst/mummichog_s5/milk_mummichog_annotation_finalized.csv")
files[[length(files) + 1]] <- list("results/milk_mummichog_annotation_summary.csv",
                                   "results/metaboanalyst/mummichog_s5/milk_mummichog_annotation_summary.csv")

## CORRECTED untargeted milk proteome GO enrichment (Table S7 / Fig 6C, §9.9).
## These live at results/ TOP-LEVEL upstream (NOT under metaboanalyst/), so the
## copy_tree("results/metaboanalyst") call below does NOT pick them up. They are
## the UniProt-native over-representation results that SUPERSEDE the retracted
## gene-level proteomics_go_tableS6.csv. Relocate under proteomics_go/ here so
## §9.9 reads the corrected, predominantly down-regulated GO-BP signature.
files[[length(files) + 1]] <- list("results/proteomics_go_uniprot.csv",
                                   "results/metaboanalyst/proteomics_go/proteomics_go_uniprot.csv")
files[[length(files) + 1]] <- list("results/proteomics_go_uniprot_fdrsig.csv",
                                   "results/metaboanalyst/proteomics_go/proteomics_go_uniprot_fdrsig.csv")

## Chemical-class enrichment figure (§10.6) -- lives at results/ top-level
## upstream; relocate under figures/cross_compartment/ here so §10.6 loads it
## alongside the other cross-compartment figures.
files[[length(files) + 1]] <- list("results/blood_class_enrichment_figure.png",
                                   "figures/cross_compartment/blood_class_enrichment_figure.png")

## ---- NEW: cross-compartment blood result CSVs (ch 10) --------------------
## Only the CSVs that §10 actually renders are ported. Full per-feature tables
## (per-pair cross_compartment_metab_*, fdr_sig_updown_lists,
## four_compartment_bep_feature_screen, non-adjusted overlap/pathway duplicates,
## etc.) run to tens of thousands of rows, are not rendered inline, and are not
## exposed for download from the built site, so they are intentionally not
## copied. §10 uses per-arrow / per-pathway summaries + the *_consistent /
## *_shortlist / *_adjusted subsets instead.
blood_csvs <- c(
  # blood intervention effects (FDR-sig ATE; §10.1 summary counts)
  "results/blood_compartment_all_FDRsig_ATE.csv",
  # cross-compartment concordance summaries (§10.2)
  "results/cross_compartment_arrow_contrast_summary.csv",
  "results/cross_compartment_threshold_free_panel.csv",
  "results/cross_compartment_fdr_first_lists.csv",
  "results/cross_compartment_matching_sensitivity.csv",
  # selenoproteins / proteome overlap (§10.3, adjusted models)
  "results/cross_compartment_proteome_overlap_adjusted.csv",
  # m/z 286.202 acylcarnitine (§10.4). The mediation outputs that used to be ported
  # here (tmle_mediation.csv, dyad_milk_infant_mediation.csv,
  # mediation_measurement_error_sensitivity.csv) were withdrawn 2026-08-27
  # along with their upstream scripts -- the analysis is not claimed by the
  # manuscript or either response letter, and rested on an unconfirmed
  # milk-to-infant feature identity.
  "results/targeted_carnitine_crossvalidation.csv",
  "results/targeted_acylcarnitine_class_summary.csv",
  "results/acylcarnitine_composition.csv",
  "results/carnitine_annotation_support.csv",
  # pathway analyses (§10.6, adjusted / signed)
  "results/blood_mummichog_pathways.csv",
  "results/blood_mummichog_pathways_adjusted.csv",
  "results/cross_compartment_pathways_adjusted.csv",
  "results/signed_pathway_direction.csv",
  "results/signed_pathway_direction_milk.csv",
  "results/fat_synthesis_timepoint_table.csv",
  # chemical-class enrichment (§10.6): the FDR-significant maternal-blood result
  # (blood mummichog is nominal-only, 0 pathways survive FDR). Non-directional +
  # directional (up/down) class over-representation by compartment.
  "results/blood_chemical_class_enrichment.csv",
  "results/blood_chemical_class_enrichment_directional.csv",
  # putative annotation (§10.7)
  "results/fdr_sig_putative_annotation.csv",
  "results/milk_fdr_sig_putative_annotation.csv",
  "results/blood_consistent_annotated_features_consistent.csv",
  # BEP-product provenance (§10.8)
  "results/bep_supplement_tracer.csv",
  "results/bep_supplement_composition_xref.csv",
  "results/four_compartment_bep_shortlist.csv",
  "results/supplement_mummichog_pathways.csv",
  # infant growth null control (§10.9)
  "results/infant_carnitine_growth_assoc.csv",
  "results/detectability_proxy_infant_carnitine.csv",
  # consolidated cross-compartment table (§10.10)
  "results/table_s8_cross_compartment.csv",
  # compartment tracking (Trenton's name-based grouping rule -- the SAME rule
  # behind manuscript Fig. 6D and Table S11 as of the 2026-08-25 reconciliation;
  # see Manuscript/SUPPLEMENT_HANDOFF_FIG6D_RESOLUTION.md upstream). Table S11
  # (§10.5) and its supporting compound list; the paired figure PNGs are
  # ported explicitly further down.
  "results/tables/table_s10_temporal_persistence.csv",   # Table S10 (§10.1)
  "results/tables/table_s11_compartment_pathway.csv",
  "results/compartment_tracking/trenton_linked_crosscompartment.csv",
  "results/compartment_tracking/trenton_pathway_compound_list.csv",
  "results/compartment_tracking/metabolite_pathways_trenton.csv"
  # NOTE: pathway_results_local.csv / metabolite_pathways_local.csv /
  # linked_upregulated_plot_data.csv (union-find grouping) are intentionally
  # NOT ported — that rule was superseded by Trenton's original method above.
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

## ---- recursive trees: enrichment CSV outputs + upstream figure PNGs -------
## (ch 9) the scripted MetaboAnalystR ORA/MSEA/Mummichog/GO result tables:
copy_tree("results/metaboanalyst", "results/metaboanalyst", pattern = "\\.csv$")
## (ch 10) pre-rendered cross-compartment figures. The blood-volcano PNGs
## (figures/blood_volcano/) are no longer ported: they predate the 2026-07-13
## blood re-run, so §10.1 reports the FDR-significant counts as tables instead.
copy_tree("figures/cross_compartment", "figures/cross_compartment", pattern = "\\.png$")
## The §10.5 figures are named appendix_* upstream; publish them under their
## existing local names so the site carries no "appendix" file names.
copy_one("figures/cross_compartment/appendix_crosscompartment_volcanoes.png",
         "figures/cross_compartment/figureS11_crosscompartment_volcanoes.png")
copy_one("figures/cross_compartment/appendix_compartment_tracking.png",
         "figures/cross_compartment/figureS10_compartment_tracking.png")

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

## The earlier "pathway_enrichment_*.RDS genuinely missing upstream" footer has
## been removed: the pathway/enrichment chapter (§9) is now built from the
## scripted MetaboAnalystR CSV outputs under results/metaboanalyst/ (copied by
## the copy_tree() call above), which supersede those never-produced RDS files.
