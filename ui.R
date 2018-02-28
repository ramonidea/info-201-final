library(shiny)
#source("main.R")
library(shinyjs)

library(plotly)




ui <- fluidPage(
  
  htmlTemplate("./www/index.html",
    title = tags$h2("INFO 201 Final Project - Data Analysis with TicketMaster API"),
    dashboard = actionButton("dashboard_btn","Dashboard"),
    music = actionButton("music_btn","Music Event"),
    sport = actionButton("sport_btn","Sport Event"),
    mainpanel = fluidRow(
      column(12,
               tabsetPanel(id="tabs",
                           tabPanel("dashboard", 
                                    tags$h3("Dash Board Page"),
                                    plotOutput("lineplot")
                           ),
                           
                           tabPanel("music",
                                    tags$h3("Music Event Page"),
                                    plotOutput("barchart")
                           ),
                           tabPanel('sport', 
                                    tags$h3("Sport Event Page"),
                                    plotOutput("piechart"),
                                    dataTableOutput("datatable")
                           )
               )
                       
  
             )
    )
      
  )
  
)