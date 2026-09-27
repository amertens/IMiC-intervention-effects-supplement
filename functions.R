## Shared helpers for the IMiC intervention-effects supplement.
## Loaded by individual chapter Rmds via source("functions.R") (or here()).

## ---- Manuscript figure conventions ------------------------------------------
## Plots drawn here follow the printed figures, so the encodings a reader learns
## from the paper carry over. Colours are colourblind-safe (Science editor, round
## 2), and every colour code is backed by a second cue (symbol shape, fill, or line
## type). The values are copied from the upstream analysis repo, from
## figure-scripts/manuscript_figures/study_colors.R and
## figure-scripts/0_figure-functions.R as used for the 2026-09-27 submission figures.
okabe_ito <- c(black = "#000000", orange = "#E69F00", skyblue = "#56B4E9",
               green = "#009E73", yellow = "#F0E442", blue = "#0072B2",
               vermillion = "#D55E00", purple = "#CC79A7")

## Studies (Figs. 3B, 5B-C, 6A-C, S5). Index the maps by name
## (imic_study_cols[studies]), never by position.
imic_study_cols <- c(
  "ELICIT"     = "#0072B2",  # Okabe-Ito blue
  "MISAME-III" = "#E69F00",  # Okabe-Ito orange
  "Mumta-LW"   = "#CC79A7"   # Okabe-Ito reddish purple
)
imic_study_shapes <- c(
  "ELICIT"     = 16,         # filled circle
  "MISAME-III" = 17,         # filled triangle
  "Mumta-LW"   = 15          # filled square
)
## Milk-component categories of the FDR-significant volcano points (Figs. 3A, 5A):
## colour i always travels with symbol i.
imic_cat_cols   <- c("#0072B2", "#E69F00", "#009E73", "#D55E00", "#CC79A7", "#56B4E9", "#882255")
imic_cat_shapes <- c(17, 18, 25, 8, 4, 3, 10)   # triangle, diamond, down-triangle, asterisk, x, plus, circle-plus
imic_shapes_for <- function(keys) {
  s <- unname(imic_study_shapes[keys])
  s[is.na(s)] <- 16
  stats::setNames(s, keys)
}

## Significance tiers of the forest plots (Figs. 2, S2, S3): not significant =
## grey open circle; nominally significant (P < 0.05) = blue open circle;
## FDR-significant (Q < 0.05) = orange filled circle. In arm-stratified plots,
## colour and line type carry the contrast, so the tier is carried by the symbol
## alone (open circle, open triangle, filled circle).
sig_tier_levels <- c("Not significant", "Nominally significant", "FDR-significant")
sig_tier_cols   <- stats::setNames(c("grey60", "#1F77B4", "#FF7F0E"), sig_tier_levels)
sig_tier_shapes <- stats::setNames(c(1, 1, 19), sig_tier_levels)
sig_tier_shapes_strat <- stats::setNames(c(1, 2, 19), sig_tier_levels)

## Volcano plots (Figs. 3A, 5A): points not FDR-significant are black (circle =
## not significant, square = nominally significant only); FDR-significant points
## take their component category's colour and symbol. Solid reference lines: grey
## at P = 0.05, green at the Benjamini-Hochberg threshold.
volcano_line_cols <- c(p = "#BAB0AC", q = "#59A14F")
logp_title <- "–Log₁₀(P-value)"   # en dash, subscript 10, as on the printed axes

## Fig. 1A (collection time), Fig. 1B (milk component class), Fig. S1 (growth measure).
imic_time_cols <- c("<1 month" = "#7F7F7F", "1-2 months" = "#FF7F0E", "2-5 months" = "#17BECF")
imic_class_cols <- c("Macronutrients" = "#2CA02C", "Micronutrients" = "#D62728",
                     "B-vitamins" = "#9467BD", "HMOs" = "#8C564B", "Proteins" = "#E377C2",
                     "Targeted metabolomics" = "#7F7F7F",
                     "Untargeted metabolomics" = "#BCBD22", "Microbiome" = "#17BECF")
imic_measure_cols      <- c("LAZ" = "#0072B2", "WLZ" = "#E69F00")
imic_measure_linetypes <- c("LAZ" = "solid",   "WLZ" = "dashed")

## Theme of the printed figures: white background, a border round each panel,
## vertical gridlines only, no y-axis ticks, and unshaded facet titles. The printed
## figures set Helvetica at 7-8 pt; on the web the browser's sans-serif font is
## used at a readable size.
theme_imic_web <- function(base_size = 12) {
  ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(),
                   panel.grid.minor   = ggplot2::element_blank(),
                   axis.ticks.y       = ggplot2::element_blank(),
                   strip.background   = ggplot2::element_blank(),
                   legend.position    = "bottom")
}

## Facet titles are written "Study (visit)", as in the printed figures, in the
## panel order of the figure each plot mirrors.
panel_orders <- list(
  forest  = c("Mumta-LW (1.5 mo.)", "Mumta-LW (2 mo.)", "ELICIT (1 mo.)", "ELICIT (5 mo.)",
              "MISAME-III (14-21 days)", "MISAME-III (1-2 mo.)", "MISAME-III (3-4 mo.)"),  # Figs. 2, S3
  volcano = c("MISAME-III (14-21 days)", "MISAME-III (1-2 mo.)", "MISAME-III (3-4 mo.)",
              "Mumta-LW (1.5 mo.)", "Mumta-LW (2 mo.)", "ELICIT (1 mo.)", "ELICIT (5 mo.)",   # Figs. 3A, 5A
              "MISAME-III (14-21 days to 1-2 mo.)", "MISAME-III (1-2 to 3-4 mo.)",           # Section 7 change
              "Mumta-LW (1.5 to 2 mo.)", "ELICIT (1 to 5 mo.)"),                              # intervals
  study   = c("ELICIT (1 mo.)", "ELICIT (5 mo.)", "Mumta-LW (1.5 mo.)", "Mumta-LW (2 mo.)",
              "MISAME-III (14-21 days)", "MISAME-III (1-2 mo.)", "MISAME-III (3-4 mo.)")  # Figs. 1B, S2
)
study_visit_panel <- function(study, visit, contrast = NULL, order = "forest") {
  base <- paste0(study, " (", visit, ")")
  base_lv <- c(intersect(panel_orders[[order]], unique(base)),
               sort(setdiff(unique(base), panel_orders[[order]])))
  if (is.null(contrast)) return(factor(base, levels = base_lv))
  lab <- paste0(base, ": ", contrast)
  factor(lab, levels = unlist(lapply(base_lv, function(b) sort(unique(lab[base == b])))))
}

