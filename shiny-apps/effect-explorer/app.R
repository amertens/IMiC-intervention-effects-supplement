# Intervention-Effect Explorer  ---------------------------------------------
# Standalone Shiny app, deployed to the online resource via shinylive
# (WebAssembly / webR) so it runs entirely in the browser on GitHub Pages —
# no server. It only *displays* the precomputed TMLE estimates; nothing is
# re-fitted here. Data live in ./data (the 12 subsetted result CSVs), bundled
# with the app at export time.
#
# Build (from the online-resource repo root):
#   source("build_apps.R")            # copies data in + shinylive::export()

library(shiny)
library(plotly)
library(DT)

# ---- outcome-group -> file-prefix map -------------------------------------
GROUPS <- c(
  "Macronutrients"                        = "primary_macro",
  "Micronutrients (incl. fat-soluble)"    = "primary_micro",
  "B-vitamins"                            = "primary_bvit",
  "HMOs"                                  = "secondary_hmo",
  "Bioactive proteins"                    = "secondary_bioactives",
  "Targeted metabolites (Biocrates)"      = "tertiary_targeted_metabolomics"
)

# ---- manuscript naming and figure conventions -------------------------------
# As in the rest of the online resource (functions.R): the printed trial names,
# visit labels, and component names, and the significance encodings of the
# printed figures (Fig. 2 for forests, Figs. 3A and 5A for volcanoes).
STUDY_NAMES <- c(Misame = "MISAME-III", Vital = "Mumta-LW", Elicit = "ELICIT")
VISIT_ORDER <- c("14-21 days", "1-2 mo.", "3-4 mo.", "1.5 mo.", "2 mo.", "1 mo.", "5 mo.")
LABELS <- c(
  "kcal.l"="Total Energy","fat"="Total Fat","protein"="Total Protein",
  "cho"="Total Carbohydrate","carbohydrate"="Total Carbohydrate",
  "as"="Arsenic","ca"="Calcium","cr"="Chromium","cu"="Copper","fe"="Iron","k"="Potassium",
  "mg"="Magnesium","mn"="Manganese","mo"="Molybdenum","na"="Sodium","p"="Phosphorus",
  "se"="Selenium","zn"="Zinc","choline"="Choline",
  "vitamin.a"="Vitamin A","a.tocopherol"="α-Tocopherol","g.tocopherol"="γ-Tocopherol",
  "b1"="Vitamin B₁","b2"="Vitamin B₂","b3"="Vitamin B₃","b6"="Vitamin B₆",
  "b12"="Vitamin B₁₂","pa"="Vitamin B₅","bio"="Vitamin B₇",
  "t"="Free Thiamin","tmp"="Thiamine Monophosphate","tpp"="Thiamine Pyrophosphate",
  "ribo"="Riboflavin","fmn"="Flavin Mononucleotide","fad"="Flavin Adenine Dinucleotide",
  "nam"="Nicotinamide","nad"="Nicotinamide Adenine Dinucleotide",
  "nmn"="Nicotinamide Mononucleotide","nr"="Nicotinamide Riboside",
  "nufa"="Nudifloramide","trp"="Tryptophan","pl"="Pyridoxal","pm"="Pyridoxamine",
  "pn"="Pyridoxine","plp"="Pyridoxal 5′-Phosphate",
  "fgf.21"="FGF-21","iga"="IgA","fsh"="Follicle-Stimulating Hormone",
  "lh"="Luteinizing Hormone","leptin"="Leptin","insulin"="Insulin",
  "calprotectin"="Calprotectin (S100A8/A9)")
TIERS <- c("Not significant", "Nominally significant", "FDR-significant")
# forest tiers (Fig. 2): grey open circle, blue open circle, orange filled circle
FOREST_COLS <- c("Not significant" = "grey60", "Nominally significant" = "#1F77B4",
                 "FDR-significant" = "#FF7F0E")
FOREST_SYMS <- c("Not significant" = "circle-open", "Nominally significant" = "circle-open",
                 "FDR-significant" = "circle")
# volcano (Figs. 3A, 5A): black circle / black square, FDR-significant points by
# component category, colour i with symbol i
CAT_COLS <- c("#0072B2", "#E69F00", "#009E73", "#D55E00", "#CC79A7", "#56B4E9", "#882255")
CAT_SYMS <- c("triangle-up", "diamond", "triangle-down", "asterisk-open", "x-thin-open",
              "cross-thin-open", "circle-cross-open")
