server <- function(input, output, session) {
  country <- reactive({
    data <- switch (input$country,
                    "malaysia" = data.frame(cbind(new_data$malaysia, condition)),
                    "thailand" = data.frame(cbind(new_data$thailand, condition)),
                    "singapore" = data.frame(cbind(new_data$singapore, condition)),
                    "philippines" = data.frame(cbind(new_data$philippines, condition))
    )
  })
  country2 <- reactive({
    data <- switch (input$country,
                    "malaysia" = perCon[1,],
                    "thailand" = perCon[2,],
                    "singapore" = perCon[3,],
                    "philippines" = perCon[4,]
    )
  })
  
  output$hist <- renderPlot({
    ggplot(country(), aes(condition, as.numeric(V1), fill = condition)) +
      geom_bar(stat = 'identity') +
      labs(x = "Condition", y = "Count") +
      scale_colour_brewer(type = "seq", palette = "Spectral")
  })
  
}