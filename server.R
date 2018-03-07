library(shiny)
library(shinyjs)
library(plotly)
source("api.R")
library(stringr)

detach("package:plyr", unload=TRUE) 
library(dplyr) 



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
      summarise(Event_Number = n()) %>% 
      na.omit() %>% 
      arrange(-Event_Number) 
    top.cities <- top.cities[c(1:5),]
    return(top.cities)
  })

  output$topcity <- renderTable({
    top.states <-
      result.country.music %>% 
      group_by(code,state) %>%
      summarise(Event_Number = n()) %>%
      arrange(-Event_Number)
    
    top.states <- top.states[c(1:5),]
    return (top.states)
  })

  output$genre.state <- renderPlot({
    genre.choice <- input$genre.pop
    us <- map_data("state")
    us$state = str_to_title(us$region)
    print(head(result.country.music))
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
})

  output$intro <- renderText({
    return('Here is the INTRO Part')
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








}
