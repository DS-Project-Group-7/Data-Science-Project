#
# You can run the application by clicking 'Run App' above.
#

library(shiny)
library(shinyjs)
library(leaflet)
library(shinythemes)
library(shinyWidgets)
library(shinydashboard)
library(highcharter)
library(dashboardthemes)
source('helper.R')

tags$style("@import url(https://use.fontawesome.com/releases/v5.15.4/css/all.css);")

header <- dashboardHeader(
  title = tags$a(href='https://bit.ly/3zmFzns', target = "_blank",
                 tags$img(src='https://bit.ly/3cSvLu7',
                          height='40', width='160')),
  titleWidth = 280,
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
  width = 280,
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
             icon = icon("border-all")),
    menuItem("Painting Support",
             tabName = "psup",
             icon = icon("scroll")),
    menuItem("Ground Layer",
             tabName = "gl",
             icon = icon("paint-brush")),
    menuItem("Paint Layer",
             tabName = "pl",
             icon = icon("palette")),
    menuItem("Frame",
             tabName = "fr",
             icon = icon("crop-alt")),
    menuItem("Explore Artist",
             tabName = "artist",
             icon = icon("users")),
    menuItem("Explore Database",
             tabName = "dataPresentation",
             icon = icon("th"))
  )
)

body <- dashboardBody(
  customTheme,
  
  tabItems(
    tabItem("home",
            fluidPage(
              titlePanel(strong("Southeast Asia Painting Conservation Data Visualisation Dashboard")),
              br(),
              p(em("The study behind this interactive dashboard was undertaken as a 
                three-year joint project between the National Art Gallery of Malaysia, 
                the J.B. Vargas Museum in Philippines, the Heritage Conservation Centre 
                in Singapore, the National Gallery in Bangkok and the Centre for Cultural Materials 
                Conservation at the University of Melbourne. It focused on a survey 
                examination of 208 canvas paintings with some specific materials analysis when 
                possible. Results were also reviewed in the context of the supply of 
                artists’ materials and art training opportunities, proposing that they 
                provided the conditions for the transfer of ‘Western’ oil painting practice.")
              ),
              br(),
              p(strong("Number of Paintings:")),
              fluidRow(
                column(3, valueBoxOutput("sing_count", width = 14)),
                column(3, valueBoxOutput("mala_count", width = 14)),
                column(3, valueBoxOutput("thai_count", width = 14)),
                column(3, valueBoxOutput("phil_count", width = 14))
              ),
              fluidRow(
                column(6, leafletOutput("mymap", height = 410)),
                column(6, imageOutput("cooking_rice"),
                       p(em("Cooking Rice, Fernando Amorsolo (1959), 
                            J.B. Vargas Museum, University of the Philippines")))
              ),
              br(),
              fluidRow(
                column(12, highchartOutput("Decade_Sum"))
              )
            )
    ),
    tabItem("dim",
            titlePanel(strong("Painting Dimension Overview")),
            fluidRow(
              column(12, highchartOutput("DM_eval"))
            ),
            fluidRow(
              column(12, highchartOutput("DM_bub"))
            )
    ),
    tabItem("aux",
            titlePanel(strong("Auxiliary Support Overview")),
            fluidRow(
              column(12, highchartOutput("AX_eval"))
            ),
            
            sidebarLayout(
              sidebarPanel(selectInput("AX", "Choose a support condition to view a brief summary:",
                                       AX_choiceVec),
                           sliderInput("AX_decade", "Select a time period for visualisation", 
                                       min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = "")
              ),
              mainPanel(highchartOutput("AX_heat"))
            ),
            fluidRow(
              column(12, highchartOutput("AX_wood"))
            )
    ),
    tabItem("psup",
            titlePanel(strong("Painting Support Overview")),
            fluidRow(
              column(12, highchartOutput("PS_eval"))
            ),
            fluidRow(
              column(8, textOutput("PS_tableinfo")),
              column(2),
              column(2, actionButton("ps_hide", "Hide/Unhide Table", value = T))
            ),
            br(),
            fluidRow(
              column(12, DT::dataTableOutput('PS_table'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            br(),
            sidebarLayout(
              sidebarPanel(
                checkboxGroupInput("PS_check", "Museum filter:", Museum_choiceVec, selected = Museum_choiceVec),
                sliderInput("PS_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = ""),
                selectInput("PS", "Choose a support condition to view a brief summary:",
                            PS_choiceVec)
              ),
              mainPanel(highchartOutput("PS_visual"))
            ),
            fluidRow(
              column(8, textOutput("PS_vtableinfo")),
              column(2),
              column(2, actionButton("ps_vhide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('PS_vtable'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            sidebarLayout(
              sidebarPanel(
                h4(strong("Heatmap for comparing two attributes")),
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
    tabItem("gl",
            titlePanel(strong("Ground Layer Overview")),
            fluidRow(
              column(12, highchartOutput("GR_eval"))
            ),
            fluidRow(
              column(8, textOutput("GR_tableinfo")),
              column(2),
              column(2, actionButton("GR_hide", "Hide/Unhide Table", value = T))
            ),
            br(),
            fluidRow(
              column(12, DT::dataTableOutput('GR_table'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            br(),
            sidebarLayout(
              sidebarPanel(
                checkboxGroupInput("GR_check", "Museum filter:", Museum_choiceVec, selected = Museum_choiceVec),
                selectInput("GR", "Choose a ground layer condition to view a brief summary:",
                            GR_choiceVec),
                sliderInput("GR_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = "")
              ),
              mainPanel(
                highchartOutput("GR_visual")
              )
            ),
            verbatimTextOutput("test"),
            fluidRow(
              column(8, textOutput("GR_vtableinfo")),
              column(2),
              column(2, actionButton("GR_vhide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('GR_vtable'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            )
    ),
    tabItem("pl",
            fluidRow(
              column(12, highchartOutput("painting_layer"))
            ),
            sidebarLayout(
              sidebarPanel(
                selectInput("media_type", "Choose a frame atribute to view a brief summary:",
                            Painting_choiceVec),
                sliderInput("frame_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = "")
              ),
              mainPanel(highchartOutput("PL_graph"))
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
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = "")
              ),
              mainPanel(highchartOutput("Frame_attr_graph"))
            )
    ),
    tabItem("artist",
              titlePanel(strong("Explore Artists")),
              br(),
              sidebarLayout(
                sidebarPanel(
                  selectInput("Artist", "Choose an artist to view their active years:", Artist_choiceVec)
                ),
                mainPanel(highchartOutput("Artist_active"))
              )
    ),
    tabItem("dataPresentation",
            fluidPage(
              titlePanel(strong("Data Exploration")),
              br(),
              column(12, DT::dataTableOutput('tbl'), style = 
                       "width:1200px; overflow-y: scroll;overflow-x: scroll;")
            )
    )
  )
)


ui <- dashboardPage(
                    header, 
                    sidebar, 
                    body
)
