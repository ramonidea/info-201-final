library(ggmap)
library(maps)
library(mapdata)
library(jsonlite)
library(httr)
library(stringi)
library(stringr)
library(dplyr)

source("api.R")




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
  cities.code <- read.csv("./data/cities.csv", stringsAsFactors = FALSE)
  cities.code <- select(cities.code, long, lat, city)
  cities.code <- na.omit(cities.code)
  cities.code$city <- as.character(cities.code$city)
  cities.code$long <- as.double(cities.code$long)
  cities.code$lat <- as.double(cities.code$lat)
  long <- c()
  lat <- c()
  name <- c()
  f <- FALSE
  for (i in names){
    print(paste0("Checking", i))
    #Check the local saved file to see whether it has been checked before or not.
    if(i %in% cities.code$city){
      temp <- cities.code[cities.code$city == i,]
      long <- c(long, temp$long[1])
      lat <- c(lat, temp$lat[1])
      name <- c(name, i)
    }else{
      f <- TRUE
      temp <- geocode_single_city(i)
      long <- as.double(c(long, temp[1]))
      lat <- as.double(c(lat, temp[2]))
      name <-as.character(c(name, i))
      cities.code <- rbind(cities.code,c(temp[1],temp[2],i))
    }
  }
  if(f){
    print("Updated the new Cities Code to local csv.")
    write.csv(cities.code, "./data/cities.csv")
  }
  return(data.frame(long = long, lat = lat, city = name))
}
