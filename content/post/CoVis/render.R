library(tidyverse)
library(htmltools)
states <- readRDS("states.rds")
future::plan(future::multiprocess, workers = 4)
.render <- furrr::future_imap(states, ~{
  .st <- state.abb[state.name %in% .y]
  if (.rerender) {
    .fns <- purrr::imap(.x$g, ~{
      .fn <- paste0("images/",.st, "_",.y,".png")
      .g <- gridExtra::grid.arrange(gridExtra::arrangeGrob(
        grobs = .x[3:1],
        nrow = 3,
        heights = ggplot2::unit(c(2, 2.5, 4), "in")
      ))
      ggplot2::ggsave(.fn, plot = .g, device = "png", dpi = 72, units = "in", height = 8.7, width = 6.1)
      .fn
      
    })
  }
  .imgs <- purrr::map(.fns, ~{
    .img <- htmltools::tags$img(width = "100%", src = paste0("data:image/png;base64,", RCurl::base64Encode(readBin(.x, "raw", file.info(.x)[1, "size"]), "txt")), style = "margin:auto;")
  })
  
  
  .tL <- tagList(shiny::fluidRow(width = 12, 
                                 tags$h3(id = stringr::str_replace(tolower(.y), "\\s", "-"), .y)))
  .tL[[length(.tL) + 1]] <- tagList(shiny::fluidRow(width = 12, tags$strong(paste0(stringr::str_split(.x$dates_txt, "\n")[[1]], collapse = ", "))))
  .tL[[length(.tL) + 1]] <-
    tagList(
      shiny::fluidRow(
        width = 12,
        style = "text-align:center;margin:auto;",
        shiny::column(6, .imgs[[1]]),
        shiny::column(6, .imgs[[2]])
      ),
      shiny::fluidRow(width = 12,
                      shiny::column(6, tags$p(
                        paste0("Open: ", paste0(.x$open, collapse = ", "))
                      )),
                      shiny::column(6, tags$p(
                        paste0("Closed: ", paste0(.x$closed, collapse = ", "))
                      ))),
      shiny::fluidRow(width = 12, tags$hr())
    )
  return(.tL)
})
saveRDS(.render, "render.rds")