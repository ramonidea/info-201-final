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
                   tags$h1("Sport Price Range Page"),
                   tags$br(),
                   tags$p("The two tables below focuses on the top 5 populated states in the US which includes
                    California, Texas, Florida, New York, and Pennsylvania. The first table represents the
                    the top 5 cheapest tickets among those states whereas, the second one focuses on the most 
                    expensive. According to the tables California and New York has the cheapest tickets.
                    For any individual in these areas who loves to watch sports and, is not willing to spend a lot on 
                    a ticket, this would be a useful dataset. On the otherhand, the second table represents
                    the top 5 expensive tickets. New York and Texs has the most expensive ones. Any sports fanatics
                    around these areas who is willing to splurge for front row seat tickets would find this dataset helpful."),
                   tableOutput('cheapesttickets'),
                   tableOutput('expensivetickets'),
                   tags$br(),
                   tags$p("The dot plot below represents the price range for tickets for the respective state. 
                     The blue dots show the most expensive tickets, whereas the pink dots show the cheapest
                     tickets. If you hover over any of the dots it presents the exact price for the ticket. 
                     You can see from the plot that New York has the highest price range for tickets while Pennsylvania
                     has the lowest one."), 
                   plotlyOutput('dotplot'),
                   tags$br(), 
                   plotlyOutput('mapbox'),
                   tags$br()
                   
                   
                   #-----------End-------------
                 )
               ))
    )
  ))
)
