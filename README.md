
# R_on_Cloud_Web_API


**Run on local R console:**
R version 3.4.4

  **Requirements preinstalled R packages:**

    install.packages("plumber")
    install.packages("jsonlite")
    install.packages("readr")
    install.packages("futile.logger")
    install.packages("tryCatchLog")
    ------------------------------------------
    > library(plumber)
    > r <- plumb("plumber.R")  # Where 'plumber.R' is the location of the file shown above
    > r$run(port=8001)


**Developer:**

    Prashant Sinalkar,
    FOSSEE, IIT Bombay





