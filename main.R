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

base.url <- "https://app.ticketmaster.com/discovery/v2/"
Sys.setenv('MAPBOX_TOKEN' = MAPBOX_TOKEN)

#get the music event
#The latest 1000 records (200 per GET, using For loop to do 5 times)
#Init the final data frame get from the loop.
final.result.data <- NULL

getSportEvents <- function(){
  for(i in c(0:4)){
    page <- i #Set the page number 
    #----------------Receive the data from the API (In this example, # of events will receive is 200(max), in US, and Music related)
    sports.events.url <- paste0(base.url, "events.json?apikey=",api.key,
                                '&size=200&countryCode=US&classificationName=Sports&page=1')
    response <- GET(sports.events.url)
    body.data <- fromJSON(content(response,"text"),simplifyVector=TRUE,simplifyDataFrame=TRUE)
    result.data <- body.data$`_embedded`$events
    #-----------Start cleaning the data and only left, name, genere, location..etc.
    #Due to the special of the data frame received from the API.
    #The genre, Location(under Venue) are lists of data frame
    #I have to use another for loop to get the data out.
    state.name <- c()
    city.name <- c()
    genre.name <- c()
    range.min <- c()
    range.max <- c()
    for (j in c(1:200)){
      state.name <-c(state.name, result.data$`_embedded`$venues[[j]]$state$name)
      city.name <- c(city.name, result.data$`_embedded`$venues[[j]]$city$name)
      genre.name <- c(genre.name, result.data$classifications[[j]]$genre$name)
      if (is.null(result.data$priceRanges[[j]]$min)) {
        range.min <- c(range.min, NA)
      } else {
        range.min <- c(range.min, result.data$priceRanges[[j]]$min)
      }
    
      if (is.null(result.data$priceRanges[[j]]$max)) {
        range.max <- c(range.max, NA)
      } else {
        range.max <- c(range.max, result.data$priceRanges[[j]]$max)
      }
     
    }
    #Here we have three list of the state, city, genre name.
    #--------And we update the result data to have only essential columns
    result.data <- 
      result.data %>% 
      select(name, id) %>% 
      mutate(city = city.name,genre = genre.name, state = state.name, min = range.min, max = range.max)
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

get.data <- getSportEvents() 

#Retrieve dataframe 
final.result.data <- get.data%>% 
  filter(state == 'California' | 
           state == 'Texas' |
           state == 'Florida' |
           state == 'New York' |
           state == 'Pennsylvania') 

#Get the Cities loc by using helper method
#Add city column for future data frame join 
cities.code <-  GetCityGeo(paste0(final.result.data$city,",",final.result.data$state)) %>% 
  mutate(city = final.result.data$city)

#Left join two data frame
#Get rid of duplicates 
join.result.data <- left_join(final.result.data, cities.code)
join.result.data <- join.result.data[!duplicated(join.result.data), ]

#Group by state and find minimum and maximum price for each state 
#Plot those prices in a dot plot
GetDotPlot <- function() {
  by.state.df <- final.result.data %>% 
    na.omit()%>% 
    group_by(state) %>% 
    summarise(min_price = min(min),
              max_price = max(max)) %>% 
    gather("type","Number",2:3)
  
  

  test <- 
  by.state.df %>% 
    plot_ly(x = ~Number, color = ~state, 
               mode = "markers", marker = list(color = "pink"), type = "box") %>% 
    layout(
      title = "Price Ranges for Tickets",
      xaxis = list(title = "Price in Dollars ($)"),
      margin = list(l = 100)
    )
  
  return(test)
}

getDropDownValues <- function() {
  return(unique(get.data$genre))
}


getSportMap <-function(sport){
  us <- map_data("state")
  us$state <- stringr::str_to_title(us$region)
  sport.map.data <- get.data %>% 
    filter(genre == sport) %>%
    group_by(state) %>% 
    summarise(max = max(max)) %>% 
    mutate(hover = paste0(state,', Sport:',sport,'<br>',"Max Price:", max)) %>% 
    na.omit() %>%
    mutate(max =cut(max,30)) %>% 
    left_join(us)
  
  sport.map.data %>% 
    group_by(group) %>% 
    plot_mapbox(x = ~long, y = ~lat, color = ~max, colors = c('#ffeda0',"#f03b20"),
                text = ~hover, hoverinfo = 'text', showlegend = FALSE) %>% 
    add_polygons(line = list(width = 0.4)) %>% 
    add_polygons(fillcolor = 'transparent', line = list(color = 'black',width = 0.5)) %>% 
    layout(title = ~paste0(sport,' by Class'),
                      font = list(color='white'),
                      plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
                      mapbox = list(style = 'dark',
                                    center = list(lat  =39.8283, lon = -98.5795),
                                    zoom = 3),
                      legend = list(orientation = 'h',
                                    font = list(size = 8)),
                      margin = list(l = 25, r = 25,
                                    b = 25, t = 25,
                                    pad = 2))
  
    
    
    
}

# 
# # Map plot box 
# GetMapBox <- function() {
#   box.data <-
#     final.result.data %>% 
#     group_by(state, city) %>% 
#     na.omit() %>% 
#     summarise(min = min(min),
#               max = max(max)) %>% 
#     left_join(unique(cities.code))
#   
#   
#  # price.state.map <- 
#   box.data %>%
#     plot_mapbox(lat = ~lat, lon = ~long,
#                 split = ~state, size=2,
#                 mode = 'scattermapbox', hoverinfo= 'text',
#                 text = ~paste0('City: ' ,city))
#     layout(title = 'Meteorites by Class',
#            font = list(color='white'),
#            plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
#            mapbox = list(style = 'dark',
#                          center = list(lat  =39.8283, lon = -98.5795),
#                          zoom = 3),
#            legend = list(orientation = 'h',
#                          font = list(size = 8)),
#            margin = list(l = 25, r = 25,
#                          b = 25, t = 25,
#                          pad = 2))
#   
#   return(price.state.map)
# }

# table: top 5 Cheapest Tickets
GetCheapestTickets <- function() {
  cheapest.tickets <- final.result.data %>%
    group_by(city, state, name, genre, min) %>% 
    summarize(Min_Ticket_Price = min(min)) %>%
    arrange(Min_Ticket_Price) %>% 
    select(city, state, name, genre, min)
  
  cheapest.tickets <- cheapest.tickets[c(1:5), ]
  return(cheapest.tickets)
}

# table: top 5 Expensive Tickets 
GetExpensiveTickets <- function() {
  expensive.tickets <- final.result.data %>%
    group_by(city, state, name, genre, max) %>% 
    summarize(Max_Ticket_Price = max(max)) %>%
    arrange(-Max_Ticket_Price) %>% 
    filter(state == 'California' | 
             state == 'Texas' |
             state == 'Florida' |
             state == 'New York' |
             state == 'Pennsylvania') %>% 
    select(city, state, name, genre, max)
  
  expensive.tickets <- expensive.tickets[c(1:5), ]
  return(expensive.tickets)
}  


