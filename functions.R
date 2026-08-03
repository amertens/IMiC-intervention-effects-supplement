## Shared helpers for the IMiC intervention-effects supplement.
## Loaded by individual chapter Rmds via source("functions.R") (or here()).

tableau10 <- c("#1F77B4","#FF7F0E","#2CA02C","#D62728",
               "#9467BD","#8C564B","#E377C2","#7F7F7F","#BCBD22","#17BECF")

## Standard study/visit factor levels used across chapters.
.harmonize_factors <- function(tab) {
  if ("study" %in% names(tab)) {
    tab$study <- as.character(tab$study)
    tab$study[tab$study == "Vital"]          <- "Mumta-LW"
    tab$study[tab$study == "VITAL-Lactation"] <- "Mumta-LW"
    tab$study <- factor(tab$study, levels = c("Misame", "MISAME-3", "MISAME-III",
                                              "Mumta-LW", "Elicit", "ELICIT"))
    tab$study <- droplevels(tab$study)
  }
  if ("visit" %in% names(tab)) {
    tab$visit <- factor(tab$visit, levels = c("14-21 days","1-2 mo.","3-4 mo.",
                                              "1 mo.","1.5 mo.","2 mo.","5 mo."))
  }
  if ("label_f" %in% names(tab)) {
    tab$label_f[tab$label_f == "Total Carbohydrate"] <- "Total Carbohydrates"
  }
  ## Upstream tables sometimes carry only chi_pval / chi_pval_adj. Alias them
  ## to pval / pval_adj so downstream plotting and tabulation works uniformly.
  if (!"pval" %in% names(tab) && "chi_pval" %in% names(tab)) tab$pval <- tab$chi_pval
  if (!"pval_adj" %in% names(tab) && "chi_pval_adj" %in% names(tab)) tab$pval_adj <- tab$chi_pval_adj
  tab
}

## Interactive forest plot. Renders a plotly hoverable forest when `interactive`
## is TRUE (HTML output), otherwise returns the static ggplot.
forest_plot <- function(tab, arm_strat = FALSE, interactive = TRUE,
                        title = "Forest Plot of Estimates") {
  tab <- .harmonize_factors(tab)
  tab$sigFDR <- factor(tab$sigFDR, levels = c(0, 1))
  tab$sig    <- factor(tab$sig,    levels = c(0, 1))
  ## plotly's ggplotly() trips on facet_wrap(study ~ visit) when the panel
  ## grid has empty cells (most study × visit grids do). Build a single
  ## combined facet column so plotly only sees a 1-D facet sequence.
  if (all(c("study","visit") %in% names(tab))) {
    tab$panel <- factor(paste0(tab$study, " — ", tab$visit))
  } else if ("study" %in% names(tab)) {
    tab$panel <- factor(tab$study)
  } else {
    tab$panel <- factor("All")
  }
  tab <- tab %>% dplyr::mutate(
    sigcat = dplyr::case_when(
      sigFDR == 1 & sig == 1 ~ "Sig",
      sigFDR == 0 & sig == 1 ~ "Sig before FDR",
      TRUE                   ~ "Not Significant"
    ),
    sigcat = factor(sigcat, levels = c("Not Significant","Sig before FDR","Sig")),
    tooltip = paste0(label_f,
                     "<br>Study: ", study, " | Visit: ", visit,
                     if ("contrast" %in% names(tab)) paste0("<br>Contrast: ", contrast) else "",
                     "<br>ATE: ", round(est, 3),
                     " (", round(cil, 3), ", ", round(ciu, 3), ")",
                     if ("pval_adj" %in% names(tab)) paste0("<br>q = ", signif(pval_adj, 3)) else "")
  )

  ## Note: plotly's ggplotly() fails when coord_flip() is combined with
  ## facet_wrap(). To get a horizontal forest, we therefore set y=label_f and
  ## x=est directly and skip coord_flip(). geom_errorbarh() supplies the
  ## horizontal error bars.
  if (arm_strat) {
    p <- ggplot2::ggplot(tab, ggplot2::aes(y = stats::reorder(label_f, est), x = est,
                                           color = contrast, shape = sigcat,
                                           group = contrast, text = tooltip)) +
      ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.5), size = 2) +
      ggplot2::geom_errorbar(ggplot2::aes(xmin = cil, xmax = ciu),
                             width = 0.2, orientation = "y",
                             position = ggplot2::position_dodge(width = 0.5)) +
      ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      ggplot2::scale_shape_manual(values = c(1, 19, 17)) +
      ggplot2::scale_color_manual(values = tableau10) +
      ggplot2::facet_wrap(~ panel) +
      ggplot2::labs(title = title, y = "Outcome", x = "Estimate (SD units)") +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "right")
  } else {
    p <- ggplot2::ggplot(tab, ggplot2::aes(y = stats::reorder(label_f, est), x = est,
                                           color = sigFDR, shape = sig, text = tooltip)) +
      ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.5), size = 2) +
      ggplot2::geom_errorbar(ggplot2::aes(xmin = cil, xmax = ciu),
                             width = 0.2, orientation = "y",
                             position = ggplot2::position_dodge(width = 0.5)) +
      ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      ggplot2::scale_shape_manual(values = c(1, 19),
                                  labels = c("Not Significant","Significant")) +
      ggplot2::scale_color_manual(values = c("grey60", tableau10[2]),
                                  labels = c("Not Significant","Significant (FDR)")) +
      ggplot2::facet_wrap(~ panel) +
      ggplot2::labs(title = title, y = "Outcome", x = "Estimate (SD units)") +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "none")
  }

  if (interactive && requireNamespace("plotly", quietly = TRUE) &&
      knitr::is_html_output()) {
    conv <- try(plotly::ggplotly(p, tooltip = "text"), silent = TRUE)
    if (!inherits(conv, "try-error")) return(conv)
  }
  p
}

