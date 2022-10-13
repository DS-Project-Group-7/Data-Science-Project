library(dplyr)
library(polished)
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}




display_art <- read.csv("../data/cleanData.csv")[,-1]
display_art <- display_art %>%
  mutate(auxiliary_support_condition = recode(auxiliary_support_condition, "0" = "Poor", "1" = "Fair", "2" = "Good", "3" = "Excellent")) %>%
  mutate(media_condition = recode(media_condition, "0" = "Poor", "1" = "Fair", "2" = "Good", "3" = "Excellent")) %>%
  mutate(ground_condition = recode(ground_condition, "0" = "Poor", "1" = "Fair", "2" = "Good", "3" = "Excellent")) %>%
  mutate(painting_support_condition = recode(painting_support_condition, "0" = "Poor", "1" = "Fair", "2" = "Good", "3" = "Excellent")) %>%
  mutate(frame_condition = recode(frame_condition, "0" = "Poor", "1" = "Fair", "2" = "Good", "3" = "Excellent"))

names(display_art) <- gsub("_", " ", names(display_art))
names(display_art) <- sapply(names(display_art), simpleCap)

# Identify binary columns
binary_column <- display_art %>%
  purrr::map_lgl(~all(.x %in% c(0,1))) %>% 
  .[-1] %>% 
  as.data.frame() %>%  
  setNames("values")
binary_column_true <- rownames(binary_column)[which(binary_column == T, arr.ind = TRUE)[, 1]]
display_art <- display_art %>%
  mutate(across(binary_column_true, 
                ~factor(ifelse(.x == "1","Yes","No"))))
  

art <- read.csv("../data/cleanData.csv")[,-1]

customSentence <- function(numItems, type) {
  paste("Contact us")
}

##
dropdownMenuCustom <- function (..., type = c("messages", "notifications", "tasks"), 
                                badgeStatus = "primary", icon = NULL, .list = NULL, customSentence = customSentence) {
  type <- match.arg(type)
  if (!is.null(badgeStatus)) shinydashboard:::validateStatus(badgeStatus)
  items <- c(list(...), .list)
  dropdownClass <- paste0("dropdown ", type, "-menu")
  if (is.null(icon)) {
    icon <- switch(type, messages = shiny::icon("envelope"), 
                   notifications = shiny::icon("warning"), tasks = shiny::icon("tasks"))
  }
  numItems <- length(items)
  if (is.null(badgeStatus)) {
    badge <- NULL
  }
  else {
    badge <- tags$span(class = paste0("label label-", badgeStatus), 
                       numItems)
  }
  tags$li(
    class = dropdownClass, 
    a(
      href = "#", 
      class = "dropdown-toggle", 
      `data-toggle` = "dropdown", 
      icon, 
      badge
    ), 
    tags$ul(
      class = "dropdown-menu", 
      tags$li(
        class = "header", 
        customSentence(numItems, type)
      ), 
      tags$li(
        tags$ul(class = "menu", items)
      )
    )
  )
}

