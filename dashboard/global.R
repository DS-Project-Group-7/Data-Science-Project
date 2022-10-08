library(shiny)
library(polished)
library(config)

app_config <- config::get()


#configure polished auth when the app initially starts up.
polished_config(
  app_name = "my_SEA_dashboard",
  api_key = app_config$api_key
)
