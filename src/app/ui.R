#
# You can run the application by clicking 'Run App' above.
#

library(shiny)
library(leaflet)
library(shinythemes)
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
              leafletOutput("mymap", height = 600)
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
                                  sidebarPanel(selectInput("PS", "Choose a support condition:",
                                                        list("Planar" = 'planar_painting_support',
                                                             "Warped" = 'warped_painting_support',
                                                             "Indentation" = 'indentations_painting_support',
                                                             "Positive Tension" = 'good_tension_painting_support',
                                                             "Holes" = 'holes_painting_support',
                                                             "Loose" = 'loose_painting_support',
                                                             "Tears" = 'tears_painting_support',
                                                             "Taunt" = 'taut_painting_support',
                                                             "Surface Dirt" = 'surface_dirt_painting_support',
                                                             "Mould" = 'mould_painting_support',
                                                             "Stains" = 'staining_painting_support',
                                                             "Corner Distortion" = 'corner_distortions_painting_support',
                                                             "Top Distortion" = 'top_distortions_painting_support',
                                                             "Bottom Distortion" = 'bottom_distortions_painting_support',
                                                             "Overall Distortion" = 'overall_distortions_painting_support',
                                                             "Insect Damage" = 'insect_damage_painting_support',
                                                             "Rust Stain" = 'rust_stains_on_support_painting_support',
                                                             "Deformation Around Tack Staples" = 'deformation_around_tacks_staples_painting_support',
                                                             "Tears Around Tack Staples" = 'tears_around_tacks_staples_painting_support',
                                                             "Loss of Tacks" = 'loss_of_tacks_insecure_support_painting_support'))
                                  ),
                                  mainPanel(highchartOutput("PS_planar"))
                                )
                       ),
                       tabPanel("Ground Layer"),
                       tabPanel("Paint Layer"),
                       tabPanel("Frame"))
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