customTheme <- shinyDashboardThemeDIY(
  ### general
  appFontFamily = "Optima"
  ,appFontColor = "#2D2D2D"
  ,primaryFontColor = "#000000"
  ,infoFontColor = "#000000"
  ,successFontColor = "#0F0F0F"
  ,warningFontColor = "#D41A1A"
  ,dangerFontColor = "#D41A1A"
  ,bodyBackColor = "#FFFFFF"
  
  ### header
  ,logoBackColor = "#FFFFFF"
  
  ,headerButtonBackColor = "#FFFFFF"
  ,headerButtonIconColor = "#000000"
  ,headerButtonBackColorHover = "#CAE0E6"
  ,headerButtonIconColorHover = "#000000"
  
  ,headerBackColor = "#FFFFFF"
  ,headerBoxShadowColor = ""
  ,headerBoxShadowSize = "0px 0px 0px"
  
  ### sidebar
  ,sidebarBackColor = "#F0F0F0"
  ,sidebarPadding = "3"
  
  ,sidebarMenuBackColor = "transparent"
  ,sidebarMenuPadding = "2"
  ,sidebarMenuBorderRadius = 0
  
  ,sidebarShadowRadius = ""
  ,sidebarShadowColor = "0px 0px 0px"
  
  ,sidebarUserTextColor = "#737373"
  
  ,sidebarSearchBackColor = "#FFFFFF"
  ,sidebarSearchIconColor = "#000000"
  ,sidebarSearchBorderColor = "#DCDCDC"
  
  ,sidebarTabTextColor = "#737373"
  ,sidebarTabTextSize = "15"
  ,sidebarTabBorderStyle = "none"
  ,sidebarTabBorderColor = "none"
  ,sidebarTabBorderWidth = "0"
  
  ,sidebarTabBackColorSelected = "#D1D1D1"
  ,sidebarTabTextColorSelected = "#000000"
  ,sidebarTabRadiusSelected = "0px"
  
  ,sidebarTabBackColorHover = "#F5F5F5"
  ,sidebarTabTextColorHover = "#000000"
  ,sidebarTabBorderStyleHover = "none solid none none"
  ,sidebarTabBorderColorHover = "#C8C8C8"
  ,sidebarTabBorderWidthHover = "4"
  ,sidebarTabRadiusHover = "0px"
  
  ### boxes
  ,boxBackColor = "#FFFFFF"
  ,boxBorderRadius = "5"
  ,boxShadowSize = "none"
  ,boxShadowColor = ""
  ,boxTitleSize = "18"
  ,boxDefaultColor = "#E1E1E1"
  ,boxPrimaryColor = "#5F9BD5"
  ,boxInfoColor = "#B4B4B4"
  ,boxSuccessColor = "#70AD47"
  ,boxWarningColor = "#ED7D31"
  ,boxDangerColor = "#E84C22"
  
  ,tabBoxTabColor = "#F8F8F8"
  ,tabBoxTabTextSize = "14"
  ,tabBoxTabTextColor = "#646464"
  ,tabBoxTabTextColorSelected = "#2D2D2D"
  ,tabBoxBackColor = "#F8F8F8"
  ,tabBoxHighlightColor = "#C8C8C8"
  ,tabBoxBorderRadius = "5"
  
  ### inputs
  ,buttonBackColor = "#E2D2FA"
  ,buttonTextColor = "#2D2D2D"
  ,buttonBorderColor = "#FFFFFF"
  ,buttonBorderRadius = "9"
  
  ,buttonBackColorHover = "#BEBEBE"
  ,buttonTextColorHover = "#000000"
  ,buttonBorderColorHover = "#969696"
  
  ,textboxBackColor = "#FFFFFF"
  ,textboxBorderColor = "#6C6C6C"
  ,textboxBorderRadius = "9"
  ,textboxBackColorSelect = "#F5F5F5"
  ,textboxBorderColorSelect = "#6C6C6C"
  
  ### tables
  ,tableBackColor = "#F8F8F8"
  ,tableBorderColor = "#EEEEEE"
  ,tableBorderTopSize = "5"
  ,tableBorderRowSize = "4"
)

content_phil <- paste(sep = "<br/>",
                      "<b><a href='https://vargasmuseum.wordpress.com'>JB Vargas Museum</a></b>",
                      "Museum Collection: 59"
)

content_mala <- paste(sep = "<br/>",
                      "<b><a href='https://www.artgallery.gov.my/en/homepage/'>National Art Gallery (Malaysia)</a></b>",
                      "Museum Collection: 53"
)

content_sing <- paste(sep = "<br/>",
                      "<b><a href='https://www.nhb.gov.sg'>National Heritage Board</a></b>",
                      "Museum Collection: 63"
)

content_thai <- paste(sep = "<br/>",
                      "<b><a href='https://www.museumthailand.com/en/museum/The-National-Gallery-Hor-Silp-Chao-Fa'>National Art Gallery (Thailand)</a></b>",
                      "Museum Collection: 33"
)

PS_choiceVec <- c(
  "Planar" = 'planar_painting_support',
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
  "Loss of Tacks" = 'loss_of_tacks_insecure_support_painting_support'
)

