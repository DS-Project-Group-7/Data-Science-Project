#
# You can run the application by clicking 'Run App' above.
#

library(shiny)
library(shinythemes)
library(shinydashboard)
source('helper.R')

header <- dashboardHeader(
  title = tags$a(href='https://bit.ly/3zmFzns', target = "_blank",
                 tags$img(src='https://bit.ly/3cSvLu7',
                          height='40', width='160')),
  titleWidth = 340,
  dropdownMenuCustom(type = "message",
                     customSentence = customSentence,
                     messageItem(
                       from = "Email us for support",
                       message = "",
                       icon = icon("envelope"),
                       href = "mailto:haonanz1@student.unimelb.edu.au"
                     ),
                     icon = icon('comment')
  )
)

sidebar <- dashboardSidebar(
  width = 350,
  sidebarMenu(
    menuItem("National Art Gallery (Malaysia)",
             tabName = "malay",
             menuSubItem("Material", tabName = "malaymaterial"),
             menuSubItem("Condition", tabName = "malaycondition"),
             icon = icon("landmark")),
    menuItem("J.B. Vargas Museum (Philippines)",
             menuSubItem("Material", tabName = "philimaterial"),
             menuSubItem("Condition", tabName = "philicondition"),
             icon = icon("landmark")),
    menuItem("Heritage Conservation Board (Singapore)",
             menuSubItem("Material", tabName = "singmaterial"),
             menuSubItem("Condition", tabName = "singcondition"),
             icon = icon("landmark")),
    menuItem("National Gallery (Thailand)",
             menuSubItem("Material", tabName = "thaimaterial"),
             menuSubItem("Condition", tabName = "thaicondition"),
             icon = icon("landmark")),
    menuItem("Summary",
             menuSubItem("Material", tabName = "summaterial"),
             menuSubItem("Condition", tabName = "sumcondition"),
             icon = icon("plus"))
  )
)

body <- dashboardBody(
  tabItems(
    tabItem("malaymaterial",
            "Malaysia material tab content"
    ),
    tabItem("malaycondition",
            "Malaysia condition tab content"
    ),
    tabItem("philimaterial",
            "Philippine material tab content"
    ),
    tabItem("philicondition",
            "Philippine condition tab content"
    ),
    tabItem("singmaterial",
            "Singapore material tab content"
    ),
    tabItem("singcondition",
            "Singapore condition tab content"
    ),
    tabItem("thaimaterial",
            "Thailand material tab content"
    ),
    tabItem("thaicondition",
            "Thailand condition tab content"
    ),
    tabItem("summaterial",
            "Summary material tab content"
    ),
    tabItem("sumcondition",
            "Summary condition tab content"
    )
  )
)


ui <- dashboardPage(skin = "black",
                    header, 
                    sidebar, 
                    body
)
