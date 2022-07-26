ui <- fluidPage(
  titlePanel("Paint Layer Condition of the 4 Countries"),
  sidebarPanel(
    selectInput("country", "Choose a country", choices = c(unique(bar_data_2$country)))
  ),
  mainPanel(plotOutput("hist")),
)