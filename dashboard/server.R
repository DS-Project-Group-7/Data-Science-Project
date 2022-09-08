library(shiny)
library(shinyjs)
library(leaflet)
library(shinythemes)
library(shinydashboard)
library(highcharter)
library(tidyr)
library(dplyr)
library(raster)
library(dashboardthemes)
source('helper.R')

options(highcharter.theme = hc_theme_google())
malay <- getData('GADM', country='MYS', level=0)
sing <- getData('GADM', country='SGP', level=0)
phil <- getData('GADM', country='PHL', level=0)
thai <- getData('GADM', country='THA', level=0)

shinyServer(function(input, output) {
  
  ################################ Homepage ################################
  
  output$sing_count <- renderValueBox({
    valueBox(
      value = "63", subtitle = "National Heritage Board",
      icon = icon("university"), color = "red", 
      href = 'https://www.nhb.gov.sg'
    )
  })
  
  output$mala_count <- renderValueBox({
    valueBox(
      value = "53", subtitle = "National Art Gallery (Malaysia)",
      icon = icon("university"), color = "orange", 
      href = 'https://www.artgallery.gov.my/en/homepage/'
    )
  })
  
  output$phil_count <- renderValueBox({
    valueBox(
      value = "59", subtitle = "JB Vargas Museum",
      icon = icon("university"), color = "blue", 
      href = 'https://vargasmuseum.wordpress.com'
    )
  })
  
  output$thai_count <- renderValueBox({
    valueBox(
      value = "33", subtitle = "National Gallery (Thailand)",
      icon = icon("university"), color = "green", 
      href = 'https://www.museumthailand.com/en/museum/The-National-Gallery-Hor-Silp-Chao-Fa'
    )
  })
  
  output$mymap <- renderLeaflet({
    
    leaflet(options = leafletOptions(minZoom = 4.5, maxZoom = 4.5)) %>%
      addTiles() %>% addProviderTiles(providers$CartoDB.Voyager) %>%
      addPolygons(data=malay, weight = 1, fillColor = "orange", 
                  highlightOptions = 
                    highlightOptions(color = "white", weight = 2,bringToFront = TRUE),
                  label = mala_labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addPolygons(data=sing, weight = 1, fillColor = "red",
                  highlightOptions = 
                    highlightOptions(color = "white", weight = 2,bringToFront = TRUE),
                  label = sing_labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addPolygons(data=phil, weight = 1, fillColor = "blue",
                  highlightOptions = 
                    highlightOptions(color = "white", weight = 2,bringToFront = TRUE),
                  label = phil_labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")) %>%
      addPolygons(data=thai, weight = 1, fillColor = "green",
                  highlightOptions = 
                    highlightOptions(color = "white", weight = 2,bringToFront = TRUE),
                  label = thai_labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto"))
  })
  
  output$cooking_rice <- renderImage({
    list(src = "cooking_rice.png",
         width = "100%",
         height = "100%",
         alt = "This is alternate text"
    )
  }, deleteFile = FALSE)
  
  output$Decade_Sum <- renderHighchart({
    art %>%
      count(decade, collection) %>%
      hchart("column", stacking = "normal", hcaes(x = decade, y = n, group = collection)) %>%
      hc_xAxis(title = list(text = "Decades")) %>%
      hc_yAxis(title = list(text = "Number of paintings")) %>%
      hc_title(text = "Painting Frequency Distribution Throughout the Century") %>%
      hc_legend(title = list(text = "Museum"))
  })
  
  ################################ Dimension ################################
  
  #Dimensions for Scatter plot 
  output$DM_eval <- renderHighchart({
    art %>% 
      #filter(between(decade, input$AX_decade[1], input$AX_decade[2])) %>%
      dplyr::select(collection, length, width, title) %>%
      rename(height = length) %>%
      hchart("scatter", 
             hcaes(x = width, y = height, group = collection)) %>%
      #hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
      hc_xAxis(title = list(text = "Width")) %>%
      hc_yAxis(title = list(text = "Height")) %>%
      hc_title(text = "Scatter Plot Between Width and Height of the Four Museums")%>%
      hc_tooltip(pointFormat = tooltip_table(c("Painting Title:","Width:", "Height:"), 
                                             c("{point.title}", "{point.x}mm","{point.y}mm")), useHTML = TRUE)
  })
  
  #Dimensions for packedbubble plot 
  output$DM_bub <- renderHighchart({
    art %>% 
      mutate(area = area/100) %>%
      #filter(between(decade, input$AX_decade[1], input$AX_decade[2])) %>%
      #count(auxiliary_support_condition, collection) %>%
      dplyr::select(collection,area,decade,country,title)%>%
      hchart("packedbubble",hcaes(x = collection, value = area, group = collection))%>%
      hc_title(text = "Area Summary for the Four Museum")%>%
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
  
  ################################ Auxiliary Support ################################
  
  output$AX_eval <- renderHighchart({
    art %>% 
      mutate(auxiliary_support_condition = 
               recode(auxiliary_support_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good")) %>%
      filter(between(decade, input$AX_decade[1], input$AX_decade[2])) %>%
      count(auxiliary_support_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = auxiliary_support_condition)) %>%
      hc_xAxis(title = list(text = "Museum")) %>%
      hc_yAxis(title = list(text = "Number of Paintings"), reversedStacks = F) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = F) %>%
      hc_title(text = "Auxiliary Support Condition")%>%
      hc_tooltip(pointFormat = tooltip_table(c("Auxiliary Support Condition:", "Number of paintings:"), 
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
      hc_xAxis(title = list(text = "Auxiliary Support Condition"), 
               categories = c("Poor", "Fair", "Good" )) %>%
      hc_yAxis(title = list(text = names(AX_choiceVec)[AX_choiceVec == input$AX]),
               categories = c("No", "Yes")) %>%
      hc_title(text = paste0("Heatmap ",names(AX_choiceVec)[AX_choiceVec == input$AX]," Condition"))%>%
      hc_tooltip(pointFormat = tooltip_table(c(names(AX_choiceVec)[AX_choiceVec == input$AX],"Auxiliary support condition:", "Number of paintings:"), 
                                             c("{point.y}","{point.condition}", "{point.n}")), useHTML = TRUE)
    #Need to update tooltips 
  })
  
  #Line chart Wood locality 
  output$AX_wood <- renderHighchart({
    art %>% 
      mutate(locality = 
               recode(locality, "local?" = "local", "Unspecified" = "import"))%>%
      group_by(locality)%>%
      count(locality, decade) %>%
      mutate(cum_sum = cumsum(n)) %>%
      hchart("areaspline",
             hcaes(x = decade, y = cum_sum, group = locality)) %>%
      hc_xAxis(title = list(text = "Decade")) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_legend(title = list(text = "Locality"), reversed = TRUE) %>%
      hc_title(text = "Cumulative sum wood type locality throughout the century")%>%
      hc_tooltip(pointFormat = tooltip_table(c("Locality:", "Number of paintings:"), 
                                             c("{point.locality}", "{point.y}")), useHTML = TRUE)
  })
  
  ################################ Painting Support ################################
  
  output$PS_eval <- renderHighchart({
    art %>% 
      mutate(painting_support_condition = 
               recode(painting_support_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good", "3" = "3 Excellent")) %>%
      filter(collection %in% input$PS_check) %>% 
      filter(between(decade, input$PS_decade[1], input$PS_decade[2])) %>%
      count(painting_support_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = painting_support_condition)) %>%
      hc_yAxis(title = list(text = "Number of Paintings"), reversedStacks = F) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = F) %>%
      hc_title(text = "Painting Support Condition Overview") %>%
      hc_tooltip(pointFormat = tooltip_table(c("Support Condition:", "Number of paintings:"), 
                                             c("{point.painting_support_condition}", "{point.y}")), useHTML = TRUE) %>%
      hc_add_event_point(series = "series", event = "click")
  })
  
  output$PS_tableinfo <- renderText({
    paste("Currently displaying condition rating", input$PS_eval_click$series, "paintings from",
          input$PS_eval_click$name, "between", input$PS_decade[1], "and", input$PS_decade[2], sep = " ")
  })
  
  toggle_ps_table <- reactiveVal(TRUE)
  observeEvent(input$ps_hide, {
    toggle_ps_table(!toggle_ps_table())
  })
  observeEvent(input$PS_eval_click, {
    if (!toggle_ps_table()) {
      toggle_ps_table(!toggle_ps_table())
    } else {
    }
  })
  
  ps_table_on_off <- reactive({
    if (toggle_ps_table()) {
      art %>%
        filter(between(decade, input$PS_decade[1], input$PS_decade[2])) %>%
        filter(painting_support_condition == substr(input$PS_eval_click$series, 1, 1) &
                 collection == input$PS_eval_click$name) %>%
        dplyr::select(accession_number, artist, title, decade)
    } else {}
  })
  
  output$PS_table <- DT::renderDataTable({
    if (length(input$PS_eval_click)) {
      ps_table_on_off()
    } else {
    }
  }, rownames = FALSE, options = list(
    autoWidth = T, pageLength = 5,
    columnDefs = list(list(width = '500px', className = 'dt-center', targets = "_all"))
  ))

  output$PS_visual <- renderHighchart({
    art %>% 
      mutate(!!sym(input$PS) := recode(!!sym(input$PS), "0" = "0 No", "1" = "1 Yes")) %>%
      filter(collection %in% input$PS_check) %>% 
      filter(between(decade, input$PS_decade[1], input$PS_decade[2])) %>%
      count(!!sym(input$PS), collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = !!sym(input$PS))) %>%
      hc_plotOptions(column = list(borderRadius = 5)) %>%
      hc_legend(title = list(text = "Is such condition present?"), reversed = TRUE) %>%
      hc_xAxis(title = list(text = "Museum")) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_title(text = names(PS_choiceVec)[PS_choiceVec == input$PS]) %>%
      hc_add_event_point(series = "series", event = "click")
  })
  
  output$PS_vtableinfo <- renderText({
    paste("Currently displaying paintings with", names(PS_choiceVec)[PS_choiceVec == input$PS], "condition", "(", 
          input$PS_visual_click$series, ")", "from", input$PS_visual_click$name, "between", input$PS_decade[1], 
          "and", input$PS_decade[2], sep = " ")
  })
  
  toggle_ps_vtable <- reactiveVal(TRUE)
  observeEvent(input$ps_vhide, {
    toggle_ps_vtable(!toggle_ps_vtable())
  })
  observeEvent(input$PS_visual_click, {
    if (!toggle_ps_vtable()) {
      toggle_ps_vtable(!toggle_ps_vtable())
    } else {
    }
  })
  
  ps_vtable_on_off <- reactive({
    if (toggle_ps_vtable()) {
      art %>%
        filter(between(decade, input$PS_decade[1], input$PS_decade[2])) %>%
        filter(!!sym(input$PS) == substr(input$PS_visual_click$series, 1, 1) &
                 collection == input$PS_visual_click$name) %>%
        dplyr::select(accession_number, artist, title, decade)
    } else {}
  })
  
  output$PS_vtable <- DT::renderDataTable({
    if (length(input$PS_visual_click)) {
      ps_vtable_on_off()
    } else {
    }
  }, rownames = FALSE, options = list(
    autoWidth = T, pageLength = 5,
    columnDefs = list(list(width = '500px', className = 'dt-center', targets = "_all"))
  ))
  
  output$PS_heatmap <- renderHighchart({
    art %>%
      filter(collection %in% input$PS_check) %>% 
      mutate(!!sym(input$PS_1) := recode(!!sym(input$PS_1), "0" = "0 No", "1" = "1 Yes")) %>%
      mutate(!!sym(input$PS_2) := recode(!!sym(input$PS_2), "0" = "0 No", "1" = "1 Yes")) %>%
      filter(collection %in% input$PS_check) %>% 
      count(!!sym(input$PS_1), !!sym(input$PS_2)) %>%
      hchart("heatmap", hcaes(x = !!sym(input$PS_1), y = !!sym(input$PS_2), value = n)) %>%
      hc_xAxis(title = list(text = names(PS_choiceVec)[PS_choiceVec == input$PS_1])) %>%
      hc_yAxis(title = list(text = names(PS_choiceVec)[PS_choiceVec == input$PS_2]))
  })
  
  ################################ Ground Layer ################################
  
  output$GR_eval <- renderHighchart({
    art %>%
      filter(between(decade, input$GR_decade[1], input$GR_decade[2])) %>%
      filter(collection %in% input$GR_check) %>%
      mutate(ground_condition = 
               recode(ground_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good", "3" = "3 Excellent")) %>%
      count(ground_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = ground_condition)) %>%
      hc_yAxis(title = list(text = "Number of Paintings"), reversedStacks = F) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = F) %>%
      hc_title(text = "Ground Layer Condition Overview") %>%
      hc_tooltip(pointFormat = tooltip_table(c("Ground Layer Condition:", "Number of paintings:"),
                                             c("{point.ground_condition}", "{point.y}")), useHTML = TRUE) %>%
      hc_add_event_point(series = "series", event = "click")
  })
  
  output$GR_tableinfo <- renderText({
    paste("Currently displaying condition rating", input$GR_eval_click$series, "paintings from",
          input$GR_eval_click$name, "between", input$GR_decade[1], "and", input$GR_decade[2], sep = " ")
  })
  
  toggle_gr_table <- reactiveVal(TRUE)
  observeEvent(input$GR_hide, {
    toggle_gr_table(!toggle_gr_table())
  })
  observeEvent(input$GR_eval_click, {
    if (!toggle_gr_table()) {
      toggle_gr_table(!toggle_gr_table())
    } else {
    }
  })
  
  gr_table_on_off <- reactive({
    if (toggle_gr_table()) {
      art %>%
        filter(between(decade, input$GR_decade[1], input$GR_decade[2])) %>%
        filter(ground_condition == substr(input$GR_eval_click$series, 1, 1) &
                 collection == input$GR_eval_click$name) %>%
        dplyr::select(accession_number, artist, title, decade)
    } else {}
  })
  
  output$GR_table <- DT::renderDataTable({
    if (length(input$GR_eval_click)) {
      gr_table_on_off()
    } else {
    }
  }, rownames = FALSE, options = list(
    autoWidth = T, pageLength = 5,
    columnDefs = list(list(width = '500px', className = 'dt-center', targets = "_all"))
  ))
  
  output$GR_visual <- renderHighchart({
    if (input$GR == "ground_layer_limit") {
      art %>%
        filter(collection %in% input$GR_check) %>%
        mutate(!!sym(input$GR) := recode(!!sym(input$GR), "to side edge" = "To Side Edge", "to face edge" = "To Face Edge", "to side edgeto face edge" = "Both")) %>%
        filter(between(decade, input$GR_decade[1], input$GR_decade[2])) %>%
        count(!!sym(input$GR), collection) %>%
        hchart("bar", stacking = "normal",
               hcaes(x = collection, y = n, group = !!sym(input$GR))) %>%
        hc_title(text = "Are Ground Applied To Face Edge or Side Edge?") %>%
        hc_xAxis(title = list(text = "Museum")) %>%
        hc_yAxis(title = list(text = "Number of Paintings"))  %>%
        hc_add_event_point(series = "series", event = "click")
    } else if (input$GR == 'ground_layer_application') {
      art %>%
        filter(collection %in% input$GR_check) %>%
        mutate(!!sym(input$GR) := recode(!!sym(input$GR), "artist applied ground" = "Artist Applied", "commercial ground" = "Commercial", 'commercial groundartist applied ground' = 'Both')) %>%
        filter(between(decade, input$GR_decade[1], input$GR_decade[2])) %>%
        count(!!sym(input$GR), collection) %>%
        hchart("bar", stacking = "normal",
               hcaes(x = collection, y = n, group = !!sym(input$GR))) %>%
        hc_title(text = "Commercial or Artist Applied Ground?") %>%
        hc_xAxis(title = list(text = "Museum")) %>%
        hc_yAxis(title = list(text = "Number of Paintings")) %>%
        hc_add_event_point(series = "series", event = "click")
    } else if (input$GR == "ground_layer_thickness") {
      art %>%
        filter(collection %in% input$GR_check) %>%
        mutate(!!sym(input$GR) := recode(!!sym(input$GR), "thinly applied" = "Thinly Applied", "thickly applied" = "Thickly Applied", 'thickly appliedthinly applied' = 'Both')) %>%
        filter(between(decade, input$GR_decade[1], input$GR_decade[2])) %>%
        count(!!sym(input$GR), collection) %>%
        hchart("bar", stacking = "normal",
               hcaes(x = collection, y = n, group = !!sym(input$GR))) %>%
        hc_title(text = "Are Ground Applied Thinly or Thickly Applied?") %>%
        hc_xAxis(title = list(text = "Museum")) %>%
        hc_yAxis(title = list(text = "Number of Paintings")) %>%
        hc_add_event_point(series = "series", event = "click")
    } else {
      art %>% 
        filter(collection %in% input$GR_check) %>%
        mutate(!!sym(input$GR) := recode(!!sym(input$GR), "0" = "0 No", "1" = "1 Yes")) %>%
        filter(between(decade, input$GR_decade[1], input$GR_decade[2])) %>%
        count(!!sym(input$GR), collection) %>%
        hchart("bar", stacking = "normal",
               hcaes(x = collection, y = n, group = !!sym(input$GR))) %>%
        hc_legend(title = list(text = "Is such condition present?"), reversed = TRUE) %>%
        hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
        hc_xAxis(title = list(text = "Museum")) %>%
        hc_yAxis(title = list(text = "Number of Paintings")) %>%
        hc_title(text = names(GR_choiceVec)[GR_choiceVec == input$GR]) %>%
        hc_add_event_point(series = "series", event = "click")
    }
  })
  
  ################################ Paint Layer ################################
  
  output$painting_layer <- renderHighchart({
    art %>% 
      mutate(painting_support_condition = 
               recode(media_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good", "3" = "3 Excellent")) %>%
      count(media_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = media_condition)) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = TRUE) %>%
      hc_title(text = "Media Condition") %>%
      hc_tooltip(pointFormat = tooltip_table(c("Media Condition:", "Number of paintings:"), 
                                             c("{point.media_condition}", "{point.y}")), useHTML = TRUE)
  })
  
  output$PL_graph <- renderHighchart({
    art %>% 
      filter(between(decade, input$frame_decade[1], input$frame_decade[2])) %>%
      mutate(painting_support_condition = 
               recode(media_type_1, "oil" = "oil", "acrylic" = "acrylic", "tempera" = "tempera")) %>%
      count(media_type_1, collection) %>%
      hchart("bar", stacking = "normal",
             #hcaes(x = collection, y = n, group = !!sym(input$media_type))) %>%
             hcaes(x = collection, y = n, group = media_type_1)) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_legend(title = list(text = "Media Types"), reversed = TRUE) %>%
      hc_title(text = "Media Types") %>%
      hc_tooltip(pointFormat = tooltip_table(c("Media Types:", "Number of paintings:"), 
                                             c("{point.media_type_1}", "{point.y}")), useHTML = TRUE)
  })
  
  ################################ Frame ################################
  
  output$Frame_eval <- renderHighchart({
    art %>% 
      mutate(frame_condition = 
               recode(frame_condition, "0" = "0 Poor", "1" = "1 Fair", "2" = "2 Good", "3" = "3 Excellent")) %>%
      count(frame_condition, collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = frame_condition)) %>%
      hc_yAxis(title = list(text = "Number of Paintings")) %>%
      hc_legend(title = list(text = "Condition Score"), reversed = TRUE) %>%
      hc_title(text = "Frame Condition") %>%
      hc_tooltip(pointFormat = tooltip_table(c("Frame Condition:", "Number of paintings:"), 
                                             c("{point.frame_condition}", "{point.y}")), useHTML = TRUE)
  })
  
  output$Frame_attr_graph <- renderHighchart({
    art %>% 
      filter(between(decade, input$frame_decade[1], input$frame_decade[2])) %>%
      count(!!sym(input$frame_attribute), collection) %>%
      hchart("bar", stacking = "normal",
             hcaes(x = collection, y = n, group = !!sym(input$frame_attribute))) %>%
      hc_plotOptions(column = list(borderRadius = 5)) %>%
      hc_legend(title = list(text = "Value"), reversed = TRUE) %>%
      hc_tooltip(crosshairs = TRUE, shared = TRUE) %>%
      hc_xAxis(title = list(text = "Museum")) %>%
      hc_yAxis(title = list(text = "Number of Paintings"))
  })
  
  ################################ Explore Artist ################################
  
  output$Artist_active <- renderHighchart({
    art %>%
      filter(artist %in% input$Artist) %>%
      count(artist, decade) %>%
      hchart("column", hcaes(x = decade, y = n))
  })
  
  ################################ Explore Database ################################
  
  output$tbl <- DT::renderDataTable(display_art, rownames = FALSE, options = list(
    pageLength = 10, autoWidth = T, 
    columnDefs = list(list(width = '500px', className = 'dt-center', targets = "_all"))
  )
  )
})
