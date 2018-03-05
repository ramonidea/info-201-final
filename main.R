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

getGenreMap <- function(genre.choice){
  
  us <- map_data("state")
  us$state = stringr::str_to_title(us$region)
  
  genre.state <- 
    result.country.music %>% 
    filter(genre == genre.choice) %>% 
    group_by(state) %>% 
    summarise(Event_Number = n()) %>% 
    arrange(Event_Number) %>% 
    left_join(us)
  
  
  
  gg <- ggplot()+
    geom_map(data = us, map = us, aes(x = long, y = lat, map_id = region),
                                color = "dark gray",fill = "black",size = 0.05)+
    geom_map(data = genre.state, map = us, aes(fill = Event_Number,map_id = region))

  return(gg)
  
}


getCountryCountMap <- function(){
      print("Start Processing Data.....")
      
      
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
        mutate(long = as.double(as.character(long)), lat = as.double(as.character(lat))    )
      
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

return(state.count.map)
}


getTopCities <- function(){
  top.cities <-
    cities.music.count <-
    result.country.music %>% 
    group_by(code,city,state) %>% 
    filter(!state %in% c("Alaska","Hawaii")) %>% 
    summarise(Event_Number = n()) %>% 
    na.omit() %>% 
    arrange(-Event_Number) 
  top.cities <- top.cities[c(1:5),]
  return (top.cities)
}

getTopStates <- function(){
  top.states <-
    result.country.music %>% 
    group_by(code,state) %>%
    summarise(Event_Number = n()) %>%
    arrange(-Event_Number)
  
  top.states <- top.states[c(1:5),]
  return(top.states)
}





# 
# 
# 
# states.genre.map %>%
#   plot_mapbox(mode = 'scattermapbox',split=~genre) %>%
#   add_markers( x = ~long, y = ~lat, text=~genre,
#     size = ~n, hoverinfo ="text", alpha = 0.8) %>%
#   layout(title = 'Event City Map in 5 Months',
#          hovermode = 'closest',
#          font = list(color='white'),
#          plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
#          mapbox = list(style = 'dark'),
#          legend = list(orientation = 'h',
#                        font = list(size = 8)),
#          margin = list(l = 25, r = 25,
#                        b = 25, t = 25,
#                        pad = 2))
# 
#     
# 
# 
# 
# 
# 
# 
# #final.result.data wrangliing
# #In this example, it group by the city, and genre, to figure out the max genre in each city
# result.data.bystate <- 
#   final.result.data %>% 
#   group_by(city, genre, state) %>% 
#   summarise(n = n()) %>% 
#   group_by(city,state) %>% 
#   filter(n == max(n)) %>% 
#   ungroup(city) %>% 
#   mutate(city = paste0(city,",",state))
# # city                       genre            state          n
# # 1 Minneapolis,Minnesota    Dance/Electronic Minnesota      1
# # 2 Agoura Hills,California  R&B              California     1
# # 3 Albany,New York          Rock             New York       2
# # 4 Albuquerque,New Mexico   Country          New Mexico     2
# # 5 Allen,Texas              R&B              Texas          1
# # 6 Alpharetta,Georgia       Rock             Georgia        3
# 
# #Make an unique city list from the data frame
# cities <- c(as.character(unique(paste0(final.result.data$city,",",final.result.data$state))))
# #Get the Cities loc by using helper method
# cities.code <-  GetCityGeo(cities)
# # long      lat                 city
# # 1  -87.90647 43.03890  Milwaukee,Wisconsin
# # 2  -95.99277 36.15398       Tulsa,Oklahoma
# # 3 -115.17456 36.10237    New York,New York
# # 4  -75.11962 39.92595    Camden,New Jersey
# # 5 -118.35313 33.96168 Inglewood,California
# # 6  -73.59291 40.70038   Uniondale,New York
# 
# #Make the cify full name in "city,state" format
# result.data$city <- paste0(result.data$city,",",result.data$state)
# 
# #left join two data frame
# join.result.data <- left_join(result.data, cities.code)
# # city                     genre            state          n   long   lat
# # 1 " Minneapolis,Minnesota" Dance/Electronic Minnesota      1 - 93.3  45.0
# # 2 Agoura Hills,California  R&B              California     1 -119    34.2
# # 3 Albany,New York          Rock             New York       2 - 73.8  42.7
# # 4 Albuquerque,New Mexico   Country          New Mexico     2 -107    35.1
# # 5 Allen,Texas              R&B              Texas          1 - 96.7  33.1
# # 6 Alpharetta,Georgia       Rock             Georgia        3 - 84.3  34.1
# 
# #Remove Hawaii and alaska due to they are not in the mainland
# join.result.data <- filter(join.result.data, state != "Hawaii" && state != "Alaska")
# join.result.data$long <-  as.double(as.character(join.result.data$long))
# join.result.data$lat <- as.double(as.character(join.result.data$lat))
# 
# us <- map_data("state")
# us$state <- stringr::str_to_title(us$region)
# #--------------------------
# join.result.data.bystate <-left_join(result.data.bystate, us)
# join.result.data.bystate <- filter(join.result.data.bystate, state != "Hawaii" && state != "Alaska")
# join.result.data.bystate$long <-  as.double(as.character(join.result.data.bystate$long))
# join.result.data.bystate$lat <- as.double(as.character(join.result.data.bystate$lat))
# 
# 
# ggplot()+
#   #plot the US map (only the shape)
#   geom_map(data = us, map = us,  aes(x = long, y = lat,map_id = region),fill = "gray")+
#   geom_map(data = join.result.data.bystate, map = us, aes(x = long, y = lat, map_id = region, fill = genre), color = "black")+
#   #Add point to represent the genre in each city and add n = the number of that kinds of events.
#   geom_point(data = join.result.data, aes(x = long, y = lat, color = genre, size = n))
#   
#
# 
# 