## Display names of the primary and secondary components, as printed (short, title
## case, B-vitamin subscripts, Greek tocopherols, IgA, FGF-21). Copied from the
## upstream biomarker_label_map (figure-scripts/0_figure-functions.R). Keyed by the
## lower-cased biomarker code; any other component keeps its own label.
biomarker_label_map <- c(
  "kcal.l"="Total Energy","fat"="Total Fat","protein"="Total Protein",
  "cho"="Total Carbohydrate","carbohydrate"="Total Carbohydrate",
  "as"="Arsenic","ca"="Calcium","ca_bio"="Calcium","cr"="Chromium","cu"="Copper",
  "fe"="Iron","k"="Potassium","mg"="Magnesium","mn"="Manganese","mo"="Molybdenum",
  "na"="Sodium","p"="Phosphorus","se"="Selenium","zn"="Zinc","choline"="Choline",
  "vitamin.a"="Vitamin A","a.tocopherol"="α-Tocopherol","g.tocopherol"="γ-Tocopherol",
  "b1"="Vitamin B₁","b2"="Vitamin B₂","b3"="Vitamin B₃",
  "b6"="Vitamin B₆","b12"="Vitamin B₁₂",
  "pa"="Vitamin B₅","bio"="Vitamin B₇",
  "t"="Free Thiamin","tmp"="Thiamine Monophosphate","tpp"="Thiamine Pyrophosphate",
  "ribo"="Riboflavin","fmn"="Flavin Mononucleotide","fad"="Flavin Adenine Dinucleotide",
  "nam"="Nicotinamide","nad"="Nicotinamide Adenine Dinucleotide",
  "nmn"="Nicotinamide Mononucleotide","nr"="Nicotinamide Riboside",
  "nufa"="Nudifloramide","trp"="Tryptophan",
  "pl"="Pyridoxal","pm"="Pyridoxamine","pn"="Pyridoxine","plp"="Pyridoxal 5′-Phosphate",
  "fgf.21"="FGF-21","iga"="IgA","fsh"="Follicle-Stimulating Hormone",
  "lh"="Luteinizing Hormone","leptin"="Leptin","insulin"="Insulin",
  "calprotectin"="Calprotectin (S100A8/A9)"
)
canonical_label <- function(code, fallback = code) {
  out <- unname(biomarker_label_map[tolower(as.character(code))])
  fb  <- as.character(fallback)
  if (length(fb) == 1L) fb <- rep(fb, length(out))
  out[is.na(out)] <- fb[is.na(out)]
  out
}

## Three-tier significance factor (levels sig_tier_levels) from whichever flags a
## table carries: sigFDR / sig (0/1, logical, or Yes/No), else pval_adj / pval.
.flag <- function(x) as.character(x) %in% c("1", "TRUE", "Yes", "yes", "true")
sig_tier <- function(tab, fdr_thresh = 0.05) {
  n   <- nrow(tab)
  fdr <- if ("sigFDR" %in% names(tab)) .flag(tab$sigFDR)
         else if ("pval_adj" %in% names(tab)) tab$pval_adj < fdr_thresh else rep(FALSE, n)
  nom <- if ("sig" %in% names(tab)) .flag(tab$sig)
         else if ("pval" %in% names(tab)) tab$pval < 0.05 else rep(FALSE, n)
  fdr[is.na(fdr)] <- FALSE; nom[is.na(nom)] <- FALSE
  factor(ifelse(fdr, "FDR-significant", ifelse(nom, "Nominally significant", "Not significant")),
         levels = sig_tier_levels)
}

## Randomised contrasts vs. control, fixed by name so a contrast keeps its colour
## and line type in every plot. Only one trial's contrasts share a facet, so the
## colours are chosen to separate within a trial; line types do the same job
## without colour.
imic_contrast_cols <- c(
  "Nico" = "#0072B2", "Az." = "#882255", "Nico+Az." = "#CC79A7",          # ELICIT (Az. in Tol's wine,
                                                                          # as upstream, so no two arms share a colour)
  "IFA/BEP" = "#E69F00", "BEP/BEP" = "#D55E00", "BEP/IFA" = "#56B4E9",    # MISAME-III
  "BEP+ExBf" = "#009E73", "BEP+ExBf+AZT" = "#000000"                      # Mumta-LW
)
imic_contrast_linetypes <- c(
  "Nico" = "solid", "Az." = "dashed", "Nico+Az." = "dotted",
  "IFA/BEP" = "solid", "BEP/BEP" = "dashed", "BEP/IFA" = "dotted",
  "BEP+ExBf" = "solid", "BEP+ExBf+AZT" = "dashed"
)
## Randomized arms (boxplots in Section 2, trajectory lines in Section 7): each
## intervention arm in its contrast colour, control in gray. The boxplots also dodge
## in legend order and the trajectory lines also differ in line type, so arm never
## rests on colour alone.
imic_arm_cols      <- c("Control" = "grey60",   imic_contrast_cols)
imic_arm_linetypes <- c("Control" = "longdash", imic_contrast_linetypes)

