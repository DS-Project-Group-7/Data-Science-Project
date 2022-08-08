

library(shiny)
library(sf)
library(rgdal)
library(leaflet)
library(shinythemes)
library(shinydashboard)
library(dashboardthemes)
source('helper.R')


shinyServer(function(input, output) {
  output$mymap <- renderLeaflet({
    
    leaflet() 
      addTiles() %>% addProviderTiles(providers$CartoDB.Positron) %>%
      addPopups(lat = 14.65385, lng = 121.06821, content_phil,
                options = popupOptions(closeOnClick = F, keepInView = T)) %>%
      addMarkers(lat = 3.1731, lng = 101.705246) %>%
      addMarkers(lat = 1.32631052396, lng = 103.845852286) %>%
      addMarkers(lat = 13.758915, lng = 100.49393)
  })
})
