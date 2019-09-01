
library(plumber)
library(yaml)
config = yaml.load_file("config.yml")
r <- plumb("plumber.R")  # Where 'plumber.R' is the location of the file shown above
r$registerHook("exit", function(){
  print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
  print("Bye bye!")
  print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
})
r$run(host=config$host$host_ip, port=config$host$host_port, swagger=TRUE)