## Colour and line-type scales for a categorical variable (typically `contrast`).
## Known contrast names get their fixed colour/line type; anything else (e.g. the
## growth-plot contrast labels) is filled in from the remaining Okabe-Ito colours
## and a cycle of line types. Use both scales with the same `name` so ggplot
## merges them into one legend.
imic_contrast_scales <- function(keys, name = "Contrast") {
  keys <- sort(unique(as.character(keys[!is.na(keys)])))
  cols <- unname(imic_contrast_cols[keys])
  spare <- setdiff(c(imic_cat_cols, okabe_ito[["black"]]), cols)
  cols[is.na(cols)] <- rep_len(spare, sum(is.na(cols)))
  lts <- unname(imic_contrast_linetypes[keys])
  spare_lt <- setdiff(c("solid", "dashed", "dotted", "dotdash", "longdash", "twodash"), lts)
  if (!length(spare_lt)) spare_lt <- c("dotdash", "longdash", "twodash")
  lts[is.na(lts)] <- rep_len(spare_lt, sum(is.na(lts)))
  list(ggplot2::scale_colour_manual(name = name, values = stats::setNames(cols, keys)),
       ggplot2::scale_linetype_manual(name = name, values = stats::setNames(lts, keys)))
}

## Volcano colour and symbol for each point: the two non-FDR tiers in black, and
## FDR-significant points by component category. As in Fig. 5A, categories holding
## under 4% of the plotted components are pooled as "Other", Triglycerides take the
## first colour, and the primary-outcome categories keep the fixed Fig. 3A mapping.
## A table without categories draws its FDR-significant points as orange triangles.
primary_cat_order <- c("Other B vitamins", "B2", "B3 or related", "B1", "B6",
                       "Micronutrient", "Macronutrient")
volcano_encoding <- function(tab, fdr_thresh = 0.05) {
  tier <- sig_tier(tab, fdr_thresh)
  cat  <- if ("category" %in% names(tab)) as.character(tab$category) else rep(NA_character_, nrow(tab))
  cat[!is.na(cat) & !nzchar(cat)] <- NA
  if (any(!is.na(cat))) {
    share <- prop.table(table(cat))
    cat[cat %in% names(share)[share < 0.04]] <- "Other"
  }
  fdr_cats <- unique(cat[tier == "FDR-significant" & !is.na(cat)])
  ord <- if (length(fdr_cats) && all(fdr_cats %in% primary_cat_order)) primary_cat_order
         else c(intersect("Triglycerides", fdr_cats), sort(setdiff(fdr_cats, "Triglycerides")))
  keep <- ord[seq_len(min(length(ord), length(imic_cat_cols)))]
  cols <- stats::setNames(imic_cat_cols[seq_along(keep)], keep)
  shps <- stats::setNames(imic_cat_shapes[seq_along(keep)], keep)
  key  <- ifelse(tier != "FDR-significant", as.character(tier),
          ifelse(!is.na(cat) & cat %in% keep, cat, "FDR-significant"))
  levels <- c("Not significant", "Nominally significant", keep,
              if (any(key == "FDR-significant")) "FDR-significant")
  list(key  = factor(key, levels = levels),
       cols = c("Not significant" = "#000000", "Nominally significant" = "#000000", cols,
                "FDR-significant" = unname(sig_tier_cols["FDR-significant"]))[levels],
       shapes = c("Not significant" = 16, "Nominally significant" = 15, shps,
                  "FDR-significant" = 17)[levels])
}
## plotly symbol names for the R point shapes used above.
plotly_symbol <- c("1" = "circle-open", "2" = "triangle-up-open", "3" = "cross-thin-open",
                   "4" = "x-thin-open", "8" = "asterisk-open", "10" = "circle-cross-open",
                   "15" = "square", "16" = "circle", "17" = "triangle-up", "18" = "diamond",
                   "19" = "circle", "25" = "triangle-down")

## Trial names and visit labels as printed. Result files use the trials' internal
## labels (Misame, Vital, Elicit) and some use numeric visit codes; every plot and
## results table here shows the manuscript's names and visit labels instead.
study_name <- function(s) {
  s <- as.character(s)
  s[s %in% c("Misame", "MISAME-3", "Misame-III", "MISAME")] <- "MISAME-III"
  s[s %in% c("Vital", "VITAL-Lactation")]                   <- "Mumta-LW"
  s[s %in% c("Elicit")]                                     <- "ELICIT"
  s
}
visit_code_labels <- list(
  "MISAME-III" = c("1" = "14-21 days", "2" = "1-2 mo.", "3" = "3-4 mo."),
  "Mumta-LW"   = c("40" = "1.5 mo.", "56" = "2 mo."),
  "ELICIT"     = c("1" = "1 mo.", "5" = "5 mo."))
visit_name <- function(study, visit) {
  s <- study_name(study); v <- as.character(visit)
  for (st in names(visit_code_labels)) {
    i <- s %in% st & v %in% names(visit_code_labels[[st]])
    v[i] <- visit_code_labels[[st]][v[i]]
  }
  v
}
## "Misame-2" / "Vital-40" / "Elicit-5" study-time codes -> "MISAME-III (1-2 mo.)".
studytime_label <- function(x) {
  x <- as.character(x)
  st <- study_name(sub("-\\d+$", "", x))
  paste0(st, " (", visit_name(st, sub("^.*-", "", x)), ")")
}

