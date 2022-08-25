#
# You can run the application by clicking 'Run App' above.
#

library(shiny)
library(leaflet)
library(shinythemes)
library(shinyWidgets)
library(shinydashboard)
library(highcharter)
library(dashboardthemes)
source('helper.R')

tags$style("@import url(https://use.fontawesome.com/releases/v5.7.2/css/all.css);")

header <- dashboardHeader(
  title = tags$a(href='https://bit.ly/3zmFzns', target = "_blank",
                 tags$img(src='https://bit.ly/3cSvLu7',
                          height='40', width='160')),
  titleWidth = 350,
  dropdownMenuCustom(type = "message",
                     customSentence = customSentence,
                     messageItem(
                       from = "Email us for support",
                       message = "",
                       icon = icon("paper-plane"),
                       href = "mailto:haonanz1@student.unimelb.edu.au"
                     ),
                     icon = icon("gear", class = "mystyle"),
                     tags$style(".mystyle {color:black;}")
                     
  )
)

sidebar <- dashboardSidebar(
  width = 350,
  sidebarMenu(
    menuItem("Home",
             tabName = "home",
             selected = T,
             icon = icon("house-user")),
    menuItem("Dimension",
             tabName = "dim",
             icon = icon("chart-area")),
    menuItem("Auxiliary Support",
             tabName = "aux",
             icon = icon("hand-point-right")),
    menuItem("Painting Support",
             tabName = "psup",
             icon = icon("hand-point-right")),
    menuItem("Ground Layer",
             tabName = "gl",
             icon = icon("hand-point-right")),
    menuItem("Paint Layer",
             tabName = "pl",
             icon = icon("hand-point-right")),
    menuItem("Frame",
             tabName = "fr",
             icon = icon("hand-point-right")),
    menuItem("Explore Database",
             tabName = "dataPresentation",
             icon = icon("plus"))
  )
)

body <- dashboardBody(
  customTheme,
  
  tabItems(
    tabItem("home",
            fluidPage(
              titlePanel("Welcome to the Southeast Asia Painting Conservation Dashboard!"),
              leafletOutput("mymap", height = 500),
              fluidRow(
                column(12, highchartOutput("Decade_Sum"))
              )
            )
    ),
    tabItem("dataPresentation",
            fluidPage(
              titlePanel("Data Exploration"),
              column(12, DT::dataTableOutput('tbl'), style = "width:900px; overflow-y: scroll;overflow-x: scroll;")
            )
    ),
    tabItem("dim",
            fluidRow(
              column(12, highchartOutput("DM_eval"))
            ),
            fluidRow(
              column(12, highchartOutput("DM_bub"))
            )
    ),
    tabItem("aux",
            fluidRow(
              column(12, highchartOutput("AX_eval"))
            ),
            
            sidebarLayout(
              sidebarPanel(selectInput("AX", "Choose a support condition to view a brief summary:",
                                       AX_choiceVec),
                           sliderInput("AX_decade", "Select a time period for visualisation", 
                                       min = 1850, max = 1970, step = 10, value = c(1850, 1970))
              ),
              mainPanel(highchartOutput("AX_heat"))
            ),
            fluidRow(
              column(12, highchartOutput("AX_wood"))
            )
    ),
    tabItem("psup",
            titlePanel("Painting Support Condition Summary Page"),
            fluidRow(
              column(12, highchartOutput("PS_eval"))
            ),
            sidebarLayout(
              sidebarPanel(
                selectInput("PS", "Choose a support condition to view a brief summary:",
                            PS_choiceVec),
                sliderInput("PS_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970))
              ),
              mainPanel(highchartOutput("PS_visual"))
            ),
            sidebarLayout(
              sidebarPanel(
                selectInput("PS_1", "Choose the first attribute:",
                            PS_choiceVec),
                selectInput("PS_2", "Choose the second attribute:",
                            PS_choiceVec, selected = PS_choiceVec[2])
              ),
              mainPanel(
                highchartOutput("PS_heatmap")
              )
            ),
            fluidRow(
              verbatimTextOutput("PS_test")
            )
    ),
    tabItem("gl",
            fluidRow(
              column(12, highchartOutput("GR_eval"))
            ),
            sidebarLayout(
              sidebarPanel(
                selectInput("GR", "Choose a ground layer condition to view a brief summary:",
                            GR_choiceVec),
                sliderInput("GR_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970))
              ),
              mainPanel(
                highchartOutput("GR_visual")
              )
            )
    ),
    tabItem("pl",
            fluidPage(
              titlePanel("Paint Layer Summary")
            )
    ),
    tabItem("fr",
            fluidRow(
              column(12, highchartOutput("Frame_eval"))
            ),
            sidebarLayout(
              sidebarPanel(
                selectInput("frame_attribute", "Choose a frame atribute to view a brief summary:",
                            Frame_choiceVec),
                sliderInput("frame_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970))
              ),
              mainPanel(highchartOutput("Frame_attr_graph"))
            )
    )
  )
)


ui <- dashboardPage(
                    header, 
                    sidebar, 
                    body
)
