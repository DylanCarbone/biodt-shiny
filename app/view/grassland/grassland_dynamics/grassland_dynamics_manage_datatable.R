box::use(
  shiny[NS, moduleServer, tags, reactiveVal, observeEvent, checkboxInput, uiOutput, renderUI, req, actionButton, HTML],
  bslib[card, card_header, card_body],
  waiter[Waiter],
  DT[DTOutput, renderDT, datatable],
  dplyr[select]
)

box::use(
  app / logic / waiter[waiter_text],
)

#' @export
grassland_dynamics_manage_datatable_ui <- function(
  id,
  i18n
) {
  ns <- NS(id)
  card(
    id = ns("datatable"),
    class = "mx-md-3 card-shadow mb-2",
    card_header(
        tags$div(
          class = "d-flex justify-content-between align-items-center",
        tags$h2(
          class = "card_title",
          i18n$translate("Grassland Management Actions")
        ),
        uiOutput(ns("show_management_btn")),
      ),
      # checkboxInput(ns("show_mngmntdata"), "Show Management Data Table", value = FALSE, width = "200px")
    ),
    card_body(
        uiOutput(
          ns("mngmnt_data_table_wrap")
      )
    )
  )
}

#' @export
grassland_dynamics_manage_datatable_server <- function(id, data_table, tab_grassland_selected) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    data_table_reactive <- reactiveVal()
    data_table_reactive(data_table)

    # Define waiter ----
    msg <- waiter_text(message = tags$h3("Loading...", style = "color: #414f2f;"))
    w <- Waiter$new(
      id = ns("mngmnt_data_table_wrap"),
      html = msg,
      color = "rgba(256,256,256,0.9)",
    )
    
    # Reactive toggle for showing table
    show_managementtable <- reactiveVal(FALSE)
    
    div_table_wrap_tag <- tags$div(
      id = "div_table_wrap",
      DTOutput(ns("mngmnt_data_table"))
    )
    
    # Toggle button UI
    output$show_management_btn <- renderUI({
      icon_dir <- if (show_managementtable()) "up" else "down"
      icon_html <- sprintf('<i class="fa-solid fa-arrow-%s"></i>', icon_dir)
      actionButton(
        ns("show_management"),
        HTML(icon_html),
        class = "primary-button",
        `aria-expanded` = tolower(as.character(show_managementtable())),
        title = if (show_managementtable()) "Collapse management actions table" else "Expand management actions table"
      )
    })
    
    # Toggle reactive state
    observeEvent(input$show_management, {
      show_managementtable(!show_managementtable())
    })
    
    # Show or hide the datatable container
    observeEvent(show_managementtable(), ignoreInit = TRUE, {
      req(data_table_reactive())
      if (show_managementtable()) {
        output$mngmnt_data_table_wrap <- renderUI({
          div_table_wrap_tag
        })
      } else {
        output$mngmnt_data_table_wrap <- renderUI(NULL)
      }
    })
    
    # Render DT on tab change
    observeEvent(tab_grassland_selected(), ignoreNULL = TRUE, ignoreInit = TRUE, {
      w$show()
      req(data_table_reactive())
      output$mngmnt_data_table <- renderDT(
        datatable(
          data_table_reactive(),
          editable = list(target = "cell", disable = list(columns = c(0, 1, 2, 3, 4, 5, 6))),
          selection = "none",
          style = "auto",
          options = list(
            scrollX = TRUE,
            paging = TRUE,
            searching = TRUE,
            info = FALSE
          ),
          class = paste('cell-border stripe compact'),
          fillContainer = FALSE,
          rownames = FALSE
        )
      )
      w$hide()
    })
  })
}
