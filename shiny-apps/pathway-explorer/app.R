# Pathway-Enrichment Explorer  ----------------------------------------------
# Standalone Shiny app deployed via shinylive (webR) — runs in the browser on
# GitHub Pages, no server. Displays the scripted MetaboAnalystR enrichment
# outputs (manuscript Tables S1–S6) from ./data; nothing is recomputed.
#
# The six enrichment result files have different schemas, so each is mapped to
# a common frame: pathway | study | timepoint | contrast | direction | p | fdr | enrichment.

library(shiny)
library(plotly)
library(DT)

# ---- analysis catalogue ----------------------------------------------------
# type drives the column harmonisation in harmonize().
ANALYSES <- list(
  "Primary ORA (Table S1)" = list(
    type = "ora_primary",
    files = c(Combined = "primary_combined_supplementary_table.csv",
              `Arm-stratified` = "primary_stratified_supplementary_table.csv")),
  "Tertiary MSEA (Table S2)" = list(
    type = "msea",
    files = c(Combined = "tertiary_msea_combined.csv",
              `Arm-stratified` = "tertiary_msea_stratified.csv")),
  "Triglyceride fatty-acids (Table S3)" = list(
    type = "tgfa",
    files = c(`Arm-stratified` = "triglyceride_fa_composition_stratified.csv")),
  "Untargeted MSEA (Table S4)" = list(
    type = "msea",
    files = c(Combined = "untargeted_msea_combined.csv")),
  "Milk Mummichog (Table S5)" = list(
    type = "mummichog",
    files = c(Combined = "milk_mummichog_tableS5.csv")),
  "Milk proteome GO (Table S6)" = list(
    type = "go",
    files = c(Combined = "proteomics_go_tableS6.csv"))
)

read_csv0 <- function(f) {
  p <- file.path("data", f)
  if (!file.exists(p)) return(NULL)
  d <- utils::read.csv(p, check.names = FALSE)
  if (!nrow(d)) NULL else d
}

# map a source table to the common frame
harmonize <- function(d, type) {
  g <- function(nm) if (nm %in% names(d)) d[[nm]] else NA
  out <- switch(type,
    ora_primary = data.frame(pathway = g("pathway"), study = g("study"),
                             timepoint = g("studytime"), contrast = g("contrast"),
                             direction = g("direction"), p = g("raw_p"), fdr = g("fdr_native"),
                             enrichment = NA_real_, stringsAsFactors = FALSE),
    msea = data.frame(pathway = g("pathway"), study = g("study"),
                      timepoint = g("timepoint"), contrast = g("contrast"),
                      direction = g("direction"), p = g("raw_p"), fdr = g("fdr_native"),
                      enrichment = g("enrichment_ratio"), stringsAsFactors = FALSE),
    tgfa = data.frame(pathway = g("fatty_acid_name"), study = g("study"),
                      timepoint = g("timepoint"), contrast = g("contrast"),
                      direction = g("direction"), p = g("raw_p"), fdr = g("fdr_native"),
                      enrichment = g("enrichment_ratio"), stringsAsFactors = FALSE),
    mummichog = data.frame(pathway = g("Pathway"), study = g("Study"),
                           timepoint = g("Time Point"), contrast = g("Contrast"),
                           direction = g("Regulation"), p = g("P-value"), fdr = g("FDR"),
                           enrichment = g("Enrichment Ratio"), stringsAsFactors = FALSE),
    go = data.frame(pathway = g("Description"), study = g("study"),
                    timepoint = g("timepoint"), contrast = g("contrast"),
                    direction = g("regulation"), p = g("p_value"), fdr = g("fdr"),
                    enrichment = g("fold_enrichment"), stringsAsFactors = FALSE)
  )
  out[!is.na(out$pathway) & out$pathway != "", , drop = FALSE]
}

# ---- UI --------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("IMiC — Pathway-Enrichment Explorer"),
  tags$p(style = "color:#555;",
         "Scripted MetaboAnalystR enrichment across studies, timepoints, and contrasts ",
         "(manuscript Tables S1–S6). Pick an analysis, filter, and read the enriched ",
         "pathways. Runs in your browser; the first load fetches the R runtime."),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("analysis", "Analysis", choices = names(ANALYSES)),
      uiOutput("arm_ui"),
      uiOutput("study_ui"),
      uiOutput("time_ui"),
      radioButtons("fdr_only", "Show",
                   choices = c("FDR-significant (q < 0.05)" = "sig", "All pathways" = "all")),
      sliderInput("topn", "Max pathways in plot", min = 10, max = 60, value = 30, step = 5),
      tags$hr(),
      tags$small(tags$em("Significance flag: fdr < 0.05. Display-only."))
    ),
    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel("Dot plot", plotlyOutput("dot", height = "640px")),
        tabPanel("Table", DT::dataTableOutput("table"))
      )
    )
  )
)

