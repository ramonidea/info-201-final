library(shiny)
#source("main.R")
library(shinyjs)
library(plotly)
# Define server logic required to draw a histogram ----

server <- function(input, output, session) {
  
  
  observeEvent(input$dashboard_btn, {
    updateTabsetPanel(session,"tabs", selected = "dashboard")
    
  })
  
  observeEvent(input$music_btn, {
    updateTabsetPanel(session,"tabs", selected = "music")
  })
  
  observeEvent(input$sport_btn, {
    updateTabsetPanel(session,"tabs", selected = "sport")
  })
  
  output$intro <- renderText({
    return('Here is the INTRO Part')
  })
  
  output$lineplot <- renderPlot({
    
    
  ggplot(data = mtcars)+
      geom_smooth(aes(x = mpg, y =disp), color="red")
   
  })
 
  
  output$barchart <- renderPlot({
    
    ggplot(data = mtcars)+
      geom_bar(aes(x = mpg, y = disp, fill = am),stat = "identity", width  =0.5)
    
  })
  
  output$piechart <- renderPlot({
    
    ggplot(data = mtcars)+
      geom_bar(aes(x = factor(1), y = disp, fill = am),stat = "identity", width  =0.5, position = "stack")+
      coord_polar("y", start = 0)
    
  })
  
  output$datatable <- renderDataTable({
    return(mtcars)
  })
  
  
  
}