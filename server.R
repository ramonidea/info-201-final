library(shiny)
library(shinyjs)
library(plotly)
source("api.R")
library(stringr)
library(dplyr)
options(shiny.sanitize.errors = TRUE)


# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  #===========Button to switch tab===========
  observeEvent(input$music_pop_btn,{
    updateTabsetPanel(session,"tabs", selected = "music")
    updateTabsetPanel(session, "music_sub", selected = "mus_pop")
  })
  observeEvent(input$music_pri_btn,{
    updateTabsetPanel(session,"tabs", selected = "music")
    updateTabsetPanel(session, "music_sub", selected = "mus_pri")
  })
  observeEvent(input$sport_pri_btn,{
    updateTabsetPanel(session,"tabs", selected = "sport")
    updateTabsetPanel(session, "sport_sub", selected = "sport_pri")
  })
  observeEvent(input$sport_pop_btn,{
    updateTabsetPanel(session,"tabs", selected = "sport")
    updateTabsetPanel(session, "sport_sub", selected = "sport_pop")
  })
  observeEvent(input$dashboard_btn, {
    updateTabsetPanel(session,"tabs", selected = "dashboard")
  })
  observeEvent(input$music_btn, {
    updateTabsetPanel(session,"tabs", selected = "music")
  })
  observeEvent(input$sport_btn, {
    updateTabsetPanel(session,"tabs", selected = "sport")
  })
  #=============END======================

  output$sports_pop_map <- renderPlotly({
    return(sports.pop.map)
  })

  output$sports_pop_pie <- renderPlotly({
    return(sports.pop.pie)
  })

  output$sports_pop_bar <- renderPlotly({
    return(sports.pop.graph)
  })


  output$stateCountMap <- renderPlotly({
    state.count.map
    })

  output$topstate <- renderTable({
    top.cities <-
      cities.music.count <-
      result.country.music %>%
      group_by(code,city,state) %>%
      filter(!state %in% c("Alaska","Hawaii")) %>%
      dplyr::summarise(Event_Number = n()) %>%
      na.omit() %>%
      arrange(-Event_Number)
    top.cities <- top.cities[c(1:5),]
    return(top.cities)
  })

  output$topcity <- renderTable({
    top.states <-
      result.country.music %>%
      group_by(code,state) %>%
      dplyr::summarise(Event_Number = n()) %>%
      arrange(-Event_Number)

    top.states <- top.states[c(1:5),]
    return (top.states)
  })

  output$genre.state <- renderPlot({
    genre.choice <- input$genre.pop
    us <- map_data("state")
    us$state = str_to_title(us$region)
    genre.state <-
      result.country.music %>%
      filter(genre == genre.choice) %>%
      group_by(state) %>%
      dplyr::summarise(Event_Number = n()) %>%
      arrange(Event_Number) %>%
      left_join(us)

    gg <- ggplot()+
      geom_map(data = us, map = us, aes(x = long, y = lat, map_id = region),
               color = "dark gray",fill = "black",size = 0.05)+
      geom_map(data = genre.state, map = us, aes(fill = Event_Number,map_id = region))
    return(gg)
})

  output$music_min_price <- renderTable({
    return(top.min)
  })

  output$music_max_price <- renderTable({
    return(top.max)
  })
  output$seattle <- renderPlotly({
    return(seattle.graph)
  })
  output$la<- renderPlotly({
    return(la.graph)
  })
  output$newyork <- renderPlotly({
    return(ny.graph)
  })





  output$mapEx <- renderPlotly({
    #Map example
    cities <- read.csv("./data/cities.csv")
    # X       long      lat                 city
    # 1 1  -87.90647 43.03890  Milwaukee,Wisconsin
    # 2 2  -95.99277 36.15398       Tulsa,Oklahoma
    # 3 3 -115.17456 36.10237    New York,New York

    #https://plot.ly/r/reference/#scattermapbox
    p <- cities %>%
      plot_mapbox(lat = ~lat, lon = ~long,split=~city,mode = 'scattermapbox', showlegend=FALSE, size=2,hoverinfo="name") %>%
      layout(title = 'Event City List',
             hovermode = 'closest',
             font = list(color='white'),
             plot_bgcolor = '#191A1A', paper_bgcolor = '#191A1A',
             mapbox = list(style = 'light'),
             legend = list(orientation = 'h',
                           font = list(size = 8)),
             margin = list(l = 25, r = 25,
                           b = 25, t = 25,
                           pad = 2))
    p
  })


  output$bargraph <- renderPlotly({
    by.state.df <- final.result.data %>% 
      na.omit()%>% 
      group_by(state) %>% 
      dplyr::summarise(min_price = min(min),
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
  })

  output$cheapesttickets <- renderTable({
    cheapest.tickets <- final.result.data %>%
      group_by(city, state, name, genre, min) %>% 
      summarize(Min_Ticket_Price = min(min)) %>%
      arrange(Min_Ticket_Price) %>% 
      select(city, state, name, genre, min)
    
    cheapest.tickets <- cheapest.tickets[c(1:5), ]
    return(cheapest.tickets)
  })

  output$expensivetickets <- renderTable({
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
  })

  output$basketballmap <- renderPlotly({
    sport <- input$sport
    
    us <- map_data("state")
    us$state <- stringr::str_to_title(us$region)
    sport.map.data <- get.data %>% 
      filter(genre == sport) %>%
      group_by(state) %>% 
      dplyr::summarise(max = max(max)) %>% 
      mutate(hover = paste0(state,', Sport:',sport,'<br>',"Max Price:", max)) %>% 
      na.omit() %>%
      mutate(max =cut(max,30)) %>% 
      left_join(us)
    
    gg <-sport.map.data %>% 
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
    
    return (gg)
  })
  
  

}
