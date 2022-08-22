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
  
  # Homepage
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
  
  output$Decade_Sum <- renderHighchart({
    art %>%
      count(decade, collection) %>%
      hchart("column", stacking = "normal", hcaes(x = decade, y = n, group = collection)) %>%
      hc_xAxis(title = list(text = "Decades")) %>%
      hc_yAxis(title = list(text = "Number of paintings")) %>%
      hc_title(text = "Painting Distribution Throughout the Century") %>%
      hc_legend(title = list(text = "Museum"))
  })
  
  # Painting Support
  output$PS_eval <- renderHighchart({
    art %>% 
      mutate(painting_support_condition = 
             recode(painting_support_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good", "3" = "3 Excellent")) %>%
      count(painting_support_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = painting_support_condition)) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = TRUE) %>%
      hc_title(text = "Painting Support Condition Overview") %>%
      hc_tooltip(pointFormat = tooltip_table(c("Support Condition:", "Number of paintings:"), 
                 c("{point.painting_support_condition}", "{point.y}")), useHTML = TRUE)
  })
  
  output$PS_visual <- renderHighchart({
    art %>% 
      mutate(!!sym(input$PS) := recode(!!sym(input$PS), "0" = "0 No", "1" = "1 Yes")) %>%
      filter(between(decade, input$PS_decade[1], input$PS_decade[2])) %>%
      count(!!sym(input$PS), collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = !!sym(input$PS))) %>%
      hc_plotOptions(column = list(borderRadius = 5)) %>%
      hc_legend(title = list(text = "Is such condition present?"), reversed = TRUE) %>%
      hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
      hc_xAxis(title = list(text = "Museum")) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_title(text = names(PS_choiceVec)[PS_choiceVec == input$PS])
  })
  
  output$PS_heatmap <- renderHighchart({
    art %>%
      mutate(!!sym(input$PS_1) := recode(!!sym(input$PS_1), "0" = "0 No", "1" = "1 Yes")) %>%
      mutate(!!sym(input$PS_2) := recode(!!sym(input$PS_2), "0" = "0 No", "1" = "1 Yes")) %>%
      count(!!sym(input$PS_1), !!sym(input$PS_2)) %>%
      hchart("heatmap", hcaes(x = !!sym(input$PS_1), y = !!sym(input$PS_2), value = n)) %>%
      hc_xAxis(title = list(text = names(PS_choiceVec)[PS_choiceVec == input$PS_1])) %>%
      hc_yAxis(title = list(text = names(PS_choiceVec)[PS_choiceVec == input$PS_2]))
  })

  # Ground Layer  
  output$GR_eval <- renderHighchart({
    art %>%
      mutate(ground_condition = 
               recode(ground_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good", "3" = "3 Excellent")) %>%
      count(ground_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = ground_condition)) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = TRUE) %>%
      hc_title(text = "Ground Layer Condition Overview") %>%
      hc_tooltip(pointFormat = tooltip_table(c("Ground Layer Condition:", "Number of paintings:"), 
                                             c("{point.ground_condition}", "{point.y}")), useHTML = TRUE)
  })
  
  output$GR_visual <- renderHighchart({
    if (input$GR == "canvas_wrapping") {
      art %>%
        mutate(!!sym(input$GR) := recode(!!sym(input$GR), NULL = "Unspecified", "to side edge" = "To Side Edge", "to face edge" = "To Face Edge", "to side edgeto face edge" = "Both")) %>%
        count(!!sym(input$GR), collection) %>%
        hchart("bar", stacking = "normal",
               hcaes(x = collection, y = n, group = !!sym(input$GR))) %>%
        hc_title(text = "Are Ground Applied To Face Edge or Side Edge?") %>%
        hc_xAxis(title = list(text = "Museum")) %>%
        hc_yAxis(title = list(text = "Number of Paintings"))
    } else {
      art %>% 
        mutate(!!sym(input$GR) := recode(!!sym(input$GR), "0" = "0 No", "1" = "1 Yes")) %>%
        filter(between(decade, input$GR_decade[1], input$GR_decade[2])) %>%
        count(!!sym(input$GR), collection) %>%
        hchart("bar", stacking = "normal",
               hcaes(x = collection, y = n, group = !!sym(input$GR))) %>%
        hc_legend(title = list(text = "Is such condition present?"), reversed = TRUE) %>%
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
        hc_xAxis(title = list(text = "Museum")) %>%
        hc_yAxis(title = list(text = "Number of Paintings")) %>%
        hc_title(text = names(GR_choiceVec)[GR_choiceVec == input$GR])
    }
  })
})
