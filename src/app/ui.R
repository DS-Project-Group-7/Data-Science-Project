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
                     icon = icon("comment", class = "mystyle"),
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
    menuItem("Summary", tabName = "summary",
             icon = icon("plus")),
    menuItem("National Art Gallery (Malaysia)",
             tabName = "malay",
             icon = icon("landmark")),
    menuItem("Vargas Museum (Philippines)",
             tabName = "phil",
             icon = icon("landmark")),
    menuItem("Heritage Conservation Board (Singapore)",
             tabName = "sing",
             icon = icon("landmark")),
    menuItem("National Gallery (Thailand)",
             tabName = "thai",
             icon = icon("landmark"))
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
                column(6, highchartOutput("Decade_Sum")),
                column(6, highchartOutput("Size_sum"))
              )
            )
    ),
    tabItem("summary",
            navbarPage("Material Summary",
                       tabPanel("Auxiliary Support"),
                       tabPanel("Painting Support",
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
                                  mainPanel(highchartOutput("PS_planar"))
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
                                )
                       ),
                       tabPanel("Ground Layer"),
                        tabPanel("Paint Layer",
                                fluidRow(
                                  column(12, highchartOutput("painting_layer"))
                                ) ),
                       tabPanel("Frame",
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
                                )))
    ),
    tabItem("malay",
            fluidPage(
              titlePanel("National Art Gallery of Malaysia Material Summary")
            )
    ),
    tabItem("phil",
            fluidPage(
              titlePanel("Vargas Museun Material Summary")
            )
    ),
    tabItem("sing",
            fluidPage(
              titlePanel("National Heritage Board Material Summary")
            )
    ),
    tabItem("thai",
            fluidPage(
              titlePanel("National Art Gallery Thailand Material Summary")
            )
    )
  )
)


ui <- dashboardPage(
  header, 
  sidebar, 
  body
)
