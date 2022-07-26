library(shiny)
library(shinydashboard)
library(ggplot2)
library(readxl)
library(dplyr)
library(tidyverse)


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
