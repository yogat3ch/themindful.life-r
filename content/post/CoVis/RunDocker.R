startSelenium <- function(){
HDA::startPkgs(c("RSelenium"))
# ----------------------- Wed Jun 12 16:40:59 2019 ------------------------# Start RSelenium

shell_out <- shell("docker info", intern = T)
# If docker is not yet started start it
inactive <- try(stringr::str_detect(shell_out, "error during connect"))
inactive <- ifelse(length(inactive) < 1, T, inactive)
if (length(shell_out) < 1 | inactive) {
  shell.exec("\"file:///C:/Program Files/Docker Toolbox/start.sh\"");message("Starting Docker Toolbox")
} else {
  message("Docker already running")
}
again <- any(c(try(stringr::str_detect(shell_out[1], "error during connect")) %>% is.na(),try(stringr::str_detect(shell_out[1], "error during connect"))))
while(again) {
  Sys.sleep(5)
  shell_out <- shell("docker info", intern = T)
  again <- any(c(try(stringr::str_detect(shell_out[1], "error during connect")) %>% is.na(),try(stringr::str_detect(shell_out[1], "error during connect"))))
}
shell_out <- shell("docker ps", intern = T)
Sys.sleep(5)
again <- any(c(try(!stringr::str_detect(shell_out[2], "standalone-chrome-debug")) %>% is.na(), !stringr::str_detect(shell_out[2], "standalone-chrome-debug")))
if (again) {
  message("No container found, starting one.")
  shell_out <- shell("docker run -d -p 4445:4444 -p 5901:5900 -v /dev/shm:/dev/shm selenium/standalone-chrome-debug", intern = T)
  Sys.sleep(5)
  
} else {
  shell_out <- try({shell("docker ps", intern = T) %>% .[2] %>% stringr::str_split("\\s{2,}") %>% unlist %>% .[1]})
  message(paste0("Container already running: ",shell_out))
}
wait <- try({shell("docker ps", intern = T) %>% .[2] %>% stringr::str_split("\\s{2,}") %>% unlist %>% .[1]})
wait <- nchar(wait) != 12
while (wait) {
  Sys.sleep(2)
  wait <- try({shell("docker ps", intern = T) %>% .[2] %>% stringr::str_split("\\s{2,}") %>% unlist %>% .[1]})
wait <- nchar(wait)  != 12
message("Waiting for container to start...")
}
Sys.sleep(5)
message("Begin RSelenium")
try({remDr <- RSelenium::remoteDriver(remoteServerAddr = "192.168.99.100",port = 4445L,browserName = "chrome")
stat <- remDr$getStatus()
})
while (!HDA::go(stat$ready)) {
  try({remDr <- RSelenium::remoteDriver(remoteServerAddr = "192.168.99.100",port = 4445L,browserName = "chrome")
  stat <- remDr$getStatus()
  })
}
sess <- remDr$getSessions()
if (length(sess) > 0) remDr$quit()
catch <- try({remDr$open(silent=T)
  remDr$setImplicitWaitTimeout(milliseconds = 10000)
  browserName <- remDr$getSession()[["browserName"]]})
while (catch != "chrome") {
  Sys.sleep(5)
  catch <- try({remDr$open(silent=T)
    remDr$setImplicitWaitTimeout(milliseconds = 10000)
    browserName <- remDr$getSession()[["browserName"]]})
}
# End Start RSelenium
return(remDr)
}
