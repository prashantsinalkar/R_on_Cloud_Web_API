
library(plumber)
r <- plumb("plumber.R")  # Where 'plumber.R' is the location of the file shown above
r$run(host="0.0.0.0", port=8001, swagger=TRUE)