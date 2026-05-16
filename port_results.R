## port_results.R
##
## Copy the upstream analysis outputs the supplement bookdown consumes into
## the supplement repo at the paths expected by each chapter. Run this once,
## or whenever the upstream analysis has been re-run.
##
## Usage (from the supplement repo root):
##   source("port_results.R")
##
## You can override the source/dest directories by setting
##   options(imic.upstream = "C:/path/to/imic_intervention_effects")
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
  list("figures/figure-data/heatmaps.RDS",
       "figures/figure-data/heatmaps.RDS")
)

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

cat(sprintf("\nPorting analysis outputs\n  from: %s\n  to:   %s\n\n", upstream, dest))
res <- vapply(files, function(f) copy_one(f[[1]], f[[2]]), logical(1))
cat(sprintf("\nCopied %d of %d files.\n", sum(res), length(res)))

## --- Files genuinely missing upstream ----------------------------------------
##
## Chapter 12 (Pathway enrichment) expects these — they are not produced
## by the current upstream analysis pipeline. The chapter will print inline
## "missing file" notices until they are generated:
##
##   results/pathway_enrichment_msea.RDS              (MetaboAnalyst ORA)
##   results/pathway_enrichment_mummichog.RDS         (Mummichog)
##   results/pathway_enrichment_go_bp.RDS             (clusterProfiler::enrichGO)
##   results/fatty_acid_composition_enrichment.RDS    (Wilcoxon TG FA composition)
##
## See the appendix Methods section for the workflow each one corresponds to.
