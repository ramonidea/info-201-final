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
library(plotly)


#The Main function to do data wrangling

source("api.R")
#Retrieve the api key (api.key)

source("helper.R")
#Source the helper method to get the city long, lat

#The Main function to do data wrangling

# Objectives
# 1. Visualize data in map
# 2. create pie chart to show the percentage of events in states
# 3. create presentation/explanation/description of data and results

# find all sport events

#The base URL for the APi
base.url <- "https://app.ticketmaster.com/discovery/v2/"
sports.events.url <- paste0(base.url, "events.json?apikey=",api.key,
                            '&size=200&countryCode=US&classificationName=Sports&page=1')
sports.events.response <- GET(sports.events.url)
sports.body.data <- fromJSON(content(sports.events.response,"text"))
sports.result.data <- flatten(sports.body.data$`_embedded`$events)
sports.result.data <- select(sports.result.data, name, url, dates.start.localDate, dates.start.localTime, dates.timezone, promoter.name, priceRanges)

# add state and city to event data
state.name <- c()
city.name <- c()
for (j in c(1:200)){
  state.name <-c(state.name, sports.body.data$`_embedded`$events$`_embedded`$venues[[j]]$state$name)
  city.name <- c(city.name, sports.body.data$`_embedded`$events$`_embedded`$venues[[j]]$city$name)
}
event.location = data.frame(state = state.name, city  = city.name)
sports.result.data <- mutate(sports.result.data, state = event.location$state, city = event.location$city)

# get US map data and merge to event data
combined.city.name <- paste0(city.name, ",", state.name)
map.data <- GetCityGeo(paste0(city.name, ",", state.name)) %>% mutate(state = event.location$state, city = sports.result.data$city)
sports.result.data <- left_join(sports.result.data, map.data, by = c("state", "city"))
Sys.setenv('MAPBOX_TOKEN' = MAPBOX_TOKEN)

# create map visualization. ScatterMapBox in plotly
map.state <- map_data("state")
sports.pop.map <- sports.result.data %>%
  plot_mapbox(lat = ~lat, lon = ~long,
              split = ~class, size=2,
              mode = 'scattermapbox', hoverinfo='city') %>%
  layout(title = 'Sports Events',
         font = list(color='white'),
         plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
         mapbox = list(style = 'dark'),
         legend = list(orientation = 'h',
                       font = list(size = 8)),
         margin = list(l = 25, r = 25,
                       b = 25, t = 25,
                       pad = 2))