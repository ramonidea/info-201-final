library(ggmap)
library(maps)
library(mapdata)
library(jsonlite)
library(httr)
library(stringi)
library(stringr)
library(dplyr)

source("api.R")


#Get the geo location from the Google Map API
#Input a vector of the city's name (preferablely using "city, state" format)
#Return a data frame with columns(long, lat , name)
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
    long <- c(long, loc$lng[1])
    lat <- c(lat, loc$lat[1])
    name <- c(name, i)
    print(paste("Geocode checking",i))
  }
  return(data.frame(long = long, lat = lat, city = name))
}

geocode_single_city <- function(i){
  base.url <- "https://maps.googleapis.com/maps/api/geocode/json?address="
  address.url <- paste0(base.url, i,"&key=",google.key.1)
  address.url<-str_replace_all(address.url," ","%20")
  response <- GET(address.url)
  body.data <- fromJSON(content(response,"text"))
  loc <- body.data$results$geometry$location
  return(c(loc$lng[1],loc$lat[1],i) )
}



#Get the long and lat of the city
GetCityGeo <- function(names){
  cities.code <- read.csv("./data/cities.csv")
  cities.code <- select(cities.code, long, lat, city)
  long <- c()
  lat <- c()
  name <- c()
  f <- FALSE
  for (i in names){
    #Check the local saved file to see whether it has been checked before or not.
    if(i %in% cities.code$city){
      temp <- cities.code[cities.code$city == i,]
      long <- c(long, temp$long[1])
      lat <- c(lat, temp$lat[1])
      name <- c(name, i)
    }else{
      f <- TRUE
      temp <- geocode_single_city(i)
      long <- c(long, temp[1])
      lat <- c(lat, temp[2])
      name <- c(name, i)
      cities.code[nrow(cities.code) + 1,] = c(temp[1],temp[2],i)
    }
  }
  if(f){
    print("Updated the new Cities Code to local csv.")
    write.csv(cities.code, "./data/cities.csv")
  }
  return(data.frame(long = long, lat = lat, city = name))
}