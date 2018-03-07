library(shiny)
source("sportspopmain.R")
library(shinyjs)
library(plotly)
source("api.R")

Sys.setenv('MAPBOX_TOKEN' = MAPBOX_TOKEN)

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
shinyServer(server)