library(shiny)
#source("main.R")
library(shinyjs)
library(plotly)

ui <- htmlTemplate(
  "./www/index.html",
  title = tags$h2("INFO 201 Final Project - Data Analysis with TicketMaster API"),
  #Three Button on the side to control the tabsetPanel
  dashboard = actionButton("dashboard_btn", "Dashboard"),
  #All of the data report goes to the main panel
  mainpanel = fluidRow(column(
    12,
    tabsetPanel(
      id = "tabs",
      tabPanel(
        "dashboard",
        #------Dashboard--------
        tags$h3("Dash Board Page"),
        plotlyOutput("lineplot")
        #-----End-------
      ),
      tabPanel("music",
               tabsetPanel(
                 id = "music_sub",
                 tabPanel(
                   "mus_pop",
                   #-----Music Popularity------
                   tags$h3("music popularity page"),
                   plotOutput("barchart")
                   #------End-------
                 ),
                 tabPanel(
                   "mus_pri",
                   #------Music Price Range---
                   tags$h3("Music price range Page"),
                   plotlyOutput("mapEx")
                   #------end---------
                   )
               )),
      tabPanel('sport',
               tabsetPanel(
                 id = "sport_sub",
                 tabPanel(
                   "sport_pop",
                   #-----Sport Popularity------
                   tags$h3("Sport Popularity Page"),
                   plotOutput("piechart")
                   #-----End------
                 ),
                 tabPanel(
                   "sport_pri",
                   #-----Sport Price------
                   tags$h3("Sport Price Range Page"),
                   dataTableOutput("datatable")
                   #-----------End-------------
                 )
               ))
    )
  ))
)
