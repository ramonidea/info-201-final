library(dplyr)
library(tidyr)
library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(jsonlite)
library(httr)
library(stringi)
library(stringr)

#Retrieve the api key (api.key)
source("api.R")

#Source the helper method to get the city long, lat
source("helper.R")
  
#PART 2: 

#Base URL for the Api 
base.url <- "https://app.ticketmaster.com/discovery/v2/"

sea.music.url <- paste0(base.url, "events.json?apikey=",api.key,'&size=100&city=Seattle%20&countryCode=US&classificationName=Music')
sea.response <- GET(sea.music.url)
sea.body.data <- fromJSON(content(sea.response,"text"),simplifyVector=TRUE,simplifyDataFrame=TRUE)
sea.result.data <- flatten(sea.body.data$`_embedded`$events)


la.music.url <- paste0(base.url, "events.json?apikey=",api.key, '&size=100&city=Los%20Angeles&countryCode=US&classificationName=Music')
la.response <- GET(la.music.url)
la.body.data <- fromJSON(content(la.response,"text"),simplifyVector=TRUE,simplifyDataFrame=TRUE)
la.result.data <- flatten(la.body.data$`_embedded`$events)

# Creates a data frame which includes event names, genre, mins and max 
#of music events in Seattle


sea.mins <- c()
sea.max <- c()
sea.genre <- c()
sea.city <- c()
for(j in c(1:100)) {
sea.mins <- c(sea.mins, sea.result.data$priceRanges[[j]]$min)
sea.max <- c(sea.max, sea.result.data$priceRanges[[j]]$max)
sea.genre <- c(sea.genre, sea.result.data$classifications[[j]]$genre$name)
sea.city <- c(sea.city, sea.body.data$`_embedded`$events$`_embedded`$venues[[j]]$city$name)
}

sea.result.data <- sea.result.data %>% 
  select(name) %>% 
  mutate(Genre = sea.genre, Minimum = sea.mins[1:100], Maximum = sea.max[1:100], City = sea.city)
sea.result.data <- sea.result.data[!duplicated(sea.result.data$name),]
sea.result.data <- sea.result.data %>% mutate(Mean = (sea.result.data$Maximum + sea.result.data$Minimum)/2)

# Creates a data frame which includes event names, genre, mins and max 
#of music events in LA
la.mins <- c()
la.max <- c()
la.genre <- c()
la.city <- c()
for(j in c(1:100)) {
la.mins <- c(la.mins, la.result.data$priceRanges[[j]]$min)
la.max <- c(la.max, la.result.data$priceRanges[[j]]$max)
la.genre <- c(la.genre, la.result.data$classifications[[j]]$genre$name)
la.city <- c(la.city, la.body.data$`_embedded`$events$`_embedded`$venues[[j]]$city$name)
}

la.result.data <- la.result.data %>% 
  select(name) %>% 
  mutate(Genre = la.genre, Minimum = la.mins, Maximm = la.max, City = la.city)
la.result.data <- la.result.data[!duplicated(la.result.data$name), ]
la.result.data <- la.result.data %>% mutate(Mean = (la.result.data$Maximm + la.result.data$Minimum) / 2)




