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

source("api.R")
#Retrieve the api key (api.key)


#The Main function to do data wrangling
base.url <- "https://app.ticketmaster.com/discovery/v2/"

#get the music event
#The latest 600 records
final.result.data <- NULL
for(i in c(0:4)){
  page <- i
  music.url <- paste0(base.url, "events.json?apikey=",api.key,'&size=200&countryCode=US&classificationName=Music&page=',page)
  response <- GET(music.url)
  body.data <- fromJSON(content(response,"text"),simplifyVector=TRUE,simplifyDataFrame=TRUE)
  result.data <- body.data$`_embedded`$events
  
  state.name <- c()
  city.name <- c()
  genre.name <- c()
  for (j in c(1:200)){
    city.name <- c(city.name, result.data$`_embedded`$venues[[j]]$city$name)
    genre.name <- c(genre.name, result.data$classifications[[j]]$genre$name)
    state.name <-c(state.name, result.data$`_embedded`$venues[[j]]$state$name)
  }
  result.data <- 
    result.data %>% 
    select(name, id) %>% 
    mutate(city = city.name,genre = genre.name, state = state.name)
    
  if(is.null(final.result.data)){
    final.result.data <- result.data
  } else{
    final.result.data <- rbind(final.result.data,result.data)
  }
}

#final.result.data wrangliing
result.data <- 
  final.result.data %>% 
  group_by(state, genre) %>% 
  summarise(n = n()) %>% 
  group_by(state) %>% 
  filter(n == max(n))

cities <- c(as.character(unique(paste0(final.result.data$city,",",final.result.data$state))))

us <- map_data("state")
us$state <- stri_trans_totitle(us$region)


geocode_city <- function(vec){
  long <- c()
  lat <- c()
  name <- c()
  for (i in vec){
    base.url <- "https://maps.googleapis.com/maps/api/geocode/json?address="
    address.url <- paste0(base.url, i,"&key=",google.key.1)
    address.url<-str_replace_all(address.url," ","%20")
    response <- GET(address.url)
    body.data <- fromJSON(content(response,"text"))
    loc <- body.data$results$geometry$location
    long <- c(long, loc$lng)
    lat <- c(lat, loc$lat)
    name <- c(name, i)
    print(paste("Geocode checking",i))
  }
  return(data.frame(long = long, lat = lat, city = name))
}

cities.code <-  geocode_city(cities)
cities.code$city <- cities



result.data <- final.result.data
result.data$long <- cities$lon
result.data$lat <- cities$lat


ggplot()+
  geom_map(data = us, map = us,  aes(x = long, y = lat,map_id = region),fill = "gray")+
  geom_point(data = result.data)
  
  
  


