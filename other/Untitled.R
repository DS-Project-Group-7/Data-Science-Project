library(ggplot2)
library("plyr")
library("dplyr")

a <- cleanData[c("collection", "media_type_1", "media_type_2", "media_type_3")]

ph <- a[a$collection == "Vargas Museum (Philippines)", ]
th <- a[a$collection == "National Gallery (Thailand)", ]
ma <- a[a$collection == "National Art Gallery (Malaysia)", ]
si <- a[a$collection == "Heritage Conservation Board (Singapore)", ]
# create a dataset
specie <- c(rep("Vargas Museum (Philippines)" , 5),
           rep("National Gallery (Thailand)" , 5),
           rep ("National Art Gallery (Malaysia)" , 5),
           rep ("Heritage Conservation Board (Singapore)" , 5)
           )
            #, rep("poacee" , 3) , rep("banana" , 3) , rep("triticum" , 3) )
media_type<- rep(c("oil" , "tempera" , "acrylic","media","tempera") , 4)
# value <- abs(rnorm(12 , 0 , 15))
data <- data.frame(specie,media_type)
#get freq
freq_ph_1<- count(ph$media_type_1)
freq_ph_1$specie <- ("Vargas Museum (Philippines)")


freq_th_1 <- count(th$media_type_1)
freq_th_1$specie <- ("National Gallery (Thailand)")

freq_ma_1<- count(ma$media_type_1)
freq_ma_1$specie <- ("National Art Gallery (Malaysia)")

freq_si_1 <- count(si$media_type_1)
freq_si_1$specie <- ("Heritage Conservation Board (Singapore)")

value1 <- rbind(freq_ph_1, freq_th_1, freq_ma_1, freq_si_1)

colnames(value1)[colnames(value1) == "x"] = "media_type"
data = left_join(data, value1, by = c("specie", "media_type"))
data[is.na(data)] <- 0

# Stacked

ggplot(data, aes(fill=media_type, x=freq, y=specie)) + 
  geom_bar(stat="identity")

#
#merge(x=policies,y=limits,by="State",all.x=TRUE)
# merge(mydf, mylookup, by.x = "OP_UNIQUE_CARRIER", by.y = "Code", all.x = TRUE, all.y = FALSE)

# left_join(mytibble, mylookup_tibble, by = c("OP_UNIQUE_CARRIER" = "Code"))