# ---- server ----------------------------------------------------------------
server <- function(input, output, session) {

  spec <- reactive(ANALYSES[[input$analysis]])

  output$arm_ui <- renderUI({
    fs <- names(spec()$files)
    if (length(fs) > 1) radioButtons("arm", "Contrast coding", choices = fs)
    else tagList(tags$label("Contrast coding"), tags$p(fs))
  })

  base <- reactive({
    sp <- spec()
    arm <- if (!is.null(input$arm)) input$arm else names(sp$files)[1]
    d <- read_csv0(sp$files[[arm]])
    validate(need(!is.null(d), "No data for this selection."))
    h <- harmonize(d, sp$type)
    h$p <- suppressWarnings(as.numeric(h$p)); h$fdr <- suppressWarnings(as.numeric(h$fdr))
    h$enrichment <- suppressWarnings(as.numeric(h$enrichment))
    h
  })

  output$study_ui <- renderUI({
    ch <- sort(unique(as.character(base()$study))); ch <- ch[!is.na(ch)]
    if (length(ch) > 1) checkboxGroupInput("study", "Study", choices = ch, selected = ch)
  })
  output$time_ui <- renderUI({
    ch <- unique(as.character(base()$timepoint)); ch <- ch[!is.na(ch)]
    if (length(ch) > 1) checkboxGroupInput("time", "Timepoint", choices = ch, selected = ch)
  })

  filt <- reactive({
    d <- base()
    if (!is.null(input$study) && "study" %in% names(d)) d <- d[as.character(d$study) %in% input$study, , drop = FALSE]
    if (!is.null(input$time)  && "timepoint" %in% names(d)) d <- d[as.character(d$timepoint) %in% input$time, , drop = FALSE]
    if (identical(input$fdr_only, "sig")) d <- d[!is.na(d$fdr) & d$fdr < 0.05, , drop = FALSE]
    d
  })

  output$dot <- renderPlotly({
    d <- filt(); validate(need(nrow(d) > 0, "No pathways match the current filters."))
    d$stratum <- paste(d$study, d$timepoint, d$contrast, sep = " | ")
    d$neglogfdr <- -log10(pmax(d$fdr, .Machine$double.eps))
    # keep the strongest rows per pathway, then top-N pathways
    ord <- order(d$neglogfdr, decreasing = TRUE)
    d <- d[ord, ]
    keep_paths <- unique(d$pathway)[seq_len(min(input$topn, length(unique(d$pathway))))]
    d <- d[d$pathway %in% keep_paths, , drop = FALSE]
    d$pathway <- factor(d$pathway, levels = rev(unique(d$pathway[order(d$neglogfdr)])))
    plot_ly(d, x = ~neglogfdr, y = ~pathway, type = "scatter", mode = "markers",
            color = ~as.character(direction),
            size = ~pmax(neglogfdr, 0.1), sizes = c(30, 300),
            text = ~paste0(pathway, "<br>", stratum, "<br>direction ", direction,
                           "<br>q ", signif(fdr, 3), " | p ", signif(p, 3),
                           if (all(!is.na(enrichment))) paste0("<br>enrichment ", signif(enrichment, 3)) else ""),
            hoverinfo = "text", marker = list(opacity = 0.7)) |>
      layout(xaxis = list(title = "-log10(FDR)"), yaxis = list(title = ""),
             legend = list(orientation = "h", title = list(text = "direction")),
             shapes = list(list(type = "line", x0 = -log10(0.05), x1 = -log10(0.05),
                                yref = "paper", y0 = 0, y1 = 1,
                                line = list(dash = "dot", color = "grey50"))))
  })

  output$table <- DT::renderDataTable({
    d <- filt()
    d <- d[, c("pathway","study","timepoint","contrast","direction","p","fdr","enrichment")]
    d$p <- signif(d$p, 3); d$fdr <- signif(d$fdr, 3); d$enrichment <- signif(d$enrichment, 3)
    DT::datatable(d, filter = "top", rownames = FALSE,
                  options = list(pageLength = 15, scrollX = TRUE))
  })
}

shinyApp(ui, server)