PRIMARY_CATS <- c("Other B vitamins", "B2", "B3 or related", "B1", "B6", "Micronutrient", "Macronutrient")
# forest panels (one per trial and visit, in the order of the printed forest
# plots) and, for arm-stratified contrasts, one colour and CI line type per arm
PANEL_ORDER <- c("Mumta-LW (1.5 mo.)", "Mumta-LW (2 mo.)", "ELICIT (1 mo.)", "ELICIT (5 mo.)",
                 "MISAME-III (14-21 days)", "MISAME-III (1-2 mo.)", "MISAME-III (3-4 mo.)")
CONTRAST_COLS <- c("Nico" = "#0072B2", "Az." = "#882255", "Nico+Az." = "#CC79A7",
                   "IFA/BEP" = "#E69F00", "BEP/BEP" = "#D55E00", "BEP/IFA" = "#56B4E9",
                   "BEP+ExBf" = "#009E73", "BEP+ExBf+AZT" = "#000000", "BEP" = "#E69F00")
CONTRAST_LTY  <- c("Nico" = "solid", "Az." = "dashed", "Nico+Az." = "dotted",
                   "IFA/BEP" = "solid", "BEP/BEP" = "dashed", "BEP/IFA" = "dotted",
                   "BEP+ExBf" = "solid", "BEP+ExBf+AZT" = "dashed", "BEP" = "solid")
MAX_FOREST <- 3000   # more estimates than this cannot be read as a forest plot
LOGP_TITLE <- "–Log₁₀(P-value)"

read_group <- function(prefix, arm_coding) {
  f <- file.path("data", paste0(prefix, if (arm_coding == "Arm-stratified") "_arm_strat" else "", ".csv"))
  if (!file.exists(f)) return(NULL)
  d <- utils::read.csv(f, check.names = FALSE)
  s <- as.character(d$study)
  d$study <- ifelse(s %in% names(STUDY_NAMES), STUDY_NAMES[s], s)
  lab <- unname(LABELS[tolower(d$biomarker)])
  d$label_f <- ifelse(is.na(lab), as.character(d$label_f), lab)
  fsv <- is.na(d$category) & tolower(d$biomarker) %in% c("vitamin.a", "a.tocopherol", "g.tocopherol")
  d$category[fsv] <- "Micronutrient"   # grouped with the micronutrients, as in Fig. 2B
  d
}

# Volcano colour/symbol key for each row (tier for non-FDR rows, category otherwise).
volcano_key <- function(d) {
  cat <- as.character(d$category)
  if (any(!is.na(cat))) {
    share <- prop.table(table(cat))
    cat[cat %in% names(share)[share < 0.04]] <- "Other"
  }
  fdr_cats <- unique(cat[d$Significance == "FDR-significant" & !is.na(cat)])
  ord <- if (length(fdr_cats) && all(fdr_cats %in% PRIMARY_CATS)) PRIMARY_CATS
         else c(intersect("Triglycerides", fdr_cats), sort(setdiff(fdr_cats, "Triglycerides")))
  keep <- ord[seq_len(min(length(ord), length(CAT_COLS)))]
  key  <- ifelse(d$Significance != "FDR-significant", d$Significance,
          ifelse(!is.na(cat) & cat %in% keep, cat, "FDR-significant"))
  lv   <- c("Not significant", "Nominally significant", keep,
            if (any(key == "FDR-significant")) "FDR-significant")
  list(key  = factor(key, levels = lv),
       cols = c("Not significant" = "#000000", "Nominally significant" = "#000000",
                stats::setNames(CAT_COLS[seq_along(keep)], keep), "FDR-significant" = "#FF7F0E")[lv],
       syms = c("Not significant" = "circle", "Nominally significant" = "square",
                stats::setNames(CAT_SYMS[seq_along(keep)], keep), "FDR-significant" = "triangle-up")[lv])
}

