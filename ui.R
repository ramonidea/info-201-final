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
                   "sport_pop"
                   #-----Sport Popularity------
                   
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
                    expensive. For any individual in these areas who loves to watch sports and, is not willing to spend a lot on 
                    a ticket, this would be a useful dataset. On the otherhand, the second table represents
                    the top 5 expensive tickets. Any sports fanatics around these areas who is willing to 
                    splurge for front row seat tickets would find this dataset helpful."),
                   tableOutput('cheapesttickets'),
                   tableOutput('expensivetickets'),
                   tags$br(),
                   tags$p("The bar graph below represents the price ranges for each of the top 5 populated states.
                          The states are color coded. Also, it is interactive as it shows the minimum, mean, and maximum
                          price for tickets when you hover over each of the bars."), 
                   plotlyOutput('bargraph'),
                   tags$br("The input filter allows the user to choose what sport they want to see on the US map.
                   More specifically the map shows what state has events associated to the sport selected. The 
                   darker the color the state is, the more expensive the ticket is."),
                   selectInput("sport", choices = getDropDownValues(), label = "Sport Type", selected = "Basketball"),
                   plotlyOutput('basketballmap')
                   
                   
                   
                   #-----------End-------------
                 )
               ))
    )
  ))
)
