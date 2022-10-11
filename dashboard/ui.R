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
library(shinyBS)


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
                     actionButton(
                       inputId = "sign_out",
                       label = "Sign out",
                       icon = icon("sign-out-alt")
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
    menuItem("Gallery",
             tabName = "gallery",
             icon = icon("envira")),
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
              p(em("This interactive dashboard visualises research data from a joint project on The Behaviour of Western Artist's Materials in Tropical Environments
                   between Balai Seni Negara (National Art Gallery) Malaysia, the JB Vargas Museum in Philippines, the National Heritage Board in Singapore, 
                   the National Gallery in Bangkok and the Centre for Cultural Materials Conservation at the University of Melbourne.1 
                   It focused on a survey of 208 canvas paintings examined from 2003-2005 and is supported by materials and laser speckle analysis. 
                   Results were also reviewed in the context of the supply of artists’ materials and art training opportunities, 
                   proposing that they provided the conditions for the transfer of ‘Western’ oil painting practice. 
                   For further information on the project, 
                   see: https://arts.unimelb.edu.au/grimwade-centre-for-cultural-materials-conservation/engagement/partners-and-networks/international/tropical-environments")
              ),
              hr(),
              p(strong("Number of Paintings:")),
              fluidRow(
                column(3, valueBoxOutput("sing_count", width = 14)),
                column(3, valueBoxOutput("mala_count", width = 14)),
                column(3, valueBoxOutput("thai_count", width = 14)),
                column(3, valueBoxOutput("phil_count", width = 14))
              ),
              fluidRow(
                column(12, leafletOutput("mymap", height = 500))
                # column(6, imageOutput("cooking_rice")),
                #        bsTooltip(id = "cooking_rice", 
                #                  title = "Cooking Rice, Fernando Amorsolo (1959), J.B. Vargas Museum, University of the Philippines"
                #        )
              ),
              hr(),
              fluidRow(
                column(12, highchartOutput("Decade_Sum"))
              ),
              hr(),
              p(paste("ARC Linkage Grant LP0211015","The Behaviour of Western Materials in Tropical Environments","(the National Heritage Board Singapore, National Gallery of Malaysia, the National Gallery of Thailand, the JB Vargas Museum University of the Philippines) (with Chief investigators Professor R Sloggett and Professor A Roberts, and PhD student Nicole Tse (2003-2008).")
              )
            )
    ),
    tabItem("dim",
            titlePanel(strong("Painting Dimension Overview")),
            fluidRow(
              column(12, highchartOutput("DM_eval"))
            ),
            hr(),
            fluidRow(
              column(12, highchartOutput("DM_bub"))
            ),
            hr(),
            fluidRow(
              column(12, highchartOutput("DM_area"))
            )
    ),
    tabItem("gallery",
            titlePanel(strong("Gallery")),
            hr(),
            h3("Balai Seni Negara (Malaysia)"),
            fluidRow(
              column(6, imageOutput("ChenWen_1")),
                     bsTooltip(id = "ChenWen_1", 
                               title = "Chen Wen Hsi, Ikan Untuk Hidangan, 1958, oil on canvasboard, framed, Balai Seni Negara (Malaysia), image Nicole Tse"
                              ),
              column(6,imageOutput("ChenWen_2")),
              bsTooltip(id = "ChenWen_2", 
                        title = "Detail from Chen Wen His, Ikan Untuk Hidangan, 1958, oil on canvasboard, framed, Balai Seni Negara (Malaysia), image Nicole Tse"
              )
            ),
            hr(),
            fluidRow(
              column(6, imageOutput("ChenWen_3")),
              bsTooltip(id = "ChenWen_3", 
                        title = "Paint brushwork detail from Chen Wen Hsi, Budak Dengan Burung, 1963, oil on Masonite, framed, Balai Seni Negara (Malaysia), image Nicole Tse"
              ),
              column(6, imageOutput("CheongSoo_1")),
              bsTooltip(id = "CheongSoo_1", 
                        title = "Paint cross section (x100) from Cheong Soo Pieng Dua Wanita Ditepi Pantal, 1945, oil on canvas, framed, Balai Seni Negara (Malaysia), image Nicole Tse"
              )
            ),
            hr(),
            fluidRow(
              column(6, imageOutput("CheongSoo_2")),
              bsTooltip(id = "CheongSoo_2", 
                        title = "Cheong Soo Pieng, Dua Wanita Ditepi Pantal, 1945, oil on canvas, framed, Balai Seni Negara (Malaysia), image Nicole Tse"
              ),
              column(6, imageOutput("Mohd_1")),
              bsTooltip(id = "Mohd_1", 
                        title = "‘Joyo’ canvas stamp ‘Made in Japan’ from Datuk Mohd. Hossein Enas, Dua Beradik (two sisters) 1962, oil on canvas, framed, Balai Seni Negara (Malaysia), image Nicole Tse"
              )
            ),
            hr(),
    ),
    tabItem("aux",
            titlePanel(strong("Auxiliary Support Overview")),
            fluidRow(
              column(12, highchartOutput("AX_eval"))
            ),
            fluidRow(
              column(8, textOutput("aux_tableinfo")),
              column(2),
              column(2, actionButton("aux_hide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('aux_table'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr(),
            sidebarLayout(
              sidebarPanel(
                checkboxGroupInput("AX_check", "Select collections for visualisation:", Museum_choiceVec, selected = Museum_choiceVec),
                sliderInput("AX_decade", "Select a time period for visualisation", 
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = ""),
                selectInput("AX", "Choose a support condition to view a brief summary:",
                            AX_choiceVec)
              ),
              mainPanel(highchartOutput("AX_visual"))
            ),
            fluidRow(
              column(8, textOutput("aux_vtableinfo")),
              column(2),
              column(2, actionButton("aux_vhide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('aux_vtable'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr(),
            fluidRow(
              column(12, highchartOutput("AX_heat"))
            ),
            hr(),
            fluidRow(
                column(12, highchartOutput("AX_wood"))
            ),
            actionButton("button", "Show Line Chart")
            
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
            fluidRow(
              column(12, DT::dataTableOutput('PS_table'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr(),
            sidebarLayout(
              sidebarPanel(
                checkboxGroupInput("PS_check", "Select collections for visualisation:", Museum_choiceVec, selected = Museum_choiceVec),
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
            hr(),
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
            fluidRow(
              column(12, DT::dataTableOutput('GR_table'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr(),
            sidebarLayout(
              sidebarPanel(
                checkboxGroupInput("GR_check", "Select collections for visualisation:", Museum_choiceVec, selected = Museum_choiceVec),
                selectInput("GR", "Choose a ground layer condition to view a brief summary:",
                            GR_choiceVec),
                sliderInput("GR_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = "")
              ),
              mainPanel(
                highchartOutput("GR_visual")
              )
            ),
            fluidRow(
              column(8, textOutput("GR_vtableinfo")),
              column(2),
              column(2, actionButton("GR_vhide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('GR_vtable'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr()
    ),
    tabItem("pl",
            titlePanel(strong("Paint Layer Overview")),
            fluidRow(
              column(12, highchartOutput("painting_layer"))
            ),
            fluidRow(
              column(8, textOutput("PL_tableinfo")),
              column(2),
              column(2, actionButton("PL_hide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('PL_table'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr(),
            sidebarLayout(
              sidebarPanel(
                checkboxGroupInput("Paint_Layer_filter_check", "Select collections for visualisation:", Museum_choiceVec, selected = Museum_choiceVec),
                selectInput("paint_layer_type", "Choose a paint layer condition to view a brief summary:",
                            Painting_choiceVec),
                sliderInput("paint_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = "")
              ),
              mainPanel(highchartOutput("PL_visual"))
            ),
            fluidRow(
              column(8, textOutput("PL_vtableinfo")),
              column(2),
              column(2, actionButton("PL_vhide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('PL_vtable'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr()
    ),
    tabItem("fr",
            titlePanel(strong("Frame Overview")),
            fluidRow(
              column(12, highchartOutput("Frame_eval"))
            ),
            fluidRow(
              column(8, textOutput("Frame_tableinfo")),
              column(2),
              column(2, actionButton("frame_hide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('Frame_table'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr(),
            sidebarLayout(
              sidebarPanel(
                checkboxGroupInput("Frame_musium_filter_check", "Select collections for visualisation:", Museum_choiceVec, selected = Museum_choiceVec),
                sliderInput("frame_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = ""),
                selectInput("frame_attribute", "Choose a frame attribute to view a brief summary:",
                            Frame_choiceVec)
              ),
              mainPanel(highchartOutput("Frame_attr_graph"))
            ),
            fluidRow(
              column(8, textOutput("Frame_vtableinfo")),
              column(2),
              column(2, actionButton("frame_vhide", "Hide/Unhide Table", value = T))
            ),
            fluidRow(
              column(12, DT::dataTableOutput('Frame_vtable'), style = 
                       "width:1000px; overflow-y: scroll;overflow-x: scroll;")
            ),
            hr()
    ),
    tabItem("artist",
              titlePanel(strong("Explore Artists")),
              br(),
              sidebarLayout(
                sidebarPanel(
                  selectInput("Artist", "Choose an artist to view their active years:", Artist_choiceVec)
                ),
                mainPanel(highchartOutput("Artist_active"))
              ),
            hr(),
            sidebarLayout(
              sidebarPanel(
                sliderInput("Artist_decade", "Select a time period for visualisation",
                            min = 1850, max = 1970, step = 10, value = c(1850, 1970),sep = "")
              ),
              mainPanel(highchartOutput("Artist_media"))
            ),
            hr(),
            fluidRow(
              column(12, highchartOutput("Artist_support"))
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

# customize your sign in page UI with logos, text, and colors.
my_custom_sign_in_page <- sign_in_ui_default(
  color = "#ffffff",
  company_name = "University of Melbourne",
  logo_top = tags$img(src='https://bit.ly/3cSvLu7',
                      height='40', width='160',style = "width: 160px; margin-top: 30px; margin-bottom: 30px;"),
  button_color = "#2445d6",
  footer_color = "#0a0a0a"
)

ui <- dashboardPage(
  title = "SEA Conservation Dashboard",
  header,
  sidebar,
  body
)
# secure your UI behind your custom sign in page
polished::secure_ui(ui,sign_in_page_ui = my_custom_sign_in_page)