## Interactive volcano plot. `tab` must have est, pval, pval_adj, label_f.
volcano_plot <- function(tab, fdr_thresh = 0.05, interactive = TRUE,
                         title = "Volcano plot",
                         x_lab = "Estimate (SD units)") {
  tab <- .harmonize_factors(tab)
  tab <- tab %>%
    dplyr::mutate(
      sig_label = dplyr::case_when(
        pval_adj < fdr_thresh ~ paste0("Significant (q<", fdr_thresh, ")"),
        pval < 0.05           ~ "Nominal p<0.05",
        TRUE                  ~ "ns"
      ),
      sig_label = factor(sig_label, levels = c("ns","Nominal p<0.05",
                                               paste0("Significant (q<", fdr_thresh, ")"))),
      neglog10p = -log10(pmax(pval, .Machine$double.eps)),
      tooltip = paste0(label_f,
                       if ("study" %in% names(tab)) paste0("<br>Study: ", study) else "",
                       if ("visit" %in% names(tab)) paste0(" | Visit: ", visit) else "",
                       "<br>est: ", signif(est, 3),
                       "<br>p: ", signif(pval, 3),
                       "<br>q: ", signif(pval_adj, 3))
    )

  facet_layer <- NULL
  if ("study" %in% names(tab) && "visit" %in% names(tab)) {
    facet_layer <- ggplot2::facet_wrap(study ~ visit, scales = "free")
  } else if ("study" %in% names(tab)) {
    facet_layer <- ggplot2::facet_wrap(~ study, scales = "free")
  }

  p <- ggplot2::ggplot(tab, ggplot2::aes(x = est, y = neglog10p,
                                         color = sig_label, text = tooltip)) +
    ggplot2::geom_point(alpha = 0.6, size = 1.4) +
    ggplot2::geom_hline(yintercept = -log10(0.05), linetype = "dotted", color = "grey50") +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
    ggplot2::scale_color_manual(values = c("grey70", tableau10[1], tableau10[2]), drop = FALSE) +
    facet_layer +
    ggplot2::labs(title = title, x = x_lab, y = "-log10(p)", color = NULL) +
    ggplot2::theme_minimal()

  if (interactive && requireNamespace("plotly", quietly = TRUE) &&
      knitr::is_html_output()) {
    conv <- try(plotly::ggplotly(p, tooltip = "text"), silent = TRUE)
    if (!inherits(conv, "try-error")) return(conv)
  }
  p
}

## Render an estimates table with consistent column formatting and download buttons.
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

