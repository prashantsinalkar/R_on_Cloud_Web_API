# plumber.R
library(plumber)
library(jsonlite)
library(readr)
library(futile.logger)
library(tryCatchLog)
library(ggplot2)

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg="")
{
    list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @png
#* @get /plot
function()
{
    rand <- rnorm(100)
    hist(rand)
}

#* @serializer unboxedJSON
#* @post /rscript
function(code="", session_id="")
{
    dir.create(file.path("/tmp/", session_id), showWarnings = FALSE)
    InputFile <- paste("/tmp/",session_id,"/",session_id,".R", sep="")
    OutputFile <- paste("/tmp/",session_id,"/",session_id,".txt", sep="")
    RunInputFile <- paste("Rscript", InputFile, sep=" ")
    fileConn<-file(InputFile)
    writeLines(code, fileConn)
    close(fileConn)
    ro <- system(RunInputFile, intern = TRUE)
    fileConn<-file(OutputFile)
    writeLines(ro, fileConn)
    close(fileConn)
    ro <- read_file(OutputFile)
    r<- list(status = "SUCCESS", code = "200", output = ro)
    return (r)
}

