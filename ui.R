library(shiny)
source("main.R")
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
        tags$h3("Dash Board Page")
        #-----End-------
      ),
      tabPanel("music",
               tabsetPanel(
                 id = "music_sub",
                 tabPanel(
                   "mus_pop",
                   #-----Music Popularity------
                   tags$h3("music popularity page")
                   #------End-------
                 ),
                 tabPanel(
                   "mus_pri",
                   #------Music Price Range---
                   tags$h3("Music price range Page")
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
                   tags$h4("Data Report:"),
                   tags$body(paste0("This is the data report for sports event popularity. 
                             The minimum number of event(s) of a state is ", 
                                    sports.pop.min, 
                                    " and the state(s) is ", sports.pop.min.state, 
                                    ". The maximum number of events of a state is ", 
                                    sports.pop.max, " and the state(s) is ", 
                                    sports.pop.max.state, 
                                    ". The average number of events per state is ",
                                    sports.pop.mean, " and the median is ", 
                                    sports.pop.median, ".")),
                   tags$h4("Sports Popularity Map"),
                   plotlyOutput('sports_pop_map'),
                   tags$h4("Number of Sports Events per State"),
                   plotlyOutput('sports_pop_bar'),
                   tags$h4("Distribution of Events of Top 5 States"),
                   plotlyOutput('sports_pop_pie')
                   #-----End------
                 ),
                 tabPanel(
                   "sport_pri",
                   #-----Sport Price------
                   tags$h3("Sport Price Range Page")
                   #-----------End-------------
                 )
               ))
    )
  ))
)