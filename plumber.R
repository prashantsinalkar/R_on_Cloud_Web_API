# plumber.R
library(plumber)
library(jsonlite)
library(readr)
library(futile.logger)
library(tryCatchLog)

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @png
#* @get /plot
function(){
  rand <- rnorm(100)
  hist(rand)
}

#* @serializer unboxedJSON
#* @post /rscript
function(code=""){
  fileConn<-file("input.R")
  writeLines(code, fileConn)
  close(fileConn)
  ro <- system("Rscript input.R", intern = TRUE)
  fileConn<-file("output.txt")
  writeLines(ro, fileConn)
  close(fileConn)
  ro <- read_file("output.txt")
  r<- list(status = "SUCCESS", code = "200", output = ro)
  return (r)
}