## Generic DT renderer with filters + CSV download. Use for any tabular result.
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
show_any <- function(x) {
  if (is.null(x)) return(invisible(NULL))
  if (inherits(x, c("plotly","htmlwidget"))) { print(x); return(invisible(NULL)) }
  if (inherits(x, "gg")) {
    ## Older saved ggplot objects sometimes fail ggplotly() conversion because
    ## of changes to the internal S4 slots; fall back to a static print on error.
    if (knitr::is_html_output() && requireNamespace("plotly", quietly = TRUE)) {
      conv <- try(plotly::ggplotly(x), silent = TRUE)
      if (!inherits(conv, "try-error")) { print(conv); return(invisible(NULL)) }
    }
    print(x); return(invisible(NULL))
  }
  if (is.data.frame(x)) { print(nice_dt(x)); return(invisible(NULL)) }
  if (is.list(x)) {
    for (i in seq_along(x)) {
      cat(sprintf("\n\n**%s**\n\n", names(x)[i] %||% paste0("Panel ", i)))
      show_any(x[[i]])
    }
    return(invisible(NULL))
  }
  print(x)
}

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

## For high-cardinality feature tables, cap the points shown in the
## interactive volcano so the rendered HTML stays a reasonable size, while
## still allowing the full table to be inspected separately via DT.
## Returns the volcano widget (or static ggplot fallback). Emits a one-line
## sub-cap via cat() when the data has been down-sampled — requires the
## calling chunk to use results='asis'.
volcano_capped <- function(df, n_show = 2000, ...) {
  if (is.null(df) || !nrow(df)) { cat("*No rows to plot.*\n\n"); return(invisible(NULL)) }
  if (nrow(df) > n_show && "pval" %in% names(df)) {
    df_show <- df %>% dplyr::arrange(pval) %>% dplyr::slice_head(n = n_show)
    cat(sprintf("\n*Interactive volcano shows top %s features by raw p-value (of %s total); full table below contains every feature.*\n\n",
                format(n_show, big.mark = ","), format(nrow(df), big.mark = ",")))
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
                                 x_lab = "Estimate (SD units)",
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
  df$neglog10p   <- -log10(pmax(df$pval, .Machine$double.eps))
  df$Significance <- factor(
    ifelse(df$pval_adj < fdr_thresh, paste0("q < ", fdr_thresh),
    ifelse(df$pval < 0.05,           "p < 0.05", "ns")),
    levels = c("ns", "p < 0.05", paste0("q < ", fdr_thresh)))
  df$tooltip <- paste0(df[[key_col]],
                       if ("study" %in% names(df)) paste0("<br>", df$study) else "",
                       if ("visit" %in% names(df)) paste0(" | ", df$visit) else "",
                       "<br>est ", signif(df$est, 3), " | p ", signif(df$pval, 3),
                       " | q ", signif(df$pval_adj, 3))
  keep <- union(intersect(show_cols, names(df)), c("neglog10p", "Significance", "tooltip", "est"))
  df   <- df[, intersect(keep, names(df)), drop = FALSE]

  if (!knitr::is_html_output() || !requireNamespace("crosstalk", quietly = TRUE)) {
    return(nice_dt(df[, setdiff(names(df), c("neglog10p","Significance","tooltip")), drop = FALSE]))
  }
  sd <- crosstalk::SharedData$new(df)

  p <- plotly::plot_ly(sd, x = ~est, y = ~neglog10p, type = "scatter", mode = "markers",
                       color = ~Significance,
                       colors = stats::setNames(c("grey70", tableau10[1], tableau10[2]),
                                                levels(df$Significance)),
                       text = ~tooltip, hoverinfo = "text",
                       marker = list(size = 6, opacity = 0.6)) %>%
    plotly::layout(title = list(text = title), xaxis = list(title = x_lab),
                   yaxis = list(title = "-log10(p)"), legend = list(orientation = "h"),
                   shapes = list(list(type = "line", x0 = 0, x1 = 0, yref = "paper",
                                      y0 = 0, y1 = 1, line = list(dash = "dash", color = "grey50")))) %>%
    plotly::highlight(on = "plotly_selected", off = "plotly_deselect", persistent = FALSE)

  hide_idx <- which(names(df) %in% c("neglog10p", "Significance", "tooltip")) - 1
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