GR_choiceVec <- c(
  "Are Ground Layer Commercial or Artist Applied?" = 'ground_layer_application',
  "Size Layer Visible" = 'size_layer_visible',
  "Are Ground Layer Thinly or Thickly Applied?" = 'ground_layer_thickness',
  "Coloured Ground" = 'coloured_ground',
  "Sulphate" = 'id_sulphate',
  "Carbonate" = 'id_carbonate',
  "Uniform Application" = 'uniform_application',
  "Proprietary Paint" = 'ground_proprietary_paint',
  "Are Ground Applied To Side or Face Edge?" = 'ground_layer_limit'
)

AX_choiceVec <- c(
  "Accretions" = 'accretions_auxiliary_support',
  "Indentations" = 'indentations_auxiliary_support',
  "Insect Damage" = 'insect_damage_auxiliary_support',
  "Joins Unstable" = 'joins_unstable_auxiliary_support',
  "Joins Split" = 'joins_split_auxiliary_support',
  "Joins not Flat" = 'joins_not_flat_auxiliary_support',
  "Mould" = 'mould_auxiliary_support',
  "Planar" = 'planar_auxiliary_support',
  "Previous Treatment" = 'prev_treatment_auxiliary_support',
  "Surface Dirt" = 'surface_dirt_auxiliary_support',
  "Staining" = 'staining_auxiliary_support',
  "Warped" = 'warped_auxiliary_support'
)

Frame_choiceVec <- c(
  "Frame material" = 'frame_material',
  "Slip Presence" = 'slip_presence_frame',
  "Glazed" = 'glazed_frame',
  "Affixed to wall by" = 'frame_affixed_to_wall_by',
  "Hanging system" = 'frame_hanging_system',
  "Strand wire" = 'frame_strand_wire',
  "Backing board" = 'backing_board_type'
)

Painting_choiceVec <- c(
  "Abrasions" = 'abrasions_media',
  "Accretions" = 'accretions_media',
  "Adhered well to support" = 'adhered_well_to_support',
  "Blind Cleavage" = 'cleavage_media',
  "Cracking" = 'cracking_media',
  "Discolouration" = 'discolouration_media',
  "Flaking" = 'flaking_media',
  "Losses" = 'losses_media',
  "Overpainting" = 'overpainting_media',
  "Surface Dirt" = 'surface_dirt_media',
  "Plastic Behaviour" = 'appears_plastic',
  "Elastic Behaviour" = 'appears_elastic',
  "Dry cured" = 'dry_cured',
  "Infilling" = 'infilling'
)

Museum_choiceVec <- c(
  "JB Vargas Museum (Philippines)",
  "National Gallery (Thailand)",
  "Balai Seni Negara (Malaysia)",
  "National Heritage Board (Singapore)"
)

Artist_choiceVec <- sort(unique(art$artist))

mala_labels <- sprintf(
  "Collection: <strong>%s</strong><br/>Number of Paintings: 53<br/><img src=%s alt=\"malay_museum\" width=\"300\" height=\"200\">",
  "Balai Seni Negara (Malaysia)","malay_museum.png"
) %>% lapply(htmltools::HTML)

thai_labels <- sprintf(
  "Collection: <strong>%s</strong><br/>Number of Paintings: 33<br/><img src=%s alt=\"th_museum\" width=\"300\" height=\"200\">",
  "National Gallery (Thailand)","th_museum.png"
) %>% lapply(htmltools::HTML)

phil_labels <- sprintf(
  "Collection: <strong>%s</strong><br/>Number of Paintings: 59<br/><img src=%s alt=\"ph_museum\" width=\"300\" height=\"200\">",
  "JB Vargas Museum (Philippines)","ph_museum.jpeg"
) %>% lapply(htmltools::HTML)

  
sing_labels <- sprintf(
  "Collection: <strong>%s</strong><br/>Number of Paintings: 63<br/><img src=%s alt=\"sg_museum\" width=\"300\" height=\"200\">",
  "National Heritage Board (Singapore)","sg_museum.jpeg"
) %>% lapply(htmltools::HTML)

special_vec <- c("ground_layer_limit", 'ground_layer_application', "ground_layer_thickness")


# convert_log = function(x){if (x == 1){"Yes" else { "No "}}}

# display_art %>% 
#  as_tibble %>% 
#  mutate_if(is.logical, convert_log)