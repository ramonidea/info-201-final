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

getMusicEvents <- function(){
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
#Retrieve dataframe 
final.result.data <- getMusicEvents() %>% 
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
  by.state.df <- final.result.data %>% filter(min != 'NA') %>% 
    group_by(state) %>% 
    summarise(min_price = min(min),
              max_price = max(max))
    
  test <- plot_ly(by.state.df, x = ~min_price, y = ~state, name = "Minimum Price", type = 'scatter',
               mode = "markers", marker = list(color = "pink")) %>%
    add_trace(x = ~max_price, y = ~state, name = "Maximum Price", type = 'scatter',
              mode = "markers", marker = list(color = "blue")) %>%
    layout(
      title = "Price Ranges for Tickets",
      xaxis = list(title = "Price in Dollars ($)"),
      margin = list(l = 100)
    )
  
  return(test)
}

# Map plot box 
GetMapBox <- function() {
  price.state.map <- join.result.data %>%
    plot_mapbox(lat = ~lat, lon = ~long,
                split = ~state, size=2,
                mode = 'scattermapbox', hoverinfo= 'text',
                text = ~paste('City: ' city)) %>%
    layout(title = 'Meteorites by Class',
           font = list(color='white'),
           plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
           mapbox = list(style = 'dark'),
           legend = list(orientation = 'h',
                         font = list(size = 8)),
           margin = list(l = 25, r = 25,
                         b = 25, t = 25,
                         pad = 2))
  return(price.state.map)
}

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


