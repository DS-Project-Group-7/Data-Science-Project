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
  
  #Dimensions for Scatter plot 
  output$DM_eval <- renderHighchart({
    art %>% 
      #filter(between(decade, input$AX_decade[1], input$AX_decade[2])) %>%
      select(collection, length,width,title) %>%
      hchart("scatter", 
             hcaes(x = width, y = length, group = collection)) %>%
      #hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
      hc_xAxis(title = list(text = "Width")) %>%
      hc_yAxis(title = list(text = "Length")) %>%
      hc_title(text = "Scatter plot between width and length of four collections")%>%
      hc_tooltip(pointFormat = tooltip_table(c("Painting Title:","Width:", "Length:"), 
                                            c("{point.title}", "{point.x}","{point.y}")), useHTML = TRUE)
  })
  
  #Dimensions for packedbubble plot 
  output$DM_bub <- renderHighchart({
    art %>% 
      mutate(area = area/100) %>%
      #filter(between(decade, input$AX_decade[1], input$AX_decade[2])) %>%
      #count(auxiliary_support_condition, collection) %>%
      select(collection,area,decade,country,title)%>%
      hchart("packedbubble",hcaes(x = collection, value = area, group = collection))%>%
      hc_title(text = "Bubble area of painting of four collections")%>%
      hc_tooltip(
        useHTML = TRUE,
        pointFormat = tooltip_table(c("Painting Title:","Area:"), 
                                    c("{point.title}", "{point.value}"))
      )%>%
      hc_plotOptions(
        packedbubble = list(
          maxSize = "150%",
          zMin = 0,
          layoutAlgorithm = list(
            gravitationalConstant =  0.05,
            splitSeries =  TRUE, # TRUE to group points
            seriesInteraction = TRUE,
            dragBetweenSeries = TRUE,
            parentNodeLimit = TRUE
          ),
          dataLabels = list(
            enabled = TRUE,
            format = "{point.name}",
            filter = list(
              property = "y",
              operator = ">",
              value = as.numeric(quantile(art$area, .95))
            ),
            style = list(
              color = "black",
              textOutline = "none",
              fontWeight = "normal"
            )
          )
        )
      )
  })
  
  #Bar chart painting condition
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
  
  #Bar chart aux condition
  output$AX_eval <- renderHighchart({
    art %>% 
      mutate(auxiliary_support_condition = 
               recode(auxiliary_support_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good")) %>%
      filter(between(decade, input$AX_decade[1], input$AX_decade[2])) %>%
      count(auxiliary_support_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = auxiliary_support_condition)) %>%
      hc_xAxis(title = list(text = "Museum")) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = TRUE) %>%
      hc_title(text = "Auxiliary support condition")%>%
      hc_tooltip(pointFormat = tooltip_table(c("Auxiliary support condition:", "Number of paintings:"), 
                                             c("{point.auxiliary_support_condition}", "{point.y}")), useHTML = TRUE)
  })
  
  #Heat map aux condition
  output$AX_heat <- renderHighchart({
    art %>% 
      mutate(!!sym(input$AX) := recode(!!sym(input$AX), "0" = "0 No", "1" = "1 Yes"),
             auxiliary_support_condition = 
               recode(auxiliary_support_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good"))%>% 
      group_by(!!sym(input$AX)) %>%
      filter(between(decade, input$AX_decade[1], input$AX_decade[2])) %>%
      count(condition = auxiliary_support_condition) %>%
      hchart("heatmap",
             hcaes(x =  condition, y = !!sym(input$AX), value = n)) %>%
      hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
      hc_xAxis(title = list(text = "Aux Support Condition"), 
               categories = c("Poor", "Fair", "Good" )) %>%
      hc_yAxis(title = list(text = names(AX_choiceVec)[AX_choiceVec == input$AX]),
               categories = c("No", "Yes")) %>%
      hc_title(text = paste0("Heatmap ",names(AX_choiceVec)[AX_choiceVec == input$AX]," Condition"))%>%
      hc_tooltip(pointFormat = tooltip_table(c(names(AX_choiceVec)[AX_choiceVec == input$AX],"Auxiliary support condition:", "Number of paintings:"), 
                                             c("{point.y}","{point.condition}", "{point.n}")), useHTML = TRUE)
      #Need to update tooltips 
  })
  
  #Bar chart options painting condition
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
