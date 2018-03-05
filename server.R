library(shiny)
source("main.R")
library(shinyjs)
library(plotly)
source("api.R")



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


  
  output$intro <- renderText({
    return('Here is the INTRO Part')
  })
  
  output$stateCountMap <- renderPlotly({
    getCountryCountMap()
    })
  
  output$topstate <- renderTable({
    return(getTopCities())
  })
  
  output$topcity <- renderTable({
    return (getTopStates())
  })
  
  output$genre.state <- renderPlot({
    return(getGenreMap(input$genre.pop))
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