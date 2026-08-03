# Intervention-Effect Explorer  ---------------------------------------------
# Standalone Shiny app, deployed to the online supplement via shinylive
# (WebAssembly / webR) so it runs entirely in the browser on GitHub Pages —
# no server. It only *displays* the precomputed TMLE estimates; nothing is
# re-fitted here. Data live in ./data (the 12 subsetted result CSVs), bundled
# with the app at export time.
#
# Build (from the supplement repo root):
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

read_group <- function(prefix, arm_coding) {
  f <- file.path("data", paste0(prefix, if (arm_coding == "Arm-stratified") "_arm_strat" else "", ".csv"))
  if (!file.exists(f)) return(NULL)
  utils::read.csv(f, check.names = FALSE)
}

# ---- UI --------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("IMiC — Intervention-Effect Explorer"),
  tags$p(style = "color:#555;",
         "Every point is one human-milk component (adjusted TMLE effect vs. control). ",
         "Filter with the controls; hover for details. This app runs in your browser — ",
         "the first load fetches the R runtime, then it is instant."),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("grp", "Outcome group", choices = names(GROUPS)),
      radioButtons("arm", "Contrast coding",
                   choices = c("Combined (pooled vs control)" = "Combined",
                               "Arm-stratified"                = "Arm-stratified")),
      radioButtons("scale", "Effect scale",
                   choices = c("Standardised (SD units)" = "sd",
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
        tabPanel("Forest",    plotlyOutput("forest",  height = "700px")),
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
    ch <- sort(unique(as.character(raw()$study)))
    checkboxGroupInput("study", "Study", choices = ch, selected = ch)
  })
  output$visit_ui <- renderUI({
    ch <- unique(as.character(raw()$visit))
    checkboxGroupInput("visit", "Visit", choices = ch, selected = ch)
  })

  # apply scale + filters
  dat <- reactive({
    d <- raw()
    if (identical(input$scale, "native") && all(c("est_unscaled","cil_unscaled","ciu_unscaled") %in% names(d))) {
      d$.est <- d$est_unscaled; d$.cil <- d$cil_unscaled; d$.ciu <- d$ciu_unscaled
      d$.q   <- if ("pval_adj_unscaled" %in% names(d)) d$pval_adj_unscaled else d$pval_adj
      d$.xlab <- "Effect (native assay units)"
    } else {
      d$.est <- d$est; d$.cil <- d$cil; d$.ciu <- d$ciu; d$.q <- d$pval_adj
      d$.xlab <- "Effect (SD units)"
    }
    if (!is.null(input$study)) d <- d[as.character(d$study) %in% input$study, , drop = FALSE]
    if (!is.null(input$visit)) d <- d[as.character(d$visit) %in% input$visit, , drop = FALSE]
    if (isTRUE(input$fdr_only)) d <- d[!is.na(d$.q) & d$.q < 0.05, , drop = FALSE]
    d$Significance <- ifelse(!is.na(d$.q) & d$.q < 0.05, "q < 0.05",
                      ifelse(!is.na(d$pval) & d$pval < 0.05, "p < 0.05", "ns"))
    d$neglog10p <- -log10(pmax(d$pval, .Machine$double.eps))
    d
  })

  pal <- c("ns" = "grey70", "p < 0.05" = "#1F77B4", "q < 0.05" = "#FF7F0E")

  output$volcano <- renderPlotly({
    d <- dat(); validate(need(nrow(d) > 0, "No rows match the current filters."))
    plot_ly(d, x = ~.est, y = ~neglog10p, type = "scatter", mode = "markers",
            color = ~factor(Significance, names(pal)), colors = pal,
            text = ~paste0(label_f, "<br>", study, " | ", visit, " | ", contrast,
                           "<br>effect ", signif(.est, 3), " | q ", signif(.q, 3)),
            hoverinfo = "text", marker = list(size = 7, opacity = 0.6)) |>
      layout(xaxis = list(title = d$.xlab[1]), yaxis = list(title = "-log10(p)"),
             legend = list(orientation = "h"),
             shapes = list(list(type = "line", x0 = 0, x1 = 0, yref = "paper",
                                y0 = 0, y1 = 1, line = list(dash = "dash", color = "grey50"))))
  })

  output$forest <- renderPlotly({
    d <- dat(); validate(need(nrow(d) > 0, "No rows match the current filters."))
    d <- d[order(d$.est), ]; d$label_f <- factor(d$label_f, levels = unique(d$label_f))
    plot_ly(d, x = ~.est, y = ~label_f, type = "scatter", mode = "markers",
            color = ~factor(Significance, names(pal)), colors = pal,
            error_x = list(type = "data", symmetric = FALSE,
                           array = ~(.ciu - .est), arrayminus = ~(.est - .cil)),
            text = ~paste0(study, " | ", visit, " | ", contrast,
                           "<br>", signif(.est,3), " (", signif(.cil,3), ", ", signif(.ciu,3), ")"),
            hoverinfo = "text", marker = list(size = 7)) |>
      layout(xaxis = list(title = d$.xlab[1]), yaxis = list(title = ""),
             legend = list(orientation = "h"),
             shapes = list(list(type = "line", x0 = 0, x1 = 0, yref = "paper",
                                y0 = 0, y1 = 1, line = list(dash = "dash", color = "grey50"))))
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
