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

#The Main function to do data wrangling

source("api.R")
#Retrieve the api key (api.key)

source("helper.R")
#Source the helper method to get the city long, lat

#The base URL for the APi
base.url <- "https://app.ticketmaster.com/discovery/v2/"

#get the music event
#The latest 1000 records (200 per GET, using For loop to do 5 times)

#Init the final data frame get from the loop.
final.result.data <- NULL

getMusicEvents <- function(){
  for(i in c(0:4)){
    page <- i #Set the page number 
    #----------------Receive the data from the API (In this example, # of events will receive is 200(max), in US, and Music related)
    music.url <- paste0(base.url, "events.json?apikey=",api.key,'&size=200&countryCode=US&classificationName=Music&page=',page)
    response <- GET(music.url)
    body.data <- fromJSON(content(response,"text"),simplifyVector=TRUE,simplifyDataFrame=TRUE)
    result.data <- body.data$`_embedded`$events
    #-----------Start cleaning the data and only left, name, genere, location..etc.
    #Due to the special of the data frame received from the API.
    #The genre, Location(under Venue) are lists of data frame
    #I have to use another for loop to get the data out.
    state.name <- c()
    city.name <- c()
    genre.name <- c()
    for (j in c(1:200)){
      state.name <-c(state.name, result.data$`_embedded`$venues[[j]]$state$name)
      city.name <- c(city.name, result.data$`_embedded`$venues[[j]]$city$name)
      genre.name <- c(genre.name, result.data$classifications[[j]]$genre$name)
    }
    #Here we have three list of the state, city, genre name.
    #--------And we update the result data to have only essential columns
    result.data <- 
      result.data %>% 
      select(name, id) %>% 
      mutate(city = city.name,genre = genre.name, state = state.name)
    #-----------------Append the data frame with the fijnal.result.data
    #If the fitst, just replace it, afterwards, using rbind to append the data on the dataframe
    if(is.null(final.result.data)){
      final.result.data <- result.data
    } else{
      final.result.data <- rbind(final.result.data,result.data)
    }
  }
  return(final.result.data)
}
#---------------------Only call once and take a while
final.result.data <- getMusicEvents()

#final.result.data wrangliing
#In this example, it group by the city, and genre, to figure out the max genre in each city
result.data <- 
  final.result.data %>% 
  group_by(city, genre, state) %>% 
  summarise(n = n()) %>% 
  group_by(city,state) %>% 
  filter(n == max(n))
# city                       genre            state          n
# 1 Minneapolis,Minnesota    Dance/Electronic Minnesota      1
# 2 Agoura Hills,California  R&B              California     1
# 3 Albany,New York          Rock             New York       2
# 4 Albuquerque,New Mexico   Country          New Mexico     2
# 5 Allen,Texas              R&B              Texas          1
# 6 Alpharetta,Georgia       Rock             Georgia        3

#Make an unique city list from the data frame
cities <- c(as.character(unique(paste0(final.result.data$city,",",final.result.data$state))))
#Get the Cities loc by using helper method
cities.code <-  GetCityGeo(cities)
# long      lat                 city
# 1  -87.90647 43.03890  Milwaukee,Wisconsin
# 2  -95.99277 36.15398       Tulsa,Oklahoma
# 3 -115.17456 36.10237    New York,New York
# 4  -75.11962 39.92595    Camden,New Jersey
# 5 -118.35313 33.96168 Inglewood,California
# 6  -73.59291 40.70038   Uniondale,New York

#Make the cify full name in "city,state" format
result.data$city <- paste0(result.data$city,",",result.data$state)

#left join two data frame
join.result.data <- left_join(result.data, cities.code)
# city                     genre            state          n   long   lat
# 1 " Minneapolis,Minnesota" Dance/Electronic Minnesota      1 - 93.3  45.0
# 2 Agoura Hills,California  R&B              California     1 -119    34.2
# 3 Albany,New York          Rock             New York       2 - 73.8  42.7
# 4 Albuquerque,New Mexico   Country          New Mexico     2 -107    35.1
# 5 Allen,Texas              R&B              Texas          1 - 96.7  33.1
# 6 Alpharetta,Georgia       Rock             Georgia        3 - 84.3  34.1

#Remove Hawaii and alaska due to they are not in the mainland
join.result.data <- filter(join.result.data, state != "Hawaii" && state != "Alaska")
join.result.data$long <-  as.double(as.character(join.result.data$long))
join.result.data$lat <- as.double(as.character(join.result.data$lat))


us <- map_data("state")
ggplot()+
  #plot the US map (only the shape)
  geom_map(data = us, map = us,  aes(x = long, y = lat,map_id = region),fill = "gray")+
  #Add point to represent the genre in each city and add n = the number of that kinds of events.
  geom_point(data = join.result.data, aes(x = long, y = lat, color = genre, size = n))
  
  

#The Main function to do data wrangling

# Objectives
# 1. Visualize data in map
# 2. create pie chart to show the percentage of events in states
# 3. create presentation/explanation/description of data and results

# find all sport events

