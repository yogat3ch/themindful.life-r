f <- c(`r-experience` = "R Experiential Coursework/RLineCounter.Rmd",
       canvassml = "CanvassML/Creating_targets.Rmd")
message(getwd())
f_mods <- purrr::imap_dfr(f, ~{
  #browser()
  # Get the rmd modified time
  .rmd_mod <- fs::file_info(.x)$modification_time
  # Construct the path to the live html file
  .live_html <- paste0(c("static", .y, paste0(.y, ".html")), collapse = "/")
  # Get the modified time of the live html file
  .live_html_mod <- fs::file_info(.live_html)$modification_time
  # Construct the path to the local html file
  .html <- paste0(dirname(.x), "/",stringr::str_sub(basename(.x), 1, -5), ".html")
  # Get the modified time of the local html file
  .html_mod <- fs::file_info(.html)$modification_time
  # If the live html file doesnt exist or is behind the rmd
  if (is.na(.live_html_mod) || .live_html_mod < .rmd_mod) {
    print(paste0(.live_html,":",.live_html_mod, " is behind ", .x, ":", .rmd_mod, " Updating..."))
    # If the local html file exists and is in front of the rmd
    if (!is.na(.html_mod) && .html_mod > .rmd_mod) {
      # Remove the old live html file
      if (!is.na(.live_html_mod)) file.remove(.live_html)
      # If the directory doesn't exist for the live file create it
      if (!dir.exists(dirname(.live_html))) fs::dir_create(dirname(.live_html))
      # Copy the local html file to the live file
      print(paste("Copying", .html, "to", .live_html))
      fs::file_copy(.html, .live_html)
    } else {
      # Otherwise render the rmd as index.html in the live directory
      message(paste("Rendering", basename(.live_html), "to", paste0("static/", .y)))
      
    rmarkdown::render(.x, output_file = basename(.live_html), output_dir = paste0("static/", .y), clean = T, output_options = list(self_contained = T))
    }
  }
  # create the record
  data.frame(
    f = .y,
    rmd = .rmd_mod,
    html = .html_mod,
    live_html = .live_html_mod,
    stringsAsFactors = F
  )
})
#message(f_mods)
# Save the record
readr::write_csv(f_mods, "Rmd_modification_log.csv")
blogdown::build_dir('static')
