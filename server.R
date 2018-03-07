library(shiny)
#source("main.R")
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
  
  output$lineplot <- renderPlotly({
    #return(plot_ly(mtcars,x=~mpg,y=~disp,type="box"))
 # ggplot(data = mtcars)+
 #     geom_smooth(aes(x = mpg, y =disp), color="red")
    plot_ly(mtcars, x = ~mpg, y = ~wt)
  })
    
  output$barchart <- renderPlot({
    ggplot(data = mtcars)+
      geom_bar(aes(x = mpg, y = disp, fill = am),stat = "identity", width  =0.5)
    
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
  
  output$piechart <- renderPlot({
    
    ggplot(data = mtcars)+
      geom_bar(aes(x = factor(1), y = disp, fill = am),stat = "identity", width  =0.5, position = "stack")+
      coord_polar("y", start = 0)
    
  })
  
  output$datatable <- renderDataTable({
    return(mtcars)
  })
#################################################################
  
  output$bargraph <- renderPlotly({
    return(GetDotPlot())
  })
  
  output$cheapesttickets <- renderTable({
    return(GetCheapestTickets())
  })
  
  output$expensivetickets <- renderTable({
    return(GetExpensiveTickets())
  })
  
  output$basketballmap <- renderPlotly({
    return(getSportMap(input$sport))
  })

  
} 