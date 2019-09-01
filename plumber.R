# plumber.R
library(plumber)
library(jsonlite)
library(readr)
library(futile.logger)
library(tryCatchLog)
library(ggplot2)
library(yaml)

config = yaml.load_file("config.yml")
# creare R directory
dir.create(file.path(config$dir$temp_dir), showWarnings = FALSE)

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg="")
{
    list(msg = paste0("The message is: '", msg, "'"))
}

#* @serializer unboxedJSON
#* @post /rscript
function(code="", session_id="", R_file_id="")
{
    # create session directory for user
    dir.create(file.path(config$dir$temp_dir, session_id), showWarnings = FALSE)
    setwd(file.path(config$dir$temp_dir, session_id))
    InputFile <- paste(config$dir$temp_dir,session_id,"/", R_file_id,".R", sep="")
    OutputFile <- paste(config$dir$temp_dir,session_id,"/", R_file_id,".txt", sep="")
    RunInputFile <- paste("Rscript", InputFile, sep=" ")
    fileConn<-file(InputFile)
    Line1 = paste("png('",config$dir$temp_dir,session_id,"/", R_file_id,".png')\n", sep="")
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
    if (file.exists(paste(config$dir$temp_dir,session_id,"/",R_file_id,".png", sep="")) == TRUE) {
        graph_exist <- TRUE
    } else {
        graph_exist <- FALSE
    }
    r<- list(status = "SUCCESS", code = "200", output = ro, graph_exist = graph_exist)
    return (r)
}

#* @serializer contentType list(type='image/png')
#* @get /file
function(req, res, session_id="", R_file_id=""){
  file = paste(config$dir$temp_dir,session_id,"/",R_file_id,".png", sep="")
  readBin(file,'raw',n = file.info(file)$size)
}

# function to run R script on system
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


#* @post /upload
upload <- function(req, res){
  cat("---- New Request ----\n")
  session_id <- gsub('\"', "", substr(req$postBody[length(req$postBody)-1], 1, 1000))
  dir.create(file.path(config$dir$temp_dir, session_id), showWarnings = FALSE)
  # the path where you want to write the uploaded files
  file_path <- paste(config$dir$temp_dir,session_id,"/", sep="")
  # strip the filename out of the postBody
  file_name <- gsub('\"', "", substr(req$postBody[2], 55, 1000))
  # need the length of the postBody so we know how much to write out
  file_length <- length(req$postBody)-5
  # first five lines of the post body contain metadata so are ignored
  file_content <- req$postBody[5:file_length]
  # build the path of the file to write
  file_to_write <- paste0(file_path, file_name)
  # write file out with no other checks at this time
  write(file_content, file = file_to_write)
  # print logging info to console
  cat("File", file_to_write, "uploaded\n")
  # return file path &name to user
  ro <- file_to_write
  r<- list(status = "SUCCESS", code = "200", output = ro)
  return (r)
}
