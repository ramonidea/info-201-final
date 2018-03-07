library(shiny)
source("sportspopmain.R")
source("music_pop.R")
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

  output$sports_pop_map <- renderPlotly({
    return(sports.pop.map)
  })
  
  output$sports_pop_pie <- renderPlotly({
    return(sports.pop.pie)
  })
  
  output$sports_pop_bar <- renderPlotly({
    return(sports.pop.graph)
  })
  
  
  
}

  output$stateCountMap <- renderPlotly({
    state.count.map
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
  
  
  

    
 
 
  
}