# Faceted forest plot: one panel per trial and visit, arm-stratified contrasts
# dodged within each panel.
forest_fig <- function(d, arm_strat) {
  panels <- paste0(d$study, " (", d$visit, ")")
  d$panel <- factor(panels, levels = c(intersect(PANEL_ORDER, panels), setdiff(unique(panels), PANEL_ORDER)))
  ord <- sort(tapply(d$.est, as.character(d$label_f), mean, na.rm = TRUE))
  d$label_f <- factor(d$label_f, levels = names(ord))
  d$tier <- factor(d$Significance, levels = TIERS)
  d$tip <- paste0(d$label_f, "<br>", d$panel, " | ", d$contrast,
                  "<br>", signif(d$.est, 3), " (", signif(d$.cil, 3), ", ", signif(d$.ciu, 3), ")",
                  "<br>P ", signif(d$pval, 3), " | Q ", signif(d$.q, 3))
  p <- ggplot2::ggplot(d, ggplot2::aes(x = .est, y = label_f, text = tip)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "dashed", colour = "grey60")
  if (arm_strat) {
    dodge <- ggplot2::position_dodge(width = 0.7)
    cols <- CONTRAST_COLS[intersect(names(CONTRAST_COLS), unique(as.character(d$contrast)))]
    p <- p +
      ggplot2::geom_errorbar(ggplot2::aes(xmin = .cil, xmax = .ciu, colour = contrast,
                                          linetype = contrast, group = contrast),
                             width = 0, orientation = "y", position = dodge) +
      ggplot2::geom_point(ggplot2::aes(colour = contrast, shape = tier, group = contrast),
                          size = 1.8, position = dodge) +
      ggplot2::scale_colour_manual(values = cols, name = "Contrast") +
      ggplot2::scale_linetype_manual(values = CONTRAST_LTY[names(cols)], name = "Contrast") +
      ggplot2::scale_shape_manual(values = c(1, 2, 19), limits = TIERS, drop = FALSE,
                                  name = "Statistical Significance")
  } else {
    p <- p +
      ggplot2::geom_errorbar(ggplot2::aes(xmin = .cil, xmax = .ciu, colour = tier),
                             width = 0, orientation = "y") +
      ggplot2::geom_point(ggplot2::aes(colour = tier, shape = tier), size = 1.8) +
      ggplot2::scale_colour_manual(values = FOREST_COLS, limits = TIERS, drop = FALSE,
                                   name = "Statistical Significance") +
      ggplot2::scale_shape_manual(values = c(1, 1, 19), limits = TIERS, drop = FALSE,
                                  name = "Statistical Significance")
  }
  p <- p +
    ggplot2::facet_wrap(~ panel, ncol = 3) +
    ggplot2::labs(x = d$.xlab[1], y = NULL) +
    ggplot2::theme_bw(base_size = 11) +
    ggplot2::theme(panel.spacing = ggplot2::unit(1, "lines"), legend.position = "bottom")
  ggplotly(p, tooltip = "text") |>
    layout(legend = list(orientation = "h", y = -0.05, yanchor = "top"),
           margin = list(l = 10, r = 10, t = 40, b = 60))
}

# ---- UI --------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("IMiC intervention-effect explorer"),
  tags$p(style = "color:#555;",
         "Adjusted TMLE effects of the interventions on each milk component. ",
         "Hover over a point for its values. The app runs R in your browser, so the first load takes a moment."),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("grp", "Outcome group", choices = names(GROUPS)),
      radioButtons("arm", "Contrast coding",
                   choices = c("Combined (pooled vs control)" = "Combined",
                               "Arm-stratified"                = "Arm-stratified")),
      radioButtons("scale", "Effect scale",
                   choices = c("Standardized (SD units)" = "sd",
                               "Native assay units"       = "native")),
      uiOutput("study_ui"),
      uiOutput("visit_ui"),
      checkboxInput("fdr_only", "FDR-significant only (q < 0.05)", FALSE),
      tags$hr(),
      tags$small(tags$em("Source: IMiC intervention-effects analysis. Estimates are display-only."))
    ),
    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel("Volcano",   plotlyOutput("volcano", height = "560px")),
        tabPanel("Forest",    uiOutput("forest_ui")),
        tabPanel("Table",     DT::dataTableOutput("table"))
      )
    )
  )
)

