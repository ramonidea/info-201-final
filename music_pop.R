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



#devtools::install_github("ropensci/plotly")
#The Main function to do data wrangling

source("api.R")
#Retrieve the api key (api.key)
Sys.setenv('MAPBOX_TOKEN' = MAPBOX_TOKEN)
source("helper.R")
#Source the helper method to get the city long, lat

#The base URL for the APi
base.url <- "https://app.ticketmaster.com/discovery/v2/"

#get the music event
#The latest 1000 records (200 per GET, using For loop to do 5 times)




####Get whole country events (int the next 5 months) and plot the genre onto the map.
##Show the major city's events number and genre ranking.
##Show Seattle Area which genre of music,
##Which Vene place has more music related events


####Get whole country events (int the next 5 months) and plot the genre onto the map.

getMusicCountry <- function(){
  #Init the final data frame get from the loop.
  result.country.music <- NULL
  for(i in c(0:4)){
    page<- i
    music.country <- paste0(base.url,"events?apikey=",api.key,"&startDateTime=2018-03-02T12:00:00Z&endDateTime=2018-08-01T12:00:00Z&size=200&sort=date,asc&countryCode=US&classificationName=Music&page=",page)
    response <- GET(music.country)
    body.data <- fromJSON(content(response,"text"))
    result.data <- body.data$`_embedded`$events
    state.name <- c()
    code <- c()
    city.name <- c()
    genre.name <- c()
    for (j in c(1:200)){
      state.name <-c(state.name, result.data$`_embedded`$venues[[j]]$state$name)
      code <- c(code, result.data$`_embedded`$venues[[j]]$state$stateCode)
      city.name <- c(city.name, result.data$`_embedded`$venues[[j]]$city$name)
      if(is.null(result.data$classifications[[j]]$genre$name)){
        genre.name <- c(genre.name, result.data$classifications[[j]]$segment$name)
      }else{
        genre.name <- c(genre.name, result.data$classifications[[j]]$genre$name)
      }
    }
    #Here we have three list of the state, city, genre name.
    #--------And we update the result data to have only essential columns
    result.data <- 
      result.data %>% 
      select(name, id) %>% 
      mutate(city = city.name,genre = genre.name, state = state.name, code = code)
    #-----------------Append the data frame with the fijnal.result.data
    #If the fitst, just replace it, afterwards, using rbind to append the data on the dataframe
    if(is.null(result.country.music)){
      result.country.music <- result.data
    } else{
      result.country.music <- rbind(result.country.music,result.data)
    }
  }
  return (result.country.music)
}

result.country.music <- getMusicCountry()

getGenres <- function(){
    return(unique(result.country.music$genre))
}

#### Which state or city has the most events happening in the next 5 months
us <- map_data("state")
us$state <- stringr::str_to_title(us$region)

states.music.count <- 
  result.country.music %>% 
  group_by(code,state) %>% 
  summarise(n = n()) %>% 
  arrange(n) %>% 
  mutate(hover = paste(state, '<br>',"Number of Events:", n)) %>% 
  full_join(us, by="state") %>% 
  mutate(n = cut(n,breaks = seq(0, 220, by = 10)))

#Make an unique city list from the data frame
cities <- c(as.character(unique(paste0(result.country.music$city,",",result.country.music$state))))
#Get the Cities loc by using helper method
cities.code <-  GetCityGeo(cities)

cities.music.count <-
  result.country.music %>% 
  group_by(code,city,state) %>% 
  filter(!state %in% c("Alaska","Hawaii")) %>% 
  summarise(n = n()) %>% 
  ungroup(city) %>% 
  mutate(city = paste0(city,',',state)) %>% 
  mutate(hover = paste(city, '<br>',"Number of Events:", n)) %>% 
  left_join(cities.code) %>% 
  na.omit() %>% 
  mutate(long = as.double(as.character(long)), lat = as.double(as.character(lat)))



 state.count.map <- 
        states.music.count %>%
        group_by(group) %>% 
        plot_mapbox(x = ~long, y = ~lat, color = ~n, colors = c('#ffeda0','#f03b20'),
                    text = ~hover, hoverinfo = 'text', showlegend = FALSE) %>%
        add_polygons(line = list(width = 0.4)) %>% 
        add_polygons(fillcolor = 'transparent',
                     line = list(color = 'black', width = 0.5),
                      hoverinfo = 'none'
        ) %>%
        add_markers(text = ~hover, hoverinfo = "text", 
                    color = I("red"), size = ~n,data = cities.music.count) %>%
        layout(
          title = 'Number of Events in the States',
          font = list(color='white'),
          plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
          mapbox = list(style = 'dark',
                        center = list(lat = 39.8283, lon = -98.5795),
                        zoom = 3),
          xaxis = list(title = "", showgrid = FALSE, showticklabels = FALSE),
          yaxis = list(title = "", showgrid = FALSE, showticklabels = FALSE),
          margin = list(l = 0, r = 0, b = 0, t = 0, pad = 0)
        )






