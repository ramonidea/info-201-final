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
sports.result.data <- select(sports.result.data, name, url, 
                             dates.start.localDate, dates.start.localTime, 
                             dates.timezone, promoter.name, priceRanges)

# add state and city to event data
state.name <- c()
city.name <- c()
for (j in c(1:200)){
  state.name <-c(state.name, 
                 sports.body.data$`_embedded`$events$`_embedded`$venues[[j]]$state$name)
  city.name <- c(city.name, 
                 sports.body.data$`_embedded`$events$`_embedded`$venues[[j]]$city$name)
}
# event.location = data.frame(state = state.name, city  = city.name)
sports.result.data <- 
  sports.result.data %>% 
  mutate(state = state.name,city = city.name)
  

sports.pop.data <- sports.result.data %>% group_by(state, city) %>% 
  summarise(Event_Number = n()) %>% 
  mutate(hover = paste0(state," ,",city,"<br>",Event_Number))


# get US map data and merge to event data
map.data <- GetCityGeo(paste0(sports.result.data$city, ",", 
                              sports.result.data$state)) %>% 
  mutate(city = sports.result.data$city)
sports.data.map <- left_join(sports.pop.data, map.data)
sports.data.map <- sports.data.map[!duplicated(sports.data.map), ]


Sys.setenv('MAPBOX_TOKEN' = MAPBOX_TOKEN)

# create map visualization. ScatterMapBox in plotly
sports.pop.map <- sports.data.map %>%
  plot_mapbox(x = ~long, y = ~lat,
              split = ~city, size=2,
              showlegend = FALSE,
              mode = 'scattermapbox',
              text = ~hover,
              hoverinfo = 'text') %>%
  layout(title = 'Sports Events',
         hovermode = 'closest',
         font = list(color='white'),
         plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
         mapbox = list(style = 'dark',
                       center = list(lat = 39.8283, lon = -98.5795),
                       zoom = 3),
         legend = list(orientation = 'h',
                       font = list(size = 8)),
         margin = list(l = 25, r = 25,
                       b = 25, t = 25,
                       pad = 2))

# mutate data to count 
# number per state
sports.events.count <- sports.result.data %>% group_by(state) %>%
  summarise(event.count = n())
sports.result.data <- left_join(sports.result.data, sports.events.count, by = "state")

# line graph for all states
sports.pop.graph <- plot_ly(
  x = sports.events.count$state,
  y = sports.events.count$event.count,
  name = "Sports events per State",
  type = "bar"
) %>% layout(xaxis = list(title = "", tickangle = -45),
             yaxis = list(title = ""),
             margin = list(b = 100),
             barmode = 'group')

# Pie chart for top 5
# filter to top 5 states
sports.events.count <- arrange(sports.events.count, -event.count)
sports.top5.state <- sports.events.count[1:5,]
sports.top5.data <- filter(sports.result.data, state == sports.top5.state$state)
# make pie chart
sports.pop.pie <- plot_ly(sports.top5.state, labels = ~state,
                          values = ~event.count, hoverinfo = ~event.count,
                          type = 'pie') %>%
  layout(
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

# statistical report
# mean, median, max with state name, min with state name
# state top 5 states
sports.pop.mean <- round(mean(sports.result.data$event.count), 0)
sports.pop.median <- median(sports.result.data$event.count)
sports.pop.max <- max(sports.result.data$event.count)
sports.pop.max.state <- filter(sports.result.data, event.count == sports.pop.max) %>% select(state)
sports.pop.max.state <- sports.pop.max.state[!duplicated(sports.pop.max.state), ]
sports.pop.min <- min(sports.result.data$event.count)
sports.pop.min.state <- filter(sports.result.data, event.count == sports.pop.min) %>% select(state)
sports.pop.min.state <- sports.pop.min.state[!duplicated(sports.pop.min.state), ]