# ---- server ----------------------------------------------------------------
server <- function(input, output, session) {

  raw <- reactive({
    d <- read_group(GROUPS[[input$grp]], input$arm)
    validate(need(!is.null(d) && nrow(d) > 0, "No data for this selection."))
    d
  })

  # dynamic study / visit choices
  output$study_ui <- renderUI({
    ch <- intersect(c("MISAME-III", "Mumta-LW", "ELICIT"), unique(as.character(raw()$study)))
    checkboxGroupInput("study", "Study", choices = ch, selected = ch)
  })
  output$visit_ui <- renderUI({
    v  <- unique(as.character(raw()$visit))
    ch <- c(intersect(VISIT_ORDER, v), setdiff(v, VISIT_ORDER))
    checkboxGroupInput("visit", "Visit", choices = ch, selected = ch)
  })

  # apply scale + filters
  dat <- reactive({
    d <- raw()
    if (identical(input$scale, "native") && all(c("est_unscaled","cil_unscaled","ciu_unscaled") %in% names(d))) {
      d$.est <- d$est_unscaled; d$.cil <- d$cil_unscaled; d$.ciu <- d$ciu_unscaled
      d$.q   <- if ("pval_adj_unscaled" %in% names(d)) d$pval_adj_unscaled else d$pval_adj
      d$.xlab <- "Average treatment effect (native assay units)"
    } else {
      d$.est <- d$est; d$.cil <- d$cil; d$.ciu <- d$ciu; d$.q <- d$pval_adj
      d$.xlab <- "Scaled average treatment effect (SD units)"
    }
    if (!is.null(input$study)) d <- d[as.character(d$study) %in% input$study, , drop = FALSE]
    if (!is.null(input$visit)) d <- d[as.character(d$visit) %in% input$visit, , drop = FALSE]
    if (isTRUE(input$fdr_only)) d <- d[!is.na(d$.q) & d$.q < 0.05, , drop = FALSE]
    d$Significance <- ifelse(!is.na(d$.q) & d$.q < 0.05, "FDR-significant",
                      ifelse(!is.na(d$pval) & d$pval < 0.05, "Nominally significant", "Not significant"))
    d$neglog10p <- -log10(pmax(d$pval, .Machine$double.eps))
    d
  })

  # Colour and symbol together carry significance (and, in the volcano, the
  # category of FDR-significant components), so neither rests on colour alone.
  ref_lines <- function(p_line) {
    c(list(list(type = "line", x0 = 0, x1 = 0, yref = "paper", y0 = 0, y1 = 1,
                line = list(dash = "dash", color = "black", width = 1))),
      if (p_line) list(list(type = "line", xref = "paper", x0 = 0, x1 = 1,
                            y0 = -log10(0.05), y1 = -log10(0.05),
                            line = list(color = "#BAB0AC", width = 1))))
  }

  output$volcano <- renderPlotly({
    d <- dat(); validate(need(nrow(d) > 0, "No rows match the current filters."))
    k <- volcano_key(d); d$key <- k$key
    plot_ly(d, x = ~.est, y = ~neglog10p, type = "scatter", mode = "markers",
            color = ~key, colors = k$cols, symbol = ~key, symbols = unname(k$syms),
            text = ~paste0(label_f, "<br>", study, " (", visit, ") | ", contrast,
                           "<br>ATE ", signif(.est, 3), " | P ", signif(pval, 3), " | Q ", signif(.q, 3)),
            hoverinfo = "text", marker = list(size = 7, opacity = 0.75)) |>
      layout(xaxis = list(title = d$.xlab[1]), yaxis = list(title = LOGP_TITLE),
             legend = list(orientation = "h"), shapes = ref_lines(TRUE))
  })

  # One panel per trial and visit, so estimates of the same component from
  # different trials and visits no longer share a row; arm-stratified contrasts
  # are dodged within each panel, each in its own colour and CI line type, with
  # the significance tier carried by the symbol (as in the rest of the site).
  forest_height <- reactive({
    d <- dat()
    n_comp  <- length(unique(d$label_f))
    n_rows  <- ceiling(length(unique(paste(d$study, d$visit))) / 3)
    per     <- if (identical(input$arm, "Arm-stratified")) 26 else 16
    max(450, min(6000, n_rows * (n_comp * per + 70) + 140))
  })
  output$forest_ui <- renderUI(plotlyOutput("forest", height = paste0(forest_height(), "px")))

  output$forest <- renderPlotly({
    d <- dat(); validate(need(nrow(d) > 0, "No rows match the current filters."))
    validate(need(nrow(d) <= MAX_FOREST, sprintf(
      "%s estimates are too many for a forest plot. Narrow the selection with the trial, visit, or FDR filters, or use the volcano or table view.",
      format(nrow(d), big.mark = ","))))
    forest_fig(d, arm_strat = identical(input$arm, "Arm-stratified"))
  })

  output$table <- DT::renderDataTable({
    d <- dat()
    cols <- intersect(c("study","visit","contrast","category","label_f",
                        ".est",".cil",".ciu","pval",".q","sigFDR"), names(d))
    out <- d[, cols, drop = FALSE]
    names(out)[names(out) == ".est"] <- "effect"
    names(out)[names(out) == ".cil"] <- "ci_low"
    names(out)[names(out) == ".ciu"] <- "ci_high"
    names(out)[names(out) == ".q"]   <- "q"
    num <- vapply(out, is.numeric, logical(1))
    out[num] <- lapply(out[num], function(x) signif(x, 3))
    DT::datatable(out, filter = "top", rownames = FALSE,
                  options = list(pageLength = 15, scrollX = TRUE))
  })
}

shinyApp(ui, server)