## Standard study/visit factor levels and display names used across sections.
.harmonize_factors <- function(tab) {
  if ("study" %in% names(tab)) {
    if ("visit" %in% names(tab)) tab$visit <- visit_name(tab$study, tab$visit)
    s <- study_name(tab$study)
    tab$study <- droplevels(factor(s, levels = unique(c("MISAME-III", "Mumta-LW", "ELICIT",
                                                        s[!is.na(s)]))))
  }
  if ("visit" %in% names(tab)) {
    v <- as.character(tab$visit)
    tab$visit <- droplevels(factor(v, levels = unique(c("14-21 days", "1-2 mo.", "3-4 mo.",
                                                        "1.5 mo.", "2 mo.", "1 mo.", "5 mo.",
                                                        v[!is.na(v)]))))
  }
  if (all(c("biomarker", "label_f") %in% names(tab))) {
    tab$label_f <- canonical_label(tab$biomarker, tab$label_f)
  }
  ## The result files leave the fat-soluble vitamins without a category; file them
  ## with the micronutrients, as in Fig. 2B ("micronutrients and fat-soluble
  ## vitamins") and the outcomes list in Section 2.
  if (all(c("biomarker", "category") %in% names(tab))) {
    fsv <- is.na(tab$category) & tolower(tab$biomarker) %in% c("vitamin.a", "a.tocopherol", "g.tocopherol")
    if (any(fsv)) { tab$category <- as.character(tab$category); tab$category[fsv] <- "Micronutrient" }
  }
  ## Upstream tables sometimes carry only chi_pval / chi_pval_adj. Alias them
  ## to pval / pval_adj so downstream plotting and tabulation works uniformly.
  if (!"pval" %in% names(tab) && "chi_pval" %in% names(tab)) tab$pval <- tab$chi_pval
  if (!"pval_adj" %in% names(tab) && "chi_pval_adj" %in% names(tab)) tab$pval_adj <- tab$chi_pval_adj
  tab
}

## ggplotly() names the legend entry of a trace mapped to several variables after
## the combination, e.g. "(Not significant,Az.,3)", where the number indexes a line
## type. Rename such entries "Az. · Not significant" (group first, significance
## last) and list each name once.
tidy_plotly_legend <- function(w) {
  tiers <- c(sig_tier_levels, "Yes", "No")
  seen  <- character()
  for (i in seq_along(w$x$data)) {
    nm <- w$x$data[[i]]$name
    if (is.null(nm) || !nzchar(nm)) next
    if (grepl("^\\(.*\\)$", nm)) {
      parts <- trimws(strsplit(sub("^\\((.*)\\)$", "\\1", nm), ",")[[1]])
      parts <- unique(parts[!grepl("^[0-9]+$", parts)])
      tier  <- intersect(parts, tiers)
      tier[tier == "Yes"] <- "P < 0.05"; tier[tier == "No"] <- "not significant"
      nm <- paste(c(setdiff(parts, tiers), tier), collapse = " · ")
      w$x$data[[i]]$name <- nm
      w$x$data[[i]]$legendgroup <- nm
    }
    if (!identical(w$x$data[[i]]$showlegend, FALSE)) {
      if (nm %in% seen) w$x$data[[i]]$showlegend <- FALSE else seen <- c(seen, nm)
    }
  }
  w
}

## Convert a ggplot to a hoverable plotly widget for HTML output; otherwise, or if
## the conversion fails, return the static ggplot.
as_widget <- function(p, interactive = TRUE, tooltip = "text") {
  if (interactive && requireNamespace("plotly", quietly = TRUE) &&
      isTRUE(knitr::is_html_output())) {
    conv <- try(plotly::ggplotly(p, tooltip = tooltip), silent = TRUE)
    if (!inherits(conv, "try-error")) return(tidy_plotly_legend(conv))
  }
  p
}

## Interactive forest plot in the style of Fig. 2 and Fig. S3: one panel per study
## and visit ("Study (visit)", Fig. 2 panel order), components ordered by effect,
## the three significance tiers, and a dashed grey line at zero. In arm-stratified
## plots each contrast has its own colour and CI line type and the tier is carried
## by the symbol.
forest_plot <- function(tab, arm_strat = FALSE, interactive = TRUE, title = NULL,
                        x_lab = "Average treatment effect (SD units)") {
  tab <- .harmonize_factors(tab)
  tab$sigcat <- sig_tier(tab)
  ## ggplotly() cannot draw facet_wrap(study ~ visit) over a grid with empty cells
  ## or coord_flip() with facets, so the forest uses one combined facet variable
  ## and a horizontal (orientation = "y") error bar.
  tab$panel <- if (all(c("study", "visit") %in% names(tab))) study_visit_panel(tab$study, tab$visit)
               else if ("study" %in% names(tab)) factor(tab$study) else factor("All")
  tab$tooltip <- paste0(tab$label_f,
                        "<br>", tab$panel,
                        if ("contrast" %in% names(tab)) paste0("<br>Contrast: ", tab$contrast) else "",
                        "<br>ATE: ", round(tab$est, 3),
                        " (", round(tab$cil, 3), ", ", round(tab$ciu, 3), ")",
                        if ("pval" %in% names(tab)) paste0("<br>P = ", signif(tab$pval, 3)) else "",
                        if ("pval_adj" %in% names(tab)) paste0("<br>Q = ", signif(tab$pval_adj, 3)) else "")

  p <- ggplot2::ggplot(tab, ggplot2::aes(y = stats::reorder(label_f, -est), x = est, text = tooltip)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = "grey60")
  if (arm_strat) {
    dodge <- ggplot2::position_dodge(width = 0.6)
    p <- p +
      ggplot2::geom_errorbar(ggplot2::aes(xmin = cil, xmax = ciu, colour = contrast,
                                          linetype = contrast, group = contrast),
                             width = 0.2, orientation = "y", position = dodge) +
      ggplot2::geom_point(ggplot2::aes(colour = contrast, shape = sigcat, group = contrast),
                          size = 2, position = dodge) +
      ggplot2::scale_shape_manual(values = sig_tier_shapes_strat, drop = FALSE,
                                  name = "Statistical Significance") +
      imic_contrast_scales(tab$contrast)
  } else {
    p <- p +
      ggplot2::geom_errorbar(ggplot2::aes(xmin = cil, xmax = ciu, colour = sigcat),
                             width = 0.2, orientation = "y") +
      ggplot2::geom_point(ggplot2::aes(colour = sigcat, shape = sigcat), size = 2) +
      ggplot2::scale_colour_manual(values = sig_tier_cols, drop = FALSE,
                                   name = "Statistical Significance") +
      ggplot2::scale_shape_manual(values = sig_tier_shapes, drop = FALSE,
                                  name = "Statistical Significance")
  }
  p <- p + ggplot2::facet_wrap(~ panel, ncol = 4) +
    ggplot2::labs(title = title, x = x_lab, y = NULL) +
    theme_imic_web()
  as_widget(p, interactive)
}

