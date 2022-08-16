library(ggplot2)
library(readxl)
library(dplyr)
library(highcharter)



clean_data <-
  read.csv(
    "data/cleanData.csv"
  )
#clean_data%>%
#  group_by(country)%>%
#  summarise(`adhered well to support`)

#clean_data%>%
#  filter(country == "thailand")%>%
#  select(artist,location)
#Set Theme
options(highcharter.theme = hc_theme_google())
#Clean year to be decades
#clean_data$year<-paste0(substr(clean_data$date,1,3),"0s")

#Density area by time


#scatter plot chart
scatter_data <-clean_data%>%
  select(
    collection,
    length,
    width,
  )

hchart(
  scatter_data,
  "scatter",
  hcaes(x = width, y = length, group = collection)
)%>%
  hc_title(
    text = "Scattor plot between width and length of 19th oil painting South East Asia"
  )


hcboxplot(
  outliers = FALSE,
  x = scatter_data$length,
  var = scatter_data$collection,
  name = "Length"
) %>%
  hc_title(text = "Width  by Museum collection") %>%
  hc_yAxis(title = list(text = "Width in milimetre")) %>%
  hc_chart(type = "column")


hcboxplot(
  outliers = FALSE,
  x = scatter_data$length,
  var = scatter_data$collection,
  name = "Length"
  ) %>%
  hc_title(text = "length  by Museum collection") %>%
  hc_yAxis(title = list(text = "length in milimetre")) %>%
  hc_chart(type = "column")

#box plot of width and length 
#density
#area vs time -> density
#Density area by time


clean_data$area<-sapply(clean_data$area, function(x) x/100)

den_data<-clean_data%>%
  select(
    year,
    area
  )


hchart(
  density(den_data$area), 
  type = "area", name = "area"
)

hchart(
  den_data$area, 
  type = "area", name = "area"
)

#area -> media_condition  

#Support type bar chart
clean_data %>% count(auxiliary_support_condition, collection)

sup_bar_data <-clean_data%>%
  select(
    country,
    support_type
  )%>%
  group_by(country)%>%
  count(support_type)

sup_bar_data<-sup_bar_data[!(is.na(sup_bar_data$support_type) | sup_bar_data$support_type==""), ]
#Group by collection
hchart(
  sup_bar_data,
  'column', hcaes(x = country, y = n,color=support_type,group=support_type),
  stacking = "normal"
)%>%
  hc_title(
    text = "Bar plot support type of 19th oil painting South East Asia"
  )

#heatmap
#area vs time => overall condition

test<-clean_data %>% 
  group_by(planar_auxiliary_support,warped_auxiliary_support)%>%
  summarise(Frequency = sum(auxiliary_support_condition))

test<-clean_data%>%
  count(auxiliary_support_condition,planar_auxiliary_support,warped_auxiliary_support)

ggplot(test,aes(auxiliary_support_condition,planar_auxiliary_support,warped_auxiliary_support))+
  geom_tile(aes(fill = n))





  hchart(heatmap_data, "heatmap", hcaes(x = planar_auxiliary_support, y = warped_auxiliary_support, value = n), name = "Aux Condition")

heatmap_data<-clean_data%>%
  group_by(
    planar_auxiliary_support,
    warped_auxiliary_support
    #mould_auxiliary_support,
    #surface_dirt_auxiliary_support,
    #staining_auxiliary_support,
    #insect_damage_auxiliary_support,
    #accretions_auxiliary_support,
    #indentations_auxiliary_support,
    #prev_treatment_auxiliary_support,
    #joins_unstable_auxiliary_support,
    #joins_split_auxiliary_support,
    #joins_not_flat_auxiliary_support
  )%>%
  count(
    condition = auxiliary_support_condition
  )
hchart(heatmap_data, "heatmap", hcaes(x = condition, y = planar_auxiliary_support, value = n), name = "Aux Condition")




#treemap
tree_data<-clean_data%>%
  group_by(country)%>%
  summarise(n = n(),
            unique = length(unique(country))) %>% 
  arrange(-n, -unique)
  

hchart(tree_data, "treemap", hcaes(x = country, value = n, color = unique))

bar_data <- clean_data %>%
  select(
    Country,
    Auxiliary.support.Condition
  ) %>%
  #replace_na(
  #  list(
  #    poor = 0,
  #    fair = 0,
  #    good = 0,
  #    excellent = 0
  #    )
  #  ) %>% 
  group_by(Country) %>%
  count(Auxiliary.support.Condition)
bar_data_2 <-bar_data %>% gather(status, n, -Country)

#ggplot(bar_data_2, aes(country,value, col=variable)) +
#  geom_bar(stat = 'identity',position = "dodge")

#ggplot(aes(x = status, y = count, fill = country)) + geom_col(position = "dodge")
