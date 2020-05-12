pchange <- function(x) {
  .v <- (x - dplyr::lead(x)) / dplyr::lead(x) %|% 0
  .out <- try(purrr::map_dbl(.v, ~{
    if (is.infinite(.x))
      .out <- 0
    else if (is.na(.x) || is.nan(.x)) 
      .out <- 0
    else
      .out <- .x
    return(.out)
  }))
  browser(expr = (class(.out) == "try-error" || any(is.nan(.out))) )
  return(.out)
}
pettit.state <- function(st, begin = NULL, end = NULL, covid_data = NULL) {
  out <- list()
  if (inherits(st, "character")) {
    # if a character
    .dates <- list(b = begin, e = end)
    .st <- ifelse(nchar(st) == 2, state.name[state.abb %in% st], st)
  } else {
    # a scraped list
    .st <- names(st)
    st <- st[[1]]
    if (!is.null(st$dates)) .dates <- setNames(st$dates, c("b", "e"))
    if (length(st$open) > 0) {
      out$open <- st$open[[1]][!is.na(st$open[[1]])]
      if (length(st$open) > 1) out$closed <- st$open[[2]][!is.na(st$open[[1]])]
    }
    
  }
  .dt <- NULL
  `-` <- lubridate::`.__T__-:base`
  if (!is.null(.dates)) {
    .dates <- purrr::imap(.dates, ~{
      if (stringr::str_detect(.x, "^[A-Z]")) .x <- paste0(.x, ", 2020")
      if (nchar(.x) > 1) {
        .out <- lubridate::as_date(lubridate::parse_date_time(.x, orders = c("ymd", "mdy", "dmy")))
        if (.y == "e") .dt <<- lubridate::today() - .out
      } else {
        .out <- NULL
      }
      return(.out)
    })
    out$dates <- .dates
    .sub <- ""
    if (inherits(.dates$b, c("Date","POSIXct"))) {
      .sub <- paste0(.sub,"Restrictions began on ", .dates$b)
    } else {
      .sub <- paste0(.sub, "No restrictions put in place")
    }
    if (inherits(.dates$e, c("Date","POSIXct"))) {
      .sub <- paste0(.sub,"\nRestrictions lift on ", .dates$e)
    }
    out$dates_txt <- .sub
  }
  
  if (is.null(.dates$b)) {
    .filter <- lubridate::ymd("2020-04-01")
  } else {
    .filter <- .dates$b
  }
    
 
  
  .d <- covid_data %>%
    dplyr::filter(state %in% .st) %>%
    dplyr::arrange(desc(date)) %>% 
    dplyr::filter(date > .filter - lubridate::days(2)) %>% 
    dplyr::mutate(dd_cases = cases - dplyr::lead(cases), dd_deaths = deaths - dplyr::lead(deaths)) %>% 
    dplyr::mutate(p_cases = pchange(dd_cases), p_deaths = pchange(dd_deaths)) %>% 
    dplyr::filter(date > .filter)
    
  
  g <- purrr::map(setNames(1:3, c("","dd_","p_")), ~{
    .out <- .d %>% 
    ggplot(data = .,
           mapping = aes(x = date)) +
    scale_x_date(date_breaks = "1 week", date_minor_breaks = "1 days", date_labels = "%m/%d") +
    theme(plot.margin = unit(c(0,rep(.2,3)), "lines"),
          plot.background = element_rect(fill = "transparent"))
    return(.out)
  })
    
  
  .change <- NULL
  # map over the data
  .cmap <- c(turq = "789174", lpink = "BB8691", red = "762238", maroon = "2B0F18", grey = "858283", sb = "3b758b") %>% purrr::map_chr(~str_replace(.x, "^", "#"))
  out$g <- purrr::imap(c(Cases = .cmap[["red"]], Deaths = "black"), ~{
    .stat <- tolower(.y)
    .out <- list()
    .pettit <-  .d %>% 
      magrittr::extract2(.stat) %>% 
      na.omit() %>% 
      trend::pettitt.test()
    # add the points regardless
    .color <- .x
    g <- purrr::imap(g, ~{
      .stat <- paste0(.y, .stat)
      .out <- .x +
        geom_point(aes_string(y = .stat), color = .color, size = rel(.8))
      return(.out)
    })
    
    if (inherits(.dates$b, c("POSIXct", "Date"))) {
      # if there is a stay-at-home order create the vline, and establish the change point
      .cp <- .dates$b + lubridate::days(.pettit[["estimate"]][["probable change point at time K"]])
      g <- purrr::imap(g, ~{
        .stat <- paste0(.y, .stat)
        .out <- .x +
          geom_vline(aes(xintercept = .dates$b), color = .cmap[["maroon"]])
        if (nchar(.y) == 0) {
          .out <- .out + 
            annotation_custom(grid::textGrob(
              paste0("Begin: ", .dates$b),
              gp = grid::gpar(
                col = .cmap[["maroon"]],
                fontsize = 10)),
              xmin = .dates$b,
              xmax = .dates$b,
              ymin = (max(.d[[.stat]]) * .9),
              ymax = (max(.d[[.stat]]) * 1)
            )
        }
        return(.out)
      })
      
      
    } else {
      .cp <- min(.d$date) + lubridate::days(.pettit[["estimate"]][["probable change point at time K"]])
      # if no state-orders
    }
    
    g <- purrr::imap(g, ~{
      .method <- ifelse(nchar(.y) == 0 , "lm", "loess")
      .stat <- paste0(.y, .stat)
      # Add the reference line
      .out <- .x +
        geom_smooth(aes_string(y = .stat), method = .method, color = .cmap[["lpink"]], alpha = .2, formula = y ~ x) +
        # add the detected change point
        geom_vline(aes(xintercept = .cp), color = .cmap[["sb"]])
      if (nchar(.y) == 0) {
        .out <- .out +
          # add the annotations to just the main plot
        annotation_custom(grid::textGrob(
          paste0("Trend\nShift:\n ", .cp),
          gp = grid::gpar(
            col = .cmap[["sb"]],
            fontsize = 10)),
          xmin = .cp,
          xmax = .cp,
          ymin = (max(.d[[.stat]]) * .9),
          ymax = (max(.d[[.stat]]))
        )
      }
      return(.out)
    })
    
    if (inherits(.dates$e, c("POSIXct", "Date"))) {
      .lcol <- colorspace::lighten(.cmap[["red"]], .4)
      g <- purrr::imap(g, ~{
        .stat <- paste0(.y, .stat)
        .out <- .x +
          # add the vline for the end date
          geom_vline(aes(xintercept = .dates$e), color = .lcol)
        if (nchar(.y) == 0) {
          .out <- .out +
            # add the labels
            annotation_custom(grid::textGrob(
              paste0("Lift: ", .dates$e),
              gp = grid::gpar(
                col = .lcol,
                fontsize = 10)),
              xmin = .dates$e,
              xmax = .dates$e,
              ymin = (max(.d[[.stat]]) * .9),
              ymax = (max(.d[[.stat]]) * 1)
            )
        }
        return(.out)
      })
      
      # if the states have lifted restrictions created before and after data and add the graphical elements
      .b <- .d %>% filter(date <= .dates$e)
      
      .a <- .d %>% filter(date >= .dates$e)
      
      .f <- as.formula(paste0(.stat, "~", "date"))
      if (nrow(.b) > 0) {
        .b_b <- lm(.f, data = .b)
        # add the before regression line
        g <- purrr::imap(g, ~{
          .stat <- paste0(.y, .stat)
          # Add the reference line
          .out <- .x
            # and its beta
          if (nchar(.y) == 0) {
            .out <- .out +
              geom_smooth(data =.b, aes_string(y = .stat), method = "lm", color = .color, alpha = .2, formula = y ~ x) +
              # add the annotations to just the main plot
              annotate("text", x = .dates$e - round(.dt / 2), y = (mean(.b[[.stat]], na.rm = T)), label = paste0("B: ", round(.b_b$coefficients["date"],3)), size = 3)
          } else {
            .out <- .out + 
              geom_segment(aes(x = min(.b[["date"]]), xend = max(.b[["date"]]), y = mean(.b[[.stat]], na.rm = T), yend = mean(.b[[.stat]], na.rm = T)), color = .color) +
              geom_boxplot(data = na.omit(.b), aes_string(y  = .stat), color = .color, alpha = .2)
          }
          return(.out)
        })
        
      } 
      if (nrow(.a) > 0) {
        .b_a <- lm(.f, data = .a)
        g <- purrr::imap(g, ~{
          .stat <- paste0(.y, .stat)
          .ch <- list()
          if (nrow(.a) > 1) {
            .ch$t <- try(do.call(t.test, purrr::map(list(x = .b, y = .a), ~{
              purrr::keep(.x[[.stat]],~!is.na(.x) && !is.infinite(.x))
            })))
            if (class(.ch$t) != "try-error") {
              .ch$p.val <- round(.ch$t$p.value, 3)
              .change[[.stat]] <<- .ch
            } else {
              browser()
            }
          }
          .out <- .x
          # and its beta
          if (nchar(.y) == 0) {
            .y_pos <- list(up = mean(.a[[.stat]], na.rm = T) + sd(.a[[.stat]], na.rm = T),
                 down = mean(.a[[.stat]], na.rm = T) - sd(.a[[.stat]], na.rm = T)) %>% {
                   .gup <- max(.a[[.stat]], na.rm = T) - .[["up"]]
                   .gd <- .[["down"]] - min(.a[[.stat]], na.rm = T)
                   .dir <- which.max(c(.gup,.gd))
                   .y_pos <- ifelse(.dir == 1, .[["up"]] + .gup / 2, .[["down"]] - .gd / 2)
                   .y_pos
                   }
            
            .out <- .out +
              # add the after regression line
              geom_smooth(data = .a, aes_string(y = .stat), method = "lm", color = .color, alpha = .2, formula = y ~ x)+
              # and it's beta
              annotate("text", x = .dates$e + round(.dt / 2), y = .y_pos, label = paste0("B: ",round(.b_a$coefficients["date"],3)), size = 3)
            
          } else {
            .a <- na.omit(.a)
            .out <- .out + 
              geom_segment(aes(x = min(.a[["date"]]), xend = max(.a[["date"]]), y = mean(.a[[.stat]], na.rm = T), yend = mean(.a[[.stat]], na.rm = T)), color = .color) +
              geom_boxplot(data = .a, aes_string(y  = .stat), color = .color, alpha = .2)
            if (exists(".ch", inherits = F)) {
              .out <- .out +
                # add the labels
                annotation_custom(grid::textGrob(
                  paste0("T.Test p-val:", .ch$p.val),
                  gp = grid::gpar(
                    col = .lcol,
                    fontsize = 10)),
                  xmin = .dates$e + lubridate::days(1),
                  xmax = .dates$e + lubridate::days(1),
                  ymin = (max(.d[[.stat]]) * .9),
                  ymax = (max(.d[[.stat]]) * 1)
                )
            }
          }
          return(.out)
        })
      } 
    }
    g <- purrr::imap(g, ~{
      if (.y == "dd_") {
        .y_lab <- paste0("Daily New ",.stat)
      } else if (.y == "p_") {
        .y_lab <- paste0("% Change in New ",.stat)
      } else {
        .y_lab <- .stat
      }
      .out <- .x +
        ylab(.y_lab)+
        scale_y_continuous(labels = function(x){ ifelse(x > 1000, paste0(x / 1000, "k"), x)}) +
        theme(plot.title = element_text(hjust = .5),
              plot.subtitle = element_text(hjust = .5),
              axis.text.x = element_text(angle = 45, size = unit(10, "pt")),
              axis.text.y = element_text(size = unit(10, "pt")),
              axis.title.y = element_text(size = unit(10, "pt"))
        )
      if (nchar(.y) == 0) {
        .out <- .out + 
          xlab("Date")
      } else {
        .out <- .out + theme(
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        plot.margin = unit(c(0,.2,0,.2), "lines"),
        axis.ticks.x = element_blank()
        )
      }
      
      
      if (nchar(.y) == 0) {
        .out <- .out + 
          labs(
          caption = paste0(
            "Pettit's: p-value ",
            round(.pettit$p.value, 3)
          )
        )
      }
        return(.out)
    })
    
    #https://stackoverflow.com/questions/12409960/ggplot2-annotate-outside-of-plot
    g <- purrr::map(g, ~{
      .out <- try(ggplot_gtable(ggplot_build(.x)))
      browser(expr = inherits(.out, "try-error"))
    # create grid layout
    .out$layout$clip[.out$layout$name == "panel"] <- "off"
    return(.out)
    })
    g <- setNames(g, c("raw","dd_","p_"))
    return(g)
  })
  if (!is.null(.change)) out$change <- .change
  return(out)
}