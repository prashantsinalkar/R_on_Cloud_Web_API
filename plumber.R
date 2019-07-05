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
    Line1 = paste("png('/tmp/",session_id,".png')\n", sep="")
    Line2 = code
    Line3 = "while (!is.null(dev.list()))  dev.off()"
    writeLines(c(Line1, Line2, Line3), fileConn)
    close(fileConn)
    #ro <- system(RunInputFile, intern = TRUE)
    ro <-robust.system(RunInputFile)
    ro <- unlist(lapply(ro,function(x) if(identical(x,character(0))) ' ' else x))
    fileConn<-file(OutputFile)
    writeLines(paste0(ro), fileConn)
    close(fileConn)
    ro <- read_file(OutputFile)
    r<- list(status = "SUCCESS", code = "200", output = ro)
    return (r)
}


robust.system <- function (cmd) {
    stderrFile = tempfile(pattern="R_robust.system_stderr", fileext=as.character(Sys.getpid()))
    stdoutFile = tempfile(pattern="R_robust.system_stdout", fileext=as.character(Sys.getpid()))

    retval = list()
    retval$exitStatus = system(paste0(cmd, " 2> ", shQuote(stderrFile), " > ", shQuote(stdoutFile)), intern = TRUE )
    retval$stdout = readLines(stdoutFile)
    retval$stderr = readLines(stderrFile)

    unlink(c(stdoutFile, stderrFile))
    return(retval)
}
