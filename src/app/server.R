library(shiny)
library(sf)
library(rgdal)
library(leaflet)
library(shinythemes)
library(shinydashboard)
library(highcharter)
library(dplyr)
library(dashboardthemes)
source('helper.R')

options(highcharter.theme = hc_theme_google())
art <- read.csv("/Users/greysonchung/Desktop/Data-Science-Project/data/cleanData.csv")

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
  
  output$PS_eval <- renderHighchart({
    art %>% 
      mutate(painting_support_condition = 
               recode(painting_support_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good", "3" = "3 Excellent")) %>%
      count(painting_support_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = painting_support_condition)) %>%
      hc_xAxis(title = list(text = "Museum")) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = TRUE) %>%
      hc_title(text = "Painting Support Condition") %>%
      hc_tooltip(pointFormat = tooltip_table(c("Support Condition:", "Number of paintings:"), 
                 c("{point.painting_support_condition}", "{point.y}")), useHTML = TRUE)
  })
  
  output$PS_planar <- renderHighchart({
    art %>% 
      mutate(!!sym(input$PS) := recode(!!sym(input$PS), "0" = "0 No", "1" = "1 Yes")) %>%
      filter(between(decade, input$PS_decade[1], input$PS_decade[2])) %>%
      count(!!sym(input$PS), collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = !!sym(input$PS))) %>%
      hc_plotOptions(column = list(borderRadius = 5)) %>%
      hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_title(text = names(PS_choiceVec)[PS_choiceVec == input$PS])
  })
})
