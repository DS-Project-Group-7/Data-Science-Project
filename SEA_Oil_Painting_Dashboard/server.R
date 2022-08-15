library(shiny)
library(leaflet)
library(shinythemes)
library(shinydashboard)
library(highcharter)
library(dplyr)
library(dashboardthemes)
source('helper.R')

options(highcharter.theme = hc_theme_google())
art <- read.csv("data/cleanData.csv")

shinyServer(function(input, output) {
  output$mymap <- renderLeaflet({
    
    leaflet() %>% # setView(lat = 10, lng = 115, zoom = 5.4) %>%
      addTiles() %>% addProviderTiles(providers$CartoDB.Voyager) %>%
      addPopups(lat = 14.65385, lng = 121.06821, content_phil,
                options = popupOptions(closeOnClick = F, keepInView = T)) %>%
      addPopups(lat = 3.1731, lng = 101.705246, content_mala,
                options = popupOptions(closeOnClick = F, keepInView = T)) %>%
      addPopups(lat = 1.32631052396, lng = 103.845852286, content_sing,
                options = popupOptions(closeOnClick = F, keepInView = T)) %>%
      addPopups(lat = 13.758915, lng = 100.49393, content_thai,
                options = popupOptions(closeOnClick = F, keepInView = T))
  })
  #Bar chart painting condition
  output$PS_eval <- renderHighchart({
    art %>% count(painting_support_condition, collection) %>%
      hchart("column", stacking = "normal",
             hcaes(x = painting_support_condition, y = n, group = collection)) %>%
      hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
      hc_xAxis(title = list(text = "Condition"), 
               categories = c("Poor", "Fair", "Good", "Excellent")) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_title(text = "Painting Support Condition")
  })
  #Bar chart options painting condition
  output$PS_planar <- renderHighchart({
    art %>% count(!!sym(input$PS), collection) %>%
      hchart("column", stacking = "normal",
             hcaes(x = !!sym(input$PS), y = n, group = collection)) %>%
      hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
      hc_xAxis(title = list(text = names(PS_choiceVec)[PS_choiceVec == input$PS]),
               categories = c("No", "Yes")) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_title(text = names(PS_choiceVec)[PS_choiceVec == input$PS])
  })
})