## Interactive volcano plot in the style of Figs. 3A and 5A. `tab` needs est, pval,
## pval_adj, and label_f; a `category` column colours the FDR-significant points.
## One panel per study and visit ("Study (visit)", Fig. 3A panel order), split by
## contrast when a table holds several per visit. The green line sits at each
## panel's Benjamini-Hochberg threshold (the largest raw P with Q < fdr_thresh), so
## panels without an FDR-significant point have no green line.
volcano_plot <- function(tab, fdr_thresh = 0.05, interactive = TRUE, title = NULL,
                         x_lab = "Scaled average treatment effect (SD units)") {
  tab <- .harmonize_factors(tab)
  if (!"pval_adj" %in% names(tab)) tab$pval_adj <- NA_real_
  tab <- tab[is.finite(tab$est) & is.finite(tab$pval), , drop = FALSE]
  enc <- volcano_encoding(tab, fdr_thresh)
  tab$point_type <- enc$key
  tab$neglog10p  <- -log10(pmax(tab$pval, .Machine$double.eps))
  if (all(c("study", "visit") %in% names(tab))) {
    multi <- "contrast" %in% names(tab) &&
      any(tapply(as.character(tab$contrast), paste(tab$study, tab$visit),
                 function(x) length(unique(x))) > 1)
    tab$panel <- study_visit_panel(tab$study, tab$visit,
                                   contrast = if (multi) tab$contrast, order = "volcano")
  } else {
    tab$panel <- factor(if ("study" %in% names(tab)) tab$study else "All")
  }
  tab$tooltip <- paste0(tab$label_f, "<br>", tab$panel,
                        "<br>ATE: ", signif(tab$est, 3),
                        "<br>P = ", signif(tab$pval, 3), " | Q = ", signif(tab$pval_adj, 3))
  q_lines <- do.call(rbind, lapply(split(tab, tab$panel, drop = TRUE), function(d) {
    s <- d$pval[!is.na(d$pval_adj) & d$pval_adj < fdr_thresh]
    if (length(s)) data.frame(panel = d$panel[1], y = -log10(max(s))) else NULL
  }))

  p <- ggplot2::ggplot(tab, ggplot2::aes(x = est, y = neglog10p)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed") +
    ggplot2::geom_hline(yintercept = -log10(0.05), colour = volcano_line_cols[["p"]], linewidth = 0.4)
  if (!is.null(q_lines) && nrow(q_lines))
    p <- p + ggplot2::geom_hline(data = q_lines, ggplot2::aes(yintercept = y),
                                 colour = volcano_line_cols[["q"]], linewidth = 0.4)
  p <- p +
    ggplot2::geom_point(ggplot2::aes(colour = point_type, fill = point_type, shape = point_type,
                                     text = tooltip), size = 1.6, alpha = 0.75) +
    ggplot2::scale_colour_manual(values = enc$cols, drop = FALSE, name = NULL) +
    ggplot2::scale_fill_manual(values = enc$cols, drop = FALSE, name = NULL) +
    ggplot2::scale_shape_manual(values = enc$shapes, drop = FALSE, name = NULL) +
    ggplot2::facet_wrap(~ panel, scales = "free", ncol = 3) +
    ggplot2::labs(title = title, x = x_lab, y = logp_title) +
    theme_imic_web()
  as_widget(p, interactive)
}

## Render an estimates table with consistent column formatting and column filters.
clean_tab <- function(tab, caption = NULL) {
  rownames(tab) <- NULL
  tab <- .harmonize_factors(tab)
  if (!"perc_imp" %in% names(tab)) tab$perc_imp <- NA_real_
  ## Some upstream tables only carry chi_pval / chi_pval_adj; alias.
  if (!"pval" %in% names(tab) && "chi_pval" %in% names(tab)) tab$pval <- tab$chi_pval
  if (!"pval_adj" %in% names(tab) && "chi_pval_adj" %in% names(tab)) tab$pval_adj <- tab$chi_pval_adj

  if (all(c("est_unscaled","cil_unscaled","ciu_unscaled") %in% names(tab))) {
    tab$ATE_unscaled <- paste0(round(tab$est_unscaled, 2), " (",
                               round(tab$cil_unscaled, 2), ", ",
                               round(tab$ciu_unscaled, 2), ")")
  } else {
    tab$ATE_unscaled <- NA_character_
  }

  tab <- tab %>%
    dplyr::mutate(
      ATE = paste0(round(est, 2), " (", round(cil, 2), ", ", round(ciu, 2), ")"),
      pval_cat = dplyr::case_when(
        pval < 0.001 ~ "***", pval < 0.01 ~ "**", pval < 0.05 ~ "*", TRUE ~ ""),
      pval_adj_cat = dplyr::case_when(
        pval_adj < 0.001 ~ "***", pval_adj < 0.01 ~ "**", pval_adj < 0.05 ~ "*", TRUE ~ ""),
      pval     = paste0(round(pval, 3), pval_cat),
      pval_adj = paste0(round(pval_adj, 3), pval_adj_cat),
      perc_imp = round(perc_imp, 2)
    )

  ## pval_adj_global retains the more conservative correction pooled across
  ## study and visit within each outcome group (the pre-revision scheme),
  ## shown alongside the per-visit pval_adj for sensitivity.
  if ("pval_adj_global" %in% names(tab)) {
    tab <- tab %>% dplyr::mutate(
      pval_adj_global_cat = dplyr::case_when(
        pval_adj_global < 0.001 ~ "***", pval_adj_global < 0.01 ~ "**",
        pval_adj_global < 0.05 ~ "*", TRUE ~ ""),
      pval_adj_global = paste0(round(pval_adj_global, 3), pval_adj_global_cat)
    )
  }

  keep <- intersect(c("study","visit","contrast","label_f","perc_imp",
                      "ATE","ATE_unscaled","pval","pval_adj","pval_adj_global"), names(tab))
  tab <- tab[, keep, drop = FALSE]

  DT::datatable(
    tab,
    extensions = "FixedHeader",
    options = list(pageLength = 15, dom = "frtip",
                   fixedHeader = TRUE, scrollX = TRUE),
    caption = caption, filter = "top", rownames = FALSE
  ) %>% DT::formatStyle(columns = keep, fontSize = "11px")
}

## Generic DT renderer with column filters. Use for any tabular result.
nice_dt <- function(df, caption = NULL, page_length = 15, round_digits = 3) {
  if (is.null(df) || nrow(df) == 0) {
    return(htmltools::tags$em("No rows to display."))
  }
  num_cols <- names(df)[vapply(df, is.numeric, logical(1))]
  dt <- DT::datatable(
    df,
    extensions = "FixedHeader",
    options = list(pageLength = page_length, dom = "frtip",
                   fixedHeader = TRUE, scrollX = TRUE),
    caption = caption, filter = "top", rownames = FALSE
  )
  if (length(num_cols)) dt <- DT::formatRound(dt, columns = num_cols, digits = round_digits)
  dt
}

## Safe loader: returns NULL with a notice if the file is missing, instead of
## breaking the book build. Notice appears inline in the rendered chapter so
## readers know which artefact is awaiting upstream regeneration.
safe_readRDS <- function(path, label = path) {
  if (!file.exists(path)) {
    msg <- sprintf("*Data file not found at `%s`. Re-run the upstream analysis pipeline to regenerate `%s`.*", path, label)
    cat(msg)
    return(invisible(NULL))
  }
  readRDS(path)
}

safe_load <- function(path) {
  if (!file.exists(path)) {
    cat(sprintf("*Metadata file not found at `%s`.*", path))
    return(invisible(FALSE))
  }
  load(path, envir = parent.frame())
  invisible(TRUE)
}

safe_read_csv <- function(path, ...) {
  if (!file.exists(path)) {
    cat(sprintf("*Results file not found at `%s`. Build the upstream analysis repo to populate it.*", path))
    return(invisible(NULL))
  }
  utils::read.csv(path, ...)
}

## Embed a pre-rendered static image (PNG) shipped by the upstream analysis
## pipeline, degrading gracefully to an inline notice when the file is absent
## (mirrors safe_readRDS / safe_read_csv). Unlike the plot helpers, the
## cross-compartment and blood-volcano figures in §§9–10 are rendered upstream
## and copied in by port_results.R rather than rebuilt from R objects here.
## Return the value of this directly as the last expression of a chunk (no
## results='asis' needed — asis_output / include_graphics both handle it).
safe_img <- function(path, label = basename(path)) {
  if (!file.exists(path)) {
    return(knitr::asis_output(sprintf(
      "\n\n*Figure not found at `%s`. Run `port_results.R` to copy `%s` from the upstream analysis repo.*\n\n",
      path, label)))
  }
  knitr::include_graphics(path)
}

## Print an object whose type may vary across builds (single ggplot, list of
## ggplots, plotly, data.frame). Used in chapters that consume saved RDS
## artefacts whose exact structure is set upstream.
## Can this ggplot actually be drawn by the INSTALLED ggplot2? Objects saved by
## ggplot2 3.x carry the bare S3 class c("gg","ggplot"); ggplot2 4.x moved to S7
## and has no ggplot_build() method for them, so print() silently falls through
## to print.default and dumps the object's internal list as thousands of lines of
## console text instead of drawing anything. Test buildability up front so we can
## say so in one line rather than flooding the page.
.gg_is_drawable <- function(x) {
  !inherits(try(ggplot2::ggplot_build(x), silent = TRUE), "try-error")
}

## Short italic notice. Requires the calling chunk to use results='asis'.
.show_note <- function(fmt, ...) cat(sprintf(paste0("\n\n*", fmt, "*\n\n"), ...))

show_any <- function(x, label = NULL) {
  if (is.null(x)) return(invisible(NULL))
  if (inherits(x, c("plotly","htmlwidget"))) { print(x); return(invisible(NULL)) }
  if (inherits(x, "gg")) {
    if (!.gg_is_drawable(x)) {
      .show_note(paste0("Saved plot object%s cannot be drawn by the installed ggplot2 (%s): ",
                        "it was written by an older version, and this release has no renderer ",
                        "for it. Re-save the object from the upstream figure pipeline under the ",
                        "current ggplot2 to restore this panel."),
                 if (is.null(label)) "" else paste0(" `", label, "`"),
                 as.character(utils::packageVersion("ggplot2")))
      return(invisible(NULL))
    }
    ## Draw statically, on purpose. These are pre-rendered manuscript figure
    ## panels, and a static image is what the surrounding prose promises. It is
    ## also the only reliable option here: ggplotly() returns an htmlwidget, and
    ## print()-ing a widget from INSIDE a function does not trigger knitr's
    ## htmlwidget path, so the plot is silently dropped from the page (the same
    ## trap that hid the Table S6 and blood-Mummichog tables). A widget has to be
    ## the chunk's own last auto-printed value to survive, which a side-effect
    ## helper like this one cannot arrange. print() of a ggplot, by contrast,
    ## draws to the graphics device and is captured wherever it is called.
    print(x); return(invisible(NULL))
  }
  if (is.data.frame(x)) { print(nice_dt(x)); return(invisible(NULL)) }
  if (is.list(x)) {
    for (i in seq_along(x)) {
      nm <- names(x)[i] %||% paste0("Panel ", i)
      cat(sprintf("\n\n**%s**\n\n", nm))
      show_any(x[[i]], label = if (is.null(label)) nm else paste0(label, " / ", nm))
    }
    return(invisible(NULL))
  }
  ## Anything else: name it rather than dumping its internals onto the page.
  .show_note("Object%s is not a plot or table and is not displayed here (class: %s).",
             if (is.null(label)) "" else paste0(" `", label, "`"),
             paste(class(x), collapse = ", "))
  invisible(NULL)
}

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

## For high-cardinality feature tables, cap the points shown in the
## interactive volcano so the rendered HTML stays a reasonable size, while
## still allowing the full table to be inspected separately via DT.
## Returns the volcano widget (or static ggplot fallback). Emits a one-line
## sub-cap via cat() when the data has been down-sampled — requires the
## calling chunk to use results='asis'.
##
## `table_note` describes what the accompanying DT below the plot actually
## contains. The default assumes the table is complete; pass an explicit string
## whenever the table is filtered, so the sub-cap cannot promise rows the reader
## will not find (e.g. the untargeted-metabolomics volcano, whose table is
## restricted to q < 0.10).
volcano_capped <- function(df, n_show = 2000, table_note = "the full table below contains every feature", ...) {
  if (is.null(df) || !nrow(df)) { cat("*No rows to plot.*\n\n"); return(invisible(NULL)) }
  if (nrow(df) > n_show && "pval" %in% names(df)) {
    df_show <- df %>% dplyr::arrange(pval) %>% dplyr::slice_head(n = n_show)
    cat(sprintf("\n*Interactive volcano shows top %s features by raw p-value (of %s total); %s.*\n\n",
                format(n_show, big.mark = ","), format(nrow(df), big.mark = ","), table_note))
  } else {
    df_show <- df
  }
  volcano_plot(df_show, ...)
}

## Interactive LINKED volcano + table (crosstalk). Brushing/selecting points in
## the volcano filters the rows shown in the table, and the table's own column
## filters drive the plot — all client-side, so it works on static GitHub Pages
## with no Shiny server. `df` needs est, pval, pval_adj, and a label column;
## study/visit/contrast add dropdown filters and richer tooltips. Returns an
## htmltools tagList (return it as the last value of a chunk).
linked_volcano_table <- function(df, fdr_thresh = 0.05,
                                 title = "Volcano — brush points to filter the table (and vice versa)",
                                 x_lab = "Scaled average treatment effect (SD units)",
                                 key_col = "label_f",
                                 filter_cols = c("study", "visit", "contrast"),
                                 show_cols = c("study","visit","contrast","label_f","est","cil","ciu",
                                               "pval","pval_adj","pval_adj_global","sigFDR")) {
  if (is.null(df) || !nrow(df)) return(htmltools::tags$em("No rows to display."))
  df <- .harmonize_factors(df)
  if (!"pval" %in% names(df) && "chi_pval" %in% names(df)) df$pval <- df$chi_pval
  if (!"pval_adj" %in% names(df) && "chi_pval_adj" %in% names(df)) df$pval_adj <- df$chi_pval_adj
  if (!all(c("est","pval","pval_adj") %in% names(df)) || !key_col %in% names(df)) {
    return(htmltools::tags$em("Table lacks the est / pval / pval_adj / label columns needed for a volcano."))
  }
  df$neglog10p <- -log10(pmax(df$pval, .Machine$double.eps))
  ## Same encoding as volcano_plot() (Figs. 3A, 5A): black circle / black square
  ## for the non-FDR tiers, category colour and symbol for FDR-significant points.
  enc <- volcano_encoding(df, fdr_thresh)
  df$point_type <- enc$key
  df$tooltip <- paste0(df[[key_col]],
                       if ("study" %in% names(df)) paste0("<br>", df$study) else "",
                       if ("visit" %in% names(df)) paste0(" (", df$visit, ")") else "",
                       "<br>ATE ", signif(df$est, 3), " | P ", signif(df$pval, 3),
                       " | Q ", signif(df$pval_adj, 3))
  keep <- union(intersect(show_cols, names(df)), c("neglog10p", "point_type", "tooltip", "est"))
  df   <- df[, intersect(keep, names(df)), drop = FALSE]

  if (!knitr::is_html_output() || !requireNamespace("crosstalk", quietly = TRUE)) {
    return(nice_dt(df[, setdiff(names(df), c("neglog10p","point_type","tooltip")), drop = FALSE]))
  }
  sd <- crosstalk::SharedData$new(df)

  p <- plotly::plot_ly(sd, x = ~est, y = ~neglog10p, type = "scatter", mode = "markers",
                       color = ~point_type, colors = enc$cols,
                       symbol = ~point_type,
                       symbols = stats::setNames(unname(plotly_symbol[as.character(enc$shapes)]),
                                                 names(enc$shapes)),
                       text = ~tooltip, hoverinfo = "text",
                       marker = list(size = 6, opacity = 0.75)) %>%
    plotly::layout(title = list(text = title), xaxis = list(title = x_lab),
                   yaxis = list(title = logp_title), legend = list(orientation = "h"),
                   shapes = list(
                     list(type = "line", x0 = 0, x1 = 0, yref = "paper", y0 = 0, y1 = 1,
                          line = list(dash = "dash", color = "black", width = 1)),
                     list(type = "line", xref = "paper", x0 = 0, x1 = 1,
                          y0 = -log10(0.05), y1 = -log10(0.05),
                          line = list(color = volcano_line_cols[["p"]], width = 1)))) %>%
    plotly::highlight(on = "plotly_selected", off = "plotly_deselect", persistent = FALSE)

  hide_idx <- which(names(df) %in% c("neglog10p", "point_type", "tooltip")) - 1
  dt <- DT::datatable(sd, extensions = "FixedHeader",
                      options = list(pageLength = 10, dom = "frtip",
                                     fixedHeader = TRUE, scrollX = TRUE,
                                     columnDefs = list(list(visible = FALSE, targets = hide_idx))),
                      filter = "top", rownames = FALSE) %>%
    DT::formatStyle(columns = names(df), fontSize = "11px")

  fcols <- intersect(filter_cols, names(df))
  filt  <- lapply(fcols, function(cc)
    crosstalk::filter_select(cc, cc, sd, stats::as.formula(paste0("~", cc))))
  htmltools::tagList(
    if (length(filt)) do.call(crosstalk::bscols, filt) else NULL,
    p, dt)
}

## Interactive LINKED scatter (feature map) + table (crosstalk). A general
## companion to linked_volcano_table for tables that aren't volcanoes — e.g.
## an m/z-vs-effect feature map of putatively annotated features. Brushing the
## scatter filters the table and vice versa. Client-side only (static-Pages safe).
linked_scatter_table <- function(df, x_col, y_col, color_col = NULL, key_col,
                                 title = "", x_lab = x_col, y_lab = y_col,
                                 filter_cols = character(0),
                                 show_cols = names(df)) {
  if (is.null(df) || !nrow(df)) return(htmltools::tags$em("No rows to display."))
  if (!all(c(x_col, y_col, key_col) %in% names(df))) {
    return(htmltools::tags$em("Table lacks the columns needed for this feature map."))
  }
  df$tooltip <- paste0(df[[key_col]],
                       "<br>", x_lab, ": ", signif(df[[x_col]], 5),
                       " | ", y_lab, ": ", signif(df[[y_col]], 3))
  keep <- union(intersect(show_cols, names(df)),
                c(x_col, y_col, color_col, "tooltip", key_col))
  df   <- df[, intersect(keep, names(df)), drop = FALSE]

  if (!knitr::is_html_output() || !requireNamespace("crosstalk", quietly = TRUE)) {
    return(nice_dt(df[, setdiff(names(df), "tooltip"), drop = FALSE]))
  }
  sd <- crosstalk::SharedData$new(df)
  args <- list(sd, x = stats::as.formula(paste0("~`", x_col, "`")),
               y = stats::as.formula(paste0("~`", y_col, "`")),
               type = "scatter", mode = "markers", text = ~tooltip, hoverinfo = "text",
               marker = list(size = 6, opacity = 0.6))
  if (!is.null(color_col) && color_col %in% names(df)) {
    ## Colour and symbol both encode the category. An up/down direction gets
    ## pointing triangles; any other category cycles through distinct symbols.
    lv   <- sort(unique(as.character(df[[color_col]][!is.na(df[[color_col]])])))
    dirn <- ifelse(grepl("^up", lv, ignore.case = TRUE), "up",
            ifelse(grepl("^down", lv, ignore.case = TRUE), "down", NA))
    if (!anyNA(dirn)) {
      cols <- ifelse(dirn == "up", okabe_ito[["vermillion"]], okabe_ito[["blue"]])
      syms <- ifelse(dirn == "up", "triangle-up", "triangle-down")
    } else {
      cols <- rep_len(imic_cat_cols, length(lv))
      syms <- rep_len(c("circle", "triangle-up", "square", "diamond", "x", "cross", "star"), length(lv))
    }
    args$color   <- stats::as.formula(paste0("~`", color_col, "`"))
    args$colors  <- stats::setNames(cols, lv)
    args$symbol  <- stats::as.formula(paste0("~`", color_col, "`"))
    args$symbols <- stats::setNames(syms, lv)
  }
  p <- do.call(plotly::plot_ly, args) %>%
    plotly::layout(title = list(text = title), xaxis = list(title = x_lab),
                   yaxis = list(title = y_lab), legend = list(orientation = "h"),
                   shapes = list(list(type = "line", xref = "paper", x0 = 0, x1 = 1,
                                      y0 = 0, y1 = 0, line = list(dash = "dash", color = "grey50")))) %>%
    plotly::highlight(on = "plotly_selected", off = "plotly_deselect", persistent = FALSE)

  hide_idx <- which(names(df) %in% "tooltip") - 1
  dt <- DT::datatable(sd, extensions = "FixedHeader",
                      options = list(pageLength = 10, dom = "frtip",
                                     fixedHeader = TRUE, scrollX = TRUE,
                                     columnDefs = list(list(visible = FALSE, targets = hide_idx))),
                      filter = "top", rownames = FALSE) %>%
    DT::formatStyle(columns = names(df), fontSize = "11px")

  fcols <- intersect(filter_cols, names(df))
  filt  <- lapply(fcols, function(cc)
    crosstalk::filter_select(cc, cc, sd, stats::as.formula(paste0("~`", cc, "`"))))
  htmltools::tagList(
    if (length(filt)) do.call(crosstalk::bscols, filt) else NULL,
    p, dt)
}

## Unnest the upstream nested intervention-effects results (study, visit, res),
## where `res` is a list whose second element ("res") is the per-feature
## estimates data.frame. Returns a flat tibble with study and visit attached.
unnest_imic_results <- function(df) {
  if (is.null(df) || !nrow(df)) return(NULL)
  out <- lapply(seq_len(nrow(df)), function(i) {
    inner <- df$res[[i]]
    if (is.list(inner) && "res" %in% names(inner)) inner <- inner$res
    if (is.null(inner) || !is.data.frame(inner)) return(NULL)
    inner$study <- df$study[i]
    inner$visit <- df$visit[i]
    inner
  })
  dplyr::bind_rows(out)
}

## Try to convert a ggplot to plotly; if conversion fails (older ggplot
## internals, unsupported facet/coord combo, etc.) print the static plot.
print_interactive <- function(p, tooltip = "text") {
  if (!inherits(p, "gg")) { print(p); return(invisible(NULL)) }
  if (knitr::is_html_output() && requireNamespace("plotly", quietly = TRUE)) {
    conv <- try(plotly::ggplotly(p, tooltip = tooltip), silent = TRUE)
    if (!inherits(conv, "try-error")) { print(conv); return(invisible(NULL)) }
  }
  print(p)
}
