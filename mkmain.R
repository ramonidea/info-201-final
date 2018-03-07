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
library(plyr)
library(plotly)


#Retrieve the api key (api.key)
source("api.R")

#Source the helper method to get the city long, lat
source("helper.R")
  
#PART 2: 

#Base URL for the Api 
base.url <- "https://app.ticketmaster.com/discovery/v2/"

sea.music.url <- paste0(base.url, "events.json?apikey=",api.key,'&size=200&city=Seattle%20&countryCode=US&classificationName=Music')
sea.response <- GET(sea.music.url)
sea.body.data <- fromJSON(content(sea.response,"text"),simplifyVector=TRUE,simplifyDataFrame=TRUE)
sea.result.data <- flatten(sea.body.data$`_embedded`$events)


la.music.url <- paste0(base.url, "events.json?apikey=",api.key, '&size=200&city=Los%20Angeles&countryCode=US&classificationName=Music')
la.response <- GET(la.music.url)
la.body.data <- fromJSON(content(la.response,"text"),simplifyVector=TRUE,simplifyDataFrame=TRUE)
la.result.data <- flatten(la.body.data$`_embedded`$events)

ny.music.url <- paste0(base.url, "events.json?apikey=",api.key,"&size=200&city=New%20York&countryCode=US&classificationName=Music")
ny.response <- GET(ny.music.url)
ny.body.data <- fromJSON(content(ny.response,"text"),simplifyVector=TRUE,simplifyDataFrame=TRUE)
ny.result.data <- flatten(ny.body.data$`_embedded`$events)

# Creates a data frame which includes event names, genre, mins and max 
#of music events in Seattle 
#Add Mean of the min and max 
sea.mins <- c()
sea.max <- c()
sea.genre <- c()
sea.city <- c()
for(j in c(1:200)) {
sea.mins <- c(sea.mins, sea.result.data$priceRanges[[j]]$min)
sea.max <- c(sea.max, sea.result.data$priceRanges[[j]]$max)
sea.genre <- c(sea.genre, sea.result.data$classifications[[j]]$genre$name)
sea.city <- c(sea.city, sea.body.data$`_embedded`$events$`_embedded`$venues[[j]]$city$name)
}
sea.result.data <- sea.result.data %>% 
  select(name) %>% 
  mutate(Genre = sea.genre, Minimum = sea.mins[1:200], Maximum = sea.max[1:200], City = sea.city)

sea.result.data <- sea.result.data[!duplicated(sea.result.data$name),] %>% 
  mutate(hover = paste0("Event: ", name, "<br>", "Min: ", Minimum, "<br>", "Max: ", Maximum))

# Creates a data frame which includes event names, genre, mins and max 
#of music events in LA
la.mins <- c()
la.max <- c()
la.genre <- c()
la.city <- c()
for(j in c(1:200)) {
la.mins <- c(la.mins, la.result.data$priceRanges[[j]]$min)
la.max <- c(la.max, la.result.data$priceRanges[[j]]$max)
la.genre <- c(la.genre, la.result.data$classifications[[j]]$genre$name)
la.city <- c(la.city, la.body.data$`_embedded`$events$`_embedded`$venues[[j]]$city$name)
}

la.result.data <- la.result.data %>% 
  select(name) %>%
  mutate(Genre = la.genre, Minimum = la.mins[1:200], Maximum = la.max[1:200], City = la.city)
  la.result.data <- la.result.data[!duplicated(la.result.data$name), ] %>% 
    mutate(hover = paste0("Event: ", name, "<br>", "Min: ", Minimum, "<br>", "Max: ", Maximum))


#Gets music events of New York 
ny.mins <- c()
ny.max <- c()
ny.genre <- c()
ny.city <- c()
for(j in c(1:200)) {
  ny.mins <- c(ny.mins, ny.result.data$priceRanges[[j]]$min)
  ny.max <- c(ny.max, ny.result.data$priceRanges[[j]]$max)
  ny.genre <- c(ny.genre, ny.result.data$classifications[[j]]$genre$name)
  ny.city <- c(ny.city, ny.body.data$`_embedded`$events$`_embedded`$venues[[j]]$city$name)
}
ny.result.data <- ny.result.data %>% 
  select(name) %>% 
  mutate(Genre = ny.genre, Minimum = ny.mins[1:200], Maximum = ny.max[1:200], City = ny.city)

ny.result.data <- ny.result.data[!duplicated(ny.result.data$name),] %>% 
  mutate(hover = paste0("Event: ", name, "<br>", "Min: ", Minimum, "<br>", "Max: ", Maximum))


#top 5 minimum events 
top.min <- sea.la.ny %>% 
  arrange(Minimum) %>%
  select(name, Minimum, City) %>%
  head()
most.cheap <- top.min[1,]

#top 5 maxmimum events
top.max <- sea.la.ny %>% 
  arrange(-Maximum) %>%
  select(name, Maximum, City) %>%
  head()
most.expensive <- top.max[1,]

# Scatterplot which shows music events in LA. shows the names, min, max, and genre 
la.graph <- plot_ly(data = la.result.data, x = ~Maximum, y=~Minimum,
                    type = 'scatter', text = ~hover, hoverinfo = 'text', split = ~Genre) %>%
  layout(title = "Price of Music Events in Los Angeles")

# Scatterplot which shows music events in Seattle. shows the names, min, max, and genre 
seattle.graph <- plot_ly(data = sea.result.data, x = ~Maximum, y=~Minimum,
                         type = 'scatter', text = ~hover, hoverinfo = 'text',split = ~Genre) %>%
  layout(title = "Price of Music Events in Seattle")

# Scatterplot which shows music events in NY. shows the names, min, max, and genre 
ny.graph <- plot_ly(data = ny.result.data, x = ~Maximum, y=~Minimum,
                    type = 'scatter', text = ~hover, hoverinfo = 'text',split = ~Genre) %>%
  layout(title = "Price of Music Events in New York")
  
  



  












